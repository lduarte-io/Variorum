# Memo — block extent and decoration geometry in the editor (C3)

**Written:** 2026-07-25, Phase 13c Batch 1A.
**Status:** DRAFT for the author. Parts 1 and 3 need her rulings; Part 2
needs her to pick a posture. Nothing in Parts 2–3 is built.
**Why it exists:** the friction batch was told to trace before it fixed,
and to split what it found by what it actually *is*. Two of the three
things it found were mis-mappings, and they are fixed (commit `01e2602`).
The third is not a bug we can fix, and one design question is genuinely
open. Under the friction doctrine (P-5) that half becomes this memo
instead of a guessed number in the code.

---

## The short version

Three of your reports — the callout colour "spreading underneath",
paragraphs of empty space that vanish when you scroll onto them, and the
editor jumping when a block is taller than the screen — turned out to be
**three different problems that happened to look alike.**

- **The callout colour: a real bug, fixed.** Every decoration was drawing
  a box that was one paragraph-gap too tall, so it ran under the text and
  touched the next block. Your diagnosis — *"we haven't figured out how to
  color blocks with their weird spacing well"* — was exactly right.
- **The editor jumping: two real bugs, fixed.** A block taller than the
  screen made the app forget where you were reading, and a second, older
  error made it forget by one block even on short ones.
- **The phantom empty space: not our bug, and there is no fix.** It is
  TextKit 2 guessing the height of text it has not laid out yet. Apple has
  no way to correct the guess, and the only thing that would eliminate it
  is banned by the app's core performance rule. **Part 2 is your call
  about what we do instead.**

---

## Part 1 — What vertical space does a block own? (fixed; confirm the rule)

### The rule the fix now follows

**A block owns its text lines. The gap below it belongs to nobody.**

Some background you already ruled on, restated so this stands alone. Since
2026-07-12 there are two different kinds of vertical space between blocks:

- **Stored space** — blank lines you actually typed or pasted. These are
  real text (newlines are content), they export, they sync, and they round
  trip byte-for-byte. Not touched by any of this.
- **The uniform gap** — a small breathing space the app draws after *every*
  paragraph, stored nowhere. You made it deliberately per-paragraph rather
  than per-block-seam, so block boundaries stay invisible at rest. It is
  7 points in the Terminal voice, 8 in Study, and 29 when inline comments
  are switched on.

The bug: TextKit 2 hands us each paragraph's geometry with that gap baked
into the bottom of it. So when the app asked "where does this block end?",
the answer it got was *one gap too low* — every block's box ended exactly
where the next block's box began, with no space between them at all.

Everything that draws around a block inherited that:

| Decoration | What it did | What it does now |
|---|---|---|
| Callout frame | Colour ran 7 pt under the last line and touched the next block — **your report** | Hugs the text, leaves the white gap |
| Dotted seam | Sat on the next block's first line | Sits centred in the white gap |
| Editing indicator | Bottom-heavy | Hugs the text |
| Comment cards | Anchored a gap low | Anchored to the text |

There is a rule you already ratified (R17) that says a coloured block must
keep at least 6 points of plain background between it and its neighbours.
It was in the code the whole time and **could never fire** — it was always
being told the gap was zero, so it always returned "no padding". It works
now.

### What this makes visible, and what I need from you

Because the rule is "leave at least 6 points of plain background", and the
uniform gap is only 7 points, a callout now gets **half a point** of
padding around its text in the Terminal voice. It is a correct, tight box.
With inline comments on (29 pt gap) it gets the full 5 points and looks
airy.

- **Q1.** Is a tight callout box what you want at rest, or should coloured
  blocks push their neighbours apart a little so the colour has room?
  (Note this connects to something already on your list: **A23**, the
  setting for a paragraph-tall gap between blocks, owned by 13d. A larger
  uniform gap would give callouts more room automatically, with no special
  case.)
- **Q2.** The seam is now centred in the gap. Confirm that is what you
  want — the alternative is hugging the block above.

---

## Part 2 — The phantom empty space (no fix exists; pick a posture)

### What is actually happening

