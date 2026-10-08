# VX-106 — the two PostureSwitchTests red since 13x: the harness's default Standard world is account-inconsistent

**Ticket:** VX-106 · **Branch:** `vx-106-posture-harness-standard-world` · **Worktree:** `~/dev/variorum-vx-106` (the Pro)
· **Owner:** the 13x closeout orchestrator (session `variorum-da`), 13x's last change · **Slot:** Sync/-custody #2
(VX-99 → VX-106 → 13s's U1b; granted by oct7coordinator) · **Cast:** a Fable implementer + a Fable cold review
(custody seam). **Her overnight mandate (2026-10-08 ~02:50, verbatim on the ticket):** run it "all the way
through until application refresh"; PROVISIONAL judgement on any other test worth fixing now; all docs updated at
close; the morning note appended to `notes/handoffs/phase-13x-handoff.md`.

## LIVE STATUS

| piece | status |
|---|---|
| 0. baseline — core headless + the two reds confirmed on the branch's base | PENDING |
| 1. the harness fix — the default Standard world's vault carries the Apple-held copy | PENDING |
| 2. the precedence pin (new) | PENDING |
| 3. the full `PostureSwitchTests` + every suite exercising the changed sources, Mac, under a stage slot | PENDING |
| 4. cold review (fresh Fable, `notes/REVIEW_PROMPT.md` verbatim) + dispositions | PENDING |
| 5. PR `VX-106: …` → merge commit → branch deleted → /Applications refresh (A1 first) → handoff note | PENDING |

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
