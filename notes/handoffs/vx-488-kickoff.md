# VX-488 — the 0.10 window hotfix run: the orchestrator kickoff (written 2026-10-22 by the VX-329 session at its
context ceiling; HER WINDOW IS OPEN AND PAUSED ON THIS RUN)

## WHERE THE WORLD STANDS (verify, never trust: git log, the tickets, the probes)

- **VX-329 is MERGED** (PR #183, merge `0aab72c39`) and its closeout is complete (the plan's §9; the handoff
  `notes/handoffs/vx-329-handoff.md`). The in-flight row for THIS run is on main.
- **THE MARKER-14 DEPLOY IS DONE AND VERIFIED on production** (2026-10-22, her explicit go, the stored PAT road —
  *[removed for publication]*
  first run; the pg_temp belt 19/19; marker 14; her vault row backfilled `mode='castle'`, the one beta tester's
  `'standard'`; the grant sweep **62 OK · 4 INFO · 0 fail**. The vx307 checklist flip + SyncSpec §12's HELD entry
  gain the window's result at THIS run's close (on main).
- **The Pro runs 0.10 (9047)** at `/Applications` (codesign verified, sha256-identical; MARKETING_VERSION bumped
  to 0.10 on main at `b59c68592`). **Her crossing is MID-FLIGHT and BLOCKED by VX-487:** she pressed Start fresh
  (her old library is WHOLE in Previous Libraries + her hand-asides + fresh A1s on both Macs), joined her account
  (bound, library in CASTLE, Touch ID gate), and sync stays "Sync locked — enter your encryption passphrase."
  NOTHING is lost; nothing has pulled yet. The Air still runs 0.9.8, quit, A1 taken
  (`variorum-vx329-air-a1-20261022T2330Z` in its container + her Desktop copy).
- **The release is NOT published yet** (deliberate — acceptance caught this first). `ReleaseNotes-0.10.md` is
  approved by her as written; the testers' message in `notes/plans/vx-329-switch-day.md` is approved.

## THE RUN (branch `vx-488-window-hotfixes`, worktree `~/dev/variorum-vx-488` — EXISTS; record file
`notes/plans/fixes/vx-488-window-hotfixes.md` — yours to create; pin-before-fix PER MEMBER; commits
`Part of VX-nnn`; NO trailers)

### Member 1 — VX-487 (Urgent, Pre-launch): Castle + Touch ID — the engine can never read the sync keys
THE TRACED MECHANISM (verified in code by the VX-329 session; re-verify yourself):
- `CommonSteps.holdSyncKeys` (Sources/VariorumCore/Protection/Executor/Acts/CommonSteps.swift:332) — the
  castle/touchID arm writes the Touch ID item and calls `holdInSession(nil, …)`.
- `NewRoadSyncKeyProvider.currentKeys` (App/Variorum/Shared/Protection/NewRoadSyncKeyProvider.swift:39) reads
  SESSION MEMORY then the SILENT item — NEVER the Touch ID item (by design: no prompt per round).
- NO unlock path loads session memory (every `holdInSession` caller swept: `ProtectionRoadLock.swift:58` CLEARS
  at lock; the only non-nil writers are the castle-no-touchID arm and `KeyDoors.swift:266`).
- So Castle+TouchID ⇒ `SyncError.encryptionKeysUnavailable` forever ("Sync locked"); restart can't help.
  P-VX307-U1-3's stated design ("rounds run while an act or unlock has loaded session memory") was never built
  on the unlock side. Her live report + relaunch persistence confirm it.
THE FIX SHAPE (the ruled direction; the implementer proposes the exact seams, the orchestrator rules forks):
(a) the join/act's castle-touchID arm ALSO holds the keys in session (the act just handled them);
(b) the Touch ID UNLOCK (`ProtectionOpenRoad.pressTouchID`, :395) loads the sync-keys touchid item into session
    in the SAME press — one press, never two prompts (the custody read's LAContext must cover the second gated
    read: `KeychainSyncKeysLeaf.readSyncKeys` currently mints its own context; it needs a context-accepting seam);
    load only for a successfully opened BOUND library.
(c) the typed-unlock-in-Castle residue (keys stay unloaded until an act or Touch ID moment) is RECORDED in the
    record file, not built — a design question for her, not an overnight invention.
PINS (red-on-old, headless — the leaves are protocol-typed, scripted in the vx-306-era test worlds): the touchID
arm holds in session; the Touch ID unlock loads session memory for a bound library and never prompts twice
(assert one gated read context / scripted-leaf call counts); the provider's session-first read is already pinned.

