# Castle, backups and restores — a second opinion

**For:** VX-266 and its 17 tickets. **What this is:** an independent assessment of the design proposal
(`design-proposal.md` in this folder, as revised after cold read 1), written 2026-10-13 at your request. It is not a
ruling: nothing is built and no ticket is changed by it. Your ask, verbatim: *"evaluate this full output and system with
fresh eyes … first independently and thoroughly consider the problem with your own ideas. then … assess the proposed
solution against what you have considered … if something that we've already built is hamstringing our ability to come
up with a truly elegant solution … you should tell me."*

**How I worked.** I read the 17 tickets and every comment, your #216 sitting, the original Castle design
(`pre-13x-postures-design.md` §1–§7 and §14), the VX-191 audit, and the code at the points that decide and write
protection. Then I wrote my own diagnosis and design **before opening the proposal** —
`second-opinion-independent-notes.md`, committed as `c24a6c44` — and only then read the proposal, its cold read and the
dispositions. Two research helpers worked alongside me: one mapped the backup, restore and Open Library code from
scratch, without reading the proposal's research (its report agrees with the proposal's evidence and adds three
hazards); one gathered Apple's documented Keychain, Touch ID and iCloud Keychain behaviour. A fresh reviewer then
attacked the changes I recommend (section 8).

---

## The short version

**The proposal is right where it matters most.** Its diagnosis is accurate. Working from first principles, I
independently reached the same core design before reading it:

- the mode is recorded, not guessed;
- opening a copy never lowers protection;
- older keys travel forward with the library;
- Keychain items are kept per key, not per library;
- one function decides and one component writes;
- long acts are written down outside the library file;
- the library knows its account;
- a generated scenario test is the proof.

That two independent designs converged is good evidence the shape is sound. **Build that design.**

**I would change four things before your sitting.** Two of them close holes that would otherwise ship:

1. **A library this Mac knows is in Castle must never open without asking, whatever file sits in its place.** As
   written, the proposal still opens an older copy through the Apple account first and protects it afterwards. Today
   and under the proposal, someone who knows your Mac's login password can move a pre-Castle backup into the library's
   place and read it, without Touch ID or your passphrase. That is exactly the person Castle is meant to stop.
   (§2.2)
2. **The written-down plans must be tamper-proof.** As written, a plan file planted beside the library could make the
   app finish a "leave Castle" you never chose, at your next Touch ID unlock. (§2.3)
3. **Drop the separate history key.** Lock the key history under the library's current key instead. This removes a
   fourth kind of key and four "half-locked" states it creates (a passphrase changed on another device, a follow that
   types one secret, Standard keeping no history key, a history key that waits for a typed secret). Restores also get
   simpler: whatever opens your library opens its past, with nothing typed. The security difference is one narrow case
   after you *leave* Castle, and I think the honest rule for that moment is simpler than the mechanism that dodges it.
   (§2.1)
4. **Backups must belong to a library and a Mac.** Today retention and the Castle offer count every Variorum backup in a
   folder, whichever library or Mac made it. The iCloud Drive offer opens the folder picker at iCloud Drive's root, so
   two Macs on one Apple account that both accept it — your Pro and your Air — share one folder and **prune and offer
   to delete each other's backups**. Neither the tickets nor the proposal name this. (§2.4)

**One structural change the proposal never weighed, which I think you should seriously consider: retire the Apple key
when a library enters Castle** (§3). Today one iCloud key per Apple account serves every library and is never deleted.
That single fact is why entering Castle can't cover your older copies. It is why the "delete your old backups?" offer
exists, and the offer is where VX-203, VX-210, VX-265, VX-263's offer wording and part of VX-209 come from. Give each
library, and each sync account, its own Apple key, and delete it once entering Castle has finished. Then every copy
Variorum ever made of that library — in iCloud Drive, Time Machine, a USB stick, or the server's own backups — stops
opening through the Apple account at that moment. Two plain rules replace the offer:

> **In Castle, your Apple account opens nothing of this library. In Standard, it opens your library and every copy
> Variorum made of it.**

