# VM-44 phone atlas — walk findings (Phase B, primary pass)

Draft working record, not canon. What the capture walk tripped on while driving the iPhone app on `main` @ `5dde1bcf9` (Debug, "MobileCatchup Capture" simulator — iPhone 17 Pro, iOS 27.0; Study voice by launch argument, light appearance; library seeded by `VM44CaptureSeedTests`, signed out, Standard protection, never Castle). Screens are under `atlas/screens/`. Each finding names the capture that shows it. "Instrument" lines are about the throwaway driver, not the app.

## App findings

### W1 — Typing on past Return in the quick-entry box LOSES words and drops the rest at the note's START (bug — data-shaped)
`findings/W1-return-mid-typing-loses-words.png` and `findings/W1-same-note-after.png` (first walk pass, copied out before the re-run overwrote `22-…`/`24-…`).
The walk typed `Walk note: the ferry timetable changes in December` into the box, then `\nsecond line, to see the box grow` in ONE `typeText` (XCUITest types at a steady fast human-ish rate). Return in the box is the "⏎ opens it" door, so the note opened mid-typing. Result in the opened note: `, to see the box grow|Walk note: the ferry timetable changes in December` — the words `second line` typed during the box → note hand-off are GONE, and the remainder landed at offset 0, BEFORE the box's text, with the caret left between them. A fast typist who presses Return to open and keeps typing meets the same thing. Ties directly to her "significant lag … when going from the quick entry box into a note". (The later walk passes type a wrapped line instead of Return so the box's two-line state is captured too.)

### W2 — The shelf's books list runs underneath the quick-entry box (layout)
`10-shelf-rest.png`, `findings/W3-new-book-hidden-under-box.png`, `20-quick-entry-at-rest.png`: the last visible row ("Manuscript · 1 note · #draft") is sliced through by the box's dashed border — no gap, fade or clip. Focused (`21-quick-entry-focused-keyboard.png`), the box's top border runs straight through the "Running log · 4 entries · #run" row's text. Her "the box looks awkward".

### W3 — `+ New Book` is unreachable without scrolling the bounded list to its end
`10-shelf-books-scrolled.png`: the door is the LAST row of the books region, below 23 books; at rest it is hidden under the quick-entry box. The walk's first tap at it landed on nothing (driver log `NOT-HITTABLE + New Book`).

### W4 — The cream room stops at the safe areas
Every root screen (`10-shelf-rest.png`, `30-library-rest-all.png`, `14-starred-page.png`): a WHITE strip behind the status bar and another below the tab bar (home-indicator zone), with the cream room only between them. Reads as two pale bands framing the app.

