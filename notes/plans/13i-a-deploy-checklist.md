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

## THE `!` ROAD (2026-10-01 — the classifier blocked the session's own POST, the 13j precedent; these run by HER hand, output read in-conversation)

Each command sources the stored token and is self-contained. Run from the repo root.

**0 — the read-only marker probe (expect `[{"marker":9}]`):**
```
! cd ~/dev/variorum && set -a && source .env.supabase.local && set +a && REF=$(echo "$VARIORUM_SUPABASE_URL" | sed -E 's|https://([a-z0-9]+)\.supabase\.co.*|\1|') && curl -s -X POST "https://api.supabase.com/v1/projects/$REF/database/query" -H "Authorization: Bearer $SUPABASE_ACCESS_TOKEN" -H "Content-Type: application/json" -d '{"query":"select sync_schema_version() as marker;"}'
```

**1 — THE DEPLOY (the file WHOLE, one session; expect `[]`; an error rolls back whole and the
marker stays 9 — read, fix, re-run):**
```
! cd ~/dev/variorum && set -a && source .env.supabase.local && set +a && REF=$(echo "$VARIORUM_SUPABASE_URL" | sed -E 's|https://([a-z0-9]+)\.supabase\.co.*|\1|') && jq -Rs '{query: .}' < Server/supabase/13_phase13i_wings.sql | curl -s -X POST "https://api.supabase.com/v1/projects/$REF/database/query" -H "Authorization: Bearer $SUPABASE_ACCESS_TOKEN" -H "Content-Type: application/json" -d @-
```

**2 — the verification tail (expect marker 10; wing/shelf present with RLS forced; the nine
reading columns; the allowlist + ciphertext probes true):**
```
! cd ~/dev/variorum && set -a && source .env.supabase.local && set +a && REF=$(echo "$VARIORUM_SUPABASE_URL" | sed -E 's|https://([a-z0-9]+)\.supabase\.co.*|\1|') && curl -s -X POST "https://api.supabase.com/v1/projects/$REF/database/query" -H "Authorization: Bearer $SUPABASE_ACCESS_TOKEN" -H "Content-Type: application/json" -d '{"query":"select sync_schema_version() as marker, (select count(*) from wing) as wings, (select count(*) from shelf) as shelves, (select relrowsecurity and relforcerowsecurity from pg_class where relname = $$wing$$) as wing_rls, (select relrowsecurity and relforcerowsecurity from pg_class where relname = $$shelf$$) as shelf_rls, (select count(*) from information_schema.columns where table_name = $$reading$$ and column_name in ($$wing_id$$,$$shelf_id$$,$$shelf_position$$,$$starred$$,$$owned$$,$$sealed_at$$,$$hide_owned$$,$$intake_seating$$,$$auto_tag_id$$)) as reading_cols, (select pg_get_functiondef($$sync_pull(bigint,text,text,text,int,text)$$::regprocedure) like $$%''wing'', ''shelf''%$$) as allowlist_grew, (select pg_get_functiondef($$key_vault_update(jsonb, int, text, text)$$::regprocedure) like $$%\"shelf\": [\"name\", \"glyph\"]%$$) as cipher_grew;"}'
```

**3 — the grant sweep (expect every row OK/INFO, wing + shelf rows included):**
```
! cd ~/dev/variorum && set -a && source .env.supabase.local && set +a && REF=$(echo "$VARIORUM_SUPABASE_URL" | sed -E 's|https://([a-z0-9]+)\.supabase\.co.*|\1|') && jq -Rs '{query: .}' < Server/supabase/maintenance/14c-post-deploy-grant-sweep.sql | curl -s -X POST "https://api.supabase.com/v1/projects/$REF/database/query" -H "Authorization: Bearer $SUPABASE_ACCESS_TOKEN" -H "Content-Type: application/json" -d @- | jq -r '.[] | select(.verdict != null) | "\(.verdict) \(.item // .relname // "")"' | sort | uniq -c
```


## THE WINDOW RECORD (2026-10-01 — running; completed lines land as they happen)

- Probe: marker 9 ✓ (her paste, 02:0x). THE DEPLOY: `[]` first run — the whole file committed
  (13y took two). Verify: marker **10**; wing/shelf present, zero rows, RLS forced; the nine
  reading columns; `cipher_grew` true; `allowlist_grew` read FALSE from a PROBE BUG (inside
  `$$`-quotes a doubled `''` is literal — the corrected `chr(39)` probe read BOTH pull and push
  allowlists grown ✓). The grant sweep: **63 OK · 4 INFO · zero mismatches**.
- The install: `/Applications/Variorum.app` = the marker-10 Release build, codesign-verified
  source and installed.
- **THE WINDOW'S ONE LIVE FINDING (the 13j-precedent class — only a live round can reach grant
  reality):** her first round refused `42501 permission denied for table wing` — the data RPCs
  run as the non-bypass `variorum_definer`, and 13's per-table template (copied from 09, which
  predates the role) missed the per-table DML grant the 14c gate file gives every sibling.
  **Repair: `grant select, insert, update, delete on wing, shelf to variorum_definer;` by her
  hand; the artifact amended to carry it; the sweep's shape did not check definer table grants —
  noted for its next owner.**
- The grant applied by her hand (`wing_ok`/`shelf_ok` both true) → her RETRY round ran clean:
  **"Synced 2:59 AM"** — the Mac half of the window is COMPLETE (the recast rows pushed; the
  marker handshake held). The PHONE's refresh is hers, any time; it refuses visibly until then.
- The §12 running-record entry written (SyncSpec §12, marker 9→10, with the live finding).
