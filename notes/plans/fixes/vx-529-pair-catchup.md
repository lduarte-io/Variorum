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

**NOT DONE IN THIS UNIT: every face and sentence (unit 2's — F-1's four app arms are mechanical placeholders); the
riders; F-9 (hers); F-10 (needs a new refusal and its sentence); the app's compile (the orchestrator's xcodebuild).
Zero `Sync/` lines.** The act's program LANDED on the architect's ruling (P6) — Shape A, with two plan-shape refinements
the ruling's R-arch-3 asked for (S-3 by the plan carrying no descriptor; the re-lock folded into `pickUpKeys`), each
stated with its mechanism under P6c/P6d. Session: a fresh `opus-implementer`, 2026-10-24, worktree
`~/dev/variorum-vx-529`. No revert is in flight.

**Read first (all read in full, in this session):** CLAUDE.md + the loaded canon; `notes/SessionResiliencyProtocol.md`;
`notes/CastleRules.md`; `notes/SyncSpec.md`; SurfaceContracts' protection bullet; this file whole; the VX-510 record's
ENVIRONMENT TRAPS + THE CHANGED-ELSEWHERE REPRO. Code: `Assessment.swift`, `Assess.swift`, `Facts.swift`, `Follow.swift`,
`KeyDoors.swift`, `KeyFile.swift`, `KeyFileCrossings.swift`, `VaultModel.swift`, `ProtectionRecord.swift`,
`ProtectionVocabulary.swift`, `DeviceSection.swift`, `Plan.swift`, `PlanRunner.swift`, `CommonSteps.swift`,
`Executor.swift`, `AccountActs.swift`, `EnterCastle.swift`, `LeaveCastle.swift`, `ReplaceAllKeys.swift`; the suites
`AssessFixtures`/`AssessTests`/`ExecutorWorld`/`ExecutorFixtures`/`FollowTests`/`AccountActTests`/`CrashHarness`/
`KeyFileTests`/`U4LaggingPairScenarios`, the scenario world's follow/key-door actions (`Alphabet.swift`).

