# VM-44 — sitting 1: the rulings, organised

**Status: her decisions, as made 2026-11-12 and 2026-11-15.** Her words are verbatim, in order, in
`../her-words.md`; this file sorts them by surface and by the question id in `sitting-1-questions.md` so a
planner or designer can find the answer fast. Where this file and `her-words.md` differ, her words win.
"Default" means the orchestrator's recommendation in `sitting-1-recommendations.md`, which she accepted
without changing. Nothing here is a wave plan; the umbrellas and waves are still to be composed and approved.

## The frame

- **The goal:** "I want to get the mobile app done and out there so that people can start actually using
  variorum synced between devices".
- **The look:** the Mac's, at phone-right sizes. "the overall look of the app is fine aside from how everything
  is weirdly small and spaced, but honestly, just use the mac app as your visual direction. the study mode
  especially. the sea greeen theme". The sizing sheet (`../design/sketches/sizing-sheet.html`: type at
  13 · 15 · 17 · 20 · 24, a 44 pt touch minimum, her words on the paper and the bars on the sea-glass room) is
  the base every mockup was drawn in; she has seen it in use and has not ruled on its numbers one by one.
- **Words:** "I think we need to word things more simply." Every drafted line is short and plain; the Mac's
  own words are reused wherever a Mac face exists; her wording pass is still owed on the designers' lines.
- **Receipts:** no line for ordinary acts ("i feel like it'll feel too noisy"). A short line with Undo only
  when something leaves the page (delete, merge, archive, a deleted tag) and for refusals.
- **iOS target:** stays iOS 26 (the minimum); the app is built with the current SDK.
- **Phone-only users exist:** "some people will only use the phone app" — so wings and shelves are fully
  manageable on the phone, and a phone that can enter Castle can leave it.

## Shell, wings, home, capture

