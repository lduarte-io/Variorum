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

## V.7 The 1a implementer's snapshot corner — RULED "One key file per snapshot" (2026-09-05)
The finding (1a's record, note 3): a backup folder held ONE key file per library key, written once and never rewritten,
so a snapshot taken after a passphrase change sat beside a key file under the OLD word — offline it opened with the
word the folder's file was first written under, not "the passphrase you had when it was made." Offered: one key file
per snapshot (recommended) · keep one per key and say it honestly. **She ruled: one key file per snapshot.** Landed:
decision 11 amended; §6, §3.5, §12 (two pins), corner 44; ledger row 42 (batch 2 builds it on 1a.2's naming); the 1a
adjudication's item 2 closed. Superseded text: decision 11's *"Key files are named by key fingerprint and never
overwritten by another key's file"*; §6's *"the key file beside them is named by fingerprint and NEVER overwritten by a
different key's file — a folder holds one per library key it has ever held"*; the 1a brief's *"Per-fingerprint NAMING
beside the store and in backup folders"* (beside the store it stands; in folders the rule is per snapshot).

## V.8 The 2b implementer's design fork — RULED (2026-09-05): the two rotation doors take both secrets typed; the vault names the acting device
The fork: the Touch-ID-only arm of entering Castle / Replace All Keys cannot produce the new keys' wraps (M′ and L′
under P and W need the secret-derived keys, which are never stored). Offered: type both or regenerate the words
(recommended) · type the passphrase and always regenerate. **Her ruling, verbatim: *"touchid is enough to reset your
passphrase, so type both or regenerate words is fine. no need to crowd the screen with also allowing passphrase reset
there."*** → decision 33; §4's header and §5's Replace All Keys authorization re-worded; copy §2b's Screens 2–4 and
§4's Replace All Keys authorization re-written (no reset road on the ceremony; Change Passphrase's Touch ID road first).
Superseded text: §4's *"Touch ID or the passphrase — checked against the vault's current copy — confirms"*; §5's
*"Castle: Touch ID, or P (or W) verified against the vault's copy… Standard: P if one is set, else a plain confirm"*;
copy §2b's *"Screen 2 — the passphrase (only if none is set)"*, *"Screen 3 — the twelve words (only if none exist)…
If they exist: You already have twelve words. They still open your library."*, *"Confirmation: Touch ID, or the
passphrase."*; copy §4's *"Authorization: Castle — Touch ID or the passphrase. Standard — the passphrase if set, else a
plain confirm."*
The device name: the notices' *[device] on [day]* had no column behind it. Offered: a plain `updated_by_device` column
now, while the lockstep is undeployed (recommended) · anonymous notices. **She chose the column** → decision 34 (the
seventh vault column; the disclosure envelope gains a device name).

## V.9 THE WINDOW's finding (2026-09-05/06) — RULED: decision 35 (indeterminate writes nothing; the follow fires on a posture mismatch)
At her phone's first ready on the marker-8 build, no Face ID appeared and the phone's new key file carried an `apple`
copy: the migration derived STANDARD (the 13p phone key file held no secrets; the vault's word was unavailable at that
instant; 2a's safety arm read a secret-less file as Standard) and the Apple arm WROTE an iCloud copy of her real phone
library key on a Castle account's library; 2c's follow, keyed on the corpus key id, never repaired it. Brought to her
as a gap in the design's own letter (her cutover refinement). **Her rulings, verbatim:** the rule — *"Indeterminate: no
writes (Recommended)"*; the repair — *"is the follow shaped fix batch good to have anyway? i'm fine with either solution,
i'd like to do the most useful one - if we need this fix we can do it, if it's better to try out use castle i can do
that."* The orchestrator's answer: the fix is needed regardless (the letter's own pin "a Standard phone under a Castle
account gates at its next open" has no trigger without it; batch 3's Standard-born-into-Castle enrollment needs the
same), so batch 2d builds it and her phone is repaired THROUGH it — which also drills the follow into Castle on real
devices. Superseded text: 2a's settled-design note 1(d) as adopted ("NO SECRETS AT ALL ⇒ Standard — the safety arm")
now applies to the LOCAL-ONLY library only; an enrolled library waits for the vault.

# PART VI — THE CLOSED BATCH RECORDS' BODIES (moved VERBATIM from the design file's §19 on 2026-09-06 at her context-load ruling — design §16; each record's header, its two-line what-shipped and its ORCHESTRATOR ADJUDICATION block stay in the design file; the bodies below are the evidence — per-commit LIVE STATUS, the quoted reverts, drills, counts, machinery notes, questions — exactly as their implementers wrote them; CANON, not context-loaded)

