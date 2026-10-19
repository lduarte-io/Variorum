# The VX-307 `key_vault` lockstep — deploy checklist (marker 13 → 14)

**Status: HELD — written 2026-10-18 at VX-307 U1 (the artifact `Server/supabase/17_phase_vx307_vault.sql`).
HER RULING (2026-10-18, verbatim in `notes/plans/vx-307-castle-crossings.md` §1): "I think it makes sense to wait to
bump the mirror until we're ready to release this so that my client doesn't stop syncing." — THIS CHECKLIST RUNS ONLY
IN THE RELEASE WINDOW THAT CARRIES VX-329's SWITCH, at her explicit go. Nothing here runs at VX-307's close.**

Every row below is PENDING-UNTIL-LIVE. The 13i-e/13n-b window shape: mirror first, then BOTH installs in the same
window behind the A1 rail, then her first rounds.

**REHEARSED 2026-10-19 (VX-308 §5R — the dress rehearsal on `variorum-vault-throwaway`, her option (b); the record
is the VX-308 plan's §6 REHEARSAL RECORD).** The full chain 01→16 (+ the two 14c gate scripts between 09 and 10)
reconstructed a faithful marker-13 mirror from scratch — every artifact `[]` on its FIRST run; the grant sweep read
production's exact 13n-b shape (63 OK · 4 INFO · 0 fail). Two pre-event `key_vault` rows were planted (one
Standard-shaped, one Castle-shaped, rotation columns null) and the preflight probe row rehearsed against them.
**Artifact 17 then ran `[]` on its FIRST run on real Postgres**; all four verification queries below came back
exactly as written — the `mode` backfill RIGHT ON BOTH ARMS (apple-held wrap present → standard; absent → castle),
`earlier_row_keys` jsonb YES, the journal-bridge NOT NULLs relaxed, rotation columns clear, `sync_reencrypt` gone,
marker 14. **Two findings, both fixed in repo at the rehearsal:** R-1 — a fresh-chain order rule (the
`pre13x-ladder-rotation-clearing-guard` overlay is SUPERSEDED by 12's fold-in: applied after 12 it re-introduces a
retired signature the sweep then flags; on a fresh mirror it is NOT applied — 12 carries its body); R-2 — the grant
sweep's `sync_reencrypt` expectation row is now MARKER-AWARE (demanded below 14, retired at 14), so THIS WINDOW's
post-deploy sweep expects **62 OK · 4 INFO · 0 fail**, not the 13n-b counts (the sweep row below reads with that
correction). The rows stay PENDING-UNTIL-LIVE — the rehearsal is additive evidence, never the window.

## Preflight (read-only probes, before the window)

- [ ] PENDING — `select user_id, master_wrapped_by_apple_held is not null as apple_held, corpus_key_id,
      rotation_started_seq from key_vault;` — expect her one row; `apple_held` MUST MATCH her real posture (today's
      encoding: wrap present = Standard — `PostureSwitch`'s own reading; the artifact's mode backfill carries exactly
      this semantic). `rotation_started_seq` MUST be null (the artifact refuses mid-rotation).
- [ ] PENDING — `select sync_schema_version();` — 13.
- [ ] PENDING — the client side at the window's release: `SyncSchema.lockstepVersion == 14`,
      `17_phase_vx307_vault.sql` registered in `AuthRLSDDLTests.lockstepFiles` (both are VX-329's commit — the drift
      pin enforces the pairing), the Release build carrying `ProtectionRoad` switched on.
- [ ] PENDING — zero instances of `/Applications/Variorum.app` (pgrep by path), A1 safety copy of the real store into
      `Backups/safety-copies/`.

## The run (her hand or the stored PAT at her explicit go — the 13j/13i-a precedent)

- [ ] PENDING — execute `Server/supabase/17_phase_vx307_vault.sql` VERBATIM, one execution. Expected: `[]` on the
      first run (the 13i-c/13i-e precedent).
- [ ] PENDING — on any error: read, fix the artifact (amend in repo, never live-only), re-run — the 13j
      read-fix-re-run road; a grant repair follows the 13i-a precedent.

## Verify (read-only, in the window)

- [ ] PENDING — `select sync_schema_version();` — 14.
- [ ] PENDING — the artifact's four verification queries (its tail): mode/earlier_row_keys present; her row's `mode`
      equals the preflight's posture; rotation columns null; `sync_reencrypt` gone.
- [ ] PENDING — the grant sweep (the 13y shape): expect the 13n-b counts ±0 (no new table; one function redefined,
      owner/grants re-asserted in the artifact).

## Installs (same window — no marker-13 build outlives the bump)

- [ ] PENDING — the Mac Release build at `/Applications` (codesign verified; sha256 vs the fresh product).
- [ ] PENDING — the phone via `devicectl` (the 13y/13i-e road).
- [ ] PENDING — her first rounds, both devices ("sync worked" is the window's close); the §12 refusal grammar has
      nothing to catch when both installs land in-window.

## After

- [ ] PENDING — this file flipped to RUN with the window's record; the SyncSpec §12 running-record entry appended (the
      merging session's, on main); the E2EE disclosure delta recorded (the artifact §1's comment: the account's posture
      and its count of sync keys are now visible structure).
