# VX-106 — the two PostureSwitchTests red since 13x: the harness's default Standard world is account-inconsistent

**Ticket:** VX-106 · **Branch:** `vx-106-posture-harness-standard-world` · **Worktree:** `~/dev/variorum-vx-106` (the Pro)
· **Owner:** the 13x closeout orchestrator (session `variorum-da`), 13x's last change · **Slot:** Sync/-custody #2
(VX-99 → VX-106 → 13s's U1b; granted by oct7coordinator) · **Cast:** a Fable implementer + a Fable cold review
(custody seam). **Her overnight mandate (2026-10-08 ~02:50, verbatim on the ticket):** run it "all the way
through until application refresh"; PROVISIONAL judgement on any other test worth fixing now; all docs updated at
close; the morning note appended to `notes/handoffs/phase-13x-handoff.md`.

## LIVE STATUS

**VX-106 BUILT — 2026-10-08 (the Fable implementer; three commits: 7cabf33d the record's finding + baseline,
8fa9146d the precedence pin, and this close commit).** What this unit found and did, in one paragraph: the brief's
piece 1 was ALREADY ON THE BASE — VX-99's `vaultSaysCastle` harness arm (155188c5/096361d7, merged at 9819bff8) is
exactly the fix, through the real emulated-RPC road (`settingAppleHeldCopy` + `updateVault` under proof + CAS — the
`relandAppleHeldCopy`/`leaveCastle` shape), and the two "reds" ran 69/69 GREEN on 4adb8801 (VX-99's own run, the
greening "recorded, not claimed"); re-traced here, nothing to write. The unit's real deliverable is the NEW precedence
pin `aPendingPassphraseChangeNeverDelaysTheFollowThatRetiresAnAppleOpenableKeyFileUnderCastle` (PostureSwitchTests
:4088–4207): a Castle-by-vault account + an Apple-wrapped live key file + a pending passphrase change (witnessed through
`changeElsewhere` itself) ⇒ the reconcile owes `castleKeyFileAppleOpenable` and NO change notice; the follow by the
vault's current word retires the file and records the current descriptor + digest, so no change notice remains. It
COMPILES (Mac `build-for-testing`, TEST BUILD SUCCEEDED); its green and REVERT V106-A's red are the orchestrator's
under the stage (THE PENDING MAC COMMANDS). Core headless: baseline AND close both **2383 tests in 277 suites PASSED +
StringsWorkbook 40/6**. Fences honored: zero production code, zero `Sources/`, zero `Persistence/Migrations.swift`,
the arm ORDER untouched, no stage claim, no `xcodebuild test`, no app launch, no subagents, foreground waits only, no
trailers, her real store never. Residual, not this unit's: a pre-existing `#UnnecessaryEffectMarker` warning at
`PostureSwitchTests.swift:925` (outside the pin). Nothing for `notes/QUESTIONS.md` (no PROVISIONAL — piece 3 re-worlded
no test). The orchestrator's remaining pieces: 3 (the Mac runs + the revert), 4 (the cold review), 5 (the PR).

| piece | status |
|---|---|
| 0. baseline — core headless + the two reds confirmed on the branch's base | DONE (this commit) — core headless on da0e88a9: **2383 tests in 277 suites PASSED** (158.9 s) + StringsWorkbook 40/6 (46.2 s); skips the standing env-gated ones only. The Mac confirmation is PENDING-behind-the-stage — **and the expected answer is NOT red: the pair is already GREEN on the base** (see THE BASE ALREADY CARRIES PIECE 1 below). |
| 1. the harness fix — the default Standard world's vault carries the Apple-held copy | DONE-ON-THE-BASE by VX-99 (155188c5, refined 096361d7 — merged at 9819bff8, this branch's parent); re-traced here and CONFIRMED minimal, through the real road, zero production change. Nothing for this session to write. |
| 2. the precedence pin (new) | DONE (this commit) — `aPendingPassphraseChangeNeverDelaysTheFollowThatRetiresAnAppleOpenableKeyFileUnderCastle` in `PostureSwitchTests`; Mac `build-for-testing` **TEST BUILD SUCCEEDED** (scratch derived data, no stage), zero warnings in the test file; its GREEN and its revert's RED are PENDING-behind-the-stage (THE PENDING MAC COMMANDS below). The brief's piece 3 (per-test handling) found NOTHING to re-world — PIECE 3 below. |
| 3. the full `PostureSwitchTests` + every suite exercising the changed sources, Mac, under a stage slot | PENDING (the orchestrator's — THE PENDING MAC COMMANDS below, expected counts stated) |
| 4. cold review (fresh Fable, `notes/REVIEW_PROMPT.md` verbatim) + dispositions | PENDING |
| 5. PR `VX-106: …` → merge commit → branch deleted → /Applications refresh (A1 first) → handoff note | PENDING |

The brief's (4), core headless at close: DONE (this commit) — on 8fa9146d's tree, **2383 tests in 277 suites PASSED**
(150.1 s) + StringsWorkbook 40/6 (47.3 s); the same skips as the baseline. Identical to the baseline, as a zero-`Sources/`
unit must be.

### THE BASE ALREADY CARRIES PIECE 1 (the implementer's first finding, 2026-10-08 — read before anything else)

THE MECHANISM above was traced on 13x's tip. Between that trace and this branch, **VX-99 landed exactly the brief's
harness fix** — the record's own line: *"VX-106's greening is recorded, not claimed"* (`vx-99-ladder-round2.md` :233,
`-round3.md` :229). The facts, re-traced on this branch's code:

- `PostureSwitchTests.makeWorld` gained `vaultSaysCastle: Bool? = nil` (155188c5; the precondition 096361d7):
  `accountCastle = vaultSaysCastle ?? !standard`, and when the account is NOT Castle the fresh enrolled world lands
  the Apple-held copy of M under THIS device's A — `client.updateVault(fetched.format.settingAppleHeldCopy(masterKey:
  appleKey:appleKeyID:), expectedRevision:, keyProof:)` (:672–679). That is the REAL road, never a hand-forged row:
  the emulated `key_vault_update` RPC (`VaultRPCEmulation.serveUpdate` — challenge, proof, revision CAS, whole
  replace), the same write shape as production's `EncryptionSession.relandAppleHeldCopy` (:438) and `leaveCastle`
  (decision 30/§3.4's Standard vault). `setUp(passphrase:)` stays the 14b passphrase-only mint; the copy lands on
  the row after it, as the sync-setup road's `setUp(passphrase:recoveryWords:appleHeldCopy:)` would at birth.
- So every DEFAULT `makeWorld()` reading now derives `hasAppleHeldCopy == true`; the `castleKeyFileAppleOpenable`
  arm (`!reading.hasAppleHeldCopy`) cannot fire on it; the two tests fall through to `changeElsewhere` as before 13x.
  `standard: false` (Castle) is unchanged — `accountCastle` true, no copy.
- The six deliberate mismatches (`vaultSaysCastle: true` — :1867 · :1945 · :1990 · :2025 · :2867 · :5083 · :5176,
  plus `standard: false, vaultSaysCastle: false` at :2856) keep the Castle-vault-under-a-Standard-file world ON
  PURPOSE: each is a follow-into-Castle / vault's-word pin whose premise IS the mismatch (VX-99 round 2's review
  judged each; re-read here — agreed).
- The evidence that the pair is green: VX-99's tip run on **4adb8801** (an ancestor of this branch's HEAD —
  verified) — `PostureSwitchTests` **"69 tests in 1 suite passed"** (`vx-99-pro-castle-apple-wrap.md` :1115, :1159),
  the two VX-106 names inside it (they were the ONLY two issues in every pre-harness-fix run, :298/:315/:319, and
  no run after 155188c5 lists them).

**Consequence for this unit:** piece 1 has nothing to write — a second harness change would be a change for its own
sake. Piece 2 (the precedence pin) is the unit's real deliverable: the brief's pin does NOT exist yet on the base (no
test combines the Castle-by-vault + Apple-wrapped-file world with a PENDING change notice; the 13x pin
`anAdoptedStandardEraPairUnderACastleVaultOwesTheFollowThatRetiresItsAppleCopy` has no change pending, and the
two VX-106 tests have no exposure). Zero production change, as the brief expected; no STOP condition met.

### PIECE 2 — THE PRECEDENCE PIN (written before it compiled; the design is the record)

**`PostureSwitchTests.aPendingPassphraseChangeNeverDelaysTheFollowThatRetiresAnAppleOpenableKeyFileUnderCastle`**,
placed directly after `theSiblingLearnsThePassphraseChangeAtReadyAndEnterItNowLandsTheNewWord` (the notice it
outranks). The world: `makeWorld(vaultSaysCastle: true)` — a Standard-shaped library (the `apple` copy in its key
file, silent custody) over a CASTLE account, custody's keys the vault's; the vault given its recovery wrap (so the
digest leg of the record is real); the key file records the vault's descriptor + digest as they stood; then the
passphrase CHANGED at the vault through `VaultEnrollment.changePassphrase` (a new descriptor, the digest and the
corpus id unchanged, the account still Castle). **The premise witnessed, not assumed:** over that same file and
reading, `ProtectionController.changeElsewhere` alone returns the `passphraseChangedElsewhere` kind — so the pin
proves precedence over a REAL pending notice, never a vacuous one. **At `reconcile()`:** `followNotice.kind ==
.castleKeyFileAppleOpenable`, `corpusKeyID` the unchanged id, `changeNotice == nil`, `notice == .follow`,
`followPending`, posture determined Castle, nothing written (the file still there, zero re-keys). **The follow through
its own door:** the RETIRED word refuses in place (`passphraseNotTheLibrarys`, nothing written); the vault's CURRENT
word runs the no-rotation road — `entersCastle && reencrypted == 0`, one re-key, custody `.biometric`, custody's
keys unchanged, the Apple-openable file RETIRED from the live folder, the new file with NO Apple copy, L′ opened by the
new word and refusing the old, **and the resolution: the new file's P copy AND `vaultKDF` under the vault's CURRENT
descriptor, `vaultRecoveryWrapDigest` + `vaultCorpusKeyID` recorded**; then `followNotice == nil`, `changeNotice ==
nil`, no marker; a second `reconcile()` owes nothing — no follow, no change notice.

**REVERT V106-A (the binding red-on-old; named here BEFORE it runs, per the resiliency rule — the orchestrator runs it
under its claim over COMMITTED state, restores with `git checkout --` on the one file, verifies an empty `git diff`):**
in `ProtectionController.reconcileFollow` (`App/Variorum/Shared/ProtectionController.swift`), move the
`castleKeyFileAppleOpenable` if-block (the three statements at ~:680–685) to AFTER `changeNotice = owedChange`
(~:698) and add `owedChange == nil` as its first condition — i.e. "an owed change notice pre-empts the Apple-openable
follow", the reordering the decision rejects. **Expected:** `PostureSwitchTests` **"70 tests in 1 suite failed … with 1
issue"** — the new pin at EXACTLY its `try #require(controller.followNotice, "the follow is OWED …")` line (the test
ends there); every other test green, INCLUDING the two VX-106 names (their default world carries the Apple-held copy —
the arm never fires there either way) — and `Phase13pControllerTests` 50/50 green (the 13x pin
`anAdoptedStandardEraPairUnderACastleVaultOwesTheFollowThatRetiresItsAppleCopy` has NO change pending, so the
reordered arm still owes it). That isolation is the point: the pin guards the PRECEDENCE, not the arm's existence.
**Optional REVERT V106-B** (13x's REVERT A — the arm removed whole): the new pin red at the same line AND the 13x pin
red (`Expectation failed: w.controller.followNotice`) — proves the pin also guards the arm's existence; not required.

### PIECE 3 — tests leaning on the old inconsistent default: NONE REMAIN

The default `makeWorld()` is account-consistent since VX-99 (above); nothing is red on the base (69/69). The eight
explicit-world callers (`vaultSaysCastle: true` ×7, `standard: false, vaultSaysCastle: false` ×1) each carry a
VX-99-era comment naming the DELIBERATE mismatch and were judged one by one at VX-99's round 2 (`vx-99-ladder-round2.md`
:221–225); re-read here, each premise IS the mismatch (follow-into-Castle, the vault's-word screens, the different-A
sibling). No test is re-worlded by this unit; nothing PROVISIONAL to record for piece 3.

