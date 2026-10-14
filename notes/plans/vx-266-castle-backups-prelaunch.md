# VX-266 — Castle & backups before launch: the design and the plan

**Status: DESIGN RULED, 2026-10-13; revised at her round-2 ruling the same night and her round-3 rulings on
2026-10-14 (§1), then for the late extra read of round 3, with calls made provisionally overnight at her word (§9).
Nothing built yet.** This file
is the binding design for the effort ("Castle & backups before launch", flagship VX-266) and its phase map. Each phase
gets its own just-in-time execution plan beside this file, with a kickoff message at its top (the split-phase rule,
`notes/PhaseSizingGuidance.md` §3). The first one is already written: `notes/plans/vx-305-castle-core.md`.

**The visual twin of §3 is `notes/plans/vx-266/castle-target-key-map.html`.** It is an acceptance artifact: the
finished code is checked against it, element by element (§4.3, her ruling).

**Provenance.** The design merges two documents:

- `notes/plans/vx-266/design-proposal.md` (the first design, revised after `cold-read-1.md`);
- `notes/plans/vx-266/second-opinion.md` (an independent design and assessment, revised after
  `second-opinion-cold-read.md` and `second-opinion-apple-facts.md`).

Read them for the *why*. This file says only what is true and what gets built. Where the two documents differ, this
file follows the second opinion as she ruled it.

**Reviewed after the merge** by the first design's author, in three rounds at her ask
(`notes/plans/vx-266/first-designer-review.md`), then by cold readers: round 1 (`design-cold-read-r1.md`), and round 2,
read by a Fable reviewer and an Opus reviewer in parallel (`design-cold-read-r2-fable.md`, and
`design-cold-read-r2-opus.md` with its answer to her question on improving the system). Round 2's findings, the
reviewers' agreement and her ruling reshaped §3 and §4. Round 3 was read by an Opus reviewer
(`design-cold-read-r3-opus.md`); the Fable reviewer started beside it finished late, on Opus, as an extra read that
isn't a ladder round (`design-cold-read-r3-extra.md`). Every finding and its disposition is in those files and in
`design-cold-read-r2.md` and `design-cold-read-r3.md`, each settled with the round-2 Fable reviewer.

---

## 1. Her rulings (2026-10-13, verbatim where quoted)

At #216, in her review of both documents, and after each review round:

- **The direction.** *"I want to handle them all together before launch - I don't want this mess to propogate once I
  have users in every conceivable configuration and state with backups in every conceivable configuration and
  state."*
- **The principle.** *"in castle = safe. out of castle = not safe. and it's pretty much as simple as that and we do
  not need to contort ourselves to fit a halfway posture."* Disclaimers are welcome where they make a sentence true:
  *"i'm honestly fine with stating a decent number of disclaimers so that people get the picture."* Refined at round 2
  (next): *"i don't really want disclaimers i want simple and clear system even if it is more onerous to switch
  between and switching makes your backups hard to open - that's fine."*
- **A fresh key at every crossing — round 2, ruled 2026-10-13.** Her direction, said to the round-2 Fable reviewer and
  relayed verbatim: *"hmm I like the idea of landing the key instead of the history. this is what my opus session
  proposed to me - where do you agree and disagree? I want the system to feel very easy to understand to people - so a
  different library landing requiring a new key makes sense to me and is is similar to what I was thinking with rotate
  key at change into / out of castle, rotate key when you leave an account, etc. i don't really want disclaimers i want
  simple and clear system even if it is more onerous to switch between and switching makes your backups hard to open -
  that's fine. standard library leaving account - if they've forgotten their passphrase cant they just reset it if
  they're in standard anyway?"* (Yes: in Standard this Mac holds the key, and today's forgot road already sets a new
  passphrase.) Asked for one yes on the shape the two reviewers and the design's owner then agreed — a fresh key
  whenever the library crosses a line (into or out of Castle, out of an account in either mode, onto another Mac);
  leaving Castle taking nothing back, every copy from before the leave sealed behind the passphrase and words; keys born
  Castle or Standard for life; a family tree of every key; one Apple key per library per Mac, an account's only for its
  vault; this Mac's facts kept on this Mac; Use Castle checking at its door; a landing that takes one secret and has the
  other typed or made new; every follow out of Castle typing one secret — and on phase 2 staying in Debug builds until
  phase 3, she said: *"yes i agree and yes phase 2 will stay in debug builds until phase 3"*. It supersedes one clause
  of her history ruling below: copies from before Castle no longer reopen through the Apple account when the library
  leaves Castle.
- **Round 3, ruled 2026-10-14.**
  - **The release switch.** Told that phases 4 and 5 rebuild other doors that write keys, she said *"that's fine on my
    devices waiting for the new system til the end of phase 5"*, then: *"yeah we'll wait to turn the new system on in
    release builds / wait to put it in release builds til i'm ready to release it."* So the whole new system stays in
    Debug builds until her word at release (§5). This supersedes "until phase 3" above.
  - **The anchor keeps the secrets of its day.** Told that an anchor that follows the passphrase and words can't reach
    her other devices, she said: *"i think that it's probably good to leave it fixed on the day you left ... i think
    that's fine that the anchor doesn't follow your pasphrase and words - c opies before you left castle open with the
    passphrase you had when you lefti s solid. leaving castle doesn't make words so your current is good - solid."*
    On a device that follows out of Castle, her sentence holds because that device's anchor is locked at its birth
    with the secret typed at its follow as well (§3.4) — a call made provisionally overnight, for her confirm (§9).
  - Asked whether the design ever changes a backup's keys behind her back, she was told no: a backup's locks are
    written once, with it, and never touched again, and a key changes only at an act she takes (§3.4, §3.12).
- **VX-209 — the mode belongs to the library; opening a copy never lowers it.** This reverses her earlier yes to the
  "you'll be leaving Castle" confirm line.
- **VX-263 — the key history is locked under the current key.** *"if you leave castle, your apple account can open
  the copies variorum made while you were in castle. again, if stated clearly, i'm fine with that."* Reshaped by her
  later rulings the same day (history flows into Castle, never out — below — and round 2's, above): those copies now
  stay safe.
- **VX-301 — retire the Apple key when entering Castle.** *"I think it's fine for people to lose access to previosu
  backups if they lost their passphrase / words / touchID + they're going into castle, so long as they're adequately
  warned about it. they can always export it as plaintext if they want to, but going into castle means going into
  protection and I agree with deleting the iCloud key when they go into castle."* Her Keychain Access check confirmed
  why: the dev scope's Apple key was revealed with the login password, on the Pro and on the Air. The review then
  found that key is shared by every library on the Apple account, which this ruling's question hadn't put in front of
  her. Asked about a *keep it for now* choice, she asked: *"if keeping it for now is offered, what are the
  implications of that? what risk does it expose? do you think it's owrth having to keep that door open forever?"* —
  answered on VX-301. **Ruled 2026-10-13:** she confirmed the shape §3.5 point 4 draws — Use Castle always retires
  the old shared key after its checks, no keep-for-now, and a library already in Castle gets one calm ask and a door
  that goes once pressed.
- **Leaving an account (§3.8), ruled 2026-10-13.** Asked whether a Castle library leaving its account should re-key,
  with its copies from while it synced staying reachable through that account while it's in Standard, she said:
  *"so basically backups from when it was in standard still open to the standard account that remains? i imagine
  that's fine"*. (The nuance said back to her then — that the reach also covered copies made while the account was in
  Castle, if the account later returned to Standard — no longer holds, and she was told so at round 3: an account
  returning to Standard makes a fresh master, and its fresh Apple key locks only that one.) Extended at round 2
  (above): a library leaving an account re-keys in either mode, so nothing written after it left opens through that
  account.
- **History flows into Castle, never out (§3.4), ruled 2026-10-13.** Her question: *"why don't we just enforce key
  rotation when they go to standard or something? … it seems to me like maybe we could avoid a LOT of this key changing
  confusion from standard to castle and castle to standard and leaving sync and starting new if we just enforced key
  rotation at every posture switch. thoughts?"* Asked whether leaving Castle should change the key with Castle's keys
  staying behind, she picked yes. Leaving Castle re-keys, and the keys made in Castle stay behind. This supersedes the
  consequence she accepted for VX-263 (*"if you leave castle, your apple account can open the copies variorum made
  while you were in castle"*): those copies now stay safe. Completed at round 2 (above): the new key takes back
  nothing — the keys from before Castle stay behind with Castle's, sealed in the Castle anchor (§3.4).
- **Landing a library from another Mac (§3.7), ruled 2026-10-13:** *"i think you should be able to land a Castle
  library with just the passphrase OR the words - that's what we guarantee for being able to access it."* Reshaped at
  round 2 (above): a different library lands under a fresh key with no history, so no key is held by two Macs. Her
  guarantee holds: one secret lands it, and at the landing the other is typed or made new.
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
    launch the touchid prompt"*. **Ruled 2026-10-13:** asked which reading, she picked the button whenever a Touch ID
    item exists; a line instead with no finger enrolled or after Touch ID changed. Built to those words at round 2
    (§3.10): the "changed" line now follows a press that fails, because the stored state can't tell a changed finger
    from a macOS update.
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

**The tickets:** the project's 17, plus VX-301, VX-302, VX-310, VX-313, VX-314, VX-317 and VX-113. §6 maps each to
its phase.

---

## 3. The design (the contract)

### 3.1 What users are told (true by construction; the scenario test checks every line)

1. **Standard or Castle is a choice for your library** — and, once it syncs, for your account. Only a deliberate act
   changes it: Use Castle, Use Standard, a follow of either on another device, or joining or moving to an account,
   which always asks first.
2. **In Castle, nothing reachable through your Apple account or this Mac's login password opens your library, or any
   copy Variorum made of it on this Mac — or, once it syncs, on any device of your account after that device
   follows.** Your passphrase, your twelve words, or Touch ID on a device you enrolled open it. Lose all three and it
   is gone — said at the door, with *Export a plain copy first* offered. A copy you send to another Mac lands there
   under a key of its own (§3.7).
   **The stated exceptions** — each shown where it applies, on the affected copy's *Opens with* line (§3.11):
   - *A library already in Castle before this change:* its copies from before Castle, made under the old shared Apple
     key (§3.5), open through your Apple account, and on this Mac for anyone with its login password, until that key
     is retired — one press, asked once on each device and kept in Settings ▸ Protection. A library entering Castle
     after this change retires it as Use Castle's last step (if that step's last check stops it, the same door shows).
   - *A library that synced with an account in Standard and later left it:* its copies from those Standard days open
     through that account until the account replaces its keys or enters Castle (§3.8). Nothing written after it left
     does, and nothing made while the account was in Castle ever does.
   - *A library sent to another Mac before this change:* the two copies share its key until either one crosses a line
     (§3.4); the retirement sheet names the other Mac's key file when it can see one.
   - *A retirement made while this Mac's iCloud Keychain is off* holds on this Mac at once, and everywhere once iCloud
     Keychain carries the deletion (§3.5).
   - *A Markdown export you turn back on in Castle* is plain text, by your choice at that door (§3.9).
   - *Copies locked under an Apple key in an Apple account this Mac has left* — made in Standard before the Mac
     switched Apple ID — open through that former account for as long as its iCloud Keychain keeps the key; this Mac
     can't delete it there (§3.5). Their *Opens with* line says so, and they can be deleted.
3. **In Standard, your Apple account opens your library and every copy Variorum made of it since it came into
   Standard** — created there, left Castle, or arrived on this Mac — through iCloud Keychain, when it's on, which
   Variorum can't see; and so does anyone who can sign in to this Mac. Said on the Standard card.
4. **Opening a backup brings back your writing as it was, in the mode your library is in now.** A synced library
   then catches up when you resume sync.
5. **Leaving Castle gives your Apple account your library from then on: the library itself, with everything you wrote
   in it, and every copy made after you leave. No copy made before you left opens through it** — those open with the
   passphrase or the twelve words you had on the day you left. Leaving never makes new words, so that day's paper keeps
   working. Your other devices each follow with one secret typed, so their own copies from before open with the words,
   and with the passphrase when it was the one typed there; each copy's *Opens with* line says which, and from which
   day (§3.4). Said in those words on every road into Standard: the leave screen, joining or moving to an account in
   Standard, and the typed step of a follow.
6. **Signing out never changes how your library is protected.** Signing in to a different account changes nothing
   until you choose to move the library there.
7. **Your library's key changes whenever it crosses a line** — into or out of Castle, out of an account, onto another
   Mac. Into Castle, every older copy comes along. Out of an account, your copies come along too, and the account you
   left keeps only what came before. Out of Castle and onto another Mac, the new key starts clean: what came before
   keeps its own locks (§3.4).

### 3.2 The things, each with one home

