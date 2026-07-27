# Phase 13c — handoff (written 2026-07-27, at the phase closeout)

**Self-contained by design.** A fresh session can answer questions about
this phase from this file plus
`notes/plans/phase-13c-book-forms-and-conversions.md` (the one running
record: kickoff rulings K1–K6, the 46-row intake ledger, batch records
1A–1E and 1F/2A–2E, the Stage 1 three-round ladder, the K6 review +
fix pass, and every adjudication). Nothing here depends on any session.

**Status: the phase is CLOSED.** Both stages shipped, reviewed, and
**installed** — `/Applications/Variorum.app` was refreshed at 15:04
from the final reviewed build, behind a fresh WAL-safe backup
(`variorum-backup-2026-07-27-210243.sqlite`, `integrity_check` ok).
**No schema change all phase** — your mirror stays at lockstep marker 4
and your phone needs nothing.

---

## YOUR CHECKLIST

- [ ] **1. Open the app.** Everything below is in it, including the
  take-card gap fix you watched land mid-day (your card heals on its
  first layout pass).
- [ ] **2. Walk the three book modes on a real book** — the picker is
  now **Outline · Book · Read**:
  - **Outline** — the book-level WRITE mode you asked for (A39):
    Write's own measure, chapter headings inline, collapsible posts,
    fully editable. Posts open EXPANDED by default — that reverses your
    R106 for this surface and is **#43(a)**, the first thing to react
    to.
  - **Book** — the two-up spread: two whole posts side by side, each
    its own scroll; ◀ ▶ turns the leaf two at a time, ◁ ▷ nudges by one
    (your "half arrow"); each page edits as the takes stack or Write
    (A44).
  - **Read** — Scroll, plus **Pages**: true fixed-leaf two-page
    pagination, read-only as you ruled (A43). Your reading position is
    anchored to the POST, not a page number, so estimate corrections
    and membership changes can never move the page under you.
- [ ] **3. Try the conversion**: a smart book's navigator now offers
  "+ new chapter" → convert; the shelf has "Convert to a Hand-Shaped
  Book…". It freezes exactly the order you're LOOKING at (including a
  view-order override) and offers a fresh smart collector.
- [ ] **4. Run "Restore Tutorial" from ⌘K** (it asks before replacing).
  The field guide's books lesson was revised this phase, so your seeded
  copy is one revision stale. A backup was already taken today.
- [ ] **5. Walk the ratify list — `notes/QUESTIONS.md` #29–#47.** The
  ones that genuinely change things:
  - **#34** — backspace between two TEXTED blocks: merge, or keep
    refusing? (Product; recommendation on file: merge when neither has
    takes. Note: our merge joins with a single space and mints lineage.)
  - **#39** — the phantom fix: keep/kill/tune, now that you've felt it.
  - **#40** — a NAMED or CALLOUT empty block still deletes on backspace.
  - **#41** — divide-in-Takes acts by carrying you to Write; native is
    13d's, promotable to its top.
  - **#43(a)** — Outline's posts-open default (the R106 reversal).
  - **#44(c)/#45(c)** — the jump scrubber: removed on Book, kept on
    Read — both answers are live in the app for you to compare; one
    ruling unifies them.
  - **#45(b)** — every post starts a new page in Read's Pages (the
    stable-address consequence).
  - **#46** — the conversion memo's five rulings (built to shape A).
  - **#47(c)** — Compare's related-only toggle defaults OFF; your
    "would make the pane feel more usable" may mean you want it ON.
- [ ] **6. Pick what's next.** 13d (refusal/ergonomics floor — plan
  ready: `notes/plans/phase-13d-refusal-ergonomics-floor.md`) or jump
  to your K4 big rocks (13f workspace / 13g formatting). Cast at
  kickoff, as always.

---

## What shipped, and how much to trust it

**Counts — verified by the orchestrator's own runs at every batch, not
taken on report:** core **882/100** · Mac **782/134** · mobile **14/4**
(phase open: 817/96 · 652/123 · 11/4). The tutorial spine ran green at
every batch (P-6). Zero sync-engine lines touched all phase.

**Stage 1** (the friction list — built overnight by Opus, three-round
ladder, independently verified by a Fable session at your request):
backspace deletes empty blocks (with the authorization re-checked
INSIDE the delete's own transaction — the ladder's signature find),
the delete door, redo (⇧⌥⌘Z), callouts in Takes/Lenses/Compare (⌥⌘C),
the callout colour and jumping-editor geometry fixes, the Fragments
daily-book repair (your two orphaned days now shelve on their next
landing), the bridge starvation fix, and the phantom fix behind its
kill switch (Settings → Appearance → Editor).

**Stage 2** (the books — Opus implementers under your K6 cast, one
Fable cold review): everything in checklist items 2–3, plus the
take-card gap fix (1F) and Compare's related-only toggle. The review
found two real MAJORs — the page address was an index rather than an
identity (a mid-read membership change would have silently swapped the
page under you), and the conversion froze the STORED order rather than
the order on screen — both fixed by the reviewer with pins that fail
on the pre-fix code, both re-verified by the orchestrator.

**A31, worth knowing:** "see a book by an attribute" had existed in the
model since Phase 2 — but its only door died, unreferenced, in Phase
13's IA rework, so the app had NO way to change a book's order at all
until now. It lives in the book navigator; "Save as This Book's Order"
adopts a browsed order. Named multi-saved orders would need schema and
are recorded for you, not built.

## Honestly recorded residuals (nothing hidden in these)

- **The 1F birth is unidentified**: what created the stale tall frame
  was hunted across two harnesses and a quantified candidate table and
  did not reproduce; the fix makes any birth self-heal within one
  layout pass regardless. The cold reviewer independently tried to
  construct it and also could not.
- **K6f**: chapter renames / remote edits mid-read render stale in
  Read's Pages until remount — a named staleness class, read-only, no
  data hazard.
- **K7**: a speculative token-leak concern with no traceable mechanism
  (the hallucination guard forbids fixing it); the one-line guard is
  named in the record if it ever fires.
- The **Design & UI review row** still owns the visual sweep: Stage 2's
  surfaces shipped machine-verified with per-batch visual loops only.

## What was done to your machine

Three `/Applications` refreshes (Stage 1's overnight one; the pinned
1F build you opened a window for; the end-of-phase one), each behind a
fresh WAL-safe backup at a verified zero-instance window. Your store
was otherwise read-only to the whole phase. Nothing was pushed.
