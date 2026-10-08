# Help-guide / website FAQ brief for the stargazing.tech agent — the pre-13x postures update

**Dated 2026-09-06, authored inside pre-13x (Postures & recovery — Standard and Castle), batch 5b, item 3.**
**Carried by the author to the site agent** — the Variorum repo's agents never work in the stargazing repo.
This is an INPUT: the entries below are `notes/plans/pre-13x-copy.md` §8 VERBATIM (the copy file is the one
source of the app's words; 13s re-voices later), each followed by the FACTS it rests on and the section of
`notes/plans/pre-13x-postures-design.md` (the settled design) that carries them. The seeded book
*Encryption Explained* (copy §7b) is the long form the FAQ mirrors; the tutorial chapter (copy §7) is the short one.

## The register (binding for every FAQ sentence)

Two registers, from the copy file's head. **Everyday surfaces** (settings, ceremonies, notices, the lobby) name no
key: *your library · your passphrase · your twelve words (never "recovery phrase" alone on first use — "your twelve
words, the recovery phrase") · your Apple account · an enrolled device · Standard and Castle · sync · a key*. **The
Encryption book and the FAQ** NAME the keys and define each on first use: *the library key* (the key the library
file is encrypted under) · *the master key* (one per account; the right to sync) · *the corpus key* (the key every
synced text is encrypted under before it leaves a device) · *the iCloud key* (Standard's one Apple-held key, in
iCloud Keychain) · *the key file* (the non-secret file beside the library holding wrapped copies of the library key)
· *wrapped* (a key encrypted under another key, or under your passphrase). **Never, in any user copy:** box, vault,
escrow, KDF, token, session, RLS. The four keystone lines (copy file head) render verbatim wherever they appear.

## The two-sentence model the FAQ must never contradict (design §2, §3.2)

Both modes are end-to-end encrypted: the library is ciphertext on disk and every synced text is encrypted on the
device before it leaves; the Variorum server never holds a key to either. The only difference is WHO HOLDS A KEY.
**Standard:** your Apple account holds the iCloud key; it opens a copy of the library key in the key file and a copy
of the master key on the server; those open the file and sync. **Castle:** no copy opens with the iCloud key; only
your passphrase, your twelve words, an enrolled device's Touch ID / Face ID, or the master key already in an enrolled
device's custody reach the library key and the master key.

## The entries — copy §8 verbatim, each with its facts

**13x CLOSEOUT (2026-10-08) — every ⚠ NOT YET BUILT mark below is now BUILT and un-flagged** (13x, VX-6,
verified by her hands on real devices: the Pro→Air AirDrop leg). The three held entries publish; each carries a
"✔ BUILT in 13x" note naming the door and the one new fact the drafts predate — **the restore hold**: after
opening a copy, sync waits until the user presses **Resume Sync** in the banner. Facts binding; 13s re-voices the
words. The record: `notes/plans/phase-13x-library-portability.md`.

Where an entry names a DOOR THE BUILD DOES NOT HAVE YET, the entry is marked **⚠ NOT YET BUILT** with the phase that
owns it — publish that entry when the door lands, or word it on the road that exists today (named beside it). The
Variorum brief's rule: a FAQ sentence that promises a door that does not exist is the class this phase closes, never a
sentence to publish.

- **I forgot my passphrase.** *Any device that opens your library can set a new one: Settings ▸ Encryption ▸
  Change Passphrase ▸ Forgot. In Castle that takes Touch ID or your twelve words. If no device opens and you
  have neither secret, Standard's Apple account still opens your library; Castle has no way back — by design.*
  — Facts: design §5 (*Change passphrase*: Standard's forgot road is a plain confirm — this device holds the keys;
  Castle's is Touch ID on a gated device, else the twelve words); §1.21 the two floors; §1.10 (a passphrase change
  is a re-wrap, a convenience act). Built at 3b (the key doors) and pinned.

- **Moving to a new Mac.** *Standard: sign into iCloud and Variorum; with sync on, everything arrives;
  without sync, open a copy of your library from your backup folder. Castle: sign in and type your passphrase
  or twelve words once; without sync, open a backup and type them.*
  — Facts: design §2 (*a new device*), §3.8 (Standard's open road: the key file's iCloud copy through the iCloud
  key; for a sync user the iCloud key → the master key → the key file's master-wrapped copy of the library key),
  §5 (*Enroll*), §6 (a restored snapshot enrolls like any library — Standard nothing typed, Castle the passphrase
  or the words once). **✔ BUILT in 13x (was ⚠ NOT YET BUILT):** the in-app doors exist — on the old Mac,
  **File ▸ Send Library to Another Mac…** (also in Settings ▸ Data Safety) writes a folder holding a sealed copy of
  the library and its key file, to AirDrop whole; on the new Mac, **File ▸ Open Library…** (also on the welcome and
  waiting faces) opens it. The current library on the receiving Mac steps aside first, kept in a dated "Previous
  Libraries" folder beside it plus a safety copy with the backups; the picked folder is only read. After it opens,
  **sync waits until Resume Sync is pressed** in the banner; a Mac new to that library then joins sync by
  enrolling (Castle: the passphrase once at the enrollment). The `RESTORE.md` recipe remains as the
  no-app fallback.

- **Restoring a backup.** *A backup folder holds sealed copies and a key file. Open a copy through File ▸
  Open Library; it opens the same way your library does — through your Apple account in Standard, with your
  passphrase or twelve words in Castle. Old copies open with the passphrase you had when they were made, or
  your twelve words — and, on the Mac your library lives on, a backup of that same library also opens with your
  current passphrase. To sync it again it joins your account like any device: on its own through your Apple account
  in Standard; with your passphrase once in Castle.*
  — Facts: design §6 (every snapshot has ITS OWN key file beside it, written with it and never rewritten —
  `variorum-backup-<stamp>-<fp8>.sqlite` + `.keys.json`; a backup opens by whatever its key file's copies open
  under: the passphrase of its day, the twelve words, the master-wrapped copy of the library key — an enrolled
  device's master, or the current passphrase online through the account's copies — and, if made in Standard, the
  iCloud key; on the Mac the library lives on, custody and the live key file pair with every snapshot of the same
  library key), §1.11 (backups are never rewritten after they are written), §3.3 (a backup carries no sync key and
  no device identity — it rejoins sync only by ENROLLING, with a fresh device identity). **✔ BUILT in 13x (was
  ⚠ NOT YET BUILT):** "File ▸ Open Library" exists, and Settings ▸ Data Safety lists the backup folder's copies
  under **Restore from Backup**, each row saying which credential opens it. ONE fact to add to the entry: **after
  opening a backup, sync waits until Resume Sync is pressed, and Resume catches the copy up to the account** —
  notes deleted since leave again and edits made since come back; to keep something from the backup, duplicate it
  first (duplicates stay). Rolling the whole account back to a backup's day is NOT what this does (that road is
  delete-and-set-up-again). Everything else in the entry is true of the build.

- **Deleting my account and starting over.** *Deleting removes the server copy and the account's keys; your
  libraries stay on your devices and still open. Create a new account and turn on sync; the library moves to
  it and uploads. Your other devices join the new account the usual way.*
  — Facts: design §5 (*Delete account*: account password + typed phrase + a fresh re-authentication; server copy +
  the account's wrapped keys + the login gone; LOCAL COPIES UNTOUCHED; *Set up sync* ADOPTS a library that synced
  under another owner — re-stamp + a full re-upload, decision 17), §7 (*a deleted-then-recreated account*).
  Built at 3a/3b, drilled on the dev store against the fake server (decision 26).

- **What can Apple see? What can Variorum see?** *Variorum's server: never your writing, in either mode. Apple:
  in Standard, iCloud Keychain holds a key to your library — protected by Apple's end-to-end encryption and
  reachable through Apple's account recovery; in Castle, nothing. With Touch ID on in Castle, this device's security
  chip holds a copy of the key for your fingerprint alone — Apple's servers and your Apple account never do.*
  — Facts: design §1.2–§1.3 (both postures E2EE; ONE Apple-held key in Standard, none in Castle), §3.1 (the iCloud
  key is ONE iCloud-synchronizable Keychain item read by the app, never by us), §3.2 (Touch ID: the Secure Enclave
  gates the raw library key on this device; adding a fingerprint invalidates it — the passphrase recovers), §8's
  where-the-key-sits line (rendered on every Castle surface that offers Touch ID — 5a, ledger 20).

- **Why is there no "reset"?** *Because a reset would be a key we hold. In Castle nobody holds one but you.
  In Standard your Apple account is the reset.*
  — Facts: design §1.4 (the account password never touches keys), §1.21 (the floors), §2's keystone 3.

- **Someone knows my account password.** *Settings ▸ Account ▸ Sign Out Everywhere, then change the password
  at stargazing.tech — signing in and changing your password happen on the website, not in the app. They
  could never read your writing with it, and after that they can't sign in either.*
  — **RUN A batch A2, row 10 — her ruling on QUESTIONS #90 (7), MINOR-6, 2026-09-07:** *"right now you go
  through the website to sign in, so i think it's good to direct users to the website but maybe i should add
  a button that brings them to the right place on the website. i'll consider it for a future round."* The
  sentence names the website's road; the BUTTON is her future-round candidate, deliberately not built here.
  — Facts: design §3.10 (the key proof: a bare session can fetch the wrapped copies, delete the whole account, and
  nothing else — it cannot read or write the sync copy), §5 (*Sign out everywhere*: every session revoked; keys
  untouched), §14.38 (a refresh token is revoked at once; an access token already issued lives to its expiry, ≤ 1 h,
  and is inert against the corpus — accepted as it stands, her word). Built at 3b (`signOut(scope: .global)`).

- **My twelve words were seen.** *Settings ▸ Encryption ▸ Regenerate Twelve Words. The old ones stop
  opening the server's copy the moment the new ones are confirmed; a device where you haven't used the new words yet
  still takes the old ones until you do. If they may have been USED, tick "Also replace my keys".*
  — Facts: design §5 (*Regenerate twelve words*: the recovery copies replaced on the server and in this key file;
  other devices take the new words at once online through the account's copy and keep taking the old ones until the
  new are typed there — the retire-by-use rule of §3.6), §1.10 (the checkbox runs Replace All Keys — the security
  act), §8's compromise rule. Built at 3b/4a and pinned (the sibling's retire-by-use).

- **I switched to Castle. Are my old backups protected?** *No. A backup made while you were in Standard still opens
  through your Apple account, and always will. Delete the ones you don't want, Time Machine included. Backups made
  after the switch are under Castle's key.*
  — Facts: design §6 (a Standard-era snapshot keeps its iCloud copy; snapshots after the switch come from the
  re-keyed library under the new key), §4 step 7 (the offer to delete the app's own pre-switch snapshots; iCloud
  Drive's Recently Deleted keeps them 30 days — said), §14.4–§14.5 (the iCloud key is never deleted; it opens nothing
  but pre-switch copies). Pinned at 2b/4b (a Standard-era key file + the iCloud key opens NO page of the post-switch
  library).

- **Someone may hold my keys themselves.** *Settings ▸ Encryption ▸ Replace All Keys: a new master key, a new corpus
  key, the server re-encrypted, and each device gives its library a new key as it follows. Nothing is lost and your
  account stays. If your ACCOUNT itself may be in someone else's hands, delete it and set sync up again instead.*
  — Facts: design §1.10 (the three acts), §3.4's act table (Replace All Keys = the key half of entering Castle;
  delete-and-set-up-again = everything it does plus the account, the server copy and the login), §5 (*Replace All
  Keys*: both secrets typed — decision 33; refused while a rotation is still finishing — decision 32), §7 (the same
  follow as entering Castle). Built at 3b, drilled with a sibling following and a stale copy refused.

