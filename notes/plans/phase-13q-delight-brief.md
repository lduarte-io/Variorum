# Phase 13q — Delight (BRIEF)

**Status: BRIEF ONLY — created 2026-08-19, the same author conversation
that created the row.** Her instruction: "note all these ideas down in
the 13q phase please. you can add that whole message in there." So this
file holds the phase's shape AND the full conversation record verbatim.
Cast and scope decided at her kickoff, as always; the design sitting
rules everything below the two ruled features.

## The ruled scope (hers, 2026-08-19)

1. **The WPM faces.** Live WPM (a rolling window over the churn
   plumbing's per-edit deltas — session UI state, nearly free) and
   lifetime WPM with her refinements: **REAL words, Monkeytype-style**
   ("i like real words like are used in monkey type" — never the
   5-chars convention), and the face **shows the denominator** ("show
   you over how many words it is true for"). Storage: a tiny LOCAL-ONLY
   stats store (real words typed · active-typing seconds; gross-not-net
   lean — a typing stat, not a document stat) — NO schema lockstep.
   "Active typing time" is a pure Domain function with tests.
2. **The pixel pet companion.** Her words: "a cute little pixel pet
   that hangs out in the sidebar or walks along the bottom and that has
   a text bubble giving out encouragement. maybe different animals with
   different personalities that you can choose in settings." Her thesis:
   "i feel like cute little details are what drive a lot of app
   downloads even more than features."

**The floated candidates (Fable, unchosen — the sitting weighs them)**
are listed in `notes/plans/fun-extras-ledger.md` and in the record
below: the revision-story recap ("Variorum Wrapped") · on-this-day ·
pet-reacts-to-events · block birthdays · milestone moments · typewriter
sounds · seasonal/unlockable icons.

## Design-sitting knots

- Art direction and WHO DRAWS THE ASSETS — the phase's one real cost.
- Personality voice: encouragement must fit the calm-default soul —
  a companion, never a nag; always dismissible; off-able entirely.
- **P3 discipline binds:** the pet is chrome and must provably cost
  zero keystroke latency — it never wakes the text layout, pauses
  politely under load, stays battery-polite. A delight feature that
  made typing stutter would betray the app's first principle; a
  P1-style perf pin is part of the deliverable.
- WPM details: gross-vs-net confirmed at the sitting; a reset button
  (a lifetime stat is hers to zero); where the faces live (editor
  chrome vs a stats corner).
- Mobile: whether the pet and faces cross to the phone rides the
  parity ledger at closeout, like everything.

## The conversation record (2026-08-19, verbatim — the message she asked preserved)

> **13q — Delight — is on the master plan** (committed, `62d35a6`),
> carrying both ideas with your refinements. Point by point:
>
> **Lifetime WPM, refined.** Real words, Monkeytype-style, is now the
> recorded rule — no 5-chars convention — and the face shows its
> denominator ("62 WPM · over 148,203 words"), which I think is the
> detail that makes the stat trustworthy instead of decorative. On
> "what kind of table": almost none. Two counters — real words typed
> and active-typing seconds — in a tiny *local-only* stats store, which
> means no schema lockstep event at all (the mirror never hears about
> it). Real-word counting rides the word-count machinery that's existed
> since 9d, and the one honest design object is the "active typing
> time" definition (count only inside bursts, never wall-clock) — a
> pure Domain function with tests, this codebase's favorite food. I
> recorded a gross-not-net lean too: deleting a sentence shouldn't
> subtract from words you genuinely typed — it's a typing stat, not a
> document stat.
>
> **The pixel pet — I think you're right, and the evidence agrees with
> you.** Duolingo's owl and Finch's little bird are arguably those
> apps' most load-bearing features; "cute details drive downloads" is a
> real thesis, not a frivolous one. The row records the design knots
> for the sitting: art direction and *who draws the assets* (genuinely
> the phase's biggest cost — everything else is cheap), personality
> voice (encouragement has to fit the calm-default soul — a companion,
> never a nag, always dismissible), and one engineering line I pinned
> into the verification cell: **the pet is chrome and must provably
> cost zero keystroke latency** — it never wakes the text layout, it
> politely pauses under load. A delight feature that made typing
> stutter would be the app betraying its own first principle, so that
> gets a P1-style perf pin like everything else.
>
> **My ideas** — recorded as unchosen candidates in the fun-extras
> ledger for the 13q sitting to weigh:
>
> - **The revision-story recap ("Variorum Wrapped")** — my favorite,
>   because it's the one *only your app can build*: yearly or monthly
>   stats where the interesting numbers come from the model itself —
>   "your most agonized-over paragraph" (most takes and commits), the
>   fan that grew largest, the most-divided chapter. Every other app
>   can count words; nobody else knows your revision story. And it's
>   shareable, which serves your downloads thesis directly.
> - **"On this day"** — last year's journal entry for today, surfaced
>   gently. Day One's most-loved feature, and `entry_date` makes it a
>   trivial query here.
> - **Pet-reacts-to-writing-events** — the pet celebrates a ⌘S
>   savepoint, dozes when you're idle, perks up during a fast burst
>   (the live-WPM window literally feeding its animation). Your two 13q
>   ideas holding hands.
> - **Block birthdays** — "born 2026-03-14 · lived through 9 takes" as
>   hover lore on the History face. Tiny, pure variorum-soul.
> - **Milestone moments** — a quiet chime and a pet bubble at the 100th
>   entry or 10k words in a book; calm-default, never a takeover.
> - **Optional typewriter sounds** — off by default, perennial
>   writing-app favorite, pairs naturally with the WPM face.
> - **Seasonal or unlockable app icons** — cheap, loved, zero risk.
>
> The family now runs 13b–13q. For what it's worth, I'd bet the
> finished 13q is the phase strangers mention first in reviews — and
> the Wrapped recap is the one they screenshot.

## References

`notes/plans/fun-extras-ledger.md` (F1/F2 + the unchosen candidates) ·
the master plan's 13q row · the 9d word-count machinery (real-word
counting's existing home) · `notes/MobileSoul.md` (if anything crosses
to the phone).