The cost is real: older backups stop being a way back through your Apple account if you lose your passphrase, your
words and Touch ID. Keeping that way back was your own choice in the original Castle design. That choice is yours to
remake, not mine.

**You asked what already-built things are holding the design back** (§4 has the full list with what to do about each).
The two that matter most:

1. **The shared, never-deleted Apple key** (above).
2. **The rule that the mode is "derived, never a setting."** It meant to prevent drift, but every input it reads is
   changed as a side effect by something else, so it drifts anyway. Both designs reverse it.

Close behind:

- Keychain items named by library rather than by key;
- several key files beside a library, where "current" means "most recently modified";
- crash markers kept inside the library file;
- "enrolled" meaning "sync keys are on this Mac," with rows stamped by whoever is signed in;
- a launch route that trusts a plain-text key file.

**Your decisions** are in §7. Each has my recommendation.

---

## 1. Where the two designs agree

| piece | my independent notes (before reading) | the proposal | verdict |
|---|---|---|---|
| Diagnosis | mode inferred from five inputs; one Keychain slot per library ID shared by every copy; readers that write; copies frozen with their day's roads; the "newest file" guess; markers inside the file; implicit account binding | the same five causes, with more evidence (churn, counts, 46 tickets in 13 patterns) | agree; the helper's independent map reproduces the mechanisms |
| Mode recorded | a protection record per library; custody is a consequence, never an input | a record inside the library file plus "what this device remembers" in the Keychain | agree; the in-file record is the better home (authenticated by the library's own encryption, travels with copies) |
| Never lowered by opening | a copy is brought under the current key and mode; only Leave Castle lowers | the same; a Castle copy from another Mac raises through Use Castle's steps | agree, plus §2.2's sharpening (key it by library ID) |
| Older keys travel forward | a history carried in the key file, under the current key | a history under a separate history key | **differ** — §2.1 |
| Custody per key | Keychain items named by key fingerprint | the same, store variant in every name | agree |
| One decider, one writer | a pure `assess`, one executor | the same, with guards (decision 35 made explicit, mint guards kept, no acting on a momentary reading) | agree |
| Acts written down outside the file | a journal outside the library, holding everything a resume needs | plans beside the library, excluded from backups, never holding a secret | agree, plus §2.3 (seal them) |
| Account binding | the record names the account; rows stamped by the binding, not the session | the same, with the four-row account table | agree |
| Proof | a generated scenario test with crash injection | the same, with what it can't reach named and the real-Keychain drills kept as gates | agree, plus adversary actions (§5) |
| Size | — | one sitting, about five phases, a go/no-go after the headless core | agree (§6) |

---

## 2. What I would change

### 2.1 The key history: lock it under the current library key, not a separate history key

**What the proposal does** (§3.2): a history key H opens the list of the library's older keys. H is wrapped under your
passphrase and your words only, kept in the Touch ID item while in Castle, never kept on the device in Standard,
replaced at every re-key, and the whole history is re-locked under the new H each time. It exists because cold read 1's
blocker (B1) showed that a history reachable through the account master would, after leaving Castle, hand
Castle-era keys to anyone in your Apple account.

**Why I'd drop it.** H adds a fourth kind of key and four states where the history is only partly locked:

- **A passphrase changed on another device.** This Mac's key file still holds H under the *old* passphrase. When this
  Mac later follows a key replacement, you type the *new* passphrase. It opens the library through the vault, but it
  can't open H, so the history can't be carried into the new key file here (unless you also type the words).
- **A follow takes one secret.** The new H gets one wrap; the other "lands the next time that secret is typed here" —
  a pending state.
- **Standard keeps no H on the device.** Every restore of an older-key backup asks for your passphrase or words, even
  on your own Mac with the library open.
- **H can only be made when a secret is typed.** The migration has to ask, and backups made before then carry a
  history nothing opens.

Each of those is a future ticket in waiting.

**The alternative.** Wrap every older key of the library under the library's **current** key, in the key file (and in
every backup's frozen copy of it). Whatever opens the library — Touch ID, the silent item, the passphrase, the words,
the master, the Apple key in Standard — opens its past. A re-key re-wraps the history with keys already in hand. Nothing
is ever typed for the history's sake, and there are no pending states. The chain only runs backwards (a new key opens
old ones, never the reverse), so **entering Castle is unaffected**: nothing Apple-reachable leads to anything written
after the switch. Cold read 1's own clean bill checks this direction.

