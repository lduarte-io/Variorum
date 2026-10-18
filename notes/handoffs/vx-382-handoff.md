# VX-382 — Run: Book view doors & reds — author handoff

**CLOSED 2026-10-18, PR #172 merged to main. Self-contained: the run record is
`notes/plans/fixes/vx-382-book-view-doors.md`, the ladder's `notes/plans/fixes/vx-382-ladder-round-1.md`.**

## Her checklist (the morning read)

1. **The ratify bundle is QUESTIONS #232** — each item one line with its options: the two U1a rulings (the
   book records your caret into the note's one memory; every book door forces Write), the box door's face, the ⑂N
   badge, the sheet's release behavior, the fold control's shifts, the chapter-⠿ call (R-U2-A2 — with option (c),
   making the bars unmistakably the chapters', as your taste alternative), the badge-gap taste note, VX-77's
   dismissal story, and the ladder's two record-only nits.
2. **One minute in the app, if you like:** open a book, click into a note, press the box's "open ↗" — you should
   land in Write at your paragraph. Index: fanned blocks wear ⑂N; click one.
3. **VX-77 is closed as hollow** — the OutlineRoom red was the test host rendering dark (a walker left the dev
   domain's appearance on dark in October's first week). The three luminance pins are now appearance-proof. No
   product change. The ticket comment has the whole story.
4. **Release:** this run merged SECOND (after VX-381, before VX-348), so per your word it minted nothing —
   VX-348 mints the one 0.9.8, and this run's section (eight book bullets, your register) is already on
   ReleaseNotes-0.9.8.md for it.
5. **Tickets minted at the closeout** (triaged, listed below) — nothing needs you tonight; VX-402 is the one
   Suspected bug with real reach (the flush helper's in-flight window), minted Medium for your pass.

## The completed block (her format — the overnight mandate's deliverable)

**Part B — VX-382 Run: Book view doors & reds** (CLOSED 2026-10-18, PR #172, merged to main — second of the
night's three; VX-348 mints the one 0.9.8)
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
  note now counts as her place for "edit here" and the carry) · ladder R1-7 (the box's Takes cell dropped clicks
  outside the word — the same W-1 class, fixed; the hover wash now fills the cell) · ladder R1-1 was checked and
  proven a non-issue (the Index's departure does not eat the carry — measured by a pin that now stays as a guard).
- **Minted during the run:** VX-402 (the flushNow in-flight-write window — the shared helper class, Medium,
  Suspected) · VX-403 (WriteTakesPanel's shared-home move, Debt, Parked) · VX-404 (the Book Panel Close
  dead-clicks after Settings — Terminal, once, Suspected, Low) · VX-405 (CommitBar.boxCell's dead-zone sibling of
  R1-7, Low). Annotated, not minted: VX-353 (two more load-flake sightings) · VX-300 (the run's after-launch
  notes: the Takes-board memory gap, the mode-stamp idea, the small nits).

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

## Finals

The full table is `notes/plans/run-finals-ledger.md` §VX-382. In one line: five Mac batches (1,590/259 ·
1,998/332 + 308/64 · 649/125 · the combined-tree fold batch 700/132 · the ladder guard 342/71) with the only
non-known red everywhere VX-167's standing flake; every pin family red-on-old by revert or in-place edit; core
`swift test` 2,897/338; two both-voices walks, all walked rows pass. The ladder closed at round 1, 0B/0M/3m/5n.

## Filed tickets, grouped by priority

- **Medium:** VX-402 — `AutosaveCoordinator.flushNow` returns early while a write is in flight (every flush-first
  door; Bug · Suspected · Editor; the reviewer's pin sketch in the ladder record).
- **Low:** VX-404 — Book Panel "Close" ignored two clicks right after Settings closed (Bug · Suspected · Books);
  VX-405 — `CommitBar.boxCell`'s word-sized button in a full-width cell (the proven R1-7 class; Bug · Suspected ·
  Editor).
- **Parked:** VX-403 — move `WriteTakesPanel` to the shared home at its file's next touch (Debt · Takes & Lenses;
  reason on the ticket).
- **Annotations, no new ticket:** VX-353 (two more sightings of its load flake, dated) · VX-300 (the run's
  after-launch notes in its body).
