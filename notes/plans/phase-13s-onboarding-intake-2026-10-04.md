# 13s — Onboarding & Voice: the author's intake (2026-10-04 evening planning sitting)

> **Status: INTAKE RECORD — her notes verbatim, preserved at her instruction ("this is my
> current list of my notes on what i'm going to do in onboarding, for the record").** The 13s
> plan is NOT yet written; when it is, this file is its first input and every row below gets a
> disposition there (the 13c intake-ledger pattern). Her stated execution shape, same sitting:
> **the onboarding TOUR is built MOCKUP-FIRST — "we'll get it all set up in a mockup first for
> my approval of each screen we click through and the text, before moving into swift code."**
>
> **Cross-links out of this list (already routed, same sitting):** "Hide the Canvas view from
> users" → **17y item (p)** (debug-only, runs in the current fix pass at her word). "The field
> guide is the only element that didn't appear" → the DEFECT half is **17y item (q)** (the
> seeder trace, before her Monday fresh install); the field guide's CONTENT rewrite stays 13s's
> (she makes a version of the seeded guide in her own store and rewrites — safe: her store
> syncs only to her own account's devices, never to anyone else's).
>
> **The copy-pass instrument** (separate but adjacent): `notes/copy-pass/all-user-facing-strings.md`
> (3,630 strings, grouped by surface, path:line each) + `notes/copy-pass/priority-order.md`
> (the ≤8h tiered burn-down). Her workflow for it: the App Strings WORKBOOK minted into her
> real store (a book, chapters per area; one note per surface; one block per string with THREE
> takes — 1 current text · 2 blank for her rewrite · 3 the locator), filled during her Monday
> pass, exported with Alternates, applied by an implementer. The generator is a throwaway
> author-only tool (Tools/, never shipped, never on a release road).

## Her notes, verbatim

* The field guide is the only element that didn’t appear
* Emphasize navigation through the initial panes
* A result, refusal, undo, doesn’t make that much sense when the user first opens it
* Giving use cases in the intro note
    * Add more personality, different things that I can use it for
    * Include a couple of example notes at the end of
    * The books are examples
    * Example standalone note - open up the user brain to the broadest easiest term of how to do this
    * The users will rabbithole themselves
    * There needs to be a pool example
    * Basic user guide - how book, pool, library works
    * Separate out an advanced mode tutorial
    * Make the default mode Study
* Intro shape
    * 1 super simple fast read Quickstart note that stands alone
    * The field guide (play through tutorial)
* There’s way too much stuff going on when you first download
    * Way too many books right now
        * Fix the casing on Jekyll and Hyde, fix quick note and starred notes casing
        * Can add to the field guide that Jekyll and Hyde and classics can be restored - under the book lessons
            * Advanced lessons, don’t appear by default
            * Remove encryption explained period
        * starred notes can stay - empty
* Organize the orientation / tutorial flow to walk you through the different levels of the editor
    * First the large areas on the left
    * Then clicking on the book
    * How you move between book -> note
    * Then clicking into a note, the different editing modes within a note
* Hide the Canvas view from users
    * Remove it for now
    * It’s not the cleanest right now
* When you click on the “in standard mode”, open the right settings pane
* More opinionated onboarding flow
    * Sherlock, basics
    * Write *one* note that isn’t in a book? So people can see how the app is useable.
* Example snippet that points you to the snippets page

* suggestion: Not anything super specific but give a bit of a helping hand to people who aren’t used to comp sci (with words like commit)

## Flags for the 13s plan (the orchestrator's read — not rulings, hers to confirm at the 13s sitting)

