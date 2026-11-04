# VX-500 — WHOLE-DIFF LADDER, ROUND 1 (cold review, Fable, 2026-11-04)

## FOR A LATER READER

The round reviewed the WHOLE diff of `vx-500-sync-followups` against `origin/main` (44 files,
+6,062 −127): the U1a engine/scheduler/transport seam (`Sources/VariorumCore/Sync/` — SyncEngine,
SyncScheduler, SyncTransport, SupabaseTransport, PullStage), the U1b profile seam (`ApplyProfile.swift`
+ the gated bench), the U2 faces (`SyncStatusViews`, `RoadAccountModel`, the two sheets) and the
retention-clock/leaf changes, the U4 migration (`v1_36_fk_child_indexes`) and its pins, the server
artifacts (keyset, rollback, sweep — anchored on the two server-half rounds; the VX-721 bracket and
the sweep's schema-privilege rows, landed AFTER round 2, were cold-read here for the first time),
and every test the diff touches. **Verdict: no BLOCKER, no MAJOR. Two MINOR, two NIT.** The one
bug-class finding is display-only on a rare recovery road (the progress line double-counts after a
discarded stage). The reviewer ran the diff's core suites itself: `swift build` green;
`swift test --filter "SyncProgressTests|ResumableCatchUpTests|SyncSchedulerTests|AuthRLSDDLTests|
MultiTenantSyncAttackerTests|MigrationTests|DeferredFKChildScanPinTests|ApplyProfileMeasurementTests"`
→ **"Test run with 158 tests in 14 suites passed after 17.512 seconds"** (the three gated bench
tests skipped by design). No Mac suite was run (no stage claim this session — the orchestrator's
closing window carries both targets whole, per the coordinator's conditioned shape).

Reviewed per `notes/REVIEW_PROMPT.md` verbatim ({PHASE} = VX-500). Read whole, this session:
CLAUDE.md + its canon; SyncSpec (all — §2/§3/§5/§7/§12 load-bearing); the plan/record file
`notes/plans/fixes/vx-500-sync-followups.md` (FOR A LATER READER, the briefs, D-495…D-505, D-539,
D-490, HER RULINGS R-500-1…12, THE DEPLOY, the U1a/U1b/U2/U4 records and self-assessments, the
server-half final calls); the two anchor rounds (`vx-500-server-half-round1.md`, `-round2.md`);
the deploy checklist and the handoff; both server artifacts whole; the sweep's new rows; the code
and tests named above, each read in source, with `Retention.plan` and `next_tenant_seq`/
`stamp_server_seq` re-verified at source by this reviewer. The plan has no "Review foci" section;
the ladder brief's named anchors (U1a items 1/2/4/7, U1b's seam shape, U2 items 4/6, U4 items
1/2/6) are each addressed in the clean bill below.

---

## FINDINGS (severity-ranked)

### F1 · [MINOR] · Sources/VariorumCore/Sync/SyncEngine.swift:652–659 (the discard-and-refetch road) · `downloaded` is never reset when an undecodable stage is discarded — the progress line then counts every re-fetched row ON TOP of the discarded stage's rows, up to ~2× the truth

- **What.** On a `.resume` plan, `downloaded` starts at the stage's row count (:585) and
  `reportsProgress` arms. If the staged batch then fails to decode (`PullStage.rows` → nil, :647 —
  the F1 (2) road: a stage an EARLIER build left), the stage is cleared and the download restarts
  from the committed cursor (:654–659) — but `downloaded` keeps its accumulated value, and every
  re-fetched window adds on top (:630).
- **Evidence (mechanism traced).** Stage of 200 undecodable rows at the committed cursor, feed head
  = the stage's reach, progress armed (the scheduler's round): `downloaded = 200`; pass 1's first
  fetch is empty → break; decode fails → discard, `fetchCursor = since`; pass 2 re-fetches the same
  200 rows and publishes `done = 400` while `remaining` (asked once, correctly) is 200. With
  P-500-8's clamp the row reads "400 of 400" — twice the library. At her scale, a ~109k-row
  catch-up resumed over a stale-format stage would read ~218k. Display-only (`done`/`total` feed
  words, never a decision — the cursor, belt and stage semantics are untouched); the road needs an
  undecodable stage, i.e. a stage left by an earlier build whose encode changed — rare, but exactly
  the recovery scene VX-494 built the road for.
