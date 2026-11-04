# VX-500 — WHOLE-DIFF LADDER, ROUND 2 (cold review of the round-1 fixes, Fable, 2026-11-04)

## FOR A LATER READER

Round 2 re-read the four round-1 fixes (`630a7b6d2` F1 · `85456ac1a` F2 · `bdb58f83d` F3 ·
`48063464a` F4, record `ea66c9b05`) against THE FINAL CALLS in
`notes/plans/fixes/vx-500-sync-followups.md`, with the surrounding code read on the tip and
SyncSpec read whole. **Verdict: all four CLOSED as fixed. No new findings at any severity. The
ladder closes with this record** (no BLOCKER/MAJOR was earned, so the cap stands at two rounds).
This reviewer re-ran the brief's filter on the tip — **"Test run with 154 tests in 10 suites
passed"**, byte-matching the fix record's close — and **independently reproduced F1's red-on-old**
in a scratchpad clone (the engine hunk of `630a7b6d2` reverse-applied, the pin kept):
`Expectation failed: downloading.last?.done == total` with `done → 750` · `total → 375` — the
recorded red lines exactly, proving the pin exercises both passes (200 stage + 175 resume + 375
refetch). The commits touch only the named files plus the record; no trailers; six commits since
round 1's record, all accounted for (the final-calls commit, four fixes, the close).

## FINDINGS

None. Nothing new at BLOCKER, MAJOR, MINOR or NIT in the fixes or their blast radius.

## F1–F4 VERDICTS

- **F1 — CLOSED as fixed.** `downloaded = 0` sits in the discard branch (SyncEngine.swift:668),
  exactly the final call's shape, beside `fetchCursor = since` with the why-0-is-honest comment
  the self-assessment promised. Mechanism re-traced on the tip: the reset is exact by construction
  because `PullStage.clear` ran two lines above in the same round and nothing restages before the
  refetch loop. `askedForTotal`/`remaining` untouched (verified in the diff), and rightly — the
  total's base `since` is also the refetch's base. The pin
  (`SyncProgressTests.aDiscardedUndecodableStageRestartsTheDownloadsProgressCount`) is a true
  red-on-old: this reviewer reproduced the red itself (750 vs 375, SyncProgressTests.swift:183) on
  the pre-fix tree, green on the tip. The discard road's standing pins
  (`ResumableCatchUpTests`) are unmoved in the 154/10 run.
- **F2 — CLOSED as fixed.** `SyncPullCountTransport`'s summary doc (SyncTransport.swift:218–230)
  now states R-500-1's index-only shape (owner + seq, NO horizon filter; may EXCEED what the feed
  serves right now) and points at `SyncProgress.total`'s doc — verified to carry the bounds a face
  must tolerate (SyncEngine.swift:51–58). Consistent with the fake's count and the pinned relation
  (`theCountIsIndexOnlyAndCountsRowsStillInsideTheHorizon`, green in this reviewer's run). The
  method-level doc, already right, untouched. Doc-class, no pin owed.
- **F3 — CLOSED as fixed.** The guard is the reviewer's named shape
  (`if case .resume = plan, progress != nil`, SyncEngine.swift:587). Byte-equivalence re-derived:
  under the guard `progress != nil`, so `reportsProgress = true` ≡ the old `= progress != nil`;
  with `progress == nil`, `downloaded` starts 0 and is never read — its only reader is the publish
  at :641 inside `if let progress`, and `reportsProgress` is consulted only inside
  progress-guarded blocks (:635–636) and the `saveProgress` mint (:702), which also guards
  `let progress` (grep-verified: no other reader). Seam suites green.
- **F4 — CLOSED as fixed.** `let ratio = pending / control`
  (DeferredFKChildScanPinTests.swift:78) — Duration's own division to Double; no Int64 exists to
  overflow, so the ~9.2 s trap is gone by construction (the old code's
  `seconds * 10^18 + attoseconds` overflows Int64 past ~9.22 s — arithmetic confirmed). Bound (4)
  and printed forensics unchanged; the non-vacuity `#expect(control > .zero)` retained at :73.
  Suite green on the tip.

## THE SELF-ASSESSMENT'S NAMED ITEMS — WEIGHED

1. **The count-surface-less pin scene (item 1): accepted, no live-total scene owed.** The final
   call's named pin was "the last downloading reading's `done` == the feed's count" — delivered
   verbatim. The double-count lives in `downloaded` alone (its only reader is the publish), the
   fix touches neither `askedForTotal` nor `remaining`, and the P-500-8 clamp is a face-side
   display rule outside the engine; a with-total engine scene would pin nothing the fix changes.
2. **Reset to 0, not a stage re-read (item 2): right by construction** — the stage was cleared in
   the same round two lines above; the branch's comment says why. The named future hazard (a road
   that discards without clearing) is hypothetical and guarded by the comment; not a finding.
