# VX-305 — Castle rebuild, phase 1: the headless core

**Status: READY, not started (plan written 2026-10-13).**

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
>   (`reconcile`), `PostureSwitch.swift` (the runner), `LibraryOpenModel.swift`, `StoreBackup.swift`,
>   `BackupRetention.swift`.
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
   of up to 60 steps, under `swift test` in a reasonable time. Record the time.
2. **Every fixed scenario in §6 is green.**
3. **Every mutation pin is red with its guard disabled** and green with it.
4. **A Fable cold-review ladder is closed** — at most three rounds, with every finding dispositioned here.
5. **The model half of the key-map table is written:** one row per element of the target key map, naming the test
   that proves the model does it. The code half comes at phase 5.

**Cast:**

- Fable orchestrates and cold-reviews; Opus implements (CLAUDE.md's standing cast).
- This phase writes no `Sync/` line, but it is the custody effort's start, so it holds the one Sync/-or-custody slot
  (the stage coordinator grants it).
- No stage is needed.

---

## 2. The shape of the code (names are the design's; refine with a recorded reason)

```
Sources/VariorumCore/Protection/
  Model/      ProtectionRecord · KeyFile (format 3: wraps + history; readers for formats 1 and 2) ·
              DeviceMemory (+ sealed fields, + key-file mirror) · Plan (+ seal) · Seal (HKDF + HMAC) ·
              Names (custody item, sync-keys item, memory item, Apple key: <scope>-apple-key-<id>, legacy name)
  Assess/     Facts · Assessment · assess(_:) · Roads · RouteFinder · Catalog (one name parser; attribution
              to library + Mac) · Retention (per library per Mac; legacy flat files never pruned)
  Executor/   Leaves (protocols: Custody, SyncKeys, AppleKeys, Vault, LibraryFile, KeyFileStore, MemoryStore,
              PlanStore, Backups, Clock, IDs, Biometry/LAEnvironment) · Executor (repairs + plan runner) ·
              Acts/ (one file per act: EnterCastle, LeaveCastle, ReplaceAllKeys, Follow, OpenCopy, Migration,
              LegacyAppleKeyQuestion, SetUpSync, Enroll, Move, ThisMacOnly, StopSyncingHere, ChangePassphrase,
              RegenerateWords, GateStyle, TouchIDRearm)
Tests/VariorumCoreTests/Protection/
  ModelTests · AssessTests · RouteFinderTests · CatalogTests · RetentionTests · ExecutorTests (per act,
  per step, per crash point) · Scenario/ (World, Fakes, Alphabet, Promises, Generator, FixedScenarios,
  MutationPins)
```

**Two rules shape the leaves:**

- **The executor is the only thing that calls a writing leaf.** `assess` takes plain values and calls nothing.
- **Guards the mutation pins switch off** live in one `ProtectionGuards` value whose off-switches exist only under
  `#if DEBUG`. Release builds strip them, as with the store's DEBUG oracles.

---

## 3. U1 — the model

Build everything in §3.2 of the design as values, with their codecs and their crypto:

- **The protection record**, as a value and its fields. The SQLite table comes in phase 2.
- **Key file format 3:**
  - the current key's wraps — passphrase with its KDF descriptor, words, master, Apple key with its id;
  - the history: every older key wrapped directly under the current key, with fingerprint, epoch and retirement date;
  - re-keying: L → L′ re-wraps the whole history under L′ and adds L.
- **Readers for formats 1 and 2.** Old key files are read forever, and the catalog and route finder use them.
- **What this Mac remembers:** its fields, the key-file mirror and the sealed subset.
- **Plans,** sealed under the key in hand, naming its fingerprint.
- **The seal:** `HMAC-SHA256(HKDF-SHA256(ikm: L, salt: libraryID, info: "variorum.seal.v1:" + purpose), canonical
  JSON)`.
- **The item and Apple-key names**, with the store-variant scope in every name.

**Tests (pure):**

- round-trips for each value;
- every wrap opens with the right secret and refuses a wrong one;
- the history survives three re-keys, with every old key still reachable from the newest and never the reverse;
- a tampered sealed field fails verification;
- format-1 and format-2 key files read as the design says;
- no secret appears in any value written to disk (scan the encodings).

---

## 4. U2 — assess, roads, the route finder, the catalog, retention

- **`assess(Facts) → Assessment`, pure.** It returns:
  - the mode and the account, each confirmed or not;
  - the roads;
  - every door with its reason;
  - the repairs owed and the acts owed;
  - the words, as typed reasons for later phases to render.
- **The rules it encodes:** design §3.3 (guards included), §3.7 (the open rule's verdicts), §3.8 (the four account
  situations), §3.10 (the Touch ID road, with VX-310's lobby rule as data: when a button is offered, when a reason
  is shown instead, and never a line with no finger enrolled).
- **The route finder** over a catalog, for every copy kind.
- **The catalog's one name parser,** covering every filename today's builds have written. Read the three existing
  parsers and keep their union.
- **Attribution and retention** per design §3.7.

**Tests:** table-driven.

- every row of the four-account table;
- every road combination;
- every copy kind against every library state;
- retention over a shared folder holding two Macs' and two libraries' copies, where nothing foreign is pruned;
- the route finder's words agree with the roads it found.

---

## 5. U3 — the executor and the acts

**The executor** runs:

- the repairs of design §3.3, each idempotent, verified before any delete;
- every act of design §3.9 as a **sealed plan**:
  - steps resume from the first unfinished one;
  - prepare-then-commit: the new key's custody item and the new key file — with the old key in its history — exist
    before the library is re-encrypted;
- the Apple-key rules of §3.5:
  - names by id;
  - one minter, so followers wait;
  - retire on entering Castle;
  - delete on sight;
  - a fresh key on leaving;
  - the legacy question only after the fold.

**Its leaves are protocols.** U3 tests against simple in-memory leaves; U4 brings the realistic fakes.

**Tests — state transitions for every act:**

- the exact writes in order;
- a crash injected after every step, then a resume that finishes or rolls back, never a third state;
- every refusal named;
- decision 35's guard: nothing Apple-reachable without a fresh vault read;
- a failed seal: the plan is ignored and the setting reads the stricter value.

---

## 6. U4 — the scenario world

### The world

The design's §4.1, whole:

- two Macs and a phone;
- two Apple accounts and two Variorum accounts;
- the fakes, with real semantics:
  - a device keychain where Touch ID items die on an enrollment change, a closed lid is transient, and Keychain
    Access can read, edit and delete every item that isn't a Touch ID item;
  - an iCloud Keychain with a propagation delay, delete propagation and no recovery;
  - file systems with copies, Time Machine rollback and container deletion;
  - a vault with CAS, the key proof and the rotation fields;
- real key files and wraps, with test-speed KDF parameters (the existing test descriptors), and stand-in library
  files keyed by their key fingerprint and carrying their record.

### The alphabet

The user's acts and the adversary's acts in §4.1, each one step.

### Starting states

Every shape today's builds leave, built as fixtures from the old formats:

- exposed;
- Standard-waiting;
- VX-202's and VX-209's victims;
- Castle with no Touch ID;
- signed out with keys;
- a deleted account;
- a stuck VX-235 marker;
- the legacy shared Apple key with pre-Castle copies;
- two Macs sharing an iCloud Drive backup folder.

### The promises

The design's §4.1 list (eleven), checked after every step.

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
- the legacy fold, then retirement — no stranded copy;
- a follow while the fresh Apple key hasn't arrived (no second key minted);
- the lid closed at Castle entry;
- a biometry change, then the re-arm question;
- her signed-in/out/other-account sequence (the design's §3.8 walk);
- a Castle copy from another Mac into a Standard library (it raises, never lowers).

### Mutation pins

Each fixed scenario that guards against a known bug runs once more with its guard switched off (`ProtectionGuards`,
DEBUG only) and **must fail**. That is the red-on-old for new code. Record the failing assertion for each.

### The generator

Seeded and reproducible: a failing seed prints its minimal sequence. It runs as part of `swift test`, with a count
small enough for the everyday loop, plus a `PROTECTION_SOAK=1` environment switch for the go/no-go run.

---

## 7. LIVE STATUS (flipped in the same commit as each piece; PENDING = unverified)

- U1 — the model: **NOT-STARTED.**
- U2 — assess, roads, route finder, catalog, retention: **NOT-STARTED.**
- U3 — the executor and the acts: **NOT-STARTED.**
- U4 — the scenario world, fixed scenarios, mutation pins, the generator: **NOT-STARTED.**
- The go/no-go record: **NOT-STARTED.**

---

## 8. Records (each unit appends its record here: what shipped, tests and counts, PROVISIONAL calls, commits, machinery notes)

*(empty)*

## 9. The ladder (the Fable reviewer's report per round, committed unedited, then the dispositions)

*(empty)*

## 10. The go/no-go and the key map's model half (filled at close)

*(empty)*

## 11. Closeout

- The STATUS banner flips to CLOSED.
- The design's §1 gains any new ruling.
- QUESTIONS gets the PROVISIONAL calls.
- **The next phase's plan, `notes/plans/vx-306-castle-open-road.md`, is written just-in-time** with its kickoff
  message.
- The handoff `notes/handoffs/vx-305-handoff.md` comes last, with her checklist at the top.
- The PR merges to `main` as a merge commit, at her word.
- MOBILE PARITY: "nothing mobile-visible" (headless phase).
