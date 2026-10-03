# 13i-e — LADDER ROUND 2 (fresh cold reviewer, `fable-reviewer`, 2026-10-03)

**Charter:** re-review the round-1 fixes — verdict each round-1 finding FIXED / NOT-FIXED /
FIXED-WITH-A-NEW-PROBLEM; surface any NEW finding inside the fix diff's blast radius. Diff under
review: `git diff 2bd9a908..589c521f` (4 commits; three files — the two-step db-level designation
guard in `Operations+Appearance.swift`, the new pin in `DailyJournalRulingsTests.swift`, the
round-1 record's dispositions). Anchors read whole in this session, nothing delegated:
`notes/REVIEW_PROMPT.md`, `notes/plans/13ie-ladder-round1.md` (findings + dispositions + fix-pass
record), the phase plan `notes/plans/phase-13i-e-daily-journal.md` (R-13ie-1…4, both riders, the
U1/U2 records, both adjudications), CLAUDE.md + the auto-loaded canon, and the production/test
code around the fix (the full `setDailyJournalBook` pair, `liveReading`,
`insertDailyJournalBook`, `OperationError`, `OpsRefusalTable`, the pin's fixtures).

**VERDICT: ROUND CLOSED — all three round-1 findings correctly dispositioned; ZERO new findings.
No BLOCKER or MAJOR anywhere in the fix diff ⇒ no round 3; the ladder closes at two rounds.**

## PER-FINDING VERDICTS (each mechanism re-traced by this reviewer, not taken from the record)

### F-R1-1 (MINOR — the db-level designation guard checked kind but not liveness) — **FIXED**

- **The fix re-traced** (`Operations+Appearance.swift:430–437`, commit `a3fd7cfe`): the two-step
  guard reads the LIVE row (`SELECT kind FROM reading WHERE id = ? AND deleted_at IS NULL`);
  fetchOne nil (dead or missing — `kind` is NOT NULL, so nil ⇔ no live row) refuses
  `readingNotFound(id:)`; a live non-book refuses `wrongReadingKind(expected: .book)`. Both sit
  ahead of every write — the demote UPDATE, the stamp UPDATE, and the cache upsert all follow the
  guards. The traced double-mint road (dead designee ⇒ every live `'daily'` bearer demoted, the
  stamp UPDATE unable to reach the dead row, the cache naming a dead id ⇒ the derived read nil ⇒
  ⌘J mints a fresh Journal beside the demoted original) is closed at the seam ACT 0 hardened.
- **The accepted refinement verified as the right call:** `readingNotFound` IS the public door's
  own word for a dead/missing row (`liveReading`, `Operations.swift:85–90`), so the db-level seam
  now converges with the public door's semantics instead of mislabeling the cause as a kind
  problem; `OpsRefusalTable` already carries a `.readingNotFound` arm (`OpsRefusalTable.swift:177`),
  so even the face-level words are covered (though no face can reach this seam with a dead id).
- **No live caller's behaviour changes — every call site re-read:** the public door
  (`setDailyJournalBook(_ readingID:)`, :388–396) pre-filters through `liveReading` in the same
  write transaction (a dead row threw `readingNotFound` there before and still does); the mint
  (`insertDailyJournalBook`, `Operations+Container.swift:277–295`) passes the live `kind: .book`
  row it just inserted — both guards pass; grep over Sources/Tests/App finds NO other caller of
  the db-level twin. The internal-seam word for a DEAD gathering or a MISSING id changes
  (`wrongReadingKind` → `readingNotFound`) — unreachable through any public road, no test premised
  on the old word (grep-verified), and the new word is the honest cause.
- **The pin verified red-on-old BY THIS REVIEWER'S OWN RUN** (a scratch worktree at `0280eb36` —
  the pin committed ahead of its fix; the main tree untouched, worktree removed after):
  `theDbLevelGuardRefusesADeadDesignee` → **RED, 6 issues**, one-for-one the recorded mechanism —
  "an error was expected but none was thrown"; `liveDailyBooks` ≠ the Journal (demoted);
  `dailyJournalBookID` nil; the cache naming the dead book; the outbox written; the missing-id arm
  thrown as `wrongReadingKind` (the wrong cause's name). **GREEN on the tip:**
  `DailyJournalDesignationKindTests` 3 tests / 1 suite passed (the new pin + ACT 0's two, the
  gathering control included).
- **Pin quality:** the fixture reaches the dead state by the raw row write an older build's
  delete / another device's tombstone is (the delete door refuses now — the only honest road);
  the outbox is cleared AFTER the fixture so the zero-outbox assert is meaningful; the guard runs
  inside the caller's single write transaction, so no TOCTOU window exists.

### F-R1-2 (NIT — the ~215-char guard line) — **FIXED** (riding `a3fd7cfe`)

The one-liner is gone; the two-step guard wraps at the file's width (longest new line ~80 chars);
the doc comment now states the WHOLE promise honestly (kind AND liveness — its wording matches
the SQL exactly: the demote UPDATE strips live bearers, the stamp UPDATE filters
`deleted_at IS NULL`).

### F-R1-3 (NIT — the Quicknotes comes-back question) — **correctly NOT FIXED (routed)**

A question for the #179 bundle, never a fix: nothing in the fix diff touches it; the round-1
record routes it to the closeout (ledger row 7, not yet due). The right disposition under the
spec rule — undefined product behavior goes to her bundle, not a ruling.

## NEW FINDINGS INSIDE THE FIX DIFF'S BLAST RADIUS

**None.** Checked and found solid:

- The diff touches exactly three files — zero `Sync/`, `Server/`, `Persistence/`, editor seam
  (`git diff --stat` verified); the dispositions file is the round-1 record itself.
- `OperationError` is `Equatable`, so the pin's exact-error `#expect(throws:)` matching is sound.
- Suite arithmetic honest: exactly ONE new `@Test` in the diff ⇒ 2172 + 1 = 2173.
- Commit-trailer sweep over `2bd9a908..589c521f`: zero `Co-Authored-By`/`Claude-Session` lines.
- The round-1 DISPOSITIONS section is accurate against the code and the commits (pin-first order
  `0280eb36` → `a3fd7cfe` verified in the log; the recorded natural-red count 6 reproduced by this
  reviewer's own pre-fix run).

## VERIFICATION RUNS (this reviewer, foreground, on the tip `589c521f`)

- `swift test --filter "DailyJournalDesignationKindTests"` → **3 tests / 1 suite PASSED**.
- The pre-fix worktree run (`0280eb36`) → the pin **RED, 6 issues** (the natural red reproduced).
- The daily/archive/keeper neighbours (incl. the two re-premised suites):
  `swift test --filter "DailyJournal|BookArchive|ArchivedIntake|ArchivedGathering|ArchivedListing|ArchivedJournalKeeper|JournalKeeperRepair|ThemeAndShelfQuery"`
  → **95 tests / 21 suites PASSED**.
- The FULL core suite: **"✔ Test run with 2173 tests in 244 suites passed after 123.059 seconds"**
  (1 standing env-gated real-server skip) — the round-1 END-run count confirmed on the same tree.
- Tree clean before and after; the scratch worktree removed and pruned; no revert in flight.

## CLEAN BILL

1. The two-step guard closes F-R1-1's traced mechanism at the db level, ahead of every write,
   with the public door's own refusal word — ACT 0's whole promise now held where its doc
   claims it.
2. No live caller's behaviour changes; ACT 0's original pins (gathering refusal + the book
   control) still green beside the new one.
3. The pin is a genuine red-on-old pin — reproduced red by this reviewer on the pre-fix tree at
   all six recorded issues, green on the fixed tip.
4. The round-1 dispositions are faithful to the cross-model flow (implementer agree, reviewer's
   final call, fix implemented by the reviewer, per-piece commits, suite green, repo-first
   record).

**THE LADDER CLOSES AT TWO ROUNDS** (round 2 raised no new finding of any severity; no round-3
trigger). Next per the phase plan: ledger rows 4–7 — the orchestrator's walk, her window, the
family close, the closeout.
