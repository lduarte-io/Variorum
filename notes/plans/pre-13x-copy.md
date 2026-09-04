# pre-13x — THE USER-FACING TEXT (every string the phase renders; written 2026-09-03 at her instruction)

**Status:** the author's instruction at the kickoff sitting: *"You can choose the ceremony words for now & it'll
also be your job to update the settings + the tutorial with the utmost clarity on all of these facts… I do
want you to write all the user facing text that's required now though and I'll handle copy changes later."*
This file is that text. **Render, don't re-derive:** the batches copy these strings verbatim (placeholder
VOICE with honest CONTENT — 13s re-voices later; the FACTS in every sentence are binding and come from
`notes/plans/pre-13x-postures-design.md` §2–§6). Where a sentence differs between platforms, the device
words ride the standing interpolation (`Mac` / `iPhone`, `Touch ID` / `Face ID`, `login password` /
`passcode`).

**Vocabulary — TWO REGISTERS (her 09-04 rule: the plain-credential legend is the standard for talking to users,
with a brief explanation of technical terms where needed).** *Everyday surfaces* (settings, ceremonies, notices,
lobby): *your library* · *your passphrase* · *your twelve words* (never "recovery phrase" alone on first use — "your
twelve words, the recovery phrase") · *your Apple account* · *an enrolled device* · *Standard* and *Castle* · *sync*
· *a key* — no key is named there. *The Encryption book (§7b) and the FAQ:* the keys are NAMED and each term is
defined on first use — *the library key* · *the master key* · *the corpus key* · *the iCloud key* · *the key file* ·
*wrapped* (a key encrypted under another key or under your passphrase). **Never in ANY user copy:** box, vault,
escrow, KDF, token, session, RLS.

**The four keystone lines (verbatim everywhere they appear):**
1. *Your library is encrypted on disk, and sync is end-to-end encrypted. The Variorum server can never read
   your writing — in either mode. The only difference is who holds a key.*
2. *An unlocked, enrolled device is as powerful as your passphrase. Touch ID guards this device — your
   passphrase is what lets a new device in.*
3. *Your account password signs you in and can delete your account. It never touches your keys.*
4. *While Variorum is open and unlocked, everything in it is readable — that is what open means. Locking
   is how you end that.*

---

## 1. SETTINGS ▸ PROTECTION — the posture chooser

**Pane title:** Protection
**Lead:** keystone 1.

**The current-state line (top, always):**
- Standard: *You're in Standard. Your Apple account holds a key.*
- Castle: *You're in Castle. Only you hold the keys.*

### The Standard card
**Name:** Standard · **Tag:** the default
**One line:** *Your Apple account holds a key. Nothing to remember day to day.*
**Who holds a key:** your Apple account — iCloud Keychain, and Apple's ways of recovering it (your device
passcode, a recovery contact, a recovery key). *That key lives in iCloud Keychain: it travels with your Apple
account to every device signed into it, and Apple's account recovery can reach it.*
**Opening:** silently, on any device signed into your iCloud.
**A new device:** sign into iCloud, sign into Variorum, and everything is there. Nothing typed.
**Who it stops:** the Variorum server — yes. Someone at your unlocked Mac — no: anyone who can open Variorum
as you can read your writing, and can set a new passphrase. Someone fully in your Apple account — no.
**If your Mac dies:** with sync on, sign in on a new Mac and it all comes back. Without sync, your Apple
account holds a key but not your writing — you need a copy of your library that survived the Mac (your
backup folder in iCloud Drive, or Time Machine).
**The floor:** you lose your writing only if you lose every Apple device, every way Apple offers to recover
your account, AND your passphrase and twelve words. Keep the words: they are your way back if your Apple
account is ever gone.

### The Castle card
**Name:** Castle · **Tag:** only you
**One line:** *Only you hold the keys. Your Mac's login password can't open your library.*
**Who holds a key:** only you — your passphrase, your twelve words, and your enrolled devices behind Touch ID.
*With Touch ID on, this Mac's security chip holds a copy of the key. It is released only to your fingerprint —
never to your login password, never to iCloud — and it never leaves this Mac. Turn on Always ask, and no copy
exists anywhere.*
**Opening:** Touch ID, with your passphrase as the fallback — or your passphrase every time, if you choose.
**A new device:** sign into Variorum and type your passphrase or your twelve words, once.
**Who it stops:** the Variorum server — yes. Your Mac's login password — yes: nothing on this Mac releases
the key to it. Someone in your Apple account — yes. Someone holding your passphrase, your twelve words, or a
fingerprint enrolled on your Mac — no.
**If your Mac dies:** with sync on, sign in and type your passphrase. Without sync, a surviving backup plus
your passphrase or twelve words.
**The floor:** lose every enrolled device AND both your passphrase and your twelve words, and your writing is
gone. Nobody can help — not Apple, not us. That is the point of Castle, and it's why we ask you to write the
words down.

