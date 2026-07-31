# Phase 13h — the folder question (DESIGN NOTE; nothing decided)

**Status: a note, authored 2026-07-30 at the author's direction during
the 13f kickoff sitting** — she asked that 13h carry it forward. It
binds nothing; her uncertainty is preserved on purpose, and the phase
**opens with the longer design conversation she named**. Cast and
scope at her kickoff, as always.

## Her words (2026-07-30, verbatim — the note she asked for)

> "I think make a note for 13h that I'm going to need to have a longer
> design conversation about what this really looks like for a folder
> of markdown files - I imagine they stay markdown and i'm only
> exposing an editor, and then if they want to become variorum posts
> that's a deliberate step to convert the markdown into a variorum
> post? I do agree that it would be helpful in luring users away from
> Obsidian. I think I'll just need to decide more at that step to be
> honest"

Sequencing affirmed the same sitting: *"yeah i like 13g before 13h"*
(and 13g's markdown-as-content fork, if ruled that way, directly
shapes what a folder file's bytes are — the order is technically kind).

## The two poles the conversation must reconcile

Her 2026-07-25 intake and her 2026-07-30 note describe DIFFERENT
architectures; both are hers, and the sitting picks (or blends):

- **Pole A — the BRIDGE (the row's standing shape, from A35):** a
  variorum post ⇄ a `.md` file; edits made in the folder (by her, an
  LLM, any tool) land BACK through ordinary operations — the Fragments
  bridge's proven pattern pointed at a folder (S5 conflict-as-variant
  guards the landings; block identity survives; "nothing typed on
  either side is ever lost"). Her original intake wording leaned here:
  *"have those edits sync or something"* / *"with sync even? that
  would be nice."*
- **Pole B — the FOLDER EDITOR (her 2026-07-30 floated shape):** the
  files **stay markdown** — Variorum only exposes an editor over the
  folder; the files are their own truth, with no block identity, no
  takes, no store row; **becoming a variorum post is a deliberate
  conversion step**. This is closest to Obsidian's own model (a vault
  of plain files), and the most LLM-transparent shape possible —
  nothing to land, the file IS the state.

## What the sitting has to decide (the questions the fork raises)

1. **Where truth lives, per file** — the store (A) or the file (B);
   or B-by-default with A as an opt-in per file ("this file is now a
   post's projection").
2. **What the folder editor is** (pole B): the TK2 editor core over a
   plain file — which of P1/P3's postures apply when there are no
   blocks; whether ANY variorum machinery (find, spellcheck levels,
   typewriter room) reaches it.
3. **What conversion means** (the deliberate step): one file → one
   post through the standing import pipeline (the 11b `importPost`
   precedent — segmentation, spacing ruling, undo); and whether the
   file survives conversion as a linked projection (drifting toward
   A) or is consumed/left behind.
4. **The A36 half** — folder import mapping folders → chapters/books
   (*"to lure people from obsidian"*) reads naturally as pole B's
   conversion door at folder scale; its round-trip expectations ride
   the 11b import pins.
5. **The LLM story in each pole:** B is maximally tool-transparent
   (any tool edits plain files); A preserves identity/lineage across
   the tool's edits. Her original micro-app framing (*"open any
   markdown file (with just the path to it or the name of the file)
   and see it / make edits / make changes and import it as a post
   into variorum if I'd like"*) contains BOTH halves — an editor over
   plain files AND a deliberate import door — which is pole B almost
   exactly.
6. **What of 13g lands underneath it:** if 13g rules
   markdown-as-content, a converted post's bytes and a folder file's
   bytes are the same dialect — conversion and (in pole A) projection
   both get simpler. If 13g rules attributed runs, the folder's
   dialect needs a mapping either way.

## What binds meanwhile

Nothing here — except the standing law: any store-touching landing
goes through ordinary operations; nothing typed anywhere is ever
lost where truth lives; never a knowledge base. Her closing word
governs the posture: *"I think I'll just need to decide more at that
step to be honest."*

## References

The 13c intake ledger rows A35/A36 (her verbatim asks) ·
`notes/source/author-intake-2026-07-25.md` lines ~257–265 (the fuller
micro-app framing) · the master plan's 13h row ·
`notes/plans/phase-13f-workspace.md` sitting round 6 (this note's
provenance) · the 11b import pins (round-trip byte stability).
