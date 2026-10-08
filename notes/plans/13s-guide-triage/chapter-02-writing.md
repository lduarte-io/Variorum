# Chapter 02 — writing (triage draft, U3 · R-13s-30)

Current seat: 2 of 10. Proposed seat: 2 (unchanged). Lessons: blocks & typing · shaping
blocks · formatting. Conventions: see `00-overview.md`.

---

## Lesson: blocks & typing

### Final text

Everything you write is made of blocks: paragraph-sized pieces with permanent identity.
You never manage them while drafting. Switch to Write (⌘1), click at the very end of
this note, and type a few paragraphs. Each paragraph quietly becomes its own block as
you type past it. No gesture, nothing to ask for.

Return makes a block wherever your cursor is: at the end of a paragraph, a new empty
block below it; in the middle of one, a divide at the cursor. Shift-Return is the
newline that stays inside a block, a blank line in the same paragraph, and a block can
hold several paragraphs that way, or by paste or merge. Otherwise boundaries only ever
change when you ask (divide, merge, extract: the structure chapter). Prefer to place
every boundary yourself? The bottom bar's "newlines make blocks" switch turns it off
for one note. Then Return is just a newline again, typing and pasting stay inside the
block, and only Divide or New Block Below make new ones.

Boundaries are invisible at rest, on purpose: a note reads as calm, seamless prose.
When you want to see the seams, press ⌘⇧B. Dotted lines appear between blocks,
everywhere, until you press it again.

The bottom bar keeps quiet count for you: which block your cursor is in, and the word
counts, both for the take you're in and for the whole note.

### Change log

- BLOCKS, WHEREVER, INSIDE → plain prose; em dashes out; the long switch sentence split
  in two.
- The type-a-few-paragraphs act, the ⌘⇧B act and the one-note switch all kept exactly.
- No behavioral claim changed.

---

## Lesson: shaping blocks

### Final text

Blocks mostly shape themselves as you type. This lesson is the hand tools, and its
blocks are staged for each one.

The first tool needs a middle sentence. This lesson was written as calm filler around
exactly one restless line. This middle sentence wants to be a block of its own. Select
that whole sentence, press ⌘⇧K (Make Block from Selection), and watch it become its own
block. From Takes, the app carries you to Write and does it there.

New blocks can also be asked for directly: ⌘⇧⏎ (New Block Below) mints an empty block
right under the one you're in and puts your cursor in it, in Write and Takes alike. In
Takes, the block ▾ menu in the bottom bar also has ＋ New block at the end of the note.
Either way, just keep typing.

A block can carry a name: a handle for finding it, never printed in the prose. This
block wears one. Open the Blocks tab (⌘6) and you'll see "the named block" where every
other row shows its first sentence. Name… on any row sets or clears one.

This block is a callout: a colored frame that says this one is different. An aside, a
goal, a warning. In Write, put the cursor here and use Block ▸ Callout to change its
color, set a leading emoji, or remove the frame. Presentation only; the text itself is
untouched, and exports render it as a quote.

### Staged content (unchanged mechanics)

- `setBlockName(blocks[3], name: "the named block")` and the blue 💡 callout on
  `blocks[4]` stay exactly as seeded; the lesson's quoted name "the named block" must
  keep matching the staged name.

### Change log

- NAME, CALLOUT → lowercase concept nouns; em dashes out.
- "watch it become its own block — from Takes, the app carries you…" split; the Takes
  carry kept as its own sentence.
- Every act kept (⌘⇧K on the staged sentence, ⌘⇧⏎, Name…, Block ▸ Callout).
- "set a leading emoji" kept: it describes the feature, it is not an emoji in copy.

---

## Lesson: formatting

### Final text

Formatting in Variorum is **markdown**, and that is not a detail of the implementation:
it is the whole design. What you see is exactly what is saved. Two stars around a word
are the bold. The editor styles the word and dims the stars, so the page reads cleanly
while the text stays plain characters you could open in any editor on earth. Nothing
about a formatted note is locked in, and an export is already markdown because it was
never anything else.

The vocabulary is small on purpose: **bold** (⌘B), *italic* (⌘I), ~~struck out~~, and
`inline code`. The last two live in the Format menu, which also carries every act
below, and right-clicking in any writing surface offers the same rows under "Format".
Try it: select these three words and press ⌘B. Press it again to take the bold off; the
act reads what is already there rather than blindly adding.

## Headings are sizes

A line that starts with #, ## or ### is a heading. Those three, and nothing else. Put
your cursor on this line and use Format ▸ Heading ▸ Heading 2 to see it happen; the
line above is already one. Setting a lead replaces whatever lead the line had, so a
heading becomes a bullet in one press rather than becoming a bullet with a stray # in
it.

- Lists are lines that start with "- "

- Format ▸ Bullet List makes one from the line you're on

- Select several lines and it makes them all into a list

- [ ] And a checkbox is a list item with a box: "- [ ] "

- [x] Click the box to tick it. That is an ordinary edit, so ⌘Z takes it back and a
sealed note refuses it

Links are written [like this](https://apple.com). Format ▸ Add Link wraps your
selection in the brackets and leaves the cursor inside the parentheses, ready for the
address. In a writing surface a plain click has to place your cursor, so ⌘-click
follows a link instead.

Now the one place the app shows you something other than what is stored. Open this book
in Read mode (the Outline · Index · Book · Read row above) and look at this lesson
again: the markers are gone, the headings are sizes, the list has bullets, the boxes
are boxes, and a link is just the words. A plain click opens it, because Read has no
cursor to place. Read is for reading; everywhere you can write, you see the text
exactly as it is saved.

### Change log

- The lesson's self-demonstrating markdown is untouched where it IS the demonstration:
  the `**markdown**` emphasis, the heading line, the three list lines, the two checkbox
  lines, the literal link. These are the syntax being taught, not voice.
- "ARE the bold" → "are the bold"; "CLICK the box" → "Click the box"; "READ mode" →
  "Read mode"; "⌘-CLICK" → "⌘-click". Em dashes out of the connective prose.
- Each lesson block stays one array entry at the port (the list lines are separate
  blocks in the seed; the blank lines between them here mark that, as everywhere).
- No doors dropped; every act kept (⌘B toggle, Heading 2, the box tick, the Read-mode
  look).
