# VX-305 ladder round 1 — the two pre-existing generator finds (NEW-1, NEW-2): trace, classify, pin, fix

**Not done, first:** (filled at close — PENDING.)

The brief: the round-1 fixes record's §"Found by the generator, outside the round"
(`notes/plans/vx-305-ladder-round-1-fixes.md`) carries both minimal sequences; both reproduce on the round's base
`e4ee1f083`. One implementer session (Opus), headless (`swift build` / `swift test`), scope
`Sources/VariorumCore/Protection/` + `Tests/VariorumCoreTests/Protection/` + this record.

## LIVE STATUS (flipped in the same commit as each piece; PENDING = unverified)

- **NEW-2 (promise 13, no tamper) — the priority:** traced; classified **a CHECKER bug** (no model change); the pin
  `LadderRound1NewFindsPins.aSentPairsHistoryIsTheSendersOwnAfterALeave` RED on the tree before the fix, GREEN after,
  RED again with the fix stashed — **DONE** (this commit). The protection set after: `✔ Test run with 430 tests in 70
  suites passed after 14.178 seconds.`
- **NEW-1 (promise 3, a replayed pre-landing capture):** traced; classified **a MODEL bug** — P-U4-6's "memory wins"
  failed twice over (the settle's roll back of a landing act the outgoing library's memory still named wrote the older
  file's facts over the memory FIRST; and the memory-wins arm could verify only through the live place, which held the
  landed library's file); the pin `LadderRound1NewFindsPins.aLoneOlderFileOfALibrarySetAsideByALandingLosesToItsMemory`
  (both forms) RED before, GREEN after, RED with the fix stashed whole AND with either link alone stashed — **DONE**
  (this commit). The protection set after: `✔ Test run with 431 tests in 70 suites passed after 13.178 seconds.`
- **NEW-2's second road** (the slice re-run on `69336aa21` met sequence 222 again by a 17-step road — the same class, the
  sender's pair in a Time Machine snapshot after a same-day send overwrote its folder): traced; the world exemption now
  reads the sent pair by identity; the pin `aSentPairsSnapshotIsTheSendersOwnToo` RED before, GREEN after, RED with the
  fix stashed — **DONE** (this commit). The protection set after: `✔ Test run with 432 tests in 70 suites passed after
  12.768 seconds.`
- The runs at the end (the generator slice again, the protection set in Debug, `swift build -c release`) — PENDING.

## NEW-2 — promise 13 with no tamper: a CHECKER bug

**The sequence** (start "a synced Standard account, a device that joined without a secret", world seed 1000225, account
`8d2d5914-…`): `createLibrary(macB, secrets)` · `useCastle(macA, alwaysAsk, newWords)` · `signIn(macB, account)` ·
`answerCorner45(macA, .standard)` · `launch(macB)` · `follow(phone, .words)` · `sendLibrary(phone → macB)` ·
`land(macB, .wordsPassphraseMadeNew)` · `useCastle(macB, alwaysAsk, newWords)` · `useStandard(macB)` →
`promise 13 on macB: the Apple account or the login password reaches b03b0684, a key from before the leave`.

**The traced mechanism, step by step** (a probe printing the slot, the family tree, every key file on macB and the
attacker's reach after each step):
1. macA's Use Castle then her corner-45 answer (Use Standard) take the ACCOUNT into Castle and back out: a new master
   twice. The phone (silently joined, Standard, never in Castle) now owes a follow.
2. `follow(phone, .words)`: the phone first migrates (record, its own Apple key `07c7107e`, a backup pair under
   `b03b0684` with that Apple wrap), then follows **keys replaced within Standard** (§3.9: "Keys replaced, same mode:
   the history grows") — a new key `eb4a5f35` whose key file carries the phone's own Apple wrap and, in its HISTORY,
   `b03b0684`. Both keys are Standard-born on the phone; neither was ever Castle's.
3. `sendLibrary(phone → macB)`: the pair (`eb4a5f35`, Standard, the phone's live key file — Apple wrap under
   `07c7107e`, history `b03b0684`) lands in macB's container in the hand-off folder `Variorum Library — 2026-01-13/`.
4. `land(macB, .wordsPassphraseMadeNew)`: a different library — a fresh key `7f6f96e0` with an EMPTY history (§3.4),
   held (synced, no Apple wrap). The landed record's family tree is the copy's own facts (§3.6 — "a copy carries only
   the library's own facts — its mode, account and family tree"), so it reads `[7f6f96e0, b03b0684, eb4a5f35]`: the
   sender's keys ride it (the landing's own-line seed, as the closer's seed-2/661 note says). The sent pair is never
   written (§3.7, "keeps its own locks").
5. `useCastle(macB)`: the account enters Castle (rotation); `a40a2585` takes `7f6f96e0` into its history; the old
   shared key is retired; no Apple key of macB's own existed for the held landing.
6. `useStandard(macB)`: the anchor first, then `d681e3ea` (empty history) under macB's fresh own Apple key `d518ee3f`.
   The world records `keptByLeave[macB]` = the before-record's family tree = `{7f6f96e0, eb4a5f35, a40a2585, b03b0684}`.

**Which road reaches `b03b0684`:** the attacker on macB (the login password + Apple account 1's iCloud Keychain) holds
`07c7107e` — the PHONE's own Apple key, alive because the phone never followed the account into Castle (§3.1 rule 2:
"after that device follows") — so the hand-off pair's key file opens to `eb4a5f35` and, through its history, to
`b03b0684`. Measured: reach over every key file on macB = `{b03b0684, bef81d01, d681e3ea, eb4a5f35}`; the same reach with
the hand-off folder's files excluded = `{bef81d01, d681e3ea}` (macB's own earlier library, another library; and the
current Standard key — rule 5). **Nothing made in Castle (`a40a2585`, and `7f6f96e0`) and no copy macB made before the
leave is reached.** No step of macB's leaves a road open: the one road is the sender's own Send Library pair, kept
exactly as the design keeps it.

**Classification: a CHECKER bug.** Promise 13 (design §4.1) protects "any copy made before the leave, or any key made in
Castle"; the checker reads it as every key in the before-record's family tree, which on a landed library includes the
SENDER's keys. The closer already met this class at seed 2 sequence 661 and exempted "a Standard pair another Mac sent
here … THAT Mac's own copy, under its own key and its own Apple key" — but only the sent image's own fingerprint. The
pair's HISTORY is the same road (its own locks, its own Apple key) reaching the sender's earlier Standard keys: the
sender's Standard copy in its day, no copy this device made, no key made in Castle (a Standard key's history takes keys
only within a mode, §3.4). No model change: §3.7 ("the sent pair is never written and keeps its own locks") and §3.6
(the copy's family tree) are as designed, and nothing a person would lose or an attacker would gain is behind it.

**The fix (the world, `Promises.swift` `castleStaysCastles`):** for each sent Standard pair in a hand-off folder on this
device, the exemption takes the image's fingerprint AND `reachableInItsDay(record, keyFile: <the pair's key file>)` —
its current key and its key file's history (never an anchor's), the existing helper the stated-limit bookkeeping
already uses for "what a Standard state reached through Apple in its day".

**The pin — `LadderRound1NewFindsPins.aSentPairsHistoryIsTheSendersOwnAfterALeave`** (the 10-step sequence through
`step`, then the trace asserted so the exemption can hide no exposure: (1) no Castle-born key kept by the leave is
reached; (2) no copy macB made before the leave is reached; (3) with the hand-off folder excluded nothing kept by the
leave is reached at all; and the sent pair's history key IS reached and kept — the pin's road — then
`expectPromisesKept`).
- **RED on the tree before the fix** (`d77bedebd`): `✘ Test aSentPairsHistoryIsTheSendersOwnAfterALeave() recorded an
  issue at LadderRound1NewFindsPins.swift:74:27: Expectation failed: found.isEmpty` — `promise 13 on macB: the Apple
  account or the login password reaches b03b0684, a key from before the leave` (assertions (1)–(3) green on both trees:
  the trace holds before and after).
- **GREEN after:** `✔ Test run with 1 test in 1 suite passed after 0.082 seconds.` (with the closer's precedent
  `aSentStandardPairIsTheSendersOwnAfterALeave`: `✔ Test run with 2 tests in 2 suites passed`).
- **The revert check:** `Promises.swift` stashed — `✘ Test run with 1 test in 1 suite failed after 0.082 seconds with 1
  issue.`; restored — `✔ Test run with 1 test in 1 suite passed after 0.082 seconds.`
- The protection set after: `✔ Test run with 430 tests in 70 suites passed after 14.178 seconds.`

### NEW-2's second road — the same class, found by re-running the round-1 slice on the first fix

The slice (seeds 1–3 × 250, soak shape, on `69336aa21` — both first fixes in) passed sequence 54 (NEW-1) and met
sequence 222 again, now shrunk to **17 steps**: `createLibrary(macB)` · `follow(phone, .oldPassphrase)` (refused) ·
`useCastle(macA, alwaysAsk, newWords)` · `crash(setScheduledExport(phone, false), 19)` · `useCastle(phone, …)` (refused
`accountMoved`) · `resetPassphrase(phone, .plainConfirm)` (refused) · `signIn(macB)` · `answerCorner45(macA, .standard)` ·
`launch(macB)` · `follow(phone, .words)` · `finishLeave(phone)` (refused) · `sendLibrary(phone → macB)` ·
`land(macB, .wordsPassphraseMadeNew)` · **`timeMachineSnapshot(macB)`** · **`sendLibrary(macB → macA)`** ·
`useCastle(macB)` · `useStandard(macB)` → `promise 13 on macB: … reaches 08a7bed3` and `… reaches b03b0684, a key from
before the leave`.

**Traced (a probe listing every key file on macB, container and snapshots, with a leave-one-out reach):** the phone's
pair (`08a7bed3`, its own Apple key `1fd80b51`, history `b03b0684`) lands on macB as before; a Time Machine snapshot
takes macB's container — the hand-off folder with it; then macB's OWN Send Library to macA, the same day, writes its pair
into the SAME-NAMED folder (the world names a hand-off folder `Variorum Library — <day>`), overwriting the phone's pair in
the container and the world's `senders[folder]` entry (now `macB`). The phone's pair lives on only in the snapshot
(`tm0`), which `keyFilesOn` reads; it opens through the phone's own Apple key to `08a7bed3` and `b03b0684`. Leave-one-out:
without `tm:Variorum Library — 2026-01-14/variorum-library-keys.json` the reach loses exactly `{08a7bed3, b03b0684}`;
nothing made in Castle (`35ec40e9`) and no copy macB made before the leave is reached. **The same class — the sender's own
Standard pair — the exemption reading it by its folder in the container, through a map the same-day send overwrote.**

**The fix (the world):** the exemption reads the pair by IDENTITY: at each `sendLibrary` the world records, for the
receiver, what the sent Standard pair reaches by its own locks — `reachableInItsDay(record, keyFile:)`, its key and its
key file's history (`Truth.sentStandardPairReach`); promise 13 exempts that set, wherever the pair's files then sit (the
folder scan it replaces read the container only, through the overwritable map). A Standard key's history holds only
keys of that device's own Standard stretch (§3.4), so the set can never hold a key the receiver made in Castle.
**Noted, not changed:** the world's day-named hand-off folder lets a device's own send overwrite a pair it received the
same day — a fake's simplification (the real destination is hers to pick, phase 5), recorded for round 2.

**The pin — `LadderRound1NewFindsPins.aSentPairsSnapshotIsTheSendersOwnToo`** (the 17 steps; the same trace assertions —
nothing Castle-made reached, no pre-leave copy of macB's reached, without every hand-off folder's files in the container
AND the snapshots nothing kept is reached, and a kept key IS reached through them — then `expectPromisesKept`).
- **RED on the first fix's tree** (`69336aa21` + the pin): `✘ Test aSentPairsSnapshotIsTheSendersOwnToo() recorded an
  issue at LadderRound1NewFindsPins.swift:126:27: Expectation failed: found.isEmpty` — `promise 13 on macB: the Apple
  account or the login password reaches 08a7bed3, a key from before the leave` · `… reaches b03b0684, …` (the trace
  assertions green).
- **GREEN after:** `✔ Test run with 3 tests in 1 suite passed after 0.117 seconds.`; with the closer's precedent
  (`aSentStandardPairIsTheSendersOwnAfterALeave`): `✔ Test run with 4 tests in 2 suites passed after 0.119 seconds.`
- **The revert check:** the three world files' change stashed — `✘ Test run with 3 tests in 1 suite failed after 0.120
  seconds with 1 issue.` (the same two violations); restored — `✔ Test run with 3 tests in 1 suite passed after 0.117
  seconds.`
- The protection set after: `✔ Test run with 432 tests in 70 suites passed after 12.768 seconds.`

## NEW-1 — promise 3 after a replayed pre-landing capture: a MODEL bug

**The sequence** (start "a phone on an older build beside a synced Castle Mac", world seed 1000057): base tree —
`createLibrary(macB, secrets)` · `updateToNewBuild(phone)` · `sendLibrary(phone → macB)` ·
`crash(useCastle(macB, alwaysAsk), afterWrites: 17)` · `land(macB, .wordsPassphraseMadeNew)` ·
`tamper(macB, .replayLibraryFile)` · `settle`; the fixed tree's minimal swaps the single tamper for
`tamperSequence(macB, [replayPlan, plantPlan, replayLibraryFile])` → `promise 3 on macB: no Apple wrap of the current
key`.

**The traced mechanism** (a probe printing, per step, the slot, the record, the live key file, BOTH memory items with
their epoch, mode, mirror and in-flight act, and the executor's log lines):
1. `createLibrary(macB)`: library **Y** (`99708862`), Standard, key `89b4e0e9`, macB's own Apple key `d0097361`.
2. `crash(useCastle(macB))` after write 17 — past the swap: Y is under `c8d07e93` (Castle), the memory names it at
   epoch 2. **Captures:** the world's `opened()` captured the slot at the press — Y's Standard-era file
   (`89b4e0e9`, epoch 1, record Standard) — the adversary's copy from Y's Standard day.
3. `land(macB)`: the open first finishes Use Castle (`retired 1 own Apple key(s)` — `d0097361`); then the phone's
   Castle pair lands as a DIFFERENT library **X** (`091f29c6`) under a fresh key `8e37d193`, held. Y goes to Previous
   Libraries WITH its key file (`c8d07e93`, history `[89b4e0e9]`); X's key file takes the live place. **The landing is
   named in both libraries** (Copies.swift: "the outgoing one's section (a crash before the swap rolls it back there)"),
   so Y's memory item (v6, `c8d07e93#2`, Castle confirmed) still names `land #2` (`c8d07e93 → 8e37d193`) in flight —
   nothing ends it there once the slot serves X.
4. `tamper(macB, .replayLibraryFile)`: the oldest capture — Y's `89b4e0e9` Standard file — is written into the slot over
   X (X's file is gone: the adversary's destruction, availability only). `tamperWith` records no `tamperedStandard`: the
   device it tampered was Castle (X).
5. The relaunch: the lobby opens Y's old file through Previous Libraries' `c8d07e93` key file (the typed passphrase,
   then its history); `unlock` takes Y's memory (sealed under `c8d07e93`, in hand) — newer than the file's section — so
   this Mac's section names `land #2`. **THE FIRST WRONG WRITE — the settle:** no plan (the landing's was deleted at its
   end) → plan-less → "before its commit point" (the library isn't under `8e37d193`) → `rollBack`: ends the act and
   `writeFacts` — the record AND the memory written from the REPLAYED record. Log: `land: rolled back #2 — the library
   stays under 89b4e0e9`; Y's memory item is now v7, `89b4e0e9#1`, Standard confirmed — **the older file won over this
   Mac's own memory**, exactly what §3.6 ("a library file replayed alone loses to the memory") and P-U4-6 (ratified (a),
   "Memory wins") rule out. **THE SECOND LINK — the repair arm:** even with no act named, assess's memory-wins arm
   verified only through the LIVE key file (`live.fingerprint == memory.currentFingerprint`), and the live place held
   X's file — so it could not fire, and the ALWAYS block's `refreshMemory` would have written the same stale facts.
6. The state left: Y in the slot, Standard confirmed, under `89b4e0e9` — a key a login-password holder held in Y's
   Standard day — with no key file of its own (none was ever frozen; P-R1-1's copy-less class, so promise 1's clause
   stays exempt) and its own Apple key retired at Use Castle (so Re-link's arm has no Standard key file to re-lock —
   the finder's second reading does not hold: nothing CAN re-link it). Promise 3 is the symptom; the substance is a
   remembered Castle library lowered to Standard by one replayed file (promise 10's claim — which the checker skips
   because the slot's library ID changed).

**Classification: a MODEL bug, under her ratified rule (P-U4-6 (a)); not P-U4-10's ceiling.** The finder's first
reading (the checker should record `tamperedStandard` for a Standard file swapped INTO a Castle slot) would have exempted
the symptom and hidden the lowering: P-U4-10's stated limit covers a tamper on a STANDARD device (and, by P-U4-6's own
text, "a file only the ANCHOR reaches") — here the device was Castle, and Y's memory's key reaches the file's key through
its HISTORY (the mirror and the set-aside key file both carry it). The second reading (the swapped-in library's Apple
road never re-linked) is not the mechanism: there is no Standard key file of `89b4e0e9` anywhere for the arm to re-lock,
and Y shouldn't read Standard at all. No product behaviour invented: the outcome is the ratified one; the two changes
are its mechanics.

**The fix — the older file loses FIRST, verified through the memory's own sealed mirror** (three edits, one rule):
- `AssessRules.olderLibraryFileProof` (Assess.swift, new, pure): the key file that proves the file loses — the live
  file of the memory's key (today's road), or, when the file came back ALONE (the live place holds no key file of THIS
  library: absent, or another library's, as a landing leaves it), the memory's own sealed mirror of its key file —
  whichever holds the file's key in its history. A whole-pair restore (the file's own key file live beside it — her
  Time Machine restore, P-U4-12) never qualifies; neither does the anchor-only residue (a leave's new key has no
  history). Assess's first arm now owes `rekeyOlderLibraryFile` on this proof.
- `rekeyOlderLibraryFile` (ExecutorRepairs.swift): takes the same proof (and now also checks the memory is THIS Mac's —
  assess's own-memory rule, seed 17, said in the executor too); on the mirror's road it sets whatever is live ASIDE
  (`setAsideLiveKeyFile`, never deleted — the round-1 rule for another key's file), writes the mirror back Apple wraps
  stripped (`restoreKeyFileFromMirror`'s rule), then re-keys as before; everything verified before the first write. A
  crash after the set-aside leaves the live place empty (the same proof again); after the mirror's write, the live file
  is the memory's (today's proof).
- `settle` (PlanRunner.swift): FIRST — when this Mac's section names an act, its own memory is newer by epoch and names
  another key — the re-key runs before the settle reads its plan or rolls anything back, so a roll back or finish acts
  against the memory's library, never the stale record. With nothing in flight the repair arm owes it as before.

**After the fix** (the probe's log at the relaunch): `the live place held 8e37d193's file, not the current key's — set
aside` · `the memory's own key file restored from its mirror — the library file came back alone` · `the library file was
older than this Mac remembers — re-encrypted under c8d07e93, the memory's facts kept` · `settle: … it lost to the memory
first` · `land: rolled back #2 — the library stays under c8d07e93` (the stale landing act now ends against Y's own key,
harmlessly). Y: `c8d07e93`, Castle confirmed, its own key file live, no Apple wrap; X's key file catalogued `.setAside`;
Y's memory v7 at `c8d07e93#2`. Every promise kept through the settle.

**The pin — `LadderRound1NewFindsPins.aLoneOlderFileOfALibrarySetAsideByALandingLosesToItsMemory(group:)`** (both
forms: `false` = the base tree's single tamper, `true` = the fixed tree's group; asserts Y back in the slot under its
remembered Castle key, its own key file live with no Apple wrap, X's file set aside, every promise kept).
- **RED on the tree before the fix** (`59d5d9289` + the pin): both cases — `Expectation failed: slot.record?.mode ==
  .castle`, `… slot.fingerprint == yCastle.currentFingerprint`, `… world.liveKeyFile(world.macB)?.fingerprint ==
  yCastle.currentFingerprint`, `… keyFiles.contains { $0.role == .setAside && $0.fingerprint == x.fingerprint }`,
  `Expectation failed: found.isEmpty` → `promise 3 on macB: no Apple wrap of the current key` — `✘ Test run with 2
  tests in 1 suite failed after 0.094 seconds with 10 issues.`
- **GREEN after:** `✔ Test aLoneOlderFileOfALibrarySetAsideByALandingLosesToItsMemory(group:) with 2 test cases passed`
  — `✔ Test run with 2 tests in 1 suite passed after 0.093 seconds.`
- **The revert check, whole and by link** (each a fresh build): all three files stashed — `✘ … 2 tests in 1 suite
  failed … with 10 issues` (`promise 3 on macB: no Apple wrap of the current key`); the settle-first link alone stashed
  — the same `✘ … with 10 issues`; the mirror proof alone stashed (Assess + ExecutorRepairs, the settle-first kept) —
  the same `✘ … with 10 issues`; restored — `✔ Test run with 2 tests in 1 suite passed after 0.093 seconds.` **Each
  link is necessary; together they fix it.**
- The protection set after: `✔ Test run with 431 tests in 70 suites passed after 13.178 seconds.` (the
  `libraryFileLosesToMemory` mutation pin — guarded green, unguarded failing — among them; both new paths sit behind
  the same guard.)

**Noted, not built (for round 2):** (1) promise 10's checker skips a step that changes the slot's LIBRARY, so a
remembered library lowered by a swap is caught only through promise 3's symptom — a check reading the swapped-in
library's own memory would see it directly; (2) the landing still leaves its act named in the outgoing library's
memory — harmless after this fix (any older file of that library re-keys first, and the act then ends against its own
key), but ending it there at the swap would be the cleaner bookkeeping; (3) the generator's group rule
(`rollsBackBothHomes`) treats a library file replayed with its key file deleted or replayed as the stated limit's shape
— with the mirror proof, the deleted-key-file case is no longer one (the memory now wins it), so that exclusion could
narrow; (4) the stale act's roll back deletes custody items of its to-key not in the slot library's tree (X's, if X had
one) — pre-existing (the Time Machine road to before a landing meets it too), unchanged here.