- **Someone was inside my Apple account, and I'm in Standard.** *Secure your Apple account first, with Apple's tools —
  change your Apple ID password and remove devices you don't recognize. Replace All Keys won't shut them out on its own
  in Standard: your Apple account holds a key to the new keys too. To put your writing beyond your Apple account's
  reach, enter Castle.*
  — Facts: **decision 30** (Replace All Keys never re-mints the iCloud key; in Standard the new master is re-wrapped
  under the SAME Apple-held key — the presence of that copy after a Standard Replace All Keys is PINNED, ledger 37),
  §8's compromise rule (fourth line), §14.35. The honest limit, tested, never assumed.

- **I moved to Castle, lost my passphrase and twelve words, and have an old backup and my iCloud.** *That backup
  opens through your Apple account, because it was made in Standard — you get back everything up to that day.
  Sync will not come back from it: entering Castle replaced your sync keys, and the new ones open only with your
  passphrase or twelve words. Delete your Stargazing account and set sync up again from that copy. Anything written
  after the backup and kept only on the server is gone — that is Castle's floor.*
  — Facts: design §14.7, §14.29 (her attacker scenario, the two-user suite: the old backup opens through the iCloud
  key; it cannot enroll without the passphrase or the words; the whole account CAN be deleted; re-setup adopts the
  copy), §1.21. Pinned at 4b (`MultiTenantSyncAttackerTests`).

