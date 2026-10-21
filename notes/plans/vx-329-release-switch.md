# VX-329 — Castle rebuild: the release switch

**Status: PLANNED (written at VX-309's closeout, 2026-10-20). Kickoff at her word; `/architect-phase vx-329`
recommended (design calls arise mid-run and her hands are in two rehearsals).**
`Ticket: VX-329 · Project: Castle & backups before launch · Branch: vx-329-release-switch · Worktree:
~/dev/variorum-vx-329 (Pro)`. Holds the Sync/-custody slot.

> **KICKOFF MESSAGE (paste-ready).** STEP 0: the bout ritual (pull both repos, `Tools/vx sync`), then from
> `~/dev/variorum` on `main`: `git worktree add -b vx-329-release-switch ~/dev/variorum-vx-329 origin/main`; push
> the branch; the in-flight row (HOLDS the Sync/-custody slot); Linear VX-329 → In Progress; announce to the stage
> coordinator. **Read first, in full, never delegated:** CLAUDE.md + its canon; `notes/SessionResiliencyProtocol.md`;
> `notes/CastleRules.md` WHOLE (rules 15, 26 and the considered-and-not-pursued ledger are this phase's heart);
> `notes/SyncSpec.md` WHOLE (§12 lockstep — the marker 13→14 bump is this phase's); `notes/SurfaceContracts.md`'s
> protection and doors sections; the VX-329 ticket body and its comments (VX-309's seven inputs);
> `notes/plans/vx-308-accounts-key-doors.md` §5R (the fresh-mirror runbook and the rehearsed artifact 17) and its
> WALK RECORD; `notes/plans/vx-309-copies-and-words.md` §8–§9 (the walk's machinery notes and the born tickets);
> `notes/plans/vx-266-castle-backups-prelaunch.md` §3.15 (today's deletion list — superseded where the ticket says
> "nothing is kept read-only"); QUESTIONS #237 (her VX-309 bundle — any answer there may reshape a unit).
> **Her calls before the first spawn (bring as one question batch):** (1) does the switch wait for VX-212 (phase 6,
> the poison-row case)? (2) the cold review — Fable (the custody/`Sync/` rule) or her waiver if credits are out;
> (3) riders: VX-461 (the export door — recommended IN, rule 26 leans on it), VX-465 (device-ID drift trace —
> recommended IN), VX-213's `pg_temp` (her go), VX-462 / VX-464 / VX-473 (small Castle & sync items in the touched
> area); (4) the release number and notes (drafted for her).

## 1. What this phase is

The last step of the rebuild: Release builds take the new road. One compile-time switch
(`ProtectionRoad.newRoadIsLive`) flips; today's whole deciding and writing code is deleted in the same change (the
old envelope, the legacy readers, the old markers, `CorpusRotation`, `PostureSwitch`, the posture drill VX-233, the
old suites whose release-floor reds are VX-406) — nothing is kept read-only. The `key_vault` lockstep (artifact
`Server/supabase/17_phase_vx307_vault.sql`, marker 13 → 14, registered in the DDL drift pin with `lockstepVersion` →
14 in ONE commit — VX-307's pinned pairing) deploys at her explicit go in this release's window. No migration (rule
26): everyone with a pre-design store exports or signs into sync before the switch, then starts fresh; her own old
stores are kept whole as copies.

## 2. The one question this phase must answer before any real store crosses

**How does a fresh new-road library get her synced writing back?** Today's account holds her rows sealed under
today's sync keys; the new account vault (artifact 17) is new. Rule 15 says the account keeps every sync key it has
ever had and a device joining years later reads everything — this phase must PROVE that holds across the switch (or
find that it doesn't and bring it to her), on the throwaway project, before her stores are touched. If the answer is
"export, then bring in", T-8 (VX-309) is the bring-in road and VX-461's export door must work first.

## 3. Proposed cut (the kickoff session's to make; acceptance units, one implementer each)

- **U1 — THE SWITCH (Fable-reviewed custody work):** flip the switch; delete today's road per the ticket; the
  lockstep commit (artifact 17 registered + `lockstepVersion` 14); the ⌃⌘L chord declared with its helper row
  (P-VX309-U1c-4 (b)); the protection suites green under the Release configuration (`swift test -c release`
  included — VX-380/VX-406's reds die with the deleted suites or are fixed). Evidence: the Release build runs the new
  road; the suites green under Release; the deletion is complete (a grep sweep table, each legacy symbol GONE).
- **U2 — SWITCH DAY, REHEARSED:** the step-by-step switch-day script for her (§2's answer inside it), run start to
  finish on the throwaway project with two test accounts and two devices' worth of libraries; then the rehearsal on a
  byte-copy of her real store on the dev slot (Look inside, then Make this my library — her hands, her credentials);
  the website delta brief REWRITTEN to the rules (F-U2-4) and handed to the site agent after a check against the
  shipped build; VX-379's truth-check of the guide and panes against the Release build, and her real store's re-seed
  plan. Evidence: the script walked green on the throwaway; her rehearsal done; the brief rewritten.
- **The deploy and the release** are hers: the mirror deploy at her explicit go; every device updated in one window
  ("update every device first: no crossing until every device runs the new build"); her acceptance on both Macs and
  the phone; the release at her word (notes drafted for her); then she deletes the throwaway project.

## 4. Dependencies and risks

- **The phone.** Her acceptance includes the phone and the switch needs every device on the new build. Check the VM
  board at kickoff: the phone's new-road faces (VM-8's ledger row; F-U2-7) — if the phone isn't ready, that's a
  scheduling call for her, not something to work around.
- **The export door (VX-461)** writes an empty file today; rule 26's instruction must not name it until it's fixed.
- **Device-ID drift (VX-465)** must be traced: a drifting device ID in Release would make "this Mac's copies" and
  retention lie.
- **Release parity ends here:** every new-road face becomes Release-visible — VX-234's wording pass and the open
  Needs-Lillian calls from #237 (VX-463, VX-468, VX-469, VX-470) are worth settling before strangers see them.
- **The cold review** is custody code — Fable, or her explicit waiver.

## 5. Records

Each unit appends its record here (the VX-309 §6 form); the ladder files `notes/plans/vx-329-ladder-round-N.md`;
the walk and the rehearsals in §8; the closeout in §9.
