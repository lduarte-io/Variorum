# BRIEF: the TWO POSTURES — what changes for Fragments (the revision Phase 20.10 waits for)
### (2026-09-01 · carried by the author · self-contained for the Fragments agent · REVISES `fragments-enrollment-brief-2026-08-31.md` and the Aug-31 lockbox reply)

> **BANNER 2026-09-04 — the journal bridge is RETIRED on the Variorum side** (pre-13x batch 0b;
> tag `archive/fragments-bridge-2026-09-04`). The authoritative word to Fragments is the 2026-09-04
> CARRY ITEM at the end of `notes/fragments-bridge-contract.md`. The spec below stands on
> Fragments' OWN merits (build it or not); nothing bridge-motivated is owed by Fragments any more.

**TL;DR.** The vault, the ceremony format spec and the enrollment flows are UNCHANGED — the Aug-31
brief's §2 stands byte-for-byte, so the 20.10 ceremony can be built to it today. What changed is the
suite's CUSTODY MODEL around the vault: Variorum collapsed its at-open modes / escrow dial / presets /
separate sync gate into **two postures — Standard (your Apple account holds the key) and Castle (only
you)** — moved its sync keys INSIDE the encrypted store so ONE unlock covers content and sync, made
every enrolled device able to set a new passphrase, and re-authorized Replace Keys and account
deletion by the ACCOUNT password. The Aug-31 lockbox reply's consistency map (which mirrored the old
three-shape model) is SUPERSEDED by §3 below. Variorum builds this as its NEXT phase, `pre-13x`
(`notes/plans/pre-13x-postures-design.md` in the Variorum repo — the binding record; her fifteen
rulings are its §1). Nothing in this brief is built yet on either side.

---

## 1. WHY (her verdict, verbatim-faithful — so the Fragments side inherits the reason, not just the shape)
- *"The average user is NOT going to understand that they have an on device key + the one time they put
  in a passphrase two years ago is why sync works + they have an iCloud escrow key but it only works
  with a backup… and so if they lose this device… they actually have NOTHING, even if they're paying
  for sync."*
- *"they all have a SINGLE encryption setting + posture. They may have different recovery mechanisms…
  but they just don't have all this key, sync, device key, escrow key, time machine loophole, etc."*
- *"Either choose full lockdown with the responsibility that implies of KNOWING YOUR PASSPHRASE… the
  warning is THEIR sign that they're safe… if you don't care about encryption, your fate is in apple /
  iCloud / your iCloud's hands."*
- *"it's up to you to protect your iCloud. My app will let you be fully protected even if your phone /
  mac is unlocked."*
- And the trap that forced the custody change (found 2026-09-01 in Variorum): with the sync keys in a
  plain Keychain item, moving the store file aside on a LOCKED Mac and relaunching minted a fresh store
  that was still signed in and still held the keys — and pulled the whole corpus in the clear. Her
  words: *"it would be kinda disasterous if someone just moving your store aside let them in."*

## 2. WHAT DOES NOT CHANGE (start here — most of 20.10 is unaffected)
- The `key_vault` format: master wrapped by the passphrase-KDF key AND by the recovery key; the
  `corpus` and `journal_bridge` class keys wrapped by master (RFC 3394); Argon2id v1 parameters;
  BIP-39 12 words; the `revision` CAS; the `e1:` wire format and AAD grammar. **§2 of the Aug-31
  brief is the spec, unchanged, citations intact.**
- Enrollment = the passphrase OR the twelve words (both full roads); Fragments holds ONLY the
  `journal_bridge` class key (their Q1 — confirmed again).
- ONE suite secret: the passphrase (its twin the twelve words), shown at passphrase-set with
  confirm-by-re-entry (Variorum's set-screen today; Fragments' ceremony under 20.10). Turning on
  sync always requires both (already so on the Variorum side).
- Road (a) — the passphrase-SET ceremony in Fragments to the written spec — stands (her Sep-1 lean:
  after this simplification; this brief IS the simplification). Acceptance bar: **the interop
  fixture** — a vault enrolled from Fragments opens in Variorum and vice versa.
