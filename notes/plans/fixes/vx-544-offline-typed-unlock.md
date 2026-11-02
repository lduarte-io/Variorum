# VX-544 — the offline typed unlock in Castle leaves sync locked for the session

**STATUS: READY TO KICK OFF — not started. Born at VX-500 (U3), LIFTED OUT at her word 2026-11-01 (R-500-10 in
`notes/plans/fixes/vx-500-sync-followups.md`): its own ticket run, branch `vx-544-offline-typed-unlock`, worktree
`~/dev/variorum-vx-544`, the Pro, after VX-500's ladder closes and after VX-683 (her priority order). Ticket VX-544 (Bug ·
Confirmed · Castle & sync · Medium; NOT Pre-launch — R-500-2). Architect shape; the cast her call at kickoff (VX-500's
standing: Fable implements; the cold reviewer is Fable — custody-adjacent). Pin-before-fix; commits `Part of VX-544`; no
trailers; the PR titled `VX-544: …`, merge commit only, and HELD if the launch freeze still stands.**

**Kickoff message (paste-ready):** `/architect-phase VX-544 — the offline typed-unlock retry. Read this file whole, then
the standard preflight (CLAUDE.md + canon, the master plan's in-flight table, notes/TICKETS.md, QUESTIONS, the resiliency
protocol, the sizing guidance), notes/CastleRules.md WHOLE, notes/SurfaceContracts.md §"Doors to the outside" (the
protection bullet), notes/SyncSpec.md §3. THE DESIGN below is ruled direction (her R-494-4 M1 (c): "a typed unlock should
hold sync keys in session until lock"); P-544-1/P-544-2 are PROVISIONAL for her sitting. One unit; its evidence is a
custody DRILL (the two-Mac test's steps 8–9 on her Air — her hands) plus the planted-road pins. The stage is needed for
the Mac suites. Ask her at kickoff whether Fable or Opus implements.`

## THE DESIGN (D-544 as written at VX-500, carried whole; the mechanism confirmed live in her two-Mac test, VX-529 steps 8–9)

**Mechanism.** Offline, the typed unlock's one bounded vault read fails; the library opens (never hostage — correct); the
derived secret is dropped with the call; nothing ever retries, so the row says "Sync locked — this Mac hasn't unlocked your
account's sync keys" until another ONLINE typed unlock or a Touch ID unlock. Castle users on the typed road (Always ask, or
Touch ID declined) who open offline — a train, a plane, a café — and come back online never sync that session.

**The posture question, answered from the rules before any code:** CastleRules rule 9 ("no copy of the key on the device
at all" under Always ask) is about the DEVICE — disk and keychain; session MEMORY already holds the account's sync keys
after a successful typed unlock (`holdInSession`, dropped at a relock — `ProtectionRoadLock.dropSessionMemory`). Holding
the typed unlock's DERIVED secret (the `PassphraseKey`s the open derived, or the words' derived `WordsKey`) in the SAME
session memory, for the same lifetime, to finish the load the user already authorized, is posture-consistent and exactly
her ruled direction. Nothing is written to disk or keychain; a lock drops it with the keys.

