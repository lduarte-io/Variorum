# VX-510 — Run: the first-run sync failures (the orchestrator kickoff; written 2026-10-23 at the 0.10 window's close)

**HER MANDATE, verbatim (2026-10-23, the window sitting — the binding record is
`notes/plans/fixes/vx-494-catchup-hang.md`, rulings R-494-11…R-494-13):** "forget about mobile, figuring out this
exact issue will be the next thing that we do, because I have two testers that set up sync while in standard and both
of them failed to sync completely and we didn't catch that, so this is obviously the biggest issue right now." And:
"VX-510 will have to make and ensure that SEVERAL accounts work and I want to add permissions so that it can read prod
to see if they are added." VM-8 (the phone) is DEFERRED behind this run at her word.

## THE PASTE-READY KICKOFF PROMPT (for her)

```
/architect-phase vx-510 — the first-run sync failures. Both of my beta testers set up sync in Standard and NEITHER
ever pushed a row; we didn't catch it. READ FIRST, IN FULL, YOURSELF: notes/handoffs/vx-510-kickoff.md (this file —
the charter, the two testers' traced stories, the acceptance I ruled, the prod-read road), then
notes/plans/fixes/vx-494-catchup-hang.md WHOLE (the window's record — rulings R-494-4…13 are the sitting's trace),
notes/plans/fixes/vx-488-window-hotfixes.md (the sync-keys fix this seam sits beside), then the standard preflight
(CLAUDE.md + canon, SyncSpec WHOLE, CastleRules WHOLE, SurfaceContracts' protection/app sections,
SessionResiliencyProtocol). The TRACE comes first — no fix without a traced mechanism; findings repo-first. The
acceptance is SEVERAL fresh accounts proven end-to-end with server-side verification. I'm reachable; bundle my calls.
```

## WHAT IS KNOWN (traced at the window sitting; verify, never trust — the record has the evidence)

*[removed for publication]*
  `mode` column has no default; only the backfill set it; her row reads `standard`). Her vault exists; her tenant
  holds ZERO rows and ZERO device cursors — **not one round ever ran**, despite hours of pre-deploy runway. The live
  suspect is VX-498's class (the set-up act triggers no round until a relaunch that never came) or an immediate quit.
*[removed for publication]*
  NO vault ever landed, zero rows, zero cursors — though he typed an enrollment passphrase on the 0.9.3/0.9.4-era
  build. Surviving stories: the old act failed its server write while the UI read as success, or a refusal he walked
  away from with nothing loud afterward. (We watched him live the same moment on 0.10: typed into the sheet, refused,
  walked away believing it done.)
- **VX-498 reproduced on 0.10's walk** (2026-10-23 04:34, the throwaway): the Standard SET-UP act landed
  (`turnOnSync — library … now names account …` in the log; Settings read "This library syncs with your account") but
  the row stayed "Sync locked", no key-proof enrollment, no device cursor, until a relaunch — then the round ran at
  once. The JOIN arm at the same walk ran its first round immediately; the CASTLE set-up at the VX-488 rehearsal did
  too. So the suspect is NARROW: the Standard set-up arm's post-act path.
- **No product bug in the arm choice itself:** the set-up vs join arm follows the server's vault read honestly
  (`RoadAccountFaces`, `.read(exists:)` vs `.unreachable`), and `createVault` refuses over an existing row (409).

## THE CHARTER

1. **THE TRACE, first and whole** (findings repo-first in the run's record before any fix session sees them):
   (a) the CURRENT 0.10 set-up/join acts end-to-end — the act → `SyncSession`/scheduler seam (does the Standard
   set-up act trigger the first round? does anything re-evaluate the row's last refusal after the act?), AND the
   act's own failure modes (can the vault write fail or be cancelled while the UI reads as success?);
   (b) **the archaeology:** the OLD road's enrollment act (deleted whole at VX-329, readable forever in git history —
   *[removed for publication]*
   silent window. The archaeology explains; only the current code gets fixed.
2. **The fixes, pin-before-fix per member:** VX-498 (the mechanism, red-on-old by behavioral revert), VX-507 (the
   act confirms its first round in its own sheet, or says what blocks it — her words drove it: "it said sync is set
   up" while nothing had synced), VX-506 (the pre-join wording — her lines to pick: "sync shouldn't seem like you're
   restarting it"), VX-509 (the standing first-run drill — build it AS the run's evidence vehicle: pinned
   state-transition tests at the act→scheduler seam + a scripted first-run walk that joins the release checklist).
3. **THE ACCEPTANCE (her ruling, use-shaped):** SEVERAL fresh accounts made and proven END-TO-END — sign-up → set-up
   (and at least one JOIN from a second library) → the first round lands → the row reads "Synced ‹time›" WITHOUT a
   relaunch — each verified SERVER-SIDE by read-only queries (the vault row, the data rows, the device cursor).
   **The prod-read road exists:** `Tools/prod-read.sh '<one SELECT>'` (SELECT-only by its own guard; the allow rule
   in `.claude/settings.local.json` names the script). **A fork to put to her at kickoff:** live accounts on
   *[removed for publication]*
   deliberately REFUSES the production ref for driven walks, so a prod walk needs her ruling on the road: the
   Release app on an aside slot, a deliberate fence exception, or her own hands) versus the drill on the THROWAWAY
   (fence-legal, same marker-14 shape) plus one production account verified by prod reads. Present both; she rules.
   Test accounts use plainly-test emails, are recorded in the run's record, and their cleanup (the account-deletion
   road — itself worth exercising once) is part of the run.
4. **Riders and neighbors:** VX-503 (the Standard join's Touch ID prompt — same seam, trace it if the window is
   open); VX-508 is NOT this run's (a one-statement production act at her word after tester A's join — the ticket has
   the exact shape); VX-502/504/505 stay with VX-500.

## MACHINERY

- **Workspace:** branch `vx-510-first-run-sync`, worktree `~/dev/variorum-vx-510` from origin/main; the in-flight
  row added atomically at kickoff (CLAUDE.md's workspace rules). Record file
  `notes/plans/fixes/vx-510-first-run-sync.md` (LIVE STATUS from the first commit; commits say `Part of VX-nnn` per
  member; NO trailers).
- **Cast:** the standing default — Fable orchestrates and cold-reviews (`fable-reviewer`; the diff is
  custody-adjacent Shared/ protection code), Opus implements. If Fable hits safeguards on this material, her
  R-494-1-shaped waiver is her call to repeat, not yours to assume.
- **The dev-store rules bind:** walks on the DEV slot only, `Tools/stage` held, the throwaway env `ps eww`-verified,
  `~/.variorum/dev-castle.env` for Castle moments, the dev slot restored whole before release (the vx-494 record's
  THE DEV SLOT section is the worked example). The helpers she made 2026-10-23 exist:
  `~/.variorum/bin/type-throwaway-passphrase` (+ the throwaway credential files) — walk-build-only by their own guard.
- **Production is read-only except at her hand:** `Tools/prod-read.sh` for SELECTs; anything mutating is her `!` road
  at her explicit word, every query ref-guarded.
- **Evidence floor:** every bug-class fix red-on-old with a behavioral revert; the first-run drill green on the final
  tree; the closing runs per CLAUDE.md (the suites covering every changed source file); a LIVE first-run proof on
  real Postgres per the acceptance above.
