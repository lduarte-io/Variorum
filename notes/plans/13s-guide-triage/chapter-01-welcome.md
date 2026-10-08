# Chapter 01 — welcome (triage draft, U3 · R-13s-30)

Current seat: 1 of 10. Proposed seat: 1 (unchanged). Lessons: start here · getting
around · the workspace · (proposed in: three ways of working). Conventions: see
`00-overview.md`.

---

## Lesson: start here

### Final text

Welcome. Variorum is built on a few beliefs about writing. A paragraph should be able
to hold more than one version of itself, side by side, for as long as you want. Nothing
you write should ever be destroyed: deleting, dividing and merging are all moves you
can take back. And what the app remembers is your choices, never your keystrokes. A
family tree, not a court record. Everything this book teaches follows from those
beliefs.

This book is Variorum teaching itself with itself. You are reading a note, inside a
chapter, inside a book on your Bookcase, and these are the same objects everything you
write will live in. Each lesson asks you to do the thing it describes, right here in
its own text.

Everything in this book is safe to play with. Cut it up, rewrite it, delete it. Help ▸
Restore Tutorial… replaces the whole book with a pristine copy whenever you want one.
Nothing you do here can touch your own writing.

Two companions to know from the start. When the app answers you (a result, a refusal,
an undo report), the answer appears briefly at the bottom of the window. And ⌘/ opens
the Shortcuts & Dictionary helper: every key the app listens for, and every word it
uses, in plain language.

The chapters of this book are listed on the left. Read in order, or jump to what
itches. When something in a lesson doesn't behave as the words promise, that is a bug
in the app, not in you.

### Change log

- Vision paragraph added at the front (the sanctioned move): choices kept open, nothing
  destroyed, a family tree not a court record. Substance from the product's own canon,
  no marketing wording; it states beliefs, it sells nothing.
- Em dashes replaced with plain punctuation throughout; parenthetical examples moved
  into parentheses.
- "listed to the left" → "listed on the left".
- No act was dropped; this lesson is the preface and had none.

---

## Lesson: getting around

### Final text

The sidebar has five places. Bookcase is home: your books, and a dashed box that reads
"new note — just start typing". Type a first line there and ⏎ mints a note and opens
it. Library is everything, searchable, with List, Cards and Timeline views. Pool holds
notes that belong to no book yet. Snippets holds loose scraps, pieces of text that
aren't notes at all. Archived keeps the notes and books you set aside: forever, no
clock.

⌘K finds anything: notes, books, blocks and commands. Type a few letters and ⏎ opens
the hit. ⌘N makes a new note from anywhere. ⌘J opens today's journal entry; the journal
is its own daily notebook on the Bookcase.

[modeRowSentence() — the derived sentence; the re-voiced TEMPLATE below, interpolations
untouched:]

A note opens into one of \(word) modes. The tabs read \(modeList), and \(keySpan)
switch between them. The first time, a note opens in Write, the plain full page; after
that it remembers the mode you left it in. The rest of this book visits each mode where
it earns its keep.

Try it now: press ⌘K, type "getting", and ⏎ back to this very lesson. Then press ⌘2
for Takes and ⌘1 for Write, and watch the same text wear both faces.

### Change log

- Caps-for-emphasis area names (BOOKCASE, LIBRARY, POOL, SNIPPETS, ARCHIVED) → real
  casing; each place keeps its one-sentence description.
- `modeRowSentence()` stays a pure derived function (the mode seam); only its template
  is re-voiced. `\(word)`, the `modeList` and `keySpan` calls stay interpolated exactly
  as built.
- The dashed box's quoted string keeps the UI's own em dash (a verbatim quote).
- "the journal" already lowercase; agrees with R-13s-36's default.
- The try-it act kept word for word in substance (⌘K, "getting", ⏎, ⌘2, ⌘1).

---

## Lesson: the workspace

### Final text

One window can show two notes at once. Right-click any note row ▸ "Open Beside" and it
opens in a second pane next to this one; View ▸ Open Beside does the same with the note
you had open most recently. Drag the seam between them to resize, and View ▸ Close
Split folds back to one.

Only one pane writes at a time. Click into a pane and it becomes the live one: its text
is the text you type in, while the other reads quietly beside it. That is deliberate,
and it is what keeps a note with ten thousand words as quick as an empty one. A split
never shows the same note twice. To see one note two ways, use Lenses (⌘4) or Compare
(⌘5).

Whole windows too: File ▸ New Window opens another full window, with its own sidebar,
its own Open list and its own trail. Right-click a note row ▸ "Open in New Window"
opens just that note, sidebar-less, for when one piece deserves its own screen.

