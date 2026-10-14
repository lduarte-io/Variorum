# Castle, backups and restores — a second opinion

> **Where these decisions live now (2026-10-13).** This document numbers its decisions D1–D10. The binding design,
> `notes/plans/vx-266-castle-backups-prelaunch.md`, cites tickets only (her word). The trace:
> D1 → VX-209 · D2 → VX-263 · D3 → VX-301 (the old shared key's retirement reshaped after the first designer's review —
> design §3.5, PROVISIONAL) · D4 → withdrawn, recorded on VX-266 · D5 → VX-313 · D6 → VX-302 · D7 → VX-314 ·
> D8 → VX-265 / VX-210 · D9 → VX-212 · D10 → VX-266 (the phases).

**For:** VX-266 and its 17 tickets. **What this is:** an independent assessment of the design proposal
(`design-proposal.md` beside this file, as revised after its cold read), written 2026-10-13 at your request. It is not
a ruling: nothing is built and no ticket is changed by it.

Your ask, verbatim: *"evaluate this full output and system with fresh eyes … first independently and thoroughly
consider the problem with your own ideas. then … assess the proposed solution against what you have considered … if
something that we've already built is hamstringing our ability to come up with a truly elegant solution … you should
tell me."* Since then you've handed the design to me: *"the rest of how this design goes is fully in your hands."*

**How I worked.**

1. I read the 17 tickets and every comment, your #216 sitting, the original Castle design
   (`pre-13x-postures-design.md` §1–§7 and §14), the VX-191 audit, and the code where protection is decided and
   written.
2. I wrote my own diagnosis and design **before opening the proposal**. That record is
   `second-opinion-independent-notes.md`, committed as `c24a6c44`.
3. Only then did I read the proposal, its cold read and the dispositions.

Three helpers worked alongside me:

- **A map of the backup, restore and Open Library code,** built from scratch without reading the proposal's research:
  `second-opinion-research-backup-restore-open.md`. It reproduces the proposal's evidence and adds hazards.
- **Apple's documented Keychain, Touch ID and iCloud Keychain behaviour:** `second-opinion-apple-facts.md`. One of its
  facts changed this assessment's centre of gravity.
- **A fresh reviewer** who attacked this document: `second-opinion-cold-read.md`. It found no blocker, three major
  and six minor problems; each one is answered there and folded in below (§8).

---

> **Your rulings so far (2026-10-13, after reading this):**
>
> - **D3, retire the Apple key: yes** — now VX-301. Your words: *"going into castle means going into protection and I
>   agree with deleting the iCloud key when they go into castle"*. Losing older backups along with the passphrase,
>   words and Touch ID is acceptable *"so long as they're adequately warned about it. they can always export it as
>   plaintext."*
> - **D2, the key history under the current key: yes**, with the honest leave sentence — recorded on VX-263.
> - **Your principle:** *"in castle = safe. out of castle = not safe … we do not need to contort ourselves to fit a
>   halfway posture."*
> - **Your Keychain Access check confirmed the gap.** The dev scope's Apple key was revealed with the login password,
>   on the Pro and on the Air.
> - **D4 is withdrawn** — it's redundant now that D3 is ruled (§2.2).
> - **The cross-Mac backup bug** is ticketed as VX-302.
> - **A visual companion** with diagrams of every posture, how each key is locked, and how moving between postures
>   works: `castle-key-map.html` beside this file.
>
> D1 and D5–D10 are still yours to rule.

## The short version

**The proposal's design is right, and I'd build it.** Working from first principles before reading it, I reached the
same core:

- the mode is recorded, not guessed;
- opening a copy never lowers protection;
- older keys travel forward with the library;
- Keychain items are kept per key, not per library;
- one function decides and one component writes;
- long acts are written down outside the library file;
- the library knows its account;
- a generated scenario test is the proof.

Two independent designs converging is good evidence the shape is sound.

**But the most important thing I found isn't in the proposal, and it's a gap in Castle's own promise.**

- Castle promises that someone who knows your Mac's login password can't read your library. For the library itself
  that holds.
- For every copy made before you entered Castle — backups, older libraries, Time Machine — it very likely doesn't. The
  iCloud key that opens those copies is never deleted, and Apple's Keychain Access app can reveal it with nothing but
  the login password.
- I've confirmed this from Keychain Access's entitlements on this Mac and Apple's documentation, but not yet on
  Variorum's own item. One two-minute check by you settles it (below).
- Today's Castle screen says those copies "still open through your Apple account". It never says "and on this Mac,
  for anyone who knows its login password".
- Nothing in the proposal changes this. Neither does my "never open without asking" rule, because someone with the
  key in hand doesn't need Variorum at all.

**The fix is the one structural change I'd add: retire the Apple key when a library enters Castle (§3).**

- Each library, and each sync account, gets its own Apple key, named by its own id.
- When a library enters Castle, its key is deleted. iCloud Keychain then removes it from every device, with no
  recovery.
- At that moment, every copy Variorum ever made of the library stops opening through the Apple account — anywhere.
- For stores that exist today, yours included, a one-time question offers to retire today's shared key in the same
  way.

That replaces the "delete your old backups?" offer with two plain rules:

> **In Castle, your Apple account opens nothing of this library. In Standard, it opens your library and every copy
> Variorum made of it.**

The real cost is the way back. Your original design kept pre-Castle copies openable through the Apple account
deliberately, so that losing your passphrase, words and Touch ID would still leave you your older writing. That choice
is yours to remake.

