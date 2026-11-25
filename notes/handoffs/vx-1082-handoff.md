# VX-1082 — your Nov 24 fixes: the handoff

Everything you reported on Nov 24, and the seven small tickets you added beside them, is fixed and merged (PR #29). It ran overnight while you slept, under your "everyone should rule provisionally", so a few calls are mine and are waiting for you below.

## Your checklist

- [ ] **Hover the shared mark — two minutes (VX-1094).** Open a book where a note also lives in another book. Rest your pointer on the small books symbol after the note's title: on a folded card, on an unfolded note, and on the Index row. Each should say "Also in “‹book›” — editing it here edits it there too" by itself. This is the one thing the overnight walk could not check. Automated pointer moves raised no tooltip at all, not even the ones that have always worked, so only your hand can say. Clicking the mark (proven) lists the other books.
- [ ] **Read QUESTIONS #284**: the calls I made in your absence, each built to the option named, the others beside it. The ones you're most likely to want to change:
  - **The shared mark's symbol** is `books.vertical`. It reads as "books", but the same glyph marks the Bookcase in the sidebar and the References button. You disliked exactly that kind of collision with Snippets. Swapping it is one line; `square.stack` and `rectangle.on.rectangle` are unused in the app.
  - **⌥⌫ at the very start of a block does nothing.** That matches what it does at the start of a document. ⌫ still joins blocks.
  - **The delete toast has one door, Undo.** I read your "or they can go to the trash" as "the Trash is still there", not as a second button on the toast.
  - **"Use as Daily Journal" is ticked AND greyed** on the Journal's own menu, the way its Private row already is.
  - **In a narrow book column the search field's floor wins**: the book's name shrinks to a letter or two while the field is open.
- [ ] **The wording pass.** Every new sentence is listed at the end of #284: the toast lines, "Note put back.", "Also in 1 other book:", "in ‹book›", "1 chapter", "archived · by tagging". Provisional, as you said was fine.
- [ ] **Try it yourself, if you like:** an empty `- [ ]` item under a line, then ⌥⌫. The marker goes and the line above stays. Delete a note: no question, a toast with Undo. Search a chapter's name: the chapter shows up and opens the book there.

## What changed, in your words' order

- **"chapter titles are not being found in search"** (VX-1074). They were being found, but shown only as their book. Now a chapter found by its name is its own row, "‹chapter› · chapter · in ‹book›", and one click opens the book's Outline at that chapter. Inside a book, its own 🔍 used to say "nothing in this book matches" while it had found the chapter. It now lists the chapter above the notes and counts it ("1 chapter · 2 passages in 2 notes"). **⌘K still doesn't list chapters**; that's ticketed (VX-1089).
- **"option backspace … will actually remove a word on the line previous"** (VX-1076). Found at last. ⌥⌫ was the Mac's own word delete, which skips over line breaks before taking a word. So on an empty checklist item, an empty line, or a line with only punctuation, it reached up and took the word above. That's why it seemed random. Now ⌥⌫ (and ⌥⌦) never takes a word from another line, in Write and in every pane. This also closes the old September question #126, where your first report of it was waiting for a call.
- **"remove confirmations on delete note"** (VX-1077). Deleting ONE note asks nothing. A toast at the bottom says it went to the Trash, with Undo; Undo brings it back along with its saved versions, and the toast mentions those versions when there are any. Several notes at once still ask first. ⌥⌘Z doesn't undo a delete, as you said. The phone is unchanged.
- **"the two boxes … isn't saying that on hover … give it its own symbol and make a click list the other books"** (VX-1075). The mark has its own symbol now, and it's a button: one click lists the other books, and each opens that book at the note. The hover was missing because the card or row around the mark answered the hover instead of the mark. The mark is now its own control with its own hover. That's what your VX-1094 check confirms.
- **The riders:**
  - A long message on the bottom bar no longer runs into "⌘J today · ⌘N new note". The hint steps aside while a message shows and comes back after it fades (VX-409). The collision only ever happened while the message was sliding in or out.
  - A toast no longer covers the encryption/words card on the Bookcase (VX-1070).
  - The dash beside a tag is no longer quoted in the search band, your option (b) (VX-1069).
  - A book's search field no longer spills over the sidebar in a narrow column (VX-1014). This one was real: short book names left the field no room.
  - The Trash no longer flashes "The Trash is empty." when you change its filter or order. Real, proven by its test before the fix (VX-1016).
  - In a note's list of books, an archived gathering says archived, and a gathering's row offers no Diverge (VX-1034).
  - The daily Journal's own menu shows "Use as Daily Journal" already ticked (VX-1027).

## How it was checked

- Every fix has a test that fails on the old code and passes on the new. I proved each by putting the old code back and watching its test fail.
- One cold review by Fable found nothing above a nit; the three nits were fixed.
- Before merging:
  - the whole Mac test suite ran, 6,532 tests (three timing flakes in it, each passing when run alone);
  - the whole phone suite ran, 1,226 tests, all passing;
  - I walked the Debug app on the dev store myself, and every fix above showed up live except the one hover in your checklist.
- The three notes the walk made are in the dev store's Trash. Its settings, voice, appearance and wing are as I found them.

## Worth your eyes

- **The overnight session switched models.** It hit your Fable limit partway through the final check and carried on with Opus at your word. Nothing was lost. The only work that needed Fable, its review of the editor change, had already finished.
- **One observation I didn't ticket.** Five other bottom bars put a message beside a count or page line: Write's, Takes', Read ▸ Pages, the spread, and the Index. A short message landed cleanly on Write's in the walk; a long one wasn't tried. Your rule is no ticket without seeing it, so it's only in #284. Say the word and it's a ticket.
- **VX-1091** (the book's mode tabs a point too wide in Terminal) will most likely disappear with VX-1036's new navigator widths. VX-1036 merges after this run and checks it with its own measurement.

## Canon and parity

- Eleven SurfaceContracts lines changed in place, plus one TEXTKIT2 note. `Tools/canon-size` reads 143,606 of 150,000, no crossing.
- Mobile parity is PL-82: the delete toast is the Mac's alone, at your word.

## Tickets filed

Tickets filed:
- [ ] VX-1094 (Low, Task, Todo): hover the shared mark on the Debug build — the one check the walk couldn't make.
- [ ] VX-1089 (Low, Improvement, Backlog): ⌘K doesn't find a chapter by its name.
- [ ] VX-1091 (Low, Bug, Backlog): in Terminal the book's mode tabs are about 1 pt wider than the navigator's old narrowest width — likely dissolved by VX-1036.