The sidebar keeps an Open list of the notes this window has open, in the order you
opened them. ⌘⇧1 through ⌘⇧9 jump straight to them, drag the rows to rearrange, and ✕
closes a row and nothing else (the note is untouched). ⌥⌘[ and ⌥⌘] walk back and
forward through where this pane has been, like a browser.

Above the page sits the context bar, always the same three doors: ← and → walk back and
forward through where this pane has been (⌥⌘[ and ⌥⌘] are the same doors), and the book
glyph opens the book this note lives in, at this very note. One more thing joins them
only when there is something to say: a note that has deleted blocks wears a quiet ⌫
badge with the count, and clicking it opens that note's tray. The deleting chapter has
the whole story. The note's tags live on the masthead's right edge, under the tray,
scraps and references icons. Click the ＃ beside the cards and a tag field slides out
with the cursor already in it: type a name, ⏎ applies it (a "/" nests, like
life/goals), ⎋ puts the field away, and ⌘⇧I opens the same field from anywhere in the
note.

Two more, for keeping and catching. Right-click any note or book ▸ "Star" pins it to
the sidebar's top: up to fifteen, meant for what you are in right now rather than as a
filing system. And ⌘⇧N pops the quick note, a small floating pad that stays above your
writing, also reachable from the ✏︎ in the system menu bar while you are in another app
entirely. ⏎ there files what you wrote and closes the pad; ⇧⏎ adds another paragraph,
so a capture can be as long as the thought is. They are the same two keys the new-note
box on the Bookcase answers. Closing the pad (or ⌘⏎) files it too, and what you wrote
is kept as a note, tagged "quicknote". The quicknotes gathering on the Bookcase shows
it, and taking the tag off sends it back to the Pool.

⌘/ opens the Shortcuts & Dictionary helper, and its "Windows & panes" group is this
whole lesson in key form, including the doors that have no key and live in a menu
instead.

### Change log

- Caps-for-emphasis removed throughout (TWO, ONE, WINDOWS, OPEN list, CONTEXT BAR,
  QUICK NOTE, FILES, ROW, TAGS → plain prose; door names keep their shipped casing).
- Long em-dash chains split into short sentences; every door kept — nothing in this
  inventory was shed.
- "the Quicknotes gathering" → "the quicknotes gathering" (R-13s-36's lowercase
  default; the landing confirms U1b landed the rename first).
- ✏︎ kept: it names the menu-bar item's glyph (the seeder's \u{270F}\u{FE0E}), not
  decoration.
- Flagged (not built): this lesson is the guide's densest manual page; a bolder pass
  would split it ("panes & windows" / "the bar and the catchers"). First-pass rule
  taken: faithful clarification, structure kept.

---

## Lesson: three ways of working (PROPOSED IN from "the library of things")

### Final text

Everything in this book comes down to three ways of working with one piece of writing.
This lesson is the map; the chapters ahead teach each road in full.

Polish in place: just write. Most text needs no machinery. Type, autosave keeps up, and
commit ⌘S marks the moments you want to be able to come back to. If your text looks
like basic text, it behaves like basic text.

Thread one piece: when one block is the question, fan it. Takes hold the attempts side
by side; the ✓ picks what the note says; a lens remembers a whole set of picks without
touching the note. The block below has a spare take to practice on.

The keeper's logbook recorded weather, oil, and wicks; never once the keeper.

Fork the piece: when the structure should differ (a rearranged argument, a different
opening), duplicate the note as a version and let the two grow apart, linked and
comparable. A lens is the same structure with different choices; a version is a
different structure; promote is the bridge.

### Staged content (unchanged mechanics)

- The practice block keeps its second take: "The logbook knew everything about the
  light and nothing about the keeping of it." (text unchanged).

### Change log

- Moved here from the tail of "the library of things" (the sanctioned move-up,
  PROPOSED; hers to decline). The staged take travels with the lesson, so the act works
  in either seat. If declined, swap one clause: "the chapters ahead teach each road in
  full" → "it is the map of everything this book has taught".
- "it absorbs the old modes tutorial" dropped: internal history, meaningless to a
  reader (logged, per the no-silent-disappearance rule).
- "⌘S keeps savepoints" → "commit ⌘S marks the moments you want to be able to come back
  to" (R-13s-31; no savepoint survival here).
- POLISH IN PLACE / THREAD ONE PIECE / FORK THE PIECE → sentence case lead-ins.
- The staged block's literary em dash → semicolon (sample prose, minimal touch).
- The closing aphorism's quotation marks dropped; it reads as the lesson's own
  sentence.