- Contract point 9 (a Variorum Replace Keys forces Fragments to re-enroll) — unchanged.
- The NEVER list and the layer separation (the suite passphrase/vault ≠ Variorum's store key ≠
  Fragments' lockbox key) — unchanged.

## 3. WHAT CHANGES — the suite model Fragments now mirrors

### 3.1 Two postures, shared names, per app
| | **Standard** (default) | **Castle** |
|---|---|---|
| who holds the key | your Apple account (iCloud Keychain + Apple's recovery paths) | only you: passphrase · twelve words · enrolled devices behind Face ID / Touch ID |
| opening | silently | Face ID / Touch ID with the passphrase as fallback, or the passphrase every time |
| a new device | sign into iCloud + sign into the app → everything, nothing typed | sign in + the passphrase (or twelve words), once |
| stops | the server? yes. someone in your iCloud? no. someone at your unlocked device? no | the server, your iCloud, your device's passcode/login password: yes. someone holding your secrets: no |
| floor | lose every Apple device AND every Apple recovery path AND (if set) both secrets | lose every enrolled device AND both secrets — gone; the ceremony says so as the sign it is real |
The Aug-31 consistency map's rows ("silent mint two items = Auto + spare", "enrolled un-locked = the
nudged state", "locked = Shape 1") collapse to these two. **The posture is chosen PER APP** (her Aug-31
ruling 5 stands: levels are not enforced-equal across the suite); what IS shared is the law, the
custody discipline, the vocabulary and the names. Each app's Castle ceremony says the other app is
guarded by its own lock.

### 3.2 "Escrow follows the posture" survives, simplified — the dial is gone
Standard MIRRORS the held keys to an iCloud-synchronizable Keychain item (no access control — Apple
does not sync gated items; service+account disjoint from every other family; payload = raw key
bytes + key id, exactly your §2.3 rule — no envelope in a keychain item). Castle mirrors NOTHING.
There is no "escrow on/off" any more; the un-locked two-item design becomes ONE synchronizable
item; the "silent mint, un-locked, escrow" population IS Standard.

### 3.3 Keys inside the encrypted store — ONE unlock covers content AND sync (her "remove the sync difference from unlocking")
Variorum moves its sync keys (master + class keys + ids) INSIDE the SQLCipher library (a local-only
table; zero schema, zero lockstep) and deletes its separate "require Touch ID to unlock sync" gate:
the library's own gate is the sync keys' gate by construction, a fresh store has no keys and can
only ASK for the passphrase, and the session tokens become device-bound (`ThisDeviceOnly`).
**For Fragments:** hold the `journal_bridge` key INSIDE the lockbox's own key-protected home (the
encrypted journal store), not as a separately-gated Keychain item — so unlocking the journal IS
unlocking its sync, with no second gate, no second prompt, no launch cache. In Standard, mirror the
held material to Fragments' own synchronizable item (the fresh-device bootstrap); in Castle, no
mirror. Bind the session tokens `ThisDeviceOnly` in both postures. Verify that NO "store missing →
reset the lock → fresh store still enrolled → pull" route exists on iOS (Variorum's
`openResettingModeToAuto` was exactly that; it is re-ruled to "your library is missing — restore or
open an existing one; the lock stays"). Your §2.3's custody-handover ordering, checked delete
`OSStatus`, and the test-process tripwire all still apply to whatever items remain.