- **Pin (red-on-old).** An engine scene on the fake: plant a valid-header stage containing one
  undecodable row (the existing F1 (2) fixture shape in `ResumableCatchUpTests`), drive
  `pull(progress:)`, assert the LAST downloading reading's `done` equals the feed's row count. Red
  on the current code (reads stage + feed), green with the fix.
- **Fix.** In the discard branch (beside `fetchCursor = since`, :659): `downloaded = 0` — the stage
  is gone and the refetch starts from the committed cursor, so the honest count restarts with it.
  (`askedForTotal`/`remaining` rightly stay: the total was counted from `since`, which is still the
  base.) One line + the pin.

### F2 · [MINOR] · Sources/VariorumCore/Sync/SyncTransport.swift:218–221 (the `SyncPullCountTransport` doc) · the protocol's contract doc says the count runs "under the feed's own horizon filter" — false since R-500-1, and the doc is exactly what a future conformer builds from

- **What.** The doc comment reads "the count past the committed cursor under the feed's own horizon
  filter (`sync_pull_remaining`, `Server/supabase/maintenance/vx495-pull-keyset.sql`)". R-500-1
  ruled, and the deployed artifact and the fake both implement, the INDEX-ONLY shape: owner + seq,
  **no** horizon filter — the count may EXCEED what the feed serves right now by the rows still
  inside the horizon (the relation `SyncProgressTests.theCountIsIndexOnlyAndCountsRowsStillInsideThe
  Horizon` pins).
- **Evidence (degradation traced).** The conformers' doctrine on this protocol is "wrappers forward,
  fakes count" — a conformer author reads THIS doc to know what to count. A future fake or test
  wrapper that follows the sentence re-adds the horizon term, its totals land BELOW the feed's
  eventual serve during the window, and the suites built on the documented `total ≥ served-now`
  relation flake or silently assert the wrong relation. The method-level doc two lines down
  ("Proof-gated like `sync_horizon`") is right; the summary line contradicts the artifact's header,
  the fake's comment and `SyncProgress.total`'s doc — three places that say the opposite.
- **Fix.** Reword the one line to R-500-1's shape (e.g. "the count past the committed cursor —
  owner + seq only, NO horizon filter (R-500-1): it may exceed what the feed serves right now by the
  rows still inside the horizon"). Doc-class; no pin possible or owed.

### F3 · [NIT] · Sources/VariorumCore/Sync/SyncEngine.swift:584–587 · the `.resume` plan pays a `stagedRowCount` COUNT(*) read even when `progress == nil`

- Every nil-progress caller (the deliberate-act engines, `pullToHead` callers) resuming a stage runs
  one `SELECT COUNT(*)` whose result feeds only `downloaded`, which nothing then reads (every
  publish is inside `if let progress`). One cheap read on a rare path; cleanliness only. Fix: guard
  the read on `progress != nil` (e.g. `if case .resume = plan, progress != nil { … }`).

### F4 · [NIT] · Tests/VariorumCoreTests/DeferredFKChildScanPinTests.swift:74–75 · the ratio's attosecond arithmetic traps on overflow instead of failing the test

- `pending.components.seconds * 1_000_000_000_000_000_000` overflows Int64 (and crashes the test
  process) once an arm exceeds ~9.2 s — the red arm measured 2.06 s at N = 8,000, so a ~4.5×-loaded
  red-side run would CRASH rather than record the failure. `Duration` supports division directly
  (`pending / control` → `Double`), which is both exact and overflow-free. Small hazard in a
  diagnostic path; the green side (~0.2 s per arm) is nowhere near it.

