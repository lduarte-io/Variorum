# VX-529 — the catch-up for a pair changed elsewhere

**STATUS: OPEN — THE BUILD PHASE COMPLETE (units 1–3 CLOSED) AND THE LADDER CLOSED (round 1: 0B·0M·1m·2n → fix
sessions L1 and L2, both verified; round 2: every fix SOUND, 0B·0M·0m·2 record-hygiene NITs, both fixed). Remaining:
the closing stage batch, the live proof, HER two-Mac test, the closeout.** The rulings are THE RULINGS + R-529-5/-6 and the architect-ruling sections; the design memo (next
section) is the built contract. Branch `vx-529-pair-catchup`, worktree `~/dev/variorum-vx-529`, the custody slot held
(the in-flight table). The kickoff is `notes/handoffs/vx-529-kickoff.md`; the repro is the VX-510 record's THE
CHANGED-ELSEWHERE REPRO (`notes/plans/fixes/vx-510-first-run-sync.md`). *(The header's original "nothing below is
built" line stood stale through the build phase — the round-1 reviewer's NIT; trued 2026-10-25.)*

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
riders; F-9 (hers — answered by R-529-5's words arm, P7); the E6 heal's WIRING (unit 2's — P7-3 ships the primitive
only); the app's compile (the orchestrator's xcodebuild).
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
    | 8 | `Follow.swift` `follow`, words | words | `wordsDoNotOpen` | FIXED — P7-2 (`wordsChangedElsewhere`, F-10's refusal) |
    | 9 | `PairCatchUp.swift` `followThePair`, words | words | `wordsDoNotOpen` | FIXED — P7-2 (`wordsChangedElsewhere`) |
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

- P7 — R-529-5's words arm (the coordinator's brief after P6, on her ratify at `e0fb54c7d`). DONE. Checked first:
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
  - P7-1 — THE WORDS ARM (DONE): the account's CURRENT words typed when the passphrase half moved ⇒ the stale passphrase lock
    DROPS (`relockedToTheAccountsPair`'s passphrase-lock change becomes keep / re-make / drop); the door's requirement for
    the passphrase-moved case becomes `.oneSecret` (either of the account's two). IN-PROGRESS — the red pins COMMITTED
    (`PairCatchUpWordsArmTests`; `AssessPairKindTests`' door row now `.oneSecret`; the entry row that expected
    `secretMissing` for the words removed — the ruling makes that road land): RED on the pre-P7-1 tree — the words arm
    `secretMissing` in all three postures, alone and for both halves, and under the crash harness; the door
    `.currentPassphrase`. The passphrase-press-resumed-by-the-words row green on both sides by nature (a guard). THE
    FIX COMMITTED (this commit): `KeyFile.droppingPassphrase()` (a value setter beside `droppingWords`);
    `PassphraseLockChange` (keep · remake · drop) replacing the re-lock's optional passphrase — rule 22's master check
    still first, `opensWithTheWords` still last; the door takes either current secret (`secretMissing` only when the
    passphrase moved and nothing was typed); the step re-makes the lock when the account's current passphrase is in
    hand, DROPS it when the PRESS chose the words and they open the fresh vault (a passphrase press resumed by a
    lobby's words alone rolls back — it never trades the press's re-made lock for a dropped one), else rolls back —
    E4 at the press names the change by the secret pressed (`wordsChangedElsewhere` for the words arm). THE DOOR'S
    REQUIREMENT for the passphrase-moved case: `.oneSecret` — truthful: either of the account's two current secrets
    lands it (its face is unit 2's; `RoadDoorAsk.of(.oneSecret)` is the follow's existing passphrase-or-words ask).
    After the words arm the file is E6's state (no passphrase lock; `pairFollow` nil — nothing owed); the heal is
    P7-3's. Value pins: `.drop` takes only the passphrase lock; `.remake` lands one where none was (the corrected
    premise). Green: 96 tests (pair, follow, key-door suites) + `PairRelockTests` 9/9. VERIFIED BY REVERT: the door's
    either-secret line and the spec put back ⇒ the same 11 issues red; restored ⇒ green. DONE (`577c69d03` pins,
    `e49321c61` fix).
  - P7-2 — F-10's refusal at the follow's own words arm and the pair door's (sweep rows 8–9). DONE — the red
    pins COMMITTED (`PairFollowWordsRefusalTests`): RED on the pre-fix tree — the follow into Castle with the OLD words
    after the Mac re-made the words and entered Castle, and the pair door (both postures) with the OLD words after both
    halves moved: `wordsDoNotOpen` (3); the nobody's-words companions green. THE FIX COMMITTED (this commit):
    `refusalForWordsTheVaultRefusesAtTheFollow` (`KeyDoors.swift` — the typed words open this library through its own
    key file ⇒ `wordsChangedElsewhere(device:day:)`, the vault's last writer and day; else `wordsDoNotOpen`) at
    `Follow.swift`'s words arm and `followThePair`'s; P6e's door helper shares the one predicate
    (`wordsOpenThisLibrary`). Green: 93 tests (the refusal, pair, follow, key-door and crossing suites).
    VERIFIED BY REVERT: both throw sites put back to `wordsDoNotOpen` ⇒ the same 3 rows red; restored ⇒ green. DONE
    (`1c724e53c` pins, `35ec32e85` fix).
  - P7-3 — the E6 heal's KeyFile primitive (P-VX529-4, PROVISIONAL; NOT wired — unit 2's). DONE (this commit) —
    `KeyFile.landingTheAccountsPassphraseLock(_:key:master:)` (`Model/KeyFileRelock.swift`): the master must reach this
    key through the master lock (the file is the account's — an unsynced file refuses `noSuchWrap(.master)`); LANDS
    the account's current passphrase only where NO lock exists — an existing lock (the account's, or a stale one
    owing the catch-up) is returned unchanged; no copy refreshed, no lock dropped. `E6HealPrimitiveTests` (3): lands
    where missing and touches nothing else (byte-equal but the lock), idempotent; never replaces a lock there; refuses
    another master, a master-less file, another key. NO CONSUMER (grep: only its own definition) — the vault-road
    open and the key doors are unit 2's to wire; never the check door.
  - P7-4 — the full core suite; the report. DONE — plus the words arm through the scenario world (`2b0294dba`,
    `PairCatchUpWordsArmScenarios`: three postures, the words moved too or not — owed, landed by the follow with
    today's words, the stale passphrase lock dropped, nothing owed after, every promise kept before and after a
    settle). THE FULL CORE SUITE at `2b0294dba`: VariorumCoreTests **3409 tests passed** (5 known issues: P2's 4
    negative controls + P6d's pinned residual); the one failure the ticketed MCP wall-clock flake (VX-353 / VX-532).
    Zero `Sync/` lines; no trailers. The app's new lines (P7-0's sentence and two face arms) compile PENDING your
    xcodebuild.
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
  with NO passphrase lock can say so instead of the misleading "doesn't open this library" — THE ARCHITECT'S FIRST
  DRAFT ("This library doesn't have a passphrase lock of its own — it opens with your twelve words.") is
  SUPERSEDED BY R-529-6 below: her direction, the why and the road, not the mechanism.
- **The check door's E6 wording (her bundle):** the fourth answer's E6 variant could explain rather than just refuse.
- **The join's words moment (her bundle):** when a join by words lands E6, one line saying the same window.
- **The guide:** one E6 line for the protection chapter — rides VX-379 (already open, Pre-launch).

## R-529-6 — THE E6 FACE SAYS THE WHY AND THE ROAD, AND THE STATE IS SURFACED UNTIL RESOLVED (2026-10-24, her words verbatim)

*"also, I don't really like this phrasing about this library doesn't have a passphrase lock because it doesn't tell
you why or how to solve it. I feel like it's unclear. maybe 'your account's passphrase hasn't been entered on this
computer yet, please do so'. I honestly feel like maybe it should be a recurrent notification until it's done - maybe
make a ticket for that? thoughts? I do think we should make it clear it's not the 'ideal' state for users and
encourage them to resolve it. they can still change their passphrase if they forgot it."*

- **The sentence direction (binding on every E6 face this run writes):** say WHY and the ROAD, never the mechanism —
  her draft's shape: *"Your account's passphrase hasn't been typed on this Mac yet — type it here to use it on this
  Mac."* (built provisional in P-VX529-3's class, her wording pass polishes; "lock" talk is out).
- **The recurrent surfacing: TICKETED (VX-538)** — the E6 state surfaced as not-ideal, recurring until resolved, in
  the band card's one home (the calm-first rules: a dismissible card above the quick entry, never a popup, never a
  second bar), rule 3's cadence as the pattern; the generalized heal (P-VX529-4) is what retires it automatically —
  the card ends the moment a typed passphrase lands the lock. The card also says the forgot-road plainly: Reset
  forgotten passphrase works in this state (no follow is owed in plain E6 — the gate is not in the way), and setting
  one you know lands the local lock in the same act. Since the card is a standing sentence about the passphrase,
  its clause is DRAFTED FOR HER beside CastleRules rule 3 at closeout (the rules change only at her word — this ask
  is her word; the clause text still goes to her verbatim before it enters the rules).

## UNIT 1 — CLOSED (2026-10-24, the architect's verification)

P1–P7 all landed and verified: the diffs read line-by-line (the `PassphraseLockChange` enum, the heal primitive's
deliberate narrowness, the F-10 helper, the words arm's rollback-not-trade rule); the pair suites re-run by the
orchestrator's own hand at every seam — finally **70 tests in 16 suites green** (5 known: P2's negative controls +
P6d's residual); zero `Sync/` lines by diff; the Mac app builds clean against the finished core (the orchestrator's
xcodebuild on the P7 tree, exit 0 — F-1's arms and P7-0's face arms compile). The implementer's premise correction
accepted (`settingPassphrase` already lands-or-replaces; the heal primitive stays narrower on purpose, pinned). One
protocol slip, honestly flagged and accepted as recorded: P7-2's revert-in-flight line went into the pushed P7-2
bullet rather than the banner — named and pushed before the revert began, so the protocol's substance held. The core
contract unit 2 builds on: the pair door takes EITHER current secret (`.oneSecret`); a words-arm landing leaves E6
(no lock, nothing owed); the heal primitive `KeyFile.landingTheAccountsPassphraseLock` awaits its unit-2 consumers.

## UNIT 2 — THE BRIEF (a FRESH `opus-implementer`, one session; THE FACES — everything the author sees)

**Read first, in full, yourself (never delegated):** CLAUDE.md and its auto-loaded canon;
`notes/SessionResiliencyProtocol.md`; `notes/CastleRules.md` WHOLE; `notes/SyncSpec.md` WHOLE; SurfaceContracts'
protection bullet; **THIS FILE WHOLE** — the design §3 is your contract, with THE RULINGS, R-529-5 (ratified, the
window sentence), R-529-6 (her face direction: the WHY and the ROAD, never the mechanism), the E6 sweep, both
architect rulings and unit 1's LIVE STATUS; the VX-510 record's ENVIRONMENT TRAPS section
(`notes/plans/fixes/vx-510-first-run-sync.md`). The code: `Sources/VariorumCore/Protection/Executor/Acts/PairCatchUp.swift`
whole (the core contract), `Assess/Assess.swift`'s pair arms, `Model/KeyFileRelock.swift`; app-side
`App/Variorum/Shared/Protection/` — `RoadAccountModel.swift`, `RoadAccountFaces.swift`, `ProtectionAccountActs.swift`
(the preflight, `RoadSettledFollow`), `ProtectionOpenRoad.swift` (the typed-unlock seam at :540-580, the bounded
vault read), `ProtectionLobbyModel.swift` + `ProtectionLobbyFace.swift`, `ProtectionSecretCheck.swift`,
`ProtectionWords.swift`, and the Mac lobby's view (`StoreLockView`).

**The scope (one acceptance unit — the run's own faces; the riders are UNIT 3's, not yours):**
1. **The follow sheet's pair kind:** the sentence naming the half, device and day (the passphrase half reuses
   `passphraseChangedElsewhere`; the words half P7-0's twin; both halves name both); the one-secret ask live
   (passphrase or words — the door already says `.oneSecret`); on the words arm, R-529-5's window sentence ("Until
   you type your account's passphrase on this Mac, copies made here open with your twelve words.") and the Reset
   chain line; the second-road quiet line (design §3, P-VX529-2); the first round at once with the sheet staying
   (the P-VX510-1 account-act convention — the catch-up changes sync's standing in Castle); the quiet words-only
   follow's durable notice (R-529-2/E8: the words recorded before ‹day› no longer open this library; older backups
   keep them).
2. **`RoadSettledFollow.kind`** tells a settled pair follow apart (its act in flight names no new key), and the STALE
   done-line ("…and this Mac caught up.") never renders while a pair follow is OWED (the repro's stale line).
3. **The lobby — R-529-1's vault road (the most sensitive piece; smallest possible diff):** a typed passphrase that
   fails every local road, signed in and online, earns ONE bounded vault read (the VX-501 bounded-read pattern at
   `ProtectionOpenRoad`); derived under the VAULT's descriptor, opening the vault's master, the master opening the
   key file's master lock ⇒ THE LIBRARY OPENS, and the catch-up (or, on a plain-E6 file, the heal) lands in the same
   act with the typed secret in hand, a durable notice saying what happened. Offline or signed out: today's refusal,
   byte-identical. Detected but not landed (the read worked, the secret refused): the honest sentence naming device
   and day plus the road line. R-529-6 binds every E6 sentence: the why and the road ("Your account's passphrase
   hasn't been typed on this Mac yet — type it here to use it on this Mac." — the class, provisional). GUARDRAILS:
   nothing written before the open succeeds and the act runs its plan; a failed road leaves every byte as it was;
   no Touch ID behavior changes; the one-presenter and words-clipboard rules stand.
4. **The check door:** the fourth answer gains the pointer line ("You can catch this Mac up in Settings ▸
   Protection.") only when the state is the catch-up's; the E6 variant's wording per R-529-6; the door still WRITES
   NOTHING — its contract is literal.
5. **The preflight and gate faces:** `accountSecretRefusal` names a words change (P7's pending note); the key doors'
   gate refusal in the detected state speaks the pair sentence pointing at the follow (R-529-3).
6. **F-1's four app arms** become the pair kind's real sentences (followNotice / followAsk / followDone /
   `FollowDoneMark`).
7. **The E6 heal's wiring (P-VX529-4, provisional):** the vault-road open and the SYNCED key doors land a missing
   passphrase lock via `KeyFile.landingTheAccountsPassphraseLock` whenever a typed passphrase verified against the
   vault is in hand; NEVER the check door.
**Out of scope:** the riders (VX-526/522/523/533/530/538 — unit 3's), the band card (VX-538, her word pending),
anything in `Sources/VariorumCore/Sync/` (zero lines; stop-and-report), any schema or stored-shape change, mobile
faces (the parity row is the closeout's).

**The discipline:** exactly unit 1's — pins red-on-old committed before fixes, reverts named then run, commit per
piece + push, LIVE STATUS (UNIT 2) from the first commit, PENDING on every unverified claim, "Part of VX-529", NO
trailers. Headless core suites plus ONE Mac and ONE iOS `build-for-testing` into `DerivedData/vx529-u2*`; NO
`xcodebuild test` (the Mac-target suite runs ride the closing stage batch), no stage, no app launch, no
store/server/production contact, no subagents. Every new sentence sentence-case, PROVISIONAL (P-VX529-3's class),
LISTED in one place in your LIVE STATUS for her wording bundle. Model/view-model state-transition tests are the
evidence for every face (the lobby model's roads, the sheet's states, `RoadSettledFollow`); UI-only glue may land
with the walk as its evidence (the orchestrator's acceptance walk follows your close).

### UNIT 2 — LIVE STATUS (the implementer owns this section)

**NOT DONE IN THIS UNIT:** the riders (unit 3's — VX-538 included, her word); mobile FACES (the shared brains compile for
the phone and its lobby inherits the E6 field and the vault road — the parity row is the closeout's); the Mac-only suites'
RUNS and every Mac-target run of this unit's suites (the closing stage batch — list under U2-P7); the acceptance walk (the
orchestrator's); the vault road's WORDS twin (F-U2-3) and the third check answer's pointer (F-U2-10) — not in the brief;
the QUESTIONS entry for P-VX529-U2-1..5 (the merging session's ledger). Every piece U2-P0…P7 DONE. Zero
`Sources/VariorumCore/Sync/` lines (by design — none needed). No revert is in flight. Session: a fresh `opus-implementer`,
2026-10-24, worktree `~/dev/variorum-vx-529`. (The orchestrator's `eb0757ab1` landed in this worktree during my read —
UNIT 3's section only, committed and pushed; nothing uncommitted, so I continued.)

**Read first (all read in full, in this session):** CLAUDE.md + the loaded canon; `notes/SessionResiliencyProtocol.md`;
`notes/CastleRules.md`; `notes/SyncSpec.md`; SurfaceContracts whole (the protection bullet); this file whole; the VX-510
record's ENVIRONMENT TRAPS. Code: `PairCatchUp.swift`, `Assess.swift`, `Assessment.swift`, `KeyFileRelock.swift`,
`KeyFile.swift`, `KeyDoors.swift`, `Follow.swift`, `Executor.swift`, `PlanRunner.swift`, `CommonSteps.swift` (the vault
reads, `holdSyncKeys`), `ProtectionRecord.swift`, `Facts.swift`; app-side `ProtectionAccountActs.swift`,
`RoadAccountFaces.swift`, `RoadAccountModel.swift`, `ProtectionOpenRoad.swift`, `ProtectionLobbyModel.swift`,
`ProtectionLobbyFace.swift`, `ProtectionSecretCheck.swift`, `ProtectionWords.swift`, `ProtectionKeyDoorActs.swift`,
`RoadKeyDoorFaces.swift`, `ProtectionOpenFaces.swift` (`RoadStandingModel.make`), `AppBootstrap.swift` (the account,
key-door and lobby roads), the Mac `StoreLockView.swift` and `RoadAccountSheet.swift`; the planted worlds
(`ProtectionAccountSupport`, `ProtectionOpenRoadPlantedTests`, `TypedUnlockSyncKeysTests`, `ProtectionJoinFollowRoadTests`).

**The pieces (flip per commit; unverified claims PENDING):**
- U2-P0 — this LIVE STATUS, the plan and the findings before code. DONE (this commit).
- U2-H — the headless harness: DONE (not durable — this session's scratchpad `u2-harness`; the VX-510 unit A recipe
  rebuilt: tools 6.2, macOS 26, the app target's settings on `Variorum` — Swift 6, default `MainActor`, approachable
  concurrency, member import visibility, `DEBUG` — the test target without default `MainActor`; the core by path,
  swift-dependencies, the sqlcipher GRDB fork). `Variorum` symlinks every `Shared/Protection/*.swift`, `Shared/`'s
  `AppBootstrap`, `AppServices`, `SyncSession`, `SyncStatusViews`, `ProtectionController`, `AuthSession`, `AuthViews`,
  `KeychainCustody`, `LibraryOpenCopy`, `WordsCopyDoor`, `ProjectConfig`, `TierViews`, `ErrorPresentation`,
  `IdleCommitScheduler`, `StoreBackup`, `OperationsRunner`, `DeviceName`, `BackupDestination`, `BackupLog`,
  `MarkdownInsurance`, `BookNameCopy`, `ExportWriter`, `StoreLocation`, `LibraryHandOff`, `RestoreHoldModel`, `WingState`,
  `PeekableSecretField`, `TravellingDotsIndicator`, `Theme/*`, `SampleLibrary/*` minus `SeededBookRestore`,
  `Features/WhatsNew/WhatsNewLedger.swift`, and ONE stub file (a slim `AppSession` + `StatusCenter`, a no-op `CopyForAI`).
  The tests: `VariorumTests/Protection/*.swift` MINUS the Mac-view suites that cannot compile without the Mac app
  (`DataSafetyRoadCounts`, `RoadLockViewNamesPin`, `VX379PaneRows`, `WordsBandSurface`, `ReadmeStartHerePlan`,
  `RoadAccountSurface`, `PreDesignFace`, `LookInsideCopyDoor`, `OneSyncKeysLeaf`, `SecretCheckSurface`,
  `TutorialNewRoadChapter`, `ProtectionKeychainFamily`, `RoadCrossingSurface`, `RoadIdleDialRoute`,
  `RoadJoinFollowSurface`, `RoadKeyDoorSurface`) and MINUS every suite that writes the REAL login keychain under a
  throwaway scope (`RoadWorld`'s: `EmptySlotMakeMineRoute`, `ICloudAppleKeysLeaf`, `KeychainLeaves`, `MakeMineRoute`,
  `PreDesignLandingsRoute`, `PlaintextExportBringInRoute`, `PreDesignStartFreshRoute`, `ProtectionBackupHook`,
  `ProtectionCrossingRoute`, `ProtectionFacesRoute`, `ProtectionFactsGatherer`, `ProtectionRoadRoute`,
  `ProtectionSystemComposition`, and `LockWorld`'s `RoadLockRoute`, `WordsLedgerCarryRoute`, `OtherLibrariesDeleteRoute`)
  — the planted worlds only; plus `AppTestKeyProvider` and `SeededGenerator` byte-copied. **BASELINE on the pre-fix tree
  (`b6b805ab7`): `✘ Test run with 460 tests in 84 suites failed … with 5 issues`** — all five harness-PATH artifacts
  (source pins reading `#filePath` beside a symlink: `CopyListingFacesSurfaceTests` ×2, `EmptySlotDoorsSurfaceTests` ×2,
  `ProtectionRoadSwitchTests` ×1 — they run in the Mac target). Every other test green.
- U2-P1 — scope 6 + scope 1's words: the pair kind's real sentences (`followNotice` / `followAsk` / `followDone` /
  `FollowDoneMark`), the follow sheet's pair-kind confirm (the half, device and day; the one-secret ask; the second-road
  line, P-VX529-2), the durable notice for the pair kinds (R-529-2/E8's words-only line; R-529-5's words arm with its window
  and Reset-chain lines), the open-session follow's Done made DURABLE (VX-457 — today only the reopen seam marks it; the
  pair follow runs on the open session, F-8), E14's face (a words-only catch-up with no master in hand asks one secret).
  IN-PROGRESS — BUILT (this commit): `ProtectionWords` — the pair kind's `followNotice` (the half named — `pairHalves`),
  `followAsk` (passphrase moved: "…your account's current passphrase or your twelve words…"; words only: "…catches up
  without asking you for anything."), `followDone` (the half, then what the old secrets open now — E8), the new
  `followDoneNotice`, `pairSecondRoad`, `pairNeedsASecret`, `pairWordsWindow`, `pairResetChain`,
  `passphraseLandedNotice`; `FollowDoneNotice` (app-side: a follow's kind · R-529-5's words arm · the heal) with
  `FollowDoneMark` names for the pair halves, the words arm and the heal (`notice`/`set(notice:)`; `owed` kept, mapping
  the words arm to the passphrase-moved pair kind and the heal to none; a later build's name reads none);
  `RoadAccountFaces.followDoor` — the pair's second road (P-VX529-2) and E14 (`asksASecret` — the door's ask `.oneSecret`
  with `pairNeedsASecret` when this Mac holds no CURRENT account keys: `ProtectionPaneRead.accountKeysInHand` — session
  memory, the silent item, Castle's listed Touch ID item, the core door's own order; read only when a words-only pair is
  owed); `ProtectionAccountRoad.followDoneNotice(for:)` + `openSessionLanding` (F-U2-1 — the open session's follow owes its
  Done durably and no receipt, by the seam's own rule) wired in `AppBootstrap.accountRoads().press`; the reopen seam marks
  the notice too; the section reads the whole notice (`followDoneNoticeOwed`); the Mac section renders
  `followDoneNotice`; `RoadAccountConfirmModel.landedLines` (the words arm's window + Reset chain beside the round) and the
  Mac sheet renders them. The first round with the sheet staying was already wired (`owesFirstRound`, the open-session
  road — unit 1's F-8 confirmed). `FollowDoneNoticeTests.onlyTheNewRoadNamesTheMark` WIDENED DELIBERATELY (the bootstrap
  may read `FollowDoneMark.notice(libraryID`; its rule — only the new road names the mark — stands). Tests:
  `PairFollowFacesTests` (the sheet's three arms incl. E14 pressed to landing; the mark's every notice; the notice's
  words; no shouting; the open-session landing rule; the words arm's sheet) and `PairFollowDoneDurableTests` (F-U2-1 end
  to end — the bootstrap, real services, a fake server). **GREEN** (the harness, `--filter "PairFollowFacesTests|
  PairFollowDoneTests|PairPreflightAndGateTests|FollowDoneNoticeTests|RoadJoinFollow|ProtectionJoinFollowRoadTests|
  RoadAccountModelTests|RoadAccountFacesTests|FirstRoundConfirmTests"`): `✔ Test run with 83 tests in 11 suites passed`;
  `--filter PairFollowDoneDurableTests`: `✔ 1 test`. THE REVERT (named before it runs; F-U2-1's red, its fix having been
  written before its pin — said so): RV-P1-1 `AppBootstrap.swift` — the open-session landing block removed (the press as
  before), the harness `--filter PairFollowDoneDurableTests`. **VERIFIED BY REVERT** on `389f3bdb9`: `✘ Test run with 1
  test … with 2 issues` — no mark (`FollowDoneMark.owed(libraryID…) == .pairChanged(passphrase: true, words: false)`) and
  no notice in the section (`account.followDone != nil`); restored by `git checkout --`, `git diff --exit-code` clean, `✔ 1
  test` green again. DONE (`389f3bdb9`). No revert is in flight.
- U2-P2 — scope 2: `RoadSettledFollow.kind` tells a settled pair follow apart (its act in flight names no new key) —
  bug-class (today it reads `.keysReplaced` and the durable Done says the keys changed) — and the stale done-line never
  renders while a follow is owed (the repro's line) — bug-class. IN-PROGRESS — the red pins COMMITTED (this commit,
  `VariorumTests/Protection/PairFollowDoneTests.swift`): **RED on the pre-fix tree** (the harness, `--filter
  PairFollowDoneTests`): `✘ Test run with 2 tests in 1 suite failed … with 5 issues` — `aSettledFollowNamingNoNewKeyIs
  ThePairCatchUp` ✘×4 (resumed and finished-from-record, both postures: `.keysReplaced` where the pair kind is owed; its
  re-keying guards green), `theDoneLineNeverStandsBesideAnOwedFollow` ✘×1 (`model.followDone == nil` — the stale
  `.keysReplaced` beside an owed follow). THE FIX COMMITTED (this commit): `RoadSettledFollow.kind` — an act in flight
  naming no new key ⇒ `.pairChanged(passphrase: false, words: false)` (the halves no durable fact holds); `RoadAccountModel
  .land` — no follow Done while the faces carry an open follow door (the mark untouched). F-U2-5's fixture corrected
  (`theSettledFollowIsReadFromDurableFacts` — a new key named; every assertion unchanged). **GREEN** (the harness,
  `--filter "PairFollowDoneTests|ProtectionJoinFollowRoadTests|RoadAccountModelTests|FollowDoneNoticeTests"`): `✔ Test run
  with 31 tests in 4 suites passed`. THE REVERTS (named before they run; each one line on this commit, the harness
  `--filter PairFollowDoneTests`, restored by `git checkout --`): RV-P2-1 `ProtectionOpenRoad.swift` — the pair arm removed;
  RV-P2-2 `RoadAccountModel.swift` — `followDone = roads.followDoneOwed()` back. **VERIFIED BY REVERT** on `52eb5cc9c`:
  RV-P2-1 ⇒ `✘ … 2 tests … with 4 issues` (the four settled-kind rows, exactly the pre-fix red); RV-P2-2 ⇒ `✘ … with 1
  issue` (`model.followDone == nil`); each restored by `git checkout --`, `git diff --exit-code` clean, the suite `✔ 2 tests`
  green again. DONE (`8e7d425fe` pins, `52eb5cc9c` fix). No revert is in flight.
- U2-P3 — scope 5: the preflight's words twin (`accountSecretRefusal` says "Those twelve words don't open this library."
  for old words that DO open it after a words change elsewhere — bug-class, the core's P7-2 split mirrored) and the key
  doors' gate refusal in the detected state speaking the pair sentence (R-529-3). IN-PROGRESS — the red pin COMMITTED
  (this commit, `VariorumTests/Protection/PairPreflightAndGateTests.swift`): **RED on the pre-fix tree** (the harness,
  `--filter PairPreflightAndGateTests`): `✘ Test run with 1 test in 1 suite failed … with 1 issue` —
  `theFollowsPreflightNamesAWordsChangeElsewhere` at `old == .refused(named)`: the preflight said `"Those twelve words
  don't open this library."` where the core's own act (asserted in the same test, green) says `"Your twelve words were
  changed on Studio Mac on January 13."`; the nobody's-words guard and nothing-written green. THE FIX COMMITTED (this
  commit): `accountSecretRefusal`'s words arm — on a follow, words the vault refuses that open THIS library's current key
  through its own key file ⇒ `wordsChangedElsewhere(device:day:)` (the core's `wordsOpenThisLibrary` predicate, restated);
  else the plain refusal. THE GATE (a design row, R-529-3): `RoadKeyDoorFaces.derive` — `.refused(.followOwed)` while the
  owed follow is the pair kind ⇒ `ProtectionWords.followFirstToCatchUp(kind, device:day:)` (the follow's notice + "Follow
  your account to catch this Mac up first."); every other follow keeps the generic line (guarded). Its face test:
  `theKeyDoorsGateSaysThePairChangeAndPointsAtTheFollow` (all three key doors; the Castle-entry guard). **GREEN** (the
  harness, `--filter "PairPreflightAndGateTests|ProtectionJoinFollowRoadTests|RoadKeyDoorRoadTests|RoadKeyDoorsModelTests|
  ProtectionAccountRoadTests|RoadKeyDoorWordsTests"`): `✔ Test run with 44 tests in 6 suites passed`. THE REVERT (named
  before it runs; one line on this commit, the harness `--filter PairPreflightAndGateTests`, restored by `git checkout --`):
  RV-P3-1 `ProtectionAccountActs.swift` — the words arm's `follows` clause removed. **VERIFIED BY REVERT** on `6d6c1ab6c`:
  `✘ Test run with 2 tests … with 1 issue` (`old == .refused(named)` — exactly the pre-fix red; the gate's test green
  through it); restored by `git checkout --`, `git diff --exit-code` clean, `✔ 2 tests` green again. DONE (`d6a587914` pin,
  `6d6c1ab6c` fix). No revert is in flight.
- U2-P4 — scope 4: the check door's fourth answer gains the pointer line in the catch-up state; its E6 variant (R-529-6);
  the door still writes nothing. DONE (this commit) — a design row (its tests, no red-on-old). `SecretCheckOutcome
  .doesNotOpen` gains `because: AccountOnly? = nil` (`.catchUpOwed` · `.notTypedHereYet` — existing constructions compile
  unchanged); `ProtectionSecretCheck.check` reads why from the vault it already read (`checkAccount` returns it beside
  the half — a READ: `AssessRules.pairFollow` on the live key file; E6 a passphrase over a synced file with no lock);
  `ProtectionWords.checkSecretsCatchUpPointer` (the design §3 draft verbatim) and `checkSecretsAccountPassphraseNot
  TypedHere`. `SecretCheckRoadTests.theHonestSplitWhenTheAccountsSecretsChangedElsewhere` FLIPPED DELIBERATELY (the fourth
  answer's two arms carry `.catchUpOwed` and the pointer — said in the test). NEW `PairCheckDoorTests`: E6 — the account's
  passphrase says why, NOTHING written (every leaf's log, every item, every byte; the lock never lands — never the
  check's), a nobody's passphrase the plain refusal, the words open both; the pointer only in the catch-up's state.
  **GREEN** (the harness, `--filter "PairCheckDoorTests|SecretCheck"`): `✔ Test run with 19 tests in 5 suites passed`
  (`SecretCheckCompositionTests`' source pins among them).
- U2-P5 — scope 7 (core): the E6 heal wired — `regenerateWords`' key-file step lands a missing passphrase lock with the
  account's passphrase it verified against the vault (inside its plan); a public, unplanned single-write heal for the
  lobby's vault road (`landingTheAccountsPassphraseLock` through the existing key-file road; the mirror follows — the
  `landAppleWrap` repair's precedent for a one-write lock addition). Headless core pins. IN-PROGRESS — BUILT (this
  commit): NEW `Executor/Acts/PassphraseLockHeal.swift` — `ProtectionExecutor.landTheAccountsPassphraseLock(_:passphrase:
  vault:)`: refuses (nothing written) an unsynced library, an act in flight, no live key file of the current key, another
  account's vault, the account moved (posture or sync key), a passphrase the vault refuses (P1's split), a master that
  doesn't reach this key; a standing lock is never replaced (returns false); else ONE key-file write
  (`landingTheAccountsPassphraseLock`) then the mirror (`writeMemory`). `vault:` takes the caller's read (the lobby's one
  bounded read — verified, never trusted: its master must open this key file's master lock); nil reads this session's,
  else once. `KeyDoors.swift` (New words' key-file step, synced arm, beside the copy refresh): a missing lock lands with
  the passphrase the door verified against the vault (inside the act's plan, its one write). Tests:
  `Tests/VariorumCoreTests/Protection/Executor/E6HealWiringTests.swift` — the heal lands under the vault's descriptor, the
  file byte-equal but the lock, the mirror follows, writes exactly `[keyFile, memory]`, idempotent (both postures); the
  caller's read (the vault unreachable after it); a standing lock never replaced; the refusals each write nothing; New
  words on E6 lands the lock (both postures, fact 1's guard green). **GREEN** (`swift test --filter "E6HealWiringTests|
  E6HealPrimitiveTests|PairInvariantPinsTests|NewWordsResumeTests|FileLessWordsTests|KeyDoorResumeTests|PairCatchUp|
  PairRefusalSplitTests"`): `✔ Test run with 73 tests in 17 suites passed … with 5 known issues` (P2's 4 controls + P6d's
  residual). THE REVERT (named before it runs; the key doors' wiring's red — written before its pin, said so): RV-P5-1
  `KeyDoors.swift` — the heal clause removed, `--filter E6HealWiringTests`. **VERIFIED BY REVERT** on `d4c1bdd54`: `✘ Test
  run with 5 tests in 1 suite failed … with 6 issues` — `newWordsLandsTheMissingPassphraseLock` ✘ in both postures (no lock
  under the vault's descriptor, the account's passphrase not opening it, fact 1's `passphraseLock: true` guard); the
  lobby heal's four tests green through it; restored by `git checkout --`, `git diff --exit-code` clean, `✔ 5 tests` green
  again. DONE (`d4c1bdd54`). No revert is in flight.
- U2-P6 — scope 3: THE LOBBY'S VAULT ROAD (below, THE DESIGN AS BUILT). The pure decision in the core
  (`VaultRoad` — headless pins), the app's composition in `ProtectionOpenRoad.openTyped`'s `.noneOpens` arm, the lobby
  face's E6 arm. Pins red-on-old for the silent refusal where the sentence is owed. IN-PROGRESS — the red pins COMMITTED
  (this commit, `VariorumTests/Protection/LobbyVaultRoadTests.swift`): **RED on the pre-fix tree** (the harness, `--filter
  LobbyVaultRoadTests`): `✘ Test run with 7 tests in 1 suite failed … with 4 issues` —
  `theAccountsCurrentPassphraseOpensThroughTheVaultAndCatchesUp` ✘ in BOTH postures (Castle Always ask, Standard with its
  quiet roads gone: the account's current passphrase refused — the VX-510 repro), `aPassphraseThatOpensNeitherNamesThe
  Change` ✘×2 (the bare `"That passphrase doesn't open this library."` where the change was readable). The five
  guardrails GREEN on the pre-fix tree, as they must stay: offline byte-identical + nothing written; a slow server costs
  the bound then today's refusal; signed out / another account read nothing; a read-only road reads nothing; the old
  passphrase still opens locally with the follow owed. THE ROAD COMMITTED (this commit): NEW core
  `Executor/VaultRoad.swift` — `VaultRoad.answer(_:vault:files:live:floor:)` (pure; the design above, `VaultRoadAnswer`:
  `.opens(key, derived:)` · `.passphraseChangedElsewhere(device:day:)` · `.notTheAccountsPassphrase` · `.nothingToSay`) with
  `Tests/VariorumCoreTests/Protection/Executor/VaultRoadTests.swift` (5: the road both postures; the change named; E6's two
  answers; nothing proven nothing said — another account's vault, both halves moved (the account-current passphrase still
  OPENS), an unsynced file, nothing moved, the production floor; a new master reaching nothing) — `✔ 5 tests` headless.
  App: `ProtectionOpenRoad.openTyped`'s `.noneOpens` arm calls `openThroughTheVault` (ONE bounded read, writing road and
  signed in only; nil keeps today's refusal) → the key through the ordinary `open` → `catchUpThroughTheVault` (the one-act
  lock; the pair follow, then the E6 heal over the read in hand; failures logged, the library open; `RoadOpenReport
  .lobbyNotice`; the typed unlock's sync-keys load over the read in hand — `loadSyncKeysAfterTypedUnlock` gains an optional
  `vault:`, nil as before); `RoadStandingModel.make` marks `lobbyNotice` as the durable notice; `ProtectionWords
  .lobbyPassphraseChangedElsewhere` + `lobbyPairRoad` + `lobbyAccountPassphraseNotTypedHere` (R-529-6's draft);
  `ProtectionLobbyFace` — E6 (P-VX529-U2-1 (a)): the passphrase field and `accountPassphraseLine` over a synced key file with
  no passphrase lock while signed in; the Mac lobby renders the line under the lead. Design-row tests added to
  `LobbyVaultRoadTests`: the named sentence exactly, the landing's durable notice through `RoadStandingModel.make`, ONE
  bounded read before the open (`fetches == before + 3`: the decision's, then the act's own two — E4), no Touch ID read;
  E6 by birth (a fresh library joined by the words): the face's field and line (signed out: the words alone), a wrong
  passphrase "doesn't open this account" with nothing written, the account's passphrase opening through the vault with
  the lock landed under the vault's descriptor (`lobbyNotice == .passphraseLanded`, the line retired after). **GREEN**
  (the harness, `--filter "LobbyVaultRoadTests|TypedUnlockSyncKeysTests|TouchIDUnlockSyncKeysTests|ProtectionOpenRoad
  PlantedTests|ProtectionLobbyModelTests|RoadLockTests|FollowDoneNoticeTests|PairFollow|PairPreflight"`): `✔ Test run with
  75 tests in 12 suites passed` (VX-501's `theTypedLoadNeverDerivesThePassphrase` source pin among them — the vault road
  derives nothing; the core does). THE REVERT (named before it runs): RV-P6-1 `ProtectionOpenRoad.swift` — the `.noneOpens`
  arm's vault-road call removed, `--filter LobbyVaultRoadTests`. **VERIFIED BY REVERT** on `f073ee6b6`: `✘ Test run with 9
  tests in 1 suite failed … with 8 issues` — exactly the pre-fix four (the road refused in both postures; the bare
  sentence ×2) plus the design rows that ride the road (the named sentence; the landing; E6's account sentence and its
  open); the five guardrails green through it; restored by `git checkout --`, `git diff --exit-code` clean, `✔ 9 tests`
  green again. DONE (`9f15baf0b` pins, `f073ee6b6` road). No revert is in flight.
- U2-P7 — the close: DONE (this commit). On the final product tree (`49d7ff537`; the record commits after it touch no
  code):
  - THE HARNESS whole (debug; this unit's five new suites symlinked in): `✘ Test run with 484 tests in 90 suites failed …
    with 8 issues` — the baseline's five harness-PATH artifacts (`CopyListingFacesSurfaceTests` ×2,
    `EmptySlotDoorsSurfaceTests` ×2, `ProtectionRoadSwitchTests` ×1) plus F-U2-9's pre-existing week-boundary flake
    (`ProtectionPairRetentionTests` ×3 — 2026-10-25 00:20 UTC; nothing it exercises is in this diff). Every other test green
    (460 at baseline + 24 new).
  - THE CORE SUITE whole (`swift test`, debug, headless): VariorumCoreTests **`Test run with 3419 tests in 453 suites passed
    … with 5 known issues`** (P2's 4 negative controls + P6d's pinned residual); the one failure the ticketed MCP wall-clock
    flake `MCPHarnessTimeLimitTests.aPeerThatNeverAnswersInitializeFailsTheConnectNamedAndBounded` (VX-353 / VX-532) in
    VariorumMCPTests; no protection code in it.
  - **Mac `build-for-testing`** (`-derivedDataPath App/Variorum/DerivedData/vx529-u2`): `** TEST BUILD SUCCEEDED **`, exit 0;
    no warning in a touched file. **iOS `build-for-testing`** (`VariorumMobile`, `generic/platform=iOS Simulator`,
    `DerivedData/vx529-u2-ios`): `** TEST BUILD SUCCEEDED **`, exit 0.
  - Zero `Sources/VariorumCore/Sync/` lines (by `git diff --stat 9b8ac6745..HEAD -- Sources/VariorumCore/Sync`: empty); no
    schema, no stored shape (the key file's existing setters only; `FollowDoneMark`'s new names are a local UI ledger value
    an older build reads as none); no trailer on any commit.
  - **THE MAC-SUITE LIST for the stage batch** (every Mac-target and phone suite exercising a changed file — run by SUITE
    TYPE): NEW — `PairFollowDoneTests`, `PairPreflightAndGateTests`, `PairFollowFacesTests`, `PairFollowDoneDurableTests`,
    `LobbyVaultRoadTests`, `PairCheckDoorTests` (all harness-green); CHANGED — `ProtectionJoinFollowRoadTests`,
    `FollowDoneNoticeTests`, `SecretCheckRoadTests` (harness-green; their source pins read `#filePath` resolved, so they
    ran); exercising changed types, harness-green — `RoadAccountModelTests`, `RoadAccountFacesTests`,
    `RoadJoinFollowFacesTests`, `RoadJoinFollowModelTests`, `RoadJoinFollowWordsTests`, `TypedUnlockSyncKeysTests`,
    `TouchIDUnlockSyncKeysTests`, `ProtectionOpenRoadPlantedTests`, `ProtectionLobbyModelTests`, `RoadLockTests`,
    `RoadKeyDoorRoadTests`, `RoadKeyDoorsModelTests`, `RoadKeyDoorWordsTests`, `ProtectionAccountRoadTests`,
    `FirstRoundConfirmTests`, `FirstRoundAfterTheActTests`, `SecretCheckModelTests`, `SecretCheckCompositionTests`; Mac-ONLY
    (compiled, their runs PENDING the stage batch) — `RoadJoinFollowSurfaceTests` (the section's notice — `followDone`'s new
    type), `RoadAccountSurfaceTests` (`RoadAccountSheet`), `SecretCheckSurfaceTests` (`SecretCheckOutcome`),
    `RoadLockViewNamesPinTests` (`StoreLockView`), `RoadKeyDoorSurfaceTests` (the key-door faces); the PHONE —
    `MobileProtectionRoadTests` (the shared lobby face) and `MobileNoRedirectSweepTests` (in `MobileStructuralTests.swift` —
    every Shared literal; no new literal names the Mac — scanned). The core's new suites (`VaultRoadTests`,
    `E6HealWiringTests`) ran in the core suite above.

**THE LOBBY'S VAULT ROAD — the design as it will be built (scope 3; R-529-1; the guardrails literal):**
- WHERE: only `ProtectionOpenRoad.openTyped`'s `.noneOpens` arm, only for a PASSPHRASE (the brief's letter — see F-U2-3),
  only on a writing road (`ctx.writes` — a hosted test run reads nothing, `aReadOnlyRoadReadsNothing`), only while signed in
  (`ctx.session.accountID`). Everything before that arm — the quiet roads, the local typed roads, Touch ID — is untouched.
- ONE bounded vault read of the signed-in account (`boundedVaultRead`, VX-501's race, the same `typedUnlockVaultBound`).
  Offline, a timeout, no vault, signed out, read-only: today's refusal, byte-identical, nothing written.
- THE DECISION IS THE CORE'S, pure (`VaultRoad.answer` — new, `Executor/`): the typed passphrase derived under the VAULT's
  descriptor (its floor first); its master from the vault; that master tried on every key file this Mac holds for the
  slot (the live one first) — the first whose master lock opens is the key. Else, read from the live key file against the
  same reading: same account proven by the master's twelve-words copy being the vault's recovery wrap byte for byte (a pre-
  unlock binding with no secret — another account's vault never makes this Mac say "your passphrase was changed"), then
  passphrase lock under another descriptor ⇒ the change named (device and day); no passphrase lock (E6) ⇒ "That passphrase
  doesn't open this account." (VX-464's sentence — the only passphrase road in E6 is the account's); anything else ⇒ today's.
- THE OPEN: the key goes through the ordinary `open(ctx, candidates:typed:)` (the slot verifies it; the settle and repairs
  as at every open). NOTHING is written before that unlock succeeds; a key that does not open the slot ⇒ today's refusal.
- THE ACT, in the same press with the typed secret in hand (never a quiet road): with the session's one-act lock, a pair
  follow owed against the read (`AssessRules.pairFollow`) ⇒ the core's `follow(.pairChanged…)` (unit 1's act — its own
  fresh read re-verifies, E4); then, a synced file still without a passphrase lock ⇒ the heal (P-VX529-4). A failure of
  either leaves the library OPEN (never hostage — the follow stays owed in Settings), logged. Then the typed unlock's
  sync-keys load as today (VX-501). The durable notice: the account section's (VX-457's mark — `FollowDoneMark`), written
  by `RoadStandingModel.make` from the open's report, as a settled follow's is.
- The face: the lobby offers the passphrase field over a SYNCED key file with no passphrase lock (E6) while someone is
  signed in, with R-529-6's line ("Your account's passphrase hasn't been typed on this Mac yet — type it here to use it on
  this Mac.") — PROVISIONAL P-VX529-U2-1 (below). No Touch ID line, button or ask changes; the one presenter and the words
  clipboard are untouched.

**Findings before any code (traced in this session; each says what it changes):**
- **F-U2-1 — the open-session follow's Done is NOT durable today.** VX-457 marks a follow's Done only on the re-keying
  reopen seam (`AppBootstrap.accountActOnNewRoad`) and at a settle (`RoadStandingModel.make`); every follow before VX-529
  re-keyed. The pair follow runs on the OPEN session (`rekeys: false`, unit 1's F-8 confirmed: `RoadAccountModel.open` →
  `ProtectionAccountRoad.press`), whose `.made` carries `shown.receipt` — spoken ONCE on the status seam, so `receipt_style`
  off hides the catch-up's Done and a quit loses it. SurfaceContracts: "a follow's Done is a durable notice until OK
  (VX-457)". Changed in U2-P1: the open-session press of a follow marks the durable notice and speaks no receipt (the seam's
  own rule, `ProtectionAccountRoad.owed`, applied there too).
- **F-U2-2 — the lobby shows NO passphrase field over a plain-E6 file** (`ProtectionLobbyFace.derive`: the passphrase field
  only when a held key file carries a passphrase lock), so R-529-1's vault road, R-529-5's "meanwhile the account's
  passphrase opens it online through the vault road" and R-529-6's "type it here" are unreachable in E6 unless the face
  offers it. PROVISIONAL **P-VX529-U2-1** (built (a)): (a) the field over a synced E6 file while signed in, with R-529-6's
  line; (b) the field only, no line; (c) no change (E6 opens by the words; the heal reaches it only through the key doors).
- **F-U2-3 — the lobby's vault road takes the PASSPHRASE only** (the brief's and R-529-1's letter). The words twin is real:
  after a words change elsewhere, a lagging Castle Always-ask library's NEW words open nothing locally (the stale copy, the
  old own words lock), though they would open it through the vault the same way. Not built; for the bundle.
- **F-U2-4 — a pre-unlock binding exists for one half only.** Before unlock this Mac cannot read which account the library
  is bound to (the record is inside it). "Same account" is proven by the live file's master words copy equalling the vault's
  recovery wrap — true when only the passphrase moved (and in E6), false when the words moved too. So with BOTH halves
  moved, a passphrase that opens neither the library nor the account gets today's plain refusal (honest, never the named
  change for another account's vault). A typed account-current passphrase still OPENS (the master lock proves it).
- **F-U2-5 — `theSettledFollowIsReadFromDurableFacts`'s fixture carries no `toFingerprint`** (an `ActInFlight` built with
  the default nil), which every real non-pair follow has (each mints its new key at its press). Telling the pair kind by its
  nil `toFingerprint` (unit 1's own `FollowProgram.finishingSteps` reading) flips that pin's `.keysReplaced` row; the
  fixture is corrected (a new key named) and the pair row added — FLIPPED DELIBERATELY, said in the test.

**Findings during the build (each says what it changes or why not):**
- **F-U2-6 — the E6 heal's reach.** It lands at the lobby's vault road (a lobby asks only in Castle, or in Standard once
  its quiet roads failed) and at New words. A Standard E6 library whose quiet roads work has no typed-passphrase moment
  but New words — the check door's E6 line says "the next time your library asks for it here", which in Standard may be
  never. VX-538's recurring card (unit 3, her word) is the natural home for a field that lands it. Not built here.
- **F-U2-7 — every wrong passphrase at a signed-in lobby now costs ONE bounded vault read** (≤ the 10 s bound, offline
  fails fast) before its refusal — the price of saying the owed sentence (R-529-1); today's was instant. For the
  reviewer.
- **F-U2-8 — the vault road's catch-up runs unit 1's act inside the lobby press**, and that act reads the vault itself
  (its door's read and its step's — E4, by design) without the decision read's bound — as every synced act's resume at a
  lobby settle already does. A server that answered the bounded read and then stalls could hold "Opening your library…"
  up to the transport's own timeout. Residual, stated; the alternative (a deferred act on the open session once the app
  has opened, the typed secret held in memory until then) is for the reviewer's judgment.
- **F-U2-9 — a PRE-EXISTING wall-clock flake, not this unit's:** `ProtectionPairRetentionTests`
  (`pairsPastFourteenDailiesAndFourWeekliesArePrunedInThePickedFolder` ×2, `anotherMacsAndAnotherLibrarysCopiesSurvive
  EveryPrune` ×1 — 17 pairs where 18 are expected) failed in the harness at 2026-10-25 00:20 UTC (Sunday — the week
  boundary; the tests read `Date()`), green at the baseline run 23:40 UTC Saturday. No file they exercise is in this
  unit's diff (`FileBackupsLeaf`, `ProtectionBackupPair` untouched). A ticket for the orchestrator.
- **F-U2-10 — the check door's THIRD answer** (the old passphrase: "opens this library, but not your account" + VX-113's
  named change) could carry the same pointer in the catch-up's state; the brief names the fourth only. Not built.

**PROVISIONAL CALLS (the plan's PROVISIONAL rule; options for the closeout's QUESTIONS entry — the shared ledger is the
merging session's):**
- **P-VX529-U2-1** — the E6 lobby (F-U2-2): (a) BUILT — the passphrase field over a synced key file with no passphrase lock
  while signed in, with R-529-6's line; (b) the field, no line; (c) no change.
- **P-VX529-U2-2** — the stale done-line is hidden while ANY follow is owed (the brief says a pair follow): (a) BUILT — any
  (a Done's "caught up" is false while any follow is owed); (b) the pair kind only.
- **P-VX529-U2-3** — the pair Done says what the old secrets open now, the passphrase half too (E8 named the words): (a)
  BUILT; (b) the half alone, no second sentence.
- **P-VX529-U2-4** — E14's face asks one secret by READING the facts (session memory, the silent item, Castle's listed
  Touch ID item — the core door's own order) rather than after the core refuses: (a) BUILT; (b) optional fields on every
  words-only door.
- **P-VX529-U2-5** — the lobby's heal is an unplanned one-write re-lock (the `landAppleWrap` repair's precedent; a crash
  leaves the old file or the new; a stale mirror is the next open's `refreshMemory`): (a) BUILT; (b) a planned act (needs
  a stored act value — R-510-20 forbids one; or riding the follow's plan — it is no follow).

**NEW SENTENCES (every one PROVISIONAL, P-VX529-3's class, sentence case — for her wording bundle; ‹device› ‹day› are
the vault's last writer and day, "Mac" the platform's noun — "iPhone" on the phone):**
1. The follow's notice, the pair kind (`followNotice`): "Your account's passphrase was changed on ‹device› on ‹day›." ·
   "Your account's twelve words were changed on ‹device› on ‹day›." · "Your account's passphrase and twelve words were
   changed on ‹device› on ‹day›." · (a settle's halves-unknown form) "Your account's passphrase or twelve words were
   changed on ‹device› on ‹day›."
2. The follow's ask (`followAsk`): passphrase moved — "Type your account's current passphrase or your twelve words once to
   catch up." · words only — "This Mac catches up without asking you for anything."
3. E14 (`pairNeedsASecret`): "This Mac needs your passphrase or your twelve words once to catch up."
4. The second road (`pairSecondRoad` — the design §3 draft verbatim): "You can also set this library aside and re-join
   your account: a fresh library fills from sync under your account's current secrets. Writing that never synced stays in
   the set-aside copy."
5. The words arm's window (`pairWordsWindow` — her ratified draft verbatim): "Until you type your account's passphrase on
   this Mac, copies made here open with your twelve words."
6. The Reset chain (`pairResetChain`): "If you don't know your account's passphrase, set one you do with Reset forgotten
   passphrase."
7. The pair Done (`followDone`, the durable notice): passphrase — "Your account's passphrase was changed on another
   device, and this Mac caught up. Your previous passphrase no longer opens this library; backups you made with it still
   do." · words (E8) — "Your account's twelve words were changed on another device, and this Mac caught up. The twelve
   words you had before no longer open this library; backups you made with them still do." · both — "Your account's
   passphrase and twelve words were changed on another device, and this Mac caught up. Your previous passphrase and twelve
   words no longer open this library; backups you made with them still do." · halves unknown — "Your account's passphrase
   or twelve words were changed on another device, and this Mac caught up."
8. The words arm's Done (`followDoneNotice(.caughtUpByTheWords)`): "Your account's passphrase [and twelve words] was
   [were] changed on another device, and this Mac caught up with your twelve words." + 5 + 6.
9. The heal's Done (`passphraseLandedNotice`): "Your account's passphrase opens this library on this Mac now."
10. The key doors' gate (`followFirstToCatchUp` = 1 + `followFirstToCatchUpRoad`): "… Follow your account to catch this
    Mac up first."
11. The lobby, the change read (`lobbyPassphraseChangedElsewhere` = the bare refusal + 1 + `lobbyPairRoad`): "That
    passphrase doesn't open this library. Your account's passphrase was changed on ‹device› on ‹day›. Your account's
    current passphrase, the one before it, or your twelve words open it." *(F-R1-2's flag: "the one before it" is
    wrong when the passphrase changed twice+ while this device lagged — the local lock holds an OLDER one; the honest
    meaning is "the one this library last knew". For her wording pass.)*
12. The lobby, E6 (`lobbyAccountPassphraseNotTypedHere` — her R-529-6 draft's shape verbatim): "Your account's passphrase
    hasn't been typed on this Mac yet — type it here to use it on this Mac."
13. The check door's pointer (`checkSecretsCatchUpPointer` — the design §3 draft verbatim): "You can catch this Mac up in
    Settings ▸ Protection."
14. The check door, E6 (`checkSecretsAccountPassphraseNotTypedHere`): "That passphrase opens your account, but it hasn't
    been typed on this Mac yet. Type it the next time your library asks for it here, and it opens this library too."
REUSED, not new: "That passphrase doesn't open this account." (VX-464's — the E6 lobby's wrong passphrase); "Your twelve
words were changed on ‹device› on ‹day›." (P7-0's — the follow's preflight now says it).

## UNIT 2 — CLOSED (2026-10-25, the architect's verification and dispositions)

All seven scope items landed and verified: the vault-road diff read line by line (the pure `VaultRoad.answer`, the
one bounded read, nil ⇒ today's refusal byte for byte, the open verified against the slot before anything lands, the
never-hostage catch-up on the session's one-act lock, and the proven-the-account's guard — the master-words copy
matching the vault's wrap before any change is NAMED, so a foreign library never hears another account's story); the
core suites re-run by the orchestrator's own hand (97 tests in 28 suites green over the new pieces); zero `Sync/`
lines by diff; the Mac app's full build on the finished tree run by the orchestrator (exit 0, PENDING flipped at this
line). The implementer's surprises, DISPOSED:
- **P-VX529-U2-1 (the E6 lobby passphrase field, synced + signed-in only) — CONFIRMED under R-529-6's letter** (her
  words ask for exactly this: "…hasn't been entered on this computer yet, please do so" — the ask implies the field);
  provisional for her pass like every face.
- **F-U2-7 (a wrong passphrase at a signed-in lobby now costs one bounded vault read, up to the 10 s bound on a slow
  network, before its refusal) — ACCEPTED as a residual, and ADDED TO HER BUNDLE** beside P-VX510-B2-1 (her one
  flagged timing call): the refusal-path read shares the unlock's bound; a shorter bound for the refusal path is a
  candidate she may want.
- **F-U2-8 (unit 1's act, run inside the lobby press, does its own reads without the decision read's bound — a server
  that answers then stalls can hold "Opening your library…" to the transport timeout) — RECORDED for the ladder**,
  with the implementer's written alternative (defer the act to after the open) standing for the reviewer to weigh.
- **F-U2-6 (the heal reaches only libraries that show a lobby; a quiet-road Standard E6 library needs VX-538's card)
  — CONFIRMS VX-538's design**; noted on its ticket's scope in unit 3's brief below.
- **F-U2-9 (the pre-existing `ProtectionPairRetentionTests` week-boundary flake, `Date()` instead of the injected
  clock) — TICKETED: VX-539** (Bug, Test-only, Tests & tooling, Low).
- **The three deliberately changed tests** (the fixture naming no new key, the mark test's new allowance, the
  honest-split pointer expectation) — each noted in-test; NAMED HERE FOR THE LADDER'S ATTENTION.
The Mac-only suites and Mac-target runs remain PENDING THE CLOSING STAGE BATCH (U2-P7's list), as briefed.

## UNIT 3 — THE BRIEF (a FRESH `opus-implementer`, one session; THE RIDERS — six members, pin-before-fix PER MEMBER)

**Read first, in full, yourself:** CLAUDE.md and its auto-loaded canon; `notes/SessionResiliencyProtocol.md`;
`notes/CastleRules.md` WHOLE; SurfaceContracts' protection bullet; **THIS FILE WHOLE** (the rulings and both units'
LIVE STATUS are your ground truth; R-529-6 and the R-529-5 section carry VX-538's design); the VX-510 record's
ENVIRONMENT TRAPS section. Per member, the ticket's own description on the board snapshot
(`~/dev/variorum/notes/TICKETS.md`, by absolute path) is part of the brief — VX-533's carries its trace question and
her verbatim report. The code per member, found by trace (the join sheet and its words notice, the hold banner's
model, the lobby's Touch ID press road, `KeyDoors.holdSyncKeysForTheSession`, the band-card machinery —
`LibraryWordsCardModel.swift` / `WordsBand.swift` — and unit 2's new seams).

**The members (strictly sequential; each lands with its own red-on-old pin verified by revert, its own commits saying
`Part of VX-<member>`, and its own LIVE STATUS block under UNIT 3):**
1. **VX-526 — the join sheet's words.** The sheet a "Sync this library…" door opens still TITLES itself and its
   button "Turn on sync" (P-VX510-A4); align both to the door's own name. And W-12's notice says "backups you made
   before today" — imprecise (rule 7's own sentence; backups made earlier the same day, before the join, open with
   the previous words too): re-draft to the honest floor (the class: "your old words still open backups made with
   them"), PROVISIONAL for her bundle.
2. **VX-522 — the hold banner's promise.** An account-less restore still shows the catch-up clause on Resume
   (VX-473 built the condition — trace why this path misses it); pin red, fix, the banner speaks sync only when the
   landed library's record names an account.
3. **VX-523 — the words-adoption notice's condition.** A join from a restored copy whose words already match the
   account's still shows the words-replaced notice; VX-456/VX-462's stays-quiet rule is missing on that path — trace,
   pin red, fix through the same rule, never a second copy of it.
4. **VX-533 — the lobby's missed Touch ID prompt.** TRACE FIRST per the ticket: after the SYSTEM sheet times out
   (her report: "it looks like an apple timeout… gets pale and then disappears"), does the lobby's own "Unlock with
   Touch ID" button still stand, and does a re-press mint a FRESH LAContext (a dead context's press would no-op)?
   Fix to the trace: the button must stand and a re-press must genuinely re-ask; model-level pin. The lobby is the
   most sensitive face — smallest diff, unit 2's guardrails bind here too.
5. **VX-530 — the double Touch ID, TRACE-FIRST (her pick; fix ONLY on a confirmed benign ordering, else REPORT).**
   The suspected shape: `holdSyncKeysForTheSession` reads the Touch ID custody class BEFORE trying the typed secrets
   it was handed and the session (the VX-503 secrets-first class, one seam over), and the act's vault step reads
   again. Trace both prompts to their reads. If and only if the mechanism is exactly redundant reads of the same
   item: fix to secrets/session first, the Touch ID class last and ONCE per act (unit 1's `material:` carry is the
   worked example), with a counting-leaf pin (red on two reads, green on one). Anything else comes back to the
   orchestrator un-fixed.
6. **VX-538 — the recurring E6 band card (R-529-6, her design; F-U2-6 is its reason: a quiet-road Standard E6
   library sees no lobby, so the card is its one surface).** On the band-card machinery (the one home above the
   quick entry — never a popup, never a second bar; the calm rules: ✕ and snooze): shown while the open library is
   SYNCED and its live key file carries NO passphrase lock; it says the why and the road (R-529-6's direction:
   "Your account's passphrase hasn't been typed on this Mac yet — type it once and it opens this library here too."
   — the class, PROVISIONAL) and the forgot-road ("If you don't know it, set one you do with Reset forgotten
   passphrase." — Reset works in this state, the gate is not in the way); recurring on rule 3's cadence PATTERN but
   WITHOUT a don't-show-again (her "until it's done" — the deliberate delta from rule 3, PROVISIONAL, flagged in
   her bundle); it RETIRES ITSELF the moment a passphrase lock lands (the heal, a key door, the catch-up — read the
   state, never a flag). DRAFT the CastleRules rule-3-adjacent clause into your LIVE STATUS for her closeout ratify —
   NEVER write CastleRules itself (author-only; the rules are frozen to every hand but hers).
**Out of scope:** everything else — the ladder follows this unit; no `Sync/` lines; no schema or stored-shape
change; no CastleRules edit; mobile faces (the parity row is the closeout's).

**The discipline:** units 1–2's, verbatim — pins red-first by member, reverts named then run, commit + push per
piece, UNIT 3 — LIVE STATUS from the first commit with one block per member, PENDING on unverified claims, NO
trailers; headless core suites + ONE Mac and ONE iOS `build-for-testing` into `DerivedData/vx529-u3*`; no
`xcodebuild test`, no stage, no app launch, no store/server/production contact, no subagents; every new sentence
sentence-case, PROVISIONAL, consolidated in one list for her bundle.

### UNIT 3 — LIVE STATUS (the implementer owns this section)

> *(Read forward: VX-523 was later RULED (A)-in-this-run at R-529-7 and FIXED in ladder session L2 — this banner's
> "NOT FIXED" was true when written and is superseded below; the round-2 reviewer's F-R2-2 asked for this pointer.)*

**NOT DONE IN THIS UNIT:** **VX-523 NOT FIXED** — traced (the brief's premise corrected: the quiet rule IS evaluated; Make
this my library's key file can't satisfy it), its red pin held as a known issue, RETURNED to the orchestrator (the fix
changes what a custody act writes — options (A)/(B)/(C) in its block); VX-533's external fact (which status the system
sheet's own timeout returns) UNVERIFIED — the fix covers the thrown class, her Air's log tells; the Mac-target and phone
suite RUNS (the stage batch — the list under THE CLOSE); every walk; the QUESTIONS entry for P-VX529-U3-1…6 (the merging
session's ledger); the CastleRules clause (DRAFTED below for her — never written into the rules); mobile faces (VX-538's
card on the phone — the parity row). Every other member DONE: VX-526, VX-522, VX-533, VX-530, VX-538. No revert is in
flight. Zero `Sources/VariorumCore/Sync/` lines (by diff); no schema, no stored shape. Session: a fresh `opus-implementer`,
2026-10-24, worktree `~/dev/variorum-vx-529`.

**Read first (all read in full, in this session):** CLAUDE.md + the loaded canon; `notes/SessionResiliencyProtocol.md`;
`notes/CastleRules.md` whole; SurfaceContracts' protection and portability bullets; this file whole; the VX-510 record's
ENVIRONMENT TRAPS, W-5/W-6/W-11/W-12 (LEG S, LEG C) and O-B4-1 (UNIT B4); each member's Linear description (read-only).

**The harness:** unit 2's headless harness (`u2-harness` in this session's scratchpad — the VX-510 unit A recipe, the app's
`Shared/` sources symlinked into a scratch SPM package) reused in place; new suites/sources are symlinked in as each member
needs them. Not durable, never committed.

**Machinery (honesty):** during VX-538's pin commit the worktree moved under me — `notes/MobileSoul.md` and
`notes/plans/mobile-round-2-orchestrator-handoff.md` changed on disk (files I never touched), then the orchestrator's
`270b58394` (THE PHONE section, PL-59, the mobile addendum, the compromise-recovery recipe — "mid-run at her word") landed on
top of my `f378f6b5e` and was pushed while my own push raced it (refused on a ref lock; nothing lost — the remote carries
both). Read as the orchestrator writing deliberately in this worktree, not a twin implementer: I touched none of its files,
stage only my own paths, and re-read the record before every edit from here on.

**Members (strictly sequential; flip per commit; unverified claims PENDING):**
- **VX-526 — the join sheet's words.** DONE — THE TRACE: the sheet's title and button are `RoadAccountConfirmModel
  .title`/`.button` = `door.door.title`/`.button` — the `RoadAccountDoor` enum's per-door words, so `.turnOnSync` says
  `turnOnSyncTitle`/`turnOnSyncButton` ("Turn on sync") on BOTH arms; VX-506 renamed only the join arm's door (the
  `RoadAccountDoorOpen.label` override in `RoadAccountFaces.derive`). W-12's sentence is `ProtectionWords.joinWordsNotShown`
  (the passphrase-typed words moment — her #236 draft, PROVISIONAL), "…still open backups you made before today."; the
  shown-words arm says `joinWordsSentence`, rule 7's sentence VERBATIM (pinned byte-equal to CastleRules by
  `RoadAccountWordsTests`/`RoadJoinFollowWordsTests` — the rules are frozen to every hand but hers; see P-VX529-U3-1).
  THE RED PIN COMMITTED (this commit, `VariorumTests/Protection/JoinSheetWordsTests.swift`): **RED on the pre-fix tree**
  (the harness, `--filter JoinSheetWordsTests`): `✘ Test run with 3 tests in 1 suite failed … with 10 issues` — the join
  sheet's title and button "Turn on sync" (both postures ×3), the notice "before today" and no floor (both emails ×2);
  `moveKeepsItsOwnSheet` green (a guard, by nature). THE FIX COMMITTED (this commit): `RoadAccountDoorOpen.title`/`.button`
  (`RoadAccountFaces.swift` — Turn on sync's JOIN arm, `joinsAnAccount`, says `ProtectionWords.joinSyncTitle`/`joinSyncButton`
  = "Sync this library"; every other door its own) read by `RoadAccountConfirmModel.title`/`.button`; `joinWordsNotShown`'s
  middle sentence "Your previous twelve words still open backups made with them." (rule 5's floor). `RoadJoinFollowWordsTests
  .theJoinReadsAsDrafted` FLIPPED DELIBERATELY to the new text (said in the test). **GREEN** (the harness, `--filter
  "JoinSheetWordsTests|RoadJoinFollowWordsTests|RoadAccountWordsTests|RoadAccountModelTests|RoadAccountFacesTests|
  NotOnYetWordsTests|FirstRoundConfirmTests|FirstRoundAfterTheActTests|ProtectionJoinFollowRoadTests|PairFollowFacesTests"`):
  `✔ Test run with 95 tests in 13 suites passed`. THE REVERTS (named before they run; each one edit on this commit, the
  harness `--filter JoinSheetWordsTests`, restored by `git checkout --`, `git diff --exit-code` clean after each): RV-526-1
  `RoadAccountModel.swift` — `title`/`button` back to `door.door.title`/`.button` [expect the six title/button issues];
  RV-526-2 `ProtectionWords.swift` — the middle sentence back to "…backups you made before today." [expect the four words
  issues]. **VERIFIED BY REVERT** on `44d456b01`: RV-526-1 ⇒ `✘ … 3 tests … with 6 issues` (exactly the title/button rows,
  both postures); RV-526-2 ⇒ `✘ … with 4 issues` (exactly the words rows); each restored by `git checkout --`, `git diff
  --exit-code` clean, `✔ 3 tests` green again. **DONE** (`3e4714fb9` pin, `44d456b01` fix). No revert is in flight.
  **P-VX529-U3-1 (PROVISIONAL — the shown-words arm):** the words moment where the WORDS were typed says
  `joinWordsSentence`, rule 7's own italic sentence verbatim ("…the old ones still open backups you made before today"),
  pinned byte-equal to the rules file — the same imprecision, but the rules are hers alone. (a) BUILT: that arm stays
  verbatim; the rule-7 amendment is DRAFTED for her below (the app's text follows the rules the moment she rules); (b) change
  the app's arm now and relax the pin (the app would say other words than her rule — not without her word); (c) leave both
  arms as they were. **THE DRAFTED RULE-7 WORDING (for her closeout ratify; never written into CastleRules here):** rule 7's
  italic sentence ending "*…the old ones still open backups made with them*" in place of "*…the old ones still open backups
  you made before today*" — rule 5's floor in rule 7's voice.
- **VX-522 — the hold banner's promise.** DONE — THE TRACE (the brief's premise CORRECTED — VX-473's condition does
  NOT miss this path): the root renders `RestoreHoldBar(hasAccount: bootstrap.roadStanding?.syncsWithAnAccount ?? true)`
  (`VariorumApp.swift:354`); `RoadStandingModel.make` reads `syncsWithAnAccount` from `session.library.record?.account != nil`
  — false for Make this my library's new library (the copy carries no sync identity) — so the root takes
  `LibraryOpenCopy.holdBanner`'s `hasAccount: false` arm, and the walk's W-5 text IS that arm verbatim ("…Sync is waiting until
  you press Resume. To keep something from this backup, duplicate it first — duplicates stay."). THE DEFECT IS THE ARM'S OWN
  WORDS: Resume's `onResume` (`AppServices.resumeSync`) triggers a round that refuses (no account in the record —
  `NewRoadSyncKeyProvider`'s `notEnrolled`), the row then reads "Sync isn't on for this library yet" (the walk saw it), so no
  sync is waiting and no catch-up can remove anything the duplicate advice guards against. When a later join binds the
  library, the landing's `rereadAccountBinding` flips the banner to the account arm (VX-473, pinned), whose clauses are true
  then. THE RED PIN COMMITTED (`a5743dbcc` — that commit carried the pin only; this record line landed one commit later, by
  a missed edit — said so): `VariorumTests/Protection/HoldBannerNoAccountWordsTests.swift`, **RED on the pre-fix tree** (the
  harness, `--filter HoldBannerNoAccountWordsTests`): `✘ Test run with 2 tests in 1 suite failed … with 6 issues` — "Sync is
  waiting", the duplicate advice, and no "doesn't sync" (both as-of forms ×3); the account arm's guard green. THE FIX
  COMMITTED (this commit): `LibraryOpenCopy.holdBanner`'s `hasAccount: false` arm = the lead + "This library doesn't sync,
  so Resume changes nothing in it." (PROVISIONAL P-VX529-U3-2 below); the account arm, the condition and the root untouched.
  **GREEN** (the harness, `--filter "HoldBannerNoAccountWordsTests|HoldBannerAccountFactTests|
  HoldBannerAccountCompositionTests|RoadRestoreHoldGateTests|RestoreHold"`): `✔ Test run with 9 tests in 4 suites passed`.
  `LibraryPortabilityDoorTests.theHoldBannerNamesNoAccountWhereNoneExists` (Mac target, not in the harness) asserts no
  "account" and a "Resume" in the arm — both true of the new text by reading; its run PENDING the stage batch. THE REVERT
  (named before it runs; one edit on this commit, `--filter HoldBannerNoAccountWordsTests`, restored by `git checkout --`):
  RV-522-1 `LibraryOpenCopy.swift` — the arm's sentence back to "Sync is waiting until you press Resume. To keep something
  from this backup, duplicate it first — duplicates stay." [expect the six issues]. **VERIFIED BY REVERT** on `7a805a7c7`:
  RV-522-1 ⇒ `✘ Test run with 2 tests in 1 suite failed … with 6 issues` (exactly the pre-fix red); restored by `git
  checkout --`, `git diff --exit-code` clean, `✔ 2 tests` green again. **DONE** (`a5743dbcc` pin, `7a805a7c7` fix). No
  revert is in flight. **P-VX529-U3-2 (PROVISIONAL — the no-account banner):** (a) BUILT: the banner stands (the hold is
  still the gate a later join's first round meets — `firstRoundHeld`) with the true fact and what its door does; (b) no
  banner while the library names no account — the hold stands silently and the banner appears the moment a join binds the
  library (VX-473's re-read already flips it), a visibility change rather than words; (c) the restore confirm's own sentence
  ("…doesn't sync with your account until you turn on sync for it in Settings ▸ Protection") — it names an account a Mac with
  none doesn't have (round 4's NIT). The door's label "Resume Sync" is unchanged under (a) — a label change is hers.
- **VX-523 — the words-adoption notice's condition.** TRACED — NOT FIXED (STOP-AND-REPORT for this member; returned to the
  orchestrator). THE TRACE (the brief's premise CORRECTED — the stays-quiet rule is NOT skipped on this path): a join from
  the restored copy is `ProtectionExecutor.join` (`AccountActs.swift:325`), which computes `wordsReplaced = !sameWords` with
  `sameWords = ownLockOpens || wordsAreTheAccountsAlready(liveFile, vault:, master:)` — the one VX-456/VX-462 rule IS
  evaluated. By the PASSPHRASE (the walk's S15): `ownLockOpens` is false (no words typed), and the rule answers false at its
  FIRST clause (`file.words == nil`) — because Make this my library's new key file (`makeMineKeyFile`, `Copies.swift:128`,
  `newLocks(passphrase:…, words: true, master: false)`) carries an OWN words lock built from the current pair and no master
  lock or master's words copy (by design: "Never the account's master: the new library carries no sync identity",
  P-VX378-U2-4 (a)). The rule's proof is wrap identity (the copy byte-equal to the vault's recovery wrap); an own words lock
  wraps the LIBRARY key under the words and the vault's wrap wraps the MASTER under them, so no comparison of the two can
  prove the same words without the words (AES key wrap — nothing to compare without the key). So nothing in the files the
  restore writes can prove sameness, and the moment speaks. By the WORDS it stays quiet (they open the own lock — the rule's
  other arm). P-VX378-U2-4 (a)'s own text ("…since it already holds the current pair, which is the account's when the device
  was synced, no words are replaced") is the behavior expected; the code cannot see it. THE RED PIN COMMITTED (this commit,
  `Tests/VariorumCoreTests/Protection/Executor/RestoredCopyJoinWordsMomentTests.swift` — headless core): **RED on the tree as
  it stands** (`swift test --filter RestoredCopyJoinWordsMomentTests`): `✘ Test run with 2 tests in 1 suite failed … with 1
  issue` — `aRestoredCopyJoiningByThePassphraseHearsNoReplacement` at `!replaced(joined)` (a synced laptop joined by the
  passphrase, its own backup made its library under the account's pair, re-joined by the passphrase); the words-arm guard
  green. HELD AS A KNOWN ISSUE (`withKnownIssue`, said in the test) so the suite stays green and a fix must flip it: `✔ Test run
  with 13 tests in 3 suites passed … with 1 known issue` (with `JoinWordsMoment*`). WHY NOT FIXED (the options, for the
  orchestrator and her): **(A)** Make this my library on a device whose outgoing library is SYNCED (its words road the
  master's copy — VX-462's shape) writes the new key file in that shape too: the master recovered from the typed words and
  the outgoing file's copy, `settingMaster(master, wordsCopy: outgoingCopy)`, NO own words lock; the one rule then decides at
  the join (quiet while the account's words are unchanged; speaks after a change elsewhere — the copy is stale). This
  CHANGES WHAT A CUSTODY ACT WRITES — a new opener (the account's master; in Standard the silent sync-keys item holds it) on a
  library that binds no account — which is P-VX378-U2-4's option (b) territory ("the master and its words copy added"),
  hers, and not a rider's call. **(B)** leave it: the moment over-speaks with true sentences (the "previous" words are the
  same words; P-VX309-U2-1's honest-limit class) — no change. **(C)** a looser proof (the restored file's passphrase lock
  under the vault's own descriptor ⇒ "the pair was the account's") — REJECTED: unsound; a words change elsewhere before the
  restore (a lagging device restoring with its stale words) or after it leaves that descriptor equal and would go QUIET over a
  real replacement. Nothing built; no product line changed.
- **VX-533 — the lobby's missed Touch ID prompt.** DONE — THE TRACE (written before any fix): **(b) "a re-press lands
  on a dead context" is RULED OUT by code** — every press reads through a FRESH `LAContext` minted inside the read
  (`KeychainCustodyLeaf.readTouchID`, `let context = LAContext()` at :156); the only context handed out
  (`TouchIDPressContext`) is returned on a read that OPENED its item and invalidated in `pressTouchID`'s `defer`. The
  automatic ask (`autoAskIfDue` → `pressTouchID`) and the button press are the same function, the same road, a new context
  each. **(a) "the button disappears" is REAL on one class of press ending:** the face's button is `itemExists && usable`
  (`AssessRules.touchID`), and the model drops the Touch ID item from its facts only when a press reports `itemGone`
  (`ProtectionLobbyModel.pressTouchID`, `.touchIDNotOpened(…, itemGone: true)`). `ProtectionOpenRoad.pressTouchID`
  (:532) infers `gone = press == nil` — "no press recorded ⇒ the probe found no item" — but a press whose keychain read
  THREW leaves exactly that too: `readTouchID`'s arms name errSecUserCanceled (⇒ `.cancelled`) and errSecAuthFailed /
  errSecInteractionNotAllowed (⇒ `.failedOnExistingItem` or `.transient`); ANY OTHER status makes `ProtectionKeychain.readData`
  throw, the arms don't match, `setLastPress` never runs, and on a fresh lobby `lastPress` is nil — so the road says the item
  is gone, the button falls (the line becomes "Touch ID isn't set up for this library") over an item the existence probe
  had found an instant before, and nothing brings it back but a become-active `refresh()` (which re-lists it) or a relaunch
  or a lock — her workaround. **THE EXTERNAL FACT, UNVERIFIED:** which status `SecItemCopyMatching` answers when the SYSTEM
  sheet fades on its own (no Apple documentation found; a forum report shows unmapped statuses such as errSecNotAvailable do
  reach this call). If it is errSecUserCanceled the button already stood after her timeout; if errSecAuthFailed it stood but
  the line said "Touch ID changed since you set it up — unlock with the passphrase." (which would also send her to the
  passphrase); if any other status, this is her mechanism exactly. THE DISTINGUISHING EVIDENCE (her Air, at her hand): the
  protection log line "road: the Touch ID read failed — …" (`pressTouchID`'s catch) is written ONLY on the thrown arm.
  THE RED PIN COMMITTED (this commit, `VariorumTests/Protection/LobbyTouchIDReaskTests.swift` — the model wired to the REAL
  press road over planted leaves; the planted read throwing is the twin of the unnamed status): **RED on the pre-fix tree**
  (the harness, `--filter LobbyTouchIDReaskTests`): `✘ Test run with 3 tests in 1 suite failed … with 4 issues` — after the
  automatic ask's read threw, the button GONE; the re-press reached no road (`pressesRun == 2`), read nothing, opened
  nothing. Guards green: a press finding the item gone still drops it; every read mints its own `LAContext` (source). THE FIX
  COMMITTED (this commit — the smallest diff, ONE function): `ProtectionOpenRoad.pressTouchID` remembers that its read
  THREW, and then answers `.touchIDNotOpened(press: .cancelled, …, itemGone: false)` — the press did not complete, nothing
  changed, the button stands (THIS press's outcome, never a stale `lastPress`). Nothing else moves: the leaf, every keychain
  read and its error mapping, the probe-found-nothing road (still the one that drops the button), the walk switch's planted
  failure (no throw — unaffected), the copy doors' and the executor's Touch ID reads (they never reach this function); the
  unit-2 guardrails hold (no write before an open; a failed press writes nothing — pinned; no other Touch ID path changes).
  No new sentence (a cancelled press says nothing; the standing button is the road). **GREEN** (the harness, `--filter
  "LobbyTouchIDReaskTests|TouchIDUnlockSyncKeysTests|ProtectionLobbyModelTests|RoadLockTests|ProtectionOpenRoadPlantedTests|
  LobbyVaultRoadTests|TypedUnlockSyncKeysTests"`): `✔ Test run with 59 tests in 8 suites passed`; with `RoadRearmTests`: `✔ 8
  tests in 2 suites`. `ProtectionCrossingRouteTests.minor3_…` (a real-keychain suite, not in the harness) presses the walk
  switch's planted failure — it returns without a throw, so its `!gone` row is untouched by this change by reading; its run
  PENDING the stage batch. THE REVERT (named before it runs; one edit on this commit, `--filter LobbyTouchIDReaskTests`,
  restored by `git checkout --`): RV-533-1 `ProtectionOpenRoad.swift` — the `if readThrew, key == nil { return … }` block
  removed [expect the four issues]. **VERIFIED BY REVERT** on `8e9408d46`: RV-533-1 ⇒ `✘ Test run with 3 tests in 1 suite failed
  … with 4 issues` (exactly the pre-fix red); restored by `git checkout --`, `git diff --exit-code` clean, `✔ 3 tests` green
  again. **DONE** (`ce5a6d7bc` pin, `8e9408d46` fix) — FOR THE THROWN CLASS; whether her Air's timeout IS that class is the
  unverified external fact above (the log line tells). Residual, NOT changed (recorded for her/the ladder): if the system
  sheet's own ending answers errSecAuthFailed, the leaf maps it to `.failedOnExistingItem` and the lobby says "Touch ID changed
  since you set it up — unlock with the passphrase." with the button standing — a misleading line after a mere timeout; the
  leaf's mapping is shared by every Touch ID read, so changing it is outside this rider's smallest diff. No revert is in
  flight.
- **VX-530 — the double Touch ID.** DONE — THE TRACE (written and committed BEFORE any pin or fix; every read named
  by file:line; "prompt" = a context-less Touch ID read on the production leaf, `KeychainSyncKeysLeaf.readSyncKeys(.touchid)`
  minting its own `LAContext` at :66 — a sheet of its own):
  - **CHANGE PASSPHRASE** (Castle + Touch ID, synced). App: `ProtectionKeyDoorRoad.press` reads no keychain for Change.
    Core `changePassphrase` (`KeyDoors.swift:216`): `keyDoorParameters` reads the vault (no keychain); the typed CURRENT
    passphrase is derived under the vault's descriptor and verified there — it OPENS the account's master. Then
    `holdSyncKeysForTheSession(…, passphrase: typed, castle: true)` (:318) loops `syncKeysClasses(touchID: true)` =
    [.touchid, .silent] and reads **the account's Touch ID sync-keys item FIRST (:322) — PROMPT 1** — before the typed
    passphrase it was handed (which derives the same keys from the vault, byte for byte — VX-503's reason) and before
    session memory (which a Touch ID unlock — VX-487 (b) — or a typed unlock — VX-501 — already loaded); finding the current
    keys it RETURNS, holding nothing and handing nothing on. `keyDoor` → `perform(KeyDoorProgram, secrets: the NEW
    passphrase)` carries no keys. The act's `vault` step (:37) → `ctx.material(for:)` (`CommonSteps.swift:416`): the NEW
    passphrase does not open the vault → `syncMaterial()` (:327): `material` nil → the same loop, **the same item read
    again (:331) — PROMPT 2** — before session memory (:336). Nothing writes the item between the two reads (the door
    writes nothing; `vault` is the act's first step). **Exactly redundant reads of one item** (the account's
    `SyncKeysItemFact(account, .touchid)`), for the same keys, both avoidable.
  - **RESET FORGOTTEN PASSPHRASE by the words** (Castle): `verifiedWords` against this library (no keychain); the door's
    `holdSyncKeysForTheSession(…, words:, castle: true)` reads the item first — **PROMPT 1**, before the typed words that
    open the vault; the act's secrets carry the WORDS, so its `material(for:)` derives from them — no second read. One
    prompt, redundant with the words in hand.
  - **RESET by Touch ID** (Castle): the app's `pressTouchID` (`ProtectionKeyDoorActs.swift:125`) reads the LIBRARY KEY'S
    custody Touch ID item — **PROMPT 1, the ruled presence confirm** (design §3.9: "today's road's presence confirm kept";
    a DIFFERENT item; not a redundant read — untouched); the core's `.touchID` arm lists custody (no prompt); the door's
    hold reads the sync-keys item — **PROMPT 2**; the act (new passphrase only, no words) re-reads it in `syncMaterial` —
    **PROMPT 3**. Prompts 2 and 3 are exactly redundant reads of one item.
  - **NEW WORDS** (synced): the current passphrase is verified against the vault and rides the act's secrets, so the vault
    step derives from it — no sync-keys read at all (not in the class).
  - **VERDICT: THE MECHANISM IS EXACTLY REDUNDANT READS OF THE SAME ITEM** — the brief's condition for a fix is met. No
    custody-integrity signal: the item is read, never written, by these doors. THE FIX (to be built after the red pin, the
    brief's shape, `pairKeysAtTheDoor` the worked example): the door's hold takes the secrets FIRST, then session memory,
    then the silent item, then — Castle only, LAST and once — the Touch ID item, and HANDS the keys it found to the act
    (`perform(…, material:)` — unit 1's carry), so the act's `syncMaterial` returns them without a read. Standard's path
    unchanged (its one read is the silent class — no prompt; outside this rider). THE COUNTING-LEAF PIN COMMITTED (this
    commit, `Tests/VariorumCoreTests/Protection/Executor/KeyDoorTouchIDReadsTests.swift` — the world's `syncKeysTouchIDReads`,
    VX-517's counter): **RED on the pre-fix tree** (`swift test --filter KeyDoorTouchIDReadsTests`): `✘ Test run with 5 tests
    in 1 suite failed … with 4 issues` — Change passphrase **2 reads** (expected 0); Reset by Touch ID, nothing in hand,
    **2** (expected 1); Reset by Touch ID with session memory loaded, **2** (expected 0); Reset by the words, **1** (expected
    0) — the trace's counts exactly; the stale-session guard green. Each row also asserts the act LANDED (the vault and the
    key file open under the new passphrase; the item read, never written; `expectSettled`). THE FIX COMMITTED (this commit,
    `Executor/Acts/KeyDoors.swift` only): `holdSyncKeysForTheSession` returns the keys it found (`@discardableResult`) and,
    in CASTLE, takes the secrets in hand FIRST (derived from the vault, held in session as its derive arm always did), then
    session memory, then the silent class, then the Touch ID class LAST and once — each counted only as the vault's current
    sync key (the same rowKeyID test as before); Standard's order unchanged. `changePassphrase` and `resetPassphrase` carry
    the keys into the act (`keyDoor(…, material:)` → `perform(…, material:)` — unit 1's carry), so the vault step's
    `syncMaterial` returns them with no read; a resume has no carry and finds its own, as before. The app's Reset presence
    confirm (the library's custody item — design §3.9) is untouched. `TouchIDSyncKeysForgottenTests
    .aCastleTouchIDKeyDoorStillFindsItsKeysInItsTouchIDItem` FLIPPED DELIBERATELY from Change to Reset by Touch ID (Change no
    longer reads the item at all; the guard's intent — Castle still finds its keys there — pinned where the item is the only
    source; said in the test). **GREEN** (`swift test --filter "KeyDoorTouchIDReadsTests|TouchIDSyncKeysForgottenTests|KeyDoor|
    PairRefusal|SyncKeysSessionHold|FileLessWords|NewWordsResume|U2LaggingPair|PairCatchUp|PairInvariantPins|E6Heal|
    JoinWordsMoment|RestoredCopy"`): `✔ Test run with 127 tests in 32 suites passed … with 6 known issues` (P2's 4 controls,
    P6d's residual, VX-523's held row). THE REVERTS (named before they run; each one edit on this commit, `--filter
    KeyDoorTouchIDReadsTests`, restored by `git checkout --`, `git diff --exit-code` clean after each): RV-530-1 — the Castle
    reorder disabled (Castle takes Standard's loop with the Touch ID class first, the carry kept) [expect 3 issues: Change 1
    read, Reset-with-session 1, words 1; Reset with nothing in hand 1 = green]; RV-530-2 — the carry removed (`keyDoor`
    passes no `material`, the reorder kept) [expect 3 issues: Change 1, Reset-nothing-in-hand 2, Reset-with-session 1; words
    green]. **VERIFIED BY REVERT** on `8014c63c7`: RV-530-1 ⇒ `✘ … 5 tests … with 3 issues` (Change 1, Reset-with-session 1,
    words 1 — exactly as named); RV-530-2 ⇒ `✘ … with 3 issues` (Change 1, Reset-nothing-in-hand 2, Reset-with-session 1 —
    exactly as named); each restored by `git checkout --`, `git diff --exit-code` clean, `✔ 5 tests` green again. **DONE**
    (`c8a25d94f` trace, `49eac5049` pin, `8014c63c7` fix). No revert is in flight. Not changed, recorded: the Reset's ruled
    presence confirm stays its own sheet on the LIBRARY's custody item (a different item; design §3.9) — so Reset by Touch
    ID with nothing in hand shows two sheets on two items (the confirm, then the account's keys once); riding the confirm's
    press for the sync-keys read (VX-487 (b)'s riding road) would make it one — a design call beyond the brief's shape.
- **VX-538 — the recurring E6 band card.** DONE (the Mac face's compile PENDING the close's build-for-testing) — THE STATE
  AND THE DESIGN AS BUILT (her R-529-6; the brief's shape; every call below PROVISIONAL and listed as P-VX529-U3-3…6):
  - **THE STATE, READ — never a flag:** the open library's record names an account AND its live key file (of the current
    key) carries NO passphrase lock (E6 — born of a join by the words, or the catch-up's words arm). A synced library's
    record already says "a passphrase exists" (`ProtectionRecord.passphraseExists` — the account's), so rule 3's reminder is
    silent there and nothing surfaced E6 at all (F-U2-6: a Standard E6 library whose quiet roads work never meets a lobby).
  - **THE HOME:** a third row in the band card above the quick entry (`WordsBandModel` — the one home; never a popup, never a
    second bar), its own small model (`AccountPassphraseCardModel`, `Shared/Protection/WordsBand.swift`), the band's
    `visible` widened to it. It says the why and the road, and the forgot-road (the brief's two sentences), and takes the
    passphrase right there: one field (the join's own label, "Your account's passphrase") and one door, which runs the E6
    heal unit 2 built (`ProtectionExecutor.landTheAccountsPassphraseLock` — the typed passphrase verified against the
    account's vault under the vault's own descriptor, one key-file write, the mirror after; never a re-key) through a new
    app road on the session's one-act lock (`ProtectionOpenRoad.landAccountPassphrase`, the sign-in NOW adopted, its
    refusals in the account's own words — a wrong passphrase is VX-464's "That passphrase doesn't open this account."). A
    landing speaks unit 2's heal sentence as a receipt ("Your account's passphrase opens this library on this Mac now.").
  - **THE CADENCE (rule 3's pattern, no don't-show-again — her "until it's done"):** due from the library's THIRD launch on
    this Mac (rule 3's launch counter, shared); *Later* hides it until the next launch (the band's snooze); the ✕ hides it
    for a WEEK (rule 3's gap — a local ledger beside the reminder's keys, `variorum.calmAsks.accountPassphrase.<id>.*`);
    nothing ever retires the schedule.
  - **THE RETIREMENT, by the state:** the row stands only while the state reads E6 — every render reads it, and the
    landings that can end it re-read (the card's own press; an account act's landing and a key door's — `RoadStandingModel
    .rereadPassphrase`, which the key doors' landing now calls too). So the heal (here, the lobby, New words), Reset forgotten
    passphrase, Change passphrase or the catch-up each retire it with no flag of its own.
  THE RED PIN COMMITTED (this commit, `VariorumTests/Protection/E6BandCardTests.swift` — compiling on the pre-fix tree):
  **RED** (the harness, `--filter E6BandCardTests`): `✘ Test run with 2 tests in 1 suite failed … with 1 issue` — an open E6
  library at its third launch: `band.visible` false (nothing surfaces E6); the guard (a synced library WITH its lock hears
  nothing) green (`f378f6b5e`). THE BUILD COMMITTED (this commit): `WordsBand.swift` — `AccountPassphraseCardRules.due`
  (rule 3's first launch and week, never retired), `AccountPassphraseCardLedger` (the ✕'s moment, local), `AccountPassphrase
  Landing`, `AccountPassphraseCardModel` (`showing` = a writing road ∧ not hidden ∧ not snoozed ∧ `owes()` — THE STATE, read at
  every look — ∧ due; `later` · `dismiss` · `submit` · `reread`), `WordsCardSnoozes.accountPassphraseProcess` (its own snooze
  set), `WordsBandModel.accountPassphrase` + `showsAccountPassphrase`, `visible` widened; `ProtectionRoadActs.swift` —
  `accountPassphraseNotTypedHere(_:)` (the state: an account named, the live key file of the current key synced — its master
  lock — with no passphrase lock) and `landAccountPassphrase(session:passphrase:signIn:)` (the session's one-act lock, the
  sign-in NOW, ONE fresh vault read when signed in as the account, then unit 2's heal; refusals by
  `RoadAccountFaces.actRefusalSentence(…, secretIsTheAccounts: true)`); `ProtectionOpenFaces.swift` — `RoadStandingModel.make`
  composes the row (launches from rule 3's shared counter, the press off the main actor, the receipt through `speak`) and
  `rereadPassphrase` re-reads it; `AppBootstrap.keyDoorRoads().landed` now calls `rereadPassphrase` too (Change and Reset land
  a lock — and the set row/rule 3's reminder were never re-read there: a latent retire, harmless); `ProtectionWords` — the
  row's three sentences; the Mac face `AccountPassphraseRow` in `WordsBandCard.swift` (the line, the forgot-road, *Later*, ✕,
  the field — the join's "Your account's passphrase" label — and the door; no popup, no alert, no keyboard shortcut — the
  card's surface pins). Design-row tests added to `E6BandCardTests` (7 in all): the row's words and no shouting; the press
  landing the lock under the VAULT's descriptor with the key unchanged and NO vault write, the receipt, the row retired by the
  state; a wrong passphrase (VX-464's account sentence), offline and signed out — nothing written, the row standing; Reset
  forgotten passphrase (Standard's plain confirm, no follow owed in plain E6) retiring it through the re-read; the cadence (not
  before the third launch, *Later* to the next launch, ✕ for a week, back after, never retired; a read-only road shows nothing).
  **GREEN** (the harness, `--filter "E6BandCardTests|WordsBandTests|PassphraseReminder|WordsCard|SetPassphraseRowReread|
  HoldBannerAccount|RoadKeyDoor|LobbyVaultRoad|PairCheckDoor|ProtectionOpenRoadPlanted|RoadStanding"`): `✔ Test run with 86
  tests in 15 suites passed`. The Mac face's compile PENDING the build-for-testing; `WordsBandSurfaceTests` (Mac target)
  PENDING the stage batch. THE REVERTS (named before they run; each one edit on this commit, `--filter E6BandCardTests`,
  restored by `git checkout --`): RV-538-1 `WordsBand.swift` — `visible` loses `|| showsAccountPassphrase` [expect the pin red
  (`band.visible`), the guard green]; RV-538-2 `ProtectionRoadActs.swift` — the state reads `account != nil` alone (the lock
  check dropped — a flag in all but name) [expect the retire rows red and the with-lock guard red]. **VERIFIED BY REVERT** on
  `354c12dc3`: RV-538-1 ⇒ `✘ Test run with 7 tests in 1 suite failed … with 1 issue` (exactly the pin, `band.visible`);
  RV-538-2 ⇒ `✘ … with 3 issues` (the press's retirement, Reset's retirement, the with-lock guard — exactly as named); each
  restored by `git checkout --`, `git diff --exit-code` clean, `✔ 7 tests` green again. No revert is in flight.
  **P-VX529-U3-3 (the home and the road):** (a) BUILT — a third row in the band card, the passphrase typed right there and
  landed by the E6 heal; (b) the row's door opens Settings ▸ Protection's key doors (no field on the card); (c) a sentence only
  (the lobby, New words and Reset as the roads). **P-VX529-U3-4 (the cadence):** (a) BUILT — rule 3's first launch and week,
  *Later* to the next launch, ✕ for a week, never retired; (b) every launch until done (no week); (c) rule 3's schedule exactly
  (third launch, weekly twice) with no don't-show-again, weekly forever after. **P-VX529-U3-5 (signed out):** (a) BUILT — the row
  shows whoever is signed in (the state is the library's) and the press says what blocks it; (b) hide it while no one is
  signed in as the library's account. **P-VX529-U3-6 (the door's word):** "Use it here" (a) BUILT; (b) "Save"; (c) "Open with
  it".
  **THE CASTLERULES CLAUSE — DRAFTED FOR HER (rule-3-adjacent; never written into the rules here — they change only at her
  word, and this text goes to her verbatim first):** *"A library that syncs, but whose account's passphrase was never typed on
  this device — it joined by the twelve words, or caught up with them — is told so in the same card: your account's
  passphrase hasn't been typed on this Mac yet; type it once and it opens this library here too, and if you don't know it,
  Reset forgotten passphrase sets one you do. It comes back from the third launch, and a week after each time it is put away,
  until a passphrase is typed here — there is no 'don't show again'."* (Rule 3's own text is silent there: a synced library's
  passphrase exists — the account's — so its reminder never shows; the clause names the deliberate delta, her "until it's
  done".)

**THE CLOSE (on the finished product tree, `723cbf276`; the record commits after it touch no code):**
- **THE CORE SUITE whole** (`swift test`, debug, headless): VariorumCoreTests **`Test run with 3426 tests in 455 suites passed
  … with 6 known issues`** (P2's 4 negative controls, P6d's pinned residual, VX-523's held row); the one failure the ticketed
  MCP wall-clock flake `MCPHarnessTimeLimitTests.aPeerThatNeverAnswersInitializeFailsTheConnectNamedAndBounded` (VX-353 /
  VX-532) in VariorumMCPTests; no protection code in it.
- **THE HARNESS whole** (debug; this unit's four new suites symlinked in): `✘ Test run with 499 tests in 94 suites failed …
  with 8 issues` — exactly unit 2's standing eight: the five harness-PATH artifacts (`CopyListingFacesSurfaceTests` ×2,
  `EmptySlotDoorsSurfaceTests` ×2, `ProtectionRoadSwitchTests` ×1 — source pins reading `#filePath` beside a symlink; they
  run in the Mac target) and F-U2-9's week-boundary flake (`ProtectionPairRetentionTests` ×3 — VX-539). Every other test green
  (484 + this unit's 15).
- **Mac `build-for-testing`** (`-derivedDataPath App/Variorum/DerivedData/vx529-u3`): `** TEST BUILD SUCCEEDED **` — the Mac
  face `AccountPassphraseRow` compiles (VX-538's PENDING flipped). No warning in a touched line (one pre-existing in
  `KeyDoors.swift`'s untouched `keyDoorParameters` — `var parameters` never mutated). **iOS `build-for-testing`**
  (`VariorumMobile`, `generic/platform=iOS Simulator`, `DerivedData/vx529-u3-ios`): `** TEST BUILD SUCCEEDED **`.
- Zero `Sources/VariorumCore/Sync/` lines (`git diff --stat 11e1c0d53..HEAD -- Sources/VariorumCore/Sync`: empty); no schema
  (`Persistence/`, `Server/` untouched), no stored shape (the E6 card's ledger is a local calm-asks defaults key; every key-file
  change is unit 2's heal through the existing setters); no trailer on any commit (checked over `11e1c0d53..HEAD`).
- **THE MAC-SUITE LIST for the stage batch** (every Mac-target suite exercising a changed file; harness-green ones say so): NEW
  — `JoinSheetWordsTests`, `HoldBannerNoAccountWordsTests`, `LobbyTouchIDReaskTests`, `E6BandCardTests` (all harness-green);
  CHANGED — `RoadJoinFollowWordsTests` (harness-green; FLIPPED DELIBERATELY, VX-526); exercising changed types,
  harness-green — `RoadAccountModelTests`, `RoadAccountFacesTests`, `RoadAccountWordsTests`, `NotOnYetWordsTests`,
  `FirstRoundConfirmTests`, `FirstRoundAfterTheActTests`, `ProtectionJoinFollowRoadTests`, `PairFollowFacesTests`,
  `HoldBannerAccountFactTests`, `HoldBannerAccountCompositionTests`, `RoadRestoreHoldGateTests`, `TouchIDUnlockSyncKeysTests`,
  `ProtectionLobbyModelTests`, `RoadLockTests`, `RoadRearmTests`, `ProtectionOpenRoadPlantedTests`, `LobbyVaultRoadTests`,
  `TypedUnlockSyncKeysTests`, `WordsBandTests`, `PassphraseReminder*`, `SetPassphraseRowRereadTests`, `RoadKeyDoor*`,
  `PairCheckDoorTests`; Mac-ONLY (compiled, runs PENDING the stage batch) — `LibraryPortabilityDoorTests` (the hold banner's
  no-account arm: no "account", a "Resume" — true of the new text by reading), `ProtectionCrossingRouteTests` (the walk
  switch's planted failure — no throw, untouched by VX-533's change by reading; a real-keychain suite), `WordsBandSurfaceTests`
  (the card's source pins — the E6 row adds no popup, alert or shortcut), `RoadAccountSurfaceTests` (the account sheet's
  title/button now read through `RoadAccountDoorOpen`), `RoadJoinFollowSurfaceTests`; the PHONE — `MobileNoRedirectSweepTests`
  (every Shared literal — the three new E6 sentences name the platform through `ProtectionCopy.deviceName`) and
  `MobileProtectionRoadTests`. The core's new and changed suites (`KeyDoorTouchIDReadsTests`, `RestoredCopyJoinWordsMoment
  Tests`, `TouchIDSyncKeysForgottenTests`) ran in the core suite above.

**NEW SENTENCES (every one PROVISIONAL, sentence case — for her wording bundle):**
1. VX-526 — the join sheet's title and button (`joinSyncTitle`, `joinSyncButton`): "Sync this library" · "Sync this library"
   (the door VX-506 named, "Sync this library…"; the set-up arm keeps "Turn on sync").
2. VX-526 — the passphrase-typed words moment's middle sentence (`joinWordsNotShown`): "Your previous twelve words still
   open backups made with them." (was "…still open backups you made before today."). The rule-7 twin for her ratify is under
   P-VX529-U3-1.
3. VX-522 — the hold banner over a library that names no account (`LibraryOpenCopy.holdBanner`, `hasAccount: false`): "This
   is your library as of ‹day›. This library doesn't sync, so Resume changes nothing in it." (was "…Sync is waiting until you
   press Resume. To keep something from this backup, duplicate it first — duplicates stay."; P-VX529-U3-2).
4. VX-538 — the band card's E6 row (`accountPassphraseCardLine` — the brief's draft verbatim): "Your account's passphrase
   hasn't been typed on this Mac yet — type it once and it opens this library here too."
5. VX-538 — its forgot-road (`accountPassphraseCardForgot` — the brief's draft verbatim): "If you don't know it, set one you
   do with Reset forgotten passphrase."
6. VX-538 — its door (`accountPassphraseCardDoor` — the implementer's, P-VX529-U3-6): "Use it here".
   REUSED, not new: "Your account's passphrase" (the join's field label), "Later" and "Dismiss" (the words row's), "That
   passphrase doesn't open this account." (VX-464's), "Your account's passphrase opens this library on this Mac now." (unit
   2's heal notice, spoken here as the receipt).

## THE PHONE — what mobile must know from this run (2026-10-25, at her word: "I want to make sure that the phone
## knows everything that has been done / is up to date on what is needed"; the ledger row is `notes/MobileSoul.md`
## PL-59, written mid-run and trued at closeout; the mobile handoff carries a dated pointer)

- **The state is the phone's too:** a pair changed on any device strands the phone identically (Castle: its stale
  passphrase loads no sync keys; Standard: it syncs with a silently stale pair).
- **Inherited through shared core at the phone's next build:** the detection (`AssessRules.pairFollow`), the pair
  follow act (rule 6's re-lock, the older-build-safe two-step plan — which also protects a stale PHONE build resuming
  a plan), R-529-5's either-current-secret arm and the E6 drop, the changed-elsewhere refusal splits and sentences
  (`ProtectionWords`, device names via `ProtectionCopy.deviceName`), `VaultRoad.answer`, the E6 heal primitive and
  its act.
- **VERIFY on the device, never assume:** the SHARED lobby road now carries the E6 passphrase field and the vault
  road (unit 2) — the phone's lobby may already behave; a device walk decides live vs latent.
- **The phone OWES (the mobile catch-up):** the pair follow's face (lands with VM-8's account section — PL-58), the
  durable notices' rendering, the check door (PL-58's standing owe), VX-538's recurring E6 card on the phone's card
  home, the key doors' changed-elsewhere refusal faces, and the pocket guide's compromise-recovery page (the Mac
  guide's is VX-379's; the pocket guide is its own).
- **Nothing refuses:** zero schema, marker untouched; every stored change is key-file values through existing
  setters.

## THE COMPROMISE-RECOVERY RECIPE — hers, to VX-379 (2026-10-25; her words verbatim)

*"and if you want safety after a sync key leak and you were in castle already, do you go standard and then enter
castle again? I think we should tell the users this clearly somehow. add the compromise recovery guide to the field
guide, under VX-379"* — VX-379's ticket updated the same day; the DRAFT below is the content direction (VX-379's
session traces the exact doors and her wording pass rules the sentences):

- **If you think someone has your secrets or your keys — three moves, in this order:** (1) change your ACCOUNT
  PASSWORD (the sign-in secret — it puts every session out of reach); (2) change your PASSPHRASE and make NEW WORDS
  (the key doors; your other devices catch up by the follow); (3) USE CASTLE — entering mints a new sync key and a
  new master, so everything you write from now on is sealed under keys nobody's old copy holds, and every device
  types a secret once. Want to stay in Standard? Use Standard afterward — leaving changes no key, so the rotation
  keeps.
- **Already in Castle?** Use Standard, then Use Castle again — re-entering mints the new keys (verified in the act:
  every entry mints a fresh master and sync key). The brief Standard window re-makes this Mac's quiet roads and
  re-entering deletes them again on every device (rule 11); do the two crossings together, in one sitting.
- **The honest limit:** writing an attacker already copied stays readable to them with the keys they took — rotation
  protects everything from now on, never the past.
- **Why a new account is not needed:** after the three moves the attacker holds no session, no proof (it moves with
  the master), no pair and no current key; a fresh account adds nothing to that beyond scrubbing old ciphertext off
  the server, which their captured copies already bypassed.

## UNIT 3 — CLOSED (2026-10-25, the architect's verification and dispositions). THE BUILD PHASE IS COMPLETE.

Five of six members verified: the diffs read (the VX-530 fix is exactly the ruled shape — the typed secret deriving
the keys first, session, the silent class, the Touch ID class last and once, the keys riding into the act on unit
1's `material:` pattern, Standard untouched; the VX-533 fix is one function — an unhandled keychain status at the
press now counts as cancelled so the button stands, no keychain mapping changed; VX-538's card reads the state and
retires by it); the suites re-run by the orchestrator's own hand (84 tests in 32 suites green over the key-door and
catch-up seams); zero `Sync/`, zero `Server/`, zero `notes/CastleRules.md` lines by diff over the whole unit. The
worktree race (the orchestrator's `270b58394` landing mid-unit) was handled correctly on both sides and is recorded
in LIVE STATUS. Dispositions:
- **VX-523 — RETURNED UN-FIXED, correctly: TO HER BUNDLE.** The implementer's trace overturned the brief's premise
  (the quiet rule RUNS; it answers false because Make this my library writes its own words lock and no master copy —
  no file comparison can prove the words are the account's). The fix is a change to WHAT A CUSTODY ACT WRITES
  (P-VX378-U2-4 option (b) territory — hers): (A) Make this my library writes the master lock + words copy the way a
  join does · (B) leave it (the notice over-speaks; every sentence true) · (C) rejected (a looser test goes quiet
  when the words really were replaced). The red row is HELD as a known issue in
  `RestoredCopyJoinWordsMomentTests`; VX-523 flips to Needs Lillian and does NOT close with this run unless she
  rules (A) or (B) at the closeout sitting.
- **VX-533 — fixed for the traced mechanism; ONE external fact for HER AIR:** which keychain status Apple's own
  sheet timeout returns is unverifiable headless. HER CHECKLIST ITEM: next missed prompt on the Air, the protection
  log's line — "road: the Touch ID read failed — …" appears ONLY in the fixed case; `errSecAuthFailed` instead means
  the misleading "Touch ID changed since you set it up" line stands (recorded, unchanged — a wording follow-up if
  her log says so).
- **VX-530's prompt-count table** (2→0 on Change; 2→1 and 2→0 on Reset's arms; 1→0 on Reset-by-words) and the
  DELIBERATELY FLIPPED VX-517 guard (Change → Reset, said in the test) are NAMED FOR THE LADDER, as are unit 2's
  three changed tests and VX-538's key-door landing re-read side effect.
- **Rule 7's own "before today" flaw** (the same as W-12's): P-VX529-U3-1's drafted rule-7 wording joins her closeout
  bundle — the rules change only at her word.

**WHAT REMAINS (the run's tail, in order):** the LADDER (round 1 spawns from this close — a fresh `fable-reviewer`,
REVIEW_PROMPT verbatim, zero framing, over `git diff main...vx-529-pair-catchup`); the CLOSING STAGE BATCH (the
Mac-target suites per units 2–3's lists — a held stage claim, zero-instance); the LIVE PROOF on the prod test
accounts (the VX-510 repro's legs as the acceptance script, Castle and Standard, passphrase and words, E6 and the
heal); HER TWO-MAC TEST with the build installed on both behind A1 (the release gate, her kickoff word); the
CLOSEOUT (canon deltas in the two-file shape, the QUESTIONS bundle — the P-VX529 family, VX-523's options, F-U2-7's
bound, the rule-7 and rule-3-adjacent clauses — the tickets triaged, MobileSoul PL-59 trued, the handoff).

## THE LADDER — ROUND 1 (2026-10-25; a fresh `fable-reviewer`, REVIEW_PROMPT verbatim, zero framing, over
`git diff main...vx-529-pair-catchup`; the reviewer read this record whole, SyncSpec and CastleRules in full, the
SurfaceContracts bullets, and re-ran the 21 VX-529 core suites itself — 100 tests green, 6 known, exactly the
record's set)

**0 BLOCKER · 0 MAJOR · 1 MINOR · 2 NIT.** Findings verbatim-faithful, each with the ORCHESTRATOR'S DISPOSITION:

- **F-R1-1 [MINOR] — the vault road's read runs where it can prove nothing.** `openThroughTheVault` makes its bounded
  network read on EVERY wrong passphrase at a signed-in writing lobby, including over a library whose held key files
  carry NO master lock (an unsynced library) — where `VaultRoad.answer`'s only possible outcome is `.nothingToSay`:
  up to the 10 s bound per typo, buying nothing (F-U2-7's accepted residual covers only the synced case, where the
  read can buy the owed sentence). Proposed fix: gate the read on any held key file carrying a master lock
  (`files.contains { $0.master != nil } || live?.master != nil`), refusals byte-identical otherwise; the pin a
  fetch-count test in `LobbyVaultRoadTests` (unsynced + signed in + wrong passphrase ⇒ 0 vault fetches; today 1).
  **DISPOSITION: CONFIRMED — fix session L1** (a fresh implementer; agree/dispute first per the cross-model flow;
  red-on-old pin, revert-verified).
- **F-R1-2 [NIT] — sentence 11's twice-lagged flaw.** "…the one before it…" is wrong when the passphrase changed
  twice+ while this device lagged (the local lock holds an OLDER one, not "the one before" the current); the honest
  meaning is "the one this library last knew". **DISPOSITION: TO HER BUNDLE, flagged beside sentence 11** (wording
  class, provisional already; no code, no pin).
- **F-R1-3 [NIT] — the record's STATUS header stood stale** ("nothing below is built" through the whole build phase).
  **DISPOSITION: TRUED the same day** (the header now states the run's real position; the truing note rides it).

**The reviewer's dispositions of everything the record named for it, all accepted as its final calls:** F-U2-8
weighed and accepted as recorded (the exposure class pre-exists at every synced settle; the deferred-act alternative
buys a rare transport-bounded stall at the cost of a held-secret window and new machinery); VX-530's prompt table and
the flipped VX-517 guard verified sound; unit 2's three changed tests and VX-526's flipped words test each justified
and matching a ruling; VX-538's key-door landing re-read judged correct behavior (a previously latent gap); VX-523's
return judged the right call; VX-533's honest residual and discriminator endorsed. **The clean bill** (abridged; the
full text is the reviewer's report): detection's false-positive premise pinned across all 24 roads; the act a true
re-lock with zero server/custody/Apple/staged/backup writes, crash-walked in three postures, R-510-20 honored to the
letter (no stored shape anywhere — `typedSecret` pre-existing); the words arm's drop-not-trade; the refusal splits'
honest seams; the vault road's same-account proof before any named change; the E6 heal's lands-where-missing-only;
the faces' durable Done and suppressed stale line; discipline verified (zero Sync/Server/CastleRules lines, no
trailers on 92 commits, pins before fixes by commit order).

### THE LADDER — L1 (a fresh `opus-implementer`; F-R1-1 only)

The finding above is the charter, verbatim. Agree/dispute FIRST (a dispute returns to the reviewer for the final
call); then the pin red-on-old in `LobbyVaultRoadTests`' harness, the gate, the revert verification, the refusals
byte-identical either side of the gate (pinned). Discipline exactly the units': headless only, zero `Sync/`,
commit + push per piece, LIVE STATUS under this section, no trailers.

### L1 — LIVE STATUS (the implementer owns this section)

**F-R1-1 FIXED (agreed; pin red-on-old `79b3d23e6`, gate `facffef48`, revert-verified). NOT DONE IN THIS SESSION:**
everything but F-R1-1 (the charter's one finding); the Mac-target run of
`LobbyVaultRoadTests` (the closing stage batch — it runs here in unit 2's headless harness only); every walk. No revert
is in flight (RV-L1-1 ran and was restored — L1-P3). Zero `Sources/VariorumCore/Sync/` lines. Session: a fresh `opus-implementer`, 2026-10-25, worktree
`~/dev/variorum-vx-529`.

**Read first (all read in full, in this session):** CLAUDE.md + the loaded canon; `notes/SessionResiliencyProtocol.md`;
this file whole; the code — `ProtectionOpenRoad.swift` (`openTyped`, `openThroughTheVault`, `catchUpThroughTheVault`,
`boundedVaultRead`, `heldKeyFiles`), `Executor/VaultRoad.swift` whole, `Model/KeyFile.swift` (the locks and every open
road), `ProtectionRoadActs.swift` (`setFirstPassphrase`); the suite `LobbyVaultRoadTests` whole and its planted worlds
(`TypedUnlockSyncKeysTests.castleAlwaysAskSynced`, `TouchIDUnlockSyncKeysTests.World`, `PlantedAccount`,
`PlantedVaultLeaf.plant`, `PlantedRoad.created`).

**F-R1-1 — AGREE.** My own trace (inputs → the futile read):
1. `openTyped` (`ProtectionOpenRoad.swift:371-412`): every local road refused a typed PASSPHRASE ⇒ the `.noneOpens` arm
   calls `openThroughTheVault(ctx, passphrase:, files:, within: bound)` (:406-407), `files` = `heldKeyFiles` (:773-786 —
   the live key file first, then each remembered library's mirror, then the catalog's key files).
2. `openThroughTheVault` (:424-472) guards only `ctx.writes` and a signed-in account (:427), then makes the network read
   (`boundedVaultRead`, :429 — up to `typedUnlockVaultBound`, 10 s, :628), and only AFTER it reads `live` (:442) and asks
   `VaultRoad.answer` (:443).
3. `VaultRoad.answer` (`VaultRoad.swift:53-72`) can say something other than `.nothingToSay` only through a MASTER lock:
   `.opens` comes only from `file.open(master:)` over `files` (:59-61), and `KeyFile.open(master:)` throws
   `noSuchWrap(.master)` when `master == nil` (`KeyFile.swift:265-268`); `.notTheAccountsPassphrase` and
   `.passphraseChangedElsewhere` sit behind the guard `live.master != nil` (:64). A master lock is the account's master's
   wrap of the library key (`settingMaster`, written only on the account roads — `AccountActs.swift:200`,
   `KeyFileCrossings.swift:72`), so an unsynced library's held files carry none.
4. So over a library none of whose held key files carries a master lock, EVERY input yields `.nothingToSay` ⇒ nil (:444-446)
   ⇒ `openTyped` returns `.refused(ProtectionWords.passphraseDoesNotOpen)` (:410) — the very refusal it returns without the
   read. The read buys nothing, costs up to the bound per typo (the lobby's "Opening…" waits on it), and asks the signed-in
   account's server about a library that names no account. Reachable: a lobby over an unsynced library (a never-synced
   Standard library whose quiet roads failed, a Make-this-my-library copy) on a Mac signed in to an account.
5. The proposed gate — `files.contains { $0.master != nil } || live?.master != nil`, evaluated BEFORE the read — is exactly
   the precondition of every non-nil answer, so nothing else changes by construction. `live` is read once, hoisted above the
   read, and the same value goes to the answer (`live` ∈ `files` whenever it reads — `heldKeyFiles` adds it first — so its
   clause is belt and braces, kept as the reviewer wrote it).

**The pieces (flip per commit; unverified claims PENDING):**
- L1-P0 — this LIVE STATUS, the agree and the trace. DONE (this commit).
- L1-P1 — THE PIN, red on the tree as it stands (`LobbyVaultRoadTests`, unit 2's harness): an unsynced library (its own
  passphrase lock, no master lock), its quiet roads gone, the Mac signed in to an account whose vault is planted ⇒ a wrong
  passphrase, and the ACCOUNT's own passphrase (which opens the vault's master — still nothing to open with it), each make
  ZERO vault fetches (today one each), refused `passphraseDoesNotOpen` byte for byte, nothing written; and THE GATE'S OTHER
  SIDE — a synced library, nothing changed elsewhere, a wrong passphrase: ONE fetch (the read stays where it can prove
  something) and the same refusal byte for byte. DONE (this commit) — `anUnsyncedLibraryMakesNoVaultRead` +
  `aSyncedLibraryKeepsItsOneReadAndTheSameRefusal` (world `unsyncedWhileSignedIn`: `road.created()`, rule 3's first
  passphrase through `setFirstPassphrase`, the account's vault planted, the quiet roads emptied; precondition asserted — a
  passphrase lock, no master lock, no account). **RED on the tree as it stands** (`c7dd3d591`'s code; the harness, `--filter
  LobbyVaultRoadTests`): `✘ Test run with 11 tests in 1 suite failed after 2.698 seconds with 2 issues.` — exactly the two
  fetch counts: a wrong passphrase `Self.fetches(world) → 1` / `fetches → 0`; the account's passphrase `→ 2` / `→ 1` (one
  read per press). Green through it, as they must stay: both refusals `== ProtectionWords.passphraseDoesNotOpen` (today's
  bytes), nothing written, the own passphrase still opening locally (a guard), the synced side's one fetch and same
  refusal, and the suite's nine standing tests.
- L1-P2 — THE GATE in `openThroughTheVault` (the live read hoisted above the read). DONE (this commit) —
  `ProtectionOpenRoad.swift`: after the writes/signed-in guard, `live` is read once and
  `guard files.contains(where: { $0.master != nil }) || live?.master != nil else { log(…); return nil }` — nil is
  `openTyped`'s existing "today's refusal" road (:410), so the refusal is the same bytes by construction; the later live
  read removed (the hoisted value goes to `VaultRoad.answer`); one doc-comment line. Nothing else moved (no core line, no
  sentence, no other road). **GREEN** (the harness, `--filter LobbyVaultRoadTests`): `✔ Test run with 11 tests in 1 suite
  passed after 2.668 seconds.` The neighbour suites: green (L1-P4).
- L1-P3 — THE REVERT, named before it runs: RV-L1-1 `ProtectionOpenRoad.swift` — the gate's guard removed (the hoisted read
  kept), the harness `--filter LobbyVaultRoadTests` [expect exactly the unsynced row's fetch counts red; every byte-identity
  assertion and the synced side green]; restored by `git checkout --` on the committed fix. **VERIFIED BY REVERT** on
  `facffef48` (announced in the banner first, `59974fbed`): RV-L1-1 ⇒ `✘ Test run with 11 tests in 1 suite failed after
  2.687 seconds with 2 issues.` — exactly the pre-fix red (a wrong passphrase `→ 1` / `→ 0`; the account's passphrase
  `→ 2` / `→ 1`), every byte-identity assertion, nothing-written and the synced side green through it; restored by `git
  checkout --`, `git diff --exit-code` clean, `✔ Test run with 11 tests in 1 suite passed after 2.736 seconds.` DONE.
- L1-P4 — the close: the suites the fix touches green in the harness (the lobby, typed-unlock, Touch ID-unlock, planted-road
  and lobby-model suites) and `VaultRoadTests` in the core. DONE (`6f683e590` carried only the banner line, by a missed
  edit — this bullet landed one commit later; said so) — THE HARNESS (`--filter "LobbyVaultRoadTests|
  TypedUnlockSyncKeysTests|TouchIDUnlockSyncKeysTests|ProtectionOpenRoadPlantedTests|ProtectionLobbyModelTests|RoadLockTests|
  LobbyTouchIDReaskTests|E6BandCardTests|PairCheckDoorTests|PairFollow|RoadRearmTests"`, on the fixed tree): `✔ Test run with
  86 tests in 14 suites passed after 4.408 seconds.` THE CORE (`swift test --filter VaultRoadTests`; no core line changed):
  `✔ Test run with 5 tests in 1 suite passed`. Zero `Sources/VariorumCore/Sync/` lines (`git diff --stat main...HEAD --
  Sources/VariorumCore/Sync` empty); L1's whole diff is `ProtectionOpenRoad.swift` (+10/−1), `LobbyVaultRoadTests.swift`
  (+72) and this record; no trailer on any L1 commit. The Mac-target run of `LobbyVaultRoadTests` rides the closing stage
  batch (already on unit 2's list). Stated for the next round (not changes): the gate reads "no held key file carries a
  master lock", not "the record names no account" (the record is inside the locked library) — so a library that stopped
  syncing while this Mac still holds an older synced key file (a catalogued backup's, a mirror's) keeps its one read, which
  is right (that file's master lock is a real road); and the live key file is now read before the network read rather than
  after it — the same value (nothing writes the live file while the lobby's press is in flight), handed to
  `VaultRoad.answer` unchanged.

## R-529-7 — VX-523 RULED: (A) IN THIS RUN (2026-10-25, her pick at the sitting, after her implications questions)

Her questions, verbatim, from the sitting: *"hmmmm. so it over speaks because it can't be SURE that it's the
accounts. but wording seems like the less significant part of this change - what does it really mean and what are the
implications of the ault writing the master wrap and its words copy ?? writing that where? what are the deeper
implications of this? I feel like this might have more implications"* — answered before the pick (the implications
analysis is the sitting reply, summarized: the two fields live in the key file beside the library, the same two the
JOIN writes at Resume anyway, so the end state is identical and only the held window changes; no new opener class; no
vault/server/custody write; the act gains one opportunistic bounded network read — offline or unprovable writes
nothing, today's file exactly; the notice's quietness becomes connectivity-dependent — the one real cost). **Her
pick: "(A) in this run (Recommended)".**

### THE LADDER — L2 (a fresh `opus-implementer`; the VX-523 fix under R-529-7)

**The charter:** Make this my library, when the session is signed in and the account's vault is readable within the
standing bound, ALSO writes the join's two proof fields into the new library's key file — the master wrap and the
words copy — exactly as a join writes them (`KeyFileCrossings`' shape), deriving from the copy's typed secret against
the vault; where the read is unavailable or the typed secret does not open the vault, it writes NOTHING and the file
is today's byte for byte. The join's quiet rule then proves the match and stays quiet (the held red row in
`RestoredCopyJoinWordsMomentTests` flips green — that is the pin, already red on today's tree). Edges to pin: the
offline restore (today's file, the notice still speaks — truthfully), the pair-changed-since-backup restore (the
secret fails the vault, nothing written, the notice speaks — truthfully), and the act's crash points (the fields ride
the act's existing planned key-file write — no new step). Read first: THIS FILE's VX-523 sections (unit 3's return,
R-529-7 above), `ProtectionCopyDoors.swift` / `CopyDoorsModel.swift` (the act), `KeyFileCrossings.swift` (the join's
shape), `AccountActs.swift`'s join arm, and the held test. Discipline exactly L1's; the fix re-checked by round 2's
fresh reviewer; VX-523 closes with the run on her ruling.

### L2 — LIVE STATUS (the implementer owns this section)

**VX-523 FIXED under R-529-7 (pins red-on-old, both halves revert-verified). NOT DONE IN THIS SESSION:** the Mac and iOS
COMPILE of the one app file changed (`ProtectionCopyDoors.swift` — compiled in unit 2's harness under the app's settings; no
`xcodebuild` here — the orchestrator's); every Mac-target and phone suite RUN (the closing stage batch — the list under L2-P5);
every walk; the empty-slot landing (F-L2-5, not in the charter); the faces F-L2-3 names (her bundle); the QUESTIONS entry for
P-VX529-L2-1 (the merging session's ledger). No revert is in flight. Zero `Sources/VariorumCore/Sync/`
lines (none needed — the act is protection-local). Session: a fresh `opus-implementer`, 2026-10-25, worktree
`~/dev/variorum-vx-529`.

**Read first (all read in full, in this session):** CLAUDE.md + the loaded canon; `notes/SessionResiliencyProtocol.md`;
`notes/CastleRules.md` whole (rule 17 the door touched; rules 2, 7, 16, 20, 22); this file whole. Code: `Executor/Acts/Copies.swift`
whole (MakeMineProgram, `makeMineKeyFile`, both public `makeThisMyLibrary` forms and the private body), `Model/KeyFileCrossings.swift`
(`NewKeyLocks`, `building`, `locking`), `Executor/Acts/AccountActs.swift` (`join`, `joinKeyFile`, `wordsAreTheAccountsAlready`),
`Executor/Acts/CommonSteps.swift` whole (`newLocks`, `material`, `syncMaterial`), `Executor/PlanRunner.swift` whole (`perform`,
`ActContext`, `resume`, `rollBack`), `Executor/Executor.swift` (`readVault`, `freshVaults`), `Executor/VaultModel.swift` whole,
`Model/KeyFile.swift` whole, `Model/KeyFileRelock.swift`, `Executor/Acts/PassphraseLockHeal.swift`, `KeyDoors.swift` (New words,
`mintKeyFile`), `Assess.swift` (`acts`, `pairFollow`, `doors`); app-side `ProtectionCopyDoors.swift` (preflight, `makeMine`),
`AppBootstrap.makeThisMyLibrary`, `ProtectionOpenRoad.swift` (`boundedVaultRead`, `typedUnlockVaultBound`, the vault road),
`ProtectionLobbyFace.swift` (E6), `ProtectionRoadActs.swift`, `ProtectionSecretCheck.swift`; the held test, `JoinWordsMomentTests`,
`U2CopyDoorTests`, `SyncKeysSessionHoldTests`, `CrashHarness`, `ExecutorFixtures`, `ExecutorWorld`, the scenario world's makeMine
and promises (`Alphabet.swift`, `World.swift`, `Promises.swift`), the lifecycle walk's copy stages and check, and the app suites
`MakeMineRoadTests`, `ProtectionAccountSupport`, `TypedUnlockSyncKeysTests`.

**THE TRACE (mine; unit 3's AGREED, the held row confirmed red):** `swift test --filter RestoredCopyJoinWordsMomentTests` on
`5dca7f06f`: `Test run with 2 tests in 1 suite passed … with 1 known issue` — the known issue at
`RestoredCopyJoinWordsMomentTests.swift:61` (`!replaced(joined)`), the words guard green. Mechanism: `join` (`AccountActs.swift`)
sets `wordsReplaced = !sameWords`; with the passphrase typed `ownLockOpens` is false and `wordsAreTheAccountsAlready` answers false at
its first clause (`file.words == nil`) because `makeMineKeyFile` (`Copies.swift:128`) builds `newLocks(passphrase:, words: true,
master: false)` — an OWN words lock, no master lock, no copy. The rule's proof is wrap identity, so nothing in that file can prove
the words are the account's. R-529-7's fix: write the join's two proof fields where provable.

**THE DESIGN AS IT WILL BE BUILT (R-529-7's charter; nothing stored changes shape — `KeyFile.master` / `masterWordsCopy` exist,
written through `settingMaster` inside `locking`, the existing setter):**
- **The proof (core, the act's door, reads only, after the current pair is verified — a refusal costs no read):** the signed-in
  account's vault (`configuration.session.accountID`), and the current pair's typed WORDS opening ITS master through the vault's
  recovery wrap (`AccountVault.master(words:)`), the key proof verified (`isMaster`). Then the proof is that master and that wrap,
  byte for byte. Anything else — signed out, the vault out of reach or absent, another account's read, words the vault refuses —
  is NO proof: the act writes today's file, byte for byte.
- **Where the read comes from:** a new parameter on both public `makeThisMyLibrary` forms, `accountsVault: AccountsVaultRead =
  .inTheDoor` — `.inTheDoor` (a core caller: ONE `readVault` in the door, out of reach ⇒ none) or `.taken(VaultSnapshot?)` (the
  caller's own read — verified, never trusted; nil ⇒ none, never a fallback to an older read, so an offline press writes nothing).
- **The write:** the proof rides `perform(…, pairProof:)` into a new in-memory `ActContext.pairProof` (the `copyKey` precedent —
  never stored; a resume before the stage rolls back without it, as without the copy key) and the act's EXISTING one key-file write
  (`makeMineKeyFile`): with a proof, the locks are the passphrase (as today), NO own words lock, the master lock with the copy — the
  join's own shape (VX-462: "where the master's twelve-words copy is written … no own words lock is kept beside it"), the Apple lock
  (Standard) as today. No new step, no new write, no vault/custody/sync-keys write; the record binds no account (P-VX378-U2-4 (a)).
- **The app (the standing bound):** `ProtectionCopyDoors.makeMine` makes ONE `boundedVaultRead` (VX-501's race,
  `typedUnlockVaultBound`) of the executor's signed-in account, writing road only, just before the core act, and passes
  `.taken(read)`; a failure or a timeout passes `.taken(nil)` (today's file). `AppBootstrap` untouched.

**Findings before any code (each says what it changes):**
- **F-L2-1 — the held suite's SETUP asserts the restored file opens by its OWN words lock** (`restored.open(words:)`, line 48); the
  fix removes that lock by design (the join's shape), so the setup line flips to the any-road open (`open(.words(…))` — the words
  still open it, through the master's copy). FLIPPED DELIBERATELY, said in the test; the pin's own assertion is unchanged but for
  losing `withKnownIssue`.
- **F-L2-2 — PROVISIONAL P-VX529-L2-1, the proof's secret:** the WORDS are the proof (the copy is exactly the typed words' road;
  rule 17's "under your current pair" needs the current words to keep opening the new library). Built (a): the words alone — so a
  PASSPHRASE changed elsewhere with the words unchanged still writes the fields, and a later join stays quiet (truthful: the words
  were not replaced); (b) also require the typed passphrase (when there is one) to open the vault — then that state writes nothing
  and the later join over-speaks (truthful sentences, P-VX309-U2-1's class). (a) is sound either way (the master is reached by the
  very words the file keeps) and is the more truthful moment; the charter's "the typed secret does not open the vault" read as the
  proof's secret.
- **F-L2-3 — the held window's faces read the file as a synced one (stated, not changed):** an unbound restored copy now carries
  the account's master lock and copy. Where the outgoing library had NO passphrase lock (E6 — joined by the words), the Castle lobby
  (pre-unlock, the record unreadable) reads the file as E6 and offers the passphrase field with R-529-6's line, and the vault road
  opens it with the account's passphrase — but lands no lock there (`catchUpThroughTheVault` refuses an unbound record), so the line
  recurs until the join. The check door and the VX-538 card read the record (no account ⇒ silent). A face's call — for her bundle.
- **F-L2-4 — New words in the held window (pre-existing class, stated):** a local New words re-makes an own words lock and leaves the
  master's copy (`KeyDoorProgram`'s key-file step refreshes the copy only when synced), so the account's words keep opening the
  unbound restored copy beside the new ones until a join — exactly the left-library class (rule 16's leave keeps every lock;
  `wordsAreTheAccountsAlready`'s own docstring names it). Not widened here.
- **F-L2-5 — the empty-slot landing (`makeThisMyLibraryInTheEmptySlot`) is NOT touched** (no library open, no current pair; the
  charter names Make this my library's own act). Its later join keeps today's moment.
- **F-L2-6 — the read happens with the app's pool closed** (`makeMine` runs after the teardown, as the act always has): on a slow
  network a signed-in press waits up to the bound before the act; offline fails fast. F-U2-7's bound question (her bundle) covers it.
  The read is not gated on the outgoing library being synced: no pre-read filter is sound (the W-6 shape itself — an unbound restored
  copy holding the account's pair with NO master lock — is exactly what a master-lock gate would skip); one bounded read on a rare,
  deliberate press. For the reviewer.

**The pieces (flip per commit; unverified claims PENDING):**
- L2-P0 — this LIVE STATUS, the trace and the design. DONE (`e848e96e9`).
- L2-P1 — THE PINS, red-on-old where the bug is claimed (core, `RestoredCopyJoinWordsMomentTests.swift`): the held row flipped
  (F-L2-1); the shape on a synced signed-in Mac; offline ⇒ today's file + the later join speaks; the words changed elsewhere ⇒
  nothing + speaks; the passphrase alone changed ⇒ written + quiet (F-L2-2); the crash after every write ⇒ the new library WITH the
  fields or the old state, never a third; no new write (the act's write log equals the offline run's, kind by kind); a fixed
  scenario through the scenario world (promises kept, the rejoin quiet, then Use Castle). DONE (`aaa2f7c63`) — the file's shared
  setup `RestoredCopyWorld` (the account on one Mac, a laptop that joined by the passphrase, its own backup planted; Standard,
  Castle Touch ID, Castle Always ask) and two new suites, `RestoredCopyProofFieldsTests` and `RestoredCopyProofFieldsScenarios`.
  **RED on the pre-fix tree** (`5dca7f06f`'s code; `swift test --filter RestoredCopy`): `✘ Test run with 10 tests in 3 suites
  failed after 0.554 seconds with 46 issues.` — exactly the claimed rows: the held pin `!replaced(joined)` (1); the shape
  `carriesTheProof` + the quiet join, ×3 postures (6); the passphrase-alone row's proof + quiet ×2 (4); the crash harness — the
  clean run not `finished` and every crash point "neither" (32: Standard and Castle Touch ID — Always ask left out, the harness's
  lobby tries the live key file only; said in the test); the two scenarios' field assertions (2 + 1 — their `expectPromisesKept`
  and every step GREEN on the old tree). **GREEN on the pre-fix tree, by nature (guards the fix must keep):** the words-arm quiet
  row, offline ⇒ today's file byte for byte + the moment speaks, the words changed elsewhere ⇒ today's file + speaks, no new write
  (the proven run's write log equals the offline run's, kind by kind).
- L2-P2 — THE CORE FIX (`Copies.swift`, `PlanRunner.perform`'s `pairProof:`, `ActContext.pairProof`) + the `.taken` pins.
  DONE (`dacc7bf63`; its revert L2-P4's RV-L2-1, verified) — `Executor/Acts/Copies.swift`: `AccountsVaultRead`
  (`.inTheDoor` · `.taken(VaultSnapshot?)`); `AccountPairProof` (the master + the wrap, redacted, never stored); both public
  `makeThisMyLibrary` forms take `accountsVault:` (default `.inTheDoor`) into the one body, which — after every refusal — asks
  `accountPairProof(words:from:)` (signed in; the vault the session's account's; the typed words open ITS master by the recovery
  wrap; `isMaster`; else nil, logged) and hands the proof to `perform(…, pairProof:)`; `makeMineKeyFile` with a proof builds
  `newLocks(words: false)` + the master and its copy (the join's VX-462 shape) in the same one write, without one today's
  locks exactly. `Executor/PlanRunner.swift`: `ActContext.pairProof` (the `copyKey` precedent) and `perform`'s defaulted
  `pairProof:` (every other caller unchanged). Nothing stored changes shape; zero `Sync/` lines. The `.taken` design row added
  (`theCallersReadIsVerifiedNeverTrustedNeverReplaced` — `.taken(nil)` writes today's file with the vault in reach and this
  session's read in hand; another account's read, and another account's vault under this account's name, today's file; the
  account's own read lands the fields with the server gone; signed out (Castle), today's file). **GREEN** (`swift test --filter
  RestoredCopy`): `✔ Test run with 11 tests in 3 suites passed after 0.578 seconds.` — the held pin among them, the crash
  harness and both scenario-world passes (every promise kept). The neighbours (`--filter "U2MakeMine|U2LookInside|
  SyncKeysSessionHold|EmptySlotMakeMine|JoinWordsMoment|ExactWrites|U2CrashHarness|CopyAct|RestoredCopy|Lifecycle|FixedScenarios|
  AccountScenarios|PairCatchUpScenarios|U4LaggingPair|OtherLibrarysCopiesDelete|U4KeyFileOffer"`): `✔ Test run with 107 tests in
  29 suites passed after 3.789 seconds.` (the lifecycle walk's makeMine check — `live?.master == nil` — untouched: its Mac is
  signed out at stages 9–10, so its door reads nothing).
- L2-P3 — THE APP'S BOUNDED READ (`ProtectionCopyDoors.makeMine`) + its harness pin (a slow server: the bound holds, today's file —
  red while the core reads unbounded in the door). DONE — THE PIN COMMITTED (`a6cd12f77`,
  `VariorumTests/Protection/MakeMineProofFieldsRoadTests.swift`, symlinked into unit 2's harness; the planted road: a Standard
  library turned on to sync, signed in, one backup of itself; the preflight then `ProtectionCopyDoors.makeMine`). The one
  production line in `a6cd12f77` is a defaulted, UNUSED `vaultWithin:` parameter on `makeMine` (no behavior — the pin's seam, the
  lobby suite's precedent), so the pin compiles on the pre-fix behavior. **RED on the tree as it stands** (the harness, `--filter
  MakeMineProofFieldsRoadTests`): `✘ Test run with 3 tests in 1 suite failed after 4.873 seconds with 2 issues.` — exactly the slow
  row: `clock.now - started < .milliseconds(1500)` (the core's own door read waited for the 2 s answer) and `isTodays` (it wrote the
  fields from that late answer). Green on both sides, as they must stay: online — ONE read, the fields written (the core's door read
  served it before the app's read existed); offline — today's file. THE FIX COMMITTED (`a6cd12f77` the pin; `05829dc27` the read;
  its revert RV-L2-2 verified — L2-P4): `ProtectionCopyDoors.makeMine` makes `proofVaultRead(session, within: bound)` — a writing road, the
  executor's signed-in account, ONE `ProtectionOpenRoad.boundedVaultRead` (VX-501's race; a late answer dropped; each ending
  logged) — BEFORE the restore hold (nothing moves while it waits; the hold-then-act order untouched), and hands it to the core as
  `accountsVault: .taken(read)`. `AppBootstrap` untouched. **GREEN** (the harness, `--filter MakeMineProofFieldsRoadTests`): `✔ Test
  run with 3 tests in 1 suite passed after 2.932 seconds.` The neighbours (`--filter "MakeMineRoadTests|PickedCopyRoadTests|
  PreviousLibrariesArcTests|WordsLedgerCarryRoadTests|CopyDoors|MakeMineProofFieldsRoadTests|ProtectionCopyCountsTests|HoldBanner|
  RestoreHold|LobbyVaultRoadTests|TypedUnlockSyncKeysTests|ProtectionOpenRoadPlantedTests"`): `✔ Test run with 82 tests in 17
  suites passed after 4.887 seconds.`; (`--filter "LookInsideRoadTests|ProtectionRestoreReceiptTests|RoadRestoreHoldGateTests|
  ProtectionJoinFollowRoadTests|RoadAccountModelTests|FirstRoundConfirmTests"`): `✔ Test run with 45 tests in 6 suites passed after
  0.637 seconds.`
- L2-P4 — THE REVERTS, each named here before it runs. RV-L2-1 DONE: named in the banner first (`1f6492aed`); `Copies.swift`'s
  `makeMineKeyFile` made to ignore the proof (`newLocks(words: true)`, the master clause disabled), `swift test --filter
  RestoredCopy` ⇒ `✘ Test run with 11 tests in 3 suites failed after 0.577 seconds with 48 issues.` — exactly the pre-fix red (the
  held pin 1, the shape 6, the passphrase-alone row 4, the crash harness 32, the scenarios 2 + 1 = 46) plus the `.taken` row's
  two given-read landings (2); the four guards green through it; restored by `git checkout --`, `git diff --exit-code` clean, `✔ Test
  run with 11 tests in 3 suites passed after 0.547 seconds.` RV-L2-2 DONE: named in the banner first (`e0763c144`);
  `ProtectionCopyDoors.makeMine`'s core call made to pass nothing (the core's default door read) with the app's read still made,
  the harness `--filter MakeMineProofFieldsRoadTests` ⇒ `✘ Test run with 3 tests in 1 suite failed after 5.089 seconds with 3
  issues.` — the slow row's two (exactly the pre-fix red: past the bound, the fields from the late answer) and the online row's
  ONE-read count (2 fetches: the app's read made and NOT handed in, the core's own door read on top — the count is what proves the
  act uses the app's read rather than a second one); offline green through it; restored by `git checkout --`, `git diff
  --exit-code` clean, `✔ Test run with 3 tests in 1 suite passed after 3.075 seconds.`
- L2-P5 — THE CLOSE. DONE (`79052d0b2`), on the finished product tree (`332679b41`; the close's commits touch no code):
  - THE CORE SUITE whole (`swift test`, debug, headless): VariorumCoreTests **`Test run with 3435 tests in 457 suites passed after
    206.223 seconds with 5 known issues.`** (P2's 4 negative controls + P6d's pinned residual — VX-523's held row is no longer one:
    6 → 5; 3426 → 3435, this session's 9 new tests); the one failure the ticketed MCP wall-clock flake
    `MCPHarnessTimeLimitTests.aPeerThatNeverAnswersInitializeFailsTheConnectNamedAndBounded` (18.9 s against 15 s — VX-353 /
    VX-532) in VariorumMCPTests; no protection code in it.
  - THE HARNESS whole (debug; `MakeMineProofFieldsRoadTests` symlinked in): `✘ Test run with 504 tests in 95 suites failed after
    47.120 seconds with 8 issues.` — exactly the standing eight: the five harness-PATH artifacts (`CopyListingFacesSurfaceTests` ×2,
    `EmptySlotDoorsSurfaceTests` ×2, `ProtectionRoadSwitchTests` ×1 — source pins reading `#filePath` beside a symlink) and VX-539's
    week-boundary flake (`ProtectionPairRetentionTests` ×3). Every other test green (499 + L1's 2 + this session's 3).
  - Zero `Sources/VariorumCore/Sync/`, `Server/`, `Persistence/` and `notes/CastleRules.md` lines (`git diff --stat main...HEAD --`
    each: empty); no stored shape (the two key-file fields exist and are written by the existing `settingMaster` inside `locking`;
    `ActContext.pairProof` and `AccountsVaultRead` are in-memory values); no trailer on any commit (`5dca7f06f..HEAD`: 0). L2's
    whole diff: `Copies.swift` (+109/−), `PlanRunner.swift` (+13/−), `ProtectionCopyDoors.swift` (+30/−), the two test files and this
    record.
  - **THE MAC-SUITE LIST for the stage batch:** NEW — `MakeMineProofFieldsRoadTests` (harness-green); exercising the changed
    `ProtectionCopyDoors.makeMine`, harness-green — `MakeMineRoadTests`, `PickedCopyRoadTests`, `PreviousLibrariesArcTests`,
    `WordsLedgerCarryRoadTests`, `LookInsideRoadTests`, `CopyDoors*`, `RoadRestoreHoldGateTests`, `ProtectionRestoreReceiptTests`;
    Mac-ONLY (runs PENDING the stage batch) — `MakeMineRouteTests`, `WordsLedgerCarryRouteTests`, `OtherLibrariesDeleteRouteTests`,
    `PreDesignLandingsRouteTests`, `WhatsNewWaitsAfterAdoptionTests` (their road is `RoadWorld`'s, signed out — the door reads
    nothing there, by reading); the PHONE — `MobileNoRedirectSweepTests` (the three new log literals name no Mac — scanned) and
    `MobileProtectionRoadTests`. The core's new suites ran in the core suite above.
  - **For the next round (stated, not changes):** the proof is the WORDS (P-VX529-L2-1 (a)); the door's read runs whenever the
    executor is signed in (F-L2-6 — no sound pre-read gate); the app reads BEFORE the restore hold, so a slow network costs up to
    the bound with nothing moved; the in-door read (`.inTheDoor`, a core caller's default) is unbounded, as every core act's own
    read is, and no app road uses it; `readVault` there records a fresh read this session (`freshVaults`), true of it.

**PROVISIONAL CALLS (for the closeout's QUESTIONS entry):**
- **P-VX529-L2-1** — the proof's secret (F-L2-2): (a) BUILT — the current pair's typed WORDS opening the vault's master (the copy
  is their road; a passphrase changed elsewhere with the words unchanged still writes the fields and the later join is quiet,
  truthfully); (b) also require the typed passphrase to open the vault (that state writes nothing; the later join over-speaks,
  truthfully).

**NEW SENTENCES:** none (three log lines only, in the app's road log; no face changed).

## L2 — THE ARCHITECT'S VERIFICATION AND DISPOSITIONS (2026-10-25)

Verified: the diff read (the `AccountsVaultRead` two-case shape with no fallback to an older read; `accountPairProof`'s
three checks; the fields riding the ONE existing key-file write; the app's one bounded read passed `.taken`); the
suites re-run by the orchestrator's own hand (29 tests in 7 suites green, the held row flipped among them); zero
`Sync/`/`Server/`/`CastleRules.md` lines by diff; the Mac app's full build on the L2 tree LANDED exit 0 (flipped from
PENDING at its notification; the orchestrator first wrote the claim prematurely, retracted it the same minute, and
flips it now on the real exit — the correction history is in the commits). The findings, DISPOSED:
- **P-VX529-L2-1 (the typed WORDS are the proof, not the passphrase) — ACCEPTED AS BUILT, provisional, HER BUNDLE:**
  the join's notice is about the WORDS being replaced; when only the passphrase changed, no words were replaced and
  the quiet is truthful. The alternative (require the passphrase too) is recorded beside it for her pass.
- **F-L2-3 (the pre-join window: a restored copy of an E6 library shows R-529-6's lobby line at every lobby until the
  join — the typed passphrase opens it through the vault but no lock lands while held) — TO ROUND 2'S ATTENTION AND
  HER BUNDLE:** it is an interaction of two new pieces (the proof fields and the heal's consumers under the restore
  hold); the reviewer weighs whether the heal should land on a held library or the face should say the join is the
  road.
- **F-L2-4 (a local New words during the window leaves the master's copy) — RECORDED, the existing left-library
  class.** **F-L2-5 (the empty-slot landing untouched) — RECORDED, outside the charter** (that landing types the
  copy's own secret with no account context; its join speaks as today). **F-L2-6 (the read runs whenever signed in;
  no sound gate exists for the W-6 shape; a slow network can cost the bound before the act) — ACCEPTED RESIDUAL:** a
  deliberate confirmed door pays one bounded read, unlike F-R1-1's per-typo path.
- **F-L2-1 (the held suite's setup line flipped to the any-road open — said in the test) and the crash-pin
  Castle-Always-ask gap (the harness lobby tries only the live file, the app's also tries the mirror — said in the
  test) — NAMED FOR ROUND 2**, the latter also for the stage batch's Mac-target run and the live proof's Castle leg.

## THE LADDER — ROUND 2 (2026-10-25; a fresh `fable-reviewer` over `c7dd3d591..HEAD` — the L1 and L2 fix sessions —
with the whole-branch diff for context; the record read whole, SyncSpec and CastleRules in full; its own runs:
the RestoredCopy/VaultRoad suites 16/4 green and the FULL core suite 3435/457 green with exactly the record's 5
known issues)

**0 BLOCKER · 0 MAJOR · 0 MINOR · 2 NIT — EVERY ROUND-1 FIX AND THE L2 FIX JUDGED SOUND. THE LADDER IS CLOSED**
(no new BLOCKER/MAJOR, so no round 3; the two NITs are record-hygiene edits, both the orchestrator's, both FIXED in
this commit):
- **F-R2-1 [NIT]** — F-R1-2's twice-lagged flag was only in the ladder section, not beside sentence 11 in the
  consolidated list a closeout would assemble her bundle from. **FIXED:** the bracketed flag now rides sentence 11.
- **F-R2-2 [NIT]** — the trued header named L1 but not L2, and unit 3's banner still opened "VX-523 NOT FIXED" with
  no forward pointer. **FIXED:** the read-forward note atop unit 3's LIVE STATUS and the header's ladder-closed line.
**The reviewer's load-bearing verdicts, accepted as final:** F-R1-1's gate is exactly the union of
`VaultRoad.answer`'s preconditions and can never starve a synced library (the join always writes a master lock);
L2's resume safety holds (a nil proof on resume can never overwrite a proof file — the stage/fingerprint guards);
no false detection downstream (the unbound record reads nothing; the restored copy's lock reuses the vault's
descriptor so the lobby names no false change post-restore); **F-L2-3's call: the heal should NOT land on a held or
unbound library** (rule 17 — the copy binds no account; the join is the one road that lands account locks), so the
recurring E6 lobby line until the join is a FACE-WORDING question for her bundle, as disposed; P-VX529-L2-1 (a)
sound (words-as-proof keeps rule 17's "under your current pair" literal). Clean bill: the frozen boundary verified
over the whole range (zero `Sync/`/`Server/`/`Persistence/`/CastleRules lines; every new type in-memory; the two
key-file fields pre-existing, written through the existing setter — R-510-20 to the letter); secrets never logged;
record honesty held through the premature-claim correction. **The only things between this tree and the merge are
the closing stage batch, the live proof, and HER TWO-MAC TEST.**

## THE CLOSING STAGE BATCH (2026-10-24 evening MDT, the orchestrator; stage claim `vx-529`, 240 min; zero instances
## confirmed before the run; she off the Pro at her word)

- **The Mac target, WHOLE** (`xcodebuild -scheme Variorum -destination 'platform=macOS' test`, DerivedData
  `vx529-stage`): **5265 tests — 5231 passed · 2 failed · 28 skipped · 4 expected failures** (~37 min).
  - **The 2 failures are VX-539, PROVEN pre-existing:** all in `ProtectionPairRetentionTests`, and the SAME suite
    with the SAME three expectation lines fails on MAIN (the shipped tree) run by the orchestrator in the same
    window (`/tmp/vx539check`) — the suite reads the real clock and this is the week boundary (Sat ~04:00 UTC),
    exactly the ticket's mechanism. Not this run's regression; nothing in the diff touches what it exercises
    (round 2 verified).
  - **The 28 skips, read per the protocol:** 27 are the standing gated capture/trace and window-geometry suites
    (by design); the 28th is the OPT-IN Apple-keys round-trip (`VARIORUM_APPLE_KEY_ROUND_TRIP=1` — it writes
    throwaway synchronizable items to the real iCloud Keychain). **Deliberately not opted in:** this run's diff has
    zero lines in the Apple-keys leaf, so the changed-source rule does not reach it (VX-510 ran it because ITS diff's
    premise needed it). The sync-keys custody suites — the leaves VX-530's fix DOES touch — ran (not in the skip
    list).
  - The 4 expected failures are the recorded known-issue rows. The ticketed MCP wall-clock flake did not fire.
  *[removed for publication]*
    vault standard rev 1 · `kp:` ENROLLED · 1 device cursor · 3 containers / 16 blocks / 16 variants, newest write
    2026-10-24 21:02Z — the first-run fix working in the field; one release stands (0.10.1, build 9311, 2026-10-24).
- **The phone suites** (`VariorumMobile`, iPhone 17 Pro simulator OS 26.2, DerivedData `vx529-phone`): **808 tests
  in 126 suites PASSED, 4 known issues** (~7 min; the whole mobile target — wider than VX-510's two filtered
  bundles). The first attempt exited 70 on an ambiguous destination name (two iPhone 17 simulators across OS 26.2
  and 27.0); pinned by device id and clean.

## THE LIVE PROOF — THE SCRIPT OF RECORD (written before it runs, the unit C pattern; the orchestrator's walk under
## the held stage; the prod test road ONLY — `VARIORUM_PROD_TEST_ROAD=1` + the allowlist from
## `~/.variorum/prod-test-accounts.env`, secrets typed only by the `~/.variorum/bin` helpers; window/region captures
## only; the `castle` account — entering state per VX-510's close: Standard, passphrase PASSPHRASE2, words the C3 set)

- **D0 — machinery:** the dev store's nine files aside WHOLE (`…-aside-vx529-drill/`, inodes recorded); a Debug walk
  build from this worktree (`DerivedData/vx529-walk`); `Tools/prod-confirm-test-user.sh` on the account; a fresh
  library L_A joined to `castle` (the account's rows pull); then L_A aside, a second fresh library L_B joined (the
  two-device stand-in, the VX-510 swap technique); prod-read confirms the vault's entering rev.
- **D1 — the everyday leg (Standard):** on L_B, Change passphrase PASSPHRASE2 → PASSPHRASE3 (rev moves). Swap to
  L_A: the detection owes the follow (Settings ▸ Protection speaks the pair sentence naming device and day; the
  stale "…caught up." line absent); sync still runs (Standard); Change passphrase on L_A refuses with the pair
  sentence, never the false one; the follow types PASSPHRASE3 → the round confirms in the sheet; the check door:
  PASSPHRASE3 "…opens this library and your account.", PASSPHRASE2 gets the honest split; the lobby after ⌃⌘L:
  PASSPHRASE2 opens nothing, PASSPHRASE3 opens.
- **D2 — the vault road (Castle):** L_B Use Castle (Always ask; both secrets). Swap to L_A → the posture follow
  (intoCastle, one secret — the standing regression leg). Both in Castle. On L_B, Change passphrase PASSPHRASE3 →
  PASSPHRASE4. Swap to L_A, ⌃⌘L: at the lobby type PASSPHRASE4 (the NEW one) → R-529-1 live: the library OPENS
  through the vault, the catch-up lands in the same press, the durable notice says so, the sync keys load (the log's
  road lines); ⌃⌘L again, PASSPHRASE4 again → opens LOCALLY (the re-lock landed; the vault road not consulted —
  the log says the local road).
- **D3 — the words arm (the forgot road):** on L_B, Change passphrase PASSPHRASE4 → PASSPHRASE5. Swap to L_A, open
  with the words (C3); the follow door's words arm: nothing but the words typed → the stale lock DROPS, the window
  sentence and the Reset chain show, the durable notice; the lobby then refuses PASSPHRASE4 (dead) and E6's line
  shows for a typed passphrase that is not the account's.
- **D4 — E6's card and the heal:** in L_A's E6 state, three launches → the VX-538 card shows with the why, the road
  and the forgot-road; at the lobby type PASSPHRASE5 (the account's current) → the HEAL lands the lock (the "opens
  this library on this Mac now" notice), the card retires on the state; ⌃⌘L, PASSPHRASE5 → opens locally.
- **D5 — the restored-copy quiet join (L2 live):** on L_A (converged), Back up now; Make this my library from that
  backup (signed in, online) → the proof fields land; Resume Sync → the join STAYS QUIET about the words (no
  words-replaced notice — the L2 fix live); the round confirms.
- **D6 — the loop closed:** swap to L_B (now lagging PASSPHRASE5 if D3/D4 moved the vault from L_A's side — else
  skip): the follow lands by the passphrase; both libraries converged; prod-read: the vault rev trail matches the
  legs, no stray writes.
- **D7 — restore:** sign the walk session out; quit at zero instances; the walk libraries' slot files and
  `Backups/<id>` folders removed BY the key files' ids; the dev store's nine files back, INODES CHECKED; one plain
  relaunch reads "Sync off (dev store)"; `Tools/stage release --who vx-529`; the account left at its ending state,
  RECORDED HERE for the next drill (the passphrase env note).
- **Evidence per leg:** the protection log's road lines, window-scoped captures into the gitignored walk folder,
  prod-read rev checks. A leg that misbehaves STOPS the drill — record, trace, never improvise past a surprise.

## Machinery

The standing cast (Fable orchestrates and cold-reviews; Opus implements, fresh per unit); pin-before-fix per member;
commits "Part of VX-529", no trailers; SessionResiliencyProtocol binds (commit per piece, LIVE STATUS from the first
commit, push after each, foreground waits); the stage only for walks/suite runs/refreshes; the dev store's rules and
`~/.variorum/dev-castle.env` for any dev-store Castle walk; the prod test road only through the VX-510 tools
(`Tools/WalkKit/first-run-walk.sh` env, `Tools/prod-confirm-test-user.sh`), secrets via the `~/.variorum/bin`
helpers. Environment traps: the VX-510 record's ENVIRONMENT TRAPS section binds verbatim for every session of this
run.
