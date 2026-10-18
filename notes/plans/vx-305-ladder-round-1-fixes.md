# VX-305 ladder round 1 — the fixes (the Opus implementer, applying the reviewer's final call)

**Not done, first:** (1) **a fully green generator slice** — two PRE-EXISTING classes the compound generator's
shifted random stream now reaches (NEW-1, promise 3; **NEW-2, promise 13 with no tamper in it**) fail 3 of 750
sequences on seeds 1–3 × 250; both reproduce on the round's base `e4ee1f083` with only the actions that existed there,
neither is one of the six findings, so neither is fixed (a second unit — for the orchestrator/reviewer, §"Found by the
generator, outside the round"). The go/no-go soak (gate 1) will meet them until they're triaged. (2) The final call's
optional `.crash(...)` wrap of a tamper group — not built, with the reason in §1(c). (3) P-R1-1's door (the copy-less
rebuild) — recorded, not built, as ruled. (4) The phase plan's §9 dispositions entry — left to the orchestrator.

The binding text is `notes/plans/vx-305-ladder-round-1-final-call.md` (all six findings CONFIRMED, FINDER-FIXES
none). The pins the implementer's answer ran red are `Tests/VariorumCoreTests/Protection/Scenario/LadderRound1Pins.swift`
(the MAJOR's scenarios — flipped to fixed-scenario assertions and joining the tree with the MAJOR's fix) and
`Tests/VariorumCoreTests/Protection/LadderRound1UnitPins.swift` (the model-level pins).

## LIVE STATUS (flipped in the same commit as each piece; PENDING = unverified)

- **2 · MINOR** — assess reads the live key file only when it is the current key's: **DONE** (`1dfbb85f8`).
- **1 · MAJOR** — the stray-file wedge: (a) both gates widened, (b) the stray file set aside, (d) the pins flipped —
  **DONE** (`95fbf9349`); (c) promise 1's clause + the compound-tamper action — **DONE** (`3ac5e5a95`).
- **TWO PRE-EXISTING CLASSES the compound generator's shifted stream surfaced — NOT this round's, NOT fixed, for the
  orchestrator/reviewer (§"Found by the generator, outside the round" below):** NEW-1 (promise 3, a different
  library's file swapped into the slot) and **NEW-2 (promise 13, no tamper at all — a landing, Use Castle, Use
  Standard)**. Both reproduce on the round's base `e4ee1f083`. They keep a generator slice from running fully green.
- **5 · NIT** — `takingOver`'s standing old-shared pick: **DONE** (`5c36da3d8`).
- **6 · NIT** — the lobby's Touch ID line before unlock: **DONE** (`5c36da3d8`).
- **3 · NIT** — DeviceActs' dead "memory" arm: **DONE** (`5c36da3d8`).
- **4 · NIT** — the P-U3-7 → P-U3-5 comment: **DONE** (`5c36da3d8`).
- The runs: **DONE** (§"The runs at the end" — Debug 429/69 green; `swift build -c release` green; the protection
  set under `-c release` 368/64 green; the generator slice: 750 sequences, 312 tamper groups, the only failures the two
  pre-existing classes).

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

## 1(c) · the checker and the generator — the class made soak-visible

**Promise 1 (Known) gains the live-key-file agreement clause** (`Promises.swift`, `known(_:)`): with the device open
and nothing in flight, when the live place's format-3 file is not the record's current key's AND no repair that brings
the current key's own file back is owed (`restoreKeyFileFromCopy`, `restoreKeyFileFromMirror`, and — added, since it
is the third repair that brings the record and the live file into agreement — `rekeyOlderLibraryFile`), it is a
violation. Keyed on "no repair owed", so a repair pending its run passes and a state no repair can leave fails. Stated
residue exempted: **P-R1-1** — no catalogued frozen format-3 copy of the current key's file (same library) exists.

**The generator gains tamper composition** — `Action.tamperSequence(String, [Tamper])`, kind 46, weight 1: two (70%)
or three distinct tampers applied in ONE closed window. `SWorld.step` brackets a group exactly as a single tamper: the
seed-9 pre-launch settle ONCE before the group (her pending resume settles before any tamper takes a lock), the
posture captured before it, `truth.beforeRollback` set when the group replays the library or key file, ONE relaunch
after, and the promise-10 check over the group (`sealed(_:before:tampers:)`, the single-tamper form a one-element
call). A tamper in the group that finds nothing to act on is skipped and said; the group is refused only when none
applied. `deliberate` counts the group as files replaced from outside, as it does a single tamper.
**Two recorded choices:**
- **The group never takes the stated limit's shape:** `replayLibraryFile` never composes with a tamper on this Mac's
  memory item (`deleteMemoryItem`, `editSealedSetting`, `replayMemory`, `deleteKeyFileAndMemory`) or on the live key
  file (`replayKeyFile`, `deleteKeyFile`), and `.replayBothHomes` is never drawn into a group — rolling the library
  file back with what it would lose to, or with its own key file, IS §3.6's stated limit, already modelled by
  `.replayBothHomes` with its truth bookkeeping (`ScenarioGenerator.rollsBackBothHomes`).