**No further findings. Specifically checked and DISMISSED:**
- U1a self-assessment items 5 and 8 (the un-pinned stall scene `done < total`; an engine scene under
  a non-zero horizon) — the reviewer's call was to demand them or not: NOT demanded. The stall's
  progress is documented display behavior with nothing deciding on it, and the horizon relation IS
  pinned at the fake seam (`theCountIsIndexOnly…`); an engine-level duplicate buys harness cost, not
  coverage. Recorded as accepted, not owed.
- The save's first publish ("saving 0 of N") landing before the belt check — a belt refusal briefly
  shows "saving 0 of N" then the retrying face; deliberate (the ownership pass), harmless, and the
  retrying face replaces it within the same publish cycle.
- `advances` allowing equal `done` (duplicate publish → one extra `publishStatus`) — harmless, and
  the equal case is deliberate (a duplicate yield).
- The handoff's paste-ready kickoff still says "v1_35" for U4 — a historical cutover record, read
  once; the plan file's live sections are trued and the U4 record carries the deviation. Not a
  finding (history is never rewritten).
- `.help(…)` on the retrying row's phone rendering — compiles and degrades to an accessibility hint
  on iOS; the phone build is green; no contract names a phone hover.
- The chain-wide bracket pin (every `owner to variorum_definer` bracketed, across ALL artifacts) —
  already recorded in HELD FOR HER as VX-721's follow-up candidate; the two artifacts this run
  touches ARE pinned (`definerCreateBracketProblems` in both VX-495 pins). Not re-raised.

---

## CLEAN BILL (what was specifically checked and found solid — the ladder brief's anchors addressed by name)

1. **U1a item 1 — SHAPE B's per-tenant seq-uniqueness premise, re-verified at source by this
   reviewer** (not inherited): `next_tenant_seq` (12:333–347) is one `INSERT … ON CONFLICT DO
   UPDATE … RETURNING` per write — the counter row's lock held to commit; `stamp_server_seq()`
   (12:420–427) is the one stamping site, minting the seq and `server_written_at :=
   clock_timestamp()` in one trigger. Uniqueness and written-at monotonicity both hold; the
   artifact's "WHY THE BOUND IS EXACT" and horizon-skew paragraphs are sound (U1a item 2 ✓).
2. **U1a item 4 — `countRemaining`'s `try?` and the signer's enroll order:** the first
   `signer.call(rpc: "sync_pull")` (SyncEngine:609) precedes any count call (:636) on fresh AND
   resumed rounds (the count is asked only inside the window loop, after a fetch), so enrollment
   always rides the pull, never the count; a swallowed `CancellationError` is caught by the loop's
   next `Task.checkCancellation()`; a 404/refusal reads as "no total" and the round goes on —
   the count can never fail a round, as designed.
3. **U1a item 7 — publishes from inside the write transaction:** the scheduler's closure only
   spawns a `Task` (no await, no DB touch) from GRDB's writer queue; `publish` writes only
   `status.progress` under the generation + `isSyncing` guards; `runOneRound` reads no status
   across the engine await expecting constancy. The generation guard plus the `isSyncing` guard
   makes a stale hop (same round after end, or a previous round during the next) unable to land.
