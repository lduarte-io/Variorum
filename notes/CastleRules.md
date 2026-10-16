# Castle Rules — how Variorum protects a library

**Status: THE CONTRACT for library protection, ruled by the author at the VX-305 simplification sitting (2026-10-16).**
Where this document and `notes/plans/vx-266-castle-backups-prelaunch.md` differ, this document wins; that design keeps
its research and its Apple-facts pointers (`notes/plans/vx-266/second-opinion-apple-facts.md`). The walk-through of
these rules — one person, one library, every stage — is `notes/plans/vx-266/castle-lifecycle.html`, and the corrector
phase's plan builds to them. The ruling record is `notes/plans/vx-305-castle-core.md` §8 (HER RULINGS, 2026-10-16).

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
2. **Every library has twelve words from the moment it is created.** They are shown once, with "write these down now".
   They open the library for as long as they are its words. There is no such thing as a library with no secret.
3. **Every library is asked for a passphrase.** The tutorial's last card asks. Until a passphrase exists, the app says
   so now and then ("your library is only secured through iCloud Keychain right now — please add a passphrase and keep
   your twelve words to ensure continued access"): at the third launch, then weekly twice, then with a "don't show
   again"; and always right before the first backup and at the first launch after a quiet road has failed. The
   passphrase is a convenience over the words; either one can reset the other.
4. **The key file carries the library's earlier keys**, sealed under the current one. So your *current* passphrase or
   words also open every older backup made in the same posture. Entering Castle takes every earlier key in; leaving
   Castle takes none out (rule 12).
5. **A backup is the library plus the key file of its day.** It opens with the secrets of its day, or with your current
   secrets through rule 4.
6. **Regenerating the words or changing the passphrase re-locks the current key.** Older backups still open through
   rule 4. The doors say so in one sentence.

## Two postures

7. **Standard is a convenience posture.** Besides your secrets, the app may keep **quiet roads** to the key: an Apple
   road (your iCloud Keychain, through your Apple account) and an on-device road (Touch ID or your login password on this
   Mac). The app does not take responsibility for what Apple does with the Apple road — if it stops working (a changed
   Apple ID, a keychain reset), the next open asks for your passphrase or words and quietly makes a fresh road. Nothing
   was ever at risk. For most people the Apple road simply works forever.
8. **Castle is one promise: no quiet road through Apple, ever, on any device of the account.** Touch ID on this Mac is
   optional; "Always ask" means no copy of the key on the device at all, and you type every time.
9. **Castle is account-wide.** When one device enters, every device of the account follows, each typing a secret once.
   Until a device follows, it can still read what it already has — its own local copy — through its own quiet road.
   That is accepted and said plainly.
10. **Entering Castle, on this device:** a new library key (its history taking every earlier key), the quiet Apple
    road deleted, the on-device road kept only as Touch ID if you choose it, and the scheduled plain-text export turned
    off with one notice (a plain copy on disk would undo the promise). On the account: the sync key is rotated in one
    write (rule 14).
11. **Leaving Castle, on this device:** a fresh Standard key with an **empty** history and a fresh Apple road. Your text,
    the server's rows and the sync key are Standard from now on — leaving is your choice about your writing. Other
    devices follow out quietly, with a notice; one that lagged through the whole Castle stretch types a secret once to
    catch up.
12. **After leaving Castle, the only thing that stays Castle-only is a backup you made while in Castle.** It opens with
    the Castle passphrase or words of its day, and never through Apple. Keep that paper.

## Sync

13. **The account's shared keys are wrapped by the passphrase and the twelve words only — never by Apple.** Joining the
    account from a new device always types one of them. That moment is also the reminder, for anyone who never wrote
    their words down, while they still have access.
14. **Each row on the server is sealed under the sync key that was current when it was written.** The sync key changes
    only when the account enters Castle, so writing made in Castle is sealed under a key no quiet road has ever held. A
    device that has not followed cannot sync until it does.

## Copies and other libraries

15. **Look inside:** any copy — your old backup, someone else's library — opens read-only with its own secrets (or its
    own quiet road on this Mac). The app writes nothing: no key file, no keychain item, no change to your library. Close
    it and the app forgets it.
16. **Make this my library:** one confirmed door. The copy takes the live place as a **new library** — a fresh identity
    and a fresh key in the posture you are in now — and your previous library steps aside whole into Previous
    Libraries. You never leave Castle by opening something.
17. **Two devices share a library through sync, never through files.** An AirDropped library is a copy; it becomes its
    own library on arrival and may diverge, unless both devices sign into the same account.
18. **Copies of other libraries are listed and can be deleted.** They open only through Look inside.

## Safety

19. **Every act that changes keys is planned, and a crash at any point leaves either the old state or the new one.**
    The next open finishes the act or rolls it back from what is on disk, and says which.
20. **If the library file and what this Mac remembers about it disagree, the app refuses to open and says what it
    found**, pointing at your backups. It never repairs by guessing. (Your own deliberate restore — a backup's library
    and key file together — is not a disagreement.)
21. **A key is deleted only after its replacement has been verified.**
22. **Each library on each device has a plain random device ID, made at creation.** No hardware fingerprinting.
23. **The core compiles in both configurations.** Nothing is behind `#if DEBUG` except the test switches that turn a
    guard off.

## What we do not promise

24. **We don't promise Apple's roads keep working** across Apple ID changes, iCloud sign-outs or keychain resets. We
    promise you never *need* them (rules 2, 3, 7).
25. **We don't migrate stores from before this design.** Export your writing or sign into sync, then start fresh. The
    people with such stores are the author and a few testers, and they have been told.
26. **A library whose every key-file copy and every backup are gone is gone.** Synced libraries are the exception: the
    twelve words recover them from the account.

---

## Considered and not pursued (so no later session re-opens them)

- **The twelve words as the root of the key** (deriving each library's key from its words so a lost key file is a
  non-event) — *not pursued, 2026-10-16.* In the sync design the words are the **account's** recovery secret, shared
  across devices and wrapping a random master (14b, R-5/R-8). Deriving library keys from them would turn "new words"
  into a lockstep re-encryption of every device's library and create two kinds of twelve words (a local library's vs
  the account's). Rule 1 — automatic redundancy of the key file — buys the same safety without either.
- **The Castle anchor** (carrying the leave-day secrets forward so pre-leave copies open on the new Standard side) and
  **the stuck leave** that served it — *superseded by rules 11–12.* Castle backups need Castle secrets; that is the line.
- **An Apple lock in the account vault and joining sync without a secret** — *superseded by rule 13.*
- **Automatic repair of a swapped-in or replayed file** ("memory wins", set-aside files, mirror restores) — *superseded
  by rule 20.* Crash safety stays; adversary repair goes.
- **Migrating every store shape today's app ever left** — *superseded by rule 25* (her words: "migrating every old user
  doesn't need to be done and shouldn't be considered an issue").
- **One library on two Macs by hand-off, and the replacement-Mac takeover of a predecessor's keys** (the salted
  hardware+login marker) — *superseded by rules 16–17 and 22.*
- **The "Opens with" route finder as a promise** — reduced to one sentence: *your passphrase or words of its day; on
  this Mac, its quiet road if it has one.*
- **Re-link as a repair act** ("heal the quiet road") — with secrets from birth it is just the lobby's normal path
  (rule 7).
- **The newest-copy offer on the unlock screen** — dropped at her P-U4-10 ruling, 2026-10-15.
- **Castle as a one-way door** (leave only by export) — considered 2026-10-16; rules 11–12 make the leave clean enough
  that it isn't needed.