Your own test eliminated the obvious explanation, and you were right to:
you pasted a long message with **no whitespace at the end** and still got
an extreme gap. It is not stored text. Here is what it is.

TextKit 2 only lays out the text you can see. For everything else it
**guesses** the height. The guess is per-paragraph, and a Variorum block is
always its own paragraph — so **one very long block is one very large
guess.**

Measured, on a post of 60 blocks with one 3,000-word block in the middle:

| | Height of the long block | Total document |
|---|---|---|
| Sitting at the top (block not yet laid out) | **4,964 pt** *(guessed)* | 11,245 pt |
| After scrolling onto it | **4,597 pt** *(measured)* | 10,885 pt |

**367 points of text that does not exist** — about 21 blank lines — held by
one long block, and it disappears the moment you scroll onto it. That is
your report, in both halves: *"paragraphs of empty space"* and *"vanish on
scroll, return when you're more on top of it"*. Apple's own API confirms
the diagnosis: the framework reports each paragraph as either "estimated"
or "laid out", and the inflated number is exactly the "estimated" one.

Short blocks do this too, but they are individually small and their errors
mostly cancel. The size of the problem is set by **your single longest
block.**

### Why I am not fixing it

- **Apple provides no way to correct or supply the guess.** There is no
  API. This is confirmed both in Apple's documentation and by the
  maintainer of the main third-party TextKit 2 editor.
- **The one thing that would eliminate it — laying out the whole document
  up front — is banned by the app's founding performance rule** (cost must
  never scale with document size). It was measured during the Phase 6
  spike: 105 ms on a 50,000-word post, 408 ms at 200,000. That is the
  Apple Notes failure mode this app exists to refuse.
- Apple's own developer support states plainly that fluctuating estimated
  heights are expected and by design, and that a scrollbar reflects
  estimated size, not final size.

So the honest options are all about **living with it well**, not removing
it.

### Your options

**A. Do nothing; write it down.** It self-corrects as you read through a
post, and it only ever shows up under a very long block.
*Cost:* you keep seeing it. *Benefit:* zero risk, zero work.

**B. Quietly lay the document out in the background after a post has been
open and idle for a moment.** The phantom would settle within a second or
two of opening and then stay honest.
*Cost:* this is the P1 invariant traded for a cosmetic fix. On a very long
post it is real main-thread work — the app could hitch while it happens. It
would need a size ceiling and careful measurement, and it is the first
thing in this project that would deliberately do work proportional to
document size. **I do not recommend it without a hard cap** (for example:
only do it for posts under some measured size, never for the rest — which
means the problem persists exactly where it is worst).

**C. Treat it as a reason to keep blocks from getting enormous.** No code:
the error is concentrated in single giant blocks, so anything that
encourages a long paste to arrive as several blocks makes it smaller. Worth
knowing: a message pasted **with blank lines between its paragraphs**
already becomes several blocks (verified). A message pasted as one
unbroken run becomes one block, and that is the worst case.
*This is a question back to you:* when you saw the extreme gap, was the
pasted message one unbroken run of text, or did it have blank lines in it?

**D. Something at the bottom of the document specifically.** If the phantom
mostly bothers you as dead space at the *end* of a post, we could stop the
document from being scrollable past its last laid-out line. *Cost:* we do
not actually know the true height either, so this can just as easily cut
off real text. **I do not recommend it** — it trades a cosmetic problem for
a correctness one.

**My recommendation: A now, with C as the thing to keep in mind**, and B
kept on the shelf with its cost stated, only if it turns out to bother you
daily.

- **Q3.** Which posture?
- **Q4.** One thing I could not settle from your report: *"the empty space
  below isn't clickable as newlines"*. My reading is that you click into
  the phantom space, the caret lands at the end of the last block rather
  than where you clicked, and typing appends there instead of at the
  visible spot — which is exactly what phantom space would do. **Is that
  what you see?** If instead the click does nothing at all, that is a
  separate bug and I would go find it.

---

## Part 3 — Inline comments and the gap (open; nothing built)

You floated an idea in the same breath as the callout report:

> *"this also relates to how the gaps that happen when you have a comment
> inline has to eb fixed - representing it in the editor as a block or
> something? idk?"*

