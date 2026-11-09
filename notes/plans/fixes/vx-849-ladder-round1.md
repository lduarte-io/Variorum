# VX-849 — ladder round 1 (cold review, Fable; 2026-11-09)

**Scope:** the whole run's diff, `git diff 75a5222ad...bd65aa5a1` (65 commits, 67 files; merge-base with main
75a5222ad; tip verified `bd65aa5a1`, tree clean). Prompt: `notes/REVIEW_PROMPT.md` verbatim. Canon read in full in
this session: SyncSpec · CastleRules · TEXTKIT2_NOTES · the vx-683 memo · the vx-544 plan ·
`notes/sync-postmortem-fragments.md` · the run record's plan, briefs, batch records and adjudications. Constraint
honored: no xcodebuild, no whole-package runs (another session's stage window live); every verification by reading,
with the diff's own headless evidence and the recorded window results as the execution record.

**Verdict: 0 BLOCKER · 0 MAJOR · 3 MINOR · 2 NIT.** No FINDER-FIXES; no `Sync/` finding, so I wrote no code.
One gating condition (R1-M3) that is already the run's own plan, stated here so the merge cannot outrun it.

---

## Findings

### [MINOR] R1-M1 · App/Variorum (ShellActions' undo/redo doors, not in this diff) · her own ⌥⌘Z under pending typing now mints a `'conflict'` card
- **What:** the structural undo/redo doors run the inverse without flushing pending typing. With VX-683 B landed,
  the inverse rewrites the take, her pending autosave then fires on a pre-undo snapshot, and the guard RESCUES:
  her buffer keeps the row and the undo's restored words become a `'conflict'` card — against R-683-2's premise
  ("a deliberate act of hers never mints this card"). The run record found and recorded this itself (batch 3
  corner C2) and the batch-3 adjudication ruled BORN TICKET at the closeout.
- **Evidence (traced):** `Operations.autosave` (Operations+Variant.swift, the guard arm) + the undo inverse's
  take rewrite; the undo road's standing insurance savepoint means nothing is lost — the card is additive noise.
  Pre-fix the same gesture silently overwrote the undo's restored text, so the net direction is an improvement.
- **The pin that would prove the eventual fix (red on today's tree):** undo pressed with typing pending → the
  undo's text on the row (her typing flushed first), NO `'conflict'` card; today the card appears.
- **Final-call shape:** CONFIRM the adjudicated disposition — the ticket MUST land at the closeout's ticket pass
  (fix shape: the flush-first doctrine at the undo door's warn→act latch, P-849-1's sibling). Not this run's fix.

### [MINOR] R1-M2 · notes/SyncSpec.md §7 (the OWNED-exclusivity paragraph) · the spec's stated rank is falsified by the landed code
- **What:** `Repairs.swift` now ranks claimants by `ownedClaimOutranks` (earliest `reading_post.created_at`, ties
  by id; the seq join removed), while SyncSpec §7 still says "the EARLIEST-ACCEPTED membership stands
  (never-accepted rows rank last per §3's seq-0 rule; ties by id)". The record queues the canon delta contingent
  on P-849-6's sitting — but the MERGE precedes the sitting (her overnight mandate), so main would carry an
  authoritative sync spec whose stated rank the code no longer implements, read IN FULL by every future sync
  session.
- **Evidence:** Sources/VariorumCore/Sync/Repairs.swift:975–1082 vs notes/SyncSpec.md §7 (the OWNED paragraph);
  the batch-6 record's own "Canon deltas owed" paragraph carries the proposed replacement text.
- **Fix shape (doc-only, the closeout's):** land the §7 line at the closeout in the standing PROVISIONAL idiom —
  the line as built plus the P-849-6 pointer — rather than leaving the superseded sentence until her sitting.
  (§3's "§7's seq-ranked repairs read it" stays true of I2 and the two I10 arms; no change there.)
- No pin (doc finding; the code side is pinned by `OwnedExclusivityRankConvergenceTests`, which I verified
  exercises the gap — both pins assert the two devices' seq pictures DIFFER at decision time).

### [MINOR] R1-M3 · LIVE STATUS row 8 · the batch-3/4 Mac pins and named reverts have NOT yet executed — a stated merge gate
- **What:** batches 1 and 2 ran their stage windows (legs A/B/D, reverts bit exactly as named — the record's
  window sections). Batches 3 and 4's Mac/simulator pins are PENDING the orchestrator's window: batch 3's leg A
  (OutsideWriteRescueCompositionTests · RestoreFlushFirstInsuranceTests · PostRescueFaceTests, 15/3) and leg B
  (the six named reverts R-G1 · R-G3 · R-P1a · R-P1b · R-G2 · R-B1), batch 4's Mac leg
  (StaleEnvelopeSweepRoadTests), leg D's phone types, the whole-core sweep, the whole Mac/phone targets on the
  merged tree (the vx-915 overlap re-prove + the AppSession eye-read), and the orchestrator's walk.
- **Why it is a finding and not only a status row:** this round's approval of batches 3–4 rests on READING those
  pins (each is behavior-red by construction — they drive only pre-fix API — and each has a named one-file
  revert); the EXECUTION record is still owed. The ladder's pass is conditional on row 8 running them before the
  PR merges, red/green exactly as named.
- **Fix shape:** none (process). The run already tracks it; this line makes the condition the ladder's.

### [NIT] R1-N1 · App/Variorum/Shared/AutosaveCoordinator.swift (flushNow's doc) · "writes land in the order they were recorded" overstates one axis
Within one batch the per-take entry is coalesced (so per-take order — the axis that matters — holds), but
cross-take writes land in variantID-sorted order, not record order. Doc-only; the ORDER PIN's claim (an older
in-flight batch never lands over a newer flush's text on one take) is exact and verified.

### [NIT] R1-N2 · App/Variorum/Shared/Protection/ProtectionOpenRoad.swift (`retryingSyncKeyLoad`) · a joiner's fresher `signIn` is discarded
A retry asked while one flight is out joins that flight, whose `signIn` was read at ITS start; a sign-in landing
between the two reads waits one occasion. Traced; impact is one delayed round, self-healing at the next
`beforeRound`. Record-only — no pin could distinguish it from the next round's ordinary healing.

---

## Concurrences (recorded corners re-checked by this round; dispositions CONFIRMED as adjudicated)

- **R1 (batch 3)** — the face-only spurious ring-end (a confirmation's fresh read raced by a landing write):
  mechanism re-traced; data-safe BY G3 (the pane adopts her own landed words); the one-read-wide window needs a
  flush door to start and land a write inside it. Low ticket at closeout — concur.
- **C1 (margin-rail recentre on a note's first fan)** — presentation rule's own consequence; concur, low ticket.
- **Batch 6 corner 1 (the partial-picture OWNED corner)** and **corner 5 (a seated arrival ranks by its bell's
  birth)** — both pre-existing, key-independent or schema-event-sized; concur with ticket/P-849-6-rider.
- **The sibling seq-rank repairs (I2 move/move · I10 ×2)** — correctly NOT widened (SyncSpec §7 rules their
  rank); one ticket at closeout — concur.
- **VX-855 RECORD-ONLY** — the hallucination guard worked: green confirm (2/2 ×3), no fix; the runner-exit trace
  corroborated in-repo (FirstRoundAfterTheActTests.swift:285; VX-691); R-855a bit exactly its two lines; the
  teardown-ordering pins stay as regression guards. Concur, including the VX-691 close-or-re-scope call at the
  ticket pass.
- **P-849-1/-3/-4/-5/-6/-7** — each PROVISIONAL is built on the spec-defensible arm with alternatives recorded;
  all six MUST reach `notes/QUESTIONS.md` at the merge (the record queues them in four places — the closeout
  should consolidate the list so none drops).

## Clean bill (checked and found solid, with the mechanism traced in this session)

1. **The guarded autosave (VX-683 B)** — guards refuse first (`editableVariant` + `ensurePlacementUnlocked`);
   the rescue's card is byte-exact S5 shape (`insertConflictVariant`: label `'conflict'`, same parent, fan's
   end, never chosen, never locked); both rows reach the outbox through ordinary triggers; touch/churn identical
   to the unguarded write (pinned by whole-row snapshot comparison); comparison as the store keeps text
   (`StoredText`, optional overload verified); the dead-block belt; `nil` = today's blind write. The extra block
   fetch runs only when a rescue is imminent (condition short-circuit) — P1 holds.
2. **Every production `record(basedOn:)` call site carries the right snapshot** — the five pane owners through
   `PaneTextAuthority.shownText`/`liveHeld` (the same fact the ring-end judges by, so the two cannot disagree);
   Write's and the phone page's ledgers are edit-maintained and never adopt while unlanded (`deferUntilClean` —
   the G3 analog for Write is closed by construction, verified at `EditorViewModel.deliver`'s policy switch);
   the quick note's `recordBase` is seeded from the STORE's text at adoption (the import-normalization corner
   seen and handled); the crystallizer's two sites; the refused-write snapshot carry in `flushNow`'s error path
   (the older snapshot over the newer run — correct, traced).
3. **VX-402, the honest flush** — the serial lock's no-interleave argument holds on the MainActor (no suspension
   between the `writing` check and its claim); waiters re-check; `inFlight`'s defer leaves no pending/inFlight
   gap on failure; `isUnlanded` = pending ∪ in-flight; the ordering pin and the held-writer pins are genuinely
   behavior-red on old (and ran in batch 1's window, reverts proven, including the recorded R-402-alone overlap
   adjudication — not hollow).
4. **The convergence pins exist and are real** (AppSpec §15.3): `TypedOverRescueConvergenceTests` (the memo's
   mechanism whole, both devices end with both texts, outboxes empty),
   `FlushBeforeTheRoundConvergenceTests` (the occasion's (ii)-shaped apply + the straggler double-card),
   `OwnedExclusivityRankConvergenceTests` (both pins assert the devices' seq pictures DIFFER at decision time —
   the gap is exercised, never a coincidence; the repair write's explicit outbox row asserted).
5. **VX-544's custody shape** — derived material only (words → `WordsKey` at the keep; never the words or the
   passphrase text; redacted, non-`Codable`); session memory only; `letGoOfSyncKeyLoad` is final and ordered
   BEFORE the leaf clear under the session's ONE lock, and `holdLoadedSyncKeys` re-checks letGo + the leaf's
   before-state + the library's current keys under that same lock — a hold cannot land after a relock, a
   sign-out, a replacing reopen (`AppBootstrap.finish(.ready)`'s outgoing let-go verified) or over a hold that
   landed meanwhile; every non-failure exit of the load ends the pending (the `defer`); the retry joins ONE
   flight; the occasion costs one memory read with nothing pending and gates on `currentKeys()` correctly
   (`throws -> SyncEncryptionKeys`, non-optional — the `try? == nil` idiom is sound, checked); lock ordering
   between the session lock and the leaf admits no inversion.
6. **The reachability trigger** — first reading is the baseline (never a trigger alone); satisfied→satisfied
   inert; a drop inside the debounce cancels; one round per settled transition; the watch dies with the chain
   (`stopObservations`, which `configure` runs first — a reconfigure leaves no stale debounce task; checked);
   `NWPathMonitor` on the main queue with `assumeIsolated` is sound.
7. **The `beforeRound` hook** — nil = inert (the keyProvider pattern; the engine never learns editors exist);
   runs to its end before `triggerSync`/`flush`/`roundNow`, with the hold and the chain re-read AFTER the
   occasion (a retired chain is never revived); scheduler-started rounds deliberately run no occasion (the
   guard covers them); R-683-3's typing-pending gate (`hasPendingAutosave`, one cheap read; dictionary-values
   snapshot iteration is mutation-safe).
8. **VX-443** — the name parser admits exactly `variorum-keys-` + 16 lowercase hex + `.json` (no path can pass;
   `LibraryClassifier.isOlderFingerprintKeyFileName` read); the leaf deletes by `unlink` at the container root
   only, lstat-regular-file only, never reads a byte; assess vouches only names whose fingerprint the OPENED
   live key file holds (current or history) and never mid-act; the executor re-verifies with the key in hand
   (`historyKey` opens, not just lists); the read-only road sweeps nothing and the pre-design face is never
   reached (both pinned, `StaleEnvelopeSweepRoadTests` / `StaleEnvelopeSweepScenarios`); rule 4 is why nothing
   openable is lost — the delete-vs-keep alternative recorded as the brief required.
9. **VX-545** — the ratified sentence at all five touch points, the lifecycle page regenerated from the fixture
   (fixture-pinned, never hand-edited), and the byte-pin strengthened to assert the ratified words AND the
   absence of the superseded ending on both the rule and the app arm.
10. **VX-921** — the rank is a pure strict total order over converged, immutable bytes (`reading_post` carries
    no `updated_at`; no road rewrites `created_at`); the arms, stamps and outbox writes untouched; the local
    twin (`enforceOwnershipAfterRevival`) already keyed `created_at, id`, so the two roads now stand the same
    row (the doc alignment is comment-only); the one fixture edit is a justified hand-stamp correction, said
    plainly; SyncSpec §9's no-clock-trust is respected (a wall clock RANKS converged bytes, never orders
    application — the precedent is VX-893's wing-mend anchor, already in SyncSpec §7).
11. **VX-919 + rollback** — guarded (marker ≥ 14, table, role), one transaction, idempotent; INVOKER trigger
    with schema-qualified relations and no SET clause (outside the pg_temp belt by construction); deterministic
    eviction (`seen_at, device_id`) that never takes the caller's own row and trims count−cap (concurrency
    overshoot heals); containment arm (a cap failure can never abort a pull); definer DELETE granted and named;
    footgun revoke; no marker, no RPC, no re-own; the grant sweep's presence-aware row (parenthesization
    checked: `(reencrypt-filter) AND (cap-filter)`); the paired rollback restores exactly the pre-state; the
    whole letter pinned in `AuthRLSDDLTests.deviceCursorCapBeltIsGuardedContainedPairedAndTouchesNoRPC`;
    NEVER executed — verified no execution evidence anywhere in the record, and the deploy HELD (row 9).
12. **The editor seam discipline (P-3 / TEXTKIT2_NOTES)** — zero lines in `PaneSurface` / `BlockRangeIndex` /
    `EditorTextView`; no TK1 API, no exclusion paths, no new rendering-attribute use; `shownText` only aligns
    the edit's snapshot with the fact the ring rule already holds; the one live pane invariant untouched; the
    G2 ring-end reuses VX-222/VX-577's blur shape (flushed — no keystroke dies).
13. **The sweep table's class-completeness** — independently spot-checked S8 (moveSpanToNewTake), S9
    (structural undo), S14 (resolveSyncConflict mints), S15 (restoreNoteVersion unmounts), N3/N4 (the lineage
    mints), S12 (the wire's other tools) against the operations layer; no missing writer class found. The G1
    and G3 holes the batch found are real (mechanisms re-traced here) and their fixes route through the one
    seam, no per-road patch.
14. **Hygiene** — 65 commits, zero attribution trailers; no history rewrite; `Sync/` touched only by batch 6's
    ruled swap (batch 1's hook is app-side as the memo promised: zero engine knowledge of editors); the
    `_sync_applying` staging in tests mirrors SyncSpec §3's apply mode faithfully; schema untouched (no §12
    event, as the kickoff promised); `notes/TICKETS.md`/QUESTIONS/master plan untouched in the worktree (the
    merge-moment rule).

## Review foci
The run's plan files carry no "Review foci" section (checked: the run record, the vx-683 memo, the vx-544 plan);
the briefs' per-batch "how I would attack this diff" self-assessments were each read and their attack lines
re-run by reading (batch 6's determinism and VX-919 attack-surface lists verified point by point above).
