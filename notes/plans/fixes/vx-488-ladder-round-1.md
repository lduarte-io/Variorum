# VX-488 — ladder round 1 (cold review, fable-reviewer, 2026-10-22)

**Scope:** the whole run diff `git diff main...HEAD` on `vx-488-window-hotfixes` (members VX-487 M1 + F-M1-1,
VX-486 M2, VX-483 M3, VX-489 M4; 30 files, ~2066 insertions). Reviewer read in this session: REVIEW_PROMPT
verbatim; CLAUDE.md + the auto-loaded canon; SyncSpec WHOLE; CastleRules WHOLE; SurfaceContracts (the app,
doors/protection); the run record `vx-488-window-hotfixes.md` whole; the kickoff handoff; every diff file read
line by line; the touched production code read in place (CommonSteps.holdSyncKeys whole, pressTouchID in place,
KeychainSyncKeysLeaf whole, the holdInSession writer/clearer sweep re-run, the production construction sweep
re-run, the allowsSync consumer sweep). Verified by own hand: the bundled `ReleaseNotes-0.10.md` is byte-faithful
to the repo-root approved draft minus its two header lines (`diff` clean); `swift test --filter
SyncKeysSessionHoldTests` → `✔ 3 tests in 1 suite passed` on the tip.

**No BLOCKER, no MAJOR.** Findings below are MINOR/NIT.

## Findings (severity-ranked)

