# VX-500 — SERVER-HALF LADDER, ROUND 1 (cold review, Fable, 2026-11-01)

## FOR A LATER READER

The round reviewed the SERVER HALF of VX-500 as a deployable unit (R-500-6: it ships to the
production mirror at her word, before any client change) — the diff `11f7ee613..HEAD` restricted
to `Server/supabase/maintenance/vx495-pull-keyset.sql`, `Server/supabase/maintenance/14c-post-deploy-grant-sweep.sql`,
`Tests/VariorumCoreTests/AuthRLSDDLTests.swift` and `Tests/VariorumCoreTests/MultiTenantSyncAttackerTests.swift`.
The engine/scheduler lines (`Sources/`) were read only where they bear on the artifact's wire
contract; their findings belong to the whole-diff ladder after U3. **Verdict: no BLOCKER, no
MAJOR. Three MINOR findings (one DDL-pin gap, one test-structure drift hazard, one deploy-procedure
wording) and a clean bill covering the SHAPE B correctness argument end-to-end** — the per-tenant
seq-uniqueness and horizon-monotonicity premises were traced to `next_tenant_seq` /
`stamp_server_seq` in `12_phase13y_tenant_seq.sql` and hold. The reviewer ran
`swift test --filter "AuthRLSDDLTests|MultiTenantSyncAttackerTests"` itself: **84 tests in 2
suites passed**.

Reviewed per `notes/REVIEW_PROMPT.md` verbatim ({PHASE} = VX-500). Canon read whole: SyncSpec
(all of it, §2/§3/§5/§7/§12 load-bearing here), the plan/record file
`notes/plans/fixes/vx-500-sync-followups.md` (R-500-1, R-500-6, D-495 + EVIDENCE, the U1a record
and self-assessment), `13_phase13i_wings.sql` §3a (the body replaced), `12_phase13y_tenant_seq.sql`
(the counter, the stamp trigger, `sync_key_gate` → `sync_key_proof_check`), the sweep whole, the
postmortem's divergence ledger, KnownIssuesAndTechDebt (grep: nothing this round owns).

---

## FINDINGS (severity-ranked)

### F1 · [MINOR] · Tests/VariorumCoreTests/AuthRLSDDLTests.swift:~660 (`theKeysetPullPicksEachTablesPageOffItsIndexThenFetchesUpToTheBound`) · the OUTER global page cut is unpinned — a body that loses `order by raw.server_seq limit %s` over the pick union stays green on every assertion

- **What.** The bound pin asserts the pick's PER-TABLE `order by t.server_seq\n          limit %s)`,
  `with picked as (`, the `bound` CTE, the two bounded fetch branches, no `in (select`,
  `sync_table_pk` ×2, the horizon ×3, the gates, the upsert and the arrays — but nothing asserts
  the outer `order by raw.server_seq\n         limit %s` inside the one `execute format(...)`
  (`vx495-pull-keyset.sql:247–259`), which is what cuts the 21-table union of per-table pages down
  to THE page.
- **Evidence (mechanism traced).** Delete that one outer `limit %s` (Postgres `format()` ignores a
  surplus argument, so the statement stays syntactically valid): `picked` becomes up to
  21 × `max_rows` seqs, `bound` their maximum, and every fetch branch serves everything up to it —
  a window of up to ~42,000 rows at the production window size, silently. Walked every assertion
  of the pin against that doctored body: all stay green (`with picked as (` present; the per-table
  limit present; the bound CTE present; both bounded branches present; no `in (select`). The
  header's own exactness claim ("the pick's union … then ONE `order by server_seq limit max_rows`
  … is the CTE `picked`") rests on exactly the line the pin does not hold.