**The build.** (1) `ProtectionRoadSession` gains `pendingSyncKeyLoad: PendingSyncKeyLoad?` (`account`, the
`TypedUnlockSecret` — derived material only, never the passphrase text; `CustomStringConvertible` redacted) set by
`loadSyncKeysAfterTypedUnlock` ONLY on `.failed`/`.timedOut` of the vault read (every other exit — loaded, no vault,
signed out, a secret that opens the library but not the vault, a moved account — leaves it nil as today), cleared on a
successful load, on `dropSessionMemory` (the relock), on sign-out, and by any act that loads the keys. (2) THE RETRY:
`ProtectionOpenRoad.retryPendingSyncKeyLoad(session, signIn:)` — the same function with the retained secret, the same 10 s
bound, the same log lines; idempotent; nil pending ⇒ nothing. (3) THE OCCASIONS: (a) every sync trigger —
`SyncSession.triggerSync()` and `flush()` gain an optional async `beforeRound: (@MainActor () async -> Void)?` hook the
Mac composition wires to the retry (run only when the provider cannot produce keys — one cheap `currentKeys()` try — so an
unlocked session pays nothing); the round then runs with the keys loaded; (b) a NEW reachability trigger — `NWPathMonitor`
in the shared `SyncSession` (Network framework, both platforms): a path transition to `.satisfied` from unsatisfied runs
`triggerSync()` once (debounced 2 s), so her step 9 ("Wi-Fi back on, a minute's wait") heals by itself. The row keeps
saying locked until the keys load; "Sync now" and the Protection door keep their roads.

**PROVISIONALs for her sitting (log in QUESTIONS at kickoff):** **P-544-1** (was VX-500's P-500-4): the retained
derived-secret shape over the alternative "a quiet one-press Unlock sync door on the locked row" — the door would make her
type again; the retention finishes what she typed. **P-544-2** (was P-500-5): the reachability trigger (a new, small,
shared machinery) vs. the trigger-only road.

**Pins (Mac, the planted road + a scripted vault leaf):** a typed unlock whose vault read fails OFFLINE leaves
`pendingSyncKeyLoad` standing and the keys unloaded; a later `retryPendingSyncKeyLoad` with the vault reachable loads the
keys and clears the pending (the BEHAVIORAL red-on-old: on the old tree nothing can load them after the failed read); a
relock clears the pending (guard); a successful first load leaves no pending (guard); the SyncSession hook runs before a
triggered round and only while keys are missing (a core-free Mac pin over a scripted scheduler — the `FirstRoundScheduling`
precedent); the reachability trigger fires `triggerSync` once per satisfied transition (a planted path publisher). Live
confirmation: HER HANDS — the two-Mac test's steps 8–9 on her Air (recorded as owed, never claimed).

## PREFLIGHT FACTS (read at VX-500's kickoff on main `00e32497c`; re-verify at this run's kickoff)

- `App/Variorum/Shared/Protection/ProtectionOpenRoad.swift`: `TypedUnlockSecret` (~:624, redacted description),
  `loadSyncKeysAfterTypedUnlock` (~:654) and its exits, `holdInSession` (~:715); `openTyped`'s call site.
  `ProtectionRoadLock.dropSessionMemory` (~:56). `NewRoadSyncKeyProvider.currentKeys()` reads session memory, then the
  silent item, never the Touch ID item; Castle keeps no silent item, so the engine refuses `encryptionKeysUnavailable`
  until something loads session memory.
- `App/Variorum/Shared/SyncSession.swift`: `triggerSync()` (~:195), `flush()` (~:237). NO reachability monitor exists
  in the app (grep `NWPathMonitor` → none); the round triggers are the write-settle observation, became-active/launch,
  Sync now, the act roads.
- VX-500's U2 changed `SyncStatusViews.swift` (the row's progress and retrying lines) — read that merged state; the
  locked line itself is untouched by both runs.

## THE BRIEF — the offline typed unlock's retained load + the retry + the reachability trigger (D-544) (the implementer per her kickoff call; custody-adjacent — CastleRules read whole)

**Who you are.** The implementer for VX-544, a Fable subagent at xhigh effort; `.claude/agents/opus-implementer.md`'s
contract binds you point for point (you are Fable at her R-500-5 word). Custody-adjacent: the typed unlock's DERIVED
secret is retained in session MEMORY only — never disk, never keychain (CastleRules rule 9 is about the device; D-544's
posture paragraph is the ruling you build to). ZERO lines under `Sources/VariorumCore/Sync/` and `Protection/`'s
headless core unless the retry needs a seam there — then STOP and record. Worktree `<home>/dev/variorum-vx-544`,
branch `vx-544-offline-typed-unlock`; the Mac suites need the stage held by this run's orchestrator (check before every run;
never claim or steal).