4. **U2 item 6 — the `.syncing` guard's scheduler invariant:** `status.isSyncing = false` and
   `status.progress = nil` are written together before ONE `publishStatus()` (SyncScheduler:330–333)
   on an actor, so no observable status carries a progress without the syncing face —
   `firstRoundCount`'s guard is sound. The flag/`lastError` pairing holds too: the catch writes
   `lastError` before the belt branch sets the flag, so a flagged status always carries the sentence
   the hover shows (U2 item 7's invariant).
5. **U2 item 4 — the retention suite's week math, re-derived by hand by this reviewer** against
   `Retention.keepDailiesAndWeeklies` (dayIndex/Monday-aligned weekIndex): at the off-boundary
   instant (2026-01-07 12:00 UTC, day 20460) dailies = offsets 2…15, covered weeks {2923, 2922,
   2921}, weeklies land at 17 · 24 · 31 · 38 (four); at the boundary instant (2026-01-04 00:20 UTC,
   day 20457 — verified a Sunday, the week's last day) dailies cover {2922, 2921, 2920} and exactly
   THREE uncovered weeks remain: 21 · 28 · 35. Both epoch-second literals verified. The suite's
   expected sets are exactly right, and the week-tail truth of 17 confirms VX-546's "real miscount"
   reading falsified. The red-on-old is deterministic on any run date after the boundary instant
   (the past-the-clock pair reads trusted under the old road's real `Date()` forever after
   2026-01-04).
6. **The pair road's production shape is byte-identical:** `roadNow` resolves the injected `\.date`
   whose live generator IS `Date()`; `runPair` hands its `now` explicitly; the one detached-task
   site passes `Date()` explicitly with the task-local reason said in place; the 19 test call-site
   edits are purely mechanical (read in diff). `ProtectionCopyCounts.read(now:)` left on `Date()`
   is correctly justified (a detached-task read the injected clock cannot reach, feeding a display
   count).
7. **U1b's seam shape:** `ApplyProfileHook` nil-inert verified at both read sites (the marks read no
   clock with a nil hook; `foreignKeyColumns` guards before `ContinuousClock.now`); the one
   structural line (`let saved = try await …; marks.lap(.applyTransaction); return saved`) preserves
   value and throw path; the inner `ApplyProfileMarks` is a closure-local never captured; no lap
   sits where a throw could skip bookkeeping (laps are reads; a thrown round reports nothing). The
   bench, probes and bisection are gated (`.enabled(if: profiling)`) so the default suite count is
   untouched (my run: the gated tests skipped).
8. **U4 — the migration:** `v1_36_fk_child_indexes` registered after main's
   `v1_35_sweep_kill_verdict_markers`; two plain single-column indexes, the measured shape; its own
   commit first (2a1b6e600 precedes the pin and bench commits); correctly NOT a SyncSpec §12 event
   (mirrors carry no client indexes — §2; the completeness walk classifies columns; marker stays
   14); the VX-502 export boundary (v1_36 refuses on every older build, 1.0.1 included) stated in
   the DDL doc and the arrival test; `MigrationTests`' enumerations updated under the
   justified-edit ritual with v1_34's own claim preserved. U4 item 3 (the one-time index build at
   an existing store's first open, not re-measured) accepted: ms-class at her ~21k blocks, the
   v1_34 precedent's silent class.
9. **U4 items 1/2/6:** the ratio pin's margins (green ≤ 1.03×, red 12.44×, bound 4, both arms in
   one test so load largely cancels; forensics printed per run; the FK-ON honesty guard present)
   accepted as a non-flake — see F4 for the one arithmetic hazard; the micro-pin + gated-bench pair
   accepted as the bug-class evidence (the migration arrival pin holds the structural half; the
   bench re-ran the engine road at scale, 3.7×); the VX-672 paragraph's RESTRICT-checked-immediately
   clause matches SQLite's documented FK behavior (RESTRICT fires immediately even for deferred
   constraints), and the paragraph correctly claims shape, not cause.
10. **The VX-721 bracket, cold-read here for the first time:** both artifacts carry the 10/14c idiom
    exactly (the grant the first statement after the guard, the revoke after the last re-own, one
    transaction, idempotent; the rollback's end state is the pre-deploy usage-only posture);
    `definerCreateBracketProblems` checks presence, uniqueness, and all four orderings
    (guard→grant→creates/re-owns→revoke→commit) on comment-stripped text and is asserted in both
    VX-495 pins; the sweep's two `has_schema_privilege` rows carry the right expectations (USAGE
    true, CREATE false — P-500-9) with fail-class wording in the sweep's own vocabulary and a sixth
    ord in the union. Proven LIVE by deploy run 2 (`[]`) and the sweep's 65 OK · 4 INFO · 0 fail.