- **No `.crash(...)` wrap of a group** (the final call's "may"): a group's edits are the adversary's file and item
  writes, not an act's, so "a crash after n writes" of one means nothing; and the seed-9 pre-settle the final call
  keeps settles any crashed act before a group, so a group can't land inside a crash window here without dropping that
  lesson. The crash-window road stays the fixed scenarios' (`aPlanlessRollBackWithNoMirrorGetsTheCurrentKeysFileBack`,
  `aPlantedPlanInsteadOfAReplayedOne`); the generator reaches the SAME wedge state by its no-crash roads (below).
- The new weight shifts every seed's stream: **the U4 soak table's step counts are of the tree before this commit**
  and no longer reproduce step for step (the go/no-go soak is re-run on the final tree).

**THE SOAK-VISIBILITY PROOF** (a temporary probe, not committed: generator sequences, soak shape ≤ 60 steps, stopping
at the first sequence whose FIRST violation is the new clause with a tamper group in it):
- **On the tree before the fix** (the two gate files checked out from `1dfbb85f8`, the checker and generator new):
  `FOUND at seed 1 sequence 96 (world seed 1000099, start VX-209's victim (a Castle library dropped to Standard by a
  copy)), after 97 sequences / 4515 steps; tamper groups so far 51 (done 50)` — `promise 1 on macB: the live key file
  is d30d1b73, the record's key e79f11e3 — and no repair brings its own file back`, minimal sequence (3 steps):
  `createLibrary("macB", secrets: false)`, `useCastle("macB", .touchID, newWords: false)`,
  `tamperSequence("macB", [plantAppleWrap, replayKeyFile, replayMemory])`. One earlier first-violation of the same
  clause came with NO group — seed 1 sequence 37, minimal `useStandard("macA")`, `tamper("macA", replayLibraryFile)`:
  **the wedge was reachable by ONE tamper** (a library file replayed after a leave — the leave's new key takes no
  history, so `libraryFileLosesToMemory` can't verify; P-U4-6's "a file only the ANCHOR reaches stays the replayed
  record") — the reviewer's "two tampers" annotation understated the reach; the existing generator must have met it
  and no promise saw it.
- **On the fixed tree**, seeds 1–3 × 250 sequences: `750 sequences, 33728 steps, 3 failing; tamper groups 312 (done
  308)` — both roads above GREEN; the 3 failing sequences are the two pre-existing classes below, nothing else.
- **Pinned** (`LadderRound1MajorPin`): `aTamperGroupReachesTheWedge` (the compound road's exact minimal sequence,
  through `step`) and `aLibraryFileReplayedAfterALeave` (the one-tamper road). Red on the pre-fix gates — `promise 1 on
  macB: the live key file is d30d1b73, the record's key e79f11e3 — and no repair brings its own file back` /
  `promise 1 on macA: the live key file is 66671aa7, the record's key 06a3e65a — …` (`✘ Test run with 2 tests in 1
  suite failed … with 5 issues`); green restored. Promise 1's clause is therefore not blind-green: it fires on the old
  tree and passes the fixed one.

**The protection set after:** `✔ Test run with 424 tests in 67 suites passed after 14.427 seconds.` (the everyday
generator loop — 2 seeds × 8 sequences — now drawing groups, green).

## Found by the generator, outside the round — NOT fixed (for the orchestrator / the round-2 reviewer)

Both reproduce on the round's base commit `e4ee1f083` with ONLY the actions that existed there (run in a scratch
worktree), so neither is caused by this round; the U4 soak's stream never reached them, the shifted one does. Neither
is one of the six findings, so neither is fixed here (a second unit).

