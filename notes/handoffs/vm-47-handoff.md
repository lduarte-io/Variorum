# VM-47 — Sizes and look: your handoff

**Final but for the merge.** Brought up to date 2026-11-20, after the merge gate's test runs. Three things are still
written `‹PENDING: …›` below and are filled as the run merges: the merge gate's last run (the whole phone suite once
more, on the exact code that merges) · the PR and its merge commit · the wave-1 phone build this run prepares for you.

*How to read this file:* **VM-NNN** and **VX-NNN** are tickets on the board. **P-47-N** is a provisional call — built
the most defensible way while you were away, waiting for your word. **R-47-N** is one of your rulings from this run. A
**test window** is a test run on the shared Mac, granted by the stage coordinator. The **review** is the cold code
review, a fresh reviewer each round. The **walk** is the simulator session that photographed every screen this run
changed. A **capture** is one of its screenshots, named `<palette>-<voice>-<light|dark>-<default|ax5>--<id>-<what>.png`
— for example `seaglass-study-light-default--c1-bookcase-rest.png`; "ax5" is the largest accessibility text size. They
are in four folders (checklist item 1): a capture named below without a folder is the walk's, in `final/`, and the later
folders hold the same names where a screen was shot again. The record behind everything here is
`notes/plans/vm-47-sizes-and-look.md`; its FOR A LATER READER section is the short version.

---

## Your checklist

- [ ] **1. The walk's screenshots are kept for you.** The closeout normally deletes a merged run's walk screenshots
  (your rule from the 13x closeout), but the questions below point at them, so they stay until your sitting. After the
  merge they are on the Pro in the main checkout's `notes/plans/vm-47-screens/` (kept out of the repo), in four
  folders: `final/` (the walk), `recapture/` (after the first fixes), `e4-before/` (the typing problem on the first
  edge fix — "What shipped" tells it) and `final-tree/` (the code that merges). Say "delete the screens" when you are
  done with them.
- [ ] **2. The one phone install for wave 1** — yours, from merged main, after all four mobile runs have merged. This
  run merges last of the four, so it prepares it: ‹PENDING: the Release device build of merged main, its signing
  check, main's sync version against production's, and the paste-ready block for the session that helps you install
  (`notes/plans/vm-44/plans/vm-45-install-runbook.md`)›. Your words (2026-11-19): "the phone step is the single wave-1
  install after all four runs have merged. whoever is last can probably do it overnight over wifi." and "agreed, i'll
  do the hands part in the morning." The runbook needs you at the phone: unlocked and awake for the safety copy and the
  install, Variorum fully quit first. **What to try first** — typing low in a note with the keyboard up — is the top
  of "The phone, first look" below.
- [ ] **3. Your sitting's questions** — forty-one provisional calls, grouped, most consequential first, in "Your
  questions" below. They are QUESTIONS #281. The ones marked *(your phone)* are best judged at true size in your hand.
- [ ] **4. The wording pass** — every new line this run put on the phone, in "The wording pass" below.
- [ ] **5. Held for your hands** — two screens no screenshot has shown (the Account sheet and the timing readout), your
  glance at which Protection door stayed, and the palette row when you want it ("Held for your hands" below).
- [ ] **6. One remainder, now on its own ticket (VM-249, waiting on you)** — Settings opens from the three home pages and
  from a note, but not from a pushed list, a book's Read page or Protection. Say whether that is fine as built (VM-53's
  own text says "from every root and from a note") or wants a door on those screens.
- [ ] **7. The tickets filed** — three, at the bottom.
- [ ] **8. The run's size, for your awareness:** the umbrella held more than two phase-sized pieces of work (the
  phone-wide type pass, the controls, the palette). You approved the composition as a run ("22 is fine, composition is
  fine.", 2026-11-15), so it ran as five batches in a row, one builder each, with one review over the whole — raised
  here as the sizing guidance asks, not split.

## The phone, first look

When the build is on your phone, these are the things this run changed, in the order worth checking:

0. **Typing low in a note, with the keyboard up — try this first.** Open a long note, tap a line in its lower half so
   the keyboard comes up, and type a few letters. The note should scroll that line up above the keyboard's bar, and
   your letters should show there. One of this run's fixes once broke exactly this ("What shipped" tells it); it is
   mended and held by a test, and this is the one behaviour worth checking in your hand.
1. **The bottom bar.** Starred · Bookcase · Library, the current one on a chip. It now also shows on a book's
   contents, the Trash, Archived and Versions' list; tapping a tab from one of those takes you to that page's start.
   It never shows inside a note.
2. **The Bookcase's top line.** "Home · Bookcase · N books" (your R-47-3), then 🗑, "+ New Note" and ⋯. With your real
   number of books, see whether the count is cut on your phone's width (P-47-27).
3. **Settings.** From the ⋯ on any of the three home pages, or from a note's ⋯ sheet. One list that scrolls; Look ▸
   Voice (writes your library's voice) and Look ▸ Appearance (follow the system, light or dark — this phone only).
4. **Your library's colours.** The phone now wears the palette your library has on the Mac (sea-glass unless you chose
   another), and the voice your library has (Study for a fresh library). Your words on the paper (white in Study light), the
   bars and sheets on the tinted room, and each screen's colour running to the very top and bottom of the glass. Two
   small things that came with that, both yours to judge (P-47-43, P-47-44): a book's Read page cuts its last line at
   the bottom edge, as it did before this run; and when you move between a list and a note, the strips at the top and
   bottom change colour at once rather than sliding with the page.
5. **Sizes and taps.** Text at 13 · 15 · 17 · 20 · 24; every button answers across a fingertip (44 points) even where
   it looks small. If you use a larger text size, your words grow and the app's chrome stops growing at the largest
   standard size.
6. **Two screens no screenshot has shown:** the Account sheet (Settings ▸ the sync row ▸ Account, or Protection's
   sign-in) and the timing readout (Settings ▸ Diagnostics ▸ Timing…, the timing run's, drawn in this run's sizes and
   colours). Neither has been seen with this run's look, so your look is their first sight.
7. **While sync is paused for keys** (locked or not yet joined): Settings should say the sync sentence and show one
   "Protection…" row, not two (VM-27). The walk could not reach that state.
8. **A light/dark switch with a note's takes open:** the take cards' and the comment draft's edges should change with
   it (VM-54).

## Your questions (QUESTIONS #281)

Each says what you would see, the options, what is built, and where a capture shows it. The captures are kept for
your sitting (checklist item 1); the record's walk file (`notes/plans/vm-47-walk.md`) also describes each one in words.
Three calls are new since the walk's first reading — P-47-42 (the dark take tint) under "Grounds and colours", and
P-47-43 and P-47-44 under "The screen's edges", both from the fix that was redone.

### Sizes and numbers

- **P-47-1 — the sizing sheet's numbers, as a set** *(your phone)*. Every size on the phone comes from the sizing
  sheet you saw in use: text 13 · 15 · 17 · 20 · 24, a 44-point minimum for anything tappable, a 20-point margin, the
  spacing steps 4 to 48, rows 44 to 88 tall, the two readable greys. Options: keep the sheet's numbers · give your own
  where one feels wrong. **Built:** as drawn — you have seen the sheet, not ruled it number by number. Captures:
  any; start with `c1-bookcase-rest`, `c3-library-rows`, `c5-note-write`.
- **P-47-4 — "Terminal two points smaller"** *(your phone)*. Terminal's prose sizes sit two points under Study's: the
  note 15 (Study 17), its title 22 (24), a screen title 18 (20), a row 15 (17), a preview 13 (15), and the line spacing
  two under as well. Options: (a) sizes and line spacing both two under · (b) sizes two under, line spacing kept in
  proportion · (c) only the note, its title and screen titles smaller, rows at Study's sizes. **Built:** (a). Captures:
  `seaglass-terminal-light-default--c5-note-write` beside `seaglass-study-light-default--c5-note-write`.
- **P-47-21 — the bar's drawn numbers** *(your phone)*. Each cell a third of the width and at least 56 tall (your
  LK-5), growing to about 60 at the largest standard text size and holding; the chip 8 points above and below the word
  and 16 at each side (narrowing to 8, then 4, where a cell is tight), corners 12 (the mockup draws 9); the other two
  words in the readable grey. The bar stays above the keyboard while the capture box or the Library search is typing
  — the mockup's "the bar leaves while the keyboard is up" belongs to the capture box's ticket (VM-73). Options: as
  built · the mockup's 9-point corners, or any number you'd change. **Built:** as listed. Captures:
  `c1-bookcase-rest`, `b1-trash-bar-top-edge`, `b4-book-contents-bar-top-edge`.
