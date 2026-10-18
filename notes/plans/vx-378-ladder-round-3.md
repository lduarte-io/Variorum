# VX-378 ladder round 3 — cold review of the gate's two fixes

**Reviewer:** Fable (fresh, zero implementation context), 2026-10-18. **Diff:** `4a4af3164..c84375010` — the CODE in
the range is the two gate fixes (`7342fa75a` fix 1 / rule 20, `c84375010` fix 2 / rule 11); the two notes-only commits
in the range (`759509db3` the discovery run, `3b423ad95` §10 + the VX-306 plan) touch no `Sources`/`Tests` line.
Reviewed against `notes/CastleRules.md` (the contract), the gate's attempt-1 traces (plan §10, QUESTIONS
P-VX378-O2-1/O2-2), rounds 1–2 (`vx-378-ladder-round-1.md`, `-round-2.md`), `notes/SyncSpec.md`, and anything the
fixes touch. Code read and tests run in the read-only review worktree at `c84375010`; the revert checks in a clean
scratch extract outside it.

Format: `[severity] · file:line · what · evidence · fix`.

---

## Findings

**[NIT] · `Sources/VariorumCore/Protection/Executor/PlanRunner.swift:289-295` (the guard-off `settle` resume call
site) · Fix 1's new pre-commit rollback can throw an uncaught `ActRolledBack` out of `settle` on the DEBUG guard-off
branch, where `settleAct`'s surrounding `catch ActRolledBack` does not reach.** Evidence (traced; reachability
SPECULATIVE): the normal resume call (`PlanRunner.swift:328-331`) is wrapped `do { resume } catch let rolledBack as
ActRolledBack { return .rolledBack(...) }`, so fix 1's `throw ActRolledBack(... .passphraseDoesNotOpen)` (`:398`) is
converted to a `SettleOutcome`. The OTHER resume call — `:294`, reached only with `guards.planNamedBySectionOn ==
false` (a DEBUG mutation switch) and `library.section.actInFlight == nil` — has no such catch, so the same throw would
propagate as a raw `ActRolledBack` out of `settleAct`/`settle`, whose contract otherwise yields `SettleOutcome` (or
`SimulatedCrash`). In that branch `actInFlight == nil`, so the `rollBack(&library,…)` the fix runs first returns at its
own `guard let inFlight` (`:497`) having changed nothing — the throw is pure, no state corruption. To reach it at all
needs: the DEBUG guard off, a verified planted/replayed plan, no act in flight, the plan carrying a `passphraseKDF`,
a typed passphrase in hand, and ≥1 lock under that descriptor on this Mac that the typed passphrase fails to open —
a contrived combination no test exercises today, which is why no pin can redden it (label it honestly, don't fix on
spec). Fix shape (optional, defensive): wrap the `:294` call in the same `catch ActRolledBack { return
.rolledBack(...) }`, or precondition that the new pre-commit check only fires when `library.section.actInFlight !=
nil`. DEBUG-only, fail-safe; no production path and no behaviour pin — a NIT recorded so the guard-off path can't
surface an internal error type.

**[NIT] · `notes/plans/vx-306-castle-open-road.md` (the next-phase plan) · Fix 2 adds a required protocol method
`KeyFileStoreLeaf.catalogedKeyFiles(ofLibrary:)` that VX-306's PRODUCTION leaf must implement, but the VX-306 plan —
which landed in this same range (`3b423ad95`) BEFORE the fix (`c84375010`) and reads "as PLANNED" — never names it.**
Evidence: the method is new on the leaf protocol (`Leaves.swift:122`), implemented so far only by the two test worlds
(`World.swift:1131`, `ExecutorWorld.swift:351`); grep of the VX-306 plan finds no `catalogedKeyFiles` / "catalogued
key file" line. The obligation IS recorded in two places — the protocol doc-comment ("VX-306's production leaf
implements it over the real folders") and QUESTIONS `P-VX378-O2-2` — so a careful VX-306 session finds it; but a
session reading only its own plan file would miss a production leaf whose absence re-opens the seed-3 class (a
rolled-back stretch's silent item + Apple key surviving Castle entry). This is the same hand-forward class rounds 1
(N5) and 2 (NIT 2) recorded for VX-306's lobby feeders. Fix: one line in the VX-306 plan's leaf/open-road section
(or its §5-style hand-forward) naming `catalogedKeyFiles(ofLibrary:)` as a production leaf the open road must
implement — reading the real `Backups/<library8>/<mac8>/`, Previous Libraries and the shared folder, filtered to key
files whose own `libraryID` is this library's. Doc-only — no pin; the build does not break (no production conformer
exists in this phase).

