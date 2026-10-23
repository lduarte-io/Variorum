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
| 1 | M1 — VX-487 (implementer session A) | NOT-STARTED — the brief is M1 below |
| 2 | M2+M3 — VX-486 + VX-483 (implementer session B) | NOT-STARTED — the briefs are M2/M3 below |
| 3 | The orchestrator's stage batch (full Mac suite + phone suite over the run diff) | NOT-STARTED |
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
- **M2 — the locked row's new words are PROVISIONAL, hers** (drafted in the M2 record at build time).
- **M2 — the Account…-does-nothing disposition** (written at build time; fix only if trivial).
