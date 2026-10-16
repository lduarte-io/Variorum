# VX-305 — Castle rebuild, phase 1: the headless core

**Status: OPEN — kicked off 2026-10-14 (`/architect-phase vx-305`; plan written 2026-10-13; revised the same night to
the design's round-2 shape, and on 2026-10-14 to round 3 and its late extra read).**

> **KICKOFF SITTING (2026-10-14, the author via the question tool — recorded before the first spawn):**
> - **The cast: the standing default, her pick** — Fable (this session) orchestrates and cold-reviews
>   (`fable-reviewer`); Opus implements at xhigh, one unit per session. (The runway's Opus-orchestrates economy was
>   offered beside it and not taken.)
> - **VX-340: option (a) CONFIRMED** — the hardware marker is a hash of the hardware identity AND the macOS login's
>   stable identity, with the record's random salt, so a second login on the same Mac starts its own device identity.
>   The §1/VX-340 PROVISIONAL mark is resolved; option (b) (hardware-only marker + a refusal on a mismatched login)
>   was offered beside it and not taken. U1 still chooses and records WHICH login identity is stable enough (the
>   plan's §3 note).
> - Workspace: `vx-305-castle-core` cut from `origin/main` at `f2eb1aa4`; worktree `~/dev/variorum-vx-305` (the Pro);
>   the in-flight row holds the ONE Sync/-or-custody slot; no stage (headless).

- **Ticket:** VX-305, in project "Castle & backups before launch" (flagship VX-266).
- **The binding design:** `notes/plans/vx-266-castle-backups-prelaunch.md`. Her rulings are its §1.
- **The acceptance artifact:** `notes/plans/vx-266/castle-target-key-map.html`.
- **Branch and worktree** (made at kickoff from `origin/main`): `vx-305-castle-core` and `~/dev/variorum-vx-305`.
- **Not the design branch:** `vx-266-castle-backups-before-launch` carries the design documents and merges first.

> **KICKOFF MESSAGE** — the orchestrator's brief for each implementer session.
>
> You are building **phase 1 of the Castle rebuild: the new protection core, headless.** Nothing in the app changes in
> this phase.
>
> **Read first, yourself, in full:**
> - `CLAUDE.md` and its auto-loaded canon;
> - `notes/SessionResiliencyProtocol.md` (the checkpoint rules below come from it);
> - **the design**, `notes/plans/vx-266-castle-backups-prelaunch.md` — whole;
> - **this plan**, whole;
> - `notes/SyncSpec.md` §3, for the custody facts;
> - `notes/plans/pre-13x-postures-design.md` §1–§7 and §14 — the design being replaced, to understand what today's
>   stores look like;
> - `notes/plans/vx-266/second-opinion-apple-facts.md` — what the real Keychain, Touch ID and iCloud Keychain do.
>   Your fakes must behave the same way.
>
> **Read for today's code** (what the model must be able to start from, and what later phases rewire):
> - `Sources/VariorumCore/Persistence/` — `StoreKeyEnvelope.swift`, `StoreKey.swift`, `StoreIdentity.swift`,
>   `BackupRestoreCandidates.swift`, `LibraryClassifier.swift`, `StorePlaintextExport.swift`;
> - `Sources/VariorumCore/Sync/CorpusRotation.swift` (the marker and the rotation);
> - `App/Variorum/Shared/` — `StoreProtection.swift`, `StoreLaunchGate.swift`, `StoreKeyGuard.swift`,
>   `KeychainCustody.swift`, `EncryptionKeychain.swift`, `AppleKeyCustody.swift`, `ProtectionController.swift`
>   (`reconcile`, `healAppleHeldCopy`), `AppleRelinkModel.swift` (17m's Re-link door — what an older build does to the
>   vault), `PostureSwitch.swift` (the runner), `LibraryOpenModel.swift`, `StoreBackup.swift`, `BackupRetention.swift`.
>
> **Do:** the unit named NEXT in this plan's LIVE STATUS — one unit per session — per its section below.
>
> **Where your code goes:**
> - code: `Sources/VariorumCore/Protection/`;
> - tests: `Tests/VariorumCoreTests/Protection/`.
>
> **Hard limits:**
> - Do not touch `App/`, `Sync/`, `Server/` or any migration.
> - `swift build` and `swift test` only — no `xcodebuild`, no stage, no app launch.
> - No new third-party dependency. CryptoKit and Foundation are enough.
>
> **The checkpoint rules (binding from your first commit):**
> - Commit per coherent piece and push after every commit (WIP commits of a compiling state are legal, and named
>   honestly).
> - Write this plan's LIVE STATUS for your unit at your start, and flip it in the same commit as each piece.
> - Mark every unverified claim **PENDING** until the run that proves it finishes.
> - Synchronous foreground waits only.
> - No `Co-Authored-By` trailer.
>
> **The rule against guessing:** where the design is silent, write two or three options into your unit's record,
> build the most design-defensible one, mark it **PROVISIONAL**, and add it to `notes/QUESTIONS.md`. Never invent
> product behaviour; never relax an invariant.
>
> Do not spawn subagents or use the Agent tool, with one exception: you may run at most ONE Sonnet lookup subagent at
> a time (spawn it with `model: "sonnet"`), strictly for external facts — web searches, Apple documentation, API
> signatures/availability. It returns facts and quotes; it never edits files and never spawns agents of its own. Never
> delegate reading of the repo's docs, the phase plan, code, or the diff under review — do that reading yourself, in
> this session.
>
> **Report back with:**
> - what shipped;
> - the test counts (`swift test` exit lines);
> - the PROVISIONAL calls made;
> - the commits made;
> - anything for the author.

---

## 1. What this phase is, and how it closes

**One phase-sized unit — the posture model — built in four implementer sessions.** Sizing is guidance (her ruling).
The four-session split exists so each session holds one coherent piece.

**The phase closes at a GO / NO-GO, which is a quality gate, not a schedule gate.** Her word: *"go even if it delays
launch."* It needs all of the following:

1. **The generated scenario runs are green** across at least 20 seeds, each running at least 1,000 action sequences
   of up to 60 steps, under `swift test` in a reasonable time — and under `swift test -c release` too, since the core
   compiles in both configurations from this phase on and nothing may meet the optimizer for the first time at the
   release switch (design §5). Record both times.
2. **Every fixed scenario in §6 is green**, in both configurations.
3. **Every mutation pin is red with its guard disabled** and green with it.
4. **A Fable cold-review ladder is closed** — at most three rounds, with every finding dispositioned here.
5. **The model half of the key-map table is written:** one row per element of the target key map, naming the test
   that proves the model does it. The code half comes at phase 5.

**Cast:**

- **Hers at kickoff** (design §5). This plan was written with Fable orchestrating and cold-reviewing and Opus
  implementing; her later runway call has runs orchestrated by Opus, with Fable cold-reviewing.
- This phase writes no `Sync/` line, but it is the custody effort's start, so it holds the one Sync/-or-custody slot
  (the stage coordinator grants it).
- No stage is needed.

---

## 2. The shape of the code (names are the design's; refine with a recorded reason)

```
Sources/VariorumCore/Protection/
  Model/      ProtectionRecord (the library's facts + the family tree + one device section per device) ·
              KeyFile (format 3: wraps + history + the Castle anchor; readers for formats 1 and 2) ·
              LegacyReaders (read-only, outliving the release switch — design §3.15: today's mode rule as one
              pure function; the reads of today's per-library-ID items and 13p escrow items; and the old
              `RotationMarker`'s read with its clearing check) ·
              DeviceMemory (+ sealed fields, + key-file mirror, + the device section's second home, + the hardware
              marker) · Plan (+ seal) · Seal (HKDF + HMAC) · Names (custody item by fingerprint and kind, sync-keys
              item, memory item, Apple key: <scope>-apple-key-<id> per library per Mac and per account, the old
              shared name)
  Assess/     Facts · Assessment · assess(_:) · Roads · RouteFinder (+ the Opens-with line) · Catalog (one name
              parser; attribution to library + Mac) · Retention (per library per Mac; legacy flat files never pruned)
  Executor/   Leaves (protocols: Custody, SyncKeys, AppleKeys, Vault, LibraryFile, KeyFileStore, MemoryStore,
              PlanStore, Backups, Clock, IDs, Biometry/LAEnvironment) · Executor (repairs + plan runner) ·
              Acts/ (one file per act: EnterCastle, LeaveCastle, ReplaceAllKeys, Follow, OpenCopy, Land,
              SendLibrary, Migration, ConfirmMode, MoveOffSharedKey, RetireSharedKey, RelinkApple, CreateLibrary,
              SetUpSync, Enroll, Move, ThisMacOnly, StopSyncingHere, DeleteAccountHere, ChangePassphrase,
              ResetPassphrase, RegenerateWords, DeviceSettings (gate style, idle lock, scheduled export),
              TouchIDRearm, OfferDelete, PlaintextExport)
Tests/VariorumCoreTests/Protection/
  ModelTests · AssessTests · RouteFinderTests · CatalogTests · RetentionTests · ExecutorTests (per act,
  per step, per crash point) · Scenario/ (World, Fakes, Alphabet, Promises, Generator, FixedScenarios,
  MutationPins)
```

**Two rules shape the leaves:**

- **The executor is the only thing that calls a writing leaf.** `assess` takes plain values and calls nothing.
- **Guards the mutation pins switch off** live in one `ProtectionGuards` value whose off-switches exist only under
  `#if DEBUG`. Release builds strip them, as with the store's DEBUG oracles, so the mutation pins run in the Debug
  configuration and everything else runs in both.
- **The core compiles in both configurations** (design §5, confirmed by her 2026-10-14 — *"dormant in release is what
  i meant."*): "off in Release" means the app's wiring,
  which phase 2 owns. Nothing in this phase is behind `#if DEBUG` except the guards' off-switches.

---

## 3. U1 — the model

Build everything in §3.2 of the design as values, with their codecs and their crypto:

- **The protection record**, as a value: the library's own facts — the mode (the current key's kind) and whether it's
  confirmed, the account, the epoch and fingerprint, and **the family tree** (every key the library has had: its
  fingerprint, its kind for life, the Mac that made it, when it was made and retired; mirrored, sealed, in the memory,
  the two unioned at open) — and **one device section per device**: the device identity and its hardware marker, the
  act in flight, the settings that could weaken protection (gate style, idle lock, scheduled export), the
  Apple key ids that Mac minted or followed and whether each is retired, the old shared key's state, and a version that
  only grows. The SQLite table comes in phase 2.
- **Key file format 3:**
  - the current key's wraps — passphrase with its KDF descriptor, words, master, and, for a Standard key, the Apple
    wrap under this Mac's own key for the library, naming its id (on stores from before this change, the old shared
    key's wrap rides beside it until that key is retired);
  - **the history**: the older keys the current key takes, each wrapped directly under it, with fingerprint, epoch and
    retirement date;
  - **the Castle anchor**: the outgoing Castle key with its whole history (and any earlier anchor kept beside it),
    sealed under one anchor key — on the device that presses Use Standard, wrapped under the passphrase and the words
    typed there; on a follower, wrapped under the secret typed at its follow and under the outgoing Castle key itself,
    with that key's own locks from the device's key file copied beside it (its passphrase or words wrap, its master
    wrap and the master's words copy), the master's road left out when the vault's master was never changed. Both are
    birth-time locks. Never re-locked after it's written: it keeps the secrets of its day, and every later re-key
    carries it unchanged;
  - the master's twelve-words copy (design §3.5a), when the file has a master wrap;
  - **re-keying, per design §3.4:** entering Castle takes everything (the anchor folded back in; an anchor the typed
    secrets can't open is kept beside the history, unchanged, and never fails the entry); within a mode, the old key
    and its history, with the anchor carried unchanged; leaving Castle and a landing take nothing, and leaving Castle
    writes the anchor first;
  - the same format serves another library's key file in `Backups/<library8>/<mac8>/` (design §3.5).
- **Readers for formats 1 and 2.** Old key files are read forever, and the catalog and route finder use them.
- **The legacy mode reader:** today's mode rule (`Posture.derive`'s inputs and corner 45's test) as one pure,
  read-only function — the migration calls it once per store, and a copy with no record calls it forever (design
  §3.7, §3.15). It decides nothing else and writes nothing.
- **The old marker's read and clearing check:** the in-file `RotationMarker` read forever, and the evidence that
  resolves it from disk — the act never happened (the library opens under its old key, the new key never landed) or
  its commit happened (design §3.13 step 1, §3.15).
- **What this Mac remembers:** the device identity with its hardware marker (also kept in the device section), the
  biometry state hash (a hint, never a verdict), the vault facts, the key-file mirror (wraps, history and anchor), the
  family tree's mirror, and the device section's second home — sealed whole.
- **Plans,** sealed under the key in hand, naming its fingerprint and the device section's act sequence.
- **The seal:** `HMAC-SHA256(HKDF-SHA256(ikm: L, salt: libraryID, info: "variorum.seal.v1:" + purpose), canonical
  JSON)`.
- **The item and Apple-key names**, with the store-variant scope in every name.

**Tests (pure):**

- round-trips for each value;
- every wrap opens with the right secret and refuses a wrong one;
- the history survives three re-keys, with every old key still reachable from the newest and never the reverse;
- **the crossings:** entering Castle takes everything; leaving Castle takes nothing, and the anchor opens with the
  passphrase and with the words; Castle → Standard → Castle folds the anchor back; a landing starts empty; within a
  mode the history grows; an unopenable anchor is kept and doesn't fail the entry;
- **the anchor keeps the secrets of its day:** no door re-locks it after it's written; every re-key carries it
  unchanged; a follower's anchor opens with the secret typed at its follow and with exactly what opened that device
  (the secret it held its key under, or the words through the master copy); with the vault's master unchanged since
  Castle, the master's road is left out; and no value ever holds a master under the passphrase;
- **the family tree:** every key a re-key or a landing mints is recorded with its kind and its Mac; its two homes
  union; it can be seeded with fingerprints a key file names but the fold couldn't reach;
- **this Mac's facts in two homes:** the newer version wins, the retired ids are the union, a library file or a memory
  item replayed — or the memory item deleted — alone changes nothing; a Mac with no memory item finds its section by
  its hardware marker — and a second macOS login on the same Mac never does: it starts its own identity (VX-340); a
  new identity on new hardware takes over every Apple key id its predecessor's section lists
  as its own, and every retired id;
- **the legacy mode reader** agrees with today's `Posture.derive` on every starting state in §6, corner 45's case
  included;
- a tampered sealed field fails verification;
- format-1 and format-2 key files read as the design says;
- no secret appears in any value written to disk (scan the encodings), and no raw hardware identifier either: the
  hardware marker is a hash of the hardware identity and the login's stable identity with the record's random salt,
  recomputed on the same hardware and login (design §3.2, VX-340). Which login identity is stable enough — one that
  survives a wiped keychain, such as the account's directory-services UUID — is U1's to choose and record.

---

## 4. U2 — assess, roads, the route finder, the catalog, retention

- **`assess(Facts) → Assessment`, pure.** It returns:
  - the mode (the current key's kind) and the account, each confirmed or not;
  - the roads;
  - every door with its reason;
  - the repairs owed and the acts owed;
  - the words, as typed reasons for later phases to render.
- **The rules it encodes:**
  - design §3.3, guards included (no repair changes a key's kind; no repair acts destructively on a Standard record's
    word alone; a lost Apple road offers Re-link's library arm);
  - §3.5 — one Apple key per library per Mac and one per account; entering Castle owing the retirement of every key
    this Mac's section lists as its own for the library; copies under a key this Mac can't delete (left in a former
    Apple ID) named at Use Castle's door; the old shared key: what still needs it, what its retirement would leave with
    no road, what would then depend on an Apple key alone, and the door-time check;
  - §3.9 — the vault's mode in three states: an Apple wrap — Standard; an id with no wrap — leaving Castle, in
    progress (a follower holds its re-key; only a device that reads the named key completes it); neither — Castle;
  - §3.7 — the open rule's verdicts: the family tree deciding "ours"; a different library landing under a fresh key
    with one secret typed and the other typed or made new, or, for a Standard pair through a readable Apple key, with
    none; a copy with no record worked out by the legacy mode reader;
  - §3.8 — the four account situations; every leave re-keying in both modes; the joining rules;
  - §3.10 — the Touch ID road, with VX-310's lobby rule as data: the button whenever a Touch ID item for the current
    key exists, what pressing it says when Touch ID is only unusable for now, the line when there's no item or no
    finger, and the "changed" line after a press fails; the re-arm question owed only after a press fails on an item
    that exists; a choice of Touch ID with no item behind it owing a quiet Always ask; a new device identity starting
    on Always ask.
- **The route finder** over a catalog, for every copy kind, with the anchor as a road and one *Opens with* line per
  copy (naming the day when an anchor or a words copy is from an earlier one; on a follower, naming the secret typed at
  its follow and what its copied locks open, the twelve words alone where none is the passphrase) — and the same
  finder with the old shared key taken away, which is how the retirement's checks list what would stop opening. It
  also gives each door that replaces a secret while an anchor exists its one sentence (design §3.9), for this
  device's anchor and its day — the reset road naming that day's words, never the forgotten passphrase.
- **The catalog's one name parser,** covering every filename today's builds have written. Read the three existing
  parsers and keep their union.
- **Attribution and retention** per design §3.7.

**Tests:** table-driven.

- every row of the four-account table;
- the vault's three states, and a follower's hold in the middle one;
- every road combination, the anchor included — a follower's anchor with each typed secret, and with stale copied
  locks;
- every copy kind against every library state — this library's own Castle-era copy after a leave reads as ours;
- retention over a shared folder holding two Macs' and two libraries' copies, where nothing foreign is pruned;
- the route finder's words agree with the roads it found, and every *Opens with* line names only roads that open;
- the retirement's list: every copy whose only road is the old shared key, every Standard library or copy with no
  passphrase or words, every account it can't check, and every other Mac's key file holding one of this library's
  keys, is on it — and nothing else is; and a vault it can read, or the library's former account, still on the old
  key — other than the act's own account — stops Use Castle at its door.

---

## 5. U3 — the executor and the acts

**The executor** runs:

- the repairs of design §3.3, each idempotent, verified before any delete — and none of them makes a Touch ID item or
  changes a key's kind;
- every act of design §3.9 as a **sealed plan**:
  - steps resume from the first unfinished one;
  - prepare-then-commit: the new key's custody item and the new key file — with the history it takes, and, leaving
    Castle, the anchor written first — exist before the library is re-encrypted, and the record is written into the
    staged file before the swap; copies pause from the prepare to the swap, and a copy's act in flight is cleared
    whenever it's opened;
  - this Mac's device section names the act in flight; a plan resumes only when it's the one named; a missing or
    unmatched plan rolls the act back before its commit point and finishes it from the record after;
- **the crossings** (design §3.4):
  - Use Castle: the old shared key's checks at the door (a vault on it stops the act), the anchor folded back, and the
    scheduled export turned off;
  - Use Standard: both secrets, the words typed and never made new; the anchor first; synced, the rotation — its
    first vault write naming the account's fresh Apple key's id with no wrap, past which a crash resumes and never
    rolls back; sync keys held by what they reach (the new keys and the previous corpus key the Castle way, on every
    device, until the previous key leaves the vault); the one completing write that adds the account's Apple wrap,
    made only by a device that reads the named key, and just the wrap when an older build has already cleared the
    previous key; and an actor lost mid-rotation, finished at a press that names the leave and waits for the named
    key, minting only if it never arrives — while a rotation with no id is completed by anyone with no Apple copy (the
    `Sync/` half is phase 3's — model it here);
  - every follow into or out of Castle typing one secret, for the new master; a follower's anchor locked under that
    typed secret and under the outgoing key with its copied locks; a follower that sees a rotation in progress — a
    previous key, or an id with no wrap — holds its re-key until the vault reads Standard or Castle;
  - every leave re-keying (Castle: both secrets; Standard: the passphrase typed or set new, the words typed or made
    new — and, in Standard, the new key under this Mac's existing own Apple key, minting nothing);
  - a different library's landing: a fresh key, an empty history, one secret with the other typed or made new — or
    none for a Standard pair through a readable Apple key — and this Mac's own Apple key in Standard; a synced pair's
    made-new secret becoming the account's at Resume Sync;
  - Send Library, with no sharing note;
  - the key doors re-wrapping the current key only, and every door that replaces a secret while an anchor exists
    carrying its sentence (design §3.9) in its plan's Done;
  - Re-link's library arm: a fresh own Apple key for every Standard key file whose own key can't be read here;
- the Apple-key rules of §3.5:
  - names by id; one per library per Mac, one per account, the vault only;
  - one minter; the vault's CAS keeps one account key; a device waits only for silent setup;
  - on entering Castle, every key this Mac's section lists as its own for the library retired and recorded, with no
    sheet; the account's once its rotation completes; a follower records the account's and its own, never the old
    shared key; a replacement Mac takes over every own id its predecessor's section lists;
  - delete on sight, by recorded id only;
  - fresh keys on leaving;
  - Re-link mints a fresh account key, never re-landing under the old shared key;
  - the old shared key: keys of their own beside it (folds first, other libraries' copies, the live library local or
    synced, the fresh pair — the move removes nothing; vaults stay on it until Castle or Re-link), and its retirement
    as Use Castle's last step — the moves again, the checks at the door, the last-step race landing with the door
    showing, no keep-for-now, the old-name item deleted only by its recorded id and recorded as retired only on the
    acting device's section — and its own door only on a library already in Castle before this change.

**Its leaves are protocols.** U3 tests against simple in-memory leaves; U4 brings the realistic fakes.

**Tests — state transitions for every act:**

- the exact writes in order;
- a crash injected after every step, then a resume that finishes or rolls back, never a third state — Use Standard
  and a follow into Standard on an Always-ask device included;
- every refusal named;
- a log scan: no log line or Diagnostics entry the executor writes carries key material, a hardware marker or the
  record's salt (design §3.2);
- decision 35's guard: nothing Apple-reachable without a fresh vault read;
- a failed seal: an unsealed or unnamed plan is ignored, and the act rolls back or finishes from the record; a memory
  item that fails its seal loses to the record's device section.

---

## 6. U4 — the scenario world

### The world

The design's §4.1, whole:

- two Macs and a phone;
- two Apple accounts and two Variorum accounts;
- the fakes, with real semantics:
  - a device keychain where Touch ID items die on an enrollment change, a closed lid is transient, a macOS update can
    move the stored state hash with nothing changed, and Keychain Access can read every item's secret except a Touch ID
    item's, and list, edit the attributes of and delete every item, Touch ID items included (the real check is phase
    3's drill);
  - an iCloud Keychain with a propagation delay, delete propagation and no recovery; a per-device off switch the app
    can't see — what a device makes while it's off stays on that device and syncs once it's turned on; and the
    same-name rule — two devices writing one name leave one survivor;
  - file systems with copies, Time Machine rollback and container deletion;
  - a vault with CAS, the key proof and the rotation fields;
- **an older build as an actor** on any device: it reads and mints only the old shared key, writes its wraps under it,
  and its Re-link re-lands the account's vault copy under it; it reads the vault's mode from the Apple wrap alone, and
  completes any rotation it finds, carrying the vault's other fields — `apple_key_id` among them — through;
- real key files and wraps, with test-speed KDF parameters (the existing test descriptors), and stand-in library
  files keyed by their key fingerprint and carrying their record.

### The alphabet

The user's acts and the adversary's acts in design §4.1, each one step — the gate-style change, the re-arm answer,
the idle lock, the scheduled export, corner 45's notice, the offer's delete, making a plaintext export, removing a
finger, a macOS update, a follow typing either secret, a landing with one secret, and Standard's passphrase reset
included.

### Starting states

Every shape today's builds leave, built as fixtures from the old formats:

- exposed;
- Standard-waiting;
- VX-202's and VX-209's victims;
- Castle with no Touch ID;
- signed out with keys;
- a deleted account;
- a stuck VX-235 marker;
- the old shared Apple key with pre-Castle copies;
- older libraries of other libraries, in Standard and in Castle, and libraries this Mac holds only backups of;
- Standard libraries with no passphrase and no words;
- a device that joined sync without typing a secret;
- 13p escrow items;
- one library on two Macs from a hand-off made before this change;
- two Macs sharing an iCloud Drive backup folder.

### The promises

The design's §4.1 list (thirteen), checked after every step — promise 2's retired-key clause, 3 and 7 once the world
settles (propagation done, followers followed).

### Fixed scenarios

Each is a named test:

- VX-209's way back (local and synced);
- W-1 / VX-263;
- VX-235's crash after the marker;
- VX-107's double crash;
- VX-109's concurrent Use Standard;
- the file swap by a login-password holder;
- the planted plan;
- the edited gate style plus an enrolled finger;
- the cross-Mac prune (VX-302);
- two macOS logins on one Mac (VX-340), on the same Apple ID and on different Apple IDs: a copy from one login opened
  in the other adopts nothing — its own identity, `<mac8>` folder, retention and Apple keys;
- the old key's fold, then retirement — no stranded copy;
- two libraries on one Apple account: a Mac entering Castle beside a second Mac's local-only Standard library with no
  passphrase — the second Mac updated, and not;
- an older library of another library, Standard with no passphrase, opening after retirement on its own key; and one
  whose library later entered Castle, whose pre-Castle copies stop opening through the Apple account;
- the window after the move: the Mac lost right after moving off the old key, its fresh pair opening elsewhere;
- an older build's Re-link landing an account's vault on the old key: nothing moves it automatically, and Use Castle
  stops at its door while a vault it can read, or the library's former account, names it; and the last-step race,
  landing with the door and the first exception showing;
- iCloud Keychain off on the Mac whose library moves: the move removes no road, and the retirement lists the library
  if it has no passphrase or words;
- one local-only library on two Macs, sent before this change, one entering Castle: the other's own key never deleted;
  and sent after: a fresh key on landing, and either Mac entering or leaving Castle changing nothing on the other;
- a silently-joined device losing its Keychain after the account entered Castle elsewhere: the words open its file;
- replays: a plan, a memory item, and a library file alone, each changing nothing; a rollback across a retirement,
  where delete on sight still fires; and both homes rolled back together — the stated limit, opening nothing written
  before it;
- an act in flight when a backup is taken: the copy carries no act, and opening it elsewhere runs nothing of it;
- Send Library after this change: a Castle pair landing with its passphrase alone and with its words alone (the other
  typed, and made new); a Standard pair through a readable Apple key with nothing typed; a new key and an empty history
  on the receiver; the receiver leaving Castle later exposing nothing of the sender's;
- leaving Castle, local and synced, with followers typing the passphrase and typing the words: the anchor written
  first; every copy from before the leave opening with the passphrase or the words and through nothing Apple-reachable;
  the Apple account opening the library and the copies made after (promise 13); a crash at every step, on Touch ID and
  on Always ask — past the rotation's first write, a resume, never a roll-back;
- a follower reaching the head first during a leave: it walks and re-encrypts but never clears the previous key while
  the vault's id stands with no wrap, and the account never reads Castle in between;
- an older build completing a leave's rotation: the vault still reads a leave in progress, followers keep holding, and
  a device that reads the named key adds the wrap;
- an acting device lost mid-way through a Castle Replace All Keys: finished by anyone, with no Apple copy, the account
  never lowered;
- a follow into Standard with the follower's iCloud Keychain off: it follows on the typed secret;
- Castle → Standard → Castle: the anchor folds back, and every older copy opens with nothing more typed;
- after a leave, a changed passphrase, new words and a reset forgotten passphrase — on this device and on another
  device of the account: copies from before the leave still opening with the leave day's passphrase or words
  everywhere, the day named, each door having said its sentence (the reset road naming the words);
- the passphrase changed during Castle on another device, which then leaves Castle: a follower that never had the new
  passphrase typed follows typing it, and its anchor opens with it;
- a Standard library that leaves its account, is backed up, then enters Castle: no copy from before the leave opens
  through anything Apple-reachable, every own key retired; and Re-link's library arm, then Use Castle: both own keys
  retired;
- a Mac that switched Apple ID, with Standard copies under its former Apple ID's key, then entering Castle: the door
  names them, and their *Opens with* line says the former account still opens them;
- an Always-ask follower relocked after the rotation, and a words-typed follower: each anchor opening with what opened
  that device; a follow after an older build's leave: the master's road left out;
- a follower meeting a rotation in progress: it holds its re-key, its rotation-window keys the Castle way, until the
  completing write; an acting device lost mid-rotation, finished by another device at a press that names the leave
  and waits for the named key;
- a Castle library joining a Standard account whose passphrase differs: the anchor keeping the secrets of its day;
- this library's own Castle-era copy restored after a leave: ours by the family tree, opening with the passphrase or
  words, taking the Standard mode, with no raise;
- one library on two Macs from before this change: the stated exception, and the sheet naming the other Mac's key
  file;
- a library leaving its account by each of the four acts, in Castle and in Standard (a forgotten passphrase set new):
  it re-keys, and nothing written after opens through the account; then the account leaving Castle elsewhere: the
  current key stays out of reach;
- This-Mac-Only Castle from an account in Standard: the account's key untouched;
- Replace All Keys on an account still on the old shared key, its follow, and a new device joining one (its key file
  under its own key);
- corner 45's ambiguous case: no custody repair until the notice is answered, and confirming Standard is a key
  change;
- a 13p escrow item: folded, then removed in Castle;
- the key file and memory item both deleted on a local-only Castle library: the lobby still opens it;
- entering Castle with the scheduled export on: it turns off here and on every device that follows, with one notice;
- the lid closed at Castle entry;
- a biometry change, then the re-arm question; and the stored hash moving with nothing changed: the button stays, a
  press opens, nothing is asked;
- both homes rolled back past a switch to Always ask, with a finger enrolled since: the restored choice says Touch ID,
  no item exists, nothing is asked, and Always ask is recorded quietly;
- a replacement Mac's first open: it starts on Always ask, and Touch ID comes on only from Settings;
- her signed-in/out/other-account sequence (the design's §3.8 walk);
- a Castle copy from another Mac into a Standard library (it raises, never lowers);
- a copy made before this change, of another library, Standard with no passphrase: it lands in Standard, never
  Castle;
- a memory item that turns up on new hardware: a new device identity, taking over its predecessor's Apple keys — a
  replacement Mac entering Castle retires its predecessor's own key;
- a living Mac cloned onto new hardware (Quick Start, Migration Assistant, or a Time Machine restore to another Mac),
  the original still in use: either entering Castle costs the other its Apple
  road, which Re-link's library arm heals, and nothing stops opening;
- a follower that only ever had the words typed — a silently-joined device that then typed the words at its follows
  among them — leaving Castle by its follow: its anchor opens with the words, and its copies' *Opens with* line says
  the twelve words, not the passphrase;
- the memory item deleted alone on an Always-ask Castle Mac with an enrolled finger: nothing changes;
- a Standard library's own Apple key lost (iCloud Keychain reset, a switch of Apple ID): Re-link's library arm, then
  promise 3 settles — local-only too;
- today's Standard-waiting and exposed libraries through the migration: the current key takes step 2's mode;
- an old build's crashed act, migrated after today's finish runner is gone: never happened, so cleared; its commit
  happened, so cleared, migrated from disk with no custody repair until the mode is confirmed; and a synced store
  whose old rotation still stands on the server, completed by the new engine with no Apple copy;
- a Time Machine rollback past a re-key: this library's later copies still read as its own;
- a synced pair landed with a passphrase made new: it becomes the account's at Resume Sync.

### Mutation pins

Each fixed scenario that guards against a known bug runs once more with its guard switched off (`ProtectionGuards`,
DEBUG only) and **must fail**. That is the red-on-old for new code. Record the failing assertion for each. The guards
include the design's — a plan the record doesn't name, the two homes of this Mac's facts, the device section's
hardware marker, no repair making a Touch ID item, gifts only for this Mac's copies, the re-key at every crossing, the
anchor written first and carried by every re-key, the family tree's own-line check and its two homes, the door-time
vault check, the export-off step, Castle-kind custody through a leave's rotation on every device, the leave's id
gating its completion, a follower's anchor locked under the secret typed at its follow, every own Apple key retired
at entering Castle, and no re-arm question without an existing item — and the old shared key's: the move keeping the
old wrap, the retirement's re-run of the moves, delete on sight by recorded id only, and the fresh pair after the
move.

### The generator

Seeded and reproducible: a failing seed prints its minimal sequence. It runs as part of `swift test`, with a count
small enough for the everyday loop, plus a `PROTECTION_SOAK=1` environment switch for the go/no-go run.

---

## 7. LIVE STATUS (flipped in the same commit as each piece; PENDING = unverified)

- U1 — the model: **DONE** (2026-10-14; the record is §8's U1 record). Pieces: (a) names · the mode · the seal —
  `246e8ecb`; (b) the record, the family tree, this Mac's facts in two homes, the hardware marker, the memory, plans —
  `add6a601`; (c) key file format 3 and its crossings, the Castle anchor — `5a31d440`; (d) the legacy readers —
  `6f848c3a`; (e) `ProtectionGuards` and the scans — `09f54557`; (f) the record — this commit. The U1 suites: 60 tests in
  18 suites green in Debug; 55 in 17 green under `-c release` (the DEBUG-only mutation suite compiled out) — run on a
  scratch copy, because the core test target does not build under `-c release` on main today (a pre-existing gap, the
  record's first line). The full core suite green in Debug.
- U2 — assess, roads, route finder, catalog, retention: **DONE** (2026-10-14; the record is §8's U2 record). Pieces:
  (a) the catalog — the one name parser and attribution — `84ed6d5f`; (b) retention per library per Mac, and U2's
  guards declared — `93d5ab48`; (c) the route finder, the *Opens with* line, the finder without the old shared key, the
  retirement's routes, the anchor sentences (with the recorded `CastleAnchor.directFingerprints` refinement) —
  `5ae90bff`; (d/e) `assess` and the open rule — WIP `570583d9`, tests `bc11f39c`, self-review `b1e07a80`, the key
  file's agreement with its mirror `5f96dc32`; (f) the guards' DEBUG mutation pins — `4e576689`; the record — this
  commit. The U1+U2 suites: 154 tests in 35 suites green in Debug; 134 in 32 green under `swift test -c release` (the
  three DEBUG-only mutation suites compiled out). The full core suite green in Debug (its first run met one
  perf-timing issue under load, green alone and on the re-run — the record's first line).
- U3 — the executor and the acts: **DONE** (2026-10-14; the record is §8's U3 record). Pieces: (a) the leaves, the
  vault model (the `Sync/` half modelled, zero `Sync/` lines), the core, the repairs, the in-memory world — WIP
  `9f694b5c`, its tests `53e94d82`; (b) the crossings — `8b3b1e39`; (c) the account acts — `843ef37c`; (d) copies —
  `469044e6`; (e) the remaining acts (key doors, settings, re-arm, confirm, create, Re-link, the old shared key, the
  migration) — `9217cfb8`; (f) the guards and their mutation pins, the log scan — `ca09dc95`, the self-review's four
  gaps — `5fbe5cb5`; the record — this commit. The protection suites (U1+U2+U3): 268 tests in 55 suites green in Debug;
  228 in 51 green under `swift test -c release` (the four DEBUG-only mutation suites compiled out). The full core suite
  green in Debug (3128 / 385, 240 / 51, 40 / 6). Not done (the record's first line): the empty-slot landing → phase 5.
- U4 — the scenario world, fixed scenarios, mutation pins, the generator: **DONE** (2026-10-15; the record is §8's U4
  record). The U4 session (partial, to `e281b846`): (a) the world; (b) today's stores + the older build; (c) the
  alphabet + the promises; (d) every sentence of §6 a named test; (e) the 21 mutation pins; (f) the generator +
  `PROTECTION_SOAK=1`. The closer (from `03d8e3e4`): (h) her ruling 2, the marker split `f87db7c6`; (i) her ruling 1,
  the stuck leave + promise 6's vault-reach qualifier `1cf72df9`; her 2026-10-15 widening applied `41c9d63f`; (j) the
  soak — 15 code bugs and 17 checker/world findings triaged and committed one by one, P-U4-12…15, the seed-9 model gap
  ratified to phase 5/VX-309; THE FINAL TREE `6128c8de`: seeds 1–20 × 1000 × ≤ 60 green in Debug (898,884 steps,
  7,067.4 s) and under `-c release` (898,884 steps, 4,528.9 s); (k) the runs — the protection set 413 tests in 65
  suites green in Debug, 352 in 60 under `-c release`, the full core suite green in Debug (3273/395 · 240/51 · 40/6);
  (l) the record — this commit.
- The ladder (§9; up to five rounds while MAJORs are found, her word): round 1 **DONE** (1 MAJOR · 1 MINOR · 4 NIT,
  all six fixed and verified, Debug 429/69 · Release 368/64); the triage of the two pre-existing generator finds
  **DONE** (NEW-2 a checker bug, NEW-1 a model bug under P-U4-6 (a); verified Debug 432/70 · Release 371/65); round 2
  **IN FLIGHT**.
- The go/no-go record: **NOT-STARTED.**

---

## 8. Records (each unit appends its record here: what shipped, tests and counts, PROVISIONAL calls, commits, machinery notes)

### U1 RECORD — the model (Opus implementer, 2026-10-14; one session, no deaths)

**Not done, first:** the core test target (`VariorumCoreTests`) does not build under `swift test -c release` on main
today — `MarkdownSyntaxTests.swift` (lines 299–306), `MarkdownEditingTests.swift` (361–363) and
`MarkdownCaretRescueTests.swift` (195–197) use the DEBUG-only `MarkdownScanCount` unguarded. Pre-existing, outside U1's
surface, so not fixed here: U1's release run was made on a scratch copy of the package with those three files removed
(the repo untouched). §1 item 1 (both configurations) needs it fixed before the GO — **owner: the orchestrator** (a
VX ticket, or the U4 session). Also not done: the QUESTIONS entries for the PROVISIONAL calls below — CLAUDE.md keeps
`notes/QUESTIONS.md` to merge moments on latest main, so they wait for the closeout (§11 already lists them).

**What shipped** — `Sources/VariorumCore/Protection/` (pure values; nothing reads a Keychain, a file or the network):
- `ProtectionGuards.swift` — the one guards value; U1's five guards (two homes · hardware marker · the tree's two homes
  · the anchor carried by every re-key · the anchor written first), off-switches `#if DEBUG` only, `…On` a constant
  `true` in Release. U3/U4 add theirs to the same value.
- `Model/ProtectionVocabulary.swift` — `ProtectionMode` (a key's kind for life = the library's mode), `ProtectionAct`
  (the §2 act list, stored raw values), `GateStyle`.
- `Model/Names.swift` — every new item and file name with the scope in every item name: custody
  `<scope>-<fp16>-<silent|touchid>` (service `…library-key`), sync keys `<scope>-<accountID>-<class>` (`…sync-keys`),
  memory `<scope>-<libraryID>` (`…memory`), Apple keys `<scope>-apple-key-<id>` beside the old shared
  `<scope>-apple-key` (today's `…apple-key` service), `variorum-library-keys.json`, `variorum-plan.json`,
  `Backups/<library8>/<mac8>`. STRICT parsers (exact `<scope>-` prefix and a well-formed tail), so `Variorum` never
  parses a `Variorum-dev` item.
- `Model/Seal.swift` — `HMAC-SHA256(HKDF-SHA256(ikm: L, salt: libraryID, info: "variorum.seal.v1:"+purpose),
  canonical JSON)`, naming the sealing key's fingerprint; `Sealed<T>` keeps and verifies the STORED canonical bytes
  (never re-encodes), opens through a `reach` (the history) when the act has re-keyed. Purposes `memory`, `plan`,
  `device-section`.
- `Model/HardwareMarker.swift` — `HMAC-SHA256(key: the record's 32-byte salt, "variorum.hardware-marker.v1" ‖
  len‖hardware ‖ len‖login)`; `MachineIdentity` is never `Codable` and prints redacted.
- `Model/FamilyTree.swift` — entries (fingerprint, kind for life, Mac, made, retired, reached), a normal form,
  birth/retire/seed (unknown kind ⇒ Castle), the union (commutative · associative · idempotent), `atOpen` (two homes).
- `Model/DeviceSection.swift` — the section (identity, marker, act in flight with a never-reused sequence, settings,
  Apple key records with purpose/origin/retirement, the old shared key's id and retirement, a version that only
  grows) and `DeviceFacts`: `reconcile` (newer wins, retired ids and the old shared key's retirement the union),
  `resolveIdentity` (continuing · found by marker · new identity with or without a predecessor), `takingOver` (a
  replacement Mac: the key file's own wrap ids, the predecessor's own library ids, every retired id of any section;
  Always ask), `thisMacsSection` (composed).
- `Model/ProtectionRecord.swift` — the library's facts, the marker salt, one SEALED section per device;
  `recordingRekey` (old retired, new born with kind and Mac, epoch +1, mode = the new key's kind, confirmed),
  `verifiedSections`, `storing`, `clearingActsInFlight` (a copy opened: acts cleared, re-sealed, unverifiable
  sections dropped).
- `Model/DeviceMemory.swift` — what this Mac remembers (scope, fingerprint, epoch, last confirmed mode+account, the
  biometry hash as a hint, the vault facts, nudge dismissals, the key-file mirror, the tree mirror, the section's
  second home), sealed whole; a memory failing its seal or naming another library opens as nil (it loses).
- `Model/Plan.swift` — the plan (device, sequence, act, keys, steps), sealed, `resumable` → `.unsealed` /
  `.notNamed` / the plan.
- `Model/Secrets.swift` — `PassphraseKey` (descriptor kept), `WordsKey`, `AppleKeyMaterial`, `ProtectionSecret` (the
  floor checked before any derivation), and the one RFC 3394 lock primitive.
- `Model/KeyFile.swift` — format 3: the wraps (P with descriptor, W, M with the master's words copy beside it, this
  Mac's own Apple wrap, the old shared wrap riding beside), the history (each older key directly under the current,
  verified by fingerprint), the anchor and the kept anchors, `roads`, `heldFingerprints`; the key doors re-wrap the
  current key only.
- `Model/CastleAnchor.swift` — the anchor: the outgoing key, its whole history and its kept anchors in one
  AES-256-GCM bundle (AAD binds the outgoing fingerprint) under a fresh anchor key; birth-time locks only —
  `.pressingDevice` (P and W) or `.follower` (the typed secret, plus the outgoing key with its copied locks; the
  master's road left out on request); `open` by every road; `roads` for the words. No API re-locks it.
- `Model/KeyFileCrossings.swift` — `rekeyed(.withinMode / .enteringCastle(openers:) / .leavingCastle)` and
  `building` (creation, landing), `writingAnchor` (first), per design §3.4; entering Castle refuses an Apple lock; a
  re-key drops the old shared wrap.
- `Model/LegacyReaders.swift` — `KeyFileDocument` (format 3 vs 1/2, newer refused), `LegacyKeyFile` (format 2's
  Apple wrap read as the OLD SHARED key's; attribution: an Apple wrap ⇒ Standard, none ⇒ Castle), `LegacyModeReader`
  (today's `Posture.derive`, its inputs exactly, `isCorner45Ambiguous`, `migrationRecord` = §3.13 step 2),
  `LegacyItems` (today's per-library-ID, escrow, sync-custody and old-shared-key names, cited per name, and their
  values: the raw key, `{deviceID, material}` and the 14b bare blob, `{id, key}`), `LegacyRotationMarker` (today's
  JSON, the undecodable-reads-`.vaultWrite` rule, `read(db)`, the clearing check `resolve(evidence)`).

**Tests** — `Tests/VariorumCoreTests/Protection/` (the §2 `ModelTests` split by subject for size, a recorded
refinement): `ProtectionFixtures`, `NamesAndSealTests` (9), `RecordModelTests` (18), `KeyFileTests` (17),
`LegacyReadersTests` (9), `ProtectionScanTests` (1), `ProtectionGuardTests` (6: 1 + the DEBUG-only 5). Every bullet of
§3's test list has its test (the mapping is the suite and test names, which read as the plan's sentences).
- Debug, U1 filtered: `✔ Test run with 60 tests in 18 suites passed after 0.034 seconds.`
- Release (`swift test -c release --filter …`, on the scratch copy described above): `✔ Test run with 55 tests in 17
  suites passed after 0.027 seconds.` (the DEBUG-only mutation suite is compiled out — 60 − 5, 18 − 1). Wall time
  6:50, the release build included.
- Full core suite, Debug (`swift test`, 4:57 wall): `✔ Test run with 2920 tests in 348 suites passed after 221.140
  seconds.` · `✔ Test run with 240 tests in 51 suites passed after 22.793 seconds.` · `✔ Test run with 40 tests in 6
  suites passed after 51.802 seconds.` (skips: the existing gated suites only).
- The guards are live: each of the five, switched off, lets its bug through (`ProtectionGuardMutationTests`).

**PROVISIONAL calls (for QUESTIONS at the closeout — CLAUDE.md's merge-moment rule):**
- **P-U1-1 — which login identity the marker covers (VX-340's open half, U1's to choose).** Chosen: (a) the login's
  directory-services UUID, `GeneratedUID` — the user record's own identity (Apple keys APFS volume ownership and
  FileVault's crypto users on it), outside the keychain and the password, minted fresh for a re-created account (the
  safe side: a new device). Set aside: (b) the numeric UID — Apple documents it as not unique, and a re-created
  account commonly re-uses it (502), which would adopt the deleted login's section; (c) the short name or home path —
  both renameable. Measured 2026-10-14 on the Pro (macOS 27.0, an unsandboxed CLI): OpenDirectory's
  `kODAttributeTypeGUID` and Collaboration's `CBUserIdentity(posixUID:authority:.local()).uniqueIdentifier` both
  return `dscl`'s `GeneratedUID` (`mbr_uid_to_uuid` is not exposed to Swift). The hardware identity is the hardware
  UUID (`IOPlatformUUID`). The one Sonnet lookup found Apple documents neither identifier's lifecycle directly, nor
  their availability under the App Sandbox (IOKit is public API per DTS; OpenDirectory/Collaboration unknown) —
  **hand-forward to phase 2's leaf:** read both in a SANDBOXED Debug build, and check GeneratedUID across a password
  reset, a keychain reset and an OS update. The phone (one login) needs its own leaf choice there too
  (`identifierForVendor` changes on reinstall).
- **P-U1-2 — identity resolution's order when a memory item from other hardware sits beside this Mac's own marked
  section.** Chosen: (a) the section wins (`foundByMarker`) — the marker is the evidence of who this Mac is (§3.6 "a
  Mac finds its own section by its hardware"). Other: (b) the literal §3.13 reading — always a new identity naming
  the memory's identity as predecessor. A rare edge (Migration Assistant into an account that had opened the library).
- **P-U1-3 — two homes disagreeing on a key's kind.** Chosen: (a) Castle wins — the safe side the migration's
  unknown-kind rule already takes. Other: (b) a kind recorded at birth beats an inferred one (needs a provenance
  field).
- **P-U1-4 — two homes of this Mac's facts at EQUAL versions.** Chosen: the record's (inside the encrypted library),
  with the retired ids still unioned. Others: the memory's; or flag the fault. Only a fault can produce it.
- **P-U1-5 — the clearing check on a fingerprint-less old marker** (`vaultWrite` / `reencrypt` / a 14c value).
  Chosen: (a) never happened, library-wise — no new library key was ever minted, so the library opens under its old
  key and no new key exists by construction; the account side is the vault's (step 1's bullets). Other: (b) commit
  happened at `reencrypt` (the account's commit point passed). Moot for the mode: such markers are written only on
  synced roads, where step 2 takes the vault's word or records "not yet confirmed" either way.
- **P-U1-6 — corner 45's ambiguous case, exactly.** Chosen: local-only, no stored 13p mode, a passphrase wrap, no
  Apple wrap, the raw key in the SILENT item (the proposal's own words; VX-202's victims read the same). `.unknown`
  custody reads today's Castle and is not flagged. Other: flag `.unknown` too.
- **P-U1-7 — a brand-new identity with no predecessor** (a copy opened by another login, a library landing) starts
  with NO gate choice (`noChoiceYet`), its act's own press deciding (§3.10, "a device with no choice yet — a landed
  library"); only a replacement Mac's takeover starts on Always ask. Other: Always ask for every new identity.
- **P-U1-8 — formats** (not product behaviour, recorded): each device section sealed separately inside the record
  (the "two sealed homes" read literally, beside SQLCipher's own page authentication); the anchor bundle AES-256-GCM
  with its held fingerprints in the clear (fingerprints are not secret; the catalog needs them unopened).

**Commits:** `c86586ca` (LIVE STATUS opened) · `246e8ecb` (a) · `add6a601` (b) · `5a31d440` (c) · `6f848c3a` (d) ·
`09f54557` (e) · the record's own commit (f). Each pushed to `origin/vx-305-castle-core` as it landed.

**Machinery notes:**
- `PassphraseKDF.floor` is the PRODUCTION floor under `-c release` (the test-host relaxation is `#if DEBUG`), so every
  U1 passphrase road takes a `floor:` and the tests pass `.relaxedForTests` explicitly — U3/U4's world must do the same.
- `swift build -c release --build-tests` fails ("unable to resolve Swift module dependency") — testability isn't on;
  `swift test -c release` is the road.
- Hand-forwards: phase 2 — an app-target test running `LegacyModeReader` against the REAL `Posture.derive` over the
  same exhaustive space (U1 checks a verbatim transcription; the app can't be imported in core); the two leaves of
  P-U1-1. U2/U3 — the `ProtectionGuards` value is theirs to extend; `DeviceFacts.thisMacsSection` and
  `FamilyTree.atOpen` are the open's two meeting points; `CopiedLocks.copying(includeMasterRoad:)` is the executor's
  to decide from the vault.
- The one Sonnet lookup (external facts only, read-only) ran in the background while code was written.

### ORCHESTRATOR NOTE after U1 (2026-10-14)

- **U1 verified, not trusted:** the 18 U1 suites re-run by the orchestrator — `✔ Test run with 60 tests in 18 suites
  passed` — and the commits, status flips and record spot-checked. The release-gap claim re-verified mechanically
  (unguarded references to a `#if DEBUG`-only symbol).
- **The release-build gap is FIXED — VX-345** (minted, triaged Bug · Confirmed · Pre-launch · High; the orchestrator's
  own small fix, commit `f880263e`): the three Markdown P1-counter tests wrapped whole in `#if DEBUG`. Proof:
  `swift test -c release --filter "KeyFileWrapTests|CastleAnchorTests|MarkdownSyntaxTests"` on THIS tree —
  `✔ Test run with 29 tests in 3 suites passed`. §1 item 1's both-configurations road is open; the ticket closes with
  the run's PR. The U1 record's "owner: the orchestrator" line is resolved here.
- P-U1-1's phase-2 leaves (the sandboxed reads, the GeneratedUID lifecycle checks) ride §11's closeout into the
  vx-306 plan.
- **P-U1-1 CONFIRMED by her (2026-10-14, same day, to the orchestrator):** *"I think that seems fine to me on the
  generatedUID, unless you have any particular concerns about it."* The orchestrator's answer: none beyond the two
  checks already owed to phase 2's leaf — the choice stands, the checks stay owed. (Also on VX-340 as a comment.)

### U2 RECORD — assess, roads, the route finder, the catalog, retention (Opus implementer, 2026-10-14; one session, no deaths)

**Not done, first:** (1) nothing of the unit — but the full core suite's FIRST Debug run met one issue outside U2's
surface: `PerfBenchmarkTests`' `timelinePageIsFlatOrUnderBudgetInCorpusSize` (a P1 timing bound on the timeline query)
under a load average of ~16–20 from other sessions on the Pro; alone it passed twice, and the full suite's re-run, with
the load down, was green (the counts below). (2) The QUESTIONS entries for the PROVISIONAL calls below wait for the closeout, as U1's did (CLAUDE.md
keeps `notes/QUESTIONS.md` to merge moments on latest main; §11 lists them). (3) The file swap by a login-password
holder — a memory item sealed under a key the open can't reach, beside an older library file — is not modelled by
`assess` (it reads only VERIFIED homes); hand-forward to U3/U4 (its fixed scenario).

**What shipped** — `Sources/VariorumCore/Protection/Assess/` (pure: plain values in, plain values out; nothing reads
a Keychain, a file or the network, and nothing calls a writing leaf):
- `CatalogNames.swift` — THE ONE NAME PARSER: the union of today's three — the backup-name parser
  (`StoreBackup.date(fromBackupURL:)`, restated in core as `BackupRestoreCandidates.backupDate`: the stamp exact, the
  tail empty or `-` + eight lowercase hex — and only those, 18k C7), the pair rules (`LibraryClassifier`'s
  `<snapshot>.keys.json`, `StoreKeyEnvelope`'s `variorum-keys-<fp16>.json` / `variorum-keys.json`, both set-aside
  writers' `.stale-<epoch>.json`) and the stamp-folder qualifier (`LibraryAdoption.adoptionStamp` /
  `LibraryAsideCopies`: `Previous Libraries/<stamp>/`, `variorum-adopt-safety-<stamp>/`) — plus the slot's
  `variorum.sqlite` and sidecars, `RESTORE.md`, `md-exports/`, the hand-off folder and this build's own names. The
  classifier's looser `isBackupNamed` is a routing hint for a PICKED file, never an acceptance of the name as the app's.
- `Catalog.swift` — the listing (two roots: the container's store folder, the far folder's `Variorum/`; key files'
  bytes and dates) → copies (backup · legacy flat · previous library · adoption safety copy) and key files (live ·
  beside the library · set aside · snapshot pair · folder file · this Mac's own key file for a library · aside copy),
  each copy attributed to its LIBRARY from its serving key file and its MAC from its `Backups/<library8>/<mac8>/`
  subfolder (a container copy outside one is this Mac's by place; a far folder's is unattributed); today's pair rules
  restated for the serving key file; names no build writes listed as foreign, never touched.
- `Retention.swift` — per library per Mac (VX-302): only this Mac's copies of this library, the container's newest 14,
  the far folder's 14 dailies + 4 weeklies (today's `BackupRetention.keep` restated); legacy flat files listed, never
  pruned.
- `RouteFinder.swift` — every road to a key (custody, every catalogued key file's locks, the history, every anchor a
  catalogued file carries — a follower's copied locks and outgoing-key lock included — Apple wraps readable here, the
  current master proven by §3.5a's words copy), each named opener with a WITNESS road of exact locks; the *Opens with*
  line as typed reasons naming a secret by its provable day (`SecretDay`: `.current`, `.of(day)` — an anchor's own
  lock, typed and verified at its act — and `.heldHere(until:)` — a frozen file's or a copied lock: what this Mac held
  then); an unpinned copy names only what opens every candidate; `withoutOldSharedKey()`; the retirement's route-based
  half (`retirementRoutes`: still needs it · would stop opening · an Apple key alone · other Macs' key files); the
  anchor sentence of every door that replaces a secret.
- `Facts.swift`, `Assessment.swift`, `Assess.swift` — `assess(_:guards:)`: the launch verdict; the mode confirmed or
  not (the record; the legacy reader for a library with no record; a hint only before unlock); §3.8's four situations;
  §3.9's vault in three states (the leave's id gating its completion, Castle-kind sync keys through the window, the
  unfinished leave's finish door, a follower's hold); §3.10's Touch ID road as data (the button whenever an item for the
  current key exists and a finger is enrolled; the press saying why; the quiet line; the changed line after a failed
  press; the re-arm question only after a press failed on an item that exists; a Touch ID choice with no item recording
  Always ask quietly); §3.3's repairs with their guards and preconditions (verified before any delete), faults, acts
  owed (the migration, the follow, confirming the mode — a key change when the current key wasn't born in it — corner
  45's notice, the fault's re-key, Re-link's library arm, the old shared key's one ask, the re-arm question); every door
  with its reason or its spec (what it asks for, whether it re-keys, which own Apple keys it retires, its words); the old
  shared key's checks at the door and the move's subjects.
- `OpenRule.swift` — §3.7's verdicts: ours by the family tree (never the history) taking the library's current mode
  (never lowered) and key, flagged when foreign; a Castle copy not in the tree raising a Standard library; a different
  library landing under a fresh key with one secret then the other (none through a readable Apple key); a copy with no
  record read by today's rule; plaintext exports; every copy's act in flight cleared.
- `ProtectionGuards.swift` — U2's fifteen guards (off-switches `#if DEBUG` only): `pruneOwnCopiesOnly`,
  `noRepairMakesTouchID`, `noRearmWithoutItem`, `ownLineByFamilyTree`, `neverLowerOnOpen`, `doorTimeVaultCheck`,
  `deleteOnSightByIDOnly`, `everyOwnKeyRetiredAtCastle`, `leaveIDGatesCompletion`, `castleKindCustodyThroughLeave`,
  `giftsOnlyForThisMacsCopies`, `unconfirmedModeNoCustodyRepair`, `standardRecordNoDestructiveRepair`,
  `freshVaultBeforeAppleWrite`, `rekeyAtEveryCrossing`.
- **A recorded model refinement (U1's value, additive):** `CastleAnchor.directFingerprints` — the keys opening THIS
  anchor yields directly (the outgoing key and its history). A kept anchor sealed inside a later one still needs its own
  day's secrets, so the route finder must not name the outer anchor's locks for keys only the inner holds (promise 9);
  `heldFingerprints` keeps its meaning. No anchor exists on disk yet, so the field is non-optional. The catalog's key
  files carry `frozenAt` (an aside folder's stamp included) and the listing's `modifiedAt` (today's newest-modified rule).
- **Shape refinements, recorded:** §2's `Roads` lives in `RouteFinder.swift` (`Route`, `RouteStep`, `Opener`) and
  `Assessment.swift` (`LobbyRoads`); the open rule is its own file; the catalog's parser is its own file.

**Tests** — `Tests/VariorumCoreTests/Protection/`: `CatalogTests` (`CatalogNameTests` 3, `CatalogAttributionTests` 4),
`RetentionTests` (5 + `RetentionGuardMutationTests` 1, DEBUG), `RouteFinderTests` (`RouteFinderRoadTests` 8,
`AnchorSentenceTests` 3, `RetirementRoutesTests` 1 — with `walk`, which opens every named opener's witness road with
the real secret of its day), `AssessTests` (`AssessAccountTests` 6, `AssessVaultTests` 8, `AssessModeTests` 7,
`AssessTouchIDTests` 6, `AssessRepairTests` 13, `AssessDoorTests` 5, `AssessOldSharedKeyTests` 3), `OpenRuleTests` 6,
`AssessGuardTests` (`AssessGuardsOnTests` 1, `AssessGuardMutationTests` 14, DEBUG), `AssessFixtures` (`AWorld`). Every
bullet of §4's test list has its test (the suite and test names read as the plan's sentences).
- Debug, U1+U2 filtered (the 35 protection suites): `✔ Test run with 154 tests in 35 suites passed after 0.227 seconds.`
  (U2: 94 tests in 17 suites.)
- Release (`swift test -c release --filter …`, on THIS tree — VX-345 holds): `✔ Test run with 134 tests in 32 suites
  passed after 0.135 seconds.` (the three DEBUG-only mutation suites compiled out: 154 − 20, 35 − 3). Wall 515 s, the
  release build included.
- Full core suite, Debug (`swift test`, the re-run, 266 s wall): `✔ Test run with 3014 tests in 365 suites passed
  after 196.513 seconds.` · `✔ Test run with 240 tests in 51 suites passed after 22.459 seconds.` · `✔ Test run with 40
  tests in 6 suites passed after 44.775 seconds.` (The first run, under load: `✘ Test run with 3014 tests in 365 suites
  failed after 192.845 seconds with 1 issue.` — the perf bound above.)
- The guards are live: each of U2's fifteen, switched off, lets its bug through (`AssessGuardMutationTests`,
  `RetentionGuardMutationTests`).

**PROVISIONAL calls (for QUESTIONS at the closeout):**
- **P-U2-1 — a Touch ID item while the library is in Standard.** Chosen: (a) reported (`Fault.touchIDItemInStandard`),
  never deleted by a repair — §3.3's "no repair deletes anything … on a Standard record's word alone" outranks the
  Standard list's "No Touch ID item for a Standard key"; it goes at the next act a person presses. Others: (b) delete it
  when corroborated beyond the record (its key a Standard key in the memory's sealed tree too); (c) delete it as a
  repair (the literal list — unsafe under a file swap).
- **P-U2-2 — a silent sync-keys item for the library's account while its keys reach a Castle-era key.** Chosen: (a)
  reported (`Fault.silentSyncKeysWhileCastleWay`); the acts re-file sync keys (phase 3). Others: (b) a Castle repair
  deleting it once the Castle-way item or the session holds the keys; (c) read §3.3's "no silent item for any key the
  library has had" as covering sync keys.
- **P-U2-3 — "here" in the retirement sheet's second item.** Chosen: (a) copies attributed to this Mac (its container,
  its `<mac8>` subfolders) and a far folder's unattributed legacy copy, which the catalog can't say is another Mac's;
  another Mac's attributed copies never. Others: (b) this Mac's attributed copies only; (c) every copy in the catalog.
- **P-U2-4 — the door stop while signed out.** Chosen: (a) the record's account stops Use Castle only when this device
  last KNEW its vault on the old key (an account-purpose Apple key record in its section with the old key's id); unknown
  ⇒ listed as an account it can't check, not a stop. Others: (b) unknown stops too (blocks every signed-out Use Castle on
  a once-synced library); (c) never stop while signed out (list only).
- **P-U2-5 — a frozen key file's lock names "what this Mac held then".** Chosen: (a) a backup pair's or an aside copy's
  passphrase or words lock reads `.heldHere(until: day)`; `.of(day)` ("you had on 12 October") is earned only by an
  anchor's own locks, typed and verified at the act; `.current` only when provable. Others: (b) name every frozen lock
  by its day (untrue on a device whose passphrase changed elsewhere — §8's residue); (c) name no days.
- **P-U2-6 — "the secret you're replacing" in the anchor sentences.** Chosen: (a) provable only for the passphrase (the
  anchor's lock under the live file's descriptor) — `AnchorSentence.replacedSecretOpensIt` true or nil — and where it
  isn't provable the sentence names the day's secret ("the words you had on 12 October", always true). Others: (b) say
  "you're replacing" always (untrue after a second words change); (c) add a words-era marker to key files (a format
  change).
- **P-U2-7 — the key file and its sealed mirror agree, never by shrinking.** Chosen: (a) a missing live key file, or one
  that lost a passphrase, words or master lock, a history entry or the anchor, is written back from the mirror; the
  mirror follows a file a key door changed; an Apple wrap is never re-added by a repair (they leave legitimately).
  Others: (b) the mirror always wins (undoes an interrupted key door's write the wrong way); (c) the file always wins (a
  deleted wrap loses roads for good).
- **P-U2-8 — Re-link's account door is offered** when the account's vault key isn't readable here OR the vault is still
  on the old shared key (§3.5 point 4 names Re-link as that account's way through). Other: (b) only when unreadable.

**Commits:** `bbd3f406` (LIVE STATUS opened) · `84ed6d5f` (a) · `93d5ab48` (b) · `5ae90bff` (c) · `570583d9` (d/e WIP) ·
`bc11f39c` (d/e tests) · `b1e07a80` (self-review) · `4e576689` (f) · `5f96dc32` (the mirror) · the record's own commit.
Each pushed to `origin/vx-305-castle-core` as it landed.

**Machinery notes:**
- "The three existing parsers" read as: the backup-name parser (`StoreBackup.date(fromBackupURL:)` and its core
  restatement `BackupRestoreCandidates.backupDate`), `LibraryClassifier`'s pair rules with `StoreKeyEnvelope`'s
  key-file names, and `LibraryAdoption.adoptionStamp` / `LibraryAsideCopies`. `CatalogNameTests` pins agreement with
  each on a corpus of the app's names and adversarial ones.
- A lock-time copy and a backup share today's name: the catalog lists a lock-time copy as a legacy flat snapshot; the
  open rule clears every copy's act in flight, so the difference changes nothing here (phase 5 names it from the file's
  own key).
- `assess` reads only VERIFIED homes: the leaf verifies the record's device section, the memory and the plan with the
  key in hand and passes values; a home that failed its seal arrives as nil.
- The route finder never opens anything; `walk` (RouteFinderTests) opens each witness road with real secrets — U4's
  promise-9 checker can reuse it. Swift Testing's `#require` can't nest (a recursive-expansion error), hence its `need`.
- Hand-forwards: **U3** — every `Repair`'s precondition is the executor's to VERIFY before a delete;
  `restoreKeyFileFromMirror`; `OwedAct.migrate`; the `DoorSpec` fields (requirements, re-keys, the own Apple keys to
  retire, the old shared key's retirement, Replace All Keys' re-link first); the move's subjects (`MovePlan`);
  `AssessRules.retireOldSharedKeyNudge`; and the invariant the route finder's `.current` passphrase reading rests on —
  a NEW passphrase always gets a fresh KDF descriptor (`PassphraseKey.derive`'s default), while a re-key and an anchor
  reuse the door's derived `PassphraseKey`. **U4** — `AWorld` and `walk`; the file-swap scenario (above).
- The one Sonnet lookup was not used.

### ORCHESTRATOR NOTE after U2 (2026-10-14)

- **U2 verified, not trusted:** the full U1+U2 suite set re-run by the orchestrator — `✔ Test run with 154 tests in
  35 suites passed` (the exact claimed count) — the worktree clean and level with origin, §7's flips in place.
- **The one U1-model change reviewed and accepted:** `CastleAnchor.directFingerprints` — a kept anchor sealed inside
  a later one still needs its own day's secrets, so the outer anchor's locks are never named as roads to the inner
  anchor's keys. Additive, promise 9's honesty, recorded with its reason; no anchor exists on disk yet.
- The perf-timing flake (`timelinePageIsFlatOrUnderBudgetInCorpusSize` under a ~16–20 load from other sessions) is
  the known machine-load class, outside U2's surface; it passed alone twice and in the full re-run. No action.
- U3's hand-forwards (the repair preconditions, `restoreKeyFileFromMirror`, `OwedAct.migrate`, `DoorSpec`,
  `MovePlan`, the fresh-KDF-descriptor invariant) and U4's (the file-swap fixed scenario, `AWorld`/`walk`) are in
  the U2 record above.

### U3 RECORD — the executor and the acts (Opus implementer, 2026-10-14; one session, no deaths)

**Not done, first:** (1) **a landing into an EMPTY slot** (a fresh Mac receiving Send Library with no library of its
own) — `land` takes the slot's unlocked library (it goes aside, the landing named in both); the empty-slot road (no
outgoing library to name the act in — `createLibrary`'s no-plan pattern) is **hand-forwarded to phase 5** (Open
Library), U4 building its receivers with a library of their own. (2) The `Sync/` half is MODELLED, not built
(`Executor/VaultModel.swift` + the `VaultLeaf`; zero `Sync/` lines) — phase 3's, Fable's. (3) Two account acts carry
their protection half only: *delete the account from this Mac* (the server's deletion is the account lifecycle's —
phase 4) and Move (its re-stamp and resync — phase 4). (4) The QUESTIONS entries for the PROVISIONAL calls below wait
for the closeout, as U1's and U2's do (CLAUDE.md's merge-moment rule; §11 lists them).

**What shipped** — `Sources/VariorumCore/Protection/Executor/` (the ONLY code that calls a writing leaf):
- `Leaves.swift` — the leaves as protocols (custody, today's items, sync keys with session memory, Apple keys by id
  plus the old shared key's compare-then-delete, the vault, the library file with its staged file and swap, key files,
  the memory, the plan, backups with the copy pause, clock, IDs — every random thing one seedable leaf, the fresh KDF
  descriptor included — biometry, Diagnostics as a TYPED entry so none can carry a secret); `ExecutorLeaves`.
- `VaultModel.swift` — the vault MODELLED from the real `KeyVaultFormat` (Crypto/): a vault's creation, a rotation's
  first write (M′ under P on the door's descriptor and W, the previous corpus key under M′, the Apple copy kept under
  the SAME account key — decision 30 — or none, or a leave's fresh id with NO wrap), the completing write (the wrap under
  the NAMED key with the window closed — just the wrap when an older build cleared it), the follower's read, the
  master by a typed secret; `VaultSnapshot` reads as U2's `VaultReading` (§3.9's three states); `VaultRefusal`.
- `Executor.swift` — `ProtectionExecutor`: the configuration (scope, the slot's library, the machine — hashed, never
  stored — device name, floor, session); `unlock(with:alsoInHand:)` — every home verified with the key in hand and every
  key the lobby's road reached (so a library file swapped for an older one loses to the newer memory — U2's file-swap
  hand-forward, the executor's share), this Mac's section resolved by U1's `thisMacsSection`, the executor following the
  slot's library id; this Mac's facts written into BOTH homes; the vault read fresh this session (decision 35's
  freshness, an absent vault counting as a read — sync setup's); `ExecutorRefusal` (every refusal named).
- `PlanRunner.swift` — `ActProgram` (steps per parameters, the new-key steps, the plan-less finishing steps) and the
  runner: BEGIN (the act named in both homes FIRST, then the plan sealed under the key in hand), idempotent steps each
  re-sealing the plan, END (cleared in both homes, the plan deleted, copies resumed); `settle` at open — a plan the
  section names resumes (the secrets a resume needs re-typed: a plan never holds one); a planted, replayed, unnamed or
  stray plan ignored and REPORTED; no usable plan → ROLL BACK before the commit point (the staged file discarded, the live
  key file restored from the sealed mirror, the new key's items deleted, an own Apple key the act minted that wraps
  nothing retired) or FINISH FROM THE RECORD after it; a new key never made durable re-minted; a step's `ActRollback`
  rolling back on the spot (the account moved before this device's first write; the losing device's unlanded account
  key deleted and recorded retired); an act that ended between its two homes' writes leaves the memory following the
  newer home.
- `ExecutorRepairs.swift` — §3.3's repairs, each precondition VERIFIED by the executor before any delete (the history
  opened with the current key; a typed road matched by the SEALED mirror byte for byte; the item still holding that
  key); none while an act is in flight; none makes a Touch ID item; nothing destructive on a Standard record's word; the
  Castle repairs only on a confirmed Castle record; delete on sight by recorded id only; decision 35; the key file back
  from its mirror never re-adding an Apple wrap.
- `Acts/` — `CommonSteps.swift` (the re-key in PREPARE-THEN-COMMIT order: the new key's custody item → the new key file
  with the history it takes and the anchor carried → the staged re-encryption → the record into the staged file, every
  verifying section re-sealed under the new key → THE SWAP → the memory → the outgoing key's items, Castle's sweep only
  once the history verifiably holds each key; copies paused from the prepare to the swap; the account's rotation with
  the new corpus id stamped in the plan BEFORE the write; the walk; the completing write gated on the named key; sync keys
  held by what they reach; the anchor written FIRST and never twice; the old shared key's retirement); `EnterCastle`,
  `LeaveCastle`, `ReplaceAllKeys`, `Follow` (into Castle, into Standard, keys replaced; the hold; the finish of a lost
  device's leave minting only at the press that stops waiting), `AccountActs` (set up sync, enroll by the joining rules,
  This Mac Only — carrying a mode while signed out — Stop syncing here, delete the account here, Move, Resume Sync after a
  landing), `Copies` (open a copy, land, Send Library, plaintext export, the offer's delete), `KeyDoors`, `DeviceActs`
  (settings, the re-arm, confirm mode, create library), `SharedKeyAndRelink` (the move, the retirement, Re-link's two
  arms), `Migration` (§3.13). Every `ProtectionAct` case has its program (shape refinement, recorded: the account family
  and the copy acts each share one file — their rules are one table each).
- `Model/Plan.swift` — **a recorded refinement of U1's plan:** `ActParameters` (optional, sealed with the plan) — what the
  press chose that a resume needs and that is NOT a secret: the gate at this press, the door's vault revision (VX-109),
  the door's KDF descriptor, the stamped corpus ids, the Apple key ids an act minted, the crossing's kinds, the copy's id,
  the follow's kind and typed secret's kind, the move's subjects. The plan's format number is unchanged (no plan exists
  on disk yet; an older plan decodes with none).
- `ProtectionGuards.swift` — U3's eleven guards (off-switches `#if DEBUG` only): `planNamedBySection`,
  `repairPreconditionsVerified`, `repairNeverMakesTouchIDItem`, `prepareBeforeCommit`, `exportOffAtCastle`,
  `followerAnchorTypedLock`, `oldSharedKeyDeletedByRecordedID`, `copyActClearedOnOpen`, `moveKeepsOldWrap`,
  `retirementRerunsMoves`, `freshPairAfterMove`; the executor also reads U2's `everyOwnKeyRetiredAtCastle`,
  `leaveIDGatesCompletion`, `castleKindCustodyThroughLeave`, `freshVaultBeforeAppleWrite`, `rekeyAtEveryCrossing`,
  `doorTimeVaultCheck`, `standardRecordNoDestructiveRepair` and `deleteOnSightByIDOnly` where it acts on the same rule.

**Tests** — `Tests/VariorumCoreTests/Protection/Executor/`: `ExecutorWorld` (every leaf in memory; a write log in
order; a crash injectable after ANY write — the write lands, the process dies, session memory and the copy pause go
with it; a shared `ICloudKeychain` and `ExecutorVault` — CAS, the key proof, one rotation at a time, completion refused
while rows remain), `ExecutorFixtures` (`EX`: a library in each shape, a second device on the same account, the lobby's
roads after a relaunch, `expectSettled`), `CrashHarness` (a crash after EVERY write of a clean run — stronger than every
step — then relaunch, settle, and the world classified: finished or never happened, never both or neither; with the
plan kept a resume must finish, with it dropped the act rolls back before its swap and finishes from the record after);
the suites — `UseCastleTests` 7, `UseStandardTests` 8, `ReplaceAllKeysTests` 5, `FollowTests` 6, `SettleSealTests` 6,
`ExecutorRepairTests` 9, `AccountJoinTests` 6, `LeaveAccountTests` 7, `OpenCopyTests` 4, `LandTests` 4,
`SmallCopyActTests` 3, `ExecutorKeyDoorTests` 5, `ExecutorDeviceActTests` 4, `SharedKeyActTests` 6,
`ProtectionMigrationTests` 4, `ExactWritesTests` 5, `ExecutorEdgeTests` 3, `ExecutorLogScanTests` 1,
`ExecutorGuardsOnTests` 1, `ExecutorGuardMutationTests` 20 (DEBUG) — 114 tests in 20 suites. §5's list, each met: the
exact writes in order (Use Castle local and synced, Use Standard local and synced, Castle Replace All Keys, opening a
copy, the follow into Castle, a leave, a landing, a synced key door, the settings, the re-arm — each read against the
design's order before it was pinned); a crash after every write then a resume that finishes or rolls back, never a third
state (Use Castle — Touch ID, Always ask, synced Always ask, plan dropped; Use Standard — local, Always ask, plan dropped,
synced Always ask; Replace All Keys; a follow into Standard on an Always-ask device; a leave — Always ask, plan dropped;
an enroll into Castle; opening a copy; a landing; the migration); every refusal named; the log scan; decision 35 (the
repair, and an act offline); the failed seals (an unsealed or unnamed plan ignored and the act rolled back or finished
from the record; a memory item failing its seal losing to the record's section).
- Debug, the protection suites (U1+U2+U3 — 55): `✔ Test run with 268 tests in 55 suites passed after 0.889 seconds.`
  (U3: 114 tests in 20 suites.)
- Release (`swift test -c release --filter …` over the same 55 names, on THIS tree): `✔ Test run with 228 tests in 51
  suites passed after 0.460 seconds.` (the four DEBUG-only mutation suites compiled out: 268 − 40, 55 − 4). Wall 526 s,
  the release build included.
- Full core suite, Debug (`swift test`, 314 s wall): `✔ Test run with 3128 tests in 385 suites passed after 195.978
  seconds.` · `✔ Test run with 240 tests in 51 suites passed after 23.262 seconds.` · `✔ Test run with 40 tests in 6
  suites passed after 47.347 seconds.` (U2's 3014 + U3's 114; 365 + 20.)
- The guards are live: each of U3's eleven, and the eight U2 guards the executor reads, switched off lets its bug through
  beside the guarded run (`ExecutorGuardMutationTests` — the failing assertion is each test's expectation on the
  unguarded run: a replayed plan changing this Mac's settings; the only road deleted; a Touch ID item made by a repair;
  no road opening the library after a crash at a swap made before its key file; the export left on; a follower's anchor
  not opening with the passphrase typed at its follow; a newer old-name item deleted; a copy's act carried; the old wrap
  dropped; no fresh pair; another library's copy stranded at the retirement; a re-linked own key left unretired at Castle;
  the previous key cleared while the leave's id stands; silent sync keys in a leave's window; an Apple wrap landed with
  no fresh read; a Standard leave keeping its key; the old key deleted though a vault names it; Use Castle's door opening
  on a vault on the old key; a Touch ID item deleted on a Standard record's word; another Mac's Apple key deleted).
- **Two real gaps the crash harness found while building, fixed and pinned:** an Apple key added but not yet recorded in
  this Mac's section (a crash between) is recorded on the resume; Replace All Keys' re-link-first carries its own vault
  revision forward (its rotation's CAS otherwise refused its own write).

**PROVISIONAL calls (for QUESTIONS at the closeout):**
- **P-U3-1 — a held follow's library half asks its one secret again.** A follow into Standard meeting a leave in progress
  writes the anchor (under the secret typed then), picks up the keys and holds; its library re-key runs at the NEXT
  follow press, which types one secret again. Chosen: (a) ask again at that press. Others: (b) keep the derived key in
  session memory across the hold, asking only after a relaunch; (c) lock the new key file under the master, its words
  copy and the Apple key only, the passphrase lock landing when next typed (today's 2c rule).
- **P-U3-2 — a synced act's plan lost past the account's commit point** (the vault rotated, the library not yet swapped).
  Chosen: (a) the library half rolls back and the device finishes the account half as any follower would (§3.6: "a
  synced rotation resumes from the server's own rotation state" — the finish door / the follow, pinned). Other: (b)
  finish the library half from the record — it needs both secrets re-typed, which no plan holds.
- **P-U3-3 — a leave forgets the old account's sync keys AFTER the swap** (VX-110 forgot first). Chosen: (a) after — the
  record's binding is what governs, and a roll back then leaves the device still enrolled. Other: (b) first, as VX-110
  (a roll back leaves the library bound to an account whose keys this Mac forgot).
- **P-U3-4 — This Mac Only carries a mode while signed out** (§3.8's one plain road: Use Castle's or Use Standard's
  crossing applied to this Mac only, in the leave's one act). Chosen: (a) one act. Other: (b) two acts in sequence (the
  leave, then the crossing — two re-keys).
- **P-U3-5 — Re-link's library arm for another library's own key file** reaches that library's key only through the old
  shared key's wrap while it exists; otherwise it is reported, not guessed (it needs that library's secret). Chosen: (a)
  skip and report. Others: (b) ask that library's passphrase or words at the door; (c) re-lock nothing for it.
- **P-U3-6 — a copy act's resume without the copy's key** (opening a copy, a landing — the copy's key is in hand only at
  the press) rolls back before its swap. Chosen: (a) roll back (she opens it again). Other: (b) leave the act in flight,
  asking for the copy's secret again.
- **P-U3-7 — no repair runs while an act is in flight** (mid-act the live key file is the new key's while the library is
  still under the old one; a repair would read "the file lost a road" and undo the act). Chosen: (a) every repair
  skipped, reported `.actInFlight`. Other: (b) only the non-destructive ones (`refreshMemory`). Hand-forward: `assess`
  owing none while an act is in flight.
- **P-U3-8 — the migration's custody items:** a confirmed Castle library gets a per-key Touch ID item only where today's
  gated item stood and this Mac's gate says Touch ID (the choice she made then; the migration is an act, not a repair);
  none under Always ask; an unconfirmed mode adds none. Others: (b) none until a press in Settings; (c) one on every Mac
  with an enrolled finger.
- **P-U3-9 — Resume Sync after a landing tells which secret was made new by what opens what** (the one the vault opens is
  the account's; the other must open the landed key file and becomes the account's). Chosen: (a) by what opens what.
  Other: (b) a fact stored at the landing (a record field — a schema change).

**Commits:** `76215573` (LIVE STATUS opened) · `9f694b5c` (a/b WIP: the core, the crossings, the world) · `8b3b1e39`
(b: the crossings' tests) · `53e94d82` (a: the core's tests) · `843ef37c` (c: the account acts) · `9632f98a` (LIVE STATUS
flips) · `469044e6` (d: copies) · `9217cfb8` (e: the remaining acts) · `ca09dc95` (f: the guards, the log scan) ·
`5fbe5cb5` (f: the self-review's four gaps) · the record's own commit. Each pushed to `origin/vx-305-castle-core` as it
landed.

**Machinery notes:**
- Swift 6: the executor is a non-Sendable final class and the leaves `AnyObject` protocols; only the vault is `async`.
  Phase 3's real vault leaf drops in behind the same protocol.
- The crash harness crashes after every WRITE, which subsumes "after every step" (a step is one or more writes plus the
  plan's). A crash before the plan's first write is, by design, an act with no plan: it rolls back.
- The record is written into the staged file with every section that verifies re-sealed under the new key, so after a
  leave (an empty history) other devices' sections stay verifiable.
- Sync keys are re-filed only when they differ (one item per account, the other class dropped).
- Hand-forwards — **U4:** `ExecutorWorld`, `EX`, `CrashHarness` and `ExecutorVault` are the simple leaves U4's world
  replaces with realistic fakes (propagation, the off switch, the same-name rule, an older build); the empty-slot landing
  above; the file-swap fixed scenario's world half (the executor's share is `unlock(alsoInHand:)`, pinned); the held
  follow's second press (P-U3-1). **Phase 2:** the leaves' real Keychain/file/SQLCipher implementations; the lobby passes
  `alsoInHand` every key its road reached; `settle` runs at every open before any repair; `assess` owes no repair while an
  act is in flight (P-U3-7). **Phase 3 (Fable, `Sync/`):** the `VaultLeaf` over `KeyVaultClient` and `CorpusRotation`
  — the stamped corpus id, the door's revision, the leave's mark (`apple_key_id` with no wrap), the completion gated on
  the named key, the walk; `SyncEngine.refuseIfRekeyIncomplete` reading the plan; the key provider reading sync keys by
  reach and session memory.
- The one Sonnet lookup was not used.

### ORCHESTRATOR NOTE after U3 (2026-10-14)

- **U3 verified, not trusted:** all 55 protection suites re-run by the orchestrator — `✔ Test run with 268 tests in
  55 suites passed` (the exact claimed count) — tree clean and level with origin, §7 flipped. **Scope re-verified by
  diff against the branch base:** outside `Protection/`, the whole branch touches only the plan file and VX-345's
  three `#if DEBUG` test guards — zero `Sync/`, `App/`, `Server/`, `Persistence/`, migration or `Package.swift`
  lines, exactly as the kickoff's hard limits demand.
- **The `Model/Plan.swift` refinement accepted:** `ActParameters` (the non-secret choices a resume needs — the gate
  chosen, the door's vault revision and KDF descriptor, stamped corpus ids, minted Apple key ids). Recorded with its
  reason.
- **Tracked hand-off:** the EMPTY-SLOT landing (a fresh Mac with no library of its own receiving Send Library) is
  deliberately phase 5's (Open Library's road) — carried to §11's closeout so VX-309's plan inherits it. U4 gives
  its receivers a library of their own meanwhile.
- The crash harness found and fixed two real bugs in-flight (the unrecorded Apple key on resume; Replace All Keys'
  re-link-first vault revision), both pinned.
- **For her bundle:** P-U3-1 (a follow that waited out a leave asks its one secret again at the next press) and
  P-U3-6 (a copy act that crashes before its swap rolls back and is redone) are the two calls with faces she would
  meet; both PROVISIONAL, options in the U3 record, QUESTIONS at the closeout.

### U4 RECORD — the scenario world (Opus implementers, 2026-10-14/15: the U4 session, stopped at a clean seam at `e281b846`; the closer session from `03d8e3e4`)

**Not done, first.** (1) DEFERRED — RATIFIED to phase 5 / VX-309 by the orchestrator (it joins the empty-slot landing
there): §3.7's "a copy of a library this Mac remembers (the one in the slot, or ANY IT KNOWS) is re-encrypted under that
library's current key" has no act in phase 1 — the executor opens only the slot's own line, so a library this Mac itself
set aside (a landing put it in Previous Libraries) reopens as a DIFFERENT library under a fresh key with an empty history,
and its own line's earlier key and that key's silent item stay outside the next Use Castle's history (promise 2; the
soak's seed 9, sequence 232, traced). The generator does not reopen a library this Mac remembers until that road exists
(`07a6101d`). (2) QUESTIONS entries for P-U4-1…15 wait for the closeout (the merge-moment rule). (3) The canon deltas this
unit implies (design §4.1 promise 6's vault-reach qualifier; §3.2/§3.6/§3.13 the marker's two parts and, if ratified,
P-U4-14's login-part predecessor) land at the merge moment.

**What shipped** — `Tests/VariorumCoreTests/Protection/Scenario/`: `Fakes.swift`, `World.swift`, `OlderBuild.swift`,
`Alphabet.swift`, `Promises.swift`, `Generator.swift` (the world, its alphabet, the thirteen promises + §3.9's vault
invariant, 17 starting states from the old formats, the seeded generator with shrinking, `PROTECTION_SOAK=1` and its
count overrides), `WorldSmokeTests.swift`, the fixed scenarios (`FixedScenarios.swift` — migration; `…Devices.swift`;
`…Accounts.swift`; `…Copies.swift`; `…More.swift`; `…Corners.swift`; `…Found.swift` — the generator's findings at their
minimal sequences) and `MutationPins.swift` (DEBUG). The world's design notes: realistic resumes (she types the secret
her press took — the plan's descriptor tells which, and since the closer the locks under it this Mac holds, the memory's
mirror included); a crash can ride any act; the world runs the assessment's repairs after every act (the app's refresh)
and re-settles a waiting act at the next vault reach (sign-in, back online, the settle); the truth tracks each holder's
secrets with their timelines; the vault fake answers only a session signed into the account, online.

**The closer's model changes (Sources, beyond the bug fixes below).** HER RULING 2 — THE MARKER SPLIT (`f87db7c6`):
`HardwareMarker` is now two salted parts (`hardware`, `login`; HMAC-SHA256 under the record's salt, one domain each);
`IdentityResolution.anotherLogin` — this hardware's part under another login's part (a section or the memory item) mints
its own identity and ADOPTS NOTHING (VX-340, no choice yet); other hardware is a replacement. P-U4-3's no-predecessor
takeover is new hardware's alone. Pins re-pointed: `DeviceFactsTests.aSecondMacOSLoginStartsItsOwnIdentity` (its old
assertion WAS the takeover), `newHardwareWithNoMemoryItemTakesOverWhatNeedsNoPredecessor`,
`ProtectionGuardTests.hardwareMarker`, the scenario pin `theHardwareMarker` (adopts nothing; still failing with the guard
off), `HardwareMarkerTests` (two parts, salted, no unsalted hash), the scans (both parts as log needles; no marker part
outside this Mac's facts). HER RULING 1 — THE STUCK LEAVE (`1cf72df9`): `readVault` reads only the session's account
(`ExecutorRefusal.vaultOutOfReach`, `VaultRefusal.notSignedIn` for the leaf); a synced resume that can't reach its vault
ROLLS BACK before its commit point and past it runs what needs no vault, then WAITS NAMED (`SettleOutcome.waiting(act,
account:)`); `ProtectionPlan.pastCommitPoint` is the one line both the executor and promise 6 read; Re-link-first inside
Replace All Keys stamps `accountWriteBegun`; a resume of an unswapped re-key pauses copies again. Promise 6 gains her
vault-reach qualifier (a synced act past its commit point whose account's vault this device can't reach — signed out,
another account, offline — stays NAMED and WAITING: the section names it, its plan is the one named, the library is
open, copies paused while unswapped; it finishes at the next vault reach). HER 2026-10-15 WIDENING (`41c9d63f`): the
older-build acts left the generator's alphabet (an older device only updates); the older-build fixed scenarios and the
door-time-vault-check pin are marked "beyond scope, kept while green" — all stayed green.

**§6's fixed scenarios → tests.** Every sentence is a named test (or a named mutation pin that runs it guarded first),
in the files above — doc comments quote the sentence. Her 2026-10-14 ruling (the legacy cut): SUPERSEDED, removed and
marked in place — "the old key's fold, then retirement — no stranded copy" and its pin (`retirementRerunsMoves`); "an
older library of another library … (both variants)"; "a copy made before this change, of another library, … lands in
Standard". RE-POINTED (already on new-system pairs, docs say so) — W-1/VX-263 (`CopyAndCrossingScenarios.w1VX263`); "this
library's own Castle-era copy restored after a leave" (`ScenarioMutationPins.ownCastleEraCopyRestoredAfterALeave`). KEPT
(the orchestrator's adjudication): `giftsOnlyForThisMacsCopies`, "the window after the move", "iCloud Keychain off … the
retirement lists the library". Her 2026-10-15 widening: BEYOND SCOPE, KEPT WHILE GREEN — `anOlderBuildCompletingALeavesRotation`,
`anOlderBuildsRelinkAndTheLastStepRace`, the older-build half of `followersAnchorsOpenWithWhatOpenedThem`, the
not-updated variant of `twoLibrariesOnOneAppleAccount`, the pin `anOlderBuildsRelinkLandsTheVaultOnTheOldKey`, and (an
old backup — a pre-migration snapshot) `aRollbackPastUseCastleToTodaysFilesKeepsTheKeysBirth`. Nothing uncovered.

**Mutation pins (21 after the cut; each green guarded, FAILING with its guard off — the failing assertion is the pin's
sentence, `#expect(holds)` false or a promise violation):** planNamedBySection (a replayed genuine plan turns the export
on) · twoHomes (a replayed memory item turns the export back on) · hardwareMarker (a second login adopts the first's
section — strengthened by the closer: it must adopt NOTHING, no export, no keys) · noRepairMakesTouchID +
repairNeverMakesTouchIDItem (a Touch ID item made by a repair) · noRearmWithoutItem (the re-arm asked with no item) ·
rekeyAtEveryCrossing (a leave keeps the key) · anchorCarriedByEveryRekey (the anchor dropped) · familyTreeTwoHomes (later
copies read foreign after a rollback) · exportOffAtCastle (the export stays on) · everyOwnKeyRetiredAtCastle (Re-link's
second own key survives Use Castle) · doorTimeVaultCheck (Use Castle passes a vault on the old key — beyond scope since
2026-10-15, kept while green) · moveKeepsOldWrap (the old wrap dropped) · freshPairAfterMove (no fresh pair) ·
giftsOnlyForThisMacsCopies (a gift for another Mac's copies) · pruneOwnCopiesOnly (another Mac's copies pruned) ·
followerAnchorTypedLock (the follower's anchor won't open with the typed secret) · castleKindCustodyThroughLeave (silent
sync keys in a leave's window) · leaveIDGatesCompletion (the previous key cleared with no wrap for the id) ·
deleteOnSightByIDOnly (another Mac's own key deleted) · ownLineByFamilyTree (the own Castle-era copy refused as
foreign) · libraryFileLosesToMemory (a replayed library file lowers the mode — U4's own guard).

**The code bugs the world found — 52, each pinned red-on-old by the named test (watched failing on the tree before its
fix), then fixed; the protection set green after each.** Before the partial record (14): the move skipping the live
library's own key; corner 45's leave keeping today's silent item (P-U4-2); a replacement Mac taking over nothing
(P-U4-3); the migration taking the vault's word over the custody shape (P-U4-4) and copying a mismatched words copy;
Replace All Keys refusing inside its plan; the key doors stuck offline on Always ask; key file + memory both deleted;
today's sync custody surviving Use Castle; the doors blind to a moved account; the key doors without a follow-owed
check; ConfirmMode skipping the deferred steps; the settings act's plan-less finish; a stray staged file. The partial's
next 23: This Mac Only into Castle (signed out) retiring the old shared key an account still stood on
(`thisMacOnlyCastleFromAStandardAccount`); a library file replayed alone in Castle lowering the mode
(`aLibraryFileReplayedAloneInCastle` — new repair `rekeyOlderLibraryFile`, guard `libraryFileLosesToMemory`, P-U4-6);
the finish-leaving door refused while the follow was owed (`aFollowerMeetingARotationInProgress`); a wiped keychain
hiding a key replacement (`aWipedKeychainStillFollowsAKeyReplacement` — repair `recordHeldSyncKeysFacts`); a settings
act recording vault facts it never followed (`aSettingsChangeNeverHidesAFollowOwed`); a replacement Mac not knowing the
old shared key was retired (`aReplacementMacKnowsTheOldSharedKeyWasRetired`, P-U4-9); a replaced device's key doors
ahead of its follow (`aReplacedDeviceFollowsBeforeItsKeyDoors` — `libraryBehind`); a resume deriving another
passphrase under the plan's descriptor (`aResumeRefusesAPassphraseThePressNeverTyped`); a wiped keychain read as Castle
at the migration (`aWipedKeychainBeforeTheMigrationKeepsStandard`, P-U4-4 refined); a stale device re-linking a Castle
account (`aStaleDeviceNeverRelinksACastleAccount`); a synced resume's passphrase never checked against the vault
(`aSyncedResumeTakesThePassphraseThatOpensTheVault`); a library migrated offline waiting on a doorless confirm
(`aDeviceMigratedOfflineFollowsOnceOnline`, P-U4-11 — U2's unit pin restated); a file replayed from before a join taking
the account (`aLibraryFileReplayedFromBeforeAJoinChangesNothing` — repair `restoreRecordFactsFromMemory`); a crashed
This Mac Only (Standard) stuck on decision 35 (`aCrashedThisMacOnlyIntoStandardFinishes`); another key's file left live
by a replaced Mac (`aMacReplacedMidUseCastleGetsItsKeyFileBack`); a crashed leave whose own key was lost
(`aCrashedLeaveWhoseOwnKeyWasLostFinishes`); a local pair's landing beside a synced library refused mid-act
(`aLocalPairLandsBesideASyncedLibrary`); the actor's lost named key (`anActorWhoseNamedKeyWasLostFinishesItsLeave`); a
wiped device behind the account (`aWipedDeviceBehindTheAccountStillFollows` — `VaultFacts.unfollowedCorpusKeyID`); Use
Castle's retirement never run after a replacement (`aReplacementFinishesUseCastlesRetirement` — repair
`retireOwnAppleKeys`); a held synced landing writing an Apple wrap (`aSyncedStandardPairLandsHeldAndFinishes`); a
rollback to today's files recorded Castle over an Apple wrap (`aRollbackPastUseCastleToTodaysFilesKeepsTheKeysBirth`,
P-U4-4 refined again); a rotation's first write refusing instead of rolling back when the account moved
(`aLeaveCrashedBeforeItsFirstWriteRollsBackWhenTheAccountMoved`). THE CLOSER'S 15 (all in `FixedScenariosFound.swift`,
each commit naming its mechanism): (1) the stuck leave, her ruling 1 — a signed-out resume read and rotated the vault,
stuck past a commit point, named by no outcome, with copies running — `aSyncedLeaveCrashedPastItsFirstWriteWaitsForTheVault`,
`aSyncedLeaveCrashedBeforeItsFirstWriteRollsBackWhileSignedOut`, `copiesStayPausedWhileAnActWaitsAcrossARelaunch` (+
`aWaitingLeaveIsFinishedByAnotherDeviceThenAtSignIn`) — `1cf72df9`; (2) a landing resumed at its swap carried the
OUTGOING library's section into the landed one (`aLandingResumedAtItsSwapKeepsTheLandedSection`, `e7ce22d6`); (3) a Mac
replaced mid Use Castle with no memory item lost the outgoing key file — the plan now carries it
(`ActParameters.outgoingKeyFile`; `aMacReplacedMidUseCastleWithNoMemoryGetsItsKeyFileBack`, `81924cae`); (4) Re-link's
arm unoffered for a local Standard library whose live file has no Apple wrap and whose Mac reads no own key
(`aReplacedMacIsOfferedReLinkForALocalLibraryWithNoAppleWrap`, `3bff0ba5`); (5) a resumed New Words refreshed the master's
words copy from a vault whose master isn't the file's (`newWordsResumedPastAnotherDevicesLeaveKeepsTheWordsCopyHonest`,
`0c92fe01`); (6) Set Up Sync stuck on its lost account key — one minter, mint afresh
(`aSetUpWhoseAccountKeyWasLostMintsAfresh`, `b503826a`); (7) a no-predecessor replacement dropped a STANDING old-shared
record (P-U4-9 extended; `aReplacementKeepsTheOldSharedKeysStandingRecord`, `a7271412`); (8) the migration with no vault's
word recorded Castle over an Apple wrap (P-U4-4 extended; `aStandardBornKeyStaysStandardWithNoVaultToAsk`, `e3ea2b78`);
(9) a key door whose account moved before its vault write stuck — it rolls back as a rotation's first write does
(`aKeyDoorWhoseAccountMovedBeforeItsVaultWriteRollsBack`, `be0c4231`); (10) a resumed follow recorded the vault as read
NOW, hiding the follow still owed — acts record the keys they TOOK (`ActParameters.followedCorpusKeyID`;
`aFollowResumedPastAnotherReplacementStillFollows`, `a897833f`); (11) a no-memory replacement never named its predecessor
(P-U4-14; `aReplacementWithNoMemoryNamesItsPredecessorByTheLogin`, `d69e28f3`); (12) an offline retirement's door-time
read threw and stuck the act (`anOfflineRetirementResumeTakesItsOwnKnowledge`, `1264931e`); (13) a resume whose live
outgoing file lost the anchor its plan recorded (a Time Machine restore) writes it again first
(`aLeaveResumedAfterARestoreTookItsAnchorWritesItAgain`, `8dd79259`); (14) another identity's replayed memory item took
the account through the memory-wins repair — only THIS Mac's memory speaks
(`anotherIdentitysMemoryItemNeverRestoresTheRecordsFacts`, `4fa3c682`); (15) a rolled-back landing restored the outgoing
key file only from a wiped mirror — the plan's copy too (`aRolledBackLandingRestoresTheOutgoingKeyFileFromItsPlan`,
`6128c8de`).

**The checker and world findings the closer fixed in the world (17 — no model change; each kept as a fixed scenario):**
a crashed landing's made-new passphrase dropped from her truth (`aCrashedLandingsMadeNewPassphraseStaysHers`); a Time
Machine restore past a Castle stretch is the stated limit (P-U4-12; `aTimeMachineRestorePastACastleStretchIsTheStatedLimit`);
a held landing waits for Resume Sync before promise 3 (`aHeldLandingWaitsForResumeSyncBeforeStandardMeansStandard`), and
is held from its press (`aCrashedHeldLandingIsHeldWhenItsResumeFinishes`); a sent Standard pair is the sender's own
(promise 13; `aSentStandardPairIsTheSendersOwnAfterALeave`); a secretless library restored by Time Machine past Use Castle
(P-U4-13; `aTimeMachineRestorePastUseCastleOfASecretlessLibrary`); her vault road while signed out
(`aSignedOutDeviceStillHasTheVaultRoad`) and §3.5a's residue for a silently-joined device
(`aSilentlyJoinedDeviceBehindANewMasterIsTheStatedResidue`); a copy's own library's secrets on a dated day and a held-here
day (`anAsideLibrarysCopyNamesItsOwnLeaveDay`, `aRolledBackOverLandingsCopyNamesItsOwnWords`); the stated limit releases
exactly what the restored state reached through Apple in its day — its key and its key file's history, never an anchor's
(`bothHomesRolledBackOverAVX209VictimIsTheStatedLimit`); she types the passphrase her press took against the mirror's lock
(`aKeyDoorResumedAfterATimeMachineRestoreFinishes`); a retirement that couldn't reach its key is a delete never carried
(P-U4-1's class; `aRetirementThatCouldNotReachItsKeyIsADeleteNeverCarried`); a Standard tamper before a Castle stretch is
theirs already in promise 13 too (`aStandardTamperBeforeACastleStretchIsTheirsAlready`); every Apple account of hers counts
among her roads (`aFormerAppleAccountStillOpensItsCopies`); a lock clears the process's copy pause
(`aReplacedMacDoesNotInheritTheCopyPause`); the pre-tamper open's resume is settled first
(`aResumeBeforeATamperSettlesHerNewWordsFirst`). SUPERSEDED by her cut (an old backup): a pre-migration Time Machine
snapshot restored over the migrated store (seed 3, sequence 724 — the generator snapshots only a migrated store,
`e6077c2d`).

**PROVISIONAL calls (options for QUESTIONS at the closeout).** P-U4-1 a retirement's delete that never reached iCloud,
then a leave — (b) the checker exempts it, stated residue [chosen]; (a) delete on sight in Standard too; (c) the leave
re-deletes retired ids first. THE CLOSER: a second road into the class — a retirement recorded while this Mac is on
another Apple ID, its delete unable to reach the key there, then back to that Apple ID and a leave (seed 6, sequence
485) — read the same way under (b); option (c) would close both. P-U4-2 the leave retires today's silent item holding
the outgoing Castle key [chosen]; or a stated corner-45 residue. P-U4-3 RESOLVED by her ruling 2 (2026-10-14/15, split
the marker): another login on this hardware adopts nothing; the no-predecessor takeover (the live key file's wrap ids,
every retired id, Always ask) is new hardware's alone. P-U4-4 (refined twice, EXTENDED by the closer) the migration
records the key's birth when the KEY FILE says it (an Apple wrap ⇒ Standard-born) or the file and custody agree on
Castle — over the vault's word, and (the closer, seed 9) with NO vault's word too, where today's rule reads a missing
silent item as Castle [chosen]; or take the vault's/today's reading (the literal step 2). P-U4-5 after both homes roll
back past Use Castle, Re-link's library arm re-wraps the pre-Castle key under Apple — ACCEPTED AND STATED by her
(2026-10-14/15): §3.6's stated limit. P-U4-6 a library file older than what this Mac remembers loses to the memory
[chosen]; (b) refuse it and offer the newest copy; (c) believe the file — and (the closer, seed 17) only THIS Mac's own
memory speaks (another identity's replayed item never). A file only the ANCHOR reaches stays the replayed record
(P-U4-10). P-U4-7 (folded into P-U4-4). P-U4-8 a Time Machine rollback past a leave keeps the later Standard stretch's
silent item [chosen]; or a repair that deletes it once each such copy keeps another road. P-U4-9 a replacement Mac takes
over the predecessor's old-shared-key record, or with no predecessor a retirement any section lists — and (the closer,
seed 7) failing that a STANDING record any section lists, so the door and §3.1's first exception still show [chosen];
(b) the predecessor's only; (c) leave it. P-U4-10 a tamper on a Standard device sits outside promises 3 and 7 until a key
is minted past it — and (the closer, seed 6) outside promise 13 for the keys it took; the lobby could offer the newest
copy (hand-forward). P-U4-11 ACCEPTED by the orchestrator: an unconfirmed synced library whose vault answers the other
mode owes the ORDINARY FOLLOW (§3.13 step 1).

THE CLOSER'S NEW CALLS: **P-U4-12 — a Time Machine restore of the container past a Castle stretch** (her act — the
library file and its key file back together, the open believing them, P-U4-8): its own Apple key was retired at Use
Castle, so Re-link's library arm re-wraps the restored Standard key and the restored state's copies open through Apple
again — read as P-U4-5's accepted limit, releasing exactly what that state reached through Apple in its day (its key
and its key file's history, never an anchor's). (a) accept as the stated limit [chosen]; (b) refuse Re-link's arm for a
key this Mac's section records retired by a Castle entry, offering the newest copy instead; (c) re-key the restored file
under the memory's current key (a road only the anchor gives — it would expose Castle-era content). **P-U4-13 — a
secretless library (today's exposed shape) restored by Time Machine past its Use Castle:** the Castle key file whose
history held the old key went with the restore, the old key's only road was the Apple key Use Castle retired, so the
restored library and its copies open by no road on this Mac. (a) read as promise 5's exception ("a Standard copy made
with no passphrase or words once its own Apple key and this Mac's are both gone"), narrowly — a device restored past a
crossing [chosen]; (b) RECOMMENDED for phase 2's lobby: count this Mac's memory mirror of the key file as a road (§3.3's
"rolled back by Time Machine, still opens" favours it — the mirror holds the Castle key's history); (c) a world whose
Time Machine restores only the library file. **P-U4-14 — the login part names the predecessor:** with no memory item (a
real replacement — Migration Assistant carries none), a record section on OTHER hardware under THIS login's part is this
login's previous Mac: named the predecessor, its own keys taken over (seed 11: Use Castle crashed past its swap, the Mac
replaced — the new identity never learned the predecessor's own keys, the pre-Castle copies stayed Apple-reachable).
(a) the login part names it [chosen]; (b) the letter of §3.5 — only the memory item names a predecessor; the
predecessor's own keys a stated residue; (c) take over every own key any section on other hardware lists. Phase 2's leaf
check of GeneratedUID's lifecycle (P-U1-1) now also decides this one: whether Migration Assistant carries GeneratedUID.
**P-U4-15 — the commit point of an act whose vault is out of reach:** `ProtectionPlan.pastCommitPoint` = the library
swapped to the act's new key, OR an act that re-keys nothing (the plan-less rule's "committed"), OR the account's first
vault write begun (stamped before the write: a rotation's `newCorpusKeyID`, Re-link-first's `accountWriteBegun`). (a) so —
an act that re-keys nothing waits rather than rolls back [chosen]; (b) stamp every vault write and roll a re-key-nothing
act back when none began. Not product, recorded: the plan carries the outgoing key file (`outgoingKeyFile`) and the
followed corpus key id (`followedCorpusKeyID`) — non-secret, sealed with the plan.

**Hand-forwards noticed, not built:** RATIFIED to phase 5 / VX-309 (the orchestrator's word): reopening this Mac's own
set-aside library under its current key (§3.7's "any it knows" — the first line above). Phase 3/4: the waiting act's face
("Finish leaving Castle — sign in to finish", from `SettleOutcome.waiting`) and the cancel-before-commit-point; the vault
leaf refusing an unauthenticated session (`VaultRefusal.notSignedIn`). Phase 2/3: the app re-settles a waiting act at the
next vault reach (sign-in, back online). Phase 2: the lobby's memory-mirror road (P-U4-13 (b)); the GeneratedUID
carry-over check (P-U4-14). From the partial: Land writes the landed key file over the outgoing one's before the swap
(phase 5, VX-309 — the closer's roll back now restores it from the plan); a crashed landing rolls back — its face should
say so; an act whose resume needs re-typed secrets stays in flight until she types them — phase 3/5's face; the §8
older-build-Re-link sentence — WAIVED by her (2026-10-14/15, "there will not be older build's relinking"); U3's
`ExecutorWorld`/`EX`/`CrashHarness` KEPT beside the world (the orchestrator's adjudication).

**THE SOAK — the go/no-go's item 1 (seeds 1–20 × 1,000 sequences × ≤ 60 steps, `PROTECTION_SOAK=1 PROTECTION_SEED=n PROTECTION_SOAK_SEEDS=1`, one seed per call, on the FINAL TREE `6128c8de` — code; every later commit is a record).** Steps are identical in both configurations (the generator is deterministic). Seconds are the test time; wall includes the build check (Release seed 1 includes the release build).

| seed | sequences | steps | Debug s | Debug wall | Release s | Release wall |
|---|---|---|---|---|---|---|
| 1 | 1000 | 45136 | 352.7 | 359 | 224.4 | 809 (incl. the release build) |
| 2 | 1000 | 44823 | 349.2 | 356 | 221.2 | 224 |
| 3 | 1000 | 44708 | 338.8 | 344 | 214.9 | 218 |
| 4 | 1000 | 45177 | 336.5 | 342 | 213.4 | 217 |
| 5 | 1000 | 45005 | 340.8 | 347 | 213.3 | 217 |
| 6 | 1000 | 45093 | 345.9 | 352 | 222.0 | 225 |
| 7 | 1000 | 45014 | 348.8 | 355 | 288.6 | 292 |
| 8 | 1000 | 44547 | 339.1 | 345 | 218.1 | 225 |
| 9 | 1000 | 45031 | 343.8 | 350 | 220.4 | 225 |
| 10 | 1000 | 45065 | 349.3 | 356 | 224.3 | 228 |
| 11 | 1000 | 44813 | 346.1 | 352 | 227.4 | 232 |
| 12 | 1000 | 45038 | 344.3 | 351 | 216.0 | 220 |
| 13 | 1000 | 44956 | 363.7 | 373 | 278.3 | 281 |
| 14 | 1000 | 45241 | 368.3 | 376 | 223.8 | 229 |
| 15 | 1000 | 44985 | 381.0 | 389 | 226.0 | 230 |
| 16 | 1000 | 44803 | 368.4 | 373 | 210.7 | 213 |
| 17 | 1000 | 44240 | 345.1 | 352 | 209.9 | 213 |
| 18 | 1000 | 44925 | 341.2 | 346 | 217.8 | 221 |
| 19 | 1000 | 45039 | 407.9 | 414 | 229.1 | 233 |
| 20 | 1000 | 45245 | 356.5 | 363 | 229.3 | 232 |
| **total** | **20,000** | **898,884** | **7,067.4** | **7,195** | **4,528.9** | **5,184** |

**THE RUNS (on the final tree):** the protection set in Debug (every `@Suite` type under `Protection/`, 65) — `✔ Test
run with 413 tests in 65 suites passed after 27.367 seconds.`; under `swift test -c release` — `✔ Test run with 352
tests in 60 suites passed after 3.136 seconds.` (the five DEBUG-only mutation suites compiled out: 61 tests; 8:04 wall
with the release build); the full core suite in Debug — `✔ Test run with 3273 tests in 395 suites passed after 193.459
seconds.` · `✔ Test run with 240 tests in 51 suites passed after 23.005 seconds.` · `✔ Test run with 40 tests in 6
suites passed after 46.609 seconds.` (exit 0). Its first run met one 60-second time limit in
`StarContextTests.aHeldObservationOfAStarGatheringHearsTheUnstar` (13i-b, outside this unit) under load — green alone
in 0.7 s and green on the full re-run above; a timing flake, not this unit's.

**Commits:** the partial's (`git log --oneline 6020391b..e281b846`, then `efd45ff7`, `3a970ec1`) and the closer's
(`git log --oneline 03d8e3e4..HEAD`): (h) the marker split `f87db7c6`; (i) the stuck leave `1cf72df9`; the 60-sequence
sweep's world finding `76d60234`; her 2026-10-15 widening `41c9d63f`; then one commit per soak finding — `e7ce22d6`,
`8c450e8c`, `db61482d`, `e3b3ebbb`, `81924cae`, `207c6297`, `e1ed8c6a`, `709ec222`, `9a42aa3c`, `e6077c2d`, `3b533d9c`,
`3bff0ba5`, `9a735ad7`, `65c12631`, `0c92fe01`, `79dd9cc6`, `b503826a`, `b69e051f`, `e5ee9401`, `a7271412`, `8c333f4e`,
`07a6101d`, `ce3a3d71`, `e3ea2b78`, `be0c4231`, `a897833f`, `d69e28f3`, `4615ceb5`, `1264931e`, `8dd79259`, `4fa3c682`,
`6128c8de` — and the LIVE STATUS flips between them; every commit pushed as it landed.

**Machinery notes.** The closer ran across usage-limit deaths; everything was on origin at each. Generator cost: ~7–8 ms
a step in Debug, ~5 ms under `-c release`; a passing Debug seed runs ~340–410 s, a failing one longer (the shrink) —
past the tool's 10-minute cap, so seeds ran as background processes with a foreground wait (one at a time, never two
builds at once). One commit message (`8dd79259`) says 412 tests where the run said 411 — the record's counts are the runs'.

### HER RULING, 2026-10-14 (mid-U4, to the orchestrator) — THE LEGACY CUT

**Her words, verbatim:** *"I don't want to strang my current store in the pro, air, phone, etc. but I don't need to
save any backups … we don't need to keep every store shape today's builds ever left. they don't need to keep opening
forever. as long as everyone's current store stays fine to open, we really don't need anything else (I can do a
plaintext export if you're really concerned about the current one breaking). But we might be able to simplify phase 2
because we do NOT need to keep supporting anything that's ever happened."* Clarified the same hour: *"once we have
changed the system design the new backups made after this is all released should keep working on an ongoing basis.
I'm just saying any current backup support is unnecessary - it's literally me and like 3 beta testers and i doubt any
of them have ever made backups."* Question-tool picks: **old copies drop** (the new system's own pairs keep the full
guarantee); **Previous Libraries / set-aside stores / other libraries' old copies take the same cut.**

**What STANDS:** every CURRENT store migrates (all of §6's starting shapes are current-store shapes — exposed,
Standard-waiting, corner 45, escrow, stuck markers, the two-Macs-one-library hand-off where both stores are live);
the NEW system's own backup pairs keep the full opens-with-its-day's-secrets guarantee (the anchor, the history, the
family tree — the VX-263 rulings, unchanged going forward); the A1 safety copy + the old-build road back through the
transition (§3.13 step 9); the old shared key's retirement checks for CURRENT stores and vaults elsewhere; the
catalog/retention/offer still LIST and DELETE old copies as files (VX-265's delete choice survives) — they just
don't open.

**What DROPS:** pre-rebuild copies opening on the new system, Previous Libraries and set-aside stores from before
the switch, other libraries' old copies — and therefore: the migration's fold beyond the current key; §3.5 point 2's
gift machinery (per-library key files + own Apple keys for OTHER libraries' old copies); the legacy readers'
keep-forever role (they become migration-only); the "copy with no record" open road; the retirement sheet's old-copy
listings. An old copy meets an HONEST REFUSAL naming its roads: an old build, or a plaintext export.

**Where it lands:** the design's §1/§3 amendments at this phase's MERGE MOMENT (the closeout's canon-delta step);
phase 2's plan (vx-306) is WRITTEN TO THE CUT; the now-dead model arms U1–U3 built (the fold-beyond-current, the
gifts) are removed with their tests at phase 2's first act — phase 1 closes with the model as built and green.

**U4 scenario deltas (the §6 list, re-read under the ruling):** SUPERSEDED — the old key's fold-then-retirement
"no stranded copy" scenario and its mutation pin (the fold shrinks to the current key; old copies stranding is now
the ruled, honestly-said outcome); the older-library-of-another-library opening scenarios (both variants); "a copy
made before this change, of another library, lands in Standard"; any scenario whose point is a pre-rebuild copy
OPENING. RE-POINTED — W-1/VX-263's fixed scenario proves the guarantee on a NEW-system pair; "this library's own
Castle-era copy restored after a leave" is built with a new-system pair. KEPT UNCHANGED — every current-store
scenario (the two-libraries-on-one-account second Mac, today's shapes through the migration, the old build's crashed
act, the pre-change two-Macs hand-off, and the rest). U4 records each skipped scenario as "superseded by this
ruling", never silently.

### ORCHESTRATOR NOTE after U4-PARTIAL + HER SITTING (2026-10-14/15)

**U4-partial verified:** the protection set re-run by the orchestrator at `efd45ff7` — `✔ Test run with 376 tests in
65 suites passed` (the exact claimed count); the 37 found-bug commits each name their mechanism and watched-red pin
(`git log 6020391b..e281b846`); the seam is honest (the remaining work named in order at the record's head).

**HER ANSWERS (the question tool, 2026-10-14/15 — verbatim where she wrote words):**
1. **The stuck leave (the soak's seed-2 finding) — STAYS IN FLIGHT, her pick of the recommendation:** a synced leave
   crashed past the rotation's first write and then signed out WAITS — said visibly ("Finish leaving Castle — sign in
   to finish"), the library opens, sync waits, copies stay paused (no new backups until it finishes, said plainly);
   a crash BEFORE the first write still rolls back; another device of the account can finish. Promise 6 gains the
   vault-reach qualifier for a synced act past its commit point; the visible face + the cancel-before-commit-point
   are phase 3/4's (the hand-forward list). The closer builds the fixed scenario from the minimal sequence and the
   promise qualifier.
2. **P-U4-3 — SPLIT THE MARKER, her pick:** two salted hashes, a hardware part and a login part (same hardware +
   different login = a second login, its own identity, adopts nothing — VX-340; different hardware = a replacement,
   takes over). Her "the marker covers the login" ruling intact; each part alone, salted, names nothing. The closer
   makes the model change (HardwareMarker/DeviceSection/resolveIdentity) with the existing pins re-pointed.
3. **P-U4-5 — ACCEPT AND STATE IT, her pick:** the both-homes rollback edge (Re-link's arm re-wrapping the
   pre-Castle key) is part of §3.6's stated limit; the exposure is pre-Castle content, login-reachable in its day
   (rule 3). The §3.6/§8 restatement lands at the merge moment.
4. **The §8 older-build-Re-link sentence — NOT ADDED, her words:** *"i'll tell everyone in beta testing to update &
   we haven't released publically yet, so there will not be older build's relinking. not a concern."* Scoped
   precisely: the SENTENCE is waived; the older-build ACTOR stays in the world (it still models her own devices'
   update windows after the release switch — the phone on yesterday's build completing a rotation).

**ORCHESTRATOR ADJUDICATIONS (the architect mandate, each against the ruling or the design's letter):**
- The three unclear-class scenarios under the legacy cut are KEPT, as U4 built them: `giftsOnlyForThisMacsCopies`
  guards built code until phase 2 removes the arm (the pin dies with it); "the window after the move" proves a
  NEW-system pair (inside the ongoing guarantee); "iCloud Keychain off … the retirement lists the library" is a
  CURRENT store's stranding risk, squarely kept by the ruling.
- **P-U4-11 ACCEPTED:** an unconfirmed synced library whose vault answers the other mode owes the ORDINARY FOLLOW —
  that is design §3.13 step 1's own sentence ("a vault that moved while the library didn't is an ordinary follow");
  U2's unit pin had the wrong reading and its restatement is the fix, not a relaxation.
- U3's executor scaffolding KEPT beside the scenario world (two harnesses, more coverage; the ladder may consolidate).

### HER RULING, 2026-10-15 — THE LEGACY CUT WIDENED: NO OLD BUILDS

**Her words, verbatim:** *"yeah i mean we do need to make sure that it doesn't ruin my existing store for sure, but
no old backups or builds have to be considered."* (This supersedes the "the older-build ACTOR stays" scoping in the
sitting block above, which predated her widening.)

**The precise line (the orchestrator's scoping, said back to her):**
- **STAYS — the don't-ruin-my-store half:** every state an old build has ALREADY LEFT in a current store is a
  migration INPUT and stays fully handled — stuck markers, a rotation still standing on the server, today's custody
  shapes, corner 45, escrow items. Her stores could carry any of them on migration day.
- **DROPS — old builds as LIVE, CONCURRENT ACTORS after the switch:** an un-updated device completing a rotation, an
  older build's Re-link re-landing a vault, the last-step-race arms, and §3.15's "today's runner's finish path kept
  for one release" (the migration ALWAYS resolves old acts from disk evidence — U1's clearing check). Handled by
  PROCEDURE: the switch (VX-329) updates every device before any crossing — her rehearsal order already does — and
  the public only ever arrives on the new build.
- **U4/closer deltas:** the older-build actor leaves the GENERATOR's alphabet; the already-green older-build fixed
  scenarios are kept as free robustness, marked "beyond scope, kept while green"; anything red that traces only to
  live old-build interference is recorded as superseded by this ruling, never fixed.
- **Lands:** the design's §3.15/§4.1/§8 amendments at the merge moment; VX-306's plan drops the old-runner keep;
  VX-307's plan drops the old-build interference choreography; VX-329's plan carries the update-every-device-first
  procedure line.

### HER RULING, 2026-10-15 (at the U4 close) — THE LADDER'S CAP RAISED FOR THIS PHASE

**Her words, verbatim:** *"this doesn't have a hard cap on 3 - you can do up to 5 if majors are still being found."*
For this phase's ladder: up to FIVE rounds while BLOCKERs/MAJORs are still being found; everything else unchanged
(a fresh reviewer per round, `notes/REVIEW_PROMPT.md` verbatim with zero framing, findings and dispositions
repo-first, the cross-model flow, the final round's fixes checked line-by-line by the orchestrator).

### HER RATIFICATIONS, 2026-10-15 (the provisional sitting at the U4 close — question-tool batches; this block grows as the sitting runs)

- **P-U3-1 RATIFIED (a):** a follow that waited out a leave asks its one secret again at the next press — as built.
- **P-U3-6 RATIFIED (a):** a copy act that crashes before its swap rolls back whole and is simply redone — as built.
- *(P-U4-13 and P-U4-14 were re-posed in plain language at her word — "this question was too unclear to me" — answers below as they land.)*
- **P-U4-13 RULED — the phase-2 rescue road (option b).** Her words: *"isn't this all not even being released until phase 5? I don't see the issue with building this in phase 2 instead of phase 1."* Phase 1 keeps the honest refusal as the recorded state; phase 2's lobby builds the keychain-saved-copy road, and the vx-306 plan carries it as a named deliverable. (Her clarifying question answered at the sitting: yes — the key file carries the library's earlier keys inside it, sealed under the current secret; entering Castle moves the old key from Apple's reach into hers alone, which is exactly the VX-263 forward guarantee.)
- **P-U4-12 RULED (a):** her words: *"ok lets let the helper heal it."* Re-link's library arm heals a deliberately-restored pre-Castle state like any Standard library whose quiet road broke — reviving that day's reach, never anything Castle made. The strict-refusal and modernize options are retired.
- **P-U4-10 RULED — the limit accepted, the offer DROPPED:** her words: *"lets drop the healthy copy deal."* The Standard-tamper ceiling stands as the stated limit; the unlock-screen newest-copy offer leaves the hand-forwards (do not carry it to any later phase's plan).
- *(Sitting Q&A, for the record: her rotation question — secretless Standard → Use Castle → Replace All Keys: the Standard-era backup still opens, because each new key file carries the key history forward (current secrets open the current file; its history reaches the old key; the old key opens the old copy). Only the no-current-file case has no road, and her P-U4-13 ruling's phase-2 mirror road shrinks that class. And the helper never conjures a key: it re-wraps a key it reaches by another live road — a typed secret, a synced account's vault, the migration-era shared key, or (phase 2, her ruling) the memory's saved copy; with no road it reports and never guesses, P-U3-5's shape.)*
- **P-U4-1 RATIFIED (b):** a retirement's unreached delete is a known leftover, as built — the record's word governs; the lingering iCloud item is hygiene (her severity frame), not chased by the leave or on sight.
- **P-U4-2 RATIFIED (a):** the leave also deletes today's legacy quiet-unlock item holding the outgoing key — as built ("The leave cleans it up").
- **P-U4-4 RATIFIED (a), in her own words:** *"everyonw starts in standaard so they have apple keys but not on the current wrap i think"* — her reasoning is the rule itself: everyone starts in Standard so Apple keys exist, but a store now in Castle carries no Apple wrap on its CURRENT key file (a Castle key never gets one), so an Apple wrap on the current file means Standard-born. Migration believes the key file; Castle only when file and custody agree. Read back to her and confirmed at the sitting.
- **P-U4-6 RATIFIED (a):** a lone older library file loses to this Mac's own memory; only this Mac's memory speaks; the deliberate whole-pair restore keeps its own road (her P-U4-12 ruling) — as built ("Memory wins").
- **P-U4-8 RATIFIED (a):** a Time Machine rollback past a leave keeps the later Standard stretch's quiet-unlock item — as built ("Keep it").
- **P-U4-15 RATIFIED (a):** an act that re-keys nothing waits (the stuck-leave shape) rather than rolls back when its vault is out of reach — as built ("Wait, finish at sign-in").
- **P-U4-9 RATIFIED (a):** a replacement Mac inherits the old shared key's record from any entry — the predecessor's first, then any device's retirement, then any standing record — so the retirement door and the honesty line survive every replacement; as built ("Inherit from any entry").
- **THE SITTING CLOSED 13/13:** every flagged provisional now carries her ruling (P-U3-1, P-U3-6, P-U4-1/2/4/6/8/9/10/12/13/14/15); P-U4-3 and P-U4-5 were hers at the U4 sitting, P-U4-7 folded, P-U4-11 the orchestrator's. The still-open quiet provisionals (P-U1-2…8, P-U2-1…8, P-U3-2…5/7…9) go to QUESTIONS at the merge as usual; P-U1-1 was hers earlier. Sitting deltas to carry: P-U4-13's phase-2 mirror road is now a RULED vx-306 deliverable; P-U4-10's newest-copy offer is DROPPED from the hand-forwards.

### ORCHESTRATOR NOTE after U4 (2026-10-15)

- **U4 verified, not trusted:** the protection set re-run by the orchestrator on the final tree `6128c8de` — Debug `✔ 413 tests in 65 suites` (the exact claimed count), Release `✔ 352 tests in 60 suites` (exact; the five DEBUG-only mutation suites' 61 tests compile out). **Soak spot-check, deterministic:** seed 13 re-run alone — 1,000 sequences, **44,956 steps**, green — the record's table row to the step (342.0 s against the table's 363.7 s: load, not substance).
- **Scope re-verified by diff against the branch base:** outside `Protection/`, the whole branch touches only the plan file and VX-345's three `#if DEBUG` guards. The record commit `1edc1354` is plan-only; zero code changes after `6128c8de`; the branch level with origin.
- The closer survived THREE budget deaths (two session limits, one weekly) with zero work lost — every death fell on a clean pushed tree; the checkpoint protocol's proof in practice.
- Next: ladder round 1 — a fresh `fable-reviewer`, `notes/REVIEW_PROMPT.md` verbatim, zero framing; the report lands in §9 unedited; up to five rounds while MAJORs are found (her cap ruling above).
- **P-U4-14 RATIFIED (a), with her severity frame recorded.** Her words: *"I think it's fine to do the same login = my previous mac, but for what it's worth, if your previous mac dies and can therefore still open the pre castle backups, why is that even that bad? the dead mac had apple keys that open pre castle copies - that doesn't seem like a huge issue to me. we're only *really* guaranteeing castle copies, right? what's the reason that we delete the apple key in general? it's just safer, right?"* — recorded as the SEVERITY FRAME for this class: retiring a dead Mac's keys is hygiene that shortens how long pre-Castle reachability lingers, not a promise the system makes; the hard guarantee is Castle-made content. The scoping stands as built (same login part = the predecessor), and phase 2's GeneratedUID check decides whether the mechanism holds on real hardware.

## 9. The ladder (the Fable reviewer's report per round, committed unedited, then the dispositions — her 2026-10-15 ruling: up to five rounds while MAJORs are still found)

### Round 1 — 2026-10-16, fresh `fable-reviewer`, zero framing; the report committed UNEDITED as `notes/plans/vx-305-ladder-round-1.md`

**Tally: 1 MAJOR · 1 MINOR · 4 NIT, plus a clean bill otherwise.** The MAJOR (PlanRunner `rollBack` + `Assess`): a plan-less
rollback after a crash mid-re-key — the memory item deleted AND an earlier genuine plan replayed over the live one, both
tampers in the adversary alphabet — leaves another key's file in the live place with no repair that restores the current
key's own file; every later `needsLiveKeyFile` act refuses `noLiveKeyFile` permanently (VX-235's unfinishable class back
by a new door, against §3.6's "a missing or unmatched plan never blocks"). The checker is structurally blind to the state,
so the 898k-step soak never saw it. Reviewer's annotation: adversarial-only reachability; availability of the protection
acts only, never content. The MINOR is the same state's diagnosis quality in `assess`; the four NITs are small (a dead
switch arm, a doc-comment misnumber, an order-dependent `.first` pick, a lobby Touch ID line misspeaking pre-unlock).

**The reviewer's own verification recorded:** diff scope clean; Debug 413/65 exact; a Release spot filter green; a
deterministic soak slice reproduced; `LegacyModeReader` hand-diffed against the live `Posture.derive` (matches); the
mutation-pin harness and the promise checker's key-reach engine inspected and found genuinely biting.

**The implementer's agree/dispute — committed unedited as `notes/plans/vx-305-ladder-round-1-answer.md`:** all six
AGREED, zero disputes; the MAJOR's pin RED in all four cases on today's tree; reachability widened honestly (a planted
plan works; no crash needed with an earlier key's file replayed while closed; always TWO tampers, never one); a second
soak-blindness reason found (the generator relaunches between steps, so it can never compose two tampers or land one
inside a crash window); three scope notes on the fix and one framing note, all sent to the reviewer.

**The reviewer's FINAL CALL — committed unedited as `notes/plans/vx-305-ladder-round-1-final-call.md`:** all six
findings CONFIRMED; FINDER-FIXES none — the implementer applies everything. Dispositions ruled: (1) the MAJOR's fix
widens the `restoreKeyFileFromCopy` gate in BOTH places (Assess + ExecutorRepairs) with the precondition written out,
sets the stray file ASIDE as `.stale-<epoch>` (never deleted), and the WORLD gains both halves — promise 1's
live-key-file-agreement clause keyed on "no repair owed" plus a compound-tamper generator action (one closed window,
the seed-9 pre-settle preserved) so the class is soak-visible; (2) the COPY-LESS case is NOT gating — PROVISIONAL
**P-R1-1** hand-forward (recommended: a phase-2/4 rebuild-under-typed-secrets door, the key doors' sibling), bundled
for the author; (3) the STALE-COPY caution adopted — the fix's pin includes a key door between the copy and the
tampers and asserts the inherited `passphraseDoesNotOpen` honestly; pre-existing, rides P-R1-1, one recording sentence
owed; (4) the framing correction ACCEPTED (§3.3's always-agree contract, not §3.6), severity stays MAJOR; (5) the
`.first` NIT fixed this round via a pure `keyFileSharedAppleKeyID` parameter threaded from unlock (matching-id first,
smallest-id tie-break, red-on-old unit pin; the no-match residue stays her P-U4-1/P-U4-9 hygiene class); (6) the
P-U4-10 adjacency worded into the record — the repair restores the LIVE KEY FILE from this Mac's own frozen pair,
never a library copy, never an unlock-screen offer; her dropped newest-copy ruling untouched. The file ends with
round 2's re-check list.

**The fixes — applied by the implementer, verified by the orchestrator (`notes/plans/vx-305-ladder-round-1-fixes.md`;
commits `1dfbb85f8` · `95fbf9349` · `3ac5e5a95` · `5c36da3d8` · `74c638dab`, each pushed):** all six landed with
red-on-old pins, revert-verified (5/6 red with the gate files reverted; the copy-less probe green on both trees BY
DESIGN — it records P-R1-1's refusal). The MAJOR's set: both gates widened on one written precondition; the stray file
set ASIDE as `.stale-<epoch>` (a name the catalog's parser already reads as `.setAside`); promise 1's live-key-file
clause (keyed on "no repair owed", P-R1-1's copy-less case exempt); the `.tamperSequence` generator action — the wedge
PROVEN soak-visible (found at seed 1, sequence 96 through a tamper group) and ALSO reachable by ONE tamper
(`replayLibraryFile` after a leave: a leave's new key takes no history, so `libraryFileLosesToMemory` cannot verify —
the round-1 "two tampers" annotation understated; both roads committed as fixed scenarios). The orchestrator re-ran
both configs EXACT: Debug `✔ 429 tests in 69 suites`, Release `✔ 368 in 64`; the scope diff clean. NOTED FOR ROUND 2:
the set-aside is scoped to the copy repair only (the mirror and plan-runner restores still overwrite a stray file —
the final call's own scoping); the optional `.crash(...)` tamper-group wrap not built (the kept pre-settle means a
group never lands inside a crash window; that road stays covered by the fixed scenarios). THE NEW GENERATOR WEIGHT
SHIFTS EVERY SEED'S STREAM: the U4 soak table stands as its own run's record; the go/no-go soak runs FRESH on the
final tree.

**Two PRE-EXISTING finds by the new generator reach (both reproduce on the round base `e4ee1f083` — not caused by the
fixes; triage before the go/no-go soak; minimal sequences in the fixes record):**
- **NEW-1 — promise 3:** a replayed pre-Send-Library capture swaps a different, Standard library into a Castle slot;
  either checker bookkeeping under P-U4-10's ratified limit, or the swapped-in library's Apple road is never re-linked.
  Unadjudicated.
- **NEW-2 — promise 13, WITH NO TAMPER:** a 10-step legitimate sequence (a secretless join → corner 45 answered →
  a follow → Send Library → the landing with words-passphrase-made-new → Use Castle → Use Standard) ends with the
  Apple account or the login password reaching a PRE-LEAVE key — a security-promise problem with no adversary in it.
  Priority of the triage.

**Triage: a fresh implementer (trace → classify → pin red-first → fix or PROVISIONAL), then round 2 re-checks the
round-1 fixes and the triage together.**

**The triage — a fresh Opus implementer, 2026-10-16 (the record `notes/plans/vx-305-ladder-round-1-newfinds.md`;
commits `d77bedebd` · `59d5d9289` · `69336aa21` · `ca48bbf65` · `b65d29390`, each pushed); verified by the
orchestrator:**
- **NEW-2 — a CHECKER bug, two roads, no model change.** The one key reached after the leave is the SENDING phone's
  own Standard pair, kept in macB's hand-off folder exactly as §3.7 keeps it ("never written, keeps its own locks"):
  its key and that key file's own history, all the phone's Standard stretch. Nothing made in Castle and no copy macB
  made before the leave is reached; the pins assert that trace on both trees, so the exemption hides nothing. The
  closer's seed-2/661 exemption covered the sent pair's own key but not its history (first fix); the slice re-run
  then met the same class by a 17-step road — the pair surviving only in a Time Machine snapshot after macB's own
  same-day send overwrote the day-named folder (second fix: the world records each sent Standard pair's reach AT THE
  SEND, and promise 13 exempts it by the pair's identity, wherever its files sit). Pins
  `aSentPairsHistoryIsTheSendersOwnAfterALeave`, `aSentPairsSnapshotIsTheSendersOwnToo` — red before, green after,
  red with the fix stashed.
- **NEW-1 — a MODEL bug, under her ratified P-U4-6 (a), "Memory wins"; not P-U4-10's ceiling** (that limit covers a
  tamper on a Standard device; this device was Castle, and the memory's key reaches the replayed file's key through
  history). A landing set library Y aside to Previous Libraries while Y's memory still named the landing in flight;
  one replayed Standard-era file of Y then beat Y's own Castle memory twice — the settle rolled the stale act back
  against the replayed record first, and the memory-wins arm could verify only through the live place, which held
  the landed library's file. Fix, three links of one rule: `AssessRules.olderLibraryFileProof` (the proof is the live
  file of the memory's key OR the memory's own sealed mirror when the live place holds no key file of THIS library —
  a whole-pair Time Machine restore, P-U4-12, never qualifies); `rekeyOlderLibraryFile` takes that proof, sets the
  stray live file ASIDE (never deleted), restores the mirror with Apple wraps stripped, and now also checks the
  memory is this Mac's own; `settle` runs that re-key FIRST when this Mac's section names an act. Pin
  `aLoneOlderFileOfALibrarySetAsideByALandingLosesToItsMemory(group:)`, both forms — red before, green after, red
  with all three links stashed and with either the settle link or the proof link alone stashed.
- **No PROVISIONAL minted, nothing for QUESTIONS** — NEW-2's fixes are the world's; NEW-1's mechanics deliver an
  outcome she already ruled (recorded as implementation calls for round 2).
- **The orchestrator's verification:** scope `48bd6b84e..HEAD` clean (Protection's Assess / ExecutorRepairs /
  PlanRunner, the Scenario world files, the new pins file, the record — zero `Sync/`, `App/`, migration or
  `Package.swift` lines); the protection set re-run EXACT — Debug `✔ Test run with 432 tests in 70 suites passed`,
  `-c release` `✔ Test run with 371 tests in 65 suites passed`; an independent revert of the three source files to
  `59d5d9289` turns the NEW-1 pin red (`slot.record?.mode == .castle` … `promise 3 on macB: no Apple wrap of the
  current key`), restored clean. The implementer's two soak-shape slices (seeds 1–3 and 4–6 × 250) green. The
  settle's new first step shifts the streams again — the go/no-go soak runs fresh on the final tree, as already
  recorded.
- **Five observations handed to round 2, none built** (the record's §"For round 2"): promise 10 skips a step that
  changes the slot's library; the landing leaves its act named in the outgoing library's memory; the generator's
  `rollsBackBothHomes` exclusion is now wider than the model's limit; the world's day-named hand-off folders; a
  stale act's plan-less roll back deleting its to-key's custody items (pre-existing).

### Round 2 — fresh `fable-reviewer`, zero framing; the diff `e4ee1f083..HEAD` (round 1's fixes + the triage), the report committed UNEDITED as `notes/plans/vx-305-ladder-round-2.md`

*(launched 2026-10-16 after the triage's verification — her word at the model switch: "you can do another Fable
ladder after the opus implementer")*

**Tally: 0 BLOCKER · 0 MAJOR · 1 MINOR · 4 NIT (one SPECULATIVE)** (committed unedited, `ca6456e9d`). **No new
BLOCKER/MAJOR, so under her cap rule round 2 is the ladder's FINAL round:** its fixes go through the cross-model flow
(implementer agree/dispute → this reviewer's final call → the implementer applies) and then get the orchestrator's
line-by-line check against each finding, since no later round reads them.
- **The MINOR:** NEW-1's mirror-proof arm for an ABSENT live place (a library file replayed with the key file deleted)
  works — the reviewer probed it, memory wins, red-on-old at the round base — but has no committed pin, and the
  generator can never reach it (`rollsBackBothHomes` excludes the pair); the exclusion's comment calls it "the stated
  limit's shape", which is wrong (§3.6's limit is the library file AND the memory item). Fix: commit the probe as a
  fixed scenario; rewrite the comment to the two honest reasons (P-U4-12's whole-pair shape for `.replayKeyFile`; a
  promise-1 false-positive hazard on an Always-ask device for `.deleteKeyFile`), adjudicating the promise-1 reading
  first if the exclusion narrows. A lesser half: no mutation-pin twin for the new roads with the guard off.
- **The NITs:** the U3 harness's `setAsideKeyFiles` is a write-only sink; the mirror and plan-runner restores still
  overwrite a stray file in place (adopt the set-aside helper or record the asymmetry); `beforeRollback` over-records
  for a group whose replay skipped; SPECULATIVE — promise 1's new clause counts a repair "owed" even if the executor
  would forever skip it (no counterexample traced; record and watch the go/no-go soak for a
  `preconditionDoesNotVerify` loop on `rekeyOlderLibraryFile`).
- **The triage's five observations adjudicated:** item 3 escalated into the MINOR; items 1, 2, 4 and 5 acceptable as
  recorded, with 1 (promise 10's breadth) and 5 (a stale act's roll back deleting another library's quiet-road item —
  availability-only, her P-U4-1 frame) for the closeout's hand-forward list.
- **The clean bill** covers every re-check the round-1 final call named (both gates agree; the set-aside
  non-destructive and catalogued; promise 1's clause proven non-blind; the seed-9 pre-settle preserved; the MINOR's
  guard conservative; NEW-2's exemption structurally unable to hide a Castle-born key; NEW-1's settle-first unable to
  misfire on a legitimate mid-act crash). The reviewer's own runs: the 19 new pins green, a 461-test/76-suite
  protection superset green in Debug, a seed-1 × 120 soak slice green with tamper groups live.

## 10. The go/no-go and the key map's model half (filled at close)

*(empty)*

## 11. Closeout

- The STATUS banner flips to CLOSED.
- The design's §1 gains any new ruling.
- QUESTIONS gets the PROVISIONAL calls.
- **The next phase's plan, `notes/plans/vx-306-castle-open-road.md`, is written just-in-time** with its kickoff
  message — every phase's new code on in Debug builds only until her release switch (VX-329), with a check that a
  Release build still runs today's road (design §5, her rulings).
- The handoff `notes/handoffs/vx-305-handoff.md` comes last, with her checklist at the top.
- The PR merges to `main` as a merge commit, at her word.
- MOBILE PARITY: "nothing mobile-visible" (headless phase).
