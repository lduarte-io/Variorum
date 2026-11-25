# Variorum 1.6

Tags inside a book, a List view for books, new notes that land ready to type, chapters in search, and fixes for word deletion, deleting notes and opening a library.

## Fixed

- A new note made inside a book could land at the bottom of a long book, out of sight and not ready to type. Fixed: it now appears on the page with the cursor in it, from every door — after the note you're on, or in a chapter when you use that chapter's own "+ new note".
- Option-Delete had a bug where, on an empty list item, an empty line or a line of only punctuation, it deleted a word from the line above. Fixed: Option-Delete and Option-Forward-Delete never take a word from another line.
- Search had a bug where a chapter found by its name showed up only as its book, and a book's own search said nothing matched. Fixed: the chapter gets its own row, and one click opens the book at that chapter.
- Opening a library could wait a long time when a backup folder lived in iCloud. Fixed: the open reads that folder in the background, and the restore list now says which place each copy comes from.
- Switching a book to its outline could show a note's title over a blank card for a moment. Fixed.
- The × on a tag pill sat lower than its text. Fixed: it's centred.
- In the Terminal voice the book navigator's view tabs were a point wider than its narrowest width, and a book's search field could spill over the sidebar in a narrow column. Fixed.
- The Trash flashed "The Trash is empty." when you changed its filter or order. Fixed.
- A notice could cover the encryption card on the Bookcase, and a long message on the bottom bar could run into "⌘J today · ⌘N new note". Fixed.
- A dash beside a tag was quoted in the search band. Fixed: the band shows just the tag.
- The shared mark on a note didn't say on hover which other books the note lives in. Fixed: it has its own symbol, says so on hover, and one click lists the other books.
- In a note's list of books, an archived gathering didn't say it was archived, and a gathering offered Diverge. Fixed.
- The daily Journal's own menu didn't show "Use as Daily Journal" as ticked. Fixed.

## New

- A book has a new List view: the Library's own rows — titles, days, tags and edited stamps — in the book's order under its chapters.
- Tags show inside a book. A per-book switch shows them on the outline's cards and the List's rows: hidden, other tags, or all tags. "Other tags" leaves off the tags that already place a note in a gathering.
- Add a tag right on a card: a small + beside a note's tags opens a field that suggests your most-used tags first. ⌘⇧I now works in books too, opening that field on the note you're on.
- Deleting a single note no longer asks first. A notice says it went to the Trash, with Undo, which brings it back with its saved versions. Deleting several notes at once still asks.
- Picking an order on a gathering, or on a book that isn't hand-ordered, now saves it as the book's order. On a hand-ordered book a pick is a way of looking, with "Save as this book's order" and "Back to manual order" shown while it's on.
- A long note title in a book rests cut with an ellipsis and scrolls like a radio ticker under the pointer, one title at a time.
- Note titles can be shown while reading: a quiet line above each note in Read's scroll, remembered per book.
- Quick notes can be tagged as you write them: a tag button sits beside the title suggestion on the new-note box and on the menu-bar quick note.
