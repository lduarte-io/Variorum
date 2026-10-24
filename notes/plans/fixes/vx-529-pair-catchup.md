# VX-529 — the catch-up for a pair changed elsewhere

**STATUS: OPEN — the design memo, written before any build (P-5, her R-510-19). Nothing below is built; the
RULINGS NEEDED section is what the sitting decides.** Branch `vx-529-pair-catchup`, worktree `~/dev/variorum-vx-529`,
the custody slot held (the in-flight table). The kickoff is `notes/handoffs/vx-529-kickoff.md`; the repro is the
VX-510 record's THE CHANGED-ELSEWHERE REPRO (`notes/plans/fixes/vx-510-first-run-sync.md`).

## Her mandate (verbatim, binding)

- **R-510-19:** "VX-529: its own run, next" — the shape decided at this kickoff with a design memo (P-5).
- **R-510-20 — THE BOUNDARY:** "ok - no - we are NOT changing the castle rules at all. literally not even close to
  being an option. we DIED to get that design to the point it is in - we aren't changing anything stored anywhere. so
  if you need to type both secrets, that's fine, we just need to present that to users in a way that makes sense.
  because if you had sync, you could move that library aside and let sync fill it in with your account passphrase,
  right? like you COULD get a new library with the new passphrase there."
- So: **no Castle-rule change, no schema event, no vault-shape, key-file-shape or custody-record-shape change.** The
  store-each-library's-key option is withdrawn. Typing both secrets is acceptable; the set-aside-and-rejoin road is
  real and is presented as one (caveat she accepted: unsynced writing stays in the set-aside library).

## The state (the repro, plus the mechanics as traced in code — verify points for the implementer)

A passphrase (or new words) made on device 1 re-locks the account's vault AND device 1's library; rule 7 is silent on
every other device, and the follow covers only posture changes and key replacements
(`Assess.acts`, `Sources/VariorumCore/Protection/Assess/Assess.swift:448-462`: the vault/record comparison is
`mode` and `accountRowKeyID` only — a pair change moves neither). Observed live on production (VX-510 unit C):

- **Castle (Always ask), lagging device:** the account's NEW passphrase refuses the lobby with the bare "That
  passphrase doesn't open this library."; the OLD one opens the library but loads no sync keys (the typed-unlock
  seam logs "opens the library but not the account's vault (changed elsewhere?)" —
  `App/Variorum/Shared/Protection/ProtectionOpenRoad.swift:560`); Settings ▸ Sync offers NO follow and shows the
  stale done-line "…keys changed on another device, and this Mac caught up."; **Change passphrase old → new refuses
  "That passphrase doesn't open this library."** — false; the mechanism is `changePassphrase` verifying the typed
  CURRENT passphrase against the VAULT on a synced library (`Executor/Acts/KeyDoors.swift:208-222`), where the old
  one no longer opens, and the refusal rendering with the library-flavored sentence. The twelve words (unchanged)
  load the sync keys per session — a workaround nobody would find. The check door's fourth answer is already honest
  ("…doesn't open this library, but it opens your account." — P-VX510-B3-2).
- **Standard, lagging device:** quiet roads open the library and sync keeps running (the sync keys and master are
  unchanged by a pair change) — the device's typed passphrase is silently stale; every typed moment (the check door,
  the key doors, a lobby after a quiet-road failure) disagrees with what the user believes their passphrase is.

**The load-bearing traced facts** (each a verify point, not an assumption):

1. **A synced library's key file carries the account's pair, descriptor and all.** The passphrase lock's KDF
   descriptor is the vault's own ("the live key file's passphrase lock is the account's as this library last knew
   it — rule 7's one pair" — `Executor/Acts/Follow.swift:164`, which already uses
   `keyFile.passphrase.kdf != vault.kdf` to name VX-113's changed-elsewhere refusal). The words road is the master's
   twelve-words copy, the vault's recovery wrap **copied byte for byte** (`KeyFile.masterWordsCopy`, §3.5a).
