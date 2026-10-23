# VX-488 — Run: the 0.10 window hotfixes (VX-487 · VX-486 · VX-483)

**STATUS: OPEN (kickoff 2026-10-22, the takeover orchestrator — Fable, `/architect-phase vx-488`; she is live and
ruling).** Branch `vx-488-window-hotfixes`, worktree `~/dev/variorum-vx-488`; ONE PR titled `VX-488: …` at the close.
The world-state and the window's remaining steps are `notes/handoffs/vx-488-kickoff.md` (read it whole); in one
breath: VX-329 is merged, the marker-14 production deploy is DONE and verified, the Pro runs 0.10 (9047) and HER
CROSSING IS MID-FLIGHT AND BLOCKED by VX-487 (nothing lost; nothing pulled yet); the release is NOT published.
**The acceptance gate: the LIVE REHEARSAL on the throwaway (her finger on the Touch ID presses) runs BEFORE anything
is reinstalled on her Mac.** Pin-before-fix PER MEMBER; the cold review is a fresh `fable-reviewer` over the run's
whole diff (custody — no waiver). Commits say `Part of VX-nnn` per member; NO trailers.

## LIVE STATUS (flip per piece, same commit; unverified claims marked PENDING)

| # | Piece | Status |
|---|---|---|
| 0 | Kickoff: preflight read whole; Linear current (VX-483 joined as member, High, In Progress); main merged into the branch (`9d69c026f`); this record | DONE (this commit) |
| 1 | M1 — VX-487 (implementer session A) | DONE (`82376db6a` (a), `96455fb2c` (b); pins revert-verified; headless + build-for-testing green — "M1 RECORD" at the end); fork F-M1-1 RESOLVED — ruled (i), BUILT `164304e91` ("F-M1-1 BUILT" under THE RULING; R7 red, evidence green) |
| 2 | M2+M3 — VX-486 + VX-483 (implementer session B) | DONE (`52a233742` M2, `f825ed8e7` + `dbb4666cb` M3; pins revert-verified RM2-1..5, RM3-1..5; harness 40/8 + M1 harness 388/67 + release compile + build-for-testing Mac + iOS green — "M2 RECORD"/"M3 RECORD" at the end); PROVISIONALs P-VX486-1/-2 in OPEN ITEMS |
| 3 | The orchestrator's stage batch (full Mac suite + phone suite over the run diff) | IN-PROGRESS — Mac run 1 at `fb080c7d1`: `✘ Test run with 5117 tests in 897 suites failed … 18 issues (including 14 known issues)` — 4 real reds, ALL the VX-489 class (M4 below), NONE from the members; VX-489 fixed, its three suites re-run `✔ 23 tests in 3 suites passed`; the phone suite next |
| 4 | The ladder (fresh fable-reviewer, whole run diff; rounds per the standing rules) | NOT-STARTED |
| 5 | THE LIVE REHEARSAL (stage window; her Touch ID presses; the acceptance gate) | NOT-STARTED |
| 6 | Merge (PR, merge commit), tickets Done, in-flight row retired | NOT-STARTED |
| 7 | Rebuild Release, fresh A1, install on the Pro; her crossing retry | NOT-STARTED (after 6) |
| 8 | The window tail: Air prompt → release publish → site delta → close-out on main → VM-8 prompt | NOT-STARTED (appendices A/B of the kickoff file) |

## The members

### M1 — VX-487 (Urgent, Pre-launch): Castle + Touch ID — the engine can never read the sync keys

**THE MECHANISM (traced by the VX-329 session, RE-VERIFIED in code by this orchestrator 2026-10-22):**
- `Sources/VariorumCore/Protection/Executor/Acts/CommonSteps.swift:333` `holdSyncKeys(_:castleWay:)` — the
  castle+touchID arm (:341–350) writes the Touch ID item and then calls `holdInSession(nil, …)` (:350). After the
  act, the keys live ONLY in the Touch ID item; `drop(.silent)` (:355) has deleted the silent item.
- `App/Variorum/Shared/Protection/NewRoadSyncKeyProvider.swift:39` `currentKeys()` reads SESSION MEMORY then the
  SILENT item — NEVER the Touch ID item (by design: no prompt per round; the header comment at :13–16 states the
  intended design — "under Always-ask Castle, rounds run while an act or unlock has loaded session memory",
  P-VX307-U1-3).