- **Fix.** Extend the bound pin with the global cut's text, e.g.
  `#expect(body.contains("order by raw.server_seq\n         limit %s),\n       bound as"), "the pick's union is cut to ONE page before the bound")`
  (whitespace per the artifact). Red-on-old shape: the suite's own doctored-fixture pattern —
  the assertion is red against the artifact's body with the outer limit removed, green as shipped;
  not a product bug today, a drift-proofing gap in the new pin (the pin family's declared purpose).
  Optional belt for the implementer's judgment, not demanded: a defensive outer `limit` on the
  fetch output would restore 13's hard output cap independent of the seq-uniqueness premise, at
  the cost of a sort node; the header already documents over-full windows as harmless, so the pin
  alone suffices.

### F2 · [MINOR] · Tests/VariorumCoreTests/MultiTenantSyncAttackerTests.swift:~184 + Tests/VariorumCoreTests/AuthRLSDDLTests.swift:~163 · the post-chain artifact list now lives in TWO places — a future post-chain artifact added to one and not the other silently weakens the other's coverage

- **What.** `AuthRLSDDLTests.postChainFunctionArtifacts = [vx495PullKeysetFile]` (private) drives
  `finalBody(of:)` and `searchPathDeployOrder`; the attacker test's arm-9 scan appends the same
  artifact by an inline hardcoded path (`sqlFiles.append(sqlDir.appendingPathComponent("maintenance/vx495-pull-keyset.sql"))`).
- **Evidence (degradation traced).** Next time a maintenance artifact redefines an RPC after the
  chain (this round establishes the precedent, so there WILL be a next), adding it to
  `postChainFunctionArtifacts` alone keeps AuthRLSDDL honest while the attacker scan's
  `deployed[name]` keeps the CHAIN's older parameter list — the "every client RPC is a deployed
  function" check still passes on the name, and the forbidden-word scan
  (`owner`/`transfer`/`move`/…) runs over a stale parameter list: a forbidden parameter added by
  the new artifact goes unscanned, which is precisely the wire-surface drift arm 9 exists to
  catch. The reverse miss (attacker updated, DDL pins not) makes `finalBody` assert against a
  superseded body.
- **Fix.** One source of truth: make `postChainFunctionArtifacts` internal (same test module) and
  have the attacker test derive its appended files from it — or, lighter, add one cross-pin in
  either suite asserting the attacker's appended set equals `AuthRLSDDLTests.postChainFunctionArtifacts`.
  Test-structure/clarity class: no product pin exists or is owed; the justification is the traced
  silent-coverage loss above.

### F3 · [MINOR] · doc — notes/plans/fixes/vx-500-sync-followups.md, THE DEPLOY step 3 (+ the sweep row's comment) · "the grant sweep … reads 62 OK · 4 INFO · 0 fail PLUS one row for the new function" does not say WHICH sweep or WHAT verdict that row must carry — around this deploy the two live copies of the sweep disagree

- **What.** The sweep's new expected row is unconditional (no marker moves, so the sync_reencrypt
  marker-aware mechanism cannot gate it). Around the held deploy there are two sweeps in the
  world: this branch's (expects `sync_pull_remaining`) and main's (does not — the PR is held).
- **Evidence (mechanism traced, from the sweep's own verdict logic at
  `14c-post-deploy-grant-sweep.sql:303–319`).** Run BEFORE the deploy, the branch's sweep reports
  `MISSING — the lockstep artifact must create it` for `sync_pull_remaining` (a fail-class row on a
  perfectly healthy mirror). Run AFTER the deploy from MAIN (any other session's verification until
  the freeze lifts and the PR merges), it reports `UNEXPECTED FUNCTION — review (a lingering old
  RPC overload is a proof-free or cross-tenant door)` — alarm wording for a deliberate deploy. A
  deploy verifier reading step 3's "PLUS one row for the new function" could accept EITHER verdict
  as "the one row", including the fail-class ones.
- **Fix.** One sentence in THE DEPLOY step 3: the sweep runs FROM THIS BRANCH's copy and the
  expectation is **63 OK · 4 INFO · 0 fail** (the new row an `OK`, not merely present); plus one
  line noting that main's sweep will read the function as UNEXPECTED until the PR merges — expected,
  not a door. Optionally the same note as a comment on the sweep's new row. Procedural/doc class —
  no pin possible; the justification is the misread-at-the-window hazard above.

No further findings. Specifically NOT findings, checked and dismissed:
- The fetch re-evaluating `clock_timestamp()` after the pick (header's "THE HORIZON ACROSS THE TWO
  PHASES") — verified sound, see clean bill 2.
- The pick's per-row volatile horizon evaluation (a row excluded early in a scan while a later row
  is admitted) — byte-identical to 13's standing single-phase semantics (the same per-row
  `clock_timestamp()` filter), and SHAPE B's later-clock fetch can only RE-ADMIT such a row, never
  lose one 13 would have served. No regression; no pin could distinguish the bodies.
- `sync_pull_remaining` counting rows the feed won't serve for ~2 s (no horizon per R-500-1) — the
  ruled shape; the client treats the total as advisory (D-496), and the deviation is bounded by the
  horizon's two seconds.