- **P-47-12 — the note's top row** *(your phone)* (its rebuild is VM-148's). The four tools (copy, find, lock, ⋯) are
  now 22-point glyphs in ink, each its own 44-point target, side by side; the chips below are 44 tall. The cost: your
  title has 54 points less room and is cut sooner ("swipe & cho…"). Options: (a) as built · (b) the tools left at 17
  points in the faint grey with only a 44-point frame · (c) the chips as 32-point capsules in one row (VM-148's
  rebuild). **Built:** (a). Captures: `c5-note-write` (all eight).
- **P-47-8 — which size each kind of text took.** Where a spot could have taken either of two sizes, the smaller was
  taken: the home pages' top lines at 13 (not 24), a book's name in Book Details at row size, a comment's words at 15,
  the sentences on the lock and Protection screens at 15, section labels at 13, the message line's words at 15, the
  wing list's names at 17, and the timing readout's text at 13 (in Study that is no longer a fixed-width face — the
  readout never lines up columns, so nothing breaks, but it reads differently from what the timing run drew). Options:
  as built · name any you'd like larger. **Built:** the smaller each time (the full list is the record's batch-1 role
  map). Captures: any (no capture opens the readout).
- **P-47-7 — the Library's filter row at 13 points.** All · Notes · … five words on one line. It fits at 375 and 402
  points wide in both voices; on the narrowest setting (320 points, Display Zoom) Terminal cannot fit all five at 13,
  so the last words are cut — never drawn under 13 — and at the largest text size in Terminal "bookless" shrinks a
  little. Options: (a) 13-point words · (b) 15-point chips (the sheet's word for filters; they shrink at 375 in
  Terminal) · (c) a row that scrolls (you declined that before, #92(b)). **Built:** (a); the row's rebuild is VM-93's.
  Captures: `c3-library-rows` (all eight), `seaglass-terminal-light-ax5--c3-library-rows`; 320 points cannot be
  captured on the simulator.
- **P-47-10 — the filter row stays as words.** Options: (a) the five word doors and the sort glyph, each 44 tall, as
  wide as their words · (b) the system's segmented control (wider per word; Terminal would no longer fit at 375 and
  #92(b) breaks) · (c) chips in a row that scrolls. **Built:** (a). Captures: as P-47-7.

### Grounds and colours

- **P-47-16 — the note in Write sits on the paper** (white in Study light; the palette's hued paper in dark), as the
  Mac's editor does, under your R-47-1. Options: (a) the paper · (b) the voice's own off-white room under every palette
  (never the tint, but not the paper). **Built:** (a). Captures: `c5-note-write` (all eight),
  `teal_rust-study-dark-default--c5-note-write`.
- **P-47-17 — the note's top on the same paper.** Your title, the tools and the chips are one strip. Options: (a) the
  paper, one ground with the note · (b) the library's tinted room (your title would sit on the tint in light) · (c) the
  title on the paper and the tools on the room (needs VM-148's rebuild). **Built:** (a). Captures: `c5-note-write`.
- **P-47-15 — what the phone wears before a library opens** (the lock screen, the twelve-words card, the "library
  missing" face, and the first instant after launch). Options: (a) the Mac's own placeholder, Terminal in its plain
  colours · (b) Study under the sea-glass — what a library that has chosen nothing wears · (c) remember the last
  library's look on this phone. **Built:** (b). No capture: the walk's library never locked.
- **P-47-5 — the faint grey in dark.** The faint (for glyphs, hints and edges) is lifted in dark so it clears 3:1 on
  every palette's dark ground: Study #766F5F, Terminal #6B7168. Options: (a) as built · (b) the sheet's #736C5D, which
  measures 2.91:1 on teal & rust's dark card. **Built:** (a). Captures: `seaglass-study-dark-default--c1-bookcase-rest`
  (the box's hint), `teal_rust-study-dark-default--c1-bookcase-rest`.
- **P-47-29 — the note's chips' colours.** After the walk's fix: a chip that is set (a date, tags, more info) in ink,
  an empty one in the readable grey; the active lens keeps the accent; the "in ‹book›" chip and the blocks chip stay
  grey. Options: (a) as built · (b) the one-book "in ‹book›" chip in ink too · (c) set chips grey as well, so set and
  empty differ only by their words. **Built:** (a). What the re-capture shows: in the pocket guide's lesson only the
  tags chip is set, so "#pocket guide" alone is in ink, and the date, more info, lens, blocks and "in ‹book›" words all
  read the same grey. Capture: `recapture/` `c5-note-write` (Study light and dark, Terminal dark).
- **P-47-30 — the segmented choices' grey words** (Voice, Appearance, Create Book's kind, the block list's views). The
  unchosen words sit on iOS's own grey track and read 4.44:1 in light and about 4.1:1 in dark — just under the 4.5:1
  the sheet asks. The track is iOS 26's own drawing; nothing short of a hand-built control recolours it. Options: (a)
  as built · (b) the unchosen words in ink (chosen and unchosen would then differ by the white thumb and the weight
  only) · (c) a hand-built control with a track in the palette's colours (iOS 26's glass selection would be lost).
  **Built:** (a), nothing changed. Captures: `r05-create-book`, `r05b-create-book-smart`, `r07-blocks-sheet`,
  `r07b-blocks-leaving`, `k1-settings-top`.
- **P-47-37 — a disabled button reads 1.65:1.** "Create Book" before a name is typed is the whole button at 35%: its
  word reads 1.65:1 in Study light, 2.09:1 in Terminal dark. Options: (a) as built — the Mac's 35% dim · (b) the word
  in the faint grey at full strength, its shape kept · (c) show the button only when it can act. **Built:** (a).
  Captures: `r05-create-book`, `r05b-create-book-smart` (Study light default, Terminal dark default, Study light ax5).
- **P-47-41 — warning words in orange.** The shared pages' warning lines on the phone — the sync row's paused states
  (keys locked, keys replaced, an account mismatch, stalled) and the Account sheet's warnings — are iOS's orange, about
  2.2:1 on the paper, under the 4.5:1 the sheet asks for small words. Options: (a) as built · (b) a warning colour of
  the phone's own, made to clear the floor in every palette (the Mac unchanged) · (c) the alarm red (a paused state
  would then read as an error). **Built:** (a). No capture shows it.
- **P-47-35 — a callout on teal & rust's dark paper** (a choice for both Mac and phone under (b)). The callout's blue
  wash is 1.05:1 against that paper, so the frame reads by its blue and its 💡 alone; its words stay clear. It is the
  Mac's own wash; what moved is the ground, since your words now sit on the hued paper. Options: (a) as built · (b) the
  dark washes stepped away from the paper on every palette, Mac and phone alike · (c) a hairline edge on a callout in
  dark. **Built:** (a). Capture: `teal_rust-study-dark-default--c7-callout-comment`.
- **P-47-42 — a peeked take in dark is a shade darker than the paper** (the same cause as P-47-35). When you swipe a
  block to peek at another take, its tint is 1.03:1 against the dark paper — a band the eye barely finds; what marks
  the peek is its thin left edge, and your words over it stay clear. These are the sizing sheet's own dark values; what
  moved is the ground, since your words now sit on the hued paper (on the old black room the same tint read lighter
  than its ground). Options: (a) as built · (b) the dark take tint a step lighter than the paper, so a peek reads as a
  raised band like the take cards · (c) a heavier edge in dark only. **Built:** (a). Captures: `recapture/` and
  `final-tree/` `seaglass-study-dark-default--c6-note-peek-take-tint` and `seaglass-terminal-dark-default--c6-note-peek-take-tint`.

### The screen's edges (from the fix that was redone)

- **P-47-43 — a book's Read page cuts its last line at the bottom edge again** *(your phone)*. Under the redo the page
  stops at the bottom of the safe area, exactly as before this run: at rest its last visible line shows about
  three-quarters of its height and the strip below is the Read page's own colour. The first edge fix had let the page
  run on to the very bottom with both lines whole — the same freedom that broke typing in a note. Options: (a) as built
  — as before this run · (b) the first fix's look on the Read page alone, its page running on behind the home bar (it
  would need that one page let past the frame at the bottom, with its own test beside the keyboard test). **Built:**
  (a). Captures: `final-tree/seaglass-study-light-default--b5-book-read-no-bar` (and `r04-book-read`), the first fix's
  look in `recapture/`.
- **P-47-44 — the top and bottom strips change colour at once when you move between pages** *(your phone — it is a
  motion)*. Each strip is one colour across the width. When you open a list or a note from a home page, or go back,
  the strip takes the new page's colour at once and does not slide with the page, so for the slide's third of a second
  part of a strip above the page going away wears the arriving page's colour — never white or black, never another
  page's. The first edge fix had each page's colour slide with it. Options: (a) as built · (b) a fade between the two
  colours during the slide (not built: it would show a third colour neither page wears) · (c) each page's colour
  sliding with it, as the first fix drew (it needs each page drawn past its frame again, the road the redo closed).
  **Built:** (a). No capture: none was caught mid-slide.

### The top line, the bar and the message line

- **P-47-27 — what gives way on the Bookcase's top line** *(your phone, with your real book count)*. The line holds
  the wing's name (a door), "Bookcase", the count, then 🗑, "+ New Note" and ⋯, all on one line with every target 44
  points. Where it cannot fit, the text is cut at its end: the count goes first, the wing's name last. Seen: Study at
  the default size reads "Home · Bookcase · 3 books" whole with about 5 points to spare (a two-digit count would be
  cut; the walk's library held 3 books); Study at ax5 "Home · Bookcase..."; Terminal at the default size
  "~/home/bookcase ·…"; Terminal at ax5 "~/home/book…" (the page word itself cut). Options: (a) cut at the end · (b)
  cut the middle (keeps the wing's name and the count) · (c) let the line wrap to two in Terminal · (d) "+ New Note" as
  a glyph, freeing about 50 points (loses its word). **Built:** (a). Captures: `c1-bookcase-rest` (all eight),
  `seaglass-terminal-light-ax5--c3-library-rows`, `seaglass-study-light-default--s05-voice-flipped-bookcase`.
- **P-47-9 — the top line's doors.** 🗑 a glyph button, "+ New Note" a 15-point word (Settings has since moved into
  the ⋯). Options: (a) as built · (b) all glyphs (loses the "+ New Note" word) · (c) words at 15 with the path cut.
  **Built:** (a). Captures: `c1-bookcase-rest`.
- **P-47-31 — the trash door is a colour emoji.** 🗑 is Apple's grey-blue emoji beside the accent "+ New Note" and ⋯;
  the grey tone cannot tint it, where the sheet draws a glyph in ink. Options: (a) keep the emoji · (b) a plain
  monochrome trash glyph in grey or ink. **Built:** (a). Captures: `c1-bookcase-rest`, `c3-library-rows`,
  `k0-bookcase-menu-open` (all eight).
- **P-47-18 — where the bar shows beyond "Roots and lists, not notes".** On the three home pages and the pushed lists;
  not on a book's Read page, a saved version's reader or Protection. Options: (a) as built · (b) every pushed screen
  except the note (Read, the reader and Protection too) · (c) Protection with the bar except while new twelve words
  are on screen. **Built:** (a). Captures: `b1-trash-bar-top-edge`, `b8-versions-listing-bar`, `b12-archived-bar`,
  `b5-book-read-no-bar`, `b9-versions-reader-no-bar`, `b13-protection-no-bar`.
- **P-47-19 — a tab tapped from a pushed list** *(your phone — it is a motion)*. The list you leave goes back to its
  page's start as the page slides away, then the page changes; tapping the current tab pops back to its start. So a
  page out of sight always stands at its start. Options: (a) as built · (b) each page keeps its place, as the system
  tab bar does (a swipe could then land on a pushed screen, and a note under a list would stay open out of sight).
  **Built:** (a). Captures: `b2-library-from-trash`, `b3-bookcase-root-after`, `b7-bookcase-from-its-book`,
  `b10-bookcase-from-versions`, `b11-library-root-after`.
- **P-47-20 — the empty system bar above pushed screens.** Kept on every pushed screen: it is the back button and both
  swipe-backs, and every later mockup keeps that row; each screen's own ticket fills its row as its mockup draws it —
  VM-148 (the note), VM-122 (a book's contents and Read), VM-100 and VM-99 (the Trash and Archived), VM-110
  (Protection), VM-147 (Versions). Options: (a) keep it · (b) hide it and put a back button in each screen's header
  (with the bar hidden the edge swipe-back has historically stopped working) · (c) the screen's title in the system bar
  and the app's own title line dropped. **Built:** (a). Captures: `b1-trash-bar-top-edge`,
  `b4-book-contents-bar-top-edge`, `b5-book-read-no-bar`, `b6-note-from-book-no-bar`, `b8-versions-listing-bar`,
  `b9-versions-reader-no-bar`, `b12-archived-bar`, `b13-protection-no-bar`.
- **P-47-36 — the message line wraps to two lines.** "Note moved to the Trash — 30 days to put it back." takes two
  lines (63 points), where the sheet draws one 44-point line. Its place above the bar, its colours and its Undo match.
  Options: (a) as built — the line grows by lines · (b) one line, cut at its end (cuts the 30-day promise) · (c)
  shorter words in your wording pass, so the common lines fit one line. **Built:** (a). Captures:
  `seaglass-study-light-default--m1-line-library-root`, `--m2-line-over-trash-bar`, and the same two in
  `seaglass-terminal-dark-default--`.

### Settings and its words

- **P-47-22 — the ⋯ on the home pages is iOS's own pull-down menu** *(your phone)*, one item today (Settings); later
  runs add their doors to it. In Terminal its item says "settings" in iOS's own face, not Terminal's mono. Options: (a)
  the system menu · (b) a sheet of rows, like the note's ⋯ · (c) the ⋯ opens Settings directly until a second item
  exists. **Built:** (a). Captures: `k0-bookcase-menu-open` (all eight), `s01-starred-menu-open`,
  `s02-library-menu-open`.
- **P-47-23 — where Protection opens.** On the screen you are on; Back returns you there (over a note if you came from
  one). Options: (a) as built · (b) on the Bookcase after a tab change (a note you came from closes) · (c) inside the
  Settings sheet, as the lock mockup draws (S1) — the larger change. **Built:** (a). Captures:
  `s03b-protection-from-library`, `s03c-back-on-library`.
- **P-47-26 — Settings' drawn parts** *(your phone)*. Every door is a row at least 44 tall that answers across its
  whole width, with no "›" and no value on the right (the mockup draws 52-point rows with "›" and values like "Castle"
  and "Study" — values the phone does not show yet); a choice is its label on its own line over the system's control;
  the sync row's doors sit under its line; the edit trace's on/off is a system switch; no foot line. Options: as built
  · the mockup's "›" and values once the values exist. **Built:** as listed. Captures: `k1-settings-top`,
  `k2-settings-swiped-1`, `k3-settings-swiped-2`, `r16-settings`.
- **P-47-24 — the appearance row's words.** The Mac's own row: "Appearance" · "Follow system" · "Light" · "Dark", with
  no line beneath it, as on the Mac. Options: (a) as built · (b) the drafted words: "System" for the first, and "Light
  or dark is for this iPhone only." under the row (with "Voice and palette belong to your library, so they change on
  every device." under Voice). **Built:** (a). Captures: `k1-settings-top`, `s06-appearance-dark-settings`.
- **P-47-25 — the list's names.** The group names "Library" (sync, Protection…), "Look" (Voice, Appearance) and "Help"
  (Acknowledgments) are drafts, beside today's "Tags" and "Diagnostics"; the voice choice keeps the phone's word
  "Voice", where the Mac's word for the same choice is "Theme". Options: (a) as built · (b) "Theme" for the voice ·
  (c) today's section words ("Voice", "Sync") as group names. **Built:** (a). Captures: `k1-settings-top`.
- **P-47-13 — sheet titles that were a grey path.** Settings, Acknowledgments and the edit trace keep their grey path
  title in the shared header; Create Book's Cancel takes Done's place in Done's weight. Options: (a) as built · (b) an
  ink title everywhere · (c) Cancel at regular weight. **Built:** (a). Captures: `k1-settings-top`, `r05-create-book`.

### The largest text size

- **P-47-14 — which size a field's typed text follows.** A field's text (a tag, a book's name, the search, a
  passphrase) is treated as the app's chrome: it grows to the largest standard size and holds, so a field stays one
  44-point line. Options: (a) as built · (b) your words' class — it keeps growing at the accessibility sizes, and
  fields grow past 44. **Built:** (a). Captures: `seaglass-study-light-ax5--c4-library-search` beside
  `seaglass-study-light-default--c4-library-search`.
- **P-47-32 — with the capture box open at the largest size, no book is left on screen.** The box's six-line floor
  counts lines at the current size, so at ax5 it takes the whole space (at the default size three books and "+ New
  Book" stay). Options: (a) as built — your rule that writing outranks the books · (b) cap the floor's line height at
  the largest standard size so a book row stays · (c) the floor gives one book row back at the accessibility sizes.
  **Built:** (a); the capture box's rebuild in wave 2 may change it. Captures: `seaglass-*-ax5--c2-bookcase-box-focused`.
- **P-47-34 — Terminal's Settings title at the largest size breaks after "~/".** "~/" on one line, "settings" on the
  next; the header about 140 points tall; nothing cut. Study's "Settings" stays one line. Options: (a) as built · (b) a
  path-shaped sheet title stops growing at the largest standard size · (c) one line, cut at its end. **Built:** (a).
  Captures: `seaglass-terminal-light-ax5--k1-settings-top` and its dark twin.
- **P-47-40 — Protection's state lines at the largest size grow like your words.** "You're in Standard." (about 47
  points) and "This library doesn't sync." (about 43), two lines each, beside doors held at about 23. These lines are
  the app's, not yours. Options: (a) as built · (b) the app's own state lines and sentences stop growing at the largest
  standard size · (c) the posture line keeps growing and the sync sentence takes the small chrome size. **Built:** (a).
  Captures: `seaglass-study-light-ax5--r17-protection`, `--r17b-protection-scrolled`, and their default-size twins.

### Terminal's lowercase

- **P-47-39 — Terminal lowercases your words on some screens and not others** (this predates the run). Versions' rows
  quote your note in lowercase ("takes are for trying; choosing is deciding…" where you wrote "Takes are for trying;
  CHOOSING is deciding."), and Starred reads "walk note" where the Library says "Walk note"; the Trash, the Blocks
  previews, take cards, Block History and Read keep your capitals. Study keeps them everywhere. Options: (a) as built ·
  (b) the app's own words lowercased and yours left as written · (c) no excerpt in Terminal's line. **Built:** (a).
  Captures: `seaglass-terminal-dark-default--b8-versions-listing-bar`, `--r10-versions`, `--r01-starred`,
  `--r14-trash`.

### Smaller look items

- **P-47-33 — the fields' caret is iOS's blue.** In the capture box and the Library search; the note's own caret and
  selection handles wear the accent. Options: (a) tint the fields with the accent · (b) leave iOS's blue. **Built:**
  (b). Captures: `c2-bookcase-box-focused`, `c4-library-search` (all eight), `teal_rust-study-light-default--c8-caret`.
- **P-47-6 — the capture box's hint at the larger size.** The hint shows the longest of its own shortenings that fits:
  the whole hint, "new note — just start typing", or "new note" — no new words. Options: (a) as built · (b) let it wrap
  (breaks your one-line-at-rest rule) · (c) new shorter words (the sheet draws "New note"; no draft exists). **Built:**
  (a); the capture box's rebuild in wave 2 may replace it. Captures: `c1-bookcase-rest` (Study default shows the whole
  hint, Terminal default the middle cut, ax5 "new note").
- **P-47-38 — the tag field's hint is cut mid-word.** "type a tag — ⏎ applies it ("/" nests: life/go…" at 17 points
  (Terminal cuts sooner). Options: (a) as built · (b) P-47-6's rule here — "type a tag — ⏎ applies it" · (c) new words
  in your wording pass. **Built:** (a); the hint's colour has changed since the walk, and the re-capture shows the cut
  standing at the same place — only its grey changed (`recapture/` `r06-tags-sheet`, Study light and Terminal dark;
  the largest size was not shot again). Captures: `seaglass-study-light-default--r06-tags-sheet`,
  `seaglass-terminal-dark-default--r06-tags-sheet`, `seaglass-study-light-ax5--r06-tags-sheet`.
- **P-47-11 — the Trash's seven kinds as chips** (All · Notes · Books · Blocks · Takes · Snippet groups · Originals),
  in a row that scrolls sideways: the chosen one on the wash in ink, the others edged and grey. Options: (a) as built ·
  (b) a segmented choice (seven words cannot share the width without cutting) · (c) a menu. **Built:** (a). Captures:
  `r14-trash`, `r14b-trash-notes-chip`.

## The wording pass

Every line this run put on the phone that you have not worded:
- **Settings' group names:** "Library", "Look", "Help" — drafts from the lock-and-protection mockup (P-47-25).
- **Settings ▸ Look ▸ Appearance:** "Appearance" · "Follow system" · "Light" · "Dark" — the Mac's own row (P-47-24).
- **"More"** — what VoiceOver calls the ⋯ on each home page's top line.
- **"Settings"** — today's word in two new places: a row in a note's ⋯ sheet, and the one item in the home pages' ⋯
  menu.
- **Gone:** the "Sync" and "Voice" section words (Voice is now the choice's own label), and "Recording edit trace — tap
  to stop" (the switch says it now). Create Book's "Smart Book" went at the merge of main ("Gathering" stands — the
  fixes run's word).
- **Shortened, no new words:** the capture box's hint (P-47-6).
- **Drafted, not built:** "Variorum for iPhone" (a foot line under Settings), "System", "Light or dark is for this
  iPhone only.", "Voice and palette belong to your library, so they change on every device." (P-47-24, P-47-26).
- **The timing readout's door and the readout** (Settings ▸ Diagnostics ▸ "Timing…"): their words are the timing run's
  (VM-64's — its readout's labels are drafts in its own bundle, QUESTIONS #280); this run only placed the door as a row
  in Diagnostics, after "Edit trace…", and drew both in the phone's sizes and colours.
- **Your ruled words, listed so you see them:** "Bookcase" on the bottom bar's middle tab (LK-5) and on the Bookcase's
  top line (R-47-3).

## Held for your hands

- **The wave-1 install** (checklist item 2), and on it the first thing to try: typing low in a note with the keyboard
  up ("The phone, first look", item 0).
- **The Account sheet's first sight:** its header and its seven fields' hints were put on the phone's sizes and
  colours in the walk's second fix batch; no screenshot and no test shows that sheet (a test cannot open it without
  the whole app, and the re-captures could not reach it either — the dev library's sync row has no Account door).
  Settings ▸ the sync row ▸ Account on your phone, in either voice.
- **The timing readout's first sight:** the timing run's readout (Settings ▸ Diagnostics ▸ Timing…) was drawn in this
  run's sizes and colours when the two runs were joined; no screenshot opens it.
- **The screenshots kept for you** (checklist item 1) — "delete the screens" when you are done with them.
- **Your glance at which Protection door stayed (VM-27):** the standing "Protection…" row stays; the sync row's own
  door is gone from Settings, so a paused sync says its sentence alone. The lock mockup's note says the same ("One
  Protection row, always").
- **The palette row** — a "Palette" row in Settings ▸ Look, which the lock mockup draws; filed as VM-247 for whenever
  you want it.

## What shipped

**Text sized for the phone (VM-48).** Most of the phone's chrome used the Mac's 11.5-point caption. Now every piece of
text has a role with a phone size (13 · 15 · 17 · 20 · 24) and grows with the system text size: your words — notes,
titles, rows, previews — across the whole range, the app's chrome up to the largest standard size and then holding.
Nothing is drawn under 13 points. The grey words are a readable grey of the phone's own; the Mac's greys are unchanged.
The note in Write is 17 points in Study, 15 in Terminal.

**Room to tap (VM-49).** One spacing scale and a 20-point margin. Every tappable thing answers across at least 44 × 44
points without changing how it is drawn; the few left, each with the ticket that rebuilds it, are in "Remainders"
below. The formatting strip's 28-point buttons stay, your ruled exception.

**One set of controls (VM-50).** Five separately built calm buttons, four kinds of field and twelve hand-built sheet
headers are now one each. Create Book's kind, its OR / AND choice and the block list's views use iOS's segmented
control in the app's colours; the Trash's kinds are chips. The Library's filter row stays as words (P-47-10).

**Your library's voice and palette (VM-51).** The phone now reads your library's voice and palette, the same settings
the Mac reads, so a change on either arrives on the other; the phone keeps no voice of its own, and Settings ▸ Voice
writes the library's voice (your R-47-2). Your words sit on the paper and the bars and sheets on the tinted room (your
R-47-1), the note in Write included; the ★ wears its own blue. Light or dark stays this phone's own. The shared theme
code the Mac uses now lives where both apps compile it (QUESTIONS #199's deferred move).

**Borders that follow light and dark (VM-54).** The take cards', the takes pill's and the comment draft's edges kept
the old colour after a light/dark switch until something else redrew them — found real in the code, its test failing
on the old code. They follow now.

**The bottom bar (VM-52).** Starred · Bookcase · Library at 17 points, the current one semibold on a chip, the others
in the readable grey, each cell at least 56 tall (your LK-5). It shows on the three home pages and the pushed lists and
never in a note; a tab from a list takes you to that page's start. The empty system bar above pushed screens was traced
and kept — it is the back button and the swipe-back (P-47-20).

**Settings (VM-53).** One list that scrolls, in groups — Library, Look, Tags, Help, Diagnostics — every row answering
across its width. It opens from a ⋯ menu on each home page (the old gear is gone) and from a note's ⋯ sheet, and Done
brings you back. The new Appearance choice (follow the system, light, dark) is this phone's alone and reaches the
editor and every sheet. Protection opens on the screen you were on.

**One Protection door (VM-27).** While sync was paused for keys, Settings showed "Protection…" twice, stacked. Now the
standing row stays and the sync line says its sentence alone — shown failing on the old code, passing on the fix.

**The walk's fixes.** The walk found eleven problems of this run's own and ten were fixed, each with a test that fails
on the old code: the room and the paper now reach the very top and bottom of the screen (they stopped short — in dark a
black band round the note); Terminal's book names no longer shrink to two letters at the largest size; no small words
in the faint grey (doors, sentences and headers — the Trash's 30-day promise among them); field hints in the phone's
grey instead of iOS's pale grey; "Delete Note…" in the app's red, not iOS's; one hairline above Settings in the note's
sheet, not two; a tab tap from a list no longer pulls the hidden Library's keyboard up over the Bookcase; the Lenses
sheet's hairline in the palette's colour; and the Account sheet's header and hints on the phone's sizes and colours.
The eleventh — the segmented controls' grey words on iOS's own track — is your call (P-47-30).

**One fix broke typing; a screenshot caught it, and it was redone.** The first fix for the screen's edges let each
page draw past its frame so its colour could reach the top and bottom of the glass. That also let the note's text run
on under the keyboard's bar, and with the keyboard up a tap in the lower half of a note no longer scrolled the note:
the line you tapped and the letters you typed stayed hidden under the bar. The re-capture of the screens showed the
note not scrolling, and one more screenshot on that build proved a typed letter was out of sight. The fix was redone:
each page's frame is cut exactly as before this run, and the app paints the strips above and below in each page's own
colour. A test now types into a note on a simulator and checks that the letter shows — it fails on the first fix and
passes now — and the last screenshots show the note scrolling just as before this run. The same redo took away two
other things the first fix had let through (your words behind the keyboard's bar, and under the clock on a scrolled
page). What it gives back is P-47-43 and P-47-44 in your questions.

**The other runs, merged in.** The wings run (VM-55) was merged into this branch before its own merge, both runs' work
kept line by line in 23 phone files, and its new faces — the wing door, its list, the one message line — put on this
run's sizes and colours; its tab tests now say "Bookcase". Then main came in with the MCP run (VX-981) and the fixes run
(VM-78): four phone files, resolved part by part by the fixes run's written map, and one new test for the one row the
join restyled by hand (Book Details' Unarchive). Last, main came in again with the timing run (VM-64): four files
resolved by its written maps — the Library screen among them, holding both runs' lines —; its timing readout and its
Settings door drawn in this run's sizes and colours with its words kept; two of its tests now tap the tab by its word
"Bookcase"; and this run's style checks now read the readout's file too. The fourth review round read that join and
the redo closely and found them sound.

## The evidence

- **The test windows,** each on the code of its moment: the whole phone suite three times (batch 1: 883 tests; batch 2:
  900; batch 3: 916), each red traced — one real defect fixed (the chrome grew a third of a point past its hold), test
  premises corrected, and the one red that is not this run's (VM-24's caret test, failing on main on purpose by your
  decision); on the code with the wings run merged in, the whole phone suite 1,045 tests in 179 suites with only VM-24's
  red, and a targeted Mac run of 565 tests in 114 suites, green; the Mac's theme tests green at every step; after the
  first merge of main, the phone tests over the joined screens (373 in 64 groups) green and the Mac's (161 in 25) with
  one red this run had made — a Mac test that read the theme code at its old place — fixed. **On the final code**
  (both merges of main in, the edge fix redone): the phone tests that cover this run, 581 in 98 groups, green; the
  timing run's speed tests alone, 13, green; the Mac tests that cover this run, 118 in 21 groups, green.
- **Shown failing on the old code and passing on the fix:** the Terminal top line that wrapped
  (`MobilePathLineGeometryTests`), the 13-point floor in the UIKit text (`theUIKitFormIsNeverBelowThirteenPointsEither`),
  the borders after a light/dark switch (`MobileBorderTraitTests`), the doubled Protection row
  (`MobileSettingsProtectionDoorTests`), every walk fix's test (`MobileScreenEdgeGroundsTests`,
  `MobileShelfMarkerColumnTests`, the faint-grey and hint tests, `MobileNoteActionsAlarmTests`,
  `MobileNoteActionsHairlineTests`, `MobileHiddenPageKeyboardTests`, and the colour and divider rules), the joined
  Unarchive row's 44-point floor (`MobileBookDetailsJoinRowsTests`), and the redo's: its edge tests failing on the first
  fix and on the old frame where each should, and the typing test (`MobileKeyboardRevealUITests`) failing on the first
  fix and passing on the final code.
- **The walk, in four sets of screenshots,** each read one by one against the sizing sheet by fresh readers (the walk
  file `notes/plans/vm-47-walk.md`): the walk itself, 283 of 285, under the sea-glass and teal & rust, both voices,
  light and dark, the default and the largest text sizes — the second palette, the voice flip, the appearance choice
  in the editor and the overlays, Settings from every home page and a note, Protection's road, the borders' flip, the
  bar on lists and its tab roads, no bar where none belongs, the wing list and the message line above the bar all
  matched; at the largest size your words grow and the chrome holds; no "Shelf" left on the top line. The re-capture
  after the first fixes, 164 of 166: every fix showed, the take peek, the takes pill and the line's Undo were caught,
  and the typing problem was found. One settling screenshot on the first fix proved it. The final code, 119 of 119:
  every fix shows, the note scrolls for the keyboard as before this run, nothing of your words sits behind the
  keyboard's bar or under the clock, nothing went backwards and nothing new was found. Never seen in any of them: the
  Account sheet, the timing readout, the paused sync states, the lobby, the 320-point width, a page caught mid-slide.
- **The review:** a midway review after the second batch and four rounds over the whole run, a fresh reviewer each.
  Midway: one major (the UIKit text had no 13-point floor — fixed, proved) and four small points. Round 1: one minor and
  four nits, nothing major — so by your rule ("up to 5 rounds as long as a major is found") no further round was owed;
  round 2 was still taken because the wings run's merge and your Bookcase ruling came in after round 1, and found two
  nits; round 3 was taken because the walk's fixes and main's merge came in after round 2, and found one minor (the
  walk's questions for you were not yet in the list for your sitting — they are now, P-47-31 to P-47-41) and two nits;
  round 4 was taken because the redo and the timing run's merge came in after round 3, and found one nit (the record's
  status line was out of date — fixed). Nothing major is open. The gate's two test fixes (below) came after the fourth
  round had closed, so no reviewer round read them: the orchestrator read them line by line, and the stage coordinator
  read the second as well.
- **The merge gate** — the full test suites, run on the code that merges, before the merge. The whole phone suite:
  1,193 tests in 209 groups, in one run. The timing run's 13 speed tests, in their own run: all passed. The whole Mac
  suite: 6,435 tests in 1,114 groups, the same count as main. Red in the phone suite: main's one known red, VM-24's
  caret test, which fails on main too and is that ticket's; and one timing test (below). Red in the Mac suite: one test
  this run had made untrue (below), and a Mac test known to fail now and then (VX-701), which passed when run alone
  straight after. Neither VM-24's red nor VX-701's is yours to worry about. This run's two reds were both in tests;
  both were fixed and proven in a last test window. The whole phone suite and the speed tests were then run once more
  on the exact code that merges: ‹PENDING: closing leg (c)›.
- **What the gate found** — two things, both in tests; no app code changed.
  (1) A timing test from the last merged run (the timing run, VM-64) checks that opening a note from the new-note box
  is timed. In the whole suite it failed once. An earlier test — one of this run's, which now runs just before it —
  left behind a mark that fires one screen refresh later, and that late mark ended the timing early. The test passed
  every time it ran on its own or beside that earlier test, so a new test was written to make it happen on purpose.
  That new test failed on the old code both times it ran and passes on the fix. The fix is in that one test file: it
  lets every such late mark fire before the timing starts.
  (2) A Mac test that reads the phone's source expected the lock screen's "Use your twelve words instead" door to use
  one particular button style. This run had deliberately moved that door onto the phone's 44-point control. The door
  still answers across its whole label, which is what the test exists to protect, so the test's sentence was brought
  true: it now accepts either style. It passes.

## Your rulings, read again against what shipped

- **R-47-1 — "grounds - prose should not be on the tint"** (2026-11-19). Your words are on the paper everywhere they
  are listed or written on a page — the home pages, a book, the Trash, Archived, Versions, the note — and the grounds now
  reach the screen's edges (since the redo, painted by the app above and below each page, while your words themselves
  stop where they did before this run). **Left:** inside two sheets your words still sit on the tinted room — the Blocks sheet's
  block previews (VM-149) and this note's tray previews (VM-153); the takes, comments and history overlays keep their
  own grounds until they become real sheets (VM-152); a take you peek at wears the take tint, its ruled colour.
- **R-47-2 — "voice only row"** (2026-11-19). Settings ▸ Look ▸ Voice writes your library's voice; there is no palette
  row, as you said — VM-247 holds that for later.
- **R-47-3 — your pick "Bookcase (Recommended)"** (2026-11-19), whose option read "The top line says Bookcase,
  matching the tab, your swipe names and the Mac." Done on the Bookcase's top line in both voices. **Where the phone
  still says "shelf":** the pocket guide's text ("a book on your shelf", "The SHELF is home", "on the shelf's top
  line" — and it says Settings is on that line, which is no longer true) — VM-212; the Debug-only guide door's note
  "The pocket guide is on your shelf." — VM-211; the refusal sentences about a shelf ("That shelf isn't there any
  more…") mean the Bookcase's shelves and are right. "Pin to Shelf Top" is gone (the fixes run).
- **Your wave rulings.** LK-1/LK-2 (the library's voice and palette; light or dark per device) — as built; before a
  library opens, the phone wears Study under the sea-glass (P-47-15). LK-5 (three words at 17, a chip, 56-point
  targets, "Roots and lists, not notes") — as built; Read, a version's reader and Protection have no bar (P-47-18);
  "the bar leaves while the keyboard is up" is the capture box's (VM-73). LK-6 (Terminal keeps its lowercase) — kept;
  P-47-39 asks about your own words in it. SW-1 (the Starred · Bookcase · Library swipe) — kept; the wing title's swipe
  and dots are wave 2's (VM-80).
- **The tickets' "every".** "a 44 pt minimum for every target" (VM-49): every tappable spot the audit counted is done or
  named with its owner below. Batch 1's "Nothing on the phone is set below 13 pt" (VM-48): held everywhere except the note's own
  body in Terminal at the very smallest text setting, about 12.4 points (VM-137, the editor's run). "reachable from
  every screen" (VM-53's title; its text says "from every root and from a note", which shipped): pushed lists, Read
  and Protection have no Settings door of their own — VM-249 holds that question for you (checklist item 6).

## Tickets

The eight members — VM-48, VM-49, VM-50, VM-51, VM-52, VM-53, VM-54, VM-27 — and the umbrella VM-47 close with the merge:
PR #‹PENDING›, merge commit `‹PENDING›`.

Tickets filed:
- [ ] VM-247 (Medium, Feature, Backlog): choose the library's palette on the phone — a Palette row in Settings ▸ Look, which the lock mockup draws and no ticket owned.
- [ ] VM-248 (Medium, Debt, Backlog): a phone test that reads the database dependency unscoped opens the simulator app's own store instead of failing.
- [ ] VM-249 (Low, Improvement, Needs Lillian): Settings from a pushed list, a book's Read page and Protection — your call whether "every root and a note" is enough.

**Remainders on other tickets** (a comment was posted on each at the ticket pass; nothing here is re-owned to VM-61,
which is done):
- **VM-218** (VoiceOver and the largest text size): at ax5 one-line rows cut your book names, Library titles and search
  hits; Book Details stays half-height at ax5 and cuts its title and your book's name; Create Book's tag list breaks a
  tag's name mid-word at ax5; Book Details' detail lines sit beside their labels, not under them; Create Book's ✓ sits in
  a frame too narrow for it past the default size.
- **VM-93** (the Library's rooms): the filter row kept as words; its Terminal-at-320 known issue (the two test strings
  name VM-93) and the Terminal-at-ax5 "bookless" shrink, which that known issue should also name; the filter doors'
  full 44-point width.
- **VM-90:** the sort glyph's full 44-point width.
- **VM-89:** no Library row shows a date.
- **VM-188 and VM-195:** the takes badge, the comment mark and the takes pill keep their small targets; the ⑂ mark is
  7 points tall; and (added after the re-capture, on VM-188) while it shows, the takes pill covers the first line of
  the next block.
- **VM-152:** the three hand-built overlays keep fixed frames that larger text can outgrow; the take card's body; real
  sheets with a grabber; the overlays' own grounds; their dim layer lightens the note in dark.
- **VM-14:** the comment field under the keyboard — the walk measured it (the field and its Add at y 784, the keyboard's
  top at y 583), evidence to move the ticket from Suspected to Confirmed.
- **VM-148:** the note's top row (P-47-12, P-47-29, the chips' capsules in one row, your cut title) and the note's top
  edge (P-47-20).
- **VM-122:** a book's contents' and Read's top edges (P-47-20); "Details · Read" in the top bar wear iOS's label colour,
  not the app's.
- **VM-100 and VM-99:** the Trash's and Archived's top edges (P-47-20); the Trash row's Put back and Delete now still sit
  side by side.
- **VM-110:** Protection's top edge (P-47-20) and its words.
- **VM-147:** the Versions screen's top edge (P-47-20) and Terminal's lowercasing of your words there (P-47-39).
- **VM-137** (Writing): the note's body under 13 points in Terminal at the smallest setting; the paragraph spacing
  fixed at launch; one stale comment in the editor's file; the markdown marker's grey; the text margin (already 20
  points as seen); the shared look the tests use; the keyboard bar's 14-point words and its own ground (added after the
  re-capture: with the keyboard up, what stands behind the bar's glass — since the redo, the note's paper).
- **VM-73:** the capture box's open ↵ door; the bar stays above the keyboard while the box is typing.
- **VM-138 and VM-139:** the keyboard bar's shape and glyph sizes; the formatting strip (your exception).
- **VM-212 and VM-211:** the "shelf" words above.
- **VM-74, VM-149, VM-153, VM-41, VM-86 and VM-101:** the capture box at rest; the Blocks sheet's and the tray's
  previews on the room; the tray's two acts side by side; the history rows' fixed heights; the tag manager's rows that
  only a long press reaches.
- **VM-112:** nothing now — its one item, "Pin to Shelf Top", left the phone with the fixes run.

## Canon

- **The contract lines changed** (applied on the branch, `71cae0706`, so they merge with the PR): SurfaceContracts ›
  The app — the phone's look follows your library's voice and palette while light or dark is this phone's own (in the
  voices bullet); a new bullet for the phone's sizes, greys, taps, controls and grounds, with how the screen's edges
  are painted; a new bullet for the bottom bar; a new bullet for Settings; the message line's place above any bar ·
  The Bookcase and books — the Bookcase's top line (in the wing switcher's phone passage) · Doors to the outside — the
  one Protection door (in the protection bullet's phone passage). No change to AppSpec.
- **Canon size** (`Tools/canon-size` after those lines; SurfaceContracts is not in the loaded set, so this run moves
  none of it): `143606 total (harness limit 150000, headroom 6394)`.
- **MOBILE PARITY:** PL-80 (applied on the branch, `notes/MobileSoul.md` §6) — the phone takes the Mac's look at
  phone-right sizes: a type layer that grows with the system text size and never draws under 13 points, the phone's
  own readable greys, 44-point targets on one spacing scale, one set of controls, the library's voice and palette (the
  theme store moved to shared code) with light or dark per device, your words on the paper and every ground reaching
  the screen's edges, the bottom bar on home pages and lists, Settings as one list from every home page and a note,
  one Protection door; zero schema, marker untouched.

## What wave 2 needs from this run

Every later mobile run builds its faces on this layer (all in `App/Variorum/Shared/Theme/` unless named):
- **Roles, not sizes.** Text takes `.phoneType(role, tokens)` (SwiftUI) or `PhoneType.uiFont(role, voice:,
  compatibleWith:)` (UIKit) — twelve roles, two scaling classes, the 13-point floor; a book's Read page takes
  `phoneReading`. Never `tokens.small/body/title/heading/mono` and never a literal size.
- **The phone's inks.** `tokens.phone.muted` for any words under 17 points that are not ink; `tokens.phone.faint` only
  for glyphs, placeholders, edges and disabled words at 17 points or more.
- **Targets and space.** `PhoneMetrics` (the spacing scale, the 20-point gutter, the row minimums) and `phoneHitArea()`
  for anything tappable drawn smaller than 44 × 44; `PhoneHitAreaButton` in UIKit.
- **The controls.** `PhoneControls.swift`: the text button, inline act, icon button, chip, `phoneField` (built with
  `TextField(phonePlaceholder:text:tokens:)`), the calm button, `PhoneSheetHeader`, `PhoneSegmentedChoice`,
  `PhoneSectionHeader`, `PhoneMenuRow`. No private button, field or header.
- **The look.** Tokens come from the shell's `router.tokens(dark:)` — the shared `ThemeStore` and
  `VoiceTokens.resolve(settings:dark:)` — never the palette-less `resolve(voice:dark:)`; her words on `tokens.surface`,
  bars and sheets on the room; the ★ on `tokens.star`; no literal or system colour; dividers wear `tokens.line`; a UIKit
  layer colour goes through `MobileTraitBorder`.
- **The shell.** The bar is `Features/Shell/MobileTabBar.swift`, shown by the destination builder on lists (a new pushed
  list adds its `listBar`); the ⋯ menu is `MobileRootMenu`, whose items are data — wave 2's doors add items there;
  Settings' groups are `MobileSettingsGroup` with `PhoneMenuRow` rows; light or dark is `MobileAppearanceController`
  (this device's defaults, never the `setting` table).
- **The screen's edges.** The shell's band clips its pages at the safe area (main's line) — never draw past it; a new
  page declares its grounds with `.mobileEdgeGrounds(top:bottom:)` (`Features/Shell/MobileEdgeGrounds.swift`) and the
  shell paints the strips. Re-run `VariorumMobileUITests/MobileKeyboardRevealUITests` (scheme `TK2SpikeUITests`, a
  dedicated simulator under a stage claim) on any change to the band's clip or frame, the Write screen's layout or the
  editor host's keyboard handling — no unit target's whole run includes it.
- **The rules that go red, and why:** `MobilePhoneTypeSourceTests` (a Mac type slot, a size under 13, a literal shrink
  factor, a Mac slot in a shared phone arm), `MobilePhoneControlsSourceTests` (a private button, field or header),
  `MobileLookSourceTests` (a ground, the Read page, the note on the paper, the ★, a literal or system colour, a bare
  divider), `MobileFaintOnDoorsSourceTests` and `MobileFaintCarriesNoWordsSourceTests` (the faint on words under 17
  points), `MobileFieldPlaceholderSourceTests` (a field without its placeholder). They scan the whole phone tree, so a
  run merging code written on older main meets them — bring each site onto the role it is, as batch 6 and batch 7 did.

## What comes next

No new plan file: wave 2's umbrellas and their kickoffs are in `notes/plans/vm-44-mobile-catch-up-plan.md` ("Wave 2 —
the shell"). The stage coordinator launches the editor run for VM-24 once all four wave-1 runs have merged (the fixes
run's handoff says how).

Tickets filed:
- [ ] VM-247 (Medium, Feature, Backlog): choose the library's palette on the phone — a Palette row in Settings ▸ Look, which the lock mockup draws and no ticket owned.
- [ ] VM-248 (Medium, Debt, Backlog): a phone test that reads the database dependency unscoped opens the simulator app's own store instead of failing.
- [ ] VM-249 (Low, Improvement, Needs Lillian): Settings from a pushed list, a book's Read page and Protection — your call whether "every root and a note" is enough.
