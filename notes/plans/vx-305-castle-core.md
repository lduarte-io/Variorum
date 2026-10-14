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
- U2 — assess, roads, route finder, catalog, retention: **IN-PROGRESS** (Opus implementer, 2026-10-14; reading done —
  CLAUDE.md and canon, the resiliency protocol, the design whole, this plan whole, SyncSpec §3, pre-13x §1–§7 and §14,
  the Apple facts, the listed core and app files). Pieces, each its own commit: (a) the catalog — the one name parser
  (the union of `StoreBackup.date(fromBackupURL:)`/`BackupRestoreCandidates.backupDate`, `LibraryClassifier`'s pair
  rules, and `LibraryAdoption.adoptionStamp`/`LibraryAsideCopies`' stamp folders) and attribution to library + Mac —
  DONE (this piece's commit; `CatalogNameTests` + `CatalogAttributionTests`, 7 tests green, filtered); (b) retention per library per Mac — DONE (this piece's commit, with U2's fifteen guards declared in `ProtectionGuards` — each proven by its piece's DEBUG mutation pin; `RetentionTests` + `RetentionGuardMutationTests`, 6 tests green, filtered); (c) the route finder, the *Opens with* line, the
  finder without the old shared key, the retirement's list, the anchor sentences — DONE (this piece's commit;
  `RouteFinderRoadTests` + `AnchorSentenceTests` + `RetirementRoutesTests`, 12 tests green, filtered — every named
  opener's witness road WALKED with the real secret of its day; with a recorded model refinement:
  `CastleAnchor.directFingerprints`, and the catalog's aside key files carry their folder's day and listed dates); (d) `assess`: facts,
  the mode and account verdicts, the vault's three states, the four situations, the Touch ID road — NOT-STARTED;
  (e) `assess`: repairs with §3.3's guards, acts owed, doors with reasons, the open rule — NOT-STARTED; (f) U2's
  `ProtectionGuards` and their DEBUG mutation tests, both configurations' runs, the record — NOT-STARTED.
- U3 — the executor and the acts: **NOT-STARTED.**
- U4 — the scenario world, fixed scenarios, mutation pins, the generator: **NOT-STARTED.**
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

## 9. The ladder (the Fable reviewer's report per round, committed unedited, then the dispositions)

*(empty)*

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
