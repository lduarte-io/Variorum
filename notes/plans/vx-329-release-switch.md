# VX-329 — Castle rebuild: the release switch

**Status: READY (plan written at VX-309's closeout, 2026-10-20; her kickoff calls ANSWERED at the 2026-10-22
sitting — the kickoff block below carries them, QUESTIONS #237's answer block is the record). `/architect-phase
vx-329`, overnight mandate, no coordinator tonight; the run pauses before the real-store rehearsal (her hands,
her morning).**
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
> **Her calls — ANSWERED at the 2026-10-22 sitting (QUESTIONS #237's answer block is the record):**
> (1) the switch does NOT wait for VX-212 — phase 6 runs right after this merge, before her public launch.
> (2) the cold review is FABLE (credits are back; no waiver).
> (3) riders IN: VX-461 (the export door — rule 26 and §2 lean on it) · VX-465 (the device-ID drift trace) ·
> VX-462 · VX-464 · VX-473 · VX-463 (ruled: conceal the words fields, with a reveal eye) · VX-469's ruled (c)
> confirm line (wording) · VX-468 if it fits (ruled: the what's-new card waits after a restore). VX-213's `pg_temp`
> has her GO (2026-10-22 follow-up): rehearse it on the throwaway mirror with the rest; its PRODUCTION application
> rides the marker-14 deploy set in the release window — the deploy itself still runs only at her explicit go.
> **VX-470 is RULED but unsized**
> ((c) plus an explicit Standard choice, carried to T-5 — #237's shape): take it only if it fits a batch cleanly,
> else it leads the next run.
> (4) the release is **0.10** (her word: no 1.0 until public launch, and 0.9.9 "will just get more confusing");
> notes drafted for her.
> **VX-423 joins as its own unit** (U3 below — her call at the sitting).
> **No stage coordinator tonight:** VX-329 is the only session running — hold `Tools/stage` claims directly and
> skip the announce step.
> **The pause point (her word):** run U1, U3 and U2's throwaway rehearsal to completion, then PAUSE with everything
> staged for her hands — the byte-copy rehearsal of her real store waits for her morning (stage the byte copy if
> container access allows, else leave her the exact commands; A1 discipline and the zero-instance gate as ever).
> **The phone (her word):** the Macs switch first — see §3's revised deploy line and §4.

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
- **U3 — VX-423 (Fable-reviewed Sync/custody work):** one refresh authority for the scope's rotating refresh
  token — the vault leaf's provider (`FollowingSessionProvider` → its `AuthSession`) and the app's own `AuthSession`
  stop refreshing it independently (F-U1-1's trace, routed at VX-308; the reuse detection fires as
  `refresh_token_already_used` and sync stops until re-login). Evidence: a red-on-old pin on the two-refreshers
  race, and U2's throwaway rehearsal running with the fix in — switch day is wall-to-wall sign-ins, which is why
  this rides here rather than phase 6 (her call at the sitting).
- **The deploy and the release** are hers: the mirror deploy at her explicit go; **both Macs** updated in one window
  (her 2026-10-22 revision of "update every device first": the phone follows when VM-8's catch-up lands — *"it's ok
  if the phone doesn't sync for a day after the switch"* — and cannot sync against marker 14 until then); her
  acceptance on both Macs now and on the phone at its catch-up; the release at her word (**0.10**, notes drafted
  for her); then she deletes the throwaway project.

## 4. Dependencies and risks

- **The phone.** SETTLED at the 2026-10-22 sitting: VM-8 is still Backlog, so the Macs switch first and the phone
  joins when VM-8's faces land (its kickoff prompt is with her; that session runs AFTER this phase merges, on a
  main-based `vm-8` worktree — VM-5 retired the `mobile` branch 2026-10-07 and her phone runs MAIN-built installs,
  so it sits at main's marker today and there is no merge leg). Her current phone install cannot sync against
  marker 14 until the VM-8 build installs — accepted by her word.
- **The export door (VX-461)** writes an empty file today; rule 26's instruction must not name it until it's fixed.
- **Device-ID drift (VX-465)** must be traced: a drifting device ID in Release would make "this Mac's copies" and
  retention lie.
- **Release parity ends here:** every new-road face becomes Release-visible. The #237 calls are SETTLED
  (2026-10-22): VX-463's conceal-with-reveal-eye and VX-469's (c) confirm line ride this run; VX-468 waits-after-
  restore rides if it fits; VX-470's ruled shape is sized at the kickoff (see the kickoff block). VX-234's wording
  pass remains.
- **The cold review** is custody code — Fable, or her explicit waiver.

## 5. Records

Each unit appends its record here (the VX-309 §6 form); the ladder files `notes/plans/vx-329-ladder-round-N.md`;
the walk and the rehearsals in §8; the closeout in §9.