- NO unlock path loads session memory. The full non-test caller sweep (re-run at this kickoff): the only NON-NIL
  `holdInSession` writers are `CommonSteps.swift:353` (the castle-NO-touchID arm) and `KeyDoors.swift:266`
  (`holdSyncKeysForTheSession` — the key doors' own pre-act hold). `ProtectionRoadLock.swift:58` clears at lock;
  `PlanRunner.swift:546/549/571` and `AccountActs.swift:229` clear.
- So Castle+TouchID ⇒ `SyncKeyProviderError.notEnrolled` ⇒ `SyncError.encryptionKeysUnavailable` forever ("Sync
  locked"); a relaunch cannot help (session memory is gone at relock/crash — `KeychainSyncKeysLeaf.swift:9`).
  P-VX307-U1-3's stated design was never built on the unlock side. Her live report + relaunch persistence confirm.

**THE FIX SHAPE (the ruled direction — the implementer proposes exact seams; the orchestrator rules forks):**
- **(a)** the join/act's castle-touchID arm ALSO holds the keys in session: `CommonSteps.holdSyncKeys`'s touchid
  branch ends `holdInSession(held, …)` instead of nil — the act just handled the keys; holding them for the session
  is exactly P-VX307-U1-3's stated design on the act side.
- **(b)** the Touch ID UNLOCK loads the sync-keys touchid item into session in the SAME press:
  `App/Variorum/Shared/Protection/ProtectionOpenRoad.swift:395` `pressTouchID` — after a successful `open` of a
  library whose record names a BOUND account, read the account's sync-keys touchid item and `holdInSession` it.
  ONE press, never two prompts: `KeychainCustodyLeaf.readCustody` mints its own `LAContext` (KeychainCustodyLeaf
  .swift:140); `KeychainSyncKeysLeaf.readSyncKeys` mints its own (KeychainSyncKeysLeaf.swift:58–64) — the custody
  read's evaluated LAContext must COVER the second gated read, so `readSyncKeys` (or a sibling) needs a
  context-accepting seam. Load only for a successfully opened BOUND library; a failed/absent sync-keys read must
  NEVER fail the unlock (the library opens; the row says locked until an act or press loads keys).
- **(c)** the typed-unlock-in-Castle residue (a typed passphrase/words unlock loads no sync keys — they stay
  unloaded until an act or a Touch ID moment) is RECORDED here, NOT built — a design question for her, bundled:
  see OPEN ITEMS below.

**PINS (red-on-old, headless — the leaves are protocol-typed; script them in the vx-306-era test worlds):**
1. The castle+touchID act arm holds the keys in session (red on old: the old arm nils).
2. The Touch ID unlock loads session memory for a bound library (red on old: no unlock path loads).
3. One press, never two prompts: assert the gated-read context / scripted-leaf call counts (the sync-keys read
   rides the press's context; no second fresh-context gated read).
4. The provider's session-first read is already pinned (do not duplicate; name the existing pin in the record).
5. The never-hostage limit: a failing sync-keys read still opens the library.

### M2 — VX-486: the locked-sync row asks for a passphrase its door can't take

Her live report (words in the ticket). **The row:** `App/Variorum/Shared/SyncStatusViews.swift` — `lockedLabel`
(:548, "Sync locked — enter your encryption passphrase": old-road vocabulary; the Encryption tab it once pointed
at is deleted) and the keysLocked face (:135–143), whose one door is `Account…` → `.openAccount(.account)`
(P-VX329-U1-4's provisional — the Account sheet cannot take a passphrase for this).
**THE FIX:** the locked state's door opens **Settings ▸ Protection** — the pane-request seam survived U1 in
`App/Variorum/Shared/ProtectionController.swift` (`requestProtectionPaneForRoadCrossing`, :45–55 — "the one
programmatic open-at-pane road", the `MCPDoor.settingsRequest` twin; the relock monitors use it). A new `Door.Act`
arm routed through `perform(_:)` (:521); the shared view compiles for iOS — if the seam is Mac-only, the phone's
arm renders the sentence without the door exactly as `.appOutOfDate` does (P-2: a door that cannot act is not
rendered). **And `lockedLabel` is reworded off the old-road vocabulary** — the new line is PROVISIONAL, HERS to
reword: draft close to the join's/lobby's own ruled language (sentence case, no shouty caps), bundle it in the
record.
**PINS:** the presented-state pin (the label — the existing pin's home, red-on-old by the wording change) + a
door-act pin (the keysLocked face's door performs the Protection pane request, never `.openAccount`).
**Her second symptom** — the Account… button doing nothing when the sheet is already up — gets a one-line
disposition in the M2 record (suspect: the single-presenter refusing re-present, VX-239/VX-243's designed shape);
fix only if trivial.

### M3 — VX-483 (High at her call): the walk-rounds opt-in — REQUIRED BEFORE THE REINSTALL

Her call (2026-10-22, in session): the VX-487 fix must be provable LIVE before her Mac gets the rebuilt app — the
rehearsal's round must actually land against the throwaway, in the app.
**The fence:** the dev store's `SyncSession` never configures — `App/Variorum/Shared/SyncSession.swift:100`
(`guard allowsSync else { return }`), `allowsSync` derived from the store variant in `AppServices` ("a dev-store
session NEVER configures sync"); the row face's own guard is `SyncStatusViews.swift:112` ("Sync off (dev store)").
**THE FIX, scoped TIGHT:** Debug-only. The fence lifts ONLY when the walk-switch env (`VARIORUM_WALK_PROJECT_URL`,
`ProtectionWalkSwitch.projectURLKey` — the VX-308 U1 piece-0 road, `ProjectConfig.swift:46–55`) is present AND the
*[removed for publication]*
says why; it must never silently run against production). The existing walk switch already refuses the production
host (`projectOverrideForThisLaunch(productionHost:)`) — reuse its read, never a second env parse. Release builds:
byte-unchanged, the fence absolute.
**PINS:** the fence holds with no env; lifts with the throwaway env; refuses the production ref (fail-loud).

### M4 — VX-489 (joined at the stage batch, 2026-10-22; the orchestrator's own hand — no custody, no editor seam): the 0.10 bump's four stale version reds

**Found by the stage batch's full Mac run** (the only 4 real reds; none from M1–M3): main's `b59c68592` bumped
MARKETING_VERSION to 0.10 AFTER VX-329's closing run, so (1) `VersionSchemeTests.theMarketingVersionIsTheFriendsBetasLine`
expected the `0.9.` prefix; (2) its stamp-phase pin filtered pbxproj lines by `MARKETING_VERSION = 0.9.` (found 0);
(3) `SupportDraftTests.theRunningAppsVersionsAreTheBundlesOwn` expected `0.9.`; (4) `WhatsNewTests
.theRunningVersionCarriesItsNotesInTheBundle` found no `ReleaseNotes-0.10.md` in the bundle. **THE FIX (the
orchestrator, Fable):** the three pins rewritten to the ruled pre-1.0 line (her 2026-10-22 release word: 0.10, "i
don't want 1.0 until public launch" — the prefix widens to `0.`, the stamp filter to `MARKETING_VERSION = 0.`, the
comments carrying the amendment; the mobile target wears 1.0, so the filter still isolates the Mac target's two
configurations); the approved `ReleaseNotes-0.10.md` bundled into the WhatsNew synchronized group **minus its two
drafting-header lines** (the `# Variorum 0.10` title and the "*Drafted at VX-329 for her rewrite…*" meta line — the
0.9.8 bundled precedent starts with content; every content line byte-faithful to her approved draft; the repo-root
draft stays as it was). Red-on-old: the full run's four ✘ ARE the red (recorded in row 3); the three suites re-ran
green (`✔ Test run with 23 tests in 3 suites passed`). The What's New auto-show for 0.10 now has its notes — the
release's own gate (`ReleaseNotes.swift`: "a release REFUSES without the file").

## Session plan (the cast — CLAUDE.md's standing default; one agent at a time, fresh per batch)

- **Implementer session A (Opus, xhigh): M1.** Headless + `build-for-testing` only.
- **Implementer session B (Opus, xhigh): M2 + M3** (rider-sized pair; the vx-329 R1 precedent). Same limits.
- **The orchestrator (Fable):** the stage batch (full Mac suite + phone suite — the closeout-coverage rule), the
  ladder, the rehearsal, the merge and the window tail. Any `Sources/VariorumCore/Sync/` line is Fable work — no
  member should need one (M1/M2 are Protection + Shared; M3 is Shared/AppServices); an implementer that wants one
  STOPS and flags.
- **The ladder:** fresh `fable-reviewer`, `notes/REVIEW_PROMPT.md` VERBATIM, zero framing, whole run diff; rounds
  per the standing rules (r2 re-reviews fixes; new BLOCKER/MAJOR ⇒ r3; cap 3). Cross-model flow: findings to the
  implementer verbatim, agree/dispute back, the reviewer rules; the implementer applies confirmed fixes.

## Environment traps (binding on every session of this run — the vx-329 §6 traps, carried with this run's deltas)

Instance checks `pgrep -fl 'Variorum.app/Contents/MacOS'` AND discriminate by PATH; real-store instances by STORE,
never quit/kill; no Release builds or /Applications refreshes while one lives — and NO /Applications refresh at all
until THIS RUN'S MERGE + THE LIVE REHEARSAL ARE GREEN (the acceptance gate; the marker-14 deploy is already live).
`xcodebuild build-for-testing` compiles without the runner; Mac tests from `App/Variorum/`, suite-level
`-only-testing`, confirm the "Test run with N tests" line and read `skipped:` before claiming a gated suite ran;
zsh `pipestatus`; NEVER a custom build configuration (non-"Debug" strips the DEBUG oracles). EVERY `xcodebuild
test` run and anything touching the screen or a shared store holds a `Tools/stage` claim (no coordinator — this
session claims directly, renew-per-row on long walks). Headless `swift build`/`swift test` is stage-free. Backups
WAL-safe, UTC names, into `Backups/safety-copies/` (A1). The dev Castle pair is `~/.variorum/dev-castle.env`, the
throwaway's users `~/.variorum/dev-vault-throwaway.env` — values never echoed, never committed, NEVER typed into
*[removed for publication]*
build lives at `App/Variorum/DerivedData/vx488` (NEVER the standard path — the stale-build lesson). The REAL dev
slot is the DEBUG container (`~/Library/Containers/io.lduarte.Variorum.debug/Data/Library/Application Support/
Variorum-dev/`); the `io.lduarte.Variorum/Variorum-dev` path is a stale decoy. The dev slot's files go aside by
`mv`, ALL top-level files, no extension filter. cliclick cannot press Touch ID; `kp:return` does not drive SwiftUI
onSubmit — System Events `key code 36` does. Window-region captures only. Implementers: no subagents, no stage, no
Debug launches, no dev-store touch; headless + `build-for-testing` only; checkpoint commits per piece, push each,
LIVE STATUS flips in the same commit, PENDING on every unverified claim; foreground waits only (poll, don't
`tail -f`).

## THE LIVE REHEARSAL (the acceptance gate — one stage window, after the ladder; her finger on the Touch ID presses)

The kickoff file's rehearsal section is the script of record; in short: stage claim → the walk Debug build into
`DerivedData/vx488` → the dev slot aside by `mv` → launch with the throwaway env, the walk switch verified
in-process via `ps eww <pid>` BEFORE any credential → fresh library on the dev slot → sign in as the throwaway's
user A → Use Castle (Touch ID gate — HER presses; her-hands rows marked) → quit → relaunch → the lobby's Touch ID
unlock → **THE PROOF: the engine's first round runs** (the status row leaves "Sync locked"; with M3's opt-in the
round actually lands against the throwaway) — and VX-486's row/door verified in the same window. Restore the dev
slot whole (mv back, same inodes; rule 21's notice once at the next plain launch is the known design).

## OPEN ITEMS (bundled for her; nothing here blocks the run)

- **M1 (c) — the typed-unlock-in-Castle residue:** under Castle+TouchID, a TYPED unlock (passphrase or words at
  the lobby) loads no sync keys — rounds stay locked until an act runs or a Touch ID moment loads them. Candidate
  shapes for her sitting (none built this run): (i) accept — the row says locked; a Touch ID press or any key-door
  act heals it (M2's door lands in Settings ▸ Protection where both live); (ii) the typed unlock derives the
  account's keys from the vault with the secret just typed (the `holdSyncKeysForTheSession` precedent — needs a
  vault read at unlock); (iii) a dedicated "unlock sync" door on the locked row.
- **M2 — the locked row's new words are PROVISIONAL, hers** (the M2 record's THE WORDS): BUILT P-VX486-2 "Sync locked —
  this Mac hasn't unlocked your account's sync keys" (the phone: "this iPhone"); the ALTERNATIVE "Sync locked — unlock
  with Touch ID to sync again" (the lobby's own words; her posture's road, false under Always ask). The door's label
  P-VX486-1 "Protection…" (the pane's name in the row's `Account…` idiom).
- **M2 — the Account…-does-nothing disposition** (the M2 record): SUSPECTED the window's own sheet modality (the row's
  Account sheet is its own `.sheet`, not the one presenter); no fix; the locked row no longer offers `Account…`.
- **M2 — the seam note** (the M2 record's THE DESIGN): a neutral `requestProtectionPane()` beside the crossing's (which
  delegates), and the press also opens the Settings window — the MCP twin's shape; the architect may re-rule.

## M1 RECORD (implementer session A — Opus, xhigh)

**NOT DONE BY THIS SESSION (first, as the contract asks):** F-M1-1 below — the act-side hold surviving the act's own
REOPEN — is a FORK for the architect, NOT BUILT (it needs a seam the brief does not name). No `xcodebuild test`, no stage,
no app launch, no dev/real-store touch (the run's traps). (c) is recorded, not built (OPEN ITEMS above).

### LIVE STATUS (per piece; PENDING = unverified)
- Piece R — this record skeleton + the preflight read whole (CLAUDE.md + canon, this file, the kickoff, the resiliency
  protocol, CastleRules WHOLE, SyncSpec WHOLE, the named code, the planted test worlds): DONE (`0b6acf703`).
- Piece 0 — the headless harness: DONE (not durable — this session's scratchpad `m1-harness`; the VX-329 U3 recipe
  re-pointed at this worktree: tools 6.2, macOS 26, the app target's concurrency settings on `Variorum`, the test target
  WITHOUT default `MainActor`; `Variorum` symlinks every `Shared/Protection/*.swift` but `ProtectionBackupHook.swift`, plus
  `Shared/AuthSession.swift`, `KeychainCustody.swift`, `LibraryOpenCopy.swift`, `WordsCopyDoor.swift`, `Features/WhatsNew/
  WhatsNewLedger.swift` and the recipe's one stub file; the test target symlinks the U3 harness's 61 files re-pointed here
  MINUS `KeychainOffMainTests` (it touches the login keychain — not this unit's) plus the `RoadWorldError` stub).
  **HARNESS BASELINE on the pre-fix tree (`0b6acf703`): `✔ Test run with 381 tests in 64 suites passed`** (0 failures).
- Piece 1 — the pins that compile on the pre-fix tree, committed BEFORE any fix: DONE (`1ce8b2748`).
  `Tests/VariorumCoreTests/Protection/Executor/SyncKeysSessionHoldTests.swift` (pin 1) — **RED on the pre-fix tree**
  (`swift test --filter SyncKeysSessionHoldTests`): `✘ Test run with 3 tests in 1 suite failed … with 2 issues` —
  `useCastleWithTouchIDHoldsTheNewKeysInSessionBesideTheItem` ✘ (`fixture.world.session[account] == item`) and
  `joiningACastleAccountWithTouchIDHoldsTheAccountsKeysInSession` ✘ (`laptop.world.session[account] == item`); the guard
  `theOtherArmsAreUnchanged` ✔ (Always ask holds in session, Standard holds nothing — by design both sides).
  `App/Variorum/VariorumTests/Protection/TouchIDUnlockSyncKeysTests.swift` (pin 2 + pin 4) — **RED on the pre-fix tree**
  (the harness, `--filter TouchIDUnlockSyncKeysTests`): `✘ Test run with 2 tests in 1 suite failed … with 3 issues` —
  `pin2_theTouchIDUnlockLoadsTheAccountsKeysForTheEngine` ✘ ×3 (session memory nil after the press; the provider's
  `currentKeys()` refused — the corpus key id nil against the item's and the vault's); the world's own setup (turn sync on,
  synced Use Castle with Touch ID, the lobby's Touch ID button) raised NO issue. `pin4_…` ✔ (a guard by design).
- Piece 2 — fix (a): DONE (`82376db6a`). `CommonSteps.swift` — the castle + Touch ID arm's `holdInSession(nil, …)` →
  `holdInSession(held, …)` (one line) and the doc comment made true. **Pin 1 GREEN**; the core protection + auth/account
  set (debug — every suite type under `Tests/VariorumCoreTests/Protection` + `AccountBindingGateTests`,
  `AccountLifecycleTests`, `AuthRLSDDLTests`, `KeyVaultClientTests`, `SupabaseTransportTests`,
  `SupabaseTransportSessionTests`, as one `--filter`): **`✔ Test run with 531 tests in 101 suites passed`** — the
  scenario world's promises (which read session memory) hold with the arm's new hold.
- Piece 3 — fix (b) + its seams + pins 3 and 5: DONE (`96455fb2c`). NEW `Shared/Protection/TouchIDPressContext.swift`
  (`TouchIDPressContext` — the evaluated `LAContext`, ended by `invalidate()`; `TouchIDPressHanding`; `TouchIDPressRiding`
  — `nonisolated` protocols, app-level). `KeychainCustodyLeaf`: the Touch ID read factored into `readTouchID` (body
  byte-identical but for its returns), `readCustody(.touchid)` = its key (behavior unchanged — the key doors' press), and
  `readTouchIDCustody` hands the evaluated context on ONLY when the read opened its item; the leaf keeps nothing.
  `KeychainSyncKeysLeaf.readSyncKeys(accountID:riding:)` — the Touch ID item under the press's context,
  `interactionNotAllowed` set first; any non-`errSecItemNotFound` answer THROWS (so the log names the status).
  `ProtectionOpenRoad.pressTouchID` — reads through `TouchIDPressHanding` when the leaf offers it (else as before), ends
  the press with a `defer` right after the read, and on `.opened` calls the new `loadSyncKeysForTheSession` (bound
  library only; logs and returns on no press / no item / a throw — never fails the unlock). The planted leaves join both
  protocols (`PlantedCustodyLeaf.handedPresses`; `PlantedSyncKeysLeaf.touchIDReads` / `ridingReads` /
  `ridingReadFails`, an ended press refused). The provider's header made true. Pins 3 + 5 added to
  `TouchIDUnlockSyncKeysTests.swift`. **The harness on the fixed tree: `✔ Test run with 4 tests in 1 suite passed`
  (`--filter TouchIDUnlockSyncKeysTests` — pins 2, 3, 4, 5) and the whole harness `✔ Test run with 385 tests in 65 suites
  passed`** (381 baseline + this unit's 4; 0 failures). No revert is in flight.
- Piece 4 — the behavioral reverts: DONE (`ff4045654` named them before they ran, `6937db19b` the results) — **no revert is in flight** (each restored by `git checkout --` of its one file,
  `git diff --exit-code` clean after every one). Run on the committed tree `96455fb2c` (core: `swift test --filter
  SyncKeysSessionHoldTests`; app: the harness, `--filter TouchIDUnlockSyncKeysTests`):
  - **R1** (`CommonSteps.swift` — the arm back to `holdInSession(nil, …)`): `✘ Test run with 3 tests in 1 suite failed …
    with 2 issues` — pin 1's two arms ✘ (`fixture.world.session[account] == item`, `laptop.world.session[account] ==
    item`); its guard ✔.
  - **R2** (`ProtectionOpenRoad.swift` — the pre-fix press, the load call removed): `✘ … 4 tests … with 7 issues` — pin 2
    ✘×3 (session nil; the provider refused), pin 3 ✘×3 (no riding read; nothing loaded), pin 5 ✘×1 (only its
    non-vacuity leg "the read was tried" — the never-hostage legs pass, as on the old tree), pin 4 ✔.
  - **R3** (same file — the TWO-PROMPT load: the riding read replaced by the context-less `readSyncKeys(accountID:
    itemClass: .touchid)`): `✘ … with 5 issues` — **pin 2 ✔ (the keys load either way) and pin 3 ✘×3** (no ride; the
    ridden press not the handed one; `touchIDReads == freshSyncPresses` — a fresh-context read, i.e. a second prompt);
    pin 5 ✘×2 (its scripted failure lives on the riding road), pin 4 ✔. Pin 3 is what catches a second prompt.
  - **R4** (same file — a HOSTAGE load: no keys loaded ⇒ the press refuses): `✘ … with 2 issues` — pin 5 ✘ (the failing
    leg's press did not open: "the Touch ID press opens the library" + the helper's throw); pins 2, 3, 4 ✔.
  - **R5** (same file — the press never ended: the `defer` removed): `✘ … with 4 issues` — pin 3 ✘ (`handed
    .isInvalidated`) and pin 5 ✘×3 (every leg's "the press ended"); pins 2, 4 ✔.
  - **R6** (`NewRoadSyncKeyProvider.swift` — the provider also reading the Touch ID item): `✘ … with 1 issue` — pin 4 ✘
    ("an error was expected but none was thrown": the provider read the item); pins 2, 3, 5 ✔.
- Piece 5 — evidence: DONE (the final tree = `96455fb2c`'s product files; every run foreground, in sequence):
  - THE CORE — the protection + auth/account set (every suite type under `Tests/VariorumCoreTests/Protection` +
    `AccountBindingGateTests`, `AccountLifecycleTests`, `AuthRLSDDLTests`, `KeyVaultClientTests`, `SupabaseTransportTests`,
    `SupabaseTransportSessionTests`; one `--filter`, 101 suite names): debug **`✔ Test run with 531 tests in 101 suites
    passed`**; release (`swift test -c release`, the same filter) **`✔ Test run with 507 tests in 97 suites passed`**; 0
    `skipped:` lines either; pin 1's suite ran green in BOTH. (The 24-test / 4-suite gap is the DEBUG-only suites, as at
    VX-329 U3.)
  - THE HARNESS (debug only — the app's protection suites name DEBUG walk machinery): **`✔ Test run with 385 tests in 65
    suites passed`** (baseline 381/64 + this unit's 4).
  - `xcodebuild -scheme Variorum -destination 'platform=macOS' -derivedDataPath App/Variorum/DerivedData/vx488-m1
    build-for-testing`: **`** TEST BUILD SUCCEEDED **`**; `-scheme VariorumMobile -destination 'generic/platform=iOS
    Simulator' -derivedDataPath App/Variorum/DerivedData/vx488-m1-ios build-for-testing`: **`** TEST BUILD SUCCEEDED **`**
    — the new `TouchIDPressContext.swift` compiled in both; no warning in any file this unit touched (both logs grepped).
- Piece 6 — the close: DONE (`dbaec3f2b`; the hashes filled in by the next commit).

**THE PINS (all five dispositioned):**
1. FIXED — pin 1 `SyncKeysSessionHoldTests` (core): red on the pre-fix tree and under R1; green after (a), debug + release.
2. FIXED — pin 2 `TouchIDUnlockSyncKeysTests.pin2_…` (planted): red on the pre-fix tree and under R2; green after (b).
3. FIXED — pin 3 `…pin3_onePressNeverTwoPrompts_…`: red under R2, R3 (the two-prompt load — pin 2 stays green there, so
   pin 3 alone catches a second prompt) and R5 (the press not ended). It needs the new seam to compile, so its red is
   the behavioral reverts', not the pre-fix tree's.
4. NOT "ALREADY PINNED" — the brief's claim did not hold: no test anywhere named `NewRoadSyncKeyProvider` (searched
   `App/Variorum/VariorumTests`, `VariorumMobileTests`, `Tests/`). Written here as a GUARD (green on both sides by design —
   the provider is unchanged): `…pin4_theProviderReadsSessionThenSilentAndNeverTheTouchIDItem`; its teeth shown by R6.
5. FIXED — pin 5 `…pin5_aFailingOrAbsentSyncKeysReadNeverFailsTheUnlock`: a guard by nature (the pre-fix press reads
   nothing, so it cannot fail one); its teeth shown by R4 (a hostage load) and R5; its "the read was tried" leg keeps the
   never-hostage claim non-vacuous (red under R2).

**PROVISIONALs:** none — no product behavior was decided: the brief ruled the load (Touch ID unlock, bound library,
never hostage) and the one prompt; the typed roads are untouched ((c), her OPEN ITEM).

**OBSERVATIONS (routed, not fixed here):**
- O-1 (pre-existing, unchanged): an act IN FLIGHT at a Touch ID unlock resumes in the open's settle, BEFORE the load —
  and its `holdSyncKeys` / `syncMaterial` read the Touch ID sync-keys item CONTEXT-LESS (each a prompt of its own on the
  real leaf). So a crash mid-act followed by a Touch ID unlock can still prompt twice. Rare (an act in flight); the
  executor's leaves are core-protocol, so riding the press there is a core seam change — the architect's call whether it
  is worth one.
- O-2 (for the rehearsal): the protection log says what the load did, one line per press —
  `road: the Touch ID unlock loaded the account's sync keys for the session (sync key xxxxxxxx)` on success; else `…
  found no Touch ID item …`, `… with no press to ride …`, or `… sync-keys read failed — <the keychain status> …`.

**THE MAC-SUITE LIST (the orchestrator's stage batch — compiled here, the planted ones run headless):**
`TouchIDUnlockSyncKeysTests` (NEW, harness-green), `RoadLockTests`, `RoadRearmTests`, `ProtectionLobbyModelTests`,
`RoadKeyDoorRoadTests`, `ProtectionAccountRoadTests`, `ProtectionJoinFollowRoadTests` (harness-green — they drive the
press or the planted leaves whose seams changed), plus the Mac-target suites over the same seams `ProtectionCrossingRouteTests`,
`ProtectionRoadRouteTests`, `ProtectionSystemCompositionTests`, `ProtectionFactsGathererTests`, `ProtectionRule27FaceTests`,
`PreDesignFaceTests`, `PreDesignStoreRefusalTests`, `CopyDoorsQuietProbeTests`, and the REAL-keychain suites over the two
leaves (throwaway scopes) `KeychainLeavesTests`, `ProtectionKeychainFamilyTests`; the phone's `MobileProtectionRoadTests`
and `MobileProtectionTests` (they name the leaves — compiled in the iOS build-for-testing).

### THE DESIGN (as built — the brief's seams; the one fork is F-M1-1)
- **(a)** `CommonSteps.holdSyncKeys`'s castle + Touch ID arm ends `holdInSession(held, …)` (was `nil`): the act just
  handled the keys; the Touch ID item is still written exactly as before and the silent item still goes.
- **(b)** ONE PRESS, BOTH GATED READS. Two app-level protocols beside the Keychain leaves (the core's `CustodyLeaf` /
  `SyncKeysLeaf` untouched — LocalAuthentication stays out of the core): a custody leaf whose Touch ID read HANDS ON the
  `LAContext` that read evaluated (taken ONCE — nil after, nil when the read did not open), and a sync-keys leaf that READS
  ITS TOUCH ID ITEM RIDING a press already evaluated (the context passed through `kSecUseAuthenticationContext`, with
  `interactionNotAllowed` set so the second read can NEVER show UI — see the Apple-facts note). `pressTouchID` takes the
  press right after the custody read (whatever the open does next), and after `.opened` of a library whose RECORD names an
  account (the same truth `NewRoadSyncKeyProvider.currentKeys` reads) reads that account's Touch ID sync-keys item riding
  the press and holds it in session memory; the press is invalidated at the end of `pressTouchID` on every path. A
  failed, absent or throwing read is LOGGED and the library opens all the same (never hostage); an unbound library reads
  nothing. Typed and quiet roads untouched ((c)).
- **Apple facts (the repo's `notes/plans/vx-266/second-opinion-apple-facts.md` §11 + one read-only lookup this session):**
  SecItem.h — "If the specified context has been previously authenticated, the operation will succeed without asking user
  for authentication" [Doc, high]; DTS (forum 655966) — a context "gets authenticated the first time you use it, and
  subsequent uses can reuse that authentication" [DTS]. LAContext.h — `interactionNotAllowed` with
  `kSecUseAuthenticationContext` "has the same effect as … kSecUseNoAuthenticationUI … fail with
  errSecInteractionNotAllowed instead of displaying the authentication UI" [Doc]. NOT FOUND anywhere: a statement about
  `interactionNotAllowed` on an ALREADY-authenticated context (the docs speak only of suppressing UI). A counter-report
  (forum 812733, `.userPresence`, iOS 17) saw a second prompt per `kSecMatchLimitOne` read on one context; an iOS 26.1+
  hang report (forum 814261) on a second key access close after a Face ID prompt. **FOR THE REHEARSAL:** one prompt is
  guaranteed by construction; if after her one Touch ID press the row still says locked and the protection log line
  `road: the Touch ID unlock's sync-keys read …` names `-25308` (errSecInteractionNotAllowed), the OS refused the reuse
  under the flag — the alternative (drop the flag, accept a possible second prompt) is HERS/the architect's, not built.
  VM-8 (the phone, Face ID) should re-check the same line.

### F-M1-1 — FORK (STOPPED, NOT BUILT): the act-side hold dies at the act's own REOPEN in the app
- **Mechanism (traced in code):** every RE-KEYING act on the new road — a crossing (Use Castle · Use Standard · Replace
  All Keys: `AppBootstrap.crossOnNewRoad` :1070), a join across postures and every follow (`accountActOnNewRoad` :1144,
  `request.shown.rekeys`) — runs through `reopenAround` (:1120), which ends `beginOpening(unlockedKey:)` (:1132) →
  `roadInputs.compose()` (:233) → `RoadInputs.live`'s `makeSystem` (`ProtectionOpenRoad.swift` :659) →
  `ProtectionSystem.live` → `ProtectionSystem.init` mints a FRESH `KeychainSyncKeysLeaf(scope:)` (`ProtectionSystem.swift`
  :63), whose session memory is an instance dictionary (`KeychainSyncKeysLeaf.swift` :30) — EMPTY. The reopened session
  (`ProtectionRoadSession(system: ctx.system, …)`, `ProtectionOpenRoad.swift` :549) is what `newRoadSyncKeys.attach` hands
  the engine (`AppBootstrap.swift` :331). So (a)'s hold — and the existing Always-ask arm's, and the follow's — reaches
  the engine ONLY for acts that do NOT reopen (turning sync on in Castle, a same-posture join: U1's acts on the open
  session; the key doors' `holdSyncKeysForTheSession`). HER PATH (Start fresh → JOIN her Castle account from a Standard
  library = a join across postures) reopens: with (a)+(b) built, sync stays locked after the join until the next Touch ID
  moment (a relaunch, or a lock + unlock). Tonight's rehearsal (quit → relaunch → Touch ID) and her retry (relaunch →
  Touch ID) both go through (b), so this does not block the gate — but her AIR crossing (Start fresh → join) will say
  "Sync locked" right after the join until she locks/relaunches and presses Touch ID.
- **Why the planted tests never saw it:** `PlantedRoad.system()` shares ONE planted sync-keys leaf across every
  composition (`ProtectionOpenRoadPlantedTests.swift` :36–41), so session memory survives a planted "reopen".
- **Options (the architect rules; none built):** (i) the bootstrap composes every system of the process over ONE
  `KeychainSyncKeysLeaf` per scope (`RoadInputs.live` holds it, `ProtectionSystem.live(variant:session:syncKeys:)` — the
  VX-423 one-refresh-authority shape); "gone at a relock" still holds through `ProtectionRoadLock.dropSessionMemory`, "gone
  at a crash" by the process. Smallest and most spec-defensible (rule 15's custody unchanged; P-VX307-U1-3's design
  reached). (ii) `reopenAround` carries the account's held keys from the old session's leaf into the reopened one (a
  hand-off at the one seam; narrower lifetime, more ad hoc). (iii) accept: re-keying acts leave sync locked until the
  next Touch ID moment, said by M2's row (the record's (c)-adjacent residue).

**THE RULING (the orchestrator, Fable, 2026-10-22 — repo-first before the build proceeds; under the mandate, as the
completion of (a)'s author-ruled intent, not a new product call):** **option (i) — ONE production sync-keys leaf per
process, owned at the composition root** and injected through the existing `syncKeys:` parameter on every production
`ProtectionSystem` construction (never a static singleton — CLAUDE.md's no-global-singletons line; the VX-423
one-authority precedent's shape). The reasons, in order of weight: (1) the key-changing paths EXPLICITLY clear session
memory (`PlanRunner.swift:546/549/571`, `AccountActs.swift:229`, `ProtectionRoadLock.swift:58`) — writers that bother
to clear a store prove the design assumed the store persisted; the per-system leaf is the accident. (2) (a)'s ruled
intent ("the act just handled them") is only delivered if the hold survives the act's own reopen — option (iii) would
under-deliver the ruling, and the product consequence lands exactly on her Air crossing (Start fresh → join → sync
should run, not sit locked). (3) The explicit clears keep their semantics byte-unchanged on the shared leaf; "gone at
a relock or a crash" holds exactly as the leaf's header promises. PIN (red-on-old by behavioral revert): through the
PRODUCTION composition path (the planted world shares one leaf set and cannot see this) — keys held via one
composition-built system survive into the next system the same composition builds (red on the per-system mint), plus
a guard that a key-change path's explicit clear still clears through the shared leaf. The implementer builds it; the
ladder re-reads it.

### F-M1-1 BUILT (implementer session A, after THE RULING)
- Piece F0 — the composition pin committed BEFORE the fix: DONE (`0a9ae0927`).
  `App/Variorum/VariorumTests/Protection/OneSyncKeysLeafTests.swift` — `OneSyncKeysLeafCompositionTests` (source read,
  the VX-423 pin's idiom and helpers): the product constructs `KeychainSyncKeysLeaf(` once, in `AppBootstrap.swift`;
  `ProtectionSystem(` once, in `ProtectionSystem.swift` (`live`); the bootstrap → `RoadInputs.live` → `ProtectionSystem
  .live` → the system each hand `syncKeys: syncKeys`. **RED on the pre-fix tree** (the harness, `--filter
  OneSyncKeysLeaf`): `✘ Test run with 1 test in 1 suite failed … with 4 issues` — the mint found in
  `ProtectionSystem.swift` (the init's per-system default), and none of the three hand-offs present; the one-construction
  line ✔ (true on both sides).
- Piece F1 — the fix + the behavioral pin + the clear guard: DONE (`164304e91`).
  - **THE SITES (every production `ProtectionSystem` construction, swept — `grep 'ProtectionSystem(\|ProtectionSystem\.live\|
    KeychainSyncKeysLeaf('` over `Shared/`, `Variorum/`, `VariorumMobile/`, `VariorumMCPShim/` and `Sources/`):** the
    product has exactly ONE system constructor, `ProtectionSystem.live(variant:session:syncKeys:)` (`ProtectionSystem.swift`),
    called from exactly ONE place, `RoadInputs.live`'s `makeSystem` (`ProtectionOpenRoad.swift`), built once per process by
    the production `AppBootstrap.init` — so every composition rides the one leaf. The `roadInputs.compose()` sites (line
    numbers on the fixed tree, `AppBootstrap.swift`): `beginOpening` :245 (every launch; every reopen after a crossing, a
    re-keying account act, Make this my library and the landings; every lobby and its presses), `startFreshOverAPreDesign
    Store` :542, `createOnNewRoadFromAFace` :566, `copyDoorsRoadsWithoutALibrary` :657, `bringInPlaintextExport` :716,
    `makeThisMyLibraryInTheEmptySlot` :806, `lockOnNewRoad` :1263 (the lock's lobby). The
    phone's root composes through the same `AppBootstrap` (no construction of its own); the MCP shim composes none. The
    mint `?? KeychainSyncKeysLeaf(scope:)` in `ProtectionSystem.init` is DELETED and `syncKeys:` made REQUIRED there (and on
    `live` and `RoadInputs.live`), so a future site cannot silently mint its own — the compiler refuses it.
  - **THE ROOT:** `AppBootstrap.syncKeys` (beside `auth`, VX-423's shape) — the production init mints
    `KeychainSyncKeysLeaf(scope: variant.rawValue)` once and hands it to `RoadInputs.live(variant: variant, auth: auth,
    syncKeys: syncKeys)`; the test init takes its harness system's own leaf (tests inject their own). ONE process serves ONE
    store variant (`AppBootstrap(variant:)` once per app process; the MCP shim is a separate process), so one leaf is one
    per scope — no second scope coexists in a process today.
  - **THE CLEARS, byte-unchanged:** `PlanRunner.swift` :546/:549/:571, `AccountActs.swift` :229, `ProtectionRoadLock.swift`
    :58 — not touched; they now reach the one leaf.
  - **TEST SITES:** `ProtectionSystemCompositionTests` and `RoadWorld` (`ProtectionRoadTestSupport.swift`) pass
    `KeychainSyncKeysLeaf(scope: scope.scope)` — a fresh one per call, byte-identical to the deleted default;
    `PlantedRoad` and the gatherer's rig already passed their own. The VX-423 pin's two literal call strings
    (`OneRefreshAuthorityTests` — `RoadInputs.live(variant: variant, auth: auth` and `ProtectionSystem.live(variant:
    variant, session: auth`) lost their closing parenthesis so the added argument reads through; their meaning (the
    authority is handed) unchanged.
  - **A CORRECTION to F0's pin, recorded:** its expected `live` line named the arguments in an order Swift refuses (the
    init declares `syncKeys` before `session`); corrected to `ProtectionSystem(scope: variant.rawValue, places: places,
    syncKeys: syncKeys, session: session)`. Its red on the pre-fix tree is unaffected (the old line had no `syncKeys` at
    all).
  - **THE PINS** (`OneSyncKeysLeafTests.swift`): `OneSyncKeysLeafRoadTests.keysHeldThroughOneComposedSystemSurviveInto
    TheNextTheSameRoadComposes` (through `RoadInputs.live` → `compose()` twice: a hold through the first system is read by
    the second and by an executor built on it) and the GUARD `aKeyChangePathsExplicitClearStillClearsThroughTheSharedLeaf`
    (the lock's `dropSessionMemory` on a session a later composition built clears the earlier system's hold, for every
    system composed after; an executor's `holdInSession(nil, …)` — the rollback's / the leave's line — the same). **The
    harness: `--filter "OneSyncKeysLeaf|OneRefreshAuthority|TouchIDUnlockSyncKeys"` `✔ Test run with 15 tests in 5 suites
    passed`; the whole harness `✔ Test run with 388 tests in 67 suites passed`** (385/65 + this piece's 3 tests, 2 suites).
- Piece F2 — the behavioral revert: DONE — **no revert is in flight** (restored by `git checkout --`, `git diff
  --exit-code` clean). **R7** (on `164304e91` — `RoadInputs.live`'s `makeSystem` handing each system a fresh
  `KeychainSyncKeysLeaf(scope:)`, the per-system mint): the harness `--filter OneSyncKeysLeaf` `✘ Test run with 3 tests in 2
  suites failed … with 7 issues` — THE PIN ✘×3 (the reopened system's leaf empty: `…?.rowKeyID == "held-by-the-act"`, the
  executor on it reads nothing, the two leaves not one), THE GUARD ✘×2 (the lock's drop and the executor's clear on a
  later system no longer reach the acting system's private leaf), THE COMPOSITION ✘×2 (a mint outside the bootstrap; the
  road no longer hands `syncKeys: syncKeys`).
- Piece F3 — evidence: DONE (the final tree = `164304e91`'s product files; foreground, in sequence): the harness **`✔ Test
  run with 388 tests in 67 suites passed`**; the core protection + auth/account set (untouched by this piece — the
  confirmation) debug **`✔ Test run with 531 tests in 101 suites passed`**, release (`swift test -c release`) **`✔ Test run
  with 507 tests in 97 suites passed`**, 0 skipped either; `xcodebuild -scheme Variorum -destination 'platform=macOS'
  -derivedDataPath App/Variorum/DerivedData/vx488-m1 build-for-testing` **`** TEST BUILD SUCCEEDED **`** and `-scheme
  VariorumMobile -destination 'generic/platform=iOS Simulator' -derivedDataPath App/Variorum/DerivedData/vx488-m1-ios
  build-for-testing` **`** TEST BUILD SUCCEEDED **`** — no error, no warning in a touched file (both logs grepped).
- **THE STAGE BATCH gains (Mac target, compiled here):** `OneSyncKeysLeafCompositionTests` + `OneSyncKeysLeafRoadTests`
  (NEW, harness-green), `OneRefreshAuthorityCompositionTests` (its two loosened strings, harness-green),
  `ProtectionSystemCompositionTests` (its system now handed a leaf explicitly — real keychain, throwaway scope), and every
  suite over `RoadWorld` (`ProtectionRoadTestSupport.swift` — `ProtectionRoadRouteTests`, `RoadLockRouteTests`,
  `ProtectionCrossingRouteTests` and the other bootstrap-constructing route suites: the bootstrap's inits changed).
- **PROVISIONALs:** none (the ruling decided the shape; nothing product-visible beyond (a)'s intent delivered).


## M2 RECORD (implementer session B — Opus, xhigh) — VX-486

**NOT DONE BY THIS SESSION (first, as the contract asks):** no `xcodebuild test`, no stage, no app launch, no dev/real-store
touch (the run's traps) — the Mac-target suites this unit touches run in the orchestrator's stage batch (listed at the
close); the row's door is walked in THE LIVE REHEARSAL, not here. The locked line's words and the door's label are
PROVISIONAL and HERS (OPEN ITEMS).

### LIVE STATUS (per piece; PENDING = unverified)
- Piece R — this record skeleton + the preflight read whole (CLAUDE.md + canon, this file whole incl. the M1 RECORD, the
  kickoff, the resiliency protocol, CastleRules WHOLE, SurfaceContracts whole — "The app" and "Doors to the outside", the
  named code; the ticket's text read once, read-only): DONE (`3726a1c89`).
- Piece 0 — the headless harness: DONE (not durable — this session's scratchpad `m2m3-h`; the M1 recipe: tools 6.2,
  macOS 26, the app target's concurrency settings on `Variorum`, the test target without default `MainActor`). Shared/
  compiled whole FAILS (the real `AppSession`'s macOS arm composes the editor's routers — Mac-app files), so `Variorum` =
  the M1 harness's symlinks + `SyncStatusViews`, `SyncSession`, `AppServices`, `ProtectionController`, the REAL
  `ProjectConfig`, `TierViews`, `AuthViews`, `ErrorPresentation`, `IdleCommitScheduler`, `StoreBackup`,
  `OperationsRunner`, `DeviceName`, `BackupDestination`, `BackupLog`, `MarkdownInsurance`, `BookNameCopy`,
  `ExportWriter`, `Theme/*`, `SampleLibrary/*` (minus `SeededBookRestore`), and ONE stub file (a slim `AppSession` +
  `StatusCenter` — the members `AppServices` and the row read); the tests = `SyncStalledRowTests`,
  `TierAndOnboardingTests`, `Phase9cAuthWiringTests`, `ProtectionWalkProjectTests` + this unit's two suites, with
  `AppTestKeyProvider` and `SeededGenerator` copied byte-for-byte. **BASELINE on the pre-fix tree (`3726a1c89`): `✘ Test
  run with 30 tests in 6 suites failed … with 4 issues`** — all 4 are harness-PATH artifacts in three `Phase9cAuthWiring`
  source pins that read `#filePath` without resolving symlinks (`theDelegatedBrowserFlowAndBothIssuerDirectionsStayOut`,
  `thePasteInIsFullyRetiredInTheSharedSources`, `theBecomeActiveHookRunsOneSyncRound` — they find no sources beside the
  symlink); they run in the Mac target (the stage batch). Every other test green.
- Piece 1 — the pins that compile on the pre-fix tree, committed BEFORE the fix: DONE (`cad1c101e`).
  `App/Variorum/VariorumTests/SyncLockedRowTests.swift` — **RED on the pre-fix tree** (the harness, `--filter
  "SyncLockedRowTests|SyncWalkFenceTests"`): `theLockedLineSpeaksTheRoadsWordsNeverThePassphrase` ✘×3 (the words; "passphrase";
  "encryption") and `theLockedRowNeverOffersTheAccountSheet` ✘×2 (the `.openAccount(.account)` act; the `Account…`
  label) — `✘ Test run with 5 tests in 2 suites failed … with 8 issues` (M3's three in the same run, its record).
- Piece 2 — the fix + the new-seam pins: DONE (`52a233742`). `Shared/ProtectionController.swift` (the neutral
  `requestProtectionPane()`; the crossing's method delegates), `Shared/SyncStatusViews.swift` (`.openProtection`,
  `canOpenProtection`, `openProtectionLabel`, `ProtectionPaneDoor` + its environment key, the row's press, the line),
  `Variorum/VariorumApp.swift` (the main window injects `ProtectionPaneDoor.settings(bootstrap.protection)`). Four
  new-seam pins in `SyncLockedRowTests` (`theLockedRowsOneDoorIsTheProtectionPane`,
  `withNoProtectionPaneTheLockedRowSaysTheSentenceAlone`, `theProtectionDoorAsksForTheProtectionPane`,
  `onlyTheLockedFaceMintsTheProtectionDoor`). **The harness on the fixed tree: `--filter SyncLockedRowTests` `✔ Test run
  with 6 tests in 1 suite passed`** (Piece 1's two now green + the four). The whole-harness and build-for-testing runs are
  Piece 4's (PENDING).
- Piece 3 — the behavioral reverts: DONE — named BEFORE they ran (`e7a0970b6`), on the committed tree `f825ed8e7` (each one
  file, restored by `git checkout --` + `git diff --exit-code`; the harness, `--filter "SyncLockedRowTests|
  SyncWalkFenceTests"`): **RM2-1** the locked face's door back to `Account…` → `.openAccount(.account)`; **RM2-2** the
  line back to "Sync locked — enter your encryption passphrase"; **RM2-3** `ProtectionPaneDoor.settings` a no-op;
  **RM2-4** the Protection door minted whatever `canOpenProtection` says (P-2 broken); **RM2-5** the Protection door
  also on the replaced-keys face. **DONE — no revert is in flight** (every restore `git diff --exit-code` clean; each run
  `Test run with 13 tests in 2 suites`):
  - **RM2-1** `✘ … with 4 issues` — `theLockedRowNeverOffersTheAccountSheet` ✘×2, `theLockedRowsOneDoorIsTheProtectionPane`
    ✘, `withNoProtectionPaneTheLockedRowSaysTheSentenceAlone` ✘ (the pre-fix door, exactly).
  - **RM2-2** `✘ … with 3 issues` — `theLockedLineSpeaksTheRoadsWordsNeverThePassphrase` ✘×3 (the words, "passphrase",
    "encryption").
  - **RM2-3** `✘ … with 3 issues` — `theProtectionDoorAsksForTheProtectionPane` ✘×3 (no ask; nothing to adopt; no fresh
    ask on the second press).
  - **RM2-4** `✘ … with 1 issue` — `withNoProtectionPaneTheLockedRowSaysTheSentenceAlone` ✘ (a door the phone could not
    act on).
  - **RM2-5** `✘ … with 3 issues` — `onlyTheLockedFaceMintsTheProtectionDoor` ✘×3 (the replaced-keys face minted it, in
    the sweep ×2 and the exact-doors leg).
- Piece 4 — evidence: DONE (the final tree = `dbb4666cb`'s product files; foreground, in sequence; shared with M3):
  - THE HARNESS (`m2m3-h`, debug) whole: `✘ Test run with 43 tests in 8 suites failed … with 4 issues` — exactly the
    baseline's three harness-PATH artifacts (Piece 0; they run in the Mac target); with those three skipped (`--skip`):
    **`✔ Test run with 40 tests in 8 suites passed`** — `SyncLockedRowTests` 6, `SyncWalkFenceTests` 7,
    `SyncStalledRowTests`, `TierAndOnboardingTests` (3 suites), `Phase9cAuthWiringTests` (incl. the dev-store sweep
    pins `startOnTheDevStoreNeverRunsTheSweep`, `aDevStoreSignInAfterWiringNeverRunsTheSweep`,
    `devStoreSessionsStayFencedEvenWhenSignedIn`, `aRealStoreSignInSweepsOffTheMainThread` — green on the new guard),
    `ProtectionWalkProjectTests` (its one-fence source pin over the edited `ProjectConfig`); no `skipped:` line.
  - THE M1 HARNESS (session A's `m1-harness`, which symlinks the edited `ProtectionWalkSwitch.swift`), rebuilt on this
    tree: **`✔ Test run with 388 tests in 67 suites passed`** (session A's F3 count, unchanged).
  - RELEASE COMPILE (headless, the harness's app sources — `swift build -c release --target Variorum`): **`Build
    complete!`** — `AppServices`' and `ProjectConfig`'s Release arms compile with `ProtectionWalkSwitch` absent (no
    DEBUG-only symbol reaches Release).
  - `xcodebuild -scheme Variorum -destination 'platform=macOS' -derivedDataPath App/Variorum/DerivedData/vx488-m2m3
    build-for-testing`: **`** TEST BUILD SUCCEEDED **`**; `-scheme VariorumMobile -destination 'generic/platform=iOS
    Simulator' -derivedDataPath App/Variorum/DerivedData/vx488-m2m3-ios build-for-testing`: **`** TEST BUILD SUCCEEDED
    **`** — no error, and no warning in any file this session touched (both logs grepped).
  - Not run (no file touched): the core package (`Sources/` and `Tests/` untouched by this session).

### THE DESIGN (settled before the build — within the brief's named latitude; see the seam note)
- **The face:** `SyncRowFace.Door.Act` gains `.openProtection` (Settings ▸ Protection through the pane request). The
  keysLocked face's one door becomes `Door(label: "Protection…", act: .openProtection)`, minted ONLY when the face is told
  a door can act there (`canOpenProtection`, defaulted false — the `canCheckForUpdates` idiom, P-2); with no door it is the
  sentence alone, exactly as `.appOutOfDate` without an updater. `keysReplaced` and `accountMismatch` keep `Account…`
  (not this unit's).
- **The door (the `CheckForUpdatesDoor` precedent):** `ProtectionPaneDoor` — an environment-injected act, nil by default
  (the phone, every test composition) ⇒ no door renders. The Mac's main window injects it from the bootstrap's one
  `ProtectionController`; the press is the MCP twin's own shape (`EditorCommands`' ⌥⌘,: `mcp.requestSettings();
  openSettings()`): the pane request first, then `openSettings()` — the Settings window adopts the request on appear (a
  fresh window) or on change (one already up) — `AppSettingsView.adoptProtectionRequest`, unchanged.
- **The seam note (reuse vs a neutral twin — the brief's own question):** `requestProtectionPaneForRoadCrossing()`
  reused as-is would be a dishonest name at a non-crossing caller (its doc: "a crossing ends on Protection"); so
  `ProtectionController` gains the NEUTRAL entry `requestProtectionPane()` (the `MCPDoor.requestSettings()` twin), and the
  crossing's method delegates to it (byte-identical effect: `settingsRequest += 1`). And the counter alone opens nothing —
  it re-points a Settings window — so the door also opens the window (the MCP press's second line). Both are the brief's
  named precedent; flagged for the architect to re-rule at the ladder if the reuse was meant literally.
- **The phone:** Settings ▸ Protection is a Mac pane (the phone's Protection screen is VM-8's), so the phone injects no
  door and its locked row is the sentence alone (P-2). OBSERVATION for VM-8: the phone's locked row thereby loses the
  `Account…` door it showed (the phone's Account sheet is reached only from this row); VM-8 injects the phone's door when
  its Protection screen lands.
- **The line:** `lockedLabel` off the old road's words — the drafts in "THE WORDS" below (PROVISIONAL, HERS).

### THE WORDS (PROVISIONAL — hers to reword; bundled in OPEN ITEMS)
- **The line (P-VX486-2), BUILT:** "Sync locked — this Mac hasn't unlocked your account's sync keys" (the phone's arm
  reads "this iPhone" — `ProtectionCopy.deviceName`). It names the state in the road's own vocabulary ("your account's sync
  keys" — `ProtectionWords.stopSyncingLead`'s words; "unlock" — the lobby's verb) and promises no act: the door beside it
  says where to go. Posture-neutral on purpose — it stays true under Castle with Touch ID (heals at the next Touch ID
  unlock or a key-door act, VX-487), under Always ask, and after a typed unlock (M1 (c), her open design question).
- **One alternative (hers to pick):** "Sync locked — unlock with Touch ID to sync again" — the lobby's own button words
  ("Unlock with Touch ID"), the plainest road for HER posture (Castle + Touch ID); not built because it is false under
  Always ask and names a road the typed-unlock residue (M1 (c)) has not ruled.
- **The door's label (P-VX486-1), BUILT:** "Protection…" — the pane's own name (`ProtectionCopy.protectionPaneTitle`) in
  the row's `Account…` idiom.

### Her second symptom (the Account… button doing nothing when the Account sheet is already up)
- **Traced, SUSPECTED (not reproduced — no walk in this session, and her words for this symptom are not in the ticket):**
  the row presents its Account sheet ITSELF (`SyncStatusRow`'s own `.sheet(item: $accountSheetTab)`), never through the
  one protection presenter; on the Mac that sheet is attached to the row's own window, which takes no clicks while the
  sheet is up — so a press on that window's `Account…` behind it does nothing by the window's modality (the sheet already
  up IS the Account surface). The single presenter (VX-239/VX-243) is not on this road: it serves Settings ▸ Protection's
  sheets, one at a time (a second press there while one stands presents nothing — its designed shape). **Disposition: no
  fix** (nothing trivial to change: the behavior is AppKit's sheet modality); and in the locked state the row no longer
  offers `Account…` at all, so this symptom's trigger is gone where she met it. If the rehearsal shows a different shape
  (e.g., the Settings window's Account sheet up while the main window's row is pressed), it is a ticket for her.

### THE PINS (all dispositioned) — M2
1. FIXED — `theLockedLineSpeaksTheRoadsWordsNeverThePassphrase` (the presented-state pin): red on the pre-fix tree and under
   RM2-2.
2. FIXED — `theLockedRowNeverOffersTheAccountSheet` (the door-act pin's compile-on-old half): red on the pre-fix tree and
   under RM2-1.
3. FIXED — `theLockedRowsOneDoorIsTheProtectionPane` (the door-act pin: `[Protection… → .openProtection]`): red under
   RM2-1 (new seam — its red is the revert's).
4. FIXED — `withNoProtectionPaneTheLockedRowSaysTheSentenceAlone` (P-2, the phone's arm): red under RM2-1 and RM2-4.
5. FIXED — `theProtectionDoorAsksForTheProtectionPane` (the injected door's act IS the pane ask; the crossing's ask
   unchanged): red under RM2-3.
6. GUARD — `onlyTheLockedFaceMintsTheProtectionDoor` (the replaced-keys and mismatch rows keep `Account…`): teeth shown by
   RM2-5.
- NOT PINNED HEADLESS (said plainly): the row's press itself (`perform(.openProtection)` → the ask + `openSettings()`) is
  view code — the rehearsal walks it (below).

### FOR THE REHEARSAL (VX-486's row in the same window)
- After M1 the Touch ID unlock HEALS the locked state, so the row may never show it on the main path. The locked row
  appears after a TYPED unlock in Castle + Touch ID (M1 (c)'s residue): relaunch → type at the lobby (HER hands — the
  traps forbid driven typing of the dev pair) → the row reads the new line with `Protection…` → the press opens Settings
  at Protection, both with Settings closed and with it open on another pane.

## M3 RECORD (implementer session B — Opus, xhigh) — VX-483

**NOT DONE BY THIS SESSION:** no `xcodebuild test`, no stage, no app launch, no env-set run — the lift is proven LIVE in
THE LIVE REHEARSAL (the walk switch verified in-process via `ps eww`, then the round landing against the throwaway).

### LIVE STATUS (per piece; PENDING = unverified)
- Piece 0 — the harness (shared with M2's — its Piece 0): DONE.
- Piece 0b — the pins that compile on the pre-fix tree, committed BEFORE the fix: DONE (`aff573e5d`).
  `App/Variorum/VariorumTests/SyncWalkFenceTests.swift` on the pre-fix tree (the same run as M2's): ARM 1
  `withNoWalkSwitchTheDevStoreNeverSyncs` ✔ (a GUARD by design — the production composition in this process's world, no
  walk switch: `.dev` never syncs, `.real` may; green on both sides); `theDerivationReadsTheLaunchsLiftOnlyInDebug` ✘
  (no `#if DEBUG` arm before the assignment — one undivided line); `theRetiredCredentialSweepGuardsOnTheRealStoreNeverTheLift`
  ✘×2 (the guard reads `sync.allowsSync`).
- Piece 1 — the fix + the new-seam pins: DONE (`f825ed8e7`). `Shared/Protection/ProtectionWalkSwitch.swift`
  (`SyncFenceLift`, the pure `syncFenceLift(walkProject:productionHost:)`, the logged `syncFenceLiftForThisLaunch`),
  `Shared/ProjectConfig.swift` (`walkProject` internal; `walkSyncFenceLift` — the launch's one decision — inside its one
  `#if DEBUG` fence), `Shared/AppServices.swift` (the DEBUG/Release arms of the derivation; the pure DEBUG
  `allowsSync(storeVariant:walkLift:)`; the sweep's `storeVariant == .real` guard), `Shared/SyncSession.swift` (its A4
  header comment made true — no code). Four new-seam pins in `SyncWalkFenceTests` (`noWalkProjectHoldsTheFence`,
  `aWalkProjectThatIsNotProductionLiftsTheFence`, `theProductionRefIsRefusedAndTheFenceStands` — six production-ref
  shapes built from `ProjectConfig.productionProjectURL` plus the fail-closed arm — and
  `thisLaunchsDecisionWithNoWalkSwitchIsNone`). **The harness on the fixed tree: `--filter
  "SyncWalkFenceTests|SyncLockedRowTests|ProtectionWalkProjectTests"` `✔ Test run with 16 tests in 3 suites passed`**
  (Piece 0b's two red pins now green; the existing walk-project source pin — one `#if DEBUG` fence in `ProjectConfig` —
  still green).
- Piece 2 — the behavioral reverts: DONE — named BEFORE they ran (`e7a0970b6`), on `f825ed8e7` (RM3-4's re-run on
  `dbb4666cb`) (same protocol and filter as
  M2's): **RM3-1** `AppServices.allowsSync(storeVariant:walkLift:)` → `storeVariant == .real` (no lift); **RM3-2** the
  refusal removed (every walk project lifts); **RM3-3** the ref matched by EXACT HOST only (the existing switch's
  comparison); **RM3-4** the DEBUG derivation arm back to `allowsSync: storeVariant == .real` (the lift never read);
  **RM3-5** the sweep's guard back to `sync.allowsSync`. **DONE — no revert is in flight** (every restore clean; each
  run `Test run with 13 tests in 2 suites`):
  - **RM3-1** `✘ … with 1 issue` — `aWalkProjectThatIsNotProductionLiftsTheFence` ✘ (`allowsSync(.dev, lifted) == true`).
  - **RM3-2** `✘ … with 20 issues` — `theProductionRefIsRefusedAndTheFenceStands` ✘ (all six production shapes ×3 legs +
    the two fail-closed legs).
  - **RM3-3** (the ref by EXACT HOST only) `✘ … with 14 issues` — the same pin ✘ on the four shapes an exact-host
    comparison misses (×3 legs) + both fail-closed legs; the exact production URL and the same-host path still refuse
    under it — which is what the ref-anywhere rule adds over the existing switch's host comparison.
  - **RM3-4** FIRST RUN `✔ … passed` — **HOLLOW**: the source pin's first form (`debugArm.contains("ProjectConfig
    .walkSyncFenceLift")`) matched the DEBUG arm's own COMMENT with the read reverted. Tightened to the code expression
    (`dbb4666cb`, committed before the re-run); **RE-RUN `✘ … with 2 issues`** — `theDerivationReadsTheLaunchsLiftOnlyInDebug`
    ✘×2 (the code expression absent; the DEBUG arm reading `storeVariant == .real`).
  - **RM3-5** `✘ … with 2 issues` — `theRetiredCredentialSweepGuardsOnTheRealStoreNeverTheLift` ✘×2.
- Piece 3 — evidence: DONE — M2's Piece 4 (one shared run): the harness 40/8 green (+ the three path artifacts), the M1
  harness 388/67, the release compile, build-for-testing Mac + iOS green.

### THE DESIGN (settled before the build)
- **The decision, pure, DEBUG-only** (`ProtectionWalkSwitch`, beside the walk project it reads — the file is `#if DEBUG`
  whole): `syncFenceLift(walkProject:productionHost:)` → `.none` (no walk project resolved this launch — the fence
  holds) · `.lifted(host:)` (a walk project that is not the production mirror) · `.refusedProduction(host:)` (the walk
  project's URL carries the production REF — derived from `ProjectConfig.productionProjectURL`'s host, never a second
  literal — anywhere, case-folded; an underivable ref refuses too: fail closed). Its input is `ProjectConfig`'s OWN
  resolved walk project (the one `projectOverrideForThisLaunch` read — exposed, never a second env parse).
- **The launch's one decision, logged once** (`ProjectConfig.walkSyncFenceLift`, inside its one `#if DEBUG` fence): a
  lift says the host only; a refusal says it refused and why, naming the host only — never the URL, never the key.
- **The derivation site** (`AppServices.init`): DEBUG — `allowsSync = storeVariant == .real || (storeVariant == .dev &&
  lift.lifts)`; Release — the line byte-unchanged (`allowsSync: storeVariant == .real`), the fence absolute.
- **A second-order fence kept (found in the trace):** the retired-credential sweep gated on `sync.allowsSync` ("the A4
  fence's own seam … IS `storeVariant == .real`"); under a lift that equality breaks, and a lifted dev session would
  reach the INSTALLED build's login-keychain items — the round-2 N1 class. Its guard becomes `storeVariant == .real`
  (semantically identical in Release, where `allowsSync ≡ storeVariant == .real`).

### THE PINS (all dispositioned) — M3
1. GUARD — `withNoWalkSwitchTheDevStoreNeverSyncs` (ARM 1 through the production composition, this process's world): green
   on both sides by design.
2. FIXED — `theDerivationReadsTheLaunchsLiftOnlyInDebug` (source — the DEBUG arm's code expression; Release's line
   byte-unchanged): red on the pre-fix tree; HOLLOW in its first form under RM3-4 (matched its own comment) — tightened
   (`dbb4666cb`), then red under RM3-4.
3. FIXED — `theRetiredCredentialSweepGuardsOnTheRealStoreNeverTheLift` (source): red on the pre-fix tree and under RM3-5.
4. FIXED — `noWalkProjectHoldsTheFence` (ARM 1, pure): a guard of the decision's `.none`.
5. FIXED — `aWalkProjectThatIsNotProductionLiftsTheFence` (ARM 2): red under RM3-1.
6. FIXED — `theProductionRefIsRefusedAndTheFenceStands` (ARM 3, fail-loud, fail-closed): red under RM3-2 and RM3-3.
7. GUARD — `thisLaunchsDecisionWithNoWalkSwitchIsNone` (the launch's one value in this process).
- NOT PINNED HEADLESS (said plainly): the log lines (one per launch, host only) and the live lift — THE LIVE REHEARSAL
  proves both: after `ps eww <pid>` shows the walk switch, the protection log carries `WALK SWITCH (…): … a walk project's,
  not the production mirror` and `A4 FENCE (VX-483): LIFTED for this launch — the dev store may sync against the walk
  project at <the throwaway's host> …`; the row leaves "Sync off (dev store)" for the signed-out face; after the join the
  first round lands against the throwaway.

### OBSERVATIONS (routed, not fixed here)
- O-B1 (pre-existing, unchanged): a walk switch with only ONE of its two variables set resolves to nothing — the
  production coordinates stand for the sign-in (the Debug app then signs in against PRODUCTION, which the account fence
  forbids by convention) and the fence holds silently (the lift reads the resolved project, never the environment).
  Detecting the half-set switch would need a second environment read — not built; the rehearsal's `ps eww` check covers
  it.
- O-B2 (for the rehearsal's restore): a lifted launch signs the DEV scope's auth item into the throwaway's user; the next
  plain Debug launch (no switch) points that token at production (a refused refresh — signed out; the fence holds). Sign
  out before restoring the dev slot to leave the posture as found.
- O-B3 (VM-8): the phone's locked row is now doorless (no Protection screen yet) — it loses the `Account…` door it showed
  in that state; VM-8 injects the phone's `ProtectionPaneDoor` when its Protection screen lands.

### THE STAGE BATCH (the orchestrator's — this session ran none of it)
Mac target: `SyncLockedRowTests`, `SyncWalkFenceTests` (NEW, harness-green), `SyncStalledRowTests`, `SyncOutOfDateFaceTests`
(the face's signature grew a defaulted argument), `TierAndOnboardingTests`, `Phase9cAuthWiringTests` (ALL of it — incl.
the three source pins the harness cannot read: `theDelegatedBrowserFlowAndBothIssuerDirectionsStayOut`,
`thePasteInIsFullyRetiredInTheSharedSources`, `theBecomeActiveHookRunsOneSyncRound`), `Phase8ServicesTests` (the A4
fence's own pins), `ProtectionWalkProjectTests`, `ProtectionWalkSwitchTests`, `ProtectionCrossingRouteTests` (the
crossing's pane ask now delegates), `MCPAsksWaitTests` (the `adopts` rule), `DataSafetyFacesTests`,
`LibraryPortabilityDoorTests`. Phone: `MobileStructuralTests` (the no-redirect "Mac" sweep and the two-register sweep walk
`Shared/` — the new literals interpolate the device's name and the log lines name no Mac), `MobileEmptyStoreTests`.

### PROVISIONALs (bundled in OPEN ITEMS) and canon
- P-VX486-1 (the door's label "Protection…") and P-VX486-2 (the locked line) — hers. No canon line changes in this session:
  the row's locked words are not in AppSpec or SurfaceContracts today; a contract line lands when she rules them (the
  closeout's call).
