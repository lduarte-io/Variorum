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
- **NEW-1 (promise 3, a replayed pre-landing capture):** traced (below); classified **a MODEL bug** (P-U4-6's
  memory-wins arm too narrow); pin + fix — PENDING.
- The runs at the end (the protection set in Debug, `swift build -c release`) — PENDING.

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

## NEW-1 — the trace

*(PENDING — written with its pin.)*
