# VM-44 — mockup rounds (the brief every designer shares)

Draft working record, not canon.

You are designing screens for Variorum's iPhone app during a PLANNING effort (no product code). Read first,
in this order:
1. `notes/plans/vm-44/her-words.md` — the author's words and rulings, verbatim. They govern.
2. `notes/plans/vm-44/design/sketches/sizing-sheet.html` — THE BASE. Every mockup inherits its
   type scale (13 · 15 · 17 · 20 · 24), the 44 pt touch minimum, its spacing scale and radii, its grounds
   rule (her words and lists sit on the paper; bars, sheets and section bands sit on the sea-glass room),
   corrected inks, and its components. Do not invent sizes or colours outside it; if you need a component
   it lacks, add it in the sheet's spirit and say so in your report.
3. `notes/plans/vm-44/design/sketches/` — the round-1 sketches (the wing masthead in
   `SW-1-wing-swipe.html` option (a), the home screen in `SW-3-home-screen.html` option (b), note rows in
   `LS-1-note-rows.html`, the Bookcase in `BK-1-bookcase.html`, the keyboard bar in
   `LK-4-LK-3-keyboard-bar.html`). The author has NOT yet chosen among their options; where your screens
   need a shell, use the graders' picks (SW-1 (a), SW-3 (b), BK-1 (a)) and keep the shell a thin, swappable
   layer so a different pick costs a re-skin, not a redesign. Reuse `sketches/_g1-sketch-generator.py`'s
   frame and CSS if it helps consistency.
4. `~/dev/variorum/notes/MobileSoul.md` §1–5 (the phone's doctrine: same brain, phone-native face; prefer
   one honest simpler gesture over porting a ceremony; no "do it on the Mac" dead ends; calm default).
5. For your surfaces: the matching audit under `notes/plans/vm-44/audit/`, the grade file under
   `design/`, the rows of `plans/master-work-list.md` for your area (grep by Area), the questions in
   `plans/sitting-1-questions.md` with the orchestrator's leanings in `plans/sitting-1-recommendations.md`,
   and the as-built screenshots under `atlas/screens/`. The Mac's contract for the surface is
   `~/dev/variorum/notes/SurfaceContracts.md` (read your surface's section) — the phone must reach the
   same capability, in a phone's grammar. Never invent product behaviour: where the contract is silent or
   a question is open, draw the options and name the question.

## What a mockup file is
- One self-contained HTML file per surface under `notes/plans/vm-44/design/mockups/`
  (inline CSS, no external assets), phone frames at 402 × 874 pt, Study voice under the sea-glass palette,
  light; one frame of each key screen also in dark.
- It shows the FLOW, not just a screen: the frames in order, left to right, with a caption under each
  saying what the user did to get there and what each control does. Include the states that matter:
  empty, loading where it can be slow, a refusal, the keyboard up, long content, nine wings, a
  largest-text-size check on the densest screen.
- Where a question is still open, draw the alternatives side by side and label them with the question id.
- Realistic content from the seeded library (`atlas/instruments/seed-summary.txt`).
- Copy is sentence case, plain, in the app's voice (the Mac's own words wherever a Mac face exists —
  find them in the code and reuse them exactly). Never capitalise a word for emphasis.
- After the frames, a short BUILD NOTES section: for each screen, the work-list rows (W- ids) it
  delivers, which shared brain it stands on (name the type, from the audits), what is new, and anything a
  builder must not get wrong. Sizes S/M/L only; never estimate time.

## Rules
- Read-only on `~/dev/variorum`. Never publish an Artifact or open a viewer; write local files and
  report absolute paths. Render each file headlessly to check it (Chrome is installed:
  `"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --headless=new --screenshot=… file://…`)
  and look at the render before you report; save renders under `design/renders/`.
- Reply in at most 300 words: paths, the screens drawn, the open questions you drew alternatives for
  and your pick on each, and anything you added to the sizing sheet's vocabulary.
