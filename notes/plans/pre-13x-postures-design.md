# pre-13x — POSTURES & RECOVERY: the two-mode simplification (design note + execution plan)

**Status: REVISED 2026-09-03 at the kickoff sitting (Fable, `/architect-phase` orchestrator) — the shape
below is SETTLED with the author across three rounds that day; her rulings are §1; §16 lists what is still
hers. NOTHING BUILT.** The 2026-09-01 text this revision replaces is in git history (the file as of commit
`e4609e4`); the architect's review that drove the revision is `notes/plans/pre-13x-design-review.md`
(committed, superseded where its §8 says so); **§18 below is the 2026-08-31 → 09-01 session record, kept
VERBATIM as history — its section numbers refer to the 09-01 numbering, and where it names a mechanism this
revision removed (the raw sync-key mirror, Replace Keys by account password, the store re-key at the
switch, the Fragments line) the revision wins.**

**Provenance:** the author's 2026-08-31 → 09-01 encryption-clarity thread produced the two-posture model;
the 2026-09-03 kickoff sitting simplified its mechanisms — the bridge retired, the account password out of
every key door, Replace Keys gone as a user door, one Apple-held key with every Apple leg a WRAP under it.
When ratified this file SUPERSEDES `notes/plans/pre-13u-memo-security-shapes.md` and dissolves most of
QUESTIONS #81 and #87; the 13p constitution's R13p-5/6/7/9 are superseded where §1 says so. **Cast: Fable**
(the phase touches `Sources/VariorumCore/Sync/` and the crypto seams — the standing rider). **Placement:**
its own in-between phase before 13y; separate from 13x (portability). **17i is NOT in this phase** (R-cor-13,
2026-09-02).

---

## 0. KICKOFF MESSAGE (for the fresh session that builds this)

Read, in order: `CLAUDE.md`; this file whole (§18 last — it is history); `notes/plans/pre-13x-design-
review.md` (why the shape is what it is; do not re-derive its traces); `notes/plans/phase-13p-note-
protection.md` §THE DESIGN + R13p-1…16 (what you are simplifying); `notes/plans/phase-14b-suite-e2ee.md`
§THE DESIGN (the vault you are extending); `notes/SessionResiliencyProtocol.md`. Then the code:
`App/Variorum/Shared/{StoreProtection,StoreKeyGuard,ProtectionController,EncryptionKeychain,
EncryptionSession,StoreLaunchGate,AppBootstrap,ProtectionShapes,StoreBackup,AuthSession}.swift`,
`Sources/VariorumCore/Persistence/{StoreKey,StoreKeyEnvelope,StoreBinding}.swift`,
`Sources/VariorumCore/Crypto/{KeyVaultFormat,KeyVaultClient,VaultEnrollment,AccountRekey,AccountDeletion,
PassphraseKDF}.swift`, `Server/supabase/{08_phase14b_lockstep,09_phase14c_multitenant,10_phase13j_purge}.sql`.
The 13b constitution P-1…P-9 binds this phase BYTE-VERBATIM as written in `.claude/skills/architect-phase/SKILL.md` (read it there; not re-copied here to keep this file readable in full). Do first: §15 batch 0 (the measurements), then batch 0b (the bridge set-aside — its own cold review).
Verify by: §15's per-batch gates, the two drills, her walk on both devices.

---

## 1. HER RULINGS (binding; the 2026-09-01 fifteen with their 09-03 supersessions, then the 09-03 set)

**From the 2026-09-01 sitting:**
1. **Two postures, nothing else** — **Standard** and **Castle**. *"Either choose full lockdown with the
   responsibility that implies of KNOWING YOUR PASSPHRASE… or, if you don't care about encryption, your
   fate is in apple / iCloud / your iCloud's hands."*
2. **Delete the dial matrix**: the escrow dial, both presets, the separate "require Touch ID to unlock sync"
   gate, the loss-legs matrix, the recipes table. *"users are NOT going to understand this."*
3. ~~Anyone with any device that opens the library + their account must be able to set a new passphrase;
   biometrics confirm where present, else the account password.~~ **SUPERSEDED 09-03 (ruling 18):** the
   account password confirms nothing about keys. Standard: any open device may set a new passphrase.
   Castle: Touch ID / Face ID, else the twelve words; an always-ask device typed the passphrase to open.
4. **Sync keys live INSIDE the encrypted library** in both postures. ~~Standard additionally mirrors them to
   iCloud Keychain.~~ **SUPERSEDED 09-03 (ruling 17):** no raw key ever sits in iCloud — Standard adds one
   Apple-held KEY and a WRAP under it.
5. **Turning on sync always requires a passphrase + a recovery phrase.** Reaffirmed 09-03 and extended:
   so does entering Castle; the ceremony impresses both on Standard users too.