**Choose buttons:** *Use Standard* · *Use Castle…* (the ellipsis: a ceremony follows).

### Castle's switches (shown only in Castle)
- **Always ask for the passphrase** — *Skip Touch ID and type your passphrase every time Variorum opens.
  Choose this if other people's fingerprints are enrolled on your Mac.* (Sub-line: *Any fingerprint enrolled
  on your Mac account can unlock with Touch ID — Touch ID guards the Mac, not the person.* Second sub-line: *With
  this on, no copy of the key is kept on this Mac at all.*)
- **Lock after time away** — *Lock your library after you haven't used Variorum for:* 5 minutes · 10
  minutes · 30 minutes · never (default 10). Sub-line: *Switching to another app doesn't lock it; time away
  does. Variorum always locks when your Mac sleeps or its screen locks.*
- **Lock Library Now** — *Locking closes the library and forgets its key until you unlock it again.*

**The one line every posture shows (bottom of the pane):** keystone 4.

---

## 2. THE CEREMONIES

### 2a. Turning on sync (the first device of an account)
**Screen 1 — what sync needs**
Title: *Sync needs two things you keep.*
Body: *Sync is end-to-end encrypted: the Variorum server stores your writing in a form it can't read. To
make that true, your account needs a passphrase and twelve words that only you have.*
- *Your passphrase lets a new device into your sync.*
- *Your twelve words do the same, and are your way back if you forget the passphrase.*
Standard addendum (shown when the account is Standard): *You're in Standard, so day to day your Apple
account handles this for you and you won't type either one. Keep them anyway: if your Apple account is
ever gone, they are the only way back to your writing.*
Castle addendum: *You're in Castle, so these two are the only ways into your writing besides your enrolled
devices. Nobody can reset them — not Apple, not us.*
Button: *Continue*

**Screen 2 — the passphrase**
Title: *Choose your encryption passphrase.*
Field: Passphrase · Confirm passphrase
Sub-line: *At least 12 characters. Four or more random words work well. This is the one thing a stolen copy
of the server could be guessed against, so make it long.*
Under-12 refusal: *Your passphrase needs at least 12 characters.*
Mismatch: *The two entries don't match.*
If the library already has a passphrase (one secret): *Your library already has a passphrase — sync uses
the same one. Type it here.* Wrong: *That isn't your library's passphrase. Check it under Settings ▸
Protection if you're unsure.*
Button: *Continue*

**Screen 3 — the twelve words**
Title: *Write down your twelve words.*
Body: *These twelve words open your account and your library exactly as your passphrase does. Write them on
paper and keep the paper somewhere real. They are shown once.*
[the words, numbered] · *Copy All* (sub-line after copying: *Copied. Your clipboard clears in 60 seconds.*)
Button: *I've written them down*
**Screen 3b — confirm**
Title: *Type your twelve words to confirm.*
Body: *This proves the paper is right before anything depends on it.*
Errors: *A recovery phrase is exactly 12 words — you entered N.* · *"word" isn't a recovery-phrase word —
check its spelling.* · *That's not quite the phrase — one of the twelve words is off. Compare it with what
you wrote down.*
Button: *Confirm*

**Screen 4 — done**
Standard: *Sync is on. Your Apple account holds a key, so your other Apple devices will join with nothing
typed. Your passphrase and twelve words are your way back if your Apple account is ever gone.*
Castle: *Sync is on. Your other devices will ask for your passphrase or twelve words, once. Nothing else
opens your writing.*
Button: *Done*

**If this library once synced under another account** (shown before Screen 1, one sentence, its own
confirm): *This library last synced under a different account. Turning on sync here moves it to this
account and uploads everything in it. Your other account isn't changed.* Button: *Move It to This Account*

### 2b. Entering Castle (Settings ▸ Protection ▸ Use Castle…)
**Screen 1 — what changes**
Title: *Castle: only you hold the keys.*
Body: *Your library gets a new key, and so does your sync. From now on your Mac's login password can't open it,
and your Apple account holds no key to it. Opening takes Touch ID or your passphrase.*
Bullets:
- *Your other devices will start asking too — Touch ID or Face ID, with your passphrase as the fallback — and each
  gives its own library a new key the same way. Each will ask for your passphrase once, to pick up your new sync
  keys.*