## VI.1 BATCH 1a RECORD (the client substrate — the implementer's record; LIVE STATUS first)

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
3. **`copyKeyEnvelope` never rewrites** — a backup folder's key file is written once, under the source's own name, and left alone thereafter (the brief's "No code path rewrites a backup folder's key file after it is written"). Consequence for batch 5's copy: a snapshot taken after a passphrase change but under the SAME library key opens with the passphrase the folder's key file was FIRST written under (the twelve words and the master-wrapped copy of the library key are unaffected) — §6's "the passphrase you had when it was made" is loose for that corner; noted for the author.
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


## VI.2 BATCH 1b RECORD (the protocol event — the implementer's record; LIVE STATUS first)

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


## VI.3 BATCH 2a RECORD (custody & posture — the implementer's record; LIVE STATUS first)

#### LIVE STATUS (flipped in the same commit as each piece; PENDING = unverified)
- **2a.1 posture DERIVED + the derived effective gate + the §13 deletions + the idle dial + Lock Now + the keyless byte-copy + backups-at-first-unlock:** DONE (`41afd430` the substrate — `Posture.derive` from both sources with the pre-2a legacy read-through and the no-secrets safety arm; `StoreAtOpenMode.effective(posture:dials:)`; `ProtectionDials { alwaysAsk, relockAfterIdleMinutes = 10 }` with `ProtectionDefaults`' read-through + `retireLegacyKeys`; the routes on `resolve(gate:presence:)` over `StoreLaunchGate.effectiveGate`; `ProtectionController` reshaped — `posture`/`effectiveGate`/`appleKeyVerified`, `moveCustody(to:)` moving BOTH items with a refused sync half reversing the key's move, `setAlwaysAsk`, `setRelockIdleMinutes`, the Apple arm in `reconcile`, `readVaultPosture` wired in `wireOneSecretHooks`, the Mac idle clock on an app-local event monitor + `IdleLockClock`; `ProtectionPreset` · `escrowOn`/`effectiveEscrowOn` + the coupling copy · `relockOnSleepAndScreenLock` · `reminderChecksOn` · `EscrowPostureCouplingTests` DELETED; the pane + the phone sheet rebuilt to copy §1; `AppBootstrap.lock` runs `lockTimeCopy` after the pool closes (`StoreBackup.performLockTimeCopyIfDue` + `checkPendingLockTimeCopies` at the next run; wired in `VariorumApp`); the phone's relock policy on the derived gate) — the byte-copy pin landed at `dc3d2fe0` (`SnapshotPairTests`); the migration's ALIGN leg (`c8b3ca8c`) is what moves a 13p store's custody onto the derived gate; the idle-clock monitor is unpinned by nature (an `NSEvent` monitor — the pure `IdleLockClock` is pinned); the reverts DONE — batches A (the byte-copy) · B (the derivation, the retirement) · C (the both-items handover).
- **2a.2 A's item family + the key file's `apple` copy + the escrow family deleted + the probe doors deleted:** DONE (`41afd430` the family + the arm + the deletions; `dc3d2fe0` `AppleKeyRoundTripTests` — the signed-host round trip under a THROWAWAY account, opt-in `TEST_RUNNER_VARIORUM_APPLE_KEY_ROUND_TRIP=1`, run once and quoted under DRILLS RUN) — the legacy-escrow removal leg landed with 2a.5's migration (`c8b3ca8c`, ownership-guarded, drilled); the reverts DONE (batch C: the Apple arm).
- **2a.3 Standard's open road (the A road; the waiting state; the probe/nudge re-based on A):** DONE (`9f28f4d8` — `StoreLobby.Kind` (`castle` · `waitingForICloudKeychain(differentAppleID:)`), `StoreLobby.openWithAppleKey` (the verdict: opened · appleKeyAbsent · differentAppleID · noAppleCopy) + `appleRoad` polled by `beginWaiting(every:)` (5 s in production — no notification exists for a synchronizable item's arrival, the lookup's fact); `AppBootstrap.routeAndOpen`'s `.open` arm: a missing bound item over an encrypted Standard store tries A → the key file's Apple copy → opens and RE-LANDS the bound item (R1-M3), else `.waitingForICloudKeychain(StoreLobby)` — a new `State` both roots render through the lobby faces with copy §2d (the title, the body, the different-Apple-ID sentence, `Enter Passphrase…` / `Enter Twelve Words…` as the doors); never a silent mint (the open refuses typed without a key; nothing lands in custody until a secret or A opens); `ProtectionShapes.tierSentence` renders copy §5's three lines; the nudge's covered/exposed/unknown re-based on `appleKeyVerified` at 2a.1) — the revert quoted under PINS (batch A).
- **2a.4 row 42 — one key file per snapshot:** DONE (`41afd430` the pairs; `dc3d2fe0` `SnapshotPairTests` — the two §12 pins: an earlier pair byte-identical across a passphrase change and NO folder file rewritten, the later pair under the new word; prune takes the pair; the lock-time copy's pin rides the same suite) — the revert quoted under PINS (batch A).
- **2a.5 the §11 migration behind the seam + the one-time confirm face on both targets:** DONE (`c8b3ca8c` — `ProtectionMigration` (`Facts` · `Leaves` · `Report` · `run`), the production leaves `Leaves.live(...)` built in `AppBootstrap.init(variant:gate:)` and run ONCE per store id at the first ready, awaited BEFORE the reconcile; the legacy gated E2EE item read under the lobby's ONE evaluated context in `StoreKeyGuard.unlockGated` and held on `SyncCustodySession.legacyMaterial` until the migration takes it; `StoreKeyGuardKeychain.loadLegacyEscrow`/`removeLegacyEscrow` (the escrow seam's last two verbs); `ProtectionController.reconcilePassphraseWrap` + `deferMigrationConfirm` + `Notice.migrationConfirm`; `MigrationConfirmModel` (copy §9, verbatim) rendered as `MigrationConfirmSheet` (Mac) and `MobileMigrationConfirmSheet` (phone); eight recording-leaves pins in `ProtectionMigrationTests` incl. the NO-KEY-MATERIAL log scan and the off-main pin; the opt-in `ProtectionMigrationDrillTests` under `TEST_RUNNER_VARIORUM_MIGRATION_DRILL=1` — RUN ONCE, its before/after inventory quoted under DRILLS RUN) — TWO FINDINGS at the first launch of the test host with the live road wired (recorded under MACHINERY NOTES): the run executes OFF the main thread by construction now, and the live leaves are never built in the test host (`KeychainTestTripwire.armed`) — the dev store's OWN migration is therefore the Debug APP's, and it stops at the login-keychain ACL prompt for the dev scope's 2026-08-31 legacy item, which needs HER keychain password (handed forward) — settled design: `ProtectionMigration.run` at the first ready (idempotent per store id; every leg logs a line, never key material): the sync custody re-scope (1a's hook) with the legacy gated E2EE item read under the lobby's ONE evaluated context; the plain item + the CF-12 opt-in items deleted; `sync_state.device_id` → custody, then the row deleted; the dial keys retired to per-store (`mode` → `alwaysAsk`); the key file's master-wrapped copy of the library key + the corpus key id from held material (the vault's KDF descriptor lands when the reconcile READ fetches the vault); the legacy escrow item removed (ownership-guarded); the passphrase confirm (copy §9, verbatim) re-wraps the local P copy under the VAULT's descriptor after the typed word unwraps the vault's master — the one-time face; *Later* defers.
- **Gate:** DONE 2026-09-05 on the restored tree — core `swift test` 1435 tests / 156 suites green; the Mac gate run (every 2a-touched suite TYPE — 24 — plus the ten spine suites of `TutorialWalkTests.swift`): 206 tests / 34 suites green, the two opt-in drills reporting `skipped:` (each run deliberately once and quoted under DRILLS RUN); the ten spine suites individually green; iOS `generic/platform=iOS` builds; the phone's protection/lobby/relock/tutorial suites on the iPhone 17 Pro (OS 26.2) simulator 61 tests / 16 suites green. The dev store's own migration run is NOT part of this gate (the login-keychain prompt, MACHINERY NOTES) — handed forward.
- **Reverts:** DONE (three batches A · B · C from the committed state `c8b3ca8c`, 2026-09-05 — every pin red under its own mechanism's revert, quoted under PINS; the tree restored to an empty diff after each; no revert in flight) — behavioural reverts of one mechanism group at a time, signatures kept, pre-revert copies in `App/Variorum/DerivedData/2a-prerevert/` (gitignored, inside the worktree — `git check-ignore` confirmed at this record's first commit), each restored with `git checkout --` and an empty `git diff` before the next; the failing assertions quoted under PINS as they land. If this line still reads STARTING in a later session, check `git status` first: an uncommitted diff in the mechanism files is a revert in flight — restore it from git, never adopt it.

#### THE SETTLED DESIGN, PER ITEM (the readings the brief left to the implementer)
1. **Posture DERIVED.** `Posture.derive(legacyMode:vaultHasAppleHeldCopy:keyFile:)` — a pure function, in this precedence: (a) the pre-2a stored mode READS THROUGH until §11 retires it (a 13p Castle store stays Castle on the marker-8 build's first launch — `.biometric`/`.passphrase` ⇒ Castle, `.auto` ⇒ Standard); (b) the vault's word when enrolled — an Apple-held copy of the master exists ⇒ Standard, none ⇒ Castle (decision 8: every device follows the account); (c) local-only: the key file's `apple` copy ⇒ Standard, else a passphrase wrap ⇒ Castle; (d) NO SECRETS AT ALL (no vault, no key file, no wraps) ⇒ Standard — the safety arm, because a library nobody can re-open by any word must not demand one. `StoreAtOpenMode.effective(posture:dials:)`: Standard ⇒ `.auto`; Castle ⇒ `.biometric`, or `.passphrase` under Always ask. The legacy read (`ProtectionDefaults.legacyMode`) is per store id first, then the scope's — and returns nil once the store has written its OWN `alwaysAsk`, so a NEW library minted over an absent store never inherits the scope's old Castle. `ProtectionDials` = Castle's two switches only (`alwaysAsk`, `relockAfterIdleMinutes` default 10; choices 5 · 10 · 30 · never); the idle clock is time since Variorum was last used (`IdleLockClock.isDue`, fed by an app-local `NSEvent` monitor on the Mac and the phone's relock coordinator). Lock Now runs the composition root's `lock()`; after the pool closes, `StoreBackup.performLockTimeCopyIfDue` byte-copies the encrypted file (no WAL pending, a backup due, the app's own folder only) with NO key leg, records the copy's name in a pending list, and the next keyed run's `checkPendingLockTimeCopies` integrity-checks it and writes the line into that run's detail. A gate-style change is ONE transition moving BOTH custody items — `ProtectionController.moveCustody(to:)`: the store key via `CustodyHandover` first, then the sync record via `SyncCustodyTransition.move`; a refused sync half REVERSES the key's move, so the two families move together or not at all.
2. **A's item family.** `AppleKeyKeychain` is the ONE query builder — `kSecAttrSynchronizable = true`, the shared group `$(AppIdentifierPrefix)io.lduarte.Variorum.shared`, the data-protection marker, `AfterFirstUnlock`; the service `io.lduarte.Variorum.apple-key`, the account `<scope>-apple-key` (the dev scope has its own A by construction — the spike's surprise 4). `readOrMint` is idempotent; production NEVER deletes (the flagless delete is a no-op at the query level; only the test-flagged delete releases — pinned in the round trip). The reconcile's Apple arm (Standard, key in hand): read A or mint it, land the key file's `apple` copy under `appleKeyID`, VERIFY it opens the key (never adopt), and re-land a copy that sits under another A; under Castle the arm never touches A and reads `appleKeyVerified = false`. A refused A write reads as not-landed, never covered. The escrow family and both DEBUG probe doors, the probe brain and their tests are DELETED (row 12); the legacy escrow ITEMS are removed at the migration under the R1-m1 ownership guard (only when the escrowed key IS this store's key).
3. **Standard's open road (§3.8).** The route over an encrypted Standard store: the bound item opens silently; a MISSING bound item tries A against the key file's `apple` copy (`StoreLobby.openWithAppleKey` — `.opened` re-lands the bound item, R1-M3's rule); `.noAppleCopy` / `.appleKeyAbsent` / `.differentAppleID` become `AppBootstrap.State.waitingForICloudKeychain(StoreLobby)` — a real state, copy §2d (the different-Apple-ID sentence when the key file names another A), whose `Enter Passphrase…` / `Enter Twelve Words…` doors run the ordinary envelope road, and whose Apple road is re-probed every 5 s (`beginWaiting(every:)` — no notification exists for a synchronizable item's arrival; the lookup's fact) until A lands, then opens and re-lands. Never a silent mint over an existing store; nothing lands in custody before a secret or A opens. The probe/nudge tiers re-based on `appleKeyVerified`: covered (A verified) · exposed (Standard, A unreadable — the ONLY signal for "iCloud Keychain off", which is undetectable directly) · unknown.
4. **Row 42.** Every snapshot is a PAIR — `variorum-backup-<stamp>-<fp8>.sqlite` + `.keys.json`, the key file copied WITH the snapshot and never rewritten (a later passphrase change leaves the earlier pair byte-identical; the folder's `variorum-keys.json` is written ONLY when absent, for 1a-era snapshots); prune and remove take the pair; the lock-time copy's pair is written the same way.
5. **The §11 migration.** `ProtectionMigration.run(facts:leaves:)` at the FIRST ready of a store id (idempotent — a done leaf per store; a refused leg returns without marking done so the next ready retries), OFF the main thread by construction, awaited before the reconcile. Legs, in order, each logging one line and never key material: (1) the sync custody re-scoped from the 14b items into the per-store pair under the gate the route used — the legacy GATED item's material read under the lobby's ONE evaluated context at unlock (`StoreKeyGuard.unlockGated` → `SyncCustodySession.holdLegacyMaterial`) and taken here, else the plain item; the identity from `sync_state.device_id` (then the row deleted), else minted; the legacy items deleted and the CF-12 opt-in retired only after write+verify; (2) the legacy escrow item removed iff it holds THIS store's key, else left and said; (3) the dial keys retired to the per-store keys (the read-through ends); (4) custody ALIGNED to the derived posture (both items in one transition; no biometry ⇒ Always ask; a refusal leaves the run undone); (5) the key file gains the master-wrapped copy of the library key + the corpus key id from the held material, and the vault's KDF descriptor when the reconcile READ reached the vault (else at the next online ready); (6) for an enrolled library, the one-time passphrase confirm is marked pending — `MigrationConfirmModel` (copy §9 verbatim) verifies the typed word against the VAULT (`enroll` + `fetchVault`), re-wraps the local passphrase copy under the vault's descriptor (`reconcilePassphraseWrap`), clears the mark; a wrong word writes nothing; *Later* hides the face for this launch and keeps the mark. The production leaves are built in `AppBootstrap.init(variant:gate:)` and NEVER in the test host (`KeychainTestTripwire.armed`).

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
migration 2a: key file gains the master-wrapped copy of the library key + corpus key id + the vault's descriptor
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
  Read: leg 1 re-scoped the sync custody from the legacy plain item into the per-store pair under the SILENT shape the route used (the identity taken from `sync_state`, the row deleted after); leg 2 removed the legacy escrow item because it held THIS store's key; leg 3 retired the scope-wide dial keys into the store's own (the idle 15 carried, `alwaysAsk` false); leg 4 aligned custody `auto → biometric` — the store key AND the sync record moved to their gated items in one transition (both `-biometric` items PRESENT after, both bound items absent); leg 5 wrote the key file's master-wrapped copy of the library key + the corpus key id + the vault's descriptor from the held material; leg 6 left the one-time confirm pending. The AFTER inventory shows exactly the per-store custody of the design and NONE of the 13p-era items. Pollution: none — every item under `drill-<uuid>` accounts and the throwaway service, deleted at the end of the test.
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


## VI.4 BATCH 2b RECORD (entering and leaving Castle + the rotation runner — the implementer's record; LIVE STATUS first)

#### LIVE STATUS (flipped in the same commit as each piece; PENDING = unverified)
- **2b.0 item (0) — the corrected copy §9 string + its pin; `Posture.derive`'s corner-45 discriminator + the route's landing-before-deriving + its pin:** DONE (`1263c001`) — built: `ProtectionCopy.migrationConfirmBody` renders copy §9's corrected sentence verbatim (the device word interpolated); `RawKeyCustody { silent · gatedOrNone · unknown }` + `Posture.derive(…, rawKeyCustody:)` — arm (c)'s no-`apple`-copy case answers Standard when the raw key sits in the SILENT bound item and Castle only when it is gated or nowhere (`.unknown` keeps the older reading); `RoutePostureFacts.rawKeyCustody`; `StoreLaunchGate.effectiveGate` reads the shape by presence (`loadAuto`) and TRIES THE APPLE LANDING before deriving (a silent, passphrase-wrapped, Apple-less key file whose A is readable gets its copy landed at the route); the controller derives from its resident (after adoption: resident ⇒ gated-or-none, none ⇒ silent); the sync custody's shape read and the migration's target derive pass the real presence. Pins: `ProtectionDialsTests.aRefusedAppleLandingNeverMakesCastle` · `StoreLaunchRouteTests.aRefusedLandingFollowedByAPassphraseSetNeverRoutesToALobby` · `ProtectionCopyTests.theMigrationConfirmRendersCopyNinesCorrectedSentence`. Green: `Test run with 107 tests in 12 suites passed` (ProtectionDialsTests · ProtectionCopyTests · StoreLaunchRouteTests · Phase13pControllerTests · Phase13pLobbyTests · ProtectionMigrationTests · CustodyHandoverTests · CopyFlowRoundTests · ProtectionDialsPerStoreTests · ProtectionSurfaceRenderTests · Phase13pCopySweepTests · StoreKeyGuardBackingTests; 0 skipped). RED-ON-OLD: DONE (quoted under PINS).
- **2b.1 the core substrate — `DeviceKeyMaterial`'s rotation fields + the provider's `RotationInProgress`; `SyncEngine.pullToHead()` + `outboxCount()` hoisted; the per-STEP `RotationMarker` replacing `AccountRekeyMarker`; the SHARED driver `CorpusRotation` in `Sync/` + its pins:** DONE (`1e7c6abb`) — built: `DeviceKeyMaterial { previousCorpusKey · previousCorpusKeyID · rotationStartedSeq }` (all-three-or-none, `rotation` / `syncKeys` / `carryingPreviousCorpusKey` / `clearingPreviousCorpusKey`; a pre-2b custody blob decodes with none); `DeviceKeySyncProvider.currentKeys` = `material.syncKeys` (the rotation reaches the seam); `SyncError.pullStalled(cursor:)` + `.outboxNotEmpty(pending:)`; `SyncEngine.pullToHead(maxAttempts:)` (retries a STALLED pull, refuses typed when it never clears; deliberately NOT gated by the marker — the runner's own tool) + `outboxCount()` (the scheduler reads it); `RotationMarker` (`sync_state`'s documented `rekey_in_progress` key, a JSON value: `step` vaultWrite · reencrypt · rekeyLibrary · custody · snapshot · offer, `entersCastle`, the old/new library-key fingerprints, the new corpus key id, `startedAt` — never a key; a 14c-era bare stamp reads as `.vaultWrite`; the engine refuses `pull()`/`push()` while ANY step is set); `RotationSecrets { passphraseKey · kdf · recoveryKey? }` + `derive(passphrase:recoveryWords:)`; `CorpusRotation.begin(client:current:secrets:appleHeldCopy:)` (decision 32 at the door; corner 30's stale-master front check; M′/C′/J′ minted; ONE `key_vault_update` under the OLD proof — M′ under P and W, C′ under M′, the previous key + id, the new hash, the Apple-held copy ONLY when the caller keeps it; the receipt's seq into the returned material) · `materialFollowing(_:master:)` (the follower's key read — C′ and the previous key + seq under M′; 2c's) · `reencryptRemainder(material:)` (pull below the seq with device id nil, open by the seq rule, re-seal at the pulled version, `reencrypt`, repeat until an EMPTY window; N of M through `progress`, M growing to what later passes find; a pass budget refuses typed) · `complete(client:material:)` (the clearing write under the CURRENT proof; idempotent; returns the material without the previous key). Pins: `CorpusRotationTests` (8): `pullToHeadRetriesAStallAndRefusesTypedWhenItNeverClears` · `pullToHeadRunsWithTheMarkerSetWhileRoundsRefuse` · `beginWritesTheVaultUnderTheOldProofCarryingThePreviousKey` (+ decision 30's PRESENCE under a kept Apple copy, the ABSENCE when none) · `theWalkReencryptsEveryRowBelowTheSeqAndCompletionClearsTheKeyAndTheSeqTogether` (a REAL A5 visibility window — the late row caught by the second pass; zero conflict variants for the offline editor) · `anyEnrolledDeviceCanFinishARotationAndANewDeviceEnrolledMidRotationReadsTheMixedCorpus` · `aCrashMidReencryptionReRunsToCompletion` · `theMarkerRoundTripsItsStepAndRefusesRoundsWhileAnyStepIsSet` · `theMaterialCarriesTheRotationAllThreeOrNoneAndOldBlobsDecodeWithNone`. Green: `Test run with 8 tests in 1 suite passed`; the FULL core suite `Test run with 1443 tests in 157 suites passed` (`2b1-core-full.log`). RED-ON-OLD: DONE (quoted under PINS).
- **2b.2 the keyed → keyed re-key twin `StoreEncryptionMigration.rekey(at:from:to:faultInjector:)` on the same `Step`s + the crash matrix:** DONE (`16a28c85`) — built: the same export · checkpoint · verify · swap road with the SOURCE opened keyed (`AppDatabase.configuration(key: old)`) and the temp (`.rekeying`) ATTACHed under the NEW key (SQLCipher mints the new file's salt); idempotence BY PROBE, not header bytes (`opens(_:key:)` — a read-only keyed open reading `sqlite_master`; already under the new key ⇒ the temp swept, `false`; under neither ⇒ a typed refusal; a plaintext store refuses — that is `migrateIfNeeded`'s road); the injector rides the SAME `Step`s; both keys scrubbed from the one key-bearing error channel (P15). Pins: `StoreEncryptionMigrationTests.rekeyMovesTheStoreToTheNewKeyAndTheOldKeyOpensNothing` (+ idempotence, the two refusals) and `aCrashAtEveryRekeyBoundaryRelaunchesIntoAWholeStoreUnderOneKey` (4 arms — after a crash at every boundary the file is under EXACTLY ONE of the two keys, and the same call resumes to the new key with the old one dead). Green: `Test run with 9 tests in 1 suite passed`. RED-ON-OLD: DONE (quoted under PINS).
- **2b.3 the app runner `PostureSwitchRunner` (Shared) with `entersCastle` — steps 1–7; the bootstrap's re-key road; `AccountRekey` + the recency probe's UI caller retired, `EncryptionSession.rekeyAccount` the runner's caller; the fresh snapshot PAIR before the offer; the scheduled `.md` insurance OFF with its notice; the offer over pre-switch PAIRS; leaving Castle:** DONE (`e9e27adb`) — built: `App/Variorum/Shared/PostureSwitch.swift` — `PostureSwitchRunner` (@MainActor @Observable) over injectable `Leaves` (the bound database · the gate · the sync custody store + provider · the vault client + the rotation transport · `signedIn` · A's leaves · the key in hand · posture/alwaysAsk/biometry · `moveCustody` · `rekeyLibrary` · pause/resume sync · `takeSnapshot` · `preSwitchSnapshots(keep:)` / `deleteSnapshotPairs` · defaults · `reconcile` · now · log) with `Leaves.live(bootstrap:protection:scope:storeURL:database:services:)` reading the services LIVE (the reopen rebuilds them); `enterCastle(passphrase:recoveryWords:)` / `replaceAllKeys(…)` = `run(entersCastle:)` — step 1 push · `pullToHead` · `outboxCount == 0` · the vault's previous key refused (decision 32) · the sync custody must hold keys; step 2 the marker at `.vaultWrite` BEFORE `CorpusRotation.begin` (no Apple-held copy entering Castle; A read-or-minted and KEPT under Standard's Replace All Keys), the returned material into custody under the current shape, the marker → `.reencrypt`; step 3 the walk (N of M into `phase`) + completion + custody without the previous key; step 4 the marker → `.rekeyLibrary` (both fingerprints) → the NEW key file FIRST (L′ under P with the SAME fresh descriptor as the vault's M′ wrap — the lobby derives once; under W when words are in hand; under M′ when enrolled; the Apple copy only under Standard's Replace All Keys; the vault's descriptor + corpus key id recorded) → `StoreEncryptionMigration.rekey` through the bootstrap's `rekeyLibrary(from:to:work:)` (flush → `.opening` → the pool closed → the work → the reopen under whichever key opens the file → re-adopt; the work's error rethrown AFTER the reopen); step 5 `moveCustody` (Touch ID, or Always ask where chosen or no biometry; Standard's Replace All Keys re-saves silent); step 6 the fresh snapshot pair + the insurance OFF (entering Castle) + the pre-switch pairs listed; the marker CLEARED at the end of step 6 (the offer is a choice — see ORCHESTRATOR-DECIDED NOTES); `resumeSync`; `reconcile`. `leaveCastle()`: A read-or-minted → ONE vault write adding M under A under the current proof → the key file's `apple` copy → `moveCustody(.auto)` → reconcile. `resume(passphrase:recoveryWords:)`: `.vaultWrite`/`.reencrypt` — the vault re-read tells (never landed ⇒ `restartRequired`; landed without custody ⇒ M′ by the passphrase via `materialFollowing`; else continue) → the walk → steps 4–6; `.rekeyLibrary` — L′ from the NEW key file (the master-wrapped copy of the library key under M′, else the passphrase), the file PROBED for which key opens it (pre-swap ⇒ redo the swap with the same L′; post-swap ⇒ continue) → custody → snapshot; `.custody`/`.snapshot`/`.offer` → the remaining steps. `deletePreSwitchSnapshots(outcome)` removes the listed pairs only. The bootstrap's `readSwitchPending` + the controller's `switchInProgress` fence the reconcile's Apple arm mid-switch (the new key file is Standard-shaped for an instant). RETIRED: `AccountRekey.swift` (+ its six core pins; the whole-replace pin ported to `CorpusRotationTests.beginOverAVaultWithARecoveryWrapLeavesNoStaleWrap`), the T1 recency probe's UI caller (`EncryptionSession.rekeyRecencyProbe`/`assessRekeyRecency`, `AppServices`' wiring, the face's warning path + `RekeyGuardFaceTests`; the core `RekeyRecencyProbe` type + its pins stay); `AppServices.runAccountRekey` + its `rekeyRunner` wiring (the ROOT wires the runner — the phone's wiring is 2c's); `AccountRekeyMarker` → `RotationMarker` everywhere (the janitor, the flow tests). The Encryption tab's door explanation lost its false truncate clause (batch 3 re-shapes the door whole). The ceremony is 2b.4's; the Mac pins 2b.5's; the reverts ride 2b.5. Green at the flip: core `swift test --filter 'CorpusRotationTests|AccountLifecycleTests|PurgeJanitor|PurgeConvergence|KeyProofGate'` 42/4; the Mac 99/11 (the protection/bootstrap/custody suites) + 77/17 (the flow/services/auth/tier suites, two 14c-contract pins rewritten — recorded under MACHINERY NOTES) + 9/2; the Mac `build-for-testing` succeeded.
- **2b.4 the ceremony — `PostureSwitchModel` (Shared) over copy §2b / §2c, the vault-checked passphrase re-auth, decision 32's + the offline + the outbox refusals at the door, the Mac sheet + the pane's two doors, the ceremony held on the controller across the reopen:** DONE (`2b95af43`; `ProtectionController.refreshEnvelopeFacts` made internal for the pins at 2b.5) — built: `App/Variorum/Shared/PostureCopy.swift` carries copy §2b / §2c / §4's resume strings verbatim (the device noun interpolated); `PostureSwitchRunner.checkDoor()` (the vault fetched FIRST — enrolled?, a previous corpus key in the vault = a rotation finishing elsewhere, the vault's day, a recovery wrap; offline throws the transport's URLError); `PostureSwitchModel` (Shared, @MainActor @Observable) — modes enter · leave · resume(marker); phases in the copy's order: checking (the door — decision 32's sentence with the vault's day, or the offline sentence, BEFORE any screen asks) → explain → setPassphrase (only when none: ≥ 12 characters, matched, verified against the VAULT when enrolled, then `controller.setPassphrase`) → the words (exist: Type My Words… verified against the vault when it holds a recovery wrap, else against this library's key file · Generate New Ones; none: `RecoveryPhrase.generate` shown once → confirmed by exact re-entry) → floor(needsPassphrase) (the checkbox; the passphrase typed unless just set, verified against the VAULT's current copy when enrolled — a retired word is refused there — else the key file) → running (the runner's phase as the During line) → done(insuranceOff, hasOffer) → offer (Delete Them = `deletePreSwitchSnapshots` over the listed pairs only · Keep Them) · leaveConfirm (Touch ID through `controller.confirmPresence`, or the passphrase) → leftCastle · resumeAsk (`passphraseRequired` from the runner) · failed(sentence); `message(for:)` words every refusal (`rotationInProgress` · `staleMaster` · `SyncError` · `PostureSwitchError` · `VaultEnrollmentError.wrongPassphrase` · URLError → the offline sentence); `controller.switchInProgress` set around the runs. `ProtectionController.activeSwitch` + `openSwitch(_:vaultTie:)` / `closeSwitch()` hold the ceremony ACROSS the re-key's reopen (the `.ready` tree rebuilds; the controller does not) + `confirmPresence(_:)` + `verifyRecoveryWordsAgainstStore(_:)`. The Mac: `ProtectionPane`'s posture section renders the doors ONLY when a runner is wired (P-2) — `Use Castle…` under Standard, `Use Standard` under Castle, `Finish Entering Castle…` / `Finish Replacing Keys…` with copy §4's resume line when the marker is pending (read by `pendingMarker()` at the sheet's close) — and presents `PostureSwitchSheet` on `controller.activeSwitch` (`interactiveDismissDisabled` while running; Copy All clears the clipboard after 60 s when unchanged; the words `.privacySensitive()`). The Backups tab's plaintext warning now names CASTLE (`plaintextExportUnderLockedDown` — its pin's phrase kept). See QUESTIONS 1 (the Touch-ID-only arm cannot wrap the new keys; built over the typed passphrase — option (A); the arm is the architect's).
- **2b.5 the Mac pins (§12's "Entering Castle" Mac half, "leaves nothing behind", Backups, one rotation at a time):** DONE (`8c240bab` the pins; the reverts' record in the next commit) — `App/Variorum/VariorumTests/PostureSwitchTests.swift` — the REAL runner over scratch leaves: a scratch KEYED store (real SQLCipher; real fingerprint-named key files beside it; the real export-and-swap through a scratch `StoreBinding` — lock → work → reopen under whichever key opens the file → adopt), an EMULATED MIRROR (`EmulatedMirror`: the fake server's push / pull / reencrypt over ONE sequence, gated by the vault-key-id fence then the key proof read from the emulated vault; every `reencrypt` batch recorded; a crash seam) over `EmulatedVault` (the flow tests' scripted vault + the rotation seq CLAIMED from the mirror's sequence when a rotation begins — the RPC's `nextval` of the rows' sequence, which the byte-identical `VaultRPCEmulation` cannot know), the real `CorpusRotation` driver, real custody material minted by `VaultEnrollment.setUp`, in-memory Keychain backings, three notes pushed under the old corpus key. Seven pins: `enteringCastleRotatesEverythingAndTheStandardEraKeysOpenNothing` (the library under L′ alone; the old key file's A-copy L opens no page; no Apple copy in the new key file; L′ under P, W and M′; the vault's previous key + seq cleared together, no Apple-held copy, the new proof hash; every note re-encrypted exactly once above the rotation seq with its ciphertext changed; the OLD keys refused at the fence on push AND pull, nothing under them reaching the mirror; a FOLLOWER under the new keys pulls every note back in the clear; custody `.biometric` through the one move; the marker gone; the fresh pair BEFORE the listing; the pre-switch pair listed with its bytes untouched, the fresh pair not listed; the insurance OFF + the flag; Delete Them removes the pair together and the fresh pair survives) · `aLocalOnlyLibraryTakesStepsFourToSevenOnlyAndItsResumeNeedsThePassphrase` · `aCrashAtEachOfTheThreeSeamsResumesToCompletion` (A mid-walk: the marker at `.reencrypt`, custody carrying the previous key, a second start refused `switchInProgress`, the resume finishes the walk; B after the export before the swap: the new key file first, the resume by the master-wrapped copy of the library key without a passphrase; B′ after the swap: the resume never exports again — `rekeys` unchanged; C between the swap and custody: the refused move leaves `.custody`, the resume moves it) · `aRotationStillFinishingOnAnotherDeviceRefusesAtTheDoorAndChangesNothing` (an unfollowed device meets the fence's CF-16 sentence FIRST; a FOLLOWED device — §14.39's mid-rotation material — is refused by decision 32 with the marker never landing, the file untouched, the vault unwritten; the ceremony's first screen is copy §4's sentence carrying the vault's day) · `leavingCastleAddsTheAppleHeldCopiesAndMovesCustodySilentRotatingNothing` · `leavingCastleRefusesUnderStandard` · `theCeremonyWalksTheCopysOrderRefusingAWrongPassphraseAgainstTheVaultAndAWrongReEntry` (explain → the fresh words shown once → a wrong re-entry refused → the floor's checkbox refused → the wrong passphrase refused AGAINST THE VAULT with nothing run → done → the offer → Keep Them deletes nothing). Green: `Test run with 7 tests in 1 suite passed` (20.8 s). RED-ON-OLD: DONE (quoted under PINS).
- **2b.6 the drills (the signed host, throwaway scopes; a scratch keyed store seeded with the sample library; a fake-server sibling): Standard → Castle · Castle → Standard · a crash at each of the three seams re-run to completion · the wall time:** DONE (`a2981116`) — `App/Variorum/VariorumTests/PostureSwitchDrillTests.swift`, OPT-IN under `TEST_RUNNER_VARIORUM_POSTURE_DRILL=1` (the 2a precedent), RUN TWICE to green (the first two runs found DRILL-side faults only — the vault emulation held weakly by the client's `load` seam and freed at `makeWorld`'s return; the seeder's `uuid`/`date`/random dependencies unimplemented in the test context; three assertions mis-stated: the real `.passphrase` custody keeps the DEVICE IDENTITY in the plain sync item with `material: nil` (1a's design — the keys leave, the identity stays), a fresh sibling's own three seeded settings arrive as MERGES not applies, and a resume's `Outcome.reencrypted` counts THIS run's rows only — the mirror's batches carry the whole count across a crash). What it runs, unlike the pins: the REAL `ProtectionController.moveCustody(to:)` over the REAL device Keychain under a THROWAWAY scope (`Variorum-drill-<uuid8>`; every item removed at teardown), the real key files, the real export-and-swap through a scratch binding with `dropResident`/`adoptResident` around it, the real `StoreBackup` pair helpers over a scratch Backups folder (the production `existingBackups` + `shortFingerprint(fromBackupURL:)` filter — `Leaves.live`'s listing), the sample library seeded WHOLE (2,533 live takes; 7,656 rows pushed to the emulated mirror under the old corpus key), a sibling library on the old keys pulled to head before the switch, the drill machine framed as NO-BIOMETRY (Castle's gate = the passphrase, no Keychain item — a Touch ID item's ACL read would PROMPT in a test). The log lines + wall times are quoted under DRILLS RUN. Green: `Test run with 2 tests in 1 suite passed after 49.056 seconds`.
- **Gate:** DONE (`bab30888`) — core `swift test` full **1440 / 157** green (`2b-gate-core.log`); the Mac gate run — every suite type in a file that names a touched symbol + the ten spine suites, 53 requested / 51 real suite types (two are helper classes) — **308 / 51** green, 0 skipped (`2b-gate-mac.log`); the ten spine suites alone **72 / 10** green (`2b-gate-spine.log`); the Mac target `build-for-testing` green; the iOS target (`VariorumMobile`, `generic/platform=iOS`) **BUILD SUCCEEDED** (`2b-gate-ios.log`); the opt-in drills 2/1 green on their own (`2b6-drill3.log`). No Release build, no `/Applications` refresh, no real-store byte-copy (the brief's fences).
- **Reverts:** no revert in flight — the 2b.3/2b.4/2b.5 batch (R-a…R-l) ran from `8c240bab` in TWO passes (the ten together, then R-c + R-g ALONE because the first pass's R-l and R-d aborted the seams test and the whole-road test before those assertions were reached — the 2b.1 walk precedent) and was restored by `git checkout --` after each (`git diff` empty both times; the failing assertions are quoted under PINS). Previously: 2b.2's probe revert ran from `16a28c85` and was restored (`git diff` empty). 2b.1's batch ran from `1e7c6abb` (two runs: the four mechanisms together, then the one-pass walk alone because `begin`'s revert masked it) and was restored by `git checkout --` (`git diff` empty). Item (0)'s revert ran from `1263c001` and was restored by `git checkout --` (`git diff` empty). Pre-revert copies, when made, go to `App/Variorum/DerivedData/2b-prerevert/` (gitignored, inside the worktree); every revert is announced here before it starts and taken from a committed state.

#### THE SETTLED DESIGN, PER ITEM (filled as each lands)
*(the LIVE STATUS lines above carry the per-item detail at commit granularity; this is the shape, item by item, as it stands at the gate)*
- **(0) the seam corrections:** copy §9 rendered corrected (the keys in per-store custody beside the library key, never in the file); `Posture.derive` reads the RAW key's custody PRESENCE (corner 45 — a refused Apple landing never makes Castle; the route tries the landing before deriving).
- **(1) the ONE rotation runner (`PostureSwitchRunner`, Shared) with `entersCastle`:** §4's seven steps in order over injectable leaves; Replace All Keys = the same road with `entersCastle: false` (the Apple-held copy KEPT under Standard — decision 30; custody re-saved silent). `AccountRekey`'s truncate road is GONE; `account_data_truncate` keeps its fence for the headless tool only. The secrets are INPUTS (`RotationSecrets` from the typed passphrase + the words in hand) — question 1.
- **(1b) `pullToHead` + `outboxCount` as engine primitives;** step 1 = ONE `push()` + `pullToHead` + an empty-outbox check (a backlog beyond one push's `maxPushIterations × batchSize` refuses `outboxNotEmpty` with the count — question 2).
- **(1c) the vault write under the OLD proof** (`CorpusRotation.begin`): M′ under P and W, C′ and the previous key + id under M′, the new hash, the seq claimed inside the RPC; the driver (`reencryptRemainder` — N of M through `progress`) SHARED with 2c's follower; `complete` clears key, id and seq together under the CURRENT proof.
- **(1d) the per-STEP marker** (`RotationMarker` in `sync_state.rekey_in_progress`: vaultWrite · reencrypt · rekeyLibrary · custody · snapshot · offer + the fingerprints and the corpus key id, never a key), written BEFORE the vault write, advanced per step, cleared at the end of step 6; `resume` re-runs from the failed step (the vault re-read tells at `.vaultWrite`/`.reencrypt`; the file PROBED at `.rekeyLibrary`).
- **(2) the keyed → keyed re-key** (`StoreEncryptionMigration.rekey`) on the same `Step`s; idempotent by probe; run through the bootstrap's `rekeyLibrary(from:to:work:)` (flush → `.opening` → the pool closed → the work → reopen under whichever key opens the file → re-adopt).
- **(3) the NEW key file FIRST** under the new fingerprint (L′ under P with the vault's fresh descriptor, W, M′; the Apple copy only under Standard's Replace All Keys; the vault's descriptor + corpus key id recorded); the OLD key file stays beside old snapshots.
- **(4) custody through `moveCustody(to:)`:** Touch ID, or Always ask where chosen or no biometry, entering Castle; silent under Standard's Replace All Keys; `.auto` leaving Castle.
- **(5) the fresh snapshot PAIR before the offer; the scheduled `.md` insurance OFF with the notice (entering Castle only); the offer over the app's own PRE-switch pairs (every snapshot whose fingerprint is not the new key's), removed as PAIRS; no folder file ever rewritten.**
- **Leaving Castle:** A read-or-minted; ONE vault write adding M under A under the current proof; the key file's `apple` copy of L; `moveCustody(.auto)`; re-lock off by derivation; NOTHING rotated; no marker.
- **Without sync:** steps 4–7 only (the secrets landing on the key file alone); the resume at `.rekeyLibrary` asks for the passphrase (no master-wrapped copy of the library key).
- **The ceremony (`PostureSwitchModel`, Shared; the Mac sheet):** the door check FIRST (decision 32's sentence with the vault's day; the offline sentence); copy §2b's screens in order — the passphrase set only if none (vault-verified when enrolled), the words typed-or-regenerated when they exist (option (A), PROVISIONAL) or generated + confirmed by exact re-entry, the floor with the passphrase verified against the VAULT's current copy (a retired word refused there) else the key file, During from the runner's phase, Done + the notice, the offer; §2c's leave confirm by Touch ID (`confirmPresence`) or the passphrase; the resume road; the ceremony HELD on the controller across the re-key's reopen. The doors render only when a runner is wired; a pending marker offers its resume instead of a second start.


#### ORCHESTRATOR-DECIDED NOTES (settled under the mandate without the author — for the cold reviewer)
- The rotation runner REPLACES `AccountRekey`'s 14c truncate road — in place through `sync_reencrypt`, never truncating; `account_data_truncate` keeps its fence for the headless `vault-bootstrap` tool alone.
- `pullToHead` + the outbox count are ENGINE primitives (fact iv), never inlined.
- The keyed → keyed re-key is `StoreEncryptionMigration`'s twin on the same `Step`s (fact iii).
- The per-step persisted marker on `AccountRekeyMarker`'s pattern, resuming at the failed step.
- Corner 45's discriminator (a refused Apple landing never makes Castle) and the corrected copy §9 sentence.
- **The migration's log line persists (the orchestrator's addition, mid-batch):** `ProtectionMigration.Leaves.live`'s `log` writes at `notice`, not `info` — macOS does not persist info-level entries, so `log show` could never read the `migration 2a:` lines the window's checklist has the orchestrator read (verified: zero lines in 24 h). Still never key material (the no-key-material pin rides the leaves, level-independent; asserting the level would need an OSLog read — not cheap, not done).
- **The marker clears at the end of step 6, not after the offer (the implementer's reading of "cleared only after step 7"):** the offer is a CHOICE and *Keep Them* is a valid end; a marker that held every sync round hostage until an OFFER was answered — or forever, if the sheet was dismissed — would refuse rounds for no mechanism. The offer's listing rides the outcome in memory.
- **The T1 recency guard retired with the truncate road it guarded:** an in-place rotation clobbers nothing on the server, so "the server holds N notes this copy doesn't have" is no longer a warning the door owes.

- **The drills run as a NO-BIOMETRY machine** (`biometryAvailable` false ⇒ Castle's gate is the passphrase, no Keychain item): a Touch ID item's ACL read would PROMPT inside a test that nothing can answer; the Touch ID target is pinned with in-memory backings, the gated add's landing is `Phase13pKeychainFactTests`' standing proof. The dial `alwaysAsk` stays FALSE in that state — Always ask is Castle-only (`setAlwaysAsk`) and a no-biometry Castle is the passphrase gate by derivation, not by the dial.
- **`ProtectionController.refreshEnvelopeFacts()` made internal** (was private) so the ceremony pins can prime a scripted controller's envelope facts without a reconcile; `closeSwitch()` calls it too.
- **The Backups tab's plaintext warning names Castle** (`plaintextExportUnderLockedDown` — the 13p "locked down" word replaced; its pin's phrase kept) — the copy file's §8 spirit, since the switch turns the export OFF with §2b's notice and a re-enable under Castle is exactly this warning's moment.

#### PINS
*(each red-on-old by a behavioural revert of its mechanism from the committed state named, signatures kept, the tree restored to an empty diff; the failing assertion quoted verbatim from the run's log)*

**Item (0) — revert from `1263c001`** (`Posture.derive`'s arm (c) back to "a passphrase wrap ⇒ Castle" whatever the custody shape · the route's Apple landing disabled · `migrationConfirmBody` back to the 2a string; suites ProtectionDialsTests · ProtectionCopyTests · StoreLaunchRouteTests — `Test run with 18 tests in 3 suites failed after 0.020 seconds with 7 issues`):
- **corner 45, the derivation:** `aRefusedAppleLandingNeverMakesCastle` — `Phase13pProtectionBrainTests.swift:82:9: Expectation failed: (Posture.derive(legacyMode: nil, vaultHasAppleHeldCopy: nil, keyFile: waiting, rawKeyCustody: .silent) → .castle) == .standard`.
- **corner 45, the route + the landing:** `aRefusedLandingFollowedByAPassphraseSetNeverRoutesToALobby` — `Phase13pLobbyTests.swift:118:9: Expectation failed: (gate.effectiveGate(scope: "route", storeID: waiting.storeID, storeURL: storeURL) → .biometric) == .auto` (the lobby, on the old tree), `:126:9` the same after A arrives, `:128:9: Expectation failed: (landed.appleKeyID → nil) == (apple.id → "551db075-…")` (no landing at the route) and `:96:6: Caught error: noAppleBox`.
- **copy §9:** `theMigrationConfirmRendersCopyNinesCorrectedSentence` — `Phase13pProtectionBrainTests.swift:207:9: Expectation failed: (ProtectionCopy.migrationConfirmBody → "Variorum now keeps your sync keys inside your encrypted library, …") == ("Variorum now keeps your sync keys in this Mac's own protected Keychain, …")` and `:211:9: … .contains("inside your encrypted library") → true`.
Green after the restore: `Test run with 107 tests in 12 suites passed` (the twelve touched types; 0 skipped).

**2b.1 — revert batch from `1e7c6abb`** (`SyncEngine.pullToHead` returning the first report whether or not it stalled · `refuseIfRekeyIncomplete` reading the marker and guarding nothing · `CorpusRotation.begin` carrying NO previous corpus key (the seq defaulted to 0) · the walk returning after ONE pass; suite `CorpusRotationTests` — `2b1-revert.log`):
- **`pullToHead` (the stall):** `pullToHeadRetriesAStallAndRefusesTypedWhenItNeverClears` — `CorpusRotationTests.swift:111:15: Expectation failed: an error was expected but none was thrown` (a stalled pull answered as head).
- **the marker guard:** `pullToHeadRunsWithTheMarkerSetWhileRoundsRefuse` — `:142:15` / `:143:15: an error was expected but none was thrown` (pull and push proceed with the marker set); `theMarkerRoundTripsItsStepAndRefusesRoundsWhileAnyStepIsSet` — `:444:19` / `:445:19` the same for every one of the six steps, and `:446:13: Expectation failed: try a.outboxCount() == outbox` (the push drained the outbox past the marker — the R1-1 strand).
- **`begin` without the previous key:** `beginWritesTheVaultUnderTheOldProofCarryingThePreviousKey` — `:163:23: Expectation failed: (begun.receipt → UpdateReceipt(revision: 2, rotationStartedSeq: nil)).rotationStartedSeq → nil` (the server assigns no seq to a payload that carries no previous key — decision 31), and the three walk/follower/crash pins red at their own `#require` of the seq (`:258`, `:351`, `:400`).
- **the one-pass walk (run alone — `2b1-revert-walk.log`):** `theWalkReencryptsEveryRowBelowTheSeqAndCompletionClearsTheKeyAndTheSeqTogether` — `:273:9: Expectation failed: (report.replaced → 13) == (rowsBelow → 14)`, `:288:13: (stored.serverSeq → 14) > (rotationSeq → 15)` (the late row the visibility window hid stays BELOW the seq), `:289:13: (try? newSeam.decryptFromWire(stored)) != nil` and `:295:13: (try? oldSeam.decryptFromWire(stored)) == nil` (it is still under the OLD key), then `:227:6: Caught error: Sync refused: 'container' row 'AA…10' column 'title' failed to encrypt/decrypt (authenticationFailed)` — the completed world cannot read it.
Green after the restore: `Test run with 8 tests in 1 suite passed`; the full core suite `1443 / 157`.

**2b.2 — revert from `16a28c85`** (`rekey`'s "already under the new key" PROBE removed — a file under the new key treated as under the old; suite `StoreEncryptionMigrationTests` — `2b2-revert.log`, `Test run with 9 tests in 1 suite failed … with 2 issues`): `aCrashAtEveryRekeyBoundaryRelaunchesIntoAWholeStoreUnderOneKey(step: .swapped)` — `StoreEncryptionMigrationTests.swift:256:6: Caught error: StoreEncryptionMigration: neither the current key nor the new key opens this store; nothing was touched` (the relaunch after the swap cannot resume — the third crash point's exact failure); `rekeyMovesTheStoreToTheNewKeyAndTheOldKeyOpensNothing` — `:213:6` the same at the idempotence run. The other three crash arms stayed green (pre-swap the old key still opens the file). Green after the restore: `9 / 1`.

**2b.3 / 2b.4 / 2b.5 (the runner, the ceremony, the Mac pins) — the batch from `8c240bab`, two passes (`App/Variorum/DerivedData/2b5-revert.log`, `2b5-revert2.log`):**
- R-a (the listing before the snapshot): `enteringCastleRotatesEverythingAndTheStandardEraKeysOpenNothing` — `Expectation failed: (world.calls.listedAfterSnapshot.value → false) == true` (also in the local-only and the ceremony pins).
- R-c (the resume exports again at `.rekeyLibrary`; second pass): `aCrashAtEachOfTheThreeSeamsResumesToCompletion` seam B′ — `Expectation failed: (world.calls.rekeys → 2) == (rekeysBefore → 1)`.
- R-d (no master-wrapped copy of the library key in the new key file): the whole road — `Caught error: noMasterBox` at `expectCastleEndState`'s `unwrapKey(master:)` (seam B's passphrase-less resume was masked by R-l in the first pass; the master-copy mechanism is the same line).
- R-e (the floor's passphrase never checked against the vault): the ceremony — `Expectation failed: (model.lastError → "That passphrase doesn't unlock this library.") == (ProtectionCopy.passphraseNotTheLibrarys → …)` · `(vaultChecks → []) == ["not-the-passphrase"]` · `(vaultChecks → []) == ["not-the-passphrase", "sesame"]`.
- R-f (`checkDoor` blind to a rotation): the door pin — `Expectation failed: (facts.enrolled → true) && (facts.rotationInProgress → false)` · `(model.phase → .explain) == (.failed(expected) → .failed("A key replacement started on another device on Sep 5, 2026 is still finishing. …"))`.
- R-g (the insurance left ON; second pass): the whole road — `Expectation failed: (outcome.insuranceTurnedOff → true) && (!MarkdownInsurance.isEnabled(in: world.defaults) → false)`.
- R-h (leaving Castle without the vault's Apple-held copy): the leave pin — `Expectation failed: (vault.format.appleKeyID → nil) == (world.apple.id → "7034…")` · `Caught error: appleHeldCopyAbsent`.
- R-j (a wrong re-entry of the words accepted): the ceremony — `Expectation failed: (model.lastError → nil) == (ProtectionCopy.wordsMismatch → "That's not quite the phrase — …")` · `(model.phase → .floor(needsPassphrase: true)) == (.wordsConfirm(words) → …)`.
- R-k (an Apple copy entering Castle — vault AND key file): the whole road — `Expectation failed: (newFile.apple == nil → false) && …` · `(vault.format.masterWrappedByAppleHeld == nil → false) && …`.
- R-l (the marker cleared after the vault write instead of advancing to `.reencrypt`): seam A — `Expectation failed: try await world.marker()?.step == .reencrypt` · `expected error "switchInProgress(…reencrypt)" … but "rotationInProgress(previousKeyID: …)" … was thrown instead` · `Caught error: nothingToResume`.
- NOT PINNED at 2b.5 (recorded, not hidden): the resume's `restartRequired` arm (the vault write never landed) and its follow-by-passphrase arm (the write landed, custody did not — `materialFollowing` by the typed passphrase); no scripted seam reaches them (the vault write and the custody save are adjacent, unseamed lines). The `Leaves.live` snapshot listing (`StoreBackup.existingBackups` filtered by fingerprint) is the drills', not the scripted leaf's.

#### DRILLS RUN (2b.6 — `App/Variorum/DerivedData/2b6-drill3.log`, the green run; `2b6-drill.log` / `2b6-drill2.log` the two drill-side fault runs)

**Drill 1 — Standard → Castle with a sibling, then Castle → Standard** (`standardToCastleWithASiblingThenBackToStandard`), verbatim from the host's stdout:
```
drill 2b: seeded the sample library in 2.921444959 seconds — 2533 live takes; pushed 7656 rows under the old corpus key in 1.4490435 seconds
drill 2b: snapshot pair written: variorum-backup-2026-09-05-111956-8e79aff7.sqlite
drill 2b: posture switch: the vault rewritten under the old proof — rotation seq 7657
drill 2b: posture switch: re-encrypted 7656 rows; the previous key cleared
drill 2b: posture switch: the new key file written (ebdbaef6)
drill 2b: re-keyed the library file in 0.054684709 seconds (under L′)
drill 2b: snapshot pair written: variorum-backup-2026-09-05-112000-ebdbaef6.sqlite
drill 2b: posture switch: the scheduled plaintext export turned OFF
drill 2b: posture switch: Castle entered — library key ebdbaef6
drill 2b: STANDARD → CASTLE in 4.094904542 seconds — 7656 rows re-encrypted; insurance off: true; pre-switch pairs: ["variorum-backup-2026-09-05-111956-8e79aff7.sqlite"]
drill 2b: the followed sibling pulled: applied 7656, merged 0, cursor 15313
drill 2b: leaving Castle: the vault gained the Apple-held copy under 322dd9ac
drill 2b: leaving Castle: done — custody silent, the Apple copies landed
drill 2b: CASTLE → STANDARD in 0.013491208 seconds
```
Asserted green around those lines: the library under L′ alone (the old L and the Standard-era key file's A-copy open nothing); L′ under P, W and M′, no Apple copy; the real Keychain after the switch — the silent store-key item GONE, no gated item, the plain sync item holding ONLY the device identity (`material: nil`), the session holding M′/C′, the controller's resident L′, `posture == .castle`; the vault's previous key + seq cleared together, no Apple-held copy, the corpus key id = custody's; the marker nil; the sibling on the old keys REFUSED at the fence (`encryptionKeysReplaced`), then FOLLOWED by the passphrase (`VaultEnrollment.enroll` → M′, no rotation left) and pulled clean; a FRESH device under the new keys applied every row (7,653 applied + 3 merged — its own seeded settings — = 7,656) and holds all 2,533 takes with a sampled long take byte-identical; the offer listed exactly the pre-switch pair, whose bytes (snapshot AND pair key file) were untouched; the fresh pair carries the new fp8; Delete Them removed the pair together and the fresh one survived; the insurance OFF. Leaving Castle: the vault's Apple-held copy under A (M recovered by A), the key file's Apple copy of L′, custody SILENT again (the real silent item holds L′; the plain sync record holds C′), `posture == .standard`, the corpus key id unchanged, the mirror untouched.

**Drill 2 — a crash at each of the three seams, re-run to completion over the same corpus** (`aCrashAtEachSeamResumesToCompletionOverTheSampleLibrary`; a fresh world per seam — each seeds + pushes the corpus again):
```
drill 2b: SEAM A (mid re-encryption) resumed to completion in 2.227585375 seconds
drill 2b: SEAM B (before the swap) resumed to completion in 0.683283125 seconds — no passphrase needed (the master-wrapped copy of the library key)
drill 2b: SEAM C (after the swap, before custody) resumed to completion in 0.646537541 seconds
```
Seam A: the mirror's first `reencrypt` threw (a network loss mid-walk) — the marker at `.reencrypt`, custody carrying the previous key, the silent item still L; `resume(passphrase:recoveryWords:)` finished the walk (the mirror's batches total 7,656 across the crash) and steps 4–6. Seam B: the re-key leaf threw before the export — the marker at `.rekeyLibrary`, the file under L; `resume(passphrase: nil)` opened L′ from the new key file's master copy, redid the swap, moved custody, took the pair. Seam C: the leaf threw AFTER the export-and-swap — the file already under L′, the silent item still L; the resume never exported again (`rekeys` unchanged), moved custody, took the pair. Every seam ends in the same end state as drill 1 (the same `expectCastleEndState`).

**The wall time, for the sitting's real-store estimate:** 7,656 rows / 2,533 takes — the vault write + the walk + completion ≈ 3.5 s against an IN-MEMORY mirror (the re-encryption is CPU-bound AES-GCM open/seal per row: 39 batches of 200), the library re-key (export-and-swap of the whole Sherlock corpus under SQLCipher) **0.055 s**, custody + the snapshot pair ≈ 0.5 s; **Standard → Castle 4.1 s end to end; Castle → Standard 0.013 s.** Against the real mirror the walk's time is the network's (39 round trips of `sync_pull` + `sync_reencrypt`, each ~200 rows) — the sitting's real-store measurement is the honest number; the ceremony's During line shows N of M.


#### SUITE COUNTS
- Core (`swift test`, full): **1440 / 157** green at the gate (`2b-gate-core.log`; 1443/157 at 2b.1 → +2 `StoreEncryptionMigrationTests` rekey pins +1 `beginOverAVaultWithARecoveryWrapLeavesNoStaleWrap` −6 `AccountLifecycleTests` re-key pins retired with `AccountRekey` = 1440).
- Mac, the gate run (51 real suite types — every type in a file naming a touched symbol, incl. the flow/services/auth/tier suites of 2b.3's 77/17 and the ten spine suites): **308 / 51** green, 0 skipped (`2b-gate-mac.log`).
- Mac, the ten spine suites alone: **72 / 10** green (`2b-gate-spine.log`) — the standing 72/10 holds.
- Mac, the touched-suite runs at the commits: item (0) 107/12; 2b.3a 99/11 + 77/17 + 9/2; 2b.4 118/15; 2b.5 `PostureSwitchTests` 7/1 (20.8 s); 2b.6 `PostureSwitchDrillTests` 2/1 (49.1 s, opt-in).
- Core at the commits: 2b.1 42/4 filtered + the full 1443/157; 2b.2 9/1.
- iOS: `VariorumMobile` for `generic/platform=iOS` **BUILD SUCCEEDED** (`2b-gate-ios.log`); no phone suite touched by this batch (the phone's runner wiring is 2c's — HANDED FORWARD), so none run.


#### HANDED FORWARD
- **To 2c (the follow + the phone):** the SHARED driver's follower entry is `CorpusRotation.materialFollowing(_:master:)` (C′ + the previous key + seq under M′, pinned in `CorpusRotationTests`) + `reencryptRemainder(material:)` — "any device holding M′ can finish step 3" is ONE call; the ceremony's ENTIRE brain is `PostureSwitchModel` (Shared) — the phone renders its phases (the Mac's `PostureSwitchSheet` is the reference face); the phone's `rekeyRunner` wiring (`EncryptionSession.rekeyRunner`) is NOT wired on the phone — `AppServices.runAccountRekey` is gone, the ROOT wires the runner (`VariorumApp.swift`'s `.ready` task builds `PostureSwitchRunner(leaves: .live(...))` and sets `bootstrap.protection.switchRunner` + `encryption.rekeyRunner`); the phone needs the same two lines over its own bootstrap/services; the "still finishing" sentence's device is "another device" (the vault carries no device name — question 4); the notices (`insuranceTurnedOffNotice`, `resumeBody`) are copy-file strings, ready.
- **To batch 3 (Replace All Keys' door + the checkboxes):** the runner serves it byte-for-byte — `PostureSwitchRunner.replaceAllKeys(passphrase:recoveryWords:)` = the same road with `entersCastle: false` (the Apple-held copy kept, custody re-saved silent, no insurance change, no offer); `EncryptionSession.rekeyAccount` already calls it (the Encryption tab's interim door "Replace Keys" — its explanation lost the false truncate clause; batch 3 re-shapes the door whole to copy §4); the recovery words at Replace All Keys: the runner takes `recoveryWords: nil` (no recovery wrap — `beginOverAVaultWithARecoveryWrapLeavesNoStaleWrap` pins that NO stale wrap survives) or the words in hand — the door's checkboxes decide; the door authorizes by the ACCOUNT PASSWORD per the design (§4) — NOT built here (the interim door still takes the passphrase; the runner needs the passphrase regardless for the wraps — question 1's shape).
- **To the sitting (her hands, the real store):** the real-store switch timing — the drill's 4.1 s for 7,656 rows against an IN-MEMORY mirror is a floor; the real number is the network's (39 round trips per 7.6k rows at batch 200) — measure at the window; the migration drill on a byte-copy of her store and the 13l restore drill per posture are the sitting's (need her passphrase); the DEV store's own switch in the Debug app (the ceremony's face in her hands) — the doors render under Standard once a runner is wired at ready (they are); a marker-8 build is needed on both devices before any real round (the key proof lockstep — 1b).
- **To the ladder's reviewers:** the two UNPINNED resume arms (PINS — `restartRequired`; the follow-by-passphrase at `.reencrypt`); the ceremony's option (A) words road (question 1); the step-1 single-push backlog refusal (question 2).
- **The throwaway Keychain items:** every drill scope's four items are deleted at teardown (`deviceKeychainRemove` · `deleteGated` · `deletePlainItem` · `deleteGatedItem`); the drill's `KeychainTestTripwire` never tripped (no real scope touched).


#### MACHINERY NOTES
- The batch's DerivedData: `App/Variorum/DerivedData/pre13x-b0` (reused); logs beside it as `2b-*.log` (gitignored).
- No instance of the app was running at this session's start (`pgrep -fl 'Variorum.app/Contents/MacOS'` empty); HEAD `663476a6`, tree clean.

- **zsh does NOT word-split an unquoted `$VAR`:** `for t in $TYPES` handed all seventeen names to ONE `-only-testing:` argument — eleven suites ran and the rest silently matched nothing (the `Executed 0 tests` class) — `${(f)TYPES}` splits on newlines; every gate command here uses it. The 2b.3 record's 77/17 is the corrected re-run (`2b3-mac3.log`).
- **`-only-testing` names are TYPE names; a suite's DISPLAY name (`@Suite("…")`) is what the log prints** — the 2b.4 run "118 tests in 15 suites" for 16 requested types was `DataSafetyTests` (a FILE, holding `BackupRetentionTests` · `BackupRunTests` · `DataSafetyRunbookTests`); the gate run's list was built from the files' `struct`/`final class` declarations instead.
- **Two 14c-contract pins rewritten at 2b.3** (`EncryptionFlowTests`): `theRekeyDoorLandsInTheMandatoryPhraseStepWithNewCustody`'s runner now saves fresh custody itself (the truncate-and-heal contract is gone), and `theRekeyWiringRunsTheBrainAdoptsCustodyAndReEnqueues` became `theRekeyDoorStaysDormantUntilTheRootWiresTheRunnerAndTheMarkerReadIsWired` — the ROOT wires the runner, so the services-level pin can only assert dormancy + the marker read.
- **The emulated vault's rotation seq:** `VaultRPCEmulation` (byte-identical in both test targets — its 1b rule) mints `rotation_started_seq` from a private static counter that cannot know the mirror's sequence; `EmulatedVault` post-processes the RPC's success (a rotation that BEGAN — the previous key absent before, present after) by claiming the seq from the mirror (`claimSeq`, the fake server's `seq += 1`) and rewriting the row + the receipt — so "below the seq" reads exactly the rows pushed before the rotation, as the real RPC's `nextval` does. The emulation file itself is untouched.
- **`KeyVaultClient` holds its `load` seam WEAKLY** (the flow tests' `[weak self]` shape): a world that does not RETAIN the emulation object sees `URLError(.cancelled)` at the first vault read — the drill's first run (`2b6-drill.log`); the pins' `World` and the drill's `DrillWorld` retain it.
- **The seeder in a test context needs `uuid` / `date` / `withRandomNumberGenerator` overridden** (swift-dependencies records an "unimplemented" issue per bare read under the test harness) — the drill sets live generators; `withSampleWorld` sets deterministic ones.
- **The real `.passphrase` custody keeps the DEVICE IDENTITY in the plain sync item** (`SyncCustodyRecord(deviceID:, material: nil)`) — 1a's design read from the other side: the keys leave the item, the identity stays; a pin asserting the item GONE is wrong.
- **A fresh device's own three seeded `setting` rows arrive as MERGES** (locally dirty from the seed), so a "applied == rows pushed" count reads 3 short; `applied + merged` is the honest total.
- **`Outcome.reencrypted` counts THIS run's rows** — across a crash + resume the mirror's recorded batches carry the whole count; the drill's seams assert the batches.
- **The pane reads the pending marker on the sheet's close** (`.task(id: controller.activeSwitch?.id)`), never at autosave cadence; the runner's `pendingMarker()` is one `sync_state` read.
- The batch's DerivedData `pre13x-b0` (reused); the logs `2b-*.log` / `2b[0-6]*.log` beside it (gitignored); `2b-prerevert/` holds the pre-revert copies.

#### QUESTIONS FOR THE AUTHOR / ARCHITECT
1. **A DESIGN FORK, found reading before building — the Touch-ID-only arm of the two rotation doors cannot produce the new keys' wraps.** Entering Castle (§4 step 2) and Replace All Keys (§5) rewrite the vault with **M′ under P and under W**, and the new key file with **L′ under P and W** — every one of those wraps needs the SECRET-DERIVED key (`PassphraseKDF.deriveKey(P, descriptor)` / `RecoveryPhrase.recoveryWrapKey(W)`), and nothing in custody yields it: the vault holds M under K_P (not K_P), the key file holds L under K_P (not K_P), and decision 3.1 says P and W are NEVER stored. So "Touch ID, or the passphrase — confirms" (copy §2b Screen 4; §4; §5's Castle row for Replace All Keys) and "You already have twelve words. They still open your library." (Screen 3) cannot both hold: with Touch ID alone, M′ cannot be wrapped under P; with the words untyped, M′ cannot be wrapped under W (the vault would lose its recovery wrap — exactly the 14c `AccountRekey` shape the design retires). **Two honest options:** (A) **the ceremony types the passphrase ALWAYS** (Screen 4's confirmation is the passphrase, vault-checked — Touch ID is not sufficient because the new keys must be wrapped under it), and when twelve words EXIST the ceremony reuses 2a's Screen 3 ("Type My Words…" → the same twelve wrap M′ / "Generate New Ones" → fresh words replace them everywhere) instead of "They still open your library" — decision 5's letter ("Turning on sync requires a passphrase AND the twelve words…; so does entering Castle"), §7's follow (which writes only the TYPED secret's copy — the design plainly assumes no derived key is cached), zero new custody; or (B) **the per-store custody item gains the DERIVED wrapping keys** (K_P + its descriptor, K_W) beside M — no new power (M already equals both), validated against the vault's descriptor at use (a change elsewhere ⇒ fall to typing), refreshed whenever a word is typed — which makes Touch ID sufficient but contradicts §7's letter and widens what custody holds. **This batch BUILDS the runner over INPUT secrets** (a `RotationSecrets` value: the passphrase-derived key + its fresh descriptor, and the recovery-derived key or nil), so either answer plugs in without touching the driver, **and builds the ceremony on (A)'s road** (the typed passphrase, vault-checked; the words typed-or-regenerated when they exist) as the PROVISIONAL — the Touch-ID-only confirmation is NOT built. The architect rules before the copy is re-voiced; the recorded consequence under (A): a Castle entry without the words typed regenerates them (the standing CF-5 mandatory step), never silently drops the vault's recovery wrap.
2. **Step 1 pushes ONCE** (`engine.push()` — `maxPushIterations` × `batchSize` = 1,000 rows) and then refuses a non-empty outbox with the count (`SyncError.outboxNotEmpty`, worded). The scheduler's steady state makes that the "what this device owes" of the design; a device with a LARGER backlog (offline for days, then Use Castle…) meets the refusal and must let sync catch up first. Should the runner DRAIN instead (loop `push()` to empty, the drill's own setup) — a one-line change in `run` — or is the refusal the intended honesty (the design's letter: "refuse a non-empty outbox")? Built to the letter; the architect's call.
3. **Entering Castle lands Touch ID when biometry exists and Always ask otherwise** — the ceremony has no gate choice of its own (copy §2b has none); the pane's *Always ask* (Castle-only, `setAlwaysAsk`) is the switch after. Confirm that the first Castle open is Touch ID by default on a Mac with biometry, or should the floor screen offer the choice?
4. **The "still finishing" sentence's `[device]` is "another device"**: the vault carries no name for the device that began a rotation (the format has no such column, and adding one is a lockstep column — 13y's window or a later event). The day it started rides the vault's `updated_at`. Accept the anonymous device for v1, or record the acting device's name in the vault at the next lockstep event?
5. **Leaving Castle may confirm by Touch ID (`confirmPresence`) while entering must take the passphrase** — an asymmetry the wraps force (M′/L′ under P need P in hand; question 1's fork), not a design choice. Stated so the cold reviewer does not read it as an oversight.
6. **The resume's two unpinned arms** (PINS): `restartRequired` (the vault write never landed) and the follow-by-passphrase (the write landed, custody did not). Both are straight-line code over pinned primitives; a seam between the vault write and the custody save would pin them — worth a fault-injection leaf on `Leaves` at the ladder if the reviewer wants it red-on-old.


