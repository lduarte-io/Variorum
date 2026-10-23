# The VX-307 `key_vault` lockstep — deploy checklist (marker 13 → 14)

**Status: RUN — the window executed 2026-10-22 at her explicit go (the stored PAT road), the tail closed 2026-10-23
(the 0.10 window: VX-488 PR #184, VX-494 PR #185, release 0.10 build 9172 published). THE WINDOW'S NUMBERS:**
artifact 17 `[]` on its FIRST run; the pg_temp belt after it (19 functions with trailing pg_temp); `sync_schema_version()`
= 14; the mode backfill RIGHT ON BOTH LIVE ARMS (her row → castle, the one pre-0.10 tester row → standard; the legacy
apple-held columns left as unread history — VX-508 clears the standard row at her word after its 0.10 join); the grant
sweep **62 OK · 4 INFO · 0 fail** (the R-2 marker-aware expectation). Installs: the Pro's Release at `/Applications`
2026-10-22 (9047), refreshed at the VX-494 merge (9162) and to the published build (9172, from the release DMG, A1
each time); the Air built in its own GUI session 2026-10-23 (9168, codesign + sha256 verified) and updates by Sparkle.
Her first rounds: the Pro's from-zero catch-up LANDED 2026-10-23 04:12 — only after VX-494 fixed the window's one
blocker (the all-or-nothing large-corpus first catch-up; its record `notes/plans/fixes/vx-494-catchup-hang.md`) — and
runs incremental since; the Air crossed in ~8 minutes the same day ("Synced"). THE PHONE did not install (VM-8,
deferred behind VX-510 at her 2026-10-23 word; marker-13 refusal is the fence, as designed). The SyncSpec §12 entry
carries the result; the E2EE disclosure delta (the posture + the earlier-sync-keys count now visible structure) is
recorded there.

*(The original HELD header, kept: written 2026-10-18 at VX-307 U1; her ruling, verbatim in
`notes/plans/vx-307-castle-crossings.md` §1: "I think it makes sense to wait to bump the mirror until we're ready to
release this so that my client doesn't stop syncing." — the checklist ran only in the release window that carried
VX-329's switch, at her explicit go.)*

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

- [x] DONE (the header's window record) — `select user_id, master_wrapped_by_apple_held is not null as apple_held, corpus_key_id,
      rotation_started_seq from key_vault;` — expect her one row; `apple_held` MUST MATCH her real posture (today's
      encoding: wrap present = Standard — `PostureSwitch`'s own reading; the artifact's mode backfill carries exactly
      this semantic). `rotation_started_seq` MUST be null (the artifact refuses mid-rotation).
- [x] DONE (the header's window record) — `select sync_schema_version();` — 13.
- [x] DONE (the header's window record) — the client side at the window's release: `SyncSchema.lockstepVersion == 14`,
      `17_phase_vx307_vault.sql` registered in `AuthRLSDDLTests.lockstepFiles` (both are VX-329's commit — the drift
      pin enforces the pairing), the Release build carrying `ProtectionRoad` switched on.
- [x] DONE (the header's window record) — zero instances of `/Applications/Variorum.app` (pgrep by path), A1 safety copy of the real store into
      `Backups/safety-copies/`.

## The run (her hand or the stored PAT at her explicit go — the 13j/13i-a precedent)

- [x] DONE (the header's window record) — execute `Server/supabase/17_phase_vx307_vault.sql` VERBATIM, one execution. Expected: `[]` on the
      first run (the 13i-c/13i-e precedent).
- [x] DONE (the header's window record) — on any error: read, fix the artifact (amend in repo, never live-only), re-run — the 13j
      read-fix-re-run road; a grant repair follows the 13i-a precedent.
- [x] DONE (the header's window record) — AFTER 17, in the same window (VX-213's held half, her go 2026-10-22): execute
      `Server/supabase/maintenance/vx213-pg-temp-search-path.sql` VERBATIM. REHEARSED GREEN on the throwaway at
      VX-329's kickoff (run 1 caught `rls_auto_enable()`, amended in repo; run 2 whole — 19 functions with trailing
      pg_temp; the sweep after read 62 OK · 4 INFO · 0 fail). Its own guard refuses below marker 14; its verify DO
      fails loud on any missed definer function. Expected: the read-only tail's 19 config rows.

## Verify (read-only, in the window)

- [x] DONE (the header's window record) — `select sync_schema_version();` — 14.
- [x] DONE (the header's window record) — the artifact's four verification queries (its tail): mode/earlier_row_keys present; her row's `mode`
      equals the preflight's posture; rotation columns null; `sync_reencrypt` gone.
- [x] DONE (the header's window record) — the grant sweep (the 13y shape): expect **62 OK · 4 INFO · 0 fail** (the R-2 marker-aware
      correction — `sync_reencrypt`'s row retires at 14; rehearsed twice on the throwaway: post-17 and post-pg_temp).

## Installs (AMENDED to her 2026-10-22 word — the Macs first; the phone follows VM-8)

- [x] DONE (the header's window record) — the Mac Release build at `/Applications` on the PRO (codesign verified; sha256 vs the fresh product;
      the A1 rail and zero instances as ever).
- [x] DONE (the header's window record) — the AIR updated in the same window (both Macs in one window — her 2026-10-22 revision of "update
      every device first").
- [x] DONE (the header's window record) — THE PHONE DOES NOT INSTALL IN THIS WINDOW: VM-8 (the phone's new-road faces) runs after this phase
      merges, on a main-based worktree; her current phone install sits at marker 13 and VISIBLY REFUSES to sync until
      VM-8's build lands — accepted by her word (*"it's ok if the phone doesn't sync for a day after the switch"*).
      The §12 refusal grammar is the fence, not a failure.
- [x] DONE (the header's window record) — her first rounds, both Macs ("sync worked" is the window's close); her phone acceptance moves to
      VM-8's catch-up.

## After

- [x] DONE (the header's window record) — this file flipped to RUN with the window's record; the SyncSpec §12 running-record entry appended (the
      merging session's, on main); the E2EE disclosure delta recorded (the artifact §1's comment: the account's posture
      and its count of sync keys are now visible structure).