| Q | Ruling |
|---|---|
| SW-1 wings | Swipe the wing title to step wings, dots show the place among nine, tap the name for the dropdown; the page keeps the Starred · Bookcase · Library swipe. |
| Wing management | Full on the phone (make, rename, delete, move contents — what the Mac does), behind a ⋯ ("being able to create but not delete wings would make it awful"; the mockup's frame 9 is the approach). |
| SW-2 a note from another wing | The app follows the note to its wing (the Mac's rule). |
| SW-3 home | The Bookcase gets the whole screen; the capture box is a one-line field at the foot that grows with what is typed. (Reverses the old half-screen writing area.) |
| SW-4 capture Return | Return is only ever a new line; "File" saves and clears; "Open" saves and opens. |
| Capture marks | The two helper keys (tag, title) above the keyboard are kept. |
| Capture keyboard | Needs a way to be put away without filing or navigating (her report, found at the trace). |
| SW-5 where a quick note lands | The current wing, in the Pool (default). |
| LK-5 bottom bar | Three words at 17 pt, the current one on a chip, 56 pt targets. Shown on roots and lists; hidden inside a note. |
| Today button | Kept beside the capture box (opens today's first journal entry). |
| Home Screen | The app is named "Variorum" and wears the sea-glass cards (VM-46, done). |

## Library, search, Trash, tags

| Q | Ruling |
|---|---|
| LS-1 note row | A list: title; the time and one line of the note's words; where it lives. |
| Journal rows | The day leads; the line under carries the time and first words (the Mac's rule). |
| LS-3 names | Pool and Snippets (the Mac's names). |
| Snippets on the phone | View, add, edit, delete. Dragging a snippet into a note stays Mac-only. |
| LS-2 search scope | The current wing, with a switch to all wings. The Mac's twin is VX-987 (moved to Todo at her word). |
| Note actions in v1 | Duplicate (with and without tags), multi-select, Undo on archive, move / copy to wing. |
| Trash, Archived, tags | Kept: Undo after deleting a tag, an unused-tags door at the Trash's foot, counts in the tag list. Delete now stays off the row. |

## Books

| Q | Ruling |
|---|---|
| BK-1 shelves | A chip row above the book list (Starred · Unshelved · each shelf · All). |
| BK-7 shelf management | Full, behind a ⋯. |
| BK-2 book views in v1 | Contents and Read. An Index and a paged reader come after v1. |
| BK-3 Arrivals | A count on the Bookcase row and the book's bar; a full-screen review (why it waits, since when, swipe to add or dismiss, multi-select, Dismiss all asks once). |
| Finish confirm | Says how many arrivals it dismisses, with an "Open Arrivals first" button. |
| BK-5 book strip | "3 of 12 · Chapter" with ‹ › at the foot of a note opened from a book. |
| BK-6 rule editor | Simple: any / all of tags, starred, not-tag; a nested rule shows as a locked row. |
| BK-8 word target and note limit | Shown and editable in book settings. |
| BK-9 Journal's new entry | "+ New entry" at the foot of the Journal's contents. |
| BK-4, BK-10 | A muted pin on pinned rows; "Move to chapter" in the note's menu (defaults). |
| Book as a folder of notes | After v1, on the Mac and the phone: VX-1000. |

## The note

| Q | Ruling |
|---|---|
| NT-1 Return | Makes a new block, as on the Mac; a key for the in-block newline. |
| NT-2 backspace | Joins blocks and removes an empty block, as on the Mac. |
| LK-4 keyboard bar | The white strip goes ("i also dont like that white strip"). One right-aligned capsule. Tapping ⋯ expands into a quick row — Undo, Redo, Comment, Commit — then the full block menu. |
| LK-3 formatting strip | A setting: seven big buttons with the rest in a menu (the default), or all eleven in one compact row. |
| Masthead | Title on its own row; chips for the note's facts; both scroll away and a slim bar with the title stays, opening the jumps (top, end, a block, find). No "block 3 of 4" readout. |
| NT-5 commit and history | Commit is one tap (the quick row) and files at once, naming optional afterwards. History and lineage is one sheet (Commits per take, Lineage per block), opened from the block menu and from each take card. |
| Takes | The visible badge, and tapping it for the swipe-and-choose pill at the foot ("I love how fast that makes it"). The conflict take's signal stays as drawn. |
| NT-10 marks | One cluster (takes and comment counts) at the block's trailing foot; the callout glyph in the gutter. |
| NT-11 comment draft | Any way of closing keeps an unsent draft. |
| NT-6 a single note's Read mode | Not in v1. |
| NT-3 copy and export | Copy is the on-screen words. Export asks which file: just the text, or with takes and tags. |
| NT-4, NT-8, NT-9 | "Seal" for a finished note; "Merge with next" beside previous; quotes and spelling like the Mac (accepted). |
| NT-14 find | Find in v1; replace after. |

## The lock and protection

| Q | Ruling |
|---|---|
| The shape | Backgrounding keeps the library open for the dial's minutes; fully closing the app always locks; a Lock now door exists. (The lock-on-every-leave rule was a planner's item, not hers.) |
| LP-1 minutes | The existing dial (5 · 10 · 30 · never), default 10. It only matters under Castle. |
| LP-3 app switcher | Shows the page as today. |
| LP-4 after an unlock | The home screen, with a "back to where I was" button. |
| LP-5 Lock now | A lock icon on the home screen (the top, or the bottom bar), besides the Protection section. |
| LP-2 the phone itself locking | Unruled until a probe shows what iOS tells the app; the probe is the lock work's first ticket. |
| LP-7 leaving Castle | Works on the phone ("if you can go into castle on phone, you should be able to leave it"). |
| LP-8 the Private eye | Shown only where a mark exists and the AI-marks switch is on, so a phone-only user never sees one. No grants sync, and no ticket for it. |
| SC-4 library doors | After v1 (look inside, open, restore, send a copy). |

## First run, joining, settings

| Q | Ruling |
|---|---|
| FR-1 first open | The Bookcase and capture box with nothing in front; the app's asks arrive as cards above the capture box, one at a time. |
| FR-2 "I already use Variorum" | Lives in the welcome card on the Bookcase; joining is one sheet (sign in, the Standard or Castle arm, honest sync progress). |
| The pocket guide | Rewritten for the phone as a seeded book, written at the end once the flows are built; her wording pass. |
| The tutorial | A short phone tour as band cards, re-enterable from Help. |
| LK-1, LK-2 voice and palette | Follow the library's synced voice and palette; light or dark stays each device's own. |
| Crash reporting | In-app, opt-in, in v1. |
| After v1 | Import from Files, capture from outside the app, Settings search, Compare. |

## Compare (after v1)

Reopened at her word. Order: comparing two takes of a block first, then her idea — notes as tabs to swipe
between, lined up block by block (`../design/mockups/compare-concept.html`).

## Performance

- The causes of her two lags are traced in code (`../audit/F-performance-trace.md`). An Instruments session on
  her phone was prepared and then set aside at her word in favour of building timing into the app: markers at
  the moments she feels (tap on the capture box, keyboard up, file, note on screen, unlock, library ready) and a
  readout. That is the performance work's first ticket; it gives before-and-after numbers for every later fix.
- Seen on her phone after the VM-46 install: a sync round of about a minute with nothing new to send.

## Done during the sitting (not part of the plan to come)

VM-45 (a current build on her phone; sync restored) · VM-46 (the icon and the name) · VX-996 (the pre-push
guard, on both Macs) · VX-998 (the owed verify pass) · VX-999 (the release scripts read the signing profile
from outside the repo) · VX-1000 minted · VX-987 to Todo · VX-207 retitled.

## Still open for her

- A wording pass over the designers' proposed lines (each mockup's build notes list them).
- LP-2, after the probe.
- QUESTIONS #275 (the guard and other contributors' commits), provisional as built.
