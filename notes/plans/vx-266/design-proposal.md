# Castle, backups and restores — a design proposal

**For:** VX-266 ("Castle & backups before launch") and all 17 tickets in the project.
**Status:** a proposal, not a ruling. Nothing here is built and no ticket has been changed. Written 2026-10-13 at
your request — *"fully, holistically consider the WHOLE of how castle is designed, the backups, the restores, the
full systems … find a path through the dark for me that you'll be proposing. I will weigh your deliverable.
don't ask me questions right now - note the decisions you made and we'll talk about them once the design is
complete."* Every call I made on your behalf is in [The decisions I made](#11-the-decisions-i-made), each tied to the
VX ticket it would be recorded on.
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
5. **Long acts can't always finish.** Most acts have no crash record at all, and the one that does (the Castle
   switch) keeps it *inside the library file* — so a backup can carry a half-finished switch.

The research grouped 46 tickets and about 150 review findings into 13 recurring patterns; these five causes
explain all of them. In October so far, 40 of the 62 commits in this area were fixes.

**What I propose.** Make the system *know* instead of *guess*, and give each fact one home:

- **The library carries its own protection record** — its mode and which account it belongs to — inside the
  library file, where only its key can read or change it. Every backup carries the record of its day.
- **One key file per library, with a key history:** the current key, plus every key the library has had, locked
  with a history key that your passphrase, your twelve words and Touch ID reach — never the Apple account.
- **This Mac keeps one Keychain item per key, not one per library name.** Opening a copy never evicts another
  file's key, and every key "move" becomes *add the new item, then remove the old one*.
- **One pure decider, one writer.** A single function reads the facts and says what is true and what is owed; a
  single reconciler is the only code that writes Keychain items, key files and the record. Nothing that decides
  ever writes.
- **Every act is a written-down plan** — kept beside the library, never inside it — that records what it will
  need before it starts, so a crash at any step finishes or rolls back.
- **A copy you open comes into your library's current mode.** Opening a backup brings back writing, never a mode.
- **The library knows which account it belongs to.** Signing out changes nothing; signing in to a different
  account never moves a library without asking.
- **A scenario test plays random sequences of everything a user can do** — two Macs and a phone, two Apple
  accounts, two Variorum accounts, backups, restores, sign-ins, sign-outs, crashes at every step — and checks the
  promises after every move. This is the answer to *"states we can't even imagine"*: we don't have to imagine them;
  the test generates them.

**What it buys you.** Five sentences that are true by construction, which the field guide can say plainly:

> 1. Standard or Castle is a choice you make for your library — and, once it syncs, for your account. Nothing
>    else changes it.
> 2. Opening a backup or an older library brings back your writing as it was. It comes back in the mode your
>    library is in now.
> 3. If you have a passphrase, every backup Variorum made of your library opens with it, your twelve words, or
>    Touch ID.
> 4. Backups made while you were in Standard also open through your Apple account. Entering Castle offers to bring
>    them into Castle.
> 5. Signing out never changes how your library is protected. If you sign in to a different account, Variorum
>    asks before moving your library to it.

**What it costs.** A real rebuild of the protection layer's middle — the part that decides and writes — not a
patch. The crypto, the vault and server, the key proof, rotations, the follow's substance, the lobby's roads and
backups-as-pairs all stay. One phase in three units; the first is fully headless (no stage, no Keychain), so the
new rules are proven by the scenario test before any screen changes. Existing stores — your three devices, the dev
stores and the beta testers — migrate once, quietly, at first unlock, drilled first on byte-copies of your stores.
No server deploy is needed for the core.

---

## Contents