- *Backups made before today — Variorum's own, Time Machine, copies you made — still open through your Apple
  account. Delete them, Time Machine included, if you want Castle to cover everything you have ever written. Keep
  them if you want a way back to what you wrote before today, should you ever lose your passphrase and twelve words.*
- *If you think someone may already hold your keys — your Apple account, or an unlocked device of yours together
  with your account password — also delete your Stargazing account and set sync up again. That gives your sync
  fresh keys.*
Button: *Continue*
**Screen 2 — the passphrase** (only if none is set): 2a's Screen 2, title *Castle needs a passphrase.*
**Screen 3 — the twelve words** (only if none exist): 2a's Screens 3/3b. If they exist: *You already have
twelve words. They still open your library.*
**Screen 4 — the floor, said once**
Title: *Read this once.*
Body: *In Castle, nobody can help you if you forget your passphrase and lose your twelve words while no
enrolled device is left. Not Apple. Not us. There is no reset. That is what makes Castle real — and it's
why the words go on paper.*
Checkbox: *I know my passphrase, and my twelve words are written down.*
Confirmation: Touch ID, or the passphrase.
Button: *Enter Castle*
**Done:** *You're in Castle. Your library has a new key that your Apple account never held. This Mac asks for
Touch ID from now on; your other devices will ask the next time they open.*
**Then, once — the offer:** Title *Delete the backups Variorum made before today?* Body: *They still open through
your Apple account, and they always will. Deleting them closes that door for what they hold. Variorum can only
delete its own backups — Time Machine, copies you made, and anything outside Variorum's folders aren't touched and
still open the old way. If your backups are in iCloud Drive, iCloud keeps deleted files for 30 days in Recently
Deleted.* Buttons: *Delete Them* · *Keep Them*

### 2c. Leaving Castle for Standard (Settings ▸ Protection ▸ Use Standard)
Title: *Back to Standard?*
Body: *Your Apple account will hold a key to your library again. Anyone fully in your Apple account, or at
your unlocked Mac, can then read your writing. Your other devices will open silently again the next time
they open.*
Confirmation: Touch ID, or the passphrase.
Button: *Use Standard*

### 2d. A new device joining
**Standard, waiting:** Title *Getting your key from iCloud Keychain…* Body: *This usually takes a moment
and can take longer. You can also enter your passphrase or twelve words instead.* Doors: *Enter Passphrase…*
· *Enter Twelve Words…* · *Open an Existing Library…* (13x)
**Standard, iCloud Keychain off on this device:** *iCloud Keychain is off on this Mac, so your Apple account
can't hand over the key here. Enter your passphrase or twelve words instead, or turn on iCloud Keychain in
System Settings.*
**Castle:** Title *Enter your passphrase to join sync.* Sub-door: *Use my twelve words instead.*
**Castle, and this library was in Standard (one sentence under the title):** *This account is in Castle, so this
library gets a new key as it joins. Everything you wrote here stays.*

---

## 3. THE LOBBY (Castle — Variorum locked)