### Where things stand

An overlay cannot reserve vertical space in TextKit 2 — an overlay is drawn
*on top of* the layout, it cannot push it around. So when you turn inline
comments on, the app makes room by widening the uniform gap after **every**
paragraph by one comment-strip's height (22 pt). Every paragraph in the
post gets airier, whether or not it has a comment on it. That is the
honest mechanism, and it is why the whole document loosens up.

### The three ways forward

**A. Keep it (today's behaviour).** Comments on ⇒ a uniformly airier page.
*Good:* boundaries stay invisible — nobody can tell which blocks have
comments by looking at the spacing, which is the property you ruled for.
*Bad:* a post with two comments in it is airy everywhere.

**B. Make room only where a comment actually is.** Give just the commented
paragraphs extra space.
*Good:* no wasted air. *Bad:* **it makes commented blocks visually
identifiable from spacing alone** — the exact thing the uniform-gap rule
was designed to prevent. This is a real reversal of a decision you made
deliberately, not a tweak.
*Cost:* moderate. Achievable with per-paragraph spacing on the commented
paragraph only.

**C. Your idea — make the comment a real thing in the flow.** This is the
one to be careful about, and I want to be straight about the cost rather
than talk you out of it.

To make the text flow reserve space for a comment, the comment has to
*become text* — something in the editor's own character stream. And the
editor's character stream is the thing block identity rides on: every block
knows where it lives by exact character offsets, and that tiling invariant
is what makes fans, lineage, splits and merges work at all. It is named in
the spec as the single riskiest thing in the project. Putting anything into
that stream that is not a block's text means the editor's text and the
blocks' text no longer agree — and every structural operation would have to
learn to step around it.

*My honest read:* the goal ("comments should not make the whole page
airy") is achievable via **B** at a fraction of the risk. **C** is a
months-later, deliberate architecture decision, not a Phase 13c fix. If the
airiness is what bothers you, B is the conversation.

- **Q5.** A, B, or "leave it for now"? (If B: accept that commented blocks
  become identifiable by spacing.)

---

## What I need from you, in one list

| | Question | My recommendation |
|---|---|---|
| Q1 | Callouts at rest: tight box, or should coloured blocks get more room? | Leave tight for now; revisit with A23's gap setting in 13d |
| Q2 | Seam centred in the white gap — confirm | Confirm |
| Q3 | Phantom space posture: A do-nothing / B background layout / C block-size / D clamp | **A**, keeping C in mind; B only if it bothers you daily; not D |
| Q4 | "Not clickable as newlines" — is the caret landing at the end of the last block? | Need your answer; changes whether there is a fourth bug |
| Q5 | Inline comments: keep uniform airiness / room only where commented / rebuild as flow content | Keep for now, or B; **not C in this phase** |

---

## Appendix — the measurements behind this memo

All taken this batch, on macOS 26.4.1 / Xcode 26.3, in real windows.

- One-line paragraph, Terminal voice: 17 pt of text inside a **24 pt**
  reported frame. With inline comments on: 17 pt inside **46 pt**.
- Consecutive block frames pre-fix: gap **0.0 pt** at every boundary.
- Callout pre-fix: **0 pt** of plain background to the next block (R17
  requires ≥ 6).
- 60-block post with one 3,000-word block: long block reported **4,964 pt**
  while estimated, **4,597 pt** once laid out; document total **11,245 →
  10,885 pt**. Fragment state moves from `estimatedUsageBounds` to
  `layoutAvailable` at exactly that transition.
- The same post with **no** giant block: total wanders only 84 pt, and
  upward (converging), which is the benign direction the Phase 6 spike
  measured.
- A giant block sitting **alone** at the top of a post: **0 pt** of
  wander — it is laid out immediately, so it is never guessed.
- Scroll anchor pre-fix, inside a 6,127 pt block at y = 2,500: anchor
  resolved to the block's first character; restore landed at y = **225**.
- Paste of a three-paragraph message with blank lines between: **3 blocks**,
  trailing newline stored on the first two, none on the last — your "no
  whitespace at the end" observation confirmed exactly.