*No BLOCKER, MAJOR or MINOR findings. Both fixes are faithful to the attempt-1 traces, scoped to their rule, and
rule-true; the two PROVISIONAL readings are the rule-defensible ones (below).*

---

## Clean bill — the two fixes, their pins, and the PROVISIONAL readings

1. **Fix 1 (`PlanRunner.resume`, rule 20, `7342fa75a`) — SOUND and rule-true.** Mechanism re-traced: before the
   commit point, a resume whose derived passphrase opens NONE of the locks this Mac holds under the plan's own
   descriptor (`PlanRunner.swift:393-406`) now `rollBack`s from what is on disk (staged file discarded, live key file
   restored from the plan's copy/mirror, the new key's items deleted by fingerprint — the established `rollBack`,
   `:487-575`) and throws `ActRolledBack` → `settleAct` returns `.rolledBack` (`:328-331`). PAST the commit point the
   `guard !plan.pastCommitPoint(...)` (`:398`) is false, so the old `throw ExecutorRefusal.passphraseDoesNotOpen`
   stands — post-commit behaviour is byte-unchanged; the fix narrows ONLY the pre-commit case from "refuse and stay in
   flight" to "roll back", exactly rule 20 ("the next open finishes the act or rolls it back from what is on disk, and
   says which") and consistent with the stuck-state her stuck-leave ruling removed. The new check is correctly guarded
   by `!locks.isEmpty`, so it is inert when this Mac holds no lock under that descriptor.
