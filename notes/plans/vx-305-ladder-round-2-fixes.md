# VX-305 ladder round 2 — the fixes (the Opus implementer, applying the reviewer's final call)

**Not done, first:** (1) **the go/no-go soak** (20 seeds × 1,000, both configurations) is the orchestrator's, on the
final tree; a soak-shape slice ran here instead (§"The runs at the end"). (2) **The closeout's hand-forward list**
(the final call's checklist point 8) is the orchestrator's: it already stands in the phase plan's §9 (`e6c3420ea`),
so this record only points at it. (3) **Nothing outside the final call is built:** no key/epoch-regression promise
clause (§1(d)(ii), a hand-forward), no narrowing of `rollsBackBothHomes` (KEEP, §1(c)), no set-aside at the two
other restores (§3, a comment instead), no code for NIT 5 (record only). (4) Plain `swift build -c release` was not
re-run separately: the `-c release --build-tests` build below compiles the same sources (the two Sources files
changed by comment lines only).

The binding text is `notes/plans/vx-305-ladder-round-2-final-call.md` (all five findings CONFIRMED, FINDER-FIXES
none); the report `notes/plans/vx-305-ladder-round-2.md`; the answer `notes/plans/vx-305-ladder-round-2-answer.md`.
Scope (verified by diff, §"Scope"): `Sources/VariorumCore/Protection/` (comment lines only, two files),
`Tests/VariorumCoreTests/Protection/` and this record.

## LIVE STATUS (flipped in the same commit as each piece; PENDING = unverified)

- **1(a) · MINOR — the absent-arm pin committed as built:** **DONE** (`4d8234068`).
- **1(b) · MINOR — the mutation twin:** **DONE** (`e927333f9`).
- **1(c) · MINOR — `rollsBackBothHomes`'s comment, code unchanged:** **DONE** (`601cd9251` — comment lines only).
- **2 · NIT — ExecutorWorld's set-aside doc comment:** **DONE** (`ecf437996` — comment lines only).
- **3 · NIT — the two restores' deliberate-overwrite sentences:** **DONE** (`43e48d8b1` — comment lines only, the two
  Sources files).
- **4 · NIT — `beforeRollback` cleared after a tamper step whose relaunch opened the library:** **DONE** (`63cf038f1`).
- **5 · NIT (SPECULATIVE) — record only:** **DONE** (§5 below; no code).
- **The runs at the end:** **DONE** — Debug `✔ Test run with 434 tests in 71 suites`; `-c release` `✔ Test run with
  372 tests in 66 suites`; the soak-shape slice seeds 1–3 × 250 green (§"The runs at the end").

## 1 · MINOR — NEW-1's absent arm unpinned; the exclusion's comment stale