- **NEW-1 · promise 3 — a different library's file swapped into the slot.** Fixed tree, seed 1 sequence 54 (world seed
  1000057, start "a phone on an older build beside a synced Castle Mac"), minimal: `createLibrary("macB", secrets:
  true)`, `updateToNewBuild("phone")`, `sendLibrary(from: "phone", to: "macB")`, `crash(useCastle("macB", .alwaysAsk,
  newWords: false), afterWrites: 17)`, `land("macB", .wordsPassphraseMadeNew)`, `tamperSequence("macB", [replayPlan,
  plantPlan, replayLibraryFile])`, `settle` → `promise 3 on macB: no Apple wrap of the current key`. On the base tree
  the SAME violation follows a plain single `.tamper("macB", .replayLibraryFile)` in place of the group. The replayed
  capture is the slot's library from BEFORE the landing (library 99708862, Standard) swapped into a Castle slot
  (091f29c6). The implementer's reading, for the reviewer: `tamperWith` records `truth.tamperedStandard` from the slot
  BEFORE the swap, so a Standard library swapped INTO a Castle slot is held to promise 3 although it is a tampered
  Standard library (P-U4-10's ceiling) — a checker bookkeeping gap, OR the swapped library's own Apple road was retired
  at the landing and nothing re-links it. Not adjudicated here.
- **NEW-2 · promise 13 — NO TAMPER: a landing, then Use Castle, then Use Standard.** Fixed tree, seed 1 sequence 222
  (and once more in seeds 1–3; world seed 1000225, start "a synced Standard account, a device that joined without a
  secret"), minimal (10 steps): `createLibrary("macB", secrets: true)`, `useCastle("macA", .alwaysAsk, newWords:
  true)`, `signIn("macB", account: "8d2d5914-…")`, `answerCorner45("macA", .standard)`, `launch("macB")`,
  `follow("phone", .words)`, `sendLibrary(from: "phone", to: "macB")`, `land("macB", .wordsPassphraseMadeNew)`,
  `useCastle("macB", .alwaysAsk, newWords: true)`, `useStandard("macB")` → `promise 13 on macB: the Apple account or
  the login password reaches b03b0684, a key from before the leave`. Byte-identical violation on the base tree.
  **A security-promise class with no adversary in it — it needs triage before the go/no-go soak** (promise 13: after
  a leave, nothing Apple- or login-reachable opens a key from before it). Not traced further here.

## 5 · NIT — `takingOver`'s standing old-shared pick

**The fix (the final call §5, shaped to stay pure).** A new parameter `keyFileSharedAppleKeyID: String?` (default nil)
threads through `DeviceFacts.thisMacsSection` and `DeviceFacts.takingOver`; `ProtectionExecutor.unlock` passes the
`sharedApple?.keyID` of the key file it already hands the takeover (`ownFile` — the live file, or the plan's carried
outgoing file). The no-predecessor STANDING arm picks the record whose id that shared wrap names — the old shared key
that actually wraps THIS library's key — else the smallest id (deterministic, never the record's storage order). The
retired-record arm above it is untouched. The residue where no record matches stays P-U4-1's ratified known-leftover
class under her P-U4-9 "any standing record" wording — recorded, not chased.

**The pin, red → green.** `TakingOverStandingOldSharedTests` (3 tests). Red-on-old shown with the parameter threaded
but the OLD `.first` pick kept (the only way a new parameter's pin can run on the old logic):
`theRecordWhoseIDWrapsThisLibraryWins` — `Expectation failed: taken.oldSharedKey?.id == "z-this-library"` →
`adopted Optional("a-another-apple-id")`; `noMatchTakesTheSmallestID` — `adopted Optional("z-second")` and `the pick
depends on the record's storage order`; `aRetirementStillWins` green on both (the retired arm's own pin). Green after.

## 6 · NIT — the lobby's Touch ID line before unlock

**The fix (the final call §6 — VX-310's letter).** In `Assess.touchID`, when no fingerprint names the current key
(before unlock with the key file AND the memory item gone — no hint), `itemExists` falls back to "any `.touchid`
custody item in this scope": the button shows, a press verifies itself (a wrong key's item fails honestly into the
passphrase road), and the quiet line saying it isn't set up disappears. Not new product behaviour: her pick read to
its words ("the button whenever a Touch ID item exists"). No existing Touch ID pin's sentence changed — the state is
reachable only with both hint sources gone (every existing Touch ID test green, unchanged).

**The pin, red → green.** `TouchIDLobbyWithNoHintTests` (2 tests). Red before the fix:
`aTouchIDItemWithNoHintShowsTheButton` — `Expectation failed: touchID.button` → `no button with a Touch ID item
present`; `Expectation failed: touchID.quietLine == nil` → `the quiet line said
Optional(VariorumCore.TouchIDQuietLine.notSetUpForThisLibrary)`; `noItemNoButton` green on both (no item, no button,
the line stays). Green after.

