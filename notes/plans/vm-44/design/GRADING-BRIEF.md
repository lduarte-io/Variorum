# VM-44 — grading the atlas (the brief both graders share)

Draft working record, not canon.

You are grading the iPhone app as it stands today, from screenshots, for an author who uses it daily and
is unhappy with it. Read `notes/plans/vm-44/her-words.md` first: her complaints are the
grading's centre of gravity, and her words are quoted exactly there. Then `~/dev/variorum/notes/MobileSoul.md`
§1–5 (what the phone app is for, and the rule that a capability keeps its soul while its shape changes).

## Her visual direction (her word, 2026-11-12 — binding)
"the overall look of the app is fine aside from how everything is weirdly small and spaced, but
honestly, just use the mac app as your visual direction. the study mode especially. the sea greeen
theme". So: do not propose a new look. The target is the Mac app's look — the Study voice under the
sea-glass palette — at sizes and spacing that are right for a phone. Spend your grading on size,
spacing, touch and flow; a screen that already looks like the Mac's Study voice is not marked down
for style. Sketches and mockups are drawn in Study + sea-glass, light first.

## Sources
- The atlas: `notes/plans/vm-44/atlas/` (screenshots, recordings, `screen-inventory.md`,
  the contact sheet). Look at every image in your half.
- The hard numbers behind the pixels: `notes/plans/vm-44/audit/G-visual-metrics.md`
  (type sizes, touch targets, how the quick-entry surface is built). Cite it; do not re-derive it.
- What is missing or stale by contract: the gap matrices `audit/A…D`. You grade what EXISTS; cite a
  gap only where a screen's weakness is really an absent feature.
- The Mac's design language, for kinship: the two voices (Terminal, Study) and their tokens in
  `App/Variorum/Shared/` (`VoiceTokens`), `notes/brand/TASTE.md`, and SurfaceContracts' "The app".
  The phone should feel like the same app, native to a phone — never a shrunken Mac window.

## The rubric — grade every screen A–F on each axis, one line of reason per grade
1. **Legibility** — type sizes for a phone held at arm's length, contrast, line length, hierarchy.
2. **Touch** — every control reachable and at least 44pt; primary actions in the thumb's reach.
3. **Clarity** — can she tell what this screen is, what each row/item is, and what to do next?
   (Her test: "so i know what each note is".)
4. **Calm** — the app's stance is calm default, depth on demand. Chrome that shouts, bands and boxes
   that draw the eye away from words, and clutter all lose marks.
5. **Craft** — alignment, spacing rhythm, consistency with sibling screens, both voices, dark mode,
   keyboard and safe-area behaviour.
6. **Native fit** — does it use the phone's own grammar (swipes, sheets, large tap rows, context menus)?
7. **Flow** — how many taps and how much hunting to do the screen's main job; dead ends; surprises.

## What to write
One file per grader under `notes/plans/vm-44/design/` (name given in your brief):
- A table: screen (with its screenshot filename) × the seven grades, plus an overall grade.
- Per screen: the three most damaging problems, concrete and visible ("the sort control is 11pt grey
  text with a 24pt tap area"), each tied to her words where one applies.
- Cross-cutting problems: the patterns that repeat across screens (these become the design-language
  sheet's agenda).
- What is GOOD and must survive the redesign.
- For the shell only (grader 1): two or three DIRECTIONS for the phone's navigation — how wings, the
  Library, the Bookcase, quick entry and search fit together — each as a small annotated HTML sketch
  (self-contained file, phone-frame sized, no external assets, saved beside your report), with the
  trade-offs named. She has nine wings and has asked for "a quick swipe between them and also a
  dropdown option". These are sketches to choose between at a sitting, not finished mockups.

## Rules
- Read-only on the repo. Never publish an Artifact or open a viewer: write local files and report
  absolute paths.
- Sentence case in any copy you draft; never capitalise a word for emphasis.
- Never estimate how long work will take.
- Grade honestly. A screen that is fine gets a B or an A; do not manufacture problems.

## Also read before grading (added once the audits landed)
- `notes/plans/vm-44/plans/sitting-1-questions.md` — the open questions for the author. Several
  are marked GATES DESIGN; your sketches exist to let her answer those by looking, not by reading.
- `notes/plans/vm-44/plans/dependency-notes.md` §1 (hard constraints: a phone type layer over
  the shared tokens, the shelf's layout arithmetic, wings before search) and `plans/master-work-list.md`
  (grep it for your surfaces; do not read it whole).
- `notes/plans/vm-44/atlas/walk-findings.md` — bugs the capture walk tripped on.

## How sketches are made (both graders)
- Self-contained HTML files (inline CSS, no external assets, no scripts needed), each showing phone
  frames at 402×874 pt (iPhone 17 Pro) side by side so options compare at a glance, with a short
  caption under each frame naming the option id from the questions file (e.g. "SW-1 (a)") and its
  trade-off in one or two plain sentences.
- Drawn in the Mac's Study voice under the sea-glass palette, light. Take the real values from the code:
  `App/Variorum/Shared/Theme/VoiceTokens.swift`, `PaletteDerivation` (grep for it), and the Mac's Study
  fonts. Put the token values you used in a small legend at the foot of each file.
- Use realistic content from the seeded library (nine wings: Home, Work, Fiction, Research, Family,
  Health, Side project, Poetry, Taxes 2025; see `atlas/instruments/seed-summary.txt`).
- These are sketches to choose between, not final mockups: correct sizes and spacing matter, pixel
  polish does not. Offer at most three options per question and say which you would pick and why.
- Save under `notes/plans/vm-44/design/sketches/`. Report absolute paths. Never open a
  viewer, never publish an Artifact.
