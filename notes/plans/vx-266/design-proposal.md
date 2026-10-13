# Castle, backups and restores — a design proposal

**For:** VX-266 ("Castle & backups before launch") and all 17 tickets in the project.
**Status:** a proposal, not a ruling. Nothing here is built and no ticket has been changed by it. Written 2026-10-13
at your request — *"fully, holistically consider the WHOLE of how castle is designed, the backups, the restores,
the full systems … find a path through the dark for me that you'll be proposing. I will weigh your deliverable.
don't ask me questions right now - note the decisions you made and we'll talk about them once the design is
complete."* **Revised the same day after a cold read** (Opus, max effort, zero context — `cold-read-1.md` beside
this file: 1 blocker, 7 major, 19 minor, 7 nits, every one answered there and folded in here). Every call I made
on your behalf is in [The decisions I made](#11-the-decisions-i-made), each tied to the VX ticket it would be
recorded on.
**Evidence:** two research files beside this one, each claim cited to file and line —
`research-custody-state-map.md` (what the code does today: every piece of state, every decision, every act and its
crash windows) and `research-backups-and-churn.md` (every kind of copy and how it opens, the change history, and the
bug patterns grouped by cause).

---

## The short version

**What is wrong.** The seventeen tickets are not seventeen bugs. They are five design choices showing up in
different places:

1. **The app guesses a library's mode.** "Castle or Standard" is written down nowhere. It is worked out again at
   every turn from up to five different things — the account's vault, whether sync keys are on this Mac, an old
   13p-era setting, which keys the key file carries, and *which Keychain slot on this Mac holds the key*. That last
   one is the root of VX-209. The code even has five different definitions of "this library is enrolled".
2. **This Mac keeps one key slot per library name, but many files share the name** — the live library, every
   backup, every older library Variorum kept, every copy sent to another Mac. Opening any of them overwrites the
   slot, and the overwritten slot then changes the guess in point 1.
3. **Deciding and writing are tangled.** The check that decides how a library opens can also write an
   Apple-account copy of its key; the phone runs that check every time the app comes back to the foreground.
   Nine functions write the library key's Keychain items (only one checks its write before deleting the old
   item), five write the sync keys, sixteen write the key file and nine write the vault — from seven independent
   tasks.
4. **Old copies remember only their own day.** A backup opens only with what its own key file carried when it was
   made, the app keeps no history of a library's keys, and each surface that talks about copies (the restore
   list, the Castle offer, the folder sweep) re-guesses what opens what.
5. **Long acts can't always finish.** Most acts have no resume record at all, and the one that does (the Castle
   switch) keeps it *inside the library file* — so a backup can carry a half-finished switch.

The research grouped 46 tickets and about 150 review findings into 13 recurring patterns; these five causes
explain all of them. In October so far, 40 of the 62 commits in this area were fix-like.

**What I propose.** Make the system *know* instead of *guess*, and give each fact one home:

- **The library carries its own protection record** — its mode and the account it belongs to — inside the library
  file, where only its key can read or change it.
- **One key file per library, with a history of the library's earlier keys,** locked by a history key that only
  your passphrase and twelve words open — and, while you're in Castle, Touch ID on this Mac. Nothing the Apple
  account can reach ever opens it.
- **This Mac keeps one Keychain item per key, not one per library name.** Opening a copy never evicts another
  file's key, and every key "move" becomes *add the new item, then remove the old one*.
- **One pure decider, one writer.** A single function reads the facts and says what is true and what is owed; a
  single reconciler is the only code that writes Keychain items, key files and the record. Nothing that decides
  ever writes, and nothing acts on a momentary reading.
- **Every act is a written-down plan,** kept beside the library (never inside it, never holding a secret), so a
  crash at any step finishes or rolls back.
- **A copy never brings its own key and never lowers protection.** A backup of your library comes back in your
  library's current mode; a Castle library brought from another Mac keeps Castle.
- **The library knows which account it belongs to, and new writing belongs to that account too.** Signing out
  changes nothing; signing in to a different account never moves a library without asking.
- **A scenario test plays random sequences of everything a user can do** — two Macs and a phone, two Apple
  accounts, two Variorum accounts, backups, restores, sign-ins, sign-outs, a closed lid, a new fingerprint, a planted
  copy, crashes at every step — and checks the promises after every move. Real-Keychain drills stay the gates for
  what a model can't reach.

**What it buys you.** Five sentences that are true by construction, which the field guide can say plainly:

> 1. Standard or Castle is a choice you make for your library — and, once it syncs, for your account. Nothing
>    else changes it.
> 2. Opening a backup of your library brings back your writing as it was, in the mode your library is in now.
> 3. If you have a passphrase, every backup Variorum makes of your library from now on opens with it or your
>    twelve words — and, in Castle, with Touch ID on this Mac.
> 4. Backups made while your library opened through your Apple account still do. Entering Castle offers to bring
>    them into Castle, or to delete them.
> 5. Signing out never changes how your library is protected. If you sign in to a different account, Variorum
>    asks before moving your library to it.

**What it costs.** A real rebuild of the protection layer's middle — the part that decides and writes — not a
patch. The crypto, the vault and server, the key proof, rotations, the follow's substance, the lobby's roads and
backups-as-pairs all stay. By the repo's sizing guidance it is **several phases, not one**: one design sitting, then
about five phases in order (section 8). The first is fully headless, and it ends with a go/no-go at which a smaller
"middle road" (section 12) is still open, because nothing in the app has moved yet. Existing stores migrate once, at
first unlock, after per-shape drills. No server deploy is needed.

---

## Contents

