# pre-13x — THE USER-FACING TEXT (every string the phase renders; written 2026-09-03 at her instruction)

**Status:** the author's instruction at the kickoff sitting: *"You can choose the ceremony words for now & it'll
also be your job to update the settings + the tutorial with the utmost clarity on all of these facts… I do
want you to write all the user facing text that's required now though and I'll handle copy changes later."*
This file is that text. **Render, don't re-derive:** the batches copy these strings verbatim (placeholder
VOICE with honest CONTENT — 13s re-voices later; the FACTS in every sentence are binding and come from
`notes/plans/pre-13x-postures-design.md` §2–§8; that file is the settled design; its history is `pre-13x-design-history.md`). Where a sentence differs between platforms, the device
words ride the standing interpolation (`Mac` / `iPhone`, `Touch ID` / `Face ID`, `login password` /
`passcode`).

**Vocabulary — TWO REGISTERS (the plain-credential legend is the standard for talking to users, with a brief
explanation of technical terms where needed).** *Everyday surfaces* (settings, ceremonies, notices,
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
If the library already has twelve words (a Castle library turning on sync): Title *Your library already has twelve
words.* Body: *Type them to use the same twelve for sync, or generate new ones — the new ones replace the old
everywhere.* Buttons: *Type My Words…* (→ Screen 3b) · *Generate New Ones* (→ Screen 3). Otherwise:
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
**Screen 2 — the passphrase (always):** none set → 2a's Screen 2, title *Castle needs a passphrase.* One set → Title
*Enter your passphrase.* Body: *Castle gives your library and your sync new keys, wrapped under your passphrase — so it
has to be typed here.* Field: Passphrase. Wrong: *That isn't your account's passphrase.* (No forgot road on this
screen — Change Passphrase, with Touch ID, comes first.)
**Screen 3 — the twelve words (always):** none yet → 2a's Screens 3/3b. Some exist → Title *Your twelve words.* Body:
*Castle gives your library and your sync new keys, and your twelve words must open them too. Type the twelve you
have — or generate new ones, which replace the old everywhere.* Buttons: *Type My Words…* (→ 2a's Screen 3b) ·
*Generate New Ones* (→ 2a's Screen 3).
**Screen 4 — the floor, said once**
Title: *Read this once.*
Body: *In Castle, nobody can help you if you forget your passphrase and lose your twelve words while no
enrolled device is left. Not Apple. Not us. There is no reset. That is what makes Castle real — and it's
why the words go on paper.*
Checkbox: *I know my passphrase, and my twelve words are written down.*
Confirmation: the passphrase typed at Screen 2 (checked against your account's copy) — Touch ID cannot make the new
keys.
Button: *Enter Castle*
**During:** *Re-encrypting your library on the server… (N of M)* — then *Giving your library a new key…* — under an
ORIGINAL animated indicator with movement (a line with a few black dots travelling back and forth, or of that family;
never the system spinner).
**If the scheduled plaintext export was on:** *Your weekly unencrypted Markdown export is now off — it would have kept
writing readable copies of your library to disk. You can turn it back on in Backups; Castle will warn you there.*
**Done:** *You're in Castle. Your library has a new key that your Apple account never held. A fresh backup was made
under it. This Mac asks for Touch ID from now on; your other devices will ask the next time they open.*
**Then, once — the offer:** Title *Delete the backups Variorum made before today?* Body: *They still open through
your Apple account, and they always will. Deleting them closes that door for what they hold. Variorum can only
delete its own backups — Time Machine, copies you made, and anything outside Variorum's folders aren't touched and
still open the old way. If your backups are in iCloud Drive, iCloud keeps deleted files for 30 days in Recently
Deleted.* Buttons: *Delete Them* · *Keep Them*

**Done, when the fresh backup could NOT be made (drafted 2026-09-06 at the ladder's round 1, F2 — MAJOR-2, under her overnight mandate; PROVISIONAL; 13s re-voices):** *You're in Castle. A fresh backup could not be made just now — check your Backups folder; your earlier backups are untouched. This Mac asks for Touch ID from now on; your other devices will ask the next time they open.* (Rendered in place of the ordinary Done when step 6's snapshot run did not write — an unwritable Backups folder, a WAL that would not drain; NO delete offer follows, since there is no fresh pair beside the earlier ones. The ordinary Done's last sentence — the Touch ID / other-devices line — RETURNED at F2's adjudication, item 1 (it states a fact every Castle Done owes) and is rendered from F3 — `ProtectionCopy.enteredCastleWithoutFreshBackup`, pinned on both platforms.)
**Done on a device that keeps no backups (the PHONE — drafted 2026-09-06 at F2's adjudication, PROVISIONAL; the round-2 fix session renders it on `.notKept`; 13s re-voices):** *You're in Castle. Your library has a new key that your Apple account never held. This iPhone asks for Face ID from now on; your other devices will ask the next time they open.* (the device word and Face ID ride the interpolations; RENDERED at F3 — `ProtectionCopy.enteredCastleWithoutBackupClaim`, `castleDoneBody` on `FreshSnapshot.notKept`; pinned on both platforms)

**Done, when another device entered Castle first (the conflict-follow — drafted 2026-09-06 at 4b's adjudication under her overnight mandate; PROVISIONAL, ledger 61; 13s re-voices):** *Another device entered Castle first, so this Mac picked up that device's keys instead. The twelve words shown here are NOT your account's — the account's words are the ones written down on [device].* (*[device]* from the vault's self-reported device name, else *another device*; the device word rides the interpolation.)

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
**Standard, a different Apple ID than the one that turned on sync — or the same one under propagation lag (the client cannot tell the two apart; HEDGED 2026-09-06 at the ladder's round 1, F2 — MAJOR-3 (d), the orchestrator's PROVISIONAL line; 13s re-voices):** *This Mac's Apple account doesn't hold the key that set up sync — if it's the same Apple account, the key may still be arriving. Enter your passphrase or twelve words once to continue now; after that this Mac opens on its own.* ~~*This Mac's Apple account isn't the one that set up sync, so it can't hand over the key. Enter your passphrase or twelve words once; after that this Mac opens on its own.*~~ *(the shipped sentence, superseded: it asserted a different Apple account, which the code cannot know)*
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
upload to this account.* Button: *Connect…* **Connect's done line** *(drafted 2026-09-06 at 3a's adjudication — its
question 7; the copy had none; batch 4 renders it as `connectDoneBody`; 13s re-voices)*: *This library is connected
to this account, and everything in it is uploading now.*
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
**Signed in, and this account's sync keys don't open with your passphrase (a library that never synced meets a vault
it can't unwrap):** *This account's sync was set up with a passphrase this library doesn't know. If you set it up on
another device, enter that passphrase to join. If you didn't set it up, someone with your account password did:
delete the account and set sync up again.* Doors: *Enter Passphrase…* · *Use Twelve Words…* · *Delete Account…*
**Enrolled:** *Sync is on. This Mac keeps your sync keys in its own protected Keychain, beside your library's key.*
Line: keystone 3.
**Keys don't match (re-enroll):** *This account's keys changed since this Mac joined — or this library came
from another account. Enter your passphrase to connect it; everything here will upload.* ~~Standard addendum:
*Or wait a moment — your Apple account can hand over the key.*~~ *(PRECISED 2026-09-06 at 5a's adjudication — ledger 66: the addendum is RETIRED — her 2026-09-05 ruling has the Standard follow ask the passphrase once (`39c5b395`); this label's sentence conflated two states: the foreign-owner ADOPT road renders §3's Connect sentence, and the UN-FOLLOWED device's headline is* **This account's keys changed since this Mac joined. Enter your passphrase to pick up the new ones.** *— rendered at 5b on the keys-replaced section.)*
**Waiting for iCloud Keychain:** as 2d.

### Change passphrase
Title: *Change your encryption passphrase.*
Offline (enrolled): *Changing your passphrase updates your account's keys on the server, so it needs a connection.*
Lead: *For when you've forgotten it or want a different one. Your devices keep syncing; the new passphrase works on
them right away when they're online, and each stops taking the old one once you've used the new one there. Changing
your passphrase isn't a security measure — if someone else may have it, tick "Also replace my keys" below.*
Fields: Current passphrase · New passphrase · Confirm new
Link: *Forgot your current passphrase?*
- Standard forgot road: *This Mac holds your keys, so you can set a new passphrase now.* Button: *Set a New
  Passphrase*
- Castle forgot road, Touch ID mode: *Confirm with Touch ID to set a new passphrase.* Always-ask mode: no
  link (you typed it to get in); instead: *Use your twelve words instead.*
Checkbox: *Also replace my keys — choose this if someone may have USED the old passphrase, or had one of your
devices unlocked.*
Done: *Your passphrase is changed. Your other devices keep syncing and take the new passphrase right away; each
stops taking the old one once you've used the new one there.*

### Regenerate twelve words
Title: *New twelve words.*
Body: *Your current words stop opening your account the moment the new ones are confirmed; a device where you
haven't used the new words yet still takes the old ones until you do. Write the new ones down first.* Checkbox: *Also replace my keys — choose this if someone may have USED the old words, or had one
of your devices unlocked.* Same authorization as change passphrase. Then 2a's Screens 3/3b.

### Replace All Keys
Title: *Replace all your keys.*
Body: *Use this if someone may have used your passphrase or twelve words, or had one of your devices unlocked. A
copy of your library or a backup holds no keys, so it is never the reason on its own. Your sync gets a new master key
and a new corpus key, everything on the server is re-encrypted from this Mac, and this library gets a new key. Your
other devices will each ask for your passphrase once, then give their own libraries new keys. Your passphrase and
twelve words stay the same unless you change them below. Old backups keep their old keys: they still open with the
passphrase you had when they were made, with your twelve words (unless you regenerate them), and — if they were made
in Standard — through your Apple account; an enrolled device's master key no longer opens them, because that key is
replaced.* *(Precised 2026-09-06 at the successor's kickoff — ledger 50(a), her ruling: the master-copy road to a
pre-rotation backup closes with the rotation; the old sentence's "exactly as they do now" over-claimed it.)*
Standard addendum: *In Standard this doesn't shut out someone inside your Apple account — your Apple account holds a
key to the new keys too. For that, secure your Apple account with Apple's tools, or move to Castle.*
Still finishing (either door, any device): *A key replacement started on [device] on [day] is still finishing — N rows
to go. Any signed-in device that has picked up the new keys can finish it. Try again after.*
Apple key unreachable (Standard only — decision 30: the new master is re-wrapped under the SAME iCloud key, which must therefore be readable here and be the account's; never minted here, never another Apple account's; drafted 2026-09-06 at the ladder's round 1, F2 — MAJOR-3 (b), the orchestrator's PROVISIONAL line; 13s re-voices): *Your Apple account's key isn't reachable on this Mac right now — ~~wait a moment and try again, or enter your passphrase.~~ *(RE-DRAFTED 2026-09-06 at F2's adjudication — its question 3: the door already takes the passphrase, and waiting cannot help a different Apple ID's Mac; the round-2 fix session renders it):* **Your Apple account's key isn't reachable on this Mac. If this Mac is signed into the Apple account that set up sync, wait a moment and try again; if it isn't, run Replace All Keys from a Mac that is.*** (Refused AT THE DOOR since F3 — the round-2 ladder's MINOR-N4, decision 32's pattern: before any screen, so *Generate New Ones* can no longer show words for a ceremony that cannot begin — and by the runner's step-2 belt; RENDERED at F3 from `ProtectionCopy.replaceKeysAppleKeyUnreachable`, the article riding the device word — the phone reads *from an iPhone that is*; pinned on both platforms.)
Checkbox: *Also choose a new passphrase*
Entrances (one mechanism, four doors): this screen; the *"Also replace my keys"* checkbox on Change Passphrase and on
Regenerate Twelve Words; and entering Castle, which runs it for you.
Authorization, both postures: your passphrase typed (checked against your account's copy) and your twelve words typed
or regenerated (2b's Screen 3) — the new keys must be wrapped under both, and Touch ID can't do that. (Forgot the
passphrase? Change Passphrase first, with Touch ID.)
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

**Passphrase changed elsewhere (a dismissable banner at every open, until the new word has been used here):** *Your
passphrase was changed on [device] on [day]. Use the new one here when you can — this Mac still takes the old one until
you do.* Buttons: *Enter It Now…* · dismiss. The same for regenerated words — the full line, drafted 2026-09-06 at 4a's adjudication as the passphrase line's mirror (4a renders it; 13s re-voices): *Your twelve words were regenerated on
[device] on [day]. Use the new ones here when you can — this Mac still takes the old ones until you do.* On an Always-ask device: *Your passphrase was changed on [device] on [day]. The old one still
opens this Mac, but sync waits until you enter the new one here.* Button: *Enter It Now…*
**A retired passphrase at a key door (Change Passphrase's current-passphrase field, Replace All Keys, the posture
switches):** *That's a passphrase you've since changed. Enter the current one — or use Touch ID, or your twelve words.*
**Waiting for your passphrase (the persistent banner on a device that has not followed a rotation):** *Sync is paused
until you enter your passphrase once — your keys were replaced on [device] on [day].* Button: *Enter…* — and on every
key door meanwhile: *Pick up your new keys first — enter your passphrase.*
**Account moved to Castle (a device that was Standard):** *Your account is now in Castle — set on [device] on
[day]. From now on this Mac asks for Touch ID to open your library, with your passphrase as the fallback. Enter your
passphrase once to pick up your new sync keys: they were replaced when Castle was entered, and only your passphrase or
twelve words open them.* Doors: *Enter Passphrase…* · *Use Twelve Words…* · *Later* (sub-line: *Until then this Mac
opens and reads, but doesn't sync — and what you write meanwhile stays under the old key until you pick up the new
ones.*)
**Account in Castle, this device still opens the old way (the posture-mismatch follow, decision 35 — no keys were
replaced):** *Your account is in Castle, but this Mac still opens without asking. Enter your passphrase once to move
this Mac's key behind Touch ID and give your library a fresh key.* Doors: *Enter Passphrase…* · *Use Twelve Words…* ·
*Later* (sub-line: *Until then this Mac opens and reads as before — what you write meanwhile stays under the old key
until you enter your passphrase.*) *(Both Later sub-lines precised 2026-09-06 — ledger 50(b), her ruling: writing made
after Later sits under the OLD library key, Apple-openable on a Standard-shaped device, until the follow; the rendered
strings and their pins follow at batch 4.)*
**Keys replaced elsewhere (a device that has not followed yet):** *Your keys were replaced on [device] on [day]. Enter
your passphrase once to pick up the new ones.* Doors: the same three; the same sub-line.
**Account moved to Standard (a device that was Castle):** *Your account is back in Standard — set on [device]
on [day]. This Mac opens silently again; your Apple account holds a key.* Button: *OK*
**The nudge — covered:** *At least one real way back into your writing exists beyond this Mac — as far as this Mac
can tell. Your Apple account's key reaches your other devices only while iCloud Keychain is on.* (macOS cannot
tell whether iCloud Keychain is on; the sentence says what the Mac can know.)
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
**Lock-time copy line (Castle — BUILT at 2a, row 7; rendered at 5b, ledger 68):** *When you lock, Variorum also keeps a sealed copy of the library
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

## 7. THE TUTORIAL — "Keeping it private" (the SHORT chapter; the full story is the Encryption book, §7b)

**Lesson 1 — What's true in every mode**
*Your library is encrypted on disk: the file Variorum writes is unreadable without its key — to Finder, to
Terminal, to a backup drive, to anyone who copies it. Sync is end-to-end encrypted: everything is encrypted on your
device before it leaves, and the Variorum server stores what it can never read. Both modes are like this. What
differs between them is only who holds a key.*
*(SUPERSEDED 2026-10-13, VX-201/VX-204: the sync sentence now says what IS sealed and a new sentence names the shape the server sees — the live text is `ProtectionCopy.privacyLessonOneParagraphs` + `privacyServerSeesShapeSentence`; QUESTIONS #216 carries her approval state.)*
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

## 7b. THE ENCRYPTION BOOK — "Encryption Explained" (a seeded book in Home beside the tutorial; 13s re-voices; every FACT binding)

**Register rule for this book and the FAQ:** plain credential words, each defined the first time it appears:
*encrypted* (scrambled so that only a key unscrambles it) · *key* (a long random number) · *wrapped* (a key that
has itself been encrypted under another key or under your passphrase, so the wrapped copy is useless without what
wraps it) · *the library key* · *the master key* · *the corpus key* · *the iCloud key* · *your passphrase* · *your
twelve words* · *the key file*. Never: box, vault, escrow, KDF, token, session, RLS.

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
*The master key. One per account, made when you turn on sync. Each of your devices keeps it in its own protected
Keychain beside the library key — never inside the library file, so never inside any backup or copy of it — and on
our server only in wrapped form: under your passphrase,
under your twelve words, and — in Standard only — under the iCloud key. The corpus key, which encrypts what leaves
your device, is wrapped under the master key. Holding the master key is what earns the right to sync at all: the
server asks every device to prove it holds it before it will accept or hand over a single row.*
*The iCloud key. A random key that Variorum places in your iCloud Keychain the first time a Standard library exists
on your Apple account. It syncs to every device signed into your iCloud, Apple's end-to-end encryption protects it in
transit, and Apple's account recovery can reach it. By itself it opens nothing: it is only ever what a Standard
wrapped copy is wrapped under. Castle leaves it where it is, with nothing current wrapped under it. If one of your
devices is signed into a different Apple account, that device's own key file holds its library key wrapped under THAT
account's iCloud key too — so that Apple account can open that device's library file, though never your sync: the
master key's Apple-held copy is under the Apple account that turned sync on.* *(The last sentence added 2026-09-06 —
ledger 48, her ruling; 13s re-voices.)*
*Your account password. It signs you in and can delete your account. It wraps nothing and opens nothing.*

**Chapter 3 — Standard, step by step**
*The first time Variorum opens, it makes a library key and a key file, places an iCloud key in your iCloud Keychain
if one isn't there, and writes a copy of the library key wrapped under it into the key file. From then on your Mac
opens the library silently, and any Mac signed into your iCloud can open a copy of it with nothing typed.*
*Turning on sync asks for a passphrase and shows you twelve words. It makes the master key and the corpus key,
sends the master key to our server wrapped three ways — under your passphrase, under your twelve words, under your
iCloud key — and keeps the raw master key in this Mac's protected Keychain beside the library key, never in the
library file. A new Apple device signs into Variorum, reads the iCloud key, unwraps the master key, and has
everything: nothing typed.*
*So in Standard: anyone fully inside your Apple account can open your library and your sync. Anyone at your unlocked
Mac can too, because your Mac opens it silently. That is Standard's trade, and it is the same trade Apple Notes
makes.*

**Chapter 4 — Castle, step by step**
*Entering Castle does five things. Your library is re-encrypted under a brand-new library key, and the new key file
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
Standard — your iCloud key. Variorum never rewrites a backup after it makes it; old ones are pruned on a schedule.*
*Why your iCloud key can still open an old backup after you moved to Castle, but not your library: the old key
file holds the old library key wrapped under the iCloud key. Your library now has a new key that was never wrapped
that way. The old copy is exactly as private as it was on the day it was made — no more.*
*Why opening an old backup does not bring sync back on its own: a backup holds your writing and nothing else — no
sync keys. To sync again it has to join your account like any device: through your Apple account in Standard, with
your passphrase or twelve words in Castle. And entering Castle replaced the keys Standard could reach, so nothing an
old copy or an old Apple-account holder could have had opens anything new. Signing in with your account password gets
you a session, not a key.*
*So if you are in Castle, have lost your passphrase and twelve words, and have no enrolled device left: an old
Standard backup opened through your Apple account gives you back what you wrote up to that day. To sync again you
delete your Stargazing account and set sync up fresh from that copy. Whatever you wrote after the backup, and kept
only on the server, is gone. That is Castle's floor, met from the other side.*
*This is why entering Castle offers to delete the backups Variorum made before that day, and why it tells you
about Time Machine and copies you made: those still open the old way, and only you can remove them.*

**Chapter 6 — Changing things**
*Changing your passphrase is for when you've forgotten it or want a different one — not a security measure. It
re-wraps the same keys under the new word. The library key, the master key, your twelve
words and sync are untouched; the new passphrase works on your other devices right away when they're online, and
each stops taking the old one once you've used the new one there. If someone may have your passphrase, replace all
your keys instead. Old backups keep the passphrase of their day — on the Mac they were made on, the current passphrase still opens them
as long as the library key hasn't changed, because the key file beside your library pairs with them.*
*Regenerating your twelve words re-wraps the same keys under new words. The old words stop opening the server's
copy and this device the moment the new ones are confirmed; a device where you haven't used the new words yet still
takes the old ones until you do — the same as a passphrase change. If your words were seen, replace all your keys.*
*Replacing all your keys (Settings ▸ Encryption) is the heavy act: a new master key, a new corpus key with everything
on the server re-encrypted under it, and a new library key on each of your devices as they follow — each asks for
your passphrase once. Your passphrase and twelve words stay unless you change them too. Use it when someone may have
USED a secret of yours, or had one of your devices unlocked: a changed passphrase stops someone who only saw the
word; someone who already held your keys is stopped only by new keys. A copy of your library or a backup holds no
keys, so it is never the reason on its own. In Standard it does not shut out someone inside your Apple account: the
new master key is wrapped under your iCloud key again, and they hold that. For that case, secure your Apple account
with Apple's tools — or move to Castle, the one act that takes the Apple-account key away. Entering Castle runs this
same act for you.*
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
*If your passphrase or twelve words were only seen, change or regenerate them. If someone may have used them, or had
one of your devices unlocked, replace all your keys. If — in Standard — someone was inside your Apple account, secure
it with Apple's tools or move to Castle; replacing your keys alone does not shut them out there. If your account
password leaked, sign out everywhere and change it. If your account itself
may be in someone else's hands, delete it and set sync up again. The device named in a notice is the device's own word
for itself; the day is the server's — an act you didn't do is the sign, whatever the name says.*

**Chapter 8 — What we can and cannot do for you**
*We cannot read your writing, in either mode. We cannot reset a Castle passphrase — a reset would be a key we
hold. We cannot recover your writing if you are in Castle and lose every enrolled device and both secrets. We can
see when your devices sync and how much; we cannot see what. We can delete your account on your word, and we can
sign your other devices out on your word. Everything else is yours.*
*When a notice names the device that changed something, that name is what the device calls itself — the day is
ours. A name you don't recognize, or an act you didn't do under a name you do, is the sign to replace your keys.*
*(The last paragraph added 2026-09-06 — ledger 49, her ruling: `updated_by_device` is the writing client's own word;
13s re-voices.)*
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
  current passphrase. To sync it again it joins your account like any device: on its own through your Apple account
  in Standard; with your passphrase once in Castle.*
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
  opening the server's copy the moment the new ones are confirmed; a device where you haven't used the new words yet
  still takes the old ones until you do. If they may have been USED, tick "Also replace my keys".*
- **I switched to Castle. Are my old backups protected?** *No. A backup made while you were in Standard still opens
  through your Apple account, and always will. Delete the ones you don't want, Time Machine included. Backups made
  after the switch are under Castle's key.*
- **Someone may hold my keys themselves.** *Settings ▸ Encryption ▸ Replace All Keys: a new master key, a new corpus
  key, the server re-encrypted, and each device gives its library a new key as it follows. Nothing is lost and your
  account stays. If your ACCOUNT itself may be in someone else's hands, delete it and set sync up again instead.*
- **Someone was inside my Apple account, and I'm in Standard.** *Secure your Apple account first, with Apple's tools —
  change your Apple ID password and remove devices you don't recognize. Replace All Keys won't shut them out on its own
  in Standard: your Apple account holds a key to the new keys too. To put your writing beyond your Apple account's
  reach, enter Castle.*
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
- **I lost a device, or one was stolen.** *In this order: Settings ▸ Account ▸ Sign Out Everywhere, so the device can't
  sync; Settings ▸ Encryption ▸ Replace All Keys, so nothing it holds opens anything new; then change your account
  password. In Castle the writing on that device stays locked behind its Touch ID or your passphrase. In Standard,
  whoever can unlock that device can read what was on it — that is Standard's trade — and that device is signed into
  your Apple account, which holds a key, so also remove it from your Apple account (your Apple ID's device list, or
  Find My).*
- **My other device uses a different Apple ID.** *Sync still works — that device types your passphrase once to join,
  then opens on its own. The nothing-typed road is for devices signed into the Apple account that turned on sync. In
  Standard, that device's own library then also opens through the Apple account it is signed into.* *(The last sentence
  added 2026-09-06 — ledger 48.)*
- **Does Castle on my Mac make my iPhone Castle?** *Once sync is on, yes — Castle belongs to your account and every
  device follows. Before sync, each library has its own mode; your iPhone learns the account's mode when it joins.*
- **Can my library live in iCloud Drive?** *Your working library stays on this Mac. iCloud Drive syncs files while
  they're being written, which can corrupt a live database — backups are complete, sealed copies, which is what a
  synced folder is good at. To have your writing on every device, use sync.* *(Drafted 2026-09-06 at 5b — the entry
  §6's why-not sentence names as "the FAQ"; the sentence is §6's verbatim. Backups MAY live there: the offer at the
  first backup run, decision 24, built at 5b. The picker's refusal of the live library's own folder is 13x's — until
  then the sentence is advice.)*

*(A build-vs-copy note recorded 2026-09-06 at 5b, item 3 — NOT a rewrite of her entries: the *Moving to a new Mac*
and *Restoring a backup* entries name an in-app OPEN-A-COPY door — "open a copy of your library from your backup
folder", "open a backup", "File ▸ Open Library" — which is 13x's (`notes/FuturePhases.md`'s 13x row; design §18
ledger 5) and does not exist in the build. The road that exists is the restore recipe the app drops into every
backup folder as `RESTORE.md` (the runbook's §3 and §6: quit, move the current library aside, put the copy in its
place, open) — it ends where the entries say: the restored copy opens by its key file's roads and then enrolls. The
outbound FAQ brief flags those three sentences ⚠ NOT YET BUILT; the words are hers / 13s's.)*

---

## 9. HER MIGRATION'S ONE-TIME MESSAGES (Mac + phone, once each)

- *Variorum now keeps your sync keys in this Mac's own protected Keychain, beside your library's key — never in
  the library file — and your account is in Castle. Nothing else changed. Confirm your passphrase once to
  finish.* Button: *Confirm…* · *Later* (the device word rides the interpolation: *this iPhone's*)
- After confirm: *Done. This device opens with Touch ID; your passphrase and twelve words are your other
  ways in.*

## 10. THE PRIVACY-POLICY BRIEF LINES (for re-issue; facts only)
Two postures; the plaintext export is the one deliberate escape; the server holds ciphertext and sealed
keys it cannot open; a signed-in session without the encryption keys can neither read nor write the sync
copy (the key-proof token); the disclosure envelope: ids, dates, positions, kinds, sizes, write cadence,
and — new — nothing at all to a session that lacks the keys.

## 11. 13s RE-VOICES — the strings this file does not carry, listed for the voice pass (created at pre-13x batch 5a, 2026-09-06; every row is 13s's INPUT, not a batch's rewrite — the facts are binding, the words provisional)

**How to read the table:** *string* is what renders today (the device nouns ride the interpolation — `Mac` / `iPhone`, `Touch ID` / `Face ID`); *home* is the constant or the face; *why provisional* is what this file lacks or what the register rule says. A row marked **REGISTER** renders a word the vocabulary head forbids (*vault*) and is exempted by exact literal in the two-register pins (`CopyRegisterPinTests` on the Mac, `MobileCopyRegisterSweepTests` on the phone) — a re-voice that drops the word must drop its exemption line.

| string | home | why provisional |
|---|---|---|
| *Another device entered Castle first, so this Mac picked up that device's keys instead. The twelve words shown here are NOT your account's — the account's words are the ones written down on [device].* | `ProtectionCopy.enteredCastleAfterAnotherDevice(device:)` — the Castle ceremony's Done when the runner's road became the follow (ledger 61) | the orchestrator's PROVISIONAL draft (§2b), hers to ratify |
| *This account is in Standard, so this library will open silently from now on and your Apple account will hold a key to it. To keep only-you keys for the whole account, enter Castle instead — Settings ▸ Protection ▸ Use Castle…* · *Join* · *Cancel* | `ProtectionCopy.joinStandardConsent` / `joinDoor` / `joinCancelDoor` (the Encryption tab) | the consent for a Castle-born library joining a Standard account (ledger 46) — the orchestrator's words; §2d has none for this direction. *(SUPERSEDED 2026-10-13, VX-201/VX-110: de-capped + reworded — the live text is `ProtectionCopy.joinStandardConsent`; QUESTIONS #216.)* |
| *Sync isn't joined on this Mac.* · *Join This Account's Sync…* | `ProtectionCopy.joinLaterLine` / `joinReofferDoor` | after Cancel — a reading (3a) |
| *iCloud Keychain wouldn't hold the key on this Mac — nothing was set up. Turn on iCloud Keychain, or enter Castle first…* | `EncryptionSession.appleKeyRefusedAtSetup` | the refusal when a Standard library's Apple key cannot land at sync setup (3a's question 4) — no copy line |
| *Cancel* · *Join* · *Close* · *Continue* · *Done* · *Unlock* · *Enter* · *Turning on sync…* · *Checking…* · *Working…* · the words field's placeholder *The 12 words, separated by spaces* / *The 12 recovery words, separated by spaces* | the ceremonies' chrome (`SyncEnrollmentView`, `KeyDoorView`, the Mac `PostureSwitchSheet` / `FollowSheet`, the phone `MobilePostureSheets` / `MobileProtectionCeremonies`, both lobbies) | chrome words the copy names only where it names a door |
| *Your twelve words are needed to replace your keys — type them, or generate new ones.* | `PostureSwitchError.wordsRequired` | the runner's own refusal (ledger 44) — the doors ask for the words first, so it is never reached through them (3b) |
| *The new passphrase couldn't be set here — your keys were replaced; change the passphrase under Account & Encryption.* | `PostureSwitchModel` (the Replace All Keys checkbox's fallback) | a refusal the copy has no line for (3b) |
| *Your twelve words are replaced. The old ones no longer open your account.* | `ProtectionCopy.regenerateWordsDone` | §4's regenerate has no Done line |
| *That isn't your account password — nothing was deleted.* | `ProtectionCopy.deleteAccountWrongPassword` | §4's delete has no refusal line |
| *Not into Variorum's backups folder — an unencrypted copy beside the sealed ones would be the one anything in that folder could read. Choose somewhere else.* | `ProtectionCopy.exportPlaintextNotIntoBackups` | the picker's refusal (3b) — §4 says only *never into the backups folder* |
| *Dismiss* | `ProtectionCopy.changeDismissDoor` | §5 says *dismiss* (a gesture); the word is 4a's |
| *Unlocking…* · *Checking your account…* | `ProtectionCopy.lobbyPhaseLine` | the lobby's phase line (4a) — §3 has none |
| *Enter Passphrase…* when it asks nothing (the follow from the word just typed at the lobby) | `ProtectionCopy.followEnterDoor` (ledger 54) | the LABEL stays §5's while the door runs with no field — a reading; 13s may name it |
| (the change door has no Done line — the notice's disappearance is the feedback) | `PostureFollowModel`'s change variant | 4a's question 3, confirmed; a line if she wants one |
| *Your new keys are in place on this Mac, and sync is back on.* | `ProtectionCopy.followDoneBody` (the follow sheet's Done) | §5 has no follow Done line (2c) |
| *This library is connected to this account, and everything in it is uploading now.* | `ProtectionCopy.connectDoneBody` | drafted by the orchestrator at 3a's adjudication (§3) |
| Regenerate offline: *Changing your passphrase updates your account's keys on the server, so it needs a connection.* | `ProtectionCopy.changePassphraseOffline` at `KeyDoorModel(.regenerateWords)` | §4 gives regenerate no offline line — it speaks change-passphrase's (4b's question 7) |
| Replace All Keys / Use Castle / Use Standard offline: *Couldn't reach the server — check your connection and try again.* | the runner's transport wording (`PostureSwitchModel.message(for:)`) | §2b/§4 give the switches no offline line (4b's question 7) |
| **REGISTER** *The vault just changed on another device — nothing was overwritten. Try again from the current state.* | `EncryptionSession.message(for: .vaultRevisionConflict)` — the change door's conflict face (§7 step 5) | 14b's sentence; names the vault |
| **REGISTER** *That recovery phrase doesn't unlock this account's vault.* · *No encryption vault exists for this account yet — run setup first.* · *This account already has an encryption vault — enroll with its passphrase instead.* | `EncryptionSession.message(for:)` | 14b's sentences; each names the vault (the §2d/§4 faces that reach them: a wrong twelve words at enroll; a vault-less account; an account that already has one) |
| *Checking this account's encryption state…* · *This account's encryption was set up by a newer version of Variorum. Update the app to unlock sync.* · *Sync setup isn't available in this build.* | `EncryptionViews` (the tab's `.unknown` / `.newerFormat` / no-store-tie arms) | 14b-era arms the copy does not name |
| *Unlock sync on this device* · *Enter your encryption passphrase to unwrap this account's keys.* · *Use my recovery phrase instead* · *Unlock with Recovery Phrase* · *Back to passphrase entry* | `EncryptionViews.enrollmentSection` / `unlockRoads` — the GENERIC not-enrolled arm (no enroll facts in view, e.g. before the first reconcile) | §4's *this account's sync keys don't open with your passphrase* line names a CONDITION (a library with its own passphrase meeting a vault it cannot unwrap) the tab cannot tell from the plain not-yet-enrolled window, so the generic arm keeps 14b's words — recorded in the 5a record's QUESTIONS |
| *This account's encryption keys were replaced. Enter your passphrase to re-enroll.* · *The keys this device holds were replaced after it enrolled — sync stays paused until you re-enroll; nothing is lost while paused.* | `EncryptionViews.keysReplacedSection` (the headline; the no-controller arm) | §4's *Keys don't match (re-enroll)* sentence describes the ADOPT road (a foreign owner — rendered by `foreignOwnerSection` from §3), and its Standard addendum (*your Apple account can hand over the key*) describes no state the built code has: the un-followed device is asked once even in Standard (§5, her call) — recorded in QUESTIONS |
| *Step 4 of 4 — Your recovery phrase (required)* and the phrase-confirm section's lines (*1. Write the 12 words down…*, *2. Type them back…*, *Confirm — I Wrote It Down*, …) | `EncryptionViews.mandatoryPhraseSection` / `phraseConfirmSection` | a 14b-era vault with no recovery wrap (every vault born since 3a has one) |
| *Variorum is locked* · *Unlock with Touch ID* · *Unlock* · *Unlock with Recovery Phrase* · *Checking iCloud Keychain…* · *Touch ID didn't go through. Try again.* (the no-passphrase-road arm) | `StoreLockView` / `MobileStoreLockView` / `StoreLobby` | lobby chrome; §3 names the prompt, the roads and the failure with a passphrase road |
| *Passphrase & twelve words* · *Encryption passphrase — Set / Not set* · *Twelve words — On file / Not saved* · *Set a Passphrase…* / *Change Passphrase…* · *Change your passphrase or your twelve words under Account & Encryption.* · *The passphrase and the twelve words are the ways back into this library when this Mac's Keychain can't help. Nothing is sent anywhere; both work offline.* | `ProtectionPane.passphraseSection` (the Mac) / `MobileProtectionSheet` | the LOCAL-ONLY library's set/change door (3b: an enrolled library changes under Account & Encryption) — §1 does not name this section |
| *Set your encryption passphrase* · *Your recovery phrase* · *Twelve words that can unlock this library if everything else…* · *I've written them down* · *Your account already has a recovery phrase* · *Extend It to This Library* · *Skip* · *The passphrase is set.* | `PassphraseSetSheet` (Mac) / `MobileProtectionCeremonies` (phone) | the 13p set door's words (the local-only road) |
| *Remembering your secrets* · *Still remember your encryption passphrase?* · *You never type it day to day…* · *Check It…* · *Later* | `ProtectionPane.reminderSection` / `ProtectionCopy.reminderHeadline` / `reminderBody` | the reminder check (Castle, always on) — §1/§5 do not name it |
| *Ways back in — right now* · the checklist rows *This Mac* · *Encryption passphrase* · *Recovery phrase* · *iCloud key* + their notes | `ProtectionCopy.checklistRows` (the pane's live checklist, moved from the retired shapes brain at 5a) | names KEYS in chrome (the register rule says everyday surfaces name none) — 13s's to re-word or retire |
| *Your library is encrypted. Two minutes makes it recoverable.* · *Right now this Mac's Keychain holds the only key. Set an encryption passphrase…* · *Set a Passphrase…* · *Show My Recovery Phrase…* · *Later* | `ProtectionCopy.nudgeHeadline` / `nudgeBody` / the offers (the 13p two-offer nudge) | §5's nudge is the three-tier sentence; the two-offer face's words are 13p's |
| *Open silently (Keychain)* · *Ask for Touch ID* · *Ask for the passphrase* · the per-mode sentences | `ProtectionCopy.modeLabel` / `modeSentence` | 13p's at-open picker words — the picker is gone (2a); rendered nowhere in the posture era (two 13p pins read them); 13s retires or re-homes them |
| *You're in Standard.* · *Your Apple account holds a key again. Nothing else changed.* | `MobilePostureSheets` (the leave-Castle Done on the phone) | §2c has no Done line |
| *Keep Variorum open. If it quits, the switch/follow picks up where it stopped.* · *Nothing was changed.* · *Confirm with Touch ID* · *Set Passphrase* · *Cancel* | both platforms' switch and follow sheets | chrome; §2b names *During* lines only |
| *Restore “Encryption Explained”* · *“Encryption Explained” is already whole — it's on your shelf.* · *Restored “Encryption Explained” — N chapters came back.* | `CapabilityRegistry` / `ShellActions.restoreSeededBook` (the Mac's Help door for the seeded book, 5a) | the door's receipts, on Sherlock's shape |
| *A key replacement started on [device] on [day] is still finishing. Any signed-in device that has picked up the new keys can finish it. Try again after.* | `ProtectionCopy.rotationStillFinishing(device:day:)` | §4's line says **(the row count REMOVED 2026-09-06 at 5a's adjudication — ledger 65: the code has no count; an 18a candidate)**; the code has no count (see the 5a record's QUESTIONS) |

| *No folder was chosen, so nothing changed.* | `ProtectionCopy.iCloudOfferNoFolderPicked` — the iCloud Drive offer's sheet after a cancelled folder panel (iCloud Drive not on this Mac, or she backed out; the sheet stays, the mark unset — *Not Now* is the answer) | §6 gives the offer no line for a cancelled pick (pre-13x 5b, item 0(a)); a reading |
| *Use This Folder* (the plain picker's prompt) · the sheet's chrome | `ExportPanels.chooseFolder(prompt:directoryURL:)` / `ICloudDriveOfferSheet` | chrome (13l's prompt reused; the offer's three doors are §6's) |
| *Working…* (the animated indicator's accessibility label) | `TravellingDotsIndicator.accessibilityLabel` — every protection surface's busy state on both platforms (pre-13x 5b, item 1) | chrome; §2b names the indicator's shape, not its spoken label |
| *You're in Castle. A fresh backup could not be made just now — check your Backups folder; your earlier backups are untouched. This Mac asks for Touch ID from now on; your other devices will ask the next time they open.* | `ProtectionCopy.enteredCastleWithoutFreshBackup` — the Castle ceremony's Done when step 6's fresh snapshot did not write (the ladder's MAJOR-2, F2: no offer is made over the earlier backups); the device word and the biometry ride the interpolations | the F2 fix session's PROVISIONAL draft (§2b), the orchestrator's words, with the ordinary Done's tail RESTORED at F2's adjudication (item 1) and rendered at F3 |
| *You're in Castle. Your library has a new key that your Apple account never held. This iPhone asks for Face ID from now on; your other devices will ask the next time they open.* | `ProtectionCopy.enteredCastleWithoutBackupClaim` — `castleDoneBody` on `FreshSnapshot.notKept`: the Castle Done on a device that KEEPS NO BACKUPS (the phone — `AppServices.backup` is nil there), the ordinary Done without its backup sentence (F2's adjudication item 2, a condition-(vii) defect; rendered at F3) | the orchestrator's PROVISIONAL draft (§2b) |
| *This Mac's Apple account doesn't hold the key that set up sync — if it's the same Apple account, the key may still be arriving. Enter your passphrase or twelve words once to continue now; after that this Mac opens on its own.* | `ProtectionCopy.waitingDifferentAppleID` — the lobby's waiting state (`StoreLockView` / `MobileStoreLockView`) and the Encryption tab's enroll face (`EncryptionViews`) when iCloud Keychain holds a key that is not the one the vault's (or the key file's) copy is under (the ladder's MAJOR-3 (d), F2) | the orchestrator's PROVISIONAL hedge (§2d): the client cannot tell a different Apple account from the same one under propagation lag |
| *Your Apple account's key isn't reachable on this Mac. If this Mac is signed into the Apple account that set up sync, wait a moment and try again; if it isn't, run Replace All Keys from a Mac that is.* | `ProtectionCopy.replaceKeysAppleKeyUnreachable` — Replace All Keys under Standard refused when the account's iCloud key is not readable here or the one read is another Apple account's (decision 30's letter; the ladder's MAJOR-3 (b), F2) — AT THE DOOR since F3 (MINOR-N4) and by the runner's step-2 belt; the device word and its article ride the interpolations (the phone: *from an iPhone that is*) | the orchestrator's re-draft at F2's adjudication (item 3; the first draft's "or enter your passphrase" pointed at no door), PROVISIONAL (§4), rendered at F3 |
| *Getting your key from iCloud Keychain… This usually takes a moment and can take longer. You can also enter your passphrase or twelve words instead.* | `ProtectionCopy.nudgeSentence(for: .waiting)` — §2d's *Standard, waiting* title + body at NEW SITES: the Protection pane's checklist sentence, the notice bar's nudge (headline + body) and the unchosen indicator on the Mac, the phone's Protection sheet — while `ProtectionLegs.appleKeyWaiting` (the round-2 ladder's NIT-N8, F3: a device merely waiting for the account's iCloud key is not EXPOSED and is no longer told to write its words down as if unguarded); the two offers beside it stand | §2d's own lines, re-used; the placement is 13s's to re-voice |
| *The server is still settling a few rows written just before the switch. Nothing is lost — sync stays paused; finish from Settings ▸ Protection in a moment, and it picks up exactly where it stopped.* | `ProtectionCopy.rotationRowsStillSettling` — the ceremony's refusal when the server's completion guard refused the clearing write three times (the ladder's BLOCKER-1, F1: a row written a second before the switch still hidden from this device's pulls; the marker stays, the resume re-walks) | the F1 fix session's PROVISIONAL draft (2026-09-06) — the copy has no line for a completion the server refuses; §2b's resume body ("Entering Castle didn't finish…") is the nearest kin |

*(Not listed: every string that renders a copy line verbatim — those are pinned by `ProtectionCopyTests` / `MobilePhoneProtectionCopyTests` and need no re-voice beyond the file's own.)*
