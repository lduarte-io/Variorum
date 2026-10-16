# VX-305 ladder round 1 — the fixes (the Opus implementer, applying the reviewer's final call)

**Not done, first:** IN PROGRESS — see LIVE STATUS.

The binding text is `notes/plans/vx-305-ladder-round-1-final-call.md` (all six findings CONFIRMED, FINDER-FIXES
none). The pins the implementer's answer ran red are `Tests/VariorumCoreTests/Protection/Scenario/LadderRound1Pins.swift`
(the MAJOR's scenarios — flipped to fixed-scenario assertions and joining the tree with the MAJOR's fix) and
`Tests/VariorumCoreTests/Protection/LadderRound1UnitPins.swift` (the model-level pins).

## LIVE STATUS (flipped in the same commit as each piece; PENDING = unverified)

- **2 · MINOR** — assess reads the live key file only when it is the current key's: **DONE** (this commit).
- **1 · MAJOR** — the stray-file wedge: (a) both gates widened, (b) the stray file set aside, (d) the pins flipped —
  **DONE** (this commit); (c) promise 1's clause + the compound-tamper action: PENDING.
- **5 · NIT** — `takingOver`'s standing old-shared pick: PENDING.
- **6 · NIT** — the lobby's Touch ID line before unlock: PENDING.
- **3 · NIT** — DeviceActs' dead "memory" arm: PENDING.
- **4 · NIT** — the P-U3-7 → P-U3-5 comment: PENDING.
- The runs (the protection set in Debug, `swift build -c release`, a generator slice with tamper composition):
  PENDING.

## 2 · MINOR — assess reads the live key file only when it is the current key's