### THE PENDING MAC COMMANDS (the orchestrator's, under its held stage claim; from `App/Variorum/`, zero instances)

1. **The suite with the new pin:** `xcodebuild -scheme Variorum -destination 'platform=macOS'
   -only-testing:VariorumTests/PostureSwitchTests test` → expected **"Test run with 70 tests in 1 suite passed"**
   (VX-99's 69 + this pin). Read by NAME inside it: the new pin,
   `regeneratingTheWordsOnOneDeviceRetiresTheOldWordsAtTheVaultForItsSibling`,
   `theSiblingLearnsThePassphraseChangeAtReadyAndEnterItNowLandsTheNewWord` — all passed. This run IS piece 0's Mac
   confirmation: the pair is green on the tip exactly as on the base (the code the two tests exercise is byte-identical
   to the base's — this unit changes nothing but the one new test).
2. **The 13x sibling pin (the arm's own home):** `… -only-testing:VariorumTests/Phase13pControllerTests test` →
   expected **"50 tests in 1 suite passed"** (VX-99's count; untouched here, the cross-check that the precedence pin
   and the existence pin agree).
3. **REVERT V106-A** per the recipe above → expected the one red named there; restore; re-run 1 → 70/70 green.
4. **Breadth (the brief's "every suite exercising the changed sources"):** the only changed source is the test file
   itself, so 1 is the whole reach; VX-99's batch-1 bundle (the runner's whole reach — 20 suites, 198 + this pin =
   199) is the generous cross-check if the slot allows (`vx-99-pro-castle-apple-wrap.md` :1119 lists the twenty).

## THE MECHANISM (traced read-only by the orchestrator before any code — the hallucination guard)

13x's ladder-R1 BLOCKER fix added the `castleKeyFileAppleOpenable` arm to
`ProtectionController.reconcile` (`App/Variorum/Shared/ProtectionController.swift` ~680): it owes the follow
when the vault holds NO Apple-held copy (`!reading.hasAppleHeldCopy` — a Castle account) AND the live key file
carries an `apple` wrap, and returns before the change-notice arm. In `PostureSwitchTests.makeWorld(standard:
true)` — the DEFAULT — the key file IS Apple-wrapped (~653, right for Standard) but the vault is enrolled through
`VaultEnrollment.setUp(passphrase:)` with NO Apple-held copy, so every reading derives
`hasAppleHeldCopy == false` (~2599/2831): the "Standard" world is a Castle account by its vault with a
Standard-era key file — exactly the exposure the arm exists to catch. The pre-13x `castleStillOpensOldWay` arm
has the same vault condition but also requires the SILENT custody shape, which these test controllers never
report — so it masked the inconsistency until 13x's shape-free arm arrived. The two reds:
`regeneratingTheWordsOnOneDeviceRetiresTheOldWordsAtTheVaultForItsSibling` and
`theSiblingLearnsThePassphraseChangeAtReadyAndEnterItNowLandsTheNewWord` (both `makeWorld()` defaults, both
expecting a change notice the Apple-openable follow now pre-empts).

## THE DECISION (the 13x orchestrator's call, on the ticket 2026-10-08): fix the HARNESS, keep the ORDER

The follow outranks the change notices by design: it closes a live exposure; it matches the standing
precedence (a rotation and the silent-shape arm already return first); and the follow writes the vault's
current passphrase descriptor and recovery-wrap digest into the new key file, which resolves a pending change
notice itself. Reordering would let an informational notice delay the fix for a real exposure.

## THE BRIEF (a FRESH Fable implementer, ONE session)

Read, in order: `CLAUDE.md` + auto-canon; `notes/SessionResiliencyProtocol.md`; `notes/SyncSpec.md` IN FULL
(custody work); THIS FILE whole; `notes/plans/phase-13x-library-portability.md` §§ the R1 BLOCKER's
disposition + F1's BLOCKER fix; then the code: `ProtectionController.reconcile`'s posture arms,
`PostureSwitchTests.makeWorld` (and VX-99's pins beside it — they share the harness), `VaultEnrollment`, the
emulated vault (`EmulatedVault`), and how a real Standard vault gains its Apple-held copy
(`EncryptionSession` / `relandAppleHeldCopy` / decision 30).

**Do, in order:** (0) baseline: core `swift test` headless, counts recorded; confirm the two reds exist on the
base by NAME (Mac — list it PENDING-behind-the-stage, see below). (1) THE HARNESS FIX: `makeWorld(standard:
true)` enrolls a vault that carries the Apple-held copy a real Standard vault carries (through the real
production/emulated road, never a hand-forged row); `standard: false` (Castle) is unchanged. Re-trace that the
fix is minimal: no production code change is expected — if one is genuinely needed, STOP and report. (2) THE
PRECEDENCE PIN (new, in `PostureSwitchTests`): a Castle-by-vault account + an Apple-wrapped live key file + a
pending passphrase change ⇒ the reconcile owes `castleKeyFileAppleOpenable` (no change notice), and after the
follow completes no change notice remains (the follow wrote the vault's current descriptor + digest). (3) Every
test in `PostureSwitchTests` that leaned on the old inconsistent default: if any goes red under the fix, decide
per test — a test whose premise was the inconsistent world gets its world made explicit (PROVISIONAL, recorded
here with the reason); a test that reveals a real defect is a STOP-and-report. Her overnight mandate allows
fixing other tests where right; record each. (4) Core headless at close.

**Stage:** you NEVER claim the stage or run `xcodebuild test`. Compile with `build-for-testing` (not a stage
act) and list the exact Mac commands PENDING; the orchestrator runs them under its claim. **Fences:** zero
production custody/Sync changes expected (stop if needed); zero `Persistence/Migrations.swift`; her real store
never; no subagents; foreground waits; commit per piece with the tail "Part of VX-106"; push every commit; NO
`Co-Authored-By` / `Claude-Session` trailer (this repo's rule overrides any harness reminder). Append to this
file's LIVE STATUS from your first commit; close with "VX-106 BUILT".