**The one difference, exactly.** After you *leave* Castle, the Apple account reaches the current key, and through the
history it also reaches keys that were retired *while* you were in Castle. The copies affected are Castle-era backups
under a key you replaced (Replace All Keys, or a follow of one) before leaving.

Note what H does *not* protect, today or under the proposal. Castle-era backups under the key you had when you left
open through the Apple account anyway, because leaving adds an Apple copy of that same key. So H's protection covers
"Castle-era copies older than your last key replacement" — a boundary no user can see or reason about. For most people,
who never replace their keys, H protects nothing at all.

**The honest rule** for leaving Castle under my version: *"Leaving Castle gives your Apple account a key to your library
and to the copies Variorum keeps of it."* The leave screen already asks for consent; this is the sentence it should
say.

**If you want Castle-era copies to stay sealed after leaving,** H is one way, with the costs above. The consistent way
is to re-key when leaving and keep Castle-era keys out of the new history. That needs your passphrase *and* words typed
to leave, on every device that follows. I don't think either is worth it.

**Recommendation:** history under the current key; the honest leave sentence.

### 2.2 A library this Mac knows is in Castle never opens without asking

**The gap.** Two places in the proposal accept a silent open first:

- §3.4: *"If what this device remembers says the library is in Castle but a road opened it without asking … the
  reconciler brings it into Castle straight away and says so."*
- §4: *"Someone puts an older, Apple-openable copy where your library was. It opens through the Apple road, as it would
  today; after unlock … the reconciler brings it into Castle at once."*

"Brings it into Castle" re-encrypts under the current key, and that needs Touch ID or your passphrase. If the person at
the keyboard isn't you, they have already read the copy by then.

**The attack, traced at HEAD** (it works today and would keep working):

1. Someone who knows your Mac's login password moves a pre-Castle backup pair from `Backups/` into the library's place
   (Finder is enough).
2. They open Variorum. The route reads the old key file, sees an Apple copy and no silent item, and derives Standard
   (`StoreProtection.swift:101-109`).
3. It opens silently through the Apple key (`AppBootstrap.swift:343-357`). iCloud Keychain releases that key to anyone
   logged in as you.
4. Today, the ready step then re-saves the old key silently (`:548`).

A variant: delete the app's container to get a fresh library, then use File ▸ Open Library on the old backup. The
proposal's open rule compares the copy with *the library currently in place*. A fresh library is "a different
library", so the copy keeps its own Standard mode.

**The fix:**

- **The never-lower rule is keyed by library ID, through what this device remembers, not by what sits at the
  location.** Any file of a library this Mac remembers in Castle opens only after Touch ID or the passphrase. That holds
  whether the file is at the library's place, picked in Open Library, or picked from a fresh library.
- After that unlock, the history reaches the older key, and the copy is re-encrypted under the current key before
  anything shows.
- For a library you deliberately abandon, offer a *Forget this library on this Mac* door. Without it, its copies keep
  asking here.
- **Robustness to go with it:** what this device remembers keeps a copy of the current key file's wrapped keys and
  history. A rolled-back or deleted key file then never strands the library on this Mac. The proposal instead relies on
  finding the newest backup's key file.

If you adopt §3 (retire the Apple key), the Apple road for this library is dead anyway. This rule still matters for
silent items, for older copies made under today's shared key, and for any copy under a different account's key.

### 2.3 Plans have to be sealed

**The gap.** Plans live beside the library, hold facts but no secrets, and the reconciler resumes them after unlock
(§3.5). A file can be written by anyone who can write the container, which is the same login-password holder as §2.2.

