# pre-13x — DESIGN HISTORY: how the Standard/Castle design was settled (2026-08-31 → 2026-09-04)

**What this file is.** The reasoning, the earlier shapes, the supersessions and the session records behind
`notes/plans/pre-13x-postures-design.md`. The design file is written CLEAN, in the present tense, for the sessions
that build it; it carries no dates and no "was" — when a builder wonders WHY a mechanism has the shape it has, the
answer is here, in the order it was found. Nothing in this file binds the build except where the design file says
the same thing; where the two disagree, the design file wins (it was written last, 2026-09-04 night, from the
rulings recorded below).

**The arc, in five sittings:**
1. **2026-08-31 → 09-01 — the encryption-clarity thread** (the author + the Fable architect). The 13p/14b dial
   matrix ("users are NOT going to understand this") became TWO POSTURES: Standard and Castle. Fifteen rulings
   (§1 below, the 09-01 fifteen). Traps found the same night: the same-machine Castle bypass through the
   absent-store route; the copy promising doors the code lacked; every other device's key file staying wrapped
   under a retired passphrase. The first design text (commit `e4609e4`) re-keyed the store at the Castle switch
   and ran Replace Keys (a master rotation) there; the sync keys were to be mirrored raw to iCloud Keychain in
   Standard. §18 below is that session's record, verbatim.
