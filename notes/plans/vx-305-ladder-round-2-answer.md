# VX-305 ladder round 2 — the implementer's agree/dispute (committed unedited; the cross-model flow's second step)

*(A fresh Opus implementer answering `vx-305-ladder-round-2.md`. No fixes applied, nothing committed by the implementer; its one artifact is the untracked pin file named below — GREEN on today's tree, so it does not break the suite. The reviewer's final call follows this document.)*

**First, what I did not do:** I applied no fixes, made no commits and pushed nothing. The tree is HEAD plus one untracked file, the pin: `<home>/dev/variorum-vx-305/Tests/VariorumCoreTests/Protection/Scenario/LadderRound2Pins.swift` (suite `LadderRound2AbsentArmPin`). Its header says "UNTRACKED"; reword that when it is committed. Every temporary change was reverted, and `git status` confirms it:
- the three NEW-1 source files went back to `59d5d9289` and were restored with `git checkout HEAD --`;
- a one-line flip of the absent arm was made and restored;
- a narrowed copy of `Generator.swift` was made and restored;
- a scratch probe file was written and deleted.

On the restored tree, the new pin, the NEW-1 pins and the mutation pins pass: `✔ Test run with 25 tests in 3 suites passed`.

## The MINOR: AGREE, with one correction to the hazard's symptom

**Pin:** `aLibraryFileReplayedWithItsKeyFileDeletedLosesToItsMemory()`. It follows the probe's shape:
1. Today's Castle library with gate `.touchID`, then launch.
2. Use Standard, then Use Castle with `.touchID`.
3. It asserts the oldest captured slot is this library's, under another key, and that the memory's mirror holds that key in its history.
4. `.tamperSequence("macA", [.deleteKeyFile, .replayLibraryFile])`, then `.settle`.
5. It asserts the slot is under the remembered key, mode Castle, at the memory's epoch. The memory's key file is live with no Apple wrap, the memory is not overwritten, the mirror-road log line is present, and every promise is kept.

**Today's tree (HEAD), verbatim:**
```
✔ Test aLibraryFileReplayedWithItsKeyFileDeletedLosesToItsMemory() passed after 0.082 seconds.
✔ Test run with 1 test in 1 suite passed after 0.083 seconds.
```

**Assess.swift, ExecutorRepairs.swift and PlanRunner.swift at `59d5d9289`, verbatim:**
```
✘ … recorded an issue at LadderRound2Pins.swift:51:9: Expectation failed: slot.fingerprint == remembered.currentFingerprint
  ↳ slot.fingerprint → "4a2ec921282d968e"   remembered.currentFingerprint → "4d1035aa4f3c443b"
✘ … :52:9: Expectation failed: slot.record?.keyEpoch == remembered.keyEpoch   (→ 1 vs 3)
✘ … :53:9: Expectation failed: world.liveKeyFile(world.macA)?.fingerprint == remembered.currentFingerprint   (→ "4a2ec921282d968e")
✘ … :55:9: Expectation failed: world.macA.library?.memory?.currentFingerprint == remembered.currentFingerprint   (→ "4a2ec921282d968e")
✘ … :56:9: Expectation failed: world.macA.logLines.contains { … "the memory's own key file restored from its mirror — the library file came back alone" }
✘ Test aLibraryFileReplayedWithItsKeyFileDeletedLosesToItsMemory() failed after 0.083 seconds with 5 issues.
✘ Test run with 1 test in 1 suite failed after 0.083 seconds with 5 issues.
```
It is red on the old tree, so the pin is real.

**The pin is specific to the absent arm.** I changed only `?? true` to `?? false` in `olderLibraryFileProof` (Assess.swift:237), then ran the pins and restored the file.
- The new pin went red with the same 5 issues.
- NEW-1's existing pin `aLoneOlderFileOfALibrarySetAsideByALandingLosesToItsMemory` stayed green in both forms.
- The whole protection set with that flip: `✘ Test run with 433 tests in 71 suites failed … with 5 issues`. The only failures are the new pin's.

So the arm was live code that no committed test exercised. The reviewer's claim is confirmed.

