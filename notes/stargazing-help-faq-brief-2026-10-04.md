# Help-guide / website FAQ brief for the stargazing.tech agent — the 2026-10-04 edition (RE-ISSUES pre-13x's)

**Dated 2026-10-04, authored at the author's direct ask (launch-content round).** SELF-CONTAINED: it supersedes
`notes/stargazing-help-faq-brief-pre13x.md` (2026-09-06) and the site agent needs no earlier brief. The FAQ
entries below are the app's ruled copy VERBATIM (`notes/plans/pre-13x-copy.md` §8 — the copy file is the one
source of the app's words; 13s re-voices later); what this edition changes is STATUS and FACTS, never the ruled
sentences. **Carried by the author to the site agent** — the Variorum repo's agents never work in the stargazing
repo. The companion policy brief is `notes/stargazing-privacy-policy-brief-2026-10-04.md`: the policy states
boundaries, the FAQ explains mechanisms; where they overlap, they agree by construction (same date, same facts).
The seeded book *Encryption Explained* is the long form the FAQ mirrors; the tutorial chapter is the short one.

## What changed since the pre-13x FAQ brief

- **UPDATED 2026-10-08 — 13x is BUILT, MERGED and VERIFIED on real devices** (the author's own library moved
  Mac → Mac by AirDrop and opened whole). The three entries marked **✔ 13x** below are final in their FACTS and
  ready to stage. **Publish them with the first PUBLIC release that carries 13x** — the public download today is
  0.9.2 (build 5178), which does NOT have these doors; until that release is out, `RESTORE.md` stays the road the
  FAQ may name. The author gives the publish word with that release. (Superseded wording, kept for the record:
  "13x is IMMINENT, not shipped… published only on the author's explicit word that 13x shipped.")
- **What 13x adds that the drafted entries did not know:** a third door, **File ▸ Send Library to Another
  Mac…** (also in Settings ▸ Data Safety), which writes a folder holding a sealed copy of the library and its key
  file — send the whole folder; and **the restore hold** — after a copy is opened, sync waits until the user
  presses **Resume Sync** in the banner, and Resume then catches the copy up to the account.