2. **2026-09-01 → 09-03 — the architect's review and the rewrite.** `notes/plans/pre-13x-design-review.md` (P1–P9)
   found the shared-access-group gap, the lobby lockout after a re-key, the backup-envelope overwrite, and
   proposed the KEK model: ONE Apple-held key with every Apple leg a WRAP under it. Its second pass (§8 there)
   dissolved the store re-key and Replace Keys at the switch — reasoning about the vault's wrapped copies alone.
   The 09-03 kickoff sitting ruled 16–28 (the bridge retired; the account password out of every key door; posture
   is the account's; no rotate door in v1; re-auth on posture changes …); the file was rewritten (`bfc967b`); the
   architect's review §19 signed off conditionally on the key-proof token. Batch 0 (measurements) and batch 0b
   (the Fragments bridge retirement) ran and closed 2026-09-04.
3. **2026-09-04 afternoon — the library-key sitting.** Her question: does "throwing away the Apple boxes" keep a
   switcher safe? Answer: not for a Time Machine copy of the Standard-era key file, because the library key never
   changed. Ruled: the library RE-KEYS when a library enters Castle; NO backup folder is ever written by a posture
   change (later the same afternoon: by anything — ruling 12 dropped); the copy makes iCloud vs device-only explicit;
   the compromise rule is general; no real-store delete-and-set-up-again drill; the export → reimport road is
   portability, not rotation; the 13y pin; the "delete backups made before today" offer.
4. **2026-09-04 evening — the master in every backup.** Her scenario ("the old copy opens through iCloud, you sign
   in, but sync doesn't come back — right?") was NOT true of the design: since the sync keys now live inside the
   library, every Standard-era snapshot carried the LIVE master and corpus key behind a key the iCloud key opens.
   Two facts reviewed apart ("backups carry M" — §19.5; "the switch removes the Apple wraps") and never put side
   by side. Ruled: the master rotates at the switch; the corpus key rotates with it and every row is re-encrypted
   in place; the POSTURE LAW and the CREDENTIAL AUDIT tables became standing artifacts; the standalone new-key door
   was retired; the book is "Encryption Explained"; the three-act bundle.
5. **2026-09-04 night — the doors.** Replace All Keys ruled (four entrances); the follow into Castle written step
   by step; same-owner rotation (follow) told from different-owner (adopt); her attacker scenario walked and it
   found that `sync_purge_execute` authorized by session + a READABLE key id — the proof now gates it; the two
   switches tabulated credential by credential; her framing of Change Passphrase adopted. Then this cleanup: the
   design file rewritten clean; everything dated moved here.

**Commits of the 09-04 sittings:** `5403ae4b` (afternoon rulings) · `b88a039d` (ruling 12 dropped, the offer, the
export road retired as rotation) · `2baee4b3` (the master finding; the Encryption book) · `e245cb6f` (the master
rotation ruled; the posture law; the audit tables; how it was missed) · `58259feb` (the corpus rotation ruled; the
bundle) · `5d46d790` (the switch table; the purge hole; the attacker scenario) · `eeaf62f7` (Replace All Keys ruled;
the follow; follow vs adopt) · then the cleanup commit that created this file.

**Companion records:** `notes/plans/pre-13x-design-review.md` (the 09-01 → 09-03 review, P1–P9 and its second
pass); `notes/plans/pre-13x-spike-memo.md` (batch 0's measured facts); `notes/plans/pre-13x-bridge-retirement.md`
(batch 0b); `notes/plans/pre-13u-memo-security-shapes.md` (superseded); `notes/plans/phase-13p-note-protection.md`
and `notes/plans/phase-14b-suite-e2ee.md` (what this phase simplifies and extends); the 09-01 design text at
`e4609e4`, the 09-03 rewrite at `bfc967b`, and the last dated form of the design file at the commit before the
cleanup (`git show <cleanup>^:notes/plans/pre-13x-postures-design.md`).

---

# PART I — THE DESIGN FILE'S DATED SECTIONS, VERBATIM (as they stood at the cleanup)

## I.1 The file's status header and provenance paragraph
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
2026-09-02). **AMENDED 2026-09-04 (afternoon — the library-key sitting): §16's RULED 2026-09-04 (afternoon) block
re-instates the LIBRARY RE-KEY at the Castle switch and at Castle enrollment, ends every backup-folder touch, and
re-words the Castle ceremony; the in-place supersessions below carry the date.**


## I.2 §1 HER RULINGS — the 2026-09-01 fifteen with their 09-03 supersessions, then the 09-03 set (verbatim)


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
    regeneration and posture changes. **SUPERSEDED 09-04 (afternoon, later):** the app NEVER rewrites a backup folder's key file after it is written —
    not at a posture change, not at a passphrase change, not at a words regeneration. Her words: *"I do not think the
    app should refresh its own backup folders' key files on a passphrase change - it's confusing."* The LIVE library's
    own key file (not a backup) stays current as always, and it pairs with every snapshot of the same library key (§6).
13. **Castle keeps the idle-minutes re-lock dial** (reads SYSTEM idle — tabbing out never locks).
14. **The absent-store route is re-ruled**: never a silent reset.
15. ~~17i is pulled into this phase.~~ Withdrawn 2026-09-02 (R-cor-13): 17i runs after, on the settled path.

**From the 2026-09-03 kickoff sitting (verbatim-faithful where quoted):**
16. **The Fragments bridge is RETIRED** — *"it's just on there due to history… if I had a feature list for
    each app's v1, the bridge wouldn't be on there."* Preserved on a branch; removed from `main` as its own
    batch (0b) with its own cold review, BEFORE any key work. No postures per app, no suite-level posture *(DONE 2026-09-04 — tag `archive/fragments-bridge-2026-09-04`; the record `notes/plans/pre-13x-bridge-retirement.md`.)*
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


## I.3 §16 OPEN RULINGS — every dated block (09-03 evening · 09-03 late evening · 09-04 · 09-04 afternoon (a)–(l) · 09-04 evening (m)/(m-corpus)/(p)/(n)/(o) · 09-04 night (q)/(t)/(r)/(s)) (verbatim)


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

**RULED 2026-09-04 (afternoon — the library-key sitting; her words verbatim-faithful):**
- **(a) THE LIBRARY RE-KEYS when a library enters Castle** — at the Standard → Castle switch on every device as it
  follows, and at the enrollment of a Standard-born library into a Castle account. *"given how users are started
  on standard, it seems like a bizarre gap to not rotate the library key"*; *"library re-key finally closes the last
  obvious gap (time machine on a standard machine has a CHANCE of catching the key unbeknownst to a user)."* Shape:
  review P7's export-and-swap (the 13p migration road), the persisted marker, the vault's Apple box removed last;
  the master is NOT rotated here (ruling 20's road stands). Batch 0 measured no export time; batch 2 measures it on
  a byte-copy of her store (*"batch 0 has already been run, but I think it's fine"*).
- **(b) NO key change and NO box change in any backup file or folder, ever, at a posture change** — *"changing the
  backup file is still fundamentally offering something confusing and the sort of half gate that the app's whole
  posture is built around NOT offering."* Retained snapshots keep their key files: *"retained snapshots being opened
  with the old key + passphrase and word boxes is fine"*; *"trying to extend key swapping and changing to backups was
  a sign that our previous design was flawed… a backup could be anywhere and the user might not even know about it."*
  The ceremony says it as a limit AND a way back: *"we shouldn't pretend backups made during the standard era are
  safe — we should just say 'delete all your backups if you want castle protection, including time machine'"*; and a
  Castle user who forgets everything may go back to a Standard-era backup through the Apple account (her framing).
- **(c) The copy makes iCloud vs device-only EXPLICIT** — *"it's essential that it becomes clear what is iCloud and
  what is device only / doesn't unlock with the computer's password, so users who use Castle realize there is still
  an 'Apple key' (unless they turn touchid off)."* The Touch ID copy is held by this device's security chip, released
  only to the fingerprint, never to the login password, never to iCloud; Always ask keeps no copy. (`pre-13x-copy.md`
  updated 09-04.)
- **(d) The compromise rule is general** — *"any user that suspects that their master key has been compromised has
  to set up sync again, not just those with a compromised iCloud."* The three-line rule (§8; §14.28).
- **(e) The separate "require Touch ID to sync" gate is GONE** (confirmed — ruling 2 / §13: the sync keys live inside
  the library, so unlocking the library IS unlocking sync; nothing is left to gate). **Pause sync / auto-sync off
  stays 18a's**; whether it is v1 is her slotting word for 18a (*"not sure if it needs to be in v1"*).
- **(f) No delete-and-set-up-again drill on her real store in this phase** — *"I'm not willing to destroy all the
  takes I have just to test this out"* (recorded with the fact, §14.30: the road destroys nothing local; her word
  stands regardless). The dev store may run it (the tutorial re-seeded after); the fake-server pins carry it.
- **(g) The plaintext-export → new-library road is THOUGHT THROUGH here even though the door is 13x's** — *"we do
  need to give users the sqlite unencrypted text to import from, so they don't lose all their takes"*: the export
  is a full copy of every synced table (takes, savepoints, edges, comments — nothing lost) minus the local sync
  tables; it KEEPS the synced tables' `sync_version` and `owner_id` columns so 13x's open door can reconcile: same
  account → enroll, pull from cursor 0, empty outbox (zero pushes, convergence by the ≤-version rule); new or no
  account → the adopt road (re-stamp + `resyncReinitialize`). Written as batch 3's design note; handed to 13x's row.
  **Corrected the same afternoon:** this is a PORTABILITY corner, not a rotation road — the master needs no export
  (§14.30) and the library key rotates in place ((a), (l)); *"I'm honestly confused at where the export -> reimport
  idea is even still holding weight"* — it holds weight only as the open-format escape and as a file 13x's door must
  be able to open.
- **(h) Posture before sync** — §14.26/27: an account alone makes nothing Castle; the vault does.
- **(i) 13y is told** — pre-13x's closeout writes ONE pin onto 13y's row: the adopt road converges under per-tenant
  `server_seq` (a cursor reset to 0 under a NEW owner reads that owner's sequence from its start; the two-user
  suite gains a delete → recreate → adopt scenario). The master plan's 13y row carries the note as of 09-04.
- **(j) Ruling 12 DROPPED** — *"I do not think the app should refresh its own backup folders' key files on a
  passphrase change - it's confusing."* One rule: the app never rewrites a backup folder's key file after writing it
  (§6 — the live key file + same-fingerprint pairing keeps the current passphrase useful on the same Mac).
- **(k) The "Delete backups made before today" button is IN** — offered once at the end of the Castle ceremony, for
  the app's OWN folders, with the note that *"any outside backups, copies, time machine, etc. aren't covered"*
  (copy 2b's offer).
- **(l) ~~A "Give this library a new key" door~~ — RETIRED 09-04 evening at her question (*"what's the point of a new
  library key door at this point?"*): a library-key rotation alone protects nothing that matters (§3.1c's closing
  paragraph); it lives on only INSIDE Replace All Keys (q) and the switch. The item as it stood that afternoon:** *"shouldn't we just expose
  a 'change library key' door rather than asking users to do that?"* Recommendation: YES, batch 3 — one more caller
  of the switch's mechanism (export-and-swap, identity preserved, the marker), Castle authorizes by Touch ID or the
  passphrase, Standard by a plain confirm, the same sentence about old backups; the export-reimport workaround
  retires with it (§13).
- **(m) ROTATE THE MASTER AT THE STANDARD → CASTLE SWITCH — RULED 09-04 evening, her words:** *"I honestly don't
  see how we could ever NOT offer master rotation at the switch and have moving to castle mean anything??"* and
  *"that's not just a sewage hole for orcs to blow up that's like a fully open wall that has already been exploded."*
  **(m-corpus) ROTATE THE CORPUS KEY WITH IT AND RE-ENCRYPT EVERY ROW — RULED 09-04 evening** (*"it seems to me like
  basically every key has to be rotated when you go from Standard -> Castle for it to mean anything… seems kinda
  niche but also requires a disclaimer on Castle that doesn't really fit the overall posture of castle, so let's just
  close that hole"*; her question why the recommendation changed is answered in (q)) (the breach
  road: an old snapshot holds the raw corpus key; the server holds every row under it; a breach + the snapshot reads
  post-switch writing with no sign-in and no proof; only a new corpus key makes post-switch writing safe against
  that compound — the shape is in §4's row: pull to head, re-push every row in place under C′, the `active_key_id`
  fence, the marker, online required). *(The earlier text of this item follows as written that afternoon.)* Her
  question (*"what stops them from getting the new master key is that it's been re-wrapped in the new passphrase…
  they can only delete their account. is that all accurate?"*) is accurate ONLY with this step. As written, the
  switch left the master unchanged, and since pre-13x moves the sync keys INSIDE the library (§3.2), every
  Standard-era snapshot carries the live master in the clear behind the library key — which the iCloud key opens.
  Restore one, sign in, and it syncs the whole current corpus and can even change the account passphrase (§14.31).
  Rotating the LIBRARY key (a) does not touch this. The step: the acting device mints M′, re-wraps the corpus key
  under M′, rewrites the vault's wraps under P and W only, replaces the key-proof hash (one `key_vault_update`
  authorized by the old proof), and puts M′ in its library; every other device's follow into Castle types P or W
  once (M′ is under nothing else) and syncs only after; a Standard-era snapshot's old master is refused by the
  server forever. COST: the one non-silent follow; a vault write; zero re-upload (the corpus key is unchanged — a
  server breach + an old snapshot would still read ciphertext with the old corpus key: the residual the
  delete-pre-switch-backups button, the Time Machine sentence and ruling 20's road cover; rotating the corpus key
  too = a full re-upload, offered as her option, not recommended for the switch). `key_vault_update` must be able
  to REPLACE the hash under the current proof (batch 1b.2, noted). Castle → Standard rotates nothing. Enrollment of
  a never-enrolled library rotates nothing.
- **(p) HOW THIS WAS MISSED (the honest account, for §19 and the next reviewer):** the 09-01 design re-keyed the
  store AND ran Replace Keys at the switch. The 09-03 sitting adopted "one Apple-held key, every Apple leg a wrap"
  and the review concluded the switch was "remove the Apple wraps, nothing else" — reasoning about the VAULT's
  wrapped copies of the master alone. The same revision moved the sync keys INSIDE the library (§3.2), which turned
  every backup into a frozen enrolled device holding the raw master and corpus key. §19.5 noted "backups now carry
  M" and classed it "no new exposure" because a backup opens with the library's own secrets — but in Standard the
  library's own secret IS the iCloud key, the credential the switch retires. Two facts, each reviewed, never put
  side by side. The correction is structural, not a patch: the POSTURE LAW (§2) and the credential audit (§3.1c),
  which every posture change is walked against from now on — and the ladder's reviewers are told to walk it.
- **(n) THE ENCRYPTION BOOK + a SHORT tutorial chapter (her direction):** *"making encryption a separate book and
  only giving it a short chapter in the tutorial… the encryption book can be longer and explain exactly how it
  works… a FULL explanation written in an accessible (but still technically accurate) way. I do consider 'wrapped'
  to be accessible."* Recorded in §8; the text is copy §7 (chapter) + §7b (book). **The plain-credential legend is
  the standard for ALL user communication** (*"should honestly be the standard for communication with the user as
  well, with a brief explanation of technical terms if needed"*): the copy file's vocabulary rule now has two
  registers — everyday surfaces stay short; the book and the FAQ name the keys and define each term on first use;
  "box" appears in no user text.
- **(o) The "new library key" door has no downside beyond the switch's, and NOTHING happens on other devices**
  (her question): the library key is per FILE, so the Mac's re-key changes the Mac's file and its key file only;
  the passphrase, the words, the master and sync are untouched; the phone experiences nothing; old backups of
  that library keep the old key and open with the passphrase of their day, the words, or (Standard-era) the iCloud
  key — the live key file no longer pairs with them. The costs: the rewrite takes as long as the library is large
  (the app is closed to writing meanwhile), and the door's benefit is narrow (a copy of your key file got out) — so
  it lives under Advanced with its one sentence. Contrast (m): rotating the MASTER is the act other devices feel.
- **(q) THE BUNDLE — three acts for users, and ONE heavy door: "Replace All Keys" — RULED 09-04 night (*"I do
  agree with the replace all keys door"*; it re-opens ruling 20 in a shape the 09-03 objections no longer touch).
  Its entrances: its own door under Settings ▸ Encryption; the checkbox *"Also replace my keys"* on Change Passphrase
  and on Regenerate Twelve Words (the leaked-secret entrance, so nobody has to know a second door exists); the
  mirror checkbox *"Also choose a new passphrase"* on the door itself; and the Standard → Castle switch, which runs it
  unasked. ONE mechanism, four entrances. Authorization in Castle: Touch ID or the passphrase (or the words) — a
  re-auth on top of whatever opened the lobby, so the open-app attacker meets it; in Standard: the passphrase if set,
  else a plain confirm.** Her questions: *"Should changing your 12
  words also change the master key? do we have anything for if those were exposed?… should we bundle some of these
  key changes? what makes sense to even have separately?"* The answer (§3.1c's closing table): Change Passphrase and
  Regenerate Words stay RE-WRAPS (cheap, everyday; the old word dies for anyone who never used it) with one honest
  sentence; Replace All Keys is the switch's key half without the posture change — new master, new corpus key, every
  row re-encrypted in place, every device's library re-keyed as it follows, the passphrase typed once per device;
  reachable as its own door AND as a checkbox on Change Passphrase / Regenerate Words (*"also replace my keys"*);
  delete-and-set-up-again remains the recovery and compromised-ACCOUNT road. Why ruling 20's reasons are gone: the
  account-password authorization is gone (ruling 18); the stale-device CLOBBER is gone (no truncation — pull to head,
  then CAS re-push in place); the mechanism is built for the switch regardless; and without the door the honest
  answer to *"my words were seen and I don't know if they were used"* is *"delete your account"*. **Why the corpus
  recommendation changed between the afternoon and the evening (her question):** in the afternoon I weighed a
  compound of two breaches against a full re-upload with the wipe-and-repush's clobber hazard; the audit's standard
  (§2's posture law — the corpus key is a credential the old posture's iCloud key reaches, full stop), the cheaper
  in-place shape, and her disclaimer test (a Castle sentence that must say "unless a court gets our server and you
  kept a Standard backup" does not fit the posture) corrected the weighing. Recorded as a change of mind, not a fact
  that changed.
- **(t) HER FRAMING OF CHANGE PASSPHRASE, adopted into copy (09-04 night):** *"if it's clear that the point of
  changing your passphrase is if YOU forgot your passphrase, and not as a security measure (for which you should use
  rotate all keys), that's fine."* Confirmed facts behind it: after a passphrase change every already-enrolled device
  KEEPS SYNCING (it holds the master); the old word stops opening the LOBBY online (Rule 1) and stops letting a NEW
  device in; Touch ID devices get the post-unlock prompt. In Castle, Change Passphrase re-auths by the current
  passphrase; forgot → Touch ID where enabled, else the twelve words (ruling 23); Replace All Keys re-auths the same
  way. Consequence stated once more: under Touch ID mode, any finger enrolled on the Mac account can open, set a new
  passphrase, and replace the keys — keystone 2's "an unlocked, enrolled device is as powerful as your passphrase",
  and Always ask is the answer for a shared Mac (§14.21).
- **(r) THE BARE-SESSION PURGE HOLE (found 09-04 night by her attacker scenario):** `sync_purge_execute` today
  authorizes by session + the `active_key_id` fence, and the key id is readable from the vault by any session; the
  batch 1b brief had left it off the proof list. It takes `key_proof` (§3.8, 1b.2, ledger 24). With that, §3.8's
  sentence — *the account password alone can sign in, see nothing, push nothing, delete nothing but the whole
  account* — is true of every RPC.
- **(s) Castle → Standard, answered (§3.1c's switch table):** nothing is rotated and at most ONE item is added to
  iCloud — the iCloud key itself, only if absent. The wrapped copies are added on the SERVER (one vault write) and on
  DISK (the key file), in place; the passphrase, words, master, corpus key and library key are unchanged; other
  devices add their own iCloud-key copy from their own iCloud Keychain and type nothing.

**STILL HERS:** (e) the posture copy — 13s re-voices from `pre-13x-copy.md`; the bridge removal's ORDER
(before the key work, recommended, or after — see LIVE STATUS); the sizing flag (17b: three phase-sized
units — one phase or a split at U3); *(RULED the same day: Replace All Keys with its checkboxes (q); the master AND corpus rotation at the switch (m)/(m-corpus); ruling 12 dropped (j); the
delete-pre-switch-backups offer (k); the book titled "Encryption Explained" (n); the standalone new-key door RETIRED
(l).)*

## I.4 §19 THE ARCHITECT'S REVIEW OF THE 09-03 DESIGN, AND THE SIGN-OFF — with the 09-04 dispositions written into it (verbatim)


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
   posture. Accepted; the plaintext export's strip rule is the pinned corollary. **09-04: this concern was UNDER-READ — a snapshot
   carrying M is an enrolled device frozen in time, so after a Standard → Castle switch a Standard-era snapshot +
   the iCloud key + a session still syncs the whole current corpus unless the master is rotated at the switch.
   §16 (m), §14.31; the library re-key (a) does not reach it.**
6. **A persists after the Castle switch.** A alone opens nothing once the boxes are removed; deleting it would
   break other libraries and accounts on the same iCloud. The residual — copies of Standard-era key files
   outside our folders — is disclosed in the ceremony. Accepted; the app's own backup folders are stripped. **09-04: SUPERSEDED by her ruling — the library re-keys at the
   switch and no backup folder is touched; the residual shrinks to pre-switch copies, which the ceremony names as a
   limit and a way back (§16 09-04 (a)/(b)).**
7. **L is never rotated.** A user who believes their Apple account was compromised while Standard rotates M
   by deleting the account, but L stays; a copied L opens FUTURE backups of that library file if the copier
   obtains them. Disposition: declined for v1 with the recorded manual road (§13); named in the Castle
   ceremony's small print. This is the one residual I would revisit first after v1. **09-04: L now rotates at the Castle switch and at
   Castle enrollment of a Standard-born library (her ruling); the only un-rotated leg is a user who stays Standard —
   which is Standard's own sentence.**
8. **The pre-unlock vault read leaks "this device woke at 9:00" to the server.** Timing metadata only, already
   inside the disclosed envelope (write cadence). Accepted.
9. **iCloud Keychain propagation is unbounded.** Not a security flaw but the most likely SUPPORT flaw: a new
   Standard device that waits an hour looks broken. Disposition: the waiting state is load-bearing, its
   passphrase door beside it, and batch 0 measures the real latency on her two devices before copy is written.
10. **The enrolled-finger caveat** and **the open-app window** are real and cannot be closed in software;
    both are in copy. Not flaws — disclosed boundaries.
11. **(added 2026-09-04 evening — the concern this review MISSED, found by the author's questions):** the switch
    left the master and corpus key unchanged while §3.2 had made every backup a raw holder of both; a Standard-era
    snapshot + the iCloud key + a session re-entered the account's sync after the switch, and + a server breach read
    post-switch ciphertext. Disposition: (m) AND (m-corpus) RULED (master + corpus rotation, every row re-encrypted in
    place); the posture law (§2) and the credential audit (§3.1c) become ladder
    obligations — every round's reviewer walks §3.1c's "at the switch" column. The sign-off's condition list gains
    (vi): §3.1c holds at closeout with every row's "at the switch" cell pinned.

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


## I.5 §18 THE SESSION RECORD, 2026-08-31 → 09-01 (verbatim — its section numbers refer to the 09-01 numbering; where it names a mechanism later removed — the raw sync-key mirror, Replace Keys by account password, the export-and-swap-then-nothing switch, the Fragments line — the design file wins)


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


## I.6 The 2026-09-02 addendum and the batch 0 architect verification (verbatim)


- **FOUR items JOIN this phase from 13u2 (her ruling R-cor-12, `notes/plans/act10-correction-round.md` §1):** the
  near-empty re-key TYPED CONFIRMATION (#86(c)) · the protection nudge bar OVERLAYING the sidebar's bottom row ·
  the legs brain counting the SYNC leg + the "extend" wording · COPY ALL on the recovery phrase (her word NEED — a
  one-session 17 entry if this phase is far). This design's §8 surfaces absorb them; §2's two-posture model DELETES
  the loss-legs presentation, so the nudge/legs items may be moot by construction — verify at batch 5 (copy).
- **§15's batch 6 (17i) is WITHDRAWN from this phase (R-cor-13):** 17i — the sync reconciliation hunt — runs as its
  OWN 17 entry AFTER this phase lands, on the settled key path; its brief is unchanged. **§16(d)'s parked "Pause
  sync" (17k) now belongs to 18a** (sync considerations — `DetailedPlanForPhases.md` row 18).
- The daily-Journal identity memo is **13i-e's** now (from 13y). The dedupe residuals are **18a's** (from 13y).

**Batch 0 — the architect's verification (2026-09-04, after the implementer's close).** Spot-checked, never
trusted: the five commits are on `origin/main` (`fa64534` · `a37f9cd` · `e29ebe3` · `e8f7a11` · `2b90724`); the
entitlements diff is exactly the second-entry shape on both targets with the default group first; the probe
files are DEBUG-only and the Mac suite is `.enabled(if:)`-gated (re-run by the architect without the variable:
both tests `skipped:`, `EntitlementsTests` green — the shared-group pin holds); the memo answers Q1–Q6 with
numbers and Q3 as PENDING-HER-SITTING with the five-minute procedure. **The tutorial spine ran against the
batch 0 tree: 72 tests in 10 suites passed** (the standing 72/10; the new Help-menu door disturbed nothing).
The memo's forward items became ledger rows 8–12. **U0 is CLOSED**; what remains of it is hers (row 2, the
phone leg). Two orchestrator-side machinery notes, recorded in the resiliency protocol's 2026-09-04 addendum:
the `tail | grep -m1` wait, and Swift Testing's skipped-test count — plus one of the architect's own: zsh does
not word-split an unquoted `$VAR` of `-only-testing` flags; build an array and pass `"${ARGS[@]}"`, or the
whole list arrives as ONE argument and xcodebuild exits 65 before running anything.



---

# PART II — BATCH 0, THE MEASUREMENT SPIKE (its brief and its record, verbatim; the measured facts live on in the design file's execution record and in `pre-13x-spike-memo.md`)

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



---

# PART III — THE SHAPES THAT WERE TRIED AND LEFT, IN ONE PLACE

| shape | when | why it left |
|---|---|---|
| the 13p/14b dial matrix (escrow dial, two presets, the sync Touch ID gate, loss legs, recipes) | 13p (08-27 → 08-30) | "users are NOT going to understand this" — two postures replace it (09-01, ruling 1–2) |
| the raw sync-key MIRROR in iCloud Keychain for Standard | 09-01 design | no raw key ever sits in iCloud; one Apple-held key with wrapped copies under it (09-03, ruling 17) |
| Replace Keys authorized by the ACCOUNT PASSWORD | 09-01 design | the account password never touches keys (09-03, ruling 18) |
| a Replace Keys / rotate door at all | 09-03 (ruling 20 declined it) | re-opened 09-04 night as Replace All Keys — in the in-place shape (pull to head, CAS re-push, no truncation) that removed the clobber hazard, with the mechanism built for the switch regardless |
| the store re-key at the Castle switch by `PRAGMA rekey` | 09-01 design | export-and-swap instead (review P7: WAL + pool; the salt cannot change under `rekey`) — then dropped entirely 09-03 with the KEK model — then re-instated 09-04 afternoon (Time Machine catches the Standard-era key file) |
| re-keying / stripping the key files in backup folders at the switch; refreshing them on a passphrase change (ruling 12) | 09-01 → 09-04 afternoon | "a backup could be anywhere and the user might not even know about it"; a half gate; the app never rewrites a backup's key file after writing it (09-04) — the live key file + same-fingerprint pairing keeps the current passphrase useful on the same Mac |
| the switch removes the Apple wraps and rotates NOTHING | 09-03 rewrite | every snapshot of an enrolled library carries the live master and corpus key; the master and the corpus key rotate at the switch (09-04 evening) |
| the plaintext export → reimport as the LIBRARY-key rotation road | 09-03 | a stand-in for a door that did not exist; the export is the open-format escape, 13x's door is restore/portability (09-04) |
| a standalone "Give this library a new key" door | 09-04 afternoon (a lean) | a library-key rotation alone protects nothing the open-device attacker lacks; folded into Replace All Keys (09-04 evening) |
| the Fragments bridge with its own posture and frozen vault format | 9b → 14d | retired (09-03, ruling 16; done 09-04) |
| a per-device stricter gate under a Standard account (hybrids) | 09-03 question (g) | two postures, no hybrids |
| a silent follow into Castle | 09-03 | the follow types the passphrase once — the new master is wrapped under nothing else (09-04 evening) |
| `sync_purge_execute` authorized by session + the key-id fence | 13j → 09-04 night | the key id is readable from the vault by any session; the proof gates it (09-04 night) |


---

# PART IV — THE SIXTH SITTING (2026-09-04, late night): the sync keys leave the library file; a passphrase change becomes a convenience act

**Her questions:** does taking the sync keys out of backups close the "pull the master from an opened backup" door
(yes — completely, and out of the FILE closes it for Time Machine and AirDrop too); does enforcing a passphrase change
on other devices make a convenience act look like security (yes — so Rule 3 and Rule 4 retired, and Rule 1 kept only
its useful half: the new word works everywhere at once, the old word retires by use); why was the master in the
library at all (the 09-01 same-machine bypass — closed since by per-store custody + the absent-store route); does a
restored backup sync automatically in Standard (yes, by enrolling through the iCloud key — Standard's contract).
**Her rulings:** the sync keys and the device identity live in per-store custody beside the library key, never in the
file; a copy of the file is writing, never a device; Change Passphrase / Regenerate Words are convenience acts with
honest copy; Replace All Keys is the security act. **Retired with it:** Rule 3 (the stale copy deleted on learning),
Rule 4 (a library opened by a retired secret syncs nothing), the standalone device-identity marker (R4's mechanism —
identity now rides the custody item), the plaintext export's strip rule (nothing in the file to strip), batch 1a's
"move the keys into `sync_state`" item. **Kept:** the rotations at the switch (anyone in your iCloud could have unwrapped
the old master from the vault during Standard), R1 (any enrolled device can finish a rotation), R2 (version-neutral
re-encryption), the follow, the owner distinction, everything else.

## IV.1 The retired §3.3 "Sync keys inside the library" (verbatim)

### 3.3 Sync keys inside the library
`sync_state` is local-only, never synced, and lives inside the SQLCipher store; `resyncReinitialize` spares its
non-bookkeeping rows. M, C (+id) and J (+id) land there as base64 rows (`e2ee.master`, `e2ee.corpus`,
`e2ee.corpus_key_id`, `e2ee.journal_bridge`, `e2ee.journal_bridge_key_id`). `LibraryKeySyncProvider` is the DB-backed
implementation of the `SyncKeyProviding` seam (synchronous by contract — a cached read refreshed on write; a locked
library reads as no keys and the engine refuses its round visibly with `SyncError.encryptionKeysUnavailable`).
**Zero schema, zero lockstep for this piece.** Consequences: one engine read path in both postures; a FRESH library
has no keys and can only ask (P/W, or — Standard — the iCloud road); `E2EEKeychainStorage`, `E2EELaunchKeyCache`,
`E2EECustodyStorage`, the CF-12 gate + `SyncGateOptIn` and `DeviceKeySyncProvider` are deleted. **A backup of an
enrolled library is an enrolled device frozen in time — it carries M and C.** This is why entering Castle rotates
them (§4). **The plaintext SQLite export NEVER copies `sync_state`, `sync_outbox`, `sync_row_seq`, `_sync_applying`,
`purge_*`:** it is produced by a keyed `sqlcipher_export` into a plaintext ATTACHed file that receives only the
synced tables — never copy-then-strip (a stripped copy leaves M in free pages). The synced tables keep their
`sync_version` and `owner_id` columns so 13x's open door can reconcile a re-opened export (§14.13).



## IV.2 The retired §3.6 with Rules 1–4 as they stood (verbatim)

### 3.6 The lobby (Castle) — three roads + two rules
Roads: **Touch ID / Face ID** (the gated item) · **the passphrase** · **the twelve words**. The two secret roads try the
LOCAL copy first (the offline cache), then — on failure, signed in and online — **the vault road**: derive per the
vault's descriptor → unwrap M → the key file's master copy → L → open → re-wrap the local P copy + record the
descriptor and the vault's corpus key id. The pre-unlock network contact is ONE authenticated vault READ (wrapped
copies only — a session without M can fetch them and nothing else). Derive ONCE when the recorded descriptor equals
the vault's; start the vault read concurrently with the derivation; progress from ~200 ms; a ~10 s ceiling hands off
to offline grace (measured: 0.77 s per derivation; 0.05–0.3 s round trip).
**Rule 1 — a retired passphrase dies when the vault can be reached, but ONLY under the SAME master:** online, if
the vault's descriptor ≠ the key file's recorded one AND the vault's corpus key id == the recorded one, the typed
passphrase is verified against the VAULT, never the cache — the old one is refused with *"your passphrase was changed
on another device; enter the new one."* If the corpus key id DIFFERS, the local copy STANDS as a road (it was never
rotated on this device), and after unlock the device lands in one of two states, told apart by the OWNER: **same
owner ⇒ the account's keys were ROTATED (entering Castle, Replace All Keys) ⇒ the FOLLOW** (§7); **different owner ⇒ a
different vault** (a deleted-then-recreated account; a library moved between accounts) ⇒ *"this account's keys don't
match this library — re-enroll"* (the enrollment row of §5 re-stamps and `resyncReinitialize`s). **A change on another
account can never lock a device out of its own library** (pinned).
**Rule 2 — offline grace, stated:** offline, the cached copy opens; the device catches up at its next connection via
the post-unlock one-time prompt (*"enter the new passphrase to update this device"* — the device opened by Touch ID
and never typed anything). Regenerated words take the same road; the local W copy re-lands the first time the words
are typed anywhere on that device.
**Rule 3 — a retired secret dies on learning:** the moment a device learns (online) that the passphrase or the words
changed under the SAME key id, it deletes the stale copy from its key file — no secret is needed to delete. Its roads
are then Touch ID / Face ID, the unchanged secret's local copy, and the new secret online (through the vault's
rewritten copy of M and the key file's M copy); the new copy lands the first time the new word is typed there. The
post-unlock prompt is deferrable on a biometric device and NOT deferrable on an Always-ask device. A device that has
not yet learned still opens with the old word offline (Rule 2).
**Rule 4 — a retired secret opens nothing NEW:** the lobby records which road opened the library. If a library was
opened by a LOCAL passphrase or words copy (offline, or before it learned), and the online reconcile then finds that
secret retired (descriptor or words copy changed under the same key id), the device enters the un-followed state (§7):
sync paused, key doors locked, the prompt NOT deferrable, until the current passphrase or the twelve words is typed —
which also lands the fresh copy. Opened by Touch ID / Face ID: Rule 3's deferrable prompt only. This is what makes a
restored old backup safe: online, its old key file's copy is refused at the lobby (Rule 1 — it records an old
descriptor); offline it opens (a backup opens with the passphrase of its day) and then syncs nothing until the
current secret is typed. Someone holding only the old passphrase and an old backup reads that backup and nothing
newer, with or without the account password.
**How the new passphrase opens a locked device:** the master inside the library is ciphertext until the library is
open, so it cannot help; the new word derives → the vault's M copy → the key file's L-under-M copy → L. Once open, a
fresh P copy is written. When the device opened by Touch ID first, the same vault unwrap VALIDATES the typed word
before a copy is written under it — which is why the prompt is online-only.



## IV.3 The retired §1 decision 10 with the Rule 3 / Rule 4 sentences (verbatim)

10. **Three acts for users, no more:** *Change Passphrase / Regenerate Twelve Words* (a re-wrap of the same keys —
    for when YOU forgot it or want another; other devices keep syncing); *Replace All Keys* (the switch's key half —
    for a secret that may have been USED or a copy that got out; four entrances: its own door, the checkbox on the
    two re-wrap doors, the checkbox on the door for a new passphrase too, and entering Castle); *Delete the account
    and set sync up again* (the recovery road and the compromised-account road). No standalone library-key door. **A retired secret dies on
    every device that learns of the change:** on learning (online — the vault's descriptor or words copy changed under
    the same key id), a device DELETES its stale passphrase or words copy from its key file at once; the prompt lands
    the new copy when the new word is typed there and is deferrable only where Touch ID / Face ID is enrolled (an
    Always-ask device has no other offline road, so it is asked then). Offline grace covers ignorance, not deferral. **And a library that was OPENED by a since-retired secret** (offline,
    from its own or a restored key file's stale copy) **does not sync until the current secret is typed** — it is
    treated as a device that has not followed (sync paused, key doors locked, the prompt not deferrable); a Touch ID or
    Face ID open is never affected. Backups are frozen enrolled devices, and "opened by a retired secret" means "not yet
    re-authorized".

# PART V — THE ORCHESTRATOR'S KICKOFF-DAY REVIEW (2026-09-05, the build orchestrator's first act): four rulings

The author's kickoff message asked for exactly this: *"The brief you have is the result of many design sessions, but
it's possible it is missing a scenario or there's some other issue with it. If you think so, BRING IT UP TO ME!! Do
not just read that the copy is finished and not tell me about a flaw, vulnerability, or other issue."* The
orchestrator read the settled design against the shipped code before spawning batch 1a and brought four findings as
one question-tool batch. Her rulings, in the labels she chose, and what each superseded (verbatim):

## V.1 Replace All Keys in Standard hands the new master to the same iCloud key — RULED "Keep A fixed, fix the copy"
The finding: in Standard the new master is re-wrapped under the unchanged A (the audit's own A row: "re-minted only
after an iCloud Keychain reset"), so an intruder who copied A keeps receiving every new master — while the
compromise rule, the Replace All Keys screen, Chapter 6 and Chapter 7 all told the user Replace All Keys answers
"someone was inside your Apple account." Offered: re-mint A at Replace All Keys (recommended) · keep A fixed and fix
the copy · A per Variorum account. **She ruled: keep A fixed, fix the copy.** Landed as decision 30; the copy's
Replace All Keys body, Chapter 6, Chapter 7, the lost-device FAQ and a new Apple-account FAQ entry re-worded; the
A-copy-of-M′ PRESENCE after a Standard Replace All Keys pinned so the honest sentence is tested.
Superseded design text: §3.4's act table, Replace All Keys "when" — *"someone may have USED a secret, or had one of
your devices unlocked, or (Standard) was in your Apple account"*; §8's rule — *"someone who may HOLD your keys (an
unlocked enrolled device plus your account password; in Standard, your Apple account) → Replace All Keys"*; the name
"the three-line compromise rule" (now four lines). Superseded copy: Replace All Keys' *"…or has a copy of your
library or a backup"* (contradicted Chapter 6's "never the reason on its own"); Chapter 6's and Chapter 7's *"or — in
Standard — was inside your Apple account"* clauses.

## V.2 Nothing on the wire or in the mirror says which corpus key a row is under — RULED "Rotation start seq in the vault"
The finding, checked at the code: `PayloadCipher`'s `e1:` envelope is nonce ‖ ciphertext ‖ tag with the key id only
in the AAD the client must already know; the mirror (`09_phase14c_multitenant.sql`) has no per-row key column, only
the vault-level `corpus_key_id` fence. §4 step 3, "any enrolled device can finish," the completion check and a
follower's decrypt all treated "a row still under the old key" as knowable. Offered: a rotation start seq recorded in
the vault with the vault row locked in every data RPC (recommended) · a per-row `key_id` column on the 18 tables · the
key id in an `e2:` envelope. **She ruled: the rotation start seq.** Landed as decision 31, the fifth vault column
`rotation_started_seq`, the `FOR UPDATE` / `FOR SHARE` serialization in §3.10 and the 1b brief, the seq rule in §4
steps 2–3 and §12, ledger row 34, and the 13y hand-forward (per-tenant seq ⇒ per-tenant rotation seq).
Superseded text: §3.10's *"four nullable columns"*; §4 step 3's *"every row still under the old key is rewritten"* and
*"COMPLETE when a device at head sees no row under the previous key, and that device clears the previous key from the
vault"* (now: below the rotation seq; clears the key AND the seq together).

## V.3 A second rotation before the first finishes would strand rows — RULED "Refuse until complete"
The finding: the vault carries ONE previous corpus key; a second Replace All Keys or Castle entry mid-rotation drops
a key that rows still sit under. Offered: refuse until complete (recommended) · chain the previous keys. **She ruled:
refuse.** Landed as decision 32: the door refusal, the `key_vault_update` refusal (`VARIORUM_ROTATION_IN_PROGRESS`),
§4 step 1's third refusal condition, §5's Replace All Keys row, the copy's "still finishing" sentence, ledger row 35.

## V.4 An Always-ask device does not "keep syncing" after a passphrase change elsewhere — RULED "Accept + state it"
The finding: an Always-ask device holds no master key, so opened with a retired word it reads and edits but cannot
sync until the new word is typed there (decision 10's "other devices keep syncing" was untrue for it); and one that
unlocks OFFLINE must retain the derived wrapping key in session memory or it never syncs that session once online.
**She ruled: accept and state it.** Landed as decision 10's exception sentence, §3.3's session-memory rule, §7's
steps 6–7, the copy's Always-ask banner variant, §12's pins, ledger row 36 and the 1a brief.
Superseded text: §3.3's *"held in memory for the unlocked session, obtained at unlock from the typed secret through the
vault when online (offline there is no network to sync with)"* — the derived key's retention was unstated.

## V.5 The orchestrator's notes, folded under the architect mandate (listed to her in the same message; none a product change)
The proof on `sync_horizon` and `sync_purge_ledger` too · a `BEFORE INSERT` trigger for the NULL hash (never a CHECK)
· `auth.uid()` scope on `key_vault_update` · the proof as a body parameter, named a bearer token in the privacy brief
· one gated read per unlock for the biometric custody item · the third crash point (swap → custody) · a CAS refuse at
a switch becomes the follow · a rotation re-delivers the corpus once per device · Macs without Touch ID get Always ask
only · Sign Out Everywhere's ≤ 1 h access-token tail · a re-minted identity with a non-zero cursor is a purge-ledger
returner · the account password's fourth power on a vault-less account (creating the vault) and its copy line ·
Regenerate's body aligned with the FAQ (a device where the new words were not yet used still takes the old ones) ·
the lost-device FAQ's Standard line (remove the device from the Apple account). Corners 35–43, ledger rows 37–40.

## V.6 Her reply to the review's recap (2026-09-05) — two corners ruled, two process rules adopted
Verbatim: *"I think the follow after a standard replace all keys should still ask for the passphrase once, it's making
sure you have it. i think an already issued access token being alive for up to an hour is fine ? why up to an hour."*
→ The Standard follow keeps asking once (§5's Replace All Keys row carries her reason); corner 38 accepted as it stands,
with the answer recorded there (the hour is the project's default access-token lifetime; a signed JWT is checked by
signature and expiry, not against a revocation list, so a global sign-out revokes the refresh tokens and cannot recall
a token already in hand; 13y's recently-re-authenticated guard closes the deletion arm). Relayed from another session,
adopted as standing rules in §19: every batch record carries ORCHESTRATOR-DECIDED NOTES (what was settled without her,
for the cold reviewer), and every batch brief is written only after the orchestrator has read the shipped code the
batch's mechanisms assume and checked the design's claims against it (the decision 31 precedent).
Her confirmation the same day, verbatim: *"both of those are fully accepted, I'll keep the lifetime as is."* — corner
38 now says the lifetime stays; the 13y "may shorten" clause is gone.
