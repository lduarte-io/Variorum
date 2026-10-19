# VX-307 — ladder round 2 (cold review over the round-1 fix legs, Fable)

**Reviewer:** fresh cold session, `notes/REVIEW_PROMPT.md` verbatim. **Diff:** `cbe35638d..85cc6bb51` (the two fix legs —
the orchestrator's U1 pair `df65cab20`, the implementer's U2a leg `abb3dd20a`→`bc76d9eee` + the leg close, the landing-rule
fix `7ad658677`, the walk-record additions and the close entries). **Anchor:** round 1's findings
(`notes/plans/vx-307-ladder-round-1.md`) and the U2a FIX LEG's per-finding dispositions in the plan's §6. **Read in full,
this session:** the fix-leg diff file-by-file; `ProtectionCrossingActs.swift`, `RoadCrossingsModel.swift`,
`AppBootstrap.swift`'s ready/teardown seams, `MacWillLock.swift`, `KeychainCustodyLeaf.swift`, `ProtectionLobbyModel.swift`,
`StoreLockView.swift` (`RoadLockView`), `ProtectionWalkSwitch.swift`, `AccountVaultClient.swift`, `NewRoadSyncKeyProvider`'s
consumers (`AppServices.swift:423/509`), and every new test in the diff. **Verified by run (headless, the review
worktree):** `swift test --filter AccountVaultWireTests` → ✔ 13 tests in 1 suite (the MINOR-1 and MINOR-2 pins among
them). No file outside this findings file was modified.

**Count: 0 BLOCKER · 0 MAJOR · 0 MINOR · 2 NIT. No new BLOCKER/MAJOR — no round 3 is earned.** The three disputes are
ruled below; every round-1 finding's fix or disposition is re-checked and holds.

---

## The three dispute calls (the cross-model flow — the reviewer's final word)

### (a) MAJOR-1's refinement — the reconcile keys on the durable mark, not the bare state. **ACCEPTED — the refinement is not just sound, it is required.**

Traced myself, end to end: `cross` writes the mark before anything moves (`ProtectionCrossingActs.swift:167–168`,
`markedHere` = Use Castle + switch on + not already owed) and clears it only on the nothing-swapped refusal (`:188`);
`reconcileExport` (`:226–237`) acts only while the mark is owed — not-Castle clears it (the rolled-back-crash and
since-left arms), Castle + sealed-off + switch-on follows the switch and returns true exactly once; the ready's call site
(`AppBootstrap.swift:641–643`) is gated to a writing new-road session and speaks `ProtectionWords.exportTurnedOffNotice`
through the session's receipt queue (drained once by `RoadStandingModel.speak`'s setter — the "once" pin is meaningful,
not vacuous); the pane re-reads the mark at every refresh and *OK* / *Turn it back on* clear it
(`RoadCrossingsModel.swift:198/227`, `ProtectionCrossingActs.swift:240–242/262`).

Why the refinement is required and not merely preference: the bare rule ("Castle + sealed-off + switch-on ⇒ follow")
re-fires at EVERY launch, and that same state is reachable by her own deliberate later choice — the Data Safety weekly-copy
toggle writes only the app's switch (P-VX307-U2a-3's recorded two-places split), so turning the copy back on in Castle by
that road leaves the sealed setting off. The bare rule would silently undo her reversal on the next open — the exact
opposite of rule 11's "one notice you may reverse". The mark-keyed rule leaves her choice standing (`noticeOwed()` false ⇒
the reconcile returns before touching anything). Confirmed against `turnExportBackOn` too (it writes the sealed setting
AND the switch and clears the mark, so no arm of the reconcile can later fire on it).

The crash-corner ordering is airtight for the switch-off itself: after a mid-act stop, the only road out of the lobby is
opening the crossed library (Make this my library and the crossings all require `.ready`; the lobby's Open Library door
renders only on rule 27's no-key-file face, which a crossed library never shows), so the crossed library's ready — where
the settle has already run and the reconcile follows the switch — always precedes any other library standing at ready.
The one residue is notice-visibility only (NIT-R2-1 below).

The Mac bootstrap pin's first-run red and its trace (the model's landing rule, fixed `7ad658677`) are verified: the old
`guard read == reads` drops an awaited refresh whose read finished before a newer in-flight one, returning with the model
stale — the defect is real, the new rule (`guard read > landed`; `landed = read`) preserves both properties (an older slow
read never lands over a newer one; an awaited refresh leaves the model at least as fresh as its own read), and the gated
twin `anAwaitedRefreshLandsWhileANewerOneIsStillInFlight` forces both orders. **MAJOR-1 is CLOSED.**

### (b) MINOR-3 — the implementer's trace stands; my round-1 candidate mechanism was wrong. **DISPUTE UPHELD; the finding's gap is closed.**