- The absence of `maintenance/vx495-rollback.sql` — R-500-6(2) assigns it to THIS round's fix
  session as a planned deliverable, so its absence from the reviewed diff is per plan. It REMAINS
  OWED BEFORE THE DEPLOY; the fix session must land it (restating so the next round checks it).

---

## CLEAN BILL (what was specifically checked and found solid)

1. **SHAPE B's exactness premise — per-tenant seq uniqueness (self-assessment item 1, pressed).**
   `next_tenant_seq` (`12_phase13y_tenant_seq.sql:333`) is one `INSERT … ON CONFLICT DO UPDATE
   … RETURNING` per row-write — the counter row's lock is held to COMMIT, so seqs are unique per
   tenant across all tables and a tenant's transactions serialize. The F-S1 floor only INITIALIZES
   counters (max over existing bookkeeping — no row re-stamp); `stamp_server_seq()` is the one
   stamping site; grep over `Server/supabase/` finds no artifact writing `server_seq` directly.
   Hence "the page's rows" ≡ "every allowed table's rows with since < seq ≤ bound", the fetch
   returns ≤ max_rows rows, and the wire output is byte-identical to 13's for every input.
2. **The horizon-skew judgment (self-assessment item 2, pressed).** `stamp_server_seq()` writes
   `server_written_at := clock_timestamp()` in the same trigger that mints the seq; with the
   counter lock held to commit, `server_written_at` is monotone in `server_seq` within a tenant
   (T2's first stamp blocks until T1 commits; within one transaction both ascend). So the horizon
   excludes a SUFFIX of the seq order: picked-but-unfetched is impossible (visibility only grows
   between the phases), fetched-but-unpicked is impossible under monotonicity (any row inside the
   horizon at pick time has seq > bound), and the only residual corner — a backwards wall-clock
   step breaking written_at monotonicity for an instant — produces exactly the skip 13's single
   filter already had: not a regression, and the 13y per-tenant commit-order belt plus A5's 2 s
   stand in front of it as before.
3. **Byte-identity of everything D-495 lists as kept**, verified side-by-side against
   `13_phase13i_wings.sql` §3a: the signature, the allowlist and owner-table arrays (also pinned
   byte-equal), `sync_key_gate(…, 'sync_pull')`, the entitlement gate, the `for_device` cursor
   upsert (greatest/seen_at), both fetch branches' select lists, owner filter, seq filter and
   derived-horizon filter, the server-only column subtraction (`sync_version`/`server_seq`/
   `server_written_at`, + `owner_id` on the mirror-only branch), and the aggregate's exact
   jsonb key set and `order by u.server_seq`. The whole delta is: the pick loop, the `picked`/
   `bound` CTEs, and ONE added predicate per fetch branch. Wire shape unchanged ⇒ the maintenance
   (no-marker) classification is correct under SyncSpec §12, and the fake server/convergence
   suites legitimately remain the evidence.
4. **The standing A5/owner pins still bite against the laid-over body** (not weakened): the owner
   pin's `from %I t` == `where t.owner_id = %L` equality reads 3 == 3 (pick + two fetch branches —
   the pick carries the owner filter too); `theVisibilityHorizonSurvivesEveryRework` finds the
   derived horizon, the pinned filter text byte-identical to 13's, and no inline interval.
5. **The two new DDL pins and their honest red.** The bound pin's and count pin's assertions each
   match the artifact's exact text (suite green, run by this reviewer); against 13's body alone
   (`postChainFunctionArtifacts` emptied) the bound pin's seven assertions have no text to match
   and `finalBody(of: "sync_pull_remaining")` records its no-create Issue — the U1a record's
   12-issue red run is structurally confirmed. The record's honest framing of the new-API pins
   (compile-red proves nothing) is the right discipline.
