> **HISTORY (2026-09-04).** This review examined the 2026-09-01 design and drove the 09-03 rewrite; parts of it were superseded the same week (its §8 says where), and the 09-04 sittings changed the switch again. The settled design is `notes/plans/pre-13x-postures-design.md`; the arc is `notes/plans/pre-13x-design-history.md`. Nothing here binds the build.

# pre-13x — THE ARCHITECT'S DESIGN REVIEW (cold read, 2026-09-03; questions for the author)

**Status:** the pre-build review the author asked for at the pre-13x kickoff sitting ("thoroughly review it,
expose potential design flaws or ways in which we could be doing something better, and propose changes and
solutions"). Read against `notes/plans/pre-13x-postures-design.md` (the design), the 13p/14b/14c records,
and the CODE as it runs today — every mechanism below names its file. **Nothing here is ruled.** §6 is the
question list; §2 answers her four opening concerns; §3 is the proposals. The Fragments bridge retirement
(her decision at this sitting) is §4.

**The frame, first:** this phase is how Variorum keeps a writer's own words under her own key — on her Mac,
on her phone, in her backups, and on our server — with two honest postures instead of a dial matrix. The
review's job is to make sure the promise the app will print is the promise the code keeps.

---

## 1. THE VERDICT IN ONE PARAGRAPH

The two-posture model is right and should stand. The mechanisms are mostly right, and three of them are
genuinely good: sync keys inside the encrypted library (§3.2), the envelope's master wrap (§3.3), and the
re-ruled absent-store route (§3.5). The review found **one gap that breaks Castle's promise outright**
(posture is per device in the design, but the sync corpus is one thing — a Standard phone puts a Castle
Mac's sync master in iCloud; §3 P1), **one platform fact that breaks Standard's cross-device story as
written** (the Mac and the iPhone do not share a keychain access group today, so an iCloud item one writes
is invisible to the other; P8), **one lobby rule that would lock a device out after a re-key** (P5), **one
backup trap the design's own §16(b) cannot answer as posed** (one envelope per folder cannot serve
snapshots under two library keys; P6), and **one simplification the bridge retirement makes available**
(Standard's Apple-held leg belongs IN the vault as a third wrap, not as a raw key mirror; P2). Replace Keys
by account password never leaks a word in any posture — but it puts the most destructive act behind the
weakest, email-resettable, online-guessable credential, and once P1 + P2 exist no legitimate user needs
that road; the review recommends removing the account password from every encryption door (2A, P3). The rest is copy, sequencing, and pins.

---

## 2. HER FOUR CONCERNS, ANSWERED

### 2A. "Using the account password to re-key??" — her doubt is right, and the design can drop it entirely

**What Replace Keys IS (today, `Sources/VariorumCore/Crypto/AccountRekey.swift`):** mint a brand-new sync
key set (master + class keys), write it to the vault as the account's ONLY vault (the old one is replaced
whole), adopt the new keys on this device, **truncate the server's copy of the corpus**
(`account_data_truncate`, fenced on the new key id), then re-upload THIS device's library as the new truth
(`resyncReinitialize` + the ordinary drain). Every other device's held keys stop matching the vault; each
lands in "keys were replaced — re-enroll" and stays paused until someone types the (new) passphrase there.

**What it is FOR:** (a) rotation — evicting a stolen or lost enrolled device (its keys stop decrypting
anything new; the server copy is rebuilt under keys it never held); (b) recovery when the vault is
unreachable by secret — you hold a readable copy of your writing but forgot the passphrase and lost the
words, so you start sync over from what you hold; (c) since the design, "move this library to this
account" (the `owner_id` re-stamp).

**What authorizes it today:** the CURRENT passphrase (`AccountRekey.run` step 1). The design changes that
to the ACCOUNT PASSWORD + the recency warning + the understanding checkbox + (from #86(c)) a typed phrase
for the near-empty case. The motivation is real (§18-A5): an enrolled Mac with no Touch ID whose owner
forgot both secrets could sync forever but never add a device, rotate, or re-upload.

**What the account password actually is — the WEAKEST credential in the system.** It is resettable by
email, so at worst it means "controls the inbox." It is typed into browsers and autofilled. And it is
verified online through `POST /auth/v1/token`, which Supabase rate-limits at about 1,800 requests per hour
per IP (bursts of 30) with no lockout — and whose configurable sign-in limit has failed to enforce in
recorded versions (§7). The encryption passphrase, by contrast, is guessable only offline against a vault
dump, at Argon2id's 64 MiB per guess, and never leaves the client. The design puts the system's most
destructive act — wipe the server copy, pause every device, re-stamp ownership — behind its weakest lock.

**The confidentiality answer is still "never reads":** an attacker with only the account password gets a
fresh empty library, runs Replace Keys, truncates the server and uploads nothing; the old ciphertext is
gone, not decrypted; every local copy survives; anything that lived ONLY on the server is lost. But the
"deletion already has this power" comparison the design leans on is too generous. Deletion is mandated,
LOUD and TERMINAL — the account is gone and the user knows. Replace Keys is a normal-looking operation whose
damage reads as a sync hiccup ("keys were replaced"), the account persists, so the attacker keeps a
foothold and can repeat it every time the victim re-uploads. Quiet, repeatable disruption is a different
class from one loud deletion.

**The finding that ends the debate: with P1 + P2 in place, NOBODY legitimately needs Replace Keys by
account password.** Walk the roads: (a) rotation is done from an ENROLLED device — it holds the master,
which IS the proof; Touch ID (or the passphrase) confirms deliberateness; the account password adds
nothing. (b) "forgot both secrets, need to add a device" is a passphrase CHANGE from held material (the
forgot road, P4), not a re-key. (c) recovery from a stale Standard backup disappears under P2 — the
Apple-held wrap hands the CURRENT master to any device in your iCloud, nothing typed. (d) recovery in
Castle without device, passphrase or words IS the floor, by her own ruling — no door should exist. (e)
"start sync over from this library, abandoning the server" is authorized by the passphrase or the twelve
words (you are the vault's owner) — which the confused user has, and the password-holder does not. (f)
moving a library to another account: you are creating or joining that account's vault, so its passphrase
is in hand by construction.

**Recommendation:** Replace Keys is authorized by an ENCRYPTION SECRET (the passphrase or the twelve words)
or by an ENROLLED DEVICE'S held keys confirmed by Touch ID / Face ID — never by the account password. The
account password keeps exactly two jobs, and the copy can say so in one line: **"your account password signs
you in and can delete your account; it never touches your keys."** The one place the design still wanted it
— Standard's no-biometrics forgot-passphrase road — has a stricter alternative that costs Standard sync
users nothing (they always hold the twelve words, ruling 5): the words authorize; and under P2 that Mac's
owner can enroll any iPhone via iCloud and change the passphrase there with Face ID. Question 4 puts the
choice to her. Add the missing account door either way: **Sign out everywhere** (revoke every other
session; Supabase's global sign-out, §7) — the actual mitigation for a stolen account password, which the
app has no door for today.

### 2B. "An empty store + re-keying can mess a user's store up"

Three shapes, and what stops each:

1. **A confused user on a fresh install runs Replace Keys** (thinking it means "connect"). Today: the
   recency probe warns (12 notes this copy doesn't have, latest Aug 28 …) and the second press proceeds;
   #86(c) adds a typed phrase for the near-empty case. **Proposed:** the door REFUSES outright from a
   library that has no user-authored content (the sample library and tutorial do not count) and points at
   the two real roads: "enter your passphrase / twelve words to reconnect" or "delete this account and
   start over." A library with no writing has nothing to make truth; the only thing that door can do there
   is harm.
2. **A stale restored backup runs Replace Keys** and flattens newer server writing. The recency warning +
   typed phrase stand. **Proposed additionally:** the door shows "reconnect with your passphrase" FIRST —
   a stale library that can re-enroll should SYNC (merge), never re-key (clobber). And (found in this
   review) a device that re-enrolls after a re-key must `resyncReinitialize` too — see P3's trace: today it
   pulls the new server truth and silently keeps, never re-pushes, any row the server lost, so those rows
   strand on that device forever unless edited.
3. **An attacker with the account password** — under 2A's recommendation the door does not open for them
   at all: Replace Keys wants a secret or an enrolled device, and they hold neither. What remains to them is
   the mandated deletion door (loud, terminal) and a stolen session's push of tombstones (bounded by the
   30-day Trash on every device) — both disclosed, neither a read.

### 2C. "The backups and the passphrase they were stored with, and iCloud"

**The story as the design leaves it, per posture** (`StoreBackup.swift` today copies ONE envelope per
backup folder; each snapshot is ciphertext under the library key):

- **Standard:** the library key sits in iCloud Keychain under the store's ID. A backup opens on any device
  in your iCloud with nothing typed — the folder's envelope is not even consulted. A passphrase change
  touches nothing here (iCloud holds keys, never passphrases). This holds until **Standard → Castle**,
  which re-keys the store and deletes the iCloud item: from then on the pre-switch snapshots open ONLY by
  the wraps in an envelope for the OLD key.
- **Castle:** a backup opens with the passphrase or twelve words that were current when the envelope beside
  it was last written. Ruling 12 keeps the app's own folders current on every change. A Time Machine copy
  from months ago carries the envelope of its day: the passphrase you had then. The master wrap (§3.3)
  adds "the current passphrase, online" for any backup of an account whose keys were never replaced.

**The trap the design cannot answer as written (§16(b)):** there is ONE `variorum-keys.json` per backup
folder. After a Standard → Castle store re-key, the folder's envelope is overwritten with the NEW key's
wraps, and every pre-switch snapshot in that folder becomes unopenable by ANY road — its key is gone from
iCloud and its wraps are gone from the folder. "Record that pre-switch backups open with the passphrase
you had then" is therefore FALSE unless the old envelope is preserved. P6 proposes envelopes named per key
fingerprint (one per library key, never overwritten), a new store ID whenever the library key changes, and
a decision at the switch: re-key the retained snapshots (cost measured in batch 0) or delete them with a
sentence — deleting the backups that were under the key iCloud held is arguably what Castle MEANS.

**The twelve words and Replace Keys:** today the words DIE at a re-key (the new vault is born without a
recovery wrap; new words follow). So every old backup's envelope holds a recovery wrap under words you were
told to throw away. P6 proposes letting the words SURVIVE a re-key by choice ("type your twelve words to
keep them, or generate new ones") — the words are a separate secret from the device being evicted, and a
stable recovery phrase makes the one backup sentence simple and true: *your twelve words open any backup
you ever made, unless you regenerated them.*

### 2D. The Fragments bridge

**I agree with retiring it, and I would not reconsider.** The reasons, in order of weight:

1. **Every posture ruling would carry a Fragments clause forever.** The Fragments agent's own analysis found
   the load-bearing one: postures are per app but the journal is one corpus, so its protection is the
   weaker app's posture — which needs a SUITE-LEVEL posture floor, a cross-repo design she would carry by
   hand and keep in step by hand at every change. That is coordination cost, not code cost, and it never
   ends.
2. **The vault format is frozen by the bridge.** The design says "the vault format is untouched" in five
   places, because Fragments reads it. With the bridge gone the vault can carry what pre-13x actually
   needs — an account-level posture and Standard's Apple-held wrap (P2) — which removes a whole custody
   mechanism (the raw sync-key mirror) and makes posture a fact on the account instead of a per-device
   setting that can drift.
3. **Her own test is the right test:** it is not on either app's v1 feature list; it is on the list by
   history. It works, it is encrypted, and it is still a second sync engine with its own hash sweep,
   duplicate-day pause, deletion travel, re-push staging inside Replace Keys (`AccountRekey.swift`
   step 6), a class key in the vault, and a daily-Journal identity that "can never be hard-deleted because
   the bridge cannot be rebuilt" (13i-e). Retiring it simplifies 13i-e too.
4. **The revival shape she named is the right one:** if the bridge returns, it returns as SHARED ROWS on
   Variorum's own sync (the collaboration era; a Fragments user as an outside collaborator on a journal
   book), not as a second engine speaking a second dialect. Nothing built for the old bridge is needed for
   that, so parking it on a branch loses nothing.

**What retiring costs, honestly:** her phone's Fragments journal stops flowing into Variorum's daily Journal
(and back). Until collaboration exists, the journal is written in ONE app or the other. That is the real
price and it is hers to weigh; on the v1 evidence I would pay it.

**How (details in §4):** a branch cut from main today preserves everything; on main the bridge is REMOVED
(not disabled) — the code, the door, the session, the tests, the plan rows — in its own batch with its own
cold review, BEFORE the crypto batches, so the deletion never mixes with key changes in one diff. The vault
keeps its `journal_bridge` class key column (the server column is NOT NULL; minting a key nobody uses is
free); one outbound line to the Fragments agent through the contract file closes their 20.10 work.

### 2E. THE ADVERSARY SHE NAMED — "someone with access to their unlocked Mac, which is probably logged into their email" — walked road by road against the design AS WRITTEN

Her sharpened requirement (this sitting): *"even someone with access to their unlocked mac (which probably
is logged into their email) won't be able to get their work."* That is Castle's adversary, precisely.
Give them everything that follows from an unlocked macOS session: the file system, the app's own
device-bound SESSION (sign-in is no barrier on that Mac — the tokens are there), the email (so the account
password, by reset), any iCloud item the APP can read on that Mac. Deny them: the passphrase, the twelve
words, an enrolled finger. Goal: read the writing.

| road | design as written | verdict | closed by |
|---|---|---|---|
| the lobby (Variorum locked) | Touch ID refuses a foreign finger; the passphrase is unknown | **holds** — with one caveat: `.biometryCurrentSet` and `confirmPresence` accept ANY finger enrolled on that macOS user account (a spouse's); the copy must say so, and "always ask for the passphrase" is that user's answer | P9.6 (copy) |
| the app left OPEN and unlocked | readable on screen until re-lock | **holds as disclosed** — Castle's stated cost; the idle dial + sleep/screen-lock re-lock + Lock Now bound it; nothing in software changes this without the per-note theater she refused | — |
| the library file, its backups, Time Machine | SQLCipher ciphertext; the key is gated (`WhenUnlockedThisDeviceOnly` + biometry) or absent; the envelope's wraps need a secret | **holds** (pre-switch Standard backups under the old key: P6) | — |
| **Change passphrase inside an open Castle session** | §4: "nothing more if you typed it" (always-ask mode); Touch ID if opened by Touch ID | **READS EVERYTHING.** An always-ask user opens at 9:00, steps away at 9:20; the adversary changes the passphrase with no re-auth, now HOLDS a passphrase that unwraps the vault, enrolls their own machine, and reads the whole corpus by sync, forever, from anywhere — long after the Mac is out of reach | **P4** (always re-ask the current passphrase; the forgot road needs Touch ID, which refuses them) |
| **Regenerate the twelve words inside an open session** | §4: "same as change-passphrase" — this RELAXES today's CF-2 (passphrase-gated) | **READS EVERYTHING** by the same route (new words → enroll) | **P4** |
| the email → account password → their own machine → enroll | needs the passphrase or words | **holds** | — |
| the email → account password → their own machine → Replace Keys | allowed from an empty library; truncates the server; reads nothing | holds for reading; disruption + a kept foothold | **P3** (a secret or an enrolled device; refuses from an empty library) |
| **move the store aside on the Mac → "start a new library" → the new library defaults to Standard** while the user's PHONE runs Standard (per-device posture) | the new library reads the account's sync-key MIRROR through the app on that Mac (its iCloud is the Mac's) and pulls the corpus | **READS EVERYTHING** under the design's per-device posture whenever any sibling device is Standard | **P1 + P2** (posture is the account's; a Castle account has no Apple-held wrap and no mirror) |
| the plaintext `.sqlite` export in an open session | asks for the passphrase | **holds** | — |
| the bulk `.md` export of the whole library in an open session | no authorization today (a menu act) | holds strictly (open = readable), but hands the adversary the whole library as plaintext in ONE gesture | **new question 12**: gate the LIBRARY-wide export behind the passphrase in Castle, as the sqlite export is; single-note export stays free |
| account deletion by account password | server copy + vault gone; local copies untouched | holds for reading; disclosed; mandated | — |
| a stolen session pushing tombstones from a custom client | deletions land in the 30-day Trash everywhere | holds for reading; disclosed | 13y's re-auth for destructive RPCs |
| the recovery phrase on the clipboard at generation (the COPY ALL item joining this phase) | Universal Clipboard carries it to every device in the iCloud | a real window | P9.11: clear the clipboard after 60 s, the password-manager convention |

**The reading:** against her named adversary the design has exactly two roads that read the writing, and
both come from the same instinct — treating "the library is open" as sufficient authorization to mint a NEW
secret. Reading an open library is Castle's disclosed cost and ends when the app re-locks; a new secret
outlives the Mac. P4 and P1/P2 are therefore not polish. They are the phase.

---

## 3. THE PROPOSALS (each: the flaw traced → the change → the cost)

### P1 — Posture is an ACCOUNT fact. Castle on one device is Castle on all of them.

**Trace.** §3.1 stores `posture` per store ID in UserDefaults — per device. §9 makes the phone "a
first-class birthplace of Castle." Nothing makes the two agree. Now walk it: her Mac is Castle; her phone
is Standard. The phone's Standard custody mirrors the ACCOUNT's sync keys — master included — to iCloud
Keychain (§3.1 row 2). The Mac's §2 promise "someone in your iCloud? yes [stopped]" is now false: whoever
is in her iCloud holds the master that decrypts every row on the server, and with her email (password
reset) a session to pull them. **This is the Fragments agent's "asymmetry on a shared corpus," and it
applies inside Variorum across its own devices.** It also bites the Standard → Castle ceremony: the Mac
re-keys and deletes its items, the other devices re-enroll — and if one of them is still Standard, it
writes the NEW master straight back into iCloud.

**Change.** When sync is on, the posture belongs to the ACCOUNT, and every device enforces it: a Castle
account's devices must all open through a gate (Touch ID / Face ID with passphrase fallback, or always
ask) and none may hold an iCloud copy of anything; a device joining a Castle account runs the Castle
ceremony before it can sync. What stays per device is the GATE STYLE (Touch ID vs always-ask; the idle
minutes). A local-only library (no account) keeps a device posture; joining an account reconciles it at
enrollment. Where the account fact lives: in the vault (P2 makes it derivable — Standard ⇔ the vault
carries an Apple-held wrap), or, failing P2, a synced `setting` row (plain enum, allowed by the 14b
classification; zero schema).

**Cost.** A ceremony rule + one fact + enforcement at enrollment; copy: "Castle is a choice for your whole
account; every device will ask." No new crypto.

### P2 — Standard's Apple-held leg belongs IN THE VAULT (a third wrap under an iCloud Keychain KEK), not a raw key mirror. The bridge retirement is what makes this possible.

**Trace.** §3.1 puts Standard's sync keys in TWO places: inside the library, and in "an iCloud-synchronizable
mirror item (the `DeviceKeyMaterial` JSON, per account)" — the raw master and class keys in iCloud. Then §4
has to "REWRITE the mirror" at Replace Keys, §18-I row 7 has to invent "prefer the mirror when the store's
keys mismatch the vault," and a device that re-keys while another Standard device is offline leaves a
stale raw-key item in iCloud until that device notices. The design took this shape because the vault format
had to stay byte-identical for Fragments (its §10). That constraint is gone.

**Change.** The vault gains one OPTIONAL wrap: `master_wrapped_by_apple_held` + an `apple_held_key_id`. The
wrapping key (the KEK) is a random 256-bit key in ONE iCloud-synchronizable Keychain item per ACCOUNT
(service `io.lduarte.Variorum.apple-held`, account = user id, in the SHARED access group — P8). A Standard
new device: sign in → read the vault → KEK from iCloud → unwrap master → class keys → sync, nothing typed —
the design's promise, kept with the vault as the single truth about keys. Replace Keys writes the new vault
WITH the wrap under the SAME KEK (the KEK never goes stale; nothing to "rewrite" on devices). Standard →
Castle: Replace Keys writes the new vault WITHOUT the wrap (a copied master cannot be un-copied — the
design already re-keys here) and deletes the KEK item (propagates). Castle → Standard: add the wrap, mint
or reuse the KEK. **Posture becomes derivable and account-wide: Standard ⇔ the wrap exists.** The library
key's per-store iCloud item STAYS (the no-sync Standard user needs it; and it is the offline road), but a
sync user gets a second road to any backup: KEK → vault → master → the envelope's master wrap → key. The
raw `DeviceKeyMaterial` mirror is not built.

**Trust accounting.** The server holds a wrap; Apple's iCloud Keychain holds the KEK; neither alone reads.
That is strictly less exposure than a raw-key mirror in iCloud, under the same posture sentence ("your
Apple account and its recovery paths hold the key"). This is the memo's own §8a design (Apple-held
recovery), which she deferred as "a step down" — Standard IS that step, already ruled; this is only the
cleaner implementation of it.

**Cost.** One additive server migration on `key_vault` (two nullable columns; account data via PostgREST,
not a sync-table lockstep — old clients ignore unknown columns; her deploy window), the `KeyVaultFormat`
field + wire row, one Keychain item family (the escrow family's exact shape, `StoreKeyGuardKeychain
.saveEscrow`), and the enrollment road. It REMOVES the mirror item family, the mirror-rewrite leg of Replace
Keys, and the "prefer the mirror" corner.

### P3 — Replace Keys: a SECRET or an ENROLLED DEVICE authorizes it (never the account password); the door is narrower, presented second, and stale devices resync on re-enrollment.

**Traces.** (i) §4: authorization = the account password; 2A above — the weakest credential in front of
the most destructive act, with no legitimate user left once P1 + P2 exist. (ii) §4: "an OPEN library (empty
counts)" — an empty library has no legitimate re-key; it is the attacker's and the confused user's road.
(iii) The re-enrollment road after a re-key: `EncryptionSession.enroll` → `adopt` → `onKeysChanged` → a
sync round. The stale device pulls the re-keying device's re-upload; server rows overwrite its clean local
rows; but any row the SERVER lost (the re-keying copy was stale) sits on this device clean and out of the
outbox — never pushed. Only an edit re-enqueues it, and then `sync_push` answers `rejected, current: null`
for a nonzero base (`10_phase13j_purge.sql` §4) and the client rebases to 0 and lands it
(`SyncEngine.swift:189`). Untouched rows strand on that device forever. (iv) The `owner_id` re-stamp is a
footgun when the signed-in account differs from the library's stamps (a family member's account, a second
account): the whole library silently moves.

**Change.** (a) **Authorization:** the current passphrase or the twelve words; OR, on an enrolled device
that holds the master, Touch ID / Face ID (the held keys are the proof; biometrics confirm deliberateness).
The account password is not accepted. (b) Refuse Replace Keys from a library with no user-authored content;
the copy names the two real roads (reconnect by passphrase / twelve words; delete account and start over).
(c) Whenever the server is ahead: the count-and-dates warning + the typed phrase (#86(c)) — never a
click-through. (d) The Encryption surface offers "reconnect with your passphrase" FIRST and Replace Keys as
the road of last resort, with its sentence: "this device's copy becomes the truth; other devices re-enroll;
anything only on the server is gone." (e) Re-enrollment on a device whose keys were replaced runs
`resyncReinitialize` before its first round (its whole copy re-enqueues; CAS merges; nothing strands).
(f) The owner re-stamp is a NAMED step in the confirm ("this library was last synced by <account>; it will
move to <account>") and requires the typed phrase when the stamps disagree.

**What A5's device does instead** (enrolled, no Touch ID, forgot both secrets): it keeps syncing (it holds
the master). To add a device it CHANGES the passphrase from held material (P4's forgot road — Standard:
the twelve words, or the account password if she keeps that arm; Castle always-ask: it typed the
passphrase to open). To rotate after a theft it needs one of the same. Under P2 a Standard owner can also
enroll an iPhone via iCloud with nothing typed and change the passphrase there with Face ID.

**Cost.** A predicate, copy, one `resyncReinitialize` call, the authorization arm (the 14b
`VaultEnrollment.enroll` unwrap is the check), and the pins §12 already lists.

### P4 — Every secret-changing door re-authenticates, in every posture. Never "you typed it earlier."

**Trace.** §4 Change passphrase, Castle: "nothing more if you typed it"; Regenerate: "same." So on a Castle
Mac in always-ask mode, opened at 9:00 and left unlocked at 9:20, a visitor changes the passphrase (and now
holds the key to enroll their own device for good) or regenerates the twelve words (and the paper copy in
the drawer dies silently). Reading an open library is Castle's stated cost; silently gaining a PERMANENT
key is an escalation the re-lock timer alone should not carry.

**Change.** The primary door for Change passphrase and Regenerate words asks for the CURRENT passphrase
(the shape every user already knows; the 14b door `VaultEnrollment.changePassphrase` exists). "Forgot it?"
opens ruling 3's road: Touch ID / Face ID where present; in Standard without biometrics, the twelve words
(every Standard sync user holds them, ruling 5) — or the account password, if she keeps that arm (question
4); in Castle always-ask there is no forgot road on an unlocked device by construction (you typed it to get
in). The vault's held-material re-wrap (`rewrapPassphrase(material:)`) stays the mechanism behind
the forgot road only. The other devices' one-time prompt ("your passphrase was changed on another device")
doubles as tamper evidence — keep it firing even for devices that open by biometrics (the design says so).

**Cost.** Copy + one extra field. It also removes the "you may have forgotten it" special case from §4.

### P5 — The lobby's retired-passphrase rule must tell a passphrase CHANGE from a key REPLACEMENT.

**Trace.** §3.4 Rule 1: "if online and the vault's descriptor ≠ the envelope's recorded one, the typed
passphrase is verified against the VAULT, never the cache — the old passphrase is refused." A Replace Keys
elsewhere ALSO changes the descriptor (fresh salt, `AccountRekey.swift` step 2) — and the vault's new master
does not unwrap the envelope's master wrap (old master). A Castle user who opens by passphrase after a
re-key on another device types the passphrase that still opens the LOCAL wrap, Rule 1 sends it to the
vault, the vault refuses it (new vault, new passphrase or same passphrase but a master that opens nothing
here), and the lobby says "your passphrase was changed on another device" — a lockout with a wrong
sentence, on a device whose local wrap was perfectly good.

**Change.** The envelope (format 2) records the vault's `corpus_key_id` beside the descriptor. Same key id +
different descriptor = a passphrase change → enforce the vault's answer (Rule 1). Different key id = keys
were replaced → the LOCAL wrap stands as a road, and the device lands in "keys were replaced — re-enroll"
after unlock (CF-16's state, exact). Add the pin: "a re-key elsewhere never locks a device out of its own
library."

### P6 — Backups: one envelope per LIBRARY KEY, a new store ID when the key changes, and twelve words that survive a re-key by choice.

**Trace.** 2C above. `StoreBackup.copyKeyEnvelope` writes one `variorum-keys.json` per folder; a store re-key
overwrites it and orphans every older snapshot. §3.5/ruling 8 scope custody per store ID, but the store ID
lives in the envelope and a re-key that keeps it would leave an iCloud item under that ID holding a DEAD
key on any device restored from an older backup (§18-C's second bullet is this collision, un-named).

**Change.** (a) Envelope files named by key fingerprint (`variorum-keys-<fp>.json`) — a folder holds one per
library key it has ever held; nothing is overwritten; the restore surface picks by the snapshot's own key
fingerprint (SQLCipher cannot read it — record the fingerprint in the snapshot's filename or a sidecar at
backup time). (b) A store re-key mints a NEW store ID (new envelope identity), so per-store-ID custody stays
coherent forever: old ID ↔ old key. (c) At Standard → Castle, ONE ruling (§16(b), re-posed with the trap
visible): re-key the retained snapshots in both destinations (batch 0 measures the cost — 18 exports), or
delete them with the sentence "your older backups were under the key iCloud held; Castle starts here."
Recommendation: re-key if under ~1 minute total on her store; else delete-with-consent. (d) Replace Keys
offers "keep my twelve words" (type them; the new master is wrapped under the same recovery key) beside
"generate new ones." The one user sentence then reads: *a backup opens with your twelve words (always,
unless you regenerated them) or the passphrase you had when it was made — and, in Standard, through your
iCloud.*

### P7 — Standard → Castle re-keys the store by EXPORT-AND-SWAP, not in-place `PRAGMA rekey`.

**Trace.** §4 names `PRAGMA rekey`. The store runs WAL with a connection POOL (readers open); an in-place
re-key rewrites every page and wants exclusive access; a crash mid-way leaves a half-re-keyed file. 13p's
migration already solved this shape: `sqlcipher_export()` into a fresh KEYED file → verify → atomic swap →
remove the old `-wal`/`-shm` (`notes/plans/phase-13p-note-protection.md` THE DESIGN). It is crash-safe at
every step, proven on her real store, and it naturally produces P6(b)'s new identity.

**Change.** Reuse the migration road for the switch; batch 0 measures export time on her store. The lookup
(§7) adds a second reason: under WAL, `PRAGMA rekey` cannot change the header salt, so the salt is REUSED
across the old and new key — export-and-swap mints a fresh file, fresh salt included. Either way, the
switch closes the pool first, runs off-main, and the iCloud items are deleted LAST (§18-I row 8's marker).

### P8 — The Mac and the iPhone must share a keychain access group, or Standard's cross-device story does not exist.

**Trace (measured this review).** The Mac carries `keychain-access-groups =
*[removed for publication]*
(`App/Variorum/Variorum.entitlements`). The iOS target (`io.lduarte.VariorumMobile`) has NO entitlements
file (`find App -name '*.entitlements'` → one file), so its default group is
*[removed for publication]*
group; the phone cannot query it. Every Standard row in §2's table that says "a new device: nothing typed"
across the two apps is false until this is fixed — and it was never measured, because the escrow item's
round-trip was verified on ONE machine.

**Change.** Add ONE shared group to BOTH entitlements (e.g. `$(AppIdentifierPrefix)io.lduarte.Variorum
.shared`) as a SECOND entry — the first (default) group stays what it is, so nothing already written strands
— and write every iCloud item (the library key item; P2's KEK) with an explicit `kSecAttrAccessGroup`
naming the shared group. Batch 0 measures propagation Mac ⇄ phone (the design's item 2 — community reports range from
seconds to hours, no Apple number exists; the "waiting for iCloud Keychain" state with the passphrase
fallback beside it is therefore load-bearing, not a corner). The Developer ID build must carry both (the
standing KnownIssues row widens to two groups). One correction to §18-H's line: a keychain item inside an
iCloud DEVICE BACKUP is wrapped with a device key and restores only to the same device (§7) — the new-phone
road is iCloud Keychain SYNC after the restore, never the backup itself; the copy must not say "restore."

### P9 — Smaller items (each a step, not a deferral)

1. **A passphrase-strength floor at the SET ceremony.** The passphrase wrap is the ONE brute-forceable thing
   in the design (Argon2id 64 MiB / t=3 slows, never stops). Today the floor is "non-empty" with a CLI-only
   under-12 warning (`VaultBootstrap.swift:86`). Castle's server-side promise is only as strong as this.
   Recommend a real minimum (12 characters, or a strength meter with a floor) and the one sentence why.
2. **A "Sign out everywhere" door** (revoke every other session) beside change-account-password — the actual
   mitigation for a stolen account password / cloned session. Supabase's sign-out with `scope: global`
   terminates every session for the user (§7).
3. **Re-authentication hygiene** (only if any account-password confirm survives question 4): the confirm is
   a password grant; it mints a session. Adopt it as the current session or sign that scratch session out —
   never leave a stray live refresh token. It shares `/auth/v1/token`'s IP-scoped limit (~1,800/hour) and
   the sign-in limit has had enforcement bugs (§7) — 13y's abuse guard must name and TEST it.
4. **The plaintext SQLite export** should be produced by a keyed `sqlcipher_export` into a plaintext
   ATTACHed file that NEVER receives the local tables (`sync_state`, `sync_outbox`, `sync_row_seq`,
   `_sync_applying`, `purge_*`) — a copy-then-strip leaves the master in free pages of the plaintext
   file. Pin: the export file has no `sync_state` table and no key-shaped values anywhere.
5. **§2's Castle row conflates two claims.** "Someone with your Mac's login password? yes [stopped]" is
   about OPENING. While Variorum is open and unlocked it is readable until it re-locks — the shipped
   `openAppIsReadable` sentence must ride the Castle row, with Lock Now and the idle dial named as the
   answer. (P4 is what keeps "readable" from becoming "keyed.")
6. **Touch ID on a shared Mac:** `confirmPresence` and the `.biometryCurrentSet` item both open for ANY
   finger enrolled on that macOS user account. Copy: "anyone whose fingerprint is enrolled on your Mac
   account." (Separate macOS accounts have separate fingerprints — the honest advice for a shared Mac.)
7. **Account deletion** should also delete the account's iCloud KEK item best-effort (P2) — hygiene, since
   the vault it unwraps is gone anyway.
8. **Store-level recovery wrap becomes a CACHE too.** With the master wrap, the twelve words open a Castle
   library ONLINE through the vault (words → master → master wrap → key) even before the store's own
   recovery wrap is landed on a second device. The lobby's dead-end sentence must count that road; the
   local wrap lands lazily the first time the words are typed (the §11 backfill's own pattern).
9. **The Standard library-key item has NO access control and reads AfterFirstUnlock** — correct for the
   posture, but the copy for "someone at your unlocked Mac" should say "or anyone who can run Variorum on a
   Mac signed into your iCloud."
10. **`openResettingModeToAuto` exists on the phone too** (`StoreLaunchGate.swift:198` is shared) — the
    re-rule lands on both by construction; the pin runs on both targets.
11. **The recovery phrase's COPY ALL** (the 13u2 item joining this phase): Universal Clipboard carries the
    clipboard to every device in the iCloud. Clear it after 60 seconds (the password-manager convention)
    and say so beside the button.

---

## 4. THE BRIDGE RETIREMENT — what changes in the plan

**Footprint (measured):** `Sources/VariorumCore/Bridge/` (6 files, 2,226 lines), the app's
`BridgeSession.swift` / `BridgeStatusViews.swift` / the Fragments-project delegated session in
`AuthSession.swift`+`SignInFlow.swift`, the bridge leg of `AppServices.swift` and `SyncSession.swift`, the
`DeviceBridgeKeyProvider`, `AccountRekey.swift` step 6 (`stageRepushFromTruth`), the `journalBridge`
class in `DeviceKeyMaterial` (STAYS — format), 13 core test files + 2 app wiring tests, the contract file,
the 13v row, the `shelveInDailyJournalBook` bridge caller, and the Fragments sections of the design (§10,
§14 item 14, §18-C's last bullet, the Castle ceremony's Fragments line).

**The shape I recommend:**
1. **Branch first:** `git branch fragments-bridge-archive` at today's `main` (no rewrite, nothing lost;
   a `notes/` README on that branch saying what it holds and how it would be revived).
2. **On `main`, a REMOVAL batch — pre-13x batch 0b, run BEFORE the crypto batches, with its own cold
   review:** delete the bridge module, its app seams, its tests and its rows; `AccountRekey` loses step 6;
   the vault keeps minting a `journal_bridge` class key (the column is NOT NULL and Replace Keys needs a
   full wire row — one comment marks it dormant); canon deltas (AppSpec §7/§9's bridge paragraphs, SyncSpec
   §3's bridge note, CoreDescription's 9b mention, the 13v FuturePhases row → retired, MobileSoul's bridge
   lines); the design file drops its §10. Why a separate batch: a 2,000-line deletion and a key-custody
   change must never share a diff a reviewer has to read as one.
3. **One outbound carry item** in `notes/fragments-bridge-contract.md` for her to hand the Fragments agent:
   the bridge is retired for now; 20.10's ceremony is moot; Fragments' own journal encryption is its own
   business; the account/issuer arrangement (14a/14d) is UNCHANGED — this retires the bridge, not the
   single Stargazing account.
4. **13i-e gets simpler:** "the daily Journal can never be hard-deleted because the bridge cannot be
   rebuilt" loses its reason; the memo's other half (a first-class identity, convergence on the marker)
   stands on its own merits.

---

## 5. THE FRAGMENTS AGENT'S ITEMS, DISPOSITIONED FOR VARIORUM

| their item | Variorum disposition |
|---|---|
| bind session tokens `ThisDeviceOnly`; refresh on 401; a calm caption when the session is gone | already the design's §3.1; keep |
| Idea A (lockbox-wrapped class key) / Idea B / Idea C | Fragments-only; moot |
| Replace Keys by account password from an empty store lets a password holder truncate the server copy | **2A / P3** — agreed and taken further: the account password authorizes NO encryption door; Replace Keys wants a secret or an enrolled device, and refuses from a library with no writing |
| Castle can only ever mean the journal in Fragments | moot |
| **postures are per app but the corpus is one — the protection is the weaker posture's** | **P1** — the same truth across Variorum's own devices; the one item to keep from the whole exchange |
| a second crypto writer with no shared test vectors | moot — and its absence is what frees the vault format (P2) |
| Fragments-only users have no encryption until they touch Variorum | moot |
| "suite law" | moot; the law is Variorum's alone now |

---

## 6. QUESTIONS FOR HER (each with the recommendation first)

1. **Retire the bridge as §4 describes** — branch + a removal batch first (0b), with its own review, before
   any key changes? *(Recommend yes.)*
2. **P1 — posture account-wide when sync is on:** Castle on any device is Castle for the account; the gate
   STYLE stays per device. Agree? *(Recommend yes; without it Castle's iCloud promise is false.)*
3. **P2 — Standard's Apple-held leg as a vault wrap under one iCloud KEK**, replacing the raw sync-key
   mirror; one additive server migration on `key_vault` in your deploy window. *(Recommend yes — fewer raw
   keys in iCloud, nothing to rewrite at re-key, posture derivable.)* If no: P1 needs a synced `setting`
   row for the account posture instead.
4. **P3 — Replace Keys authorized by a SECRET or an ENROLLED DEVICE, never the account password** (your
   doubt, confirmed by the trace: no legitimate user needs the password road once P1 + P2 exist); refuse
   from a library with no writing of its own; "reconnect by passphrase" offered first; the typed phrase
   whenever the server is ahead; re-enrolling devices resync; the owner re-stamp named in the confirm.
   *(Recommend all.)* **Sub-question — the ONE remaining account-password arm:** Standard's
   forgot-passphrase road on a Mac without Touch ID. Keep it (ruling 3's letter; the desk is already
   conceded in Standard), or make the twelve words the only confirmation there (stricter; costs a Standard
   sync user nothing — they always hold the words; a Standard user can also enroll an iPhone via iCloud
   and change the passphrase there with Face ID)? *(Recommend the words — then the sentence "your account
   password never touches your keys" is true without exception, and the plaintext export in Standard asks
   for the passphrase where one is set, else a plain confirm.)*
5. **P4 — secret-changing doors always re-ask** (current passphrase; "forgot it?" → Touch ID, else the
   account password in Standard). This softens ruling 3's "nothing more if you typed it." *(Recommend
   yes.)*
6. **P6(c) — at Standard → Castle, re-key the retained snapshots or delete them with a sentence?**
   *(Recommend: re-key if batch 0 measures under a minute on your store; else delete-with-consent.)*
7. **P6(d) — let the twelve words survive Replace Keys by choice** ("keep my words: type them" / "new
   words")? *(Recommend yes — it makes the backup sentence one sentence.)*
8. **P9.1 — a passphrase minimum at the set ceremony:** 12 characters, or a strength meter with a floor?
   *(Recommend a 12-character floor + the one sentence why: it is the only thing a stolen server copy can
   be brute-forced against.)*
9. **P9.2 — "Sign out everywhere"** as a new account door in this phase? *(Recommend yes; small.)*
10. **§16's still-open items, unchanged:** (a) CF-11 forget door folded into sign-out *(yes)*; (c) a keyless
    byte-copy backup at lock time *(yes, the app's own folder only)*; (e) Castle's idle re-lock default
    *(off; 15 minutes when on)*; (f) the account-password minimum *(12, same floor as the passphrase)*;
    (g) the posture copy — 13s re-voices; (h) default the backup folder into iCloud Drive under Standard
    *(offer it at the first backup run with the one sentence; never silently)*.
11. **The pre-unlock vault read (§3.4)** contacts the server before the Castle lobby opens. You ruled
    "nothing runs before unlock" for the STORE; this is one account read. Fine as stated? *(Recommend yes,
    disclosed in the lobby's copy.)*
12. **Gate the LIBRARY-wide `.md` export behind the passphrase in Castle** (as the plaintext `.sqlite` export
    already is), leaving single-note export free? *(Recommend yes — 2E's table: it is the one gesture that
    hands an open library to a visitor whole.)*

---

## 7. FACTS VERIFIED BY LOOKUP (2026-09-03; a read-only helper; sources named)

- **`PRAGMA rekey` under WAL:** works, but "the key salt, stored in the database header, can't be changed
  and is therefore reused" (Zetetic community material); cost is proportional to database size — Zetetic
  staff: "rekey operations are expected to be fairly time consuming because they have to decrypt and
  re-encrypt the entire database" (discuss.zetetic.net/t/pragma-rekey-performance/4049); `PRAGMA rekey`
  "can not be used to encrypt a standard SQLite database" (zetetic.net/sqlcipher/sqlcipher-api). No
  authoritative statement found that other connections must be closed or a checkpoint run first — treat
  both as required anyway. → P7 (export-and-swap).
- **iCloud Keychain OFF:** items "are stored locally on your device" (support.apple.com/en-us/109016) → the
  on-device key comes free; the new-device road closes. → §3.6.
- **Deletion propagates** across the iCloud Keychain circle (Apple Community guidance; consistent with
  Apple's secure-keychain-syncing guide) — an inference from documented behavior, not a quoted API contract.
- **Access-controlled items do not sync**; `kSecAttrSynchronizable` and `ThisDeviceOnly` are mutually
  exclusive (Apple developer forums, several threads). → the design's two-item premise holds.
- **Shared access group required:** "each application using this password must have the Keychain Access
  Groups Entitlement enabled, and a common access group specified" (developer.apple.com/documentation/
  security/sharing-access-to-keychain-items-among-a-collection-of-apps). → P8.
- **Keychain items in an iCloud device backup are device-key-wrapped** — "they can only be restored to the
  device that originally backed them up" (Apple DTS, developer.apple.com/forums/thread/93373); a new device
  receives them only through iCloud Keychain SYNC. → P8's correction to §18-H.
- **Propagation latency:** no Apple number; community reports from under a minute to hours. → the waiting
  state is load-bearing.
- **Supabase global sign-out:** `signOut({ scope: 'global' })` — "all sessions active for the user are
  terminated" (supabase.com/docs/guides/auth/signout). A password change terminates the session ("the user
  changes their password or performs a security sensitive action" — guides/auth/sessions); whether it
  terminates ALL sessions on a self-service change is not confirmed from primary docs. → P9.2: offer the
  explicit door rather than relying on the password change.
- **Rate limits:** `/auth/v1/token` is limited per IP at 1,800 requests/hour (bursts of 30), the table not
  distinguishing the password grant from refresh (supabase.com/docs/guides/auth/rate-limits); GitHub issues
  supabase/auth#2333 and supabase/supabase#41947 report the configurable sign-in limit NOT enforced in some
  versions. → 2A; 13y's abuse guard must test, not assume.

## APPENDIX — who holds what under the PROPOSED shape (the table the copy should render from)

| holds | Standard | Castle |
|---|---|---|
| the library key | this device's Keychain (silent) · iCloud Keychain (per store ID, shared group) · the envelope's wraps (passphrase · words · master) | the gated item or none · the envelope's wraps only |
| the sync master + class keys | inside the library · the vault under passphrase + words + **the Apple-held KEK** | inside the library · the vault under passphrase + words only |
| the KEK | one iCloud Keychain item per account | does not exist |
| the session | this device only | this device only |
| what the account password alone can do | sign in · delete the account · (if she keeps that arm) confirm a forgotten-passphrase change on a Mac without Touch ID · **never read, never re-key** | sign in · delete the account · **never read, never open, never change a passphrase, never re-key** |
| a new device gets everything by | iCloud + sign-in, nothing typed | sign-in + the passphrase or twelve words, once |
| the floor | lose every Apple device and every Apple recovery path and (if set) both secrets | lose every enrolled device and both secrets |

---

## 8. SECOND PASS — the shape after her evening reply (2026-09-03; recorded before the reply, so it lives in the repo, not the chat)

**Her positions, verbatim-faithful:** the open-app attacker is not a fair gate ("at that point, it's kinda
wraps"); the point is to be unlike Day One, whose "password-locked" database reads from the terminal;
re-auth inside an open Castle session is acceptable ("you need touchid or recovery phrase even inside an
open Castle session — shouldn't be an issue for a user that got into the session, so whatever"); a Standard
phone under a Castle Mac is "obviously an issue"; the bridge is retired, as its own batch first; with
Standard's leg in the vault "nobody needs an account password road"; the twelve words may stand in for
Touch ID on a Mac without it; "if you're in castle mode, you NEED TO KNOW your passphrase or your 12
words. we cannot save users from that simple fact"; changing the MODE to Standard must need the passphrase
or Touch ID; deletion by account password is natural; re-enrollment must re-initialize sync; the backup
file being overwritten "absolutely shouldn't happen"; the words surviving a re-key "would be nice"; the
set ceremony for Castle or sync "should ABSOLUTELY REQUIRE both a passphrase and the 12 words," impressed
on iCloud users too; "sign out everywhere" may be "the real mitigation that I need instead of re-key";
she wants "passphrase + 12 words for everyone, then iCloud for those who want the ease + less risk" — still
not NO risk, and that floor stated. Open questions she asked: should re-key be OFFERED at all (Standard
Notes does not); what happens to the master and to other devices at a re-key; how the "confused user"
reaches re-key at all when logged-in ≠ unlocked; does a deleted-then-recreated account sync its old
library; is the memo-era four-row table still true; "am I making a mess?"

**The refinement this pass adds — ONE Apple-held KEY, and every Apple-held leg is a WRAP under it:**
P2 put the master's Apple-held wrap in the vault under an iCloud-Keychain KEK. Take it to its end: the
ENVELOPE gains the same wrap for the LIBRARY key, under the SAME KEK. Standard = each locked box (vault,
envelope) carries one extra wrap under the Apple key; Castle = neither does. Consequences, all
simplifying: (1) NO raw key ever sits in iCloud — not the library key item the design had, not the sync-key
mirror; iCloud holds exactly one random key that unwraps nothing on its own; (2) the Standard → Castle
switch becomes "remove the Apple-held wraps + delete the KEK item" — NO store re-key, NO Replace Keys, NO
device re-enrollment, other devices simply adopt the gate at their next open; P7 dissolves and P6(c) dissolves
with it; (3) the no-account Standard user gets the same recovery road as the sync user (KEK → envelope →
library key on a new Mac with a copy of the library), one mechanism for both populations; (4) the KEK is
re-mintable from any enrolled device if Apple's account recovery ever resets iCloud Keychain — self-heal,
logged; (5) posture is DERIVABLE and account-wide: Standard ⇔ the vault (or, with no account, the
envelope) carries an Apple-held wrap. The day-to-day silent open under Standard is unchanged: the device
Keychain's bound item, this device only.

**Re-key, resolved:** with the KEK model the only thing a Standard → Castle switcher might want to
"un-copy" is a master someone ALREADY extracted through their Apple account before today — the same class
as "my passphrase was already stolen," and the same rare answer: rotate. So: **no user-facing "Replace
Keys" front door in v1.** Everyday tools are Change passphrase (a leaked passphrase), Sign out everywhere
(a leaked session), and the lock itself (a lost device). The rotation machinery (`AccountRekey`) stays for
the headless migration tool and, if she wants it, an "Advanced ▸ Rotate encryption keys" door from an
ENROLLED device, authorized by the passphrase or the words, with the recency count + the typed phrase, and
"keep my twelve words" by typing them. The empty-store confusion, the account-password debate, and the
stale-clobber door all leave with the front door.

**The owner re-stamp moves to SYNC SETUP.** A deleted-then-recreated account today cannot sync its old
library: every row carries the OLD owner id, and the push RPC refuses "owner_id mismatch" (`09_phase14c
_multitenant.sql`). The design hid the fix inside Replace Keys. It belongs in the first-device setup:
"turning on sync for a library that once synced under another account moves it to this account" — re-stamp
+ full enqueue, authorized by the new account's own ceremony (passphrase + words, which setup demands).

**Mode changes re-authenticate in BOTH directions** (her addition): Castle → Standard needs the passphrase or
Touch ID exactly as the doors in P4 do.

**The memo-era four-row table (her screenshot), corrected:** row 1 — "set a new passphrase" is confirmed by
Touch ID, else the twelve words (never the account password), in both postures; row 2 unchanged; row 3
unchanged; row 4 — "start over" is account deletion (or setup under a fresh account adopting a fresh
library), never Replace Keys. The full corrected table is in the reply and will be the design's §5.

**What the second pass supersedes in §3 above:** P2 (extended to the envelope; the per-store iCloud
library-key item is NOT built), P3 (the door itself retreats to Advanced or nothing; its narrowing rules
apply to whatever remains), P6(c) and P7 (dissolved — no store re-key at the switch), P9.3 (moot without
an account-password arm). Everything else stands. The design file is rewritten after her rulings on this
pass, not before.
