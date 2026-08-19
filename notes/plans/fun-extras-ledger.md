# Fun extras — the delight ledger

**Status: created 2026-08-19.** A home for small for-fun features the
author names in passing, so they are never lost and never mistaken for
tech debt (KnownIssues' owner rule does not apply — these are wishes,
not obligations). Each item rides a phase when she says so at a kickoff;
nothing here is scheduled by existing.

## F1 — Words-per-minute faces (author, 2026-08-19, verbatim) — **SLOTTED: 13q** (same day)

Her refinements (later the same day): **real words, Monkeytype-style**
(never the 5-chars convention — her call, "i like real words like are
used in monkey type"), and the lifetime face **shows the denominator** —
"show you over how many words it is true for" (e.g. "62 WPM · over
148,203 words"). Table answer: a tiny LOCAL-ONLY stats store (two
counters), no schema lockstep; real-word counting rides the existing
word-count machinery (per-block/selection counts shipped at 9d).



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

## F2 — The pixel pet companion (author, 2026-08-19, verbatim) — **SLOTTED: 13q** (same day)

> "another idea i had is a cute little pixel pet that hangs out in the
> sidebar or walks along the bottom and that has a text bubble giving
> out encouragement. maybe different animals with different
> personalities that you can choose in settings. i feel like cute little
> details are what drive a lot of app downloads even more than
> features."

The 13q row carries the design knots (art assets, personality voice vs
the calm-default soul, the P3 chrome discipline, pet-reacts-to-events).

## Floated candidates (Fable, 2026-08-19 — UNCHOSEN; the 13q sitting weighs them)

Offered when she asked "do you have any other ideas thus far?"; recorded
so they aren't lost, binding nothing:

- **The revision-story recap ("Variorum Wrapped").** A yearly/monthly
  recap face: words written, busiest day, longest streak — and the stats
  ONLY this app can compute, because only this app knows them: "your
  most agonized-over paragraph" (the block with most takes/commits),
  "this book's most-divided chapter," the fan that grew largest. Shareable
  by design (her downloads thesis, aimed); the data model already holds
  every number.
- **"On this day."** Last year's journal entry for today, surfaced
  gently (Day One's most-loved feature; `entry_date` makes it a trivial
  query).
- **The pet reacts to writing events.** Celebrates a ⌘S savepoint,
  dozes when idle, perks up during a fast burst (the live-WPM window
  feeding the animation — her two 13q ideas holding hands).
- **Block birthdays / hover lore.** "Born 2026-03-14 · lived through
  9 takes" on a block's History face — tiny, pure variorum-soul.
- **Milestone moments.** A quiet, tasteful celebration at round numbers
  (100th entry, 10k words in a book) — calm-default: a chime and a
  bubble, never a takeover.
- **Optional typewriter sounds.** Subtle, off by default (a perennial
  writing-app favorite; pairs naturally with the WPM face).
- **Seasonal/unlockable app icons.** Cheap, loved, zero product risk.