**Four more changes to the proposal, in order of weight:**

1. **Plans and protection settings must be sealed, not just stored.**
   - A plan file planted beside the library could make the app finish a "leave Castle" you never chose.
   - An edited "Always ask" setting could make the app create a Touch ID item that a newly enrolled finger opens.
   - Keychain Access can edit keychain items as well as files, so sealing with a key derived from the library's key
     is the only protection. (§2.3)
2. **Backups must belong to a library and a Mac.** Today, retention counts every Variorum backup in a folder. The
   iCloud Drive offer opens its picker at iCloud Drive's root, so your Pro and your Air, if both accept it, share one
   folder and prune each other's history. (§2.4)
3. **Lock the key history under the library's current key, not a separate history key.**
   - This removes a key, and four states in which the history is only partly locked.
   - It makes every restore of your own library work with nothing typed.
   - It **re-accepts cold read 1's blocker as a stated trade**: after you leave Castle, your Apple account opens the
     copies Variorum kept while you were in Castle. For a synced library, today's protection after leaving already
     stops at "copies from before your last key replacement". (§2.1)
4. **A library this Mac remembers in Castle never opens without asking**, whatever file sits in its place. Without
   this, someone with the login password can swap an older backup into place and open a local-only Castle library with
   no Touch ID. It's defence in depth: it closes the no-tools route; §3 closes the rest. (§2.2)

**You asked what already-built things are holding the design back.** In order:

1. **The shared, never-deleted Apple key.** It's why Castle can't cover older copies, why the delete-your-backups
   offer exists, and why the login password reaches pre-Castle writing.
2. **The rule that the mode is "derived, never a setting".** It meant to prevent drift, but everything it reads is
   changed as a side effect elsewhere, so it drifts anyway.
3. **Keychain items named by library rather than by key.**
4. **Several key files beside a library, with "current" meaning "most recently modified".**
5. **Crash markers kept inside the library file.**
6. **"Enrolled" meaning "sync keys are on this Mac",** with new rows stamped by whoever happens to be signed in.
7. **Trusting anything stored on the Mac** — files or keychain items — to make a decision before unlock.

§4 has each with what to do. **Your decisions** are in §7, each with my recommendation. **One check needed your hands
(done 2026-10-13 — confirmed on the Pro and the Air):**

