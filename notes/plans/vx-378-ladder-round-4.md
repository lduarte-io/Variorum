# VX-378 ladder round 4 — cold review of the gate's checker fix

**Reviewer:** Fable (fresh, zero implementation context), 2026-10-18. **Diff:** `c84375010..66f7561e1` — the CODE in
the range is ONE commit (`66f7561e1`: promise 1's lagging-device clause, `Tests/VariorumCoreTests/Protection/Scenario/
Promises.swift:366-377`, and the pin `U4GatePins.swift:66-89`); the four other commits in the range are notes-only
(round 3's report and dispositions, attempt 2's discovery table, QUESTIONS P-VX378-O2-1/O2-2, the VX-306 plan's
obligations — zero `Sources`/`Tests` lines, diff checked). Reviewed against `notes/CastleRules.md` rule 10 and
promise 1's own rules 9/11/13, the gate's attempt-2 seed-8 trace (the plan's §10), rounds 1–3
(`vx-378-ladder-round-{1,2,3}.md` + the plan's §9), and `notes/SyncSpec.md`. Code read and tests run in the read-only
review worktree at `66f7561e1`; the revert check and the over-width probe in clean scratch extracts outside it.

Format: `[severity] · file:line · what · evidence · fix`.

---

## Findings

**[MINOR] · `Tests/VariorumCoreTests/Protection/Scenario/U4PromiseCheckTests.swift:21-30` (beside the new exemption,
`Promises.swift:374-377`) · The oracle suite's promise-1 plant covers only the SOLO (account-less) arm, so the new
synced-world `return []` has no standing red proof that a device that HAS followed is still held — the
checker-blindness class the suite's own header (:3-7, "a promise that can never fire would bless whatever the model
does") exists to prevent.** Evidence: the new clause is promise 1's first exemption keyed on per-device sync state;
`onePostureCatchesAQuietRoadToAnEarlierKey` builds `fresh(on: macA)` (`record.account == nil`, so the clause can
never fire there), and no test in the tree plants a promise-1 breach on a synced FOLLOWED device (grep). Today the
other side holds — **my own probe, executed in a scratch extract of `66f7561e1`**: the "a synced Castle account with
Touch ID on two Macs" start, macB launched, `record.accountRowKeyID == current` ASSERTED, a silent custody item for
macB's current key planted → `onePosture(macB, settled: true)` returns FOUR violations (the silent-item line, the
current key, an earlier key, macB's own backup copy) — so there is NO behavior bug and NO pin is owed (the arm is
coverage, green by construction). The hazard is forward-looking: a regression that left followed devices' records
stale (or a later widening of the clause) would blind promise 1 on every synced Castle world while every soak stayed
green — on the one promise that IS Castle, in the phase whose GO rests on soak greens. Fix: add the probe as a
permanent oracle arm in `U4PromiseCheckTests` (≈20 lines; its full text is in the appendix below) — and per round 3's
NIT-1 precedent, land it as VX-306's first commit (or fold it before attempt 3 starts) so the gate's soaked tree
stays the final tree; the orchestrator's call.

**[NIT] · `Tests/VariorumCoreTests/Protection/Scenario/Promises.swift:42-43` (the header's STATED LIMITS, L1) · L1's
parenthetical now under-describes the limit the code applies: "(it is still Standard; promise 1 is the followers')" —
after this fix a lagging device can be CASTLE-recorded (an earlier Castle stretch whose record names an earlier sync
key), and promise 1 exempts it too.** Evidence: the new clause fires only inside `onePosture`'s `record.mode ==
.castle` guard (:358-359) — exactly the shape L1's parenthetical says never reaches promise 1; the file header is the
subsystem's design record (rounds 1–2's standing bar), so a fresh session reading L1 would re-derive the pre-fix
reading and mistake the new clause for width. Fix: one line — e.g. "(it is still in its own earlier posture —
Standard, or an earlier Castle stretch whose record names an earlier sync key; promise 1 is the followers')".
Doc-only — no pin; the same defer-one-commit option as above.

*No BLOCKER or MAJOR findings. The exemption is exactly rule 10's stated boundary — no wider (both width questions
answered with executed evidence below) — and the pin is an honest, behavioral red-on-old by my own revert.*

---

## Clean bill — the exemption's boundary, the pin, and what I checked

1. **The exemption is provably "has not followed the account's current entry into Castle" — no other lag can win
   it.** `record.accountRowKeyID` is written only inside the planned key-change acts (`CommonSteps.swift:137/141` —
   `newRowKeyID ?? followedRowKeyID`, atomic with the swap) and at the join (`AccountActs.swift:208-210`); the
   account's `rowKeyID` changes ONLY at `VaultModel.enteringCastle` (:216-233, the sole row-key mint — `leavingCastle`
   (:241) changes no key, and `alreadyInCastle` enforces rule 15's "the sync key changes only when the account enters
   Castle"). So `record.accountRowKeyID != current` ⇔ not-followed-the-current-entry; a lag that "is not the account's
   re-entry" cannot produce the mismatch. A crashed follow cannot leave a followed-but-stale settled state: mid-act the
   outer guard (`actInFlight == nil`, :358) already skips the device, and rule 20's resume lands the act whole or rolls
   it back — both sides of which read correctly here.
2. **A device that HAS followed is held — executed, not assumed.** The scratch probe (finding 1): followed macB with
   the row-key equality asserted, a planted silent item → promise 1 fires with four violations. The guard chain
   (`record.mode == .castle` + `record.account != nil` + a live snapshot + the preceding account-standard early-out)
   means a SOLO library can never take the new exit, so the existing solo oracle
   (`onePostureCatchesAQuietRoadToAnEarlierKey`) is untouched — it ran green-on-clean/red-on-plant in my basket.
3. **What the exemption masks is own-day material only — read off the old checker's own red.** The revert run's three
   violation lines are macB's own current key, its own earlier key, and its OWN backup in its OWN container — all
   wrapped under the old master that macB's silently-filed Standard-era item holds; nothing of the new stretch.
   Rule 10 verbatim: "Until a device follows, it can still read what it already has — its own local copy — through its
   own quiet road. That is accepted and said plainly." The new stretch stays guarded WITHOUT promise 1: a silent item
   holding the account's CURRENT sync key is promise 3's clause on EVERY device, lag or no lag (`Promises.swift:
   527-530` — not gated on the record's row key), and a settled, signed-in, online device that failed to follow fails
   promise 3's "it doesn't hold the account's current sync key" (:546-553). A signed-out device genuinely cannot
   follow: `settleWorld` offers follows only to a session-matching online device (`Alphabet.swift:818-833`), and
   `.signOut` clears the session while leaving the record (:330-333) — rule 10's case, with rule 16 honored.
4. **The pin is honest.** (a) The seed formula matches the generator's own (`seed &* 1_000_003 &+ sequenceIndex`,
   `Generator.swift:311` → `8 &* 1_000_003 &+ 473`); the start-state lookup is unambiguous (exactly one name contains
   "Castle account with Touch ID" — `StartingStates.swift:112`); the four actions are §10's minimal sequence verbatim.
   (b) **My own revert:** a clean scratch extract of `66f7561e1` with ONLY `Promises.swift` reverted to `c84375010` →
   `✘ Test run … failed … with 1 issue` — exactly the record's count, the issue being promise 1 on macB (the three
   own-day lines above); on HEAD green. (c) `#expect(macB.slot?.record?.mode == .castle)` guards the scenario's
   load-bearing precondition (the rollback landed), so a drift onto the account-standard early-out path would be
   visible, not silently green. (d) The pin passes in BOTH configurations under my own hands (Debug; release
   `U4GatePins` 3/3).
5. **Blast radius green, my own runs on `66f7561e1` (review worktree):** `U4GatePins|U4PromiseCheckTests|
   U4LaggingPairScenarios` → `✔ 16 tests in 3 suites`; the wider basket `FixedScenarios|U2Pins|U4|WorldSmoke|
   GeneratorTests|MutationPins|Lifecycle|CutPins|CrossingTests|LeaveCastle|FollowTests|AccountAct|ExecutorGuard|
   AssessGuard` → `✔ 191 tests in 47 suites` (the default seeded generator — promises after every step — among them);
   release `swift test -c release --filter U4GatePins` → `✔ 3 tests in 1 suite` (the release build completing is
   rule 24's compile check on the final tree). The commit's "protection set Debug 388/149" coheres: pre-fix 387/149
   plus exactly one new test in an existing suite.
6. **Scope and hygiene.** The range's code is exactly `66f7561e1`: two TEST files, 37 insertions, 0 deletions, ZERO
   `Sources/` lines — a checker fix that cannot change model behavior; zero `Sync/`, `Server/`, `App/`, schema or
   migration lines; no `Co-Authored-By`/`Claude-Session` trailer; `Part of VX-378` present. The four notes-only
   commits carry round 3's record (committed unedited) and attempt 2's tables, consistent with everything I re-ran.
7. **The record is honest and the gate discipline held.** Plan §10 names attempt 2's NO-GO at seed 8 with the trace,
   the fix, the pin's red/green, the new FINAL TREE `66f7561e1`, and ATTEMPT 3 owed WHOLE on it (ATTEMPT3_PENDING,
   RELEASE3_PENDING) — gate item 1's both-runs-on-the-final-tree rule applied to its own fix, restarting rather than
   grandfathering attempt 2's partial greens. The checker fix carries no PROVISIONAL and needs none: rule 10's
   sentence is explicit ("That is accepted"), quoted verbatim, and the clause builds nothing beyond it; the "said
   plainly" half is the face phases' (the checklist's rule-10 row and VX-306/307 own the faces).
8. **Grammar consistency.** The new clause reuses promise 4(b)'s caught-up comparison (`record.accountRowKeyID ==
   vault.rowKeyID`, :664) rather than inventing a second lag notion; its placement — after the account-standard
   early-out, before L6's `fromOutside` — keeps the existing limits' precedence; the comment's "as promise 3 always
   did" is fair (promise 3 never held a signed-out lagging device to the account's current posture: L1 + the
   signed-in/online gates at :546-548), and the rules-checklist row 10 still reads true.

---

## Appendix — the probe (finding 1's proposed oracle arm, run green in my scratch extract of `66f7561e1`)

```swift
/// 1 (the synced arm) — the lagging-device exemption never swallows a device
/// that HAS followed: a silent item on a followed Castle device still fires.
@Test func onePostureStillCatchesAFollowedSyncedDevice() async throws {
    let world = SWorld(seed: 424_242)
    let synced = StartingState.all.firstIndex { $0.name.contains("Castle account with Touch ID") }!
    try await StartingState.all[synced].build(world)
    await world.done([.launch("macB")])
    let record = try #require(world.macB.slot?.record)
    let account = try #require(record.account)
    let current = try #require(world.server.snapshot(account)?.rowKeyID)
    #expect(record.accountRowKeyID == current, "macB should have followed in this start state")
    #expect(world.onePosture(world.macB, settled: true).isEmpty, "clean before the plant")
    let key = try #require(world.macB.library?.key)
    world.macB.keychain.local[KName.custody(SWorld.scope, PF.fp(key), .silent)] = KItem(value: .key(key))
    #expect(!world.onePosture(world.macB, settled: true).isEmpty, "promise 1 must still fire on a followed device")
}
```

*(Round-4 reviewer's note: the MINOR is coverage for the checker itself — no pin owed, nothing red today, proven by
the probe; the NIT is doc-only. Neither gates the gate; both can ride VX-306's first commit so attempt 3's tree stays
`66f7561e1`. The fix under review is faithful to rule 10's letter, no wider than its stated boundary in either asked
direction, and its pin is a true behavioral red-on-old by my own revert.)*