6. **The search-path machinery handles a self-belting post-chain artifact correctly.** The
   resolver's alter rule is append-idempotent (`preserved = inForce.last == "pg_temp" ? inForce :
   inForce + ["pg_temp"]`), so the artifact's re-assert alters over its own `public, pg_temp`
   headers are clean, not flagged; `searchPathDeployOrder` places the artifact after the belt
   under 17; the doctored-chain unbelted arm rightly drops the artifact beside the belt (it
   re-asserts pg_temp itself — left in, the arm's "every checked function flagged" would be false
   for the two new signatures for the right reason); `everyDefinerPathEndsInPgTempOnceTheBeltIsRead`
   now covers `sync_pull_remaining(bigint, text, text, text)` through the artifact's inline header.
7. **Grants, owner, posture.** `sync_pull`'s revoke/grant lines are byte-identical to 12's
   (authenticated + service_role — matching the sweep's `(false, true, true)`);
   `sync_pull_remaining` takes `sync_horizon`'s exact posture (authenticated only; public, anon
   AND service_role revoked — the sweep row `(false, true, false)` matches; the pin also asserts
   the never-service_role negative). The `alter function … owner to variorum_definer` re-asserts
   close the real hole that `create or replace` by the PAT's postgres role would reopen (a
   BYPASSRLS-owned definer), inside the artifact's one transaction — no window. The paired
   `alter … set search_path` keeps a re-run landing the same state even though the headers
   already carry the list.
8. **The wire pin's growth is exactly the new road and the contract agrees end-to-end.**
   `clientRPCs` + `pullRemaining` requirement + the artifact read BY NAME after the sorted chain
   (deploy order correct: no top-level artifact sorts after 17 — verified by listing; reading the
   maintenance folder wholesale would indeed regress `deployed`'s final parameter lists — the 13j
   in-window rename and the pre-13x overlay carry older ones). The forbidden-word scan now covers
   both new functions' names and parameter lists (clean). The gate binds the proof to the RPC name
   (`extensions.hmac(nonce || ':' || rpc_name, kp2)` — `12_phase13y_tenant_seq.sql:720ff`), the
   artifact gates under its OWN name (`'sync_pull_remaining'`), and the engine signs
   `signer.call(rpc: "sync_pull_remaining")` (`SyncEngine.swift:520`) — server and client halves
   of the challenge contract agree, so the deployed count will verify once the client ships (and
   sits merely unused until then, exactly as R-500-6 says).
9. **The marker guard and transaction discipline.** The guard reads the chain's real key
   (`sync_meta`,`'lockstep_version'` — written by 05 and bumped since), refuses NULL and < 14 with
   a named error, never writes sync_meta (pinned); the artifact is one `begin;…commit;`,
   idempotent on re-run; sync_meta is RLS-on-unforced with postgres as owner, so the PAT road
   reads it. The 13j 42702 class is clear: no parameter or local shadows a column of the static
   SQL it runs (`device_cursor`, `entitlement`, `sync_meta` columns all checked against
   `caller`/`dev`/`horizon`/`tbl`/`pick_sql`/`fetch_sql`/`count_sql`/`result`/`deployed_marker`).
10. **The count body per R-500-1 exactly:** owner + seq per table and nothing else (no
    `server_written_at`, no interval of any spelling — pinned), the pull's own two gates, the
    pull's own allowlist (pinned equal), summed as one `select` of 21 subquery counts into bigint;
    the known costs are honestly recorded in the header (O(rows remaining), asked once per long
    round, failure never fails a round). The index-only claim remains the planner's — correctly
    left to THE DEPLOY step 3's live `EXPLAIN` (self-assessment item 3: the right disposition; a
    string pin cannot reach it).
11. **Dumb-server alignment (SyncSpec §1–§2, §5, §12):** no constraint joins the mirror, no merge
    intelligence lands server-side (a count is a read), the A5 horizon mechanism and the
    server-only subtraction survive on every serving branch, and the §12 procedure for a
    body-only change (mirror first, nothing on the wire, clients need no install) is exactly what
    R-500-6 deploys.
12. **Suites, run by this reviewer:** `swift test --filter "AuthRLSDDLTests|MultiTenantSyncAttackerTests"`
    → "Test run with 84 tests in 2 suites passed" (AuthRLSDDL 82 + the grown arm-9 wire pin suite 2),
    matching the record's counts.
13. **Known issues / plan hygiene:** KnownIssuesAndTechDebt carries nothing this round owned; the
    self-assessment's engine-side press items (4, 5, 7, 8) are correctly the whole-diff ladder's,
    not this round's; item 9's finder blindness to a hypothetical `function public.name (`
    spelling is pre-existing, unchanged in kind and narrowed by the paren fix — acceptable as
    recorded.

## Round disposition handles

- F1 → the server-half fix session (one `#expect` in the bound pin; red via the doctored-body
  pattern; the optional SQL belt is the implementer's judgment call, not demanded).
- F2 → the same session (share `postChainFunctionArtifacts` or cross-pin the two lists).
- F3 → the orchestrator's record edit (THE DEPLOY step 3 wording + optionally the sweep row
  comment); no code.
- Standing reminder for the fix session, per R-500-6(2): `maintenance/vx495-rollback.sql`
  (13's §3a body + the belt's pg_temp re-assert, idempotent, its own marker guard) must exist
  before the deploy.