### 3.4 The doors, suite-wide (authorization is the change)
| door | who | authorization | what changes | other devices |
|---|---|---|---|---|
| **Change passphrase** | any UNLOCKED enrolled device | Castle: you are unlocked — Face ID re-confirm if you opened by Face ID, nothing more if you typed it. Standard: Face ID where present, else the **account password** (the app opened silently; something must prove it's you). The twelve words also authorize. | re-wrap the vault master (held-material road, no old passphrase); re-wrap local caches | keep syncing (they hold the keys); learn the new passphrase via §3.5 |
| **Regenerate twelve words** | same | same as change-passphrase (NOT passphrase-gated any more) | new recovery wrap | same road |
| **Replace keys** | an OPEN store (empty counts) + signed in | **account password** + the stale-copy recency warning (T1) + a TYPED confirmation when this copy is near-empty (her #86(c) ruling) | new master + class keys; server copy truncated; this copy re-uploaded; the Standard mirror rewritten; all rows re-stamped to the current account | STOP ("keys were replaced") until re-enrolled — contract point 9 |
| **Delete account** | signed in, enrolled OR NOT | **account password** + typed confirmation (never the encryption passphrase — a lost key must never make deletion impossible; Apple's guidance allows re-auth) | server copy + vault + account gone; local copies untouched | lose sync, keep local |
| **Sign out** | — | — | tokens only; keys stay inside the store (the store is the gate) | — |
| **Plaintext export** | open store | re-authenticated (Castle: the passphrase; Standard: Face ID else account password) | MUST strip every local sync/key table | — |
Precedent she asked for and we verified (official docs): Proton's signed-in trusted device resets the
password with no old secret; Apple ADP's trusted device is an official recovery path; Obsidian Sync
recreates the remote vault from local data (= Replace Keys); 1Password's Secret Key is our
passphrase's twin and its deletion/cancel run on an EMAIL-verification road — deletion is an account
act, never a key act. Hard-biometric gating of "set a new secret" has no precedent; Fragments' 20.10
change-passphrase must not require Face ID as the ONLY confirmation.

### 3.5 Cross-device passphrase change — "the vault is truth; every local wrap is a cache"
The trap: the device that CHANGES the passphrase re-wraps its own local caches; every OTHER device's
cache stays under the retired passphrase, so its lobby accepts the OLD one and rejects the NEW until
someone types the new one there — and nothing asks. Variorum's fix, which Fragments must mirror
wherever it caches a passphrase-derived wrap locally:
1. wrap the local key(s) ALSO under the suite MASTER (a "master wrap"), so a device that can reach
   the vault re-derives its own keys without the passphrase;
2. record the vault's KDF descriptor (salt + params, non-secret) beside the local passphrase wrap;
3. at unlock, if online and the vault's descriptor ≠ the recorded one, verify the typed passphrase
   against the VAULT: the retired one is refused ("your passphrase was changed on another device —
   enter the new one"), the new one opens via the vault road and re-wraps the cache;
4. offline, the cached wrap opens — stated in copy as offline grace; the device catches up at its
   next connection (a one-time post-unlock prompt for devices that opened by Face ID);
5. a regenerated recovery phrase takes the same road; Replace Keys lands the device in
   keys-replaced, and re-enrollment rewrites both the keys and the master wrap.
**If Fragments' ONLY passphrase road is vault-derivation (online), the staleness class cannot occur
and steps 1–4 are moot** — your §2.3 "invalidated item → passphrase → re-derive from the vault →
re-mint" already IS the vault road. The moment an OFFLINE passphrase cache is added, steps 2–4 bind.

### 3.6 What Castle requires, what Standard needs
- Castle enrollment REQUIRES the passphrase AND the twelve words (generated, written down, confirmed
  by re-entry, once) — a Castle store with "no passphrase" is not a state that exists. The 30-day
  secret-check cycle is Castle-only. Your §2.4 lock-requires-enrollment ruling maps 1:1.
- Standard needs no passphrase to have a way back; its only unrecoverable state is iCloud Keychain
  OFF + no secrets, and the ONE nudge exists for exactly that ("write down your twelve words"). A
  Standard SYNC user always has both secrets (sync setup requires them). The "exposed-tier" machinery
  you skipped stays skipped.
- Standard's honest sentence: *"your Apple account and its recovery paths hold the key; the server
  can't read it."* Never "Apple can read" — iCloud Keychain is itself end-to-end encrypted; the
  trust base is Apple's account and its recovery chain (support.apple.com/102651: without the
  device passcode, a recovery contact or a recovery key, E2EE data is permanently inaccessible).
- The phone under Standard gets its keys back through iCloud Keychain on Quick Start / iCloud-backup
  restore — seamless migration is a Standard feature; Castle = the passphrase once. Say so.

### 3.7 Plaintext escapes
Variorum reversed its "never a plaintext SQLite" rule: a deliberate, re-authenticated, warned,
user-placed plaintext export is offered; never scheduled plaintext. If Fragments mirrored the
one-escape rule, it may relax it the same way — with the strip rule of §3.4's last row.

## 4. YOUR §6 QUESTIONS — the answers that CHANGED (the rest of the Aug-31 reply stands)
- **Q2 (escrow conventions):** superseded — no escrow dial; Standard's mirror item convention is
  §3.2 (synchronizable, no ACL, disjoint service+account, raw bytes + key id, per app). Castle has no
  such item — pin its ABSENCE.
- **Q3 (the prompting cycle):** Castle-only now; Standard never reminds (the passphrase there is for
  enrolling and authorizing, not recovery).
- **Q4 (re-lock):** unchanged for the phone (immediate on background/leave, flush-then-lock order).
  For the record, the Mac keeps sleep/screen-lock re-lock always in Castle plus ONE optional idle-
  minutes dial reading SYSTEM idle (switching apps never locks).
- **Q5 (vault-less accounts):** every SYNC user has a vault; a signed-in account that never ran the
  ceremony is still possible until 20.10 gives Fragments the ceremony — which closes it suite-wide.
- **Q6 (keychain traps), ADDED:** keys inside the encrypted store beat any keychain item; bind tokens
  `ThisDeviceOnly`; the same-machine "store missing → reset → pull" class (§3.3); scope custody by
  STORE ID, never by app variant; `.biometryCurrentSet` invalidating on biometric re-enrollment is
  the DEFENSE against "add my finger to your phone," not a bug — keep the passphrase road behind it.

## 5. TESTS TO ADD ON THE FRAGMENTS SIDE (beyond your §5)
- **The interop fixture** (the 20.10 bar): a vault enrolled from Fragments opens in Variorum; one
  enrolled from Variorum opens in Fragments; the same twelve words unwrap both.
- **Passphrase-change propagation:** change in Variorum → Fragments refuses the retired passphrase
  when online, opens with the new one via the vault, re-wraps; offline, the old one opens and the
  prompt fires at the next connection (if any local cache exists — else pin that none does).
- **Keys replaced:** a Variorum Replace Keys lands Fragments in the visible keys-replaced state;
  re-enrollment by passphrase restores sync (contract point 9, now pinned against the NEW master).
- **Deletion:** account deleted from Variorum → Fragments reads an honest unenrolled/signed-out
  state, local journal untouched.
- **No pull without a secret:** a fresh/missing store on a still-signed-in device cannot sync until a
  secret is typed (Castle) or the Standard mirror is present.
- **Castle mirrors nothing:** no synchronizable item exists under Castle (a red pin, not a comment).
- **Standard bootstrap:** a fresh device with the iCloud mirror enrolls with nothing typed.

## 6. TIMING (what can start now vs what waits for pre-13x)
**Now:** the ceremony to the unchanged §2 spec; the interop fixture; moving the journal key inside
the lockbox; device-bound tokens; the change-passphrase door to §3.4's authorization; deletion by
account password. **Waits for pre-13x** (Variorum's next phase — the record is
`notes/plans/pre-13x-postures-design.md`): the final posture copy and the exact Standard/Castle
sentences (13s re-voices both apps together), the near-empty typed-confirmation wording, and the
Standard mirror's exact item naming if Fragments wants byte-parity with Variorum's convention. The
two apps must not diverge on the LAW; copy may lag.

## 7. PROCESS
The Fragments repo stays hands-off for the Variorum side; she carries this brief; questions come back
through `notes/fragments-bridge-contract.md`. No secrets appear in this brief. The Aug-31 enrollment
brief remains the spec for everything §2 lists; this brief revises its §3–§5 framing (custody, the
doors, the postures) and supersedes the Aug-31 lockbox reply's consistency map.
