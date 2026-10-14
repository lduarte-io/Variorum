# VX-266 — Castle & backups before launch: the design and the plan

**Status: DESIGN RULED, 2026-10-13. Nothing built yet.** This file is the binding design for the effort ("Castle &
backups before launch", flagship VX-266) and its phase map. Each phase gets its own just-in-time execution plan
beside this file, with a kickoff message at its top (the split-phase rule, `notes/PhaseSizingGuidance.md` §3). The
first one is already written: `notes/plans/vx-305-castle-core.md`.

**The visual twin of §3 is `notes/plans/vx-266/castle-target-key-map.html`.** It is an acceptance artifact: the
finished code is checked against it, element by element (§4.3, her ruling).

**Provenance.** The design merges two documents:

- `notes/plans/vx-266/design-proposal.md` (the first design, revised after `cold-read-1.md`);
- `notes/plans/vx-266/second-opinion.md` (an independent design and assessment, revised after
  `second-opinion-cold-read.md` and `second-opinion-apple-facts.md`).

Read them for the *why*. This file says only what is true and what gets built. Where the two documents differ, this
file follows the second opinion as she ruled it.

**Reviewed after the merge** by the first design's author, in two rounds at her ask; every finding and its
disposition is in `notes/plans/vx-266/first-designer-review.md`.

---

## 1. Her rulings (2026-10-13, verbatim where quoted)

At #216 and in her review of both documents:

- **The direction.** *"I want to handle them all together before launch - I don't want this mess to propogate once I
  have users in every conceivable configuration and state with backups in every conceivable configuration and
  state."*
- **The principle.** *"in castle = safe. out of castle = not safe. and it's pretty much as simple as that and we do
  not need to contort ourselves to fit a halfway posture."* Disclaimers are welcome where they make a sentence true:
  *"i'm honestly fine with stating a decent number of disclaimers so that people get the picture."*
- **VX-209 — the mode belongs to the library; opening a copy never lowers it.** This reverses her earlier yes to the
  "you'll be leaving Castle" confirm line.
- **VX-263 — the key history is locked under the current key.** *"if you leave castle, your apple account can open
  the copies variorum made while you were in castle. again, if stated clearly, i'm fine with that."*
- **VX-301 — retire the Apple key when entering Castle.** *"I think it's fine for people to lose access to previosu
  backups if they lost their passphrase / words / touchID + they're going into castle, so long as they're adequately
  warned about it. they can always export it as plaintext if they want to, but going into castle means going into
  protection and I agree with deleting the iCloud key when they go into castle."* Her Keychain Access check confirmed
  why: the dev scope's Apple key was revealed with the login password, on the Pro and on the Air. **The shape of the
  old shared key's retirement (§3.5) is PROVISIONAL, hers to confirm** (§9): the review found that key is shared by
  every library on the Apple account, which this ruling's question didn't put in front of her.
- **Never opening a copy without asking** (the second opinion's fourth decision) is withdrawn as redundant under
  VX-301; the record is on VX-266.
- **The rest — *"My rulings: I want to go with your recommendations on all of these"*:**
  - **VX-313:** plans and protection-weakening settings are sealed.
  - **VX-302:** copies belong to a library and a Mac.
  - **VX-314:** new writing belongs to the library's account.
  - **VX-265 / VX-210:** the Castle offer shrinks under VX-301.
  - **VX-212:** gets its own design, never deletes server rows, and runs *"once the first plan is working"*.
  - **VX-266:** several phases, with a go/no-go after the core.
- **Numbering (her word):** a decision that is only a ruling on one ticket is recorded on that ticket; a decision that
  became work has its own ticket, and this file cites tickets only. The second opinion's own decision numbers are
  traced to their tickets at the top of `second-opinion.md`.
- **The built things holding the design back** (second opinion §4): *"I'm fine getting rid of each of those already
  built things."*
- **Priority.** *"I also want castle thoroughly fixed and working beautifully before launch, so D10 is fine but
  honestly I'm going to say go even if it delays launch."* The go/no-go after phase 1 is a quality gate, not a
  schedule gate.
- **Sizing.** *"you can use more than two phase sized units if you need for this. sizing should only ever be
  considered guidance."*
- **Two more items placed here, at her word:**
  - VX-113, the follow's wrong-passphrase sentence, which should name the change;
  - VX-310, the lobby's Touch ID line and button — her report: *"there should always be a button you can click to
    launch the touchid prompt"*.
- **The acceptance artifact.** *"make me a new version of the castle-key-map that has JUST the posture that is being
  built by your plan file. checking the final code against that map will be a part of the acceptance criteria for the
  phase."*

The earlier rulings this design keeps are in §3.12 (the signed-out screen, the copy rulings, the VX-210 line).

---

## 2. What this fixes

**The diagnosis**, agreed by both documents and confirmed by three independent reads:

1. **The mode is guessed** — from five inputs, one of them the Keychain slot a library's ID names.
2. **One Keychain slot is shared by every copy** of a library.
3. **Deciding code writes.**
4. **Copies keep only their own day's keys.**
5. **Long acts journal into the library file itself.**
6. **Account binding is implicit,** and rows are stamped by whoever is signed in.
7. **Anything on the Mac can steer a decision before unlock** (and Keychain Access can edit keychain items too).
8. **One shared, never-deleted Apple key** means Castle can't cover older copies, and the Mac's login password reveals
   it.

**The tickets:** the project's 17, plus VX-301, VX-302, VX-310, VX-313, VX-314 and VX-113. §6 maps each to its phase.

---

## 3. The design (the contract)

### 3.1 What users are told (true by construction; the scenario test checks every line)

1. **Standard or Castle is a choice for your library** — and, once it syncs, for your account. Only a deliberate act
   changes it: Use Castle, Use Standard, a follow of either on another device, or joining or moving to an account,
   which always asks first.
2. **In Castle, nothing reachable through your Apple account or this Mac's login password opens your library, or any
   copy Variorum made of it on this Mac — or, once it syncs, on any device of your account after that device
   follows.** Your passphrase, your twelve words, or Touch ID on a device you enrolled open it. Lose all three and it
   is gone — said at the door, with *Export a plain copy first* offered. A copy you sent to another Mac without sync
   is that Mac's library, protected as it is there.
   **The stated exception, for stores from before this change:** copies made under the old shared Apple key (§3.5)
   open through your Apple account, and on this Mac for anyone with its login password, until that key is retired.
   Use Castle retires it unless you choose to keep it for now; while it remains, every Castle surface says so.
3. **In Standard, your Apple account opens your library and every copy Variorum made of it** — and so does anyone who
   can sign in to this Mac. Said on the Standard card.
4. **Opening a backup brings back your writing as it was, in the mode your library is in now.** A synced library
   then catches up when you resume sync.
5. **Leaving Castle gives your Apple account a key to your library and every copy Variorum kept of it, including
   copies made while you were in Castle.** Said on the leave screen (VX-263).
6. **Signing out never changes how your library is protected.** Signing in to a different account changes nothing
   until you choose to move the library there.

### 3.2 The things, each with one home

| thing | home | written by | travels with copies |
|---|---|---|---|
| **The library file** | the slot (unchanged path); SQLCipher under the current library key L | the executor (re-keys); the app (writing) | it *is* the copy |
| **The protection record** — library ID, mode (`castle` / `standard`), account (none or one id), key epoch, current key fingerprint, changed-at, **the Apple key ids it has retired** (delete on sight reads them) | a one-row table inside the library file, `protection_record`, in the local-only family (no lockstep; the plaintext export leaves it behind) | the executor only | yes — each copy carries its day's record |
| **The library identity for exports** — the library ID alone | a small plain table the plaintext export keeps (the derived-tables precedent: local, never synced, kept by the export) | the executor | yes, including in plaintext exports |
| **The key file, format 3** — library ID; the current key's fingerprint and epoch; the current key wrapped under P (with its KDF descriptor), W, M (when bound) and A (Standard only, naming the Apple key's id); **the history** — every older key of the library, each wrapped directly under the current key, with its fingerprint, epoch and retirement date; and, when bound, **that master wrapped under the twelve words**, copied from the vault's recovery wrap — non-secret, refreshed from the vault while that master is current, replaced only when the master wrap is (§3.5a) | **one** file beside the library, `variorum-library-keys.json` (a name older builds never read) — and, for each other library this Mac holds copies of whose newest copy is in Standard, one in that library's backup folder, `Backups/<library8>/` (§3.5). Each backup pair carries a frozen copy written with it, never rewritten | the executor only | yes — as the pair's frozen copy |
| **Custody items** — one Keychain item per library key: `silent` (Standard, `WhenUnlockedThisDeviceOnly`) or `touchid` (Castle, `.biometryCurrentSet`); none under Always ask | device keychain, service `io.lduarte.Variorum.library-key`, account `<scope>-<fingerprint16>-<class>` | the executor only | no |
| **Sync keys** — M, C, J for the bound account | device keychain, one item per account, `silent` or `touchid` (none under Always ask: session memory) — service `io.lduarte.Variorum.sync-keys`, account `<scope>-<accountID>-<class>` | the executor only | no |
| **What this Mac remembers** — per library ID: its location (scope), current fingerprint and epoch, mode and account last confirmed, **the device identity**, the settings (Touch ID or Always ask, idle lock, scheduled Markdown export, nudge dismissals), and a mirror of the key file's wraps and history | one non-secret Keychain item per library ID (device-only), service `io.lduarte.Variorum.memory`, account `<scope>-<libraryID>`; the protection-weakening fields are **sealed** (§3.6) | the executor (settings through their own doors) | no |
| **"A library lived here"** | a marker file in the app's own container beside the slot | the executor | no — deleting the container starts fresh |
| **Plans** (one per library at a time) | `variorum-plan.json` beside the library, excluded from backups (`NSURLIsExcludedFromBackupKey`), **sealed** (§3.6), never holding a secret | the executor only | no |
| **Apple keys** | iCloud Keychain, synchronizable, the shared access group; **named by their own id** — `<scope>-apple-key-<id>` — one per Standard library this Mac holds copies of (the live one, and other libraries whose newest copy is in Standard), one per sync account. The **old shared** `<scope>-apple-key` is never written by this build, and deleted only by its retirement (§3.5) | the executor only | — |
| **The vault** (server) | unchanged protocol: M under P, W and (Standard) the account's Apple key, with `apple_key_id`; C and J under M; the key proof; the rotation fields | the executor through the existing RPCs | — |
| **Backups** | pairs (snapshot + frozen key file) in `Backups/<library8>/<mac8>/` in the container and in the picked far folder; legacy flat files stay where they are | the backup service; retention through the catalog | they are copies |

### 3.3 Deciding and writing

- **`assess(facts) → Assessment`** is one pure function, and the only decision code. Its inputs are the facts above,
  plus:
  - the session (signed in as whom);
  - the vault reading — fresh, for this account, this session — or none;
  - the store file's presence;
  - the container marker.

  It returns:
  - the mode and the account, each *confirmed* or *not yet confirmed*;
  - the **roads** that open the file;
  - every door with its reason;
  - the **repairs** owed and the **acts** owed;
  - the words every surface shows.

  Everything that decides calls it: the route, the lobby, the doors, the views and the sync engine's key provider.
  `Posture.derive`, `effectiveGate`'s decision half, the controller's projections and the doors' private checks all
  go.
- **The executor** is the only code that writes custody items, sync keys, the key file, the record, what this Mac
  remembers, plans, Apple keys and the vault. It runs repairs and plan steps. Every write is verified, and every delete
  comes after the replacement has verified.
- **Before unlock, nothing on the Mac decides anything.** The lobby offers the roads this device has for the
  library:
  - custody items named by any fingerprint in the key file, what the Mac remembers, or its mirror;
  - Apple wraps whose Apple key is readable;
  - the passphrase or words, with the vault road behind them.

  Every road verifies itself, because a key that doesn't open the file opens nothing. A key reached through the
  history counts as a road, so a library left mid-re-key, or rolled back by Time Machine, still opens.
- **Repairs move toward the record, with guards:**
  - A synced library writes nothing Apple-reachable without a fresh vault read for its account (decision 35, kept).
  - An unconfirmed or ambiguous mode writes nothing Apple-reachable.
  - Nothing acts on a momentary reading (§3.10).
  - Opening a copy **never lowers** the mode (§3.7).
- **The repairs:**
  - **Castle:** no silent item for any key the library has had — **including the per-library-ID items the migration
    kept for downgrade safety**; no format-1 or format-2 key file beside the library once the history verifiably holds
    its key (a key the fold couldn't reach keeps its file: it's that copy's only road); no Apple wrap of the current
    key — if one is ever found, the repair is a re-key; and no Apple key whose id the record lists as retired
    (delete on sight, by id only — never by library ID, since another Mac's unsynced copy of the same library may be
    in Standard under a key of its own).
  - **Standard:** the Apple wrap lands when the library's or account's own Apple key is readable; a vault that names
    the old shared key is moved to the account's own key (a fresh vault read, under CAS — §3.5); no Touch ID item for
    the library's keys.
  - **Always:** the record, what this Mac remembers and the key file agree. Sync keys match the record's account.

### 3.4 The key history (VX-263)

- **Every re-key adds the old key to the history.** The re-keys are entering Castle, Replace All Keys, a follow, and
  raising a copy from another Mac into Castle.
- **How it's held:** the new key file wraps every older key directly under the new key. The executor unwraps the old
  history with the old key, which is in hand during any re-key, and re-wraps it.
- **It runs backwards only.** A key opens older keys, never newer ones, so an old key opens nothing written after it.
- **Every backup's frozen key file carries the history as of its day.**
- **Prepare-then-commit falls out of it** (VX-235's class). The new key file — the new key's wraps, plus the old key
  in its history — and the new custody item are written **before** the library is re-encrypted. Whatever state a crash
  leaves, a road opens the file: the old custody item, the new key, or the new key through the history. The old
  custody item is deleted only after the swap commits.

### 3.5 Apple keys (VX-301)

- **Named by their own id.** The vault records its key's id (`apple_key_id`), and so does a key file's Apple wrap.
- **One minter.** Apple keys are minted only by a deliberate act or the migration, always under a fresh id: sync
  setup in Standard, Use Standard (re-linking an account that's already Standard included, §3.9), a new local
  library, and the migration's move off the old shared key (below). An account's key is the one its vault names; if
  two devices mint for one account, the vault's CAS keeps one, and the other device deletes the key it minted, unused.
  - A device that can't read the key the vault names **waits**, whether the key hasn't arrived yet, iCloud Keychain
    is off, or the device is on another Apple ID. The app can't tell those apart.
  - For its own key file only, such a device may use a key of its own, under its own new id (corner 34's road).
  - Two devices therefore never create the same item. This replaces the shared-name mint guards (F2/F3) with a rule
    that can't race; its convergence pins live in phase 3.
- **Entering Castle retires it.** After the switch commits, the library's Apple key (or the account's) is deleted,
  along with every device-own key made for it, and each id is recorded as retired in the record. Each device does the
  same for its own when it follows. Deletes of synchronizable items reach every device, and app-made items have no
  recovery.
- **Delete on sight, by recorded id.** In Castle, a key whose id the record lists as retired is deleted again if it
  reappears — a key deleted while sync was off can come back when sync does. Nothing is ever deleted for belonging to
  "this library" by ID: another Mac's unsynced copy of the same library may be in Standard under a key of its own.
- **Leaving Castle mints a fresh key.** The other devices wait for it to arrive, keeping their keys in silent items
  meanwhile.
- **The old shared key — today's `<scope>-apple-key`.** There is one per Apple account and scope, shared by every
  library and account on it, on every device. Deleting it deletes it everywhere, with no recovery. So:
  1. **This build never writes under it.** It reads it only to move things off it, and the route finder counts it as
     a road while it exists.
  2. **Each device's migration moves everything it holds off it** (§3.13), while it is still readable:
     - it folds every key reachable through it into the history of the library that key belongs to;
     - each *other* library this Mac holds copies of — an older library, or backups only — whose newest copy is in
       Standard gets a format-3 key file in its backup folder, `Backups/<library8>/`, under an Apple key of its own,
       so its copies keep opening exactly as before, through the Apple account. A library whose newest copy is in
       Castle gets none: its pre-Castle copies are what retirement is for. (An older library of *this* library is a
       copy: its keys go into the live history.)
     - the live library moves to its own key: a local-only library at once; a synced account only with a fresh vault
       read, under the vault's CAS (offline, the repair does it later). The key file drops its old-key wrap only after
       the new wrap verifies;
     - it ends with **a fresh backup pair** of the live library, so the newest pair carries the history and the new
       wraps.

     After that, nothing this device holds in Standard needs the old key.
  3. **An older build can put things back on it.** Its Re-link door re-lands an account's vault copy under the old
     key, and it mints a new old-key item when it finds none. So a vault that names the old key is moved to the
     account's own key by the next device on this build that reads it (a repair, §3.3), and the retirement repeats
     every move before it deletes anything.
  4. **Retiring it is a step of Use Castle** — **PROVISIONAL in this shape, hers to confirm** (§9):
     - **The checks, before the sheet:** the moves of point 2 run again. Then the route finder looks at every copy in
       the catalog — other libraries' and other Macs' in a shared backup folder included — and every account vault
       this device can read, for anything that would stop opening.
     - **The sheet** lists those things concretely ("3 backups from Lillian's Air"; "your account x@… can't be
       checked while you're signed out"), and says what the Mac can't see: *"Before you do, open the latest Variorum
       on every device signed into this Apple account. A device that hasn't been updated keeps opening its library on
       that device. But if that device is lost or reset before it updates, that library and its backups open only
       with a passphrase or the twelve words — and without either, not at all."*
     - **A vault still naming the old key** after the moves (a race with an older build's Re-link) stops the
       retirement, which says so: retiring then would cost that account its Apple road.
     - **Use Castle** then retires the old key as its last step, after the library's own. When the list isn't empty,
       a second button, *Use Castle, keep the old Apple key for now*, does everything else. Cancel is always there.
     - **A store already in Castle** — at the migration, or after *keep it for now* — gets one notice, and a standing
       door in Settings ▸ Protection, *Retire the old Apple key…*, with the same checks and sheet.
  5. **Retiring** deletes the key and records its id as retired in the record; delete on sight covers it from then on.
     A new old-key item that an older build mints later has a new id. It holds nothing of a Castle library, and it is
     left alone.
  6. **Until it's retired,** §3.1 rule 2's stated exception shows on every Castle surface.

### 3.5a The master's twelve-words copy in key files

A device that joined sync without typing a secret has, in its key file, only its library key under the master and
under the Apple key. When the account enters Castle elsewhere, the master is replaced and the account's Apple key
retired. If that device then loses its Keychain before it follows (a reinstall, Migration Assistant), nothing would
open its file. So:

- **Every key file that has a master wrap also carries that master wrapped under the twelve words,** copied from the
  vault's recovery wrap. That copy is non-secret: it is under the 128-bit words, so it adds no brute-force target.
  The passphrase-wrapped master is deliberately *not* copied.
- **It is refreshed from the vault while that master is current,** for example after the words are regenerated, and
  it is replaced only when the key file's master wrap is replaced (the follow).
- **So the words always open the file,** and a backup's frozen key file gains the same road. Opening goes from the
  words, to the master, to the library key.
- No server change.
- **The residue** (§8): if the words are regenerated while such a device is offline, its copy stays under the old
  words until it refreshes. If its Keychain is lost before then, after the account key was retired, only the server
  copy brings its writing back, and its unsynced edits are lost.

### 3.6 Seals (VX-313)

- **The seal.** `HMAC-SHA256(key: HKDF-SHA256(ikm: L, salt: libraryID, info: "variorum.seal.v1:" + purpose), message:
  the sealed fields' canonical JSON)`, naming the sealing key's fingerprint.
- **What it covers:**
  - **plans** (purpose `plan`), sealed under the key in hand when the plan is written;
  - in what this Mac remembers (purpose `memory`), **the fields that could weaken protection** — the gate style, the
    idle lock, the scheduled Markdown export — and the recorded mode.
- **Checking.** Seals are verified after unlock, with the named key, reached through the history when the plan's own
  act has since re-keyed. An Always-ask device verifies after the typed unlock, before any step runs.
- **A failed or missing seal:**
  - a plan is ignored, never resumed, and reported in Diagnostics and the log;
  - a setting reads as the **stricter** value — Always ask; the default idle lock; the export off — until you choose
    again.

### 3.7 Copies

- **One catalog** knows every place copies live:
  - the container's backups;
  - the far folder;
  - `Previous Libraries/`;
  - the lock-time copies;
  - legacy flat backups;
  - `.stale-*` key files.

  It has one name parser and attributes each copy to its **library** (from the pair's key file) and its **Mac** (from
  the subfolder). The restore list, Open Library, the Castle offer and retention all read it.
- **Retention acts only on this Mac's copies of this library** (VX-302): 14 in the container, 14 daily plus 4 weekly
  in the far folder. Legacy flat backups are never pruned automatically; they are listed, and only you delete them.
  Older libraries are kept as today, and the adoption's safety copy lasts only until the open finishes.
- **One route finder.** For a copy under key K it gathers every road to K, in plain words. Those roads are:
  - the copy's own key file;
  - the live key file's history;
  - any key file the catalog knows that holds K, as its current key or in its history;
  - a custody item for K;
  - an Apple wrap whose key is readable;
  - the current master's wrap (synced).

  The route finder is the only source of any sentence about what opens a copy, and the scenario test checks that every
  road it names really opens the copy.
- **The open rule (VX-209):**
  - **A copy of a library this Mac remembers** (the one in the slot, or any it knows) **is re-encrypted under that
    library's current key, straight from the staged copy into place**, and takes the library's mode and account. A
    copy whose rows belong to another account runs the Move road inside the open's plan. The current key comes from
    custody (Touch ID or silent) or a typed secret; it is never the copy's own key.
  - **A Castle copy of a library this Mac remembers in Standard** raises the library to Castle through Use Castle's
    own steps: the passphrase and words typed, a fresh key. Or you cancel.
  - **A copy whose key isn't in the library's history** is flagged in the restore list and the confirm as *"made on
    another Mac, or not by you"* — a planted pair.
  - **A different library** keeps its own key and mode, and the confirm says so concretely. The library you had goes
    to your older libraries.
  - **A plaintext export** carries its library ID. If it's the same library, it is encrypted under the current key
    and mode; otherwise it becomes a new library in Standard, and the confirm says so. Any landing without sync
    bookkeeping gets a fresh sync identity.
  - **The confirm** states the outcome concretely from the open's plan — no "check" (her #216 ruling).
- **The Castle offer under VX-301** (VX-265, VX-210). Once the old shared key is retired, nothing of this library
  opens through the Apple account, so the offer keeps only:
  - the Markdown-exports line (VX-208's, approved);
  - the older libraries of *other* libraries, which still open through the Apple account (each library under its own
    key since the migration), with keep or delete as their own choice (VX-265). Deleting the last copy this Mac holds
    of a library deletes its key file and its Apple key too;
  - the old shared key's checks and sheet (§3.5 point 4), while the store still has it;
  - VX-210's one line, reworded for the new truth: copies outside Variorum's folders aren't deleted, but they no
    longer open through the Apple account either — except Markdown exports, which are plain text.

### 3.8 Accounts (VX-314)

- **The record names the account.** Signing in or out never changes it.
- **New rows are stamped with the record's account,** never the session's (`OwnerIdentity` reads the binding). A
  library with no account mints unowned rows, and joining claims them.
- **The four situations** (the proposal's §3.7 table, kept):

  | the library's account | signed in as | what happens |
  |---|---|---|
  | none | anyone | local only; the Encryption tab offers to turn sync on |
  | X | X | in sync; it follows X's mode |
  | X | nobody | not syncing; the one-road This-Mac-Only screens below are offered |
  | X | another account Y | one screen, *Move it to y@…* or *Sign out*; the same email with a different account is named |

- **The account changes only through acts:** This Mac Only, Stop syncing here, deleting the account from this Mac, and
  Move. Signing back in to an account the library left is an ordinary turn-on-sync, with its consent.
- **Signed out, Use Castle and Use Standard each offer one plain road:** the mode applies to this Mac only, and this
  Mac stops using the old account. This is her #216 screen for Castle, mirrored for Standard. *Stop syncing this
  library on this Mac* sits beside them.

### 3.9 The acts (each one a sealed plan; resume from the first unfinished step; prepare-then-commit)

- **Use Castle.**
  - The door: the passphrase and the words typed (decision 33, kept); the floor warning; *Export a plain copy first*
    offered; and, while the store still has the old shared key, its checks and sheet (§3.5 point 4).
  - Synced: the rotation, exactly today's protocol, with VX-109's fix — `begin` takes the door's vault revision.
  - The new key: its custody item, then the new key file (P, W, plus M when synced; the history; no Apple wrap), then
    the re-encryption.
  - Then the record and what this Mac remembers. The old custody item, every silent item, the per-library-ID items
    the migration kept, and the format-1/2 key files beside the library all go — each only once the history verifiably
    holds its key. A fresh backup is made, and the library's (or account's) own Apple key is deleted and recorded as
    retired.
  - Last, the old shared key is retired (§3.5), unless you chose to keep it for now.
- **Use Standard.**
  - The door: Touch ID or the passphrase, plus the §3.1 rule 5 sentence.
  - A fresh Apple key, minted only here; the key file gains the Apple wrap; synced, the vault gains M under it.
  - Custody moves to silent; the record and what this Mac remembers change.
- **Replace All Keys.** As today (decision 30 included), on a plan, with the history.
- **The follow** (into Castle, into Standard, keys replaced).
  - As today, on a plan that carries every fact a resume needs: "another device switched", the words rule (VX-107).
  - The history grows, and the device deletes its own Apple keys when following into Castle.
  - Until you type the secret, the library opens and you can write; sync waits, with the banner.
  - Typing the old passphrase after it was changed elsewhere is refused with the change named (VX-113, her #205
    ruling): *"Your passphrase was changed on [device] on [day] — enter the new one."*
- **The account acts:** set up sync, enroll/join, connect/Move, This Mac Only, Stop syncing here. As the proposal
  describes, each on a plan, the Move road re-stamping and resyncing.
- **The key doors:** change passphrase, regenerate words. They re-wrap the current key and re-lock nothing else; the
  history needs no secret.
- **Re-link your Apple account** (17m's door, for a Standard account whose Apple key no device can read — after an
  iCloud Keychain reset or a change of Apple ID): Use Standard's key step on an account that's already Standard — a
  fresh account key, minted at the press, landed under the vault's CAS. It never re-lands under the old shared key,
  and it re-keys nothing.
- **Opening a copy** (§3.7).
- **The migration** (§3.13).
- **Retiring the old shared key** (§3.5): Use Castle's last step, or its own door on a store already in Castle.
- **Gate-style changes and the Touch ID re-arm** (§3.10).

### 3.10 Touch ID

- **The choice is stored and sealed.** Touch ID or Always ask is your stored choice, sealed (§3.6). Nothing acts on a
  momentary reading: a closed lid (`builtInSensorInaccessible`), a disconnected or unpaired keyboard, or a lockout
  takes the passphrase road for that one open and changes nothing.
- **After a biometry change:** the item's read fails, and `domainState.biometry.stateHash` changed. Variorum then asks,
  after the passphrase opens the library: *"Touch ID changed on this Mac — a finger was added or removed, or macOS was
  updated. Use Touch ID for Variorum again? Every finger enrolled on this Mac will open it."* It re-arms only on yes.
- **A Mac without Touch ID hardware:** the Castle switch says so, and Always ask is recorded only at your press.
- **The lobby's Touch ID line and button follow the real road** (VX-310):
  - Whenever this library's key has a Touch ID item, the **Unlock with Touch ID button is always there**, however
    many times the prompt was dismissed. The automatic ask happens once, at open.
  - If Touch ID is only temporarily unusable (lid closed, keyboard disconnected or unpaired, a lockout), the button
    stays. Pressing it says why ("Open the lid…") and nothing changes.
  - When no Touch ID item can work, there is no button, and one quiet line says why. Two cases, two lines:
    - no finger enrolled on this Mac: Touch ID isn't set up here;
    - the item was invalidated by an enrollment change: Touch ID changed since you set it up — unlock with the
      passphrase, and Variorum asks about Touch ID again (the re-arm question, above).
  - This reads her *"there should always be a button"* as "always, wherever Touch ID can work". **PROVISIONAL,
    hers to confirm** (§9).

### 3.11 Words (copy)

- **Every sentence about what opens a copy comes from the route finder;** every confirm and Done comes from the
  act's plan.
- **The two-register rule holds.** Everyday surfaces name no key; the field guide's encryption chapter names every
  key. "Box" appears in no user text.
- **VX-211:** a passphrase strength check with no new dependency. Any passphrase Variorum suggests is shaped visibly
  unlike the twelve words.
- **VX-264's rulings, as ruled at #216:**
  - the signed-out screen, "one road, plain";
  - the ordinary Done without "your other devices will ask" when no account moved;
  - the This-Mac-Only Done ending *"Set up sync again later with a new account and it starts in Castle."*;
  - the compromise line returned;
  - "older libraries" wording;
  - the Account tab's *"The server can never read your writing."*;
  - the concrete confirm.

  The field guide's older-copy warning and the confirm's "leaving Castle" line retire: the behaviour they warned about
  is gone.
- **VX-239 / VX-243:** one presenter owns where every protection sheet shows — one host at a time — and re-presents an
  in-flight act after unlock.

### 3.12 Kept exactly as today

- the cryptographic primitives;
- the vault protocol: the key proof and challenge, CAS, the rotation seq, version-neutral re-encryption, one rotation
  at a time;
- decision 30 (a Standard Replace All Keys stays under the account's Apple key);
- decision 33 (both secrets typed for the rotation doors);
- the follow's substance;
- the lobby's three roads and the vault road;
- backups as pairs, never rewritten (decision 11);
- the restore hold and Resume Sync;
- `Previous Libraries/`;
- the plaintext export's exclusions;
- the two-register rule;
- the phone sharing the same brains.

### 3.13 The migration (existing stores: her Pro, Air and phone, the dev stores, the beta testers)

It runs once, at first unlock on the new build, **as a plan**:

1. **Finish anything in flight with today's runner.** VX-235's stuck marker is cleared on proof that the switch never
   happened: the library still opens under its old key, and the new key file never landed.
2. **Work out the mode once with today's rules.**
   - A synced library with the vault in reach takes the vault's word; without it, the mode is recorded as *not yet
     confirmed*.
   - Corner 45's ambiguous case records Castle, with a one-time notice and Use Standard one press away.
   - Nothing Apple-reachable is written meanwhile.
3. **Write the record, what this Mac remembers (sealed), and the device identity** carried over from the sync-keys
   item, so no new device cursor is created.
4. **Add the per-key custody items,** verified. The old per-ID items stay in place, unread, for one release — and
   entering Castle removes them once the history holds their key (§3.9).
5. **One pass of the catalog:** attribute existing copies to their library and Mac; new backups go to the
   per-library, per-Mac subfolders. The fold below reads the key files the catalog finds.
6. **Write the format-3 key file** and fold every reachable older key into the history:
   - keys from the old key files, through the old shared Apple key when it is readable;
   - keys reachable through the passphrase, **typed once if needed**;
   - custody.

   Old key files stay — for one release, and in any case until the history verifiably holds their key. A key the fold
   couldn't reach (say, one under a passphrase from long ago) keeps its file: it's that copy's only road. The 13p
   escrow items for keys now in the history are removed.
7. **Move everything off the old shared key** (§3.5 point 2): other libraries' copies first, then the live library (a
   synced account only with a fresh vault read, under CAS), then **a fresh backup pair** of the live library.
8. **A store already in Castle** gets one notice: copies from before Castle still open through the Apple account until
   the old key is retired, with the door to retire it (§3.5 point 4).
9. **The road back.** Until the first re-key under the new build, an older build still opens the library, because its
   items and files are untouched. After that, the road back is the A1 safety copy with the passphrase or words.

### 3.14 VX-212 (its own phase, after the main rebuild works, designed with her first)

This is a starting shape, not a ruling:

- An undecryptable row below the rotation seq is **quarantined**: kept sealed, listed in Diagnostics, never deleted.
- The pull skips quarantined rows by their recorded seq, so one bad row no longer refuses the whole round.
- The rotation completes over the quarantine.
- Quarantined rows are retried whenever this device's keys change.

It is `Sync/` work: Fable writes it, under a convergence pin, with its own SyncSpec line.

### 3.15 What gets deleted (her ruling: *"I'm fine getting rid of each of those already built things"*)

- corner 45 and `RawKeyCustody`;
- `Posture.derive`'s five-input derivation and the 13p legacy read-through, after migration;
- every reading that writes: `effectiveGate`'s Apple landing, `landCustody`'s Keychain writes and
  `CustodyCollisionRule`, `ensuredEnvelope`'s set-aside and new ID, and the item read that writes key files;
- custody named by library ID;
- several key files per folder and the newest-modified rule;
- the in-file `RotationMarker` (`sync_state.rekey_in_progress`) and the `switchPending` / `thisDeviceOnly` defaults;
- the five definitions of "enrolled";
- the session-stamped owner;
- Castle settings in UserDefaults;
- the shared never-deleted Apple key as a live road, and 17m's Re-link re-landing under it;
- VX-202's belts;
- the duplicate safety copy;
- the confirm's "leaving Castle" line and the guide's older-copy warning;
- the Finder-revealing "Restore from a Backup";
- the identity-only silent sync item.

---

## 4. The proof

### 4.1 The scenario test (phase 1 builds it; every later phase extends it)

A headless world, run under `swift test`. It contains:

- two Macs and a phone, two Apple accounts and two Variorum accounts;
- a fake server with CAS and rotation;
- fake device keychains with Touch ID semantics — invalidated on an enrollment change, transient when the lid is
  closed;
- a fake iCloud Keychain with propagation delay, delete propagation and no recovery;
- fake file systems that support copies, Time Machine rollback and container deletion;
- real key files and real key wraps, with test-speed passphrase stretching.

**Every user act** is in its action alphabet:

- create a library; set or change the passphrase; regenerate the words;
- Use Castle (with or without keeping the old shared key for now); Use Standard; Replace All Keys; Re-link the Apple
  account; retire the old shared key;
- turn on sync; sign in as X or Y; sign out; This Mac Only; Stop syncing here; delete the account; Move;
- back up; restore backup *n*; open older library *n*; open a plaintext export; send a library to the other Mac;
- lock and unlock;
- add a fingerprint; close the lid; unplug the keyboard; trigger a lockout;
- turn iCloud Keychain off and on; switch Apple ID; wipe a keychain; replace a Mac;
- crash at any step of any act;
- **run an older build on a device:** it reads and mints only the old shared key, writes its wraps under it, and its
  Re-link re-lands the account's vault copy under it.

**The adversary's actions** are in it too, all with the login password:

- edit a key file;
- plant a plan;
- edit a sealed setting;
- read or delete keychain items as Keychain Access could — never Touch ID items;
- swap the library file at its place;
- delete the container and open an old copy;
- plant a crafted pair in the iCloud Drive folder;
- share one backup folder between two Macs.

**Starting states:** every shape today's builds leave (§3.13), including older libraries of other libraries, copies
whose only road is the old shared key, and Standard libraries with no passphrase and no words. **The promises, checked
after every action:**

1. **Known:** one record per live library, and what this Mac remembers agrees with it.
2. **Castle means Castle:** no silent item holds any of the library's keys; no Apple key the record lists as retired
   exists; no Apple key wraps the current key; the vault has no Apple copy; and nothing a login-password holder can
   read opens the library or any copy made on this Mac or on a device of its account that has followed — except
   copies under the old shared key while it exists (the stated exception).
3. **Standard means Standard:** the Apple wrap exists whenever the library's or account's Apple key is readable;
   otherwise the assessment says "waiting".
4. **No silent change:** the mode and account change only at a deliberate act or its follow. A copy never lowers the
   mode or brings its own key.
5. **Nothing stranded:** with the secrets the model says you hold, every copy Variorum wrote opens. The exceptions are
   exactly the stated ones: the floor; what a retirement sheet listed before you confirmed it; what was on a device
   still on an older build when the old key was retired (the sheet's sentence); and §3.5a's residue.
6. **Crash-safe:** after a crash at any step and a relaunch, the act finishes or rolls back, the library opens, and
   no copy carries a half-finished act.
7. **Converges:** every device of an account ends in the account's mode and keys.
8. **The posture law:** after entering Castle, nothing from before opens anything written after.
9. **Honest words:** every road the route finder names opens the copy, and every confirm and Done matches what the
   act did.
10. **Sealed:** no planted or edited file or keychain item changes the mode, the custody or the gate style.
11. **Own copies only:** retention and the offer never touch another library's or another Mac's copies.

**Red-on-old for new code: mutation pins.** Each known bug's sequence is a fixed scenario:

- VX-209's way back;
- W-1;
- VX-235's crash;
- VX-107's double crash;
- the file swap;
- the planted plan;
- the cross-Mac prune;
- the old key's fold before retirement;
- **two libraries on one Apple account:** a Mac entering Castle and a second Mac's local-only Standard library with no
  passphrase — the second Mac updated, and not; retirement strands nothing outside promise 5's exceptions;
- **an older library of another library,** Standard with no passphrase: it still opens after retirement, on its own
  key; and one whose library later entered Castle: its pre-Castle copies stop opening through the Apple account;
- **the window after the move:** the Mac is lost right after moving off the old key; the fresh pair opens its copies
  elsewhere;
- **an older build's Re-link** puts the account back on the old key; the repair moves it off again, and the retirement
  re-checks before deleting;
- **one local-only library on two Macs** (sent, no sync), one entering Castle: the other's own key is never deleted;
- **a silently-joined device** loses its Keychain after the account entered Castle elsewhere: the words open its file
  (§3.5a).

Each is shown to **fail** when its guard is removed from the new code, and to pass with it.

### 4.2 The gates the model can't reach

The scenario test can't reach these:

- real-Keychain drills on a throwaway scope: Touch ID invalidation, access groups, deletes of synchronizable items;
- the posture drill (VX-233, healed in phase 3);
- the migration drills per shape;
- the restore drill;
- dev-store walks in both voices, under held stage claims;
- her hands-on acceptance on both Macs and the phone.

The Keychain test tripwire forbids test-process writes to the real and dev scopes, by design. So the Keychain legs run
on a throwaway scope and through the Debug app on the dev store.

### 4.3 The key-map acceptance (her ruling)

`notes/plans/vx-266/castle-target-key-map.html` shows the built system:

- Castle and Standard, local and synced;
- every key's home and locks;
- the history;
- every act's steps;
- who can open what.

The final phase's closeout carries **the map table**: one row per map element, each naming the test, drill or walk
that proves the code matches it, and its result. An element with no proof, or a mismatch, blocks the effort's close.
If a phase changes the design, the map changes in the same commit, at her word.

---

## 5. The phases (each its own run, ticket, branch, ladder and closeout; one sitting ruled them all)

The cast, in every phase:

- Fable orchestrates and cold-reviews; Opus implements.
- Every `Sync/` line is Fable's, and this effort holds the one Sync/-or-custody slot.
- `/architect-phase` is recommended (custody and design-heavy); `/run-phase` is hers to pick at any kickoff.
- One acceptance unit per implementer session.
- Every bug-class change lands red-on-old.
- No new dependency, and no lockstep event: the server is untouched except phase 6's design, if it needs one, and
  VX-213's `pg_temp` fix at her go.

| phase | ticket | what | acceptance units and evidence | members |
|---|---|---|---|---|
| **1 — the headless core** | VX-305 | `Sources/VariorumCore/Protection/`: the record, key file v3 and history, what the Mac remembers and its seals, the custody/Apple-key/vault interfaces, `assess`, the executor and sealed plans, the catalog and route finder with attribution and retention, and §4.1's scenario world | **one phase-sized unit** (the posture model), built in four sessions (model · assess and routes · executor · the world). Evidence: the generated runs green across seeds; every fixed scenario green; every mutation pin red without its guard. **GO / NO-GO at close** — a quality gate; her word is "go even if it delays launch" | VX-228 (corner 45's model), VX-235 (plans), VX-263 (history), VX-302 (attribution) |
| **2 — the open road and the migration** | VX-306 | the route and lobby on roads; per-key items, what the Mac remembers, the record and key file v3 going live; the migration (§3.13); the phone builds and opens | two units (the open road · the migration). Evidence: the migration drill per §3.13 shape; the Keychain leg on a throwaway scope; the dev store under a held claim; her stores rehearsed on byte-copies; the restore drill | VX-228, VX-209 (the open rule's road), VX-263 (the fold), VX-301 (the moves off the old shared key, the fresh pair), VX-213 (the leftover key file), VX-310 (the lobby's Touch ID) |
| **3 — the acts** | VX-307 | Use Castle, Use Standard, Replace All Keys and the follow on sealed plans; the Apple keys' lifecycle (VX-301); the `Sync/` lines (VX-107, VX-109, the marker leaving the library file — `SyncEngine.refuseIfRekeyIncomplete` reads the plan); the old shared key's checks and retirement, and the vault's move-back repair; VX-233's drill healed | one road per session. Evidence: each road's drill; the posture drill green; convergence suites for the Apple-key mint/wait/delete rules | VX-301, VX-313, VX-107, VX-108, VX-109, VX-113, VX-233 |
| **4 — accounts and the key doors** | VX-308 | the binding and rows owned by it (VX-314); the four situations; the one-road signed-out screens both ways; Stop syncing here; Move; setup, enroll and connect; change passphrase and regenerate; the Touch ID re-arm; sealed gate style; Re-link minting a fresh account key; the one presenter | one door per session. Evidence: each door's drill; the account-sequence walk (signed in, out, into another account, back) | VX-314, VX-313, VX-301 (Re-link), VX-264 (the signed-out screen), VX-239, VX-243 |
| **5 — copies and words** | VX-309 | the restore list over the catalog (older libraries included); Open Library and the open rule; the plaintext export's ID; retention per library and Mac; the Castle offer under VX-301, with the old shared key's sheet and notice; Data Safety and `RESTORE.md`; VX-211; VX-264's and VX-210's words | two units (copies · words). Evidence: walks in both voices; the restore drill; **the key-map table (§4.3)** | VX-209, VX-210, VX-211, VX-264, VX-265, VX-302, VX-213 (the record corrections, the privacy text) |
| **6 — VX-212** | VX-212 | designed with her first (§3.14), then built under Fable | one repair rule. Evidence: convergence suites plus one live two-device round | VX-212 |

**Sizing is guidance** (her ruling, §1). Phases may hold more than two phase-sized units, or merge, at the
orchestrator's judgment, recorded in the phase plan. The split above is a recommendation for ladders a cold reviewer
can hold in one read, not a rule.

**Order and gates.** 1 → (go/no-go) → 2 → 3 → 4 → 5 → 6. VX-212 (phase 6) comes *"once the first plan is
working"* (her word): its design sitting follows phase 5's close. A phase closes on its kind's evidence, never on a pin alone. The `/Applications` refresh follows each phase's
walk or drill.

**The riskiest part** is phase 2's migration, which touches every existing store. **The cut lines, if ever needed:**
the restore list's older-libraries section and the per-Mac far-folder subfolders (a filename tag would do).

---

## 6. Every ticket, placed

| ticket | settled by | phase |
|---|---|---|
| VX-209 the way-back revert | the record + per-key items + the open rule; FLIP `VX209WayBackRoundTripTests` | 2, 5 |
| VX-228 corner 45 | deleted; the mode recorded | 1, 2 |
| VX-263 W-1 | the history; the migration's fold; the route finder's words | 1, 2, 5 |
| VX-264 her #216 rulings | §3.11 / §3.8 | 4, 5 |
| VX-265 a separate delete choice | the offer's other-libraries group | 5 |
| VX-210 other folders | §3.7's reworded line | 5 |
| VX-235 the unfinishable marker | prepare-then-commit; sealed plans; the migration clears today's stuck markers | 1, 2, 3 |
| VX-107 the double crash | the follow's plan carries the facts (`Sync/` — Fable) | 3 |
| VX-108 doors on a stale reading | doors read `assess`; the acts read the vault they fetch | 3 |
| VX-109 `begin` re-fetches | `begin` takes the door's revision (`Sync/` — Fable) | 3 |
| VX-212 the poison row | its own design | 6 |
| VX-213 tidy-ups | the leftover key file (fold, then retire); escrow items removed; `pg_temp` at her go; the record corrections and privacy text | 2, 5 |
| VX-211 passphrase strength | §3.11 | 5 |
| VX-239 / VX-243 sheets | one presenter | 4 |
| VX-233 drill rot | the runner takes dependencies explicitly | 3 |
| VX-301 retire the Apple key | §3.5: every library, older library and account moves to a key of its own; Use Castle retires the old shared key after its checks; delete on sight by recorded id; the vault's move-back repair; Re-link mints fresh | 2 (the moves), 3 (lifecycle, retirement), 4 (Re-link), 5 (the sheet's words) |
| VX-302 cross-Mac pruning | §3.7 attribution and retention | 1, 5 |
| VX-113 the changed-elsewhere refusal | §3.9: the follow names the change | 3 |
| VX-313 seals | §3.6 | 1 (the model), 3, 4 |
| VX-314 rows owned by the library's account | §3.8 | 4 |
| VX-310 the lobby's Touch ID | §3.10: the button and line follow the real road | 2 |
| VX-266 flagship | this file | — |

Outside the project, settled in passing and hers to fold in: VX-100 (asked twice — the open and the enrollment in one
session), VX-101 (older libraries in the restore list), VX-102 (a landed copy's flags), VX-104 (an older-library
drill), VX-152 (Lock reentrancy), VX-240 (a wrong instruction mid-act).

---

## 7. Canon deltas, landed at the closeouts (contract lines plus pointers, never history)

- **`pre-13x-postures-design.md`:**
  - §3.1's posture row becomes "recorded in the library, remembered by the Mac, reconciled", and its dials row
    becomes "what the Mac remembers, sealed".
  - §3.3's local-only set grows by `protection_record`.
  - §3.5 becomes format 3: one file and the history.
  - §3.7 and decision 14 now cover Standard too.
  - Decision 6 and corner 5: the Apple key is **retired** on entering Castle; the old shared key, after every
    library, older library and account has moved to a key of its own.
  - 17m's Re-link door: it mints a fresh account key (its never-mint rule retires with the shared key).
  - Decision 8's local half reads "its own record's".
  - Decision 11 gains the history.
  - Decision 13: custody per key.
  - Corner 4: pre-Castle copies stop opening through the Apple account.
  - Corner 14: each account its own Apple key.
  - Corner 34: device-own keys by id.
  - Corner 36: the stored choice.
  - Corner 45 is retired.
  - §6's sentence becomes §3.1 rule 4.
- **AppSpec §7:** the record table, the export identity table, format 3; `rekey_in_progress` retires. **AppSpec §12:**
  13x's custody-collision clause; the restore list's reach; one restore door; the offer under VX-301.
- **The 13x plan:** the row-4 custody-collision memo and ledger 5 (an export lands under its own library ID).
- **SyncSpec §3's pre-13x paragraph:** custody per key, and the rotation's resume record leaves the library file.
  VX-212 adds its own line.
- **OverallModel:** none. No invariant is relaxed.

---

## 8. Risks

- **A rebuild before launch.** Mitigated by the order: proven headless first, then a gate, then road by road with
  drills.
- **Stores we haven't seen** (0.9 testers). Every old shape is a drill, and nothing Apple-reachable is written while
  unconfirmed.
- **iCloud Keychain behaviour.** Deletes and propagation are documented but not drilled yet; the repair is "delete on
  sight", and the throwaway-scope drill comes first in phase 3.
- **Fakes drifting from the real Keychain** (VX-233 / VX-106's pattern). The fakes are built from the measured facts,
  and the real drills stay the gates.
- **Scope creep.** The ticket list is the scope.
- **The residue — stated, not fixed:**
  - a device still on an older build when the old shared key is retired keeps its library working there, but loses
    its Apple-account recovery; if it is lost or reset before it updates, its library and backups open only with a
    passphrase or the words, and without either, not at all. The sheet says so.
  - backups an older build made on a silently-joined device, under a key a Standard Replace All Keys retired before
    that device updated.
  - §3.5a's: words regenerated while a silently-joined device is offline.

---

## 9. Open (decided at the phase that meets it, recorded PROVISIONAL, logged in QUESTIONS)

- **The old shared key's retirement as Use Castle's step** (§3.5 point 4), with *keep it for now* offered only when
  something listed would stop opening, and its own door for a store already in Castle — PROVISIONAL, hers to confirm.
  Her VX-301 ruling predates the finding that the key is shared by every library on the Apple account.
- **VX-310's reading of "always"** (§3.10): the button is always there wherever a Touch ID item exists, and gives way
  to a line naming why when none can work — PROVISIONAL, hers to confirm.
- **The exact Touch ID re-arm and retirement-sheet copy:** her approval at phase 4 and phase 5's walks.
- **A retention rule for older libraries:** kept as today until she rules.
- **VX-212's design:** her sitting before phase 6.
- **Whether a release version of the key map ships** in the field guide's encryption chapter: after phase 5, re-voiced
  and verified against the shipped build.