1. [What I looked at](#1-what-i-looked-at)
2. [Why it keeps breaking](#2-why-it-keeps-breaking)
3. [The design](#3-the-design)
4. [The hard cases, step by step](#4-the-hard-cases-step-by-step)
5. [Every ticket, settled](#5-every-ticket-settled)
6. [What the research found that no ticket names](#6-what-the-research-found-that-no-ticket-names)
7. [Migration](#7-migration)
8. [The phases](#8-the-phases)
9. [Risks](#9-risks)
10. [What canon this changes](#10-what-canon-this-changes)
11. [The decisions I made](#11-the-decisions-i-made)
12. [What I considered and set aside](#12-what-i-considered-and-set-aside)

---

## 1. What I looked at

- **All 17 tickets** with every comment, and your #216 sitting verbatim (`notes/QUESTIONS.md`).
- **The canon:** `SyncSpec.md` in full; the original Castle design (`pre-13x-postures-design.md` §1–§14: the 35
  decisions, the key model, both switches, backups, the cross-device choreography, the 48 corners); the design
  history's account of why mode was made "derived, never a setting"; the VX-191 audit; the VX-201 record and
  handoff; the 13x portability plan; the phase-sizing guidance.
- **The code** that decides, writes and presents protection — about 25,000 lines in 53 files — read directly at
  the decision points (`Posture.derive`, `StoreLaunchGate.effectiveGate`, `LibraryOpenModel.landCustody`,
  `StoreKeyEnvelope.locate`, `StoreIdentity`, `CustodyCollisionRule`, `BackupRestoreCandidates`) and mapped in
  full by two research helpers.
- **The churn:** 213 commits touched the area between 6 July and 13 October; 52% of them have fix-like subjects, and
  in October it is 65% (40 of 62). The area grew from about 10,000 lines on 1 September to about 24,900 today.
  `ProtectionController` has taken 51 commits and `PostureSwitch` 43 (it grew 29% in October alone). After the
  pre-13x build itself, the tail is fix after fix on the same mechanisms: 13x, VX-99, VX-110, VX-202, VX-209,
  VX-203, VX-80, VX-201.
- **A cold read** of the first version of this proposal (`cold-read-1.md`), whose findings reshaped sections 3–12.

Your words from the original design sitting are the yardstick I measured this against:

> *"they all have a SINGLE encryption setting + posture. They may have different recovery mechanisms… but they
> just don't have all this key, sync, device key, escrow key, time machine loophole, etc."*
>
> *"sometimes you have to go through the whole building of the complexity to realize it is NOT the right shape."*

---

## 2. Why it keeps breaking

The research grouped every ticket and review finding in this area into thirteen root-cause patterns. They fold into
five causes, and four kinds of cost that follow from them.

### 2.1 The app guesses a library's mode

The original design made mode **derived, never stored**, for a good reason: *"Posture cannot drift between devices —
it is not stored anywhere but the vault's shape."* For a synced library that works: the vault is one truth that
every device reads.

A library that is not synced has no vault, and its key file alone cannot tell "Castle" from "Standard whose Apple
copy hasn't landed yet" — both carry no Apple copy. So the code looks at **which Keychain slot on this Mac holds the
key** (corner 45, `StoreProtection.swift:101-109`): the silent slot means Standard, the Touch ID slot means Castle.
That slot is device state named by the library's ID, and every copy of the library shares the ID.

`Posture.derive` takes five inputs (`StoreProtection.swift:85-98`), and each caller gathers a different subset: the
route passes the slot's shape, the controller a cached vault answer, the Open Library confirm passes "unknown". The
mode is worked out at 6 places, read straight off the vault at 12 more, and turned into a gate at 5. On top of
that:

- the code has **five definitions of "enrolled"** (the route counts any sync-key record; the ready path counts a
  session or keys; the switch needs vault, transport, session and keys; the key doors read a cached state; the
  sync-key shape always says no);
- the controller's **cached vault answer is written in one place and never cleared** — it survives sign-out,
  account deletion and opening a different library;
- the controller infers the Keychain shape from **how the library was opened** (a key typed or brought in reads as
  if it were behind Touch ID), so right after any adoption the same library reads Castle for a moment (F-U5-5);
- doors choose Use Castle or Use Standard from that cached reading, not from the vault in hand (VX-108).

Nothing anywhere records "this library is in Castle". **Pattern count from the research:** 13 bugs where mode was
inferred from a local stand-in (VX-209, VX-228, VX-99, VX-108, VX-110, the 13x blocker, …).

### 2.2 One key slot per library name, many files per name

This Mac keeps the library key in **one** Keychain item per library ID (`<scope>-<storeID>-bound` or
`-biometric`). A library ID names many files: the live library, every backup pair, every older library in
`Previous Libraries/`, every adoption safety copy, every library sent to another Mac and back. Only one of them can
own the slot.

Opening a copy re-lands the slot (`LibraryOpenModel.landCustody`, `LibraryOpenModel.swift:509-545`). On VX-209's
way back that is fatal: restoring the Standard-era backup puts its key in the silent slot and **deletes the Castle
library's Touch ID item**; bringing the Castle library back finds the silent slot occupied, reads "Standard",
saves the Castle key silently, and the next check lands an Apple copy. The 13x `CustodyCollisionRule` decides
*which* key wins the one slot; with one slot, someone always loses. The pre-13x design review proposed a way out —
*"a store re-key mints a NEW store ID … old ID ↔ old key"* (P6(b)) — and it was not adopted.

The same shape appears in key files: several fingerprint-named key files can sit beside one library, and "the
current one" is the one with the **newest modification date** (`StoreKeyEnvelope.swift:482-497`). The design said
to try each and keep the one that opens; that was never built. A Time Machine restore or a copy can flip it.

**Pattern count:** 6 bugs from one slot shared across copies; the per-name switch flags, dials and sync keys are
shared the same way.

### 2.3 Deciding writes, and writes come from everywhere

`StoreLaunchGate.effectiveGate` (`StoreLaunchGate.swift:405-427`) decides how a library opens — and under some
conditions also wraps the library key under the Apple key and saves the key file (`:411-420`). It is reached from
six places: the launch route, adoption, the ready check, the migration, Lock, and **the phone's relock check on
every scene change**. Any of them can turn a library Apple-openable; that is why VX-209 completes within the same
session (F-U5-6).

More broadly, nine functions write the library key's Keychain items — and only one of them checks its write before
deleting the old item — five write the sync keys, sixteen write, move or delete the key file, and nine write the
vault. They are reachable from seven independent tasks (the route, ready housekeeping, the re-land, the lobby's
Apple probe, the switch runner, adoption, the reconcile), and even reading the silent item can migrate old items
and create a key file. Safety depends on each being right at once, so each incident added a belt: the custody
queue, `switchInProgress`, `suspendForAdoption`, `switchPending`, VX-202's two gates and two belts. Adoption writes
the Keychain with its results thrown away and without the verify-then-delete rule written after a key was once
lost (`LibraryOpenModel.swift:533-543`). And a momentary reading already changes custody: today's migration and
Castle switch read a closed MacBook lid as "no Touch ID" and act on it (`ProtectionMigration.swift:240-244`,
`PostureSwitch.swift:1330-1333`).

**Pattern counts:** 8 "a read that writes", 8 races between unordered writers, 8 writes whose results are
ignored or skip the handover rule.

### 2.4 Old copies remember only their own day

Decision 11 — *backups are never rewritten* — is a good rule, and I keep it. But nothing else remembers a
library's old keys. When a key is retired (entering Castle, Replace All Keys, the follow), each older copy can be
opened only by what its own key file carried on its own day. If that day had no passphrase and no Apple copy, the
copy's own key file has **no road at all** (VX-263 / W-1). The only file that does hold a road is the leftover key
file beside the library — which VX-213 wants to delete and which the restore list never reads
(`BackupRestoreCandidates.swift:85-122` reads only the copy's own key file).

And there is no single list of copies: at least six separate folder scans with their own rules, and three copies
of the backup-name parser. Each new kind of copy (13x's older libraries and safety copies, hand-offs) stays
invisible to the older code until a ticket adds it (VX-203, VX-210). Leftovers are kept forever with no recorded
purpose — the doctrine "never delete, its wraps are somebody's recovery legs" — so each later ticket guesses
whether a leftover matters, and the guesses disagree (VX-213 against VX-263). Every adoption keeps the outgoing
library **twice** (`Previous Libraries/` plus a safety copy), and neither is ever pruned.

**Pattern counts:** 10 frozen-copy bugs, 9 copy-discovery bugs, 8 leftovers-without-a-purpose.

### 2.5 Long acts can't always finish

| act | resume record today |
|---|---|
| Use Castle, Replace All Keys, the follow into Castle | a step marker — **stored inside the library file** (`sync_state`) |
| Leave Castle, the follow into Standard, sync setup, enrolling, Connect, change passphrase, regenerate words, re-link, opening a copy | **no resume record** — each relies on the next reconcile to heal, or on nothing (opening a copy leaves a restore-hold marker, which holds sync but resumes nothing) |

Where a marker exists, it does not carry everything its later steps need: a crash after the `.rekeyLibrary` marker
but before the new key file lands can never be resumed (VX-235); "another device switched" lives only in memory
(VX-107); `CorpusRotation.begin` re-fetches the vault instead of using the revision the door read (VX-109). Because
the marker lives inside the library file, **the Castle switch's own fresh backup carries a half-finished switch**:
restoring it lands a library that refuses to sync until a resume runs. Opening a copy has a crash window in which
the app quietly starts a fresh empty library at your library's place, in either mode (traced from code, not
reproduced).

**Pattern count:** 12 crash-window bugs.

### 2.6 What the causes cost

| cost | count | what it looks like |
|---|---|---|
| Words that overclaim or describe the design instead of the code | 19 | "They still open through your Apple account, and they always will" (VX-263); "Variorum can only delete its own backups" (VX-210); Data Safety says restoring is "a Finder operation, not a button" right under the Restore list; recovery text names a key file modern folders don't contain |
| Sheets with no host, two hosts, or lost across lock | 11 | VX-243, VX-239, VX-206, VX-240 |
| Test worlds that drift from reality | 9 | VX-233 (the one end-to-end drill red since September), VX-106, a test that once overwrote your live custody |
| Duplicated deciders that disagree | 8 | VX-99's two Apple-copy deciders; two rules for whether the Castle offer appears; two different "Restore from a Backup" doors |

Your question at #216 — *"do we not know what happened?"* — is the design's fault, not the copy's. When the app
guesses, its words have to hedge.

---

## 3. The design

### 3.1 The rules (what users are told)

> 1. Standard or Castle is a choice you make for your library — and, once it syncs, for your account. Nothing
>    else changes it: not opening a backup, not signing out, not signing in to another account.
> 2. Opening a backup of your library brings back your writing as it was, in the mode your library is in now. (A
>    synced library then catches up with your other devices when you resume sync.)
> 3. If you have a passphrase, every backup Variorum makes of your library from now on opens with it or your twelve
>    words — on this Mac, and on another Mac with your newest backup beside it — and, in Castle, with Touch ID on
>    this Mac. Backups from before keep the roads they were made with.
> 4. Backups made while your library opened through your Apple account still do. Entering Castle offers to bring
>    them into Castle, or to delete them.
> 5. Signing out never changes how your library is protected. If you sign in to a different account, Variorum asks
>    before moving your library to it.

Everything below exists to make these sentences always true and checkable by a test. The route finder (3.6) is the
only source for any sentence about what opens a particular copy, so the words can never claim more than the keys
allow.

**Unchanged for users:** the two modes and what each protects against; the passphrase and the twelve words; the
Apple-account key in Standard; Touch ID / Face ID and Always ask; the lobby's three roads and the vault road;
entering and leaving Castle; Replace All Keys; the follow on other devices; backups as pairs, never rewritten by the
app on its own; the restore hold and Resume Sync; older libraries kept in `Previous Libraries/`.

### 3.2 The facts, each with one home

| fact | home | written by | travels with copies? |
|---|---|---|---|
| **The protection record** — the library's ID, its mode, and the account it belongs to (none, or one) | a one-row table inside the library file, in the local-only family (so the plaintext export leaves it behind) | the reconciler | yes — every backup and older library carries the record of its day |
| **The key file** — the library's ID; the **current key** wrapped under the passphrase, the words, the account master (synced) and the Apple key (Standard only); and the **key history**, every earlier key of this library | **one** file beside the library (format 3, under a new file name older builds don't read); each backup pair keeps its own copy, written with it, never rewritten | the reconciler | yes — a pair's key file is the whole key file of its day |
| **The history key** — opens the key history | wrapped in the key file under the passphrase and the words **only**; in Castle also kept in this device's Touch ID item; never in a silent item, and never under anything the Apple account can reach | the reconciler | inside the key file, wrapped |
| **This device's keys** — one Keychain item **per library key**, named by the store variant, the key's fingerprint and its class (silent or Touch ID); in Castle it also holds the history key. Plus one sync-keys item per library (master, corpus key, device identity — as today) | the device Keychain | the reconciler | no — device-only, as today |
| **What this device remembers** — which library lives at the app's library location; per library ID, its current key's fingerprint, the mode and account last confirmed here, and this device's preferences for it (Touch ID or Always ask — set only by you — the idle lock, the scheduled Markdown export, dismissed nudges) | one small, non-secret, device-only Keychain item per library ID, store-variant scoped | the reconciler (preferences: their own doors) | no |
| **"A library lived here"** — the evidence the missing-library screen needs | a marker file in the app's own container, beside the library | the reconciler | no — deleting the container or reinstalling clears it, so a fresh start stays a fresh start |
| *(unchanged)* **The account's vault** — the account's mode and keys | the server | key acts, under the key proof | — |

What this table removes: the mode inferred from a Keychain slot (corner 45); several key files per folder with
"newest wins"; one Keychain slot shared by every copy of a library; the in-file step marker.

In steady state each library has exactly one key item on a device — its current key's; older keys live only in the
history. Naming items by key is what lets a re-key add the new item before removing the old one, and guarantees an
item can only ever be used for the file its key opens — so opening one copy can never take another copy's item. The
store variant stays in every name, as today, so the dev store never reads the real store's items (the phone's Debug
and Release builds share one Keychain).

**Why the record lives inside the library file.** It is then protected for free — only the library's key can read
or change it — it travels with every copy, matching that copy's content exactly, and it cannot be separated from
the writing it describes. On a Mac that has never seen the library, it is the only trustworthy statement of its
mode: someone who can edit files can strip wraps from a key file, but cannot rewrite the record of a Castle library
without its key. It is read after unlock, which is when every decision that writes is made; before unlock the app
only needs to know which roads exist (3.4). A copy's record is never trusted to lower anything (3.6).

**Why the history key opens only with your secrets.** The history key lets your passphrase and words — and, in
Castle, Touch ID — open every older copy, and lets a passphrase change or a words regeneration re-lock the whole
history without asking for the old word. It is never wrapped under anything the Apple account can reach: not the
Apple key, and not the account master or the library key, both of which get Apple-held copies in Standard. So
leaving Castle, joining a Standard account or moving to one never makes a key that was retired in Castle reachable
through the Apple account. In Standard the history key is not kept on the device at all, so an older-key backup asks
for your passphrase or words. It is replaced at every re-key (entering Castle, Replace All Keys, the follow), with
the whole history re-locked under the new one. When only one of your secrets is typed (the follow takes one), the
other one's wrap lands the next time that secret is typed here, as the library key's own wraps do today.

**"Enrolled" becomes three plain facts,** each named where it's used: *the library belongs to account X* (the
record); *this device has X's sync keys for it* (the Keychain); *signed in as X* (the session). The five current
definitions go.

### 3.3 One decider, one writer

- **`assess(facts) → assessment`** — one pure function. In: the record, the key file, which Keychain items exist,
  what this device remembers, the session, the vault (if read in this session, for this account), and any plan in
  flight. Out: the library's mode and account, each *confirmed* or *not yet confirmed*; the roads that open it;
  which doors are open and why; and the **repairs owed**. It never writes. The route, the lobby, the doors, the
  views and the sync engine's key provider call it and nothing else. It replaces `Posture.derive`, the gate's
  decision half, the controller's posture projections and the doors' private checks.
- **The reconciler** — the only code that writes Keychain items, key files, the record and what this device
  remembers. It runs whenever an input changes — unlock, sign-in, sign-out, a vault read, the end of an act — and
  as the steps of a plan. Each repair is idempotent, checks the world before acting, and verifies before it
  deletes. Repairs move toward the record, under three guards:
  - **Decision 35, made explicit:** no repair that adds Apple reach runs on a synced library without a fresh vault
    read for its account, and nothing Apple-reachable is written while the mode is not yet confirmed.
  - **The Apple key's minting rules carry over unchanged** (today's `mintAllowed` and "waiting" guards), so a device
    never mints a second Apple key that iCloud Keychain might later discard.
  - **Nothing acts on a momentary reading.** A Touch ID item is never removed because Touch ID is unavailable right
    now (a closed lid, an unplugged keyboard, a lockout after failed tries).

  The repairs themselves:
  - **Castle:** every key of the library lives behind Touch ID or nowhere — no silent item for any key it has had;
    the current key has no Apple wrap (if one is ever found, the repair is a re-key, since an Apple wrap may have
    been copied elsewhere). When Touch ID changes on the device (a finger added or removed), the Touch ID item stops
    working — by design, so that someone who knows the login password can't enrol a finger and get in. Variorum then
    asks once — *"Touch ID changed on this Mac. Use Touch ID for Variorum again? Every finger enrolled on this Mac
    will open it."* — and puts the item back only on that yes; otherwise the passphrase stays the road.
  - **Standard:** the Apple wrap lands when the Apple key is readable (under the guards above) — "waiting for iCloud
    Keychain" is a fact in the assessment, not a guess; the silent item holds the current key and nothing else; a
    leftover Touch ID item and any history key kept on the device are removed.
  - **Agreement:** the record, what this device remembers and the key file agree; the sync keys match the record's
    account.
  - **The follow:** a synced library whose vault says another mode follows it — into Castle by typing the passphrase
    or words once, into Standard automatically with a notice, both as today. It is an act with a plan, not a repair.
- **Touch ID or Always ask is your stored choice,** never a reading. If Touch ID can't be used when you enter Castle,
  the switch says so and records Always ask as your choice — instead of today's mismatch, where the key lands
  "nowhere" while the setting still says Touch ID.

### 3.4 Before unlock: roads, not modes

The lobby decides from **which roads exist**:

1. a silent Keychain item for this key → open without asking;
2. a Touch ID item for this key → Touch ID, the passphrase as fallback;
3. an Apple wrap in the key file and the Apple key readable → open without asking; an Apple wrap but the key not yet
   readable → "Getting your key from iCloud Keychain…", with the passphrase and words as doors;
4. otherwise → the passphrase or twelve words (and, signed in, the vault road).

Its words follow the road, so they are always true. "This key" is the one the library file is under: during a
re-key, the plan names which key that is until its commit point, and the lobby reads the plan, so it never offers the
new key's roads for a library still under the old one (the VX-80 class). Whether the library *should* be in Castle is
decided after unlock, from the record, and any mismatch is repaired then, in the safe direction. If what this device
remembers says the library is in Castle but a road opened it without asking (only possible for an older copy whose
key file still carries an Apple wrap), the reconciler brings it into Castle straight away and says so.

**A missing library is missing in both modes.** Today, under Standard, a library file that vanished is replaced by
a fresh empty library without a word. With the container's "a library lived here" marker, the app shows *"Your
library file is missing — restore it, open another, or start a new one"* whichever mode it was in. Deleting the
app's container or reinstalling removes the marker, so a deliberate fresh start still starts fresh.

**A missing key file is not fatal.** What this device remembers names the library at this location and its current
key, so Touch ID or the silent item still opens it. The app then asks for the passphrase once to rebuild the key
file's wraps, and takes the history from the newest backup's key file.

### 3.5 Every act is a written-down plan

Every act — Use Castle, Leave Castle, Replace All Keys, the follow, sync setup, enrolling, Connect or moving an
account, This Mac Only, stopping sync here, changing the passphrase, regenerating words, re-linking, opening a copy,
and the migration — becomes a **plan** written to disk before its first step:

- **Kept beside the library on this device, never inside the library file**, so no backup or copy of the library
  can carry a half-finished act. Plan files are excluded from Time Machine and other backups, and a plan whose world
  doesn't match (copied to another Mac, say) is ignored as stale.
- **Facts captured up front, never secrets.** The plan records the vault revision the door read (VX-109: `begin`
  uses it, so a concurrent change elsewhere is refused by the server's existing check and the retry becomes the
  follow), "another device switched" and the words rule (VX-107), the target mode and the target account. It never
  holds the passphrase, the words or a key derived from them; a resume that needs one asks again.
- **Prepare, then commit:** the new key goes into its own Keychain item and its key file is written *before* the
  library is re-keyed (VX-235: no step can point at a key that doesn't exist yet). Moving a key is always *add the
  new item, verify, then remove the old one*, so there is never a moment when the only copy of a key is in flux
  (VX-202's race had nothing else to race against).
- **Backups pause only while the library file itself is being swapped,** never for the whole length of an act — a
  rotation that stalls offline doesn't stop your backups.
- Steps are idempotent; resume runs from the first step whose result is not yet true; a step that cannot finish
  rolls back to a state the assessment recognises. One plan per library at a time; a second act waits with a
  sentence.

The vault's own rotation protocol on the server — the previous corpus key, the rotation seq, version-neutral
re-encryption, one rotation at a time — is unchanged.

### 3.6 Copies: backups, older libraries, exports

**One catalog of copies.** One module knows every place copies live — the backup folder, the second backup folder,
`Previous Libraries/`, the lock-time copies, and the set-aside `.stale-` key files — with one name parser. The restore
list, Open Library, the Castle offer and retention all read it, so a new kind of copy is added once and seen
everywhere.

**One route finder.** For a copy under key *K*, it gathers every road that reaches *K*: the copy's own key file; the
live key file's current key and history; every other key file in the catalog (a newer backup's history reaches older
keys anywhere); this device's Keychain item for *K*; the account master (synced); the Apple key (copies whose key file
carries an Apple wrap). It answers in plain words — "Touch ID", "your passphrase or twelve words", "the passphrase you
had on 3 September", "your Apple account", or honestly "nothing on this Mac opens it". It is the only source for any
sentence about what opens a copy — the restore list, the confirm, the offer, the field guide — and the scenario test
checks that every road it names actually opens the copy.

**Opening a copy as your library — the rule: a copy never brings its own key into your library, and never lowers its
protection.**

- **A copy of the same library from this Mac's own line** — its key is the library's current key or one in its
  history (any backup or older library made here, or by this library before): it is **re-encrypted under the
  library's current key** — straight from the staged copy into place, so no Apple-openable file ever sits at the
  library's place — and takes the library's mode and account. Any backup made since the last key change is already
  under the current key, so for most restores nothing is re-encrypted at all.
- **A copy of the same library from another Mac** (its key is unknown here): the same, except when the copy is in
  Castle and your library here is in Standard. Then opening it runs Use Castle's own steps first — your passphrase
  and words, a fresh key — or you cancel. Castle comes with a Castle library. A copy that says Standard never takes a
  Castle library out of Castle.
- **A different library** keeps its own key and mode; your current library is kept with your older libraries, as
  today.
- **A synced library** ends in its account's mode; after Resume Sync it catches up with your other devices. If the
  copy's writing belongs to a different account than the library's (a backup from before a Move), the open's plan
  runs the Move road — re-stamp and resync — as part of the open.
- **A plaintext export** carries the library's ID in a small plain table (not secret). A copy of the same library is
  encrypted under the library's current key and mode; anything else becomes a new library in Standard, and the
  confirm says so. Any landing that carries no sync bookkeeping gets a fresh sync identity on this device.

A copy's record is never trusted to lower anything, so a pair planted in your iCloud Drive backup folder by someone
in your Apple account can't install a key they know: if you open it, its writing comes in under your library's key.

The confirm states the outcome concretely, because the plan knows it before you press anything:
*"Your library goes back to how it was on 12 October. It stays in Castle."* ·
*"Your library goes back to how it was on 12 October, then catches up with your other devices when you resume sync.
It stays in Castle."* ·
*"This is a different library, in Standard: it opens without asking on Macs signed in to your Apple account. Your
current library is kept with your older libraries."* ·
*"This copy is in Castle. Your library here is in Standard, so opening it puts your library in Castle: type your
passphrase and twelve words."* No "check", no hedge (your #216 ruling).

**The restore list** shows backups and older libraries (VX-101's ask), each with its road. The library-missing
screen's *Restore from a Backup…* opens the same list instead of revealing a folder in Finder. Data Safety's prose
and `RESTORE.md` are rewritten to describe the doors that exist.

**Backups** are written exactly as today. The adoption's separate safety copy is kept only until the open finishes
(the older library in `Previous Libraries/` is the lasting copy), so each restore stops storing your library twice.

**The Castle offer**, after entering Castle, lists copies that still open through the Apple account — computed by the
route finder, so it never overclaims — in two groups with their own choices (VX-265):

- **Backups** of this library: **Bring them into Castle** (each copy re-encrypted under your current key into a new
  pair; the old pair removed only after the new one opens — recommended), **Delete them**, or **Keep them**.
- **Older libraries** — keeping your #216 wording's reach, *"older libraries Variorum kept when you opened or restored
  a different one"*: this library's own can be brought into Castle, deleted or kept; any other library Variorum kept
  can be deleted or kept (it can't be brought under this library's key).

It also clears the folder-level key files that carry old Apple-wrapped keys when the copies they serve are gone. One
line says what it can't reach (VX-210): *"Variorum only looks in its own folders on this Mac. Backups in a folder you
used before, on a drive that isn't connected, in Time Machine or copied elsewhere aren't touched and still open the
old way. Backups deleted from iCloud Drive stay in its Recently Deleted for 30 days."*

### 3.7 Accounts: the library knows where it belongs

The record names the account; with the session, that gives four situations — the whole state space, each with one
behavior:

| the library belongs to | signed in as | what happens |
|---|---|---|
| no account | nobody, or anyone | Local only. Signed in, the Encryption tab offers to turn on sync for it; nothing happens by itself. |
| account X | X | In sync; the library follows X's mode (into Castle by typing your passphrase or words once, into Standard automatically with a notice — both as today). |
| account X | nobody | Not syncing; nothing else changes. Use Castle and Use Standard each offer one plain road: the mode applies to this Mac only, and this Mac stops using the old sync account — your ruled screen for Use Castle (VX-264), and its mirror for Use Standard. *Stop syncing this library on this Mac* is there too. |
| account X | another account Y | Not syncing. One plain screen: *"This library syncs with x@…. You're signed in as y@…."* — **Move it to y@…** (today's Connect road, with the mode consent when Y's mode differs) or **Sign out**. If y@… has the same email as x@… but is a different account (the old one was deleted), the screen says that. |

- **New writing belongs to the library's account, not to whoever is signed in.** A library that belongs to X creates
  X-owned rows even while signed out or signed in as Y; a library with no account creates unowned rows, and joining
  an account claims them. (Today rows take the signed-in account when they are created, so writing while signed in as
  someone else mixes owners in one library.)
- **Sign out** never changes the record; the sync keys stay, as today.
- The account changes only through **This Mac Only**, **Stop syncing here**, **deleting the account from this Mac**,
  and **Move** — each a plan.
- **Signing back in to an account the library left** is an ordinary *turn on sync*, with its consent — not a follow,
  not a revert.
- Signing in or out re-runs the assessment at once (today sign-in runs no reconcile, so the screen can be stale until
  the next lock).

Your sequence — signed in, signed out, signed in to a different account whose library is in Castle, signed out,
signed back in to the original — is a walk through this table with a question at every account change and no silent
change at any step.

### 3.8 The scenario test

A headless test that builds a small world — two Macs and a phone, two Apple accounts, two Variorum accounts, a fake
server, fake Keychains and iCloud Keychain, real key files and real wraps (with test-speed passphrase stretching and
stand-in library files) — and plays **random sequences of everything a user can do**: create a library; set or change
a passphrase; regenerate words; Use Castle; Leave Castle; Replace All Keys; turn on sync; sign in as X or Y; sign out;
This Mac Only; stop syncing here; delete the account; back up; restore backup *n*; open older library *n*; open a
plaintext export; send a library to the other Mac; lock and unlock; add a fingerprint; close the lid or unplug the
Touch ID keyboard; get locked out of Touch ID; turn iCloud Keychain off and on; wipe a Keychain; replace a Mac; plant a
crafted pair in the iCloud Drive backup folder; **crash at any step of any act**, then relaunch. It also starts from
every shape today's builds can leave a store in, for the migration.

After every move it checks the promises:

1. **Known, not guessed:** every live library has one record, and what this device remembers agrees with it.
2. **Castle means Castle:** for a library in Castle, nothing reachable through the Apple account opens its current
   key; no silent Keychain item holds any of its keys; its account's vault has no Apple copy.
3. **Leaving Castle stays honest:** after a library leaves Castle — by Use Standard, joining a Standard account or
   moving to one — no key retired while it was in Castle opens through the Apple account or a silent item.
4. **Standard means Standard:** the Apple wrap exists whenever the Apple key is readable; otherwise the assessment
   says "waiting for iCloud Keychain".
5. **No silent change:** a library's mode or account changes only at a deliberate act (or the follow of one) — never
   at a restore, an open, a sign-in, a sign-out, a relaunch, a closed lid or a crash — and a copy never brings its own
   key or lowers protection.
6. **Nothing stranded:** given the passphrase and words the user has (or had when a copy was made), every copy the
   app ever wrote opens — except the one documented floor (no passphrase was ever set, and the only device that held
   the key is gone).
7. **Crash-safe:** after a crash at any step and a relaunch, the act finishes or rolls back and the live library
   opens; no copy ever carries a half-finished act.
8. **Converges:** every device of an account ends in the account's mode and keys.
9. **The posture law:** after entering Castle, nothing from before — old key files, old Keychain items, the old master
   — opens anything written after.
10. **Honest words:** every road the restore list names opens that copy; every sentence the confirm, the Done and the
    offer would show matches what the plan actually did.

**What it can't reach,** so it never stands alone: the real Keychain's behavior (the data-protection and file
keychains, access groups, how Touch ID invalidation looks), iCloud Keychain's propagation and conflicts, and the real
cost of passphrase stretching. The real-Keychain drills on a throwaway scope, the posture drill (VX-233, healed) and
the dev-store walks stay the gates for those. Red-on-old evidence for VX-209 is the existing stage-verified pin
`VX209WayBackRoundTripTests`, flipped when it's fixed; against today's rules modelled in the harness, W-1 fails promise
10 (the list says nothing opens a copy that something does open).

### 3.9 What gets deleted

Corner 45 and `RawKeyCustody`; the gate's Apple landing; adoption's Keychain writes; `CustodyCollisionRule`; the
13p-era stored mode after migration; several key files per folder and the newest-date rule; VX-202's belts and the
switch-pending flag (nothing outside the reconciler writes, so there is nothing to belt); the in-file step marker and
its dead `.offer` step; the duplicate safety copy; the five "enrolled"s; the confirm's "you'll be leaving Castle" line
and the field guide's older-copy warning (the behavior they warn about no longer exists); the second,
Finder-revealing "Restore from a Backup".

### 3.10 What stays exactly as it is

The crypto (AES-GCM, key wraps, Argon2id, the twelve words); the vault and its protocol (the key proof and its
challenge, CAS, the rotation seq, version-neutral re-encryption, one rotation at a time); the follow's substance; the
lobby's three roads and the vault road; backups as pairs, written once; the restore hold; `Previous Libraries/`; the
plaintext export's exclusions; the two-register copy rules; the device identity's home; the phone sharing the same
brains.

---

## 4. The hard cases, step by step

*(Each is also a fixed sequence in the scenario test.)*

**VX-209 — a Castle library, an older Standard-era backup, and the way back (local only).**
1. You restore the backup. The route finder opens it through your Apple account (its own key file) or Touch ID / your
   passphrase (the key history). The confirm says: *"Your library goes back to how it was on 2 October. It stays in
   Castle."* The copy is re-encrypted under your library's current key straight into place; the Touch ID item is
   untouched, because it belongs to that key, not to the library's name; the record says Castle.
2. You bring the Castle library back from your older libraries. Same library, same current key: nothing is
   re-encrypted and nothing in the Keychain moves. Castle.

**VX-209 — synced.** The same, and the record also names the account; after Resume Sync the library catches up and the
vault confirms Castle. There is no window where the live file opens through the Apple account (today: until the follow
runs).

**W-1 / VX-263 — entering Castle from "only this Mac can open your work".** The ceremony sets your passphrase and words,
re-keys the library, and puts the old key into the history. Every earlier backup opens with Touch ID, your passphrase
or your words. The leftover key file is gone because its one useful fact now lives in the history — VX-213 and VX-263
are both satisfied. (A library already in W-1's state today is handled by the migration: the leftover file's key joins
the history the first time the passphrase is typed.)

**Leaving Castle after a Replace All Keys.** The account master gains its Apple copy, as today. The history key isn't
under the master, the Apple key or the library key, and it leaves the device with the Touch ID item, so Castle-era
backups still open only with your passphrase or words.

**Signed out, then Use Castle or Use Standard.** *Continue* leaves the account on this Mac and applies the mode
locally; the Done says so (for Castle, ending with *"Set up sync again later with a new account and it starts in
Castle."*). Signing back in to the old account later is an ordinary turn-on-sync with its consent.

**Signed in to a different account.** Nothing syncs and nothing changes until you choose **Move it to y@…** or **Sign
out**; writing meanwhile still belongs to the library's account. Moving takes Y's mode with the consent screen when it
differs (Castle → Standard asks; Standard → Castle asks for Y's passphrase and re-keys).

**The account was deleted on another device.** You can't sign in to it any more. Signed out, the one-road doors (This
Mac Only for either mode) and *Stop syncing here* take the library off it. A new account under the same email is a
different account, and Variorum says so and asks before moving the library.

**Two Macs passing a local-only library back and forth (Send Library to Another Mac).** A library you put in Castle on
the Pro arrives in Castle on the Air: if the Air's copy was in Standard, opening it runs Use Castle's steps there. A
library you took out of Castle on the Pro doesn't take the Air out of Castle — you choose Use Standard on the Air.

**A copy planted in your iCloud Drive backup folder** by someone in your Apple account, claiming to be your library in
Castle. If you open it, its writing comes in under your library's key, never a key they know, and its claim can only
raise protection.

**A crash at any step of entering Castle.** The new key is in its own Keychain item and its key file is written before
the library is re-keyed; the plan holds every fact; relaunch resumes from the first unfinished step, and the lobby reads
the plan to know which key the library is under. The switch's fresh backup is taken after the commit point, so it never
carries the switch.

**A crash while opening a copy.** The plan records which library was moved aside and where; relaunch finishes the
landing or moves your library back. It never starts a fresh empty library in its place.

**Opening a copy while your library is locked or missing.** Touch ID or the silent item still reaches the library's
current key through what this device remembers, so the copy is brought into the library's mode as usual. Only on an
Always-ask device with the key unreachable does the open ask for your passphrase and words; it never lands the copy in
a lower mode.

**A new Mac, from backups only.** Copy the backup folder over and open the newest pair with your passphrase or words;
its history opens every older pair made from the new build on. Older ones open with the roads they were made with.

**Touch ID changed (a finger added or removed).** The passphrase opens the library; Variorum asks once whether to use
Touch ID again, saying every enrolled finger will open it, and puts the Touch ID item back only on yes.

**The lid is closed, the Touch ID keyboard is unplugged, or Touch ID is locked out.** The passphrase opens the library
for that open; nothing is removed; Touch ID works again when it's available.

**A Mac without Touch ID.** The Castle switch says Touch ID isn't available and records Always ask as your choice;
every surface agrees with it.

**iCloud Keychain off (Standard).** "Waiting for iCloud Keychain" is a fact in the assessment; the exposed nudge speaks;
the reconciler lands the Apple wrap as soon as the key is readable. No guess about Castle is ever made from it.

**Always ask.** No Keychain item holds the key; every road is typed. The history works the same way.

**Someone puts an older, Apple-openable copy where your library was.** It opens through the Apple road, as it would
today; after unlock, its record says Standard while this device remembers Castle, so the reconciler brings it into
Castle at once and tells you what it found.

---

## 5. Every ticket, settled

| ticket | how the design settles it | phase |
|---|---|---|
| **VX-209** way-back revert | mode lives in the record; copies come into the library's mode and never bring their own key; per-key Keychain items; nothing that decides writes. FLIP `VX209WayBackRoundTripTests`. | open road, copies |
| **VX-228** corner 45 redesign | corner 45 is deleted. Its stranding tradeoff dissolves: a copy may open by any road it has (the Apple key included), and is then brought into the library's mode. | core, open road |
| **VX-263** W-1 | the key history; the route finder reads every key file in the catalog; the offer's words come from the route finder; today's W-1 libraries are folded in by the migration. | core, open road, copies |
| **VX-264** your #216 rulings | items 1–6 built as ruled, plus the same one-road screen for Use Standard signed out; item 7 (the concrete confirm) becomes the plan's own outcome sentence; the guide's older-copy warning retires. | acts, copies |
| **VX-265** separate delete choice | the offer's two groups, each with its own choices, keeping your #216 reach. | copies |
| **VX-210** other folders | the one line, as ruled, with iCloud Drive's Recently Deleted named. | copies |
| **VX-235** unfinishable marker | prepare-then-commit plans: key item and key file before the step moves; the migration clears today's stuck markers safely. | core, open road |
| **VX-107** double crash loses facts | the plan captures "another device switched" and the words rule. (`Sync/` — Fable.) | acts |
| **VX-108** doors gate on a stale reading | doors read the assessment; key doors re-check the vault they fetch, and the plan carries that revision. | acts |
| **VX-109** `begin` re-fetches the vault | `begin` takes the door's revision. (`Sync/` — Fable.) | acts |
| **VX-212** poison row | not settled by a one-liner. It needs its own design in `Sync/` (Fable) and your ruling — for example a named stuck state in which the unreadable rows stay sealed and are listed, never deleted, the previous key stays wrapped under the new master (no exposure), and "one rotation at a time" gains an explicit way out. | sync item |
| **VX-213** tidy-ups | item 1 is resolved by the key history (no leftover file; its key isn't lost); the duplicate-add class can't recur (the item's class is in its name, items are never updated in place); 13p escrow items for keys now in the history are removed; `pg_temp` is a server function fix at your go; the record corrections are doc lines. | open road, copies |
| **VX-211** passphrase strength | a built-in strength check (no new dependency); any suggested passphrase is shaped visibly unlike the twelve words so the two are never confused; the 12-character floor stays. | copies |
| **VX-239** sheet hidden after lock | one presenter owns where every protection sheet shows, and re-presents an in-flight plan after unlock. | acts |
| **VX-243** follow sheet on two windows | the same presenter: one host at a time. | acts |
| **VX-233** drill rot | the switch runner takes its dependencies explicitly (no task-local reach); the drill is green again and joins the gates. | acts |
| **VX-266** flagship | this proposal → your review → the plan file `notes/plans/vx-266-castle-backups-prelaunch.md` → the phases. | — |

Six open tickets outside the project touch the same code, and the design settles or simplifies each — yours to fold
in: **VX-100** (a copied library asks for the passphrase twice — the open and the enrollment run in one session, so
the word typed to open can be used again in memory), **VX-101** (the restore list offers older libraries — included
above), **VX-102** (a landed copy inherits the source's flags — the open's plan), **VX-104** (an end-to-end
older-library drill — a fixed sequence in the scenario test), **VX-152** (Lock isn't reentrant — one plan at a time
and one writer), **VX-240** (a wrong instruction while a re-key or restore runs — the presenter).

---

## 6. What the research found that no ticket names

Each of these falls out of the design rather than needing its own fix. The research read each one in the code; none
was reproduced on a device, so each gets its red-on-old pin before it counts as fixed. Where one is user-visible today,
I'd file it as a ticket under VX-266 at your word.

| found (research file) | today | after |
|---|---|---|
| The Castle switch's own fresh backup carries the half-finished switch inside it (backups §8 S-9) | restoring it lands a library that won't sync until a resume runs | plans live beside the library, never in it |
| A crash mid-open leaves a fresh empty library at your library's place (backups §8 S-2, in either mode — cold read n1) | silent | the open is a plan; a missing library is "missing" in both modes |
| A finger added or removed silently sends every later launch to the passphrase for good (custody §4.16) | the Touch ID item is never offered back | Variorum asks once, and puts it back only on your yes |
| A closed lid already reads as "no Touch ID" to today's migration and Castle switch (custody §8 S-8; cold read M4) | they act on it — Always ask is forced, or the key lands nowhere while the setting says Touch ID | nothing acts on a momentary reading; the gate style is your stored choice |
| Leaving Castle can leave the Touch ID item behind forever (custody §4.5, §6b row 2) | nothing deletes it under Standard | Standard repairs remove it |
| The cached vault answer survives sign-out, account deletion and adoption (custody §5 H6) | posture-driven writes can act on it | the vault answer is tied to the session and account |
| Sign-in runs no reconcile (custody §4.9) | the pane can be stale until the next lock | the assessment re-runs at sign-in and sign-out |
| Every restore keeps your library twice, forever (backups §8 S-13) | `Previous Libraries/` + a safety copy, never pruned | the safety copy lasts only until the open finishes |
| Two different "Restore from a Backup" doors; Data Safety contradicts itself; recovery text names a file that doesn't exist (backups §8 S-6, S-8, S-10, S-14) | confusing | one list, one door, prose rewritten |
| The restore list skips the second backup folder and older libraries (backups §2.1) | invisible | the catalog lists them |
| Adoption ignores Keychain results and skips verify-then-delete (backups §8 S-5) | a failed save can still delete | only the reconciler writes, always verifying |
| The phone runs the writing check on every scene change (custody §7 M3) | an Apple copy can land on any app switch | decisions never write |
| Deleting the account leaves the library "enrolled" with a dead key, forever (custody §8 S-19) | undecided mode; the Apple step and migration legs never run | deleting it here is an account change to local-only; elsewhere the signed-out doors |
| A failed vault read (offline, signed out, no vault, any error) keeps the previous answer (custody §8 S-17) | an old answer can drive a write | the assessment marks the vault "not read", and nothing that writes acts on it |
| Leave Castle acts on a guessed reading (custody §8 S-22) | can run on a stale or undecided reading | key doors read the vault they fetch |
| The scheduled Markdown export setting isn't per library or per store: entering Castle on the dev store switches it off for the real store too (custody §8 S-13) | settings bleed across libraries and stores | kept per library in what this device remembers |
| Nudge and reminder dismissals are shared by every library on the Mac (custody §8 S-12) | a new library inherits old dismissals | kept per library in what this device remembers |
| "Your Apple account holds a key" is said for every Standard library, including ones still waiting for iCloud Keychain (custody §8 S-15) | overclaims | the words come from the assessment's facts |
| 13p escrow items — a raw library key in iCloud Keychain — survive when they belong to a key no longer in hand (VX-191 §O.2) | against design law 28 ("iCloud holds a key to a wrapped copy, never the copy") | the migration removes those for keys it puts in the history |
| Writing while signed in to another account mixes row owners in one library (cold read M2) | rows take the signed-in account | rows take the library's account |

---

## 7. Migration

Existing stores — yours, the dev stores, the beta testers, and anyone who installed a 0.9 build — migrate once, at
first unlock on the new build, as a plan, so a crash mid-migration resumes:

1. **Finish anything in flight first.** A pending switch or follow is resumed with today's runner before anything
   moves. VX-235's stuck marker is cleared when the library still opens under its old key and the new key file never
   landed (the switch never happened); the switch then starts again from its door. A This-Mac-Only flag carries into
   the plan, so its honest Done survives.
2. **Work out the mode one last time with today's rules.** A synced library with the vault in reach takes the vault's
   word. A synced library with no vault in reach (signed out, or its account deleted) records the mode it acts as
   today, marked *not yet confirmed by the account*: it writes nothing Apple-reachable until a vault read confirms
   it, and the follow runs if the vault disagrees. Where today's state is ambiguous (a passphrase, no Apple copy, the
   key in the silent item — corner 45's case), it records Castle, so nothing Apple-reachable is written, and says so
   once, with Use Standard one press away.
3. **Write the record and what this device remembers.**
4. **Add the per-key Keychain items,** store-variant scoped, same class, verified. The old per-library-ID items are left
   in place, unread, for at least one release, so an older build can still open the library. They are removed at the
   first re-key under the new build (Castle allows no silent copy of any old key) or after that release.
5. **Write the one key file under its new name,** which older builds don't read; the old key files stay where they are
   for the same release. Their keys join the history once the history key can be made — the first time your
   passphrase is typed. The first unlock after the migration asks for it once if there are old keys to fold, as the
   pre-13x migration did. Until then, the old key files stay the roads to the copies they serve.
6. **Remove 13p escrow items** for keys now in the history.
7. **Run the route finder once over the catalog.** If any of this library's copies still open through the Apple
   account — VX-99 found 13 such pairs on your Pro on 8 October, some of which backup rotation may have pruned since —
   the Castle offer appears once.

**The road back.** Until the first re-key under the new build, an older build still opens the library: its Keychain
items and key files are untouched, and it doesn't read the new file. After a re-key, the road back is the A1 safety
copy taken before the migration, with your passphrase and words.

**Drills.** The scenario test starts from every shape today's builds can leave a store in — exposed, Standard-waiting,
the VX-202 and VX-209 victims, Castle on a Mac without Touch ID, signed out with keys, a deleted account, a stuck
VX-235 marker — and checks that each migrates to the right record without writing anything Apple-reachable it
shouldn't. The Keychain leg can't run on the real or dev scopes from a test process (the Keychain test tripwire refuses
them, by design), so it is drilled on a throwaway scope and by running the Debug app on the dev store under a held
stage claim — including W-1's repro (kept at `Backups/safety-copies/castle-W1-20261013/`), whose old backups must
open with the dev passphrase afterwards. Your Pro's and Air's stores are rehearsed on byte-copies first.

Copies made before the new build have no record inside them; opening one works its mode out once with today's rules,
like the migration — and a copy never lowers protection anyway. Old backups' key files (formats 1 and 2) are read as
they are, forever.

**No server deploy:** the record is a local-only table — no lockstep, the marker stays 13. The one optional server
change is VX-213's `pg_temp` fix, at your go.

---

## 8. The phases

**By the repo's sizing guidance, this is several phases, not one.** A posture model is phase-sized; a custody unit is
one road, proven by that road's drill; a phase holds at most two phase-sized units, and a third is a split. Your plan
was one sitting and one run; the guidance allows one design sitting to rule several phases, and the pre-13x build this
replaces took twelve implementer sessions. I recommend one sitting, then these phases in order, each its own ticket
under the project at your word:

1. **The core, headless** (`Sources/VariorumCore/Protection/`): the record, the key file and its history, the per-key
   Keychain interface, what the device remembers, `assess`, the reconciler's repairs, the plan runner, the catalog and
   route finder, and the scenario test with its fakes — including today's shapes as starting states. No stage, no app
   change. **It ends with a go/no-go:** if the core shows the full design is too much before launch, the middle road
   (section 12) is still open, because nothing in the app has moved yet.
2. **The open road:** the lobby and route on roads, the per-key items and the record going live, and the migration.
   This is the riskiest phase, because it touches every existing store; its evidence is the per-shape migration drills
   and the dev-store run.
3. **The acts:** entering and leaving Castle, Replace All Keys and the follow on plans (VX-107, VX-109 and moving the
   step marker out of the library file are Fable's `Sync/` lines here); then the account doors — setup, enroll,
   Connect and Move, This Mac Only, Stop syncing here — and the key doors. One road per unit, each with its drill. Likely
   two phases.
4. **Copies and words (Mac):** the restore list, Open Library and the open rule, the Castle offer, the plaintext export,
   Data Safety and `RESTORE.md`, the copy rulings, VX-211.
5. **VX-212,** designed with you first, as a small `Sync/` effort under Fable.

**Cast and rules.** This is *the* custody/`Sync/` effort while it runs. Fable orchestrates and cold-reviews every round;
Opus implements, except the `Sync/` lines, which Fable writes. Every bug-class change lands red-on-old. No new
dependency. Each phase's closeout re-reads the rulings it built against what actually shipped — above all the
"every", "never" and "all" in the five rules and the scenario test's promises — and tickets any remainder (your
2026-10-13 closeout rule).

**The riskiest part** is the migration and the open road: a defect there strands someone at launch. **The cut lines** if
time runs short: the bring-into-Castle choice (rule 4's second sentence then reads "offers to delete them"), the restore
list's older-libraries section, and the road-based lobby wording.

---

## 9. Risks

- **A rebuild right before launch.** Mitigated by the order: the rules are proven headless first, with a go/no-go before
  any app code moves; the app moves onto them road by road with drills; the migration is drilled per shape before any
  real device sees it.
- **Migrating stores we haven't seen.** 0.9 builds are public, so the migration has to handle every shape today's code
  can produce, not only yours. That is why it finishes in-flight acts first, writes nothing Apple-reachable while a mode
  is unconfirmed or ambiguous, and keeps the old items and files for a release.
- **Re-encrypting a copy when it opens** takes seconds for a typical library, on the same road the Castle switch uses
  today; the picked file is still never written.
- **The record lives inside the library file,** so a library that can't be unlocked can't state its mode — but nothing
  that writes runs before unlock, and the roads before unlock are facts.
- **Test fakes that drift from the real Keychain** — the very pattern behind VX-233 and VX-106. The fakes are built
  from the Keychain facts already measured and pinned (the pre-13x spike memo), and the real-Keychain drills, the
  posture drill and the dev-store walks stay the gates.
- **Scope creep.** The ticket list is the scope; section 6's items come free with it or not at all; the cut lines are
  named so they can be cut cleanly.

---

## 10. What canon this changes

If you accept the design, these lines change at the closeouts — each as a contract line with a pointer to your ruling,
as the canon rule asks:

- **The original Castle design** (`pre-13x-postures-design.md`): §3.1's posture row ("derived, never a setting")
  becomes "recorded in the library and reconciled"; §3.1's dials row ("UserDefaults per store ID") becomes what the
  device remembers, per library; §3.3's "exactly those four" local-only tables becomes five; §3.5 (format 2,
  fingerprint naming, the try-each rule) becomes format 3, one file, the history; §3.7 and decision 14 (the
  missing-library route) now cover Standard too; decision 8's local-only half ("each library's posture is its own key
  file's") becomes "its own record's"; decision 11 gains the bring-into-Castle exception at your press; decision 13
  ("custody items are scoped per store ID") becomes per key; corner 4 (pre-switch copies keep the Apple road) gains the
  offer to bring them in; corner 36 (no Touch ID) becomes your stored choice; corner 45 is retired; §6's one user
  sentence is replaced by rule 3.
- **AppSpec §7:** the record table (local-only, no lockstep) and the key file's format 3; the `sync_state` key
  `rekey_in_progress` retires. **AppSpec §12:** 13x's custody-collision clause; the restore list's reach; one restore
  door; the Castle offer's groups.
- **The 13x plan:** the row-4 custody-collision memo is superseded; ledger 5 (a plaintext landing gets a fresh key and a
  fresh library ID) changes to "the same library's ID when the export carries it, with a fresh sync identity".
- **SyncSpec §3** (the pre-13x paragraph): custody per key; the rotation's resume record leaves the library file.
  VX-212's design, once ruled, adds its own line to SyncSpec.
- **OverallModel:** nothing. No invariant is relaxed; the posture law becomes promises 3 and 9.

---

## 11. The decisions I made

Each is mine, made so the design could be complete; each is yours to accept, change or reverse, and would be recorded
with your words on the ticket named.

- **Mode belongs to the library, not to a copy:** opening a backup brings back writing in the library's current mode.
  *This reverses the premise of your earlier yes to the "you'll be leaving Castle" confirm line* (VX-209's comment of
  2026-10-13): the new confirm says the library stays in its mode. → VX-209
- **The protection record lives inside the library file,** in the local-only family (no lockstep). → VX-228
- **One key file per library, with a key history behind a history key** that only the passphrase and words open — and,
  in Castle, Touch ID on this Mac — never anything the Apple account can reach; replaced at every re-key. This settles
  VX-213 against VX-263 in favour of both: the leftover file goes, its key doesn't. → VX-263, VX-213
- **Keychain items per key, not per library name,** store-variant scoped, the item's class in its name. → VX-228,
  VX-213
- **A copy never brings its own key and never lowers protection:** a copy from this Mac's own line takes the library's
  mode; a Castle copy from another Mac raises the library here to Castle through Use Castle's own steps. → VX-209
- **New writing belongs to the library's account,** not the signed-in session. → VX-264, or a new ticket under VX-266
- **The signed-out doors work in both directions,** with *Stop syncing this library on this Mac* beside them; a new
  account under an old email is named as a different account. → VX-264
- **After Touch ID changes, Variorum asks once before using it again.** → a new ticket under VX-266
- **Touch ID or Always ask is your stored choice;** nothing acts on a momentary reading. → VX-228
- **Plans live beside the library,** never hold a secret, and are excluded from backups; every protection act gets one.
  → VX-235
- **A missing library is "missing" in both modes,** judged by evidence in the app's own container, so a fresh start
  stays fresh. → a new ticket under VX-266
- **The lobby speaks in roads, not modes.** → VX-228
- **The Castle offer gains "Bring them into Castle"** — new pairs under the current key, the old pair removed only after
  the new one opens. It is a deliberate exception to "the app never rewrites a backup", and only your press runs it. →
  VX-265
- **The offer's older-libraries group keeps your #216 reach,** counting other libraries Variorum kept, which can be
  deleted or kept. → VX-265
- **The restore list includes older libraries,** and the library-missing screen's restore door opens it. → VX-101
  (folded in, if you agree)
- **The adoption safety copy lasts only until the open finishes.** → a new ticket under VX-266
- **Plaintext exports carry the library's ID** (not secret); any landing without sync bookkeeping gets a fresh sync
  identity. → VX-209
- **The migration** finishes in-flight acts first, writes nothing Apple-reachable while a synced library is unconfirmed,
  treats corner 45's ambiguous case as Castle with a notice, keeps old items and key files for a release, and asks for
  the passphrase once when there are old keys to fold. → VX-228
- **13p escrow items are removed** for keys now in the history. → VX-213
- **VX-212 gets its own design and ruling,** not a line in this proposal. → VX-212
- **Passphrase strength without a new dependency:** a built-in check; any suggestion shaped visibly unlike the twelve
  words. → VX-211
- **The protection brain moves into the core package,** with the scenario test as coverage and the real-Keychain drills
  and walks as the gates. → VX-266, VX-233
- **One design sitting, then about five phases,** with a go/no-go after the headless core. → VX-266

---

## 12. What I considered and set aside

- **Keep patching each ticket.** Each fix is small, but each adds a belt to the same mechanisms; section 1's numbers are
  what that road costs, and it leaves VX-228's stranding tradeoff unsolved.
- **The middle road** (the cold read's m16): per-key Keychain items, the decide/act split, every copy re-encrypted under
  the library's current key, plans beside the library, and old key files *kept* and read by one catalog-wide route
  finder — your #216 fix shape for W-1. It meets every ticket in the project without the record, format 3 or the
  history key, and it is genuinely smaller: perhaps three phases instead of five or six. What it gives up: the mode
  stays worked out (safely now, because nothing aliases any more — corner 45 would read only the current key's own
  item, and every error leans toward Castle); a library opened on a new Mac can't prove its mode (a Standard library
  with a passphrase and no Apple copy arrives in Castle); "enrolled" still needs the account fix; old backups keep their
  day's secrets, as decision 11 always said; leftover key files stay beside the library; and a Mac lost with only the
  backup folder can't open backups from the "only this Mac" era, whose one road sits in a key file beside the lost
  library. **It is the honest alternative,** and the go/no-go after the core phase is where you could still choose it.
- **The minimal structural fix:** an explicit mode field in the key file, a gate that stops writing, and re-keying
  copies when they open. It would fix VX-209 and W-1, but keep one slot per library name, several key files per
  folder, writes from seven tasks and markers inside the library file — so the next bugs would come from the same
  places.
- **Remember "this library was Castle" on the Mac and gate copies with it** (VX-228's arm (a)). It strands Standard-era
  backups that have no passphrase. The design gets the same protection without stranding: the copy may open by any
  road it has, and is then brought into the library's mode.
- **Refuse the Apple landing whenever a Touch ID item exists** (VX-228's arm (b)). A belt on a guess; it still infers
  mode from the Keychain.
- **Rewrite old backups' key files to add today's passphrase** (VX-263's option (b)). It breaks "never rewritten"
  silently and misses copies outside the folders; the history reaches the same copies without touching them.
- **A new library ID at every re-key** (the pre-13x review's P6(b), not adopted then). It would also stop copies
  colliding, but it splits one library's sync identity at every key change. Per-key Keychain items give the same
  separation and keep one identity.
- **Mode in the key file with its own signature,** instead of inside the library file. It works, but needs its own
  signature scheme and can be separated from the writing it describes; the library file gives both for free.
- **Wrap the history key under the current library key or the account master.** Simpler, but both get Apple-held copies
  in Standard, so leaving Castle would hand Castle-era keys to the Apple account (the cold read's blocker, B1, against
  this proposal's first version).
- **"Newest choice wins" between copies, by a change counter** (this proposal's first version). Set aside: counters on
  two Macs don't say which choice came later, and a copy that can win can be forged by someone in your Apple account to
  install a key they know (the cold read's M1).
- **One mode per Mac instead of per library.** Simpler to say, but wrong for two libraries on one Mac and for accounts;
  the per-library record with the account's vault on top keeps today's model.

---

## Appendices

- `research-custody-state-map.md` — every piece of protection state, the key hierarchy, every decision function and its
  side effects, every act's steps and crash windows, the 27 inference heuristics, the recognised shapes and the gaps
  between them, and the phone's differences — with file and line.
- `research-backups-and-churn.md` — every kind of copy and how it is written and opened, the restore list and Open
  Library step by step, the Castle offer, where copies collide, the churn statistics, the ticket history, and the
  thirteen bug patterns grouped by cause.
- `cold-read-1.md` — the cold read of this proposal's first version, with my disposition of every finding.
