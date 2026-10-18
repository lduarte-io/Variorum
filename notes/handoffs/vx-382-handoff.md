# VX-382 — Run: Book view doors & reds — author handoff

**STATUS: DRAFT with PENDING slots (the window is running; final at the merge).**

## Her checklist (the morning read)

1. **The ratify bundle is QUESTIONS #PENDING(number)** — nine items, each with options: the two U1a rulings (the
   book records your caret into the note's one memory; every book door forces Write), the box door's face, the ⑂N
   badge, the sheet's release behavior, the fold control's shifts, the chapter-⠿ call (R-U2-A2 — with option (c),
   making the bars unmistakably the chapters', as your taste alternative), the badge-gap taste note, VX-77's
   dismissal story, and the ladder's two record-only nits.
2. **One minute in the app, if you like:** open a book, click into a note, press the box's "open ↗" — you should
   land in Write at your paragraph. Index: fanned blocks wear ⑂N; click one.
3. **VX-77 is closed as hollow** — the OutlineRoom red was the test host rendering dark (a walker left the dev
   domain's appearance on dark in October's first week). The three luminance pins are now appearance-proof. No
   product change. The ticket comment has the whole story.
4. **Release:** this run's section is in ReleaseNotes-0.9.8.md (nine book bullets, your register). PENDING(whether
   this run minted 0.9.8 or merged before VX-348 — the coordinator's last-merger rule).
5. **Tickets minted at the closeout** (triaged, listed below) — nothing needs you tonight; the two Suspected bugs
   wait for your word on priority.

## The completed block (her format — the overnight mandate's deliverable)

**Part B — VX-382 Run: Book view doors & reds** (CLOSED 2026-10-18, PR #PENDING, merge PENDING(sha))
- [x] VX-303 Book's "open ↗" breaks the deep-link rule — every book open door (five doors, one road) lands in
  Write at her block with her caret's offset; "edit here" rides the same place; every door forces Write even with
  nothing live (R-U1a-2). Verified: red-on-old ×3 families + 2 guard probes, batch 1590/259, the U1 walk.
- [x] VX-304 "Open in Write" door in the left note box + Index takes — the box door in every book mode, ⑂N badges
  on Index blocks, the in-place Takes sheet (pending typing written first, the live pane released), Outline→Index
  carries the live block at her caret (finding D-2 found, fixed, class-swept). Verified: batch 1998/332 + the
  64-suite D-2 verify, the U1 walk both voices.
- [x] VX-291 Book Outline ▸ target — 22-pt target, voiced hover, ▸/▾ one control, Index's chapter fold in the same
  pass (P-U2-1); the walk found the overhang swallowing clicks (W-1) — fixed so the button's own frame IS the
  target, pinned by a real click.
- [x] VX-21 Book Panel grips under a derived sort — the panel's chapter ⠿ draws under manual order only. The
  premise corrected along the way: the panel has only chapter grips; your Journal's bars were chapter ⠿s (the
  chapter's drag still works grip-less and via its menu). Options (b)/(c) in the bundle.
- [x] VX-69 The order popover takes Escape (quick entry keeps its text; the census float untouched).
- [x] VX-77 Index chapter panel "clips at the 240-pt floor" — DISMISSED AS HOLLOW: the red was the dark test host,
  proven both ways in one window; the three luminance scans now pin .aqua (test-only), ending the class.
- [x] VX-115 BookCollectingDoorsTests stale pin — reads the gear's act as declared (contains), green.
- **Found and fixed during the run (not members):** D-2 (the departing Outline ate the mode-switch's block
  landing) · W-1 (the fold target's overhang took hover but dropped clicks) · ladder R1-2 (a click into a book
  note now counts as her place for "edit here" and the carry) · PENDING(R1-1 verdict) · PENDING(R1-7 verdict).
- **Minted during the run:** PENDING(ticket ids) — the flushNow in-flight-write window (the shared helper class,
  from ladder R1-3) · WriteTakesPanel's shared-home move (ladder R1-6, Debt) · the Book Panel Close dead-clicks
  after Settings (Terminal, once, Suspected) · the VariorumMCPTests harness time-limit flake (load class).

## What shipped (the mechanism map, for a fresh session)

- ONE landing road: `BookOpenDoor.Landing` (note, block, offset, find, mode) → `onOpenSearchHit` → `RootView.open`
  → `ShellRouter.adopt(landing:offset:)` (+ `ModeLanding`) → `PostDetailView.jump`/`initialMode`. No second
  authority; VX-360's seam touched, not fixed (where a landing can still be lost is §U1a RECORD).
- The place memory: `CommandRouter.noteFocusedBlock(remembersOtherNotes:)` — a non-active note's report feeds the
  note's ONE memory; mount placements bracketed (`duringCaretPlacement`); the Index pane filters its going-live;
  a CLICK-arrival counts as hers (ladder R1-2). The Takes board deliberately does not opt in (VX-300).
- The records: `notes/plans/fixes/vx-382-book-view-doors.md` (the run) ·
  `notes/plans/fixes/vx-382-ladder-round-1.md` (findings, dispositions, the fix leg) — both READ IN FULL by any
  resuming session.

## Finals — PENDING (the ladder window's counts, then the merge)

## Filed tickets, grouped by priority — PENDING (minted at the closeout)