### F1 · MINOR · `Sources/VariorumCore/Protection/Executor/Acts/AccountActs.swift:234` (`forgetUnboundSyncKeys`) + the adopt/step-aside roads
**What:** with F-M1-1's process-shared sync-keys leaf, an account's session hold now outlives the library that
earned it across a library swap, and no road clears it. `forgetUnboundSyncKeys` deletes unbound accounts' ITEMS
but not their session holds — asymmetric with the rollback's own idiom (`PlanRunner.swift:546`, which clears
session beside the item in the same loop).
**Evidence (traced):** the full `holdInSession` writer/clearer sweep (re-run this session): clears exist at lock
(`ProtectionRoadLock.swift:58` — keyed on the CURRENT record's account), rollback (`PlanRunner.swift:546/549/571`),
account-leave (`AccountActs.forgetSyncKeys`, :229) and the Standard arm; none runs on the step-aside/adopt roads
for the OUTGOING account. Mechanism: open library A (bound to account X, Castle + Touch ID) → the press loads
`session[X]` (`ProtectionOpenRoad.loadSyncKeysForTheSession`) → Make this my library / Open Library lands library
B (unbound, or bound to Y) → the reopen composes a fresh system over the SAME leaf (F-M1-1), so `session[X]`
persists for the process life with no remaining clear road: the library whose relock would drop it has stepped
aside, so the leaf header's "gone at a relock" can no longer be exercised for X. Pre-F-M1-1 the swap's fresh
composition discarded the hold implicitly. NO read path reaches the stale hold (the provider keys on the current
record's account; the executor's reads are account-keyed), so this is in-memory retention hygiene, never
disclosure or wrong sync — hence MINOR, not MAJOR.
**Pin (red-on-old):** the `OneSyncKeysLeafRoadTests` idiom — hold under X through one composed system; run the
step that should forget X (the unbound-forget step on a record naming no/another account, or the step-aside
road); assert `sessionSyncKeys(accountID: X) == nil`. Red on this tree.
**Fix shape:** clear session beside the item deletion in `forgetUnboundSyncKeys` (PlanRunner:546's exact idiom);
optionally an explicit `holdInSession(nil, …)` for the outgoing record's account on the step-aside road.

### F2 · NIT · `App/Variorum/Shared/Protection/KeychainSyncKeysLeaf.swift:85` + `ProtectionOpenRoad.swift` (`loadSyncKeysForTheSession`)
**What:** an undecodable Touch ID item reads as nil (`.flatMap { try? decode }` swallows the decode error) and the
load's log then says "found no Touch ID item for the account" — misleading for a rehearsal diagnosis (the item
exists; its payload is bad). Same idiom as the pre-existing context-less read, so behavior is consistent; log
wording only. No pin (behavior-equal); fix optional: distinguish the decode failure in the log line.

### F3 · NIT · `App/Variorum/Shared/Protection/ProtectionOpenRoad.swift` (`loadSyncKeysForTheSession` guard)
**What:** the one "no press to ride" log line also covers the leaf-not-`TouchIDPressRiding` case (unreachable in
production — both production leaves conform; planted worlds only). Wording only.

### F4 · NIT · `App/Variorum/Shared/Protection/ProtectionOpenRoad.swift:700` (`RoadInputs.live`)
**What:** `nonisolated(unsafe) let syncKeys = syncKeys` hushes the Sendable check instead of carrying the proof
(both the production leaf and every planted leaf are lock-guarded `@unchecked Sendable`). A `SyncKeysLeaf &
Sendable` existential (or a Sendable refinement on the protocol) would state the real constraint. Cleanliness
only; the shared instance is lock-guarded (verified: `KeychainSyncKeysLeaf.lock` around `session`).

## Clean bill (checked and found solid)

- **M1 (a)** — the one-line arm change in `CommonSteps.holdSyncKeys` read in full context: the Touch ID item is
  written exactly as before, `drop(.silent)` still runs, the Standard arm still clears session, the Always-ask arm
  unchanged; the doc comment made true. Pin 1 (`SyncKeysSessionHoldTests`) re-run by this reviewer on the tip:
  3/1 green; its red-on-old mechanism is plain (the old arm wrote `holdInSession(nil, …)` where the pin asserts
  the held keys).
- **M1 (b)** — one press covers both gated reads: the custody leaf's Touch ID body was factored byte-faithfully
  (compared hunk by hunk — same guards, same `lastPress` facts, same catch arms); the press is handed ONLY when
  the read opened its item; `pressTouchID` invalidates it by `defer` on every exit, and the load runs before the
  defer fires (scope order verified); `interactionNotAllowed` is set on the ride so the second read can never
  show UI; a failing/absent read never fails the unlock (pin 5's four legs cover throw, gone item, unbound
  library, stale key — including press-ended assertions on the failure paths). The load's account truth
  (`session.library.record?.account`) is byte-the-same truth `NewRoadSyncKeyProvider.currentKeys` reads. The
  `noneOpens` arm returns `.failedOnExistingItem` hard-coded, so pin 5's stale leg is sound for planted leaves.
  All lobby Touch ID callers route through the one `ProtectionOpenRoad.pressTouchID` (caller sweep: StoreLockView,
  MobileRoadFaces, ProtectionLobbyModel → AppBootstrap:512); the key doors' own press is the pre-existing
  session-holding road. The Apple-facts residual (-25308 under `interactionNotAllowed` on an already-authenticated
  context) is honestly recorded with a rehearsal tripwire and a named fallback decision for her — the right
  disposition for an un-pinnable OS behavior.
- **F-M1-1** — the composition sweep re-run by this reviewer: exactly ONE production `KeychainSyncKeysLeaf(` mint
  (AppBootstrap:183) and ONE `ProtectionSystem(` construction (`live`); `syncKeys:` made required so a future
  per-system mint is compiler-refused; the explicit clears byte-unchanged and now reaching the one leaf (the
  guard test exercises the lock's drop and an executor's clear through later compositions); the leaf's session
  dictionary is NSLock-guarded, so sharing it process-wide is thread-safe; the test bootstrap takes its harness
  system's own leaf. The VX-423 pin's two literal strings loosened honestly (meaning unchanged). The ruling's
  trade-off (holds now survive reopen by design) is recorded; its one unruled residue is F1 above.
- **M2** — the keysLocked face: door minted only under `canOpenProtection` (P-2, the `canCheckForUpdates` idiom);
  the sweep pin covers every face state × syncing × offline and pins `keysReplaced`/`accountMismatch` keeping
  `Account…`; the neutral `requestProtectionPane()` with the crossing's method delegating (counter semantics
  byte-identical); `AppSettingsView.adoptProtectionRequest` adopts on appear AND on change (read in place,
  unchanged); the press is the MCP twin's two lines (ask, then `openSettings()`). Both render sites accounted:
  RootView:605 (Mac main window — injection verified in VariorumApp on the same environment chain the updates
  door already rides) and MobileSettingsView:121 (no injection ⇒ sentence alone, P-2). The phone's loss of the
  locked row's `Account…` door is correctly routed to VM-8 (O-B3) and is additionally unreachable today: the
  phone's marker-13 build refuses on lockstep BEFORE any key refusal, so the keysLocked face cannot present on
  the phone until a VM-8-era build, which brings the phone's own door. The line and label are marked PROVISIONAL,
  hers, in OPEN ITEMS — no canon line went stale (the locked row's words are in no canon file today).
- **M3** — the lift decision is pure, fed by `ProjectConfig`'s OWN resolved walk project (no second env parse —
  pinned by source); the ref derives from `productionProjectURL`'s host (never a second literal), matched
  case-folded anywhere in the URL; an underivable ref fails closed; `.refusedProduction` never lifts and the
  launch logs why, host only. Release arm byte-unchanged (verified in the diff and pinned by source with the
  RM3-4 lesson applied — the pin matches the code expression, not a comment). The second-order fence (the
  retired-credential sweep now guarded on `storeVariant == .real`) is the right correction: under a lift,
  `allowsSync` no longer implies the real store, and the sweep reaches the login keychain's installed-build
  items. The full `allowsSync` consumer sweep (re-run this session) found the remaining consumers —
  `connectSyncIfAllowed`, `SyncSafetyFace`, the status row, DataSafetyPane — all of which SHOULD follow the lift
  for the rehearsal to work; none is a fence. Rule 24's exception class (a DEBUG switch that turns a guard off)
  covers the `#if DEBUG` placement; `ProtectionWalkSwitch` verified `#if DEBUG` whole (line 30 → trailing
  `#endif`).