A planted plan reading *Leave Castle, next step: add the Apple copy* would be resumed at your next Touch ID unlock.
The app would add the Apple wrap and move the key to the silent item: you'd be in Standard without having chosen it.
The proposal's "a plan whose world doesn't match is ignored as stale" doesn't stop this, because the library ID and the
key fingerprints are public in every key file.

**The fix:** seal every plan with a key derived from the library's current key. The plan is written while the library
is open, and checked after unlock, when the key is in hand. Keeping plans in the Keychain is an equivalent fix. An
unsealed or mismatched plan is ignored and reported, never resumed. A plan that *lowers* protection also carries the
record of the consent you gave at its door.

Related, and smaller: let the key file carry a re-key in progress itself (its current key plus its pending key). The
lobby then decides from one file and what the device remembers, and never needs to read plans (the proposal's m6(e)
answer has the lobby read the plan).

### 2.4 Backups belong to a library and a Mac

**The hazard.** Found by my helper, traced and verified:

- `StoreBackup.existingBackups` (`StoreBackup.swift:704-715`) lists every Variorum-named snapshot in a folder.
- `prune(keep:)` (`:609-615`) and the far folder's 14-daily-plus-4-weekly rule (`BackupRetention.swift:87-119`) count
  them all, whatever library or Mac made them. The Castle offer lists them the same way.
- The iCloud Drive offer opens its picker at iCloud Drive's root (`ICloudDriveOffer.swift:99-106`), and backups land
  in `<pick>/Variorum/Backups`.

So two Macs on one Apple account that both accept the offer share one folder. Each Mac's retention deletes the other's
older backups, a busy Mac can push a quiet Mac's history out entirely, and the Castle offer on one Mac lists the other
Mac's backups for deletion. That is your Pro-and-Air setup.

**The fix:** the proposal's one catalog must attribute every copy to its library (the pair's library ID) and to the Mac
that made it (from what the device remembers). Retention and the offer then act only on this Mac's copies of this
library. A per-library subfolder inside the picked folder is the simple way to do it. Existing shared folders migrate
by attribution, never by deletion.

**Other hazards from my helper's map** that the proposal settles in substance but doesn't list. Each needs a
red-on-old pin when its phase lands:

- **A reader that changes the library's identity.** The Apple arm's `ensuredEnvelope` sets aside a non-matching key
  file and starts a *new library ID* (`ProtectionController.swift:1129-1142`).
- **Copies with no key file.** Adoption lands the library before its key file (`LibraryAdoption.swift:295-304`), so a
  crash between the two leaves ciphertext with no key file and no recovery road. Pair and folder key-file writes are
  best-effort `try?`, so a snapshot can exist with nothing that opens it.
- **The restore list promises roads it never checks.** "Your current passphrase (online)" is shown for copies made
  before the master was rotated, which it can't open (`LibraryOpenCopy.swift:114`).
- **The lock-time copy is named after the wrong key.** It takes its name from the located key file, not from the key
  its bytes are under (`StoreBackup.swift:648-655`).
- **Resume Sync can hide a hold that still stands.** It clears the banner even when removing the marker failed
  (`RestoreHoldModel.swift:85-89`).
- **Orphans accumulate.** `.stale-*` key files are never read or removed, and older libraries and safety copies are
  only ever removed by the Castle offer. Give older libraries a retention rule of their own.

### 2.5 Optional simplification: secrets in custody, everything else in what the device remembers

The proposal keeps two custody families: library-key items, plus one sync-keys item per library that also carries the
device identity. The identity riding the sync-keys item is why Castle needs an "identity-only" silent item beside the
Touch ID one.

**Simpler:** custody items hold only secrets — the library key per key, and the account's keys per account. Everything
non-secret moves into what the device remembers:

- the device identity;
- the current fingerprint;
- the mode and the account;
- your preferences;
- the mirrored history.