6. **Standard users may set a passphrase / recovery phrase too** — and Standard SYNC users always have both.
7. **Sync keys and the session are device-bound.**
8. **Custody items scoped per STORE ID.**
9. **The plaintext SQLite export is BACK** (reverses R13p-8's "never"): re-authenticated, warned, user-chosen
   destination, never scheduled; the local sync tables never leave with it.
10. **Account deletion authorizes by the ACCOUNT PASSWORD** and must be reachable when signed in but not
    enrolled.
11. **The recovery phrase is MANDATORY at Castle enrollment** — generated, written down, confirmed by re-entry,
    ONCE. (With ruling 5's extension: at sync setup too.)
12. **A passphrase change refreshes the key files in the on-disk backup folders** — extended 09-03 to words
    regeneration and posture changes.
13. **Castle keeps the idle-minutes re-lock dial** (reads SYSTEM idle — tabbing out never locks).
14. **The absent-store route is re-ruled**: never a silent reset.
15. ~~17i is pulled into this phase.~~ Withdrawn 2026-09-02 (R-cor-13): 17i runs after, on the settled path.

**From the 2026-09-03 kickoff sitting (verbatim-faithful where quoted):**
16. **The Fragments bridge is RETIRED** — *"it's just on there due to history… if I had a feature list for
    each app's v1, the bridge wouldn't be on there."* Preserved on a branch; removed from `main` as its own
    batch (0b) with its own cold review, BEFORE any key work. No postures per app, no suite-level posture
    floor, no frozen vault format. If it ever returns it returns as shared rows in a collaboration era.
17. **One Apple-held key; every Apple leg is a WRAP under it.** Standard = the vault and the key file each
    carry one extra box that the Apple key opens; Castle = they do not. The raw sync-key iCloud mirror the
    09-01 design had is NOT built.
18. **The account password never touches keys.** It signs you in and can delete your account. It authorizes
    no passphrase change, no export, no key act, in either posture. *"if standard's leg is in the vault,
    I agree nobody needs an account password road. you either have your passphrase or it's in the vault."*
19. **Posture is the ACCOUNT's.** *"if your phone is standard, your mac can't be castle mode — that's
    obviously an issue."* Castle on one device is Castle for the account; every device gates. The gate
    STYLE (Touch ID vs always-ask; the idle minutes) stays per device.
20. **No Replace Keys door, no "rotate keys" in v1.** *"I'm not feeling like 'rotate keys' is a need in v1…
    if a castle switcher believes their apple account was compromised, they should just delete their
    stargazing account fully and reupload."* The declined door's ideas are recorded in §13.
21. **Sync setup ADOPTS a library that synced under another account** (re-stamp + full re-upload), so
    delete-then-recreate works; **re-enrollment re-initializes sync** so nothing strands.
22. **Changing the posture in EITHER direction re-authenticates** — *"you should need the passphrase or
    touchid to CHANGE the mode into standard — why not, right?"*
23. **Secret-changing doors in Castle re-authenticate** (current passphrase; forgot → Touch ID, else the
    words) — accepted as cheap: *"shouldn't be an issue for a user that got into the session, so whatever."*
    In Standard any open device may change it (ruling 3's replacement).
24. **The open-app attacker is NOT a gate.** *"If you leave variorum itself unlocked there's nothing we can
    really do security wise about that… the point is to distinguish it from apps like Day One."* Likewise
    a compromised Mac, a keylogger, a debugger on the running app: out of scope, said once in copy.
25. **The key file beside backups is NEVER overwritten** by a different key's file — *"that absolutely
    shouldn't happen."*
26. **Sign out everywhere** is a phase deliverable — *"the real mitigation."*
27. **Castle's honest floor stands:** *"if you're in castle mode, you NEED TO KNOW your passphrase or your
    12 words. we cannot save users from that simple fact."* Standard's floor stands too and is said:
    *"if all of their apple devices are stolen + they keychain reset, only the 12 words or passphrase would
    save them still."*
28. **The tutorial and Variorum Mobile change with this phase** (her instruction at the go).

---

## 2. THE MODEL (what users are told — the whole of it)

Both modes: your library is encrypted on disk, and sync is end-to-end encrypted — **the Variorum server can
never read your writing in either mode.** The only difference is **who holds a key.**

| | **Standard** (default) | **Castle** |
|---|---|---|
| who holds a key | your Apple account — iCloud Keychain, and Apple's recovery paths (device passcode · recovery contact · recovery key) | only you: your passphrase, your twelve words, and your enrolled devices behind Touch ID / Face ID |
| opening | silently, on any device signed into your iCloud | Touch ID / Face ID with the passphrase as fallback, or the passphrase every time |
| a new device | sign into iCloud + sign into Variorum → everything, nothing typed | sign in + type your passphrase (or twelve words), once |
| who it stops | the Variorum server: **yes**. someone at your unlocked Mac: **no** — anyone who can launch Variorum as you can read, and can set a new passphrase. someone fully in your iCloud: **no** | the server: **yes**. your Mac's login password: **yes** — nothing on this Mac releases the key to it. someone in your iCloud: **yes**. someone holding your secrets or an enrolled finger: **no** |
| if your computer dies | **with sync:** sign in + iCloud brings everything back. **without sync:** iCloud holds a KEY, not your writing — you need a copy of the library that survived the Mac (the backup folder placed in iCloud Drive, or Time Machine) | **with sync:** sign in + your passphrase. **without sync:** a surviving backup + your passphrase or twelve words |
| the floor | lose every Apple device AND every Apple recovery path AND both secrets | lose every enrolled device AND both secrets — **gone; nobody can help, and that is the point** |
| the ceremony | at sync setup: passphrase + twelve words, once, with the sentence: *"keep your twelve words even in Standard — they are your way back if you ever lose your Apple account"* | at the switch or at sync setup: passphrase + twelve words, once, with the floor said as the sign the lock is real |
| optional | — | "always ask for the passphrase instead of Touch ID"; lock after N idle minutes |

**The keystone lines (verbatim-class, kept):** *"An unlocked, enrolled device is as powerful as your
passphrase. Touch ID guards this device — your passphrase is what lets a new device in."* (Castle) · *"Sync
brings your writing back to any device"* — *"…through your Apple account"* (Standard) / *"…as long as you keep
your passphrase or twelve words. We can never reset it for you: that's what end-to-end means."* (Castle) ·
**"Your account password signs you in and can delete your account. It never touches your keys."** (both) ·
*"While Variorum is open and unlocked, everything in it is readable — that is what open means. Locking is how
you end that."* (both; the shipped `openAppIsReadable` line).

**The two design laws (the architect's, ratified by the shape):** a SECRET or an ENROLLED DEVICE authorizes
every key act — never an account credential. iCloud holds a KEY TO A BOX — never the contents of a box.

---

## 3. THE MECHANISMS

### 3.1 The pieces (internal vocabulary; users meet "your key", "your passphrase", "your twelve words")

| piece | what | where it lives |
|---|---|---|
| **P** the passphrase · **W** the twelve words | the two secrets; W is P's twin | in the user's head / on paper — NEVER stored |
| **M** the master key | one random 256-bit key per ACCOUNT, minted at sync setup; decrypts everything in sync through the class keys it wraps | inside every enrolled library (`sync_state`); in the vault only as BOXES |
| **C** (and the dormant **J**) | the corpus class key (and the journal-bridge class key the vault format still carries — minted, never used) | wrapped under M in the vault; inside enrolled libraries |
| **L** the library key | one random 256-bit key per LIBRARY FILE; what SQLCipher decrypts the file with | RAW in exactly one place per device — the device Keychain (Standard: the bound plain item, silent; Castle: the `.biometryCurrentSet` item, or NONE under always-ask); in the key file only as BOXES |
| **A** the Apple key | one random 256-bit key per iCloud account; minted the first time a Standard library exists on this iCloud (the ceremony-free first launch included — so a brand-new Standard library has its Apple box from day one), or read if it already exists | ONE iCloud-synchronizable Keychain item (no access control — Apple does not sync ACL'd items; `AfterFirstUnlock`; the SHARED access group, §3.7); read by the app, never by us |
| **the vault** (server, per account) | M boxed under P (with P's KDF descriptor) · M boxed under W · **[Standard] M boxed under A** (+ `apple_key_id`) · C and J boxed under M · the `revision` CAS · **the key-proof token hash (§3.8)** | `key_vault`, owner-only RLS, via PostgREST; read needs a session; WRITE needs a session + the key proof |
| **the key file** (`variorum-keys-<fp>.json`, beside each library and in every backup folder) | format 2: `storeID` · L boxed under P (+ descriptor) · L boxed under W · **L boxed under M** ("the master box") · **[Standard] L boxed under A** ("the Apple box") · the vault's `corpusKeyID` last reconciled against · `keyFingerprint` | non-secret; holding it grants nothing |
| **the session** | the account's tokens | the data-protection Keychain, `ThisDeviceOnly` — a cloned Mac signs in again |
| **posture** | DERIVED, never a setting: the ACCOUNT is Standard ⇔ the vault has an Apple box; a LOCAL-ONLY library is Standard ⇔ its key file has an Apple box; an enrolled library's key file must agree with the vault (reconciled at every ready launch/unlock and at enrollment) | nowhere else |
| Castle's two switches + the idle dial | per device, UserDefaults per store ID | as today |

"Box" = the key encrypted under another key (RFC 3394 `AES.KeyWrap`, exactly as `KeyVaultFormat` and
`StoreKeyEnvelope` already do it; a wrong key REFUSES, never yields bytes). The passphrase box is the only
brute-forceable one (Argon2id, the v1 descriptor, `PassphraseKDF`); every other box is under a random key.

### 3.1b Every credential — what unlocks it, what it unlocks, where it stays (per posture; her table, 2026-09-04)

| credential / key | what unlocks it | what it unlocks | where it stays — Standard | where it stays — Castle |
|---|---|---|---|---|
| **the account password** | your memory (resettable by email) | sign-in (a session); account deletion. **Never a key.** | your head / password manager; the server holds a hash | same |
| **the session** (tokens) | sign-in | fetching the vault's boxes; and — only together with the key proof — sync | this device's Keychain, device-bound; cleared by sign-out | same |
| **the passphrase** P | your memory | the library key (the key file's P box); the master (the vault's P box); enrolling a new device | nowhere | nowhere |
| **the twelve words** W | the paper | exactly what P unlocks | nowhere but paper | nowhere but paper |
| **the Apple key** A | being signed into your iCloud on a trusted device (iCloud Keychain, end-to-end encrypted; Apple's account recovery) | the library key (the key file's Apple box); the master (the vault's Apple box) | ONE item in iCloud Keychain, readable only by Variorum | the item may exist (it was minted before, or serves another library on this iCloud) but **no box opens with it** |
| **Touch ID / Face ID** | a finger/face enrolled on this device's user account | the gated library-key item | not used to open (silent open instead) | the Secure Enclave gates the item; adding a fingerprint invalidates it (P recovers) |
| **the library key** L | silently, this device's Keychain (Standard) · the gated item (Castle) · or ANY box in the key file: P, W, the master, A | the library file (SQLCipher decrypts pages with it) | raw: this device's Keychain, bound to the hardware. Boxed: the key file beside the library and in every backup folder (P, W, master, **Apple**) | raw: the gated item, or nowhere (always-ask). Boxed: the key file (P, W, master — **no Apple box**) |
| **the master** M | any vault box (P, W, A) — or it is already inside an open enrolled library | the class keys → everything in sync; the master box in every key file → the library key; the key proof | raw: inside every enrolled library. Boxed: the vault under P, W, **and A** | raw: inside every enrolled library. Boxed: the vault under P and W only |
| **the class key** C | the master | the text on the server | inside enrolled libraries; the vault under M | same |
| **the key proof** | derived from the master | the right to read or write the sync copy, and to update the vault | computed on demand by any device holding M; the server keeps only its hash | same |
| **the key file** | nothing — it is boxes | nothing alone | beside the library; in backup folders; public | same |

**Read it as two sentences.** Standard: Apple holds A; A opens a box in the key file and a box in the vault;
those boxes hold L and M; L opens the file, M opens sync. Castle: no box opens with A; only P, W, an
enrolled device's Touch ID, or the master already inside an open library reach L and M.

**A deleted-then-recreated account, in these terms:** the old vault (M's boxes) is gone with the account;
A, the key file, and L are untouched, so every library and backup opens as before. The new account's setup
mints M′, seals it in NEW boxes (under P, W, and — Standard — the SAME A) in a NEW vault, and puts M′ inside
the library beside its rows, which re-stamp and re-upload. So yes: a new boxed master exists — on the
server, under the same Apple key. Nothing in iCloud changes.

### 3.2 Sync keys inside the library
`sync_state` is local-only, never synced, and lives inside the SQLCipher store; `resyncReinitialize` spares
its non-bookkeeping rows. M, C (+id) and J (+id) land there as base64 rows. `DeviceKeySyncProvider`
becomes a DB-backed implementation of the same `SyncKeyProviding` seam (synchronous by contract — a cached
read refreshed on write; a locked library reads as no keys and the engine refuses its round visibly).
**Zero schema, zero lockstep for this piece.** Consequences: one engine read path in both postures; a FRESH
library has no keys and can only ask (P/W, or — Standard — the Apple road); `E2EEKeychainStorage`,
`E2EELaunchKeyCache` and the CF-12 gated twin are deleted. **The plaintext SQLite export (§4) NEVER copies
`sync_state`, `sync_outbox`, `sync_row_seq`, `_sync_applying`, `purge_*`** — it is produced by a keyed
`sqlcipher_export` into a plaintext ATTACHed file that receives only the synced tables, never copy-then-
strip (a stripped copy leaves M in free pages).

### 3.3 The key file, format 2 — the master box and the Apple box
`StoreKeyEnvelope` gains: `master: Data?` (L under M); `apple: Data?` + `appleKeyID: String?` (L under A);
`vaultKDF: PassphraseKDF.Descriptor?` + `vaultCorpusKeyID: String?` (what the local P box was last
reconciled against); files are named by key fingerprint (`variorum-keys-<fp>.json`; the legacy
`variorum-keys.json` reads as format 1 for the store's current key). Written at enrollment, at every
re-wrap, at every posture change. Format 1 files read as "no master box, no Apple box, unknown descriptor."
**The master box is what makes both local secret boxes CACHES**: any device holding M can extend its own key
file with no visit (§11's backfill), and the twelve words open a Castle library ONLINE through the vault
before the local W box has ever been landed on that device.

### 3.4 The lobby (Castle) — three roads + two rules
Roads: **Touch ID / Face ID** (the gated item) · **the passphrase** · **the twelve words**. The two secret
roads try the LOCAL box first (the offline cache), then — on failure, signed in and online — **the vault
road**: derive per the vault's descriptor → unwrap M → the key file's master box → L → open → re-wrap the
local P box + record the descriptor and the vault's `corpusKeyID`. The pre-unlock network contact is ONE
authenticated vault READ (boxes only — §3.8: a session without M can fetch boxes and nothing else).
**Rule 1 — a retired passphrase dies when the vault can be reached, but ONLY when it is the SAME master:**
online, if the vault's descriptor ≠ the key file's recorded one AND the vault's `corpusKeyID` == the
recorded one, the typed passphrase is verified against the VAULT, never the cache — the old one is refused
with *"your passphrase was changed on another device; enter the new one."* If the `corpusKeyID` differs,
the library's master is from a DIFFERENT vault (a deleted-then-recreated account, a library moved between
accounts): the local box STANDS as a road, and after unlock the device lands in *"this account's keys don't
match this library — re-enroll"* (CF-16's state; the enrollment row in §4 re-stamps and re-initializes). **A change on another account can
never lock a device out of its own library** (pinned).
**Rule 2 — offline grace, stated:** offline, the cached box opens; the device catches up at its next
connection via the post-unlock one-time prompt (*"enter the new passphrase to update this device"* — the
device opened by Touch ID and never typed anything). Regenerated words take the same road; the local W box
re-lands the first time the words are typed anywhere on that device.

### 3.5 The absent-store route — RE-RULED
Today (`StoreLaunchGate.swift:198`, `AppBootstrap.swift:236`, shared by both apps): a demanded mode over an
absent store resets the mode and mints a fresh library. New rule: *"your library file is missing — restore
it, open an existing library, or start a new one"* — the lock STAYS; starting new is a deliberate act that
mints under a NEW store ID (per-store-ID custody, ruling 8, makes the old items unreachable but never
deleted). On a Castle ACCOUNT a new library cannot get M without a secret (no Apple box exists), so the
2026-09-01 read hole (§18-A1) is closed twice over.

### 3.6 Standard's open road
Auto-open from this device's bound Keychain item. Missing item (a restored copy on a fresh device; a wiped
Keychain): the key file's Apple box via A from iCloud Keychain — and, for a sync user, A → vault → M → the
master box as a second road. A absent (iCloud Keychain lag, iCloud Keychain off, no Apple ID): a real
**"waiting for iCloud Keychain"** state with two doors — *"enter your passphrase / twelve words instead"* and
*"open an existing library"* (13x). Never a silent mint over an existing store. The T2 three-value probe
(covered / exposed / unknown) survives as this state's verdict; the nudge keeps two tiers + the honest
unknown: *"iCloud Keychain is off on this Mac — write down your twelve words."* **Propagation latency is
unbounded in practice** (§7 of the review: community reports from seconds to hours; no Apple number), so the
waiting state and its passphrase door are load-bearing, not a corner.

### 3.7 The shared keychain access group (measured gap — the review's P8)
The Mac declares `$(AppIdentifierPrefix)$(PRODUCT_BUNDLE_IDENTIFIER)`; the iOS target declares nothing, so
its default group is `…io.lduarte.VariorumMobile`. An iCloud item written on one is INVISIBLE to the other,
so no Standard cross-device story exists until this is fixed. Both targets gain a SECOND group,
`$(AppIdentifierPrefix)io.lduarte.Variorum.shared` (the first, default group stays, so nothing already
written strands — the gated store-key item, the bound item, her migrated items all stay where they are),
and every iCloud-synchronizable write names it explicitly via `kSecAttrAccessGroup`. The one iCloud item
this design writes is A. The Developer ID build must carry both groups (the standing KnownIssues row widens).

### 3.8 The key-proof token — a session alone can neither write the vault nor touch the mirror (the architect's condition, §19)
The server cannot verify P — that is E2EE — so today any session for the account can PATCH the vault row
and push rows (tombstones, garbage ciphertext) through `sync_push`. Close it with one derived value:
**`kp = HMAC-SHA256(M, "variorum.key-proof.v1")`**, computed by every device that holds M, presented on
every `sync_push` / `sync_pull` call and on every vault UPDATE, stored server-side only as `SHA-256(kp)` in
`key_vault` (written at vault creation), compared in constant time inside the RPCs. The vault's PostgREST PATCH is replaced by a SECURITY DEFINER
`key_vault_update(payload, expected_revision, key_proof)` that carries the CAS inside it; vault CREATE stays a
session-only insert that sets the hash (no vault exists yet to protect); **a vault whose `key_proof_hash` is
NULL accepts its FIRST proof from any session** — the migration arm for her existing vault at the window,
harmless pre-launch and closed the moment the hash lands. Vault READ stays session-only (a new device
must fetch the boxes to obtain M). `account_purge` stays session-only (deletion
is mandated and loud). Consequences: **the account password alone can sign in, see nothing, push nothing,
delete nothing but the whole account**; a stolen or cloned session is inert against the corpus; the "poison
push" and "quiet tombstone" classes vanish; the pull side stops disclosing even the structure to a bare
session. Cost: two nullable columns on `key_vault` (`master_wrapped_by_apple_held`, `apple_key_id`) + one
(`key_proof_hash`) and a `key_proof` parameter on `sync_push`/`sync_pull`/the vault-update RPC — **ONE §12
lockstep event, marker 7 → 8**, in her deploy window (the 13j choreography: mirror first, then both her
devices' installs; the marker bump makes a pre-change build refuse cleanly instead of erroring on the new
signatures). The fake-server harness gains the check. 13y's per-tenant `server_seq` remains its own later
event.

---

## 4. THE DOORS (who · authorization · what changes · what other devices see)

| door | needs | authorization | changes | other devices |
|---|---|---|---|---|
| **Set up sync** (first device of an account) | an open library, signed in, no vault | the ceremony: P (verified against the library's own P box if one exists — one secret) + W generated/confirmed, ONCE | mint M, C, J; boxes under P, W, and (Standard) A — A read from iCloud Keychain, minted + written if absent; create the vault (+ `kp`); M/C/J into the library; the master box (+ Apple box) into the key file; **if the library's rows carry another owner's stamp or a foreign master: re-stamp every row + `resyncReinitialize`** (the deleted-then-recreated account, a library from another account) | — |
| **Enroll** (a device joins an existing vault) | a library (fresh or with content), signed in | Standard: A from iCloud → the vault's Apple box → M, nothing typed (P or W as the alternative). Castle: P or W → the vault → M | M/C/J into the library; the master box into the key file; the device's custody/posture reconciled to the account's; **if the library previously synced under a different master or owner: re-stamp + `resyncReinitialize`** — nothing strands | — |
| **Change passphrase** | an OPEN library | Standard: the current P if known; *forgot it?* → a plain confirm (this device holds the keys; the desk is conceded). Castle: the current P; *forgot it?* → Touch ID / Face ID on a gated device; an always-ask device typed P to open. The twelve words authorize everywhere (built) | vault: M re-boxed under the new P from HELD M (`rewrapPassphrase(material:)`); key file: L re-boxed; backup folders' key files refreshed (ruling 12) | keep syncing untouched (they hold M); learn the new P via §3.4 (the vault road + the one-time prompt) — which is also the tamper evidence |
| **Regenerate twelve words** | same | same as change-passphrase | new W box in vault + key file + backups | same road; their local W box re-lands when the words are next typed there |
| **Standard → Castle** | an open library, signed in if sync is on | the ceremony: P set if none; W generated + confirmed (ruling 11); Touch ID or P confirms (ruling 22) | remove the Apple box from the vault (an M-holder's CAS write, with `kp`) and from this key file; **strip the Apple box from the key files in the app's own backup folders** (a box removal, no re-key — cheap); move L's custody plain → gated (or → none under always-ask) through the existing `CustodyHandover` transition; re-lock on sleep/screen-lock ON; **A itself is NOT deleted** (it may serve other libraries or accounts on this iCloud, and it opens nothing once the boxes are gone). No store re-key, no re-upload | at their next ready launch/unlock they read the vault: no Apple box ⇒ the account is Castle ⇒ *"your account is now in Castle; this device will ask from now on"* → custody moves to gated, their key file's Apple box is removed, their backup folders' key files stripped. Until then a Standard device may open silently once more — stated |
| **Castle → Standard** | an open library | P or Touch ID (ruling 22) + the one consent sentence (*"your Apple account will hold a key"*) | read A from iCloud (mint + write if absent); add the Apple box to the vault (`kp`) and to this key file; custody gated → plain; re-lock off | at their next open: an Apple box ⇒ Standard ⇒ they adopt silent open with a one-time notice. (PROVISIONAL, §16: whether a device may keep a stricter local gate under a Standard account — recommended NO for v1: two postures, no hybrids) |
| **Delete account** | signed in (enrolled or not) | **account password** + typed confirmation | server copy + vault + login gone (the purge); LOCAL COPIES UNTOUCHED; the app signs out; keys stay inside the library; A is left in iCloud (it serves local libraries) | lose sync; keep everything local; a later account adopts them at setup |
| **Sign out everywhere** | signed in | — (it is the mitigation for a stolen password/session; Supabase `signOut(scope: global)`) | every other session revoked; keys untouched | sign in again |
| **Sign out** | — | — | clears this device's tokens; keys stay inside the library (the library is the gate); the CF-11 "forget keys" door is folded in (PROVISIONAL, §16) | — |
| **Plaintext `.sqlite` export** | an open library | Castle: P (never Touch ID alone). Standard: P if one is set, else a plain confirm | a decrypted copy WITHOUT the local sync tables (§3.2) to a user-chosen location; a plain warning; never scheduled, never into the backups folder | — |
| **Plaintext `.md` export** | — | unchanged (13l; the scheduled insurance opt-in, warned under Castle). PROVISIONAL (§16): the LIBRARY-wide export asks for P in Castle | — | — |
| **Lock Now / re-lock** | Castle | — | tears down services, drops key material (`StoreBinding.lock`) | — |

**What the account password can do, in BOTH postures:** sign in · delete the account · sign out everywhere ·
cancel. It can NEVER open a library, read or write the mirror (§3.8), change a passphrase, change a posture,
or export. **Its worst case is the loud one — the account deleted — which every local copy survives.**

**What "rotate" means now that no door does it:** delete the account and set sync up again under a new one
(a new M; the library re-uploads; the library's own key L is unchanged — see §13 for the declined rotation
door and the recorded manual road for L).

---

## 5. PASSPHRASE CHANGE vs. STARTING OVER (the one table users need)

| | change your passphrase | delete the account and set sync up again |
|---|---|---|
| what it is | a new word for the same locks (a re-box) | a new sync world: new master, empty server, your library re-uploaded |
| your library key | unchanged | unchanged |
| your sync keys | unchanged | NEW |
| the server's copy | untouched | gone, then re-uploaded from this device |
| other devices | keep syncing; need the new passphrase next time they ask for one | sign into the new account; Standard re-enrolls by iCloud, Castle by the passphrase; each re-uploads its own copy |
| twelve words | unchanged | new ones (the ceremony runs again) |
| old backups | open with the passphrase / words you had when their key file was last refreshed — the app keeps its own folders current; the master box lets the current passphrase open any backup of an un-deleted account online | open exactly as before (the library key never changed) |
| iCloud (Standard) | nothing changes — iCloud holds a key to a box, never a passphrase | nothing changes — the same Apple key opens the new vault's Apple box |

---

## 6. BACKUPS UNDER THE MODEL
The 13l backups are ciphertext + key file(s), launch-if-due + daily, 14 dailies + 4 weeklies
(`StoreBackup.swift`), made through GRDB `backup(to:)` from an OPEN keyed connection — under Castle they run
**at the first unlock of the day if due**. PROVISIONAL (§16): a keyless byte-copy at lock time when due (the
app's own folder only).
**The key file in a backup folder is named by key fingerprint and NEVER overwritten by a different key's
file** (ruling 25) — a folder holds one per library key it has ever held; new snapshots carry the fingerprint
in their filename so the restore surface pairs them; legacy `variorum-keys.json` serves legacy snapshots.
Refreshed on every passphrase change, words regeneration and posture change (ruling 12, extended).
**The one user sentence, true in every case:** *"A backup opens with your twelve words — always, unless you
regenerated them — or the passphrase you had when it was made; and, in Standard, through your iCloud."*
Disclosed once at the Castle switch: *"backups made before today that live outside Variorum's own folders
(Time Machine, copies you made) can still be opened through your Apple account."* The runbook
(`notes/DataSafetyRunbook.md`) is rewritten for two postures; same-Mac erase-and-restore: Castle reopens by
passphrase, Standard by iCloud — proven in the drill, never assumed.

---

## 7. CROSS-DEVICE CHOREOGRAPHY (Mac + phone)
**A passphrase change (both Castle):** 1. Mac (open): re-box M in the vault (CAS + `kp`), re-box L in its key
file, refresh its backups. Phone untouched, keeps syncing. 2. Phone, next open by Face ID: the post-unlock
reconcile reads descriptor ≠ recorded, same `corpusKeyID` → the one-time prompt → on success re-box +
record. 3. Phone, next open by passphrase, ONLINE: Rule 1 → OLD refused with the sentence; NEW opens via the
vault road. 4. Phone OFFLINE: the old one opens (cache); step 2 fires at the next connection. 5. Both change
at once: the vault's CAS refuses the second; it re-reads and retries. The same steps serve Standard and a
regenerated phrase.
**A posture switch:** the acting device changes the vault (§4); every other device reads the vault at its
next ready launch/unlock and follows (Castle: adopt the gate; Standard: adopt silent open), with a one-time
notice naming the device and day. Offline devices follow when they connect — the same grace as Rule 2.
**A deleted-then-recreated account:** §4's setup + enrollment rows; the phone sees "keys don't match" and
re-enrolls (Standard: nothing typed) with re-stamp + re-init.

---

## 8. COMMUNICATION CHANGES (every surface)
- **ALL user-facing text is `notes/plans/pre-13x-copy.md`** (written 2026-09-03; render, don't re-derive).
- **Protection pane** → the two-posture chooser (Standard default; Castle behind the ceremony) + Castle's
  two switches + the idle dial + Lock Now. Presets / escrow / loss legs / sync-gate sections deleted.
- **`ProtectionShapes`** → §2's table rendered; two what-ifs per posture; the keystone lines; the two design
  laws in the field guide. "Render, don't re-derive" binds: §2 IS the copy.
- **Tutorial "keeping it private"** (ruling 28) → rewritten to §2 + §5: the two postures, the ceremony's two
  secrets and why Standard users keep them too, the change-vs-start-over table, the open-app sentence, the
  Standard floor and the Castle floor; re-seeded through the seeder's replace door; the walk asserts both
  postures and both floors are named.
- **Backups tab** (`DataSafetyCopy`) → §6's sentence per posture; "backups run while your library is open"
  under Castle.
- **Encryption tab** → setup / enroll / change / regenerate / sign out everywhere / delete under §4's
  authorizations; the biometric-sync toggle, the forget door, the reset door and the Replace Keys door GONE;
  the not-enrolled state shows delete/cancel.
- **The nudge** → two tiers + unknown (§3.6). **The unchosen indicator** → "Standard".
- **The sync signup ceremony** → passphrase + twelve words + one sentence per posture on what iCloud does +
  Standard's keep-your-words line.
- **Mobile** (ruling 28; §9) — the same shared faces; the posture chooser; the account-posture reconcile;
  the ceremony; the shared access group.
- **The tier sentence** (13t) → posture-conditional (§2). **Runbook** rewritten; **KnownIssues** rows
  resolved (the E2EE custody residual; the clone row; the Castle-bypass row; the copy-ahead-of-code row; the
  staleness row); **QUESTIONS #81 / #87** dissolved as listed at closeout; the memo superseded.
- **Outbound brief re-issued**: the stargazing privacy-policy brief (two postures; the plaintext export; the
  disclosure envelope SHRINKS — a bare session no longer reads structure, §3.8).
- **Marketing discipline:** Castle is the headline; Standard's sentence must survive the landing page; and
  the Day One contrast is the true one — *"the file itself is ciphertext, and in Castle the key that opens
  it is not on your Mac in any form your login password can release."*

## 9. MOBILE
All faces are shared code; the phone changes with the Mac inside this phase (MobileSoul §6 "design
together"; ruling 28). Phone specifics: Castle = Face ID with the passphrase as fallback (every iPhone has
biometrics; "always ask" remains the one switch); Standard = iCloud Keychain (present when signed in);
quick capture demands unlock under Castle (unchanged); the phone is a first-class birthplace of libraries
and of Castle; **the phone follows the account posture like any device** (§7); the iOS target gains the
shared access group and A's item family; the iOS device-backup fact is stated in copy (a keychain item in
an iCloud device backup restores only to the SAME device — a new phone receives A through iCloud Keychain
SYNC, so the road is "sign into iCloud, open Variorum," never "restore the backup"). Parity ledger line at
closeout.

## 10. THE FRAGMENTS BRIDGE — RETIRED (ruling 16)
Batch 0b (§15) sets it aside on a branch and removes it from `main`: `Sources/VariorumCore/Bridge/` (6 files,
2,226 lines), `BridgeSession.swift`, `BridgeStatusViews.swift`, the Fragments-project delegated session in
`AuthSession.swift` + `SignInFlow.swift`, the bridge legs of `AppServices.swift` / `SyncSession.swift`, the
`DeviceBridgeKeyProvider`, `AccountRekey.swift` step 6, 13 core test files + 2 app wiring tests, the 13v
row (→ retired in FuturePhases), the bridge paragraphs of AppSpec §7/§9, SyncSpec §3, CoreDescription §8's
9b mention, MobileSoul's bridge lines, and this file's Fragments lines. **Kept:** the vault's `journal_bridge`
class key column (NOT NULL; minted, dormant, one comment), `DeviceKeyMaterial.journalBridgeKey` (format).
**One outbound carry item** in `notes/fragments-bridge-contract.md` for her to hand the Fragments agent: the
bridge is retired for now; 20.10's ceremony is moot; Fragments' own journal encryption is its own business;
the ONE Stargazing account and the suite issuer (14a/14d) are UNCHANGED. 13i-e loses its "the bridge cannot
be rebuilt" reason for the daily Journal's undeletability; its identity half stands on its own.

## 11. MIGRATION (existing stores — pre-launch: hers and the phone)
**There is exactly ONE existing enrollment — the author's two devices**, run in her presence; no population
migration exists. Her Mac (Biometric mode, escrow already removed by the 09-01 coupling) and her phone map
to **Castle**: at first unlock, move the E2EE Keychain material into `sync_state`; delete the plain + gated
E2EE items; re-bind the tokens; retire the dial keys; write the key file's master box + descriptor +
`corpusKeyID` from HELD material (no visit, no typing — this alone gives the vault road); compute and land
`kp` in the vault (an M-holder's write) at the lockstep window; the passphrase box follows the first time
the passphrase is typed anywhere (the migration may ask ONCE — *"confirm your passphrase to finish"*). The
vault gains no Apple box (Castle). `sync_state` keys and the custody scope migrate to store-ID naming; the
existing gated store-key item stays under the app's own group. Every migration leg logs a line (the 13p
launch-log pattern — that log is what let the 09-01 incident be diagnosed).

## 12. TESTS & PINS
Red-on-old for every mechanism: keys-in-library (a fresh library cannot sync without a secret or, in
Standard, A; the absent-store route never opens a pullable library); the key-proof token (a session without
`kp` cannot push, pull, or PATCH the vault — and CAN fetch it and CAN purge); Rule 1 with the key-id
distinction (a retired passphrase refused online under the same master; a foreign master never locks a
device out; offline opens old); the master box (the current passphrase opens an old backup online; the
twelve words open a library whose local W box was never landed); the Apple box (a Standard new device
enrolls with nothing typed; a Castle vault carries none — pin the ABSENCE; the switch strips the app's
backup key files); posture derivation + follow (a Standard phone under a Castle account gates at its next
open; a Castle→Standard switch propagates); the plaintext export carries no local sync table and no
key-shaped value; per-store-ID custody; per-fingerprint key files (a second key's file never replaces the
first); setup adopts a foreign-stamped library (delete → recreate → every row syncs); re-enrollment
`resyncReinitialize`s (a row the server lost is re-pushed, not stranded); deletion reachable when not
enrolled; the 12-character floor; the descriptor floor on read (§19); "never wrap under a network-supplied
key" (§19); the shared access group on both targets (an entitlements pin); the memo's verbatim pins REPLACED
by §2's. The convergence suites gain §7's choreography against the fake server (which gains `kp`). Both
drills re-run: the 13p migration drill on a byte-copy of her real store, and the 13l restore drill per
posture, on both devices.

## 13. WHAT GETS DELETED — and the DECLINED doors, recorded
**Deleted:** `StoreAtOpenMode` as a three-way setting (posture + gate style replace it), `ProtectionDials
.escrowOn` + `effectiveEscrowOn` + the coupling copy, `ProtectionPreset`, `ReminderCheckPolicy` as a dial
(Castle: always on), `relockOnSleepAndScreenLock` as a dial (Castle: always on), the CF-12 sync gate +
`E2EELaunchKeyCache` + `E2EEKeychainStorage` (custody moves into the library), the escrow item family
(`StoreKeyGuardKeychain` escrow arms — A's family replaces it), the CF-11 forget door (PROVISIONAL — folded
into sign-out), the R13p-9 reset door as a separate door (merged into change-passphrase), **`AccountRekey`
as a user door + `RekeyRecencyProbe`'s UI caller** (the brain survives for the headless `vault-bootstrap`
tool only), `lossLegs`/`lossMath`, the recipes/need-states/shapes tables, the escrow verify-landed probe,
`openResettingModeToAuto`, the bridge (§10).
**Declined for v1, ideas recorded (ruling 20):** a user-facing key rotation ("Replace Keys" / "Rotate
keys"). If it ever returns: from an ENROLLED device only; authorized by P or W (never the account password);
the count-and-dates recency warning + a typed confirmation phrase; "keep my twelve words" by typing them;
never from a library with no writing of its own; re-enrolling devices re-initialize. **The manual road that
exists instead:** delete the account and set sync up again (rotates M). **L is not rotated by any v1 road**
— the recorded workaround is the plaintext export opened as a NEW library (13x's open-an-existing-library
door can adopt a plaintext SQLite by encrypting it under a fresh key — the 13p migration road), losing
nothing. Also declined: a per-device stricter gate under a Standard account (hybrids); L rotation at the
Castle switch.

## 14. EDGE CASES & CORNERS (each is a step, not a deferral)
1. The plaintext export never receives local tables (§3.2). 2. Deletion/cancel reachable when not
enrolled. 3. Custody per store ID. 4. The Castle switch strips the app's backup key files' Apple boxes;
outside copies disclosed (§6). 5. A is never deleted — it opens nothing once the boxes are gone; it serves
other libraries/accounts on the same iCloud. 6. Two libraries on one Mac with different postures joining one
account: the second adopts the account's posture with consent at enrollment. 7. Old backups after a
deleted-then-recreated account hold the OLD M in `sync_state` — useless (the old vault is gone) and the
restored library lands in "keys don't match — set up sync again." 8. Backups run at unlock-if-due under
Castle; freshness copy never cries wolf. 9. Same-Mac erase-and-restore proven in the drill. 10. iCloud
Keychain lag/off: the waiting state + the honest unknown. 11. Offline grace after a passphrase change or a
posture change, stated. 12. Apple's account-recovery paths named in Standard's sentence. 13. Two Variorum
accounts on one iCloud share A — each account's boxes are its own. 14. Sparkle relaunch → lobby (verify).
15. Quick capture/hotkey under Castle demands unlock (unchanged, re-verified). 16. The pre-unlock vault
read is the ONE network contact before unlock; a locked device never syncs; with `kp` a locked device's
session fetches boxes and nothing else. 17. Two devices changing at once → CAS refuse + retry. 18. A Castle
"always ask" Mac + forgotten passphrase + no words = the floor; the ceremony says so. 19. A Standard user
with iCloud Keychain OFF and no secrets is the ONLY unrecoverable Standard state — the nudge's whole job.
20. Time Machine / Migration Assistant of a Castle Mac carries nothing usable (keys inside the library;
tokens bound; the gated item hardware-wrapped); of a Standard Mac carries what iCloud carries anyway.
21. Any finger enrolled on the macOS user account passes Touch ID — copy: *"anyone whose fingerprint is
enrolled on your Mac account"*; always-ask is the shared-Mac answer. 22. The recovery phrase's COPY ALL
clears the clipboard after 60 s (Universal Clipboard). 23. A Standard account's Apple box can be REMOVED
only by an M-holder (`kp`) — an account-password holder cannot flip a posture in either direction. 24. The
client never wraps M or L under a key it received from the network; A is read from iCloud Keychain or
minted locally, never from the server (§19). 25. "Pause sync" is 18a's; "rotate" is §13's.

## 15. BATCHES (strictly sequential; each red-on-old; the tutorial spine green every batch)
0. **Measure + spike**: A's item written under the shared group on the Mac and read on the phone (and the
   reverse) — propagation observed on two real devices; the pre-unlock vault read's latency; a same-Mac
   restore of `ThisDeviceOnly` items characterized; the `key_proof` RPC change drafted against the fake
   server. Decision memo → her.
0b. **The bridge set-aside** (ruling 16): `git branch fragments-bridge-archive` at `main`; the removal on
   `main` (§10); the canon deltas; the outbound carry item; ITS OWN cold review (a FRESH Fable reviewer — the diff
   touches `AuthSession` and `Sync/`-adjacent seams).
1. **Substrate**: keys into `sync_state` + the DB-backed provider (Sync/); key file format 2 (master box ·
   Apple box slot · descriptor + `corpusKeyID` · fingerprint naming); the vault's additive columns + `kp`
   (`KeyVaultFormat` format field + wire row; the RPC parameter; the fake server); the shared access group
   on both targets; device-bound tokens; per-store-ID custody; the absent-store re-rule. **The §12 lockstep
   event (marker 7 → 8) is drafted here and DEPLOYED at her window before batch 2's live rounds.**
2. **Postures**: the posture derivation + per-device follow; Standard's silent open + the Apple road + the
   waiting state; A's item family; Castle's gated custody + always-ask + re-lock; the two switches with
   re-auth; backup key files per fingerprint + box maintenance; the migration (§11) for her two devices.
3. **Doors**: setup-adopts (re-stamp + re-init) and re-enrollment re-inits; change passphrase + regenerate
   under §4's authorizations; sign out everywhere; deletion by account password (reachable unenrolled); the
   plaintext export; the 12-character floor; the descriptor floor.
4. **Lobby + cross-device**: the vault road; Rule 1 with the key-id distinction; offline grace; the post-
   unlock prompt; the posture-follow notice; the phone's faces; convergence pins for §7.
5. **Copy + tutorial + runbook + parity line + the deletions** (§8, §13); the privacy-policy brief re-issued.
Then the cold-review ladder (Fable reviewers — the phase is `Sync/` + custody + the editor-adjacent lobby),
the two drills, her acceptance walk on both devices, the `/Applications` refresh and the phone install.

## 16. OPEN RULINGS — her 2026-09-03 evening answers recorded; the rest with the recommendation first

**RULED 2026-09-03 (evening):**
- **(i) The key-proof token: YES** — ships in THIS phase's lockstep event (marker 7 → 8). Her words on the
  class: *"I agree with your change — I was uncomfortable with deletion with only the account password
  anyway."* (Clarified in reply: the token does NOT gate deletion — deletion stays account-password + typed
  phrase + a FRESH re-authentication, because Apple's 5.1.1(v) requires it reachable by a user who has lost
  every secret; what the token removes is every OTHER power a bare session had.)
- **Sleep / screen-lock re-lock always ON in Castle: YES** — *"but the app unfocused should still have an
  inactivity dial."* The dial's clock is therefore **time since Variorum was last USED** (frontmost with
  input), not system idle — tabbing out never locks instantly (ruling 13's letter), N minutes unfocused
  does. Default: pending her pick (her float: 5 min; recommendation below).
- **(g) A stricter local gate under a Standard account: NO.** Two postures, no hybrids.
- **(h) The library-wide `.md` export gated in Castle: NO** — *"we're taking the position that if your
  variorum is open that's it."*
- **iCloud Keychain propagation latency: ACCEPTED** — *"icloud sync is known to suck, the passphrase is the
  alternative."* The waiting state + its passphrase door stand as designed.
- **L rotation by plaintext export → a NEW library: AGREED as the recorded manual road.** Her question
  *"do we have a way for a user to get started with a plaintext backup?"* → today only by hand (place a
  plaintext `.sqlite` at the store path; the 13p migration encrypts it on the next open — the runbook's
  road); the user DOOR is 13x's "Open a library file…" (plaintext → encrypted under a FRESH key + identity;
  ciphertext → with its key file). Recorded on 13x's row at closeout.

**RULED 2026-09-03 (late evening), continued:** (a) CF-11 folded into sign-out: YES (*"sounds simpler"*).
(d) the account-password minimum: **12** (+ Supabase leaked-password protection ON). (f) the iCloud Drive
backup offer: YES (*"agree to promoting backups to be kept in icloud drive"*); the LIVE library stays local
(iCloud Drive syncs files while they are written — corruption class; sync is the road to every device).
(j) other devices adopt silent open automatically on a Castle → Standard switch, with a one-time notice: YES.
(k) the ceremony words and ALL user-facing text: the architect's, written now — **`notes/plans/pre-13x-
copy.md`** (render, don't re-derive; she re-voices later); the tutorial carries the facts, the website FAQ
carries the restore/re-upload detail. 13x gains "Open a library file…" (plaintext → fresh key + identity).
A deleted-then-recreated Standard account leaves iCloud UNCHANGED: one Apple key, the same one opens the new
account's box and every old backup's key file (the library key never changed) — "two keys in iCloud" cannot
occur.

**RULED 2026-09-04:** (b) the keyless byte-copy at lock time: YES, the app's own folder only. (c) the
inactivity default: **10 minutes, 5 offered** (offered set 5 · 10 · 30 · never). The guard against working
from a library inside iCloud Drive: **13x's** (no door in this phase can place the live library there).
Batch 0 authorized (*"you're clear to start batch 0"*).

**STILL HERS:** (e) the posture copy — 13s re-voices from `pre-13x-copy.md`; the bridge removal's ORDER
(before the key work, recommended, or after — see LIVE STATUS); the sizing flag (17b: three phase-sized
units — one phase or a split at U3).

## 17. CANON DELTAS AT CLOSEOUT
AppSpec §14 (this phase's delta) + §7's `setting`/`sync_state` note (keys live in `sync_state`; the key file
beside the store); SyncSpec §3 (the key provider reads the store; the vault read before unlock; the
key-proof token) + §12's running record (marker 7 → 8: the vault's additive columns + `key_proof` on the
sync RPCs — the choreography executed in her window); CoreDescription untouched (substrate) except §8's 9b
mention retired with the bridge; the 13p constitution's R13p-5/6/7/9 recorded as superseded; the memo
superseded; KnownIssues rows resolved; 13x's row trimmed to portability; MobileSoul parity line; QUESTIONS
#81 / #87 dissolved / re-listed; the bridge's canon deltas (§10) land with batch 0b.

---

## 17b. EXECUTION RECORD (the running record the `/architect-phase` skill requires — kept lean enough to read in full)

### Acceptance units (the sizing guidance, said out loud)
| unit | kind | evidence that closes it |
|---|---|---|
| U0 batch 0 — measurements | spike (not a unit) | the decision memo `notes/plans/pre-13x-spike-memo.md` |
| U1 batch 0b — the bridge set-aside | operations | core + Mac + iOS suites green with the bridge gone; no bridge door renders; its own cold review |
| U2 batch 1 — substrate + the lockstep event (marker 7→8) | sync/protocol (phase-sized) | convergence suites incl. the key proof; ONE live two-device round on the real mirror after her deploy |
| U3 batch 2 — postures + the two switches | custody (phase-sized) | three drills: the Standard new-device road (nothing typed), the Castle new-device road (passphrase once), the Standard→Castle switch with a Standard sibling device following |
| U4 batch 3 + 4 — doors + lobby + cross-device | custody (phase-sized) | per-door drills (change passphrase across two devices; regenerate; sign out everywhere; delete + re-setup + re-upload; the plaintext export's strip pin; the vault road at the lobby) |
| U5 batch 5 — copy + tutorial + mobile faces | UI | hands-on use of both apps, both postures; the tutorial spine green |
**This is THREE phase-sized units under one theme — one over the guidance's two.** Raised to the author
2026-09-04 with two roads: run as one phase with sequential batches and drills as gates (13p's shape,
"at the line", ran clean), or split at the seam after U3 (pre-13x-a: U1–U3; pre-13x-b: U4–U5), sharing this
sitting's rulings. Her call; U0 proceeds either way.

### Environment traps (the standing set — every batch brief carries this verbatim)
Instance checks via `pgrep -fl 'Variorum.app/Contents/MacOS'` discriminated by PATH; treat real-store
instances by STORE — NEVER quit/kill one; NO Release builds or `/Applications` refreshes while one lives
(and none at all before the lockstep deploy lands — a marker-8 client would visibly refuse against the
marker-7 mirror); core tests via `swift test` from the repo root; Mac app tests from `App/Variorum/` with
suite-level `-only-testing` only, confirm the "Test run with N tests" line; `xcodebuild build-for-testing`
compiles without the runner; NEVER add a custom build configuration (SPM deps compile RELEASE under any
configuration not named exactly "Debug", silently stripping DEBUG-gated oracles — the 4G trap); zsh
`pipestatus`; scratch and screenshots in gitignored dirs INSIDE the worktree (never the session
scratchpad — it dies with a crash); never `git checkout` over uncommitted work; commit per piece and PUSH
after every commit (the resiliency protocol outranks the older "architect pushes" line); synchronous
foreground waits only; the A1 backup rail before ANY touch of the real store; suites beside her live
session flash the test host's windows — prefer zero-instance windows for timing-sensitive measurements;
never spawn subagents (one Sonnet lookup for external facts is the sole exception, read-only).

### LIVE STATUS (flipped in the same commit as each piece; PENDING = unverified)
- **U0 batch 0** — **DONE (`e8f7a11`; Q3 PENDING-HER-SITTING)** — the memo `notes/plans/pre-13x-spike-memo.md`; commits
  `fa64534` · `a37f9cd` · `e29ebe3` · `e8f7a11` + the closing one; the batch record is under §17c.
- U1 batch 0b — NOT-STARTED (placement: before the key work per ruling 16; her 09-04 question "is it fine
  to remove the bridge after?" answered in the sitting — either order works; "after" costs a small port of
  the bridge's key provider in batch 1 and carries its tests through; "first" is recommended).
- U2 batch 1 — NOT-STARTED. U3 batch 2 — NOT-STARTED. U4 batches 3–4 — NOT-STARTED. U5 batch 5 — NOT-STARTED.

### THE LEDGER (numbered; every row owned; grows as batches land)
| # | item | owner | status |
|---|---|---|---|
| 1 | the shared keychain access group on both targets (review P8) | U0 → U2 | **done at U0 (`a37f9cd`)** — both signed products carry `[own group, ….Variorum.shared]` under the team wildcard, no App-ID step; U2 consumes it (Keychain Sharing on the App IDs is 13r's, for the distribution profiles) |
| 2 | A crosses Mac ⇄ phone under the shared group (measured on her two devices) | U0 | **PENDING-HER-SITTING** — both DEBUG doors built (`e29ebe3`); the five-minute procedure is the memo's Q3; flips when she reports the five values |
| 3 | the decision memo | U0 | **done (`e8f7a11`)** — `notes/plans/pre-13x-spike-memo.md` |
| 4 | the guard against working from a library inside iCloud Drive | **13x** (the Open-a-library door is the only road that could put it there; recorded on 13x's row at closeout) | deferred, owned |
| 5 | "Open a library file…" (plaintext → fresh key + identity; ciphertext + key file) | **13x** | deferred, owned |
| 6 | the inactivity dial: default 10, offered 5 · 10 · 30 · never; clock = time since Variorum was last used | U3 | open |
| 7 | the keyless byte-copy at lock (app folder only) | U3 | open |

### BATCH 0 BRIEF — measurements (a FRESH Fable implementer; self-contained; read §0's list first)
**Goal:** the facts the postures depend on, measured on real hardware, in a decision memo — and NOTHING
built beyond what measuring requires. **Deliverables:** `notes/plans/pre-13x-spike-memo.md` (the Phase 6 /
13p memo pattern: each question, the observed fact, the number, the recommendation) + this file's LIVE
STATUS and ledger rows 1–3 flipped + the batch record (§17c, appended by you).
**Q1 — the shared access group compiles, signs and launches on BOTH targets.** Add a SECOND entry
`$(AppIdentifierPrefix)io.lduarte.Variorum.shared` to `App/Variorum/Variorum.entitlements` and create the
iOS target's entitlements file with the same two-entry shape (the default group first, so nothing already
written strands — confirm the first entry resolves to the target's own bundle id on each target). Build
both. If signing refuses (the provisioning profile / App ID may need "Keychain Sharing" enabled in her
developer account — an AUTHOR-ONLY step), STOP on that leg, record the exact error, and write the
one-line instruction for her; do not work around signing.
**Q2 — a synchronizable item written under the shared group on the Mac is readable on the Mac** (the
shape of `StoreKeyGuardKeychain.escrowQuery` with `kSecAttrAccessGroup` = the shared group, `AfterFirstUnlock`,
no ACL): write, read back, delete, under a DEBUG-only probe (a `#if DEBUG` menu item or a Mac test marked
`.disabled` by default — NEVER a fixed account that a test process could touch in production; use a
throwaway account name with a timestamp; `KeychainTestTripwire` stays honored). Record the status codes.
**Q3 — the item crosses to the PHONE.** You cannot install on her phone; PREPARE the leg: the same probe
in the iOS target behind `#if DEBUG` (write on one device, read on the other, both directions), and a
five-minute written procedure for her sitting (install the dev build via Xcode, tap, read the result on
screen). Record Q3 as PENDING-HER-SITTING with the procedure.
**Q4 — the vault read's latency before unlock:** measure the round-trip of an UNauthenticated request to
the project URL (`ProjectConfig`'s host; a HEAD or a 401-returning GET on `rest/v1/key_vault`) five
times; report median and max. That is the pre-unlock network contact's floor; the authenticated fetch adds
one PostgREST query. No credentials are needed and none are used.
**Q5 — `kSecAttrSynchronizable` + `kSecAttrAccessGroup` interaction facts on THIS macOS point release:** does
a delete under the shared group with the synchronizable flag match the item (it must); does a query
WITHOUT the group match it (it must not from another group); record.
**Q6 — Argon2id v1 derivation time on this Mac** (the existing `PassphraseKDF` harness test reports it; one
number for the memo's lobby-latency budget).
**Explicitly NOT batch 0:** the key-proof RPC (batch 1), any Keychain custody change to the app's real
items, any store touch, any `Sync/` change, any Release build. **Scratch:** gitignored dir inside the
worktree. **Record:** append `### Batch 0 — record (implementer: Fable, 2026-09-04)` under §17c with the
LIVE STATUS lines per Q, flipped per piece; commit per piece, push after every commit; foreground waits
only. **Done when:** the memo is committed, the entitlements change is committed (or its signing refusal
recorded with her one-line instruction), the probes exist behind DEBUG, and this file's LIVE STATUS says
`U0 — DONE (hash)` with Q3 PENDING-HER-SITTING.

### 17c. BATCH RECORDS (appended by each implementer; newest at the bottom)

### Batch 0 — record (implementer: Fable, 2026-09-04)

**Scope:** the BATCH 0 BRIEF above, nothing more. **Baseline:** `a3ff54c` (the brief's own commit). **Environment
at start:** her live real-store app running (`/Applications/Variorum.app`, PID 79767) — NEVER touched; no Release
build, no `/Applications` refresh, no store touch, no `Sync/` line, no production Keychain item, anywhere in this
batch. Builds use a gitignored `App/Variorum/DerivedData/pre13x-b0` inside the worktree. **No revert is in flight.**
**Facts read before any change (read-only):** the Mac Team Provisioning Profile embedded in her install and the iOS
*[removed for publication]*
so the Q1 hypothesis is "signing accepts the shared group without an App-ID change" — to be proven by building.

**LIVE STATUS (flipped in the same commit as each piece; PENDING = unverified):**
- **Q1 (shared group on both targets)** — DONE (this commit). `Variorum.entitlements` carries the second entry;
  `App/Variorum/VariorumMobile.entitlements` CREATED (two entries, default first) and wired by `CODE_SIGN_ENTITLEMENTS`
  on both VariorumMobile configs. **Both builds succeeded with NO signing change and NO App-ID step** — the team
  *[removed for publication]*
  *[removed for publication]*
  *[removed for publication]*
  *[removed for publication]*
  Profile: *". The first entry resolves to each target's own bundle id, as required. Nothing for the author here.
  (The Mac `EntitlementsTests` pin for the shared group rides the PROBES commit, beside the other tests.)
- **Q2 (Mac synchronizable round trip under the shared group)** — DONE (`e29ebe3`; this line flipped one commit
  late — the flip script aborted on a counting assertion and the commit chain ran anyway; machinery honesty).
  `Shared/SharedKeychainGroupProbe.swift` (DEBUG-only, both targets; throwaway service
  `io.lduarte.Variorum.pre13x-shared-group-probe`; timestamped account, deleted at the end) +
  `VariorumTests/SharedKeychainGroupProbeTests` gated `.enabled(if:)` on `VARIORUM_SHARED_GROUP_PROBE=1`. **Run
  2026-09-04T06:22:11Z in the signed host:** add `0` → read (shared group named, synchronizable=true) `0`, landed in
  *[removed for publication]*
  `-25300`. The tripwire stayed armed and never fired (its own suite ran green beside it). **Verified DISABLED BY
  DEFAULT:** the same suite without the variable → both tests `skipped: "writes one synchronizable throwaway item (it
  rides into iCloud Keychain and is deleted) — run deliberately with TEST_RUNNER_VARIORUM_SHARED_GROUP_PROBE=1"`,
  XCTest's counter `Executed 0 tests` (Swift Testing's own summary still says "Test run with 2 tests in 1 suite
  passed" — it counts the skipped tests; read the `skipped:` lines, not the count). The gated run: 16 tests / 5
  suites green (`SharedKeychainGroupProbeTests` · `EntitlementsTests` incl. the new shared-group pin ·
  `Phase13pKeychainFactTests` — the keychain-identity regression guard, still landing ACL'd writes after the
  entitlements change · `KeychainPartitionTests` · `KeychainTripwireTests`).
- **Q3 (the item crosses to the phone)** — **PENDING-HER-SITTING.** Built (`e29ebe3`): the Mac Help-menu door
  (`Variorum/Core/SharedKeychainGroupProbeDoor.swift`, `#if DEBUG`) and the phone's Settings row + sheet
  (`VariorumMobile/Features/Shell/MobileKeychainProbeScreen.swift`, `#if DEBUG`), both over the one brain and a
  fixed `cross-device` account under the throwaway service; the iOS Debug build with the screen compiles and signs
  (generic device, `IOS-BUILD2-EXIT 0`). The five-minute procedure is in the memo's Q3. Nothing was installed on her
  phone (prepare-only). Both doors sit outside the capability registry by the TK2 Spike door's rule (DEBUG-only dev
  instruments; the registry walk covers every build a user can hold) — recorded here so the choice is visible.
- **Q4 (pre-unlock network floor)** — DONE (measured this session; the memo has the table). Five cold GETs to
  `rest/v1/key_vault`: totals 0.177 / 0.041 / 0.314 / 0.051 / 0.050 s → **median 0.051 s, max 0.314 s**; warm
  keep-alive 0.015 s; the gateway answers `401 UNAUTHORIZED_MISSING_API_KEY` before PostgREST. No credentials used.
- **Q5 (synchronizable + access-group facts)** — DONE (the same run as Q2): delete WITH the flag under the shared
  group `0` (matches); read naming the DEFAULT group `-25300` (another group does not see it); read with NO group
  from the same app `0` (the writer's own app searches all its groups); read/delete WITHOUT the flag `-25300` — a
  flagless delete is a silent no-op and the item survives it; `kSecAttrSynchronizableAny` `0`.
- **Q6 (Argon2id v1 on this Mac)** — DONE: `KDF-LATENCY (Mac, v1 descriptor m=64MiB t=3 p=1): 0.769s 0.766s 0.763s —
  median 0.766s` (M3 Pro, load ~3, her live app running).
- **The memo** `notes/plans/pre-13x-spike-memo.md` — DONE (this commit): the headline table, environment, Q1–Q6
  each with the observed fact · the number · the recommendation, Q3 as PENDING-HER-SITTING with the five-minute
  procedure, the surprises, what is handed forward. **Ledger rows 1–3 + U0 line** — flipped in the closing commit.

**CLOSE (2026-09-04, ~00:50 local).** Commits: `fa64534` (the record opened) · `a37f9cd` (Q1 — the entitlements,
its own commit) · `e29ebe3` (the probe brain, the Mac suite, both doors, the entitlements pin) · `e8f7a11` (the memo +
the late Q2–Q6 flips) · this closing commit (ledger rows 1–3, the U0 line). **Needs the author: ONLY Q3's sitting**
— five minutes on both devices, the memo's procedure; no signing step, no App-ID change, no account action of any
kind arose. **Environment at close:** her live app (PID 79767) still running, never touched; no Release build; no
store touch; no `Sync/` line; no production Keychain item; the only synchronizable bytes that ever existed were one
throwaway item for ~30 ms and its tombstone. Suites beside the piece: 16/16 green in the gated probe run (the
keychain-identity guard `Phase13pKeychainFactTests` among them); the full Mac suite was NOT run (a measurement
batch touching no production code path; the reviewer's call whether the closeout wants it). **Two machinery lessons,
for the resiliency protocol's owner:** (1) `tail -n +1 -f <log> | grep -m1 EXIT` does NOT return when the EXIT line
lands — `tail -f` only dies on the NEXT write after grep exits, so both blocking waits here ran to the harness's
10-minute limit for runs that had finished in seconds; poll with a `grep -q` loop instead. (2) Swift Testing's
"Test run with N tests" counts SKIPPED tests — read the `skipped:` lines / XCTest's `Executed 0 tests`, never the
count; the assertion that mis-read it is why the Q2–Q6 flips rode one commit late.


---

## 19. THE ARCHITECT'S REVIEW OF THIS DESIGN, AND THE SIGN-OFF (2026-09-03, written after the rewrite, reviewing the text above as a cold reader would)

**Read for:** every place a key exists, who can reach it, and by what; every write the server accepts and
from whom; every promise §2 prints and the mechanism under it; and what a reader hostile to "vibe-coded
encryption" would look for first.

**What holds, and why (the claims, each with its mechanism):**
- *The server never reads your writing.* The server holds ciphertext under C, and M only as boxes under P
  (Argon2id 64 MiB), W (128 bits of BIP-39 entropy through HKDF) and, in Standard, A (a random key in
  iCloud Keychain the server never sees). No key is derived server-side; no key is transmitted except as a
  box. The 14b serializer classification walk keeps every text column ciphertext by construction.
- *Castle: nothing on the Mac releases the key to the login password.* L is raw only in a `.biometryCurrentSet`
  data-protection item (or absent); the key file holds boxes; M lives inside the locked library; the session
  is inert against the corpus (§3.8). Terminal, Finder, Time Machine, Migration Assistant, and a cloned
  Keychain obtain ciphertext and boxes. This is the Day One contrast, and it is true.
- *Standard: your Apple account holds a key, and only that.* iCloud carries A; A opens boxes; the boxes
  hold L and M. iCloud + a copy of the library = the library; iCloud + a session = sync. iCloud alone opens
  nothing. Apple's recovery chain is disclosed as the trust base.
- *The account password never touches keys.* No door consults it except sign-in and deletion; and with the
  key-proof token no RPC that reads or writes the corpus or the vault accepts a bare session.
- *Nothing is ever silently minted over an existing library; a lock is never silently reset* (§3.5, §3.6).
- *Posture cannot drift between devices* — it is not stored anywhere but the vault's shape.

**Concerns I raised on myself, and their dispositions:**
1. **A bare session could PATCH the vault and push rows** (the server cannot verify P). Serious enough that I
   would not sign off on the confidentiality story alone while the availability story let an email-holder
   quietly tombstone a library. Disposition: **§3.8, the key-proof token — my ONE condition for sign-off.**
   If she defers it to 13y, the interim must be disclosed in the privacy brief and the "structure visible to
   a bare session" line stays in the disclosure envelope.
2. **The vault's KDF descriptor is truth; a weakened descriptor served to a client** would make the client
   derive with weak parameters. Traced: no leak results (the derived key never leaves the client; a foreign
   box refuses), and with `kp` a session cannot alter the descriptor — but a server breach could. Disposition:
   the client refuses descriptors below the v1 floor (m ≥ 19 MiB, t ≥ 2, 16-byte salt) — a pin, free.
3. **Could the server induce a client to wrap M under a key the server chose?** Only if the client ever wrapped
   under a network-supplied key. Disposition: invariant §14.24, pinned — A is read from iCloud Keychain or
   minted locally; the server supplies only boxes and an `apple_key_id` the client verifies against the A it
   holds, never adopts.
4. **The master box makes M a skeleton key across the account's libraries.** Since M already decrypts the
   whole corpus, this adds no content exposure; it adds convenience (any enrolled device opens any of the
   account's library copies). Accepted and recorded.
5. **Backups now carry M** (inside `sync_state`). A backup opens by the same secrets that open the library, so
   no NEW exposure — but a Standard backup in iCloud Drive + iCloud Keychain = M, which is exactly Standard's
   posture. Accepted; the plaintext export's strip rule is the pinned corollary.
6. **A persists after the Castle switch.** A alone opens nothing once the boxes are removed; deleting it would
   break other libraries and accounts on the same iCloud. The residual — copies of Standard-era key files
   outside our folders — is disclosed in the ceremony. Accepted; the app's own backup folders are stripped.
7. **L is never rotated.** A user who believes their Apple account was compromised while Standard rotates M
   by deleting the account, but L stays; a copied L opens FUTURE backups of that library file if the copier
   obtains them. Disposition: declined for v1 with the recorded manual road (§13); named in the Castle
   ceremony's small print. This is the one residual I would revisit first after v1.
8. **The pre-unlock vault read leaks "this device woke at 9:00" to the server.** Timing metadata only, already
   inside the disclosed envelope (write cadence). Accepted.
9. **iCloud Keychain propagation is unbounded.** Not a security flaw but the most likely SUPPORT flaw: a new
   Standard device that waits an hour looks broken. Disposition: the waiting state is load-bearing, its
   passphrase door beside it, and batch 0 measures the real latency on her two devices before copy is written.
10. **The enrolled-finger caveat** and **the open-app window** are real and cannot be closed in software;
    both are in copy. Not flaws — disclosed boundaries.

**What a hostile reader would look for, and what they would find:** keys in the clear on disk — none (the
gated item is hardware-wrapped; `sync_state` is inside SQLCipher); a "password lock" over a readable database
— no (the database is ciphertext; the lock gates the key); a recovery road the vendor holds — no (the vendor
holds boxes); a passphrase of any length — no (12-character floor, Argon2id); an escrow key sitting raw in
iCloud — no (a key to boxes); a re-key door behind an email-resettable password — no (gone); a session that
can rewrite the vault — no (`kp`). What they WOULD find and could write about: iCloud Keychain's trust base
in Standard (disclosed, by design), the enrolled-finger caveat (disclosed), and the open-app window
(disclosed, universal).

**Sign-off.** As the architect I sign off on this design **conditionally**, and the conditions are ordinary
phase discipline plus one item: (i) the key-proof token (§3.8) ships in this phase's lockstep event, or its
deferral is disclosed; (ii) the descriptor-floor and never-wrap-under-a-network-key pins land in batch 1;
(iii) batch 0 observes A crossing between her two real devices under the shared group before any Standard
copy is written; (iv) the cold-review ladder runs with FABLE reviewers on every round (her R-cor-14 rule
covers `Sync/` and custody; this phase is both), and the two drills run on both devices; (v) the honest
boundaries in §2 and §14 survive 13s's re-voicing verbatim in substance. With those, I believe the app
would not make the news for an obvious flaw: every key is accounted for, every door names its authorization,
the server is provably dumb, and the two things a critic could write are the two things the copy says first.

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

### H. THE 2026-09-01 INCIDENT — "It says I don't have a passphrase, but I do" (the design's proof)
Her refreshed Castle-class Mac (Biometric mode) showed the exposed nudge and a "Set a Passphrase…"
door although she has held the suite passphrase since 14b. Two facts stacked: **(1)** her passphrase
is the VAULT's; her store's envelope was never extended with it — the one-secret follow hooks fire
on vault setup/enroll/change ON THE DEVICE THAT ACTS, and her Mac enrolled in 14b, a month before
envelopes existed (the 13p handoff's owed "one visit"); so the nudge's brain, reading envelope +
custody facts only, was literally right about the LOCAL copy and wrong about her writing (on the
server, behind the vault passphrase — a leg the brain never counted). **(2)** the iCloud spare had
been removed by her own coupling ruling at the first reconcile of the refreshed build. The other
session recorded a 13u2 item (count the sync leg; say "extend," never "set").
**Why it cannot recur under this design, for new users AND for her:**
- Castle makes the passphrase AND the twelve words mandatory at enrollment (ruling 11) — a Castle
  library with "no passphrase" is not a state that exists.
- Standard needs no passphrase to have a way back (iCloud); its nudge fires ONLY for iCloud Keychain
  off + no secrets (§3.6) — and a Standard sync user always has both secrets (ruling 5).
- The envelope's master wrap (§3.3) lets an enrolled device extend its own envelope from HELD material
  with no visit (§11's backfill), and the vault road re-wraps the passphrase wrap the first time the
  passphrase is typed — "vault has it, this library doesn't" cannot persist past one unlock.
- The legs brain is DELETED; what replaces it (§8's "ways back in" line) is computed from facts —
  envelope wraps · custody items · the iCloud item's verified presence · vault enrollment — and
  **counts sync**: an enrolled account IS a way back for the writing, stated as such.
- The set-screen's one-secret verification stands: with a vault present, "set" verifies against the
  vault and reads as EXTEND; the words are shown beside it.
**The 13u2 nudge-copy item is RETIRED at this phase's kickoff** (the brain it would patch is deleted;
one home, as with #86(c)).
**Three more lines the incident surfaced, kept here so they are not lost:** the iPhone under Standard
gets its store key back through iCloud Keychain on Quick Start / an iCloud-backup restore (seamless
phone migration is a Standard feature; Castle = the passphrase once — the phone's copy says so);
account-password re-authentication is a sign-in call against the suite issuer (14a's direct
email+password road) and inherits Supabase's auth rate limits — 13y's abuse guard should name the
re-auth doors; stale iCloud items for libraries that no longer exist are harmless and deliberately
never swept (they still open a surviving backup of that library — a feature).

### I. THE FINAL AUDIT (her 2026-09-01 question: "have I given my users the real security I'm promising, without any back doors? is someone going to be shocked they've lost their work in any tricky scenario?")

**Back doors — Castle, claim by claim.** *The server cannot read:* true — the vault's wraps open only
under the passphrase or the words; keys never leave clients. *Apple cannot read:* true — no iCloud
item exists in Castle (after the switch re-keys both the store and the sync keys). *Your login
password cannot read:* true — the library key is gated or absent, the sync keys sit inside the
library, a fresh store can only ask. **The one capability a stolen SESSION keeps, disclosed:** a
custom client holding your tokens can push tombstones or call the truncate RPC — it can DISRUPT
(deletions land in the 30-day Trash on every device; the server copy can be emptied and re-uploaded
from any device), never read. The mitigations: tokens device-bound; 13y's abuse guard should require
a RECENTLY RE-AUTHENTICATED session for the destructive RPCs (truncate, purge) — noted on 13y. The
deliberate second secrets — the twelve words; an enrolled device ("as powerful as your passphrase");
Replace Keys by account password (reads nothing) — are disclosed in the ceremony, which is what
separates a door from a back door. Riders that must hold: the scheduled `.md` insurance WARNS under
Castle (R13p-8's rider, kept); crash reports (13r, opt-in) carry no content; the plaintext export is
the ONE deliberate escape and asks for the passphrase in Castle.
**Back doors — Standard:** the honest list IS the design: anyone fully in your Apple account (and
Apple's recovery chain), and anyone at your unlocked device — and with an iCloud address as your
account email, sync too (the compound warning). Nothing undisclosed.

**"Shocked to lose my work" — every scenario walked, with the answer each must have in copy:**
1. **Standard, NO sync, the Mac dies.** iCloud Keychain holds the KEY; the WRITING was only on that
   Mac, and the app's own backups live on the same disk. Unless the backup folder lived in iCloud
   Drive (or Time Machine ran), the writing is gone — with the key safely in iCloud. THIS is the
   shock scenario, and the §2 table overstated it until this audit ("nothing lost — iCloud brings it
   back"). Corrected: the sentence is conditional, and §16(h) puts the backup destination into the
   design. Sync users are not in this scenario (the server is the copy).
2. **Standard + sync, loses every Apple device and every Apple recovery path.** Sign in + the
   passphrase (or the words) brings everything back — IF they still know the passphrase they set once
   at sync setup and never used since. The sync-setup ceremony must say: *"keep your twelve words even
   in Standard — they are your way back if you ever lose your Apple account."*
3. **Castle, forgot the passphrase, an enrolled device opens by Face ID / Touch ID:** change it there.
   No loss. **No Touch ID, no words:** the floor — said in the ceremony as the sign the lock is real.
4. **Passphrase changed on one device; another device offline for weeks:** the old one still opens it
   (cache); the prompt fires at the next connection; if the new one was forgotten meanwhile, the
   unlocked device changes it again. No loss.
5. **Replace Keys from a stale or near-empty copy:** the T1 count-and-dates warning + the typed
   confirmation; the second press is deliberate. Anything only on the server is named before it goes.
6. **Deleted notes vanish after 30 days:** the Trash is visible on every device; Put back; the purge
   runs only past the horizon; backups are ciphertext + envelope.
7. **A restored OLD backup after Replace Keys:** lands in keys-replaced; in Standard the iCloud mirror
   heals it with nothing typed (a corner to build: prefer the mirror when the store's keys mismatch
   the vault); in Castle, the passphrase once.
8. **The Standard → Castle switch crashes mid-way** (store re-key · Replace Keys · item removal are
   three acts): a persisted marker (the `AccountRekeyMarker` pattern) makes re-running complete it, and
   the iCloud items are deleted LAST — never a half-switched library with no key anywhere.
9. **Apple resets iCloud Keychain during account recovery (Standard):** existing devices keep their
   local copies; a new device afterwards needs the passphrase (sync) or a surviving copy + nothing
   (no sync — scenario 1 again). Disclosed as the Standard floor.
10. **Lost the twelve words:** regenerate from any unlocked enrolled device. No loss.
11. **A shared family iCloud (Standard):** the co-user can read — Standard's own sentence.
12. **The plaintext export left lying around:** the warning says exactly that; a user act.
Every row above is either already a step in §§3–15 or was added at this audit (§16(h); the marker in
row 8; the mirror-heals-restore corner in row 7; the sync-setup sentence in row 2; the 13y note).

**The two-sentence version, for when the length of this file makes it dizzying:** *Standard — your
Apple account holds the key; the server can't read; back up the file somewhere that survives the
Mac. Castle — only you hold the key; know your passphrase and keep your twelve words; an enrolled
device can always set a new one.* Everything else is execution and copy, and the two drills catch
what the sweep missed.

## ADDENDUM 2026-09-02 (the Act 10 correction round's sitting — POINTERS ONLY; the design above is untouched)

- **FOUR items JOIN this phase from 13u2 (her ruling R-cor-12, `notes/plans/act10-correction-round.md` §1):** the
  near-empty re-key TYPED CONFIRMATION (#86(c)) · the protection nudge bar OVERLAYING the sidebar's bottom row ·
  the legs brain counting the SYNC leg + the "extend" wording · COPY ALL on the recovery phrase (her word NEED — a
  one-session 17 entry if this phase is far). This design's §8 surfaces absorb them; §2's two-posture model DELETES
  the loss-legs presentation, so the nudge/legs items may be moot by construction — verify at batch 5 (copy).
- **§15's batch 6 (17i) is WITHDRAWN from this phase (R-cor-13):** 17i — the sync reconciliation hunt — runs as its
  OWN 17 entry AFTER this phase lands, on the settled key path; its brief is unchanged. **§16(d)'s parked "Pause
  sync" (17k) now belongs to 18a** (sync considerations — `DetailedPlanForPhases.md` row 18).
- The daily-Journal identity memo is **13i-e's** now (from 13y). The dedupe residuals are **18a's** (from 13y).