### W5 — Indistinguishable rows: duplicate book names across wings, and date-titled notes
`10-shelf-rest.png`: two "Ideas inbox" rows (two wings' legal twins) side by side, nothing telling them apart. `30-library-rest-all.png`: three Library rows that read only "2026-11-12" (quick notes and journal entries are titled by their day), no body preview on any row. Her "showing preview more like apple notes so i know what each note is".

### W6 — Library search finds TITLES only (confirmed)
`33-library-search-lighthouse.png`: "lighthouse" returns two rows (The Lighthouse Keeper · Lighthouse service records), although the seed's Fiction wing holds notes and a scrap with "lighthouse" in their text. The Mac's search is full-body. Settled by `33-library-search-body-word-ferry.png`: "ferry" returns **"Nothing found."** although at least four notes carry "ferry" in their body (the walk's own quick notes, "Walk note: the ferry timetable…", titled by their day). Also `80-note-sealed.png`: that note's body has "like birds to a lighthouse", and it was not among the "lighthouse" hits. With every quick note titled by its date (W5), a title-only search cannot find what she wrote on the phone.

### W7 — A book's count includes an archived member its list hides (observation)
`40-book-essays-contents.png` lists 7 notes; `10-shelf-rest.png` and `41-book-details-sheet.png` say "8 notes"; Read says "note 1 of 7" (`42-book-read-view.png`). The seed archived one Essays member; the count counts it, the list hides it, and nothing on the phone says so. The pinned membership carries no mark either.

### W8 — Read view: the floating back button sits over the prose
`42-book-read-view-scrolled.png`: scrolled, the glass back circle overlays the first visible lines of text (no top inset or fade).

### W9 — THE PALE BAND, confirmed: the keyboard bar's three buttons sit on a full-width white strip
`60-editor-keyboard-bar-rest.png` (also `findings/W9-keyboard-bar-crop.png`). The note's room is `#FAF8F3` (cream); from the bar's top edge to the keyboard the strip is pure `#FFFFFF` across the whole width, ~50 pt tall, with the three glass circles (Aa · ⑂ · ⋯) floating on it. This is the `UIToolbar`-as-`inputAccessoryView` backdrop Phase A predicted (F6). Her words: "a whole pale band around the quick click buttons rather than just the buttons themselves". The same white shows behind the status bar and under the tab bar (W4) — the app never paints the safe areas or the accessory's backdrop in the room colour.

### W10 — Tiny affordances in the note: the ⑂ badge, the corner icons, the chips, the formatting strip
`50-note-write-rest.png`: the fanned block's ⑂ badge in the right gutter is a faint glyph a few points high; the corner doors (copy · find · seal · ⋯) are small grey glyphs; the chip row (no date · #essay #goals · more info · blocks · lens) is small muted text with no button shape. `60-editor-keyboard-bar-rest.png`: the bar's ⑂ is a hairline glyph inside a 44 pt circle. `61-editor-formatting-strip.png`: eleven acts (× B I S ⟨⟩ link # • ☑ ⇥ ⇤) packed into one capsule at small size and low contrast; the link glyph renders larger than its neighbours. Her "many of the button affordances are absolutely tiny".

### W11 — Wings leak as duplicates everywhere a list crosses them
`51-note-membership-sheet.png`: "Add to a book" lists every wing's books in one flat list, "Ideas inbox" twice. `52-note-tags-sheet.png`: "Apply a tag" shows `#draft` twice and `#idea` twice (per-wing tag twins), with nothing telling them apart. Same root as W5 / Phase A's F4.

### W12 — Blocks sheet in picking mode shows two "Done" buttons side by side
`54-note-blocks-picking.png`: the header reads "Done Done" (the picking mode's done and the sheet's done, same word, adjacent).

### W13 — The takes peek pill covers the next paragraph's first line
`71-takes-peek-pill.png`: the `‹ take 2/3 · warmer › ✓` pill sits on top of "To Sherlock Holmes she is" — the start of the following block's text is hidden while peeking.

### W14 — A finished book still offers `+ New Note` and `+ New Chapter`
`47-book-finished-letters.png`: Letters ✓ (Finished — assembly frozen) renders both doors exactly as an open book does. Not pressed (pressing could mint); a door that can only refuse is shown.

### W15 — Waiting arrivals are invisible on the phone (confirms Phase A F4)
`46-book-ideas-inbox-arrivals.png`: the Ideas inbox book with 3 waiting arrivals (seed summary: "arrivals waiting: 3") shows its three members and nothing else — no count, no mark, no door.

### W16 — Settings is a non-scrolling stack: at default text size it happens to fit; a swipe does nothing (Phase A's F7, partly confirmed)
`90-settings-sheet.png` and `90-settings-sheet-swiped.png` are identical: the swipe-up moved nothing. On this 6.3-inch iPhone 17 Pro at the default Dynamic Type size every row is on screen, down to the Debug-only `TK2 Spike` door, with ~150 pt to spare — so nothing is unreachable TODAY at this size. The large-text check (`96-settings-xxxl-text*.png`) shows whether the lower rows fall off once the text grows. The sheet also shows every Debug leftover Phase A listed (F8): Diagnostics ▸ Record edit trace / Edit trace…, Tutorial (dev store), Performance (dev store) ▸ Seed the 100k fixture, TK2 Spike.

### W17 — On the dev-store Debug build the Settings Sync row has no door at all
`90-settings-sheet.png`: the Sync section reads "Sync off (dev store)" and nothing else; the only sign-in door is inside Protection… (`95-protection-screen.png`: "This library doesn't sync. Sign in to turn on sync. Sign in…"). Expected for the fenced dev store; noted because the inventory expected a Settings sign-in row.

### W18 — THE LAG, on camera: box → note freezes mid-push for ~0.7 s, then a second keyboard slides in
`recordings/rec-02-quick-entry-to-note.mp4` (raw clip, 23.3–24.6 s) and `findings/W18-quick-entry-to-note-hitch-frames-10fps.png` (14 frames at 10 fps). After `open ↵`: at 23.6 s the box's keyboard is already gone and the note has slid half-way in, the shelf still showing on the left; the frames from 23.6 s to 24.3 s are IDENTICAL (the push animation stalls), then the note snaps to full width and a fresh keyboard slides up from below. On a simulator on an M-class Mac; a phone will differ, but the shape (keyboard torn down and rebuilt, the push stalled while the editor mounts) is the "significant lag … from the quick entry box into a note". By contrast, tapping INTO the box (`rec-01…`, ~19.5 s) expands the box and raises the keyboard within one 0.5 s sampling frame, and the 40k-word note (`rec-03…`, ~25 s) opens with its text drawn inside the push — no stall seen on either in the simulator.

### W19 — The chrome ignores Dynamic Type: at XXXL text nothing but the prose and book titles grows
`96-settings-xxxl-text.png` vs `90-settings-sheet.png`: identical — every Settings row the same size at the largest standard text size (the driver logged the "Edit trace…" door's frame as 14 pt tall at XXXL). `96-shelf-xxxl-text.png` vs `10-shelf-rest.png`: the book titles grew (and now truncate, "The Lighthouse K…"), while the path line, `+ New Note`, `Settings`, the row meta, the quick-entry hint and the tab bar stayed exactly as small. So the "weirdly tiny font" cannot be rescued by the system text size: the chrome's small size is fixed (Phase A's F5 — `tokens.small`). It also means Settings (W16) "fits" at every text size only because its text never grows.

### W20 — Archived BOOKS have no home on the phone
`35-archive-room.png`: the Archive room lists two archived notes, with facets "All · Notes" only. The seed archived one book ("Old projects", seed summary "books archived: 1"); it is (correctly) off the shelf and appears nowhere else — not in the Archive room, not in Library ▸ Books (`31-library-filter-books.png`). Matches the plan's 4d row ("the archived-BOOKS group … her 2026-10-04 walk met exactly this hole").

### W21 — The New Block Below receipt has no Undo
`65-editor-structural-receipt-undo.png`: after ⋯ ▸ New Block Below the receipt line reads "New block added below — type away." and offers no `Undo` door (the inventory expected a bare Undo on the receipt row). `65-editor-after-undo.png` is therefore the same state, and the empty block stays in the note (`66-editor-keyboard-down.png`). Undo may live only in ⋯ Note Actions (its Undo/Redo rows).

### W22 — Small vocabulary drift: "Unpin from Shelf Top"
`11-shelf-book-longpress-menu.png`, `11-shelf-journal-longpress-menu.png`: the shelf's long-press menu still offers "Unpin from Shelf Top" beside "Unstar"; on the Mac the Pin door was retired into Star/Unstar (AppSpec §9, the union star).

### W23 — Prose slides under the pinned masthead with a hard cut
`81-long-note-scrolled.png`: scrolled, the masthead (title · chips) stays pinned and the first visible prose line is sliced in half at the chip row's edge — no inset, fade or divider. The Library list does the same under its filter row (`30-library-scrolled-1.png`).

### W24 — Dark mode: the pale band and the white strips vanish (they are system backgrounds, not the room)
`variants/60-editor-keyboard-bar-rest--study-dark.png`, `variants/10-shelf-rest--study-dark.png`: in dark the keyboard bar's strip, the status-bar zone and the home-indicator zone all sample pure `#000000`, the same as the fully black room, so the band reads as part of the room. In light they are `#FFFFFF` against the room (W4, W9). So the fix is to paint those zones in the room's colour; dark only hides the problem by coincidence. Every surface walked honoured dark (shelf, box, Library, note, keyboard bar, formatting strip, Settings); none stayed light.

### W25 — Terminal light has the same band and strips, and truncates more
`variants/60-editor-keyboard-bar-rest--terminal-light.png`: Terminal's room is `#F6F6F1`; the bar's strip and both safe-area zones are `#FFFFFF`, the same band as Study. Terminal's monospace chrome is lowercase and as small as Study's; it also truncates sooner: shelf titles "the lighthouse ke…", "interview transcri…" (`variants/10-shelf-rest--terminal-light.png`), the note title "On keeping a commonp…" (`variants/50-note-write-rest--terminal-light.png`).

### W26 — Dark mode contrast: the muted chrome is dim grey on black
`variants/10-shelf-rest--study-dark.png`, `variants/90-settings-sheet--study-dark.png`, `variants/50-note-write-rest--study-dark.png`: the path line, the row meta, the chip row and the Settings section labels are small dim grey text on black — readable on a screenshot at full size, but they compound W19's fixed small size; the prose and titles are the only high-contrast text. (By eye from the captures, not a measured contrast ratio.)

## Instrument notes (the driver, not the app)

- **The first walk pass pressed Return inside a seeded note (instrument damage, throwaway sim data).** Its keyboard-dismiss fallback tapped the keyboard's Return when a drag could not dismiss it — and in `test06_editor` the heading menu was still open, so the drag failed and Return landed in "On keeping a commonplace book", splitting its second paragraph at "He was, I ⏎ take it" (`66-editor-keyboard-down.png`, then visible in `70-…`, `71-…`). `test07_takes` ended with the same fallback, so that note may carry one more split. The driver now never presses Return with an editor on screen. The note still serves every capture; only its paragraphing differs from the seed.
- **Status-bar taps dismiss nothing.** The original `dismissMenu()` tapped at the top of the screen; context menus stayed open and blocked the next steps (the first pass's `11-shelf-journal-longpress-menu`, `36-trash-room*`, `64-…`, the formatting × and the block ⋯ menu). Fixed (the dimmed backdrop low on the screen; in the editor, the masthead band).

- **The band keeps all three pages alive, so naive XCUITest queries hit off-screen copies.** Starred, Shelf and Library each render their own tab bar, path line and doors, offset a screen-width apart and clipped (`MobileShellView.swift` — "no paging container, deliberately"). `firstMatch` on "Library" resolved to the Starred page's copy; the first FirstRun pass therefore captured the Shelf three times. Fixed in the driver (`onscreen(_:)` picks the first on-screen, hittable match). Not an app bug, but a later XCUITest suite on the phone needs the same rule.
- **The seeder's xcodebuild hangs after the test ends.** The hosted test finished in 4.7 s (summary written), then `xcodebuild test-without-building` sat idle for 3+ minutes and was stopped by hand. The test "fails" on `@Dependency(\.date) has no test implementation, but was accessed from a test context` (`Date.swift:37`) — the issue the runbook predicted; the seed itself completed.
- **What the walk itself added to the seeded store (state for the secondary passes).** Quick notes from the walk and recordings, each titled by its day: "First note, typed on the phone" (first run), two "Walk note: the ferry timetable…" notes (first pass and re-run), "timing the quick entry", "from quick entry into the note"; today's journal entry (Extras ▸ Today's Entry — journal now "14 entries"); one empty block below the first block of "On keeping a commonplace book" (New Block Below, receipt had no Undo) and the paragraph split above. Every destructive door was opened and CANCELLED (Delete Book, Delete Note ×2, Empty Trash) — nothing deleted, nothing purged. Never signed in; Sync never pressed; the library stayed Standard (no Castle surface opened).
- **Driver misses left as misses:** `+ new scrap` (C7) and `+ add a link` (E4) were not found as buttons, and a Trash row's `Delete Now` is not exposed as its own button (C16's per-row confirm). Probably label/role shapes (a `Text` inside a tappable row); not chased in the primary pass.