**Read first, in full:** `CLAUDE.md` + its canon · THIS FILE WHOLE (PREFLIGHT FACTS — the typed-unlock load and the
retention facts; D-544 whole; HELD FOR HER's P-544-1/-2; ENVIRONMENT TRAPS; the U1a and U2 records for the seam you
join) · `notes/CastleRules.md` WHOLE · `notes/SurfaceContracts.md` §"Doors to the outside" (the protection bullet —
VX-501's typed-unlock load sentence, VX-486/487's locked row) · `notes/SyncSpec.md` §3 (the keys-absent refusal grammar)
· `notes/SessionResiliencyProtocol.md` §implementer · the code: `App/Variorum/Shared/Protection/ProtectionOpenRoad.swift`
(`TypedUnlockSecret` :624, `loadSyncKeysAfterTypedUnlock` :654 and its exits, `holdInSession` :715, `openTyped`'s call
site) · `ProtectionRoadSession.swift` · `ProtectionRoadLock.swift` (`dropSessionMemory` :56) · the sign-out road (grep
`holdInSession(nil`) · `App/Variorum/Shared/SyncSession.swift` (`triggerSync` :195, `flush` :237, how rounds are
triggered; the write-settle observation, became-active/launch, Sync now) · the Mac composition that wires `SyncSession`
(grep `SyncSession.configure` and `AppServices`) · the standing planted-road pins for the typed unlock (grep
`loadSyncKeysAfterTypedUnlock` under `App/Variorum/VariorumTests/`) and the scripted-scheduler precedent
(`FirstRoundScheduling`, grep it).

**The pieces, in order (commit per piece; the record flipped in each):**

1. **The retained pending load.** `ProtectionRoadSession` gains `pendingSyncKeyLoad: PendingSyncKeyLoad?` — the account
   and the `TypedUnlockSecret` (derived material only; `CustomStringConvertible` redacted — the existing shape), set by
   `loadSyncKeysAfterTypedUnlock` ONLY on the vault read's `.failed`/`.timedOut` exits (every other exit leaves it nil —
   loaded, no vault, signed out, a secret that opens the library but not the vault, a moved account), cleared on a
   successful load, on `dropSessionMemory` (the relock), on sign-out, and by any act that loads the keys. **Pins
   (red-on-old):** a typed unlock whose vault read fails offline leaves the pending standing and the keys unloaded (the
   pending does not exist on the old tree — a new-API red by compile; make the BEHAVIORAL red honest by pinning the
   observable: after the failed load, a later reachable vault read through the retry loads the keys — on the old tree
   nothing can, so a pin that drives "fail, then vault reachable, then keys present" is red for a behavioral reason once
   the retry entry point exists; say which pins are compile-red and which behavior-red); a relock clears it (guard); a
   successful first load leaves none (guard).
2. **The retry.** `ProtectionOpenRoad.retryPendingSyncKeyLoad(session, signIn:)` — the same function with the retained
   secret, the same 10 s bound, the same log lines; idempotent; nil pending ⇒ nothing; success clears the pending; a
   second failure keeps it. Pin: the retry with the vault reachable loads the keys and clears the pending.
