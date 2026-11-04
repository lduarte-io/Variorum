# VX-500 — SERVER-HALF LADDER, ROUND 2 (cold review, Fable, 2026-11-01)

## FOR A LATER READER

The round RE-REVIEWED the round-1 fixes and everything they introduced (the ladder's rule: a round-2
reviewer re-checks the fixes) — the diff `b9b97ad58..a8038ad91` (five commits), restricted to
`Server/supabase/maintenance/vx495-rollback.sql` (new, 219 lines), `Tests/VariorumCoreTests/AuthRLSDDLTests.swift`
(+89 −1) and `Tests/VariorumCoreTests/MultiTenantSyncAttackerTests.swift` (+14 −5) — and re-read the
server half as a deployable unit (R-500-6: it ships to the production mirror at her word, before any
client change; the rollback must restore the exact pre-deploy state if the live round refuses). F3's
fix (the orchestrator's deploy-step wording, in `b9b97ad58`) was checked against the sweep's actual
verdict logic. **Verdict: round 1's F1, F2 and F3 are CLOSED as fixed; the rollback artifact is sound
and restores the exact pre-deploy state component by component — the byte-identity verified by this
reviewer's own `diff`, not the pin alone. No BLOCKER, no MAJOR. Two NEW MINOR findings, both
drift-proofing gaps the fix session itself named in its self-assessment (items 2 and 7) and deferred
to this round for the call — each a one-line test addition; NEITHER GATES THE DEPLOY** (both are
about future-drift coverage in the string pins, not about what the deployed SQL does). The reviewer
ran `swift test --filter "AuthRLSDDLTests|MultiTenantSyncAttackerTests"` itself: **"Test run with 85
tests in 2 suites passed after 0.304 seconds"** — matching the fix record and the orchestrator's own
run. `git diff --stat b9b97ad58..a8038ad91 -- Sources/` is EMPTY, and nothing after `a8038ad91`
touched the reviewed files.

Reviewed per `notes/REVIEW_PROMPT.md` verbatim ({PHASE} = VX-500). Read whole, this session: SyncSpec
(all; §2/§5/§12 load-bearing), the plan/record file `notes/plans/fixes/vx-500-sync-followups.md`
(D-495 + EVIDENCE, R-500-1/-6/-7, THE DEPLOY, the U1a/U1b records, SERVER-HALF ROUND 1 — THE FINAL
CALLS, the SERVER-HALF FIX BRIEF and RECORD), `notes/plans/fixes/vx-500-server-half-round1.md` (the
anchor), the rollback artifact whole, the keyset artifact whole, 13's §3a, 12's grant/owner tail and
`next_tenant_seq`/`stamp_server_seq` (the SHAPE B premises re-spot-checked at source, not inherited),
the sweep's expectation rows and verdict cases, `AuthRLSDDLTests`' finders, the three VX-495 pins and
the whole resolver (`searchPathResolution`, `searchPathDeployOrder`, the doctored-chain arm), and
`MultiTenantSyncAttackerTests` whole.

---

## ROUND-1 FINDINGS, RE-CHECKED

- **F1 — CLOSED.** The one `#expect` landed in the bound pin (`AuthRLSDDLTests.swift:684–685`) on the
  artifact's exact bytes (`from (%s) raw\n         order by raw.server_seq\n         limit %s),\n       bound as`
  — 9·9·9·7 leading spaces, verified against `vx495-pull-keyset.sql:250–253`; this reviewer counted
  the needle's occurrences in the artifact: exactly one), placed between the per-table-limit and
  bound assertions as the SQL reads. The honest red's mechanism re-walked by this reviewer: deleting
  the outer `limit %s),` destroys the needle while every OTHER assertion of the pin stays green
  against that body (walked each one) — the recorded red (1 issue, the new assertion alone, at the
  then-tip's :674) is exactly that shape. The declined defensive SQL limit stays declined (the body
  stays byte-minimal against 13's — the right call).
- **F2 — CLOSED.** `postChainFunctionArtifacts` and `vx495PullKeysetFile` are internal `static let`s
  (`AuthRLSDDLTests.swift:161, 168`); arm 9 derives its appended files from the list in order with
  the non-vacuity `#expect(!list.isEmpty)` (`MultiTenantSyncAttackerTests.swift:187–190`); the inline
  path is gone — `maintenance/vx495-pull-keyset.sql` lives as CODE in exactly one place. The drift
  round 1 traced (a future post-chain artifact scanned by one suite and not the other) cannot recur
  between the suites. One residue remains INSIDE AuthRLSDDLTests — finding F-R2-2 below.
- **F3 — CLOSED** (the orchestrator's edit, `b9b97ad58`). THE DEPLOY step 3 now names THE BRANCH'S
  sweep, the verdict **63 OK · 4 INFO · 0 fail** with the new row an OK, and main's UNEXPECTED
  FUNCTION misread until the merge. Checked against the sweep's own verdict cases
  (`14c-post-deploy-grant-sweep.sql:306–321`: expected-absent ⇒ `MISSING — the lockstep artifact must
  create it`; observed-unexpected ⇒ `UNEXPECTED FUNCTION — review …`) and the count row's posture
  tuple (`:113` — `(false, true, false)` = the artifact's authenticated-only grants). Exactly the
  asked fix.
- **The standing reminder — HONORED.** `maintenance/vx495-rollback.sql` exists, pinned, before the
  deploy (R-500-6 (2)); THE DEPLOY §4's rollback line names a real file.

## THE ROLLBACK ARTIFACT, REVIEWED WHOLE (new in this range)

Verified by this reviewer, independently of the pin:

- **Byte-identity:** my own `diff` of `13_phase13i_wings.sql:184–291` against
  `vx495-rollback.sql:79–186` — IDENTICAL. The pin's (a) compares `lastBody` over RAW text on both
  sides (signature, header, body, interior comments; nothing stripped) — the strongest honest reading.
  The backwards finder has no comment-match hazard: `create or replace function sync_pull(` occurs
  exactly once per file (grepped all three).
- **The exact pre-deploy state, component by component:** body = 13's §3a ✓; owner =
  `variorum_definer` (12:1731's exact spelling) ✓; grants byte-identical to 12:1751–1752 and to the
  keyset artifact's for `sync_pull` (`revoke … from public, anon; grant … to authenticated,
  service_role;`) ✓; search_path = `public, pg_temp` re-landed by the alter — load-bearing and said
  so, since the copied header is 13's bare `public` and a `create or replace` resets the SET clause ✓;
  `sync_pull_remaining` dropped by its exact created signature `(bigint, text, text, text)`, taking
  its ACL with it ✓. The DROP over "may stay" (self-assessment item 5) is the RIGHT call and the
  brief's letter: the deploy contract is "restore the exact pre-deploy state", and a rolled-back
  mirror should hold exactly the function set it held before; the branch-sweep consequence
  (`sync_pull_remaining` MISSING until the keyset re-runs) is documented in the header where the
  verifier will read it.
- **The guard and the transaction:** reads `sync_meta`/`lockstep_version`, never writes it (pinned);
  its own exception name `VARIORUM_VX495_ROLLBACK_NEEDS_14`; no shadowing (locals `deployed_marker`
  against columns `key`/`value` — the 13j 42702 class clear); one `begin;`…`commit;`; idempotent;
  harmless on a mirror that never received the keyset artifact (13's body over 13's body, the drop
  finds nothing, the alters land the state in force). Its live risk is strictly BELOW the keyset
  artifact's: every executable line but the guard and the drop has run live in some form (13's body
  on production since marker 10, 12's grant/owner spellings, the belt's alter spelling).
- **The pin's (b) resolver claims, checked against the resolver's actual code**
  (`AuthRLSDDLTests.swift:3157–3237`): the alter branch ignores owner alters (no `set search_path`
  prefix ⇒ `continue`); `drop function if exists` retires the signature; a create resets the path to
  its header's; the laid-over order `searchPathDeployOrder + [rollback]` models the real deploy
  position (…17 → belt → keyset → rollback); the checked/not-checked assertions use the resolver's
  normalized spelling (`sync_pull(bigint, text, text, text, integer, text)`). The doctored-chain arm
  filters from `searchPathDeployOrder`, so it ignores the rollback by construction, as claimed.
- **Mid-flight safety:** a rollback landing between two windows of one catch-up serves window 1 from
  SHAPE B and window 2 from 13's body — byte-identical wire shape and page semantics both ways; the
  client's stage-continuity checks are seq-based and unaffected. A client that had the count half
  (none does — the PR is held) would meet a 404 ⇒ "no total", never a failed round.

---

## FINDINGS (severity-ranked; both are the fix session's own self-assessment items, deferred to this round for the call)

### F-R2-1 · [MINOR] · Tests/VariorumCoreTests/AuthRLSDDLTests.swift:684 + Server/supabase/maintenance/vx495-pull-keyset.sql:259 · F1's fix pins the outer cut's TEMPLATE text but not the `format()` argument tuple that feeds it — the one line routing `max_rows` into the pinned `limit %s` is unpinned

- **What.** The bound pin now holds the page CTE's text (`from (%s) raw … order by raw.server_seq …
  limit %s), bound as`), but the `execute format(…)` call's argument list
  (`pick_sql, max_rows, fetch_sql)`, artifact line 259) — the only line that makes the pinned `%s`
  BE `max_rows` — has no assertion. The fix session said so itself (self-assessment item 2, NOT
  PINNED) and left the call to this round.
- **Evidence (mechanism traced).** Doctor line 259 to `pick_sql, 500, fetch_sql)` (or any wrong
  variable): the SQL stays valid, EVERY assertion of the bound pin and the count pin stays green
  (they read only the `$q$…$q$` templates and the artifact's statements), and the deployed page
  silently stops honoring the caller's `max_rows` — a hardcoded 500 against the client's 2,000 is a
  4× slower catch-up, invisible until a live window. The same class sits on the pick's own tuple
  (`tbl, caller, since_seq, horizon, max_rows);`, line 206). This artifact never runs in CI — the
  string pins are its ONLY pre-deploy evidence, which is exactly why round 1's F1 standard applies
  to the data flow as much as the template.
- **Fix.** ONE `#expect(body.contains("pick_sql, max_rows, fetch_sql)"), …)` in the bound pin (the
  needle occurs exactly once in the artifact — this reviewer counted); optionally the pick tuple's
  line beside it. Red by the suite's own doctored-fixture pattern (the doctoring above is red on
  exactly the new assertion, green as shipped). Test-structure/drift-proofing class — no product pin
  owed; the justification is the traced silent drift above.

