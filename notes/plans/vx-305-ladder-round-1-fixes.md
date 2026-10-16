# VX-305 ladder round 1 — the fixes (the Opus implementer, applying the reviewer's final call)

**Not done, first:** IN PROGRESS — see LIVE STATUS.

The binding text is `notes/plans/vx-305-ladder-round-1-final-call.md` (all six findings CONFIRMED, FINDER-FIXES
none). The pins the implementer's answer ran red are `Tests/VariorumCoreTests/Protection/Scenario/LadderRound1Pins.swift`
(the MAJOR's scenarios — flipped to fixed-scenario assertions and joining the tree with the MAJOR's fix) and
`Tests/VariorumCoreTests/Protection/LadderRound1UnitPins.swift` (the model-level pins).

## LIVE STATUS (flipped in the same commit as each piece; PENDING = unverified)

- **2 · MINOR** — assess reads the live key file only when it is the current key's: **DONE** (this commit).
- **1 · MAJOR** — the stray-file wedge (both gates widened; the stray file set aside; promise 1's clause; the
  compound-tamper action; the pins flipped): PENDING.
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

**Commit:** this commit.