**A notable point: on the old tree, `expectPromisesKept` stayed green.** The promises cannot see this case when the replayed file is Castle-born.
- On the old tree, the memory verified, because the memory's key was in hand through the Touch ID press.
- The old proof needed the live file, so no re-key was owed. The always-runs block then owed `refreshMemory`, which overwrote the verified, newer memory with the older file's facts.
- Promise 10 watches mode, account, custody and gate style; it never looks at the key or the epoch. Nothing it watches moved.
- Only the pin's own assertions catch this. The soak could catch a regression of this arm only when the replayed file is Standard-era, because then the mode drops and promise 10 fires.

**(b) the missing mutation-pin twin: AGREE.** I probed this scenario wrapped in `mutationPin(off: libraryFileLosesToMemory = false)`.
- Guard on: the slot ends at 4d1035aa, the remembered key.
- Guard off: the slot ends at 4a2ec921, the older key. The scenario's own check is false, but the violation list is `[]`.

The twin bites, but only through its own check, which fits the blindness above.

**(a) the comment: AGREE that it is stale; the honest reason for excluding `.deleteKeyFile` is narrower than the reviewer's.** The comment dates from round 1, when the proof really was the live key file, so it was true then and NEW-1 made it wrong.

I probed Always ask (Castle, then Use Standard, then Use Castle, then the group), with the current key's backup pairs present and removed, and with both replay forms:
- **Current key's pair present:** the memory wins in both forms, with no violation. This is the normal state, because Use Castle's own `backup` step always writes that pair.
- **Pairs removed, Castle-era file replayed:** the older file wins silently and no promise fires.
- **Pairs removed, Standard-era file replayed:** promise 10 fires, `after deleteKeyFile + replayLibraryFile: the mode is standard`.

The reviewer's predicted symptom, promise 1's "no verified memory item", does not occur. When the memory can't be verified, `refreshMemory` is owed, and the launch's repairs rewrite the memory under the opened older key before any promise runs.

The mechanism: the memory verifies only with a key the lobby put in hand. On Always ask, the memory key's only roads on this Mac are the live key file and its catalogued frozen copies. The memory's own mirror is not a lobby road in phase 1. That is exactly P-U4-13 (b), which her ruling sends to phase 2 ("the lobby's memory-mirror road").

So the honest reason for `.deleteKeyFile` is this: where the live key file is the memory key's only road on this Mac, deleting it leaves the memory unverifiable. That loses the memory home in effect, as `.editSealedSetting` (already in that set) does, until phase 2's ruled road lands. The reason for `.replayKeyFile` is as the reviewer says: P-U4-12's whole-pair shape, which P-U4-6's ratification explicitly sets apart.

## Narrow or keep `rollsBackBothHomes`: KEEP; rewrite the comment and hand the narrowing forward to phase 2

1. **I found no generator road to the hazard's precondition.** The precondition is: Always ask, no catalogued frozen copy of the current key, and a surviving road to an older key of the same library.
   - Every act that makes a new key ends with `backup`, written to the container and the far folder. That covers EnterCastle, LeaveCastle, ReplaceAllKeys, Follow, the two account acts and the migration.
   - The acts that make a key with no pair are land, openOlderLibrary and createLibrary. They have no older file of the same library to replay. A replay there is another library's file, which is NEW-1's other-library road; there the live file never gave the memory's key, so deleting it changes nothing.
   - The catalog is only the container and the far folder; Time Machine snapshots are not in it.
   - A container wipe removes the older keys' roads too, so the library just doesn't open — the same result a single `.deleteKeyFile` already gives.
2. **A narrowed slice ran green (temporary, reverted).** Seeds 1–2 × 250, soak shape: `PROTECTION GENERATOR: 2 seeds × 250 sequences, 500 sequences, 22618 steps … 235.3 s (SOAK)`, with 208 tamper groups, 9 of which drew the pair. That is weak evidence on its own.
3. **The deciding reason: round 2 is the final round.**
   - Narrowing shifts every seed's stream and adds a new composition to the go/no-go soak that no later ladder round will read.
   - Its only failure I could construct is a promise-10 false positive on P-U4-13 (b), a class already ruled to phase 2.
   - Even narrowed, the soak would catch an arm regression only in the Standard-era form.
   - The deterministic pin covers the arm and is specific to it.

Recommendation: rewrite the comment to the two reasons above, and narrow the exclusion when phase 2's mirror road lands.

## The four NITs

