# Variorum 0.10.5

## A new book comes with Variorum

- Machiavelli's *The Prince* is now the seeded book: every paragraph is English on the page with the 1532 Italian one fan away.
- The most quoted lines carry a third translation, and the book's last block holds a 1640 English verse — three renderings side by side.
- Every chapter keeps saved lenses, so one click reads the whole chapter in Italian beside the English and one click reads it back.
- Chapter XVIII carries a small seeded comment pair — a translator's note and an editor's reply — to show how comments work.
- It seeds into fresh libraries only: an existing library picks it up any time from Help ▸ Restore "the prince", and sherlock holmes joins jekyll as restore-only.

## The Trash is fast now, and takes multiples

- The Trash shows its rows at once — the seconds-long blank page is gone.
- Put back and Delete Now answer immediately.
- Pick several rows with ⌘-click or ⇧-click and put them back or delete them now together, with honest counts in the confirm.
- The Trash never says it is empty before it has looked.

## Deletes that stick

- Deleting a seeded book on one device now sticks everywhere — the returning-Sherlock bug is fixed.
- Quitting the app during its own cleanup no longer leaves a crash report behind.

## Notes, versions and history

- Saved versions now seat in Compare beside a note's other versions, and unmarking one there promotes it to a regular note after a confirm.
- Compare with Latest Version lives on File, the note menus and ⌘K while a note has a saved version.
- A saved version opens full size, read-only, with Back and Promote.
- Block History opens each saved moment in place, with counts on the region headers and a read-in-full sheet carrying Restore and Bring back as a take.

## Editor and books

- A note with many deleted blocks no longer lags on new blocks and Return.
- ⌘↑ and ⌘↓ step through a book's notes while reading; ⌥⌘N starts a new note in the focused book.
- ⌥⌘L moves a note or book to another wing and ⇧⌥⌘L copies it there; the Outline's navigator keeps your place in view as the page scrolls.
- An approved AI client can now be granted a gathering as a place, and the wire refuses anything a tool's schema doesn't declare.

## Under the hood

- This release runs one local library migration, v1_34: an index that removes the deleted-notes editor lag — local only, nothing changes on the server.
- And a second, v1_35: it sweeps the retired bookkeeping the old resurrection defense left behind — local only, nothing changes on the server.