I verified the implementer's trace line by line in this session: `beginOpening` composes ONE road per open
(`AppBootstrap.swift:309`), `routeOnNewRoad` takes one `ctx`, arms the walk switch on `ctx.system.custody` (`:515`) and
hands the SAME ctx to the lobby (`:526`), whose roads press through it — so the armed and the pressed leaf are one
instance, and my round-1 candidate ("a fresh compose per press splits them") is ruled out; I withdraw it. What the walk
saw is fully explained by the auto-ask: `RoadLockView`'s `.task` runs `autoAskIfDue` → `pressTouchID`
(`StoreLockView.swift:336`, `ProtectionLobbyModel.swift:89–126`) — the FIRST press — and the plant is consumed inside the
custody read before any prompt (`KeychainCustodyLeaf.swift:132–136`), silently, leaving the changed line with the button
standing. The walker's later click was a REAL press, and its cancel overwrites the failed-press fact on both the leaf
(`:151`) and the lobby's face (`ProtectionLobbyModel.swift:116`), so the typed open owed no re-arm — W-VX307-1's observed
prompt, exactly.

The round-1 disposition's three asks are all met: the instance question traced (and instrumented — the DEBUG log lines
name the leaf at the arm, at the plant's answer and at every real press; never key material); the headless pin landed
(`RoadRearmTests.minor3_afterAFailedPressTheTypedRoadIsOpenAndNoSecondPressComesByItself` — honestly labeled a
behaviour pin, green on both trees, which is right for a question-closing pin rather than a bug pin); recipe row 5
corrected in place. The orchestrator's walked re-arm row (the close entry: the plant spent silently on the instrumented
leaf, the changed line, the card, `touch_id_rearm: done`) corroborates live. The her-finger GUI row's retirement in
favour of the real-finger unlock nicety row is an acceptable supersession — the end-to-end walk now proves the chain the
finger row was to prove. **MINOR-3 is CLOSED.**

### (c) NIT-3 — hollow to fix, record-only. **DISPUTE UPHELD.**

Verified the teardown ordering myself: every path flips `state = .opening` only after `await onWillLock?()`
(`AppBootstrap.swift:1066/1235/1318/1394/1467`), and the Mac's `onWillLock` (`MacWillLock.swift`, order load-bearing by
its own header) ends with `stopServices()` → `services?.stop(); services = nil` (`VariorumApp.swift:284–285`). The
provider's only consumers are the engines `AppServices` composes (`AppServices.swift:423/509`), created after ready and
gone before the window opens — so nothing can ask the provider between a teardown and the next ready, and no pin can go
red on this tree. My round-1 label already said as much ("a hollow finding if raised higher"); under the contract a row
no pin can turn red is recorded, not fixed. The implementer's routing (a named note for VX-329's live-road wiring, with
the account faces at VX-308) is the right home. **NIT-3 is CLOSED as recorded, not fixed.**

---

## New findings (this round's diff only)

### NIT-R2-1 · `App/Variorum/Shared/Protection/ProtectionCrossingActs.swift:228–231` (with `AppBootstrap.exportNoticeOwedKey`) · the durable mark is one per defaults domain, not per library — a later ready of a DIFFERENT library that is not in Castle clears a standing, un-acknowledged notice early