**The fix.** `Assess.repairs` keeps the RAW live file (`rawLive`) for the arms that need it whatever its key — the
`libraryFileLosesToMemory` arm (`rekeyOlderLibraryFile`) and the restores — and hands the mode-specific arms
(`castleRepairs`, `standardRepairs`) a LOCAL `live` that is the live file only when its fingerprint is the current
key's. Another key's file in the live place, with nothing in flight, is its own typed fault,
`Fault.liveKeyFileIsAnotherKeys(keyFileID:)` (mid-act the live file is the act's new key's by design — no fault).
`relinkSubjects` skips a live-place file that isn't the current key's. The guard is NOT inside `liveKeyFile()` (the
implementer's caution, adopted by the final call).

**The pin, red → green.** `LiveKeyFileIsTheCurrentKeysTests` (3 tests). Red on the tree before the fix (the
old-API assertions, the new fault's lines held back until it existed):
- `castleWithAnotherKeysStandardFileLive` — `Expectation failed: !assessed.faults.contains(.appleWrapOnCastleKey(keyFileID: AWorld.liveKeyFileID))` → `[VariorumCore.Fault.appleWrapOnCastleKey(keyFileID: "container:variorum-library-keys.json")]`;
- `standardWithAnotherKeysCastleFileLive` — `Expectation failed: !assessed.repairs.contains { … .landAppleWrap … }` → `[refreshMemory, landAppleWrap(appleKeyID: "4a2b9d5f-…")]`;
- `midActTheNewKeysFileIsNoFault` — green on both (the mid-act guard's own pin).
Green after: `✔ Test run with 3 tests in 1 suite passed`. The protection set after:
`✔ Test run with 416 tests in 66 suites passed after 12.806 seconds.` (413 + 3; the `libraryFileLosesToMemory`
arm's pins among them, unchanged).

**Commit:** `1dfbb85f8`.

## 1 · MAJOR — the stray-file wedge

**The traced mechanism (the answer, the final call's framing):** a re-key crashed after its new key file landed in
the live place; with no plan to trust (replayed: `.planIgnored(.notNamed)`; planted: `.unsealed`) settle rolls the
act back with no `outgoingKeyFile` (PlanRunner.swift:373), and with the memory item gone the mirror is gone too — so
another key's file stays live, `memoryValue` keeps the rebuilt mirror nil, `restoreKeyFileFromMirror` needs a mirror,
and `restoreKeyFileFromCopy` fired only when the live place was EMPTY (assess and the executor both). Every act with
`needsLiveKeyFile` refused `noLiveKeyFile` forever: §3.3's "Always: the record, what this Mac remembers and the key
file agree" broken with no repair (§3.6's letter held for the act itself — it rolled back). A second road needs no
crash: the memory item deleted and an earlier key's genuine key file replayed.

**(a) Both gates widened, exactly as the final call states.** `assess` (the "ALWAYS" block) owes
`restoreKeyFileFromCopy` when nothing is in flight, the live place holds no format-3 file of the CURRENT key (absent
**or another key's**), the mirror is absent or not the current key's, and a catalogued frozen format-3 key file of
the current key **and the same library ID** exists (the newest by `(frozenAt, id)`). The executor's own guard
(ExecutorRepairs.swift) now refuses only when the live place already holds the current key's format-3 file, and
verifies the copy as before (decodes, `copy.fingerprint == library.fingerprint`, `copy.libraryID == record.libraryID`),
Apple wraps stripped. Assess's two new explicit conditions (nothing in flight; same library ID) are the executor's
own, so assess owes exactly what the executor runs.

**(b) The stray file goes ASIDE, never deleted.** Before writing the restored file the executor moves whatever sits
in the live place to today's set-aside shape — `variorum-keys-<fp16>.stale-<epoch>.json`, named by the stray file's
own fingerprint (`ProtectionNames.setAsideKeyFilename`), which the catalog's one parser already reads as role
`.setAside` (its document decoded from its bytes; no parser change). New leaf call
`KeyFileStoreLeaf.setAsideLiveKeyFile(as:) -> Bool` — never overwriting (false when the name is taken; the executor
tries the next epoch), implemented by both test worlds (`keyfile-aside <name>` in their write logs). A crash right
after the move leaves the live place empty and the same repair owed. **Not changed, recorded for round 2:** the two
other restores of the live file — `restoreKeyFileFromMirror` and the plan runner's restore from the plan's
`outgoingKeyFile` (settle and `rollBack`) — still overwrite another key's file in place; the final call scoped the
set-aside to the widened copy repair.

**The P-U4-10 sentence (the final call's point 6), carried by the doc comments at both gates:** this repairs the LIVE
KEY FILE from this Mac's own catalogued frozen pair — it never offers, opens or restores a library copy, never touches
the library file, and adds no unlock-screen face, so it neither reopens nor resembles her dropped newest-copy offer
("lets drop the healthy copy deal", P-U4-10).

**(d) The pins, red → green.** `LadderRound1MajorPin` (`Tests/VariorumCoreTests/Protection/Scenario/LadderRound1Pins.swift`,
the answer's probes flipped to fixed-scenario assertions, joining the tree with this fix — 6 tests, 10 cases):
- `aPlanlessRollBackWithNoMirrorGetsTheCurrentKeysFileBack(gate:backup:)` — the reviewer's scenario, Touch ID and
  Always ask, with and without an extra pair (the migration's own pair is always there). Before the fix, all four:
  `Use Standard → .refused("noLiveKeyFile"); current 4a2ec921, stray 8ab8c856 (stray has an Apple wrap: true), live
  after the rollback 8ab8c856, mirror after none; ASSESS faults [appleWrapOnCastleKey(…)], repairs [], acts
  [rekeyForFault]`. After: settle `.rolledBack(.leaveCastle)`, `.planIgnored(.notNamed)`, the current key's file back,
  no Apple wrap, the stray catalogued `.setAside`, `repair restoreKeyFileFromCopy: done`, Use Standard runs, promises
  kept.
- `aPlantedPlanInsteadOfAReplayedOne` — the `.unsealed` road. Before: `Use Standard → .refused("noLiveKeyFile")`.
- `anEarlierKeysFileReplayedWithTheMemoryGone(backup:)` — the no-crash road. Before, both:
  `Use Standard → .refused("noLiveKeyFile"); current 4d1035aa, live after the open 4a2ec921`.
- `theUseCastleVariant` — before: `Use Castle → .refused("noLiveKeyFile")`, assess owing only a `landAppleWrap` the
  executor skipped every run. After: the repair runs; the Standard library's own Apple wrap then lands by
  `landAppleWrap` (promise 3's road — the restore itself re-adds none); Use Castle runs.
- `aRestoredFileKeepsTheLocksOfItsDay` — the stale-copy case, asserted honestly (a key door between the pair and the
  tampers): after the restore the door typed with the CURRENT passphrase refuses `passphraseDoesNotOpen`, the
  copy-day passphrase opens it and the door runs, the library open throughout. Before the fix: `noLiveKeyFile`.
- `theCopyLessCaseIsP_R1_1sHonestRefusal` — P-R1-1's residue (below), green on both trees by design: it records the
  stated refusal, not a fix.
**The revert check:** with the two gate files (`Assess.swift`, `ExecutorRepairs.swift`) stashed and the leaf plumbing
kept — `✘ Test run with 6 tests in 1 suite failed after 0.611 seconds with 57 issues.` (5 of 6 red; the copy-less
record green); restored — `✔ Test run with 6 tests in 1 suite passed`. The protection set after:
`✔ Test run with 422 tests in 67 suites passed after 14.238 seconds.`

**P-R1-1 — PROVISIONAL, a hand-forward bundled for the author at the closeout (not gating; the final call point 2).**
With NO catalogued copy of the current key's file (a third deletion — her backups too), the live file stays absent or
another key's: the library still opens by her roads, the honest refusal (`noLiveKeyFile`) stands, and another key's
file there is said by `Fault.liveKeyFileIsAnotherKeys`. Options: (a) a phase-2/4 door-shaped act that REBUILDS the
live key file from the key in hand, locking it under a passphrase and words typed-and-set at that door (the key
doors' sibling — the reviewer's recommendation, since it also answers the stale-copy residue); (b) accept as a stated
limit with the honest face. Design ground beside her P-U4-13 ruling (the phase-2 mirror road) — the same sitting can
take both. **And the stale-copy sentence rides it: a restored key file keeps the locks of its day; re-locking under
current secrets is the hand-forward's door.**