### F-R2-2 · [MINOR] · Tests/VariorumCoreTests/AuthRLSDDLTests.swift:168 vs :3059 · F2's drift class has one remaining home INSIDE AuthRLSDDLTests: a future artifact added to `postChainFunctionArtifacts` but not to `searchPathDeployOrder` is read by `finalBody` and arm 9 yet never by the search-path resolver

- **What.** `postChainFunctionArtifacts` (:168) feeds `finalBody(of:)` (:183) and, since F2, arm 9's
  deployed-function scan; `searchPathDeployOrder` (:3059) positions the keyset artifact separately,
  by name, in its `after` map under 17. The fix session deliberately did not fold them (deploy
  POSITION is per-artifact knowledge — right) and flagged the residue itself (self-assessment
  item 7).
- **Evidence (degradation traced).** A future post-chain artifact X added to
  `postChainFunctionArtifacts` alone: `finalBody` lays it over (the body pins see it), arm 9 scans
  its names and parameters — but the resolver never reads X, so the functions it re-creates resolve
  to the CHAIN+BELT's state, which ends in `pg_temp`, and
  `everyDefinerPathEndsInPgTempOnceTheBeltIsRead` stays green while the DEPLOYED reality carries X's
  bare `public` header — the exact drift the belt pin exists to catch, silently uncovered. Nothing
  fails; the coverage just isn't there. (This round establishes post-chain artifacts as a recurring
  pattern, so there WILL be a next one — round 1's own F2 argument.)
