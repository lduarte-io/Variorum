# 17y B2 — cold-review ladder ROUND 2 (opus-reviewer, 2026-10-05; the fix-round re-review — THE LADDER CLOSES HERE)

**Scope:** `git diff d3560ab9..873fed6b` (the fix round), reviewed fresh and cold under
`notes/REVIEW_PROMPT.md` with round 1's record (`17y-b2-ladder-round1.md`) as the checklist.
Probes ran in a scratch clone at 873fed6b (a `git archive` copy fails the Stamp Build Number
script — a walker fact worth keeping); the worktree untouched; zero instances throughout. The
reviewer re-confirmed the cast call independently (fence diff EMPTY; `CaptureTextView` outside
the seam by its own header).

**Verdict: 0 BLOCKER · 0 MAJOR · 0 MINOR · 3 NIT — all three NEW and all comment/record-only.
No round 3. Every round-1 finding is CONFIRMED:** MAJOR-1 fixed (lock-first re-proven by
removing the one line — RED 4 issues; the op's own refusal speaks, sealed wording held),
MINOR-1 fixed (identity revert RED 2/2; the round-1 hollow configuration now RED at the
`#require`; the load-bearing note at all three sites), NIT-1 fixed for the class (async hop:
0 warning lines; synchronous probe: 1), NIT-2/3/4/5/6 each re-proven by revert or bite probes
exactly as recorded. MAJOR-2 and F-B2-7's re-owns verified in the records (B-DEDUPE's ladder
and B3's brief item 11 carry them).

## The three new NITs and their dispositions (the orchestrator's, same seam)

- **[NIT-A] `CaptureTextView.swift:191–197` — the new comment overclaims the `.task` road**
  (its own round could not reproduce that ordering; the measured warning roads — the padding
  tap and the title chip — go unnamed). **DISPOSITION: FIXED AT THIS SEAM** (comment-only, by
  the orchestrator): the comment names the two measured roads and marks the `.task` road's
  ordering untraced (F-FR-1).
- **[NIT-B] `Capability.swift:747` + `TutorialBooksChapterTests.swift:19–20` — two more stale
  "synthetic drags never commit" comments** (F-B2-1's class, missed by round 1's four).
  **DISPOSITION: FIXED AT THIS SEAM** (one-line corrections; the menu twins stay, only the
  stated reason changes).
- **[NIT-C] the spot-walk record calls `notes/plans/17y-screens/b2fix/` gitignored; it was
  not** (`.gitignore` covered only `b-seed/` and `b2/`; an unfenced add could push dev-store
  PNGs into never-rewritten history). **DISPOSITION: FIXED AT THIS SEAM** — `.gitignore` gains
  the dir; the record's claim becomes true rather than re-worded.

## The F-FR dispositions (owed from the fix round, ruled here)

- **F-FR-1 (a focus request raised before the box is windowed is dropped; the pin's host
  therefore drives the re-raise road, not `.task`): RECORD-ONLY, NO OWNER — the hollow-finding
  rule.** The only reproduction lives in the TEST window's mount order; the real Bookcase road
  was walked live twice (B2 walk m1; the caret arrives). No user-visible defect is traced, so
  there is nothing a red-on-old pin could guard; the candidate fix (seed `wantsInitialFocus`
  when no window is found) would change focus behaviour on both capture doors on an untraced
  trigger — exactly what the fix round rightly declined. If a real trigger ever surfaces, it
  becomes work with an owner then; the record (the fix-round section + this file) is the
  knowledge's home.
- **F-FR-2 (103 pre-existing "Modifying state during view update" lines in the Canvas
  arrival/bank/drag, masthead and routing suites): RECORD-ONLY.** Pre-existing, none from this
  pass's families; Canvas is Debug-only after (p), lowering the Release stake to zero for its
  share. A warning-hygiene sweep is not 17y's scope; the close bundle MAY offer it to her as a
  candidate 19-ledger letter (her glance, not a question).

**THE B2 LADDER'S FINAL SHAPE: round 1 (0/2/2/6) → the fresh fix round (8 findings fixed,
2 re-owned in-pass) → round 2 (0/0/0/3, comment/record-only, dispositioned above). The batch
closes with the orchestrator's spot-walk (the 17 file's record) + her Monday drag spot-check
as the standing human confirmation.**