**The pieces (flip per commit; unverified claims PENDING):**
- P0 — this LIVE STATUS. DONE (`25c7adca4`).
- P1 — scope 3, THE REFUSAL SPLIT at `changePassphrase`'s vault-verify arm. DONE (`4fd6d904f` pin, `1ccdd5b27` fix) — the red pin
  (`Executor/PairRefusalSplitTests.swift`): RED on the pre-fix tree, both postures, for the repro's exact reason —
  `expected .passphraseChangedElsewhere(device: "Mac A", day: …) but .passphraseDoesNotOpen was thrown`; its two
  companions (opens-neither; nothing changed elsewhere) green. THE FIX COMMITTED: `refusalForAPassphraseTheVaultRefuses`
  (`KeyDoors.swift`) — opens this library's own lock under a descriptor the vault no longer carries ⇒
  `passphraseChangedElsewhere(device:day:)`, else `passphraseDoesNotOpen` — thrown at `changePassphrase`'s arm only
  (F-4's siblings untouched). Green with its neighbours (42 tests: the key-door, follow and session-hold suites).
  VERIFIED BY REVERT: the one `throw` line back to the plain refusal ⇒ the pin RED again (both postures, the same
  `passphraseDoesNotOpen`); restored by `git checkout` ⇒ 3/3 green.
- P2 — scope 4, THE INVARIANT PINS (fact 1's guard). DONE (`577b0898e`) — `Executor/PairInvariantPinsTests.swift`: one
  existing-behavior pin per synced road that writes a passphrase lock or the master's words copy — set up sync (both
  postures); the join in the same posture by the passphrase and by the words (E6's state: the library's own lock
  dropped); the join into Castle (by either secret) and out of it; Move; the follow into Castle (by either secret), out
  of Castle (quiet), and catching up on replaced keys; Use Castle and Use Standard synced; Replace All Keys, Change
  passphrase, Reset forgotten passphrase and New words (both postures each); New words minting the gone-everywhere file
  (both). After each: any passphrase lock is under the VAULT's descriptor, the master's words copy IS the vault's
  recovery wrap, and the road leaves the lock it should. 24 cases green on the tree as it stands (the trace in F-list
  confirmed: every synced setter derives under, or writes, the vault's descriptor; the copy is always the fresh read's).
  Plus a NEGATIVE CONTROL (`withKnownIssue`): a lock planted under another descriptor and a stale copy are each caught.
- P3 — scope 1, DETECTION. DONE (`98a183538` pin, `c909ee285` fix, `eab973d13` the revert's record) — RED first (`AssessPairRedPins`, behavior-level,
  compiling on the old tree: no follow owed, no follow door, Change passphrase / New words open — both postures, a
  passphrase and words changed elsewhere), now green. Built: `FollowKind.pairChanged(passphrase:words:)`
  (`Assessment.swift`); the pure reading `AssessRules.pairFollow(keyFile, reading)` — the passphrase lock's
  descriptor against `VaultReading.kdf`, the master's words copy against `VaultReading.recoveryWrap`, both-present
  legs only — over `currentKeyFile` (the live file only when it is the current key's); `acts`' same-posture arm
  appends it AFTER the `keysReplaced` test (E2: posture and key follows outrank it), `typesOneSecret` = the passphrase
  moved; the follow door's spec for the third kind: `DoorSpec(requires: passphrase ? .currentPassphrase : .none,
  synced: true)` — `rekeys: false`, no Apple key retired, no words; the `followOwed` gate unchanged. F-2's guard: the
  core's `follow` refuses `.pairChanged` `nothingToDo` before anything (pinned, `PairCatchUpGuardTests`: nothing
  written, no plan, no act in flight, the key and file unchanged); `FollowProgram.name` → `"pairChanged"`,
  `afterCommit(.pairChanged)` → `["memory"]` (unreachable until P6). F-1's four app arms landed (the mark's name;
  the three wording functions fold `.pairChanged` into `.keysReplaced`'s existing sentences, each commented UNIT 2's)
  — THEIR COMPILING IS PENDING (headless only; the orchestrator's first `xcodebuild` will say). The kind-level tables
  (`AssessPairKindTests`): which half moved and E5's both; the door's spec; every key and mode door `followOwed`
  (and two of three leaves, as for every follow — see F-9); E2; E3; E1 (signed out, unread, another account's
  read); both-present legs (E6, no copy, a half-read reading); another key's file in the live place; the pure
  reading's table. THE FULL CORE SUITE after it: 3372 tests passed (4 known issues — P2's negative control); one
  failure elsewhere, `VariorumMCPTests`' `MCPHarnessTimeLimitTests` wall-clock bound (19 s against 15 s under the
  full parallel run) — 3/3 green alone in 2 s; no protection code in it. VERIFIED BY REVERT: the `acts` pair arm
  disabled ⇒ `AssessPairRedPins` RED again (the same 12 issues as on the old tree); restored ⇒ 12/12 green.
- P4 — scope 2, THE ACT'S PURE PIECES. DONE (`b7f6ab499`) — `KeyFile.droppingWords()` (a value setter beside
  `droppingApple`; no shape change) and `KeyFile.relockedToTheAccountsPair(key:master:accountsWordsCopy:
  accountsPassphrase:dropsOwnWordsLock:)` (`Model/KeyFileRelock.swift`): rule 22 FIRST (the master in hand must open
  this key through the master lock — else `doesNotOpen(.master)` / `noSuchWrap(.master)`, nothing returned); the
  passphrase lock re-made only when a passphrase is given; the copy refreshed byte for byte; the own words lock
  dropped when asked; `opensWithTheWords` checked last (rule 2). The LANDED predicate needs no new function: one key
  file write carries the whole re-lock, so landed ⇔ `AssessRules.pairFollow(file, freshReading) == nil`.
  `PairRelockTests` (7 tests): each half, both (E5), nothing but the locks moved (fingerprint, epoch, history, the
  master lock's bytes, the Apple wrap), the old secrets stop opening the live file (rule 7, E8) while a backup frozen
  before keeps its day's (E7, rules 4–5) and the new secrets reach older keys through the history, the rule-22
  refusals, idempotence (AES key wrap is deterministic — a resume re-running the write lands the same bytes), the
  dropper. Green with every key-file suite (59 tests).
- P5 — scope 2, THE FORK PROPOSAL. DONE (`3f3c9944d`) — below, under THE FORK; REPORTED BACK. P6 waits on the ruling.
- P6 — scope 2, THE ACT'S PROGRAM, on the architect's ruling (`59e8b4ca1`: Shape A). DONE; sub-pieces:
  - P6a — S-2 VERIFIED: the key doors take NO backup after a re-lock — `KeyDoorProgram`'s steps are `vault`?/`keyFile`/
    `memory` and its plan-less finish `memory` alone (`KeyDoors.swift:25-29`); the app's key-door road
    (`ProtectionKeyDoorActs.press`) and its account road (`ProtectionAccountActs.perform`) start none after the act
    either. So the catch-up takes none (the ruling's condition met). DONE (this commit).
  - P6b — the act in the RULED shape (reshaped at P6c/P6d — read those for the plan as it stands) (`follow`'s third-kind entry checks; `FollowProgram`'s no-re-key arm, steps
    `pickUpKeys`/`relock`/`memory`, `toKey` nil; F-2's guard removed, its pin flipped to the entry checks).
    DONE (`a4e3f3f1e` pins; this commit the act) — the red pins COMMITTED (`Executor/PairCatchUpTests.swift`, replacing the guard's suite): each half and
    both in all three postures (Standard, Castle Touch ID, Castle Always ask) — the key, record and history unchanged,
    `pairFollow` nil after, no vault/custody/Apple/staged/backup write, the mirror following, the keys held per
    posture; E7's backup untouched; the second press `nothingToDo`; the entry checks (nothing moved; nothing typed /
    words only for the passphrase half; the old passphrase ⇒ the change named; garbage ⇒ the plain refusal; E14's
    `secretMissing` then the account's passphrase landing it; the posture moved ⇒ `accountMoved`), each with nothing
    written; the crash after every write, three postures, and with the plan gone. RED on the guard's tree — every act
    test `nothingToDo` (22 issues); the nothing-moved row green on both sides by nature. THE ACT COMMITTED (this
    commit): `Executor/Acts/PairCatchUp.swift` — `followThePair` (the door: a fresh read; posture or sync key moved ⇒
    `accountMoved`; the halves re-derived from that read, none ⇒ `nothingToDo`; the passphrase half requires the
    account's current passphrase, verified, P1's split on a wrong one; typed words verified; the keys from the secrets,
    else session, else the silent item, else — Castle only, last — the Touch ID item (E14: none ⇒ `secretMissing`);
    the master must open the key file's master lock, else `accountMoved`), `perform(…, material:)` carrying the
    door's keys in memory so the press reads custody once; steps `pickUpKeys` (fresh read, posture/key check ⇒
    `ActRollback(.accountMoved)`, keys held per posture — Standard's silent item via `holdSyncKeys`, Castle's session —
    the followed key stamped), `relock` (landed ⇒ nothing; the passphrase half's passphrase must open the fresh vault,
    else `ActRollback` — E4 names the change at the press, `secretsRequired` at a resume; one
    `writeLiveKeyFile(relockedToTheAccountsPair(…))`), `memory`. `FollowProgram`: `pairChangedName`, `isPairCatchUp`,
    `kind` learns the name, `steps`/`run` branch to `PairCatchUp`, `finishingSteps` reads a follow naming no new key
    as the pair kind ⇒ `["memory"]`. F-2's guard RETIRED (`follow` dispatches the third kind to `followThePair`). The
    plan records `passphraseKDF` (the ruled shape as built — P6c revisits it). Green: 59 tests across the five pair
    suites and `FollowTests` (the crash harness in all three postures and plan-gone included).
  - P6c — S-3: the stranded-open pin. DONE (`0eab9a8cd` pin, `6b48999c0` fix) — the pin (`PairCatchUpStrandedOpenTests`: the crash after
    every write, Standard and Castle Always ask, the relaunch's lobby typing the OLD passphrase, roll-back allowed):
    RED on P6b's tree — 14 crash points where `the settle threw .passphraseDoesNotOpen` (the plan records the vault's
    descriptor, so `PlanRunner.resume` derives the old passphrase under it and, the act being always past its commit
    point, throws out of the settle — before the re-lock from the vault check, after it from the lock check).
    THE FIX COMMITTED (this commit) — BY THE PLAN'S SHAPE, not a `PlanRunner` clause (a deliberate refinement of the
    ruling's S-3 wording, same end): the pair plan records NO passphrase descriptor, so the generic resume derives no
    passphrase it could throw on; `ActContext.typedPassphrase` (in memory, the act's span — `typedWords`' twin) carries
    what the lobby typed, and the step's `accountsCurrentPassphrase` derives it under the FRESH vault's descriptor and
    holds it only while it opens the vault (the press's verified passphrase first). WHY THE SHAPE: R-arch-3 — an older
    build resuming this plan has no drop clause; only a plan with no descriptor keeps ITS generic check from stranding
    the open too (P6d). Green: 85 tests (the pair suites, `FollowTests`, the key-door suites). VERIFIED BY REVERT: the
    descriptor put back in the plan ⇒ the pin RED again (the same 14 `the settle threw .passphraseDoesNotOpen`);
    restored ⇒ the pair suites 12/12 green.
  - P6d — R-arch-3: the downgrade-resume trace and the plan's shape. DONE (`d90cb57d8` pin, this commit the shape) —
    THE TRACE (an older build = any
    build before VX-529 on this road, 0.10 / 0.10.1; its `FollowProgram`, `PlanRunner.resume` and `CommonSteps` are
    this branch's non-pair paths byte for byte — `git diff main` adds only the pair arm, `perform`'s `material` and
    `ActContext.typedPassphrase`): it reads `follow = "pairChanged"` as `.keysReplaced` and resumes a NAMED plan by its
    step names — `pickUpKeys` harmless (the same keys held the same way, the same key stamped; out of reach ⇒ a
    harmless roll back; no usable secret ⇒ `secretsRequired` out of its settle — see the residual below); `memory`
    harmless; **`relock` a name it doesn't know ⇒ `default: throw .nothingToDo` out of its settle — the app's open
    catches it ("could not settle now", `ProtectionOpenRoad.swift:753-759`), the library opens, the act stays in
    flight and every door refuses `actInFlight` at every open until she upgrades: NOT harmless.** With no plan to
    trust it finishes from the record: `afterCommit(.keysReplaced)` = `memory` (harmless), `retireOldCustody` (returns
    at once — `current == plan.fromFingerprint`, the key unchanged), `backup` (a fresh pair of whichever valid state
    the file is in) — harmless; a nil `toKey` is never reached (no step it runs needs one). THE PIN COMMITTED
    (`PairCatchUpOlderBuildTests`: crash after every write, the plan's `follow` cleared — the older build's reading —
    then resumed; every settle must land): RED on the ruled shape — 12 crash points, all three postures, `an older
    build's settle threw .nothingToDo`. THE SHAPE (this commit): the re-lock FOLDS into `pickUpKeys` — the plan is
    `["pickUpKeys", "memory"]`, both names every build of this road knows; this build's `pickUpKeys` for the pair
    kind is `pickUpThePair` (a fresh read; posture/key ⇒ roll back; LANDED ⇒ the keys held where in hand, nothing
    re-locked; else the passphrase/keys checks, the keys held, the key stamped, ONE key-file write). THE MECHANISM, an
    older build: a named plan ⇒ its `pickUpKeys` (the same keys held, the same key stamped) then `memory`, the act ending
    with the key file in whichever whole state the crash left (the old locks or the re-lock — rule 20's two; that build
    has no detection, so the old state owes nothing there, and the next new build detects it again); no plan ⇒ its
    `memory`/`retireOldCustody` (returns, the key unchanged)/`backup` — harmless; a nil `toKey` reached by nothing;
    the plan carries no passphrase descriptor (S-3), so its generic resume derives nothing to throw on. GREEN: the pin
    settles every crash point in all three postures; 86 tests across the pair, follow and key-door suites. THE STATED
    RESIDUAL (pinned as a known issue, `theResidualCastleAlwaysAsk…`): Castle Always ask, an older build, `pickUpKeys`
    interrupted, a lobby that took only a passphrase — that build derives none and its session is empty, so its own
    `pickUpKeys` throws `secretsRequired` out of its settle (the library open, doors refusing at that open); data-safe
    (the key never changed, every road opens the library), healed at the first open whose lobby takes the words, or the
    upgrade — that build's own follows resumed without a usable secret behave the same. A stored-format change could
    close it; the ruling forbids one, and nothing else reaches into an older build.
  - P6e — S-5 overruled in part: F-4's two seams + the sweep table over every vault-verify throw site. DONE
    (`478c3bc28` pins, `1ce5187d2` fix) — the table pins (`PairRefusalSiblingSeamTests` in `Executor/PairRefusalSplitTests.swift`): RED on the
    pre-fix tree, all 9 in-class rows with today's refusal — New words (both postures) and the crossing + Replace All
    Keys (both postures) with the OLD passphrase: `passphraseDoesNotOpen` (6); Replace All Keys with the OLD words
    after a words change elsewhere: `wordsDoNotOpen` (2); Reset by the OLD words, Castle Always ask, no keys held:
    `secretsRequired(.changePassphrase)` (1); their opens-neither companions green. THE FIX COMMITTED (this commit):
    P1's `refusalForAPassphraseTheVaultRefuses` at `regenerateWords`' synced arm and `doorSecrets`' passphrase arm; a
    words twin `refusalForWordsTheVaultRefuses` (`KeyDoors.swift` — the typed words open THIS library, its own lock or
    its copy through its master lock ⇒ `accountMoved`, else `wordsDoNotOpen`) at `doorSecrets`' words arm; and
    `holdSyncKeysForTheSession`'s no-master arm says `accountMoved` when WORDS reached it (Reset's road verified them
    against this library first). Green: 183 tests (the pair, follow, key-door, crossing, file-less-words, session-hold,
    U2 and fixed-scenario suites; 5 known issues — P2's 4 controls and P6d's residual). VERIFIED BY REVERT: both files
    at `478c3bc28`'s lines ⇒ the same 9 rows red; restored ⇒ green. THE SWEEP TABLE (every `VaultModel.master(…)` /
    `vault.master(…)` site in `Sources/VariorumCore/Protection/` — the throw-on-nil ones verdicted; the class: a typed
    secret that still opens THIS library but not the account's vault, refused with a sentence saying it doesn't open
    this library, or asking for something else):

    | # | Site (function) | Typed | Before | Verdict |
    |---|---|---|---|---|
    | 1 | `KeyDoors.swift` `changePassphrase` | the current passphrase | `passphraseDoesNotOpen` | FIXED — P1 `1ccdd5b27` |
    | 2 | `KeyDoors.swift` `regenerateWords`, synced arm | the current passphrase | `passphraseDoesNotOpen` | FIXED — P6e `1ce5187d2` |
    | 3 | `EnterCastle.swift` `doorSecrets`, passphrase (Use Castle · Use Standard · Replace All Keys) | passphrase | `passphraseDoesNotOpen` | FIXED — P6e |
    | 4 | `EnterCastle.swift` `doorSecrets`, words | words | `wordsDoNotOpen` | FIXED — P6e (words twin ⇒ `accountMoved`, "Follow it first.") |
    | 5 | `KeyDoors.swift` `holdSyncKeysForTheSession` (Reset by the words, no keys held) | words, verified against the library | `secretsRequired` | FIXED — P6e (words ⇒ `accountMoved`; no secret keeps `secretsRequired`) |
    | 6 | `PairCatchUp.swift` `followThePair`, passphrase | passphrase | — (new) | FIXED by construction (P1's helper) |
    | 7 | `Follow.swift` `follow`, passphrase | passphrase | VX-113's `passphraseChangedElsewhere` on the descriptor alone | OUT — already names the change (best-effort, F-5) |
    | 8 | `Follow.swift` `follow`, words | words | `wordsDoNotOpen` | IN THE CLASS, NOT FIXED — F-10 |
    | 9 | `PairCatchUp.swift` `followThePair`, words | words | `wordsDoNotOpen` | IN THE CLASS, NOT FIXED — F-10 |
    | 10 | `AccountActs.swift` `join` (enroll · Move), passphrase | the account's passphrase | `passphraseDoesNotOpen`, rendered "…your account" (VX-464) | OUT — the secret is the ACCOUNT's, and the face names the account |
    | 11 | `AccountActs.swift` `join`, words | the account's words | `wordsDoNotOpen`, rendered "…your account" | OUT — the same |
    | 12 | `CommonSteps.swift` `enterCastleWrite` (in the act) | the press's passphrase | `ActRollback(.accountMoved)` ⇒ "Follow it first." | OUT — already honest |
    | 13 | `PlanRunner.swift` `resume`'s synced check | a resume's passphrase | `passphraseDoesNotOpen` out of the settle | OUT of the door class (no door says it; the open logs "could not settle"); the pair plan never arms it (S-3); the key doors' own rule is F-U1a-1 |
    | 14 | `KeyDoors.swift` `mintKeyFile` (in the act) | the act's own new words | `needsFreshVault` | OUT — act-internal, no typed secret judged |
    | 15 | `KeyDoors.swift` the vault step's landed check and the words-copy refresh guard; `CommonSteps.swift` `material`; `AccountActs.swift` `wordsAreTheAccountsAlready`'s input; `VaultModel.master` itself | — | not throw sites | OUT |

    App sites (read for the table; no app line changed here): `ProtectionAccountActs.swift` `accountSecretRefusal`
    (the account road's preflight, mirroring rows 7/10/11 — and row 8's words twin, F-10's); `ProtectionSecretCheck`
    (the check door's four honest answers, P-VX510-B3-2) OUT; `ProtectionOpenRoad.swift`'s typed-unlock seam (it logs
    and loads nothing — no refusal) OUT.
  - P6f — the full core suite and the report. DONE — the full core suite at `148f326f5`: VariorumCoreTests
    **3396 tests passed** (5 known issues: P2's 4 negative controls + P6d's pinned residual); the one failure the
    ticketed MCP wall-clock flake (VX-353 / VX-532). Then THE SCENARIO WORLD'S OWN PASS (this commit,
    `Scenario/PairCatchUpScenarios.swift`): her other Mac re-makes the passphrase, the words, or both; this Mac owes
    exactly `.pairChanged(…)` once the vault is read, presses the follow typing today's passphrase, owes nothing
    after, and today's passphrase and words both open the caught-up live library — `expectPromisesKept` before and
    after a settle; Castle Always ask, Castle Touch ID and Standard × the three halves: green. THE FINAL FULL RUN on the
    finished tree (`b8470202d`): VariorumCoreTests **3397 tests passed** (5 known issues: P2's 4 negative controls +
    P6d's pinned residual); the one failure `VariorumMCPTests`' `MCPHarnessTimeLimitTests` wall-clock bound (19.0 s
    against 15 s under the full parallel run) — the ticketed flake VX-353 / VX-532, no protection code in it. Zero
    `Sync/` lines (by diff); no commit trailers. DONE.
- **THE SESSION'S END STATE (pre-fork, `3f3c9944d`):** the full core suite `swift test` — VariorumCoreTests **3379 tests
  passed** (4 known issues: P2's negative control, by design); the one failure is `VariorumMCPTests`'
  `MCPHarnessTimeLimitTests` wall-clock bound under the full parallel run (19.1 s against 15 s; 3/3 green alone) — the
  ticketed flake VX-353 / VX-532, no protection code in it. Zero lines in `Sources/VariorumCore/Sync/`. The app's
  compile (F-1's four arms) PENDING the orchestrator's first `xcodebuild`.

- P7 — R-529-5's words arm (the coordinator's brief after P6, on her ratify at `e0fb54c7d`). IN-PROGRESS. Checked first:
  nothing in R-529-5's letter fights the code built (stop-and-report not triggered). ONE FACTUAL CORRECTION to the brief's
  premise for P7-3: `relockedToTheAccountsPair` already LANDS a passphrase lock where none exists (`settingPassphrase`
  sets or replaces) — P7-3 still ships the heal as its own narrower primitive (land-where-missing ONLY: no copy refresh,
  no lock dropped), so unit 2's consumers cannot reach the catch-up's wider transform by accident. Sub-pieces:
  - P7-0 — `ExecutorRefusal.wordsChangedElsewhere(device:day:)` (VX-113's words twin), its drafted sentence in
    `ProtectionWords` (P-VX529-3's class, PROVISIONAL — her pass) and the two act-refusal faces' arms beside VX-113's
    (every app switch over `ExecutorRefusal` has a `default:` arm, so nothing else breaks); unused by the core until
    P7-2. DONE (this commit) — `Executor.swift`; `ProtectionWords.wordsChangedElsewhere(device:day:)` ("Your twelve words
    were changed on ‹device› on ‹day›.", the VX-113 sentence's four-arm form); `RoadCrossingFaces` /
    `RoadAccountFaces` `actRefusalSentence` arms. Core builds; the app arms' compile PENDING (your xcodebuild).
  - P7-1 — THE WORDS ARM: the account's CURRENT words typed when the passphrase half moved ⇒ the stale passphrase lock
    DROPS (`relockedToTheAccountsPair`'s passphrase-lock change becomes keep / re-make / drop); the door's requirement for
    the passphrase-moved case becomes `.oneSecret` (either of the account's two). Red pins first. NOT-STARTED.
  - P7-2 — F-10's refusal at the follow's own words arm and the pair door's (sweep rows 8–9). Red pins first.
    NOT-STARTED.
  - P7-3 — the E6 heal's KeyFile primitive (P-VX529-4, PROVISIONAL; NOT wired — unit 2's). NOT-STARTED.
  - P7-4 — the full core suite; the report. NOT-STARTED.
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
- **F-9 — a trap the gate leaves, for the architect (not changed): with the pair follow owed, `followOwed` refuses EVERY
  key door — Reset forgotten passphrase included — and Stop syncing here / This Mac only, while the passphrase half's
  catch-up takes only the account's current passphrase (design §2). A person on the lagging device who does not
  remember the passphrase set elsewhere has no door here but deleting the account (rule 3: "either one can reset
  the other"). Options: (a) the passphrase half also accepts the account's twelve words — dropping the stale
  passphrase lock rather than re-making it (E6's state; the account's passphrase then opens through the vault
  online — fact 3, R-529-1's road); (b) Reset forgotten passphrase is exempt from the PAIR kind's gate (it re-makes
  the passphrase on both locks anyway — the passphrase half lands as its side effect; a words half still owed after
  is the quiet one); (c) leave it — the other device is the road. Built as the memo says (c); an author-shaped call.
- **F-10 — the class's words twin INSIDE THE FOLLOW (sweep rows 8 and 9), for her wording pass / unit 2:** old
  words typed at a follow (a posture or key follow whose words also changed elsewhere; the pair door's E14 ask)
  still say "Those twelve words don't open this library." — false when they open it. The doors around it now say
  "Your account changed on another device. Follow it first.", which inside the follow itself would be circular, and
  no refusal names a words change elsewhere; an honest one needs a new refusal and its sentence (VX-113's twin —
  e.g. "Your account's twelve words were changed on ‹device› on ‹day›."), which this unit does not mint.
- **F-8 — the app routes an account act by `spec.rekeys`** (`RoadAccountModel.swift:509-516`): a re-keying act closes
  the pool and reopens; one that changes no key runs on the open session. The third kind's door says `rekeys: false`,
  so the app's existing road already runs it on the open session (unit 2's to confirm).

#### UNIT 1 — THE FORK: the act's program shape (the implementer's PROPOSAL — RULING PENDING, the architect's)

**What both shapes share (built the same either way):** the public entry is the core's `follow(_:kind:typed:gate:)` —
the door the app already calls with the assessment's kind (P-VX529-1: one door). For `.pairChanged` it re-reads the
vault and re-derives the moved halves FROM THAT READ (`AssessRules.pairFollow(liveKeyFile, vault.reading)`; nil ⇒
`nothingToDo`; posture or sync key moved ⇒ `accountMoved` — E2/E4), then, all before `perform` (reads only, nothing
begun): the passphrase half requires `typed.passphrase` (else `secretMissing`), derived under the VAULT's descriptor and
verified there (wrong ⇒ P1's `refusalForAPassphraseTheVaultRefuses`: the old one names the change, garbage the plain
refusal); the master from that passphrase, else — words only — custody/session (the Touch ID class only in Castle,
VX-517; secrets first, VX-503), else `secretMissing` (F-7, the face asks the passphrase); the master verified to open the
live key file's master lock (rule 22). The act: `toKey: nil` (no new key — `toFingerprint` nil, so the plan machinery reads
it as "re-keys nothing": `pastCommitPoint` true, the plan-less settle finishes it), steps `["pickUpKeys", "relock",
"memory"]` — `pickUpKeys` as built (the fresh read, the keys secrets-first, `holdSyncKeys` per posture, the followed row
key stamped — the same key, idempotent); `relock`: LANDED already (`pairFollow == nil` on the live file against the
act's fresh read) ⇒ nothing, no secret needed; else the passphrase half with no passphrase in hand (a resume) or one that
no longer opens the fresh vault (E4: it moved again) ⇒ `ActRollback` (rule 20's old state; the follow is owed again);
else one `writeLiveKeyFile(relockedToTheAccountsPair(…))`; `memory` ⇒ `rememberNewKey` (rule 1's mirror follows). No
backup step (the key doors' precedent: a re-lock is no key change; the scheduled backup carries the new pair — S-2).
**And one clause in `PlanRunner.resume`, needed under BOTH shapes** (F-U1a-1's twin): a no-re-key act is always past its
commit point, so a passphrase typed at the lobby that opens no lock under the plan's descriptor throws
`passphraseDoesNotOpen` OUT OF THE SETTLE (`PlanRunner.swift:423`) — the stuck-act class — once the re-lock has landed and
the lobby took the OLD passphrase; for the pair act that passphrase is dropped instead (the step then finishes if landed,
else rolls back).

**SHAPE A — RECOMMENDED: a no-re-key arm INSIDE `FollowProgram`.** The act in flight is `.follow` (raw value `"follow"`,
unchanged); `ActParameters.follow = "pairChanged"` (the existing free-form string); `FollowProgram.kind` learns the name
(its default arm reads unknown names as `keysReplaced` — that must not stay the pair act's road); `steps` branches to the
three above; `finishingSteps` tells the pair kind with no plan by its act in flight naming NO `toFingerprint` (every other
follow re-keys) ⇒ `["memory"]`; the posture-moved resume guard in `run` applies as it stands (`newKind` = the record's
mode). For it: **nothing stored changes, to the letter of R-510-20** — no new `ProtectionAct` value in the record's act in
flight or the plan; one door, one act family ("Follow your account…" for every way the account moved); the app's settled-
follow reading (`RoadSettledFollow.kind`) already treats it as a follow Done (unit 2 tells the kind by the nil
`toFingerprint`); `pickUpKeys`/`holdSyncKeys` give the per-posture custody unchanged; the scenario world's `.follow`
action and `settleWorld`'s auto-follow exercise it under every promise with zero harness change (F-3). Against it:
`FollowProgram` gains a branch sharing nothing with `LibraryRekey`; a build older than this one resuming a pair plan
would throw `nothingToDo` on `relock` (a downgrade mid-act — a corner of the same size under B).

**SHAPE B — a sibling re-lock program on the key doors' plan machinery** (`["keyFile", "memory"]`, `resumeCannotFinish`'s
roll-back idiom). It needs its own act: either a NEW `ProtectionAct` case — a new value of what `ProtectionVocabulary.swift`
calls "a stored FORMAT" (the record's act in flight, the plan), which I read as outside R-510-20 ("we aren't changing
anything stored anywhere"); an older build would fail to decode this Mac's sealed section while it is in flight — or an
existing act's value (`.changePassphrase` / `.regenerateWords`), whose resume rules (`passphraseIsNew`, F-U1a-1's
replaced-lock drop) and the app's Done wording key on the act and would misread it. The plan-less registry
(`program(for: act)`) takes no parameters, so B cannot share `.follow` without a parameter-aware registry. For it: the
re-lock sits with rule 6's other re-locks. Against it: the stored-vocabulary question; the app's settled-follow reading
and the scenario world's follow action would each need a route.

**Sub-decisions riding the ruling (my defaults in brackets, each PROVISIONAL until ruled):** S-1 words-only with no master
in hand ⇒ [refuse `secretMissing`; the door also ACCEPTS an optional typed passphrase there] (F-7, proposed E14) · S-2 a
fresh backup at the end ⇒ [no — the key doors' precedent] · S-3 the resume drop clause above ⇒ [yes, pair act only] ·
S-4 F-9's forgotten-new-passphrase trap ⇒ [(c) as built; (a)/(b) are hers to weigh] · S-5 F-4's two sibling seams
(`regenerateWords`, `doorSecrets`) take P1's helper ⇒ [not in this unit unless ruled — one line each].

## UNIT 1 — THE ARCHITECT'S RULING ON THE FORK (2026-10-24, after verifying P1–P5: the commits spot-checked, the five
suites re-run green by the orchestrator's own hand — 40 tests, the 4 known issues P2's negative controls; zero
`Sync/` lines confirmed by diff)

- **THE SHAPE: A** — the no-re-key arm inside `FollowProgram`, exactly as proposed: one door for every way the
  account moved (P-VX529-1), no new stored `ProtectionAct` value (R-510-20's letter — an older build must never meet
  an act value it cannot decode), `ActParameters.follow = "pairChanged"` on the existing free-form field, `toKey`
  nil, steps `["pickUpKeys", "relock", "memory"]`, relock idempotent (skips when `pairFollow == nil` on the fresh
  read), rolls back on a missing secret or a vault moved again (E4).
- **S-1 ACCEPTED** (a words-only catch-up with no master in hand refuses `secretMissing`; the face asks for a secret
  — E14 below). **S-2 ACCEPTED conditionally:** no backup step, PROVIDED it matches the key doors' own re-lock
  behavior — verify what `changePassphrase` does about backups and state the answer in LIVE STATUS; if the key doors
  back up after a re-lock, the catch-up does too. **S-3 ACCEPTED** (the PlanRunner resume drop clause), with its own
  red-on-old pin — a typed lobby passphrase that opens no lock under the in-flight plan's descriptor is dropped, not
  thrown, so the act never strands the open. **S-4 stands** (F-9 is HERS — bundled at this sitting, build (c)
  as-built meanwhile). **S-5 OVERRULED IN PART — F-4's two sibling seams are IN SCOPE for P6:** `regenerateWords`'
  synced arm and `doorSecrets` (EnterCastle.swift:99) take P1's helper, each with a red-on-old table pin; and the
  CLASS gets the sweep-table discipline — enumerate EVERY `VaultModel.master(...) != nil else throw` site, verdict
  each FIXED or provably out of the class (the join's account-naming refusal, VX-464's, is expected out), the table
  in LIVE STATUS.
- **R-arch-3 — the downgrade-resume check (named for the ladder too):** a pairChanged plan interrupted mid-act and
  resumed by an OLDER build would read `follow = "pairChanged"` as `.keysReplaced` (FollowProgram.kind's default) —
  trace what that resume would actually do (`finishingSteps`, `retireOldCustody` against an unchanged fingerprint,
  a nil `toKey`) and either show it harmless by mechanism or shape the plan so it is (never a stored-format change);
  state the mechanism in LIVE STATUS. A downgrade mid-act is extreme but the record must say why it is safe.
- **E13 accepted** (a half-finished own passphrase change reads as a pair change on the same device — true and
  honestly worded; the device named is this one; her wordings pass sees it). **E14 accepted** (Castle Always-ask
  unlocked by the OLD words holds no master: the words-only catch-up types one account secret there — R-510-20's
  "type both where you must"; the core refuses `secretMissing`, unit 2's face asks). **F-1's mechanical app arms
  accepted** (they mint no sentence; the orchestrator's xcodebuild verifies the compile; unit 2 replaces them).
  **F-8 and `RoadSettledFollow.kind`** noted for unit 2's brief.

## F-9 — HER SECURITY QUESTION AND THE ANALYSIS (2026-10-24, at the F-9 sitting; her words verbatim)

**Her answer to the F-9 question (not a pick — a question back):** "do you think it's a problem at all that you
changed your passphrase elsewhere and the old one lets you change it? What if you changed it because someone learned
your passphrase? i feel like it might be weakening the value of changing your passphrase - does rotate keys cover
that road ??" (Same sitting: **VX-530 rides TRACE-FIRST** — her pick, parented under VX-529.)

**The analysis (the architect's, traced against the rules and the code):**

1. **The old passphrase opening the lagging device is physics, not a door this run adds** — an offline file cannot
   be reached by a change made elsewhere, the same truth as rule 5's floor ("a backup opens with the passphrase and
   words you had when you made it"). Today that stale lock lives FOREVER on a lagging Standard device (no door
   retires it); the catch-up is the FIRST road that retires the old passphrase there. As designed, the catch-up
   STRENGTHENS the change's value; the old passphrase authorizes nothing account-side (the gate refuses every key
   door; the catch-up demands a CURRENT account secret).
2. **"Someone learned your passphrase," by what they hold:** nothing else ⇒ nothing (sign-in is the account
   password, a different secret; the vault demands the new passphrase at once). An old backup too ⇒ rule 5's stated
   floor (old secrets open old copies, forever — rules 13, 25 territory). One of your signed-in STANDARD devices too
   ⇒ they never needed the passphrase (rule 8's quiet roads open it); the answer to device compromise is Castle (or
   signing the device out), never the passphrase change — and a passphrase change deliberately does not evict a
   signed-in Standard device from sync (custody holds the sync keys; the Standard trust model).
3. **Her instinct was RIGHT about the F-9 (b) option, which is WITHDRAWN:** exempting Reset forgotten passphrase
   from the gate would let old-passphrase + a lagging Standard device REWRITE the account's pair (plain confirm +
   custody's quietly-held master) in exactly the state where the owner may have just changed the passphrase to lock
   someone out. The gate stays whole; no Reset exemption.
4. **"Does rotate keys cover that road?"** Replace All Keys replaces THE LIBRARY'S KEY ONLY — never the account's
   sync key ("it changes only when the account enters Castle", rule 15; P-VX378-U2-1's recorded reading, restated in
   `ReplaceAllKeys.swift`'s header). So: a learned passphrase (no material) is covered by the passphrase change
   itself; a feared KEY extraction (they held your device or files while the old pair stood) is covered by USE
   CASTLE — the one act that mints a new sync key, kills the Apple roads account-wide and makes every device re-type
   a secret. Replace All Keys covers a leaked library key file, not a leaked passphrase.
5. **The REVISED F-9 proposal — R-529-5, pending her ratify: the follow accepts EITHER of the account's CURRENT
   secrets** (rule 14's own grammar: "joining the account from a new device always types one of them"). With the
   current passphrase, the full re-lock as designed. With the current WORDS (the forgot-the-new-passphrase road),
   the stale passphrase lock is DROPPED — the old passphrase stops opening this library at once, which is the
   passphrase change ARRIVING here — the words copy refreshes, the sync keys load; the passphrase lock returns when
   a passphrase is next typed here (meanwhile the account's passphrase opens it online through the vault road,
   R-529-1, and Reset — un-gated once the pair converged — sets a known one). An attacker who merely learned the OLD
   passphrase holds neither current secret and can do nothing but read the local copy they already physically hold.

## R-529-5 — RATIFIED, WITH THE SENTENCE (2026-10-24, the same sitting; her words verbatim)

Her ratify, after two clarifying rounds recorded here: *"Ratify, with the sentence. It's a good point that this
state is reachable in other ways - maybe make sure that that's clearly expressed everywhere it needs to be. It does
still open any version of your library with your passphrase (just backups might not accept it, for the E6 corner
described). Do you think that there's anywhere else we need to update because of E6? Ratified with the sentence
either way"* — and, the round before, her backup question verbatim: *"but then their library isn't rekeyed under the
new passphrase, right? so any backups they made wouldn't open with the passphrase that is their accounts passphrase
at that time? isn't this a problem if either the 12 words or the passphrase changes and we don't make them type the
follow?"* (answered: no pair change ever re-keys — rule 6; the quiet words-change case has no gap — the passphrase
lock stays intact and the new words ride the master copy into every later backup; the words-ARM window is real,
bounded, and is E6's existing class, which a words-REJOIN reaches identically; the floor holds — the words open every
copy; the window closes at the first typed passphrase).

**THE RULING:** the catch-up accepts EITHER of the account's CURRENT secrets. The passphrase arm: the full re-lock.
The WORDS arm: the stale passphrase lock DROPS (the old passphrase stops opening this library at once); the sheet
says the window plainly (draft, P-VX529-3's class: *"Until you type your account's passphrase on this Mac, copies
made here open with your twelve words."*) and points at the Reset chain (*follow with your words, then set a
passphrase you know with Reset forgotten passphrase*); the lock is re-made at the next typed-passphrase moment. The
gate stays whole; no Reset exemption (F-9's analysis).

**THE E6 SWEEP (her ask: "anywhere else we need to update because of E6?") — the architect's candidates, each for
unit 2 or her bundle, none built autonomously beyond the ruled sentence:**
- **The heal, generalized (PROVISIONAL P-VX529-4):** ANY synced library missing its passphrase lock (join-by-words
  born, or the words arm's window) re-makes it at any moment a typed passphrase verifies against the vault — the
  vault-road open (R-529-1's act has the secret in hand) and the key doors. NEVER the check door (its ruled contract:
  "checking changes nothing"). This is R-529-5's own "re-made next time a passphrase is typed here" applied to the
  whole class; flagged provisional because join-born E6 predates this run.
- **The lobby's E6 sentence (unit 2):** the key file is readable pre-unlock, so a typed passphrase against a file
  with NO passphrase lock can say so instead of the misleading "doesn't open this library" — draft: *"This library
  doesn't have a passphrase lock of its own — it opens with your twelve words."* (offline face; online the vault road
  simply opens it).
- **The check door's E6 wording (her bundle):** the fourth answer's E6 variant could explain rather than just refuse.
- **The join's words moment (her bundle):** when a join by words lands E6, one line saying the same window.
- **The guide:** one E6 line for the protection chapter — rides VX-379 (already open, Pre-launch).

## Machinery

The standing cast (Fable orchestrates and cold-reviews; Opus implements, fresh per unit); pin-before-fix per member;
commits "Part of VX-529", no trailers; SessionResiliencyProtocol binds (commit per piece, LIVE STATUS from the first
commit, push after each, foreground waits); the stage only for walks/suite runs/refreshes; the dev store's rules and
`~/.variorum/dev-castle.env` for any dev-store Castle walk; the prod test road only through the VX-510 tools
(`Tools/WalkKit/first-run-walk.sh` env, `Tools/prod-confirm-test-user.sh`), secrets via the `~/.variorum/bin`
helpers. Environment traps: the VX-510 record's ENVIRONMENT TRAPS section binds verbatim for every session of this
run.
