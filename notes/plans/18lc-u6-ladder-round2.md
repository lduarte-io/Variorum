# 18l-c U6 — ladder ROUND 2 (fresh opus-reviewer over the fix pass, 2026-09-28)

**Window:** `1c048025..8d246b00` (round 1's fix pass). **Verdict: 0 BLOCKER · 0 MAJOR · 2 MINOR
· 4 NIT — no round 3 earned.** Scope checked by the reviewer first: no `Sync/`, no custody, the
one editor-seam file touched by comment only. Same-model round → the orchestrator arbitrates;
dispositions below, landed repo-first before the fix batch. The reviewer verified round 1's
fixes at the mechanism level (its clean bill: F1's `newPostInReading` rows match the old path
with the checks moved before the mint and the pin's teeth in `RF1.log`; F2's injection per
precedent, red in `RF2.log`, the Debug domain clean after its own run; F5's re-runs postdate
the last code commit; F6 composes through the Domain helper over a store read on the same
`\.database`; its own 19/19 green run on HEAD; P1/S1 hold).

## FINDINGS × DISPOSITIONS

| # | Sev | Finding (mechanism in the reviewer's report, kept) | **Disposition** |
|---|---|---|---|
| R2-M1 | MINOR | The fix pass's LIVE STATUS rows contradict the tree (F1/F2 still "PENDING", F3/F7/F8 "NOT-STARTED", row Z claims all closed) — the RESUME RECORD a successor would redo work from; F3's her-bundle line still paraphrases the OLD advice; NOT DONE item (4) stale (F10 edited KnownIssues) | **CONFIRMED — record fixes** (flip the five rows with hashes; rewrite PROVISIONAL item 1 to the shipped keeps-its-notes wording; amend NOT DONE (4)) — the fix batch's, in its own record |
| R2-M2 | MINOR | The imported-road orphan (round 1's noticed item) left UNOWNED — and its cost premise is FALSE: `Operations.assertReadingAcceptsPosts` exists for exactly this (doc-quoted; a shipped caller already uses it), so `place`'s mint arm can refuse BEFORE minting with zero `Sources/` changes; red-on-old pin described (delete a quiet chapter, lock, restore → one Pool orphan today) | **CONFIRMED — FIX NOW** (the unowned-means-fix-now rule + the false premise falls): `assertReadingAcceptsPosts` before `importPost` in the mint arm, with the described red-on-old pin verified by revert |
| R2-N1 | NIT | The new `failureLine` arms put MAC-ONLY words on the PHONE's face (the shared home's own header rule; the phone has no cap/settings controls; the arms unpinned) | **CONFIRMED — FIX** (platform-neutral words — the reviewer's lines are right; both arms added to BOTH existing `failureLine` case lists) |
| R2-N2 | NIT | F6's nil-composition guard throws `markerMissing` — the wrong failure class name | **CONFIRMED — FIX** (a `displayedTakeNotInFan` case; the F12 face arm already covers it) |
| R2-N3 | NIT | #156's "no third road without faking rows" OVERSTATES: a real third road exists (the last stamp-writing op on the book clock → real tray + bottom sort) at the price of self-contradicting dates (an 1886 savepoint after 2026 deletions) | **CONFIRMED — FIX the #156 text: list (c) WITH its price** (her choice rests on the complete fork; no exclusion wording) |
| R2-N4 | NIT | Two comments state a FALSIFIED defaults-domain fact (Debug and Release domains are separate — bundle ids differ, verified read-only); + `SeededBookRestore`'s header still lists two books | **CONFIRMED — FIX the comments to the verified fact** (F2's severity stands — the leak was inert for exactly this reason, now stated truly) |

**Close shape:** all six are small and none is a new BLOCKER/MAJOR — the fix batch lands in the
resumed U6 session; the orchestrator VERIFIES the batch directly (diffs + the touched suites)
and closes the round at adjudication (the 18l-b U4 precedent: R2 verified + NITs dispositioned,
no round 3 without a new B/M). Round cap status: 2 of 3.
