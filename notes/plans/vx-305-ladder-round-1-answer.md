# VX-305 ladder round 1 — the implementer's agree/dispute (committed unedited; the cross-model flow's second step)

*(A fresh Opus implementer answering `vx-305-ladder-round-1.md`. No fixes applied, nothing committed by the implementer; its one artifact is the untracked red pin file named below. The reviewer's final call follows this document.)*

## VX-305 ladder round 1: the implementer's agree/dispute (no fixes applied, nothing committed or pushed)

**Not done:** no fixes, commits or pushes, as instructed. The only change in the tree is one untracked pin file: `<home>/dev/variorum-vx-305/Tests/VariorumCoreTests/Protection/Scenario/LadderRound1Pins.swift`. It is red by design, so `swift test` on the protection set will fail while it sits in the tree.

**Tally:** I agree with all six findings and dispute none. I have three scope notes on the MAJOR's proposed FIX and one framing note.

### The MAJOR's pin result, verbatim

The reviewer's scenario is built as `LadderRound1MajorPin.aPlanlessRollBackWithNoMirrorLeavesAnotherKeysFileLive(gate:backup:)`, run for Touch ID and Always ask, with and without an extra backup. The steps:
- Act A (`setScheduledExport`) crashes after write 3, its genuine plan is grabbed off disk, and the relaunch settles A.
- Use Standard crashes after write 13, with the new key's file live, the library still under the old key, and the plan on disk.
- The two tampers then run through `apply`: `deleteMemoryItem`, then `replayPlan` with A's plan.
- Relaunch, then Use Standard again.

**RED in all 4 cases on today's tree.** For example:
```
✘ ... gate → .touchID, backup → false at LadderRound1Pins.swift:90:9: Expectation failed: result == .done
↳ gate .touchID, backup false, A crashed after write 3, the leave after write 13: Use Standard → .refused("noLiveKeyFile"); current 4a2ec921, stray 8ab8c856 (stray has an Apple wrap: true), live after the rollback 8ab8c856, mirror after none; ASSESS faults [VariorumCore.Fault.appleWrapOnCastleKey(keyFileID: "container:variorum-library-keys.json")], repairs [], acts [VariorumCore.OwedAct.rekeyForFault]
```
The intermediate expectations all held, so the path is exactly the reviewer's:
- the settle returns `.rolledBack(.leaveCastle)`;
- `.planIgnored(.notNamed)` is reported;
- no act is left in flight;
- A's plan is gone after its own settle.

The whole file ends `✘ Test run with 6 tests in 1 suite failed after 0.533 seconds with 10 issues.` The other five tests are supporting probes, covered below.

### Per finding

**MAJOR (PlanRunner `rollBack` plus the Assess gate): AGREE.**
- **Mechanism, traced myself:** `settle` (PlanRunner.swift:343–375) ignores the replayed plan as not named. With no plan it trusts and `committed` false, it calls `rollBack(&library, act:)` with no `outgoingKeyFile` (line 373).
- `unlock` built the library with `memory == nil` after the deletion, so the restore list at lines 553–554 is empty and lines 555–558 keep the stray file live.
- `memoryValue` (Executor.swift:325) then writes a memory with a nil mirror.
- The repairs can't reach it: `restoreKeyFileFromMirror` needs a mirror; `restoreKeyFileFromCopy` is gated on an empty live place in both Assess.swift:281 and the executor (ExecutorRepairs.swift:202).
- Every act with `needsLiveKeyFile` then refuses at PlanRunner.swift:231. That is Use Castle, Use Standard, Replace All Keys, the follow, Send Library, the account acts and the key doors (lines 110–117).

**Reachability is wider than the annotation:**
- **No captured plan needed:** with a planted plan instead of a replayed one, the seal fails, settle takes the `.unsealed` arm (line 353) and reaches the same rollback. Pinned RED in `aPlantedPlanInsteadOfAReplayedOne` (the leave crashed after write 13; Use Standard → `.refused("noLiveKeyFile")`; `.planIgnored(.unsealed)` asserted).
- **No crash needed:** deleting the memory item and replaying an earlier key's genuine key file while the app is closed lands in the same state. Pinned RED in `anEarlierKeysFileReplayedWithTheMemoryGone`, both cases: current 4d1035aa, live 4a2ec921, `noLiveKeyFile`.
- It is still always two tampers, never one.

**A second reason the soak never saw it:** the world's `step` launches a closed device before every tamper, which settles a crashed act, and relaunches right after it (Generator.swift:27–35 and 67–75). So the generator can never put two tampers together or land one inside a crash window. That is on top of the promise blindness the reviewer named. The fix's pin must use `apply`, as mine does.

**The Use-Castle variant:** `theUseCastleVariant` is RED (Use Castle → `noLiveKeyFile`, settle `.rolledBack(.enterCastle)`). `assess` owes only `landAppleWrap`, and the executor skips it every run as `preconditionDoesNotVerify`. Nothing in the assessment says anything is wrong, exactly as the reviewer said.

**Scope notes on the proposed FIX** (for the reviewer's final call, not disputes):
1. **The gate changes in two places.** It must widen in `assess` (Assess.swift:281) and in the executor's own guard (ExecutorRepairs.swift:202).
2. **The source can be absent.** Every variant above had a copy to restore from, because the `today` fixture and migration leave a frozen pair of the current key (`Backups/<lib8>/<mac8>/…-4a2ec921.keys.json`). So my "backup: false" cases are not copy-less. With truly no catalogued copy, the state stays stuck. This already happens today without the stray file: `theKeyFileAndTheMemoryItemBothDeletedWithNoBackup` deletes `Backups/`, then the key file and memory item on a Touch ID Castle library. The lobby opens it, then Use Standard → `.refused("noLiveKeyFile")`, live key file none. The proposed repair closes the MAJOR only where a copy exists. Whether a door that types both secrets should rebuild the file in the copy-less case is a design question, not mine.
3. **The source can be stale.** The both-deleted repair the fix reuses restores the newest frozen copy, whose locks are of its day. `aCopyRestoredAfterAPassphraseChange` runs Change Passphrase, then deletes the key file and memory item: Use Standard with the current passphrase → `.refused("passphraseDoesNotOpen")`. The fix inherits this, so its pin should include a key door between the copy and the tamper. This is a pre-existing behaviour I am flagging, not a finding I am adding.

**Framing note:** §3.6's "a missing or unmatched plan never blocks" governs the act in flight, and that act did roll back (pinned). The contract the end state breaks is §3.3's "Always: the record, what this Mac remembers and the key file agree", which no repair restores. I agree the severity is MAJOR: the state is permanent, and in the Use-Castle variant nothing reports it.

**MINOR (`assess` reasons over another key's live file): AGREE.**
- `UnlockedFacts.liveKeyFileID` is whatever sits in the live place, whatever its key (World.swift:879–880; Facts.swift:205–206). `liveKeyFile()` (Assess.swift:209–213) returns it unchecked.
- Measured, Use-Standard variant: `faults [appleWrapOnCastleKey]`, `acts [rekeyForFault]`, and no act can answer it.
- Measured, Use-Castle variant: `repairs [landAppleWrap]`, skipped `preconditionDoesNotVerify` (ExecutorRepairs.swift:171–174) on every run.
- No wrong write is reachable. `landAppleWrap` and Re-link's library arm (SharedKeyAndRelink.swift:60) both check `live.fingerprint == library.fingerprint`.
- **One caution on the fix:** put the guard on line 303's local `live` only, never inside `liveKeyFile()`. The `libraryFileLosesToMemory` arm (Assess.swift:234–235) has to read a live file of a different key (the memory's newer key) to owe `rekeyOlderLibraryFile`.

**NIT, DeviceActs.swift:20 / 37–38: AGREE.** The early `if step == "memory"` return runs for every "memory" step, so the switch's `case "memory"` can never execute.

**NIT, SharedKeyAndRelink.swift:69: AGREE.**
- The comment says "PROVISIONAL P-U3-7".
- The U3 record numbers skip-and-report as **P-U3-5** (vx-305-castle-core.md:1000–1002); P-U3-7 is no-repair-while-in-flight (lines 1006–1009).
- Her sitting's Q&A (line 1433) also calls it "P-U3-5's shape".

**NIT, DeviceSection.swift:420 (`.first` over the standing old-shared records): AGREE, with a refinement.**
- It does depend on section storage order. It is deterministic per record bytes, so it is not a convergence bug.
- But it is more than taste. The retirement deletes by the RECORDED id first (CommonSteps.swift ~566–571: `recorded?.id ?? readable?.id`), and delete-on-sight needs `facts.appleKeys.oldSharedID == shared.id` (Assess.swift:410). So inheriting another Apple account's standing id makes this Mac's retirement miss its own old shared key. That is P-U4-1's ratified known-leftover class, hygiene under her P-U4-14 severity frame.
- "Highest version or smallest id" makes the pick deterministic but no more correct. The principled pick prefers the record whose id matches the old shared key this Mac can read (known at `unlock`, not inside the pure `takingOver`), then a deterministic tie-break.
- Her P-U4-9 wording ("then any standing record") permits either.

**NIT, Assess.swift:148–167 (the Touch ID line before unlock): AGREE.**
- `fingerprint = unlocked?.currentFingerprint ?? slotFingerprintHint`.
- The hint's documented sources are the slot's key file, else the memory (Facts.swift:240–243), and both are gone in that scenario. So `itemExists` is false and the line says `.notSetUpForThisLibrary`.
- Meanwhile `LobbyRoads.custodyItems` (Assess.swift:202) still lists the Touch ID item, and the lobby opens through it.
- The suggested phase-2 reading (the button exists whenever a custody item exists) is her verbatim VX-310 pick, "the button whenever a Touch ID item exists" (design §1 / line 135).

### Misreadings of a §8 ruling

None found. One adjacency for the reviewer to weigh:
- P-U4-10 ("the Standard-tamper ceiling stands … the newest-copy offer DROPPED") does not cover the Use-Castle (Standard-library) variant. Its limit lasts only "until a key is minted past it", and minting is exactly what this state blocks.
- The proposed fix is an automatic repair of the live key file, extending U4's existing both-deleted repair. It is not the dropped unlock-screen newest-copy offer, so it does not reopen her "lets drop the healthy copy deal" ruling. It should still be worded so it isn't read that way.

### Files
- Pin file (untracked): `<home>/dev/variorum-vx-305/Tests/VariorumCoreTests/Protection/Scenario/LadderRound1Pins.swift`. Its six tests:
  - `aPlanlessRollBackWithNoMirrorLeavesAnotherKeysFileLive` (the reviewer's scenario)
  - `aPlantedPlanInsteadOfAReplayedOne`
  - `theUseCastleVariant`
  - `anEarlierKeysFileReplayedWithTheMemoryGone`
  - `aCopyRestoredAfterAPassphraseChange`
  - `theKeyFileAndTheMemoryItemBothDeletedWithNoBackup`
- Code traced: PlanRunner.swift · Executor.swift · ExecutorRepairs.swift · Assess.swift · DeviceActs.swift · SharedKeyAndRelink.swift · CommonSteps.swift · DeviceSection.swift (all under `Sources/VariorumCore/Protection/`)
- The report answered: `notes/plans/vx-305-ladder-round-1.md`
