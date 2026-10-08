# The field guide triage — U3 drafts (R-13s-30)

First-pass triage of the whole field guide: the LLM-isms out, the caps-for-emphasis out
absolutely, each chapter rephrased for clarity with meaning preserved. Drafted by the U3
Fable agent, 2026-10-08, against this branch's `TutorialSeeder.swift` (post-main-merge,
through commit 901f3f16 — rulings R-13s-1…37 read). Under R-13s-35 these drafts land
autonomously tonight (Opus port, Fable cold review); her judgment runs in the app,
post-merge. This is the first pass, not hers — her own deeper rewrite follows later and
nothing here forecloses it.

## How to read the chapter files

- `chapter-NN-<slug>.md`, numbered by the guide's CURRENT book order (the seeder's plan
  array), one file per chapter. Each lesson: the full rephrased text in final form, ready
  to port, then a change log (one line per move; flagged proposals kept separate).
- Interpolated constants are written exactly as the seeder spells them, inline:
  `\(TrayPath.archivedTab)`, `\(TrashWindow.days)`, and so on. They stay interpolated at
  the port — never flattened to literals.
- Key glyphs are written literally (⌘⇧D, ⌥⌘Z, ⏎, ⌫, ▸, ·, ✓, ⋯, ␣). The porting
  implementer maps them to the seeder's escape style as the file already does.
- Quoted UI strings keep the UI's own punctuation, including its dashes (the dashed box
  really reads "new note — just start typing"). The ban on em dashes binds the guide's
  own prose, not a verbatim quote of a shipped surface.
- Paragraph breaks in a lesson's final text mark the seeded BLOCK boundaries, matching
  the source lesson's paragraph array one to one unless the change log says otherwise.
- Staged content (practice takes, the staged comment) is included under its lesson,
  labeled, because it is user-visible prose and got the same treatment.

## The voice rules applied (R-13s-22, R-13s-30, R-13s-31/32)

1. No caps for emphasis, anywhere. UI names keep their real casing (Bookcase, Takes,
   Trash, commit ⌘S); concept nouns (block, take, commit, lens, version, gathering) are
   plain lowercase and defined by their first sentence, the tour's pattern.
2. No em dashes in the guide's prose; no emoji. Short declarative sentences, one idea
   per sentence, her Start Here register. Colons, commas, parentheses and periods do the
   work em dashes did.
3. The word is commit, never savepoint-as-label. Savepoint survives exactly once in the
   whole guide, as the explanatory common noun defining commit at its first teach
   ("keeping takes safe", paragraph 1) — logged there per R-13s-32.
4. Every lesson still asks you to do the thing, right there in its own text. No act was
   dropped; where an act's premise changed (the seed reshape), the act was restaged, and
   the change log says so.
5. Behavioral claims were checked against the seeder's own annotations and, where the
   overnight units change the facts (R-13s-36 casing, R-13s-37 seed and restore doors),
   written to the POST-U1b target and flagged for the landing to verify against the
   built seed.

## The proposed chapter order (the sanctioned moves applied)

| # | Chapter | Was | Note |
|---|---------|-----|------|
| 1 | welcome | 1 | "start here" gains the vision front (sanctioned); "three ways of working" PROPOSED in as its closing lesson (see below) |
| 2 | writing | 2 | unchanged |
| 3 | takes | 3 | unchanged |
| 4 | structure | 4 | unchanged |
| 5 | deleting & getting it back | 5 | unchanged |
| 6 | where things go | 6 | unchanged |
| 7 | ways of looking | 8 | moves up one: the workflow chapters now run unbroken 1–9 |
| 8 | the library of things | 9 | "three ways of working" departs if the move-up is accepted |
| 9 | books & the bookcase | 10 | stays the workflow capstone |
| 10 | keeping it private | 7 | the sanctioned slide: safety after the workflow, as the guide's closing word |

**The privacy slide, applied (sanctioned):** the chapter moves from 7th to last. Workflow
reads unbroken; the guide closes on the serious chapter, which suits its first-week role
("now you know how to work; here is what keeps it safe"). Tradeoff stated: it loses its
adjacency to "where things go" (the recovery map it was placed beside), and the guide no
longer ends on the books capstone. Alternative if she prefers the capstone ending: seat
it 9th, before books — everything above still holds.

