# 13n-b — THE DEPLOY CHECKLIST (marker 12 → 13; the overnight window under R-13nb-28 as amended — mirror → Mac → phone, one sitting, her first rounds at her morning)

**Status: PREPARED, NOT RUN.** The mirror deploy executes under HER EXPLICIT
AUTHORIZATION recorded verbatim at R-13nb-28's amendment ("you can also go
ahead and replace my application when you're done / deploy - I'd like to
authorize that right now, so you simply use the PAT when it's time. my
phone should be available over wifi, if that doesn't work I'll install the
new one tomorrow."). The artifact is `Server/supabase/16_phase13nb_private.sql`
(the architect's own commit `304b41d1` at the U1/U2 seam; Sync/ lines
Fable-only per AF-4). Until the window completes, both installed marker-12
builds would refuse against a marker-13 mirror — so the mirror and the
installs run in ONE window at the closeout tail, AFTER the PR merges (the
Release build comes from merged `main`). The dev store never syncs, so the
branch's marker-13 builds were safe throughout the phase.

## Before the window

- [ ] The U4 ladder closed green; the closeout's whole-target runs green at the tip.
- [ ] The PR merged to `main` (merge commit); `~/dev/variorum` pulled to the merge.
- [ ] Zero-instance window: `pgrep -fl 'Variorum.app/Contents/MacOS'` empty of
      `/Applications` paths (overnight expectation; if her real-store app is
      RUNNING, the window HOLDS — never quit or kill it — and the handoff
      carries the window instead).
- [ ] A1 rail: WAL-safe safety copy of the real store into the container's
      `Backups/safety-copies/` with a UTC name.
- [ ] The one wire-touching fact (the last honest exit, recorded here since
      she reads this tomorrow): `ai_private_at` on `container` and `reading`
      travels PLAIN — a bare timestamp; disclosed structure only: that a
      note or book is marked Private to AI, never which one beyond the row
      identity the mirror already holds, never any words. (R-13nb-4's
      classification, the v1_25 commit's SyncSchema lines.)

## The window (the architect's hands, through the stored PAT — the 13i-c/13i-e precedent + her R-13nb-28 amendment)

1. **The read-only marker probe** (expect `[{"marker":12}]`) — command 0 below.
2. **The mirror:** run `Server/supabase/16_phase13nb_private.sql` WHOLE
   (command 1; expect `[]`; on any live error — the read-fix-re-run road:
   read the refusal, fix THE FILE, commit, re-run; the transaction rolls
   back whole and the marker stays 12).
3. **Verify** (command 2): `sync_schema_version()` = 13 · `ai_private_at`
   present on BOTH `container` and `reading` (expect `column_rows` = 2).
4. **The grant sweep** (command 3): every row OK/INFO — no new table, so
   the sweep should read exactly as at 13i-e (63 OK · 4 INFO · 0 fail).
5. **The Mac:** Release build from merged `main` (lockstepVersion 13) →
   A1-railed copy to `/Applications` → codesign verify by Info.plist +
   codesign output, NEVER by executing the binary (the 13i-d class rule).
   Her relaunch is HER morning act; her first open runs `v1_24` + `v1_25`
   (additive; the grants store is LOCAL-ONLY and mints fresh).
6. **The phone:** `xcrun devicectl device install app` to her iPhone 17 Pro
   *[removed for publication]*
   available at the window's prep) from the merged tree's `VariorumMobile`
   scheme (the 13y/13i-e road). If the phone is unreachable overnight, her
   recorded fallback stands: she installs tomorrow, and the marker-12 phone
   visibly refuses to sync until then — the §12 grammar, an ACCEPTED
   temporary strand (her word).
7. **The §12 running-record entry** in `notes/SyncSpec.md` THEN — the
   marker-12→13 paragraph naming this file, the artifact, and the window's
   facts, with her pending first rounds stated as pending.

## After

- [ ] The plan's ledger rows 8/9 flipped with the window's record.
- [ ] The handoff's morning checklist carries: relaunch the Mac app (first
      round should run clean), open the phone app (first round converges;
      if the phone wasn't installed overnight, install it first), then the
      live both-directions proof — one note edited on each device lands on
      the other.
- [ ] The memory file updated; commit + push.

## THE COMMANDS (each sources the stored token; run from the repo root on merged main; the `!`-prefixed forms are HER versions if any permission classifier blocks the session's POST — the 13j/13i-a precedent)

**0 — the read-only marker probe (expect `[{"marker":12}]`):**
```
cd ~/dev/variorum && set -a && source .env.supabase.local && set +a && REF=$(echo "$VARIORUM_SUPABASE_URL" | sed -E 's|https://([a-z0-9]+)\.supabase\.co.*|\1|') && curl -s -X POST "https://api.supabase.com/v1/projects/$REF/database/query" -H "Authorization: Bearer $SUPABASE_ACCESS_TOKEN" -H "Content-Type: application/json" -d '{"query":"select sync_schema_version() as marker;"}'
```

**1 — THE DEPLOY (the file WHOLE, one session; expect `[]`):**
```
cd ~/dev/variorum && set -a && source .env.supabase.local && set +a && REF=$(echo "$VARIORUM_SUPABASE_URL" | sed -E 's|https://([a-z0-9]+)\.supabase\.co.*|\1|') && jq -Rs '{query: .}' < Server/supabase/16_phase13nb_private.sql | curl -s -X POST "https://api.supabase.com/v1/projects/$REF/database/query" -H "Authorization: Bearer $SUPABASE_ACCESS_TOKEN" -H "Content-Type: application/json" -d @-
```

**2 — VERIFY (expect marker 13 and column_rows 2):**
```
cd ~/dev/variorum && set -a && source .env.supabase.local && set +a && REF=$(echo "$VARIORUM_SUPABASE_URL" | sed -E 's|https://([a-z0-9]+)\.supabase\.co.*|\1|') && curl -s -X POST "https://api.supabase.com/v1/projects/$REF/database/query" -H "Authorization: Bearer $SUPABASE_ACCESS_TOKEN" -H "Content-Type: application/json" -d '{"query":"select sync_schema_version() as marker, (select count(*) from information_schema.columns where column_name = ''ai_private_at'' and table_name in (''container'',''reading'')) as column_rows;"}'
```

**3 — THE GRANT SWEEP (every row OK/INFO; the standing command, unchanged):**
```
cd ~/dev/variorum && set -a && source .env.supabase.local && set +a && REF=$(echo "$VARIORUM_SUPABASE_URL" | sed -E 's|https://([a-z0-9]+)\.supabase\.co.*|\1|') && jq -Rs '{query: .}' < Server/supabase/maintenance/14c-post-deploy-grant-sweep.sql | curl -s -X POST "https://api.supabase.com/v1/projects/$REF/database/query" -H "Authorization: Bearer $SUPABASE_ACCESS_TOKEN" -H "Content-Type: application/json" -d @-
```