**(a) The pin — `LadderRound2AbsentArmPin.aLibraryFileReplayedWithItsKeyFileDeletedLosesToItsMemory()`**
(`Tests/VariorumCoreTests/Protection/Scenario/LadderRound2Pins.swift`, `4d8234068`): committed byte-identical to the
answer's untracked file but for its header's UNTRACKED line, now the provenance line naming this round's four
records. Its proof is the answer's, run then: green on HEAD (`✔ Test run with 1 test in 1 suite passed after 0.083
seconds.`); RED with Assess.swift, ExecutorRepairs.swift and PlanRunner.swift at `59d5d9289` (`✘ Test run with 1 test
in 1 suite failed after 0.083 seconds with 5 issues.` — the slot under `4a2ec921…`, not the remembered `4d1035aa…`;
the record's epoch 1, not 3; the live key file and the memory both `4a2ec921…`; the mirror-road log line absent);
and RED with ONLY the arm's `?? true` flipped to `?? false` while NEW-1's own pin stayed green (the whole protection
set under the flip: `✘ Test run with 433 tests in 71 suites failed … with 5 issues`, every issue the new pin's).
Re-run in the committed tree: `✔ Test run with 1 test in 1 suite passed after 0.079 seconds.`

**(b) The mutation twin — `ScenarioMutationPins.aLibraryFileReplayedWithItsKeyFileDeletedLosesToTheMemory()`**
(`MutationPins.swift`, inside its `#if DEBUG` beside `aLibraryFileReplayedAloneLosesToTheMemory`; `e927333f9`): the
harness's standard single test — the same scenario guarded (its own check holds and every promise is kept) and with
`libraryFileLosesToMemory` off (it must fail). The check is the scenario's own sentence — the slot under the
remembered key at the memory's epoch — since the violation list stays `[]` with the guard off (the blindness the final
call §1(d)(ii) hands forward: promise 10 never watches the key or the epoch, and the replayed file is Castle-born).
The answer's probe of the same shape: guarded slot `4d1035aa` (the remembered key), unguarded `4a2ec921` (the older
one), violations `[]` both ways. **Proof it bites:** green as committed — `✔ Test aLibraryFileReplayedWithItsKeyFileDeletedLosesToTheMemory() passed after 0.144 seconds.`; with its off-switch
neutralized to `{ _ in }` (both runs guarded, a scratch edit restored at once) it fails — `✘ Test
aLibraryFileReplayedWithItsKeyFileDeletedLosesToTheMemory() recorded an issue at MutationPins.swift:368:30:
Expectation failed: failed` (the harness's "with the guard off, the scenario still passed") — `✘ Test run with 1 test
in 1 suite failed after 0.148 seconds with 1 issue.`; restored, the suite `✔ Test run with 22 tests in 1 suite passed
after 11.165 seconds.`

**(c) The comment — `ScenarioGenerator.tamperGroup`'s doc comment** (`Generator.swift`, `601cd9251`): rewritten to
the final call §1(c)'s wording, every clause kept — `.replayBothHomes` never joins a group (its own stated-limit
bookkeeping), and `replayLibraryFile` never composes with: a tamper on this Mac's MEMORY home (`deleteMemoryItem`,
`editSealedSetting`, `replayMemory`, `deleteKeyFileAndMemory` — §3.6's stated limit, modelled by `.replayBothHomes`);
`replayKeyFile` (the whole-pair shape her P-U4-12 ruling keeps as a deliberate restore's road, P-U4-6's carve-out
quoted, which promise 10 would otherwise read as a violation); `deleteKeyFile` (the memory key's only road here —
Always ask, no frozen pair — deleting it leaves the memory unverifiable and the older file wins by the two-homes
rule: P-U4-13 (b)'s ruled phase-2 class, the lobby's memory-mirror road a vx-306 deliverable; NARROW when that road
lands; the absent arm pinned deterministically by `LadderRound2AbsentArmPin`). **The CODE of `rollsBackBothHomes` is
unchanged** — KEEP, not narrow: the commit's diff is `///` lines only (checked: no non-comment line added or removed).
The slice below runs the very same stream as the triage's (33,684 steps on seeds 1–3 × 250 both times).

**(d) The hand-forwards this finding feeds** (the vx-306 narrowing; the key/epoch-regression checker reading with
its exemptions) are on the closeout list in the phase plan's §9 (`e6c3420ea`) — not code this round.

## 2 · NIT — the U3 harness's `setAsideKeyFiles` sink

A doc comment on `ExecutorWorld.setAsideLiveKeyFile` (`ecf437996`): the move is never a delete and refuses an existing
name, but this U3 harness keeps set-aside files OUT of its catalog view — it has none (`catalogKeyFiles` is a
test-filled lookup by id), so a set-aside file isn't readable there by catalog id; the scenario world
(`DeviceLeaves`) models that half (the file stays in the container, catalogued `.setAside`) and its pins assert it.
No behavior change (the diff is `///` lines only). No pin — a fake-fidelity note.

## 3 · NIT — the mirror and plan-runner restores overwrite a stray in place

One sentence at each site (`43e48d8b1`), comment lines only: `PlanRunner.settle`'s no-identity restore (the plan's
outgoing file written over the stray) and `restoreKeyFileFromMirror` — the overwrite is deliberate, the stray being a
crashed (never-swapped) act's new-key file or a replayed genuine one whose keys the restored file's (the mirror's)
history or anchor already holds; the copy repair's set-aside is the belt. No behavior change and no new counted
write (the set-aside would add one inside an act's crash window — the final call's reason for the comment option).
Diff: `ExecutorRepairs.swift | 5 +++++`, `PlanRunner.swift | 6 +++++-` — the one removed line is the old comment
line "`// key's own file.`", re-wrapped.

## 4 · NIT — `beforeRollback` over-recorded

`SWorld.step` (`Generator.swift`, `63cf038f1`): the tamper bracket's relaunch now notes when it OPENED the library,
and at the end of the step (after `checkPromises` and `noSilentChange`) that device's `truth.beforeRollback` entry is
cleared — its replay's effect landed and was judged inside the deliberate step (promise 10 there; promise 4 counts
the step deliberate), so the entry was spent whether the replay skipped, lost to the memory or won. KEPT when the
relaunch didn't open: the later open is that entry's one legitimate consumer. A crash-wrapped single tamper (the
generator may wrap kind 43) never enters the bracket and keeps its entry, as before. Test world only; checker
bookkeeping — no action drawn and no write counted differently (the slice's step count matches the triage's exactly).
**The mechanism, probed (a scratch test, deleted):** the absent-arm scenario's group step, the replay applied and
lost to the memory — before the fix `beforeRollback[macA] = Optional((mode: castle, account: nil))` stays stale after
the step; after it, `nil`. No pin owed (the final call §4: a checker leniency no failing-on-old test pins). The
protection set right after: `✔ Test run with 434 tests in 71 suites passed after 14.974 seconds.`

