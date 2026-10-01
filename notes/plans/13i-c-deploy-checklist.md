# 13i-c — THE DEPLOY CHECKLIST (marker 10 → 11; HER window — mirror → Mac → phone, one sitting)

**Status: PREPARED, NOT RUN.** The mirror deploy executes ONLY on her explicit go (CLAUDE.md's
lockstep rule; the 13i-c plan §11). The artifact is `Server/supabase/14_phase13i_c_outflow.sql`
(authored at U1; line-read in the ladder). Until the window completes, both installed marker-10
builds would refuse against a marker-11 mirror — so NOTHING deploys early, and the
`/Applications` refresh HOLDS behind this window (the stranding rule).

## Before the window

- [ ] The 13i-c ladder closed green; the full core + Mac + mobile suites green at the tip.
- [ ] Zero-instance window: SHE quits the real-store app (`pgrep -fl 'Variorum.app/Contents/MacOS'`
      empty of /Applications paths; never killed by a session).
- [ ] A1 rail: WAL-safe safety copy of the real store into the container's
      `Backups/safety-copies/` with a UTC name.
- [ ] Her one-line PRE-DEPLOY SUMMARY: the one wire-touching PROVISIONAL — `auto_tag_ids` travels
      PLAIN (ids, the class of the column it replaces; P-13ic-8) — a last honest exit.

## The window

1. **The mirror:** run `Server/supabase/14_phase13i_c_outflow.sql` whole (her hand via the `!`
   road below, or the architect through the PAT at her word; on any live error — the read-fix-
   re-run road: read the refusal, fix THE FILE, commit, re-run; the transaction rolls back whole
   and the re-run guard permits a retry below marker 11).
2. **Verify** (the file's own read-only tail): `sync_schema_version()` = 11 · the `auto_tag_ids`
   column present on `reading` · the post-deploy grant sweep (`maintenance/14c-post-deploy-grant-
   sweep.sql`) every-row OK/INFO (no new table — the sweep should read exactly as at 13i-a).
3. **The Mac:** Release build (lockstepVersion 11) → A1-railed copy to `/Applications` → codesign
   verify → SHE relaunches; first open runs `v1_20` (the carry-over; any rule-less gathering to
   the Trash); her first sync round pushes the carried rows; verify a clean round (outbox empty,
   no repair storm, no refusal).
4. **The phone:** her Xcode run to device (same tree); its first round converges (both devices
   ran the same migration; server-wins CAS meets the carried rows).
5. **Both directions proven live:** one note edited on each device lands on the other.
6. **The §12 running-record entry** is written in `notes/SyncSpec.md` THEN — the event is
   recorded when it happened (the marker-10→11 paragraph naming this file, the artifact, and
   the window's facts), and the master plan/closeout flip with it.

## After

- [ ] `notes/plans/phase-13i-c-owned-finished-sealed.md` ledger row 7 flipped with the window's record.
- [ ] The memory file updated; commit + push.

## THE `!` ROAD (the 13i-a checklist's commands with the file name swapped; these run by HER
## hand, output read in-conversation; each sources the stored token; run from the repo root)

**0 — the read-only marker probe (expect `[{"marker":10}]`):**
```
! cd ~/dev/variorum && set -a && source .env.supabase.local && set +a && REF=$(echo "$VARIORUM_SUPABASE_URL" | sed -E 's|https://([a-z0-9]+)\.supabase\.co.*|\1|') && curl -s -X POST "https://api.supabase.com/v1/projects/$REF/database/query" -H "Authorization: Bearer $SUPABASE_ACCESS_TOKEN" -H "Content-Type: application/json" -d '{"query":"select sync_schema_version() as marker;"}'
```

**1 — THE DEPLOY (the file WHOLE, one session; expect `[]`; an error rolls back whole and the
marker stays 10 — read, fix, re-run):**
```
! cd ~/dev/variorum && set -a && source .env.supabase.local && set +a && REF=$(echo "$VARIORUM_SUPABASE_URL" | sed -E 's|https://([a-z0-9]+)\.supabase\.co.*|\1|') && jq -Rs '{query: .}' < Server/supabase/14_phase13i_c_outflow.sql | curl -s -X POST "https://api.supabase.com/v1/projects/$REF/database/query" -H "Authorization: Bearer $SUPABASE_ACCESS_TOKEN" -H "Content-Type: application/json" -d @-
```

**2 — VERIFY (expect marker 11 and one `auto_tag_ids` row):**
```
! cd ~/dev/variorum && set -a && source .env.supabase.local && set +a && REF=$(echo "$VARIORUM_SUPABASE_URL" | sed -E 's|https://([a-z0-9]+)\.supabase\.co.*|\1|') && curl -s -X POST "https://api.supabase.com/v1/projects/$REF/database/query" -H "Authorization: Bearer $SUPABASE_ACCESS_TOKEN" -H "Content-Type: application/json" -d '{"query":"select sync_schema_version() as marker, (select count(*) from information_schema.columns where table_name = ''reading'' and column_name = ''auto_tag_ids'') as column_rows;"}'
```

**3 — THE GRANT SWEEP (every row OK/INFO; the 13i-a checklist's command, unchanged):**
```
! cd ~/dev/variorum && set -a && source .env.supabase.local && set +a && REF=$(echo "$VARIORUM_SUPABASE_URL" | sed -E 's|https://([a-z0-9]+)\.supabase\.co.*|\1|') && jq -Rs '{query: .}' < Server/supabase/maintenance/14c-post-deploy-grant-sweep.sql | curl -s -X POST "https://api.supabase.com/v1/projects/$REF/database/query" -H "Authorization: Bearer $SUPABASE_ACCESS_TOKEN" -H "Content-Type: application/json" -d @-
```