**Touch ID prompt (system sheet reason):** *Unlock your Variorum library*
**Lobby prompt, Touch ID mode:** *Unlock your library with Touch ID.* Beneath: *Use your passphrase instead*
· *Use your twelve words*
**Lobby prompt, always-ask mode:** *Enter your encryption passphrase to unlock your library.* Beneath: *Use
your twelve words*
**Touch ID failed:** *Touch ID didn't go through — enter your encryption passphrase instead.*
**Wrong passphrase:** *That passphrase doesn't unlock this library.*
**Wrong words:** *Those twelve words don't unlock this library.*
**Retired passphrase (online, same account):** *Your passphrase was changed on another device — enter the
new one.*
**Offline note (shown small when the vault can't be reached):** *You're offline. If your passphrase was
changed on another device recently, the one you had before still works here until you're back online.*
**After unlock, keys don't match the account (a library from another account or a deleted one):** *This
account's keys don't match this library. Enter your passphrase to connect it — everything in it will
upload to this account.* Button: *Connect…*
**Dead end (no Touch ID item, no passphrase or words on file — practically unreachable):** *No way to
unlock this library exists on this Mac: its Touch ID item is gone, and no passphrase or twelve words are on
file beside the library. Restore the key file from a backup folder, or restore the whole library from a
backup.*
**Key file unreadable:** *This library's key file exists but can't be read. Restore it from a backup folder,
or unlock with Touch ID if it's offered.*
**Library file missing (the re-ruled route):** Title *Your library file is missing.* Body: *Variorum's
library isn't where it was. Your lock hasn't changed.* Doors: *Restore from a Backup…* · *Open an Existing
Library…* · *Start a New Library* (sub-line: *A new library starts empty and has its own key.*)

---

## 4. SETTINGS ▸ ACCOUNT & ENCRYPTION

**Signed out:** *Sign in to sync your library across your devices. Sync is end-to-end encrypted.* Button:
*Sign In…*
**Signup password floor:** *At least 12 characters.* Refusal: *Your account password needs at least 12
characters.* Breached-password refusal (Supabase leaked-password protection): *That password has appeared in
a known data breach — choose another.*
**Signed in, no sync yet:** *Sync isn't set up on this account.* Button: *Turn On Sync…* (→ 2a)
**Enrolled:** *Sync is on. This Mac holds your keys inside your library.* Line: keystone 3.
**Keys don't match (re-enroll):** *This account's keys changed since this Mac joined — or this library came
from another account. Enter your passphrase to connect it; everything here will upload.* Standard addendum:
*Or wait a moment — your Apple account can hand over the key.*
**Waiting for iCloud Keychain:** as 2d.

### Change passphrase
Title: *Change your encryption passphrase.*
Fields: Current passphrase · New passphrase · Confirm new
Link: *Forgot your current passphrase?*
- Standard forgot road: *This Mac holds your keys, so you can set a new passphrase now.* Button: *Set a New
  Passphrase*
- Castle forgot road, Touch ID mode: *Confirm with Touch ID to set a new passphrase.* Always-ask mode: no
  link (you typed it to get in); instead: *Use your twelve words instead.*
Checkbox (PROVISIONAL (q)): *Also replace my keys — choose this if someone may have USED the old passphrase, or has
a copy of your library.*
Done: *Your passphrase is changed. Your other devices keep syncing; they'll ask for the new one the next time
they need a passphrase. The old passphrase now opens nothing for anyone who never used it.*

### Regenerate twelve words
Title: *New twelve words.*
Body: *Your current words will stop working the moment the new ones are confirmed. Write the new ones down
first.* Checkbox (PROVISIONAL (q)): *Also replace my keys — choose this if someone may have USED the old words, or
has a copy of your library.* Same authorization as change passphrase. Then 2a's Screens 3/3b.

### Replace All Keys (PROVISIONAL (q) — recommended; built at her word; the standalone "new library key" door is gone)
Title: *Replace all your keys.*
Body: *Use this if someone may have used your passphrase or twelve words, or has a copy of your library or a
backup. Your sync gets a new master key and a new corpus key, everything on the server is re-encrypted from this
Mac, and this library gets a new key. Your other devices will each ask for your passphrase once, then give their own
libraries new keys. Your passphrase and twelve words stay the same unless you change them below. Old backups keep
their old keys and open exactly as they do now.*
Checkbox: *Also choose a new passphrase*
Authorization: Castle — Touch ID or the passphrase. Standard — the passphrase if set, else a plain confirm.
Button: *Replace Keys* · progress line: *Re-encrypting your library on the server… (N of M)*
Done: *Done. Your other devices will ask for your passphrase the next time they open.*

### Sign out
Title: *Sign out of this Mac?*
Body: *This Mac stays signed out of sync until you sign in again. Your library and its keys stay on this Mac.
To stop another device from syncing, use Sign Out Everywhere from a device you trust. To give this Mac away,
delete the library too.*
Button: *Sign Out*

### Sign out everywhere
Title: *Sign out everywhere?*
Body: *Every device signed into your account is signed out, including this one. Use this if you think
someone has your account password. Then change it. Your libraries and keys on your devices aren't touched.*
Button: *Sign Out Everywhere*

### Delete account
Title: *Delete your Stargazing account?*
Body: *Your account, its sync copy on our server, and its keys are deleted. Nothing on this Mac or your
other devices is touched — every library stays, and still opens exactly as it does today. You can set sync
up again later under a new account; your library will upload to it.*
Re-authentication: *Enter your account password to continue.*
Typed phrase: *Type DELETE MY ACCOUNT to confirm.*
Button: *Delete Account*

### Export a decrypted copy (the plaintext `.sqlite`)
Title: *Export an unencrypted copy of your library.*
Body: *This writes your whole library as a plain, unencrypted database file, readable by anyone who has it,
anywhere you put it. Variorum never does this on its own. Choose where it goes and treat it like the
writing itself.*
Authorization: Castle — *Enter your passphrase.* Standard — the passphrase if set, else *Export* directly.
Button: *Choose Where…*

---

## 5. NOTICES AND ONE-TIME PROMPTS

**Passphrase changed elsewhere (post-unlock, device opened by Touch ID):** *Your passphrase was changed on
another device. Enter the new one to update this Mac.* Doors: *Enter…* · *Later* (sub-line: *Until then,
Touch ID keeps working here.*)
**Account moved to Castle (a device that was Standard):** *Your account is now in Castle — set on [device] on
[day]. From now on this Mac asks for Touch ID to open your library, with your passphrase as the fallback.*
Button: *OK* — **superseded by (m), RULED — the notice is:** *…with your passphrase as the fallback. Enter your passphrase once to pick up your
new sync keys: they were replaced when Castle was entered, and only your passphrase or twelve words open them.*
Doors: *Enter Passphrase…* · *Use Twelve Words…* · *Later* (sub-line: *Until then this Mac opens and reads, but
doesn't sync.*)
**Account moved to Standard (a device that was Castle):** *Your account is back in Standard — set on [device]
on [day]. This Mac opens silently again; your Apple account holds a key.* Button: *OK*
**The nudge — covered:** *At least one real way back into your writing exists beyond this Mac.*
**The nudge — exposed (Standard, no Apple key landed, no secrets):** Headline *Right now, only this Mac can
open your work.* Body: *Your Apple account hasn't been able to take a key yet, no passphrase is set and no
twelve words are written down — so if this Mac is lost or broken, your writing goes with it. Two minutes
fixes that: turn on iCloud Keychain, or set a passphrase (your twelve words appear on the same screen).*
**The nudge — unknown:** *Whether a spare way in exists can't be told right now — this library's key file
exists but can't be read. That is a fact about this check, not about your writing: whatever opened the
library still does.*
**Recovery phrase copied:** *Copied. Your clipboard clears in 60 seconds.*
**The enrolled-finger line (Castle, Touch ID mode, under the switch):** *Any fingerprint enrolled on your
Mac account can unlock with Touch ID.*

---

## 6. SETTINGS ▸ BACKUPS

**Standard sentence:** *A backup opens through your Apple account — or with your passphrase or twelve words.*
**Castle sentence:** *A backup opens with your twelve words — always, unless you regenerated them — or with
the passphrase you had when it was made. Backups made while you were in Standard also open through your Apple
account. Backups run while your library is open.*
**Lock-time copy line (Castle, if built):** *When you lock, Variorum also keeps a sealed copy of the library
as it was — checked the next time you unlock.*
**The iCloud Drive offer (once, at the first backup run):** Title *Keep a copy of your backups in iCloud
Drive?* Body: *Variorum keeps backups beside your library, on this Mac. A copy in iCloud Drive survives the
Mac.* Standard addendum: *Your Apple account then holds both the key and the writing.* Castle addendum:
*Backups are encrypted; the copy is safe anywhere.* Buttons: *Use iCloud Drive* · *Choose Another Folder…* ·
*Not Now*
**Why the live library can't live in iCloud Drive (the FAQ, and the folder picker's refusal if someone points
it at the library):** *Your working library stays on this Mac. iCloud Drive syncs files while they're being
written, which can corrupt a live database — backups are complete, sealed copies, which is what a synced
folder is good at. To have your writing on every device, use sync.*

---

## 7. THE TUTORIAL — "Keeping it private" (the SHORT chapter; her 09-04 direction — the full story is the Encryption book, §7b)

**Lesson 1 — What's true in every mode**
*Your library is encrypted on disk: the file Variorum writes is unreadable without its key — to Finder, to
Terminal, to a backup drive, to anyone who copies it. Sync is end-to-end encrypted: everything is encrypted on your
device before it leaves, and the Variorum server stores what it can never read. Both modes are like this. What
differs between them is only who holds a key.*
*Your account password signs you in and can delete your account. It never touches your keys.*
*And one thing no setting changes: while Variorum is open and unlocked, everything in it is readable — that is
what open means. Locking is how you end that.*

**Lesson 2 — Standard and Castle: what you must keep**
*Standard is the default. Your Apple account holds a key. Keep: your Apple account, and — if you use sync — your
passphrase and twelve words, in case your Apple account is ever gone. Anyone who can open Variorum as you, at your
unlocked Mac or fully inside your Apple account, can read.*
*Castle means only you hold the keys. Keep: your passphrase and your twelve words. Touch ID opens this Mac for you;
your passphrase is what lets a new device in. Lose every enrolled device and both secrets, and your writing is gone
— nobody can help. That is the point.*
*The whole story — every key, where it lives, what happens when you switch, why an old backup behaves the way it
does — is in the book "Encryption Explained" on this shelf.*
(The walk asserts the chapter names both modes, both floors, keystone 3 and keystone 4, and the book's door.)

---

## 7b. THE ENCRYPTION BOOK — "Encryption Explained" (a seeded book in Home beside the tutorial; her 09-04 direction; title RULED; 13s re-voices; every FACT binding)

**Register rule for this book and the FAQ:** plain credential words, each defined the first time it appears:
*encrypted* (scrambled so that only a key unscrambles it) · *key* (a long random number) · *wrapped* (a key that
has itself been encrypted under another key or under your passphrase, so the wrapped copy is useless without what
wraps it) · *the library key* · *the master key* · *the corpus key* · *the iCloud key* · *your passphrase* · *your
twelve words* · *the key file*. Never: box, vault, escrow, KDF, token, session, RLS.
(The master and corpus-key rotation at the switch — §16 (m)/(m-corpus) — are RULED; the [m] marks are gone.)

**Chapter 1 — What is encrypted, and with what**
*Your library is one file. Every page of it is encrypted with AES-256 under the library key — a random 256-bit
number — and every page carries a check, so a tampered page is noticed. Without the library key the file is noise:
to Finder, to Terminal, to Time Machine, to anyone who copies it.*
*Sync is end-to-end encrypted in both modes. Before any text leaves your device it is encrypted with AES-256-GCM
under the corpus key, which only your devices ever hold. The server stores and passes along what it cannot read.
What it can see is the shape: that a note exists, when it changed, roughly how much, and how things are ordered —
never a word of it.*
*Your passphrase is never stored anywhere. It is stretched with Argon2id (64 MB of memory, three passes — about a
second on a Mac) into a key, and that key wraps other keys. Anyone guessing your passphrase against a stolen copy
pays that second per guess, which is why we ask for twelve characters or more.*
*Your twelve words are a random key written out as words (128 bits — the same standard hardware wallets use).
They wrap exactly what your passphrase wraps, so either one opens the same doors.*

**Chapter 2 — The keys, and where each one lives**
*The library key. One per library file — your Mac's library and your iPhone's library have different ones. The
raw key sits in the device's Keychain: in Standard it is handed to Variorum silently once you have logged in; in
Castle it is held by the Mac's security chip and released only to your fingerprint, or kept nowhere at all if you
choose Always ask. Beside the library sits the key file, a small text file holding the library key wrapped several
ways: under your passphrase, under your twelve words, under the master key, and — in Standard only — under the
iCloud key. Anyone can read the key file; it gives them nothing without one of those.*
*The master key. One per account, made when you turn on sync. It lives inside every library that has joined your
account, protected by that library's own encryption, and on our server only in wrapped form: under your passphrase,
under your twelve words, and — in Standard only — under the iCloud key. The corpus key, which encrypts what leaves
your device, is wrapped under the master key. Holding the master key is what earns the right to sync at all: the
server asks every device to prove it holds it before it will accept or hand over a single row.*
*The iCloud key. A random key that Variorum places in your iCloud Keychain the first time a Standard library exists
on your Apple account. It syncs to every device signed into your iCloud, Apple's end-to-end encryption protects it in
transit, and Apple's account recovery can reach it. By itself it opens nothing: it is only ever what a Standard
wrapped copy is wrapped under. Castle leaves it where it is, with nothing current wrapped under it.*
*Your account password. It signs you in and can delete your account. It wraps nothing and opens nothing.*

**Chapter 3 — Standard, step by step**
*The first time Variorum opens, it makes a library key and a key file, places an iCloud key in your iCloud Keychain
if one isn't there, and writes a copy of the library key wrapped under it into the key file. From then on your Mac
opens the library silently, and any Mac signed into your iCloud can open a copy of it with nothing typed.*
*Turning on sync asks for a passphrase and shows you twelve words. It makes the master key and the corpus key,
sends the master key to our server wrapped three ways — under your passphrase, under your twelve words, under your
iCloud key — and keeps the raw master key inside your library. A new Apple device signs into Variorum, reads the
iCloud key, unwraps the master key, and has everything: nothing typed.*
*So in Standard: anyone fully inside your Apple account can open your library and your sync. Anyone at your unlocked
Mac can too, because your Mac opens it silently. That is Standard's trade, and it is the same trade Apple Notes
makes.*

**Chapter 4 — Castle, step by step**
*Entering Castle does four things. Your library is re-encrypted under a brand-new library key, and the new key file
wraps it under your passphrase, your twelve words and the master key only — never under the iCloud key. Your
sync gets a new master key too, sent to the server wrapped only under your passphrase and twelve words; the old
master key stops being accepted. And a new corpus key: everything on the server is re-encrypted under it
from your Mac, so nothing written after today is ever under a key an old copy holds. The copy of the library key your Mac keeps moves behind Touch ID — held by the
security chip, released to your fingerprint, never to your login password — or is kept nowhere if you choose
Always ask. And your other devices follow: each re-encrypts its own library the same way and asks for your
passphrase once to pick up the new sync keys.*
*After that, three things can open your library: your passphrase, your twelve words, or a device you already
enrolled, through its fingerprint. Nothing in iCloud can. Nothing on our server can. Your Mac's login password can't.
And nothing can be reset: there is no key anyone else holds. That is the floor, and it is what makes Castle real.*

**Chapter 5 — Backups, and why an old one behaves the way it does**
*A backup is a sealed copy of your library file plus its key file as they were that day. It opens with whatever
that key file's wrapped copies open under: the passphrase you had then, your twelve words, and — if you were in
Standard — your iCloud key. Variorum never changes a backup after it makes it.*
*Why your iCloud key can still open an old backup after you moved to Castle, but not your library: the old key
file holds the old library key wrapped under the iCloud key. Your library now has a new key that was never wrapped
that way. The old copy is exactly as private as it was on the day it was made — no more.*
*Why opening that old backup does not bring sync back: the old backup holds the old master key inside it.
Entering Castle replaced it. The server accepts only the new one, and the new one is wrapped only under your
passphrase and twelve words. Signing in with your account password gets you a session, not a key — and a device
holding the old master key cannot change your passphrase either, because the server refuses it before it can touch
anything.*
*So if you are in Castle, have lost your passphrase and twelve words, and have no enrolled device left: an old
Standard backup opened through your Apple account gives you back what you wrote up to that day. To sync again you
delete your Stargazing account and set sync up fresh from that copy. Whatever you wrote after the backup, and kept
only on the server, is gone. That is Castle's floor, met from the other side.*
*This is why entering Castle offers to delete the backups Variorum made before that day, and why it tells you
about Time Machine and copies you made: those still open the old way, and only you can remove them.*

**Chapter 6 — Changing things**
*Changing your passphrase re-wraps the same keys under the new word. The library key, the master key, your twelve
words and sync are untouched; your other devices ask for the new passphrase the next time they need one. Old
backups keep the passphrase of their day — on the Mac they were made on, the current passphrase still opens them
as long as the library key hasn't changed, because the key file beside your library pairs with them.*
*Regenerating your twelve words re-wraps the same keys under new words; the old words stop working the moment the
new ones are confirmed.*
*Replacing all your keys (Settings ▸ Encryption) is the heavy act: a new master key, a new corpus key with everything
on the server re-encrypted under it, and a new library key on each of your devices as they follow — each asks for
your passphrase once. Your passphrase and twelve words stay unless you change them too. Use it when someone may have
USED a secret of yours, or holds a copy of a library or a backup: a changed passphrase stops someone who only saw
it, but a copy of your library carries the keys inside it, and only new keys leave that copy behind. Entering Castle
runs this same act for you.*
*Switching to Standard wraps the library key and the master key under your iCloud key again. Switching to Castle is
Chapter 4.*
*Deleting your account and setting sync up again is the one act that replaces everything: a new master key, a new
corpus key, and your library uploaded fresh. Your libraries on your devices are never touched by it.*

**Chapter 7 — Who can read what**
*The Variorum server: never, in either mode. Apple: in Standard, whoever is fully inside your Apple account can
open your library and your sync; in Castle, nobody through Apple. Your Mac's login password: in Standard, anyone who
can log in as you can open Variorum and read; in Castle, no. Someone holding your passphrase or twelve words: yes,
in either mode — those are the keys. Someone at your Mac while Variorum is open and unlocked: yes, in either mode —
that is what open means.*
*If your passphrase or twelve words were only seen, and nobody has a copy of your library, change or regenerate
them. If someone may have used them, or holds a copy of a library or a backup, or had one of your devices unlocked,
replace all your keys. If your account password leaked, sign out everywhere and change it. If your account itself
may be in someone else's hands, delete it and set sync up again.*

**Chapter 8 — What we can and cannot do for you**
*We cannot read your writing, in either mode. We cannot reset a Castle passphrase — a reset would be a key we
hold. We cannot recover your writing if you are in Castle and lose every enrolled device and both secrets. We can
see when your devices sync and how much; we cannot see what. We can delete your account on your word, and we can
sign your other devices out on your word. Everything else is yours.*
---

## 8. THE HELP GUIDE / WEBSITE FAQ (for the stargazing.tech agent; detail the tutorial deliberately leaves out)

- **I forgot my passphrase.** *Any device that opens your library can set a new one: Settings ▸ Encryption ▸
  Change Passphrase ▸ Forgot. In Castle that takes Touch ID or your twelve words. If no device opens and you
  have neither secret, Standard's Apple account still opens your library; Castle has no way back — by design.*
- **Moving to a new Mac.** *Standard: sign into iCloud and Variorum; with sync on, everything arrives;
  without sync, open a copy of your library from your backup folder. Castle: sign in and type your passphrase
  or twelve words once; without sync, open a backup and type them.*
- **Restoring a backup.** *A backup folder holds sealed copies and a key file. Open a copy through File ▸
  Open Library; it opens the same way your library does — through your Apple account in Standard, with your
  passphrase or twelve words in Castle. Old copies open with the passphrase you had when they were made, or
  your twelve words — and, on the Mac your library lives on, a backup of that same library also opens with your
  current passphrase.*
- **Deleting my account and starting over.** *Deleting removes the server copy and the account's keys; your
  libraries stay on your devices and still open. Create a new account and turn on sync; the library moves to
  it and uploads. Your other devices join the new account the usual way.*
- **What can Apple see? What can Variorum see?** *Variorum's server: never your writing, in either mode. Apple:
  in Standard, iCloud Keychain holds a key to your library — protected by Apple's end-to-end encryption and
  reachable through Apple's account recovery; in Castle, nothing. With Touch ID on in Castle, this device's security
  chip holds a copy of the key for your fingerprint alone — Apple's servers and your Apple account never do.*
- **Why is there no "reset"?** *Because a reset would be a key we hold. In Castle nobody holds one but you.
  In Standard your Apple account is the reset.*
- **Someone knows my account password.** *Settings ▸ Account ▸ Sign Out Everywhere, then change it. They
  could never read your writing with it, and after that they can't sign in either.*
- **My twelve words were seen.** *Settings ▸ Encryption ▸ Regenerate Twelve Words. The old ones stop
  working the moment the new ones are confirmed — for anyone who never used them. If they may have been used, or
  whoever saw them could also have a copy of your library or a backup, tick "Also replace my keys".*
- **I switched to Castle. Are my old backups protected?** *No. A backup made while you were in Standard still opens
  through your Apple account, and always will. Delete the ones you don't want, Time Machine included. Backups made
  after the switch are under Castle's key.*
- **Someone may hold my keys themselves.** *Settings ▸ Encryption ▸ Replace All Keys: a new master key, a new corpus
  key, the server re-encrypted, and each device gives its library a new key as it follows. Nothing is lost and your
  account stays. If your ACCOUNT itself may be in someone else's hands, delete it and set sync up again instead.*
- **I moved to Castle, lost my passphrase and twelve words, and have an old backup and my iCloud.** *That backup
  opens through your Apple account, because it was made in Standard — you get back everything up to that day.
  Sync will not come back from it: entering Castle replaced your sync keys, and the new ones open only with your
  passphrase or twelve words. Delete your Stargazing account and set sync up again from that copy. Anything written
  after the backup and kept only on the server is gone — that is Castle's floor.*
- **Someone has my old backups and my Apple account — and I've since moved to Castle.** *They can open those
  backups: what you wrote before the switch, as it was then. Nothing more. Your library and your sync have new keys
  that were never wrapped for your Apple account, and the server refuses the old ones. If they also have your
  account password they can delete your account or sign you out — loud, and every copy on your devices survives —
  so change that password and use Sign Out Everywhere.*
- **Does Castle on my Mac make my iPhone Castle?** *Once sync is on, yes — Castle belongs to your account and every
  device follows. Before sync, each library has its own mode; your iPhone learns the account's mode when it joins.*

---

## 9. HER MIGRATION'S ONE-TIME MESSAGES (Mac + phone, once each)

- *Variorum now keeps your sync keys inside your encrypted library, and your account is in Castle. Nothing
  else changed. Confirm your passphrase once to finish.* Button: *Confirm…* · *Later*
- After confirm: *Done. This device opens with Touch ID; your passphrase and twelve words are your other
  ways in.*

## 10. THE PRIVACY-POLICY BRIEF LINES (for re-issue; facts only)
Two postures; the plaintext export is the one deliberate escape; the server holds ciphertext and sealed
keys it cannot open; a signed-in session without the encryption keys can neither read nor write the sync
copy (the key-proof token); the disclosure envelope: ids, dates, positions, kinds, sizes, write cadence,
and — new — nothing at all to a session that lacks the keys.
