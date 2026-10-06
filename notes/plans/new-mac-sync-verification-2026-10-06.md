# The new Mac's 0.9.2 sign-in — the seeded-furniture fold's FIRST LIVE RUN (verification doc, written 2026-10-06 by the 17y/librarywalkpolish orchestrator; self-contained for a fresh session)

> **Who reads this:** the fresh session the author kicks off to verify her new-Mac install.
> You are OBSERVATIONAL: she drives the GUI; you direct the checks, judge the outcomes
> against this doc, and write up anything surprising. READ-ONLY toward her store throughout
> — no store edits, no "helpful" cleanup, no credentials work. Tombstones and ids are the
> diagnosis; a hand-fix destroys the evidence.

## 1. What this is a test of

17y's B-DEDUPE built the **seeded-furniture pairwise fold** (`Sync/SeededFurnitureDedupe`):
when a fresh install's starter furniture meets the account's own copies at sign-in, each
pair that is STILL THE SEED'S OWN WORK (content-identical, never engaged by her) folds to
one — smallest id keeps, the loser tombstones; **her engagement always keeps both; any
doubt keeps both**. The acceptance was pinned against the REAL seed (the drift guard
`TutorialFurnitureFoldTests` + the shipped-shape core fold) and the whole pass was
Fable-laddered. Her new-Mac install is the first LIVE account to walk the road — the bed
named in the records since the night it was built. Deep records: the binding design
`notes/plans/17y-bdedupe-design-memo.md` · the ladder `notes/plans/17y-bdedupe-ladder-
round1.md` · the rulings R-17y-5/8 in `notes/plans/17y-sitting-rulings-2026-10-05.md` ·
QUESTIONS #186 · the B-DEDUPE RECORD in `notes/plans/phase-17-standing-fixes.md`.

## 2. The ordering that makes the test valid (already sequenced; verify before judging)

1. **0.9.2 is RELEASED and the new Mac installed it from the website** (a 0.9.1 first
   launch would seed Jekyll and pollute the bed — she deliberately waited).
2. **Her MAIN store's field guide was RE-SEEDED at the arc's close** (Help ▸ Restore
   Tutorial…, behind the A1 backup rail) BEFORE the new Mac signed in — this is what makes
   the account's guide pristine-of-the-current-seeder, so the fold can read both copies as
   the seed's own. If the re-seed hasn't happened yet, the GUIDE pair will keep both BY
   DESIGN (not a bug) — check the close record before flagging.
3. **First launch, then sign-in, then LET SYNC SETTLE** a few minutes WITHOUT touching any
   seeded object. The fold runs on pull occasions after the arriving batch settles (the F2
   quiescence arms + a one-shot deferral marker), so a brief window where doubles are
   VISIBLE is expected — they fold on the next pull after quiescence. Touching a seeded
   object during the window is the one known race (#186(g)) and also legitimately converts
   a foldable copy into an engaged keep-both.

## 3. Expected outcome per object (the Home wing, after settle + a second pull)

| Object | Expected | Why |
|---|---|---|
| The field guide (book + its lessons) | EXACTLY ONE | the book-grain fold; guide identity carries word target, the sealed lesson, the seed's comments |
| The tutorial scraps pool | ONE | the pool grain |
| The guide's twin note | ONE (inside the guide's own fold if membered) | the note grain |
| classics · starred notes · Quicknotes (gatherings) | ONE EACH — unless her account copy was ever renamed/re-ruled/shelved/starred-changed/outflowed/finished/sealed/owned/archived (then TWO is CORRECT: engagement keeps both) | the gathering grain judges name + rule by TAG PATH + no engagement |
| The first quick note ("a first quick note") | ONE — unless her copy was edited/tagged-beyond-seed/commented | the note grain |
| The Welcome shelf | ONE | the older R5 adopt-by-role keeper |
| Sherlock + Encryption Explained | ONE each, Sherlock's arrangement INTACT (#classics tags, OWNED, Welcome placement) | the older sample-library pristine dedupe; both sides Mac-arranged here |
| Jekyll | PRESENT — exactly her account's existing copy, nothing seeded fresh | R-17y-8: fresh stores don't seed it; existing libraries keep theirs; it syncs down normally |
| Tags (`#classics`, the quicknote tag, the guide's tag) | one live row per path per wing | the `tag.path` fold |
| The Quicknotes designation + the daily Journal | the quicknote pad files correctly; ⌘J works; designations point at LIVE keepers | the fold re-points a loser's designation to the keeper (§20's letter) |

**Functional spot-checks after the counts:** file one quicknote (lands in the one
Quicknotes gathering); press ⌘J (the one Journal behaves); open the field guide (lessons
read correctly, the "the seal" lesson sealed, the word target present on the guide book).

## 4. Deliberate KEEP-BOTH outcomes (correct behavior — do not flag as bugs)

Engagement ALWAYS keeps both: a rename, an edit, a re-rule, re-tag, shelf move, star
change, outflow/dial change, finish/seal/own/archive on HER account's copy means that pair
holds two — the design errs toward keeping her work, every time. A half-dead copy reads
ENGAGED (conservative). If she can say "I never touched that one" and it still kept both
past a second pull, THAT is a finding.

## 5. Known residual classes (watch, with low expectation)

- **#186(g), the crossing race:** her engagement racing an in-flight retirement, a
  minutes-wide window — avoided by the don't-touch-during-settle rule; recorded as HERS to
  escalate into a full defense.
- **VR-109 (KnownIssues):** an UNARRANGED sample copy meeting an arranged one can strip
  demo state if the raw copy wins the id toss — needs a RAW seeder (a phone seed or pre-U7
  build). Both sides here are 0.9.2-Mac-arranged, so it should not trip; if classics shows
  Sherlock-less anyway, that's this class — evidence, not panic.
- A fold loser's `version_of` edge may dangle (#186(h)) — lineage doors tolerate it.

## 6. On any surprise — the evidence to gather (change nothing)

Which object (kind + title) · both copies' visible state (which shows engagement, what
differs) · whether a second manual sync pull folds it · the Settings sync state ·
timestamps if visible · screenshots. Write it up in the session and report back to the
author; the orchestrator's records (above) own the diagnosis. NO store edits, no deletes,
no "cleanup" — the duplicate IS the evidence.

## 7. What a clean run answers (the records it closes)

- KnownIssues row "a fresh SIGNED-OUT library… keeps the UNJUDGED seeded objects TWICE"
  (the live confirmation of its close; the acceptance already held against the real seed).
- QUESTIONS #186(b) (her Monday/new-Mac bed named at the build) and #183(c) (alternative
  (i) proven live). GitHub: VR-111 can close on the result.

## 8. The kickoff prompt (paste-ready; the author's copy also lives in the session that wrote this doc)

> You are verifying the FIRST LIVE RUN of Variorum's seeded-furniture fold — my new-Mac
> 0.9.2 install signing into my account. Read FIRST and IN FULL:
> `notes/plans/new-mac-sync-verification-2026-10-06.md` (repo `~/dev/variorum`; if this
> machine has no clone, say so and I'll paste it). It carries what this tests, the expected
> per-object outcomes, the deliberate keep-both cases, the known residuals, the evidence
> rules, and the records a clean run closes. The short shape: fresh 0.9.2 install (no
> Jekyll seeded), signed in, sync settled a few minutes untouched. Walk me through the §3
> table's counts and the functional spot-checks; judge outcomes against §4 before calling
> anything a bug; on any surprise follow §6 exactly — read-only toward my store, I drive
> the GUI, the duplicate is the evidence. Report the result against §7's records.