The identity-only item disappears. This needs one migration leg that carries the existing identity across (cold read
m9's concern: a new identity mints a new device-cursor row). Worth doing if the open-road phase has room; not required.

---

## 3. The structural option: retire the Apple key when entering Castle

**Today** (decision 6, corner 5; `AppleKeyCustody.swift:135` names the key by store scope only, and `:191-197` says it is
"never deleted in production"):

- There is one Apple key per Apple account, shared by every library and every Variorum account, and never deleted.
- Entering Castle removes the copies under it from the live key file and the vault.
- But every older key file keeps its copy, so every backup, older library, Time Machine snapshot and iCloud Drive pair
  made before Castle opens through the Apple account forever. On this Mac it also opens for anyone logged in, which is
  §2.2's attack.
- Hence the Castle offer and its tickets.
- Hence also the VX-191 audit's residual: the server's own backups of the old vault row, read with the Apple key, still
  open pre-Castle writing.

**The change:**

- Mint one Apple key per local-only library and one per sync account, named by the library's or account's ID.
- When a library enters Castle, delete its Apple key from iCloud Keychain once the switch has committed. Each device
  deletes the account's key when it follows.
- Leaving Castle mints a fresh one.

**What it buys:**

- **Castle covers every copy Variorum ever made of the library** — iCloud Drive, Time Machine, copies you carried
  elsewhere, and the server's own backups — the moment you enter. (The exception is a copy someone already opened
  before then, which no design can recall.)
- **For new users the Castle offer has nothing left to ask about Apple reach.** No "delete your backups?", no "bring
  them into Castle" job. VX-265 and VX-210 shrink to nothing; what remains is VX-208's Markdown-exports line.
- **§2.2's attack dies** for this library's Apple road.
- **Two plain rules** replace a paragraph of caveats (the short version).
- **Accounts stop sharing one key.** Each account's copies really are its own (corner 14, made literal).

**What it costs:**

1. **The way back.** In Castle, losing your passphrase, your words and Touch ID loses the library *and* its older
   backups. Today the pre-Castle backups would still open through your Apple account. Your original Castle design kept
   them deliberately, "as a limit and a way back." This is the real trade, and it's yours.
2. **It relies on iCloud Keychain deleting the item everywhere** — the Apple facts below.
3. **Leaving Castle on one device makes the others wait** for the new key to arrive through iCloud Keychain before
   their Apple copy lands. They keep opening through their own custody meanwhile, so this is the existing "waiting for
   iCloud Keychain" fact, not a lockout. Followers must *wait* for the acting device's key, never mint their own;
   today's minting guards need that one change.
4. **Existing stores keep today's shared key for their older copies.** The migration can't safely delete a key other
   libraries or accounts may use. For your devices and the few beta testers, the offer stays as it is today; everyone
   who installs after launch starts on per-library keys.
5. **It doesn't replace the re-key at entry.** Re-keying the library and rotating the account keys still defend
   against someone who already took a key while you were in Standard. This change adds protection against someone who
   gets into the Apple account *after* you enter.

**Apple facts it depends on** (see the platform-facts section at the end): the deletion of a synchronizable item
propagates to the account's other devices; whether app-made items are listed or recoverable anywhere (the Passwords
app, a "recently deleted" list) is APPLE-FACTS-PENDING.

**Recommendation:** adopt it, unless the way back matters more to you than a Castle that covers everything.
Pre-launch is the only cheap moment: every user who starts on today's shared key keeps it for their older copies.

---

## 4. What's holding the design back — the built things, and what to do with each

