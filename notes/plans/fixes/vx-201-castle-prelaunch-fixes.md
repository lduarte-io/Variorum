# VX-201 — Run: Castle pre-launch fixes (the record)

**Status: OPEN — kicked off 2026-10-13 (architect shape, Fable orchestrator; her kickoff message named the
pre-build assessment below as the first deliverable). Branch `vx-201-castle-prelaunch-fixes` (cut from
`origin/vx-191-encryption-audit`, main merged in at kickoff), worktree `~/dev/variorum-vx-201`, the Pro.**

**Binding principles:** the 13b constitution P-1…P-9 binds this run verbatim as carried in
`.claude/skills/architect-phase/SKILL.md` (in-repo; copied by pointer for record leanness — the one recorded
deviation from the copy rule). CLAUDE.md's standing rules, the author-only list, SyncSpec §12, and the
hallucination guard (pin-before-fix PER MEMBER, red-on-old verified by revert) bind as everywhere.
**Product frame (leads every brief):** this is the author's own writing app hardening its OWN privacy promises
before public release — when the app says Castle, nothing current may still open the old way. Defensive work on
her code, at her request.

## KICKOFF MESSAGE (paste into a fresh session)

> /architect-phase vx-201
>
> This is RUN VX-201, "Castle pre-launch fixes" — seven members, all from the VX-191 encryption & Castle audit,
> all ruled pre-launch by the author on 2026-10-12/13. **Product frame first** (it keeps the safeguards calm): this
> is the author's own writing app hardening its OWN privacy promises before public release — making sure that when
> a user turns on Castle, the app never says "Castle" while something current is still reachable the old way.
> Defensive work on her code, at her request.
>
> **Branch:** create `vx-201-castle-prelaunch-fixes` FROM `origin/vx-191-encryption-audit` (it carries the audit
> record you need), in a fresh worktree `~/dev/variorum-vx-201`. The one PR (`VX-201: …`, merge commit) carries both
> VX-191's record and this run.
>
> **Read first (after CLAUDE.md's preflight):** `notes/plans/fixes/vx-191-encryption-audit.md` WHOLE (§O.3, §V, §W,
> §W.1, §W.2, §X are the briefs), the three auditor reports under `notes/plans/fixes/vx-191-audit/`, `notes/SyncSpec.md`
> (custody seams), `notes/plans/pre-13x-postures-design.md` §1, §3.4, §4, §14, and this file. The Linear tickets carry
> her rulings as comments — read each member's comments.
>
> **Members (pin-before-fix PER MEMBER; red-on-old verified by revert):**
> 1. **VX-202** — the re-key reopen's detached `saveAuto(L′)` (`AppBootstrap.swift:520-530`) races the custody move's
>    `deleteAuto` (§O.3). Fix: no re-save while a switch marker is set / a switch is in progress; belts: a lingering
>    silent item under a DEMANDED gate is deleted at ready, never read as posture; the route's landing arm
>    (`StoreLaunchGate.swift:367-376`) never lands mid-switch. Pin at the BOOTSTRAP level (the existing pins inject
>    their own `rekeyLibrary` and never exercise the production reopen) with a held `saveAuto`.
> 2. **VX-110** — signed out with sync custody held, Use Castle offers TWO doors: **Sign In…** (the account-wide
>    switch) and **Use Castle on This Mac Only** (forget the old account's keys here via the existing
>    `EncryptionSession.forgetDeviceKeys`, then the local road, with an HONEST Done: this Mac's library is in Castle;
>    the old account's sync copy is unchanged — delete that account if you still can). Signing back into the old
>    Standard account then lands on the join consent (Join / Cancel), never a silent revert. Also: de-cap
>    "ACCOUNT" in `ProtectionCopy.joinStandardConsent` and give that sentence a wording pass (her no-caps rule).
>    A flat "refuse unless signed in" is WRONG — it traps the lost-account user (§W).
> 3. **VX-203** — the Castle "delete old backups" offer must also reach `Previous Libraries/*/` and
>    `Backups/safety-copies/*/` (Standard-era whole-library copies), or at minimum name them (auditor B1d).
> 4. **VX-204** — the field guide's "everything is encrypted" (`PostureCopy.swift:781`) overstates; dates, tag-tree
>    shape, memberships, flags and sizes travel plain (the website privacy brief already says so). One sentence.
> 5. **VX-206** — entering Castle (run from Settings ▸ Protection) must END on Protection with its info popup showing,
>    not on General.
> 6. **VX-208** — ONE line in the Castle process: plaintext `.md` exports written before Castle aren't covered — delete
>    them yourself. No delete offer of our own (her ruling).
> 7. **VX-209** — a Castle library silently becomes Standard after Open Library / Restore of a Standard-era backup or a
>    plaintext export — and even on the way BACK for a backup of the same library (§W.2's trace — verify it with a pin
>    before building on it). Pre-launch scope (her rulings): a **confirmation line** on the Open/Restore confirm when
>    the current library is Castle and the incoming one reads Standard, and a **field-guide warning** in the Castle
>    section with instructions for reading an old backup (today's honest instruction: afterwards check Settings ▸
>    Protection and choose Use Castle again — re-verify against the fix you land). The deeper fix (corner 45 must not
>    read a previously-Castle store id as Standard-waiting) is welcome if it falls out of VX-202's belts; else ticket it.
>
> **Copy is hers:** every NEW or changed user-facing sentence (VX-110's Done + consent, VX-204, VX-208, VX-209's
> confirm line + guide text) is drafted, bundled in `notes/QUESTIONS.md`, and presented to her before it ships —
> PROVISIONAL until she approves. Sentence case, no capitals for emphasis.
>
> **Cast & review:** strictly sequential per CLAUDE.md; members 1, 2 and 7 touch custody/keychain ⇒ the cold review is
> Fable (`fable-reviewer`, `notes/REVIEW_PROMPT.md` verbatim) over the whole run's diff; the author may redirect
> (VX-99 moved to Opus at her word when Fable's safeguards fired — lead every brief with the product frame above).
> Phone parity: the Castle doors are `Shared/` — the phone compiles and its faces get the same copy.
>
> **Environment:** this is the ONE `Sync/`-or-custody effort in flight — check the in-flight table and declare it;
> every `xcodebuild test` needs a held `Tools/stage` claim (an `oct12coordinator` may be scheduling the Pro stage —
> ask it). Headless `swift test` runs freely. Record: this file (`notes/plans/fixes/vx-201-castle-prelaunch-fixes.md`),
> LIVE STATUS from the first commit, push after each piece. Close with the `/Applications` refresh at a zero-instance
> window, the PR (merge commit), members closed individually, VX-191 closed with it.

## §A — PRE-BUILD ADVERSARIAL ASSESSMENT (the orchestrator, 2026-10-13 kickoff; her ask: a second layer over the audit agent's self-authored tickets, VX-110 and the backup-adoption roads especially)

Method: every ticket-cited code site re-read at this branch's HEAD by this orchestrator (not delegated, not
trusted from the audit record): `AppBootstrap.swift:526-531` (the detached R1-M3 re-save) and `rekeyLibrary`
(:810-841), `PostureSwitch.swift:521/:535` (the enrolled guard) and the local road (:693-700),
`EncryptionSession.forgetDeviceKeys` (:579-583), `StoreLaunchGate.effectiveGate`'s landing arm (:362-383) and
`rawKeyCustody` (corner 45). **Every cited mechanism is real as described.** The members stand; the refinements
below are BINDING on the briefs. Verdict per member:

**VX-202 (the reopen race) — CONCUR, with four binding refinements.**
1. *Coverage, not just the ceremony:* the ceremony, the follow (both arms) and the marker RESUME all reach
   `rekeyLibrary` → the same reopen → the same R1-M3 arm. The fix must cover every reopen that is part of a
   switch. An in-memory `switchInProgress` on `AppBootstrap` (set by `rekeyLibrary`, cleared after the runner's
   custody move) covers the live path; the persisted `RotationMarker` covers a crash-resume's reopen. Prefer both.
2. *Belt (b) safety:* the at-ready sweep (a lingering silent item under a DEMANDED effective gate is deleted,
   never read as posture) must key on the CURRENT store id and fire only when the silent item's key is NOT the
   only opener left — i.e. the live key file carries P/W wraps for it or the gated item verifies. Under custody
   law that is always true in Castle, but the belt must check, not assume (a hand-damaged key file must not
   become an unopenable library). It must also stay inert during a 13x adoption's deliberate `landCustody`
   window (dials there reset to Auto, so the gate is not demanded — verify with a pin, don't assume).
3. *Belt (c) reality check:* the route's landing arm runs PRE-OPEN — `RotationMarker` is a database read and
   cannot be consulted there. The belt needs a store-id-scoped signal outside the DB (the dials' UserDefaults
   home is the natural neighbor): written when a switch begins, cleared when custody lands. This same signal is
   the only cheap road to VX-209's deeper fix — see VX-209 below for why we do NOT stretch it that far tonight.
4. *The pin:* must exercise the PRODUCTION reopen (`AppBootstrap.rekeyLibrary` → `beginOpening` → ready → the
   R1-M3 arm) with the utility save HELD until after the custody move — red on old by revert. The existing
   switch pins inject their own `rekeyLibrary` leaf and prove nothing here (the audit's own observation,
   re-confirmed: `PostureSwitchTests.swift:763`, `PostureSwitchDrillTests.swift:478`).

**VX-110 (the two doors) — CONCUR with her ruled design; five things the ticket does not say, each binding.**
1. *Crash ordering is the whole game.* If the forget runs LAST and the session dies between the re-key and the
   forget, custody still holds the old account's material — the next sign-in to that account is the silent
   follow-into-Standard revert, the exact bug. The forget must happen EARLY in the This-Mac-Only road (before or
   atomically with the custody move) AND be carried by the marker's resume so no crash window leaves it undone.
   Pin the crash window (kill between re-key and forget; the resume completes the forget).
2. *`forgetDeviceKeys` keeps the device identity* (read at :579 — material goes, identity stays). That is the
   RIGHT shape: a later sign-in to the old account is an ENROLL (the join consent — `EncryptionViews.swift:431-466`),
   and the identity-only custody record keeps the route's landing arm SKIPPED (`enrolled = syncCustodyPresent`),
   so the Castle shape is protected at every later launch. Both facts get pins, not prose.
3. *Her multiple-accounts worry, answered structurally:* custody is per STORE ID and holds exactly ONE account's
   material (the last enrolled — decision 17's adopt road replaces it). So "the old account" is singular per
   library, and forgetting on this library never touches another library's custody. The brief demands a pin:
   two stores, two custody records, forget on one, the other intact. The remaining multi-account corner —
   sign-in to a NEW account after This-Mac-Only — takes the sync-setup road, and a Castle library's vault is
   born Castle (decision 17 + corner 26). The audit flagged that road as NEVER EXERCISED BY TESTS; the Done copy
   leans on it ("delete that account… set up again"), so U2 lands a state-transition pin for born-Castle setup
   from a Castle library, or the Done copy drops the implication.
4. *The gate for the two doors* is "signed out AND sync custody material held" — the state from which the silent
   revert is reachable. A signed-out library with an enrolled-SHAPED key file but NO custody material cannot
   silently revert (its sign-in is an enroll with consent), so it keeps the plain local road; a genuinely
   pre-sync library is untouched (the kickoff's own line). The Sign In… door routes to sign-in and ends the
   ceremony (re-press after signing in); auto-resuming a custody ceremony across an async sign-in is
   choreography risk for zero honesty gain — PROVISIONAL, bundled.
5. *The phone:* the runner and copy are `Shared/`, but the audit never read the phone's door conditions
   (`MobileProtectionSheet`). U2 confirms the phone's Use Castle door state when signed out and gives it the
   same two-door or refusal shape — never the old silent local road with the ordinary Done.

**VX-203 (the offer's missed folders) — CONCUR; three bounds.** (1) The lister offers only folders whose key
file carries an `apple` wrap — a Castle-era prior library in `Previous Libraries/` is not Apple-openable and
must not be swept into a "Standard-era" delete. (2) Granularity is the whole `<stamp>/` folder with honest
counts in the confirm, and the offer's words must say these are the step-aside/way-back copies (the adoption
confirm called them a recoverable home — deleting them closes that road; the sentence owns it). (3) The same
lister serves the follow road (B1d's rider). `Backups/safety-copies/` matching stays on the adopt-safety naming
plus key-file inspection — never a blanket folder delete.

**VX-204 (the guide sentence) — CONCUR, copy-only, one structural consequence:** the paragraph is SEEDED
(`TutorialSeeder` + `MobileTutorialSeeder` share `PostureCopy.privacyLessonOneParagraphs`), so existing stores
keep the stale sentence — the closeout re-seeds her real store's field guide behind the A1 rail (the standing
closeout rule), and the phone's seeder ships the same words. Draft rides the QUESTIONS #215 bundle.

**VX-206 (end on Protection) — CONCUR; one coordination fact:** VX-214 (settings panes polish, live, author-
attended) owns the Settings panes' internals this week. U4 keeps this diff to the ceremony's LANDING (restore
the Protection selection + its popup across the re-key teardown), never pane internals; the overlap is declared
on the in-flight row and to the coordinator.

**VX-208 (the one line) — CONCUR as ruled** (no delete offer of our own). Home: the insurance-off notice's
neighborhood (`PostureCopy.swift:434-437`) so the line appears exactly where the export story is told.
PROVISIONAL placement, bundled with the copy.

**VX-209 (the way-back revert) — CONCUR with her pre-launch scope, and a deliberate refusal of the deeper fix
tonight.** The confirm line (outgoing Castle + incoming reads Standard, plaintext exports included) and the
guide warning both land. The deeper fix — corner 45 remembering "this store id was Castle" — looks one belt
away via VX-202's store-id signal, but it can STRAND a user: a pre-Castle Standard-era backup may carry NO
passphrase wrap (silent-only era), so forcing a demanded gate on a remembered-Castle store id would leave that
backup openable only by the twelve words, or not at all. That is a design sitting's tradeoff, not an overnight
belt (QUESTIONS/ticket per the kickoff's "else ticket it"). SEQUENCING: U5 (VX-209) runs AFTER U1 lands so the
guide's instruction is written against the shipped behavior, not the pre-fix one.

**Cross-cutting (binding):** every new or changed user-facing sentence is PROVISIONAL and bundles into
QUESTIONS **#215** before the PR merges; sentence case, no capitals for emphasis (VX-110's consent de-cap
included). This run is the ONE custody effort in flight (declared; VX-179's custody line closed before our
kickoff). All `xcodebuild test` under stage claims via `oct12coordinator`; headless `swift test` free. Mac-suite
closeout coverage follows the changed-SOURCE rule (grep tests for changed types, not changed test files).

## §B — ACCEPTANCE UNITS (strictly sequential; ONE implementer session each; evidence named)

| unit | members | evidence that closes it |
|---|---|---|
| U1 | VX-202 | the bootstrap-level race pin red-on-old by revert through the PRODUCTION reopen; belts (b)/(c) pinned incl. the adoption-window inertness; existing switch/drill suites green (stage) |
| U2 | VX-110 | state-transition pins: two doors offered on the gate state; forget-then-sign-in lands the consent, never the follow; the crash-window resume completes the forget; two-store custody isolation; born-Castle setup pin (or Done copy softened); the consent de-capped; phone door confirmed |
| U3 | VX-203 + VX-208 | lister pins red-on-old (apple-wrapped stamp folders listed, Castle-era ones not; follow road too); the confirm's honest counts; the one VX-208 line landed PROVISIONAL |
| U4 | VX-204 + VX-206 | the guide sentence landed on both seeders PROVISIONAL; ceremony-from-Protection ends on Protection with the popup (walk-verified); zero pane-internal lines (VX-214 overlap) |
| U5 | VX-209 | FIRST a pin REPRODUCING §W.2's round-trip trace at HEAD (open a Standard-era backup of the same library, bring the Castle library back — lands Standard; the trace was read, never run — her carried-forward reminder 2); then the Open/Restore confirm line pinned on the classifier (backup pair + plaintext export arms); the guide warning written against U1's landed behavior AND the reproduced trace, PROVISIONAL |

Then: the fable ladder over the WHOLE run diff (members touch custody) with `notes/REVIEW_PROMPT.md` verbatim;
round 2 re-reviews fixes; my hands-on walk of the ceremony + the two doors on the dev store under a stage claim;
the QUESTIONS #215 copy bundle; closeout per the skill (refresh at a zero-instance window via the coordinator,
PR merge commit, members closed individually, VX-191 closed with it, her real store's guide re-seed behind A1).

## ENVIRONMENT TRAPS (every brief carries this verbatim)
Instance checks: `pgrep -fl 'Variorum.app/Contents/MacOS'` AND discriminate by PATH; real-store instances are
treated by STORE and never quit/killed; no Release builds or `/Applications` refreshes while one lives. Mac
tests from `App/Variorum/`, suite-level `-only-testing` only, confirm the "Test run with N tests" line; NEVER a
custom build configuration. zsh `pipestatus`. Backups WAL-safe, UTC names, into `Backups/safety-copies/`,
ALWAYS before touching the real store (A1). Never `git checkout` over uncommitted work; push after every
commit; synchronous foreground waits only (poll, don't `tail -f`). EVERY `xcodebuild test` needs a held
`Tools/stage` claim granted by `oct12coordinator` (READY → GO; release + one-line result after). Headless
`swift build`/`swift test` on the core package runs freely. The real Keychain drills (`PostureSwitchDrillTests`)
are stage work. Work ONLY in `~/dev/variorum-vx-201`.

## §C — U1 BRIEF (VX-202: the re-key reopen's silent re-save race — ONE implementer session, Opus xhigh)

**Product frame first:** this is the author's own writing app hardening its OWN privacy promise before public
release — after entering Castle, nothing current may still open the old way. Defensive work on her code, at her
request. You are the U1 implementer. Work ONLY in `~/dev/variorum-vx-201` (branch
`vx-201-castle-prelaunch-fixes`). Append your record as `## U1 RECORD (VX-202)

**Not done in this unit (stated first):** no `xcodebuild test` of any kind was run (stage work, per §C) — every pin
result, every red-on-old run and every existing-suite result below is **PENDING** the orchestrator's stage window;
no walk (U1 has no face; the brief names the pins as its evidence); the phone's `MobileProtectionTests` (simulator)
not run; the ordinary-road ordering belt (the save on the custody queue) has no deterministic pin; the VX-209
deeper fix ("ever was Castle") deliberately not built; the local-only race OUTCOME already on disk is not healed by
either belt (finding F2). Zero lines in `Sources/VariorumCore/Sync/`, zero user-facing copy, no schema, no
`notes/QUESTIONS.md` entry (no product call was made; that ledger is merge-moment-only).

### LIVE STATUS (closed 2026-10-13 ~01:40; PENDING = unverified)
- Reading done in this session, never delegated: this file whole, the VX-191 record whole, `notes/SyncSpec.md` in
  full, the postures design §1/§3.4/§4/§14, `notes/SessionResiliencyProtocol.md`, the VX-80 record; the code named
  in §C plus `LibraryOpenModel.landCustody`, `PostureSwitchModel`/`PostureFollowModel`, `Posture.derive`, and the
  existing pins (`PostureSwitchTests`, `PostureSwitchDrillTests`, `Phase13pControllerTests`,
  `VX80CastleFollowRecoveryTests`, `Phase13pLobbyTests`, `MobileWindowReplayTests`).
- DONE 64c96bfe (the fix) · ffbcbd61 + 1d97f52d (the pins) · c2f188b7 (the revert patches) · this commit (record).
- VERIFIED here: `build-for-testing` green for `Variorum` (macOS) and `VariorumMobile` (generic iOS Simulator), zero
  warnings in the changed files; all six revert patches `git apply --check` clean AND compile (R-a1+R-c+R-d1+R-d2
  together, R-a2 alone, R-b alone — they share one hunk pairwise), tree restored to the committed fix each time.
- DerivedData: the run-tagged `App/Variorum/DerivedData/vx201` (gitignored; 2.4 GB after the Mac build, the phone
  build added to it) — built with `COMPILER_INDEX_STORE_ENABLE=NO`. `df -h` (data volume): 134 MiB free at the
  ENOSPC (~00:58) · 32 GiB at 01:20 after the coordinator's cleanup · 51 GiB at 01:35 after both builds.
- ENVIRONMENT INCIDENT (~00:58): the Pro's data volume hit 100% during my FIRST build-for-testing (default
  DerivedData path). I removed exactly that build's folder (`~/Library/Developer/Xcode/DerivedData/Variorum-
  diwnyrznuwxhklevjvupjqqgktgr`, 2.0 GB, created by it, its info.plist naming this worktree) and, after the
  coordinator's note, the same-path folder of my second build; nothing else was touched. Standing consumers then
  (read-only): DerivedData 35 GB across worktrees, CoreSimulator 32 GB, /private/tmp 9.4 GB, macOS update snapshots
  (one `MSUPrepareUpdate`).

### What landed (the mechanism, per leg)
1. **Gate i — `AppBootstrap.switchInProgress`** (in-memory, distinct from the controller's model-set flag): set by
   `rekeyLibrary` synchronously before its reopen; cleared ONLY by the runner after `moveCustodyForSwitch` returns
   (`Leaves.endSwitch`, wired in `.live` to `bootstrap.endSwitch()` on both platforms; inert default for scripted
   worlds). The R1-M3 arm's condition requires it clear, so the switch's own reopen schedules nothing. A road that
   throws before custody leaves it set (the switch is pending); the resume's custody move clears it.
2. **Gate ii — the marker**: on every other ready the arm schedules a MainActor task (`AppBootstrap.relanding`,
   test-visible like `opening`) that reads `readSwitchPending` (the persisted `RotationMarker`), then RE-READS both
   in-memory flags and requires the key to still be the key in hand, then saves through
   `ProtectionController.relandSilentItem` — on the controller's serial custody queue, enqueued synchronously after
   the checks, so it runs before any custody move enqueued later (ordering by construction; the old save was a
   detached utility task). The marker read happens only off the switch's road (gate i), as §C requires.
3. **Belt b — `ProtectionController.sweepLingeringSilentItem`**, first act of every reconcile after the vault read:
   fires only when (after the bootstrap adopted; no switch in flight; no marker) a silent item AND the gated item both
   exist, and the posture derived with the GATED item as the custody shape is a DETERMINED Castle (the vault's word,
   or the local rule; indeterminate writes nothing — decision 35). Safety: the silent key opens nothing current (the
   resident this ready opened with is another key) OR the live key file carries a passphrase/twelve-words copy of it
   by explicit fingerprint — else left, logged. The delete is the guard's (production: `StoreKeyKeychain.delete`,
   DP-flagged); a silent item that was the open's key stays in hand as the resident.
4. **Belt c — the store-id flag**: `StoreLaunchGate.switchPending`/`setSwitchPending` (live: `ProtectionDefaults`
   key `variorum.protection.<scope>.<storeID>.switchPending`, beside the dials; scripted: `ScriptedSwitchPendingBox`,
   inert default). The runner keeps it mirroring "the marker names a step before custody landed": set BEFORE writing
   a `.vaultWrite`/`.reencrypt`/`.rekeyLibrary`/`.custody` marker (and again once the new key file exists), cleared
   AFTER the `.snapshot` marker or any marker clear (end of road, `restartRequired`, the CAS→follow hand-over). The
   route's landing arm (`effectiveGate`) refuses while it is set — which also covers `currentEffectiveGate` and
   `landCustody`'s reads of the same function.

### The pins — `VariorumTests/VX202ReopenRaceTests` (10 tests) and the red-on-old protocol (ALL PENDING, stage)
Run green first, then each revert: `git apply notes/plans/fixes/vx-201-u1-reverts/<R>.patch`, `build-for-testing`,
`test-without-building -only-testing:VariorumTests/VX202ReopenRaceTests`, read which tests fail, then
`git checkout -- App/Variorum/Shared/` (the fix is committed; nothing else is uncommitted there).
| pin | test | expected red under |
|---|---|---|
| (a) the race, production reopen, save held past the move | `theReopensSilentSaveHeldPastTheCustodyMoveLeavesNoSilentItem` | **R-a1** (arm pre-fix): silent L′ after release + the relaunch opens without a lobby · **R-a2** (gate i removed): `relanding` non-nil |
| (b) post-crash marker | `aPendingSwitchMarkerKeepsTheRecoveryUnlockFromReLandingTheSilentItem` | **R-b** (marker unread): B lands silent |
| (b) control (VX-80 heal, no marker) | `withoutAMarkerTheRecoveryUnlockStillReLandsTheProvenKey` | green under every revert except R-a1 (its `scheduled` assert) |
| (c) sweep, local Castle | `theSweepRemovesASilentItemBesideTheGatedOneOnALocalCastleLibrary` | **R-c** (sweep not called): silent stays, posture Standard, the Apple arm wraps L′ under A |
| (c) sweep, enrolled Castle | `theSweepRemovesTheLingeringSilentItemOnAnEnrolledCastleAccount` | **R-c** |
| (c) safety: the only road in | `theSweepLeavesASilentItemThatMayBeTheOnlyRoadIn` | green both sides (a bound) |
| (c) corner 45 untouched | `theSweepLeavesAStandardWaitingLibraryAlone` | green both sides (a bound) |
| (c) adoption-window inertness | `theSweepIsInertOnEveryShapeTheAdoptionLandsCustodyIn` | green both sides (three `landCustody`/plaintext shapes) |
| (d) the landing arm | `theRoutesAppleLandingRefusesWhileASwitchIsPending` | **R-d1** (flag ignored): the copy lands |
| (d) the flag's life + resume | `theSwitchPendingFlagSpansExactlyTheCustodyPendingStepsAndTheResumeClearsIt` | **R-d2** (runner writes no flag) |
Expect "Test run with 10 tests" for the suite (no `.enabled(if:)` gates in it).

**Existing suites (changed-SOURCE rule — every Mac suite that drives the bootstrap, the controller's reconcile or
custody, the runner, the gate or the adoption) — PENDING, one stage run** from `App/Variorum/`:
`xcodebuild test-without-building -scheme Variorum -destination 'platform=macOS' -derivedDataPath DerivedData/vx201`
plus `-only-testing:VariorumTests/` + each of: VX202ReopenRaceTests VX80CastleFollowRecoveryTests PostureSwitchTests
Phase13pControllerTests Phase13pLobbyTests StoreLaunchRouteTests Phase13pKeyedDrillTests LobbyVaultRoadTests
LibraryPortabilityDoorTests AppleRelinkDoorTests AppBootstrapOffMainTests CustodyReleaseTests KeyDoorTests
WordsCopyDoorTests CopyRegisterPinTests ProtectionMigrationTests ProtectionSurfaceRenderTests ProtectionTierFaceTests
ProtectionDialsTests ProtectionDialsPerStoreTests ProtectionCopyTests ProtectionCadenceTests StoreKeyGuardBackingTests
RetiredNamesPinTests SyncLockedFaceTests EncryptionFlowTests CopyFlowRoundTests CrossoverRoundTests
AccountLifecycleDoorTests AccountDoorWiringTests TerminologyPinTests FreshAccountSetupGeneralityTests
AuthSessionLazyLoadTests EncryptionCustodyThreadTests ProtectionSetModeOffMainTests ProtectionReconcileOffMainTests
PostureSwitchDrillTests ProtectionMigrationDrillTests (the two drills are opt-in: add
`TEST_RUNNER_VARIORUM_POSTURE_DRILL=1` / `TEST_RUNNER_VARIORUM_MIGRATION_DRILL=1` for the brief's "drill suites
green", and read their `skipped:` lines otherwise). Phone (simulator stage): `VariorumMobileTests/MobileWindowReplayTests`
(the one existing follow through `bootstrap.rekeyLibrary`; gate i makes its `backing.auto == nil` deterministic).

### Findings for the orchestrator (dispositions owed by the run, none acted on beyond the brief)
- **F1 — belt b's "demanded effective gate", interpreted (PROVISIONAL, the orchestrator's to confirm).** Read off the
  route's derivation it is unreachable for a local-only library: the lingering silent item IS corner 45's evidence
  (silent ⇒ Standard-waiting ⇒ `.auto`), so the leg would be hollow. Built instead on the custody law's own
  discriminator: two items for one key (silent beside gated) + the posture read with the GATED shape, determined.
  Without a gated item the silent item is the shape (Standard-waiting, a never-followed device, Always ask) and the
  sweep never acts — the follow/enroll machinery owns those (an enrolled Always-ask lingering item is healed by the
  standing enroll-join re-key; a local-only Always-ask one is gate i's to prevent).
- **F2 — the local-only race OUTCOME already on disk (a pre-fix build's) is NOT healed by either belt.** At the next
  launch the route's landing arm wraps L′ under A before any ready (belt c refuses only while a switch is pending;
  custody had landed), after which the library is genuinely Standard-shaped and the sweep has nothing to act on.
  Gate i prevents new instances. A "gated item present ⇒ never land" refusal at the landing arm would catch it — NOT
  built (§C: do not stretch belt c); candidate for VX-209's deeper-fix ticket.
- **F3 — VX-80's designed heal is overridden while a marker is pending** (§C's gate ii, exactly VX-80's stranded
  state): a switch crashed between swap and custody now asks the passphrase at every relaunch until the pane's
  resume, instead of re-opening silently. VX-80's own pin stays green (its store carries no marker); its doc
  sentence "losing this heal would re-strand every relaunch" now reads true only for the marker-less class.
- **F4 — a wrong-key silent item with NO marker on a Castle-shaped key file** (stale save or corruption) is still
  healed to the current key by the R1-M3 arm, and on a local-only library the next route can then land A — the
  corner-45 class (VX-209 territory). The one in-app road to that state I found (an ordinary ready's save delayed past
  a later switch) is closed by the custody-queue ordering + the key-in-hand check; not pinned (needs a production
  seam to hold the marker read).
- **F5 — adoption corner:** `landCustody` ignores its own delete results; if `deleteGated` is refused on the Auto
  arm, a silent K_in can sit beside a stale gated item on a Castle-era pair, and the sweep would remove the silent
  item at the next ready (the library then asks instead of opening silently). Not pinned; the state is already a
  custody-law violation. Also verified (§A's premise): the adoption's inertness comes from the custody SHAPE and the
  key file, not the dials (dials carry only Castle's gate style; `ProtectionDials()` never makes a gate undemanded).
- **F6 — her devices at the refresh:** the sweep can act on her REAL store at the first ready of the new build (a
  lingering silent copy beside the gated item on a determined-Castle library is removed, logged "custody sweep: …");
  that is the belt working, but it is a custody write on her store — worth naming at the A1-railed refresh.
- **F7 —** `MobileWindowReplayTests` composes the runner without the new `endSwitch` leaf (inert default): the
  bootstrap flag stays set after its follow, harmless to its assertions; production `.live` wires it on both
  platforms.
