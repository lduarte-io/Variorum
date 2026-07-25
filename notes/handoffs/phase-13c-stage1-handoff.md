# Phase 13c — Stage 1 handoff (written 2026-07-26, end of the overnight run)

**Self-contained by design.** A fresh session can answer questions about
this run from this file plus
`notes/plans/phase-13c-book-forms-and-conversions.md`. Nothing here
depends on the session that did the work.

**Status: the phase is MID-FLIGHT, not finished.** Stage 1 (your friction
list) is built, three-round-laddered, and **installed**. Stage 2 (the
book work — the phase's committed scope) has complete briefs and **no
implementation**.

---

## YOUR CHECKLIST

- [ ] **1. Open the app.** It was refreshed from a green Release build at
  07:31 with zero instances running. Everything below is in it.
- [ ] **2. Try the five things you reported.** Backspace an empty block
  (including one at the very start of a post) · ⇧⌥⌘Z to redo a
  structural undo · a callout in Takes/Lenses/Compare, or ⌥⌘C · the
  callout colour on a block (it should hug the text now, not bleed under
  it) · scroll past a long block and see whether the phantom gap is gone.
- [ ] **3. Check the Fragments repair.** Your 2026-07-11 and 2026-07-16
  journal entries were confirmed orphaned — landed from Fragments, in no
  book. The fix repairs them the next time a landing writes those days.
  If they are still in the Pool and it bothers you, opening ⌘J on that
  date shelves them immediately.
- [ ] **4. Walk the ratify list — `notes/QUESTIONS.md` #29–#42.** Fourteen
  open items. The four that actually change things are flagged below.
- [ ] **5. Decide what's next**: Stage 2 (the book work, briefs ready) or
  13d (the rest of the friction floor). Either is a clean start.

---

## What shipped, and how much to trust it

**Counts, all verified by my own runs rather than taken on report:**

| | phase open | now |
|---|---|---|
| core | 817 / 96 | **858 / 98** |
| Mac | 652 / 123 | **733 / 129** |
| mobile | 11 / 4 | **14 / 4** |

**Your reported bugs, with what they actually were:**

- **Callout colour "spreading underneath"** — real, fixed. TextKit folds
  a paragraph's trailing gap *into* the block's frame, so every
  decoration drew a box one gap too tall and consecutive blocks touched
  with zero space between them. Your diagnosis (*"we haven't figured out
  how to color blocks with their weird spacing"*) was right to the pixel.
  **A finding rode along: R17 — the white-gap rule you ratified at the
  design sittings — had been dead code since it shipped**, always handed
  a gap of zero and always returning zero padding. It works now.
- **The editor jumping on tall blocks** — two real bugs. A block taller
  than the screen collapsed to one anchor point (a 2,251 pt leap on
  resize), and underneath it a coordinate-space error named the block
  *below* the right one — invisible because the jump code carried the
  *identical* error and the two cancelled. A test had been passing for
  the wrong reason since Phase 7.
- **The phantom whitespace** — **not our bug.** TextKit guesses the
  height of text it hasn't laid out: one 3,000-word block reports
  4,964 pt guessed vs 4,597 pt real. No API corrects it. **But a fix
  exists and shipped** (below).
- **"Clicking does nothing"** — **investigated and dismissed, correctly.**
  The click *does* reach the editor and your cursor *does* move — to the
  end of your text, because there is nothing in the phantom to put a
  cursor in. Five candidate causes were traced and refuted. There was
  something dead to fix nearby (a 6 pt strip) and it was proven to be
  **AppKit's own** and deliberately left alone rather than fixed-and-credited.
- **Fragments landing in the Pool** — real, fixed, **and confirmed in
  your actual store**: your 2026-07-11 entry was created 17 seconds after
  the Fragments row it landed from and carries no book membership row at
  all. The bridge called the "create the entry" half of the daily door
  and never the "put it in the book" half.
- **"The bridge doesn't refresh often enough"** — it was the sign-out.
  With sync signed out there was no scheduler, so **the bridge ran once
  per launch for five days** while your Fragments session stayed valid.
  Fixed structurally (the same starvation returns on any expired
  session), plus the status row that said "Bridged 11:04 PM" for all five
  of those days.
- **Backspace / delete / redo** — all built. Redo is ⇧⌥⌘Z, structural
  only, never interleaved with text undo.
- **Callouts outside Write** — built: Takes, Lenses, Compare, plus ⌥⌘C.

**The phantom fix, and why it needs your ruling.** It lays out just the
one long block you're looking at — bounded to that block, never the
document. Measured: ~1 ms per 1,000 words, and the per-word cost *drops*
as blocks get bigger. It carries a size cap, a proof it runs at most once
per block per width, and **a kill switch** (Settings → Appearance →
Editor). It is **PROVISIONAL** precisely so you can rule on it having
felt it. **QUESTIONS #39.**

---

## The four ratify items that actually change something

1. **#34 — backspace at a seam between two blocks that BOTH have text
   does nothing today.** In every ordinary editor that keystroke joins
   the paragraphs. It invokes your own principle back at you: *"if your
   text looks like basic text with no variants, it should behave like
   basic text."* My recommendation: merge when neither block has takes,
   speak when either does. **Not built — product behaviour is yours.**
2. **#39 — the phantom fix's posture.** Keep it, or switch it off.
3. **#41 — "divide in takes mode" was deferred to 13d, and the deferral
   corrected me.** My ledger said there is no divide in Takes. **False** —
   the door flushes, carries your caret, visibly switches you to Write,
   and does the real divide. What you want is for it to act *without
   leaving Takes*, which needs machinery Takes doesn't have plus the
   multi-take ceremony being mountable outside the Write editor. Lift it
   to the top of 13d if it hurts more than that sizing suggests.
4. **#40 — a *named* or *callout* empty block still deletes on
   backspace.** The line drawn was "does deleting make it unrecoverable"
   rather than "did you author it" — a name and a callout are columns on
   the block row that undo restores, and the tray lists the block *by its
   name*. The clincher: block tags cascade too, so guarding "anything
   attached to a block" would shrink the carve until it never fires.

The rest (#29–#33, #35–#38, #42) are recorded PROVISIONALs and bundled
calls; each has options and a recommendation.

---

## What the review ladder found — worth knowing

Three rounds ran, the full cap. **The same bug class was found three
times at three different depths**, which is the most useful thing in this
record:

1. **Round 1:** the empty-block carve fired on blocks whose *archived
   takes* held prose — "there is no text to lose" was false.
2. **Round 2:** it fired on blocks holding *comments* — same sentence,
   one guard over. And because deleted comments are found *by block*, and
   the block was now only in the tray, AppSpec §7's ratified "deleted
   comments stay visible and resurrectable — never skimpy" quietly
   stopped holding.
3. **Round 3:** the guards were reading a projection **the editor
   deliberately holds stale while you type**, and only the text was
   re-checked at deletion. **The tell: every test protecting that carve
   called a manual "reload" step that production doesn't** — they were
   green because they rehearsed a state the real app never reaches.

So the third fix stopped adding guards and moved the check **inside the
database transaction that does the deleting**, where it cannot be read
stale by construction.

**Two failures were mine and are on the record:** two items you ruled
into the friction batch (A9 and A13(a)) were never briefed, and I
declared Stage 1 complete anyway — round 2 caught it; and the one
canonical-*vision* change in this phase (mobile pillar 8) was recorded
without quoting you, which round 3 caught. Your words are now beside it.

---

## What did NOT happen

- **Stage 2 — the phase's entire committed scope** — is unbuilt: the
  uniform-page book view, the Outline-becomes-a-writing-surface work, the
  Book spread, Read's true pagination, the smart→curated conversion,
  Compare's related-blocks-only setting, book-order-as-a-lens. **All five
  batch briefs are written** in the plan file, ready to hand to a fresh
  session.
- **A9** (divide without leaving Takes) — deferred to 13d with its
  reason, #41.
- **The C3 block-extent memo** (`notes/plans/phase-13c-memo-block-extent.md`)
  needs your rulings on Parts 1 and 3.

---

## What I did to your machine

- **Refreshed `/Applications/Variorum.app`** from a green Release build —
  zero instances verified at build *and* immediately before the copy;
  signature and Release identity confirmed. **No schema change this
  phase**, so nothing can outrun your deployed sync marker.
- **Took a WAL-safe backup first**:
  `Backups/variorum-backup-2026-07-25-133011.sqlite`, `integrity_check`
  ok. Your store was otherwise **read-only** to this entire run.
- **Ran `caffeinate -d` overnight** to hold the login session unlocked —
  the Mac test runner hangs under a locked session, which is exactly how
  13b's gate failed. It has been stopped.
- **Never** wrote to your live Fragments data (every bridge test ran
  against the fake server), quit any app instance, or pushed anything.