- **Someone has my old backups and my Apple account — and I've since moved to Castle.** *They can open those
  backups: what you wrote before the switch, as it was then. Nothing more. Your library and your sync have new keys
  that were never wrapped for your Apple account, and the server refuses the old ones. If they also have your
  account password they can delete your account or sign you out — loud, and every copy on your devices survives —
  so change that password and use Sign Out Everywhere.*
  — Facts: design §14.29 (the nine arms, each pinned at 4b: the pair opens pre-switch writing; push/pull refused;
  the follow needs the passphrase or words; Replace All Keys refused; the vault write refused; purge/truncate
  refused; account deletion and sign-out-everywhere CAN be done — the disclosed account-password class), §3.4.

- **I lost a device, or one was stolen.** *In this order: Settings ▸ Account ▸ Sign Out Everywhere, so the device can't
  sync; Settings ▸ Encryption ▸ Replace All Keys, so nothing it holds opens anything new; then change your account
  password. In Castle the writing on that device stays locked behind its Touch ID or your passphrase. In Standard,
  whoever can unlock that device can read what was on it — that is Standard's trade — and that device is signed into
  your Apple account, which holds a key, so also remove it from your Apple account (your Apple ID's device list, or
  Find My).*
  — Facts: design §8's compromise rule (a leaked session → sign out everywhere; someone who may HOLD your keys → Replace
  All Keys), §3.4's act table (Replace All Keys: the master, the corpus key, and — device by device as each follows —
  every library key; a lost device's custody holds the OLD master, refused by the server from the rotation on), §2
  (Standard: someone at your unlocked Mac — no; Castle: your Mac's login password — yes), §1.3 (Standard's one
  Apple-held key). The lost-device entry ledger 32 asked for; the order is the design's.