| thing | home | written by | travels with copies |
|---|---|---|---|
| **The library file** | the slot (unchanged path); SQLCipher under the current library key L | the executor (re-keys); the app (writing) | it *is* the copy |
| **The protection record** — the library's own facts: library ID; mode (`castle` / `standard`, the current key's kind) and whether it's confirmed; account (none or one id); key epoch; current key fingerprint; changed-at; and **the family tree** — every key the library has ever had, non-secret: its fingerprint, its kind (Castle or Standard, for life), which Mac made it, and when it was made and retired (mirrored, sealed, in what this Mac remembers; the two are unioned at open, §3.6). **One device section per device** — that Mac's own facts (§3.6): its device identity and hardware marker (a hash of this Mac's hardware identity with a random salt the record carries — never the identifier itself — so it recomputes on the same hardware, after unlock like every decision, and a marker that leaks alone, say into a log, names no Mac — so no log line, Diagnostics entry or support bundle ever carries a marker or the salt, as none carries key material); the act in flight (its sequence number, the act, and the keys it moves between — none when idle); the settings that could weaken protection (the gate style, the idle lock, the scheduled Markdown export); the Apple key ids that Mac minted or followed for the library and its account, and whether each is retired; the old shared key's state; and a version that only grows | a table inside the library file, `protection_record`, in the local-only family (no lockstep; the plaintext export leaves it behind) | the executor only | the library's facts, yes; a device section counts only on its own Mac (§3.6), and a copy's act in flight is cleared when it's opened (§3.7) |
| **The library identity for exports** — the library ID alone | a small plain table the plaintext export keeps (the derived-tables precedent: local, never synced, kept by the export) | the executor | yes, including in plaintext exports |
| **The key file, format 3** — library ID; the current key's fingerprint and epoch; the current key wrapped under P (with its KDF descriptor), W, M (when bound) and, for a Standard key only, A — this Mac's own Apple key for the library (each Apple wrap names its key's id; on stores from before this change the old shared key's wrap rides beside it until that key is retired, §3.5); **the history** — the older keys the current key takes (§3.4), each wrapped directly under it; **the Castle anchor**, after a leave — the keys from before the leave, sealed under one anchor key that only the secrets of that day open, carried unchanged by every later re-key (§3.4); and, when bound, **that master wrapped under the twelve words**, copied from the vault's recovery wrap (§3.5a) | **one** file beside the library, `variorum-library-keys.json` (a name older builds never read) — and, for each other library this Mac holds copies of whose newest copy is in Standard, this Mac's own key file for it in `Backups/<library8>/<mac8>/`: in the container, and beside this Mac's copies of it in the far folder (§3.5). Each backup pair carries a frozen copy written with it, never rewritten | the executor only | yes — as the pair's frozen copy |
| **Custody items** — one Keychain item per library key, of the key's own kind for life: `silent` for a Standard key (`WhenUnlockedThisDeviceOnly`), `touchid` for a Castle key (`.biometryCurrentSet`), none for a Castle key under Always ask. An item goes when its key is replaced; nothing moves a key from one kind of item to the other | device keychain, service `io.lduarte.Variorum.library-key`, account `<scope>-<fingerprint16>-<class>` | the executor only | no |
| **Sync keys** — M, C, J for the bound account, **held by what they can reach**: the Castle way (`touchid`, or session memory under Always ask) while they reach a Castle-era key — in Castle, and through a leave's rotation until the previous corpus key leaves the vault — and `silent` otherwise (§3.9). Kind for life is a library key's rule; a sync key's custody follows its reach | device keychain, one item per account, `silent` or `touchid` (none under Always ask: session memory) — service `io.lduarte.Variorum.sync-keys`, account `<scope>-<accountID>-<class>` | the executor only | no |
| **What this Mac remembers** — per library ID: its location (scope), current fingerprint and epoch, mode and account last confirmed, **the device identity** (`<mac8>` is its first eight characters) with a hardware marker that mints a new identity when the item turns up on other hardware (§3.13) — both also kept in this Mac's device section, so a Mac whose memory item is gone finds its own section by its hardware (§3.6) — the biometry state hash when its Touch ID item was made (a hint for the lobby, §3.10), the vault facts today's key file caches (the KDF descriptor, corpus key id and recovery-wrap digest), nudge dismissals, a mirror of the key file's wraps, history and anchor and of the family tree, and **the second home of this Mac's device section** (the same fields and version, §3.6) | one non-secret Keychain item per library ID (device-only), service `io.lduarte.Variorum.memory`, account `<scope>-<libraryID>`; **sealed** (§3.6) | the executor | no |
| **"A library lived here"** | a marker file in the app's own container beside the slot | the executor | no — deleting the container starts fresh |
| **Plans** (one per library at a time) | `variorum-plan.json` beside the library, excluded from backups (`NSURLIsExcludedFromBackupKey`), **sealed and named by the act in flight** (§3.6), never holding a secret | the executor only | no |
| **Apple keys** | iCloud Keychain, synchronizable, the shared access group; **named by their own id** — `<scope>-apple-key-<id>` — **one per library per Mac**, minted and named by that Mac for its key file of that library (the live one, and other libraries whose newest copy is in Standard), and **one per sync account**, which locks only the account's master in the vault (§3.5). The **old shared** `<scope>-apple-key` is never written by this build, and deleted only by its retirement (§3.5) | the executor only | — |
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
  - the mode (the current key's kind) and the account, each *confirmed* or *not yet confirmed*;
  - the **roads** that open the file;
  - every door with its reason;
  - the **repairs** owed and the **acts** owed;
  - the words every surface shows.

  Everything that decides calls it: the route, the lobby, the doors, the views and the sync engine's key provider.
  `Posture.derive`, `effectiveGate`'s decision half, the controller's projections and the doors' private checks all
  go.
- **The executor** is the only code that writes custody items, sync keys, the key file, the record, what this Mac
  remembers, plans, Apple keys and the vault. It runs repairs and plan steps. Every write is verified, and every delete
  comes after its replacement has verified — except a retirement, which deletes with no replacement by design.
- **Before unlock, nothing on the Mac decides anything.** The lobby offers the roads this device has for the
  library:
  - this scope's custody items, enumerated, whatever fingerprint they name;
  - the route finder's roads for the slot: the key file beside it, any key file the catalog knows (the newest backup
    pair's included), the history, the anchor (with the passphrase or the words), and Apple wraps whose key is
    readable;
  - the passphrase or words, with the vault road behind them.

  Every road verifies itself, because a key that doesn't open the file opens nothing. A key reached through the
  history or the anchor counts as a road, so a library left mid-re-key, or rolled back by Time Machine, still opens. A
  missing library is missing in both modes; a missing key file or memory item is never fatal while any of these roads
  remains.
- **Repairs move toward the record, with guards:**
  - A synced library writes nothing Apple-reachable without a fresh vault read for its account (decision 35, kept).
  - An unconfirmed or ambiguous mode runs no custody repair in either direction: the library keeps today's custody
    shape until the mode is confirmed (§3.13).
  - No repair ever makes a Touch ID item: one is made only at a press (§3.10).
  - Nothing acts on a momentary reading (§3.10).
  - Opening a copy **never lowers** the mode (§3.7).
  - No repair changes a key's kind: a key is born Castle or Standard and keeps that kind for life (§3.4).
  - In Standard, a login-password holder holds the library key and can rewrite the record (rule 3). So no repair
    deletes anything, or re-keys, on a Standard record's word alone; what a Standard record says is acted on only
    through the acts a person presses.
- **The repairs:**
  - **Castle:** no silent item for any key the library has had — **including the per-library-ID items the migration
    kept for downgrade safety**; no format-1 or format-2 key file beside the library once the history verifiably holds
    its key (a key the fold couldn't reach keeps its file: it's that copy's only road); no Apple wrap of the current
    key — a Castle key never has one, so finding one (a planted file) is a fault the repair answers with a re-key; no
    Apple key whose id this Mac's device section lists as retired (delete on sight, by id only — never by library ID,
    since another Mac's copy of the same library may be in Standard under a key of its own); and no 13p escrow item
    holding any of its keys, once the history holds that key.
  - **Standard:** the key file carries an Apple wrap of the current key under this Mac's own Apple key for the
    library (§3.5). If that key can't be read here — iCloud Keychain was reset, or the Mac moved to another Apple ID —
    no repair mints one: the assessment says the Apple road is lost and offers Re-link's library arm (§3.9). An
    account from before this change keeps its vault on the old shared key until it enters Castle or is re-linked —
    nothing moves a vault automatically. No Touch ID item for a Standard key.
  - **Always:** the record, what this Mac remembers and the key file agree. Sync keys match the record's account.

### 3.4 The key history and the Castle anchor (VX-263)

- **A fresh key whenever the library crosses a line** (her rulings, §1): entering Castle, leaving Castle, leaving an
  account in either mode, and a different library arriving on a Mac — plus Replace All Keys and the follow, as today.
  **A key is born Castle or Standard and keeps that kind for life**; the library's mode is its current key's kind.
- **What the new key's history takes:**
  - **Entering Castle — everything:** the old key, its history, and the anchor if there is one, opened with the
    secrets typed at the door (both) or at the follow (one). Old backups keep opening for you. An anchor those secrets
    can't open — they changed since the leave — is kept beside the history, unchanged, listed in Diagnostics, and never
    fails the entry; it keeps opening with the secrets of its day, and a later leave seals it inside the new anchor.
  - **Within a mode** (Replace All Keys, a follow that keeps the mode, leaving an account): the old key and its
    history, with the anchor carried over unchanged. Your copies keep opening through the new key; whoever lost access
    — an old master, the account you left — opens only what came before.
  - **Leaving Castle — nothing.** The new key starts with an empty history, and everything from before the leave goes
    into the Castle anchor (below).
  - **A different library landing — nothing.** The sent pair keeps its own locks (§3.7).
- **The Castle anchor.** At a leave, before anything else is written, the executor seals the outgoing Castle key with
  its whole history — and any earlier anchor kept beside it — into one bundle under a fresh anchor key. The anchor key
  is locked only with what opened that device's library on the day it left Castle, never with anything the Apple
  account or the login password reaches:
  - **on the device that presses Use Standard,** under the passphrase and the words typed there;
  - **on a device that follows out of Castle,** under the secret typed at its follow — it opened the vault, so it is
    current — and under the outgoing Castle key itself, with that key's own locks from the device's key file copied
    beside it: the passphrase or words that device held it under, and the Castle-era master with its words copy
    (§3.5a). Both are birth-time locks, made with what's in hand as the anchor is sealed: the secret just typed, and
    the open library's own key. If the vault's master is still the Castle-era one — an older build left without
    changing it, and put it under the old shared Apple key — the master's road is left out. So a follower's anchor
    opens with the secret typed at its follow and with whatever opened that device that day. Where none of those is
    the passphrase — a device that only ever had the words typed — its copies' *Opens with* line says the twelve
    words, not the passphrase.

  It lives in the key file, so it rides frozen into every later backup pair, and every later re-key carries it
  unchanged. There is one at a time.
- **It keeps the secrets of its day** (her ruling, §1). The anchor is locked once, when it's written — at the leave,
  or on a follower at its follow — and never re-locked: copies from before you left open with the passphrase or the
  words you had that day. Leaving never makes new words, so that day's paper keeps opening them. Locking a follower's
  anchor under the secret typed at its follow is part of writing it, not a later re-lock: no door ever re-locks an
  anchor after it's written. Every door that replaces a secret while an anchor exists says what still opens the
  copies from before the leave (§3.9's key doors).
- **How it's held:** the history wraps each key it takes directly under the current key. The executor unwraps the
  old history with the old key, which is in hand during any re-key, and re-wraps what the new key takes.
- **It runs backwards only.** A key opens older keys, never newer ones, so an old key opens nothing written after it.
- **A backup's locks never change.** Every backup's frozen key file carries the history and the anchor as of its day,
  and nothing ever writes to a pair again. A key changes only at an act a person takes.
- **The family tree** (§3.2) is the non-secret list of every key the library has had, kept in the record and mirrored
  in what this Mac remembers, the two unioned at open. "Is this copy ours?" reads the tree, never the history (§3.7),
  and the route finder's words read its dates.
- **Prepare-then-commit falls out of it** (VX-235's class). The new key file — the new key's wraps, the history it
  takes, and the anchor — and the new custody item are written **before** the library is re-encrypted, and leaving
  Castle writes the anchor first of all. Whatever state a crash leaves, a road opens the file: the old custody item,
  the anchor (with the secrets of the leave), the new key, or the new key through the history. The old custody item
  is deleted only after the swap commits; under Always ask there is none, and the anchor or the history is the road.

### 3.5 Apple keys (VX-301)

- **Named by their own id.** The vault records its key's id (`apple_key_id`), and so does a key file's Apple wrap.
- **One per library per Mac, one per account.** Each Mac mints and names its own Apple key for each library it holds
  a Standard key file for — the live library, and other libraries whose newest copy is in Standard — and locks that
  key file's current key under it. An account's Apple key locks only the account's master in the vault. The items are
  synchronizable, so a replacement Mac on the same Apple account recovers through them: "this Mac's own" means minted
  and named by it.
- **One minter.** Apple keys are minted only by a deliberate act or the migration, always under a fresh id:
  - for a library: creating it in Standard; leaving Castle, by the act or its follow; landing a different library in
    Standard; setting up sync or joining an account in Standard (this device's own key for its key file, if it has
    none); Re-link's library arm, for a Standard key file whose own Apple key can't be read here (§3.9); and the
    migration's keys of its own (below). Leaving an account in Standard mints nothing: the account's key never locks
    the library, so its new library key goes under this Mac's existing own key, as Replace All Keys' does;
  - for an account: sync setup in Standard; Use Standard on a synced library; Re-link; and Replace All Keys on an
    account still on the old shared key, which re-links first (§3.9, point 7 below). If two devices mint for one
    account, the vault's CAS keeps one, and the other device deletes the key it minted and drops its wrap.
  - Replace All Keys in Standard isn't a crossing: its new library key goes under this Mac's existing Apple key for the
    library, and nothing is minted for the library.
  - A device that can't read the key the vault names **waits for silent setup only**: its own key file never waits,
    since it's under its own key. Whether the key hasn't arrived, iCloud Keychain is off, or the device is on another
    Apple ID, the app can't tell, and the passphrase or the words always open the vault.
  - Two devices therefore never create the same item. This replaces the shared-name mint guards (F2/F3) and corner
    34's device-own key with one rule that can't race: every device already has its own. Its convergence pins live in
    phase 3.
- **Entering Castle retires every Apple key of this Mac's own for the library** — every id this Mac's device section
  lists as its own for the library and not yet retired, not only the one the live key file names. A Mac can hold
  more than one: Re-link's library arm mints a new one beside a key it couldn't read, and a replacement Mac adopts
  its predecessor's. After the switch commits each is deleted, with no sheet, and its id recorded as retired in this
  Mac's device section; a key this Mac can't reach is deleted on sight if it ever comes back. One it can never reach —
  left in an Apple account this Mac no longer uses — can't be deleted from here: copies locked under it are §3.1 rule
  2's last stated exception, and Use Castle's door names them. The account's key goes when the account itself enters
  Castle: its rotation rewrites the vault with no Apple copy, and once the rotation completes the acting device
  deletes the key and records it as retired. A device that follows records the account's key and its own as retired, and deletes its
  own. Deletes of synchronizable items reach every device, and app-made items have no recovery; a delete made while
  this Mac's iCloud Keychain is off reaches only this Mac until it's on again, when delete on sight finishes it (§8).
- **A replacement Mac takes over its predecessor's keys.** A new device identity on new hardware (§3.13) adopts, for
  each library it holds, the Apple key ids its live key file's wraps name as its own, every other id its predecessor's
  device section lists as its own (the predecessor is the identity named by the memory item it came with), and every
  id any device section of the record lists as retired, since a retired key is dead everywhere. So entering Castle
  there retires all of the predecessor's own keys too, and delete on sight keeps working.
- **Delete on sight, by recorded id.** In Castle, a key whose id this Mac's device section lists as retired is deleted
  again if it reappears — a key deleted while sync was off can come back when sync does. Nothing is ever deleted for
  belonging to "this library" by ID: another Mac's copy of the same library may be in Standard under a key of its own.
- **Leaving Castle mints fresh keys** — this Mac's own for the new library key and, synced, a fresh account key for
  the new master. The rotation's first vault write names that account key's id in the vault's existing
  `apple_key_id` field with no wrap beside it, so every device can read the rotation as a leave; the wrap itself
  joins the vault only in the write that completes the rotation (§3.9), so the vault never holds a Castle-era corpus
  key under anything Apple-reachable. Every other device types one secret at its follow (§3.9) and needs no Apple key
  to follow.
- **The old shared key — today's `<scope>-apple-key`.** There is one per Apple account and scope, shared by every
  library and account on it, on every device. Deleting it deletes it everywhere, with no recovery. So:
  1. **This build never writes under it.** It reads it only to move things off it, and the route finder counts it as
     a road while it exists.
  2. **Each device's migration gives everything it holds in Standard a key of its own — beside the old one, never
     instead of it** (§3.13), while the old key is still readable:
     - it folds every key reachable through the old key into the history of the library that key belongs to;
     - each *other* library this Mac holds copies of — an older library, or backups only — whose newest copy is in
       Standard gets this Mac's own key file for it, in `Backups/<library8>/<mac8>/` (in the container, and beside
       this Mac's copies of it in the far folder — never for copies the catalog can't attribute to this Mac), under
       an Apple key of its own, made once per library per Mac. A library whose newest copy is in Castle gets none: its
       pre-Castle copies are what retirement is for. (An older library of *this* library is a copy: its keys go into
       the live history.)
     - the live library — local or synced — gains this Mac's own Apple key. Its old-key wrap stays beside the new one
       until the old key is retired — keeping a wrap isn't writing under the key — and a re-key drops it;
     - an account from before this change keeps its vault on the old key until it enters Castle or is re-linked: the
       vault holds one Apple copy, and moving it to a key whose arrival in iCloud can't be confirmed (iCloud Keychain
       may be off, and macOS can't say — corner 46) could cost the account's other devices their silent setup;
     - it ends with **a fresh backup pair** of the live library, so the newest pair carries the history and every
       wrap.

     **The move only adds roads.** Until the old key is retired, everything opens exactly as before; after, each
     Standard thing has an Apple key of its own, which reaches other devices wherever iCloud Keychain carries it.
  3. **An older build keeps using the old key,** and its Re-link can land an account's vault copy under it. Nothing on
     this build moves a vault off it automatically.
  4. **Retiring it is a step of Use Castle** — **her ruling, 2026-10-13** (§1) — **and Use Castle either finishes or
     doesn't start:**
     - **The checks, at the door, before the sheet:** the moves of point 2 run again. Then the route finder looks, with
       the old key taken away, at every copy in the catalog — other libraries' and other Macs' in a shared backup
       folder included — and at every account vault this device can read. It lists:
       - what would stop opening;
       - every Standard library or copy here with no passphrase or twelve words: its only road off this Mac would be an
         Apple key this Mac can't confirm reached iCloud;
       - any key file another Mac wrote that holds one of this library's keys — a library sent there before this change
         (§3.1 rule 2's third exception).
     - **A vault that still names the old key stops Use Castle at its door** — one this device can read, or, while
       signed out, the account the record still names — other than the account this very act moves into Castle. It
       says so and names the way through: that account's own act — Castle, or Re-link on one of its devices.
     - **The sheet** lists those things concretely ("3 backups from Lillian's Air"; "2 older libraries with no
       passphrase"; "your account x@… can't be checked while you're signed out"), and says what the Mac can't see:
       *"Before you do, open the latest Variorum on every device signed into this Apple account, and give any library
       still in Standard there a passphrase or twelve words. A library in Standard keeps opening on its own device. But
       if that device is lost or reset, a library with neither opens elsewhere only through your Apple account — and
       only if iCloud Keychain carried its key, which Variorum can't check — or, if that device hadn't been updated,
       not at all."* It also says that another Variorum account still in Standard on this Apple account sets up new
       devices with its passphrase until it's re-linked.
     - **Use Castle** then retires the old key as its last step, after the library's own. There is no *keep it for
       now*: it would leave a library that says Castle with its older copies open through the Apple account — the
       halfway posture she ruled out. To deal with something the sheet lists first, cancel, deal with it, and come
       back. The vault check is read fresh again at that last step; in the rare case it now finds one (an older build's
       Re-link in between), the key stays, and the library lands with the door and §3.1's first exception showing.
     - **A library that was already in Castle before this change** gets one ask on each device, at a calm moment, and
       the same checks and sheet behind a door in Settings ▸ Protection, *Retire the old Apple key…*. The door and
       §3.1's first exception show on one condition: this device's section lists the old shared key among the keys
       that ever wrapped this library's keys, and not as retired. Pressing it retires the key, so both go for good, and
       a library entering Castle after this change never sees either unless the last-step race above happens.
  5. **Retiring** deletes the old-name item only when its id is the one this device's section lists, and records it
     as retired — on the retiring act's own device section only. A device that follows records the account's key and
     its own as retired, never the old shared key; delete on sight covers the old key only where it was retired. A new
     old-name item that an older build mints later has a new id. It holds nothing of a Castle library, and it is left
     alone.
  6. **Until it's retired,** on a library that was already in Castle, §3.1 rule 2's first exception shows wherever it
     applies.
  7. **An account still on the old shared key keeps working with nothing written under it:** enrolling a device reads
     the vault's Apple copy (a read, not a write); the device locks its own key file under its own key; and Replace All
     Keys on such an account re-links it first — a fresh account key, with Re-link's consent and caveat (§3.9) — so its
     new master goes under the account's own key, as decision 30 says.

### 3.5a The master's twelve-words copy in key files

A device that joined sync without typing a secret has, in its key file, only its library key under the master and
under its own Apple key. When the account enters Castle elsewhere, the master is replaced. If that device then loses its
Keychain before it follows (a reinstall, Migration Assistant) and its own Apple key never reached iCloud, nothing would
open its file. So:

- **Every key file that has a master wrap also carries that master wrapped under the twelve words,** copied from the
  vault's recovery wrap. That copy is non-secret: it is under the 128-bit words, so it adds no brute-force target.
  The passphrase-wrapped master is deliberately *not* copied.
- **It is refreshed from the vault while that master is current,** for example after the words are regenerated, and
  it is replaced only when the key file's master wrap is replaced (the follow).
- **So the words always open the file,** and a backup's frozen key file gains the same road. Opening goes from the
  words, to the master, to the library key. It is also a follower's words road into its Castle anchor (§3.4).
- No server change.
- **The residue** (§8): the copy is refreshed only while its master is current, so when the words change —
  regenerated alone, or together with the master at Use Castle or Replace All Keys — a silently-joined device that
  hasn't refreshed or followed keeps the master under the old words. If its Keychain is lost before then, the old
  words still open its file; without them, only the server brings its writing back, and its unsynced edits are lost.

### 3.6 Seals and freshness (VX-313)

- **The seal.** `HMAC-SHA256(key: HKDF-SHA256(ikm: L, salt: libraryID, info: "variorum.seal.v1:" + purpose), message:
  the sealed fields' canonical JSON)`, naming the sealing key's fingerprint.
- **What sealing can protect.** In Castle the library key is out of the login password's reach, so a seal stops what a
  login-password holder could otherwise plant, edit, replay or delete. In Standard that person holds the library key
  (rule 3) and could rewrite the record itself, so the claims below are Castle's, and in Standard no repair acts
  destructively on the record's word alone (§3.3).
- **A seal proves what a value says, not that it's current.** A genuine plan or memory value captured earlier and
  written back later would still verify. So nothing that decides lives where a replay of one item reaches it alone:
  - **This Mac's facts have two sealed homes**: its device section of the record, inside the encrypted library, and
    what this Mac remembers. Each carries a version that only grows. At open the newer wins, and the retired Apple key
    ids are the union of both. A library file replayed alone loses to the memory; a memory item replayed alone loses
    to the record. This is VX-313's ruling ("sealed") built stronger.
  - **A Mac finds its own section by its hardware.** The device section carries the device identity and its hardware
    marker. A Mac whose memory item is gone — deleted, or wiped with the keychain — adopts the section whose marker
    matches its hardware, so its settings and its retired ids stay its own; only new hardware starts a new identity
    (§3.5, §3.13). Deleting the memory item therefore changes nothing on its own.
  - **The family tree has two homes too:** the record and its sealed mirror in the memory, unioned at open, since a
    tree only grows. A rolled-back or replayed library file can't make this library's own copies look foreign.
  - **A copy carries only the library's own facts** — its mode, account and family tree. A device section counts only
    on its own Mac, and only when it's newer than that Mac's memory; a copy's act in flight is cleared whenever it's
    opened, so no copy carries a half-finished act to another Mac or back in time.
  - **Plans are sealed and named.** The device section carries the act in flight with its sequence number; a plan
    resumes only if its seal covers that number. A plan the section doesn't name is ignored and reported in
    Diagnostics and the log.
  - **A missing or unmatched plan never blocks** (VX-235's class). Before the commit point the act rolls back — the
    old custody item, the anchor or the history still open the library — and after it, the act's remaining steps,
    fixed for each act, finish from the record. A synced rotation resumes from the server's own rotation state.
  - **What this Mac remembers is sealed** (purpose `memory`), so an edit is caught; a replayed memory item loses to a
    newer record.
  - **No repair makes a Touch ID item** (§3.10).
- **Checking.** Seals are verified after unlock, with the named key, reached through the history when the plan's own
  act has since re-keyed. An Always-ask device verifies after the typed unlock, before any step runs.
- **The limit, stated** (§8): in Castle, someone who rolls back both homes at once — the library file and the memory
  item together, with the key file and the plan — returns this Mac's settings to that earlier state, and nothing local can
  tell it from the real one (a synced library's vault can). It never opens what was written before the rollback to
  them: a rollback brings back no key they can use, a Touch ID item made before their finger was enrolled stays
  closed to it, and a rolled-back choice of Touch ID with no item behind it records Always ask quietly — no question
  offers to make a new item (§3.10). What's written after it is protected as the restored state says.

### 3.7 Copies

- **One catalog** knows every place copies live:
  - the container's backups;
  - the far folder;
  - `Previous Libraries/`;
  - the lock-time copies;
  - the adoption safety copies (`Backups/safety-copies/variorum-adopt-safety-*`);
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
  - the live key file's anchor, with the passphrase or the words;
  - any key file the catalog knows that holds K, as its current key, in its history or in its anchor;
  - a custody item for K;
  - an Apple wrap whose key is readable;
  - the current master's wrap (synced).

  The route finder is the only source of any sentence about what opens a copy: one *Opens with* line per copy
  (§3.11). The scenario test checks that every road it names really opens the copy.
- **The open rule (VX-209):**
  - **Is it ours?** The family tree decides — its two homes unioned (§3.6), and seeded at the migration with every
    fingerprint the catalog's key files name for this library, reached or not (§3.13). A copy whose key is in the
    tree is this library's own line, whatever its kind; one whose key isn't is flagged in the restore list and the
    confirm as *"made on another Mac, or not by you"* — a planted pair, or a library sent back from another Mac.
  - **Any copy's act in flight is cleared when it's opened,** including lock-time copies, which are byte copies of
    the file: only the live record's own act ever resumes.
  - **A copy of a library this Mac remembers** (the one in the slot, or any it knows) **is re-encrypted under that
    library's current key, straight from the staged copy into place**, and takes the library's current facts — its
    mode, account and family tree from the record, and this Mac's facts from the newer home (§3.6), so a restored copy
    can't weaken delete on sight. A copy from this library's own line takes the current mode (rule 4): a Castle-era
    copy opened into a Standard library opens with the passphrase or the words through the anchor, and the confirm
    says its writing will then open through the Apple account. A copy whose rows belong to another account runs the
    Move road inside the open's plan. The current key comes from custody (Touch ID or silent) or a typed secret; it is
    never the copy's own key.
  - **A Castle copy not in the family tree, of a library this Mac remembers in Standard,** raises the library to
    Castle through Use Castle's own steps: the passphrase and words typed, a fresh key. Or you cancel.
  - **A different library** keeps its own mode and **lands under a fresh key with no history** — her ruling (§1).
    Its passphrase alone, or its words alone, unlock the pair; the landing then asks for the other one — typed, or
    made new (a new passphrase if it's forgotten, since the words proved access; new words if they're lost, since the
    passphrase did) — so both open it from the start. A Standard pair that opens through an Apple key this Mac can read
    lands with nothing typed, with this Mac's own Apple key, and the passphrase and words are offered as Standard offers
    them; if they're declined, the confirm says the landed library opens through this Mac and its Apple account
    only. The sent pair is never written and keeps its own locks; the library you had goes to your older libraries.
    No act of Variorum's ever leaves a key held by two Macs; a Mac cloned onto new hardware while the original stays
    in use is the one way two hold it (§8). **A synced pair** lands held, as today: a secret made new at its landing becomes
    the account's at Resume Sync, through the account's own forgot road with the secret just typed, and the landing
    says so. **Decision 33's asymmetry, stated:** a landing accepts one secret, because her
    guarantee is that either one lands it; raising your own library to Castle keeps both typed.
  - **A copy with no record** — any copy made before this change — has its mode worked out once with today's rules,
    as the migration does (§3.13), through the read-only legacy mode reader that outlives the switch (§3.15). An
    exposed-era Standard copy with no passphrase or words is never defaulted to Castle.
  - **Send Library** writes the pair and says nothing about sharing: nothing is shared, since the other Mac lands it
    under a key of its own. Like any backup, the pair opens with its own locks.
  - **A plaintext export** carries its library ID. If it's the same library, it is encrypted under the current key
    and mode; otherwise it becomes a new library in Standard, and the confirm says so. Any landing without sync
    bookkeeping gets a fresh sync identity.
  - **The confirm** states the outcome concretely from the open's plan — no "check" (her #216 ruling).
- **Copies pause while an act is between its prepare and its swap.** The record is written into the staged file before
  the swap, so every backup, lock-time copy and Send Library carries a key and a record that match, named from the
  file's own key; and a copy's act in flight is cleared whenever it's opened (§3.6).
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

- **The account changes only through acts:** set up sync, enroll or join, This Mac Only, Stop syncing here, deleting
  the account from this Mac, and Move. Signing back in to an account the library left is an ordinary turn-on-sync,
  with its consent.
- **Leaving an account** (This Mac Only, Stop syncing here, deleting the account from this Mac, Move) **re-keys the
  library, in either mode** — her rulings (§1). The new key's history takes the old one, so your copies keep opening
  for you, and the anchor rides along unchanged. The account you left opens only the copies from while it synced in
  Standard — until it replaces its keys or enters Castle — and never what you write after (§3.1 rule 2's second
  exception).
  - **In Castle:** both secrets, as decision 33's doors take them — the passphrase typed, the words typed or made new.
  - **In Standard:** this Mac holds the key, so the new key's silent item and this Mac's own Apple key carry it with
    nothing remembered; the passphrase is typed or set new (Standard's forgot road), and the words typed or made new.
  - The account's Apple key is left alone: the account's other devices still use it.
- **Joining or moving into an account** in Castle is entering Castle for this library: the re-key, this Mac's own Apple
  key retired, and the old shared key's checks (§3.5). Joining or moving into an account in Standard from Castle is
  leaving Castle for it: its key change and anchor (§3.4), with rule 5's sentence at the consent. Joining an account
  in the library's own mode — Standard from Standard, or Castle from Castle — adds the master's wrap and takes nothing
  away, so the key stays. When the library's passphrase differs from the account's, enrolling re-wraps the library
  key under the account's (corner 27, kept); the anchor, if any, is untouched and keeps the secrets of its day.
- **Signed out, Use Castle and Use Standard each offer one plain road:** the mode applies to this Mac only, and this
  Mac stops using the old account. This is her #216 screen for Castle, mirrored for Standard. *Stop syncing this
  library on this Mac* sits beside them.

### 3.9 The acts (each one a sealed plan; resume from the first unfinished step; prepare-then-commit)

- **Use Castle.**
  - The door: the passphrase and the words typed (decision 33, kept); the floor warning; *Export a plain copy first*
    offered; any copies here locked under an Apple key this Mac can't delete — one left in an Apple account it no
    longer uses — named, with what that means (§3.5); and, while the store still has the old shared key, its checks —
    a vault that names it stops the act here — and its sheet (§3.5 point 4).
  - Synced: the rotation, exactly today's protocol, with VX-109's fix — `begin` takes the door's vault revision.
  - The new key: its custody item (a Touch ID item, made at this press, or none under Always ask), then the new key
    file (P, W, plus M when synced; the history taking every older key, the anchor folded in; no Apple wrap), then the
    record written into the staged file, then the swap. Copies pause from the prepare to the swap.
  - Then what this Mac remembers. The old custody item, every silent item, the per-library-ID items the migration
    kept, the 13p escrow items, and the format-1/2 key files beside the library all go — each only once the history
    verifiably holds its key. **This device's scheduled Markdown export turns off, with one notice** (today's step,
    kept). A fresh backup is made, and every Apple key of this Mac's own for the library is deleted and recorded as
    retired; synced, the account's was deleted and recorded as retired when the rotation completed (§3.5).
  - Last, the old shared key is retired (§3.5).
- **Use Standard** — a key change, like Use Castle's (her rulings, §1).
  - The door: your passphrase and your twelve words, typed — the words are never made new here, so the paper you have
    keeps opening what stays behind — plus rule 5's sentence, saying plainly that the library itself, with everything
    written in Castle, opens through the Apple account from now on.
  - **The anchor first:** the outgoing Castle key and its whole history, sealed under the typed passphrase and words
    (§3.4), written into the current key file before any other step, and carried into the new one.
  - Synced: the rotation, as Use Castle's — a new master and sync key, your writing on the server re-encrypted, and the
    vault rewritten with the new master under your passphrase and your words. **The rotation's first write also names
    the account's fresh Apple key** — minted at this press, in iCloud Keychain before the write — in the vault's
    `apple_key_id`, with no wrap: the mark that this rotation is a leave. That write is the account's commit point, as
    Use Castle's always was: past it a crash resumes, never rolls back.
  - **How every device reads the vault's mode:** a wrap present — Standard; an id with no wrap — leaving Castle, in
    progress; neither — Castle. Today's builds read only the wrap, so they see Castle until the wrap lands.
  - **Sync keys are held by what they can reach** (§3.2). Until the previous corpus key leaves the vault, the new
    master reaches a Castle-era key through it, so the new sync keys and the previous corpus key stay in Castle-kind
    custody — the account's Touch ID sync item, made at this press and holding all three, or session memory under
    Always ask — and no Castle-era key is ever within the login password's reach.
  - **One write completes the leave:** it adds the account's Apple wrap of the new master under the key the vault
    names, with the previous-corpus-key window closed — so no Castle-era corpus key ever sits under anything
    Apple-reachable. Only a device that can read that named key makes it: this one, or another device of the account
    once iCloud Keychain carries the key there. Other devices walk and re-encrypt, but never clear the previous key
    while an id stands with no wrap. If an older build clears it first (it can: any enrolled device completes a
    rotation today, and its write carries the id through untouched), the leave still reads as in progress, and the
    completing write is then just the wrap. Once the window is closed, the new sync keys reach nothing Castle-era, so
    they move to a silent item and the Touch ID item goes.
  - **If this device never finishes,** another device of the account finishes it at a press that reads the vault's
    id — *"Finish leaving Castle, started on [device] on [day]"*. It waits for the named key, and mints a fresh
    account key only if that one never arrives (the vault's CAS keeps one). A key the lost device minted that never
    landed wraps nothing; if it ever surfaces in iCloud, it is left alone, as an older build's re-minted old key is
    (§3.5 point 5). A rotation with no id is Use Castle's or a Castle Replace All Keys: any device completes it, and no
    finisher ever adds an Apple copy to it. These are `Sync/` lines: Fable's, phase 3.
  - The new library key: its silent item, then the new key file (this Mac's fresh Apple key, P, W, plus the new master
    when synced; an empty history; the anchor), then the record written into the staged file, then the swap. Copies
    pause from the prepare to the swap.
  - Then what this Mac remembers; the Castle key's Touch ID item goes with its key; a fresh backup.
- **Replace All Keys.** As today (decision 30 included), on a plan, with the history. On an account still on the old
  shared key, it re-links the account first (§3.5 point 7).
- **The follow** (into Castle, into Standard, keys replaced).
  - As today, on a plan that carries every fact a resume needs: "another device switched", the words rule (VX-107).
  - **Every follow into or out of Castle types one secret, once** — the passphrase or the words, through the vault.
    Until then the library opens on its current key and you can write; sync waits, with the banner. No such follow
    waits on an Apple key. A device that sees the master replaced while the vault reads a rotation in progress — a
    previous corpus key standing, or an id with no wrap (a leave not yet complete) — follows the keys but holds its own
    library's re-key until the vault reads Standard or Castle. While it holds, the keys it takes are held by what they
    reach, as the acting device's are: in its Castle-kind custody while the previous corpus key stands. A
    keys-replaced follow in Castle types one secret too, since the new master is under only the passphrase and the
    words. A keys-replaced follow in Standard reads the new master through the account's Apple
    key, as today, or takes the passphrase or the words when that key can't be read here.
  - **A follower's new key file** is locked under the secret it typed and under the new master, with that master's
    words copy beside it (§3.5a) — so the words open it either way, and the passphrase directly when it was the one
    typed — plus, in Standard, this Mac's own fresh Apple key.
  - Into Castle: the new master from the vault; a new library key of Castle's kind (a Touch ID item made at this
    press where this device's gate style says so, or none), its history taking every older key; every Apple key of
    this Mac's own for the library deleted and recorded as retired, with the account's; the scheduled Markdown export
    off, with one notice.
  - Into Standard: the anchor first (§3.4 — under the secret just typed, and under the outgoing Castle key with that
    key's own locks from this device's key file copied beside it); then a new library key of Standard's kind (its
    silent item, this Mac's own fresh Apple key) with an empty history; the Castle key's Touch ID item goes with its
    key; rule 5's sentence at the typed step.
  - Keys replaced, same mode: the history grows.
  - Typing the old passphrase after it was changed elsewhere is refused with the change named (VX-113, her #205
    ruling): *"Your passphrase was changed on [device] on [day] — enter the new one."*
- **The account acts:** set up sync, enroll/join, connect/Move, This Mac Only, Stop syncing here, deleting the
  account from this Mac. As the proposal describes, each on a plan, the Move road re-stamping and resyncing, with
  §3.8's rules: every leave re-keys.
- **The key doors:** change passphrase (verifying the current one) and new words (asking the passphrase). They re-wrap
  the current key and re-lock nothing else: the history needs no secret, and the anchor keeps the secrets of its day
  (§3.4).
- **Every door that replaces a secret while an anchor exists says what still opens the copies from before the
  leave** — one sentence, from the route finder, for this device's anchor and its day:
  - every door that replaces the words — new words, Replace All Keys, a leave from an account, sync setup's choice to
    make new words — *"Copies from before 12 October still open with the words you're replacing — keep that paper."*;
  - change passphrase: *"Copies from before 12 October still open with the passphrase you're replacing, or that day's
    words."*;
  - Standard's reset road for a forgotten passphrase: *"Copies from before 12 October now open with that day's twelve
    words — keep that paper."* It never points you at a passphrase you've told it you forgot;
  - Use Castle that can't fold an anchor in, because the secrets typed at its door changed since that leave: the
    anchor stays beside the history, unchanged, and the door says which secrets, of which day, still open the copies
    it holds.

  Where this device's anchor doesn't open with what the sentence names (§3.4's words-only devices), the route finder
  says what does instead.
- **Re-link your Apple account** (17m's door, for a Standard account whose Apple key no device can read — after an
  iCloud Keychain reset or a change of Apple ID): Use Standard's key step on an account that's already Standard — a
  fresh account key, minted at the press, landed under the vault's CAS. It never re-lands under the old shared key,
  and it re-keys nothing. Its consent says the new key reaches other devices only through iCloud Keychain, which
  Variorum can't see.
  - **Its library arm** — for a Standard library whose own Apple key this Mac can't read (an iCloud Keychain reset, a
    change of Apple ID), local-only libraries included: it mints a fresh own key for this Mac and re-locks the key file
    under it, for every Standard key file this Mac holds that needs one, other libraries' included. The assessment
    offers it wherever a Standard library's Apple road is lost (§3.3). It re-keys nothing.
- **Opening a copy, and landing a library** (§3.7).
- **The migration** (§3.13).
- **Retiring the old shared key** (§3.5): Use Castle's last step, or its own door on a library already in Castle
  before this change.
- **Gate-style changes and the Touch ID re-arm** (§3.10).

### 3.10 Touch ID

- **The choice is stored per device, in this Mac's facts** (§3.6): Touch ID or Always ask. Nothing acts on a momentary
  reading: a closed lid (`builtInSensorInaccessible`), a disconnected or unpaired keyboard, or a lockout takes the
  passphrase road for that one open and changes nothing.
- **A device with no choice yet** — a landed library, a first follow into Castle — starts on Touch ID where this Mac
  has an enrolled finger, the item made at that act's own press, and on Always ask otherwise; its idle lock at the
  default, and its scheduled export off. **A new device identity** (a replacement Mac, §3.13) has no act and so no
  press: it starts on Always ask, and Touch ID comes on only when you turn it on in Settings, with the passphrase.
- **The stored biometry state hash is a hint, never a verdict:** a macOS update can move it with no enrollment change.
  It's kept in what this Mac remembers when the item is made, and it only chooses which line to show after a press
  fails.
- **When a press fails against an item that exists** — a biometry change invalidated it — Variorum asks, after the
  passphrase opens the library: *"Touch ID can't open Variorum on this Mac any more. Set it up again? Every finger
  enrolled on this Mac will open it."* It makes a new item only on yes; a no records Always ask, at that press. No
  repair ever makes one.
- **When this device's choice is Touch ID but no item exists** — it was deleted, the keychain was wiped, or both of
  this Mac's homes were rolled back past a switch to Always ask — nothing is asked. Always ask is recorded quietly,
  the lobby's quiet line says Touch ID isn't set up for this library, and Touch ID comes back only from Settings, with
  the passphrase. A question that appears by itself after an item vanished could be answered yes to a choice you had
  undone, with someone else's finger enrolled (the rollback in §3.6); a press in Settings can't be steered that way.
- **A Mac without Touch ID hardware:** the Castle switch says so, and Always ask is recorded only at your press.
- **The lobby's Touch ID line and button follow the real road** (VX-310):
  - Whenever this scope has a Touch ID item for the library's current key, the **Unlock with Touch ID button is
    there**, however many times the prompt was dismissed. The automatic ask happens once, at open.
  - If Touch ID is only temporarily unusable (lid closed, keyboard disconnected or unpaired, a lockout), the button
    stays. Pressing it says why ("Open the lid…") and nothing changes.
  - With no item, or no finger enrolled on this Mac, there is no button, and one quiet line says why: Touch ID isn't
    set up here, or isn't set up for this library.
  - A press that fails because the item no longer opens shows *Touch ID changed since you set it up — unlock with the
    passphrase*, and the re-arm question follows the unlock. With no item there's no press, so no question.
  - Before unlock, the lobby reads what this Mac remembers as a display hint only; it decides nothing.
  - This is her pick read to its words — *the button whenever a Touch ID item exists* (§1); the "changed" line waits
    for a press because the stored hash can't tell a changed finger from a macOS update.

### 3.11 Words (copy)

- **Every sentence about what opens a copy comes from the route finder,** as one line per copy — *Opens with: Touch
  ID · your passphrase · your words*, or *the passphrase or words you had on 12 October* — used everywhere: the
  restore list, the offer, the confirm, Data Safety and the field guide. A copy whose line a person wouldn't
  understand is a design bug, not a wording problem. Every confirm and Done comes from the act's plan.
- **The two-register rule holds.** Everyday surfaces name no key; the field guide's encryption chapter names every
  key. "Box" appears in no user text.
- **VX-211:** a passphrase strength check with no new dependency. Any passphrase Variorum suggests is shaped visibly
  unlike the twelve words.
- **The field guide's Standard lesson shows the login-password truth** with a *try it yourself* line (Keychain Access,
  the login password, the silent item), so "anyone who can sign in to this Mac" lands.
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
  at a time — a leave's id with no wrap (§3.9) is this build's reading of an existing field, with no server change;
- decision 30 (a Standard Replace All Keys stays under the account's Apple key — re-linked first for an account still
  on the old shared key, §3.5);
- decision 33 (both secrets typed for the rotation doors), with two stated narrowings: a landing accepts one secret
  (§3.7), and Use Standard types the words, never makes new ones (§3.9);
- entering Castle turns this device's scheduled Markdown export off, with one notice (pre-13x decision 6;
  `PostureSwitch.swift`'s `entersCastle` step), on Use Castle and on every follow into Castle;
- the follow's substance;
- the lobby's three roads and the vault road;
- backups as pairs, never rewritten (decision 11);
- the restore hold and Resume Sync;
- `Previous Libraries/`;
- the plaintext export's exclusions;
- the two-register rule;
- the phone sharing the same brains.

### 3.13 The migration (existing stores: her Pro, Air and phone, the dev stores, the beta testers)

It runs once, at first unlock on the new build, **as a plan** — and on a Release build only once she has turned the
new system on at release (§5):

1. **Finish anything in flight with today's runner** — its finish path, kept read-and-finish-only for one release
   after the switch (§3.15). VX-235's stuck marker is cleared on proof that the switch never happened: the library
   still opens under its old key, and the new key file never landed.
2. **Work out the mode once with today's rules** — the legacy mode reader (§3.15), a pure function of today's
   inputs.
   - A synced library with the vault in reach takes the vault's word; without it, the mode is recorded as *not yet
     confirmed*.
   - Corner 45's ambiguous case records Castle, not yet confirmed, with a one-time notice — carrying the floor sentence
     and *Export a plain copy first* — and Use Standard offered as the key change it now is.
   - Until the mode is confirmed (the vault read, or the notice answered), no custody repair runs in either direction:
     the library keeps today's custody shape, and nothing Apple-reachable is written. Confirming a mode the current key
     wasn't born in is a key change, never a move.
3. **Write the record, what this Mac remembers (sealed, with this Mac's device section in both homes), and the device
   identity** carried over from the sync-keys item, with its hardware marker, so no new device cursor is created. The
   family tree's first entries: the current key takes the mode step 2 records; every older key the fold reaches is
   attributed by its key file — an Apple wrap marks a Standard key, none marks a Castle key, and an unknown one counts
   as Castle's, the safe side, which strands nothing since all of them stay openable through the history; and every
   fingerprint the catalog's key files name for this library is listed, reached or not, so its own copies read as
   its own.
4. **Add the per-key custody items,** each of its key's kind, verified. The old per-ID items stay in place, unread, for
   one release — and entering Castle removes them once the history holds their key (§3.9).
5. **One pass of the catalog:** attribute existing copies to their library and Mac; new backups go to the
   per-library, per-Mac subfolders. The fold below reads the key files the catalog finds.
6. **Write the format-3 key file** and fold every reachable older key into the history:
   - keys from the old key files, through the old shared Apple key when it is readable;
   - keys reachable through the passphrase, **typed once if needed**;
   - custody — today's items named by library ID, read by the legacy readers (§3.15);
   - the 13p escrow items (a raw key in iCloud Keychain, named by store id), read the same way.

   Old key files stay — for one release, and in any case until the history verifiably holds their key. A key the fold
   couldn't reach (say, one under a passphrase from long ago) keeps its file: it's that copy's only road. The 13p
   escrow items for keys now in the history are removed.
7. **Give everything this Mac holds in Standard a key of its own, beside the old one** (§3.5 point 2): other
   libraries' copies attributed to this Mac first, then the live library — local or synced, once its mode is
   confirmed Standard (decision 35) — then **a fresh backup pair** of the live library. Nothing is removed.
8. **A library already in Castle** gets one ask on each device, at a calm moment: copies from before Castle still open
   through the Apple account until the old key is retired — with the checks, the sheet and the door to retire it
   (§3.5 point 4).
9. **The road back.** Until the first re-key under the new build, an older build still opens the library, because its
   items and files are untouched. After that, the road back is the A1 safety copy with the passphrase or words.

**The device identity's hardware marker:** if what this Mac remembers turns up on different hardware — Quick Start,
Migration Assistant, a restored backup — a new identity is minted there, so two Macs never share a device cursor or a
`<mac8>` folder (pinned; whether macOS ever carries the item is unproven either way). The new identity takes over its
predecessor's Apple keys for each library it holds (§3.5). A Mac on the same hardware whose memory item is gone keeps
its identity, found by its marker in the device section (§3.6).

### 3.14 VX-212 (its own phase, after the main rebuild works, designed with her first)

This is a starting shape, not a ruling:

- An undecryptable row below the rotation seq is **quarantined**: kept sealed, listed in Diagnostics, never deleted.
- The pull skips quarantined rows by their recorded seq, so one bad row no longer refuses the whole round.
- The rotation completes over the quarantine.
- Quarantined rows are retried whenever this device's keys change.

It is `Sync/` work: Fable writes it, under a convergence pin, with its own SyncSpec line.

### 3.15 What gets deleted (her ruling: *"I'm fine getting rid of each of those already built things"*)

**When:** today's code stays alive on main until her release switch, because Release builds keep running it until then
(§5). So nothing below is deleted phase by phase: it goes at that switch, in the same change that turns the new system
on (VX-329). Each phase's plan says which of today's writers its new code replaces, so the switch's change can list
them all.

**What dies at the switch — every deciding and writing role of today's code:**

- corner 45 and `RawKeyCustody` as deciders;
- `Posture.derive` as the app's decision, and the 13p legacy read-through as a road the app opens through;
- every reading that writes: `effectiveGate`'s Apple landing, `landCustody`'s Keychain writes and
  `CustodyCollisionRule`, `ensuredEnvelope`'s set-aside and new ID, and the item read that writes key files;
- custody named by library ID, as a place anything is written or decided;
- several key files per folder and the newest-modified rule;
- the in-file `RotationMarker` (`sync_state.rekey_in_progress`) as a live marker, and the `switchPending` /
  `thisDeviceOnly` defaults;
- the five definitions of "enrolled";
- the session-stamped owner;
- Castle settings in UserDefaults;
- the shared never-deleted Apple key as a live road, and 17m's Re-link re-landing under it;
- a synced library's key file locked under its account's Apple key, and corner 34's device-own key for accounts on
  the old shared key (every device has its own key per library);
- a landed library keeping the key it came with, the record's hand-off notes, and Send Library's sharing sentence;
- the silent follow into Standard, and leaving Castle without a key change;
- VX-202's belts;
- the duplicate safety copy;
- the confirm's "leaving Castle" line and the guide's older-copy warning;
- the Finder-revealing "Restore from a Backup";
- the identity-only silent sync item.

**What stays, as read-only legacy readers in the core** — because the migration runs after the switch ships, at each
store's next unlock, and copies made before this change exist forever:

- **today's mode rule**, as one pure function of today's inputs (`Posture.derive`'s inputs and corner 45's test): the
  migration's step 2 calls it once per store, and opening a copy with no record calls it for as long as such copies
  exist (§3.7). It decides nothing else and writes nothing;
- **the fold's reads** of today's per-library-ID custody items and the 13p escrow items (§3.13 step 6), reading only;
- **the `RotationMarker` read and today's runner's finish path**, so the migration's step 1 can finish an act a
  crash left in flight on the last old build — kept for one release after the switch, then deleted.

The phase-1 plan's legacy readers (formats 1 and 2, and a copy with no record worked out by today's rules) are these.

---

## 4. The proof

### 4.1 The scenario test (phase 1 builds it; every later phase extends it)

A headless world, run under `swift test`. It contains:

- two Macs and a phone, two Apple accounts and two Variorum accounts;
- a fake server with CAS and rotation;
- fake device keychains with Touch ID semantics — invalidated on an enrollment change, transient when the lid is
  closed, and a stored state hash that a macOS update can move with nothing changed;
- a fake iCloud Keychain with propagation delay, delete propagation and no recovery; a per-device off switch the app
  can't see — what a device makes while it's off stays on that device and syncs once it's turned on (facts §6(a));
  and the same-name rule — two devices writing one name leave one survivor;
- fake file systems that support copies, Time Machine rollback and container deletion;
- real key files and real key wraps, with test-speed passphrase stretching.

**Every user act** is in its action alphabet:

- create a library; set or change the passphrase; reset a forgotten passphrase (Standard); regenerate the words;
- Use Castle; Use Standard; Replace All Keys; Re-link the Apple account; retire the old shared key (its door);
- turn on sync; join or move into an account in Castle or in Standard; sign in as X or Y; sign out; This Mac Only;
  Stop syncing here; delete the account from this Mac; Move;
- follow on another device, typing the passphrase or the words;
- back up; restore backup *n*; open older library *n*; make and open a plaintext export; send a library to the other
  Mac and land it there (one secret typed, the other typed or made new; a Standard pair with none);
- delete another library's copies in the offer;
- lock and unlock;
- change the gate style; answer the Touch ID re-arm question yes or no; set the idle lock; turn the scheduled
  Markdown export on or off; answer corner 45's notice;
- add or remove a fingerprint; close the lid; unplug the keyboard; trigger a lockout; update macOS;
- turn iCloud Keychain off and on; switch Apple ID; wipe a keychain; replace a Mac;
- crash at any step of any act;
- **run an older build on a device:** it reads and mints only the old shared key, writes its wraps under it, and its
  Re-link re-lands the account's vault copy under it; it reads the vault's mode from the Apple wrap alone, and
  completes any rotation it finds, carrying the vault's other fields through.

**The adversary's actions** are in it too, all with the login password:

- edit a key file;
- plant a plan;
- edit a sealed setting;
- replay an earlier plan, memory item, key file or library file — one at a time, or both homes of this Mac's facts
  together (the stated limit, §3.6);
- read any keychain item's secret except a Touch ID item's; list, edit the attributes of and delete every item, Touch
  ID items and the memory item included (whether Keychain Access can list and delete a Touch ID item is checked on a
  throwaway scope in phase 3's drill; the world assumes it can);
- swap the library file at its place;
- delete the container and open an old copy;
- plant a crafted pair in the iCloud Drive folder;
- share one backup folder between two Macs.

**Starting states:** every shape today's builds leave (§3.13), including older libraries of other libraries, copies
whose only road is the old shared key, Standard libraries with no passphrase and no words, 13p escrow items, and one
library on two Macs from a hand-off made before this change. **The promises, checked after every action — 2's
retired-key clause, 3 and 7 once the world settles (propagation done, followers followed):**

1. **Known:** one record per live library, and what this Mac remembers agrees with it.
2. **Castle means Castle:** no silent item holds any of the library's keys; no Apple key this Mac's device section
   lists as retired exists; no Apple key wraps the current key; the vault has no Apple copy; and nothing a
   login-password holder can read opens the library or any copy made on this Mac or on a device of its account that
   has followed — except the stated exceptions (§3.1 rule 2), and a library recorded Castle but not yet confirmed,
   which keeps today's custody until it is (§3.13).
3. **Standard means Standard** (once the world settles): each device's key file carries an Apple wrap of its current
   key under that device's own Apple key for the library.
4. **No silent change:** the mode and account change only at a deliberate act or its follow. A copy never lowers the
   mode or brings its own key. (The migration's recording of corner 45's ambiguous case isn't a change: it records
   what today's rules say, and runs no custody repair until it's confirmed.)
5. **Nothing stranded:** with the secrets of each copy's day — the passphrase and words current when that copy, or
   the anchor holding its key, was written — every copy Variorum wrote opens. The exceptions are exactly the stated
   ones: the floor; what a retirement sheet listed before you confirmed it; what was on a device still on an older build
   when the old key was retired (the sheet's sentence); a Standard copy made with no passphrase or words once its own
   Apple key and this Mac's are both gone; and §3.5a's residue.
6. **Crash-safe:** after a crash at any step and a relaunch, the act finishes or rolls back, the library opens, and
   no copy carries a half-finished act.
7. **Converges** (once the world settles): every device of an account ends in the account's mode and keys.
8. **The posture law** (decision 28): after entering Castle, nothing that only the old posture could reach — the Apple
   account, this Mac's login password, a silent item — opens anything written after, on any device that has followed.
9. **Honest words:** every road an *Opens with* line names opens the copy, and every confirm and Done matches what
   the act did.
10. **Sealed** (in Castle, §3.6): no planted, edited, replayed or deleted file or keychain item, alone, changes the
    mode, the account, the custody or the gate style. Rolling back both homes of this Mac's facts at once is the stated
    limit, and it never opens what was written before it to the one who did it.
11. **Own copies only:** retention never touches another library's or another Mac's copies; the offer touches another
    library's only at your press, and another Mac's never.
12. **Moving adds:** the migration's move off the old shared key removes no road; only its retirement does.
13. **What Castle wrote stays Castle's, in its copies:** after leaving Castle, nothing the Apple account or a
    login-password holder can reach opens any copy made before the leave, or any key made in Castle. (The library
    itself opens to them from the leave on — that's rule 5 — and a Castle-era copy you open into it is your act, said
    at its confirm.) The one exception: a leave or follow made by an older build, which puts the Castle-era master
    under the old shared Apple key with no change of keys — stated in §8; this build never adds to it.

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
- **an older build's Re-link** lands an account's vault on the old key: nothing moves it automatically, and Use Castle
  stops at its door while a vault it can read, or (signed out) the account the record names, names it; and the
  last-step race, which lands with the door and the first exception showing;
- **iCloud Keychain off** on the Mac whose library moves: the move removes no road, and the retirement lists the
  library if it has no passphrase or words;
- **one local-only library on two Macs, sent before this change,** one entering Castle: the other's own key is never
  deleted; **and sent after this change:** it lands under a fresh key, and either Mac entering or leaving Castle changes
  nothing on the other;
- **a silently-joined device** loses its Keychain after the account entered Castle elsewhere: the words open its file
  (§3.5a);
- **replays:** a replayed plan, a replayed memory item, and a library file replayed alone (the gate style, the
  scheduled export, the retired ids): none changes anything; a rollback across a retirement: delete on sight still
  fires (the union); and both homes rolled back together, which returns this Mac's settings and opens nothing written
  before it;
- **an act in flight when a backup is taken:** the copy carries no act, and opening it elsewhere runs nothing of it;
- **Send Library after this change:** a Castle pair lands with its passphrase alone (the words typed, and made new),
  and with its words alone (the passphrase typed, and made new); a Standard pair through a readable Apple key with
  nothing typed; the landed key is new and its history empty; the receiving Mac leaving Castle later exposes nothing of
  the sender's;
- **leaving Castle:** the anchor is written first; every copy from before the leave opens with the passphrase or the
  words of the leave day and through nothing Apple-reachable; the Apple account opens the library and the copies made
  after; synced and local, with followers typing the passphrase, and the words — an Always-ask follower relocked
  after the rotation among them — each follower's anchor opening with the secret typed at its follow and with what
  opened that device that day; a crash at every step, on Touch ID and on Always ask; a follower that sees the rotation
  still in progress holds its re-key, its rotation-window keys in Castle-kind custody, until the one completing write;
  **a follower reaching the head first**, which walks and re-encrypts but never clears the previous key while the
  vault's id stands with no wrap, so the account never reads Castle in between; **an older build completing the
  leave's rotation**: the vault still reads a leave in progress, followers keep holding, and a device that reads the
  named key adds the wrap; an acting device lost mid-rotation, finished by another device at a press that names the
  leave, waiting for the named key and minting only if it never arrives; **an acting device lost mid-way through a
  Castle Replace All Keys**: finished with no Apple copy, the account never lowered;
- **a follow after an older build's leave** (no change of keys, the master under the old shared key): the follower's
  anchor leaves the master's road out, and nothing this build writes is Apple-reachable;
- **a follow into Standard with that device's iCloud Keychain off:** it follows on the typed secret, and promises 2, 7
  and 13 hold;
- **Castle → Standard → Castle:** the second Use Castle folds the anchor back in, and every copy from both Castle
  stretches and before opens with nothing more typed;
- **after a leave, change the passphrase and make new words — on this device, and on another device of the account —
  and reset a forgotten passphrase:** copies from before the leave still open with the leave day's passphrase or words
  on every device; the route finder names the day, and each door said its sentence (§3.9) — the reset road naming the
  words, never the forgotten passphrase;
- **the passphrase changed during Castle on another device, which then left Castle:** a follower that never had the
  new passphrase typed follows out typing it, and its anchor opens with it; **a follower that typed the words:** its
  copies' *Opens with* line says the twelve words;
- **a Standard library leaves its account, is backed up, then enters Castle:** no copy from before the leave opens
  through anything Apple-reachable — every Apple key of this Mac's own for the library retired, the one minted before
  the leave included; and **Re-link's library arm, then Use Castle:** both own keys retired;
- **a Mac that switched Apple ID** with Standard copies under its former Apple ID's key, then enters Castle: the door
  names those copies, and their *Opens with* line says the former account still opens them;
- **this library's own Castle-era copy, restored after a leave:** the family tree knows it; it opens with the
  passphrase or words, takes the Standard mode, and the confirm says so — no raise, no "made on another Mac";
- **one library on two Macs from before this change:** the stated exception holds, and the retirement sheet names the
  other Mac's key file when it can see it;
- **a library leaves its account** (each of the four acts), in Castle and in Standard (a forgotten passphrase set new):
  it re-keys, carrying any anchor; nothing written after opens through the account; its copies from its synced
  Standard days do, until the account replaces its keys or enters Castle. Then another device turns Castle off for the
  account: the library's current key stays out of the account's reach;
- **a Castle library joins a Standard account whose passphrase differs:** it leaves Castle with its anchor, the
  library key is re-wrapped under the account's passphrase, and the anchor keeps the secrets of its day;
- **This-Mac-Only Castle from an account in Standard:** the account's key is untouched, and its other devices keep
  their Apple road;
- **Replace All Keys on an account still on the old shared key** (re-linked first), **its follow**, and **a new device
  joining** such an account (its key file under its own key);
- **corner 45's ambiguous case:** no custody repair until the notice is answered, and confirming Standard is a key
  change;
- **a 13p escrow item:** folded, then removed in Castle;
- **the key file and the memory item both deleted** (a local-only Castle library): the lobby still opens it, through
  the enumerated custody items or the newest pair's key file;
- **entering Castle with the scheduled Markdown export on:** it turns off on this device and on every device that
  follows, with one notice;
- **the stored Touch ID hash moves with nothing changed** (a macOS update): the button stays, a press opens, and
  nothing is asked;
- **a copy made before this change, of another library,** Standard with no passphrase: it lands in Standard, never
  Castle;
- **a memory item that turns up on new hardware:** a new device identity is minted there, and it takes over its
  predecessor's Apple keys — a replacement Mac entering Castle retires its predecessor's own key;
- **a living Mac cloned onto new hardware** (Quick Start, Migration Assistant, or a Time Machine restore to another Mac,
  the original still in use): the clone
  gets its own identity; if either Mac enters Castle and retires the Apple key they share, the other heals with
  Re-link's library arm, and nothing stops opening;
- **the memory item deleted alone** on an Always-ask Castle Mac where a finger has been enrolled: the Mac finds its own
  device section by its hardware, and nothing changes — no Touch ID item, no question;
- **both homes rolled back past a switch to Always ask,** with a finger enrolled since: the restored choice says Touch
  ID, no item exists, nothing is asked, and Always ask is recorded quietly;
- **a replacement Mac's first open:** it starts on Always ask, and Touch ID comes on only from Settings;
- **a Standard library's own Apple key lost** (iCloud Keychain reset, or a switch of Apple ID): the assessment offers
  Re-link's library arm, and after it promise 3 settles — for a local-only library too;
- **today's Standard-waiting and exposed libraries through the migration:** each current key takes the mode step 2
  records, and promise 2 holds for whatever is recorded Castle;
- **a Time Machine rollback past a re-key:** this library's later copies still read as its own (the family tree's two
  homes);
- **a synced pair landed with a passphrase made new:** at Resume Sync it becomes the account's, through the account's
  forgot road, as the landing said.

Each is shown to **fail** when its guard is removed from the new code, and to pass with it. The guards include a plan
the record doesn't name, the two homes of this Mac's facts, the device section's hardware marker, no repair making a
Touch ID item, no re-arm question without an existing item, gifts only for this Mac's copies, the re-key at every
crossing, the anchor written first and carried by every re-key, a follower's anchor locked under the secret typed at
its follow, the family tree's own-line check and its two homes, the door-time vault check, the export-off step,
Castle-kind custody through a leave's rotation on every device, the leave's id gating its completion, and every own
Apple key retired at entering Castle.

### 4.2 The gates the model can't reach

The scenario test can't reach these:

- real-Keychain drills on a throwaway scope: Touch ID invalidation, access groups, deletes of synchronizable items,
  and whether Keychain Access can list and delete a Touch ID item;
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
- the history and the Castle anchor;
- every act's steps, with the whole cycle — into Castle and back out — as a flow chart (what you have, each step, what's
  new, what goes away, who can open what after it), and entering Castle animated on the map. The cycle alone is also
  its own page, `notes/plans/vx-266/castle-key-cycle.html`;
- who can open what.

Phase 5's closeout — the last before VX-212's own phase — carries **the map table**: one row per map element, each
naming the test, drill or walk that proves the code matches it, and its result. An element with no proof, or a
mismatch, blocks the effort's close. If a phase changes the design, the map changes in the same commit, at her word.

**The companion explainer**, `notes/plans/vx-266/castle-map-fable.html` — the plain-language page the round-2 Fable
reviewer made at her ask (the rules in a sentence, the four crossings, who opens what) — is second to the maps: it
proves nothing, and wherever it and the maps differ, the maps win. At phase 5's closeout, when the field-guide question
in §9 is decided, it is re-verified against the maps, or deleted.

---

## 5. The phases (each its own run, ticket, branch, ladder and closeout; one sitting ruled them all)

The cast, in every phase:

- **Hers at each kickoff.** This file was written with Fable orchestrating and cold-reviewing and Opus implementing.
  Her later call on main (the release runway, 2026-10-13: *"I decided to orchestrate with Opus to reduce load on Fable
  and make sure there was enough for reviews."*) has runs orchestrated by Opus, with Fable cold-reviewing; the
  runway's Castle row still reads "Fable leads". She picks at each kickoff.
- Every `Sync/` line is Fable's, and this effort holds the one Sync/-or-custody slot.
- `/architect-phase` is recommended (custody and design-heavy); `/run-phase` is hers to pick at any kickoff.
- One acceptance unit per implementer session.
- Every bug-class change lands red-on-old.
- No new dependency, and no lockstep event: the server is untouched except phase 6's design, if it needs one, and
  VX-213's `pg_temp` fix at her go.

| phase | ticket | what | acceptance units and evidence | members |
|---|---|---|---|---|
| **1 — the headless core** | VX-305 | `Sources/VariorumCore/Protection/`: the record with its family tree and device sections, key file v3 with the history and the anchor, what the Mac remembers and its seals, the custody/Apple-key/vault interfaces, `assess`, the executor and sealed plans, the catalog and route finder with attribution and retention, and §4.1's scenario world | **one phase-sized unit** (the posture model), built in four sessions (model · assess and routes · executor · the world). Evidence: the generated runs green across seeds; every fixed scenario green; every mutation pin red without its guard. **GO / NO-GO at close** — a quality gate; her word is "go even if it delays launch" | VX-228 (corner 45's model), VX-235 (plans), VX-263 (the history, the anchor, the family tree), VX-302 (attribution), VX-313 (this Mac's facts in two homes, sealed plans) |
| **2 — the open road and the migration** | VX-306 | the route and lobby on roads; per-key items, what the Mac remembers, the record and key file v3 going live; the migration (§3.13); the phone builds and opens — **on in Debug builds only, like every phase's new code, until her release switch** (VX-329, §5 below) | two units (the open road · the migration). Evidence: the migration drill per §3.13 shape; the Keychain leg on a throwaway scope; the dev store under a held claim; her stores rehearsed on byte-copies; the restore drill | VX-228, VX-235 (the migration clears today's stuck markers), VX-209 (the open rule's road), VX-263 (the fold), VX-301 (keys of their own beside the old shared key, the fresh pair), VX-213 (the leftover key file), VX-310 (the lobby's Touch ID); the device identity's new home and hardware marker (second opinion §2.5) |
| **3 — the acts** | VX-307 | Use Castle (its checks at the door; the export-off step), Use Standard (a key change: the anchor; history flows into Castle, never out), Replace All Keys and the follow (every follow typing one secret) on sealed plans; the Apple keys' lifecycle (VX-301); the `Sync/` lines (VX-107, VX-109, the marker leaving the library file — `SyncEngine.refuseIfRekeyIncomplete` reads the plan — the leave marked in the vault by the account key's id with no wrap, and its one completing write — made only by a device that reads that key — adding the account's Apple copy; sync keys held by what they reach, on every device, through the window); every Apple key of this Mac's own retired at entering Castle; the old shared key's checks and retirement; copies pausing between an act's prepare and its swap; VX-233's drill healed | one road per session. Evidence: each road's drill; the posture drill green; convergence suites for the Apple-key mint/wait/delete rules | VX-235 (prepare-then-commit, the record naming the act), VX-263 (the anchor, leaving Castle), VX-301, VX-313, VX-107, VX-108, VX-109, VX-113, VX-233 |
| **4 — accounts and the key doors** | VX-308 | the binding and rows owned by it (VX-314); the four situations; the one-road signed-out screens both ways; Stop syncing here; Move; setup, enroll and connect; every leave re-keying, in both modes (§3.8), carrying any anchor; change passphrase, new words and the reset road, with every door that replaces a secret while an anchor exists saying its sentence (§3.9); the Touch ID re-arm (only after a press fails on an item that exists; a new device identity starting on Always ask, §3.10); the gate style in this Mac's facts; Re-link minting a fresh account key, and its library arm; the one presenter | one door per session. Evidence: each door's drill; the account-sequence walk (signed in, out, into another account, back) | VX-314, VX-313, VX-263 (the anchor carried by every leave; the per-door sentences), VX-301 (Re-link and its library arm), VX-264 (the signed-out screen, the leaving rules), VX-239, VX-243 |
| **5 — copies and words** | VX-309 | the restore list over the catalog (older libraries included); Open Library and the open rule (the family tree deciding "ours"; a different library landing under a fresh key, the other secret typed or made new); Send Library with no sharing sentence; the plaintext export's ID; retention per library and Mac; the Castle offer under VX-301, with the old shared key's sheet and notice; the *Opens with* line everywhere; Data Safety and `RESTORE.md`; the field guide's try-it-yourself line; VX-211; VX-264's and VX-210's words; the lock-time copy named from the file's own key; adoption writing the key file before the store lands | two units (copies · words). Evidence: walks in both voices; the restore drill; **the key-map table (§4.3)** | VX-209, VX-210, VX-211, VX-263 (the route finder's words), VX-264, VX-265, VX-301 (the sheet's words), VX-302, VX-317, VX-213 (the record corrections, the privacy text) |
| **6 — VX-212** | VX-212 | designed with her first (§3.14), then built under Fable | one repair rule. Evidence: convergence suites plus one live two-device round | VX-212 |
| **the release switch — at her word** | VX-329 | the new system on in Release builds, in one change in one place; §3.15's deletions; the legacy readers kept | its own run and ladder. Evidence: the scenario suite and soak under `swift test -c release`; the real-scope branch rehearsed before her live stores migrate (§9), every Apple key id it mints logged; a Release build of the switch's change on byte-copies of her stores behind the A1 rail; the restore drill; a Fable cold review of the switch's diff; her acceptance on both Macs and the phone | VX-329 |

**Sizing is guidance** (her ruling, §1). Phases may hold more than two phase-sized units, or merge, at the
orchestrator's judgment, recorded in the phase plan. The split above is a recommendation for ladders a cold reviewer
can hold in one read, not a rule.

**Order and gates.** 1 → (go/no-go) → 2 → 3 → 4 → 5 → 6, each merging to main as it closes, all in Debug builds only;
then the release switch at her word (VX-329, below). VX-212 (phase 6) comes *"once the first plan is working"* (her word): its
design sitting follows phase 5's close, and whether the release waits for it is hers. A phase closes on its kind's
evidence, never on a pin alone.

**The release switch: the new system stays off in Release builds until her word.** Each phase merges to main as it
closes, like every other run, and other efforts' refreshes and beta builds would carry anything turned on in Release.
So **every phase's new code — the new road, the migration, the acts, the doors and the copies — is on in Debug builds
only**: no Release build — hers, the phone's, a tester's, or one another effort refreshes or cuts — runs it. Debug
builds use the fenced dev store, so until the switch the new system touches only the dev store and byte-copies of her
stores; today's code stays alive on main because Release still runs it (§3.15). **Her rulings:** *"phase 2 can be
copied on dev s tore and my store copies and then we can release it to my store / the store of my beta testers"*,
*"my mac and phone can wait for phase 3 to be done"*, after round 2 *"yes phase 2 will stay in debug builds until phase
3"*, and at round 3, told that phases 4 and 5 rebuild doors that write keys too, *"that's fine on my devices waiting
for the new system til the end of phase 5"* and *"yeah we'll wait to turn the new system on in release builds / wait to
put it in release builds til i'm ready to release it."*

- **What "off in Release" means** (PROVISIONAL, for her confirm — §9): the app's wiring. The core compiles in both
  configurations and is tested in both from phase 1 (`swift test` and `swift test -c release`), so no new code meets
  the optimizer for the first time at the switch; Release builds carry it dormant, and the switch flips the wiring.
  The literal reading — the new code left out of Release builds entirely until the switch — is the other option.
- **The switch is one change in one place, with its own ticket, run and ladder (VX-329)**, made at her word when she's
  ready to release — after phase 5 at the earliest: the new system turns on for Release builds, the migration runs on
  her Mac, her phone and her testers' stores at their next unlock, and §3.15's deletions land in the same change.
  Phase 2's plan adds a check proving a Release build still runs today's road.
- **The switch's evidence**, beyond the phases': the scenario suite and soak under `swift test -c release`; the
  real-scope branch rehearsed before her live stores migrate — Debug builds use the dev scope and the Keychain
  tripwire keeps tests off the real one, so the migration's fold through the real old shared key would otherwise run
  for the first time on her store (how it's rehearsed is §9's, decided with her; the rehearsal logs every Apple key id
  it mints, so a stray key can be deleted by id); a Release build of the switch's change on byte-copies of her stores
  behind the A1 rail before anything reaches `/Applications`; the restore drill; a Fable cold review of the switch's
  diff, since it deletes custody code; and her acceptance on both Macs and the phone.
- **Today's bugs stay live in Release until the switch.** Keeping the new code off in Release keeps its fixes off too:
  VX-209's silent drop out of Castle when a Standard-era copy is opened, VX-302's cross-Mac pruning, VX-317's banner,
  VX-107, VX-108, VX-109, VX-113 and VX-213's tidy-ups all stay as they are in every Release build, hers and her
  testers', until the switch. Whether any of them gets a small fix on today's road first is hers (§9).
- **The dev store after phases 2 and 3.** Once a Debug build from main has migrated the dev store, and phase 3's first
  act has re-keyed it, a Debug build from a branch cut before phase 2's merge can't open it — other efforts' walks and
  the phone's Debug build among them; before that re-key, such a build still opens it but writes today's key files
  beside it. Efforts merge main before walking the dev store.
- **Told at this design's merge:** the release runway and the stage coordinator — the switch, VX-329, and the dev
  store's note above.

**The riskiest part** is phase 2's migration, which touches every existing store. **The cut lines, if ever needed:**
the restore list's older-libraries section and the per-Mac far-folder subfolders (a filename tag would do).

---

## 6. Every ticket, placed

| ticket | settled by | phase |
|---|---|---|
| VX-209 the way-back revert | the record + per-key items + the open rule (the family tree decides "ours"; a copy takes the current facts; a different library lands under a fresh key, the other secret typed or made new); FLIP `VX209WayBackRoundTripTests` | 2, 5 |
| VX-228 corner 45 | deleted; the mode recorded; confirming it is a key change | 1, 2 |
| VX-263 W-1 | the history and the Castle anchor (into Castle, everything; out of Castle, nothing; the anchor keeps the secrets of its day and rides every re-key; a follower's anchor locked at its birth under the secret typed at its follow); the family tree in two homes; the migration's fold; the route finder's words | 1, 2, 3, 4, 5 |
| VX-264 her #216 rulings | §3.11 / §3.8 (the leaving and joining rules included) | 4, 5 |
| VX-265 a separate delete choice | the offer's other-libraries group | 5 |
| VX-210 other folders | §3.7's reworded line | 5 |
| VX-235 the unfinishable marker | prepare-then-commit; sealed plans; the migration clears today's stuck markers | 1, 2, 3 |
| VX-107 the double crash | the follow's plan carries the facts (`Sync/` — Fable) | 3 |
| VX-108 doors on a stale reading | doors read `assess`; the acts read the vault they fetch | 3 |
| VX-109 `begin` re-fetches | `begin` takes the door's revision; and the leave's rotation: the account key's id written at its start with no wrap, the three-state reading, completion only by a device that reads that key, the lost actor's finish naming the leave, sync keys held by what they reach (`Sync/` — Fable) | 3 |
| VX-212 the poison row | its own design | 6 |
| VX-213 tidy-ups | the leftover key file (fold, then retire); escrow items removed; `pg_temp` at her go; the record corrections and privacy text | 2, 5 |
| VX-211 passphrase strength | §3.11 | 5 |
| VX-239 / VX-243 sheets | one presenter | 4 |
| VX-233 drill rot | the runner takes dependencies explicitly | 3 |
| VX-301 retire the Apple key | §3.5: one Apple key per library per Mac and one per account (the vault only); the migration's keys of their own beside the old shared key; accounts stay on it until Castle or Re-link; Use Castle retires every key of this Mac's own for the library, and the old shared key after its checks at the door; leaving an account mints nothing; a replacement Mac takes over all its predecessor's own keys; a key left in a former Apple ID is a stated exception; delete on sight by recorded id; Re-link mints fresh, and its library arm mints a library's own key when it's lost | 2 (the moves), 3 (lifecycle, retirement), 4 (Re-link and its library arm), 5 (the sheet's words) |
| VX-302 cross-Mac pruning | §3.7 attribution and retention | 1, 5 |
| VX-113 the changed-elsewhere refusal | §3.9: the follow names the change | 3 |
| VX-313 seals | §3.6: this Mac's facts in two sealed homes, newer wins, the device section found by its hardware marker; plans sealed and named by the act in flight; copies carry only the library's facts; no repair makes a Touch ID item; the claims scoped to Castle | 1 (the model), 3, 4 |
| VX-314 rows owned by the library's account | §3.8 | 4 |
| VX-310 the lobby's Touch ID | §3.10: the button whenever an item exists; the stored hash a hint (the re-arm question that follows a failed press is phase 4's door, asked only when the item exists) | 2 |
| VX-317 Resume Sync's banner | clears only when the hold marker is gone | 5 |
| VX-329 the release switch | §5: the new system on in Release at her word; §3.15's deletions and legacy readers; its own run and evidence | after 5 |
| VX-266 flagship | this file | — |

**Also in the phases' scope**, from the second opinion's research and rounds 2 and 3, each with a red-on-old pin: the
device identity's move into what this Mac remembers and the device section, with its hardware marker (phase 2,
VX-306); the check that a Release build still runs today's road (phase 2's plan, VX-306), the switch itself being
VX-329's; the lock-time copy named from the file's own key, and adoption writing the key file
before the store lands (phase 5, VX-309).

Outside the project, settled in passing and hers to fold in: VX-100 (asked twice — the open and the enrollment in one
session), VX-101 (older libraries in the restore list), VX-102 (a landed copy's flags), VX-104 (an older-library
drill), VX-152 (Lock reentrancy), VX-240 (a wrong instruction mid-act), VX-81 (a macOS 27.0.1 crash in the re-key
reopen — phase 3's executor replaces that runner, so phase 3 re-checks it), and VM-15 (a sibling phone that hasn't
followed into Castle — VX-301 and the follow's typed secret settle it: the phone follows like any device).

---

## 7. Canon deltas, landed at the closeouts (contract lines plus pointers, never history)

- **`pre-13x-postures-design.md`:**
  - §3.1's posture row becomes "recorded in the library, remembered by the Mac, reconciled", and its dials row
    becomes "this Mac's facts, in the record's device section and what this Mac remembers".
  - §3.3's local-only set grows by `protection_record`.
  - §3.5 becomes format 3: one file, the history and the anchor.
  - §3.7 and decision 14 now cover Standard too.
  - Decision 6 and corner 5: the Apple key is **retired** on entering Castle — this Mac's own per library, the
    account's with the account's rotation; the old shared key, by Use Castle's last step after its checks.
  - Corner 46 (iCloud Keychain's state can't be seen) reaches the words: rule 3 says "when it's on".
  - Decision 7: leaving Castle re-keys, takes nothing back (the anchor), and mints fresh Apple keys, never "read,
    minted if absent".
  - Decision 9: a posture change in either direction is a key change with both secrets typed, not Touch ID or the
    passphrase.
  - Decision 33's "Touch ID confirms only wrap-free acts (leaving Castle, …)": leaving Castle is no longer wrap-free;
    and its two narrowings (a landing's one secret; Use Standard's typed words).
  - The Castle table's "at the switch to Standard" column and the two-switches table's Castle → Standard column ("the
    same key", "NO rotation"), §4's Castle → Standard paragraph ("Nothing rotated"), §7's follow into Standard
    ("nothing typed, nothing rotated") and §12's "a Castle→Standard switch propagates silently": a key change, with
    every device typing one secret.
  - Decision 3, §3.3's device-identity row and decision 13's identity clause: the device identity moves to what this
    Mac remembers, with a hardware marker; sync keys are per account, not per store.
  - §3.4's credential-audit tables ("STAYS in iCloud", "minted if absent") follow the retirement and the per-Mac keys.
  - §6's "for as long as it exists" goes.
  - 17m's Re-link door: it mints a fresh account key (its never-mint rule retires with the shared key).
  - Decision 8's local half reads "its own record's".
  - Decision 11 gains the history and the anchor.
  - Decision 13: custody per key, of the key's kind for life.
  - Corner 4: pre-Castle copies stop opening through the Apple account.
  - Corner 14: each account its own Apple key, locking only its vault.
  - Corner 34 is retired: every device has its own key per library.
  - Corner 36: the stored choice, per device; the re-arm question only after a press fails on an item that exists,
    and a new device identity starts on Always ask.
  - Corner 45 is retired.
  - Corner 33 (a library arriving by AirDrop needs no new key): a landing lands under a fresh key, one secret typed and
    the other typed or made new.
  - Corner 6 (only a library Standard-born into Castle re-keys at enrollment): joining an account in Standard from
    Castle is leaving Castle, with its anchor; joining in the library's own mode keeps the key.
  - Corner 27 (enrollment's one-passphrase re-wrap): kept; an anchor is untouched and keeps the secrets of its day.
  - §6's sentence becomes §3.1 rule 4.
- **AppSpec §7:** the record table (with the family tree and device sections), the export identity table, format 3;
  `rekey_in_progress` retires. **AppSpec §12:** 13x's custody-collision clause (a different library lands under a
  fresh key, one secret typed and the other typed or made new); the line "so a Mac new to a library enrolls" follows
  the identity's move; the restore list's reach; one restore door; the offer under VX-301; the *Opens with* line.
- **The 13x plan:** the row-4 custody-collision memo and ledger 5 (an export lands under its own library ID).
- **SyncSpec §3's pre-13x paragraph:** custody per key, and sync keys held by what they can reach; the device identity
  and the per-store sentence follow the identity's move; the rotation's resume record leaves the library file; a
  Castle → Standard rotation names the account's fresh Apple key's id in `apple_key_id` at its start with no wrap
  (the vault reads: a wrap — Standard; an id with no wrap — leaving Castle, in progress; neither — Castle), and only
  a device that reads that key completes it, adding the wrap once the previous corpus key is cleared. VX-212 adds its
  own line.
- **`notes/plans/pre-13x-copy.md` (the copy file, the one source of the app's words):** every entry whose fact this
  design changes is re-written by the phase that changes the behaviour behind it, and published only when Release
  runs it (VX-329). That covers:
  - the cards (rule 3's login-password truth);
  - the ceremonies (Use Castle's door and checks; Use Standard's rule 5; the follow's one typed secret);
  - the lobby's re-arm question;
  - the key doors' sentences;
  - the backups and older-copy lines;
  - the tutorial chapter;
  - the FAQ's entries on old backups after Castle, lost secrets with an old backup, leaving Castle, a new Mac and
    restoring;
  - the privacy-brief lines.

  The design handoff lists each surface with its phase.
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
  - §3.5a's: the words changing while a silently-joined device hasn't refreshed or followed.
  - copies from before a leave keep the secrets of the leave day (her ruling): change both your passphrase and your
    words later, and they need the old ones — every door that replaces a secret says so, and the route finder names
    the day.
  - a follower's anchor opens with the secret typed at its follow, and through the master's words copy with the words
    only as fresh as that device's copy was when it left: words made new during Castle while that device was offline
    aren't among them, and a passphrase changed elsewhere and never typed there isn't either. Its *Opens with* line
    names what does open it.
  - an older build's leave or follow puts the Castle-era master under the old shared Apple key with no change of keys;
    this build never adds to it (its follow leaves the master's road out of its anchor), and it ends when the old key
    is retired.
  - in Castle, rolling back both homes of this Mac's facts at once returns this Mac's settings to that state (§3.6) —
    and never opens what was written before it to the one who did it. In Standard, a login-password holder holds the
    library key and can rewrite the record, as rule 3 says.
  - a retirement made while this Mac's iCloud Keychain is off deletes only this Mac's copy until it's on again; the
    key lives on in iCloud meanwhile, and delete on sight finishes the job.
  - rule 2's second and third exceptions: copies made while a library synced with an account in Standard (until that
    account replaces its keys or enters Castle), and a library sent to another Mac before this change, until either
    copy crosses a line.
  - a Standard copy made with no passphrase or words opens only through its own Apple key and this Mac; if both are
    gone, nothing typed can bring it back. The Standard card says so.
  - a Standard library with no passphrase or words on a Mac whose iCloud Keychain is off: after the old key is
    retired, it opens only on that Mac. The sheet lists the ones this Mac holds and says it for the rest.
  - another Variorum account still in Standard on the same Apple account: after the old key is retired, it sets up
    new devices with its passphrase until it's re-linked. The sheet says so.
  - a Mac cloned onto new hardware while the original stays in use shares the library's key and its Apple key with
    the original until either one crosses a line or retires that key. If one enters Castle, the other's Apple road
    goes, and the other heals with Re-link's library arm; its silent item and its passphrase and words keep opening
    it meanwhile.
  - copies locked under an Apple key left in an Apple account this Mac no longer uses open through that account until
    its keychain loses the key; this Mac can't delete it there (rule 2's last stated exception). Use Castle's door
    names them, and they can be deleted.
  - today's bugs stay live in every Release build until her release switch (§5): the new code that fixes them is off
    in Release until then. Whether any gets a small fix on today's road first is hers (§9).

---

## 9. Open (decided at the phase that meets it, recorded PROVISIONAL, logged in QUESTIONS)

- **The exact Touch ID re-arm and retirement-sheet copy, and the leave screen's plain line:** her approval at phase 4
  and phase 5's walks.
- **A retention rule for older libraries:** kept as today until she rules.
- **VX-212's design:** her sitting before phase 6.
- **Whether a release version of the key map ships** in the field guide's encryption chapter: after phase 5, re-voiced
  and verified against the shipped build. The companion explainer (§4.3) is its first draft, re-verified or deleted
  then.
- **The cast at each kickoff** (§5).
- **The release switch:** her word, when she's ready to release — after phase 5 at the earliest (§5, VX-329).

**Called provisionally overnight, 2026-10-14, at her word** — *"i want you two to continue through to handoff, ruling
provisionally where needed ... document decisions and why they were made for me in enough detail that i can discuss it
with a session tomorrow"* — each settled with the round-2 Fable reviewer, which had the final say at her word. The
options and the reasons are in `design-cold-read-r3.md` (the extra read's section) and the design handoff:

- **A follower's anchor is also locked at its birth under the secret typed at its follow** (§3.4), and rule 5 says
  what opens a follower's copies (§3.1). PROVISIONAL, for her confirm: it touches the premise of her ruling that the
  anchor keeps the secrets of its day. The other option was to change nothing in the mechanism and only say the truth
  — that on a follower, copies from before the leave open with whatever opened that device then, which is often not
  the passphrase she had when she left.
- **"Off in Release" means the app's wiring; the core compiles and is tested in both configurations from phase 1**
  (§5). PROVISIONAL, for her confirm: her words were *"wait to put it in release builds"*. The other option is the
  literal one — the new code left out of Release builds entirely until the switch.
- **How the real-scope branch of the migration is rehearsed before her live stores migrate** (§5): open, decided with
  her in VX-329's plan. The options: a spare macOS user on the same Apple ID; the Air first, as a canary; or the
  rehearsal taken as the first leg of the real migration. Whatever runs logs every Apple key id it mints.
- **Today's bugs in Release until the switch** (§5, §8): whether VX-209, VX-302 and VX-317 get small fixes on today's
  road first, and the rest wait — hers, bug by bug, from the table in the handoff.
- **The Touch ID re-arm question asks only after a press fails on an item that exists**; with no item, Always ask is
  recorded quietly and Touch ID comes back from Settings (§3.10). PROVISIONAL: it narrows when the question appears
  (round 3 had it ask after a delete or a wipe too); VX-310's button rule is untouched.
- **A new device identity starts on Always ask** (§3.10). PROVISIONAL, with her words at phase 4's walk.
