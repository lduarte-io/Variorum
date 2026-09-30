# 18o LADDER — ROUND 2 (cold re-review of the round-1 fixes, fable-reviewer, 2026-09-30)

**Reviewer:** fresh `fable-reviewer`, `notes/REVIEW_PROMPT.md` verbatim ({PHASE} = 18o), zero
framing beyond the ladder rule (round 2 re-reviews the fixes against round 1's findings).
**Range reviewed:** `bec30448..HEAD` — the two fix commits (`f50f68f2` doc-only in
`Sync/SampleLibraryDedupe.swift`; `7ed59c3c` dispositions + record corrections), every hunk
read. The phase's TRUE full range (`044a6bb0^..HEAD`, per R1-3) was round 1's; this round's
scope is the fixes plus every disposition's claim, each verified at the source.
**Canon read this round:** CLAUDE.md + auto-loaded canon · `notes/SyncSpec.md` IN FULL (the
fix touches `Sync/`) · `notes/plans/18o-ladder-round1.md` whole · the phase plan's ledger +
U6 record whole · `SampleLibraryDedupe.swift` IN FULL ·
`SyncEngine.swift`'s pull-apply path (:480–:590) + seq bookkeeping (:655–:789) ·
`Merge.swift:116` · `SampleLibrarySignedOutRetirementTests.swift` IN FULL · KnownIssues
row 66 (the U6-adjacent owner cell).
**Runs by this reviewer:** baseline core `swift test --filter
SampleLibrarySignedOutRetirementTests|SampleLibraryDedupeRepairTests` → **21/3 green**;
the R1-2 mutation **M-noSeqGuard RE-RUN INDEPENDENTLY** (the two `knownSeq` guards dropped
at `SampleLibraryDedupe.swift:332-335`) → `Test run with 4 tests in 1 suite failed … with
2 issues` — EXACTLY `aCopyRestoredAfterTheDeletionIsNeverTakenByTheOldTombstone`, both
arms (:198, :200), everything else green; restored by `git checkout --`, diff empty,
21/3 green after. No Mac tests (the fixes carry zero app-target lines); her app untouched,
zero instances checked by PATH before any run.

---

## VERDICTS ON THE ROUND-1 FINDINGS (each disposition's claim verified at the source)

- **R1-1 — FIXED.** The reworded doc (`SampleLibraryDedupe.swift:305-310`) is TRUE at the
  code, clause by clause: the F2 arm (:239) sits after the `count == 1` early return
  (:224-227), so it never runs on this road; every pull-applied row gets `recordSeq` inside
  the same apply on ALL THREE roads (clean write `SyncEngine.swift:544`; echo/stale skip
  :534; the dirty-merge road `Merge.swift:116`), and `runPostApplyRepairs` runs after the
  loop (:548) in the same transaction, so the guard's `knownSeq` read (:332) sees the
  recorded seq; `knownSeq` (:776) is SyncSpec §3's rule verbatim (absent ⇒ 0). "The
  never-accepted guard alone" is exact — on this road that guard is the operative decline.
- **R1-2 — FIXED.** The M-noSeqGuard run's claimed counts reproduced independently this
  round (2 issues, exactly the restore-guard pin's two arms, the other three tests green;
  clean restore verified twice — the disposition's and mine). The test doc-comment
  "M-noSeqGuard is its teeth" (:175) is now true as written; the U6 record carries the run
  (ledger row 17's disposition block, plan :2242-2244).
- **R1-3 — FIXED.** Ledger row 18 (plan :233) names the true range `044a6bb0^..HEAD` with
  the mis-scoping's history; this round's brief carried the corrected framing; the round-1
  file's header records the range actually reviewed.

## FINDINGS (severity-ranked)

**[MINOR] · `notes/plans/phase-18o-correctness-singles.md:2205-2206` (U6 record, THE DESIGN
item 5) · The R1-1-corrected falsehood survives verbatim-in-substance in the phase's own
binding record** · Item 5 says *"F2's quiescence rule extends naturally: a live copy that
itself arrived this batch defers exactly as today (the existing arm already re-arms the
one-shot marker)."* That is the exact claim R1-1 falsified: on the new leg's road the
count==1 early return (:224-227) precedes the F2 arm (:239), so no deferral happens and no
marker is re-armed — the arrived copy is DECLINED by the never-accepted guard (:332), a
different mechanism with no marker. The R1-1 fix corrected the code doc but not the record's
parallel claim; a repo-wide sweep shows this is the ONE surviving instance (the test files'
F2 comments all describe the multi-copy road, where the arm genuinely runs). The plan files
are the binding design records (AppSpec §12), the U6 record is #146's design record, and
#146 is PROVISIONAL with her ratify pending plus 13y adjacent — a future toucher reading
item 5 inherits the same "a second net exists" belief R1-1 existed to kill. Doc-only, no
pin possible (behavior is already right; the traced degradation is the record misleading
the next toucher). **Fix:** one bracketed correction at item 5 — superseded by the ladder's
R1-1: on the count==1 road there is no deferral; the shield is the never-accepted guard
(the code doc at :305-310 carries the true mechanism).

**[NIT] · `notes/plans/18o-ladder-round1.md:211-215` · Stale "(pending)" disposition stubs
above the filled DISPOSITIONS section** · The original placeholder block ("Finding 1 —
(pending)" …) survives above the real dispositions appended at :219-234; a fast reader
meeting the first section could take the findings as undispositioned. **Fix:** delete the
stub block or mark it "superseded below".

No BLOCKER, no MAJOR — round 3 is NOT earned; this round's verdict closes the ladder.
Nothing in the fix diff tracks word-level change, copies text across entities, or scales
with corpus size (the diff is one doc comment + record lines; zero behavior).

## CLEAN BILL (what this round checked and found solid)

1. **The R1-1 rewording's every claim traced at the sources** (see the verdict above) —
   including the corners: a batch row beyond the straggler stopIndex is neither applied nor
   counted (arrivingDeadIDs is prefix-only, `SyncEngine.swift:517`); a repair-revived row
   keeps its recorded seq; the empty-window marker road hands the leg an empty
   `arrivingDeadIDs` and returns 0 before any guard.
2. **The M-noSeqGuard evidence is real teeth, not theatre:** under the mutation the
   from-scratch third device retires the deliberately-restored copy and the retirement
   propagates to the restoring device — both arms red in the ruled scenario's own shape;
   the other three tests (retirement fires · edited never retired · Put back real) stay
   green, so the mutation isolates exactly the deliberate-restore corner.
3. **SyncSpec conformance of the fixes re-checked after a full read:** the diff adds zero
   behavior, zero schema (marker stays 9), zero server lines; §3's never-accepted-ranks-0
   rule is now quoted CORRECTLY at the one place in `Sync/` that leans on it; §7's
   explicit-outbox and repair rules are untouched by the fix commits.
4. **The dispositions' process shape:** same-model flow correctly applied (Fable reviewed,
   the Fable seat implemented U6 — the orchestrator arbitrated against the spec, and its
   own-side findings got no softer treatment: all three CONFIRMED); every finding carries a
   written disposition landed repo-first before this round; "no new BLOCKER/MAJOR ⇒ no
   round 3" matches the ladder rule.
5. **Records consistent across the three homes:** ledger rows 17/18, the U6 DISPOSITION
   block, and the round-1 file agree on the counts (M-noSeqGuard 2 · M-always 3 · M-wide 9
   · pins 7 · R-U6 identical) and on the range history.
6. **Hygiene:** zero commit trailers in the range; tree clean before and after my mutation
   run; KnownIssues row 66's #146 arm correctly awaits the closeout (ledger row 19), owed
   nothing by these fixes.

## DISPOSITIONS (filled after orchestrator arbitration)

- R2-1 (the record's design item 5) — (pending)
- R2-2 (the stale stubs, NIT) — (pending)