2. **Fix 1's pin is an honest red-on-old (my own revert).** `U4GatePins.aCrashedMakeMineThenAWipedKeychainRollsBack
   AtTheNextOpen` replays seed 2 seq 585 from its world seed (`2 &* 1_000_003 &+ 585`, the generator's own formula —
   `Generator.swift:311`) as its six-step minimal sequence. On HEAD: green. In a clean scratch extract of `c84375010`
   with ONLY `PlanRunner.swift` reverted to `4a4af3164`: `✘ … 3 issues` — the act in flight, copies paused, promise 6
   — matching the recorded count exactly. A true behavioural red-on-old.
3. **Fix 2 (`retireOldCustody` + `retireOwnAppleKeys`, rule 11, `c84375010`) — SOUND, scoped, and fail-safe.**
   Entering Castle now also sweeps the SILENT items for keys named by every CATALOGUED key file whose own `libraryID`
   is this library's (`CommonSteps.swift:197-206`, `vouched`), and retires the Apple keys those files are wrapped under
   (`:273-278`). Scope verified: `catalogedKeyFilesOfThisLibrary()` filters by `library.record?.libraryID`
   (`:228-230`), so another library's copy (a different `libraryID`, Look inside's quiet road, rule 17) is never
   touched — this is precisely why attempt-1 option (b) was rejected. `heldFingerprints` is label-only
   (`KeyFile.swift:308-311` — current + history fingerprints, no decryption, no secret), so the sweep knows a backup
   reaches a forgotten key without opening it, and without the backup's key. Over-sweep is fail-safe (rule 11 wants
   every quiet road to this library dead; deleting a silent item loses only a convenience, never data or a correct
   open); the common Castle entry is unchanged (the forgotten-key set is empty when the live history already holds the
   keys — `catalogued` is then a subset of `tree`, and the Apple union is a subset of the existing own/earlier sets),
   which is why the touched suites and discovery seeds 21-40 stay green. The two test-world leaves both implement the
   new method and both filter by `libraryID` excluding the live file (`World.swift:1131-1136`,
   `ExecutorWorld.swift:351-353`).
4. **Fix 2's pin is an honest red-on-old (my own revert).** `U4GatePins.aRolledBackStretchsSilentItemAndAppleKeyGo
   AtCastleEntry` replays seed 3 seq 310 (`3 &* 1_000_003 &+ 310`) from the "two Macs sharing an iCloud Drive backup
   folder" start state. On HEAD: green. In a clean scratch extract with ONLY `CommonSteps.swift` reverted to
   `4a4af3164` (the new leaf kept so it compiles): `✘ … 1 issue` at the `expectPromisesKept` assertion
   (`FixedScenarios.swift:29`, `found.isEmpty`) — a promise-1 violation (a login-password holder reaching a Castle-era
   backup) — matching the recorded count exactly.
5. **The two PROVISIONAL readings are the rule-defensible ones.** P-VX378-O2-1 (a): rule 20 forbids leaving an act in
   flight; option (b) is the stuck state her stuck-leave ruling removed — (a) is the only rule-true option. P-VX378-O2-2
   (a): rule 9/11 require no quiet road to this library survive Castle entry, and the catalogued backup vouches the
   forgotten key is this library's; option (b) breaks rule 17, option (c) ("stated limit") contradicts "Castle is
   Castle" — (a), scoped by `libraryID`, is the only option honouring rule 11 without breaking rule 17. Both carry
   their traces in QUESTIONS and plan §10; both are correctly marked PROVISIONAL for her eye, as her through-to-the-gate
   ruling directs.
6. **Both pins green on HEAD together:** `swift test --filter U4GatePins` → `✔ 2 tests in 1 suite`. The touched
   suites green on HEAD (my own run): `U4*`, `CutPins*`, `Lifecycle`, `CrossingTests`, `LeaveCastleTests` →
   `✔ 58 tests in 14 suites`; `ExecutorGuardTests` + `U2CrashHarnessTests` + `GeneratorTests` (default 2×8) +
   `WorldSmokeTests` green. The crash-safety oracle (promise 6, `Promises.swift:757-767`) and the four-things oracle
   (promise 7) are unchanged by the fixes and still red their planted breaches.
7. **Scope and hygiene.** The range's `Sources`/`Tests` changes are exactly the two fixes across six files
   (`CommonSteps.swift`, `Leaves.swift`, `PlanRunner.swift`, `ExecutorWorld.swift`, `U4GatePins.swift`, `World.swift`);
   no `Sync/`, `Server/`, `App/`, schema or migration line; no `Co-Authored-By`/`Claude-Session` trailer; the vault's
   new shape remains modelled in `VaultModel` only and the server `key_vault` change is still named as VX-307's
   SyncSpec §12 lockstep. The new leaf has exactly two conformers, both test worlds; no production conformer exists
   yet, so the build compiles clean (`swift test` built). Fix 2 reads the catalogue twice per Castle entry (once in
   `retireOldCustody`, once in `retireOwnAppleKeys`) — acceptable for a rare deliberate act, not P1-relevant (cost ∝
   this library's bounded copy count, never the corpus).
8. **The gate verdict is honestly still open.** §10's GATE_SOAK / GATE_VERDICT are PENDING — attempt 2 (discovery +
   gate soak on the final tree `c84375010`) is running in the main worktree, not yet landed. That is expected by the
   plan's own sequencing (gate item 1 re-runs both on the final tree after this ladder's fixes); it is not a finding,
   and round 3 reviews only the two fixes, as the brief directs.

*(Round-3 reviewer's note: the two NITs above are doc/defensive hand-forwards with no pin owed; neither gates the gate.
Both gate fixes are faithful to their attempt-1 traces, rule-true, and honestly red-on-old by my own reverts.)*