3. **The raw-readings dip (item 3): traced and benign.** Under the scheduler, `advances`
   (SyncScheduler.swift:350–356) suppresses same-phase dips and admits the final equal-or-greater
   reading, so the UI holds at the pre-discard peak (≤ the feed's count) and ends at the honest
   count; the pin reads the raw closure and asserts the LAST reading only, immune to the dip.
4. **F4's zero-control corner (item 4): the guard's loss is deliberate, not accidental — accepted.**
   Old and new both fail a zero control (old: nursed huge-but-finite ratio; new: +inf/NaN, and
   neither is `< 4`); the new failure carries its forensics. Strictly more honest.
5. **The `staged == 200` premise (item 5): confirmed.** The non-vacuity line fails loudly if the
   fixture's seeding ever changes, and the red's 750 = 200 + 175 + 375 proves both passes (stage +
   refetch) are exercised — verified by this reviewer's own red reproduction, not the green.

## CLEAN BILL (what was specifically checked and found solid)

1. The four commits touch exactly the briefed files (stat-verified); nothing else rides the range
   since round 1's record; no commit carries a `Co-Authored-By`/`Claude-Session` trailer.
2. The fix record's load-bearing claims each located and proven: the red line (reproduced
   independently — 750 vs 375 at SyncProgressTests.swift:183), the green runs (the brief's filter
   re-run by this reviewer: 154 tests in 10 suites passed, exact match), F4's green (the VX-720
   suite in the same run), F3's "seam suites unchanged" (subsumed by the 154/10 green).
3. The pin's fixture mechanics: `armFailPull(atCall:)` is one-shot (FaultInjectingTransport.swift:
   146–152), so the second engine run forwards transparently; the transport does not conform to
   `SyncPullCountTransport`, so `remaining` is nil and the pin's `total` is the fake's own feed
   count; the progress closure is called inline (:641), so the raw readings' order is
   deterministic; `PullStage.rows` returns nil on ANY undecodable payload (PullStage.swift:217–229)
   and `stagedRowCount` counts the corrupted row too — the 200 premise holds.
4. SyncSpec conformance of the whole fix set: display-only counters, no cursor/belt/stage
   semantic touched (the one-writer belt, the continuity check and `UndecodableStage`'s
   second-failure throw all byte-unchanged); S1–S5 untouched; nothing scales with corpus (the
   COUNT(*) F3 guards was the only added read, now paid only by progress-carrying rounds).
5. The empty-refetch corner (a discard whose refetch returns nothing — e.g. a purge shrank the
   feed): falls through to the `emptyReport` road with the stage already cleared; progress simply
   stops publishing and the round's end clears it. No wedge, no wrong commit.
6. `pullToHead(progress:)` defaults nil, so the F3 comment's caller list is accurate; a
   progress-carrying `pullToHead` still gets the staged count, correctly.

## Round disposition

All four round-1 findings CLOSED as fixed; the dismissals stand as accepted; no round 3 is
earned. The ladder closes with this record. The merge-moment canon deltas enumerated in round 1's
clean bill item 18 remain owed at the closeout (restated, not re-found).