**"Three ways of working" up (PROPOSED, hers to decline):** it moves from the library
chapter's tail to the welcome chapter's close, as the map of the whole app read before
the details. It absorbs the old modes tutorial and IS the map, which argues for the
front; its staged practice take travels with the lesson, so the act works in either
seat. Tradeoff: near the front it names takes, lenses and versions before their
chapters; the draft handles that by pointing forward ("the chapters ahead teach each
road"). If declined, the same draft reads correctly in its old seat with one clause
swapped — the change log in chapter 01 carries both spellings.

**Tour agreement check (for the landing):** the tour's leg-end card names "takes in
depth, divide and merge, books that collect, privacy" — all four survive the reorder as
chapters; no chapter renames; the two guide-pointing cards need no change.

## Vocabulary and seed-fact dependencies (for the landing session)

- **R-13s-31 sweep:** every lesson's "savepoint" became commit; the one sanctioned
  survival is logged in chapter 03. The quoted fold line in "keeping takes safe" is
  drafted as "N quiet commits · show" on the assumption U4's app sweep renames the
  surface's fold line — the landing verifies the exact renamed string before the port.
- **R-13s-36 casing:** drafts say "the journal" and "the quicknotes gathering"
  (lowercase defaults). The landing confirms U1b landed the renames first.
- **R-13s-37 seed facts:** "the classics walk" was restaged off the classics gathering
  (no longer seeded; restorable by its new door) onto the seeded starred-notes gathering;
  "the journal & the pool" was restaged off the seeded quicknote (no longer seeded) onto
  a quick note the reader makes; the Jekyll restore sentence stays (restorable, the
  interpolated name picks up the lowercase title). Chapter 09's change logs carry each.
- **Prose-matched code hooks the port must move with the words:** the seeder's own
  `hasPrefix("EXIT THREE, middle")` (chapter 06 renames the staged trio to sentence
  case); `theDeletedSpareTakeWaitsInTheBlocksPast` finds a staged take by its prose
  (chapter 05/06 staged takes rephrased); the plan array and walk tests re-pin as the
  landing brief already says.

## Flagged proposals (not built; collected from the chapter logs)

1. **The fenced privacy chapter's book door conflicts with R-13s-37.** Copy §7's pinned
   closing sentence points at the book "Encryption Explained" "on this shelf" — a book
   the ruled launch seed neither ships nor lets you restore. The sentence will be false
   on a fresh store. Outside this pass's fence (her never-soften rule); needs an
   orchestrator/author call on the copy constant. The chapter file says it in place.
2. **Title rename:** "export — it's all yours" carries the guide's one em-dash title;
   propose "export: it's all yours" (plan array, phone twin and pins ripple — landing
   sized, hers to decline).
3. **Literal 30s → `\(TrashWindow.days)`:** two lessons said "30 days" as a literal
   where sibling lessons interpolate; the drafts promote them to the constant (logged
   per lesson; strictly a drift-proofing, no word change).
4. **Bolder rewrites logged, not taken** (guardrail 5): each chapter's log lists the
   places where a restructure was tempting and the faithful clarification was taken
   instead — notably the workspace lesson (a candidate split into "panes & windows" and
   "the bar & the catchers") and the merge lesson (a candidate two-lesson split).
5. **Chapter title "deleting & getting it back"** could shorten to "deleting"; declined
   — her phrasing teaches the promise, and the phone twin shares the string.

## What this pass could not resolve from the repo alone

- The exact post-U4 fold-line string ("N quiet commits · show") and the post-U1b door
  names (the classics-gathering restore door's menu title) — flagged above, landing
  verifies.
- The Encryption Explained conflict (flag 1) — needs a ruling outside the fence.

## Status (flipped per chapter commit)

| File | State |
|------|-------|
| 00-overview.md | DONE |
| chapter-01-welcome.md | DONE |
| chapter-02-writing.md | DONE |
| chapter-03-takes.md | DONE |
| chapter-04-structure.md | DONE |
| chapter-05-deleting.md | DONE |
| chapter-06-where-things-go.md | DONE |
| chapter-07-keeping-it-private.md | NOT STARTED (fence notes + flags only, as ruled) |
| chapter-08-ways-of-looking.md | NOT STARTED |
| chapter-09-library-of-things.md | NOT STARTED |
| chapter-10-books-and-the-bookcase.md | NOT STARTED |