- **M4** — the three version pins widened to the ruled pre-1.0 line honestly (the stamp filter
  `MARKETING_VERSION = 0.` still isolates the Mac target's two configurations — the mobile target wears 1.0 —
  and the count==2 pin holds the shape); the bundled `ReleaseNotes-0.10.md` verified byte-faithful to the
  repo-root approved draft minus exactly the title and meta lines (diff run by this reviewer); the release gate
  (`ReleaseNotes.source(for:)`) now finds the 0.10 file.
- **The pins' honesty** — pin 4's "already pinned" brief claim corrected in the open (no such test existed; a
  guard written with its teeth shown by revert R6); RM3-4's first form exposed as hollow and tightened before
  re-run; pin 3's red correctly attributed to the behavioral reverts (its seam cannot compile on the pre-fix
  tree). This is the hallucination-guard discipline working as written.
- **Sync shape** — no `Sources/VariorumCore/Sync/` line in the diff (verified by diffstat); no schema change; no
  wire change; the engine's refusal grammar untouched; S1–S5 untouched. SyncSpec read whole: nothing in this
  diff bears on the merge matrix, repairs or lockstep (marker 14 rides VX-329, not this run).
- **CastleRules** read whole against the diff: rules 9/11/15 (custody shapes untouched — no new persistence, the
  Touch ID item and session memory are the pre-existing shapes), rule 22 (no key deletion changed), rule 24 (the
  DEBUG fence is the named exception class), rule 21/17 untouched.
- **Process** — pin-before-fix per member with revert-verified reds (R1–R7, RM2-1..5, RM3-1..5) recorded before
  they ran; commits per piece with `Part of VX-nnn`, no trailers (git log read); the record file repo-first and
  current; `notes/KnownIssuesAndTechDebt.md` holds nothing this run owned (the board is tickets-first; the run's
  members are the tickets themselves).

## Round-1 disposition

No BLOCKER or MAJOR. F1 (MINOR) goes to the implementer verbatim with its pin shape; F2–F4 are NITs the
implementer may fold into F1's commit or decline with a line. Round 2 re-reads the fixes per the standing rules.