> 1. Open **Keychain Access** and search for `apple-key`.
> 2. Open the item whose **Account** is `Variorum-dev-apple-key` (the dev store's). It's probably listed as
>    `io.lduarte.Variorum.apple-key`. If only `Variorum-apple-key`, your real store's, is there, use that.
> 3. Tick **Show password** and enter your login password.
>
> If a value appears, the gap in the short version is confirmed; don't copy it anywhere. If the item isn't listed, or
> nothing is revealed, tell me — that's good news, and it lowers §3's urgency. About two minutes.

---

## 1. Where the two designs agree

| piece | my independent notes (before reading) | the proposal | verdict |
|---|---|---|---|
| Diagnosis | mode inferred from five inputs; one Keychain slot per library ID shared by every copy; readers that write; copies frozen with their day's roads; the "newest file" guess; markers inside the file; implicit account binding | the same five causes, with more evidence (churn, counts, 46 tickets in 13 patterns) | agree; my helper's independent map reproduces the mechanisms |
| Mode recorded | a protection record per library; custody is a consequence, never an input | a record inside the library file plus "what this device remembers" | agree; the in-file record is the better home (authenticated by the library's own encryption, travels with copies) |
| Never lowered by opening | a copy is brought under the current key and mode; only Leave Castle lowers | the same; a Castle copy from another Mac raises through Use Castle's steps | agree, plus §2.2's sharpening |
| Older keys travel forward | a history in the key file, under the current key | a history under a separate history key | **differ** — §2.1 |
| Custody per key | Keychain items named by key | the same, store variant in every name | agree |
| One decider, one writer | a pure `assess`, one executor | the same, with guards (decision 35 explicit, mint guards kept, nothing acts on a momentary reading) | agree |
| Acts written down outside the file | a journal outside the library with everything a resume needs | plans beside the library, excluded from backups, never holding a secret | agree, plus §2.3 (seal them) |
| Account binding | the record names the account; rows stamped by the binding | the same, with the four-row account table | agree |
| Proof | a generated scenario test with crash injection | the same, with what it can't reach named and real-Keychain drills kept as gates | agree, plus adversary actions (§5) |
| Size | — | one sitting, about five phases, a go/no-go after the headless core | agree (§6) |

---

## 2. What I would change in the proposal

### 2.1 The key history: lock it under the current library key, and say plainly what leaving Castle means

**What the proposal does** (its §3.2). A history key H opens the list of the library's older keys:

- H is wrapped under your passphrase and words only.
- It is kept in the Touch ID item while you're in Castle, and never kept on the device in Standard.
- It is replaced at every re-key, re-locking the whole history each time.

It exists because cold read 1's one blocker, B1, showed that a history reachable through the account master would,
after leaving Castle, hand Castle-era keys to anyone in your Apple account.

**What H costs.** A fourth kind of key, and four states where the history is only partly locked. The reviewer
confirmed all four.

- **A passphrase changed on another device.** A Standard or Always-ask device's key file still holds H under the
  *old* passphrase. When it later follows a key replacement, you type the *new* one, which can't open H. The history
  stops there unless you also type the words.
- **A follow takes one secret.** The new H gets one wrap; the other "lands the next time that secret is typed here".
- **Standard keeps no H on the device.** Every restore of an older-key backup asks for your passphrase or words, even
  on your own Mac with the library open.
- **H can only be made when a secret is typed.** The migration has to ask, and backups made before then carry a
  history nothing opens.

**The alternative.** Wrap every older key under the library's **current** key, in the key file and in every backup's
frozen copy of it.

- Whatever opens the library — Touch ID, the silent item, the passphrase, the words, the master, or the Apple key in
  Standard — opens its past.
- A re-key re-wraps the history with keys already in hand, so nothing is ever typed for the history's sake and no
  pending state exists.
- The chain runs backwards only, so **entering Castle is unaffected**: nothing Apple-reachable leads to anything
  written after the switch. Both cold reads confirm this.

**What it gives up — this re-accepts cold read 1's blocker B1, as a stated trade.** Exactly:

1. **After any road into Standard** — Use Standard, joining or moving to a Standard account, or a follow into
   Standard — the Apple account reaches the current key and, through the history, keys retired while the library was
   in Castle. So Castle-era copies under a key you replaced before leaving become Apple-openable.
2. **In Standard,** copies from the exposed era (made while no Apple copy had landed) become Apple-openable once the
   Apple key lands. That is Standard working as designed: they were Standard copies whose Apple copy never landed.
   A Standard Replace All Keys changes nothing here, because its older copies carry Apple wraps of their own
   (decision 30).

**What today's protection after leaving actually is.** Leaving Castle gives the Apple account the key you leave with.
For a synced library it also gives it the master: every key file carries a master copy, and leaving adds an Apple copy
of the master to the vault.

So today, and under the proposal's H, the Castle-era copies that stay sealed after leaving are only those under keys
retired before you left — in practice, copies from before your last Replace All Keys. That boundary is invisible to
users. Most people never replace their keys, so for them H protects nothing.

**The honest sentence for the leave screen** under my version: *"Leaving Castle gives your Apple account a key to
your library and to every copy Variorum keeps of it."* Under §3, the key you leave with is a fresh one, and the
sentence is the same.

**If you want Castle-era copies to stay sealed after leaving,** neither H nor my version does it fully. That needs a
re-key at leaving, plus a full master rotation for synced libraries. I don't recommend it: leaving Castle is a
deliberate choice to trust your Apple account with the library again.

**Recommendation:** history under the current key, with the honest leave sentence. It's your call, because it
re-accepts a reviewed blocker.

### 2.2 A library this Mac remembers in Castle never opens without asking

> **Withdrawn after your D3 ruling (2026-10-13).** Once entering Castle deletes the Apple key, every copy of a Castle
> library — wherever it is — opens only with Touch ID (through the history), the passphrase or the twelve words. So
> this rule has nothing left to stop.
>
> - **The one leftover case:** a store whose owner declines the one-time question about today's shared key. They
>   chose that, with the warning.
> - **Planted files and edited settings** are §2.3's job (sealing), not this rule's.
> - **Your question — the person who entered Castle, forgot everything, lost their writing and starts again.**
>   Nothing stops them. *Start a New Library* makes a new library with its own key and nothing of the old one. The old
>   library's copies stay unopenable, which is Castle's promise, said at the door. Variorum can later offer to clear
>   the old library's leftovers (its key item, its backups) once you confirm you can't open them.
>
> The original text follows, for the record.

**The gap.** Two places in the proposal accept a silent open first:

- §3.4: *"If what this device remembers says the library is in Castle but a road opened it without asking … the
  reconciler brings it into Castle straight away and says so."*
- §4: *"Someone puts an older, Apple-openable copy where your library was. It opens through the Apple road, as it would
  today; after unlock … the reconciler brings it into Castle at once."*

"Brings it into Castle" re-encrypts under the current key, which needs Touch ID or your passphrase. If the person at
the keyboard isn't you, they have read the copy by then.

**The attack, traced at HEAD for a local-only Castle library** (the reviewer confirmed it end to end):

1. Someone who knows the Mac's login password moves a pre-Castle backup pair into the library's place, with Finder.
2. They open Variorum. The route reads the old key file, sees an Apple copy and no silent item, and derives Standard
   (`StoreProtection.swift:101-109`).
3. It opens silently through the Apple key (`AppBootstrap.swift:350-357`). Today the key is then also re-saved
   silently (`:548-556`).

A **synced** Castle library is already defended at this route. Its sync keys are on the Mac, so the reading is
"indeterminate", the custody shape says Castle, and the Castle lobby appears (`StoreLaunchGate.swift:408`,
`StoreProtection.swift:91-93, 113-116`).

**The fix:**

- The never-lower rule is keyed by **library ID**, through what this device remembers, not by what sits at the
  location.
- Any file of a library this Mac remembers in Castle opens only after Touch ID or the passphrase — at the library's
  place, picked in Open Library, or picked from a fresh library after the container was deleted. Cold read m19
  already establishes that the keychain survives that deletion.
- After unlock, the history reaches the older key, and the copy is re-encrypted under the current key before anything
  shows.
- A *Forget this library on this Mac* door lets you abandon a library deliberately. It needs Touch ID or the
  passphrase, because forgetting lowers protection.

**What it doesn't stop.** Someone who reads the Apple key out of Keychain Access, then decrypts a backup with a short
script, never touches Variorum. They can also delete the "remembered" record in Keychain Access. So this rule closes
the no-tools route, and §3 closes the rest. It's still worth having, because it makes Variorum's own behaviour honest.

**Robustness to go with it:** what this device remembers keeps a mirror of the current key file's wrapped keys and
history, so a rolled-back or deleted key file never strands the library on this Mac. The cost is a second copy to keep
in step. The executor writes the key file and its mirror in one act, and the mirror is checked against the key file
at every ready.

### 2.3 Plans and protection settings are sealed

**The gap.** Plans live beside the library, hold facts but no secrets, and the reconciler resumes them after unlock
(the proposal's §3.5). Anything on the Mac can be written by someone with the login password. That includes keychain
items: Keychain Access holds a wildcard keychain entitlement and can presumably edit what it lists (Apple facts 1–2).

- **A planted plan** reading *Leave Castle, next step: add the Apple copy* would be resumed at your next unlock. The
  app would add the Apple wrap and move the key to the silent item: you'd be in Standard without having chosen it.
  The proposal's "a plan whose world doesn't match is ignored as stale" doesn't stop it, because the library ID and
  key fingerprints are public in every key file. The reviewer confirmed this against the proposal.
- **A protection setting** works the same way. Today the adoption (`LibraryOpenModel.swift:538`), the migration and
  the switch all write the Touch ID item from a stored setting. Flip "Always ask" to Touch ID, enroll a finger, and
  wait for your next passphrase unlock: the repair builds a Touch ID item that the new finger opens. The same goes for
  setting the idle lock to "never".

**The fix:**

- **Sealing.** Every plan, and every stored setting that could weaken protection (the gate style, the idle lock), is
  sealed with a key derived from the library key in hand when it is written, and names that key's fingerprint.
- **Verifying.** After unlock, the executor verifies the seal with that key, reaching it through the history if the
  plan's own act has re-keyed the library since. An Always-ask device verifies after the typed unlock and before any
  step runs.
- **On a bad seal:** an unsealed or mismatched plan is ignored and reported, and an unsealed setting reads as the
  stricter value. A plan that lowers protection also carries the record of the consent you gave at its door.
- **Before unlock, nothing on the Mac decides anything.** The lobby needn't know which key is current. It tries every
  road this device has for the library, and each road verifies itself, because a key that doesn't open the file opens
  nothing. That replaces the proposal's "the lobby reads the plan" (its m6(e) answer) and my draft's key-file field,
  which the reviewer rightly flagged.

### 2.4 Backups belong to a library and a Mac

**The hazard,** traced by my helper and confirmed by the reviewer:

- `StoreBackup.existingBackups` (`StoreBackup.swift:704-716`) lists every Variorum-named snapshot in a folder.
- `prune(keep:)` (`:609-615`) and the far folder's 14-daily-plus-4-weekly rule (`BackupRetention.swift:87-118`) count
  them all, whichever library or Mac made them.
- The iCloud Drive offer opens its picker at iCloud Drive's root (`ICloudDriveOffer.swift:101-106`), and backups land
  in `<pick>/Variorum/Backups`.

So two Macs on one Apple account that both accept the offer share a folder. Each Mac's retention deletes the other's
older backups, and a busy Mac can push a quiet Mac's history out entirely. That's your Pro and your Air.

**The fix:** the proposal's one catalog attributes every copy to its library (the pair's library ID) and to the Mac
that made it. Retention acts only on this Mac's copies of this library. A per-library subfolder inside the picked
folder is the simple way. Existing shared folders migrate by attribution, never by deletion.

The Castle offer may still list another Mac's copies of a *synced* library — they hold the same account's writing —
but it must say whose they are. Under §3 the offer mostly disappears.

**Other hazards from the map** that the proposal settles in substance but doesn't list; each needs a red-on-old pin
in its phase:

- **The Apple arm can change a library's identity.** `ensuredEnvelope` sets aside a key file that doesn't match and
  starts a new library ID (`ProtectionController.swift:1129-1142`).
- **A crash in adoption can leave a library with no key file.** Adoption lands the library before its key file
  (`LibraryAdoption.swift:295-304`), so a crash between the two leaves ciphertext and no recovery road. Pair and folder
  key-file writes are also best-effort `try?`.
- **The restore list promises roads it never checks.** "Your current passphrase (online)" is shown for copies made
  before the master was replaced, which it can't open (`LibraryOpenCopy.swift:114`).
- **The lock-time copy can carry the wrong name.** It is named from the located key file, not from the key its bytes
  are under (`StoreBackup.swift:648-655`).
- **Resume Sync can hide a hold that still stands.** It clears the banner even when removing the marker failed
  (`RestoreHoldModel.swift:85-89`).
- **Leftovers pile up.** `.stale-*` key files are never read or removed, and older libraries and safety copies only
  ever go through the Castle offer. Give older libraries a retention rule of their own.

### 2.5 Optional: secrets in custody, everything else in what the device remembers

The proposal keeps the device identity inside the sync-keys item, which is why Castle needs an "identity-only" silent
item beside the Touch ID one. Moving the identity into what the device remembers removes that item. Then custody holds
only secrets, and everything non-secret sits in one record.

This reverses the proposal's answer to cold read 1's m9, so it isn't free. It needs a migration leg that carries the
existing identity, or every device mints a new one and leaves an old cursor holding the purge horizon. It also needs a
guard against cloned identities: iOS Quick Start has been seen to carry this-device-only items to a new phone (Apple
fact 10), so re-mint the identity when the hardware changes. Worth doing if the open-road phase has room; not required.

---

## 3. The structural change: retire the Apple key when a library enters Castle

**Today:**

- There is one Apple key per Apple account, per store, named by the store alone (`AppleKeyCustody.swift:135`). Every
  library and every Variorum account on that Apple account shares it, and it is "never deleted in production" (`:189-190`).
- Entering Castle removes the copies under it from the live key file and the vault. Every older key file keeps its
  copy, so every backup, older library, Time Machine snapshot and iCloud Drive pair made before Castle stays openable
  through the Apple account.
- The Apple account here is broader than it sounds. It includes anyone who can add a device to your iCloud Keychain:
  the Apple account plus any trusted device's passcode, a recovery contact or a recovery key (Apple fact 4). It also
  very likely includes **anyone who knows this Mac's login password**, through Keychain Access (fact 1).
- That's why the Castle offer exists. VX-203 and VX-208 grew it in VX-201's run, and VX-210, VX-265, VX-263's offer
  wording and part of VX-209 follow from it.
- It's also why the VX-191 audit's server residual exists: the server's own backups of the old vault row, read with
  the Apple key, still open pre-Castle writing.

**The change:**

1. **Apple keys named by their own id.** Each local-only library and each sync account gets its own Apple key, named
   by its id: `<scope>-apple-key-<id>`, with the store variant kept. The vault already records which key its Apple copy
   is under (`apple_key_id`), and so does a library's key file (`appleKeyID`).
2. **One minter.** Only the device that makes an account or library Standard mints its key: sync setup in Standard,
   leaving Castle, a fresh local library. Any other device that can't read that key waits. Not yet arrived, iCloud
   Keychain off, and another Apple ID all look the same to it; there's no API to tell them apart (fact 6). A device on
   another Apple ID may use a key of its own, under its own name, for its own file only (corner 34's road).
   **Two devices therefore never mint the same item.** The same-item conflict that orphaned the vault's copy before
   the pre-13x ladder's F2/F3 fixes can't happen by construction.
   - This rebuilds `reconcileAppleKey`'s mint-and-wait rule (`ProtectionController.swift:1600-1690`), so it reopens
     that settled ground. It gets its own convergence pins: the leave race, the slow arrival, the other Apple ID.
3. **Retire on entering Castle.** Once the switch has committed, the account's or library's Apple key is deleted, and
   so is every device key made for it; each device deletes its own when it follows. Deletes of synchronizable items
   reach every device, with no "recently deleted" for app items (fact 3).
   - The Castle repair is "delete it whenever it's seen". A key deleted while this Mac's iCloud Keychain was off can
     come back when sync returns, and OS updates have silently turned sync back on (fact 6).
4. **Leaving Castle mints a fresh key.** The other devices wait for it. Their keys move to the silent item meanwhile,
   and their Apple copy lands when the key arrives — the existing "waiting for iCloud Keychain" fact, not a lockout.
5. **Stores that exist today, yours included.**
   - A Standard store keeps today's shared key until it enters Castle. That steady state is already guarded: nothing
     deletes the shared key, so nothing races.
   - When such a store enters Castle — or, **once, for a store already in Castle (yours)** — Variorum asks whether to
     retire the old shared key.
   - The question says what that means: *"Older copies of this library made before Castle — backups, older libraries,
     Time Machine — stop opening through your Apple account. Any other device signed into this Apple account that keeps
     a Variorum library in Standard will keep opening it, but its own older copies will need your passphrase or twelve
     words."*
   - For you, with every library in Castle, it costs nothing current. Your pre-Castle copies (VX-99 counted 13
     Apple-openable pairs on your Pro on 8 October) stop opening through the Apple account. You can still open them
     with Touch ID or your passphrase, through the history.

**What it buys:**

- **Castle covers every copy Variorum ever made of the library,** the moment the key is retired: iCloud Drive, Time
  Machine, copies you carried elsewhere, and the server's own backups. The exception is anything someone already opened
  before then; no design can recall that.
- **The login password stops reaching pre-Castle writing** on this Mac, through Variorum or around it.
- **The Castle offer has nothing left to ask about Apple reach.** No "delete your backups?", and no background job
  bringing backups into Castle. What remains is VX-208's Markdown-exports line, and listing older libraries of *other*
  libraries.
- **Two plain rules** replace a paragraph of caveats (the short version).
- **Accounts stop sharing a key,** so corner 14's "each account's copies are its own" becomes literal.

**What it costs:**

1. **The way back.** In Castle, losing your passphrase, your words and Touch ID loses the library *and* its older
   backups. Today the pre-Castle backups would still open through your Apple account. Your original design kept them
   deliberately, "as a limit and a way back". This is the trade, and it's yours.
2. **More Apple-key events.** A mint at every leave, a delete at every entry, and the follower-wait rule above. Leaves
   and entries are rare, deliberate acts.
3. **Other devices wait after a leave.** After leaving Castle on one device, the others open normally but carry no
   Apple copy until the new key arrives through iCloud Keychain.
4. **It doesn't replace the re-key at entry.** Re-keying the library and rotating the account keys still defend against
   someone who took a key while you were in Standard. This change adds protection against someone who reaches the Apple
   key *after* you enter.

**Recommendation:** adopt it, with the one-time question for existing stores, unless the way back matters more to you
than a Castle that covers everything. Pre-launch is the cheap moment: everyone who starts after it ships never has a
shared key at all.

---

## 4. What's holding the design back — the built things, and what to do with each

| built thing | where | what it causes | what to do |
|---|---|---|---|
| **One Apple key per Apple account, never deleted** | decision 6, corner 5; `AppleKeyCustody.swift:135, 189-190` | Castle can't cover older copies; the login password reaches pre-Castle writing; the offer and its tickets; the server-backup residual | §3: keys named by id, retired on entering Castle; the one-time question for today's stores |
| **The mode "derived, never a setting"** | §3.1's posture row; `Posture.derive` | five inputs, each changed by something else; corner 45; VX-209 | record it (both designs) |
| **Keychain items named by library ID** | decision 13; `StoreKey.swift:265-267` | every copy shares one slot; opening one evicts another | name items by key (both) |
| **Several key files beside a library, "current" = newest modified** | §3.5; `StoreKeyEnvelope.swift:482-497` | a copy or Time Machine flips which key file counts | one key file with the history (both) |
| **Crash markers inside the library file, flags in UserDefaults** | §4's marker pattern; `PostureSwitch.swift:1827-1838`; `ProtectionDefaults` | backups carry half-finished switches; flags outlive markers | sealed plans beside the library (both + §2.3) |
| **"Enrolled" = sync keys on this Mac; rows stamped by whoever is signed in** | decision 25; `AppBootstrap.swift:498-501` | five meanings of "enrolled"; mixed owners; silent reverts at sign-in | the record names the account; rows follow it (both) |
| **Trusting things stored on the Mac to decide before unlock** | `StoreLaunchGate.effectiveGate`; settings in `ProtectionDefaults` | a file or keychain edit steers how the library opens or what custody gets built | before unlock only self-verifying roads; seal anything that can weaken (§2.2–§2.3) |
| **Backups counted per folder, not per library and Mac** | `StoreBackup.existingBackups` | two Macs prune each other (§2.4) | attribute copies; retention per library and Mac |

**Not holding anything back — keep them:**

- backups as frozen pairs (decision 11); the history is the piece that was missing;
- the vault, the key proof and the rotation protocol;
- one library key per library file;
- the follow re-keying each device;
- the lobby's roads and the vault road;
- Touch ID items protected by the Secure Enclave, which Keychain Access can't open with the login password.

---

## 5. What I checked and agree with, briefly

- **Copies re-encrypted under the current key**, straight from the staged copy into place, and the plaintext export
  carrying the library ID.
- **The account table** (four rows), the one-road signed-out screens in both directions, and *Stop syncing this library
  on this Mac*.
- **Touch ID or Always ask as your choice**, now sealed (§2.3).
  - Nothing acts on a momentary reading. macOS 15+ can tell a closed lid (`builtInSensorInaccessible`) or a
    disconnected keyboard apart from a lost item (fact 9).
  - After a biometry change Variorum asks before turning Touch ID back on. The question should say "Touch ID changed on
    this Mac, or macOS was updated", since the change signal can also move with a major update (fact 8).
- **The migration's order:** finish in-flight acts; write nothing Apple-reachable while unconfirmed or ambiguous; keep
  old items and key files for a release; ask the passphrase once to fold old keys into the history. Add §3's one-time
  question.
- **The scenario test.** Add adversary actions to its alphabet:
  - edit a key file;
  - plant a plan;
  - edit a stored setting;
  - read or delete keychain items as Keychain Access could;
  - swap the library file at its place;
  - delete the container and open an old copy;
  - share one backup folder between two Macs.

  Add promises to match §2.2–§2.4 and §3: in Castle no Apple key of this library exists; retention never touches
  another Mac's copies.
- **VX-212 gets its own `Sync/` design** and your ruling, and must never delete server rows. A sketch for that design:
  - an undecryptable row is quarantined, listed and kept sealed;
  - the pull skips quarantined rows by recorded seq, so one bad row no longer refuses the whole round;
  - the rotation completes over the quarantine;
  - quarantined rows are retried whenever this device's keys change.

  That changes pull semantics, so it needs Fable and a convergence pin.

---

## 6. The phases

Agreed: this is several phases, not one, and the go/no-go after the headless core is the right safety valve. My changes
make the core smaller (no history key) and add sealed plans and settings, per-library-and-Mac attribution, and the
library-ID rule. §3 adds the Apple keys' naming, minting and retirement, and the one-time question. The order I'd run:

1. **The headless core.** The record, format 3 with the history, what the device remembers (mirror included), custody
   per key, `assess`, the executor, sealed plans and settings, the catalog with attribution, and the route finder. Plus
   the scenario world, with today's shapes and the adversary actions, and the Apple-key rules modelled as fakes.
   **Go/no-go.**
2. **The open road and the migration** — the riskiest phase: per-shape drills, the dev store, then byte-copies of your
   stores, and the Keychain Access check from the short version made into a drill.
3. **The acts.** The switches, the follow and Replace All Keys on plans. VX-107, VX-109 and moving the marker out of the
   library file are Fable's `Sync/` lines. The Apple key's lifecycle (§3) lands here, with its convergence pins.
4. **The account and key doors,** with rows owned by the binding.
5. **Copies and words:** the restore list, the open rule, what's left of the Castle offer, Data Safety, VX-211, and the
   VX-264, VX-265 and VX-210 copy.
6. **VX-212,** designed with you first.

---

## 7. The decisions for you

| # | decision | my recommendation | where it would be recorded |
|---|---|---|---|
| D1 | The mode belongs to the library; opening a copy never lowers it (this reverses your "you'll be leaving Castle" yes) | yes | VX-209 |
| D2 | The key history under the current key, re-accepting cold read 1's B1 with the honest leave sentence — or the proposal's separate history key | **ruled yes, 2026-10-13** | VX-263 (recorded) / VX-213 |
| D3 | Retire the Apple key when entering Castle (keys named by id, one minter), including the one-time question for today's stores | **ruled yes, 2026-10-13** | VX-301 |
| D4 | A library this Mac remembers in Castle never opens without asking | **withdrawn** — redundant under D3 | — |
| D5 | Plans and protection-weakening settings are sealed with the library's key | yes | VX-235 |
| D6 | Copies belong to a library and a Mac; retention acts only on this Mac's copies of this library | yes | a new ticket under VX-266 |
| D7 | New writing belongs to the library's account | yes (both designs) | VX-264 or a new ticket |
| D8 | The Castle offer: under D3, only the Markdown line and other libraries; without D3, the proposal's two groups | follows D3 | VX-265 / VX-210 |
| D9 | VX-212 designed separately; never delete server rows | yes | VX-212 |
| D10 | Several phases with a go/no-go after the headless core | yes | VX-266 |

Everything in the proposal's §11 that this list doesn't mention, I agree with as written.

---

## 8. What the fresh reviewer found in this document, and what changed

The full report and my disposition of each finding are in `second-opinion-cold-read.md`. No blocker. In short:

- **M1 — retiring the Apple key reopens the minting race.** Confirmed: today only "the key is never deleted" stops a
  master-holding device from minting a second one. → Keys named by their own id with one minter (§3 point 2), so two
  devices never mint the same item, and pins for the race.
- **M2 — retiring the key wouldn't reach your stores.** Confirmed. → The one-time question for stores that exist today
  (§3 point 5), and the short version says who it reaches.
- **M3 — dropping the history key re-accepts B1, with the reach understated.** Confirmed as framing. → §2.1 now names
  B1, gives both cases, and records today's actual boundary for synced libraries.
- **Minors:**
  - the file swap applies to local-only Castle libraries only (scoped in §2.2);
  - my key-file "re-key in progress" field trusted an unsealed file (dropped, §2.3);
  - sealing was underspecified (specified, §2.3);
  - the cross-Mac offer listing is right for synced libraries (recast, §2.4);
  - §2.5 reopens cold read 1's m9 (said);
  - VX-203 and VX-208 exist (Done, VX-201's run).
- **Small ones:** a citation drift; D3 gets its own ticket; the mirror's upkeep is named.

The reviewer's clean bill confirms the rest:

- the four half-locked states of the history key;
- entering Castle unaffected under my history;
- the file-swap attack for local-only Castle libraries;
- the planted-plan attack against the proposal;
- the cross-Mac pruning hazard;
- the six further hazards from the map.

---

## Appendix A — the cases, walked under my version

**VX-209, local only.** You restore a pre-Castle backup.

1. This Mac remembers the library in Castle, so the open asks for Touch ID first.
2. The history reaches the backup's key, and the copy is re-encrypted under the current key straight into place.
3. It stays in Castle. The Touch ID item is never touched, because it belongs to the current key.

Bringing the Castle library back moves nothing. Under D3, the backup's own Apple copy is already dead.

**VX-209, synced.** The same; then Resume Sync catches up and the vault confirms Castle.

**W-1 / VX-263.** Entering Castle from the exposed state puts the old key into the new key's history. Every earlier
backup opens with whatever opens the library now. The leftover key file goes, so VX-213 and VX-263 are both satisfied.

**A passphrase changed on the Air, then a key replacement the Pro follows.** The Pro follows by typing the new
passphrase through the vault, and re-wraps its history with the library key it already holds. Nothing is lost. (Under
the history-key design, a Standard Pro's history key is locked under the old passphrase, so the history stops at this
follow.)

**Leaving Castle after a Replace All Keys.**

- **Under my version,** the Apple account reaches the key you leave with and its history, so Castle-era backups open
  through the Apple account. The leave screen said so.
- **Under the proposal,** backups under the replaced key stay sealed; those under the key you leave with don't.
- **Under D3,** the key you leave with is wrapped under a freshly minted Apple key, and the same rule as mine holds.

**Someone with your login password, on a Mac in Castle.**

- **Without D3:** they can very likely read the shared Apple key in Keychain Access and open every pre-Castle backup
  with a script. D4 only stops the version that uses Variorum.
- **With D3:** the key is gone, so there's nothing to read. Touch ID items resist Keychain Access, and the library
  itself stays closed.

**A planted plan or an edited setting.** Not sealed with the library's key, so the plan is ignored and reported, and
the setting reads as the stricter value (D5).

**Pro and Air sharing an iCloud Drive backup folder.** Each Mac prunes only its own copies of its own library, and the
offer names whose copies it lists (D6).

**A new Mac, from the backup folder only.**

1. Open the newest pair with your passphrase or words.
2. Its history opens every older pair.
3. In Standard, the account's Apple key, arriving through iCloud Keychain, opens them with nothing typed.
4. Under D3, Castle-era pairs open only with your secrets, which is the point.

**An Apple account change on this Mac (Standard).**

- The silent item keeps opening the library.
- Under D3, this Mac can't read the account's key, so it waits. For its own file it may use a key of its own,
  under the new Apple account.
- Older copies open through the history.

**A follower that reconciles before a freshly minted key arrives (D3).** It waits; it never mints a key under the
vault's id. Its keys sit in the silent item meanwhile, and the Apple copy lands when the key arrives. No same-item
conflict can occur.

---

## Appendix B — Apple platform facts this rests on

Gathered by a research helper on 2026-10-13 from Apple's developer documentation, the Apple Platform Security guide,
Apple Support articles, Apple DTS answers on the developer forums, and `codesign` entitlement dumps on this Mac
(macOS 27.0). The full report, with every source, is `second-opinion-apple-facts.md`. Confidence: **high** = documented
by Apple; **medium-high** = documented plus observed, not yet tested here.

| # | fact | confidence | what it means for the design |
|---|---|---|---|
| 1 | Keychain Access carries a wildcard keychain entitlement (`keychain-access-groups = ["com.apple.keychainaccess", "*"]`) and lists the password items of every app; "Show password" asks only for the login password. Not yet tested on Variorum's own items. | medium-high | Someone who knows the Mac's login password can very likely read Standard's silent library key and the shared Apple key, and so open every copy wrapped under it, with or without Variorum. Touch ID items are evaluated in the Secure Enclave and resist this. |
| 2 | Keychain Access can presumably edit and delete what it lists. | medium | Nothing in the keychain is tamper-proof against the login-password holder. Anything that could weaken protection is sealed with the library's key, and an unsealed value is read as the stricter one. |
| 3 | Deleting a synchronizable item "affects all copies of the item, not just the one on your local device". App-created items have no "Recently Deleted" recovery; the Passwords app's uses Apple-only access groups. | high / medium-high | Retiring the Apple key works: one delete removes it from every device on that iCloud Keychain. |
| 4 | Anyone who can add a device to the iCloud Keychain obtains the Apple key: the Apple account with two-factor authentication and any trusted device's passcode or login password, escrow recovery, a recovery contact or a recovery key. iCloud Keychain is end-to-end encrypted with or without Advanced Data Protection. | high | "Your Apple account holds a key" means exactly this set of people. |
| 5 | The cloud copy can vanish without the app knowing: Reset iCloud Keychain, too many wrong security-code attempts, a reset of end-to-end encrypted data, or a delete on any device. | high | Standard's durable roads are the passphrase and words; the Apple key is a convenience road, and its presence proves nothing. |
| 6 | There is no API for "is iCloud Keychain on" or "which Apple ID". Signing out offers keep-or-delete. OS updates have silently re-enabled iCloud Keychain. A delete made while sync is off is local, and the cloud copy can return when sync does. | high / medium | The mode can never be inferred from the Apple key. A retired key can reappear, so the Castle repair deletes it whenever it's seen. A device that can't read the vault's key can't tell "not yet arrived" from "another Apple ID", which is why §3 has one minter and followers wait. |
| 7 | A synchronizable item can't carry a biometric or other access control; Apple's own regression test expects `errSecParam`. | medium | The Apple key is protected only by iCloud Keychain's trust circle, plus the login on each Mac it reaches. |
| 8 | A `.biometryCurrentSet` item dies on any enrollment change, adding then removing a finger included. Its read errors are ambiguous: `errSecAuthFailed` also appears on transient failures. `LAContext.domainState.biometry.stateHash` (macOS 15+) is a hint and can change across major OS updates. | high / medium | The Touch ID copy is a rebuildable cache, and the passphrase always stays a road. The re-arm question must allow for "macOS was updated". |
| 9 | With the lid closed, `LAEnvironment` reports `builtInSensorInaccessible`, and evaluation was observed failing with `systemCancel` ("Touch ID is not available in closed clamshell mode"). Unpaired or disconnected keyboards have their own codes. Enrollment is unchanged, so items survive. | high / medium | Nothing may act on "Touch ID unavailable", and there's an API to tell the cases apart. |
| 10 | `ThisDeviceOnly` means "never synced", not "never leaves". iOS Quick Start has been seen to carry such items; iOS backups restore them to the same erased device. Mac Time Machine and Migration Assistant handling of Local Items is undocumented and reportedly lossy. | medium | Keychain contents on a new device are never proof of anything. A device identity can be cloned, so re-mint it when the hardware changes. |
| 11 | A Secure Enclave key with `[.privateKeyUsage, .biometryCurrentSet]` can unwrap a key from a blob kept in a file. The blob is useless after an erase, on a new Mac, or after an enrollment change. | high | A possible alternative for the Touch ID road (a wrap in the key file instead of a keychain item). Not recommended: per-key items already remove the aliasing, and this changes more. |
| 12 | Keychain items outlive deleting the app, on iOS and macOS. | high (macOS) / DTS (iOS) | A reinstall can find old items, which is why "a library lived here" is judged by a marker in the app's own container. |

**Tests worth running before the phases build on them** (minutes each, on the dev store):

1. Keychain Access reveals the dev scope's Apple key and silent library key with the login password. **Yours — it
   needs your login password. The short version asks for it.**
2. The read result for a Touch ID item after a finger is added, on macOS.
3. The `LAEnvironment` values with the lid closed.
4. What Time Machine and Migration Assistant carry of Local Items on macOS 27.