- **"Make the default mode Study" — RULED (her word, 2026-10-05: "default mode study is an
  explicit ruling").** A fresh store wakes in the STUDY voice; existing stores keep whatever
  voice is set (a default flip, never a migration). AppSpec §12's two-voices contract is
  untouched — only which voice leads at first open changes. Lands in 13s; the canon delta is
  13s's closeout line.
- **"Way too many books" + the restorable classics** reshape the SEED SET — the same seeder
  17y (q) traces. Sequence deliberately: (q)'s mechanism first, then 13s's seed-set changes
  land on a seeder that is known-correct. Seed work is Sync-adjacent (dedupe facts): the Fable
  review rule binds those diffs.
- **"Remove encryption explained period"** — removing a seeded note class; same seeder lane.
- **Casing fixes (Jekyll and Hyde, quick note, starred notes)** — seed-content strings; they
  may also fall out of her copy-pass workbook naturally; dedupe at plan time.
- **"When you click on the 'in standard mode', open the right settings pane"** — a small
  navigation defect/affordance; could run as a fix-pass letter if 13s's code half wants a
  leaner scope. Routed at plan time.
- **The quickstart-note + field-guide two-piece intro shape, advanced lessons hidden by
  default, the opinionated flow (Sherlock → basics → one bookless note), the pool example,
  the snippet example pointing to Snippets** — the tour's CONTENT spine; all mockup-first.
- **The comp-sci helping hand ("commit" etc.)** — a GLOSSARY-REGISTER direction for the copy
  pass as much as for the tour; her copy pass already owns the words, the tour owns the
  first-touch explanations.

## Addendum — her 2026-10-05 ~03:20 notes (recorded verbatim-faithful by the 17y orchestrator at her instruction, mid-17y)

* Jekyll's removal from the default seed RUNS NOW (17y, R-17y-8 — her confirm: "unless they
  select to add it as an example or demonstration that I mention - if that's what you mean,
  then continue"). 13s may surface the add-it-as-an-example door in the tour's own voice.
* "I also don't want people to see a quicknote spawned already."
* Her CURRENT PLAN for the final seed set, verbatim: "my current plan is to finish with only
  starred notes there with 0 items starred, sherlock, and field guide (maybe one standalone
  note too)". Orchestrator's reading flags for the 13s sitting (not rulings): "0 items
  starred" touches the born-starred rule (R-13id-5 — the daily Journal and Quicknotes mint
  starred); her list carries NO Quicknotes gathering, NO classics gathering, NO seeded
  quicknote, NO Encryption Explained; the Journal already mints on demand (⌘J), not at birth.
* **A STARRED SHELF for starred books** — her idea, her words: "i feel like there should be a
  starred shelf for starred books ? thoughts? doesn't have to be built now but maybe worth
  putting on the plan." Orchestrator's thoughts, recorded for the sitting: fits the strip's
  grammar as a VIRTUAL ★ row beside "All" (a filter like the census solos, never a container
  — pointer religion holds); consistent with the starred-float; the open design question is
  its overlap with the sidebar's Starred section (notes+books mixed) vs the strip's ★
  (books-only, board idiom) — a mockup call for 13s or the next Bookcase touch, not a build
  now (her own framing).

* Her 2026-10-05 clarification of "0 items starred": it is WITHIN the starred gathering —
  starred NOTES show empty at birth; born-starred BOOKS (Journal, Quicknotes) stand, and the
  starred SHELF (built at 17y item (s), R-17y-9) can have Journal on it. The earlier
  born-starred flag above is answered by this.

## INTAKE FROM 17y + librarywalkpolish (2026-10-06, the 0.9.2 close — at her word: "make a note for the 13s session of where those extra rewording items are")

The 0.9.2 pass changed user-facing words AFTER her App Strings workbook was minted, so the
workbook does not carry them. **The field guide is EXCLUDED from this intake at her word**
("field guide differences don't matter, because I'll simply restore that one" — her restored
copy IS the current text; reword it in place). What 13s should know about:

- **The ⌘/ helper changed FOUR entries** (not in the workbook): the "tag cards (masthead)"
  row, the Windows star row + the "star" dictionary entry (the right-click word is
  `StarCopy.starRow`, ⌘K's act is `StarCopy.verb` — keep both constants interpolated; the
  `HelperCurrencyTests` pins bind the claims), and the "tag" dictionary entry. File:
  `App/Variorum/Variorum/Features/Help/HelperView.swift`. Diff:
  `git diff 6c8e4f02..origin/main -- App/Variorum/Variorum/Features/Help/HelperView.swift`.
- **FIFTEEN judgment-shaped wording items (J-1…J-14, J-16) are recorded, deliberately not
  built** — whether/how the guide and helper should TEACH the new surfaces (the census
  popover, the Cards/Notes switch, drop-to-star, the cross-wing "Now in …", the Arrivals
  icon's two states, inline book creation in the add-to-book picker, "unfiled", book archive
  in the map lessons, the Book Panel, …). THE LIST: `notes/plans/librarywalkpolish-vr122-
  guide-pass.md` (the audit table carries each with its anchor). These are 13s's re-voicing
  decisions, hers.
- **Wording guards now exist and will bite re-voicing:** `TutorialCurrencyTests` (lesson
  claims bound to the app's constants), `noLessonTeachesADoorThisReleaseHides` (the hidden-
  door set derives from the model — a paraphrase escapes it, a label tracks),
  `HelperCurrencyTests`, `DeadVocabularyTests`. A 13s re-voice that renames a door updates
  the constant, and the pins follow for free; prose that contradicts a door goes red.
- **Release notes: from 0.9.3 SHE WRITES THEM herself** (R-17y-10 — "i'll write them myself
  in the future"); nobody drafts unless she asks.
- Standing from the earlier 17y sittings, already in this file's territory: her FINAL SEED
  SET statement + the starred-shelf-empty look decision (the 17y rulings file's "FOR 13s's
  INTAKE" section, verbatim).