| built thing | where | what it causes | what to do |
|---|---|---|---|
| **One Apple key per Apple account, never deleted** | decision 6, corner 5; `AppleKeyCustody.swift:135, 191-197` | Castle can't cover older copies; the offer and its tickets; the login-password file swap; the server-backup residual | §3: one key per library and per account, deleted on entering Castle |
| **Mode "derived, never a setting"** | §3.1's posture row; `Posture.derive` | five inputs, each changed by something else; corner 45; VX-209 | record it (both designs) |
| **Keychain items named by library ID** | decision 13; `StoreKey.swift:265-267` | every copy shares one slot; opening one evicts another | name items by key (both) |
| **Several key files beside a library, "current" = newest modified** | §3.5; `StoreKeyEnvelope.swift:482-497` | a copy or Time Machine can flip which key file counts | one key file with the history (both) |
| **Crash markers inside the library file, plus per-library flags in UserDefaults** | §4's marker pattern; `PostureSwitch.swift:1827-1838`; `ProtectionDefaults` | backups carry half-finished switches; flags outlive markers | sealed plans beside the library (both + §2.3) |
| **"Enrolled" = sync keys on this Mac; Sign Out keeps them; rows stamped by whoever is signed in** | decision 25; `AppBootstrap.swift:498-501` | five meanings of "enrolled"; mixed owners; silent reverts at sign-in | the record names the account; rows follow it (both) |
| **The launch route trusts a plain-text key file** | `StoreLaunchGate.effectiveGate` | a file edit or swap steers how the library opens | roads only before unlock, and §2.2's rule |
| **Castle's settings in UserDefaults, per scope or per ID** | `ProtectionDefaults` | tamperable; bleed across libraries | what the device remembers, in the Keychain (both) |
| **Backups counted per folder, not per library and Mac** | `StoreBackup.existingBackups` | two Macs prune each other (§2.4) | attribute copies; retention per library and Mac |

**Not holding anything back — keep them:**

- backups as frozen pairs (decision 11); the history is the piece that was missing;
- the vault, the key proof and the rotation protocol;
- one library key per library file;
- the follow re-keying each device;
- the lobby's roads and the vault road.

---

## 5. What I checked and agree with, briefly

- **Copies re-encrypted under the current key**, straight from the staged copy into place, and the plaintext export
  carrying the library ID.
- **The account table** (four rows), the one-road signed-out screens in both directions, and *Stop syncing this library
  on this Mac*.
- **Touch ID or Always ask is your stored choice.** A closed lid, an unplugged keyboard or a lockout never changes
  anything. After a biometry change, Variorum asks before turning Touch ID back on.
- **The migration's order:** finish in-flight acts; write nothing Apple-reachable while unconfirmed or ambiguous; keep
  old items and key files for a release; ask the passphrase once to fold old keys.
- **The scenario test, with additions.** Add adversary actions to its alphabet — edit a key file, plant a plan, swap
  the library file at its place, delete the container and open an old copy, share one backup folder between two Macs —
  and promises that match §2.2–§2.4.
- **VX-212 gets its own `Sync/` design** and your ruling. I agree it must never delete server rows.
  - Sketch for that design: an undecryptable row is quarantined, listed and kept sealed.
  - The pull then skips quarantined rows *by recorded seq*, so one bad row no longer refuses the whole round.
  - The rotation completes over the quarantine, and quarantined rows are retried whenever this device's keys change.
  - That changes pull semantics, so it needs Fable and a convergence pin.

---

## 6. The phases

Agreed: this is several phases, not one, and the go/no-go after the headless core is the right safety valve. My changes
make the core smaller (no history key) and add three small pieces: sealed plans, per-library-and-Mac copy attribution,
and the never-open-without-asking rule. If you adopt §3, the Apple key's lifecycle lands with the acts phase and the
migration. The order I'd run:

1. **The headless core.** The record, format 3 with the history, what the device remembers (mirror included), custody
   per key, `assess`, the executor, sealed plans, the catalog with attribution, the route finder, and the scenario world
   with today's shapes and the adversary actions. **Go/no-go.**
2. **The open road and the migration** — the riskiest phase: per-shape drills, the dev store, then byte-copies of your
   stores.
3. **The acts.** The switches, the follow and Replace All Keys on plans; VX-107, VX-109 and moving the marker out of the
   library file are Fable's `Sync/` lines; plus the Apple key's lifecycle if §3 is adopted.
4. **The account and key doors,** with rows owned by the binding.
5. **Copies and words:** the restore list, the open rule, the offer (much smaller under §3), Data Safety, VX-211, and the
   VX-264, VX-265 and VX-210 copy.