1. [What I looked at](#1-what-i-looked-at)
2. [Why it keeps breaking](#2-why-it-keeps-breaking)
3. [The design](#3-the-design)
4. [The hard cases, step by step](#4-the-hard-cases-step-by-step)
5. [Every ticket, settled](#5-every-ticket-settled)
6. [What the research found that no ticket names](#6-what-the-research-found-that-no-ticket-names)
7. [Migration](#7-migration)
8. [The phase](#8-the-phase)
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
  handoff; the 13x portability plan.
- **The code** that decides, writes and presents protection — about 25,000 lines in 53 files — read directly at
  the decision points (`Posture.derive`, `StoreLaunchGate.effectiveGate`, `LibraryOpenModel.landCustody`,
  `StoreKeyEnvelope.locate`, `StoreIdentity`, `CustodyCollisionRule`, `BackupRestoreCandidates`) and mapped in
  full by two research helpers.
- **The churn:** 213 commits touched the area between 6 July and 13 October; 52% of them are fixes, and in October
  it is 65% (40 of 62). The area grew from about 10,000 lines on 1 September to about 24,900 today.
  `ProtectionController` has taken 51 commits and `PostureSwitch` 43 (it grew 29% in October alone). After the
  pre-13x build itself, the tail is fix after fix on the same mechanisms: 13x, VX-99, VX-110, VX-202, VX-209,
  VX-203, VX-80, VX-201.

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

Nothing anywhere records "this library is in Castle". **Pattern counts from the research:** 13 bugs where mode was
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
*which* key wins the one slot; with one slot, someone always loses. The pre-13x design review even proposed the
fix — *"a store re-key mints a NEW store ID … old ID ↔ old key"* (P6(b)) — and it was never built.

The same shape appears in key files: several fingerprint-named key files can sit beside one library, and "the
current one" is the one with the **newest modification date** (`StoreKeyEnvelope.swift:482-497`). The design said
to try each and keep the one that opens; that was never built either. A Time Machine restore or a copy can flip it.

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
lost (`LibraryOpenModel.swift:533-543`).

**Pattern counts:** 8 "a read that writes", 8 races between unordered writers, 8 writes whose results are
ignored or skip the handover rule.

### 2.4 Old copies remember only their own day

Decision 11 — *backups are never rewritten* — is a good rule, and I keep it. But nothing else remembers a
library's old keys. When a key is retired (entering Castle, Replace All Keys, the follow), each older copy can be
opened only by what its own key file carried on its own day. If that day had no passphrase and no Apple copy, the
copy has **no road at all** (VX-263 / W-1). The only file that does hold a road is the leftover key file beside
the library — which VX-213 wants to delete and which the restore list never reads
(`BackupRestoreCandidates.swift:85-122` reads only the copy's own key file).

And there is no single list of copies: at least six separate folder scans with their own rules, and three copies
of the backup-name parser. Each new kind of copy (13x's older libraries and safety copies, hand-offs) stays
invisible to the older code until a ticket adds it (VX-203, VX-210). Leftovers are kept forever with no recorded
purpose — the doctrine "never delete, its wraps are somebody's recovery legs" — so each later ticket guesses
whether a leftover matters, and the guesses disagree (VX-213 against VX-263). Every adoption keeps the outgoing
library **twice** (`Previous Libraries/` plus a safety copy), and neither is ever pruned.

**Pattern counts:** 10 frozen-copy bugs, 9 copy-discovery bugs, 8 leftovers-without-a-purpose.

### 2.5 Long acts can't always finish

| act | crash record today |
|---|---|
| Use Castle, Replace All Keys, the follow into Castle | a step marker — **stored inside the library file** (`sync_state`) |
| Leave Castle, the follow into Standard, sync setup, enrolling, Connect, change passphrase, regenerate words, re-link, opening a copy | **none** — each relies on the next reconcile to heal, or on nothing |

Where a marker exists, it does not carry everything its later steps need: a crash after the `.rekeyLibrary` marker
but before the new key file lands can never be resumed (VX-235); "another device switched" lives only in memory
(VX-107); `CorpusRotation.begin` re-fetches the vault instead of using the revision the door read (VX-109). Because
the marker lives inside the library file, **the Castle switch's own fresh backup carries a half-finished switch**:
restoring it lands a library that refuses to sync until a resume runs. Opening a copy has a crash window in which,
under Standard, the app quietly starts a fresh empty library at your library's place (traced from code, not
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
> 2. Opening a backup or an older library brings back your writing as it was. It comes back in the mode your
>    library is in now.
> 3. If you have a passphrase, every backup Variorum made of your library opens with it, your twelve words, or
>    Touch ID — on this Mac always, and on another Mac when your newest backup is beside the older ones.
> 4. Backups made while you were in Standard also open through your Apple account. Entering Castle offers to bring
>    them into Castle, or to delete them.
> 5. Signing out never changes how your library is protected. If you sign in to a different account, Variorum asks
>    before moving your library to it.

Everything below exists to make these sentences always true and checkable by a test.

**Unchanged for users:** the two modes and what each protects against; the passphrase and the twelve words; the
Apple-account key in Standard; Touch ID / Face ID and Always ask; the lobby's three roads and the vault road;
entering and leaving Castle; Replace All Keys; the follow on other devices; backups as pairs, never rewritten by
the app on its own; the restore hold and Resume Sync; older libraries kept in `Previous Libraries/`.

### 3.2 The facts, each with one home

| fact | home | written by | travels with copies? |
|---|---|---|---|
| **The protection record** — the library's ID, its mode, the account it belongs to (none, or one), and a change counter | a small local-only table **inside the library file**, one row | the reconciler | yes — every backup and older library carries the record of its day |
| **The key file** — the library's ID; the **current key** wrapped under the passphrase, the words, the account master (synced) and the Apple key (Standard only); and the **key history** — every earlier key of this library, locked with a **history key** | **one** file beside the library (format 3); each backup pair keeps its own copy, written with it, never rewritten | the reconciler | yes — a pair's key file is the whole key file of its day, history included |
| **The history key** — opens the key history | wrapped in the key file under the passphrase, the words and the account master — **never the Apple key**; and kept on this device beside the current key | the reconciler | inside the key file, wrapped |
| **This device's keys** — one Keychain item **per key** (named by the key's fingerprint and its class, silent or Touch ID), holding that key and the history key; plus one sync-keys item per library (master and corpus key) | the device Keychain | the reconciler | no — device-only, as today |
| **What this device remembers about each library** — for each library ID it has used: the current key's fingerprint, the mode, the account, the change counter, this device's sync identity; and this device's preferences for that library (Touch ID or Always ask, the idle lock, the scheduled Markdown export, dismissed nudges) | one small, non-secret, device-only Keychain item per library ID | the reconciler (preferences: their own doors) | no |
| *(unchanged)* **The account's vault** — the account's mode and keys | the server | key acts, under the key proof | — |

What this table removes: the mode inferred from a Keychain slot (corner 45); several key files per folder with
"newest wins"; one Keychain slot shared by every copy of a library; the in-file step marker.

In steady state each library has exactly one key item on a device — its current key's; older keys live only in the
history. Naming items by key is what lets a re-key add the new item before removing the old one, and guarantees an
item can only ever be used for the file its key opens — so opening one copy can never take another copy's item.

**Why the record lives inside the library file.** It is then protected for free — only the library's key can read
or change it — it travels with every copy, matching that copy's content exactly, and it cannot be separated from
the writing it describes. It is read after unlock, which is when every decision that writes is made. Before unlock
the app only needs to know which roads exist, and the key file and Keychain answer that (3.4).

**Why there is a history key, and why the Apple key never reaches it.** The history key is what lets Touch ID, your
passphrase or your words open *every* older copy, and lets a passphrase change or a words regeneration re-lock
the whole history without asking for the old word. Because it is never wrapped under the Apple key, leaving Castle
later never makes keys that were only ever Castle-protected reachable through the Apple account. **It is replaced at
every re-key** (entering Castle, Replace All Keys, the follow), with the whole history re-locked under the new one —
otherwise someone who copied it in Standard could open keys retired later in Castle.

**The change counter** goes up by one at every deliberate change of mode or account: Use Castle, Leave Castle, the
follow, joining or moving an account, This Mac Only, deleting the account. It is how the app tells "this copy is
older than the choice you made here" from "this copy carries a newer choice made on another Mac". Users never see
it.

**"Enrolled" becomes three plain facts,** each named where it's used: *the library belongs to account X* (the
record); *this device has X's sync keys for it* (the Keychain); *signed in as X* (the session). The five current
definitions go.

### 3.3 One decider, one writer

- **`assess(facts) → assessment`** — one pure function. In: the record, the key file, which Keychain items exist,
  what this device remembers, the session, the vault (if read in this session, for this account), and any plan in
  flight. Out: the library's mode and account, each *known* or *waiting for the vault*; the roads that open it; which
  doors are open and why; and the **repairs owed**. It never writes. The route, the lobby, the doors, the views and
  the sync engine's key provider call it and nothing else. It replaces `Posture.derive`, the gate's decision half,
  the controller's posture projections and the doors' private checks.
- **The reconciler** — the only code that writes Keychain items, key files, the record and what this device
  remembers. It runs whenever an input changes — unlock, sign-in, sign-out, a vault read, the end of an act — and
  as the steps of a plan. Each repair is idempotent, checks the world before acting, and verifies before it
  deletes. Repairs only move toward the record:
  - **Castle:** every key of the library lives behind Touch ID or nowhere — no silent item for *any* key in its
    history; the current key has no Apple wrap (if one is ever found, the repair is a re-key, since an Apple wrap
    may have been copied elsewhere); after a passphrase unlock on a device set to Touch ID, the Touch ID item is put
    back (today a fingerprint change sends every later launch to the passphrase for good).
  - **Standard:** the current key gets its Apple wrap when the Apple key is readable — "waiting for iCloud
    Keychain" is a fact in the assessment, not a guess — and the silent item holds the key; a leftover Touch ID
    item is removed.
  - The record, what this device remembers and the key file agree; the sync keys match the record's account.
  - A synced library whose vault says another mode owes **the follow** — an act, never a silent repair.
- **Gate style is a fact, not a dial that can disagree:** on a device with no Touch ID, Castle means Always ask.
  (Today a Castle library on a Mac without biometry reads "Touch ID" with no Touch ID item behind it.)

### 3.4 Before unlock: roads, not modes

The lobby decides from **which roads exist**:

1. a silent Keychain item for this key → open without asking;
2. a Touch ID item for this key → Touch ID, the passphrase as fallback;
3. an Apple wrap in the key file and the Apple key readable → open without asking; an Apple wrap but the key not yet
   readable → "Getting your key from iCloud Keychain…", with the passphrase and words as doors;
4. otherwise → the passphrase or twelve words (and, signed in, the vault road).

Its words follow the road, so they are always true. Whether the library *should* be in Castle is decided after
unlock, from the record, and any mismatch is repaired then, in the safe direction. If what this device remembers
says the library is in Castle but a road opened it without asking (only possible for an older copy whose key file
still carries an Apple wrap), the reconciler brings it into Castle straight away and says so.

**A missing library is missing in both modes.** Today, under Standard, a library file that vanished is replaced by
a fresh empty library without a word. With what this device remembers, the app knows a library lived here and shows
*"Your library file is missing — restore it, open another, or start a new one"* whichever mode it was in.

**A missing key file is not fatal.** What this device remembers names the library's current key, so Touch ID or the
silent item still opens a library whose key file was deleted, and the reconciler writes the key file again.

### 3.5 Every act is a written-down plan

Every act — Use Castle, Leave Castle, Replace All Keys, the follow, sync setup, enrolling, Connect or moving an
account, This Mac Only, changing the passphrase, regenerating words, re-linking, opening a copy, and the migration —
becomes a **plan** written to disk before its first step:

- **Kept beside the library on this device, never inside the library file**, so no backup or copy can ever carry a
  half-finished act. No backup is taken while a plan is in flight; the switch's fresh backup is taken after the
  plan's commit point.
- **Everything a later step needs is captured up front:** the vault revision the door read (VX-109: `begin` uses it,
  so a concurrent change elsewhere is refused by the server's existing check and the retry becomes the follow);
  "another device switched" and the words rule (VX-107); the target mode and the new change counter.
- **Prepare, then commit:** the new key goes into its own Keychain item and its key file is written *before* the
  library is re-keyed (VX-235: no step can point at a key that doesn't exist yet). Moving a key is always *add the
  new item, verify, then remove the old one*, so there is never a moment when the only copy of a key is in flux
  (VX-202's race had nothing else to race against).
- Steps are idempotent; resume runs from the first step whose result is not yet true; a step that cannot finish
  rolls back to a state the assessment recognises. One plan per library at a time; a second act waits with a
  sentence.

The vault's own rotation protocol on the server — the previous corpus key, the rotation seq, version-neutral
re-encryption, one rotation at a time — is unchanged.

### 3.6 Copies: backups, older libraries, exports

**One catalog of copies.** One module knows every place copies live — the backup folder, the second backup folder,
`Previous Libraries/`, the lock-time copies — with one name parser. The restore list, Open Library, the Castle offer
and retention all read it, so a new kind of copy is added once and seen everywhere.

**One route finder.** For a copy under key *K*, it gathers every road that reaches *K*: the copy's own key file; the
live key file's current key and history (through the history key — Touch ID, passphrase or words); every other key
file in the catalog (a newer backup's history reaches older keys anywhere); this device's Keychain item for *K*; the
account master (synced); the Apple key (Standard-era copies). It answers in plain words — "Touch ID", "your
passphrase or twelve words", "the passphrase you had on 3 September", "your Apple account", or honestly "nothing on
this Mac opens it". The scenario test checks that every road it names actually opens the copy.

**What happens when you open a copy as your library — one rule:**

- **A copy of the same library** (same ID):
  - with a change counter **older than or equal to** what this device remembers: it is **re-encrypted under the
    library's current key** and takes the library's current mode and account. Touch ID, your passphrase and your words keep
    working, and nothing about protection changes. Any backup made since the last key change is already under the
    current key, so for most restores nothing is re-encrypted at all.
  - with a **newer** change counter (a newer choice made on another Mac): the copy's mode, account and key win, and
    this device's previous key moves into the history. On an exact tie, the safer mode wins.
- **A different library** keeps its own key and mode; your current library is kept in `Previous Libraries/`, as
  today.
- **A synced library** always ends in its account's mode: after the restore hold and Resume Sync, the vault
  outranks everything (today's rule, now explicit). Its writing behaves as today: after Resume Sync, changes made
  since on your other devices come back in.
- **When the library's current key can't be reached** (you open a copy from the lobby while your library is locked
  or its file is missing, and the device is set to Always ask), the copy is never left in a lower mode: the open asks
  for your passphrase and words — the Castle switch's own steps — or you cancel.
- **A plaintext export** carries no protection. The export will now carry the library's ID (not secret): a copy of
  the same library is encrypted under the library's current key and mode; anything else becomes a new library in
  Standard, and the confirm says so.

The confirm screen states the outcome concretely, because the plan knows it before you press anything:
*"Your library goes back to how it was on 12 October. It stays in Castle."* ·
*"This is a different library, in Standard: it opens without asking on Macs signed in to your Apple account. Your
current library is kept with your older libraries."* No "check", no hedge (your #216 ruling).

**The restore list** shows backups and older libraries (VX-101's ask), each with its road. The library-missing
screen's *Restore from a Backup…* opens the same list instead of revealing a folder in Finder. Data Safety's prose
and `RESTORE.md` are rewritten to describe the doors that exist.

**Backups** are written exactly as today. The adoption's separate safety copy is kept only until the open finishes
(the older library in `Previous Libraries/` is the lasting copy), so each restore stops storing your library twice.

**The Castle offer**, after entering Castle, lists **this library's** copies that still open through the Apple
account — computed by the route finder, so it never overclaims — in two groups with their own choices: *backups*
and *older libraries* (VX-265). For each: **Bring them into Castle** (each copy re-encrypted under your current key
into a new pair; the old pair removed only after the new one opens — recommended), **Delete them**, or **Keep them**
(they still open through your Apple account). One line says what it can't see (VX-210): *"Variorum only looks in
its own folders on this Mac. Backups in a folder you used before, on a drive that isn't connected, in Time Machine
or copied elsewhere aren't touched and still open the old way."* Other libraries in `Previous Libraries/` are not
this library's business and are not listed.

### 3.7 Accounts: the library knows where it belongs

The record names the account; with the session, that gives four situations — the whole state space, each with one
behavior:

| the library belongs to | signed in as | what happens |
|---|---|---|
| no account | nobody, or anyone | Local only. Signed in, the Encryption tab offers to turn on sync for it; nothing happens by itself. |
| account X | X | In sync; the library follows X's mode (the follow, as today). |
| account X | nobody | Not syncing; nothing else changes. Mode doors say *"Sign in to change your account's mode"*; Use Castle offers your ruled one road: *"Castle will apply to this Mac only, and this Mac will stop using your old sync account…"* [Cancel] [Continue] (VX-264). |
| account X | another account Y | Not syncing. One plain screen: *"This library syncs with x@…. You're signed in as y@…."* — **Move it to y@…** (today's Connect road, with the mode consent when Y's mode differs) or **Sign out**. Never a silent follow, never a silent revert. |

- **Sign out** never changes the record; the sync keys stay, as today.
- **This Mac Only** leaves the account on this device (forgets its sync keys here) and applies the act — a counted
  change of account.
- **Deleting the account** leaves the library local-only, a counted change. Another device learns the account is
  gone the next time it signs in, and says so.
- **Signing back in to an account the library left** is an ordinary *turn on sync*, with its consent — not a follow,
  not a revert.
- **If the account it belongs to no longer exists** (deleted from another device), the next sign-in says so and offers
  to keep the library on this device only.
- Signing in or out re-runs the assessment at once (today sign-in runs no reconcile, so the screen can be stale
  until the next lock).
- The rows' account stamp keeps its sync role but stops deciding which account a library belongs to; rows are
  stamped when the library joins an account, not at every sign-in.
- The device's sync identity (not secret) moves from the sync-keys item into what this device remembers, so leaving
  an account no longer leaves a half-empty sync record that reads as "enrolled".

Your sequence — signed in, signed out, signed in to a different account whose library is in Castle, signed out,
signed back in to the original — is a walk through this table with a question at every account change and no
silent change at any step.

### 3.8 The scenario test (the proof)

A headless test that builds a small world — two Macs and a phone, two Apple accounts, two Variorum accounts, a fake
server, fake Keychains and iCloud Keychain, real key files and real wraps — and plays **random sequences of
everything a user can do**: create a library; set or change a passphrase; regenerate words; Use Castle; Leave
Castle; Replace All Keys; turn on sync; sign in as X or Y; sign out; This Mac Only; delete the account; back up;
restore backup *n*; open older library *n*; open a plaintext export; send a library to the other Mac; lock and
unlock; change a fingerprint; turn iCloud Keychain off and on; wipe a Keychain; replace a Mac; **crash at any step of
any act**, then relaunch.

After every move it checks the promises:

1. **Known, not guessed:** every live library has one record, and what this device remembers agrees with it.
2. **Castle means Castle:** for a library in Castle, nothing reachable through the Apple account opens its current
   key; no silent Keychain item holds any of its keys; its account's vault has no Apple copy.
3. **Standard means Standard:** the Apple wrap exists whenever the Apple key is readable; otherwise the assessment
   says "waiting for iCloud Keychain".
4. **No silent change:** a library's mode or account changes only at a deliberate act (or the follow of one) —
   never at a restore, an open, a sign-in, a sign-out, a relaunch or a crash.
5. **Nothing stranded:** every copy the app ever wrote opens by some road the user still has — except the one
   documented floor (no passphrase was ever set, and the only device that held the key is gone).
6. **Crash-safe:** after a crash at any step and a relaunch, the act finishes or rolls back and the live library
   opens; no copy ever carries a half-finished act.
7. **Converges:** every device of an account ends in the account's mode and keys.
8. **The posture law:** after entering Castle, nothing from before — old key files, old Keychain items, the old
   master — opens anything written after.
9. **Honest words:** every road the restore list names opens that copy; every sentence the confirm, the Done and
   the offer would show matches what the plan actually did.

It runs thousands of sequences in seconds under `swift test` — no stage, no Keychain, parallel across worktrees. It
is also the **red-on-old** evidence for the redesign: pointed at today's rules (`Posture.derive` and corner 45 are
pure functions, so they can be plugged in), it fails promise 4 on VX-209's sequence and promise 5 on W-1's. The
posture drill (VX-233), healed, stays the end-to-end check on the real Keychain.

### 3.9 What gets deleted

Corner 45 and `RawKeyCustody`; the gate's Apple landing; adoption's Keychain writes; `CustodyCollisionRule`; the
13p-era stored mode after migration; several key files per folder and the newest-date rule; VX-202's belts and the
switch-pending flag (nothing outside the reconciler writes, so there is nothing to belt); the in-file step marker
and its dead `.offer` step; the duplicate safety copy; the five "enrolled"s; the confirm's "you'll be leaving
Castle" line and the field guide's older-copy warning (the behavior they warn about no longer exists); the second,
Finder-revealing "Restore from a Backup".

### 3.10 What stays exactly as it is

The crypto (AES-GCM, key wraps, Argon2id, the twelve words); the vault and its protocol (the key proof and its
challenge, CAS, the rotation seq, version-neutral re-encryption, one rotation at a time); the follow's substance;
the lobby's three roads and the vault road; backups as pairs, written once; the restore hold; `Previous
Libraries/`; the plaintext export's exclusions; the two-register copy rules; the phone sharing the same brains.

---

## 4. The hard cases, step by step

*(Each is also a fixed sequence in the scenario test.)*

**VX-209 — a Castle library, an older Standard-era backup, and the way back (local only).**
1. You restore the backup. The route finder opens it through your Apple account (its own key file) or Touch ID /
   your passphrase (the key history). The confirm says: *"Your library goes back to how it was on 2 October. It
   stays in Castle."* The copy is re-encrypted under your library's current key; the Touch ID item is untouched,
   because it belongs to that key, not to the library's name; the record says Castle.
2. You bring the Castle library back from your older libraries. Same library, same current key: nothing is
   re-encrypted and nothing in the Keychain moves. Castle.

**VX-209 — synced.** The same, and the record also names the account; after Resume Sync the vault confirms Castle.
There is no window where the live file opens through the Apple account (today: until the follow runs).

**W-1 / VX-263 — entering Castle from "only this Mac can open your work".** The ceremony sets your passphrase and
words, re-keys the library, and puts the old key into the history. Every earlier backup opens with Touch ID, your
passphrase or your words. The leftover key file is gone because its one useful fact now lives in the history —
VX-213 and VX-263 are both satisfied.

**Signed out, then Use Castle.** *Continue* leaves the account on this Mac (counted) and enters Castle locally; the
Done says so, ending with *"Set up sync again later with a new account and it starts in Castle."* Signing back in to
the old account later is an ordinary turn-on-sync with its consent.

**Signed in to a different account.** Nothing syncs and nothing changes until you choose **Move it to y@…** or
**Sign out**. Moving takes Y's mode with the consent screen when it differs (Castle → Standard asks; Standard →
Castle asks for Y's passphrase and re-keys).

**Two Macs passing a local-only library back and forth (Send Library to Another Mac).** The newest choice wins: a
library you put in Castle on the Pro arrives in Castle on the Air even if the Air remembers it as Standard; a library
you took out of Castle on the Pro arrives in Standard. The confirm says which and why.

**A crash at any step of entering Castle.** The new key is in its own Keychain item and its key file is written
before the library is re-keyed; the plan holds every fact; relaunch resumes from the first unfinished step. No step
can leave a marker that points at nothing (VX-235), and the switch's fresh backup is taken after the commit point,
so it never carries the switch.

**A crash while opening a copy.** The plan records which library was moved aside and where; relaunch finishes the
landing or moves your library back. It never starts a fresh empty library in its place.

**Opening a copy while your library is locked or missing.** Touch ID or the silent item still reaches the library's
current key through what this device remembers, so the copy is brought into the library's mode as usual. Only on an
Always-ask device with the key unreachable does the open ask for your passphrase and words; it never lands the copy in
a lower mode.

**The account was deleted on another device.** This device still says the library belongs to it until it next tries
to sign in; then it says the account is gone and offers to keep the library here only.

**A new Mac, from backups only.** Copy the backup folder over and open the newest pair with your passphrase or
words; its history opens every older pair too.

**A changed fingerprint, a wiped Keychain.** The Touch ID item is invalid or gone: the lobby asks for the passphrase,
and after unlock the reconciler puts the key back behind Touch ID. Nothing else moves.

**iCloud Keychain off (Standard).** "Waiting for iCloud Keychain" is a fact in the assessment; the exposed nudge
speaks; the reconciler lands the Apple wrap as soon as the key is readable. No guess about Castle is ever made from
it.

**Always ask.** No Keychain item holds the key; every road is typed. The history works the same way.

**A Mac without Touch ID.** Castle there means Always ask, and every surface says so; nothing waits on a Touch ID item
that can't exist.

**Someone puts an older, Apple-openable copy where your library was.** It opens through the Apple road, as it would
today; after unlock, its older change counter disagrees with what this device remembers, so the reconciler brings it
into Castle at once and tells you what it found.

---

## 5. Every ticket, settled

| ticket | how the design settles it | unit |
|---|---|---|
| **VX-209** way-back revert | mode lives in the record; copies come into the library's mode; per-key Keychain items; nothing that decides writes. FLIP `VX209WayBackRoundTripTests`. | U2, U3 |
| **VX-228** corner 45 redesign | corner 45 is deleted. Its stranding tradeoff dissolves: a copy may open by any road it has (the Apple key included), and is then brought into the library's mode. | U1, U2 |
| **VX-263** W-1 | the key history; the route finder reads every key file in the catalog; the offer's words come from the route finder. | U1, U3 |
| **VX-264** your #216 rulings | items 1–6 built as ruled; item 7 (the concrete confirm) becomes the plan's own outcome sentence; the guide's older-copy warning retires. | U3 |
| **VX-265** separate delete choice | the offer's two groups, each with its own choices; only this library's copies are listed. | U3 |
| **VX-210** other folders | the one line, as ruled. | U3 |
| **VX-235** unfinishable marker | prepare-then-commit plans: key item and key file before the step moves. | U1, U2 |
| **VX-107** double crash loses facts | the plan captures "another device switched" and the words rule. (`Sync/` — Fable.) | U2 |
| **VX-108** doors gate on a stale reading | doors read the assessment; key doors re-check the vault they fetch, and the plan carries that revision. | U2 |
| **VX-109** `begin` re-fetches the vault | `begin` takes the door's revision. (`Sync/` — Fable.) | U2 |
| **VX-212** poison row | the finishing device retires rows it proves no key can read, lists them in Diagnostics, and completes. (`Sync/` — Fable.) | U3 |
| **VX-213** tidy-ups | item 1 is resolved by the key history (no leftover file; its key isn't lost); the duplicate-add class can't recur (the item's class is in its name, items are never updated in place); `pg_temp` is a server function fix at your go; the record corrections are doc lines. | U2, U3 |
| **VX-211** passphrase strength | a built-in strength check (no new dependency) and a suggested passphrase built from the twelve-word list the app already ships; the 12-character floor stays. | U3 |
| **VX-239** sheet hidden after lock | one presenter owns where every protection sheet shows, and re-presents an in-flight plan after unlock. | U2 |
| **VX-243** follow sheet on two windows | the same presenter: one host at a time. | U2 |
| **VX-233** drill rot | the switch runner takes its dependencies explicitly (no task-local reach); the drill is green again and joins the phase's proof. | U2 |
| **VX-266** flagship | this proposal → your review → the plan file `notes/plans/vx-266-castle-backups-prelaunch.md` → one run. | — |

Six open tickets outside the project touch the same code, and the design settles or simplifies each — yours to fold
in: **VX-100** (a copied library asks for the passphrase twice — the open's plan can carry the word into the
enrollment), **VX-101** (the restore list offers older libraries — included above as optional), **VX-102** (a landed
copy inherits the source's flags — the open's plan), **VX-104** (an end-to-end older-library drill — a fixed sequence
in the scenario test), **VX-152** (Lock isn't reentrant — one plan at a time and one writer), **VX-240** (a wrong
instruction while a re-key or restore runs — the presenter).

---

## 6. What the research found that no ticket names

Each of these falls out of the design rather than needing its own fix. The research read each one in the code; none
was reproduced on a device, so each gets its red-on-old pin before it counts as fixed. Where one is user-visible
today, I'd file it as a ticket under VX-266 at your word.

| found (research file) | today | after |
|---|---|---|
| The Castle switch's own fresh backup carries the half-finished switch inside it (backups §8 S-9) | restoring it lands a library that won't sync until a resume runs | plans live beside the library, never in it |
| A crash mid-open under Standard leaves a fresh empty library at your library's place (backups §8 S-2) | silent | the open is a plan; a missing library is "missing" in both modes |
| A fingerprint change sends every later launch to the passphrase (custody §4.16) | the Touch ID item is never put back | the reconciler re-lands it after a passphrase unlock |
| A Castle library on a Mac without Touch ID reads "Touch ID" with nothing behind it (custody §6b row 6) | the dial and the Keychain disagree; sync reads the wrong item | gate style is a fact |
| Leaving Castle can leave the Touch ID item behind forever (custody §4.5, §6b row 2) | nothing deletes it under Standard | Standard repairs remove it |
| The cached vault answer survives sign-out, account deletion and adoption (custody §5 H6) | posture-driven writes can act on it | the vault answer is tied to the session and account |
| Sign-in runs no reconcile (custody §4.9) | the pane can be stale until the next lock | the assessment re-runs at sign-in and sign-out |
| Every restore keeps your library twice, forever (backups §8 S-13) | `Previous Libraries/` + a safety copy, never pruned | the safety copy lasts only until the open finishes |
| Two different "Restore from a Backup" doors; Data Safety contradicts itself; recovery text names a file that doesn't exist (backups §8 S-6, S-8, S-10, S-14) | confusing | one list, one door, prose rewritten |
| The restore list skips the second backup folder and older libraries (backups §2.1) | invisible | the catalog lists them |
| Adoption ignores Keychain results and skips verify-then-delete (backups §8 S-5) | a failed save can still delete | only the reconciler writes, always verifying |
| The phone runs the writing check on every scene change (custody §7 M3) | an Apple copy can land on any app switch | decisions never write |
| Deleting the account leaves the library "enrolled" with a dead key, forever (custody §8 S-19) | undecided mode; the Apple step and migration legs never run | deletion is a counted change to local-only |
| A failed vault read (offline, signed out, no vault, any error) keeps the previous answer (custody §8 S-17) | an old answer can drive a write | the assessment marks the vault "not read", and nothing that writes acts on it |
| Leave Castle acts on a guessed reading (custody §8 S-22) | can run on a stale or undecided reading | key doors read the vault they fetch |
| The scheduled Markdown export setting isn't per library or per store: entering Castle on the dev store switches it off for the real store too (custody §8 S-13) | settings bleed across libraries and stores | kept per library in what this device remembers |
| Nudge and reminder dismissals are shared by every library on the Mac (custody §8 S-12) | a new library inherits old dismissals | kept per library in what this device remembers |
| "Your Apple account holds a key" is said for every Standard library, including ones still waiting for iCloud Keychain (custody §8 S-15) | overclaims | the words come from the assessment's facts |

---

## 7. Migration

Existing stores are few: your Pro, your Air and your phone, the dev stores, and the beta testers. Each migrates once,
quietly, at its first unlock on the new build — as a plan, so a crash mid-migration resumes:

1. Work out the library's mode **one last time with today's rules** — and if the library is synced and the vault
   can't be read yet, wait (today's "indeterminate writes nothing" rule, kept for this one step). Where today's state
   is ambiguous (corner 45's case: a passphrase, no Apple copy, the key in the silent item), the migration reads the
   evidence a Castle switch leaves — an older Standard-era key file beside a newer one with no Apple copy — and
   otherwise keeps today's reading. Either way, the first launch says plainly which mode the library is in, with the
   other one press away.
2. Write the record and what this device remembers (change counter 1).
3. Re-file the Keychain: for each library-ID-named key item, add the per-key item with the same class, verify, then
   remove the old one. The sync-keys item keeps its shape.
4. Build the one key file: the current key's wraps from today's current file; every other key file the catalog can see
   — beside the library and in the backup folders — adds its key to the history, straight away if the key can be
   reached now (Touch ID, the master, the Apple key), otherwise the first time the passphrase is typed (the old files
   stay until then).
5. Retire the 13p-era stored mode and the per-name flags.
6. Run the route finder once over the catalog. If any of this library's copies still open through the Apple account
   — VX-99 found 13 such pairs on your Pro on 8 October, some of which backup rotation may have pruned since — the
   Castle offer appears once, with its bring-into-Castle choice.

Drilled first on byte-copies of your Pro and Air stores (A1 safety copies) and on the dev stores, including W-1's
repro (kept at `Backups/safety-copies/castle-W1-20261013/`), whose old backups must open with the dev passphrase
after migration. Old backups' key files (formats 1 and 2) are read as they are, forever, and a copy made before the new
build — which has no record inside it — gets its mode worked out once, the same way as the migration, when it is
opened.

The migration is one-way: a store migrated by the new build won't open on an older build (the usual rule for a
schema change). The A1 safety copy taken before it is the road back.

**No server deploy:** the record is a local-only table — the same road as the MCP grants and the search index; no
lockstep, the marker stays 13. The one optional server change is VX-213's `pg_temp` fix, at your go.

---

## 8. The phase

**One phase, three acceptance units, strictly in order.** The first is headless and not phase-sized; the other two
are, which keeps within the "at most two phase-sized units" guidance.

- **U1 — the protection core, headless** (`Sources/VariorumCore/Protection/`): the record, key file format 3 with the
  history and history key, the per-key Keychain interface, what the device remembers, `assess`, the reconciler's
  repairs, the plan runner, the copy catalog, the route finder, and the scenario test with its fakes. *Evidence:*
  the scenario test green over many thousands of sequences; red on today's rules for VX-209 and W-1; each promise
  pinned on its own.
- **U2 — the app on the core, Mac and phone:** the lobby and route on roads; the controller, the switch, the follow
  and every door on plans; the presenter; the migration; the deletions; `Sync/` lines (VX-107, VX-109, the step
  marker moving out of the library file) written by Fable. *Evidence:* the posture drill green (VX-233); the
  migration drilled on byte-copies of your stores; the Mac and phone suites; a walk entering and leaving Castle on
  the dev store.
- **U3 — copies and words, Mac:** the restore list and Open Library on the catalog, the route finder and the open
  rule; the Castle offer's groups and the bring-into-Castle choice; the plaintext export's ID; Data Safety and
  `RESTORE.md`; VX-264/265/210's copy; VX-211; VX-212 (Fable); VX-213's remainder. *Evidence:* a restore walk on the
  dev store through every case in section 4, W-1's repro opening, and your acceptance walk.

**Cast and rules.** This is *the* custody/`Sync/` effort while it runs. Fable orchestrates and cold-reviews every
round; Opus implements, except the `Sync/` lines, which Fable writes. Every bug-class change lands red-on-old; the
scenario test makes most of those pins generated rather than hand-picked. No new dependency.

**Size, honestly.** U2 is the big one: it rewires the middle of the app's protection code. I'd expect the new core to
be a few thousand lines, the app-side protection code to shrink overall, and a good share of today's custody pins to
be rewritten against the new shape. If the phase needs a cut line, two pieces can move after launch without weakening
any promise: the bring-into-Castle choice (the offer keeps Delete and Keep) and the restore list's older-libraries
section.

---

## 9. Risks

- **A rebuild right before launch.** Mitigated by the order: the rules are proven headless first; the app moves onto
  them unit by unit with the drill and suites green; the migration is drilled on your stores' copies before your
  devices see it.
- **Migration on your real stores.** They are Castle and synced — the best-understood shape. The migration waits for
  the vault before writing, and keeps every old key file until its key is safely in the history.
- **Re-encrypting a copy when it opens** takes seconds for a typical library, on the same road the Castle switch uses
  today; the picked file is still never written.
- **The record lives inside the library file,** so a library that can't be unlocked can't state its mode — but
  nothing that writes runs before unlock, and the roads before unlock are facts.
- **Test fakes that drift from the real Keychain** — the very pattern behind VX-233 and VX-106. The fakes are built
  from the Keychain facts already measured and pinned (the pre-13x spike memo), the posture drill runs on the real
  Keychain, and each unit ends with a walk on the dev store.
- **Scope creep.** The ticket list is the scope; section 6's items come free with it or not at all; the two optional
  pieces are named so they can be cut cleanly.

---

## 10. What canon this changes

If you accept the design, these lines change at the closeout — each as a contract line with a pointer to your
ruling, as the canon rule asks:

- **The original Castle design** (`pre-13x-postures-design.md`): §3.1's posture row ("derived, never a setting")
  becomes "recorded in the library and reconciled"; decision 13 ("custody items are scoped per store ID") becomes
  per key, with what the device remembers per library; decision 8's local-only half ("each library's posture is its
  own key file's") becomes "its own record's"; corner 45 is retired; decision 11 gains the bring-into-Castle exception
  at your press; §6's one user sentence is replaced by rule 3.
- **SyncSpec §3** (the pre-13x paragraph on custody): custody per key; the device identity's new home; the rotation's
  crash record moves out of the library file.
- **AppSpec §7**: one local-only table (the protection record) and the key file's format 3 — no lockstep. **AppSpec
  §12**: the restore list's reach, one restore door, the Castle offer's two groups.
- **OverallModel**: nothing. No invariant is relaxed; the posture law becomes the scenario test's promise 8.

---

## 11. The decisions I made

Each is mine, made so the design could be complete; each is yours to accept, change or reverse, and would be recorded
with your words on the ticket named.

- **Mode belongs to the library, not to a copy:** opening a backup brings back writing in the library's current mode.
  *This reverses the premise of your earlier yes to the "you'll be leaving Castle" confirm line* (VX-209's comment of
  2026-10-13): the new confirm says the library stays in its mode. → VX-209
- **The protection record lives inside the library file**, as a local-only table (no lockstep). → VX-228
- **One key file per library, with a key history behind a history key** that Touch ID, the passphrase, the words and
  the master reach — never the Apple key — and that is replaced at every re-key. This settles VX-213 against VX-263
  in favour of both: the leftover file goes, its key doesn't. → VX-263, VX-213
- **Keychain items per key, not per library name,** with the item's class in its name. → VX-228, VX-213
- **Newest choice wins** between copies of a local-only library from different Macs (the change counter; the safer
  mode on a tie); the account's vault decides for synced libraries. → VX-209
- **A copy is re-encrypted under the library's current key when it opens** (unless it already is). → VX-209
- **The library knows its account;** sign-out changes nothing; a different account asks (Move / Sign out); This Mac
  Only and account deletion are counted changes; a deleted account is named at the next sign-in. Rows are stamped
  with an account when the library joins it, and the device's sync identity moves out of the sync-keys item. →
  VX-264 (or a new ticket for the different-account screen)
- **A copy is never left in a lower mode:** when the library's current key can't be reached, opening a copy asks for
  the passphrase and words instead. → VX-209
- **Plans live beside the library, never inside it,** and every protection act gets one — including those with no
  crash record today. → VX-235
- **A missing library is "missing" in both modes,** never silently replaced by an empty one. → a new ticket under
  VX-266
- **The lobby speaks in roads, not modes.** → VX-228
- **The Castle offer gains "Bring them into Castle"** as its first choice — new pairs under the current key, the old
  pair removed only after the new one opens. It is a deliberate exception to "the app never rewrites a backup", and
  only your press runs it. Optional for launch. → VX-265
- **The offer lists only this library's copies,** in two groups with their own choices. → VX-265
- **The restore list includes older libraries,** and the library-missing screen's restore door opens it. Optional for
  launch. → VX-101 (folded in, if you agree)
- **The adoption safety copy lasts only until the open finishes.** → a new ticket under VX-266
- **Plaintext exports carry the library's ID** (not secret), so re-opening one is recognised. → VX-209
- **Gate style follows the device:** no Touch ID means Always ask. → VX-228
- **Migration reads a Castle switch's evidence where today's state is ambiguous**, and otherwise keeps today's
  reading; the first launch on the new build says plainly which mode each library is in. → VX-228
- **The protection brain moves into the core package** behind small interfaces, so the scenario test runs headless.
  → VX-266
- **The scenario test is the phase's proof,** with the healed posture drill (VX-233 stays pre-launch, as grouped).
  → VX-233
- **Poison rows are retired** by a device that proves no key reads them, and listed in Diagnostics. → VX-212
- **Passphrase strength without a new dependency:** a built-in check plus a suggested passphrase from the twelve-word
  list. → VX-211
- **One phase in three units, the first headless.** → VX-266

---

## 12. What I considered and set aside

- **Keep patching each ticket.** Each fix is small, but each adds a belt to the same mechanisms; section 1's numbers
  are what that road costs, and it leaves VX-228's stranding tradeoff unsolved.
- **A minimal structural fix:** an explicit mode field in the key file, a gate that stops writing, and re-keying copies
  when they open. It would fix VX-209 and W-1, but keep one slot per library name, several key files per folder,
  writes from seven tasks and markers inside the library file — so the next bugs would come from the same places. It
  is the fallback if the full design doesn't fit before launch.
- **Remember "this library was Castle" on the Mac and gate copies with it** (VX-228's arm (a)). It strands
  Standard-era backups that have no passphrase. The design gets the same protection without stranding: the copy may
  open by any road it has, and is then brought into the library's mode.
- **Refuse the Apple landing whenever a Touch ID item exists** (VX-228's arm (b)). A belt on a guess; it still infers
  mode from the Keychain.
- **Rewrite old backups' key files to add today's passphrase** (VX-263's option (b)). It breaks "never rewritten"
  silently and misses copies outside the folders; the history reaches the same copies without touching them.
- **A new library ID at every re-key** (the pre-13x review's P6(b)). It would also stop copies colliding, but it
  splits one library's sync identity at every key change. Per-key Keychain items give the same separation and keep
  one identity.
- **Mode in the key file with its own signature,** instead of inside the library file. It works, but needs its own
  signature scheme and can be separated from the writing it describes; the library file gives both for free.
- **Wrap the history under the current library key** (no separate history key). Simpler, but leaving Castle would
  then make the whole history reachable through the Apple account.
- **One mode per Mac instead of per library.** Simpler to say, but wrong for two libraries on one Mac and for
  accounts; the per-library record with the account's vault on top keeps today's model.

---

## Appendices

- `research-custody-state-map.md` — every piece of protection state, the key hierarchy, every decision function and
  its side effects, every act's steps and crash windows, the 27 inference heuristics, the recognised shapes and the
  gaps between them, and the phone's differences — with file and line.
- `research-backups-and-churn.md` — every kind of copy and how it is written and opened, the restore list and Open
  Library step by step, the Castle offer, where copies collide, the churn statistics, the ticket history, and the
  thirteen bug patterns grouped by cause.