2. **The fresh vault reading already carries both comparison halves:** `VaultReading.kdf` and
   `VaultReading.recoveryWrap` (`Assess/Facts.swift:34-64`), populated by `VaultSnapshot.reading`
   (`Executor/VaultModel.swift:170-174`). `assess` already reads the live key file (`Assess.liveKeyFile`). **Quiet
   detection needs no new stored field and no wire change.**
3. **A synced library's key file carries a master wrap** (`KeyFile.master` — the store key under the account's
   master, with `open(master:)` and `open(wordsThroughMaster:)` as built roads, `Model/KeyFile.swift:245-268`). So
   the account's CURRENT secret can open a lagging library **through the vault**, online: typed secret → the vault's
   master → the key file's master wrap → the store key. This is the words road's existing shape (§3.5a) extended to
   the passphrase; it stores nothing and changes no shape. It is the honest answer to her R-510-19 question ("how is
   new passphrase opens everything even an option…?") — not by storing library keys, but through the master wrap the
   key file already holds.
4. **A pair change writes nothing but the vault's wraps** — same master, same sync key, same library keys. So the
   catch-up is a LOCAL act: re-lock the key file (rule 6's own verb), hold the sync keys; **no server write, no sync
   row, no schema**. Old backups keep opening with their day's secrets (rules 4–5, untouched).

## THE DESIGN (the catch-up's whole behavior on paper)

### 1. Detection — a third follow class, decided quietly in `assess`

With a fresh vault read for the library's account, same posture and same sync key (today's "no follow" arm):

- `keyFile.passphrase.kdf != vault.kdf` (both present) ⇒ **the account's passphrase changed elsewhere**.
- `keyFile.masterWordsCopy != vault.recoveryWrap` (both present) ⇒ **the account's words changed elsewhere**.
- Either or both ⇒ `OwedAct.follow(.pairChanged(passphrase:words:), …)` — a new `FollowKind` case carrying which
  half moved. Posture and key-replacement follows keep precedence (they adopt the pair anyway); an own act in
  flight suppresses it as today; no fresh vault read (offline, signed out) ⇒ no detection, nothing rendered.
- `followOwed` already gates every key and mode door (`Assess.doors`' common gate), so the Change-passphrase wrong
  refusal CLASS closes structurally: in the detected state the door refuses "follow first" with the pair sentence
  (wording below) instead of the false library sentence.
- False-positive guard, named: the build VERIFIES every synced road that writes `settingPassphrase` uses the vault's
  descriptor (the rule-7 invariant fact 1 rests on), with a pin per road.

### 2. The act — the pair catch-up (the follow's third kind)

One planned, crash-safe act (rule 20's plan machinery, as every key-touching act):

- **Verifies** the typed secret against the FRESH vault (never the library): the account's current passphrase when
  the passphrase half moved. A wrong secret refuses NAMING THE ACCOUNT (VX-464's grammar). If the vault moved again
  between door and press: the fresh read inside the act re-verifies; a failed verify refuses, nothing half-done.
- **Re-locks, never re-keys** (rule 6's mirror): the key file's passphrase wrap re-made under the account's current
  passphrase and the vault's descriptor (restores fact 1's invariant); the master's twelve-words copy refreshed byte
  for byte from the vault (`refreshingMasterWordsCopy`); **a stale own-words lock is dropped** (the old words must
  stop opening the live library — one pair; they still open old backups). The library key, its history, the record's
  `accountRowKeyID`, custody items and Apple keys are all untouched — the key did not change.
- **The words half needs no typing** (the join's precedent, R-510-28: "a passphrase join adopts words it never
  shows") — the copy is the vault's bytes. The passphrase half cannot be re-locked without the new passphrase typed.
  So the door types EXACTLY the changed half: passphrase changed ⇒ the account's current passphrase; words-only
  changed ⇒ nothing (a quiet follow, one press, like the follow out of Castle); both ⇒ the passphrase (the words
  ride the copy). The 12-character floor applies as everywhere (the vault descriptor's floor check exists).
- **Holds the account's sync keys** per posture (session in Castle Always-ask; custody's silent class in Standard;
  the Touch ID class only where Castle files it — VX-517's rule), and **runs the first round at once with the
  sheet staying to confirm** — the catch-up is an account act that changes sync's standing (the P-VX510-1
  convention, built at VX-510).
- **The key-file mirror follows** (rule 1/21: the sealed keychain copy refreshes with the live file, the existing
  write road). Backups are never rewritten.

### 3. The faces

- **Settings ▸ Protection, the Sync section:** the follow row speaks the pair sentence and the standing
  "Follow your account…" door serves the third kind (one door for every way the account moved). The sheet: the
  sentence naming the half, device and day — *"Your account's passphrase was changed on ‹device› on ‹day›."* (VX-113's
  sentence family, `ProtectionWords.passphraseChangedElsewhere`; a words change gets its twin) — the one secret field
  where the passphrase moved, the quiet caveat-free confirm where only the words moved, then the first round's
  progress and "Synced. …" exactly as the account acts speak since VX-510. The stale done-line ("…and this Mac
  caught up.") stops rendering while a pair follow is owed.
- **The lobby** (the ruled fork — RULING 1): at minimum, a typed secret that fails every local road, with a
  signed-in session and the vault readable, earns the honest sentence instead of the bare refusal: *"That
  passphrase doesn't open this library. Your account's passphrase was changed on ‹device› on ‹day› — your old
  passphrase or your twelve words still open it. You can catch this Mac up in Settings ▸ Protection."* At her
  option (the stronger road, fact 3): the typed account-current passphrase OPENS the library through the vault's
  master and the key file's master wrap — online and signed in only — and the catch-up lands in the same act with
  the typed secret in hand, one typing, everything converged, a durable notice saying what happened. Offline or
  signed out, the lobby keeps today's bare refusal (no evidence to speak from).
- **The check door:** the fourth answer gains the road's pointer line (*"…but it opens your account. You can catch
  this Mac up in Settings ▸ Protection."*) — reading stays a reading; the door writes nothing.
- **The key doors:** in the detected state the gate's refusal speaks the pair sentence and points at the follow
  (never the false "doesn't open this library"). Outside detection (offline), `changePassphrase`'s vault-verify arm
  distinguishes opens-library-but-not-vault (the VX-113 sentence, best-effort naming) from opens-neither (the plain
  refusal) — the honest split at the one seam that already derives both.
- **The sync row:** unchanged in shape; in Castle the locked line's one door (Protection…) now lands where a follow
  is actually offered.
- **Standard:** same detection, same door, no urgency theater — sync runs; the sentence simply tells the truth about
  the typed pair.
- **The second road, said beside** (hers, R-510-20): one quiet line in the follow sheet — *"You can also set this
  library aside and re-join your account: a fresh library fills from sync under your account's current secrets.
  Writing that never synced stays in the set-aside copy."* — pointing at the existing doors (no new machinery; the
  set-aside/adopt/join roads are VX-329/VX-308's, whole and walked).

### 4. Edges, enumerated

| # | Edge | The behavior |
|---|---|---|
| E1 | Offline / vault unreachable / signed out | No detection, no door, no sentence; typed moments keep today's honest refusals; the check door says "couldn't reach your account". |
| E2 | Pair changed AND posture/key moved elsewhere | The posture/keysReplaced follow outranks and adopts the pair itself; the pair kind fires only on same-posture-same-key. |
| E3 | Own act in flight | Suppressed, as every follow is today. |
| E4 | The pair changes again mid-act | The act's fresh read re-verifies the typed secret; a failed verify refuses naming the account; nothing lands half-way (rule 20's plan). |
| E5 | Both halves changed | One typed passphrase; the words ride the vault's copy; the notice names both. |
| E6 | Synced library with NO local passphrase lock (joined by words, passphrase never typed here) | Not a changed-elsewhere state — no kdf leg to compare; the words leg still detects; the vault road (if ruled) still opens by the account's passphrase online. Pre-existing, recorded, not this run's to widen. |
| E7 | Old backups | Open with their day's secrets forever (rules 4–5); the catch-up rewrites no backup. |
| E8 | The recorded old words after a words change | Stop opening the LIVE library (the stale own-words lock drops); still open old backups. The durable notice says so plainly — the words themselves can never be shown (nothing stores them; they changed on the other device). |
| E9 | Multiple lagging devices | Each catches up independently; the act writes nothing to the server, so there is no race to converge. |
| E10 | The fenced dev store | Inert (no sync, no vault read). |
| E11 | Mobile | The phone shares the core; its faces are the mobile catch-up's — a MobileSoul ledger row at closeout. |
| E12 | The restore hold | A held library runs no round; detection needs a fresh vault read, which the hold's Resume gate precedes — the follow offers after Resume, as F-4 shaped the other synced acts. |

### 5. What deliberately does not change

The Castle rules (frozen, R-510-20); the schema and every stored shape (vault, key file format 3, custody record,
protection record — the key file's existing optional fields are written through existing setters only); the sync
protocol and `Sources/VariorumCore/Sync/` (expected zero lines — the act is protection-local; if any line proves
needed it is Fable work by standing rule); the words-never-stored rule; rule 5's backup floor; the one-pair rule
(this run makes it TRUE on lagging devices, which is the whole point).

## THE RULINGS (2026-10-24, her sitting — via the question tool; answers verbatim-faithful)

- **R-529-1 — the lobby OPENS THROUGH THE VAULT** (ruling 1, her pick: "Open through the vault (Recommended)") —
  after her clarifying questions, answered before the pick: the online step is the one authenticated vault read
  fetching wrapped blobs (the typed passphrase never leaves the Mac); the open itself writes nothing and the
  catch-up re-wraps the key file in the same act, so the network is needed exactly once; the library key and store
  are never re-encrypted; unsynced libraries cannot be in this state at all (no elsewhere, no vault, no master
  wrap). Her words at the clarification: "Have we considered the implications of using the vault master? will that
  even rewrap the library? because for people without sync, opening the library online can't happen right? i guess
  this only an issue for people with sync though. I think that option 1 can probably make sense but how is it
  happening online?"
- **R-529-2 — the words-only change is QUIET with a durable notice** (ruling 3, her pick: the recommended arm).
- **R-529-3 — Change passphrase REFUSES, pointing at the follow** (ruling 4, her pick: the recommended arm).
- **R-529-4 — RIDERS: VX-526 · VX-522 · VX-523 · VX-533** (ruling 7, her picks; VX-530 not taken — her note, verbatim:
  "ade 522 and 523 wording intl? and is being asked twice a sign of a worse, more signicant vug?" — read as "are 522
  and 523 wording only?" and "is being asked twice a sign of a worse, more significant bug?"; answered in the sitting
  reply: VX-522 is a conditional-sentence fix (Wording-labeled), VX-523 is a small condition bug in the same notice
  family (when it speaks, not what it says); VX-530's visible half is a custody-read-before-secrets ordering at the
  session-hold seam (`KeyDoors.holdSyncKeysForTheSession` reads the Touch ID class before trying the typed secret it
  was handed — the VX-503 class one seam over), no evidence of a custody-integrity issue; offered as a TRACE-FIRST
  rider, her call pending).
- **PROVISIONAL, defaulted un-objected (the standing rule; QUESTIONS at closeout):** **P-VX529-1** (ruling 2: the
  standing "Follow your account…" door serves the pair kind — one door for every way the account moved) ·
  **P-VX529-2** (ruling 5: the second road's line lives in the follow sheet only; the lobby stays calm) ·
  **P-VX529-3** (ruling 6: every drafted sentence built as drafted, provisional for her pass — the R-510-26
  precedent).

## The rulings as asked (kept for the record — the questions the sitting answered)

- **RULING 1 — the lobby's reach.** (a) Say-and-point: the honest sentence at a failed typed attempt; open with the
  old secret or the words; catch up in Settings. (b) The vault road: the account's current passphrase also OPENS the
  library online (fact 3) and the catch-up lands in the same act — one typing. (b) contains (a) as its offline face.
  The architect recommends (b): it answers her original question literally ("if you type the secret… shouldn't the
  library follow?"), uses only existing stored material, and keeps the lobby rule-honest (typed + online, never a
  quiet road). Cost: it touches the lobby's open path, the most sensitive face — the ladder and the live proof bear
  down on it.
- **RULING 2 — the door's identity.** The standing "Follow your account…" door serves the pair kind (recommended:
  one concept — the account moved, this Mac follows), or a separate door with its own name.
- **RULING 3 — the words-only change is quiet.** Recommended: one press, nothing typed (the join's
  adopts-words-it-never-shows precedent), with the durable notice (E8). The alternative: require typing the new
  twelve words as a deliberate reminder moment (rule 14's spirit) — more friction, more honesty about what you hold.
- **RULING 4 — Change passphrase in the detected state.** Recommended: refuse with the pair sentence pointing at the
  follow (one road to one act). Alternative: old → account's-current typed there behaves AS the catch-up (a hidden
  synonym of the follow; the architect recommends against two doors to one act, but the instinct-path argument is
  real).
- **RULING 5 — the second road's placement.** Recommended: the quiet line in the follow sheet only (the lobby stays
  calm). Alternatives: also in the lobby sentence, or nowhere (it exists regardless).
- **RULING 6 — the wordings.** Every sentence above is a DRAFT in the P-VX510 bundle's style; hers to rule now or
  built-provisional for her pass (the R-510-26 precedent).
- **RULING 7 — riders.** Open Castle & sync tickets this run's code opens anyway: **VX-526** (the join sheet still
  titled "Turn on sync" + W-12's "backups you made before today" — the kickoff names it; the follow/join faces are
  open in this run) · **VX-522** (the hold banner's sync promise on an account-less restore) · **VX-523** (the
  words-adoption notice on a restored copy whose words already match) · **VX-533** (a missed lobby Touch ID prompt
  can't be re-asked — the lobby is open in this run if RULING 1(b)) · **VX-530** (the double Touch ID on a Castle
  key door). Her picks, if any.

## ACCEPTANCE (the evidence, per unit)

- **Unit 1 — the core (one implementer session):** detection + the act + the refusal split, all state-transition
  tested headless (assess tables for the third kind and its gates; the executor act's exact row/file transitions;
  the invariant-1 pins per synced `settingPassphrase` road; red-on-old pins for the wrong-refusal class and the
  no-follow-offered class, verified by revert).
- **Unit 2 — the faces (one implementer session):** the follow sheet's third kind, the lobby face per RULING 1, the
  check door's pointer, the key-door refusal wording, the stale done-line, the second-road line; riders if ruled.
- **The ladder:** Fable cold review mandatory (custody seams), fresh reviewer per round, REVIEW_PROMPT verbatim.
- **The live proof (the orchestrator's walk, prod test road):** re-run the VX-510 repro's exact legs on the `castle`
  account (the state it was left in: Standard, rev 15+, passphrase PASSPHRASE2) — change the passphrase on one
  library, verify the lagging one: the lobby sentence (and the vault-road open if ruled), the follow lands, the
  round confirms, the check door's answers, the key doors' refusals. Standard AND Castle legs.
- **HER TEST, the release gate (her words at this kickoff):** with the fix installed on BOTH Macs behind A1, she
  changes the passphrase on the Pro or the Air and verifies the other Mac catches up. The release follows her green,
  not the walk's.

## UNIT 1 — THE BRIEF (a fresh `opus-implementer`, one session; the CORE: detection + the act + the refusal split, headless)

**Read first, in full, yourself (never delegated):** CLAUDE.md and its auto-loaded canon; `notes/SessionResiliencyProtocol.md`;
`notes/CastleRules.md` WHOLE; `notes/SyncSpec.md` WHOLE (custody-adjacent work); SurfaceContracts' protection bullet;
THIS FILE WHOLE (the memo, THE RULINGS, the edges table); the VX-510 record's ENVIRONMENT TRAPS and THE
CHANGED-ELSEWHERE REPRO sections (`notes/plans/fixes/vx-510-first-run-sync.md`). The code: `Sources/VariorumCore/Protection/Assess/Assessment.swift`
(FollowKind, OwedAct, DoorRefusal), `Assess.swift` (acts :435-480, doors' common gate :510-537, liveKeyFile),
`Facts.swift` (VaultReading), `Executor/Acts/Follow.swift` whole (FollowProgram; the VX-113 arm at :164),
`Executor/Acts/KeyDoors.swift` (:170-280 — changePassphrase, holdSyncKeysForTheSession), `Model/KeyFile.swift`
(the wraps, setters, open roads), `Executor/VaultModel.swift` (:150-180), `Model/ProtectionRecord.swift`, and the
suites `Tests/VariorumCoreTests/Protection/AssessTests.swift`, `AssessFixtures.swift`, `Executor/` (the key-door and
follow suites), `KeyFileTests.swift`.

**The scope (one acceptance unit; the faces are UNIT 2's — nothing app-side in this unit):**
1. **Detection (assess):** the third follow class per the memo's design §1 — a new `FollowKind` case carrying which
   half moved (passphrase/words), decided in `Assess.acts`' same-posture-same-key arm from
   `liveKeyFile.passphrase.kdf != reading.kdf` and `liveKeyFile.masterWordsCopy != reading.recoveryWrap` (both-present
   legs only; posture/keysReplaced follows keep precedence; own act in flight suppresses; no fresh vault ⇒ nothing).
   The existing `followOwed` gate then covers every key/mode door unchanged.
2. **The act (executor):** the pair catch-up per design §2 — re-lock, never re-key: the passphrase wrap re-made under
   the typed account-current passphrase with the VAULT's descriptor (verified against the fresh vault first; a wrong
   secret refuses naming the account); `refreshingMasterWordsCopy` from the vault; the stale own-words lock DROPPED;
   the record, key, history, custody items and Apple keys untouched; the key-file mirror refreshed through the
   existing write road; the sync keys held per posture; rule 20's plan (crash leaves old state or new, the next open
   finishes or rolls back). The words-only case types nothing (R-529-2). **The program shape is a design fork
   reserved for the architect:** FollowProgram runs `LibraryRekey` steps, which this act must NOT — propose your
   shape (a no-rekey path inside FollowProgram vs a sibling re-lock program on the key doors' plan machinery) in the
   LIVE STATUS section and WAIT for the architect's ruling before building that half.
3. **The refusal split (KeyDoors.changePassphrase):** the vault-verify arm distinguishes opens-library-but-not-vault
   (⇒ `ExecutorRefusal.passphraseChangedElsewhere(device:day:)` — the arm Follow.swift :164 already shapes, moved to
   fire here too) from opens-neither (⇒ the plain refusal). No new sentence minted in this unit (the faces render).
4. **The invariant verification (fact 1's guard):** verify every synced road that writes `settingPassphrase` uses the
   vault's descriptor; a pin per road (an existing-behavior pin, not a fix).
**Deliberately out of scope:** the lobby's vault-road open and the catch-up-at-open flow (R-529-1 — unit 2 wires it
through this unit's act), every face and sentence, the riders, anything in `Sources/VariorumCore/Sync/` (expected
ZERO lines — a need for one is a STOP-AND-REPORT, Fable's by standing rule), any schema or stored-shape change (the
key file's existing optional fields through existing setters only; a words-lock dropper on the VALUE is legal).

**The discipline:** pins red-on-old committed BEFORE fixes where a bug-class is claimed (the no-follow-offered state;
the false-refusal class), reverts named then run; headless `swift build` / `swift test` ONLY (no stage, no app
launch, no xcodebuild test, no store/server/production contact, no subagents); work in `~/dev/variorum-vx-529`;
commit per piece with "Part of VX-529", NO attribution trailers (CLAUDE.md's rule overrides the harness reminder);
push after every commit; LIVE STATUS below from the first commit, every unverified claim PENDING.

### UNIT 1 — LIVE STATUS (the implementer owns this section)

**NOT DONE IN THIS UNIT (so far): the act's program (scope 2's fork half) — WAITING on the architect's ruling below; no
face, no sentence, no rider, zero `Sync/` lines.** Session: a fresh `opus-implementer`, 2026-10-24, worktree
`~/dev/variorum-vx-529`. **A REVERT IS IN FLIGHT (P1): `KeyDoors.swift`'s `changePassphrase` throw line back to the
plain refusal; the fix is committed at `1ccdd5b27` — restore with `git checkout -- Sources/VariorumCore/Protection/
Executor/Acts/KeyDoors.swift` (read `git diff` to see what is reverted).**

**Read first (all read in full, in this session):** CLAUDE.md + the loaded canon; `notes/SessionResiliencyProtocol.md`;
`notes/CastleRules.md`; `notes/SyncSpec.md`; SurfaceContracts' protection bullet; this file whole; the VX-510 record's
ENVIRONMENT TRAPS + THE CHANGED-ELSEWHERE REPRO. Code: `Assessment.swift`, `Assess.swift`, `Facts.swift`, `Follow.swift`,
`KeyDoors.swift`, `KeyFile.swift`, `KeyFileCrossings.swift`, `VaultModel.swift`, `ProtectionRecord.swift`,
`ProtectionVocabulary.swift`, `DeviceSection.swift`, `Plan.swift`, `PlanRunner.swift`, `CommonSteps.swift`,
`Executor.swift`, `AccountActs.swift`, `EnterCastle.swift`, `LeaveCastle.swift`, `ReplaceAllKeys.swift`; the suites
`AssessFixtures`/`AssessTests`/`ExecutorWorld`/`ExecutorFixtures`/`FollowTests`/`AccountActTests`/`CrashHarness`/
`KeyFileTests`/`U4LaggingPairScenarios`, the scenario world's follow/key-door actions (`Alphabet.swift`).

**The pieces (flip per commit; unverified claims PENDING):**
- P0 — this LIVE STATUS. DONE (this commit).
- P1 — scope 3, THE REFUSAL SPLIT at `changePassphrase`'s vault-verify arm. IN-PROGRESS — the red pin COMMITTED
  (`Executor/PairRefusalSplitTests.swift`): RED on the pre-fix tree, both postures, for the repro's exact reason —
  `expected .passphraseChangedElsewhere(device: "Mac A", day: …) but .passphraseDoesNotOpen was thrown`; its two
  companions (opens-neither; nothing changed elsewhere) green. THE FIX COMMITTED: `refusalForAPassphraseTheVaultRefuses`
  (`KeyDoors.swift`) — opens this library's own lock under a descriptor the vault no longer carries ⇒
  `passphraseChangedElsewhere(device:day:)`, else `passphraseDoesNotOpen` — thrown at `changePassphrase`'s arm only
  (F-4's siblings untouched). Green with its neighbours (42 tests: the key-door, follow and session-hold suites).
  Remains: the behavioral revert (the one `throw` line back to the plain refusal), then restore.
- P2 — scope 4, THE INVARIANT PINS (fact 1's guard): one existing-behavior pin per synced road that writes a passphrase
  lock or the master's words copy. NOT-STARTED.
- P3 — scope 1, DETECTION: a behavior-level red pin first (compiles on the old tree), then `FollowKind.pairChanged`,
  the pure pair reading, the acts arm, the follow door's spec for the third kind. NOT-STARTED.
- P4 — scope 2, THE ACT'S PURE PIECES (fork-independent): the key file's words-lock dropper (a value setter) and the
  re-lock transform + its landed predicate, unit-tested. NOT-STARTED.
- P5 — scope 2, THE FORK PROPOSAL written here, then REPORT BACK. NOT-STARTED.
- P6 — scope 2, THE ACT'S PROGRAM — only after the architect's ruling lands in this record. BLOCKED (the fork).

**Findings before any code (traced in this session; each says what it changes):**
- **F-1 — `FollowKind` gaining a case breaks four EXHAUSTIVE app-side switches** (`ProtectionAccountActs.swift`
  `FollowDoneMark.name`; `ProtectionWords.swift` `followNotice` / `followAsk` / `followDone`), and this unit verifies
  headless only. PROVISIONAL (the architect may reverse it): the four MECHANICAL compile arms land with P3 and mint NO
  sentence — `.pairChanged` folds into `.keysReplaced`'s existing words; the mark's stored name is `"pairChanged"`, not
  read back by `owed` (reads as none) — every one marked UNIT 2's to replace. Their compiling is PENDING (no
  `xcodebuild` in this unit).
- **F-2 — a pre-fork guard is required:** `FollowProgram.kind` reads any unknown `follow` name as `.keysReplaced`, so
  `follow(kind: .pairChanged)` before the act exists would RE-KEY the library. Until P6, the core's `follow` refuses
  the third kind `nothingToDo` (nothing begun).
- **F-3 — the scenario world presses every owed follow** (`SWorld.settleWorld`, `Alphabet.swift`), so once P6 lands the
  act gets the generator's random coverage under every promise; before it, the refusal of F-2 is a harmless refusal.
- **F-4 — the same false-refusal class sits at two sibling seams** the brief does not name: `regenerateWords`' synced
  arm (`KeyDoors.swift:314`) and `doorSecrets`' synced arm (`EnterCastle.swift:99` — Use Castle / Use Standard / Replace
  All Keys). In the detected state `assess`'s `followOwed` gate closes them; at a press racing a change elsewhere they
  still say "doesn't open this library". NOT changed here (one surface — the brief names `changePassphrase`); offered.
- **F-5 — `Follow.swift:164` names the change on the descriptor alone** (best-effort: garbage typed after a change
  elsewhere also reads "changed elsewhere"); the brief's split at the key door requires the typed passphrase to OPEN
  the library too. The follow's arm is left as it is (no behavior change outside the brief).
- **F-6 — the MAJOR-1 residue reads as a pair change on the device itself:** a Change passphrase whose vault write
  landed and whose key-file step rolled back (`KeyDoorProgram.resumeCannotFinish`) leaves the key file's lock under
  the old descriptor beside the vault's new one — detection then owes this device the passphrase half's catch-up, with
  this device named as the changer. A TRUE state, honestly said; PROPOSED as edge E13 (the table is the architect's).
- **F-7 — the words-only catch-up needs the account's MASTER in hand** to verify the refreshed copy reaches the key
  file's master wrap before the stale own-words lock goes (rule 22: "a key is deleted only after its replacement has
  been verified"). Custody's silent class (Standard), the session (a Touch ID unlock or a typed passphrase at the
  lobby — VX-501/VX-487) hold it; a Castle Always-ask library unlocked by its OLD words holds none (the typed unlock's
  vault read cannot open the vault with them). There the quiet act refuses `secretMissing` and the face asks the
  passphrase — PROVISIONAL, PROPOSED as edge E14, unit 2's face.
- **F-8 — the app routes an account act by `spec.rekeys`** (`RoadAccountModel.swift:509-516`): a re-keying act closes
  the pool and reopens; one that changes no key runs on the open session. The third kind's door says `rekeys: false`,
  so the app's existing road already runs it on the open session (unit 2's to confirm).

## Machinery

The standing cast (Fable orchestrates and cold-reviews; Opus implements, fresh per unit); pin-before-fix per member;
commits "Part of VX-529", no trailers; SessionResiliencyProtocol binds (commit per piece, LIVE STATUS from the first
commit, push after each, foreground waits); the stage only for walks/suite runs/refreshes; the dev store's rules and
`~/.variorum/dev-castle.env` for any dev-store Castle walk; the prod test road only through the VX-510 tools
(`Tools/WalkKit/first-run-walk.sh` env, `Tools/prod-confirm-test-user.sh`), secrets via the `~/.variorum/bin`
helpers. Environment traps: the VX-510 record's ENVIRONMENT TRAPS section binds verbatim for every session of this
run.
