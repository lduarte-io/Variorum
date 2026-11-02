# VX-495 / VX-496 — the keyset pull's server-half deploy checklist (a MAINTENANCE artifact; marker 14 stays)

**Status: HELD — every row PENDING-UNTIL-LIVE; the run is at her EXPLICIT word only (R-500-6, `notes/plans/fixes/vx-500-sync-followups.md`).**
The artifact: `Server/supabase/maintenance/vx495-pull-keyset.sql` (SHAPE B — D-495 EVIDENCE; `sync_pull_remaining` per R-500-1).
The rollback: `Server/supabase/maintenance/vx495-rollback.sql`. Both idempotent, both guarded ≥ marker 14, neither writes
`sync_meta`. NOT a lockstep event: the wire is byte-identical (signature, output shape, order), so no client install
follows — every 0.10.7 device gets the cheaper pages at its next catch-up; the count RPC sits unused (authenticated-only)
until the client half ships with the held PR. The pre-deploy gate: the SERVER-HALF ROUND closed (round 1
`vx-500-server-half-round1.md` 0/0/3 MINOR, fixed; round 2 `vx-500-server-half-round2.md` 0/0/2 MINOR, both landed, no round 3) — **THE GATE IS OPEN (2026-11-01 ~17:15 MDT); the run waits for her word.**

## Preflight (read-only; DONE 2026-11-01 ~16:55 MDT by the orchestrator through `Tools/prod-read.sh`, from `~/dev/variorum`)

*[removed for publication]*
      2026-11-01 23:27 UTC — the active Mac), `e62f18b8…` 354,397 (2026-10-30), **`7e7609fa…` 245,728 (seen 2026-10-25
      09:30 UTC — the Pro, a week behind; the VX-494 record names this id as her Pro's)**.
- [x] **Rows past the Pro's cursor: 22,905** (container 156 · block 6,474 · variant 6,810 · commit_point 831 · edge 1,034
      · container_block 6,474 · wing 1 · reading 9 · reading_section 32 · reading_post 175 · tag 10 · post_tag 279 · lens 61
      · lens_choice 415 · block_comment 138 · setting 3 · purge_intent 3) — ~12 windows of 2,000. **The index-only count
      shape, LIVE:** the 21-table sum as one bare SELECT answered in 0.64 s wall (incl. the HTTPS round trip) — R-500-1's
      shape works at this remaining-set size; the from-zero case stays unprobed until a device needs it.
