# VX-488 — ladder round 2 (cold review of round 1's fixes, fable-reviewer, 2026-10-22)

**Scope:** the fix leg `git diff 06f4fe957..HEAD` (commits `2fa806cca` → `f5ad3f177`; 8 files, ~223 insertions):
the F1 fixes (clear 1 in the swap step, clear 2 in `forgetUnboundSyncKeys`, the third clear on the plain-text
bring-in road — ruled into F1's scope by the orchestrator mid-leg), the F2/F3 wording fixes, their pins, and the
record. F4 was deferred as VX-490 — no code expected, none found.

**Read in this session:** REVIEW_PROMPT verbatim; CLAUDE.md + the auto-loaded canon; round 1's findings and
THE FINAL CALLS (`vx-488-ladder-round-1.md`, whole); the run record's LADDER R1 FIXES + THE THIRD CLEAR sections
and the M1 record; every diff file line by line; the touched production code read in place (`makeMineSwap` whole
with both act programs and `forgetOtherLibraries`, `forgetUnboundSyncKeys` beside `forgetSyncKeys` and the
PlanRunner rollback idiom at :545–549, `landPlaintextExport` whole, `bringInPlaintextExport` whole,
`ProtectionRoadLock.dropSessionMemory`, the `loadSyncKeysForTheSession` guard split, the planted worlds' session
stores). Verified by own hand on the tip: `swift test --filter SyncKeysSessionHold` → `✔ 5 tests in 2 suites`;
`swift test --filter "EmptySlotMakeMine|U2CopyDoor|Lifecycle|FixedScenarios"` (the suites over the changed acts)
→ `✔ 54 tests in 13 suites`; `xcodebuild -scheme Variorum -destination 'platform=macOS' build-for-testing` →
`** TEST BUILD SUCCEEDED **`; the leg's commits carry no trailers; VX-490 confirmed on the board (Debt · Low ·
Castle & sync · Confirmed, pointing at the finding).

**No BLOCKER, no MAJOR. No new findings above NIT. The round is a PASS — the ladder closes.**

## Verdict per round-1 finding

### F1 — FIX SOUND (all three clears)
- **Clear 1 (`Copies.swift:makeMineSwap`)** — the load-bearing drop, and the implementer's PREMISE CORRECTION
  to THE FINAL CALLS is factually right: `makeMineSwap` replaces `library.record` with the landed record before
  returning, and `forgetOtherLibraries` (the `afterCommit` step the ruling named) reads only the NEW record's
  `libraryID` — so the swap step is the one place the outgoing record and the landed commit are both in hand
  (verified in code, Copies.swift:185–220 and :224–231). The drop is the ruling's direct leaf drop
  (`holdInSession(nil, accountID: outgoing)`), so it covers Always ask's session-only custody; it runs in BOTH
  adopt programs (`MakeMineProgram` and `EmptySlotMakeMineProgram` share the `swap` step; the empty slot starts
  from `record: nil` — nothing outgoing, nothing dropped); it is resume-safe (a resume past the swap reads the
  new record, account nil → no drop, and the crash emptied session memory; a resume before it re-runs the swap
  and the drop idempotently); the guard `outgoingAccount != record.account` is correct and defensive (today the
  landed record always names no account — `makeMineRecord` mints `account: nil`).
- **Clear 2 (`AccountActs.swift:forgetUnboundSyncKeys`)** — PlanRunner:546's exact idiom, verified side by side
  (the same in-loop `holdInSession(nil, accountID: item.accountID)` beside the delete). Reaches only accounts
  with items, as the ruling accepted — session-only holds are clear 1's job.
