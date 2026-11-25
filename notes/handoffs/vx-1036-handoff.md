# VX-1036 — Inside a book: the handoff

Everything in this umbrella is built, reviewed and merged: the book's List view, tags inside a book, new notes that land ready to type, the order dial that saves, titles while reading, and tags on quick notes. It ran overnight and into the day under your "continue overnight ruling provisionally", so the calls I made in your absence are waiting for you below.

## Your checklist

- [ ] **Look at it live — the Debug app on the dev store.** It's built from the final main and the dev store is dressed so the new things show. *(What's dressed and where to look is filled in below once the final window runs — see "Your look" at the end.)*
- [ ] **Then tell any session "done looking" — THE PUT-BACK.** Your words: "make sure you note in the handoff that the dev store will have to be put back to whatever is normal / latest once I've looked through it." The session you tell sweeps the sample content, puts the dev store back to its normal resting posture (signed out, the settings it had), and asks nov24's successor to lift the fence.
- [ ] **The 1.6 release — yours.** It's made ready and published nowhere. The notes are below in "The release"; the label 1.6 is provisional, yours to rename. If you like it after your look, say so and a session publishes it; changes first are fine too.
- [ ] **Read QUESTIONS #285** — every call I made, each built to the option named with its alternative. The ones you're most likely to want to change:
  - **The capture tag button is a bare "+".** The alternatives are "＃" or "+ tag".
  - **The tags switch is remembered per book on this Mac**, not synced.
  - **List rows don't show the AI marks** (the shared icon, the Private eye) that Library rows do — the outline cards don't either. Should they?
  - **The × on a gathering's placing tag** takes the note out of the gathering without asking, the way the Library's pills already do. A confirm, an undo, or no × there are the alternatives.
  - **The order dial can wrap even at the widest navigator** in the Terminal voice when the book is ordered by "Major revision", and at your own Study widths (about 252 and 258 pt). You accepted a wrap "in a narrow one"; this is more than that. Accept it, or shorten those dial faces.
- [ ] **The three faces you'd only seen in words** — captured so you can judge them: the three-position tags switch and the "…" on a long title (`notes/plans/vx-1036-screens/batch2/p4-switch/switch-three-positions-sheet.png`, `notes/plans/vx-1036-screens/batch2/p6-long-title/title-sheet.png`), and the quick note's tag button (`notes/plans/vx-1036-screens/batch4/p2-capture-tags/`, and live in `notes/plans/vx-1036-screens/walk/w2-12-foot-typed.png`). These folders stay on the Pro and aren't in the repo.
- [ ] **Your real store's field guide** now says a book has "five views". It changes in your library only when you choose Help ▸ Restore Field Guide…
- [ ] **Optional:** a Fable read of the VX-96 change (when the outline mounts a far row), when your Fable credits are back. The Opus reviewers judged it outside Fable's required class; it's offered, not owed.

## What changed

- **"when making a new note within a book, it's made at the bottom of a long list sometimes and then you can't actually see the new note"** (VX-1039). Every new-note door now ends with the note on the page, live, the cursor in it. A chapter's own "+ new note" files it in that chapter; the other doors file it after the note you're on. From Read, List or Index the book turns to the outline so the note is ready to type.
- **The order dial saves** (VX-1040). A pick on a gathering, or on a book that isn't hand-ordered, is the book's order at once. On a hand-ordered book a pick is a look, with "Save as this book's order" and "Back to manual order" right there.
- **Tags inside a book** (VX-1038, with VX-1081, VX-1080 and VX-576). A switch beside "expand all · collapse all" — hidden, other tags, all tags — puts pills in the cards' headers, beside the title or on their own line under a long one. A small + adds a tag, most-used first. ⌘⇧I does it on the note you're on. The pill's × is centred now. A long title rests with "…" and scrolls like a radio under your pointer.
- **List** (VX-1084, with VX-1091). A fifth view: the Library's own rows, in the book's order under its chapters. One click selects, a double-click or Return opens. The navigator got a little wider so five tabs fit.
- **Titles while reading** (VX-881). Read ▸ Scroll can show each note's title as a quiet line, per book.
- **Tags on a quick note** (VX-1078). A tag button beside the title suggestion on the new-note box and the menu-bar quick note.
- **The outline's blank beat** (VX-96). Switching to the outline no longer flashes a title over an empty card.

## The release

1.6 is made ready and published nowhere. The notes, in the shape you approved for 1.5:

*(The notes are `App/Variorum/Variorum/Features/WhatsNew/ReleaseNotes-1.6.md`; the session that publishes reads them to you in chat first.)*

## How it was checked

- Every fix has a test that fails on the old code and passes on the new; I proved each by putting the old code back.
- Two hands-on walks on the dev store, and two stage windows of the app's tests (1,639 and 1,771).
- Three rounds of cold review. The first two found real problems — the outline's heights didn't know about the new pills, and the most-used-tags count read far too much of the library — and both are fixed. The third found nothing serious.
- Before merging: the whole Mac suite (6,652 tests) and the whole phone suite (1,226 tests), all passing.
- Canon size after the changes: 144,275 of 150,000 (5,725 headroom).

## Worth your eyes

- **The overnight session switched models** at your Fable limit and carried on with Opus at your word. The run sat idle from about 07:30 to 09:53.
- **One thing I found that was already there:** a quick note filed with tags shows up in the Library without its pills until the list refreshes. It happens with typed `{#tag}` too, so it isn't new. Ticketed (VX-1095).

## Your look

*(Filled in after the final window: the Debug app's path, the main commit it's built from, what's dressed in the dev store and where to find it, and the release's state.)*

## Tickets filed

- [ ] VX-1093 (Low, Bug, Backlog): a pre-mount test passes only when another suite has adopted typography first.
- [ ] VX-1095 (Low, Bug, Backlog): a quick note filed with tags shows in the Library without its pills until the list re-reads.
- [ ] VX-1096 (Low, Debt, Backlog): the shared note row still reaches into the Library feature for its stamp and click types.
- [ ] VX-1097 (Low, Bug, Backlog): a note made beside a pinned note from a filtered Index can land below a hidden note.
- [ ] VX-1098 (Low, Bug, Backlog): turning a book's Read titles on or off can move the reading place.
