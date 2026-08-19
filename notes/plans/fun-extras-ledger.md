# Fun extras — the delight ledger

**Status: created 2026-08-19.** A home for small for-fun features the
author names in passing, so they are never lost and never mistaken for
tech debt (KnownIssues' owner rule does not apply — these are wishes,
not obligations). Each item rides a phase when she says so at a kickoff;
nothing here is scheduled by existing.

## F1 — Words-per-minute faces (author, 2026-08-19, verbatim)

> "had this kinda random feature idea … just a little for fun thing I'd
> like having: variorum extra feature: show the words per minute that
> you're currently typing at and show the lifetime words per minute that
> you've typed at."

Assessment sketch (from the same conversation, so the pickup phase
starts warm):

- **The live half is nearly free.** The editor already reports per-edit
  char deltas (the churn plumbing); a rolling window (~10–60 s) over
  insertions gives live WPM with zero new storage — session UI state, a
  small chrome face.
- **The lifetime half is the design question.** It needs two persisted
  counters — words typed and ACTIVE-TYPING seconds — and "active typing
  time" must be defined honestly (accumulate only inside typing bursts,
  e.g. inter-keystroke gap under ~5 s; never wall-clock-since-open). That
  definition is a pure Domain function with tests — exactly the house
  style.
- **Open calls for whoever builds it:** the typing-test convention
  (5 chars = 1 word) vs real word boundaries; per-device/local-only vs
  synced (lean LOCAL-ONLY — typing speed is device-truth, phone ≠ Mac;
  if ever synced, counters are the merge matrix's harmless-drift class,
  like churn); a reset button (a lifetime stat should be hers to zero);
  where the faces live (editor chrome vs a stats corner).
- No schema if local-only; if the counters ever join the synced
  `setting` table they are numeric — inside the 14b "enum semantics, no
  prose" column fence — but local-only avoids the question entirely.
