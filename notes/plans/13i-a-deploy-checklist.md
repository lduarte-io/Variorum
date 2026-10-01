# 13i-a — THE DEPLOY CHECKLIST (marker 9 → 10; HER window — mirror → Mac → phone, one sitting)

**Status: PREPARED, NOT RUN.** The mirror deploy executes ONLY on her explicit go (CLAUDE.md's
lockstep rule; the 13i-a plan §8). The artifact is `Server/supabase/13_phase13i_wings.sql`
(authored at U1/U2, line-read in the ladder). Until the window completes, both installed marker-9
builds would refuse against a marker-10 mirror — so NOTHING deploys early, and the
`/Applications` refresh HOLDS behind this window (the stranding rule).

## Before the window

- [ ] The 13i-a ladder closed green; the full Mac + mobile + core suites green at the tip.
- [ ] Zero-instance window: SHE quits the real-store app (`pgrep -fl 'Variorum.app/Contents/MacOS'`
      empty of /Applications paths; never killed by a session).
- [ ] A1 rail: WAL-safe safety copy of the real store into the container's
      `Backups/safety-copies/` with a UTC name.
- [ ] Her one-line PRE-DEPLOY SUMMARY read aloud (the 13y governance shape): the TWO
      13i-a PROVISIONALs — the R2 owned-exclusivity repair's shape (#167) and the grandfathered
      legacy rule terms — one line each, a last honest exit.

## The window

1. **The mirror:** run `Server/supabase/13_phase13i_wings.sql` whole (her hand via the `!` road,
   or the architect through the PAT at her word; on any live error — the 13y read-fix-re-run
   road: read the refusal, fix THE FILE, commit, re-run; the transaction rolls back whole and
   the re-run guard permits a retry below marker 10).
2. **Verify** (the file's own read-only tail): `sync_schema_version()` = 10 · `wing`/`shelf`
   present, zero rows, RLS forced both · the nine `reading` columns + `container.wing_id` +
   `tag.wing_id` + `reading_post.status` present · the allowlist and ciphertext-registry probes
   true · the post-deploy grant sweep (`maintenance/14c-post-deploy-grant-sweep.sql`) every-row
   OK/INFO, wing + shelf rows included.
3. **The Mac:** Release build (lockstepVersion 10) → A1-railed copy to `/Applications` → codesign
   verify → SHE relaunches; first open runs `v1_18` (the store migrates: kind recast, pins →
   starred, the designated book stamps `'daily'`); her first sync round pushes the recast
   `reading` rows; verify a clean round (outbox empty, no repair storm, no refusal).
4. **The phone:** her Xcode run to device (same tree); its first round converges (the recast
   rows meet by ordinary server-wins CAS — both devices ran the same migration).
5. **Both directions proven live:** one note edited on each device lands on the other.
6. **The §12 running-record entry** is written in `notes/SyncSpec.md` THEN — the event is
   recorded when it happened (the marker-9→10 paragraph naming this file, the artifact, and the
   window's facts), and the master plan/closeout flip with it.

## After

- [ ] `notes/plans/phase-13i-a-schema-event.md` ledger row 13 flipped with the window's record.
- [ ] The memory file updated; commit + push.
- [ ] 13i-b's plan is the next kickoff's (at her word).