6. **VX-212,** designed with you first.

---

## 7. The decisions for you

| # | decision | my recommendation | ticket it would be recorded on |
|---|---|---|---|
| D1 | The mode belongs to the library; opening a copy never lowers it (this reverses your "you'll be leaving Castle" yes) | yes | VX-209 |
| D2 | Key history under the current key (and the honest leave sentence) vs a separate history key | under the current key | VX-263 / VX-213 |
| D3 | Retire the Apple key when entering Castle (one key per library and per account) | yes, unless you want to keep the way back | VX-228 (new scope) |
| D4 | A library this Mac remembers in Castle never opens without asking, whatever file is in its place; plus a *Forget this library on this Mac* door | yes | VX-228 |
| D5 | Plans are sealed (or kept in the Keychain) | yes | VX-235 |
| D6 | Copies belong to a library and a Mac; retention and the offer act only on this Mac's copies of this library | yes | a new ticket under VX-266 |
| D7 | New writing belongs to the library's account | yes (both designs) | VX-264 or a new ticket |
| D8 | The Castle offer: under D3, only today's legacy copies and the Markdown line; without D3, the proposal's two groups | follows D3 | VX-265 / VX-210 |
| D9 | VX-212 designed separately; never delete server rows | yes | VX-212 |
| D10 | Several phases with a go/no-go after the headless core | yes | VX-266 |

Everything in the proposal's §11 that this list doesn't mention, I agree with as written.

---

## 8. What a fresh reviewer found in my changes

REVIEW-PENDING.

---

## Appendix A — the cases, walked under my version

**VX-209 (local only).** You restore a pre-Castle backup. This Mac remembers the library in Castle, so the open asks
for Touch ID first. The history (under the current key) reaches the backup's key, and the copy is re-encrypted under
the current key straight into place. It stays in Castle; the Touch ID item is never touched, because it belongs to the
current key. Bringing the Castle library back moves nothing.

**VX-209 (synced).** The same; then Resume Sync catches up, and the vault confirms Castle.

**W-1 / VX-263.** Entering Castle from the exposed state puts the old key into the new key's history. Every earlier
backup opens with whatever opens the library now. The leftover key file goes; VX-213 and VX-263 are both satisfied.
Under D3 there was no Apple copy to retire in that state anyway.

**A passphrase changed on the Air, then a key replacement followed on the Pro.** The Pro follows by typing the new
passphrase through the vault, and re-wraps its history with the library key it already holds. Nothing is lost. (Under
the history-key design, the Pro's history key is locked under the old passphrase, and the history stops at this
follow.)

**Leaving Castle after a Replace All Keys.**

- Under my version, the Apple account reaches the current key and its history, so Castle-era backups open through the
  Apple account. The leave screen said so.
- Under the proposal, Castle-era backups under replaced keys stay sealed, but those under the key you left with don't.
- Under D3, the key you leave with is a fresh one, and the same rule holds: Standard opens everything Variorum keeps.

**Someone with your login password swaps a pre-Castle backup into place.** Variorum asks for Touch ID or the passphrase
before anything opens (D4). Under D3, that backup's Apple copy is dead in any case.

**A planted plan.** It isn't sealed with the library's key, so it is ignored and reported (D5).

**Pro and Air sharing an iCloud Drive backup folder.** Each Mac prunes and offers only its own copies of its own
library (D6).

**A new Mac, from the backup folder only.** Open the newest pair with your passphrase or words; its history opens every
older pair. In Standard without D3 the old Apple key also works. Under D3, pairs from a Castle era open only with your
secrets, which is the point.

**An Apple account change on this Mac (Standard).** The silent item keeps opening the library. The Apple copy re-lands
under whatever Apple account this Mac is now signed into — Standard means "your Apple account holds a key," and that
account is the one here now. Older copies under the previous Apple account's key open through the history.

---

## Appendix B — Apple platform facts used

APPLE-FACTS-PENDING.