- [x] Honest expectation for her acceptance: the download's ~12 calls go from roughly half a second each (the old shape
      sorts the ~23k rows ahead per call) to ~0.2 s — seconds saved, not minutes; the SAVE (~23k rows, 6,474 blocks landing
      before 6,810 takes on a store already holding ~21k blocks — VX-720's scan) will dominate and is NOT changed by this
      deploy (U4's index is client-side, after the freeze). Say so when timing it.
- [ ] `select sync_schema_version();` — 14. (Her `!` road or `Tools/prod-read.sh`.)
- [ ] Her Variorum on the Pro stays CLOSED until the run below lands (an open spends the test on the old shape).

## The run (her `!` road — the classifier blocks a session's mutating POST; or the orchestrator through the stored PAT at her EXPLICIT go, the 13i-c/13n-b precedent)

```
! cd ~/dev/variorum && set -a && source .env.supabase.local && set +a && REF=$(echo "$VARIORUM_SUPABASE_URL" | sed -E 's|https://([a-z0-9]+)\.supabase\.co.*|\1|') && jq -Rs '{query: .}' < ~/dev/variorum-vx-500/Server/supabase/maintenance/vx495-pull-keyset.sql | curl -s -X POST "https://api.supabase.com/v1/projects/$REF/database/query" -H "Authorization: Bearer $SUPABASE_ACCESS_TOKEN" -H "Content-Type: application/json" -d @-
```
(The artifact is on the BRANCH's worktree — the PR is held, so main does not carry it yet.) Expected: `[]` on the first run.

**RUN 1 (2026-11-01 23:43 UTC, the stored PAT at her word R-500-8) — REFUSED WHOLE: `ERROR: 42501: permission denied for
schema public`, HTTP 400.** Nothing landed (read-only after: `sync_pull`'s body has no `with picked as`; no
`sync_pull_remaining`). THE CAUSE, settled by probes (the management endpoint runs as `postgres`, non-superuser, a member
of `variorum_definer`, CREATE on public via `pg_database_owner`): **`variorum_definer` has USAGE but NOT CREATE on schema
`public`** — the ACL reads `{pg_database_owner=UC/…, postgres=U/…, anon=U, authenticated=U, service_role=U,
variorum_definer=U}` — while `maintenance/14c-gate-definer-owner.sql:81` granted it `usage, create`. Postgres requires
the NEW owner to hold CREATE on the schema for `alter function … owner to`, so both `owner to variorum_definer` lines
fail. Dry runs (the artifact with `commit;` → `rollback;`, nothing landing): whole → the same error; the guard + both
`create or replace` → `[]`; the whole minus the two `owner to` lines → `[]`. The last re-own that succeeded live was 17's
(2026-10-22); the server now reports Postgres 17.6 — a platform upgrade or ACL rewrite between then and now is the
likely thief. The rollback artifact carries the same `owner to` line and would fail identically. **A `create or replace`
keeps the existing owner** (dry run B: `sync_pull` stays `variorum_definer`), so the pull alone could land — but the NEW
count function would be owned by `postgres` (BYPASSRLS), which the 14c two-layer net forbids for a data function. The
fix is her call (the question put at ~17:50): restore 14c's letter — `grant usage, create on schema public to
variorum_definer;` as the artifacts' first statement — plus a sweep row for the privilege.
- [ ] On any error: READ it, fix the artifact IN REPO (never live-only), re-run — the 13j read-fix-re-run road. A 42702-class
      name shadowing or a `format()` arity slip would show here first (the DDL pins are string pins; this is the SQL's
      first execution on a Postgres).

## Verify (read-only, in the window)

- [ ] `select pg_get_functiondef('sync_pull(bigint,text,text,text,int,text)'::regprocedure)` — the body carries `with picked
      as (` and `bound as (select max(server_seq) as seq from picked)`.
- [ ] `select proname, proconfig, pg_get_userbyid(proowner) from pg_proc where proname in ('sync_pull','sync_pull_remaining')`
      — each `{search_path=public, pg_temp}`, owner `variorum_definer`; TWO rows.
- [ ] The grant sweep — THE BRANCH'S `Server/supabase/maintenance/14c-post-deploy-grant-sweep.sql` (it carries the new
      function's expected row; main's sweep reads UNEXPECTED FUNCTION until the merge — not a finding): **65 OK · 4 INFO ·
      0 fail** — the count's row and VX-721's two `schema-privilege` rows (`variorum_definer` USAGE on public HELD, CREATE NOT held —
      the 10/14c idiom's end state; the CREATE expectation PROVISIONAL P-500-9, the DEPLOY-FIX RECORD) OK.
- [ ] `EXPLAIN (ANALYZE, BUFFERS)` of the count's shape for her tenant from the Pro's cursor (her `!` road) — the index-only
      claim, read live (U1a's self-assessment item 3).

## The acceptance — HER REAL-WORLD TEST (her words: the week-behind Pro)

- [ ] She opens Variorum on the Pro; the round runs. The orchestrator reads, read-only: `log show --last 30m --predicate
      'process == "Variorum"'` for the CFNetwork task summaries (the window calls and their durations) and the app's own
      `io.lduarte.Variorum:protection` lines; the server's `device_cursor` for `7e7609fa…` advances to the head; the row
      says "Synced …". Record: calls, per-call time, download wall time, the save's wall time (CPU/WAL as at VX-494), vs
      the honest expectation above.
- [ ] If the round REFUSES with a server error naming `sync_pull`: the ROLLBACK runs (the same `!` shape with
      `vx495-rollback.sql`), her next round confirms 13's body serves, the artifact is fixed in repo, round 3 of the
      server-half ladder reads the fix before any re-run.

## After

- [ ] This file flipped to RUN with the window's numbers; the plan's THE DEPLOY §4 and LIVE STATUS row 3b flipped; the
      SyncSpec §12 running record gains a one-line maintenance entry at the MERGE moment (the merging session's, on main —
      not a marker event, but the body the mirror runs changed); the E2EE envelope unchanged (no new column, no new
      disclosure).
