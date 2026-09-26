# Filming notes — product demos & shorts

How to shoot Variorum for vertical short-form, and what actually needs to be on
camera. Written 2026-09-26 alongside shorts 01–03; also the reference for
AI-video / demo-tool experiments.

## The one-gesture rule

Each short demonstrates ONE gesture end to end — never a feature tour. The
viewer should be able to reconstruct the whole interaction from memory after one
watch. If a script needs two ideas, it's two videos.

## What to show — the beat that carries each concept

The concept is never the feature; it's the *moment on screen* that makes the
feature legible. These are the money shots:

| concept | the beat that carries it |
|---|---|
| the fan / takes | a calm paragraph **blooms** into 3–4 side-by-side cards — summoned, not ambient |
| choosing a take | click a take and the paragraph **swaps in place while the rest of the page holds perfectly still** — this stillness is the whole point; lock the scroll position |
| calm default | the fan **folds away** and the page reads as plain minimal prose again |
| speed | typing mid-document with **zero input latency**, at 60fps — felt in the viewer's own fingers; scrolling is secondary |
| delete is safe | delete → tray → **Put back returns it to its exact slot**, same scroll position held throughout |
| savepoints | pin → **visibly wreck the text** → restore; the relief is the content |
| read mode | the same note flipping between an editing surface and a **calm page you'd actually read** — then a sentence click landing back in edit at that block |
| themes | one note, palette/voice changes rippling — best as a satisfying B-roll loop, not a script |

## Staging content

- **Real prose, never lorem ipsum.** Viewers read the screen; the demo text is
  part of the script. Write it in advance.
- Takes in a fan must read as **genuinely different drafts** — one lyrical, one
  terse, one restructured — so the idea lands in a single glance without VO.
- Stage everything in the **dev store** (the Debug build,
  `io.lduarte.Variorum.debug`) — never the real daily-drive store. Standing
  project rule, and it means demo content can be reset and replayed freely.
- For repeatable, precise takes: `cliclick` + `Tools/WalkKit/` can script the
  pointer choreography deterministically (dev-store Debug only). A scripted walk
  gives identical camera takes across recording attempts — worth it for the
  money shots where the cursor path matters.

## Vertical format (9:16)

- The Mac app is landscape, but the **prose column with its sacred margins crops
  beautifully to 9:16** — zoom into the column rather than showing the full
  window. The minimalist surface is an asset here; most Mac apps crop terribly.
- Use Screen-Studio-style **zoom-pans** for the transitions (wide enough to
  establish the page → tight on the block for the gesture → back wide for the
  calm ending). Plan the zoom keyframes per script beat.
- Keep UI text legible **after** the crop — check on an actual phone, not the
  editing timeline.
- **Cursor choreography:** slow, deliberate movement; plan the pointer path
  before recording; no hunting, no overshoot. The cursor is the actor.
- Export 1080×1920. **60fps for anything with scrolling or typing** (the speed
  stunt is 60fps or it doesn't exist); high bitrate — text shreds under
  compression faster than faces do.

## On-camera app hygiene

- Set receipts to **quiet** so toasts don't wander through the frame.
- Editing indicator and seams: off/at rest unless the seam IS the subject.
- Test **both rooms**: the fully black dark room pops hard on OLED phones; the
  light Terminal voice is more distinctive as *yours*. Film the flagship both
  ways and A/B the first-frame hold before committing the series to one.
- First frame is the hook image (the graveyard, the split screen, the hovering
  cursor) — never a logo, never a talking head.
- Burned-in captions always (most shorts play muted); the scripts' VO lines are
  written short enough to be the captions verbatim.

## AI video tooling — where it helps and where it must not

- **Good for:** the hook B-roll (the graveyard doc, the `maybe-later-FINAL.docx`
  gag), title cards, motion-graphics overlays, VO generation/cleanup, music.
- **Never for the product footage.** The demo must be real screen capture of the
  real app — AI-generated or reconstructed UI reads as fake within seconds and
  undercuts the exact claims being made (especially speed). The credibility of
  build-in-public content *is* the realness.
- **No time-remapping in comparisons** (speed stunt): never fast-forward our
  side or slow theirs. If the difference needs editing tricks, don't make the
  claim.
- A useful hybrid: AI tools for the PAIN beats (other apps, hypothetical docs),
  hard cut to real capture at the TURN. The texture shift even helps — the real
  app feels like relief.