**The protection set after NITs 5 and 6 (and 3, 4):** `✔ Test run with 429 tests in 69 suites passed after 13.289
seconds.`

## 3 · NIT — DeviceActs' dead "memory" arm

**The fix.** The unreachable `case "memory"` in `DeviceSettingsProgram.run`'s switch is removed; the early return
stays, its comment now saying it serves BOTH the ordinary flow and the plan-less finish. No pin (dead code) — the
protection set green after.

## 4 · NIT — the P-U3-7 → P-U3-5 comment

**The fix.** `SharedKeyAndRelink.swift`'s library-arm comment now cites **P-U3-5** (the skip-and-report call, the U3
record); P-U3-7 is the no-repair-while-in-flight call. No pin.

## The runs at the end (on the final tree, `5c36da3d8` — every later commit is this record)

- **The protection set, Debug** (every `@Suite` under `Tests/VariorumCoreTests/Protection/`, 69 — the round added
  `LiveKeyFileIsTheCurrentKeysTests`, `LadderRound1MajorPin`, `TakingOverStandingOldSharedTests`,
  `TouchIDLobbyWithNoHintTests`): `✔ Test run with 429 tests in 69 suites passed after 14.566 seconds.` (413 + 16; the
  pins-off mutation suites among them, green — each asserts guarded-green AND unguarded-fail in one test.)
- **Release:** `swift build -c release` — `Build complete! (93.37 sec)`. The compiled subset:
  `swift build -c release --build-tests -Xswiftc -enable-testing` (7:45 wall), then `swift test -c release --skip-build`
  over the same 69 names — `✔ Test run with 368 tests in 64 suites passed after 4.009 seconds.` (429 − 61 DEBUG-only
  = 368; 69 − 5 = 64 — U4's arithmetic, plus this round's 16 tests in 4 suites.)
- **A generator slice with tamper composition** (soak shape ≤ 60 steps; a temporary first-violation probe, not
  committed): seeds 1–3 × 250 — `750 sequences, 33728 steps, 3 failing; tamper groups 312 (done 308); 290.0 s`; the
  three failures are NEW-1 (×1) and NEW-2 (×2), both pre-existing, nothing else. The everyday generator loop inside the
  protection set (2 seeds × 8) is green.
- **Scope:** `git diff --stat df5fa9b43..HEAD` touches only `Sources/VariorumCore/Protection/`,
  `Tests/VariorumCoreTests/Protection/` and this record — zero `Sync/`, `App/`, `Server/`, `Persistence/`, migration
  or `Package.swift` lines; no new dependency.

## For round 2's re-check (the final call's list, answered where it points)

- **The two widened gates agree:** assess owes `restoreKeyFileFromCopy` under exactly the executor's conditions —
  nothing in flight (`runRepairs` skips everything in flight; assess now says so too), no format-3 file of the current
  key in the live place, no current mirror, a catalogued frozen copy of the current key **with the same library ID**
  (assess now filters on it, as the executor verifies it).
- **The set-aside is non-destructive and catalogued:** the leaf never overwrites (false when the name is taken); the
  name is today's set-aside shape, parsed by the one parser as `.setAside`; `expectWedgeRepaired` asserts the stray file
  catalogued `.setAside` in every wedge pin. The mirror and plan restores still overwrite (recorded in §1(b)).
- **Promise 1's clause is keyed on "no repair owed", not blind-green:** red on the pre-fix gates in two generator-found
  roads (`aTamperGroupReachesTheWedge`, `aLibraryFileReplayedAfterALeave`), green on the fixed tree.
- **The compound action keeps the seed-9 pre-settle:** `step` runs ONE pre-launch settle before a group exactly as
  before a single tamper (the bracket is shared code, `tampered`).
- **The MINOR's guard didn't break `libraryFileLosesToMemory`:** the raw live file feeds that arm; its existing pins
  (`aLibraryFileReplayedAloneInCastle`, `aLibraryFileReplayedFromBeforeAJoinChangesNothing`, the
  `libraryFileLosesToMemory` mutation pin) are green in the 429.
- **The `.first` pin is red-on-old:** shown with the parameter threaded and the old pick kept (§5).
- **The Touch ID fallback ripples nowhere:** every existing Touch ID test green, none edited.

## Commits

`1dfbb85f8` (2 · MINOR) · `95fbf9349` (1 · MAJOR (a)(b)(d)) · `3ac5e5a95` (1 · MAJOR (c), and NEW-1/NEW-2 recorded) ·
`5c36da3d8` (the four NITs) · this record's closing commit. Each pushed to `origin/vx-305-castle-core` as it landed.