### Member 2 — VX-486: the locked-sync row asks for a passphrase its door can't take
Her live report (words in the ticket). The row: `SyncStatusViews.swift` (`lockedLabel` :548; the door acts
`perform(_:)` just above — `.openAccount(tab)` opens the Account sheet). THE FIX: the locked state's door opens
**Settings ▸ Protection** (the pane-request seam survived U1 in `ProtectionController` — find it; the relock
monitors use it), and `lockedLabel` is reworded off the old-road vocabulary — the new line is PROVISIONAL, HERS
to reword (draft close to the join's own ruled language; sentence case, no shouting). Pin: the presented-state
pin (the label) + a door-act pin. Her second symptom — the Account… button doing nothing when the sheet is
already up — fold a one-line disposition into the record (the single-presenter refusing re-present; fix only if
trivial).

### Member 3 — VX-483 (bump it to High when you take it): the walk-rounds opt-in — REQUIRED BEFORE THE REINSTALL
Her call (2026-10-22, in session): the fix must be provable LIVE before her Mac gets the rebuilt app. Scope it
TIGHT: Debug-only; the A4 fence (find it: the dev store's `SyncSession` never configures — "Sync off (dev
store)") lifts ONLY when the walk-switch env (`VARIORUM_WALK_PROJECT_URL`) is present AND the URL's ref is NOT
*[removed for publication]*
throwaway env; refuses the production ref.

### The ladder
Fresh `fable-reviewer`, `notes/REVIEW_PROMPT.md` VERBATIM, zero framing, over the run's whole diff — custody code,
so Fable review is MANDATORY (no waiver on file). Rounds per the standing rules (round 2 re-reviews fixes; cap 3).

### THE LIVE REHEARSAL (the acceptance gate BEFORE the reinstall; one stage window)
Stage claim; the walk Debug build into `App/Variorum/DerivedData/vx488` (NEVER the standard path); the DEV slot's
files aside by `mv` (ALL top-level files, no extension filter — the real slot is in the DEBUG container:
`~/Library/Containers/io.lduarte.Variorum.debug/Data/Library/Application Support/Variorum-dev/`; the
`io.lduarte.Variorum/Variorum-dev` path is a stale decoy); launch with the throwaway env
(`~/.variorum/dev-castle.env` NEVER typed into driven UI; `~/.variorum/dev-vault-throwaway.env` is disposable by
design; VERIFY the walk switch in-process via `ps eww <pid>` BEFORE any credential; the ref guard
*[removed for publication]*
throwaway's user A → Use Castle (Touch ID gate — HER FINGER does the presses; she is present and willing; mark
her-hands rows) → quit → relaunch → the lobby's Touch ID unlock → **THE PROOF: the engine's first round runs**
(the status row leaves "Sync locked"; with member 3's opt-in the round actually lands against the throwaway) —
and VX-486's row/door verified in the same window. Restore the dev slot whole (mv back, same inodes; rule 21's
notice once at the next plain launch is the known design). Window-region captures only. cliclick cannot press
Touch ID and `kp:return` does not drive SwiftUI onSubmit — System Events `key code 36` does (the VX-329
machinery notes, in the plan's walk-window record).

### After the rehearsal is green
1. Merge (PR, merge commit, the harness attribution lines in the body; tickets 486/487/483 + the run Done;
   in-flight row retired; the record file complete).
2. Rebuild Release from main, fresh A1, install `/Applications` on the Pro (zero instances; codesign + sha256).
   **Then she retries her crossing's tail: relaunch → Touch ID → the pull brings her library back. Her
   acceptance closes the Pro.**
3. **The Air**: give her this paste-ready prompt for a Claude session ON the Air (ssh builds fail codesign with
   errSecInternalComponent — it must run in the Air's GUI login): [reproduce the VX-329 session's Air prompt —
   it is in this conversation's record; update it to "verify the tip contains the VX-488 merge"; same steps:
   its own stage lock, pull, Release build into DerivedData/release-0.10, ditto to /Applications, codesign +
   version + sha256, never launch]. Her Air crossing follows (same Start fresh flow; her account reads Castle).
4. **The release at her standing word** (already given): the DMG + appcast publish — the road and HER RULES are
   the memory `variorum-release-publishing` + the VX-348 release record (`notes/handoffs/vx-348-handoff.md`);
   notes approved as written; she sends the testers' message herself (the switch-day script's paste-ready block).
5. **The site delta**: she authorized either handing `notes/stargazing-castle-rebuild-delta-brief.md` to her
   site agent or editing the site directly (a subagent may write the copy; the brief carries facts only).
6. **The window close-out on main**: `notes/plans/vx307-deploy-checklist.md` flipped to RUN with the window's
   record (the deploy numbers above + her first rounds); SyncSpec §12's HELD marker-14 entry gains the result;
   the VX-465-class note if her device-ID era re-minted; board snapshot; memory run-states.
7. **VM-8 (the phone)** — her kickoff prompt is already written (the VX-329 session's message of record; also
   reproduce it for her): she pastes it AFTER everything above; the phone deliberately refuses marker 14 until
   its build lands (her accepted word). The VX-487 fix is core/shared, so the phone inherits it — VM-8's
   acceptance must include the phone's own Castle first round (Face ID gate — the same class).

## STANDING RULES THAT BIND (the short list)
CLAUDE.md + canon preflight IN FULL yourself (CastleRules WHOLE — this run is custody); SessionResiliencyProtocol
(commit per piece, LIVE STATUS, push every commit, foreground waits); one implementer + one reviewer at a time,
fresh per round; no trailers on commits, attribution lines on the PR body only; sentence case, her words
byte-faithful and provisional lines marked HERS; A1 before touching the real store; never quit/kill a real-store
instance; zero-instance gates for installs; `Tools/stage` for anything on-screen or store-touching (no
coordinator — claim directly); NO second /Applications refresh anywhere without its A1; the throwaway is hers to
delete AFTER everything; `/Users/Shared/vx329-rehearsal/` STAYS (hers). Linear by the raw GraphQL
(`~/.variorum/linear.key`; the MCP needs OAuth). If a step needs her (Touch ID presses, GUI, her credentials,
adjudication) — pause and ask; her real credentials are never typed or handled by a session.