11. **The two orchestrator-landed round-2 pins:** F-R2-1's `format()` tuple needle
    (`pick_sql, max_rows, fetch_sql)`) present in the bound pin and unique in the artifact
    (artifact :287 — counted by this reviewer); F-R2-2's cross-pin (`postChainFunctionArtifacts ⊆
    searchPathDeployOrder`, one-directional) present at AuthRLSDDLTests:3371.
12. **The server artifacts against the anchors:** everything the two server-half rounds closed
    stays closed — SHAPE B's pick/bound/fetch text, the outer page cut pinned, the count's
    index-only shape, no marker write, 13's arrays byte-equal, the rollback's byte-identity
    machinery and never-in-chain posture, the resolver handling, the deploy-order change
    (`[String: [String]]`, belt then keyset under 17). Nothing after the rounds weakened a pin;
    the range since round 2 only added the bracket, the sweep rows and the two round-2 pins.
13. **The wire surface:** arm 9's allowlist grew by exactly `sync_pull_remaining` + the one
    `pullRemaining` protocol requirement, the post-chain artifacts derived from the ONE list, and
    the challenge contract agrees end-to-end (the artifact gates under `'sync_pull_remaining'`;
    the engine signs `signer.call(rpc: "sync_pull_remaining")`; the wire keys match the SQL
    signature; the bare-bigint parse matches PostgREST's scalar result). The production transport
    is the bare `SupabaseTransport` (the only production `SyncTransport` conformer; minted at
    AppServices:175 and handed unwrapped), so the `as?` cast succeeds in production and the test
    wrappers model the undeployed surface.
14. **The faces:** classification order verified in source (devStore → unconfigured → syncing →
    offline → retrying → keysLocked/notOnYet → mismatch → crypto → behind → notEntitled → error →
    stalled → idle) — D-505's letter; `.retrying` carries `.syncing`'s exact doors (CF-15);
    "Syncing…" byte-unchanged with no progress and every other kind's line pinned byte-identical
    under the new parameter; ONE count spelling (`progressCount`) serving the row and both sheets;
    P-500-8's clamp display-only with the stored total untouched; the PROVISIONALs (P-500-1/-2/-3/
    -7/-8) recorded in full with alternatives, correctly bundled for her.
15. **VX-490:** the leaf parameter `any SyncKeysLeaf & Sendable`, the `nonisolated(unsafe)` escape
    hatch gone, the bootstrap's never-read stored copy dropped (compile-verified; the F-M1-1
    one-leaf doc moved to the mint); the :728 `VaultLeaf` sibling correctly left with its
    cascade reason (a core seam this unit does not own).
16. **Performance invariants:** nothing in the diff scales with corpus beyond what R-500-1 ruled
    (the count, once per long round, server-side); the publishes are bounded by windows + the
    1,000-row stride; the two indexes strictly reduce cost; no word-level tracking, no text copied
    across entities.
17. **Suites, run by this reviewer:** `swift build` green; the diff's core suites
    **158 tests in 14 suites passed** (AuthRLSDDL 83 · the attacker pair · SyncProgress 7 ·
    the resume/scheduler suites · MigrationTests · the vx720 pin · the seam pins, gated bench
    skipped). Mac suites deliberately not run (no stage claim; the closing window's conditioned
    full-target runs are the merge gate).
18. **Hygiene:** `notes/KnownIssuesAndTechDebt.md` carries nothing this run's members own (grepped);
    QUESTIONS.md and the shared ledgers untouched on the branch (the merge-moment rule — the drafted
    canon deltas are enumerated in the ladder plan and MUST land at the merge: AppSpec §12's row
    lines, SyncSpec §12's maintenance entry for the deployed body, SurfaceContracts' row contract,
    AppSpecRecord's dated entry, the QUESTIONS PROVISIONALs bundle — restated here so the closeout
    checks it); no commit in the range carries a trailer; the protection-test edits are mechanical.

## Round disposition handles

- F1 → one line in the discard branch + its engine-scene pin (red-on-old per the finding).
- F2 → one doc line in `SyncTransport.swift` (no pin possible).
- F3, F4 → the implementer's or orchestrator's judgment; neither gates anything.
- No BLOCKER/MAJOR ⇒ by the ladder's rule, no round 3 is earned by this record; round 2 re-checks
  the fixes.
