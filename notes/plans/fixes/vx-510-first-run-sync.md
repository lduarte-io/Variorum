# VX-510 — Run: the first-run sync failures

**STATUS: OPEN (kickoff 2026-10-23). Branch `vx-510-first-run-sync`, worktree `~/dev/variorum-vx-510`, the Pro.
The charter is `notes/handoffs/vx-510-kickoff.md` (read whole); the window's trace is
`notes/plans/fixes/vx-494-catchup-hang.md` (R-494-4…13); the sync-keys seam beside this one is
`notes/plans/fixes/vx-488-window-hotfixes.md`. Members: VX-498 (the set-up act's silent no-round — the mechanism) ·
VX-507 (the act confirms its first round) · VX-506 (the pre-join wording, riding) · VX-509 (the standing first-run
*[removed for publication]*
one-statement act surfaced to her the moment it lands). Cast: Fable orchestrates and cold-reviews
(`fable-reviewer` — the diff is custody-adjacent Shared/ protection code), Opus implements, one at a time.
Pin-before-fix PER MEMBER; commits say `Part of VX-nnn`; NO trailers.**

## HER KICKOFF RULINGS (2026-10-23, the kickoff message — verbatim-faithful; recorded before any work)

- **R-510-1 — THE PROD ROAD, ruled (the kickoff file's fork is DECIDED):** "The kickoff file talks about choosing
  between three roads for the live accounts — I'm ruling it now: make a deliberate, narrow exception so dev test
  accounts can reach production (a named road for named test accounts; never delete the fence that keeps every
  other walk off prod), because otherwise how will we ever know if something actually works in prod or not?"
  → The acceptance's fresh accounts run against PRODUCTION through a named, narrow exception: the fence stays for
  everything else; the exception admits only named test accounts. The exact seam is a design item below (D-ROAD).
- **R-510-2 — TWO TEST ACCOUNTS, RIGOROUS LIFECYCLE:** "maybe we need two dev accounts, one standard and one
  castle, and we need to go through RIGOROUS testing for both: signing up, syncing, making a backup, restoring a
  backup, changing keys, trying the backup again, etc." And: "You can also bring those testing items to me — maybe
  it's worth doing them now, as part of this. I don't know. I want to release soon and I NEED to know that
  everywhere where the rubber meets the road is alright."
  → Bundled as a kickoff-sitting decision below (THE SITTING BUNDLE): the first-run acceptance (several fresh
  accounts, set-up + join, both postures) lands in THIS run per the charter; whether the FULL lifecycle drill
  (backup → restore → key change → backup again, both postures) runs inside this run or as its own chartered
  follow-up is her call — the kickoff prompt's own words: "if the full two-posture lifecycle drill outgrows this
  run, charter it as its own written follow-up — but the first-run trace, fix, and live proof land in THIS run
  either way."
- **R-510-3 — PERMISSIONS:** "I do NOT CARE what I need to add to your permissions — propose narrow rules like
  prod-read and I'll add them." → Any new road this run needs is proposed to her as a narrow named rule
  (the `Tools/prod-read.sh` precedent), never worked around.
- **R-510-4 — THE UNDER-TESTED-SEAMS SWEEP:** "we NEED real testing on every area where the rubber meets the road
  because I want to launch soon. As part of this, sweep for what else is under-tested at the live seams and bring
  me the map." → A deliverable of this run: THE MAP — every seam where the product meets the real world (live
  Postgres, the real keychain, Touch ID, Sparkle, the DMG, the real filesystem, the MCP socket…), what evidence
  each has today, and what it lacks; propose-only, hers to slot.

## THE CHARTER (the kickoff file's, binding)

1. **THE TRACE, first and whole** — (a) the CURRENT 0.10 set-up/join acts end-to-end: the act → `SyncSession`/
   scheduler seam (does the Standard set-up act trigger the first round? does anything re-evaluate the row's last
   refusal after the act?), AND the act's own failure modes (can the vault write fail or be cancelled while the UI
   *[removed for publication]*
   *[removed for publication]*
   archaeology explains; only the current code gets fixed. Findings land HERE before any fix session sees them.
2. **The fixes, pin-before-fix per member:** VX-498 (red-on-old by behavioral revert), VX-507 (the act confirms
   its first round in its own sheet, or says what blocks it), VX-506 (the pre-join wording — her line: "sync
   shouldn't seem like you're restarting it"), VX-509 (the standing drill, built AS the run's evidence vehicle).
3. **THE ACCEPTANCE (hers, use-shaped):** SEVERAL fresh accounts made and proven END-TO-END — sign-up → set-up
   (and at least one JOIN from a second library) → the first round lands → the row reads "Synced ‹time›" WITHOUT
   a relaunch — each verified SERVER-SIDE by `Tools/prod-read.sh` (the vault row, the data rows, the device
   cursor). Per R-510-1 this runs on PRODUCTION through the named test-account road. Test accounts use
   plainly-test emails, are recorded here, and their cleanup (the account-deletion road — itself worth exercising
   once) is part of the run.
4. **Riders and neighbors:** VX-503 (the Standard join's Touch ID prompt — same seam, trace it if the window is
   *[removed for publication]*
   `Tools/prod-read.sh` at natural moments; the moment it lands, surface the one-statement act for her `!` hand.

## LIVE STATUS (flip per piece, same commit; unverified claims marked PENDING)

| # | Piece | Status |
|---|---|---|
| 0 | Kickoff: preflight read whole (the kickoff file, vx-494 WHOLE, vx-488, CLAUDE.md + canon, SyncSpec WHOLE, CastleRules WHOLE, SurfaceContracts, the resiliency protocol, the master plan, TICKETS, QUESTIONS tail); worktree + branch; in-flight row on main; VX-510 In Progress with members parented; this record with her kickoff rulings | DONE (this commit) |
| 1 | THE TRACE (a) — the current set-up/join acts end-to-end (the act→scheduler seam; the act's own failure modes) | NOT STARTED |
| 2 | THE TRACE (b) — the archaeology: the old road's enrollment act as tester B ran it on Oct 13 | NOT STARTED |
| 3 | The kickoff sitting bundle answered (D-ROAD shape; lifecycle drill in-run or chartered; the acceptance's account set) | NOT STARTED — bundled after the trace |
| 4 | The fixes: VX-498 + VX-507 + VX-506 (+ VX-503 if open), pins red-on-old per member | NOT STARTED |
| 5 | VX-509 — the standing first-run drill (state-transition pins at the act→scheduler seam + the scripted walk on the release checklist) | NOT STARTED |
| 6 | D-ROAD — the named prod test-account road (the fence exception per R-510-1), with its pins | NOT STARTED — shape proposed at the sitting bundle |
| 7 | THE ACCEPTANCE — several fresh accounts end-to-end on production, server-verified | NOT STARTED |
| 8 | THE MAP — the under-tested live seams (R-510-4), propose-only | NOT STARTED |
| 9 | The ladder (fresh `fable-reviewer`, whole run diff), dispositions, fixes | NOT STARTED |
| 10 | Closing runs (suites covering every changed source), PR, merge, closeout ledgers, handoff | NOT STARTED |

## ENVIRONMENT TRAPS (binding on every session of this run — the vx-494/vx-488 traps, with this run's deltas)

Instance checks `pgrep -fl 'Variorum.app/Contents/MacOS'` AND discriminate by PATH; real-store instances by
STORE, never quit/kill; no Release builds or /Applications refreshes while one lives. EVERY `xcodebuild test` run
and anything touching the screen or a shared store holds a `Tools/stage` claim. Headless `swift build`/`swift
test` is stage-free. zsh `pipestatus`; NEVER a custom build configuration. Backups WAL-safe, UTC names, into
`Backups/safety-copies/` (A1). Walks on the DEV slot only; the throwaway env `ps eww`-verified before any
credential (MAP THE NAMES — the env file's keys are `VARIORUM_THROWAWAY_*`, the walk switch wants
`VARIORUM_WALK_*`); the dev Castle pair `~/.variorum/dev-castle.env`; the throwaway's users
`~/.variorum/dev-vault-throwaway.env`; her helpers `~/.variorum/bin/type-throwaway-passphrase` (+ credential
files), walk-build-only by their own guard; values never echoed, never committed, NEVER typed into driven UI.
The walk's Debug build lives at `App/Variorum/DerivedData/vx510` (never the standard path). The REAL dev slot is
the DEBUG container (`~/Library/Containers/io.lduarte.Variorum.debug/Data/Library/Application Support/
Variorum-dev/`). The dev slot's files go aside by `mv`, ALL top-level files; restore whole before release;
sign the walk session OUT before restoring (O-B2). cliclick cannot press Touch ID; SwiftUI onSubmit needs System
Events `key code 36`. **Production is read-only except at her hand:** `Tools/prod-read.sh` for SELECTs
*[removed for publication]*
Debug app NEVER signs into her real account. Implementers: no subagents, no stage, no Debug launches, no
dev-store touch; headless + `build-for-testing` only; checkpoint commits per piece, push each, LIVE STATUS flips
in the same commit, PENDING on every unverified claim; foreground waits only (poll, never `tail -f`, never end a
turn waiting).

## THE TRACE (piece 1 — findings land here before any fix session sees them)

*(to be written by the orchestrator's trace, next)*

## THE ARCHAEOLOGY (piece 2)

*(to be written)*

## OPEN ITEMS (bundled for her; kept current)

- The kickoff sitting bundle (piece 3): D-ROAD's exact shape; the lifecycle drill in-run vs chartered follow-up;
  the acceptance's account set (two standing dev accounts — standard + castle — vs per-run fresh accounts).
