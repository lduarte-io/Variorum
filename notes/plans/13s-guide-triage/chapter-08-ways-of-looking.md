# Chapter 08 — ways of looking (triage draft, U3 · R-13s-30)

Current seat: 8 of 10. Proposed seat: 7 (moves up one as privacy slides last). Lessons:
read · lenses · compare & versions · blocks [· canvas]. The last lesson is the derived
`lookingLessonContent()` — both build flavors drafted below; the derivation (title and
intro following `PostMode.buildKeepsCanvas`) stays a pure function. Conventions: see
`00-overview.md`.

---

## Lesson: read

### Final text

Read (⌘3) is the note beside its own index, and it opens on edit. The column on the
left is the index: markdown headings become sections, every other block files under the
one above it, and a note with no headings lists plainly. Click a row and the text
beside it scrolls there; the ⋯ menu carries the block acts. In the text, click any
block and it goes live right where it is, one block at a time. The outline button folds
the column away and back. Read opens standing at the block you were just in, whichever
mode you came from.

Switch the face to read and the same note is a page: the paper a book's reading flow
uses. Markdown rendered, boundaries gone, nothing to edit. Choose continuous, or pages
(the book's own leaves; ← → turn them); Aa − / Aa ＋ size the type. Reading is the
point. And when a sentence needs work, click its paragraph: the page turns to edit with
that block live.

Try it: press ⌘3. The column stands at this lesson. Click this very paragraph in the
text and it goes live; type a word. Switch to read, click this paragraph again, and the
page turns to edit with it live. Then ⌘1 back to Write.

### Change log

- READ/EDIT caps → the switch's own lowercase face names (edit · read) where the faces
  are meant, Read where the mode is named; em dashes out.
- The try-it act kept exactly.

---

## Lesson: lenses

### Final text

A lens is a saved way of looking at a note: for each block, which take to show. It
never changes the note. A lens is the same structure with different choices. Lenses
mode (⌘4) is their home: full-text columns side by side.

Both blocks of this lesson carry two takes, and a lens named "the other reading" is
saved beside the chosen text. In Lenses, add its column (＋ column ▸ Open "the other
reading") and read the two versions of this lesson side by side. The ‹ › arrows on any
cell re-pick that block's take; 💾 saves your current picks as a new lens.

✓ Make this the note adopts a column: the note's chosen takes become what it shows.
Adopting swaps, never destroys. The outgoing chosen is auto-saved as a lens named
"chosen until (today)", so you can always swap back.

### Staged content (the lens's alternate takes, re-voiced)

- Alternate on block 1: "A lens is a bookmark on your choices: it remembers, for every
  block, which take you'd show, without moving the note an inch. Lenses mode (⌘4) lays
  such readings out as columns."
- Alternate on block 3: "✓ Make this the note is the one door from looking to being:
  adopt, and the column's picks become the note's chosen takes. The old chosen is kept
  as "chosen until (today)": swaps, never destroys."
- The seeded lens "the other reading" and its two choices stay exactly as staged.

### Change log

- LENS, ADOPTS caps → plain prose; the maxim's quotation marks dropped; em dashes out
  (lesson and staged takes both).
- 💾 kept: it is the surface's own save-lens button glyph (\u{1F4BE}), named not
  decorated.
- The add-column act and the adopt teaching kept exactly.

---

## Lesson: compare & versions

### Final text

A version is a different note related to this one. A version is a different structure.
Two gestures share the word: Mark as Versions just draws a link between two existing
notes; Duplicate as Version mints a whole copy (takes and all) and draws the link in
one gesture. Mark = connect, duplicate = copy + connect.

This lesson already has a version twin; it was duplicated when the book was seeded.
Open Compare (⌘5): the notes sit side by side, related blocks tied by lineage, and
every pane is editable. Click into either column and type: the edit lands in that note,
and the one live ring moves wherever you click, across notes. Drag a block's ⣿ handle
to reorder it; each column reorders its own note only.

Compare is honest about relationships. "Follow this note's order" arranges the other
columns beside their related blocks (display only; nothing moves); lineage colors mark
the families, and rails appear only where a real relationship exists. Compare against
an unrelated note and it says "there is no relationship here". The two just sit plainly
side by side, no blanks, no colors.

Compare opens with "related blocks only" on: it hides every block lineage has nothing
to say about, leaving just the material that connects across the columns. Nothing is
moved or deleted. It is a way of looking, and one click back: turn the chip off to read
the notes whole. Against an unrelated note it tells you there is nothing to show,
rather than showing you nothing.

Outlines live here too: press "make outline note" in Compare's header and the app mints
a linked condensation, first sentence per block, and opens it beside this note,
registered point by point. And the Diff sheet has Save…: the whole diff as a plain-text
file, ready to hand to an AI agent.

Unmark deletes only the connection; both notes stay exactly as they are. The library's
right-click menu has Duplicate as Version for any note, any time.

### Change log

- VERSION, NOTE, MARK AS VERSIONS, DUPLICATE AS VERSION, EDITABLE, OPENS, LOOKING caps
  → plain prose with the two door names in their real casing.
- "the Diff sheet now has Save…" → "has Save…" ("now" was changelog-speak inside a
  lesson).
- Em dashes out; the twin, its rename and its tag stay exactly as staged
  (`twinTitle` untouched — a reserved identity).
- Every door kept (Compare, Follow this note's order, related blocks only, make
  outline note, Diff Save…, Unmark, Duplicate as Version).

---

## Lesson: blocks [· canvas] (`lookingLessonContent()` — both flavors)

### Final text — intro paragraph, Canvas build (Debug)

Two more ways of looking, each a different traversal of the same note: nothing is ever
copied into a view. (Outlining lives in Compare now: an outline is just a related note
beside its draft, the previous lesson's "make outline note".)

### Final text — intro paragraph, no-Canvas build (Release)

One more way of looking, a different traversal of the same note: nothing is ever copied
into a view. (Outlining lives in Compare now: an outline is just a related note beside
its draft, the previous lesson's "make outline note".)

### Final text — the workbench paragraph (both flavors)

Blocks (⌘6) is the workbench: the note's blocks as objects. Every row shows what it
carries: takes, comments, words, tags, a lock, when it last moved. Click a row and its
panel opens on the right. Edit the text there, see its takes, or jump onward (Write,
Takes, its history). ⌘-click picks several, and the bar above acts on all of them at
once: merge, tag, archive, delete, move out to snippets. One ⌥⌘Z takes the whole act
back. Rows reorder with ↑ ↓, or the row's ⋯ menu moves by position: top, bottom, or the
number you type. Move out to snippets does what it says: the block leaves this note and
becomes a snippet there (a block lives in one place; ⌥⌘Z brings it back).

### Final text — the two canvas paragraphs (Canvas build only)

Canvas (⌘7) scatters the blocks as sticky-note cards. They open in a tidy grid until
you arrange them; drag a card by its ⠣ header (arrangement is yours and is remembered;
the note's order doesn't move) and resize it from the corner grip. Click into a card
and type: edits land on the take the card is showing. The little number in a card's
corner is the block's place in the note's current order.

The canvas has one door back into order: "order by clicking". Click cards in the order
the note should read (each shows its number as you go), then Apply once: the numbered
cards lead the note and everything else keeps its relative order after them (⌥⌘Z
undoes; Cancel changes nothing). "Fit all" shows every card at once; bigger boards open
a read-only overview, and a click on any card lands back on it. The ‹ › switcher on a
card flips which take you're viewing ("viewing — not what the note shows"); choosing
stays a separate, deliberate ✓.

### Change log

- The lesson stays the ONE pure function with the ONE seam: the title
  ("blocks · canvas" / "blocks") and intro variant still derive from
  `PostMode.buildKeepsCanvas`; only the strings inside re-voiced.
- BLOCKS/CANVAS caps → mode names in real casing; em dashes out of the guide's prose.
- The quoted card caption "viewing — not what the note shows" keeps the UI's own dash
  (verbatim quote — the landing verifies it against the card's shipped string).
- The drag-header glyph is the seeder's \u{2823} (rendered ⠣ here), unchanged.
- The named manual-page shed was CONSIDERED and not taken: every workbench door is
  kept (merge, tag, archive, delete, move out to snippets, ↑ ↓ reorder, ⋯ move by
  position, the panel's jumps). Bolder option logged for her pass: cut the ⋯
  move-by-position and reorder detail to the ⌘/ helper and the registry, leaving the
  row-panel-bar triad; under guardrail 6 each cut door would get its own log line
  then.