- **I reset my iCloud Keychain — now a new device asks for my passphrase.** *(added 2026-09-21 at RUN A batch A3,
  with the door 17m built; the sentence is the app's own Settings copy in the FAQ's register)* *Nothing is lost and
  sync keeps running. The copy of your key your Apple account held was wrapped under the iCloud key you just
  replaced, so it no longer matches — and that copy is what lets a new Apple device join with nothing typed. On a Mac
  that already has your keys, open Settings ▸ Protection ▸ Re-link Your Apple Account: it tells you which Apple
  account will hold the key, asks for your passphrase, and writes that one copy under the key your Apple account
  holds now. No key is replaced and nothing is re-encrypted. The same door is the answer when the Mac that turned
  sync on has moved to a different Apple account — read the sentence before you confirm, because it names the
  account that will hold your key from then on.*
  — Facts: design §3.4 (Standard's iCloud key row: it is READ, never re-minted — decision 30), the ladder's
  **MINOR-N1** (the heal keys on a key READ and never on a mint, which is precisely why a reset leaves the account's
  Apple-held copy orphaned), **QUESTIONS #90 item 10** (her ruling: a deliberate door with a consent sentence, not an
  automatic re-land), and **17m**, built at RUN A batch A3 — Settings ▸ Protection on the **Mac**; it refuses before
  asking when this Mac's iCloud Keychain hands back no key at all, and it never mints one. **The phone has no twin
  yet** (QUESTIONS #139) — word the entry for the Mac until it does.

- **My other device uses a different Apple ID.** *Sync still works — that device types your passphrase once to join,
  then opens on its own. The nothing-typed road is for devices signed into the Apple account that turned on sync. In
  Standard, that device's own library then also opens through the Apple account it is signed into.*
  — Facts: design §1.3 (one Apple-held copy per account), §14.34, ledger 48 (the different-Apple-ID disclosure — the
  last sentence, added 2026-09-06; the same sentence stands in *Encryption Explained*'s Chapter 2 and copy §2d's
  waiting-state line, rendered at 5a).

- **Does Castle on my Mac make my iPhone Castle?** *Once sync is on, yes — Castle belongs to your account and every
  device follows. Before sync, each library has its own mode; your iPhone learns the account's mode when it joins.*
  — Facts: design §1.8 (posture is the account's once the account's copies exist), §14.26 (posture before sync is
  per library), §7 (the follow on both platforms — pinned at 2c/4b), §9.

- **Can my library live in iCloud Drive?** *(drafted 2026-09-06 at 5b into copy §8 — the entry copy §6's why-not
  sentence names as the FAQ's half; the sentence itself verbatim from §6)* *Your working library stays on this Mac.
  iCloud Drive syncs files while they're being written, which can corrupt a live database — backups are complete,
  sealed copies, which is what a synced folder is good at. To have your writing on every device, use sync.*
  — Facts: decision 24 (backups MAY be kept in iCloud Drive — the offer at the first backup run, built at 5b; the
  LIVE library never lives there), decision 29 / ledger 4 (the folder picker's refusal of the library's own folder
  is 13x's guard — **✔ BUILT in 13x (was ⚠ NOT YET BUILT)**: the backup-folder picker refuses the library's own
  folder with copy §6's sentence, and Open Library… says the same sentence when the picked copy sits in iCloud
  Drive; the entry publishes as written).

## What the FAQ must NOT say (the code does not keep it)

- Any in-app "open a library file" / "File ▸ Open Library" door (13x's — flagged on three entries above).
- A remaining-rows count for a key replacement still finishing (ledger 65: the app names the device and the day
  only).
- Per-note locks (never built — R13p-16; the app-lock is the posture's gate).
- A Standard follow that picks new keys up silently: after Replace All Keys or entering Castle EVERY device asks
  the passphrase once, Standard included (§5, her call — the retired copy addendum, ledger 66).
- That the operator can see or reset anything a key protects (§3.10: a signed-in account without the keys reads and
  writes nothing on the sync copy; the account password's powers are sign in · sign out everywhere · delete the
  account — and, on an account that never turned on sync, creating the account's key copies before the owner does,
  which is loud and survivable).