- **Mechanism (traced):** the mark is a single boolean beside the weekly switch. After an entry (notice owed, not yet
  *OK*'d), adopting a different Standard library (Make this my library) reaches a ready whose `reconcileExport` takes the
  not-Castle arm and clears the mark — the pane's notice disappears without her *OK*. A pin could go red on this tree
  (adopt-after-entry, assert the notice still owed), so I label the mechanism honestly rather than SPECULATIVE — but the
  RULES are silent on whether a notice survives swapping the whole library out, and the reconcile's own "she has since
  left" reading defensibly covers it. **The substance cannot be lost:** the switch-off always lands before any other
  library can stand at ready (the ordering traced under dispute (a)), and the cleared state leaves the switch OFF — the
  safe direction. **Disposition asked:** no fix this phase; carry one line into the VX-329/VX-308 hand-forward — when the
  live road lets more than one library stand at ready in Release, key the mark by library (the id in the mark's value
  instead of a boolean) so the not-Castle clear fires only for the library that wrote it. If anyone wants the notice's
  cross-library persistence as product behaviour, that is a QUESTIONS item, not a ruling here.

### NIT-R2-2 · `App/Variorum/Shared/Protection/RoadCrossingsModel.swift:186–200` · the landing rule keys on start order while snapshot order can invert — record-only, pre-existing class

- Both the old and the new rule number a read at `refresh()` entry, but the underlying read (`roads.read()` hops to a
  detached task) can execute out of start order: a later-STARTED read can carry an earlier snapshot, land, and block an
  earlier-started-but-fresher one. Not a regression (the old rule had the same property), converges at the next refresh,
  and no pin distinguishes it from legal staleness without gating the roads' internals. Recorded so a future reader
  doesn't "fix" the new rule back to `read == reads` (which re-opens the awaited-refresh defect) or mistake this note for
  one.

---

## Round-1 findings — re-check of the fixes (each against its recorded claim)

- **MAJOR-1:** fixed as ruled under dispute (a). The pins: `major1_anEntryStoppingPastItsSwapIsReconciledAtTheNextReady`
  (the crash idiom via `PlantedCustodyLeaf.failingDeletes`, the settle's resume, the follow, the once),
  `major1_theNoticeIsDurableUntilAnsweredAndOwedOnlyWhileItApplies` (the no-mark-on-refusal, the in-process tail, OK /
  Turn it back on / out-of-Castle clears), `major1_theNoticeIsReReadFromTheDurableMark` (the relaunch read), and the Mac
  bootstrap pin (red on its first run for the landing-rule reason, re-run green 15/2 per the record). Mechanism, pins and
  claims line up. CLOSED.
- **MINOR-1 (the per-account single-flight):** verified in `AccountVaultClient.swift:203–244` — the in-flight task
  carries its account and a token; a different-account caller never piggybacks (it runs its own fetch, whose signed-in
  gate refuses before any request composes); the token-compared defer never clobbers a replacement entry. The pin
  (`aPiggybackedFetchForAnotherAccountRefusesNotSignedIn`, gate-held, deterministic) runs green here; red-on-old holds by
  mechanism — the old code answered any in-flight task's value regardless of account. CLOSED.
- **MINOR-2 (the bounded attempt loop):** verified in `AccountVaultClient.swift:305–340` — at most one stale retry and
  one enroll, in any order; the previously-uncovered post-enroll stale now retried; a second enroll demand exits typed
  (`keyProofRefused`); a second stale exits typed (`challengeStale`); the loop is bounded by construction (every arm sets
  a one-way flag or throws); the same-master-only post-enroll hash refresh guard is carried unchanged. The pin
  (`aStaleChallengeThenAnEnrollDemandStillLandsTyped`, the scripted STALE-then-ENROLL order) runs green here; red-on-old
  holds by mechanism — the old shape's escape path was the retry inside the stale catch, which no sibling clause covers.
  CLOSED.
- **MINOR-3:** closed under dispute (b).
- **MINOR-4:** the `VariorumApp.swift` bottom-stack comment now names rule 27's banner only and says U2c dropped the
  split pair's line — accurate against `ProtectionRoadBar`. CLOSED (clarity class, no pin, as ruled).
- **NIT-1:** folded into P-VX307-U2b-3's bundle note at my round-1 disposition — the fold is in the plan (the chips
  nuance rides her page-prose call). CLOSED as routed.
- **NIT-2:** noted in the record with the do-not-"fix" warning. CLOSED as routed.
- **NIT-3:** closed under dispute (c).

## Clean bill (checked and found solid, this diff)

1. **Scope discipline:** the fix leg touches no `Sources/VariorumCore/Sync/` line; the wire-leaf fixes (custody wire,
   `Protection/Wire/`) are the orchestrator's — consistent with her kickoff cast ruling (U1 is Fable's unit, so its fix
   leg is same-model arbitration, correctly recorded as such). No core file in the U2a leg. Commits carry no attribution
   trailers; nothing rewritten.
2. **Release safety:** the reconcile runs only with a non-nil new-road session (`AppBootstrap.swift:641`); the mark is
   written only inside `cross` (new-road only); the leaf instrumentation and the walk switch are `#if DEBUG`; the
   suite-named export switch never falls back to the app's domain. The record's Release build check is consistent with
   what the diff could reach.
3. **The receipt seam:** `addReceipt` → queued on the session → drained once by `RoadStandingModel`'s `speak` setter —
   the route pin's `count == 1` assertion is meaningful (an empty drain fails it), and the crash-corner line is
   receipt-class under `receipt_style` with the pane's durable notice as the standing home (P-VX307-U2a-9, recorded).
4. **The walk-record corrections:** recipe row 5's new text (type, never press again; the leaf ids to read) matches the
   traced behaviour exactly; the close entry's walked re-arm row is consistent with the instrumentation the diff adds.
5. **Test honesty:** the headless MINOR-3 pin is labeled a behaviour pin (green both trees) rather than dressed as a bug
   pin; the finger-gated Mac pin is `.enabled(if:)`-gated with the reason in the gate; `PlantedCustodyLeaf.failingDeletes`
   is the minimal crash idiom; the `ReadGates` rig forces the race deterministically in both directions; the mutation
   reds are recorded with their restores.
6. **The fix-leg records** (`§6 U2a FIX LEG`, the close entries) match the diff commit-for-commit; every PENDING claim at
   the leg's close was either discharged by the orchestrator's recorded Mac run (171/33, the one red being the pin
   pre-fix; the re-run 15/2) or remains honestly PENDING (nothing claimed green that I could not locate).

**For round 3: nothing.** No new BLOCKER or MAJOR exists in this diff; the two NITs are record-and-route class.
