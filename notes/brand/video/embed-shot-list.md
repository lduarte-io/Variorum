# Embed shot list — feature loops for the blog post and the product page

Drafted 2026-10-04, written to be DRIVEN BY AN AI (Opus or another session)
with the author checking results. Every clip here is a **silent, looping,
landscape screen capture** (the inline-figure format from `filming-notes.md` —
these are NOT the vertical shorts; those have their own scripts). Generous
candidate list on purpose: shoot wide, she picks.

## Hard rules for the driving agent (non-negotiable)

1. **DEV STORE ONLY.** Stage and record in the Debug build
   (`io.lduarte.Variorum.debug`, Xcode Run). NEVER open, script against, quit
   or kill the real-store app at `/Applications/Variorum.app`. All demo
   content is seeded in the dev store and freely resettable.
2. **Scripted pointer choreography** via `cliclick` + `Tools/WalkKit/`
   (dev-store Debug only — the standing walk rule). Script the pointer path
   per clip so takes are identical across attempts; slow, deliberate motion,
   no hunting, no overshoot.
3. **Real prose, staged in advance** — never lorem ipsum. Takes in a fan must
   read as genuinely different drafts (one lyrical, one terse, one
   restructured). Write the demo text before recording; the words on screen
   are part of the shot.
4. **Capture:** landscape, the window sized generously; crop to the prose
   column in post if wanted. 60fps for anything with scrolling or typing
   (V5 especially); high bitrate — text shreds under compression. Each loop
   6–12s, cut so the last frame flows into the first (start and end on the
   calm page where possible).
5. **App hygiene:** receipts set to quiet; seams and editing indicator off
   unless the seam is the subject; no dev chrome in frame. Record the hero
   clips (V1, V13) in BOTH light and the black dark room; everything else in
   whichever the author picks after seeing those.
6. If a gesture misbehaves or a surface looks broken, STOP and report —
   never ship a workaround take or improvise alternate content.

## Tier 1 — the blog post set (shoot all five; the post uses at most three)

*[removed for publication]*
at the paragraph that describes it. Recommended three: **V1 + V2 + V5**, with
V3/V4 as swap candidates.

- **V1 — the fan (HERO).** 10–12s. Beats: calm page of real prose (1.5s hold)
  → summon the fan on one paragraph → 3–4 takes visible side by side (1s
  hold) → click take 2: the paragraph swaps IN PLACE, page perfectly still →
  click take 3: swaps again → choose one → fan folds away → calm page (1.5s
  hold, loop point). Staging: a mid-length note; the fanned block in the
  upper third of the viewport; scroll position LOCKED throughout. Serves:
  blog "What Variorum is"; product page §1.
- **V2 — delete → tray → put back.** 8s. Beats: paragraph selected → delete →
  the page closes the gap → open the note's tray → the paragraph is there →
  Put back → it returns to its EXACT slot → calm. Same scroll position held
  the whole clip. Serves: blog "nothing destroyed" bullet; page §3.
- **V3 — savepoint pin → wreck → restore.** 10s. Beats: a good paragraph →
  pin a savepoint → visibly rewrite it worse (2–3s of typing) → open the
  take's history → restore the savepoint → the good version is back. The bad
  rewrite should be legibly worse at a glance. Serves: blog savepoints
  mention; page §2.
- **V4 — read mode flip + sentence-click landing.** 8–10s. Beats: editing
  surface → flip to the calm read page (continuous) → brief scroll as a
  reader → click a sentence mid-page → lands back in edit AT that block,
  caret visible. Serves: blog read-mode bullet; page §5.
- **V5 — speed (Variorum alone — the split-screen stunt belongs to short 02,
  not here).** 8s @ 60fps. Beats: a 50k-word manuscript → fling-scroll fast →
  jump to the end → click into the middle of a paragraph → type a sentence,
  letters landing under the cursor with zero lag. Show the word count
  somewhere honest (e.g. the note's stats) at the start. Serves: blog speed
  bullet; page §10. HONESTY: real capture, real document, no time remapping.

## Tier 2 — the product page set (one loop per major section; shoot as many
as practical, the page can start with Tier 1 clips only and grow)