## 5 · NIT (SPECULATIVE) — "owed" isn't "runnable": traced closed, record only

No code. The answer's trace, accepted by the final call: `restoreKeyFileFromMirror`'s and `restoreKeyFileFromCopy`'s
executor preconditions match assess's (the copy's only extra skip is a set-aside finding no free name in 60 epochs);
`rekeyOlderLibraryFile`'s one divergence (the key needed in `[library.key] + keysInHand`, while assess's memory may
verify through the wider `reach`, which also reads silent items) cannot pass silently — assess's early return
suppresses `refreshMemory`, so the memory keeps naming the newer key and promise 1 fires one of its first two arms —
and the world's `walkLobby` already puts every silent item's key in `also`. Promise 1's clause stays keyed on "owed".
The phase-2 lobby line (`alsoInHand` / the same `reach`) is on the closeout list (§9, `e6c3420ea`).

## The runs at the end (on `63cf038f1` — the final code; this record's commit follows)

- **The protection set, Debug** (every `@Suite` under `Tests/VariorumCoreTests/Protection/`, 71 — collected by
  `grep -A3 '^@Suite'`, the filter their names joined): `✔ Test run with 434 tests in 71 suites passed after 14.974
  seconds.` (432 + the absent-arm pin + the mutation twin; the everyday generator loop among them.)
- **The generator, soak shape** (`PROTECTION_SOAK=1 PROTECTION_SOAK_SEQUENCES=250 PROTECTION_SOAK_SEEDS=3`):
  `PROTECTION GENERATOR: 3 seeds × 250 sequences, 750 sequences, 33684 steps, max 60 steps, 264.8 s (SOAK)` —
  `✔ Test seededSequencesKeepEveryPromise() passed after 264.760 seconds.`; `tamperSequence: done 306, refused 4,
  crashed 0`. (33,684 steps — the triage's seeds 1–3 slice to the step: nothing this round shifts the stream.)
- **Release, re-run** (two Sources files changed, comments only): `swift build -c release --build-tests -Xswiftc
  -enable-testing` — `Build complete! (445.31 sec)` (7:27 wall); then `swift test -c release --skip-build` over the
  same 71 names — `✔ Test run with 372 tests in 66 suites passed after 3.929 seconds.` (434 − 62 DEBUG-only = 372 —
  the twin joins the DEBUG-only mutation suite; 71 − 5 = 66.)

## Scope

`git diff --stat e6c3420ea..HEAD` before this record's commit (7 files, +157/−7):
`Sources/VariorumCore/Protection/Executor/ExecutorRepairs.swift` and `PlanRunner.swift` (comment lines only — checked:
no non-comment line added or removed), `Tests/VariorumCoreTests/Protection/Executor/ExecutorWorld.swift` (a doc
comment), `Tests/VariorumCoreTests/Protection/Scenario/` (`LadderRound2Pins.swift` new, `MutationPins.swift`,
`Generator.swift`) and this record — zero `Sync/`, `App/`, `Server/`, `Persistence/`, migration or `Package.swift`
lines; no new dependency. The scratch probes (the answer's Always-ask probe, the twin probe, the NIT 3 probe) were
deleted, never committed.

## Commits

`4d8234068` (1(a): the pin; this record opens) · `e927333f9` (1(b): the mutation twin) · `601cd9251` (1(c): the
comment) · `ecf437996` (NIT 1) · `43e48d8b1` (NIT 2) · `63cf038f1` (NIT 3) · this record's closing commit. Each pushed
to `origin/vx-305-castle-core` as it landed.