3. **The occasions.** (a) every sync trigger — `SyncSession.triggerSync()` and `flush()` gain an optional async
   `beforeRound: (@MainActor () async -> Void)?` hook the Mac composition wires to the retry, run ONLY when the provider
   cannot produce keys (one cheap `currentKeys()` try — an unlocked session pays nothing); the round then runs with the
   keys loaded. Pin: the hook runs before a triggered round and only while keys are missing (a core-free Mac pin over a
   scripted scheduler — the `FirstRoundScheduling` precedent). (b) THE REACHABILITY TRIGGER (P-544-2): `NWPathMonitor`
   in the shared `SyncSession` (Network framework, both platforms) — a path transition to `.satisfied` from unsatisfied
   runs `triggerSync()` once, debounced 2 s; a planted path publisher for the pin (fires once per satisfied transition;
   never on launch's first reading alone — decide and record). The phone gets the trigger by sharing the file; its
   retry hook is unwired there (no typed-unlock pending on the phone's road today — say so for the MOBILE PARITY line).
4. **The words.** The row keeps saying locked until the keys load (VX-486's sentence, unchanged); "Sync now" and the
   Protection door keep their roads; no new sentence (if one is needed, it is PROVISIONAL and goes to QUESTIONS).
5. **Close.** `swift build`; the Mac suites: every suite that names `loadSyncKeysAfterTypedUnlock`, `ProtectionRoadSession`'s
   session memory, `dropSessionMemory`, `SyncSession.triggerSync`/`flush`, plus the new suite(s) — `xcodebuild … test
   -only-testing:VariorumTests/<Suite>` per suite, the "Test run with N tests" lines; the stage held by the
   orchestrator. **The live confirmation is HER HANDS** (the two-Mac test's steps 8–9 on her Air) — record it as owed,
   never claimed. SELF-ASSESSMENT at the end: say exactly where the derived secret lives, how long, and every road that
   clears it.

**Your record:** `### VX-544 RECORD` under UNIT RECORDS; LIVE STATUS from the first commit; the pins (compile-red vs
behavior-red said plainly); the close's lines; first line = what you did NOT do. Flip the orchestrator's LIVE STATUS
row 5. Commits `VX-500 U3: … Part of VX-544`; no trailers; pull --rebase before each push; foreground waits only.

**Not yours:** `Sync/`; U1b/U2's files; the ladder; the deploy; the PR. **ENVIRONMENT TRAPS — the section above,
binding verbatim.**

## ENVIRONMENT TRAPS (carried verbatim from VX-500's plan; binding)

Instance checks use `pgrep -fl 'Variorum.app/Contents/MacOS'` AND discriminate by PATH (the test host matches mid-run);
inside a command that names the app's path use `pgrep -x Variorum`. Real-store instances are treated by STORE, never
quit or killed; no Release build or `/Applications` refresh while one lives. Headless `swift build`/`swift test` need no
stage; EVERY `xcodebuild test` needs a HELD `Tools/stage` claim (`--minutes` up to 240); Mac tests from `App/Variorum/`
with suite-level `-only-testing`, confirm the "Test run with N tests" line; never a custom build configuration. Swift
Testing's count includes skipped tests. The core suite's known load-flakes: `MCPHarnessTimeLimitTests.aPeerThatNever…`
(named), VX-722, VX-723 (Suspected). Commit per piece, push after every commit, LIVE STATUS flipped in the same commit,
PENDING on every unverified claim; foreground waits only; never `git checkout` over uncommitted work; a behavioral revert
is named in the record BEFORE it runs, at a committed tip. The orchestrator writes nothing in the worktree while an
implementer or reviewer is live there (drafts in the scratchpad; pathspec adds only — the VX-500 lesson). No subagents for
implementers. No store, no server contact.

## LIVE STATUS

| # | Piece | Status |
|---|---|---|
| 0 | Kickoff: preflight whole; worktree + branch; the in-flight row; VX-544 In Progress; P-544-1/-2 into QUESTIONS | NOT STARTED |
| 1 | The unit (THE BRIEF): the pending load, the retry, the two occasions, the pins | NOT STARTED |
| 2 | The ladder (a fresh `fable-reviewer`; rounds per CLAUDE.md) | NOT STARTED |
| 3 | Closing Mac runs over every changed source; the PR opened (HELD if the freeze stands); the FOR A LATER READER section; the handoff | NOT STARTED |
| 4 | Her drill: the two-Mac test's steps 8–9 on the Air (owed) | NOT STARTED |
