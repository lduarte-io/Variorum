# VX-283 handoff — the Open list grows, closes with ⇧⌘W and reorders by drag; the Library's controls row steadies (2026-10-16)

**Run:** VX-283 "Run: Sidebar & Library polish" · PR #167, merged to `main` as a merge commit (e2efdc79) · the record
`notes/plans/fixes/vx-283-sidebar-library-polish.md` (your triage and rulings, every unit's record and PROVISIONALs,
the stage windows, the walks, the review) · built 2026-10-14/16 on the Pro under your kickoff answers, your walk rule
(*"I want you to have an opus on xhigh walk with screenshots of the areas where the UI changed - especially the tab bar,
which is having its scroll fixed + getting taller. it should look right after it's done."*), your first overnight word,
and your second: *"I'll be sleeping finish everything and send the fresh install to the website overnight."*

## Your checklist

1. **Hand-check the Open list's drag (VX-376, High). It's the one thing nothing but your hand can prove.** Synthetic
   drags can't reach ANY drop target in the sidebar; main's own drag failed the same test (the run's main-build
   control). So every walk could only check the drag's start, never a landing. The new drag is main's own per-row drop
   road, the one your hands used, plus a line, an end zone and a settle. It is proven by tests and by matching main's
   road. In 0.9.7, drag an Open row:
   1. down one row;
   2. down several;
   3. to the end, in the room under the last row;
   4. up.
   Each should show a thin line where it will land and settle there; a drop on the row's own place does nothing. **If
   any drop fails, say so: the fallback is one commit, main's exact road, without the line.**
2. **Try 0.9.7: one release covering VX-336's AI work and this run** (your 2026-10-15 call, *"x283 will release a single
   release (0.9.7) covering both your work & their work. it should not bump the version again"*). It is on the
   website, and installed in /Applications as the same build: **0.9.7 (7933)** (the site commit `a37a275d`; the replaced 0.9.5 (7503) is in your Trash, and a safety copy of your store is `Backups/safety-copies/vx283-refresh-20261016T180250Z`). What's new in the
   sidebar and Library:
   - **The Open list** runs down to just above the sync row and stops there. Its scroll bar sits in the margin, clear
     of every ✕ (and Starred's ★).
   - **⇧⌘W** closes the note you're looking at and lands on the next one in the list (else the previous, else the
     Library), so you can close them all quickly. View ▸ Close All Notes clears the list. A ✕ on the note you're
     looking at does the same as ⇧⌘W (your ruling); a ✕ on any other row just removes that row. In a window merged
     into macOS tabs, ⇧⌘W is macOS's Close Window (your "Keep ⇧⌘W, live with it").
   - **Following:** the list follows the note you open, close or go back to, and never pulls back from where you
     scrolled (your "Only on your next act").
   - **The edges** fade softly where there's more to scroll, half a row deep and never solid, instead of slicing a row
     (your "The fade, reshaped").
   - **The Library's controls row** wraps onto two lines when the window is narrow, keeping the info panel on screen.
     Typing, searching or picking a sort never makes it jump. With your ~231-pt sidebar, Terminal sits on two lines
     with the panel closed, steadily.
   - **Smaller things:** messages no longer cover the quick-entry box (on the Bookcase and the Library); in dark mode
     the List's "books" / "notes" headings no longer draw a grey band; the View menu lost its doubled separator.
3. **Ratify or reverse the provisional calls: QUESTIONS #228.** Each was built as stated there, with a line to reverse
   it. The ones most worth your eye:
   - **The drag's shape (P-U2d-1):** the line sits at the top of the row you're over and the drop lands before that
     row, rather than U2's first half-row precision, which no drop on this road could verify.
   - **P-U2d-2:** the room under the last row is always a drop zone, even when the list scrolls.
   - **P-U3c-1:** the Library's two segmented controls keep their natural width (they used to squeeze after a search,
     which flipped the row).
   - **P-U3-4:** the dark heading uses the List's paper colour, not the black room, so a palette's hue isn't crossed by
     a black band.
   - **P-U1-4:** the list's floor on a short window is 3½ rows.
4. **For your eye, not provisional** (the last walk's observations, none caused by this run):
   - Typing into an EMPTY search field with the info panel open closes the panel on the first letter (the selected
     note leaves the results; the existing design).
   - Once, a keyboard sort pick closed the panel; it didn't happen again in three tries.

## What shipped (nine members + a rider)

- **VX-285 · VX-286 · VX-287 · VX-289 (U1):** the Open list's height, scroll bar, Close Note ⇧⌘W, Close All. Your
  follow and fade rulings came at the U1 memo sitting.
- **VX-288 (U2 → U2d):** the drag, the light version, with the chip on the Open list's rows only.
  - The first build's drop was never reached by a walk's drag. Two traces and a main-build control proved that no
    synthetic drag reaches sidebar drops at all.
  - So it ships on main's own per-row road (P-U2d-1), verified by tests and parity.
  - Your hand check is item 1.
- **VX-121 · VX-175 · VX-20 · VX-245 + VX-359 (U3 → U3b → U3c):** toasts clear of quick entry, the controls row (three
  legs: stable widths, then the segmented controls' squeeze found by a trace), the dark heading, the six line-limit
  lint sites, the menu separator.

## Tickets this run filed (triaged to your labeling rule)

- **High:** VX-376 — your hand check of the drag (Task, Needs Lillian).
- **Medium:** VX-360 — the shell drops a navigation request when two land in one frame (Bug, App shell; latent, found
  by a batch flake).
- **Low:**
  - VX-373 — at a very short window (620 pt), the followed current row can sit under the footer's edge (Bug).
  - VX-374 — two next-touch tidy-ups in the controls row, from the review (Debt).
  - VX-375 — walks can't verify sidebar drag landings; explore a road (Exploration, Tests & tooling).
  - VX-344 — multi-select in the Open list, Parked at your triage (Feature).
  - VX-359 — the doubled separator, fixed here, closes with the merge.

## The rest of the record

- **The review:** a fresh Fable at xhigh, two rounds, no blocker or major either round. Round 1's four tidy-ups were
  applied; round 2's two nits are VX-374.
- **Evidence:**
  - every unit's pins were red on the old code by a named revert;
  - every unit ran a Mac batch, and an Opus screenshot walk with the orchestrator's own look at the captures;
  - the merged tip's whole Mac target: 4,854 tests / 800 suites — 18 issues incl. 14 known; two reds, both standing on main (VX-115's `BookCollectingDoorsTests.theSettingsDoorIsOneActOnBothRoads`; VX-167's `DestructiveUndoWarningTests.redoNeverAsks` under wide parallelism); VX-245's line-limit lint, red on main before this run, now GREEN; 32 gated skips; no new red.
- **Your rulings reconciled against what shipped:**
  - VX-121's "ANY toast" is covered on the one component that draws the band, so both surfaces;
  - "Only on your next act" is built per its list of acts;
  - VX-285's "the full height they can" runs to just above the footer;
  - VX-245's six sites are fixed (the lint is green);
  - VX-288's "a nice little line … snap into place" is built on main's road, with your hand check owed.
- **MOBILE PARITY:** nothing mobile-visible. The Open list, the Library's controls row and the View menu are Mac-only;
  no `Shared/` code changed.
- **Zero** `Sync/`, custody, schema or editor-seam lines; marker 13 untouched; zero lockstep.