- **V6 — extract a sentence.** 6–8s. Select the last sentence of a paragraph
  → Extract → it becomes its own block below, source intact → (optional tail:
  fan the new block, one beat). Page §4.
- **V7 — divide, the everyday cut.** 6s. Caret mid-paragraph → divide → two
  blocks, page text byte-identical → structural undo (⌥⌘Z) → whole again.
  Doubles as the §3 undo demo. Page §4 + §3.
- **V8 — Divide choosing takes… (the ceremony).** 12s. A fanned block → open
  the ceremony sheet → real prose side by side, the ✂ placed on the gap in
  take 1, then take 2 → confirm → two blocks, fans distributed. Page §4. (The
  most visually distinctive clip in the set; also a shorts-04 candidate.)
- **V9 — Merge choosing takes… (the round-trip).** 12s. Two adjacent fanned
  blocks → the merge ceremony → pair take 1+1 and 2+2 by hand → confirm → one
  block whose fan holds both joined takes. Ideal staging: the blocks V8 just
  divided, so the round-trip reads. Page §4.
- **V10 — Lenses.** 8s. A note in Lenses: two or three columns, each a
  different set of take choices → change one column's choice for a block →
  only that column re-reads. Page §5.
- **V11 — Canvas.** 6–8s. The same note as spatial cards → drag two cards to
  regroup them → calm hold. Page §5.
- **V12 — Blocks workbench.** 6–8s. Multi-select three blocks → the bulk bar
  appears → one bulk act (e.g. tag them) → context panel glimpse. Page §5.
- **V13 — books: one note, two books + the book panel.** 10s. A note open
  with its book panel showing chapter context → the same note visibly listed
  in a second book → reorder within the panel. Page §6. (Second hero — shoot
  in both themes.)
- **V14 — a gathering collecting.** 10s. A gathering defined on a tag → in
  another note, apply that tag (capture microsyntax or the tag door) → the
  note arrives in the gathering. Page §6 + §8.
- **V15 — wings.** 6s. Switch from Home to a second wing: a different
  bookcase, different library — separate rooms. Page §6.
- **V16 — the daily journal.** 8s. ⌘J → today's entry opens → type a line →
  the entry visible in the Journal book, ordered by day. Page §7.
- **V17 — capture microsyntax.** 6s. Type `{#essays/drafts} {t:"A better
  title"}` in a capture → the tokens vanish → the note carries the tag and
  the title. Page §8.
- **V18 — snippets drag.** 6–8s. Drag a scrap from Snippets into a draft → it
  lands as a block; the scrap remains in Snippets. Page §9.
- **V19 — references.** 8s. A PDF open in the reference panel beside the
  draft → flip a page → close and reopen the note → the PDF remembers its
  page. Page §9.
- **V20 — themes ripple.** 8–10s. One note: Terminal light → Study → the
  black dark room → two palette presets. A satisfying loop; also the page's
  §12 figure and general B-roll. Page §12.
- **V21 — the app lock.** 6s. The locked lobby (glyph rain) → Touch ID →
  the library opens. Page §11. (Nothing sensitive on screen in the unlock
  frame — stage a bland library view.)
- **V22 — export with Alternates.** 8s. Export a note with a fanned block →
  open the `.md` in a plain editor → the Alternates section visible. Page §9
  + §11 (the exit-is-open claim made visible).

## Tier 3 — optional / staging-heavy (only if time allows)

- **V23 — move span to new take.** 6s. Select a passage → lift it to a new
  take on the same block → remainder stays. Page §4.
- **V24 — conflict-as-variant.** Two devices edit the same paragraph offline
  → sync → the losing version arrives as a new take in the fan. The single
  best privacy/sync visual (page §11) but needs two staged devices/stores —
  attempt only if the author wants to set it up; NEVER fake it.
- **V25 — whole-note version restore.** 8s. Save a version → restructure the
  note heavily → restore → the note returns whole. Page §2/§3.

## Deliverables per clip

`notes/brand/video/captures/` (gitignored if large — the author decides):
`vNN-name.mp4` (master, landscape, 60fps where specified) — crops and webm
derivatives are the website's problem, not the capture session's. A one-line
log per clip (date, build, theme, any deviation from the beats above) in
`captures/LOG.md`.