- **Fix.** ONE cross-pin, e.g. in `everyDefinerPathEndsInPgTempOnceTheBeltIsRead`:
  `for artifact in Self.postChainFunctionArtifacts { #expect(Self.searchPathDeployOrder.contains(artifact), …) }`
  — one-directional (deployOrder may rightly hold files the post-chain list doesn't: the belt, the
  13j rename). Red by the doctored-fixture pattern (drop the keyset file from the `after` map in a
  scratch doctoring). Test-structure class, no product pin; the justification is the traced
  silent-coverage loss.

No further findings. **Specifically checked and DISMISSED (the self-assessment's remaining items):**
- Item 1 (the F1 text's whitespace exactness) — the pin family's standing nature; the brief asked for
  the artifact's exact bytes; a re-indent going red is the family working. Declined.
- Item 3 (the rollback has never run on a Postgres) — recorded honestly; its live risk is strictly
  below the keyset artifact's (above); the deploy window's VERIFY tails are the real evidence, as
  THE DEPLOY already says. Accepted as recorded.
- Item 4 (the resolver models Postgres's SET-clause reset) — Postgres replaces `proconfig` with the
  new definition's (the belt's own live finding at the 17 deploy confirms it); and were the rule
  otherwise, the rollback's alter is idempotent and merely re-asserts. Accepted.
- Item 6 (raw byte-equality includes 13's interior comments) — right behavior: 13 is deployed canon
  and stays byte-untouched by rule; a comment edit there SHOULD demand a re-copy. Accepted.
- Item 8 (the rollback-run-without-the-keyset scene unmodeled) — no pin could distinguish the bodies
  for a real reason (13's body over 13's body; the drop finds nothing); a pin green on both sides is
  hollow by the guard. Rightly reasoned, not pinned.
- Items 9/10 (the mis-aimed first sed, recorded; the access widening) — records and test-module
  scoping, no issue.

---

## CLEAN BILL (what was specifically checked and found solid)

1. **F1's fix, mechanism and red** — the needle unique in the artifact (counted), the placement
   right, the recorded red's shape re-walked assertion by assertion against the doctored body.
2. **F2's fix** — one list, non-vacuity pinned, the inline path gone; arm 9's deploy-order modeling
   (top-level chain sorted lexically, then the list in order) matches reality; the signature regex's
   `deployed[name] = params` keeps the LAST parameter list, so the keyset artifact's lists win as
   they do on the mirror.
3. **F3's fix** — the deploy-step wording against the sweep's actual verdict cases and the count
   row's posture tuple (`(false, true, false)` ≡ authenticated-only).
4. **The rollback's byte-identity** — my own `diff`, independent of the pin; and the pin's (a) is
   the strongest honest comparison (raw, nothing stripped).
5. **The exact pre-deploy state restored** — body, owner, grants, search_path, function set — each
   component traced to its source artifact (13 §3a; 12:1731, 1751–1752; the belt) and matched against
   the keyset artifact's re-asserts; the count's DROP is the contract's letter and the sweep
   consequence is documented where the verifier reads it.
6. **The rollback pin's resolver claims** — verified against `searchPathResolution`'s actual code:
   owner-alters ignored, drops retire signatures, creates reset paths, the laid-over order models the
   real deploy position, the doctored-chain arm ignores the rollback by construction.
7. **The guard and transaction discipline** — marker read, never written; no 42702-class shadowing;
   one transaction; idempotent; harmless without the keyset deploy; forward → back → forward legal
   with no half-state (both artifacts land their whole state).
8. **No standing pin weakened** — the range only adds assertions, widens two test statics to
   internal, and swaps arm 9's inline path for the shared list; the A5/owner pins, the belt drift pin
   and the doctored-chain arms are byte-unchanged in what they assert.
9. **SHAPE B's premises re-spot-checked at source** (not inherited from round 1):
   `next_tenant_seq` is one row-locked `INSERT … ON CONFLICT DO UPDATE … RETURNING` per write;
   `stamp_server_seq()` mints the seq and `server_written_at := clock_timestamp()` in one trigger;
   no artifact writes `server_seq` directly (grepped `Server/supabase/` whole).
10. **The suites, run by this reviewer** — "Test run with 85 tests in 2 suites passed after 0.304
    seconds" (`AuthRLSDDLTests` 83 · `MultiTenantSyncAttackerTests` 2), matching the fix record and
    the orchestrator's verification.
11. **The range's hygiene** — zero lines under `Sources/` (my own `git diff --stat`); the keyset
    artifact and the sweep byte-unchanged in the range; nothing after `a8038ad91` touched the
    reviewed files; no trailers on any of the five commits; nothing of the doctorings committed.

## Round disposition handles

- **The pre-deploy gate:** NO BLOCKER, NO MAJOR; round 1's findings closed; the rollback sound and
  pinned. Neither new finding gates the deploy — both are one-line drift-proofing additions to the
  string-pin coverage, landable before the deploy at the orchestrator's convenience or riding the
  whole-diff ladder after U3/U4. The gate's opening is the orchestrator's call per THE DEPLOY §4's
  "every finding dispositioned".
- F-R2-1 → one `#expect` on the `format()` argument tuple (red via the doctored-fixture pattern).
- F-R2-2 → one cross-pin, post-chain list ⊆ `searchPathDeployOrder` (one-directional).
- No round 3 is earned (the ladder's rule: a NEW BLOCKER/MAJOR earns it; there is none).