- **The write-authorization mechanism changed (13y, 2026-09-24), with NO user-visible change to any entry:** the
  server now verifies key-holding by per-request single-use challenges over a per-account integrity secret
  (previously: a stored hash the client's value was compared against). Every user-facing sentence below stands
  as written — a signed-in session without the keys still reads and writes nothing on the sync copy. Fact
  citations in this brief say "the key proof (13y challenge protocol)" where the old brief said §3.10 alone.
- **Account-destroying acts hardened (13y):** clearing an account's synced data requires a fresh
  re-authentication at the moment of the act (delete-account already did). No entry's wording changes; the
  must-not-say list gains nothing.
- **Nothing in the 13i family (wings, shelves, books/gatherings, the daily Journal, book archive — deployed
  2026-10-01/02/03) touches these mechanisms.** Product-level FAQ content about books and organization is NOT
  this brief's scope; if the site wants it, the product page draft (`notes/brand/site/variorum-product-page.md`)
  is the content authority and a dedicated brief can follow.
- Everything else in the pre-13x brief STANDS and is restated in full below.

## The register (binding for every FAQ sentence)

Two registers, from the copy file's head. **Everyday surfaces** (settings, ceremonies, notices, the lobby) name
no key: *your library · your passphrase · your twelve words (never "recovery phrase" alone on first use — "your
twelve words, the recovery phrase") · your Apple account · an enrolled device · Standard and Castle · sync · a
key*. **The Encryption book and the FAQ** NAME the keys and define each on first use: *the library key* (the key
the library file is encrypted under) · *the master key* (one per account; the right to sync) · *the corpus key*
(the key every synced text is encrypted under before it leaves a device) · *the iCloud key* (Standard's one
Apple-held key, in iCloud Keychain) · *the key file* (the non-secret file beside the library holding wrapped
copies of the library key) · *wrapped* (a key encrypted under another key, or under your passphrase). **Never,
in any user copy:** box, vault, escrow, KDF, token, session, RLS. The four keystone lines render verbatim
wherever they appear.

## The two-sentence model the FAQ must never contradict

Both modes are end-to-end encrypted: the library is ciphertext on disk and every synced text is encrypted on the
device before it leaves; the Variorum server never holds a key to either. The only difference is WHO HOLDS A
KEY. **Standard:** your Apple account holds the iCloud key; it opens a copy of the library key in the key file
and a copy of the master key on the server; those open the file and sync. **Castle:** no copy opens with the
iCloud key; only your passphrase, your twelve words, an enrolled device's Touch ID / Face ID, or the master key
already in an enrolled device's custody reach the library key and the master key.

## The entries — the ruled copy verbatim, each with its facts

Entries marked **✔ 13x** are built and verified; stage them now and publish with the first public release that carries 13x (above).

- **I forgot my passphrase.** *Any device that opens your library can set a new one: Settings ▸ Encryption ▸
  Change Passphrase ▸ Forgot. In Castle that takes Touch ID or your twelve words. If no device opens and you
  have neither secret, Standard's Apple account still opens your library; Castle has no way back — by design.*
  — Facts: Standard's forgot road is a plain confirm (this device holds the keys); Castle's is Touch ID on a
  gated device, else the twelve words; a passphrase change is a re-wrap, a convenience act. Built and pinned.

- **Moving to a new Mac.** *Standard: sign into iCloud and Variorum; with sync on, everything arrives;
  without sync, open a copy of your library from your backup folder. Castle: sign in and type your passphrase
  or twelve words once; without sync, open a backup and type them.*
  — **✔ 13x (built):** the doors exist. On the old Mac, **File ▸ Send Library to Another Mac…** writes a folder
  (a sealed copy + its key file) to AirDrop whole; on the new Mac, **File ▸ Open Library…** (also on the welcome
  and waiting screens) opens it. The receiving Mac's current library steps aside first — kept in a dated
  "Previous Libraries" folder beside it, plus a safety copy with the backups — and the picked folder is only
  read. After it opens, **sync waits until Resume Sync is pressed**; a Mac new to that library then joins sync by
  enrolling — Standard nothing typed, Castle the passphrase once. Until the public release carries 13x, today's
  road is the `RESTORE.md` recipe in every backup folder.

- **Restoring a backup.** *A backup folder holds sealed copies and a key file. Open a copy through File ▸
  Open Library; it opens the same way your library does — through your Apple account in Standard, with your
  passphrase or twelve words in Castle. Old copies open with the passphrase you had when they were made, or
  your twelve words — and, on the Mac your library lives on, a backup of that same library also opens with your
  current passphrase. To sync it again it joins your account like any device: on its own through your Apple
  account in Standard; with your passphrase once in Castle.*
  — **✔ 13x (built):** "File ▸ Open Library" exists, and Settings ▸ Data Safety lists the backup folder's
  copies under **Restore from Backup**, each saying which credential opens it. **One fact to carry:** after
  opening a backup, sync waits until **Resume Sync** is pressed, and Resume catches the copy up to the account —
  notes deleted since leave again and edits made since come back; to keep something from the backup, duplicate it
  first (duplicates stay). It does NOT roll the whole account back to the backup's day. Facts otherwise, all true
  of the build: every snapshot has ITS OWN key file beside it, written with it and never
  rewritten; a backup opens by whatever its key file's copies open under (the passphrase of its day, the twelve
  words, an enrolled device's master-wrapped copy — and, if made in Standard, the iCloud key); a backup carries
  no sync key and no device identity — it rejoins sync only by ENROLLING, with a fresh device identity.

- **Deleting my account and starting over.** *Deleting removes the server copy and the account's keys; your
  libraries stay on your devices and still open. Create a new account and turn on sync; the library moves to
  it and uploads. Your other devices join the new account the usual way.*
  — Facts: delete-account is account password + typed phrase + a fresh re-authentication; server copy + the
  account's wrapped keys + the login gone; LOCAL COPIES UNTOUCHED; set-up-sync ADOPTS a library that synced
  under another owner (re-stamp + a full re-upload). Built and drilled.

- **What can Apple see? What can Variorum see?** *Variorum's server: never your writing, in either mode. Apple:
  in Standard, iCloud Keychain holds a key to your library — protected by Apple's end-to-end encryption and
  reachable through Apple's account recovery; in Castle, nothing. With Touch ID on in Castle, this device's
  security chip holds a copy of the key for your fingerprint alone — Apple's servers and your Apple account
  never do.*
  — Facts: both postures E2EE; ONE Apple-held key in Standard, none in Castle; the iCloud key is one
  iCloud-synchronizable Keychain item read by the app, never by us; Touch ID gates the raw library key in the
  Secure Enclave on this device — adding a fingerprint invalidates it; the passphrase recovers.

- **Why is there no "reset"?** *Because a reset would be a key we hold. In Castle nobody holds one but you.
  In Standard your Apple account is the reset.*
  — Facts: the account password never touches keys; the two floors, stated.

- **Someone knows my account password.** *Settings ▸ Account ▸ Sign Out Everywhere, then change the password
  at stargazing.tech — signing in and changing your password happen on the website, not in the app. They
  could never read your writing with it, and after that they can't sign in either.*
  — Facts: the key proof (13y challenge protocol) — a bare session can fetch the wrapped key copies, delete the
  whole account, and nothing else; it cannot read or write the sync copy. Sign Out Everywhere revokes every
  session; keys untouched. A refresh token is revoked at once; an already-issued access token lives to its
  expiry (≤ 1 h) and is inert against the corpus — accepted, her word. The her-ruled note stands: the sentence
  names the website's road; a take-me-there BUTTON is her future-round candidate, deliberately not built.

- **My twelve words were seen.** *Settings ▸ Encryption ▸ Regenerate Twelve Words. The old ones stop
  opening the server's copy the moment the new ones are confirmed; a device where you haven't used the new
  words yet still takes the old ones until you do. If they may have been USED, tick "Also replace my keys".*
  — Facts: recovery copies replaced on the server and in this key file; other devices take the new words at
  once online and keep taking the old ones until the new are typed there (retire-by-use); the checkbox runs
  Replace All Keys. Built and pinned.

- **I switched to Castle. Are my old backups protected?** *No. A backup made while you were in Standard still
  opens through your Apple account, and always will. Delete the ones you don't want, Time Machine included.
  Backups made after the switch are under Castle's key.*
  — Facts: a Standard-era snapshot keeps its iCloud copy; snapshots after the switch come from the re-keyed
  library; the switch offers to delete the app's own pre-switch snapshots (iCloud Drive's Recently Deleted
  keeps them 30 days — said). Pinned: a Standard-era key file + the iCloud key opens NO page of the post-switch
  library.

- **Someone may hold my keys themselves.** *Settings ▸ Encryption ▸ Replace All Keys: a new master key, a new
  corpus key, the server re-encrypted, and each device gives its library a new key as it follows. Nothing is
  lost and your account stays. If your ACCOUNT itself may be in someone else's hands, delete it and set sync up
  again instead.*
  — Facts: both secrets typed; refused while a rotation is still finishing; the same follow as entering Castle.
  Built, drilled with a sibling following and a stale copy refused.

- **Someone was inside my Apple account, and I'm in Standard.** *Secure your Apple account first, with Apple's
  tools — change your Apple ID password and remove devices you don't recognize. Replace All Keys won't shut
  them out on its own in Standard: your Apple account holds a key to the new keys too. To put your writing
  beyond your Apple account's reach, enter Castle.*
  — Facts: Replace All Keys never re-mints the iCloud key; in Standard the new master is re-wrapped under the
  SAME Apple-held key (pinned). The honest limit, tested, never assumed.

- **I moved to Castle, lost my passphrase and twelve words, and have an old backup and my iCloud.** *That
  backup opens through your Apple account, because it was made in Standard — you get back everything up to that
  day. Sync will not come back from it: entering Castle replaced your sync keys, and the new ones open only
  with your passphrase or twelve words. Delete your Stargazing account and set sync up again from that copy.
  Anything written after the backup and kept only on the server is gone — that is Castle's floor.*
  — Facts: her attacker scenario, pinned in the two-user suite: the old backup opens through the iCloud key; it
  cannot enroll without the passphrase or the words; the whole account CAN be deleted; re-setup adopts the copy.

- **Someone has my old backups and my Apple account — and I've since moved to Castle.** *They can open those
  backups: what you wrote before the switch, as it was then. Nothing more. Your library and your sync have new
  keys that were never wrapped for your Apple account, and the server refuses the old ones. If they also have
  your account password they can delete your account or sign you out — loud, and every copy on your devices
  survives — so change that password and use Sign Out Everywhere.*
  — Facts: the nine pinned arms: the pair opens pre-switch writing; push/pull refused; the follow needs the
  passphrase or words; Replace All Keys refused; the vault write refused; purge/truncate refused; account
  deletion and sign-out-everywhere CAN be done — the disclosed account-password class.

- **I lost a device, or one was stolen.** *In this order: Settings ▸ Account ▸ Sign Out Everywhere, so the
  device can't sync; Settings ▸ Encryption ▸ Replace All Keys, so nothing it holds opens anything new; then
  change your account password. In Castle the writing on that device stays locked behind its Touch ID or your
  passphrase. In Standard, whoever can unlock that device can read what was on it — that is Standard's trade —
  and that device is signed into your Apple account, which holds a key, so also remove it from your Apple
  account (your Apple ID's device list, or Find My).*
  — Facts: a lost device's custody holds the OLD master, refused by the server from the rotation on; the order
  is the design's.

- **I reset my iCloud Keychain — now a new device asks for my passphrase.** *Nothing is lost and sync keeps
  running. The copy of your key your Apple account held was wrapped under the iCloud key you just replaced, so
  it no longer matches — and that copy is what lets a new Apple device join with nothing typed. On a Mac that
  already has your keys, open Settings ▸ Protection ▸ Re-link Your Apple Account: it tells you which Apple
  account will hold the key, asks for your passphrase, and writes that one copy under the key your Apple
  account holds now. No key is replaced and nothing is re-encrypted. The same door is the answer when the Mac
  that turned sync on has moved to a different Apple account — read the sentence before you confirm, because it
  names the account that will hold your key from then on.*
  — Facts: the iCloud key is READ, never re-minted; the Re-link door (17m) is Settings ▸ Protection on the
  **Mac**; it refuses before asking when this Mac's iCloud Keychain hands back no key, and it never mints one.
  **The phone had no twin at last record (QUESTIONS #139) — verify at publish; until it does, word the entry
  for the Mac**, as above.

- **My other device uses a different Apple ID.** *Sync still works — that device types your passphrase once to
  join, then opens on its own. The nothing-typed road is for devices signed into the Apple account that turned
  on sync. In Standard, that device's own library then also opens through the Apple account it is signed into.*
  — Facts: one Apple-held copy per account; the different-Apple-ID disclosure stands in *Encryption Explained*
  Chapter 2 and the waiting-state line.

- **Does Castle on my Mac make my iPhone Castle?** *Once sync is on, yes — Castle belongs to your account and
  every device follows. Before sync, each library has its own mode; your iPhone learns the account's mode when
  it joins.*
  — Facts: posture is the account's once the account's copies exist; before sync it is per library; the follow
  is pinned on both platforms.

- **Can my library live in iCloud Drive?** *Your working library stays on this Mac. iCloud Drive syncs files
  while they're being written, which can corrupt a live database — backups are complete, sealed copies, which
  is what a synced folder is good at. To have your writing on every device, use sync.*
  — Facts: backups MAY be kept in iCloud Drive (the offer at the first backup run); the LIVE library never
  lives there. **✔ 13x (built):** the backup-folder picker refuses the library's own folder with this
  sentence, and Open Library… says it when a picked copy sits in iCloud Drive.

## SEARCH — added 2026-10-08 (13o built 2026-10-07; the VX-83 follow-up confirmed it in use the same night)

The finder is BUILT and VERIFIED in use (the author's own first-use report drove VX-83's refinements;
everything below is shipped behavior, walked on the real build). **Publish with the first public release
that carries 13o + VX-83** — the public 0.9.2 (5178) has none of it. No ruled FAQ copy exists for search
yet (13s re-voices later), so these are the FACTS help/FAQ sentences may be written from, in the register
above.

- **One finder.** The Library's search field answers everything: words rank passages under their notes with
  honest counts and quiet filter chips; a `#tag` alone lists the tagged notes themselves (sortable, scoped
  to the wing), with the books the tag flows into on top; a plain word that names a tag offers it as a
  one-press chip (`tag: #name ›`) — saying it's a tag is an explicit act, never guessed.
- **when ▾** opens a calendar popover: one day, or a span pressed as first-day-then-last-day with the run
  washing in; the sentence at its foot is the confirmation, and nothing narrows until a day is pressed.
- **Takes are in every search; savepoints behind "+ commits".** Every live take of every paragraph is
  searched by default. The explicit `+ commits` filter adds everything ever saved — each hit marked
  "commit · <day>". `+ archived` adds archived material. These filters are facts about the question,
  always visible as chips while armed.
- **Click a result, land at the match:** the note opens in Write with the match selected and the find bar
  armed with the matched words; ⌘G steps onward.
- **A book's masthead 🔍** runs the same engine scoped inside that book; ⌘K carries passages under its
  title hits.
- **Search is local by construction** — the index is derived on-device and never syncs; the server could
  not build it (it stores sealed values). The FAQ may connect this to the privacy story; the policy brief's
  boundaries already agree.

## What the FAQ must NOT say (the code does not keep it)

- Any of 13x's doors (Open Library…, Send Library to Another Mac…, Restore from Backup) as AVAILABLE before the
  first public release that carries 13x is out — they are built, but the public 0.9.2 (5178) does not have them.
- A remaining-rows count for a key replacement still finishing (the app names the device and the day only).
- Per-note locks (never built — deliberately; the app-lock is the posture's gate).
- A Standard follow that picks new keys up silently: after Replace All Keys or entering Castle EVERY device
  asks the passphrase once, Standard included (her call, on record).
- That the operator can see or reset anything a key protects: a signed-in account without the keys reads and
  writes nothing on the sync copy (the key proof, 13y challenge protocol); the account password's powers are
  sign in · sign out everywhere · delete the account — and, on an account that never turned on sync, creating
  the account's key copies before the owner does, which is loud and survivable.
- Anything the companion policy brief's cautions forbid (same date; they agree): no "reset" or operator
  recovery road; never "your writing is in iCloud" for Standard; no cross-account activity inference (closed at
  13y — the per-account line replaced it).
- *(search, added 2026-10-08)* That search finds deleted text: the Trash is not searched (deliberate — a later
  feature may add search INSIDE the Trash), and whole-note Versions are never searched.
- *(search)* That savepoints/commits surface in an ordinary search: only behind the explicit "+ commits" filter.
- *(search)* The indexing technology by name (the standing never-name-FTS5 rule).
- *(search)* Any of the search doors as AVAILABLE before the first public release carrying 13o + VX-83 is out
  (the 13x gate's twin above — same release, in all likelihood).
