# Castle Rules — how Variorum protects a library

**Status: THE CONTRACT for library protection, ruled by the author at the VX-305 simplification sitting (2026-10-16),
amended the same day at her rulings on the design cold read (`notes/plans/vx-378-design-cold-read.md`), and again at her
U2 ruling (rules 11–12: both secrets at a crossing — P-VX378-U2-2, the plan's §8) and her FACTS DIFF rulings (rules 12
and 25 — FD-2, FD-3, the plan's §8 note after U3). Amended again at her rulings at the U4 stop (2026-10-17, the plan's §8):
rules 4, 5 and 12 — the floor (a backup opens with the secrets you had when you made it; your current ones open older
backups of the same library); rule 17 — Make this my library carries no keys; rule 21 — the fingerprint and the wrapped
copy, the notice instead of the refusal, and the key-file offer. Amended at her morning sitting after the gate (2026-10-18,
the plan's §8): rule 5's quiet-road clause reads as built — P-VX378-O1-1; rule 25 states the honest limit of the entry sweep and rule 11 points at it —
P-VX378-O2-2. Amended at her sitting on VX-306's bundle (2026-10-18 afternoon — her words verbatim in
`notes/plans/vx-307-castle-crossings.md` §3a; built at VX-412): rules 2, 3 and 7 — THE WORDS ARE NEVER SHOWN BEFORE THE
FIRST SCREEN ("opening the app for the first time [is] a calm moment where the user can just type"; "i dont want the lobby
at start"), the card above the quick entry is the one home for the words and for rule 3's reminder, the tutorial's last
card shows the words beside its passphrase ask, and nothing ever stores the words. Until VX-412 lands, the Debug build and
the lifecycle page's stage 1 still show the creation-time words card; the page follows at that merge.**
Where this document and `notes/plans/vx-266-castle-backups-prelaunch.md` differ, this document wins; that design keeps
its research and its Apple-facts pointers (`notes/plans/vx-266/second-opinion-apple-facts.md`). The walk-through of
these rules — one person, one library, every stage — is `notes/plans/vx-266/castle-lifecycle.html`, and the corrector
phase's plan (`notes/plans/vx-378-castle-simplified.md`) builds to them. The ruling record is
`notes/plans/vx-305-castle-core.md` §8 (HER RULINGS, 2026-10-16).

**The rule about this document:** it stays short enough to read in one sitting, in plain language. If it ever needs a
long list of exceptions to stay true, that is a sign the design needs cutting, not the document growing.

---

## The one sentence

**Your writing is encrypted. Your passphrase or your twelve words — together with any copy of your library — always
open it. Everything else is a convenience.**

---

## Every library

1. **Every library is encrypted with its own random key.** The key lives in a small **key file** beside the library.
   The key file is as essential as the library itself, so the app keeps copies of it for you without asking: beside the
   library, inside every backup, and a sealed copy in this Mac's keychain. Losing the library means losing every copy of
   both — at which point there was nothing left to open anyway.
2. **Every library has twelve words from the moment it is created.** They are shown once — and never before the first
   screen: the first open is the Bookcase and the quick entry with nothing in front of them. They are shown when the
   user asks for them, from the card the app keeps above the quick entry until it is dismissed (*your library is
   encrypted — click here to record the twelve words that are its key*; dismissing it says where to find them in
   Settings) or at the tutorial's last card. Nothing stores the words, so the first look mints the words the user
   records (rule 6's act — the key unchanged); the card says "write these down now" and warns before it closes that
   they will not be shown again. Until they are recorded, this Mac's quiet roads (rule 8) are the library's only
   opener here, which is why the card stays. They open the library for as long as they are its words. There is no
   such thing as a library with no secret.
3. **Every library is asked for a passphrase.** The tutorial's last card asks, and shows the twelve words beside the
   ask (rule 2). Until a passphrase exists, the app says so now and then — in the same card above the quick entry that
   offers the words, the one home for both asks; never a second bar, never a popup — ("your library is only secured
   through iCloud Keychain right now — please add a passphrase and keep your twelve words to ensure continued access"):
   at the third launch, then weekly twice, then with a "don't show again"; and always right before the first backup and
   at the first launch after a quiet road has failed. The passphrase is a convenience over the words; either one can
   reset the other.
4. **The key file carries every earlier key the library has had**, sealed under the current one, and **every key change
   carries that list forward — no exceptions.** A backup always opens with the passphrase and words you had when you
   made it. Every key change also carries the earlier keys forward, so your current ones open older backups of the same
   library. Only typed secrets reach through the list; a quiet road opens only a key it directly holds.
5. **A backup is the library plus its key file.** It opens with the passphrase and words you had when you made it, with
   your current secrets through rule 4, or through this Mac's quiet roads while they still hold the key the backup's key
   file is locked under.
6. **Changing the passphrase or making new words re-locks the current key; it does not change the key.** Older backups
   made under that same key still open with your new secrets; older keys still open through rule 4. The doors say so in
   one sentence.
7. **A device holds one pair of secrets at a time.** Alone, the library's own. Synced, the account's: the first device
   to turn on sync hands its library's pair up to become the account's; a device that joins an account later adopts the
   account's pair, and is told plainly — *your library's twelve words are now your account's twelve words; here they
   are; the old ones still open backups you made before today*. Joining re-locks the key under the new pair; it never
   changes the key. The key doors change the library's and the account's locks together. Make-this-my-library (rule 17)
   keeps your current pair. Fresh words appear only at a library's own first look (rule 2) or its new-words door (rule 6);
   joining shows the account's.

## Two postures — and only one at a time

**A library (and the account it syncs with) is in exactly one posture. Castle protects your library while it is in
Castle. Entering takes everything in; leaving hands everything out. The app never keeps a protection you chose to leave,
and never leaves a hole you chose to close.**

8. **Standard is a convenience posture.** Besides your secrets, the app may keep **quiet roads** to the key: an Apple
   road (your iCloud Keychain, through your Apple account — which also reaches your other Macs on that account) and an
   on-device road (this Mac's login keychain: your login password or Touch ID). The app does not take responsibility for
   what Apple does with the Apple road. If it stops working — a changed Apple ID, a keychain reset — the next open uses
   whatever quiet road still works and quietly makes a fresh Apple road; it asks for your passphrase or words only when
   no quiet road remains. Either way nothing was ever at risk. For most people the Apple road simply works forever.
9. **Castle is one promise: no quiet road through Apple, ever, on any device of the account.** Touch ID on this Mac is
   optional; "Always ask" means no copy of the key on the device at all, and you type every time.
10. **Castle is account-wide.** When one device enters, every device of the account follows, each typing a secret once.
    Until a device follows, it can still read what it already has — its own local copy — through its own quiet road.
    That is accepted and said plainly.
11. **Entering Castle types your passphrase and your twelve words.** On this device: a new library key carrying every earlier key, the Apple
    and on-device keychain items **deleted** (an Apple item's deletion reaches every device on the Apple account — so
    your Standard-era backups' quiet locks die with it, and they are now Castle-protected along with the live library),
    the on-device road kept only as Touch ID if you choose it, and the scheduled plain-text export turned off with one
    notice you may reverse (a plain copy on disk would undo the promise; it is your call). On the account: a new sync
    key, in one write (rule 15). Other devices follow by typing one secret. Rule 25 names the exceptions: two kinds of older
    lock the app cannot reach, neither of them a road to your current writing.
12. **Leaving Castle types your passphrase and your twelve words, and hands everything to Standard.** On this device: a new Standard key
    carrying every earlier key — the Castle ones included — with a fresh Apple road and the on-device road back; this
    Mac's on-device road and its sealed key-file copy now hold the new key. Your text, the server's rows, the sync key and
    **every backup you have ever made** are Standard from now on. The leave screen says so plainly: *your library and all
    your backups will open through your Apple account and this Mac again; if you want Castle-era writing to stay
    Castle-protected, don't leave.* Other devices follow out quietly, with a notice; one that lagged through the whole
    Castle stretch types a secret once to catch up, today's or the one it had when it last synced.
13. **A Castle-era backup is protected while your library is in Castle.** Nothing else is promised about it.

## Sync

14. **The account's shared keys are wrapped by the passphrase and the twelve words only — never by Apple.** Joining the
    account from a new device always types one of them. That moment is also the reminder, for anyone who never wrote
    their words down, while they still have access.
15. **Each row on the server is sealed under the sync key that was current when it was written, and the account keeps
    every sync key it has ever had**, each sealed under the current master — rule 4's idea applied to the account, so a
    device joining years later reads everything. The sync key changes only when the account enters Castle; while the
    account stays in Castle, writing made there is sealed under a key no quiet road holds, and a device that has not
    followed cannot sync until it does. Leaving Castle hands that writing to Standard (rule 12) — the server's keys and
    the library's follow the same one-posture rule.
16. **Leaving an account changes none of your library's keys or secrets** — it stops syncing, and the server keeps what
    you pushed (removing it is the account-deletion road). Signing back in is a join (rule 7).

## Copies and other libraries

17. **A copy is a copy.** *Look inside:* any copy — your old backup, someone else's library — opens read-only with its
    own secrets (or its own quiet road on this Mac). The app writes nothing: no key file, no keychain item, no change to
    your library. Close it and the app forgets it. *Make this my library:* one confirmed door. The copy takes the live
    place as a **new library** — a fresh identity and a fresh key in the posture you are in now, under your current pair
    — and your previous library steps aside whole into Previous Libraries. The app's Restore from Backup is this door.
    You never leave Castle by opening something.
18. **Two devices share a library through sync, never through files.** An AirDropped library is a copy; it becomes its
    own library on arrival and may diverge, unless both devices sign into the same account. A restored copy that joins
    the account merges by its rows, exactly as any device does. Someone else's copy you make yours joins *your* account
    as a copy and nothing ever leaves theirs: the server keeps every account's rows apart, and only an account's own
    sign-in and sync key reach its rows.
19. **Copies of other libraries are listed and can be deleted.** They are read only through Look inside.

## Safety

20. **Every act that changes keys is planned, and a crash at any point leaves either the old state or the new one.**
    The next open finishes the act or rolls it back from what is on disk, and says which.
21. **This Mac remembers four things about its library — its ID, its device ID, a fingerprint of its current key, and
    a copy of its key file: the key itself, still wrapped under your locks — and only the app's own doors change them.**
    If the library in the live place is not the one this Mac last opened, the app opens it and says so once — *"This
    is an older copy of your library, from <date>"* or *"This is a different library than the one this Mac last had
    open"* — and remembers this one from then on; its posture follows the account's as any device's does. If the key
    file beside the library doesn't open it, the app looks for one that does in the places it keeps them — this Mac's
    keychain copy and each backup's key file — and offers what it found, saying where (*"The key file beside your
    library doesn't open it. The backup from August 3 holds a key file that does. Use it?"*); nothing is written before
    your yes, and if none opens it, rule 27 says so. It never repairs by guessing, and it never decides for you.
    (Hand-restoring a backup pair into the live place therefore opens it, with the notice; the app's own Restore door is
    still the honest road.)
22. **A key is deleted only after its replacement has been verified.**
23. **Each library on each device has a plain random device ID, made at creation.** No hardware fingerprinting.
24. **The core compiles in both configurations.** Nothing is behind `#if DEBUG` except the test switches that turn a
    guard off.

## What we do not promise

25. **We don't promise Apple's roads keep working** across Apple ID changes, iCloud sign-outs, keychain resets or a move
    to a new Mac. We promise you never *need* them (rules 2, 3, 8). A Standard-era backup locked under an Apple account
    you have since left keeps that lock, which the app cannot delete. Likewise a quiet lock this Mac no longer remembers — a
    key file kept outside the app's own folders, after a rollback — survives entering Castle; it reaches only backups from
    before you entered, never your current writing (rules 9, 11).
26. **We don't migrate stores from before this design, and we don't handle them.** Everyone with such a store exports
    their writing or signs into sync before the switch, then starts fresh; the people concerned are the author and a few
    testers, and they have been told.
27. **A library whose every key-file copy and every backup are gone is gone.** Synced libraries are the exception: the
    twelve words recover them from the account.

---

## Considered and not pursued (so no later session re-opens them)

- **The twelve words as the root of the key** (deriving each library's key from its words so a lost key file is a
  non-event) — *not pursued, 2026-10-16.* In the sync design the words are the **account's** recovery secret, shared
  across devices and wrapping a random master (14b, R-5/R-8). Deriving library keys from them would turn "new words"
  into a lockstep re-encryption of every device's library and create two kinds of twelve words. Rule 1 — automatic
  redundancy of the key file — and rule 7 — one pair at a time — buy the same safety without either.
- **Re-sealing the whole account under a new sync key at each Castle entry** — *not pursued.* Rule 15's kept list of
  earlier sync keys reads every row with no bulk operation and no crash window.
- **The Castle anchor** (a separately locked pocket carrying Castle keys out of a leave so that typed secrets reached
  Castle backups but the Apple road did not) and **the stuck leave** that served it — *superseded by rules 4 and 12.*
  Also superseded, the same day: **"Castle backups need Castle secrets forever"** (the leave with an empty history). Her
  reasoning: leaving requires the passphrase, which already opens every Castle backup, so sealing them protected against
  nobody; one posture at a time; never protect the user from their own choice.
- **An Apple lock in the account vault and joining sync without a secret** — *superseded by rule 14.*
- **Automatic repair of a swapped-in or replayed file** ("memory wins", set-aside files, mirror restores) and **the
  family tree** that let the app recognise a library's own past keys — *superseded by rules 17 and 21.* A copy is a
  copy; crash safety stays; the app detects and refuses, never repairs.
- **Migrating or refusing-with-a-message stores from before this design** — *superseded by rule 26* (her words:
  "migrating every old user doesn't need to be done and shouldn't be considered an issue"; "we do NOT need to be
  concerned with pre-design stores").
- **One library on two Macs by hand-off, an identity-preserving restore, and the replacement-Mac takeover of a
  predecessor's keys** (the salted hardware+login marker) — *superseded by rules 17–18 and 23.*
- **The "Opens with" route finder as a promise** — reduced to one sentence: *your current passphrase or words; on this
  Mac, its quiet road if it still holds that key.*
- **Re-link as a repair act** ("heal the quiet road") — with secrets from birth it is just the lobby's normal path
  (rule 8).
- **The newest-copy offer on the unlock screen** — dropped at her P-U4-10 ruling, 2026-10-15.
- **Showing the twelve words at creation, before the first screen** (the VX-306 build) and **keeping the words until
  they are recorded** (so a snoozed card could re-show them) — *not pursued, 2026-10-18, her ruling.* The first open
  stays calm; nothing stores the words; a later look mints fresh ones (rule 2).
- **Castle as a one-way door** (leave only by export) — considered 2026-10-16; rules 12–13 make the leave clean enough
  that it isn't needed.