- **The third clear (`ProtectionCopyDoors.swift:landPlaintextExport`)** — ruled into F1's scope by the
  orchestrator's adjudication, legitimately: the bring-in with a library open is one of the finding's
  adopt/step-aside roads and never runs Make this my library (the open library steps aside whole;
  `ProtectionOpenRoad.create` mints the new one), so with the process's one leaf nothing would ever clear the
  outgoing hold — the finding's exact mechanism. The implementation reuses the lock's own clear
  (`ProtectionRoadLock.dropSessionMemory`, keyed on the outgoing session's record's account — sync-keys-only,
  no side effects, verified); the drop runs only after `result.created` is set, so the read-only road, a failed
  step-aside and a failed creation all keep the hold (the refusal paths reopen or recover the old library, whose
  hold is then its account's current keys); the `outgoing:` seam defaults nil, so the no-library faces drop
  nothing. The outgoing session is quiescent during the landing (`beginAct` held, state `.opening`) — the
  off-main read follows the file's own pre-existing pattern (`sendLibrary`), and the strict-concurrency build
  accepts it (my own build-for-testing run).
- **The pins are honest.** Each pin's decisive assertion is `session[X] == nil` after an act whose pre-fix code
  contains no session write at all (plain from the diff), so red-on-old is guaranteed by mechanism, and the
  revert runs (R8, R9, R10) show per-clear isolation — each clear pinned by its own test alone. The forget pin's
  RE-POINTING (Always ask → Touch ID, recorded in the open before the fix landed) is itself an honesty catch:
  the step iterates items, so an Always-ask session-only hold is unreachable by it — exactly the ruling's reason
  for clear 1. The bring-in pin's seam-before-fix shape (T0: seam unused + pin red; T1: drop; R10: red again) is
  the same disposition M1's pin 3 used, honestly recorded. The planted stores the pins assert ARE the stores the
  production clears write (`ExecutorWorld.session` ↔ the planted leaf's `holdInSession`; `PlantedSyncKeysLeaf`
  shared across compositions, so the bring-in drop reaches the leaf the pin reads).

### F2 — FIX SOUND
The load's no-item line now reads "found no readable Touch ID item" (`ProtectionOpenRoad.swift`): truthful for
both the missing and the undecodable item; the decode idiom unchanged, in step with the context-less read —
exactly as confirmed. Log wording only; no pin owed.

### F3 — FIX SOUND
The one guard split in two (`loadSyncKeysForTheSession`): the no-press case and the leaf-not-`TouchIDPressRiding`
case each get their own line; the guard logic is behavior-equal to the combined original (press nil/invalidated
→ line 1; leaf not riding → line 2). Wording only; no pin owed.

### F4 — CORRECTLY DEFERRED
No code in the leg touches the `nonisolated(unsafe)` line (diffstat verified); VX-490 exists on the board with
the final calls' exact disposition (Debt, Low, Castle & sync, Confirmed; the finding pointer in its body).

## New findings

### N1 · NIT · notes/plans/fixes/vx-488-window-hotfixes.md (THE THIRD CLEAR, "Where, and when the record is in hand")
**What:** the record's sentence "A landing that lands nothing (a refusal, a failed creation) drops nothing: the
bootstrap then reopens the old library, whose hold stands" overstates one sub-window — on a creation failure
AFTER the step-aside, the old library's files are already in Previous Libraries, so `beginOpening(unlockedKey:
oldKey)` lands on an empty slot (the missing face), not the reopened library. **The code's choice is still
right** (dropping there would be premature: a hand restore of the old library would make the hold its account's
current keys; a make-mine restore triggers clear 1; a quit clears by process death — the retention is bounded
and unreadable, round 1's established fact). Record wording only; no pin could exist (no wrong behavior); no
action required this run.

## Considered and dismissed (traced, not findings)
- **A signed-in-but-unbound account's hold surviving a swap** (clear 1 keys on the record's account only):
  unreachable at rest — a join's pre-swap pickup exists only mid-act under `beginAct` exclusivity, and the
  rollback (PlanRunner:548–549) and the leave's forget clear the failure legs; at the swap, any standing hold is
  the outgoing record's account or nothing. The final calls' induction claim holds as far as I can trace; no
  red-on-old pin could name a reachable state.
- **The Sendable capture of `outgoing` in the bootstrap's detached task:** same pattern as the file's
  pre-existing captures; the session is quiescent for the landing's duration; compiles under the project's
  strict settings (own build).
- **Clear 2 clearing twice for a two-class account:** idempotent, and byte-the-idiom of PlanRunner's own loop.

## Clean bill (checked and found solid)
- The leg touches exactly 8 files (diffstat): 3 app production, 2 core production, 2 pin files, the record — no
  `Sources/VariorumCore/Sync/` line, no schema, no wire, no default's meaning changed.
- The F1 pins green on the tip by my own hand (`✔ 5 tests in 2 suites`); the core suites over the changed acts
  green (`✔ 54 tests in 13 suites` — EmptySlotMakeMine, U2CopyDoor, Lifecycle, FixedScenarios); Mac
  build-for-testing green (app + test targets compile, the new `SessionHoldBringInTests` included).
- Commit hygiene: pin-before-fix order holds in the log (`2fa806cca` pins → `094130af7` fixes; `261c495c6`
  seam+pin → `3af9ed5f8` drop); each commit `Part of VX-487`; no trailers; the record flipped per piece with the
  revert evidence (R8/R9/R10) recorded before the next piece.
- The orchestrator's mid-leg scope ruling (the third clear into F1) is recorded repo-first in the run record
  with the premise note and the exact traced mechanism — process followed.

## Round disposition
**PASS.** Every round-1 fix answers its finding; the pins are honest with verifiable red-on-old mechanisms; the
leg introduces nothing at BLOCKER or MAJOR (one record-wording NIT, N1, no action owed). No round 3 is earned —
this closes the ladder.