- **NIT 1, `setAsideKeyFiles` write-only: AGREE.** One precision: the dict is read once, by its own name-collision check (ExecutorWorld.swift:472); nothing else reads it. The U3 harness has no catalog view at all: `catalogKeyFiles` is a lookup by id that tests fill in, so a set-aside file can't be read by catalog id there. In the scenario world it is catalogued as `.setAside`. No current test reads set-aside files. I'd take the doc comment, or fold the file into `catalogKeyFiles` under the id the real catalog would give it.
- **NIT 2, the other two restores overwrite a stray file in place: AGREE.** Traced both sites:
  - PlanRunner.swift:336–339 writes over any non-current live file. `outgoingKeyFile` requires the current key's fingerprint and the same library.
  - `restoreKeyFileFromMirror` (ExecutorRepairs.swift:188–199) writes over the stray the same way.
  - The stray is either an act's new-key file from an act that never swapped (a never-used key whose history and anchor are already in the restored file), or an earlier genuine file an adversary replayed (its keys are in the current key's history or anchor). Nothing is lost.
  - Adopting the set-aside adds a counted write: the world's `setAsideLiveKeyFile` calls `wrote(...)`. The mirror restore can run inside an act's crash window (`act()` runs the repairs), so crash-point numbering would shift. In the final round I'd take the doc-comment option; either works.
- **NIT 3, `beforeRollback` over-records: AGREE, and the cause is wider than stated.**
  - Every action that records an entry is itself counted as deliberate for promise 4 on that device (`deliberate` covers `.tamper`, `.tamperSequence`, `.timeMachineRollback` and `.deleteContainerAndOpenOldCopy`), so an entry is never used up at its own step.
  - The tamper step relaunches the device inside the step (Generator.swift:80–85), and promise 10 judges the effect there.
  - So an entry goes stale after any tamper-borne replay whose library opened at that relaunch: one that was skipped, one that applied and lost (my pin's own state leaves `beforeRollback[macA] = (castle, nil)`), or one that applied and won.
  - The stale entry waits until a later non-deliberate step lands on exactly that mode and account, then excuses it once.
  - The reviewer's fix narrows this. The complete fix: clear `beforeRollback[name]` at the end of a tamper step when the relaunch opened the library, and keep it when it didn't, because the later open is the legitimate user of the entry. Test-world only.
- **NIT 4 (SPECULATIVE), "owed" isn't "runnable": AGREE to record it and move on. There is no hole; traced:**
  - `restoreKeyFileFromMirror`: the executor's precondition matches assess's exactly, and it has no other way to skip.
  - `restoreKeyFileFromCopy`: same filter (fingerprint and library ID); the only extra skip is the set-aside finding no free name in 60 tries.
  - `rekeyOlderLibraryFile` has the one real difference the reviewer names. Assess's memory may have verified through `reach`, which also reads silent custody items directly (Executor.swift:301–310), while the executor needs the key in `[library.key] + keysInHand`.
  - That difference cannot pass silently. When assess owes the re-key it returns early (Assess.swift:267), so no `refreshMemory` is owed and the memory keeps naming the newer key. Promise 1's first check then fires: "no verified memory item" if the memory verified only through keys in hand (the checker's `reach` has none), or "the memory names X#e, the record Y#e′" if it verified through a silent item (the checker reads those too).
  - In the world, `walkLobby` puts every silent item's key in `also`, so the difference can't be reached here.
  - Hand-forward for phase 2's lobby: pass every key it reads, silent items included, in `alsoInHand`, or have the re-key read its key through the same `reach`.

## Readings of the §8 rulings

- **MINOR (a):** the `.replayKeyFile` reason matches P-U4-12 and P-U4-6's carve-out ("the deliberate whole-pair restore keeps its own road"). It is correct.
- **The `.deleteKeyFile` hazard:** the reviewer doesn't name P-U4-13 (b). The hazard is that ruled phase-2 class (her ruling: the memory-mirror road is a vx-306 deliverable, and phase 1 keeps the state). This is a missing anchor rather than a misreading, and it is what decides keep over narrow.
- **Observation 5's "her P-U4-1 hygiene frame":** P-U4-1 rules that a delete which never reached its item is a known leftover. Observation 5 is the opposite: it deletes another library's quiet road. The reviewer's "availability-only" conclusion still holds on its own trace, but the hand-forward line should say that on its own merits rather than cite P-U4-1. Low weight.
