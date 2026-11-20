# VM-47 — the run's one walk: what the captures show

**Run:** VM-47, "Sizes and look" (branch `vm-47-sizes-and-look`, worktree `~/dev/variorum-vm-47`). **Tree walked:** code
`b20b04fad` (batches 1–5, the ladder's fixes, VM-55's re-land) plus R-47-3's one word (`50635a674` — the Bookcase root's
line says "Bookcase"; the walk app and driver rebuilt on it into `DerivedData/vm47-walk`). **Record:** `notes/plans/vm-47-sizes-and-look.md` — §3 "One
walk for the whole run" (the brief), §4 rows W.0–W.8 (LIVE STATUS), §5 (the PROVISIONAL calls), §6 (each batch's results).

**Who does what.** The walker DRIVES the walk (builds the driver, runs both parts, keeps them honest, records each part's
result block in §5 below). A FRESH READER, briefed from this file alone, reads every capture against the sizing sheet and
fills "Seen" and "Verdict" in §4 and the Findings in §6. This file is written so that reader needs nothing else: every
capture's file name, what it shows, and what to check (§3).

## FOR A LATER READER

PENDING — written when both parts are read (what was seen, what was this run's and was fixed, what is another ticket's,
what is hers).

## 1. Where the captures are and how to read them

- **Folder:** `notes/plans/vm-47-screens/final/` (gitignored — local to the Pro). One PNG per capture, **1206 × 2622 px =
  402 × 874 pt at 3x** (iPhone 17 Pro, iOS 26.2 simulator). Divide pixels by 3 for points.
- **File name:** `<palette>-<voice>-<appearance>-<size>--<id>-<what>.png`
  - `<palette>`: `seaglass` or `teal_rust`. Part A's sea-glass is the store's UNSET default (nothing written — what a fresh
    library reads, VX-710); part B's is written explicitly (`seaglass`). They should look identical.
  - `<voice>`: `study` or `terminal` (the LIBRARY's voice, set through Settings at each run's start). `<appearance>`: `light`
    or `dark` (the simulator's; the app follows it, except in s06–s11 where the app's own choice overrides it). `<size>`:
    `default` (the Large text size) or `ax5` (the largest accessibility size).
  - `<id>-<what>`: exactly the names in §3's tables, e.g. `seaglass-terminal-dark-ax5--c1-bookcase-rest.png`.
- **Logs:** `final/walk-log.txt` — every shot and every miss (`MISSING` / `NOT-HITTABLE` / `OFFSCREEN` / `KEYBOARD-STAYS` /
  `NOT CAPTURED (time)`), each line naming its file prefix and `[step id]`; `final/logs/` — one xcodebuild log per run,
  `timings.txt`, `progress-a.txt` / `progress-b.txt`. A capture listed in §3 but absent from the folder is explained by the
  log and by the result blocks in §5.
- **Tools** (no stage needed; first `source ~/dev/variorum-vm-47/notes/plans/vm-47-screens/instruments/walkfinal.zsh`):
  `walk_sheets [id …]` — per-step contact sheets in `final/sheets/<id>-NN.png`: every combination of one capture side by
  side, four to a sheet at 1 pt per pixel (402 px wide each), labelled with the combination — the fastest way to compare
  voices, appearances and sizes; `walk_crop <png> <top-pt> <bottom-pt>` — a full-width band at full 3x size into
  `final/crops/` (for small text: the path line is roughly 55–110 pt down, the bar roughly the last 100 pt);
  `walk_pixel <png> <x-pt> <y-pt> …` — the hex colour under each point (for grounds and inks).

## 2. The standard, and the values to expect

Judge against the sizing sheet, `notes/plans/vm-44/design/sketches/sizing-sheet.html` (open it; its text and tables are the
numbers: "Grounds", §A type, §B touch, §C spacing, §D the two inks, §E components, "Token values used"). In short:

- **Grounds (R-47-1, ruled — "prose should not be on the tint"):** her prose and lists on the PAPER (`tokens.surface`); bars,
  sheets, the path line, the field's surround, the filter row and section bands on the ROOM. Under a palette, light: the
  paper is the VOICE's own (Study `#FFFFFF`, Terminal `#FBFBF7`) and the room is the palette's (sea-glass `#E5F0EC`); dark:
  the room is black `#000000` and the paper carries the palette's hue (sea-glass `#0F1A16`). Named exceptions: a book's Read
  page is a cream page (voice-independent) on the VOICE's own room (Study light `#FAF8F3`, never the palette's); the note in
  Write, its masthead included, is on the paper (piece 3.10, P-47-16, P-47-17). Sheets (Settings, Tags, …) sit on the room
  with their rows on the paper. The three hand-built UIKit overlays (takes, comments, block history) keep their own grounds
  (VM-152).
- **Type (§A):** five sizes, 13 · 15 · 17 · 20 · 24; NOTHING under 13 pt (the old caption was 11.5 pt — visibly smaller than
  a 13 pt meta line). Study: prose Iowan Old Style, chrome SF Pro. Terminal: all SF Mono, chrome lowercased, its prose two
  points under Study (note body 15/25, note title 22, screen title 18, row title 15, preview 13 — P-47-4). Roles: note body
  17 on a 27 line · note title 24 semibold · sheet and screen title 20 · row title 17 semibold · row preview 15 · meta 13 ·
  section header 13 semibold · chip 15 medium · inline act 15 · control and tab 17 · mono 17. Chrome (meta, chips, controls,
  tabs, headers) grows to xxxLarge and HOLDS — at AX5 a 17 pt chrome role is about 23 pt, no larger; her words (body,
  titles, row titles, previews) keep growing at AX5.
- **Touch (§B):** every target ≥ 44 × 44 pt (the drawn shape may be smaller); a tab cell a third of the width and ≥ 56 tall;
  the formatting strip's 28 pt acts are her ruled exception.
- **Inks (§D):** the phone's corrected muted and faint — light: Study muted `#6A6359` / faint `#8B7F6A`, Terminal `#61655F`
  / `#7E8376`; dark: muted is the voice's own (Study `#948C7C`, Terminal `#8B9088`), faint Study `#766F5F` / Terminal
  `#6B7168` (P-47-5). The voices' OLD small inks (Study light `#8D8578` / `#B5AD9E`, Terminal light `#8B9088` / `#B3B6AE`)
  should appear nowhere in the phone's chrome. Ink: Study `#29241C` / `#E8E3D8`, Terminal `#23272B` / `#D6DAD2`. Sea-glass:
  accent `#3B6A59` / `#90C1AF`; line and wash `#CBE2D9` (light) and `#1C332A` · `#1F382F` (dark); take tint `#E8F2EE` /
  `#0D1713`; take line `#B7D7CB` / `#254137`. The ★ is the star token — blue in every voice, never the accent. Teal &
  rust's values are not tabled: judge by the same relations (paper and room distinct in light, prose on the paper, the inks
  readable — its dark card is the hardest case for faint).
- **Components (§E):** sheet header — title 20 at the 20 pt gutter, Done 17 semibold in the accent with a 64 × 44 area, row
  ≥ 56; menu row — ≥ 44 one line, 64 with a detail line, label 17 in ink, detail 13 corrected muted; chip — 15 medium in a
  32 pt capsule, 44 pt area; receipt line — one line 44 tall at the foot, words 15 corrected muted, the act 15 semibold in
  the accent; tab bar — Starred · Bookcase · Library at 17, the current one semibold in ink on a chip (the wash, radius 12),
  the others regular corrected muted, the hairline above, the room down to the home indicator.
- **The one message line's place (batch 6's meeting 2; the ladder's R2-n1):** where a bar is on screen — a root, a pushed
  list — the line sits ABOVE it, never over its doors (m1, m2); inside a note in Write there is no bar, so a line showing
  there sits at the foot (just above the home indicator, or above the keyboard when it is up), never lifted a bar's height
  over empty space — a lifted line inside a note is a finding (name the capture and what led to it: no test drives a note
  pushed over a list, R2-n1).

**Already recorded with an owner — describe if seen, do not count as new:** the three UIKit overlays' fixed frames and
hand-built sheets (VM-152 — their text can outgrow a frame above xxxLarge); Settings rows that do not exist on the phone yet
(a palette chooser, Lock now, writing settings — other tickets); the Library filter row at 320 pt (VM-93; not capturable);
the keyboard bar's 14 pt chrome (VM-137); the Read page's page meta in its own pale ink (batch 1, for her look); the
masthead's layout — the title beside four tools, chips in a wrapping flow (VM-148); pushed screens keeping the system back
bar (W-009, P-47-20 — the captures are for her look); a remover beside a restorer on a Trash or tray row (VM-100 /
VM-153); the sheets' missing grabber and detents (VM-152); a take card's body, the comment draft field, the history rows
(VM-152 / VM-189 / VM-14 / VM-193 / VM-41); the bar staying above the keyboard while the box or the search is focused
(VM-73). Questions already put to her — look and describe precisely: what truncates on the Bookcase's path line in Terminal
(P-47-27 — since R-47-3 the line is three characters longer there, and in Study a two-digit count now meets the edge at
402 pt). Ruled since: the line reads Bookcase (R-47-3) — the Bookcase root's own path line says "Bookcase" (Study) /
"bookcase" (Terminal), matching its tab; a "Shelf" anywhere on that line is a defect.

**Classify every finding:** THIS RUN'S DEFECT (a size, ink, ground, control, hit area or bar placement this run built that
does not match the sheet or the record — the walker fixes it narrowly, with a test where one holds, and re-captures) ·
ANOTHER TICKET'S (name it: the owners above, the record's §6 inventories, or `~/dev/variorum/notes/TICKETS.md`, read-only;
never invent a number) · A QUESTION FOR HER (into the record's §5, with the capture file names). Hard lines for any fix: no
edit to `Shared/Theme/VoiceTokens.swift`, `MobileEditorTextView.swift`, `MobileEditorViewModel.swift`, `Shared/EditorBrain/`
or `Sources/`; the Mac's look unchanged; no rendered word changed; VM-55's behaviour and words unchanged.

## 3. Every capture: what it shows and what to check

**The combinations.** Part A: `seaglass` × {`study`, `terminal`} × {`light`, `dark`} × {`default`, `ax5`} — eight prefixes,
e.g. `seaglass-study-light-default--`, `seaglass-terminal-dark-ax5--`. Part B: `teal_rust-study-light-default--` and
`teal_rust-study-dark-default--` (the core); `seaglass-study-light-default--` and `seaglass-terminal-dark-default--`
(Settings' flows, the bar's roads and VM-55's faces, the wider pass); `seaglass-terminal-light-default--` (VM-54's flip
only); `seaglass-study-light-ax5--` (the wider pass only). Where part B shares a prefix with part A, the capture names differ.

### 3a. The seed — part A, once (prefix `seaglass-study-light-default--`)

| Id | File (after the prefix) | Shows | Check |
|---|---|---|---|
| s0 | `s0-pocket-guide-contents.png` | the pocket guide's contents, opened from Settings' DEBUG door onto the Bookcase's stack | a book's contents page (see r02); the store seeded |
| s1 | `s1-seeded-note.png` | the lesson "swipe & choose" in Write after a saved version and a comment | the comment mark (●1) beside a block; otherwise as c5 |
| s2 | `s2-seeded-library.png` | the Library, the search cleared | the seeded rows; otherwise as c3 |

### 3b. The core — part A × 8 combinations; part B × `teal_rust` Study light and dark (default size only)

| Id | File | Shows | Check |
|---|---|---|---|
| k1 | `k1-settings-top.png` | Settings just after its voice choice was pressed (the sheet re-voiced), at its top | the header: "Settings" as a muted path (Terminal `~/settings`), Done 17 semibold in the accent (P-47-13); section names 13 semibold corrected muted on the ROOM; rows full width on the PAPER with hairlines from the gutter; the Library group: the sync row (its line 13; any doors 17 with 44 pt areas) and ONE "Protection…" row (VM-27); the Look group: "Voice" over a two-segment system control (Terminal · Study, the library's voice chosen — R-47-2) and "Appearance" over Follow system · Light · Dark in the Mac's words with no line beneath (P-47-24, P-47-25, P-47-26); segment words 15 medium, the chosen in ink on the paper, the others corrected muted; segments ≥ 44 tall and sized by their words |
| k2 | `k2-settings-swiped-1.png` | the same list swiped up once | Tags ▸ Manage Tags, Help ▸ Acknowledgments, Diagnostics (Record edit trace — a system switch tinted the accent — and Edit trace…): menu rows ≥ 44, labels 17 in ink; nothing clipped |
| k3 | `k3-settings-swiped-2.png` | swiped again — the list's foot | the DEBUG groups (Tutorial, Performance, TK2 Spike); air at the foot; at AX5 (Terminal above all) the list scrolls and nothing is cut, overlapped or truncated (batch 5's ask) |
| k0 | `k0-bookcase-menu-open.png` | the Bookcase with its ⋯ menu open | a system pull-down anchored at the ⋯ (P-47-22) with one item, "Settings" (Terminal "settings"); the ⋯ glyph 22 pt in the accent |
| c1 | `c1-bookcase-rest.png` | the Bookcase root at rest | **the path line, ONE line about 44 tall:** the wing door "Home · Bookcase  ·  N books" (Study) / "~/home/bookcase  ·  N books" (Terminal) at 13 pt, "Home" in the accent and the rest corrected muted, then 🗑, "+ New Note" (15, the accent) and ⋯ — in Terminal the words cannot all fit: record EXACTLY what is cut (P-47-9, P-47-27; in Study, too, if a two-digit count is cut); the line reads Bookcase (R-47-3), the bar's word; **the books** on the PAPER: names 17 semibold in ink (Terminal 15), meta 13 corrected muted, rows ≥ 44, the Today chip (15 medium in a 32 pt capsule) on the Journal's row, "+ New Book" 17 in the accent; **the box at rest:** one line, its hint on ONE line (the longest of its own cuts that fits — "new note — just start typing", or "new note" — P-47-6), the dashed edge; **the bar:** "Bookcase" semibold in ink on a wash chip, Starred and Library regular corrected muted, cells a third wide and ≥ 56 tall, the hairline above, the room to the bottom edge (P-47-21); at AX5 every bar word whole, Terminal included; nothing under 13 pt anywhere |
| c2 | `c2-bookcase-box-focused.png` | the box tapped: open, the keyboard up | the box grown, a caret, its text size the note body's; the books region yielding but visible; the bar above the keyboard (recorded: VM-73) |
| c3 | `c3-library-rows.png` | the Library root | the path line "Home · Library" + 🗑 + "+ New Note" + ⋯ on one line; the search field (paper, the take-line edge, radius 12, ≥ 44 tall) on the room; the filter row "All · Books · Notes · Bookless · Scraps" at 13 pt in ONE row, no word shrunk or cut, the sort glyph at its end (P-47-7, P-47-10); rows on the PAPER (notes and books interleaved: titles 17, dates 13 corrected muted, each ≥ 44); the bar with "Library" on the chip; the keyboard should be DOWN — if it is up, the log line `NOTE the keyboard is still up after leaving the box` says the app left it up after the box (describe it) |
| c4 | `c4-library-search.png` | "swipe" typed into the field, the keyboard up | the typed text 17 (at AX5 about 23 pt, the field still about 44 tall — P-47-14); the hits listing under it |
| c4 | `c4-library-search-results.png` | the same, the keyboard down | hit rows on the paper: title 17 in ink, detail 13 corrected muted |
| c5 | `c5-note-write.png` | the lesson "swipe & choose" open in Write | **the masthead on the PAPER** (P-47-17): the title 24 semibold (Terminal 22) in ink, on one line beside the four tools; the tools — copy, find, lock, ⋯ — 22 pt glyphs in INK with touching 44 pt areas (P-47-12); the membership chip and the five chips (date · tags · more info · blocks · lens) at 15, in a wrapping flow, each 44 tall; **her prose on the PAPER** (P-47-16): body 17 on a 27 line (Terminal 15/25) at 20 pt margins; the ⑂ badge in the gutter of the fanned block; NO bottom bar; the system back bar above the masthead (P-47-20); no message line lifted inside the note — if one shows, it sits at the foot (§2, R2-n1) |
| c6 | `c6-note-peek-take-tint.png` | default size only: an in-page swipe on the fanned block — the next take peeking | the peeked take on the TAKE TINT, the pill (‹ n/m ›) near it; legible in light and dark |
| c7 | `c7-callout-comment.png` | default only: the lesson "comments & callouts" in Write | the callout's wash (blue, 💡) behind block 2 and the comment mark (●n in the comment ink) beside block 1, both clear on the paper in light and dark |
| c8 | `c8-caret.png` | default only: the prose tapped — the caret, the keyboard and its bar up | the caret visible on the paper; the keyboard bar's three resting cells |
| c9 | `c9-selection.png` | default only: a word double-tapped | the selection wash readable on the paper (visible, not hiding the words); the edit menu may show |

### 3c. Settings' flows — part B (`seaglass-study-light-default--`, `seaglass-terminal-dark-default--`)

The app's appearance choice is flipped AGAINST the simulator: in Study light (simulator light) to DARK — files
`s06…s09-appearance-dark-…`, then `s10-appearance-light-chosen`; in Terminal dark (simulator dark) to LIGHT — files
`s06…s09-appearance-light-…`, then `s10-appearance-dark-chosen`.

| Id | File | Shows | Check |
|---|---|---|---|
| s01 | `s01-starred-menu-open.png` | Starred with its ⋯ menu open | the same ⋯ and menu as k0, on a third root (P-47-22) |
| s02 | `s02-library-menu-open.png` | the Library with its ⋯ menu open | the same, on the Library |
| s03 | `s03-settings-from-library.png` | Settings opened from the Library's ⋯ | the same sheet as k1 (Settings from every root) |
| s03b | `s03b-protection-from-library.png` | Settings ▸ Protection… | Protection pushed on the LIBRARY's stack (P-47-23): its title and sections; NO bottom bar (P-47-18); the system back bar (P-47-20); absent if the store offers no Protection row (the log says MISSING) |
| s03c | `s03c-back-on-library.png` | Back from Protection | the Library root again |
| s04 | `s04-voice-flipped-settings.png` | Settings with the OTHER voice pressed | R-47-2: the sheet re-voiced at once (Study ↔ Terminal faces; Terminal lowercased) and the other segment chosen |
| s05 | `s05-voice-flipped-bookcase.png` | Done → the Bookcase in the other voice | the root follows the library's new voice (the voice is then set back) |
| s06 | `s06-appearance-<dark\|light>-settings.png` | Appearance pressed against the simulator | the sheet redrawn in the chosen appearance at once (this phone's own choice, LK-1/LK-2) |
| s07 | `s07-appearance-<dark\|light>-bookcase.png` | Done → the Bookcase | the root (room, paper, bar) in the chosen appearance |
| s08 | `s08-appearance-<dark\|light>-note.png` | a note in Write | the UIKit editor in the chosen appearance (her prose on that appearance's paper), the masthead too; no message line lifted inside the note (§2, R2-n1) |
| s09 | `s09-appearance-<dark\|light>-takes-overlay.png` | the takes overlay opened | a UIKit overlay in the chosen appearance (cards and their edges) |
| s10 | `s10-appearance-<light\|dark>-chosen.png` | the simulator's own word pressed | the sheet in the simulator's appearance again, that segment chosen |
| s11 | `s11-appearance-follow-system.png` | Follow system pressed | the same look; "Follow system" chosen |
| s12 | `s12-note-actions-settings-row.png` | a note's ⋯ sheet | the header "Note" with Done; menu rows — Save a Version and Versions… 17 in the accent with 13 detail lines, ≥ 64; a "Settings" row ≥ 44 with no detail; Delete Note… last in the alarm |
| s13 | `s13-settings-over-the-note.png` | its Settings row pressed | the Settings sheet over the note (VM-53: Settings from a note) |
| s14 | `s14-back-on-the-note.png` | Done | back on the note in Write; no message line lifted inside the note (§2, R2-n1) |

### 3d. The bar's roads and VM-55's faces — part B (`seaglass-study-light-default--`, `seaglass-terminal-dark-default--`)

| Id | File | Shows | Check |
|---|---|---|---|
| b1 | `b1-trash-bar-top-edge.png` | the Trash pushed from the Bookcase's 🗑 | a pushed LIST wearing the bar ("Bookcase" on the chip) on the room under a paper page; its top edge: the system back bar, then "~/trash" / "Trash" (P-47-20); the kind chips (P-47-11); the seeded trashed note's row |
| b2 | `b2-library-from-trash.png` | "Library" tapped from the Trash | lands on the Library ROOT (P-47-19) |
| b3 | `b3-bookcase-root-after.png` | "Bookcase" tapped | the Bookcase ROOT — the Trash it left is gone (the stack returned to its root) |
| b4 | `b4-book-contents-bar-top-edge.png` | the pocket guide's contents | the bar on a pushed list; the top edge: back + "Details" · "Read" in the system bar; the book's name 20; rows on the paper |
| b5 | `b5-book-read-no-bar.png` | the book's Read | NO bar (P-47-18); the cream page on the voice's own room |
| b6 | `b6-note-from-book-no-bar.png` | a note opened from the book ("your first take") | Write; NO bar; no message line lifted inside the note — this is a note pushed over a list, the road no test drives (§2, R2-n1) |
| b7 | `b7-bookcase-from-its-book.png` | "Bookcase" (the current tab) tapped from the book | the Bookcase ROOT (the current tab pops its own stack) |
| b8 | `b8-versions-listing-bar.png` | Note ▸ Versions… on the fanned lesson | the listing wears the bar ("Library" on the chip); the seeded moment's row |
| b9 | `b9-versions-reader-no-bar.png` | the moment read | NO bar; the "‹ Versions" door; if a message line shows, it sits at the foot, never lifted a bar's height — the reader over its listing is the other road no test drives (ladder round 2, R2-n1) |
| b10 | `b10-bookcase-from-versions.png` | "Bookcase" tapped from the listing | the Bookcase root |
| b11 | `b11-library-root-after.png` | "Library" tapped | the Library ROOT — the listing and the note under it closed (P-47-19) |
| b12 | `b12-archived-bar.png` | Library ▸ Bookless ▸ the "Archived" row | the Archived room (likely empty — its promise line) wearing the bar |
| b13 | `b13-protection-no-bar.png` | the Bookcase's ⋯ ▸ Settings ▸ Protection… | NO bar (P-47-18); absent if no Protection row |
| w1 | `w1-wing-list-bookcase.png` | the wing door ("Home" on the path line) tapped on the Bookcase | VM-55's list on this run's layer: the sheet header (its title, Done 17 semibold), one row "Home" — the name 17 in ink, the ✓ 13 in the accent — ≥ 44 tall, at the 20 pt gutter, on the room (P-47-8); a medium-height sheet |
| w2 | `w2-wing-list-library.png` | the same door on the Library | the same list |
| w3 | `w3-wing-pick-lands-bookcase.png` | "Home" picked in the list | the list closes and the app LANDS on the Bookcase root (VM-55's landing) |
| m1 | `m1-line-library-root.png` | a note just sent to the Trash from its Library row | THE ONE MESSAGE LINE at the foot, ABOVE the bar (never over its doors): one line about 44 tall on the room with a hairline, the receipt's words at 15 corrected muted, "Undo" 15 semibold in the accent (sheet §E's receipt line) |
| m2 | `m2-line-over-trash-bar.png` | the Trash pushed while the line still shows | the line lifted above the TRASH's bar too (meeting 2: "a bar is on screen") |
| m3 | `m3-after-undo.png` | the line's Undo pressed | the line gone; the note put back (not in the Trash listing) |

### 3e. VM-54's flip — part B (`seaglass-study-light-default--`, `seaglass-terminal-light-default--`)

The simulator is switched light → dark WHILE each surface is on screen; the borders must follow.

| Id | File | Shows | Check |
|---|---|---|---|
| f1 | `f1-takes-cards-light.png` | the takes overlay in light | the take cards' edges (the chosen card's in the chosen mark) |
| f2 | `f2-takes-cards-dark.png` | the same after the flip to dark | every card edge in its DARK colour — no light line left on black |
| f3 | `f3-comment-draft-light.png` | the comments overlay in light | the comment draft field's edge |
| f4 | `f4-comment-draft-dark.png` | after the flip | the draft's edge in its dark colour |
| f5 | `f5-pill-light.png` | the takes pill after an in-page swipe | the pill's edge |
| f6 | `f6-pill-dark.png` | after the flip | the pill's edge dark — the pill fades after 2.4 s, so it may already be gone (then no evidence either way) |

### 3f. The wider pass — part B (`seaglass-study-light-default--`, `seaglass-terminal-dark-default--`, `seaglass-study-light-ax5--`)

| Id | File | Shows | Check |
|---|---|---|---|
| r01 | `r01-starred.png` | Starred | the ★ in its OWN token (blue) before a note and a book — never green; rows on the paper, names 17, "note" / "book" 13 in faint; "Home · Starred" + ⋯; "Starred" on the bar's chip |
| r02 | `r02-book-contents.png` | the pocket guide's contents | as b4: the name 20, chapter labels 13 semibold, note rows ≥ 44, "+ New Note" / "+ New Chapter" ≥ 44, on the paper; the bar |
| r03 | `r03-book-details.png` | Details | the sheet header (Done); the book's name 17; menu rows (Finish, Delete Book… in the alarm) ≥ 44 |
| r04 | `r04-book-read.png` | Read | the cream page on the voice's own room; serif 17 on 27, titles 25 / 21; page meta 13 in its own pale ink (recorded) |
| r04b | `r04b-book-read-scrolled.png` | Read scrolled | the flow continuing |
| r05 | `r05-create-book.png` | + New Book | the sheet header with "Cancel" in Done's place, semibold (P-47-13); the name field (≥ 44, paper, take-line edge); the kind as a segmented choice; the calm button (paper fill, take-line edge, full width) |
| r05b | `r05b-create-book-smart.png` | "Smart Book" pressed | the segment moved; the tag rows and the OR / AND segmented choice appear, each ≥ 44 |
| r06 | `r06-tags-sheet.png` | the note's Tags chip | the header; the tag field (≥ 44, typed text 17 — P-47-14); applied tags with "✕ remove" (15); suggestion rows ≥ 44 |
| r06b | `r06b-membership-sheet.png` | the membership chip ("Books holding this note") | the header; the book rows; diverge / remove / open copy as 15 inline acts; "+ book" rows ≥ 44 |
| r06c | `r06c-more-info-sheet.png` | More Info | the header; link and file rows; "+ add a link" ≥ 44 |
| r07 | `r07-blocks-sheet.png` | Blocks | the header with "Select" beside Done; the segmented choice; block rows ≥ 44 with her words at 15 (the previews' ground is VM-149's) |
| r07b | `r07b-blocks-leaving.png` | the "leaving" segment | that segment chosen (ink on the paper); its list or its empty line |
| r08 | `r08-lenses.png` | Lenses | the header; "the note" row and lens rows ≥ 44; the save and adopt doors as inline acts |
| r09 | `r09-note-actions.png` | Note Actions (the masthead's ⋯) | as s12 |
| r10 | `r10-versions.png` | Versions… | as b8 |
| r11 | `r11-takes-overlay.png` | the ⑂ badge tapped: the takes overlay | the hand-built overlay: Done, the cards (her words), ✓ / ⋯ per card, Branch / Blank, "Turn takes into blocks"; text 13 or more; at AX5 how the fixed frames hold (VM-152) |
| r12 | `r12-block-history.png` | a card's ⋯ ▸ Block History… | the overlay: header, rows, Done; at AX5 the fixed rows (VM-152 / VM-41) |
| r13 | `r13-comments-overlay.png` | the keyboard bar's ⋯ ▸ Comments… | the overlay: the seeded comment, Edit / Delete, the draft field, Add; at AX5 the frames |
| r14 | `r14-trash.png` | the Trash (from the Bookcase) | as b1: "~/trash", the sort and "Empty Trash" (17, the alarm); the 30-day line; the kind chips in ONE sideways row (All · Notes · Books · Blocks · Takes · Snippet groups · Originals), "All" on the wash in ink, the others edged and corrected muted (P-47-11); rows with Put back / Delete now / Open note as 15 inline acts |
| r14b | `r14b-trash-notes-chip.png` | the "Notes" chip pressed | "Notes" now on the wash, "All" edged; the listing filtered |
| r15 | `r15-archived.png` | Archived (Library ▸ Bookless ▸ the Archived row) | as b12 |
| r16 | `r16-settings.png` | Settings from the Bookcase's ⋯ | as k1 |
| r17 | `r17-protection.png` | Settings ▸ Protection… | as s03b; absent if no row |
| r17b | `r17b-protection-scrolled.png` | Protection scrolled | its lower sections; text 13 or more (its sentences 15), doors 17 with 44 pt areas |

## 4. Screen by screen — the reader's verdicts

| # | Screen | Captures | Seen | Verdict |
|---|---|---|---|---|
| 1 | The seed | s0 s1 s2 | (Study light default only.) **s0** — the pocket guide's contents pushed on the Bookcase's stack: the system back button and "Details · Read" in the system bar, "the pocket guide" in the serif, the chapter labels (welcome, writing, takes, structure, the library of things) 13 semibold corrected muted, the note rows in ink on the paper #FFFFFF. BUT the bottom bar is drawn MID-SCREEN at 484–539 pt (the room #E5F0EC, its hairline at 483) — exactly where c2 puts it above an open keyboard — with no keyboard on screen; the rows continue under and below it on the paper and the list's content stops at ≈826 pt with paper below. The seed had typed into the Bookcase box twice just before (the log), so the box's keyboard state is the likely cause; I could not judge it from this frame (see §6, "not judged"). **s1** — "swipe & choose" in Write, the note and its masthead on the paper #FFFFFF to the screen's edges (Study's paper is white, so the edges match here); the ⑂ mark beside block 3; NO ●1 comment mark (the seed's comment submit was NOT-HITTABLE and tapped by its centre, so no comment was filed — the driver's miss); no message line. **s2** — the Library with its search field focused (caret the system blue #0088FF) and iOS's own first-use "Speed up your typing by sliding your finger…" card in the keyboard's place (iOS's, not the app's); rows are titles only; the strip above the path band (0–62 pt) is #FFFFFF, not the room. | NOT JUDGED AS THE APP'S (seed captures — the brief): the lifted bar in s0 is listed as not judged (§6); the missing ●1 in s1 is the seed's miss. What they do show feeds W-A1 (s2's white top strip) and W-A7 (s2's caret). |
| 2 | Bookcase at rest | c1 (A ×8; B teal ×2) | **part A** (8 captures). **Grounds** (`walk_pixel` + column runs at x = 3 and 395 pt): path band = the room 62–110 pt (48 tall; #E5F0EC light, #000000 dark); books on the paper (#FFFFFF Study, #FBFBF7 Terminal, #0F1A16 dark) 110–784; the bar = the room 785–840 with the palette's hairline at 784 (#CBE2D9 / #1C332A), 56 pt in all (AX5: 781.3–840, 58.7). **The strips at the edges:** LIGHT, both voices — 0–62 pt above the path band is **#FFFFFF**, and **840–874 pt under the bar is #FFFFFF** (the room stops at 840; in Terminal #FFFFFF is neither the room nor its paper #FBFBF7); DARK — both strips #000000, which IS the room, so they match. **Path line** (one line, 48 tall in all 8): Study default "Home · Bookcase  ·  3 books" WHOLE (H cap 9.3 pt → 13.2 pt; "Home" #3B6A59 / #90C1AF, the rest #6A6359 / #948C7C; it ends at 191.3 pt, the 🗑's 44 pt frame starts ≈212.8, so ≈5.5 pt of slack beyond the spacer's 16 — a two-digit count (≈7–8 pt more) would cut the tail; this store has 3 books, so that case is NOT exercised); Study AX5 "Home · Bookcase..." (17.6 pt; the whole count gone, the page word whole); Terminal default "~/home/bookcase  ·…" (13 pt mono; the count gone, a lone "·" then "…"); Terminal AX5 "~/home/book…" (the page word itself cut). No "Shelf" anywhere (R-47-3 holds). The 🗑 is the colour emoji U+1F5D1, 22.7 pt tall (28.7 at AX5), its own grey-blue — not the muted tone; "+ New Note" 15.1 pt accent (20.3 at AX5); ⋯ accent, 20 pt wide. **Books:** names Study Iowan semibold (l ascender 13.0 pt → 17.2) in ink #29241C / #E8E3D8, Terminal mono (≈15) #23272B / #D6DAD2; row pitch 45.3 (Study) / 44.0 (Terminal); meta 13.2 pt in the corrected muted (#6A6359, #948C7C, #61655F, #8B9088) trailing on the name's line (Terminal: "17 notes · #pocket…" cut at default); the Today chip a wash capsule exactly 32.0 pt tall (#CBE2D9 / #1F382F) with "✎ today" 15 in the accent, 32.0 at AX5 too; "+ New Book" 17 in the accent. Terminal's names start at 47.5 pt (an invisible reserved column), "+ new book" at 20. **AX5:** Study names "journal", "the p…", "the p…" (the two books read the same); Terminal names start at 83 pt and read "jo…", "the…", "the…", meta "17 notes ·…". **The box at rest:** one line, dashed edge and hint in the corrected faint (#8B7F6A, #766F5F, #7E8376, #6B7168); Study default the WHOLE hint "new note — just start typing · ↵ opens it", Terminal default "new note — just start typing", AX5 both "new note"; ≈46 tall at default. **Bar:** "Bookcase" semibold in ink on a wash chip 109 × 36 pt (radius 12), Starred/Library regular in the corrected muted; words 17 (S 12.7 pt cap), AX5 ≈23 (Terminal b ascender 17.0 → 23.1); every bar word WHOLE at AX5 in Terminal (starred 21–113, library 289–382 pt). Nothing set under 13 pt; no message line. | **DOES NOT MATCH** the grounds at the edges in light (W-A1: under the bar 840–874 and above the path line 0–62 pt are #FFFFFF, not the room). **FOR HER LOOK** — the path line's truncation as built (W-A2, P-47-27: the count goes first in Terminal at default and in Study at AX5, the page word itself at Terminal AX5). **DOES NOT MATCH** at AX5 Terminal: the invisible marker column grows to ≈55 pt and leaves 2–3 letters of each name (W-A3); at AX5 in both voices one-line rows cut her book names (W-A4, VM-218). 🗑's colour emoji (W-A5, question). Everything else MATCHES: type sizes, inks, chip 32, rows ≥ 44, bar cells 56, AX5 bar words whole. |
| 3 | Bookcase, the box focused | c2 | (8 captures.) The box open, its hint at the note-body size, a caret in the system BLUE (#0088FF light, #0091FF dark — not the accent). Default (4): the books region yields but stays visible (three rows and "+ New Book", whose baseline sits ≈3 pt above the box's dashed top); the bar above the keyboard at 484–539 pt (recorded: VM-73); a 9 pt sliver at the bar's ends 539–548 where the keyboard's rounded top meets it shows the bare window (#FFFFFF / #000000). AX5 (4): the box fills the whole region from the path line (110) to ≈433 pt and **no book is visible at all** — not a row, not "+ New Book" — in both voices and appearances. | Default MATCHES (the bar over the keyboard is VM-73's). **DOES NOT MATCH** the check's "books yielding but visible" at AX5 — the six-line floor in lines of the scaled box text takes the whole region (W-A6, a question). The blue caret (W-A7, a question). The white/black corners beside the keyboard are W-A1's mechanism. |
| 4 | The ⋯ menu on a root | k0 (A ×8; B teal ×2), s01, s02 | **part A** (8 captures). A system pull-down (iOS 26 glass) grown from the ⋯ over the right of the path line, one item: "Settings" (Study) / "settings" (Terminal — lowercased, but in the system's SF Pro, not the voice's mono; the system menu takes no voice face); at default the item is ≈17 pt and the menu covers the count, 🗑 and "+ New Note"; at AX5 the item is the system's AX5 size (≈45 pt) and the menu covers the path line and the first book row. The ⋯ itself is under the menu in every capture (measured in c1: the accent, 20 pt wide). The rest of the screen as c1 (its white strips in light). | MATCHES P-47-22 as built (the system Menu anchored at the ⋯, one item); FOR HER LOOK: the item in the system face, not Terminal's mono (the system menu's own). |
| 5 | Settings, top to bottom | k1 k2 k3 (A ×8; B teal ×2), s03, r16 | **part A** (24 captures; k2 and k3 differ only by the scroll indicator — pixel-diffed — except Terminal light AX5 and Terminal dark default, where they are identical: one swipe already reaches the foot). Header on the ROOM: "Settings" Iowan ≈20 muted (#6A6359 / #948C7C) / "~/settings" mono muted (#61655F / #8B9088); "Done"/"done" 17 semibold-weight in the accent (D cap 12.0 → 17.0). Section names 13 semibold corrected muted on the room (Library, Look, Tags, Help, Diagnostics, Tutorial (dev store), Performance (dev store), and an unnamed band over TK2 Spike). Rows on the PAPER with hairlines from the gutter; menu rows 44–45 pt; labels 17 in ink. Library group: "Sync off (dev store)" 13.2 pt corrected muted (kept capitalised in Terminal — the shared `SyncStatusRow`, unlowercased on the Mac too), no doors in this state; ONE "Protection…" row. Look: "Voice" over a two-segment system control (Terminal · Study; the library's voice chosen in each combination — R-47-2), "Appearance" over Follow system · Light · Dark in the Mac's words, no line beneath (P-47-24/25/26); segment words ≈15 (T 11.0 / F 10.7 pt caps), chosen in ink on a paper thumb, others corrected muted on the system's own grey track (#EEEEEF Study light, #EAEAE8 Terminal light, #273030 dark — not a token); control 45 pt tall; Voice's two segments ≈equal halves, Appearance's sized by their words. Diagnostics: Record edit trace with an (off) system switch, Edit trace…; the DEBUG groups at the foot; air below. **AX5:** chrome holds at ≈23 (Done 17 pt ascender → 23), section names 17.6, rows grow; Study's title "Settings" ≈50 pt on one line; **Terminal's title wraps: "~/" on one line, "settings" (≈46 pt mono) on the next** (k1–k3, light and dark), and the header is then ≈140 pt tall; nothing cut, overlapped or truncated — the list scrolls to its foot. | MATCHES the sheet and P-47-13/24/25/26 and R-47-2 at default in all four, and at AX5 nothing is cut (batch 5's ask holds). FOR HER LOOK: Terminal's AX5 path title broken after "~/" (W-A8). Notes, not findings: the segmented track is the system's grey; the sync line keeps the shared row's capital. |
| 6 | Library | c3 | (8 captures.) The keyboard is DOWN in all eight (no "keyboard still up" line in the log). Grounds as c1: path band and the field's surround and the filter row on the room 62–206 pt, rows on the paper, the bar 785–840; light: #FFFFFF above 62 and below 840 (W-A1). **Path line** "Home · Library" / "~/home/library" + 🗑 + "+ New Note" + ⋯ on one line in seven; Terminal AX5 reads "~/home/libr…" (the page word cut). **Search field:** the paper (#FFFFFF / #FBFBF7 / #0F1A16) with the take-line edge (#B7D7CB / #254137), 44.7–45.0 pt tall edge to edge at default AND at AX5; its placeholder "Search notes, books…" is the SYSTEM placeholder grey — #C5C5C7 (1.72:1 on white), #C2C2C1 on Terminal's paper, #515858 on the dark paper (2.45:1) — not the corrected faint. **Filter row** in ONE row with the sort glyph ↑↓ in the accent at its end: "All" in ink, the other four in the corrected **FAINT** (#8B7F6A 3.37:1 on the room; #7E8376 3.34:1; dark #766F5F / #6B7168 ≈4.2:1 on black), 13 pt at default (x-height 7.3 pt), 17.6 at AX5; at **Terminal AX5** (light and dark) "bookless" is SHRUNK to ≈13.6 pt (x-height 7.33 against its siblings' 9.67) — Study AX5 unshrunk. **Rows** on the paper: titles only (Iowan semibold ≈17 / mono ≈15, pitch ≈44 pt), NO date on any row; only notes are in view (loose thought … swipe & choose), so "notes and books interleaved" cannot be seen in this frame. AX5: titles one line each and cut ("What's true…", "the voice sw…", "comments & c…"), both voices. Bar: "Library" on the chip. No message line. | **DOES NOT MATCH** in four places this run built: the unchosen filter words in the faint (W-A9, under the sheet's 4.5:1 for words under 17), the field's placeholder in the system grey (W-A10, under the sheet's 3:1 for placeholders), "bookless" shrunk at Terminal AX5 (W-A11 — the row's rebuild is VM-93's), and the edges (W-A1). FOR HER LOOK: the path line at Terminal AX5 (W-A2). ANOTHER TICKET'S: no date on a Library row (W-A12, VM-89); AX5 titles cut (W-A4, VM-218). Field height MATCHES (P-47-14 (a)). |
| 7 | Library search | c4 (both files) | (16 captures.) "swipe" typed: at default ≈17 (s x-height 9.7 pt incl. overshoot), at AX5 ≈23 (12.3–12.7 pt) — the control role held at xxxLarge; the field stays 44.7–45.0 pt tall at both sizes. The caret is the system blue (#0088FF; #7FC3FF mid-blink). One hit, "swipe & choose", title in ink (Iowan semibold / mono), detail "note" 13 in the corrected muted (#6A6359, #948C7C, #61655F, #8B9088 — not the faint it looks like at a glance), on the paper; at AX5 the hit title is cut ("swipe & c…", "swipe & ch…"). Keyboard up in `c4` (the bar above it — VM-73), down in `-results`. The filter row and its faint words and Terminal-AX5 "bookless" as row 6. Edges as row 6. | MATCHES P-47-14 (a) as built (a PROVISIONAL — hers: which class a field's text is) and the hit row's sizes and inks. Carried: W-A7 (blue caret), W-A4 (AX5 hit title cut), W-A9/W-A11 (the filter row), W-A1 (edges). |
| 8 | A note in Write | c5, s08, s14, b6 | **part A** (c5 ×8). The masthead and her prose on the PAPER (P-47-16, P-47-17), but the paper STOPS at 62 pt and at 840 pt: above and below it the strips are #FFFFFF in light (Terminal's paper is #FBFBF7) and **#000000 in dark against the paper #0F1A16** — black bands top and bottom; the last prose line is cut at 840 by the band (Terminal default c5). Title Iowan ≈24 semibold in ink (x-height 12.3 pt) / mono ≈22, one line beside four tools, cut "swipe & cho…" at default, "swi…" / "swip…" at AX5 (the masthead's layout: VM-148, recorded). Tools copy · find · lock · ⋯ in INK (#29241C / #23272B; light ink in dark), glyphs 21–27 pt tall. Membership "in the pocket guide" / "~/the pocket guide" in the corrected muted. The five chips at ≈15 (n x-height 8.3 pt) as bare words in a wrapping flow (Terminal wraps "lens" to a second row; AX5 two rows): SET chips (#pocket guide, blocks) in the corrected muted, EMPTY chips (no date, more info, lens) in the corrected **FAINT** (#8B7F6A 3.93:1 on white, #7E8376 on Terminal's paper, #766F5F 3.57:1 on the dark paper). Body Study Iowan 17 on a 27.3 pt pitch at the 20 pt margin; Terminal ≈15 on ≈25. The ⑂ mark beside block 3 at x 371–376 pt is 7.0 × 5.3 pt in a hairline muted grey (#6E675D) — visible but tiny. NO bottom bar. The system back button (glass circle) above the masthead (P-47-20). **No message line in any of the eight** — none lifted, none at the foot (R2-n1's rider). | The page's own ground MATCHES P-47-16/17. **DOES NOT MATCH** at the edges (W-A1: the paper does not reach the status bar or the home indicator; dark shows black bands and cuts the last line). The empty chips in the faint (W-A9). ANOTHER TICKET'S: the masthead's layout and the cut title (VM-148, recorded); the ⑂ mark's size (W-A13, VM-188 / VM-195). R2-n1: MATCHES (no lifted line). |
| 9 | The paper checks | c6 c7 c8 c9 (A ×4 default; B teal ×2) | **part A** (16 captures, default size). **c6** is PIXEL-IDENTICAL to c5 in all four combinations (difference bounding box: none) — no peek, no take tint and no pill were captured. **c7** "comments & callouts": the callout's blue wash behind block 2 (#E8F1F8 light, #14202B dark) with 💡 small at the frame's top-left; the ●1 in the comment ink (#6D5F3E / #B3A25F), its digit 13.7 pt — both clear on the paper in light and dark. **c8**: the keyboard and the keyboard bar's three resting glass cells (Aa · ⑂ · ⋯; Aa at 14, VM-137); NO caret is visible in any of the four (in dark the region above the keyboard is pixel-identical to c7). The band behind the keyboard bar (≈487–553 pt) is the bare window — #000000 in dark under the paper #0F1A16, #FFFFFF in light (Terminal's paper #FBFBF7). **c9**: a word selected ("is" / "a"); the selection wash readable over the words (#CFD8D5 behind ink in Study light, #3A5149 behind light ink in Study dark), handles in the accent (#3B6A59 / #90C1AF), the system edit menu over the chip row. | c7 MATCHES; c9 MATCHES. **NOT JUDGED** (no evidence captured): c6's take tint and pill; c8's caret. The black/white band under the keyboard bar is W-A1's mechanism (or the bar's own ground — see W-A1). |
| 10 | The core under teal & rust | part B's `teal_rust-…` k0–c9 | read by part B's readers — §4b | the Verdict column there; findings in §6 |
| 11 | Settings: the voice flipped | s04 s05 | read by part B's readers — §4b | the Verdict column there; findings in §6 |
| 12 | Settings: the appearance | s06–s11 | read by part B's readers — §4b | the Verdict column there; findings in §6 |
| 13 | A note's door to Settings | s12 s13 s14 | read by part B's readers — §4b | the Verdict column there; findings in §6 |
| 14 | Protection | s03b s03c, b13, r17 r17b | read by part B's readers — §4b (from the Library), §4c and §4d (from Settings, the wider pass) | the Verdict column there; findings in §6 |
| 15 | The bar on pushed lists | b1, b4, b8, b12, r02, r14, r15 | read by part B's readers — §4c | the Verdict column there; findings in §6 |
| 16 | A tab tapped from a pushed list | b2 b3 b7 b10 b11 | read by part B's readers — §4c | the Verdict column there; findings in §6 |
| 17 | No bar | b5, b6, b9, b13 | read by part B's readers — §4c | the Verdict column there; findings in §6 |
| 18 | The wing door's list | w1 w2 w3 | read by part B's readers — §4c | the Verdict column there; findings in §6 |
| 19 | The one message line | m1 m2 m3 | read by part B's readers — §4c (m3 absent — the driver's timing, §6 set 2 (a)) | the Verdict column there; findings in §6 |
| 20 | VM-54's flip | f1–f6 (×2 voices) | read by part B's readers — §4b | the Verdict column there; findings in §6 |
| 21 | Starred | r01 (×3) | read by part B's readers — §4c (Study light, default size) and §4d (Terminal dark; Study light at AX5) | the Verdict column there; findings in §6 |
| 22 | A book's contents | r02, b4, s0 | read by part B's readers — §4c (Study light, default size) and §4d (Terminal dark; Study light at AX5) | the Verdict column there; findings in §6 |
| 23 | Book Details | r03 | read by part B's readers — §4c (Study light, default size) and §4d (Terminal dark; Study light at AX5) | the Verdict column there; findings in §6 |
| 24 | A book's Read page | r04 r04b, b5 | read by part B's readers — §4c (Study light, default size) and §4d (Terminal dark; Study light at AX5) | the Verdict column there; findings in §6 |
| 25 | Create Book | r05 r05b | read by part B's readers — §4c (Study light, default size) and §4d (Terminal dark; Study light at AX5) | the Verdict column there; findings in §6 |
| 26 | The note's sheets | r06 r06b r06c r07 r07b r08 | read by part B's readers — §4c (Study light, default size) and §4d (Terminal dark; Study light at AX5) | the Verdict column there; findings in §6 |
| 27 | Note Actions | r09, s12 | read by part B's readers — §4c (Study light, default size) and §4d (Terminal dark; Study light at AX5) | the Verdict column there; findings in §6 |
| 28 | Versions | r10, b8, b9 | read by part B's readers — §4c (Study light, default size) and §4d (Terminal dark; Study light at AX5) | the Verdict column there; findings in §6 |
| 29 | The three UIKit overlays | r11 r12 r13 | read by part B's readers — §4c (Study light, default size) and §4d (Terminal dark; Study light at AX5) | the Verdict column there; findings in §6 |
| 30 | Trash | r14 r14b, b1, m2 | read by part B's readers — §4c (Study light, default size) and §4d (Terminal dark; Study light at AX5) | the Verdict column there; findings in §6 |
| 31 | Archived | r15, b12 | read by part B's readers — §4c (Study light, default size) and §4d (Terminal dark; Study light at AX5) | the Verdict column there; findings in §6 |

**Which PROVISIONAL calls each part shows.** Part A: P-47-1 (the sheet's numbers as a set), P-47-4, P-47-5 (dark), P-47-6,
P-47-7, P-47-8 (batch 1's role map), P-47-9, P-47-10, P-47-12, P-47-13 (Settings' header), P-47-14, P-47-16, P-47-17,
P-47-21, P-47-22, P-47-24, P-47-25, P-47-26, P-47-27; R-47-1, R-47-2 and R-47-3 (was P-47-28) as built. Part B: P-47-5 (teal & rust's
dark card), P-47-8 (VM-55's faces), P-47-11, P-47-13 (Create Book's Cancel), P-47-14 (the tag field), P-47-16 and P-47-17
under a second palette, P-47-18, P-47-19, P-47-20, P-47-21 (on pushed lists), P-47-22, P-47-23, P-47-27, VM-54's flip.
**Not shown:** P-47-15 (the lobby — the only lobby face this store shows is the words card, never captured), P-47-7's
320 pt case (Display Zoom — simctl cannot set it; the geometry pins are its evidence), VM-27's doored sync states (the store
never syncs; `MobileSettingsProtectionDoorTests` is that evidence), a second wing (the phone has no wing management — the
wing list shows Home alone).

**Part B is read in three sets** (one fresh reader each — a single reader's context cannot hold 184 captures): §4b, the second palette, Settings' flows and the border flip (76 captures); §4c, the bar's roads, VM-55's faces and the wider pass in Study light (60); §4d, the wider pass in Terminal dark and at AX5 (48). Rows 2–9 above carry part A's reading; where part B shot the same screen again its half is in §4b. Findings: part A's W-A1 … W-A13, set 1's W-B1 … W-B5, set 2's W-C1 … W-C8, set 3's W-D1 … W-D3 (§6).

## 4b. Part B, set 1 — the second palette, Settings' flows, the border flip

Read 2026-11-19 by part B's first reader (fresh, briefed from this file). **All 76 captures of the set are present**
(`final/`: 28 `teal_rust-study-{light,dark}-default--` k0–c9, the four `seaglass-study-light-default--s1b…s4b`, 16 + 16
Settings' flows `s01…s14`, 6 + 6 flips `f1…f6`; the walk log has a SHOT line for each and no MISSING in this set). Every
one was looked at full size; where two captures are pixel-identical (diffed — named in the rows) the pair was looked at
once. Grounds and inks by `walk_pixel` and column runs (a scratch helper with the same 3x arithmetic); sizes from pixels
÷ 3. **The tree walked is §0's** (`b20b04fad` + `50635a674`) — BEFORE part A's fixes, so W-A1, W-A3, W-A9 and W-A10 show
here as they were, not as fixed. Teal & rust's values were MEASURED, not looked up.

| # | Screen | Captures | Seen | Verdict |
|---|---|---|---|---|
| B1 | The core under teal & rust | `teal_rust-study-{light,dark}-default--` k0 k1 k2 k3 c1 c2 c3 c4 c4-results c5 (20) | **Teal & rust, measured.** Light: room #E1F4F2, paper #FFFFFF (Study's own; room vs paper 1.14:1 — sea-glass is 1.17), accent #AE4028 (5.17:1 on the room, 5.89 on the paper, 4.55 on the wash), line = wash #C3EAE6, field edge (take line) #ACE2DC. Dark: room #000000, paper #0C1D1B (1.21:1 vs black), accent #E08D7B (8.27:1 on black, 6.85 on the paper, 4.51 on the wash #16403C), line #143B36, field edge #1A4C46. The phone's inks are the voice's whatever the palette: muted #6A6359 (5.20:1 on the room, 5.93 on the paper, 4.58 on the wash) / dark #948C7C (6.30 on black, 5.22 on the paper); faint #8B7F6A (3.45 on the room, 3.93 on the paper) / dark #766F5F (4.21 on black, **3.49 on teal's dark paper** — the hardest case clears 3:1, P-47-5 (a) holds); ink #29241C / #E8E3D8 (15.40 / 13.59 on the paper). **k1–k3:** the header on the room ("Settings" Iowan in the muted, Done in the accent), section names 13 semibold muted on the room, rows on the paper with hairlines from the gutter, the sync line 13 muted, ONE "Protection…", Voice (Terminal · Study, Study chosen) and Appearance (Follow system · Light · Dark) as system segmented controls 45 pt tall (366–411), track the system's #EEEEEF light / #253234 dark; k2 reaches the foot (DEBUG groups, air); k3 = k2 but the scroll indicator (light), pixel-identical (dark). **k0:** the system pull-down from the ⋯, one item "Settings" in the system face, covering the count, 🗑, + New Note and ⋯. **c1:** path band the room 62–110, books on the paper 110–784, the palette's hairline at 784 (#C3EAE6 / #143B36), the bar's room 785–840; "Home" accent, the rest muted, "Home · Bookcase  ·  3 books" WHOLE; names Iowan semibold ink on a 45.3 pt pitch; meta 13 muted; the Today chip exactly 32.0 tall (117.3–149.3) on the wash with "✎ today" in the accent; "+ New Book" accent; the box's hint WHOLE "new note — just start typing · ↵ opens it" and its dashed edge in the faint; the bar's "Bookcase" semibold ink on a wash chip 35.7 tall, Starred/Library muted. **Edges:** light 0–62 and 840–874 #FFFFFF; dark #000000 (= the room). **c2:** the box open, its caret the system blue (#40A6FF light, #0374C6 dark — caught mid-blink), the books still visible, the bar above the keyboard 484–539 and the bare window 539–553 (#FFFFFF / #000000). **c3:** the field on the paper, 44.7 pt tall (109.7–154.3), take-line edge; its placeholder the system grey #C5C5C7 (1.72:1) / #4E5A5C on the dark paper (2.44:1); the filter row "All" ink, the other four in the faint (3.45:1 on the room / 4.21 on black), ↑↓ accent; rows titles only (the re-seed's "Walk note" first), no dates. **c4:** "swipe" in ink, the field still 44.7; caret pale blue (#BFE1FF / #093A54 mid-blink); one hit "swipe & choose" ink with "note" 13 in the muted; keyboard up (bar above it) / down in `-results`. **c5:** masthead and prose on the paper; light paper #FFFFFF is the window's white so no edge shows; dark paper #0C1D1B runs 62–840 between #000000 bands; title "swipe & cho…" ink, the four tools ink, membership muted; chips "no date", "more info", "lens" in the FAINT, "#pocket guide", "blocks" muted; body 17 on a 27.3 pitch at 20; ⑂ 5.3 × 7.0 pt at x 371; no bar; the system back circle; NO message line. Nothing under 13 pt outside the system's own. | **MATCHES** the relations §2 asks of a second palette: paper and room distinct in light (1.14:1), her prose and lists on the paper, every phone ink readable on every teal ground (dark faint 3.49:1 on the paper), the accent ≥ 4.5:1 on its own wash in both appearances. **DOES NOT MATCH** only where part A already found it, identically under teal & rust: W-A1 (#FFFFFF strips in light, #000000 bands round the dark note), W-A9 (filter words, empty chips), W-A10 (placeholder), plus W-A5, W-A7, W-A12, W-A13 as recorded. No new finding on these screens. |
| B2 | The paper checks under teal & rust | `teal_rust-study-{light,dark}-default--` c6 c7 c8 c9 (8) | **c6** pixel-identical to its c5 in BOTH appearances — no peek, take tint or pill captured (part A's result holds). **c7:** the callout's wash #E8F1F8 light / #14202B dark (the Mac palette's blue, `MobileCallout.color` — not the library palette's) behind block 2, 💡 at the frame's top-left; against the paper it is 1.14:1 light and **1.05:1 on teal's dark paper #0C1D1B** (1.08:1 on sea-glass's #0F1A16, 1.27:1 on the black it sat on before R-47-1) — readable in dark by its hue only (W-B2); the ●1 in the comment ink #6D5F3E (6.26:1) / #B3A25F (6.83:1), drawn 15.7 × 10.7 pt. **c8: a caret IS caught in both** — after "its", x 147.7–149.3, y 344.3–369.7 (1.7 × 25.3 pt): #EBCFC9 light = the accent #AE4028 at 25% over white, #76554B dark = #E08D7B at 50% over the paper — the editor's caret is the ACCENT, caught mid-fade; the keyboard bar's three glass cells (Aa · ⑂ · ⋯); behind them (487–553) #000000 under the dark paper, #FDFDFD–#FFFFFF over white in light. **c9:** "is" selected; the wash is the accent tinted (≈ #E4CFCA light, ink over it 10.3:1; ≈ #53423B dark, 7.4:1), handles the accent (#A63D26 / #DD8B79), the system edit menu over the chip row. No message line in any of the eight. | c7, c8, c9 **MATCH** (callout, comment mark, caret, selection readable on the paper). c6 **NOT JUDGED** (no evidence, as part A). c8 closes part A's gap for teal & rust — and sharpens **W-A7**: the editor's caret wears the accent, the fields' caret (c2, c4) the system blue. **FOR HER LOOK:** the blue callout on teal & rust's dark paper (W-B2). The keyboard-bar band is W-A1's (dark). |
| B3 | The re-seed's state (the driver's evidence) | `seaglass-study-light-default--` s1b s2b s3b s4b | **s1b** is pixel-identical to part A's `s1-seeded-note` and to `seaglass-study-light-default--c5-note-write`: the fanned lesson, NO ●1 — the comment's Add sat under the keyboard (the log: `NOT-HITTABLE comment submit … NOT tapped`, the Add frame at y 784 under a keyboard top at 583; VM-14). **s2b** the Library: "Walk note" first, then the lessons; the trashed note not listed. **s3b** Starred: ★ journal · book, ★ the pocket guide · book, ★ Walk note · note; the ★ #3D6B8E (the star token, blue); "book"/"note" in the FAINT #8B7F6A (W-A9's class — swept by its fix). **s4b** the Trash pushed from the Bookcase: "A note to put in the trash", "note  ·  30 days left", Put back (accent) and Delete Now (alarm) side by side (recorded: VM-100 / VM-153), the kind chips with "All" on the wash, the page on the paper #FFFFFF, the bar's room 785–840, #FFFFFF above 62 and below 840 (W-A1); **the window line "Deleted things wait here for 30 days, then they're gone." in the FAINT #8B7F6A (3.93:1, 13 pt)** (W-B1). | The library holds what part B needed — a starred "Walk note", a trashed note, both books starred, the lesson's saved version — EXCEPT the comment (VM-14's field under the keyboard; no comment mark anywhere in part B). The APP's, seen here: **W-B1** (THIS RUN'S DEFECT — the Trash's promise sentence in the faint); the rest as recorded. |
| B4 | The ⋯ menu on Starred and the Library | `seaglass-study-light-default--` s01 s02; `seaglass-terminal-dark-default--` s01 s02 | The same system pull-down as k0, grown from the ⋯, ONE item: "Settings" (Study) / "settings" (Terminal — lowercased, in the system's SF face, not the voice's mono); on Starred it covers the path line's right half and the first row's "book"; on the Library the path line's doors and the field's right half. Starred (Terminal) shows her names lowercased — "walk note" where the Library row says "Walk note" (`MobileStarredView.swift:127` runs the name through `chromeLabel`, as the Mac sidebar's `rowTitle` does — a note for set 2's r01, not counted); its ★ #5B93DE (Terminal dark's star token), drawn 7.0 × 6.7 pt (Study's 11.3 × 10.7). Grounds as c1/c3 (W-A1 strips in light). | **MATCHES** P-47-22 on a third root and on the Library (one menu, anchored at the ⋯, one item). FOR HER LOOK, as part A: the system menu's face is not Terminal's mono. |
| B5 | Settings from the Library and from a note; the note's ⋯ sheet | `seaglass-study-light-default--` and `seaglass-terminal-dark-default--` s03 s12 s13 s14 | **s03** (from the Library's ⋯) is pixel-identical to part A's k1 in the same combination except the presenting corners at 62–118 (≤ 12 levels — what shows behind the sheet): the same header, groups, rows, controls. **s12, the note's ⋯ sheet** ("Note" / "note" Iowan or mono 20 in ink, Done in the accent, a system grabber, a medium-height sheet, every row on the ROOM — the record's grounds table, "every SwiftUI sheet … on the room"; only Settings puts its rows on the paper): "Save a Version" and "Versions…" 17 in the accent, each with a 13 detail line in the FAINT (#8B7F6A / #6B7168 — W-A9's sweep, fixed since); then **TWO hairlines 13.3 pt apart with nothing between them** (646.7–647.3 and 660.3–661.0, both voices) above "Settings" (17, accent, no detail); a hairline; **"Delete Note…" in the SYSTEM red — #F23032 light, #FF4245 dark — not the alarm** (the Trash's own "Delete Now" in s4b wears the alarm #9B3B2F), its detail sentence in the faint. **s13**: the Settings sheet over the note — identical to s03 but its corners, where the dimmed NOTE now shows (#CCCCCC — the white paper dimmed; s03 shows the Library's room dimmed, #B7C0BD): VM-53's road holds. **s14** after Done: pixel-identical to part A's c5 in the same combination but the back circle's glass (≤ antialias): the note in Write, NO message line, no bar. | **MATCHES** "Settings from every root and from a note" (k1 Bookcase, s03 Library, s13 note; the ⋯ on Starred in s01) and R2-n1 (no lifted line in s14). **DOES NOT MATCH** in the note's ⋯ sheet: the doubled hairline (W-B4) and Delete Note… in the system red against the sheet's alarm (W-B3), both voices; its detail lines in the faint are W-A9's, fixed. |
| B6 | Protection from the Library | `seaglass-study-light-default--` and `seaglass-terminal-dark-default--` s03b s03c | **s03b:** Protection PUSHED on the Library's stack — the system back circle top-left, NO bottom bar (P-47-18, P-47-20, P-47-23); "Protection" Iowan / "~/protection" mono ≈ 20 in the muted; group names 13 semibold muted ("Your passphrase", "Your twelve words", "Sync"); doors 17 in the accent ("Set a passphrase…", "Record your twelve words…", "Check my passphrase or twelve words…" — two lines in Terminal, wrapped not cut, "Use Castle…", "Sign in…"); the explainer sentences in the corrected muted at 13 on an 18 pitch (`meta` — §3f's r17b expects 15: set 2 judges r17/r17b); "You're in Standard." and "This library doesn't sync." in ink; hairlines between groups. The WHOLE page is on the ROOM (#E5F0EC light; #000000 dark) — as the record's grounds table built it ("…and Protection — on the room"). Edges: Study light #FFFFFF 0–62 and 840–874 around the room (W-A1 on a pushed screen); Terminal dark all #000000. **s03c:** Back lands on the Library ROOT — Study light pixel-identical to s2b; Terminal dark as s02 without the menu. | **MATCHES** P-47-18 (no bar), P-47-20 (the system back bar), P-47-23 (on the stack she came from; Back returns there). W-A1 shows on this pushed screen in light (its re-capture list names s03b). Nothing new. |
| B7 | Settings: the voice flipped (R-47-2) | `seaglass-study-light-default--` and `seaglass-terminal-dark-default--` s04 s05 | **s04, Study light → "Terminal" pressed:** the sheet re-voiced AT ONCE — "~/settings", "done", "library", "look", "voice", "protection…", "manage tags" lowercased in SF Mono; the rows' paper became Terminal's #FBFBF7, the inks Terminal's (muted #61655F, ink #23272B), the room the palette's #E5F0EC, the track #EAEAE8; "terminal" chosen in ink on the thumb; "Sync off (dev store)" keeps its capital (the shared `SyncStatusRow`, as part A noted). **Terminal dark → "Study" pressed:** pixel-identical to part A's `seaglass-study-dark-default--k1-settings-top`. **s05** after Done: the Bookcase in the NEW voice — the Study-light run's is part A's Terminal light c1 to the pixel but for the hint's blinking ▋ (off in this frame), "~/home/bookcase  ·…" (W-A2); the Terminal-dark run's is pixel-identical to part A's Study dark c1. | **MATCHES R-47-2:** the Library's voice flips at once on the sheet and on the root, Terminal's chrome lowercased, both directions. |
| B8 | Settings: the appearance (LK-1/LK-2) | `seaglass-study-light-default--` s06–s09 `…-dark-…`, s10 `-light-chosen`, s11; `seaglass-terminal-dark-default--` s06–s09 `…-light-…`, s10 `-dark-chosen`, s11 | **Every surface took the chosen appearance at once, and back.** **s06:** the sheet in the chosen appearance, differing from part A's k1 of that appearance ONLY in the Appearance control (464.7–505.7 pt); the presenting area and the status bar follow (black with white glyphs / grey with black). **s07:** the Bookcase root — the Study run's (→ dark) pixel-identical to part A's Study dark c1; the Terminal run's (→ light) identical to Terminal light c1 but the ▋'s blink: room, paper, bar all in the chosen appearance. **s08:** the note in Write — UIKit editor, masthead and prose — differs from part A's c5 of that appearance only in the back circle's glass (antialias); her prose on that appearance's paper (#0F1A16 / #FBFBF7). **s09:** the takes overlay (UIKit) in the chosen appearance: dark — ground #0F1A16, cards #15261F, chosen edge #93B57E, other edges #1C332A; light — ground #FBFBF7, cards #FDFDFA, chosen edge #2F7D5F, others #CBE2D9; its scrim is the INK at 25% (`MobileTakesBrowserView.swift:295`), so in dark it LIGHTENS the note (#454C47 over #0F1A16) and in light darkens it (#C5C6C4 over #FBFBF7), covering only the editor's region (283 / 326 pt down), not the masthead (W-B5). **s10:** the simulator's own word pressed — the sheet in the simulator's appearance, that segment chosen; **s11:** "Follow system" chosen — identical to s03 but the edge band. No surface was left in the other appearance. **W-A1 in the flipped appearance:** the window's own ground follows the CHOSEN appearance — #000000 bands round the dark paper in the Study run (s08: 0–62 and 840–874 around #0F1A16), #FFFFFF strips round the light room and paper in the Terminal run (s07: #FFFFFF / #E5F0EC / #FBFBF7; s08: #FFFFFF around #FBFBF7). No message line in s08. | **MATCHES** LK-1/LK-2 and P-47-24 (the Mac's three words, nothing beneath): the sheet, the root, the UIKit editor and the UIKit overlay all redraw in the chosen appearance and come back. W-A1 shows exactly as in the native appearance (the bands are the window's, which follows the choice). The overlay's scrim (W-B5) is VM-152's overlay. |
| B9 | VM-54's flip — borders follow light → dark | `seaglass-study-light-default--` and `seaglass-terminal-light-default--` f1–f6 | Each dark capture was shot within a second of the simulator's flip (the log's FLIP / SHOT lines). **f1 → f2, the takes cards:** Study — chosen edge #5A7D46 → #93B57E, the others #CBE2D9 → #1C332A (top, bottom and left edges measured), card #FFFFFF → #15261F, ground → #0F1A16; Terminal — chosen #2F7D5F → #6FBF94, others #CBE2D9 → #1C332A, card #FDFDFA → #15261F. **f3 → f4, the comment draft:** its edge #CBE2D9 → #1C332A (all four sides at 784/823 and 16/321 pt), its fill #FFFFFF / #FDFDFA → #15261F, "Add a comment…" muted → dark muted (#6A6359 → #948C7C; #61655F → #8B9088). A sweep of every pixel between the status bar and the home indicator of all six dark frames finds NONE of the light tokens (#CBE2D9, #B7D7CB, #5A7D46, #2F7D5F, #E5F0EC, nor the light inks). **f5:** NO pill and NO peek in either voice — block 3 still shows its chosen take (the in-page swipe did not peek, as c6). **f6:** a MID-TRANSITION frame in both voices (the system's light → dark cross-fade, shot the same second as the flip): the paper #A8ACAB (Study) / #8A8F8B (Terminal), neither light nor dark; no pill. The comment draft field is 40 pt tall and Add 52 × 40 (the log; VM-14 / VM-152). | **MATCHES VM-54:** no border left in its light colour after the flip — card edges, the chosen edge and the draft field's edge all measured in their dark colours. **NO EVIDENCE** on the pill (f5 caught no pill; f6 is a transition frame). |

## 4c. Part B, set 2 — the bar's roads, VM-55's faces, the wider pass (Study light)

Read 2026-11-19 by part B's second reader (fresh, briefed from this file). **All 60 captures of the set are present**
— the bar's roads and VM-55's faces, 18 + 18 (b1–b13, w1–w3, m1, m2), and the wider pass's first combination, 24 (r01 …
r17b); §3d's `m3-after-undo` is ABSENT in both combinations (the log: `[m3] MISSING the line's Undo` — §6 "Part B, set
2", question (a), says why). Every one
looked at full size; pixel-identical twins (diffed, named in the rows) looked at once. Grounds and inks by `walk_pixel`,
column runs and an ink-bounding-box helper with the same 3x arithmetic (scratch, not committed); sizes from pixels ÷ 3;
contrast by the WCAG arithmetic. **The tree walked is §0's** (`b20b04fad` + `50635a674`) — BEFORE part A's fixes, so
W-A1, W-A3, W-A9 and W-A10 show as they were. Where I traced code, HEAD is `1973c98b7`.

| # | Screen | Captures | Seen | Verdict |
|---|---|---|---|---|
| C1 | The bar on pushed lists | b1 b4 b8 b12 (both), r02 r14 r14b r15 (Study light), m2 (both) | **The bar at the FOOT on every pushed list**, both combinations: Study light the palette's hairline #CBE2D9 at 784 and the room #E5F0EC 785–840, the chip the wash #CBE2D9 794–830 (36 tall); Terminal dark hairline #1C332A at 784, the room #000000 785–874, chip #1F382F. **The chip's word is the owning stack's:** "Bookcase" on b1 (the Trash from the Bookcase), b4 / r02 (the pocket guide's contents), r14 / r14b; "Library" on b8 / r10 (Versions' listing), b12 / r15 (Archived), m2 (the Trash pushed from the LIBRARY's 🗑). The list itself on the paper (#FFFFFF / #0F1A16) from 62 to 784. **b4 is normal** — the bar at 784–840, no keyboard, the rows running to the bar's hairline. What differs in part A's `s0` (the same contents, the bar lifted to 484–539 with no keyboard drawn): the road, not the screen — `s0` was shot straight after the seed had typed into the Bookcase's box and opened Settings over it (the box's focus live under the push); b4 came after b1–b3 with no field focused. **b10 reproduces the same lifted position, 484–539 to the point, with the keyboard drawn** (C2, W-C2). | **MATCHES P-47-18 / P-47-21 on pushed lists** (the bar at the foot, the owning tab's word on the chip, cells as on the roots). W-A1 at the foot in Study light (840–874 #FFFFFF under the bar's room) and, in Terminal dark, the #000000 strip 0–62 above the paper on every pushed list. |
| C2 | A tab tapped from a pushed list | b2 b3 b7 b10 b11 (both) | **Every landing is a ROOT** — no back circle, the root's path line: b2 the Library root (from the Trash); b3 the Bookcase root, pixel-identical to part A's `c1` in BOTH combinations (the Trash it left is gone); b7 pixel-identical to b3 (the current tab popped its own stack from the book); b11 the Library root (the Versions listing and the note under it closed — P-47-19's "a note below a list closes as Back would"). **BUT b10 and b11 carry the KEYBOARD, in both combinations:** b10 is the Bookcase root with the box AT REST (its hint, no caret; in Terminal no ▋) and a software keyboard up, the bar lifted above it to 484–539 (hairline 483), nothing on the Bookcase focused; b11 shows whose keyboard it is — the Library's search field holding "swipe" with a caret (the walk had searched "swipe" to open the lesson for b8). b8 and b9 (the listing and the reader, over the same stack) have NO keyboard: the field gave the keyboard up when the note was pushed and took it back when P-47-19 popped the Library's stack to its root while its page was a screen-width away. | **MATCHES P-47-19** for where each tap lands (roots only, the stacks back at their roots). **DOES NOT MATCH** in b10: a keyboard over the Bookcase with nothing on the Bookcase focused, typing into a field on a hidden page, the bar lifted 300 pt — **W-C2** (THIS RUN'S, born of P-47-19's leaving-stack pop). |
| C3 | No bar | b5 b6 b9 b13 (both), r04 r04b r17 r17b | **No bar on any:** b5 / r04 Read (the cream page to the foot); b6 the note from the book (Write, the paper; Terminal's black bands 0–62 and 840–874 round it — W-A1); b9 the Versions reader — at its foot the reader's OWN verbs band (Restore · Promote 15 accent, Delete… 15 alarm #9B3B2F / #E08A7C) on the room 776–840 under a #CBE2D9 / #1C332A hairline, not the tab bar; b13 / r17 Protection (pushed on the Bookcase's stack; pixel-identical to set 1's `s03b`, which came from the Library). **(e) — no message line in b6 or b9, in either combination:** nothing at the foot, nothing lifted (the note pushed over a list and the reader over its listing — R2-n1's two untested roads). | **MATCHES P-47-18** (no bar on Read, a note, the reader, Protection) and **R2-n1** (no lifted line on either road). |
| C4 | The pushed screens' top edges (P-47-20, W-009 — for her look) | b1 b4 b5 b6 b8 b9 b12 b13 (both) | Every pushed screen keeps the SYSTEM bar row (62–106) holding the iOS 26 round glass back button (44 pt, x 16–60; white glass with a soft shadow in light, dark glass #182520 with a palette-tinted rim in Terminal dark); the row's ground is the page's own. Then, per screen: **Trash** — nothing else in the bar row; ≈35 pt of empty page, then the page's header line at 141–160: "Trash" Iowan ≈20 in the corrected muted #6A6359 / "~/trash" mono ≈18 #8B9088, with "newest first" (15, accent) and "Empty Trash…" / "empty trash…" (17, the alarm #9B3B2F / #E08A7C) on the same line; the promise line; the kind chips. **A book's contents** — the bar row also holds ONE glass capsule at the right with "Details" and "Read" (17; the system's label colour, #000000 on light, #F3F4F4 on dark — not a token; Terminal "details read" lowercased in mono); under it the book's name Iowan ≈20 ink at 131 (Terminal mono, 128). **Read** — the back circle alone over the voice's room (#FAF8F3 / #000000); the cream page card from ≈124 pt; scrolled (r04b) the prose passes UNDER the glass button with the system's scroll-edge fade. **A note from a book** — the back circle alone; the masthead (title, the four tools) from ≈135. **Versions' listing** — the back circle alone; "Versions" / "~/versions" ≈20 muted at 133. **Versions' reader** — the back circle (the system's) AND, under it at 143, the app's own "‹ Versions" / "‹ versions" (15, accent): two back doors stacked, going to different places (the reader replaced its listing, so the system's leads to the note and the app's to the listing). **Archived** — the back circle alone; "Archived" / "~/archived" at 133. **Protection** — the back circle alone; "Protection" / "~/protection" at 140. | **FOR HER LOOK** (P-47-20 (a) as built): the empty trailing bar row everywhere but the book's contents; the system-coloured "Details · Read"; the reader's two stacked backs. No defect against the sheet. |
| C5 | The wing door's list (VM-55) | w1 w2 w3 (both) | **w1 / w2:** a MEDIUM-height sheet (top at ≈415 pt) with the system grabber, floating 8 pt in from the screen's sides, on the room (#E5F0EC / #000000 — in Terminal dark a black sheet over a black-dimmed root, its edge barely findable). Header: "Wings — each a separate library" / "wings — each a separate library" Iowan / mono in INK, 20 (W cap 14.7 pt) on TWO lines (440–486) beside "Done" / "done" 17 semibold accent (D cap 12.0; #3B6A59 5.31:1, #90C1AF 10.43:1) at the sheet's 20 pt gutter (x 27.3 = 8 + 19.3). One row: "✓ Home" / "✓ home" — the ✓ 8.7 × 8.7 pt (13 pt) in the accent, "Home" 17 (H cap 12.3) in ink #29241C 13.21:1 / #D6DAD2 14.82:1, at x 28 / 47. The same list over the Library (w2). **w3:** the pick lands on the Bookcase ROOT — pixel-identical to b3 in Study light; in Terminal identical but the box hint's blinking ▋ (a 7 × 14 pt box at 297–305). | **MATCHES P-47-8** (title, Done 17 semibold, the row 17 in ink with a 13 ✓ in the accent, on the room, medium detent) and VM-55's landing. The row's 44 pt can't be measured from a drawn shape (no separators) — not judged. The title in ink (a sheet header's, not a muted path) is the sheet §E header's. |
| C6 | The one message line | m1 m2 (both); m3 ABSENT (both) | **m1:** a note sent to the Trash from its Library row; THE line at the foot ABOVE the bar, never over its doors — its hairline at 721 (#CBE2D9 / #1C332A, the palette's line), its ground the room (#E5F0EC / #000000) 722–784, its foot on the bar's hairline at 784. Words "Note moved to the Trash — 30 days to put it back." / lowercased in mono, 15 pt (N cap 10.7) in the corrected muted (#6A6359 5.08:1 on the room / #8B9088 6.44:1 on black), **wrapped to TWO lines (737–768.7)**, so the line is **63 pt tall, not one 44 pt line**; "Undo" / "undo" 15 semibold (U+d 11.7) in the accent (#3B6A59 5.31:1 / #90C1AF 10.43:1) at x 328–365 (Study) on the first line. It floats over the Library's last row (by design). **m2:** the Trash pushed from the Library's 🗑 while the line still shows — the SAME line at the same 721–784, above the Trash's bar ("Library" on its chip). The bar under it 785–840; Study light's 840–874 #FFFFFF (W-A1). | **MATCHES** the line's PLACE (meeting 2: above the bar on a root and on a pushed list, never over the doors), its ground, hairline, inks, sizes and Undo. **DOES NOT MATCH** the sheet §E's "One line, 44 tall": these words wrap, 63 pt — **W-C1** (a question for her). m3: NOT CAPTURED — the driver's timing, not the app (§6, question (a)). |
| C7 | Starred | r01 (Study light; pixel-identical to set 1's `s3b`) | Path band the room #E5F0EC 62–110 ("Home" accent #3B6A59, "· Starred" muted; ⋯ accent, 20.3 × 4.3 pt); rows on the paper #FFFFFF 110–784; three rows on a 44.0 pt pitch (126 · 170 · 214); **the ★ #3D6B8E — the star token, blue, 5.69:1 — 11.3 × 11.0 pt at x 21**, never the accent; names Iowan semibold 17 in ink #29241C (journal, the pocket guide, Walk note — Study keeps her capital); "book" / "note" 13 at the trailing edge in the FAINT #8B7F6A 3.93:1; the bar with "Starred" on the wash chip. Edges: #FFFFFF 0–62 and 840–874 (W-A1). | **MATCHES** the ★ check, the rows and the grounds. "book"/"note" in the faint are W-A9's (swept since — r01 is on its re-capture list). |
| C8 | A book's contents | r02 = b4 (pixel-identical), s0 compared | The name "the pocket guide" Iowan semibold ≈20 (20.7 pt t→g) in ink at 131; chapter labels (welcome, writing, takes, structure) 13 semibold in the corrected muted #6A6359 5.93:1; note rows Iowan semibold 17 ink on a 44.1 pt pitch; all on the paper #FFFFFF; the bar at the foot ("Bookcase"). "+ New Note" / "+ New Chapter" are below the fold (the list runs on under the bar) — not in the frame. The top edge as C4. | **MATCHES** (name 20, labels 13 semibold, rows ≥ 44 on the paper, the bar). The two "+" doors NOT JUDGED (not on screen). |
| C9 | Book Details | r03 | A MEDIUM sheet (top ≈415) with the system grabber, on the room #E5F0EC. Header "Book Details" Iowan ≈20 ink (13.21:1), "Done" 17 semibold accent at 455–467. The book's name Iowan semibold 17 ink; "17 notes · #pocket guide" 13 muted 5.08:1. Rows: "Finish" (17, accent) and "Delete Book…" (17, the ALARM #9B3B2F 5.88:1), each 68.7 pt (576.7–645.3 between palette hairlines #CBE1D9), each with its detail line TRAILING on the label's own line (an `HStack`), 13 in the FAINT #8B7F6A 3.37:1 ("a finished book reads ✓ and freezes its notes", "Its notes stay in the library."). | **MATCHES** (the header, rows ≥ 64, Delete Book… in the alarm — the very ink Note Actions' Delete Note… lacks, W-B3). The detail lines in the faint are W-A9's (its sweep named Book Details' detail lines; r03 is on its re-capture list). FOR HER LOOK: the detail beside the label, not under it as sheet §E draws a menu row. |
| C10 | A book's Read page | r04 = b5 (pixel-identical), r04b; b5 Terminal dark | Study light: the room #FAF8F3 (the voice's own, never the palette's) ✓; the cream page #FFFDF6 as a rounded card from ≈124 pt; text #2A2620 14.77:1; book title ≈25 (24.3 pt t→g); "I · WELCOME" spaced caps #A49681 2.84:1 (cap 10.0 → ≈14 pt); note title ≈21; prose 17 on a 27.1 pt pitch at x 34; **r04b** the flow continues ("app, not in you." → "note 1 of 17 · i" → "getting around"), the page meta 13 in #C2BCB0 — **1.86:1 on the cream**. Terminal dark: room #000000, page #171511, text #E3DCD0 13.38:1, the chapter label in SF MONO #8D8371 4.88:1 (Study's is SF Pro — the label takes the voice's chrome face on a voice-independent page). Edges, Study light: #FFFFFF 0–62 and 840–874 round the #FAF8F3 room and the last prose line cut at 840 (W-A1). | **MATCHES** the ground, the cream page and serif 17/27, titles 25/21. The page meta's own pale ink (1.86:1) and the chapter label's 2.84:1 are batch 1's recorded "for her look". |
| C11 | Create Book | r05 r05b | A FULL-height sheet, no grabber (VM-152's detents), on the room. "New Book" Iowan ≈20 ink; **"Cancel" 17 in the accent, SEMIBOLD** (its stems 6 px = Done's 5–6 px at 3x) in Done's place — P-47-13 ✓. The name field 151.7–196.3 = **44.6 pt**, the paper #FFFFFF, the take-line edge #B7D7CB; its placeholder "Name" in the system grey #C5C5C7, 1.72:1 (W-A10). The kind as the system segmented control, **45 pt** (210–255): "Book" chosen in ink on a paper thumb; "Journal Book", "Smart Book" 15 in the corrected muted #6A6359 **on the system's track #D7E1DE — 4.44:1**. The explainer 13 muted 5.08:1. The calm button "Create Book" full width at the foot (776–820, 44), DISABLED (no name yet): the whole control at 35% — fill #EEF5F3, edge barely there, the word #B0C4BD, **1.65:1**. **r05b** "Smart Book" pressed: the segment moved (Smart Book on the thumb, the others 4.44:1); the explainer two lines; the tag rows "#machiavelli" / "#pocket guide" Iowan semibold 17 ink with their paths 13 in the faint #8B7F6A 3.37:1, on a 44 pt pitch, behind an empty 22 pt leading column (the ✓ draws only once picked). The OR / AND choice is NOT on screen — it appears only when several tags are picked (`MobileCreateBook.swift:51`). | **MATCHES** P-47-13 (Cancel semibold), the field (≥ 44, paper, take-line edge), the segmented choice's size, the calm button's shape. **DOES NOT MATCH:** the unchosen segment words under §D's 4.5:1 (**W-C4**); the placeholder (W-A10, fixed since); the tag paths in the faint (W-A9, swept since). A QUESTION: the disabled calm button's word at 1.65:1 (**W-C5**). OR / AND NOT JUDGED. |
| C12 | The note's sheets | r06 r06b r06c r07 r07b r08 | All FULL height with no grabber (VM-152), on the room #E5F0EC; headers Iowan ≈20 ink + "Done" 17 semibold accent (D cap 12.3). **r06 Tags:** the tag field 149.7–194.3 = 44.6 pt, paper, take-line edge; its hint in the system grey #C5C5C7 (W-A10) and **CUT mid-word: "type a tag — ↩ applies it ("/" nests: life/go…"** at 17 (**W-C6**); applied "#pocket guide" Iowan semibold 17 ink with "✕ remove" 15 muted 5.08:1; **"Apply a tag" 13 semibold in the FAINT #8B7F6A, 3.37:1**; "+ #machiavelli" 17 accent. **r06b Books:** "the pocket guide" Iowan semibold 17 ink with "diverge" / "remove" 15 muted (inline acts, muted tone); **"Add to a book" 13 semibold in the FAINT, 3.37:1**; "+ journal", "+ the prince" 17 accent on a 48 pt pitch; **"Editing here edits the note everywhere it appears." 13 in the FAINT, 3.37:1**. **r06c More Info:** "Nothing kept beside this note yet — add a link below." 13 muted 5.08:1; "+ add a link" 17 accent. **r07 Blocks:** "Select" 17 accent (regular) beside "Done"; the segmented choice "in the note · archived · leaving" 45 pt (150–195), unchosen words 4.44:1 on #D7E1DE (W-C4); block rows her words Iowan 15 in ink on the room (VM-149's ground); the ⑂ beside the fanned block 5.3 × 7.0 pt at x 375 (W-A13 on a new screen). **r07b leaving:** "leaving" on the thumb in ink ✓ (Select gone); "Leaving — on the 30-day clock" 13 semibold muted; **its explainer "Everything this note has on the 30-day clock. Put back keeps a row; Delete Now ends its days early." 13 in the FAINT, 3.37:1, two lines** — the sizing sheet §A draws this very sentence in the corrected muted; "Nothing from this note is on the clock." 13 muted. **r08 Lenses:** "› the note" Iowan semibold 17 accent; the empty sentence 13 muted; **a hairline in the SYSTEM separator #B4BCBB** (not the palette's line); "save the current view as a lens…" 17 accent. | **MATCHES** the headers, the field heights, the segmented choice's chosen state, inline acts 15, "+" rows 17 in the accent. **DOES NOT MATCH:** section headers and sentences in the faint (**W-C3** — "Apply a tag", "Add to a book", "Editing here…", the tray's explainer); unchosen segment words 4.44:1 (W-C4); the tag hint cut (W-C6, a question); the Lenses hairline the system's grey (**W-C7**). |
| C13 | Note Actions | r09 = set 1's `s12` (pixel-identical) | As set 1 read it: "Note" Iowan 20 ink + Done; "Save a Version" / "Versions…" 17 accent with 13 detail lines in the faint; the doubled hairline above "Settings" (646.7 and 660.3, #CDE1D9 — the palette's line, twice); "Delete Note…" in the system red #F23032. | **DOES NOT MATCH** — W-B3 and W-B4 show here too (identical); the faint detail lines are W-A9's (fixed since). Nothing new. |
| C14 | Versions | r10 = b8 (pixel-identical); b9 (both) | **Listing (b8):** the paper #FFFFFF / #0F1A16 62–784; "Versions" Iowan ≈20 / "~/versions" mono in the muted #6A6359 / #8B9088; **the explainer (three lines in Study, four in Terminal) 13 in the FAINT — #8B7F6A 3.93:1 / #6B7168 3.55:1**; the moment's row: "Nov 19, 2026 at 4:18 PM" Iowan semibold ink, its meta 13 muted (#6A6359 5.93:1) "4 blocks · “Takes are for trying; CHOOSING is deciding. The take with the ✓ ”"; the bar ("Library"). **Reader (b9):** "‹ Versions" 15 accent; the moment's title Iowan ≈20 in the MUTED (the path voice; Terminal "~/nov 19, 2026 at 4:18 pm"); **its meta line in the FAINT (#8B7F6A 3.93:1 / #6B7168 3.55:1) — the same line the listing draws in the muted**; her prose 17 Iowan / 15 mono in ink on the paper; the verbs band on the room 776–840. **Terminal lowercases HER words in both meta lines:** "“takes are for trying; choosing is deciding. the take with the ✓ ”" — her CHOOSING lost (**W-C8**). | **MATCHES** the bar (listing), no bar (reader), the paper, the title and prose sizes. **DOES NOT MATCH:** the explainer and the reader's meta in the faint (W-C3); her excerpt lowercased in Terminal (W-C8, a question — predates the run). |
| C15 | The three UIKit overlays | r11 r12 r13 | **r11 Takes:** the overlay's white ground from 395 pt; "Takes · block 3 of 4" Iowan ≈20 muted #6A6359; "Done" 17 accent (regular); three cards on #FFFFFF, the chosen card's edge the chosen #5A7D46, the others the take line; "✓ Chosen" ≈14 (C cap 10.0) in #5A7D46 4.71:1; "Take 2", "Take 3" ≈14 muted; per card a ✓ (#5A7D46, 9.0 × 8.7) and ⋯ (muted); her words Iowan 17 ink; "All Takes to Blocks" ≈15 accent; "+ New take" ≈14 semibold MUTED; "Branch this one ⧉", "Blank ○" ≈15 accent. The ink-at-25% veil (#C9C8C6 over the paper) covers the prose from 283 pt; the masthead above it undimmed (W-B5). **r12 Block History:** "Block History" ≈20 muted; Done; "Commits" 13 semibold muted; its explainer 13 muted on a TIGHT ≈15.5 pt pitch (three lines in 41 pt; the meta role's line is 18); "▾ take 1 of 3 · the take you're in" 13 semibold in the chosen green #5A7D46 4.71:1; each take's COUNT "1" (13, muted) sits on its OWN line under its header at x 377–381, not on the header's line; the commit row "The rain came in from the sea witho…" Iowan 17 ink cut, "Nov 19, 2026 at 4:19 PM · quiet" 13 muted, "Restore" 15 accent. **r13 Comments:** "Comments" ≈20 muted; "No comments on this block yet." 13 muted at x 17.0 (3 pt left of the 20 gutter the title holds); the draft field 784–824 = 40 pt tall with the take-line edge, "Add a comment…" Iowan 17 muted; "Add" 17 accent. Nothing under 13 pt (the card labels ≈14, the counts and meta 13); nothing overlapped. | **MATCHES** "text 13 or more" (the smallest ≈14, the counts 13). As recorded: the hand-built frames, the 40 pt draft field, the stacked counts, the tight explainer pitch, the empty line's 17 pt inset (VM-152 / VM-41 / VM-14 / VM-193); the veil (W-B5, VM-152). |
| C16 | Trash | r14 r14b (b1, m2 above) | As b1 (C1, C4): "Trash" ≈20 muted, "newest first" 15 accent, "Empty Trash…" 17 alarm (E cap ≈12 → 17); **the promise "Deleted things wait here for 30 days, then they're gone." 13 in the FAINT #8B7F6A 3.93:1** (Terminal dark #6B7168 3.55:1, two lines); the kind chips in ONE sideways row: "All" on the wash #CBE2D9 in ink (11.31:1), "Notes", "Books", "Blocks", "Snippet gro…" edged in the take line #B7D7CB (32.7 pt capsules, 204.3–237.0) with 15 pt words (N cap 10.7) in the corrected muted #6A6359 5.93:1; the row's clip at ≈392 pt (≈10 pt short of the screen's edge, inside the margin) cuts "Snippet groups" — the rest (Originals) scroll. **The phone's Trash has SIX kinds, not §3f's seven: All · Notes · Books · Blocks · Snippet groups · Originals** — takes are not a Trash kind (`TrashScope.filterKinds`, `RecoveryActs.swift:924`; a take lives in its note's tray). Rows: three notes ("A note for the message line" ×2 — both m-runs' notes, since m3 never pressed Undo — and "A note to put in the trash"), titles Iowan semibold 17 ink, "note · 30 days left" 13 muted, "Put back" 15 accent and "Delete Now" 15 alarm side by side (VM-100 / VM-153). **r14b:** "Notes" on the wash in ink, "All" edged; the listing (all notes) unchanged. | **MATCHES** P-47-11 (chips: chosen on the wash in ink, others edged and muted, 32 pt, one sideways row), "Empty Trash…" 17 in the alarm, inline acts 15. **DOES NOT MATCH:** the promise in the faint — W-B1 shows here (and in Terminal dark at 3.55:1, wrapped). The §3f "Takes" chip is the walk doc's slip, not a defect. |
| C17 | Archived | r15 = b12 (pixel-identical); b12 Terminal | The paper #FFFFFF / #0F1A16; "Archived" / "~/archived" ≈20 muted; **"kept — no clock" 13 in the FAINT** (#8B7F6A 3.93:1 / #6B7168 3.55:1); the filter row "All" (ink) · "Notes" (the faint — W-A9) at 13, **starting at x 28.3, 8 pt inside the 20 pt gutter the title holds** (the shared row's own 20 pt padding inside the Archive's 8 — both predate the run); "Nothing archived." 13 muted; the bar ("Library"). | **MATCHES** the bar and the paper. W-B1 (its promise) and W-A9 (Notes) show here. The 8 pt indent is noted, not filed (predates the run; the row's rebuild is VM-93's). |
| C18 | Settings | r16 = part A's `seaglass-study-light-default--k1-settings-top` (pixel-identical) | As part A read it. Measured here for W-C4: the unchosen segment words on Settings' light track #EEEEEF are 5.11:1 (Study) — clear; on part A's DARK Settings (`seaglass-study-dark-default--k1…`, `seaglass-terminal-dark-default--k1…`) the track is #273030 and the unchosen words are **#948C7C 4.06:1 / #8B9088 4.15:1**. | **MATCHES** in Study light. W-C4 in dark (part A's captures, measured by this reader). |
| C19 | Protection | r17 = b13 (both pixel-identical to set 1's `s03b`), r17b | The whole page on the room. "Protection" Iowan ≈20 muted; group names 13 semibold muted ("Your passphrase", "Your twelve words", "Sync"); doors 17 in the accent (S cap 12.7); **the explainer sentences 13 (V cap 9.7, E cap 9.3) in the corrected muted #6A6359 5.08:1 on an ≈17.7 pt pitch** — the sizing sheet §A's meta role names "explainer sentences" at 13/18, so §3f's "its sentences 15" is the walk doc's slip, not the sheet's; the state lines "You're in Standard." Iowan 17 ink and "This library doesn't sync." Iowan ≈15 ink; "Sign in to turn on sync." 13 muted; hairlines between groups. **r17b is r17 again** (diff ≤ 2 levels at the back glass): the page fits the screen, so the swipe moved nothing — its "lower sections" are the ones r17 already shows. Edges: #FFFFFF 0–62 and 840–874 round the room (W-A1). | **MATCHES** the sheet (sentences 13 muted ≥ 4.5:1, doors 17, headers 13 semibold); P-47-18 (no bar). Nothing under 13 pt. Protection's words are VM-110's. |

## 4d. Part B, set 3 — the wider pass in Terminal dark and at AX5

Read 2026-11-19 by part B's third reader (fresh, briefed from this file). **All 48 captures of the set are present** —
`seaglass-terminal-dark-default--` r01 … r17b (24) and `seaglass-study-light-ax5--` r01 … r17b (24); the walk log has a
SHOT line for each (`[r01]` … `[r17]`, 00:44–00:53Z) and no MISSING, NOT-HITTABLE or NOT CAPTURED in this set. Every one
looked at full size, each beside its Study-light-default twin on `walk_sheets`; pixel-identical pairs (diffed) named in
the rows and looked at once. Grounds and inks by `walk_pixel`, column runs and an ink-box helper with the same 3x
arithmetic (scratch, not committed); sizes from pixels ÷ 3 — an AX5 size is the glyph's height against its default twin's
times the role's default size (×2.8 for her words' rows, ×1.33 for the chrome hold); contrast by the WCAG arithmetic.
**The tree walked is §0's** (`b20b04fad` + `50635a674`) — BEFORE the walk's fixes, so W-A1, W-A3, W-A9, W-A10 and the
batch-2 set (W-B1, W-B3, W-B4, W-C2, W-C3, W-C4, W-C7) show as they were. Code traced at HEAD `05afd4b34`.

| # | Screen | Captures | Seen in Terminal dark | Seen at AX5 | Verdict |
|---|---|---|---|---|---|
| D1 | Starred | r01 | Path band the room #000000 62–110: "~/" and "starred" muted #8B9088 6.44:1, "home" accent #90C1AF 10.43:1, ⋯ accent 20 × 4.3 pt; rows on the paper #0F1A16 110–784 on a 44.0 pt pitch (125 · 169 · 214); **the ★ #5B93DE — the star token, blue — 5.66:1, 7.0 × 6.7 pt**; names SF Mono ≈15 in ink #D6DAD2 12.56:1 — her "Walk note" drawn **"walk note"** (W-C8, below); "book"/"note" 13 in the faint #6B7168 **3.55:1** (W-A9); the bar: hairline #1C332A at 784, the room #000000 785–874, "starred" semibold ink on the wash #1F382F (794–830) 8.90:1, the others muted 6.44:1. | The path line held at ≈17.3 ("Home" accent 5.31:1, "· Starred" muted 5.08:1); her names Iowan semibold ≈48 pt (the W of "Walk note" 37.3 pt tall against 13.3 at default — ×2.8) on an 85.7 pt pitch, **"the pocke…" cut** beside its "book" (W-A4); the ★ held at 11.7 × 14.3 pt (×1.3), #3D6B8E 5.69:1; "book"/"note" ≈17.6 in the faint 3.93:1 (W-A9); the bar 781.3–840 with every word whole at ≈22.7 (B cap 16.0 against 12.0); #FFFFFF 0–62 and 840–874 (W-A1). | **MATCHES** the ★ check (its own blue token, both), the rows, the grounds, the chrome hold. As recorded: W-A9 ("book"/"note"), W-A4 (AX5 cut — VM-218), W-A1 (AX5 edges), W-C8 (Terminal lowercases her note's name). |
| D2 | A book's contents | r02 | The system bar row: the dark-glass back circle (#182520, palette-tinted rim) and ONE capsule "details   read" — SF Mono, lowercased, in the system's label colour #F3F4F4 (not a token, as set 2 read it); #000000 0–62 above the paper #0F1A16 (W-A1 on a pushed screen, set 2's). "the pocket guide" mono ≈18 in ink 12.56:1 at 128; chapter labels 13 semibold muted 5.46:1; note rows mono 15 ink on a ≈44 pitch; the list runs on under the bar at 784 ("bookcase" on the chip). "+ New Note" / "+ New Chapter" are below the fold. | The book's name ≈48 pt on TWO lines ("the pocket" / "guide") — it grows and wraps ✓; chapter labels held ≈17.3 (13.3 against 10.0); note rows ≈47 pt one line each: **"blocks & typ…" cut** (W-A4), "start here", "getting around", "formatting" whole; the system toolbar's "Details · Read" held by the SYSTEM at ≈19.8 pt (D cap 14.0 against 12.0); the system's scroll-edge wash 62–133 (#FBFBFB → white); the bar 781.3–840 ("Bookcase"); #FFFFFF 840–874 (W-A1). | **MATCHES** (name, labels, rows on the paper, the bar). W-A4 (AX5 — VM-218), W-A1 as recorded. The two "+" doors NOT JUDGED (below the fold in both). |
| D3 | Book Details | r03 | A medium sheet (top ≈415) on the room #000000 over the dimmed page #080E0B — its edge **1.08:1**, found by the grabber (#48484A) alone; "book details" mono ink 14.82:1, "done" accent 10.43:1; the name mono ink; "17 notes · #pocket guide" muted 6.44:1; "finish" accent with its detail "a finished book reads ✓ and freezes its notes" (two lines, lowercased) in the faint **#6B7168 4.19:1** on black (W-A9); **"delete book…" in the dark ALARM #E08A7C 8.10:1** ✓, its detail two lines faint 4.19:1; hairlines the palette's dark line (#1C322A, #192722). | The sheet still opens at the MEDIUM detent (top 415) and its content does not scroll: **the title "Book De…" cut beside Done** (Iowan ≈52 pt — B-to-k 38.7 against 15.0 — on ONE line though the header allows two), **the book's name "the pocket gu…" cut**; meta 17.6 muted; Finish's detail two lines 17.6 faint; "Delete Book…" alarm #9B3B2F ≈23 whole; "Its notes stay in the library." one line; nothing under the rows is lost. | Terminal **MATCHES** (the dark alarm on Delete Book…; the detail lines are W-A9's). **DOES NOT MATCH at AX5:** the squeezed medium sheet cuts its own title and her book's name — **W-D1** (VM-218). The black sheet over a black-dimmed page (1.08:1) is the system sheet's, noted. |
| D4 | A book's Read page | r04 r04b | The voice's own dark room #000000; the cream page #171511 as a card from ≈124 (x 10–392); text #E3DCD0 13.38:1; title ≈25 (24.3 t→g); "I · WELCOME" in SF MONO #8D8371 4.88:1 (set 2's note); prose 17 on a 27.3 pitch at x 34. **r04b:** the flow continues; the page meta "note 1 of 17 · i" 13 mono in **#6B6456 — 3.11:1** on the dark page (batch 1's recorded pale page-meta ink; the light value is 1.86:1). The card stops FLAT at 840 and clips its last line (828–840 — 12 of a 16.7 pt line), the black room below (W-A1's clip; in dark it reads as the page ending mid-line). No bar ✓. | The room #FAF8F3 (the voice's own) ✓ and the cream page #FFFDF6; the book title ≈58 pt on two lines, both lines LEFT-aligned at x 55 inside a centred block (line 1 55–335.7, line 2 55.3–203.3 — a one-line title centres); "I · WELCOME" held at ≈18 (cap 13.0 against 9.7), #A49681 2.84:1 (recorded); the note title ≈55; prose ≈48 pt on a 76.3 pt pitch (×2.8); **r04b** the flow continues ("your shelf, / made of the / same notes, …"), passing under the back glass with the system's fade; the last line clipped at 840 and #FFFFFF 0–62 / 840–874 (W-A1). No bar. | **MATCHES** the ground rule (the voice's room, never the palette's), the cream page and the full-range serif. W-A1's clip in both (in dark the black room hides the band, not the cut line). The dark page meta at 3.11:1 and the light at 1.86 are batch 1's recorded "for her look". The AX5 title's left-aligned lines: noted, not filed (VM-122 / VM-218). |
| D5 | Create Book | r05 r05b | A full-height sheet on the room #000000. "new book" mono ink 14.82:1; "cancel" accent 10.43:1 in Done's place. The name field 151.7–196.3 = **44.6 pt**, the dark paper #0F1A16, the take-line edge #254137; its placeholder "name" the system's **#515858, 2.45:1** (W-A10). The kind as the segmented control 210–255 = **45 pt** on the system's track **#1C1C1F** (the fill over black): "book" chosen in ink on a paper thumb #0F1A16 12.56:1, **"journal book", "smart book" #8B9088 — 5.22:1, clear** (W-C4 does NOT show on a sheet over the black room). The explainer muted 6.44:1, lowercased. The calm button DISABLED: fill #050908, the word "create book" **#364942 — 2.09:1** (W-C5). **r05b:** the thumb on "smart book"; the explainer two lines; tag rows "#machiavelli" / "#pocket guide" mono 15 ink with their paths 13 in the faint #6B7168 4.19:1 (W-A9), on a 44 pt pitch; OR / AND not on screen (no tag picked). | "New / Book" wraps to TWO lines (≈48 pt) with "Cancel" ≈23 semibold centred beside it — the header's two lines working; the field 237.7–282.3 = **44.7 pt** ✓ (P-47-14), its placeholder "Name" ≈22.6 pt in #C5C5C7 1.72:1 (W-A10); the segmented control 296–341 = **45 pt**, its words WHOLE at ≈20 (B cap 14.7 against 11.0 — the chip role held), unchosen #6A6359 on #D7E1DE **4.44:1** (W-C4); the explainer 17.6 one line; the disabled button's word ≈23 at 1.65:1 (W-C5). **r05b:** the tag list — **"#machiav" / "elli": her tag's name broken MID-WORD** (rowTitle ≈48 beside its 17.6 path), and **the list's fixed 220 pt frame** shows a row and a half, the second row's path "pocket guide" clipped by the frame's foot — **W-D2**. | **MATCHES** (Cancel semibold, the field 44, the segments 45 and whole, the calm button's shape) in both; W-C4 clears in Terminal dark (5.22:1). As recorded: W-A10, W-C4 (AX5 4.44), W-C5 (dark 2.09:1), W-A9. **NEW at AX5:** W-D2 (VM-218). OR / AND not on screen. |
| D6 | The note's sheets | r06 r06b r06c r07 r07b r08 | All full height on the room #000000; headers mono ink + "done" accent. **Tags:** field 150–194.3 (44.3), the dark paper, edge #254137; its hint in the system's #515858 2.45:1 (W-A10) and cut EARLIER than in Study — "type a tag — ↩ applies it (“/”…" (W-C6); "#pocket guide" ink + "× remove" muted 6.44:1; **"apply a tag" 13 semibold in the faint, 4.19:1** (W-C3); "+ #machiavelli" accent. **Books:** "the pocket guide" ink + "diverge remove" muted 6.44:1; **"add to a book" faint 4.19:1, "editing here edits the note everywhere it appears." faint 4.19:1, two lines** (W-C3); "+ journal" / "+ the prince" accent. **More Info:** the sentence muted 6.44:1, "+ add a link" accent. **Blocks:** "select" accent beside "done"; the segmented control on #1C1C1F, "archived" / "leaving" 5.22:1 — clear; previews mono 13 in ink 14.82:1 KEEPING her capitals ("CHOOSING", "PEEK"), the fourth cut at its two lines ("…says wha…"); the ⑂ 5.3 × 7.0 pt #898E86 (W-A13). **Leaving:** header 13 semibold muted 6.44:1, the explainer three lines faint 4.19:1 (W-C3), "nothing from this note is on the clock." muted. **Lenses:** "› the note" accent; the empty line muted; **the hairline #323235 — the system separator over black, not the palette's dark line #1C332A** (W-C7). | Headers one line each (≈50 pt titles, Done ≈23; Blocks' "Select" fits beside Done). **Tags:** field 164.7–209.3 = 44.7 ✓; **its hint WHOLE — "type a tag — ↩ applies it (“/” nests: life/goals)" — at ≈16.5 pt** (t 11.0 pt tall against 11.3 at default): the system field shrinks its placeholder to fit, below the field's own AX5 size, so W-C6's cut does not show here; **"#pocket…" (her tag, ≈48) cut** beside "✕ remove" (W-A4); "Apply a tag" 17.6 semibold faint 3.37:1 (W-C3). **Books:** **"the po…" cut** beside "diverge remove" (W-A4); "Add to a book" 17.6 faint; "Editing here…" two lines faint. **More Info:** whole. **Blocks:** segments 45, words whole; **every preview cut at its two lines** (rowPreview ≈45 pt) — even the one-sentence block reads "Takes are for / trying; CHOOS…" (W-A4's class; the row is VM-149's); ⑂ held 7.3 × 9.3. **Leaving:** the explainer three lines 17.6 faint 3.37:1. **Lenses:** "› the note" ≈48 accent; the hairline #B4BCBB, 1 pt (W-C7). | **MATCHES** the headers, the fields' 44, the inline acts, the "+" rows. **DOES NOT MATCH as recorded:** W-C3 (dark 4.19:1 on black; AX5 3.37:1), W-C6 (Terminal: cut earlier; AX5: whole, shrunk), W-C7 (dark #323235), W-A10 (dark 2.45:1), W-A13, W-A4 at AX5. Nothing new. |
| D7 | Note Actions | r09 | A medium sheet on black over the dimmed note; "note" ink, "done" accent; "save a version" / "versions…" accent, details faint 4.19:1 (W-A9); **the doubled hairline at 646.7 and 660.3** (#1C2D26 / #16201C) above "settings" (W-B4); **"delete note…" #FF4245 — iOS's red, 6.12:1 — not the dark alarm #E08A7C** (W-B3); its detail two lines, faint, lowercased. | "Note" ≈52 one line beside Done ≈23 (the title's top ≈13 pt under the grabber); labels ≈23, details 17.6 faint; **the doubled hairline at the same 646 / 660** (W-B4); "Delete Note…" **#F23032 3.43:1** at ≈23 (W-B3), its detail two lines; nothing cut. Behind the sheet the masthead "swi…" (VM-148, W-A4). | **DOES NOT MATCH as recorded** — W-B3 and W-B4 in both combinations; nothing new. |
| D8 | Versions | r10 | The paper #0F1A16, #000000 0–62 above it (W-A1); "~/versions" muted 5.46:1; **the explainer four lines 13 in the faint #6B7168 3.55:1** (W-C3); the moment "nov 19, 2026 at 4:18 pm" mono ink; its meta muted 5.46:1 — **"4 blocks · “takes are for trying; choosing is deciding. the take with the ✓ ”": her capitals gone** (W-C8); the bar ("library"). | "Versions" ≈50 muted; the explainer four lines 17.6 faint 3.93:1 (W-C3); **the moment's title "Nov 19, 2026…" cut** at ≈48 (W-A4 — the date and time that tell one moment from another are the part lost); its meta two lines 17.6 muted 5.93:1, her capitals kept; the bar ("Library"); #FFFFFF edges (W-A1). | **MATCHES** the paper and the bar. As recorded: W-C3, W-C8 (Terminal), W-A4 (AX5 — VM-218), W-A1. |
| D9 | The three UIKit overlays | r11 r12 r13 | Overlay ground the paper #0F1A16 to 840, black 840–874 (W-A1); **the veil #414A45 over the prose from 326 pt — the ink at 25% LIGHTENS the dark note** (W-B5), the masthead undimmed. **Takes:** "takes · block 3 of 4" muted 5.46:1, "done" accent 8.84:1; cards #15261F, the chosen edge #6FBF94, the others #1B3127; "chosen" #6FBF94 7.19:1, "take 2" / "take 3" muted 4.85:1 on the card (≈13); her words mono ink 11.15:1 with her capitals; ✓ #6FBF94, ⋯ muted; "all takes to blocks", "branch this one ⧉", "blank ○" accent; "+ new take" muted, ≈13 (its k 9.7 pt tall — Starred's 13 pt "b" is 9.7). **Block History:** "block history" muted, "commits" 13 semibold muted, the explainer muted 5.46:1, "▾ take 1 of 3 · the take you're in" #6FBF94 8.10:1, the commit "The rain came in from the sea…" ink cut, "nov 19, 2026 at 4:19 pm · quiet" muted, "restore" accent, each count on its own line (VM-41). **Comments:** "comments" muted, the empty line at x 17 muted 5.46:1, the draft field 784–824 = 40 pt (fill #15261F, edge #1C332A), "add a comment…" muted 4.85:1, "add" accent. No light line left on black. | VM-152's fixed frames, described: **Takes** — the overlay from ≈480 pt; its header "Takes · block 3…" (≈50 pt) drawn UNDER the first card's top edge (524) with Done ≈23 above it; the chosen card's words ≈48 pt clipped by the card after three lines, the other two cards off the frame; the footer acts ≈20, "+ New take" ≈17 (N 12.0). **Block History** — "Block History" (≈50) printed OVER "Commits" and the explainer's first line; "take 2 of 3" printed over the commit's date line; the commit row "The rain c…" ≈48. **Comments** — "Comments" (≈50) printed over "No comments on this block yet." (≈17, N 12.0); the draft field still 40 pt (784–824) with its placeholder (≈48 pt) cut by the field's own edge ("Add a comme…" half drawn). The veil #C9C8C6 from 359.7 pt (W-B5). | Terminal dark **MATCHES** (text ≥ 13, the dark edges, no light line on black); W-B5 (the veil lightens). AX5: **VM-152's recorded "text can outgrow a frame above xxxLarge"** — the overlaps and clipping are described, not counted (their header type is this run's `screenTitle`, full range, in frames this run did not set). |
| D10 | Trash | r14 r14b | The paper, #000000 0–62 (W-A1). The header line: "~/trash" muted 5.46:1, "newest first" accent 8.84:1, **"empty trash…" the dark alarm #E08A7C 6.86:1**, whole (ends 380.7); **the promise, lowercased, two lines, 13 in the faint #6B7168 3.55:1** (W-B1); the kind chips in ONE sideways row — "all" ink on the wash #1F382F 8.90:1, the others edged #254137 with muted words 5.46:1, capsules 32 (222.7–254), the row clipped at ≈392 ("snippe"); rows: her titles mono ink **WITH her capitals** ("A note for the message line", "A note to put in the trash" — this screen does not lowercase her names, Starred does: W-C8), "note · 30 days left" muted 5.46:1, "put back" accent, "delete now" alarm 6.86:1. **r14b:** "notes" on the wash in ink 8.90:1, "all" edged and muted. | "Trash" ≈50 muted; "newest first" ≈20 accent and **"Empty / Trash…" (alarm 6.86:1) wrapped to two lines** (166–211) beside it; the promise two lines 17.6 faint 3.93:1 (W-B1); the chips: **the capsule still 32.7** (276.3–309) around ≈20 pt words (N cap 14.0), "All · Notes · Books · Blocks · Snipp", the row clipped at 393; rows: her titles ≈48 on two lines, whole ✓; meta 17.6 muted 5.93:1; "Put back" / "Delete Now" ≈20; **r14b** "Notes" on the wash in ink 11.31:1, "All" edged; the bar; W-A1 edges. | **MATCHES** P-47-11 (chips: chosen on the wash in ink, the others edged and muted, 32 pt, one sideways row — at AX5 too) and the alarm in both appearances. W-B1 shows (3.55:1 dark, 3.93:1 AX5). The AX5 door wrapped across two lines: noted (VM-100 / VM-218), not filed. |
| D11 | Archived | r15 | The paper; "~/archived" muted 5.46:1; **"kept — no clock" faint 3.55:1** (W-B1's class); the filter row "all" ink / **"notes" faint 3.55:1** (W-A9), starting at x 29 (set 2's 8 pt indent); "nothing archived." muted; the bar ("library"). | "Archived" ≈50 muted; "kept — no clock" 17.6 faint 3.93:1; the filter row "All" ink / "Notes" faint 3.93:1 at 17.6, from x 28.7, whole; "Nothing archived." muted 5.93:1; the bar; W-A1 edges. | **MATCHES** the bar and the paper; W-B1 and W-A9 as recorded. |
| D12 | Settings | r16 | The sheet's room #000000 with rows on the paper #0F1A16; "~/settings" muted 6.44:1, "done" accent; section names 13 semibold muted, lowercased; "Sync off (dev store)" keeps its capital (part A's note); Voice: "terminal" ink on a paper thumb, **"study" #8B9088 on the system track #273030 — 4.15:1**; Appearance "light" / "dark" **4.15:1** (W-C4 — on Settings, whose controls sit on the paper rows); the off switch: track #273030, the system's white knob; menu rows 44. | "Settings" ≈50 one line beside Done; section names 17.6; menu rows still **44 pt** with ≈23 labels (Protection… 255–299, Manage Tags 611–655, Acknowledgments 708.3–752.3); the two choices 45 pt (Appearance 502.3–547.3), "Terminal · Study" and "Follow system · Light · Dark" whole; unchosen on #EEEEEF 5.11:1; the list scrolls; nothing cut. | **MATCHES** (part A's k1 read holds at AX5). W-C4 confirmed on this capture in Terminal dark (4.15:1). |
| D13 | Protection | r17 r17b | The whole page on the room #000000 (0–874); "~/protection" muted 6.44:1; group names lowercased, muted; doors lowercased accent 10.43:1 ("check my passphrase or / twelve words…" wrapped, not cut); the explainer sentences 13 muted 6.44:1 KEEPING their capitals; "You're in Standard." and "This library doesn't sync." mono ink 14.82:1; "Sign in to turn on sync." muted; hairlines #1C332A. **r17b = r17** (diff ≤ 1 level at the back glass): the page fits — nothing to scroll in Terminal at the default size. | The page SCROLLS — **r17b shows its lower sections** (the evidence set 2 lacked): "Protection" ≈50 muted; group names 17.6; doors ≈23 accent; the explainers held at 17.6 muted 5.08:1; **but "You're in Standard." ≈47 pt on two lines and "This library doesn't sync." ≈43 pt on two lines** (×2.75 / ×2.9 against default) beside doors at ≈23 and "Sign in to turn on sync." at 17.6 directly under them — **W-D3**; #FFFFFF 0–62 and 840–874 round the room (W-A1); no bar. | Terminal dark **MATCHES** (inks, the dark line, no bar). AX5: **W-D3 — a question** (P-47-8's role map as built: the app's state lines take her words' full range). W-A1 as recorded. |

## 4e. The re-capture, set 1 — the core in four combinations, Settings' flows, the border flip

Read 2026-11-19 by the re-capture's first reader (fresh, briefed from this file and the run record's §5 and §6). **All 80
captures of the set are present** in `recapture/`: `test10_core` in `seaglass-study-light-default--` (16: k0–k3, c1, c2, c3,
c4, c4-results, c5, c6, c7, c8-caret-1/-2/-3, c9), `seaglass-terminal-dark-default--` (16), `seaglass-study-dark-default--`
(16) and `seaglass-terminal-light-ax5--` (10: k0–k3, c1–c5 with c4-results); `test50_settings` in
`seaglass-study-light-default--` (16, s01 … s14); `test30_flip` in `seaglass-study-light-default--` (6, f1–f6). The walk log
has a SHOT line for each and no MISSING, NOT-HITTABLE or NOT CAPTURED in this set (s14's "NOT REACHABLE … the sync row's
doored states" line, as in part B). **The tree:** the walk app rebuilt on the merged tree's app code `4866c7fb8` (record §4
row W.9) — the walk's fixes and main's merge both in. Every capture looked at full size; pixel-identical pairs (diffed)
looked at once — k2 = k3 in all four core runs; the three c8 frames identical but for the caret's fade (Study light and
dark) or identical (Terminal dark). Every capture diffed against its pre-fix twin in `final/` (for c8, the single
`c8-caret`) and every band of difference explained in the rows or listed in §6. Grounds and inks by pixel (column and row
runs, an ink-core sampler, WCAG arithmetic — a scratch script with §1's 3x rule, not committed); sizes from pixels ÷ 3.

| # | Finding or evidence | Captures | Seen now (measured) | Before (the twin) | Verdict |
|---|---|---|---|---|---|
| E1 | W-A1 — the roots in light | `seaglass-study-light-default--` c1 c2 c3 c4 c4-results k0 s01 s02 s03c s05; `seaglass-terminal-light-ax5--` c1 c2 c3 c4 c4-results k0 | Columns at x 0.2, 3, 395 and 401.8: the room #E5F0EC in ONE run from 0 to the page's paper (0–110 on the Bookcase, 0–206 on the Library); under the bar one run from its hairline (784 / AX5 781.3) to 874, (200, 860) #E5F0EC — the bar's room reaches the bottom edge; the status bar's glyphs sit on the room | #FFFFFF 0–62 and 840–874 | **FIX CONFIRMED** |
| E2 | W-A1 — the roots in dark | `seaglass-study-dark-default--` c1 c3 c4-results k0, `seaglass-terminal-dark-default--` the same, `seaglass-study-light-default--s07` | #000000 0–874 at both edges (the dark room); SD c1, SD k0 and s07 pixel-identical to their twins | the same (#000000 matched by coincidence) | **AS BEFORE** (matches) |
| E3 | W-A1 — a note | `seaglass-study-light-default--` c5 c6 c7 c8 c9 s14 f1 f3 f5; `seaglass-terminal-light-ax5--c5`; SD and TD c5–c9; `seaglass-study-light-default--` s08 s09 f2 f4 | Study light: #FFFFFF 0–874 = Study's paper (no change, white on white). Terminal light AX5: the paper #FBFBF7 0–874 at both edges (a 1.03:1 step under the diff's threshold — measured, not diffed). Dark (SD, TD, s08, s09, f2, f4): the paper #0F1A16 0–874 at x 3 and 395; under the takes overlay (s09, f2) and the comments overlay (f4) the paper runs to 874 too. The dark note's foot 840–874 is empty paper; the last drawn line (TD c5 820.7–835.7) whole, as in the twin | Study light the same; TL AX5 #FFFFFF 0–62 / 840–874 round #FBFBF7; dark #000000 bands 0–62 and 840–874 round the paper | **FIX CONFIRMED** |
| E4 | W-A1 — sheets and Protection | k1–k3 (all four core runs), `seaglass-study-light-default--` s03 s04 s06 s10 s11 s12 s13; s03b | Settings: the strip above the sheet is the dimmed ROOM #B7C0BD in light (the room under the system's dim), black in dark; the sheet's own room runs 838–874 (#E5F0EC / #000000; Terminal light AX5 k1 850–874 the rows' paper #FBFBF7) as before. Note Actions (s12): #CCCCCC above = the paper dimmed; the floating sheet's foot corners show the dimmed note (#C6C6C6 / #C0C0C0) as before. Protection (s03b): #E5F0EC 0–874 at x 0.2, 3, 395, 401.8 — the room to both edges | Settings: #CCCCCC (white dimmed) 0–62; Protection #FFFFFF 0–62 / 840–874 | **FIX CONFIRMED** |
| E5 | W-A1 — with the keyboard up | c2 c4 ×4 combinations; c8-caret-1/-2/-3 and c9 ×3 | Roots: from the bar's hairline (483 / AX5 480.3) the room runs unbroken to the keyboard's top ≈ 560 at x 1 — the corners beside the keyboard's rounded top are the room (#E5F0EC; dark #000000); the keyboard's own glass now tints from it (key area #D9E0E1, was #E2E4E8). A note: (110, 500) behind the keyboard bar is #E7F0F7 Study light / #14202B both darks — the callout block's wash, i.e. the paper AND her prose run behind the bar's three glass cells and on under the keyboard's top edge (see W-E3); the keyboard's glass over the dark paper #171B1A | the bare window: #FFFFFF 539–559 beside the keyboard (light roots); behind the keyboard bar 487–553 #FFFFFF / #000000, the prose stopping at ≈ 487 | **FIX CONFIRMED** (the ground reaches the keyboard); **NEWLY CAUGHT** — her words behind the bar's cells (W-E3) |
| E6 | W-A1 — anything drawn where it should not be | x 0.2 and 401.8 columns of c1, c3 (Study light, Terminal dark), TL AX5 c1, SD c5, s03b; every capture looked at | Only each page's own grounds and hairline at the side edges — no neighbour page at an edge, no control under the status bar (the back circle sits at 60–103 pt, as before) | — | **MATCHES** (the sideways clip holds) |
| E7 | W-A3 — Terminal's marker column | `seaglass-terminal-light-ax5--c1`, `--k0`; `seaglass-terminal-dark-default--c1`, `--c2`, `--k0`; `seaglass-study-light-default--s05` (flipped to Terminal) | AX5: the names' first ink at x 52.3–53.3 pt — **≈ 31 pt further left**; they read **"jou…", "the…", "the…"** — still cut: the freed width went to the trailing meta, now "17 notes · #p…" and "28 notes · #m…"; the box hint "new note▋". Default: the names' first ink at 45.7 / 45.3 pt — **2.3 pt left**, whole ("journal", "the pocket guide", "the prince"); "+ new book" at 20 as before | AX5: names from 83.3–84.3, "jo…", "the…", "the…"; default 48.0 / 47.7 | **FIX CONFIRMED** (the column) — the AX5 names still cut is **W-A4's** (VM-218), as the record predicted ("This alone leaves Terminal AX5 names still cut by the trailing meta") |
| E8 | W-A9 — the filter row's unchosen words | c3, c4, c4-results ×4 | "Books · Notes · Bookless · Scraps": Study light #6A6359 **5.08:1** on the room; Study dark #948C7C **6.30:1** on black; Terminal dark #8B9088 **6.44:1**; Terminal light AX5 #61655F **5.09:1**; "All" in ink (13.21 / 16.41 / 14.82 / 12.89:1); every word at its twin's x | #8B7F6A 3.37, #766F5F 4.21, #6B7168 4.19, #7E8376 3.34:1 | **FIX CONFIRMED** (all ≥ 4.5:1) |
| E9 | W-A9 — the masthead's chips (P-47-29, for her look) | c5 ×4 (and every note capture: c6–c9, s08, s09, s12 behind, s14, f1–f6) | Study light on the paper: "no date" #6A6359 **5.93:1**, "#pocket guide" #29241C ink **15.40:1**, "more info" #6A6359, "blocks" #6A6359, "lens" #6A6359; the membership line "in the pocket guide" #6A6359. Study dark: empty #948C7C **5.34:1**, set #E8E3D8 13.91:1. Terminal dark: empty #8B9088 **5.46:1**, set #D6DAD2 12.56:1 ("lens" on its own second row, 282.3–294, as before). Terminal light AX5: empty #61655F **5.73:1**, set #23272B 14.50:1. **What she will see:** in the seeded lesson exactly ONE chip is set — the tags chip, "#pocket guide" — and it is the only chip word in ink; the date (none), more info (no links) and lens (none active) read empty in the muted; the blocks chip and the one-book membership line stay muted by option (a)'s design — so four of the five chip words and the membership line read the same muted, and only the tags chip stands apart | empty chips in the faint (#8B7F6A 3.93, #766F5F 3.57, #6B7168 3.55, #7E8376 3.75:1); set chips muted | **FIX CONFIRMED** |
| E10 | The merge's face in this set — the date chip (VM-84) and the masthead | c5 ×4 | "no date" (the lesson has no entry date) at its twin's place (x 21.0–72.0, y 239–250.7; Terminal 21.3–83.7); only its ink moved (E9). The masthead otherwise: the diff against the twin is confined to the chip row (239–253.3; Terminal dark also 282.7–294, the wrapped "lens"; TL AX5 its two chip rows) — title, the four tools and the membership line pixel-identical | "no date", the faint | **AS BEFORE** (nothing visible from the merge: an undated note cannot show the observed-date road) |
| E11 | W-A10 — the search placeholder | c3 ×4 (also s02, s03c) | "Search notes, books…" / Terminal "search notes, books…" (the same words): Study light #8B7F6A **3.93:1** on the field's #FFFFFF; Study dark #766F5F **3.57:1** on #0F1A16; Terminal dark #6B7168 **3.55:1**; Terminal light AX5 #7E8376 **3.75:1** on #FBFBF7 | #C5C5C7 1.72, #515858 2.45, #515858 2.45, #C2C2C1 1.72:1 | **FIX CONFIRMED** (all ≥ 3:1) |
| E12 | W-B1 / W-C3 and W-A9's sweep — the faint on words, where this set shows them | `seaglass-study-light-default--` s01 s03b s12, c1 | No sentence in the faint anywhere in the 80: s12's three detail lines (Save a Version's, Versions…'s and Delete Note…'s two-line sentence) #6A6359 **5.08:1** on the sheet's room; s01 Starred's "book" / "book" / "note" #6A6359 **5.93:1**; s03b's explainers #6A6359 5.08:1 (muted before too). The faint is left only where the sheet allows it: the box's hint (a placeholder, #8B7F6A 3.93:1 / dark #766F5F) and its dashed edge, and the search's placeholder | s12's details and s01's words #8B7F6A (3.37 / 3.93:1) | **FIX CONFIRMED** where shown (the Trash's and the Archive's promises and W-C3's sheets are set 2's) |
| E13 | W-B3 — "Delete Note…" | `seaglass-study-light-default--s12` | #9B3B2F, the alarm — **5.88:1** on the sheet's room #E5F0EC | #F23032 (iOS's red) 3.43:1 | **FIX CONFIRMED** |
| E14 | W-B4 — the hairline above "Settings" | `seaglass-study-light-default--s12` | **ONE** hairline between Versions… and Settings, at 651.0–651.7 (core #CFE1DA, the line under antialias; the next divider #CBE2D9 at 720.7). Gaps: Versions…' detail foot 624.3 → hairline 26.7 pt; hairline → "Settings" ink 680.0, 28.3 pt; "Settings" foot 695.7 → the next hairline 25.0; → "Delete Note…" 742.0, 21.3. The header "Note" / Done and the first two rows sit **4.6 pt lower** (title ink from 454.3, was 449.7; the sheet's top 415 and the grabber unchanged) and Settings / Delete **9.3 pt higher** — explained: the twin's stack overflowed the medium detent by ≈ 9.2 pt (a `VStack` with a trailing `Spacer(minLength: 0)`, centred when too tall, the header pushed 4.6 pt into its top padding); one divider and one 14 pt gap fewer and it fits with ≈ 4.4 pt to spare, the header back at its 20 pt padding | two hairlines 13.6 pt apart (646.7, 660.3); title at 449.7 | **FIX CONFIRMED** (and the header at its padding again) |
| E15 | The evidence gap: c6, the take's peek | `seaglass-{study-light,study-dark,terminal-dark}-default--c6`; `seaglass-study-light-default--f5`, `--f6` | **Caught in all three c6.** The peeked take ("The rain came in from the sea, and the sea did not explain itself.") on the take tint: light #E8F2EE (§2's) over x 16.3–351.3, y 530.7–603.0 — 1.14:1 on the paper — with a 2.3 pt left edge in the take line #B7D7CB (x 14–16.3, the sticky marker); dark #0D1713 (§2's) on the paper #0F1A16 — **1.03:1, darker than the paper**, the edge #254137 (1.60:1) carrying it (W-E2). **The pill "‹ take 2/3 › ✓":** a capsule x 20.3–159.0 (Terminal 20.0–174.3) by **27.7 pt** (607.3–635.0; Terminal 643.3–671.0); its ground the card — #FFFFFF light, #15261F dark; its edge the take line, 0.7–1 pt (#B7D7CB / #254137); its words ≈ 13 pt (the k's ascender 10.0 pt, as a 13 pt "Books") in the muted — #6A6359 5.93:1, #948C7C 4.74:1, #8B9088 4.85:1 on the card; the ✓ in the positive (#5A7D46 4.71:1, #93B57E 6.89:1, #6FBF94 7.19:1). It sits over the next block's first line and hides "A flip is a PEEK: y" (W-E1) | every c6 pixel-identical to its c5 — no peek | **NEWLY CAUGHT** |
| E16 | The evidence gap: c8, the caret | `seaglass-{study-light,study-dark,terminal-dark}-default--c8-caret-1/-2/-3` | **The caret is in all nine frames.** Study light: after "its", x 147.7–149.3 (1.7 pt) × y 344–370 (26 pt), **#3B6A59 — the accent**, 6.19:1 on the paper, in frames 1–2, mid-fade (#9DB4AC) in 3. Study dark: **#90C1AF — the dark accent**, 8.84:1 on #0F1A16, in 1–2, #709789 in 3. Terminal dark: #90C1AF in all three, 1.7 × 21 pt (382.3–403.3) after "carries " | no caret in any c8 | **NEWLY CAUGHT** — the editor's caret is the accent on the paper (set 1 saw the same under teal & rust); the fields' caret is still the system blue (W-A7, E19) |
| E17 | VM-54's flip — f1–f6 | `seaglass-study-light-default--f1` … `--f6` | f1 (light) as before: the chosen edge #5A7D46, the others #CBE2D9. f2 (dark): chosen #93B57E, the others #1C332A, card #15261F, the paper to 874. f3 → f4: the draft field 784–824 pt, edge #CBE2D9 → #1C332A, fill → #15261F; the overlay identical to its twin, but the note behind it is NOT scrolled (W-E4). f5: the pill up (E15's light values). **f6 is again a cross-fade frame** — every ground 90 % of the way to dark (the paper #27302D = 0.1 × #FFFFFF + 0.9 × #0F1A16) — and in it the pill's edge is **#335046 = exactly 0.1 × #B7D7CB + 0.9 × #254137**, its ground #2C3B35 = 0.1 × #FFFFFF + 0.9 × #15261F, the take tint #222C28 the same blend: an edge left in its light colour would read #B7D7CB through the fade. The cards' and the draft's edges as before | f5 caught no pill; f6 a ≈ 88 % fade frame with no pill | **NEWLY CAUGHT** — no light edge left on the pill (by the fade's arithmetic; no settled dark frame exists); the cards and the draft **AS BEFORE** (VM-54 holds) |
| E18 | Every other difference from the twins (the regression check) | all 80 | Explained, band by band: the W-A1 strips and corners; the W-A9 / W-A10 inks; W-A3's 2.3 pt; s12's rows (E14); the new evidence states (c6, c8, f5, f6); the keyboard's glass tinting from what is now behind it (c2, c4, c8, c9); **the store's content** — the re-seed's "Walk note" first in the Library (c3 ×4, s02, s03c), and in s02 / s03c two "A note for the message line" rows (this time the bar's roads ran BEFORE Settings' flows, and both runs' m3 Undo put their note back); **blink phases** — the box's caret (SD / TD c2), the search's caret (SD c4), Terminal's ▋ in the box hint (TD c1 / k0, TL AX5 c1 / k0) | — | No regression **but one unexplained difference: W-E4** (f3–f5, the note's scroll) |
| E19 | The known questions for her | as named | **W-A2** as before — "Home · Bookcase  ·  3 books" whole (Study), "~/home/bookcase  ·…" (Terminal), "~/home/book…" and "~/home/libr…" (Terminal AX5); the path band pixel-identical to the twins. **W-A5** as before — the 🗑 colour emoji on every root. **W-A6** as before — TL AX5 c2: the box fills 110 → ≈ 425 pt, no book row. **W-A7** as before — the box's caret #0088FF (light) / #0473C4 (dark), the search's #7FC3FF / #0B3850 mid-blink, while the editor's caret is now SEEN to be the accent (E16). **W-A8** as before — TL AX5 k1–k3: "~/" over "settings", pixel-identical to the twins below 62 pt. **W-C4** as before — the dark Settings captures are pixel-identical to their twins (4.06 / 4.15:1 on the system's track); Study light's track #EEEEEF. Also as before: W-A4 (AX5 cuts), W-A11 ("bookless" shrunk at TL AX5 — 10.0 pt tall against its siblings' 13.3), W-A12 (no dates), W-A13 (the ⑂ 7 pt) | — | **AS BEFORE** |

## 5. The walker's result blocks

The driver's build: GREEN — `App/Variorum/DerivedData/vm47-walk`, cold, 14:11–14:19 on 2026-11-19 (`** TEST BUILD SUCCEEDED
**`; the bundle carries `VM47FinalWalk/test01_seed · test10_core · test20_rest · test30_flip · test40_shell ·
test50_settings`; the temporary copy removed, the tree clean).

PENDING — part A's and part B's: captures written against expected (99 / 182), every MISSING / NOT CAPTURED with its step,
the device's state, instances, new crash reports (the baseline before the walk: the newest is
`VariorumMobile-2026-11-19-120544.ips`).

## 6. Findings

### Part A, the eight combinations

Read 2026-11-19 by a fresh reader: every one of the 99 captures looked at full size (the k2/k3 pairs pixel-diffed — they
differ only by the scroll indicator, or not at all — and the c6 captures found pixel-identical to their c5), sizes from
pixels, every ground and ink by `walk_pixel` / column runs. Not one message line in any part A capture. In dark no light
line or light ground is left on black (the hairline #1C332A, the field edge #254137, the strips #000000).

| Combination | Verdict in one line |
|---|---|
| `seaglass-study-light-default` (17, with the seed) | W-A1 (white strips under the bar and above the path line), W-A5, W-A7, W-A9, W-A10, W-A12, W-A13; c6 and c8 not judged; the seed's s0 not judged. The path line whole. |
| `seaglass-study-dark-default` (14) | Roots' edges match (black is the room); W-A1 in the note (black bands above and below the paper, and under the keyboard bar), W-A5, W-A7, W-A9, W-A10, W-A12, W-A13; c6 and c8 not judged. |
| `seaglass-terminal-light-default` (14) | W-A1, W-A2 (the count cut: "~/home/bookcase  ·…"), W-A5, W-A7, W-A9, W-A10, W-A12, W-A13; c6 and c8 not judged. |
| `seaglass-terminal-dark-default` (14) | W-A1 (note), W-A2, W-A5, W-A7, W-A9, W-A10, W-A12, W-A13; c6 and c8 not judged. |
| `seaglass-study-light-ax5` (10) | W-A1, W-A2 (the count cut: "Home · Bookcase..."), W-A4, W-A5, W-A6, W-A7, W-A9, W-A10, W-A12, W-A13. |
| `seaglass-study-dark-ax5` (10) | W-A1 (note), W-A2, W-A4, W-A5, W-A6, W-A7, W-A9, W-A10, W-A12, W-A13. |
| `seaglass-terminal-light-ax5` (10) | The most findings: W-A1, W-A2 ("~/home/book…", "~/home/libr…"), W-A3, W-A4, W-A5, W-A6, W-A7, W-A8, W-A9, W-A10, W-A11, W-A12, W-A13. |
| `seaglass-terminal-dark-ax5` (10) | As Terminal light AX5, with W-A1 in the note only. |

### Part A's findings

**W-A1 — The grounds stop at the safe area: no screen's room or paper reaches the status bar or the home indicator.**
THIS RUN'S DEFECT.
- Captures: every root (`*--c1-bookcase-rest`, `*--c2-…`, `*--c3-library-rows`, `*--c4-…`, `*--k0-…`) and every note
  (`*--c5-note-write`, `*--c6…c9-*`, `s1`), all eight combinations; s2.
- Seen: column runs at x = 3 and 395 pt. Light roots, both voices: 0–62 pt is #FFFFFF above the path line's room
  (#E5F0EC from 62), and 840–874 pt is #FFFFFF under the bar's room (785–840) — the bar's room does not run down to the
  home indicator, and in Terminal #FFFFFF is neither the room nor the voice's paper #FBFBF7. Dark roots: both strips
  #000000 = the dark room, so they match by coincidence. Notes: the paper runs 62–840 only — Terminal light #FFFFFF
  strips around the paper #FBFBF7; DARK **#000000 bands (62 pt above, 34 pt below) around the paper #0F1A16**, and the
  last prose line is cut at 840 (`seaglass-terminal-dark-default--c5-note-write`); with the keyboard up the band behind
  the keyboard bar (≈487–553 pt) is #000000 in dark / #FFFFFF in light (`*--c8-caret`, `*--c9-selection`); on c2 the
  corners where the keyboard's rounded top meets the bar (539–548) are the same bare window.
- The standard: §2 "the room down to the home indicator" and the sheet §E tab bar "Bar 49 + the 34 pt home-indicator
  inset, both painted in the room" (P-47-21); R-47-1's grounds (the sheet's phone frames are the room edge to edge);
  P-47-16/17 (the note on the paper). `MobileTabBar.swift:124` itself says "the room, down past the home indicator".
- Where it comes from: `App/Variorum/VariorumMobile/Features/Shell/MobileShellView.swift` — the band is
  `GeometryReader { proxy in ZStack { … } .frame(width: proxy.size.width, height: proxy.size.height) … .clipped() … }`
  (lines 233, 287, **291**). The GeometryReader's frame is the safe area (and shrinks above the keyboard), and
  `.clipped()` cuts every page's own `ignoresSafeArea()` ground at that frame: the bar's
  `tokens.room.ignoresSafeArea(.container, edges: .bottom)` (`MobileTabBar.swift:124`), the roots'
  `tokens.room.ignoresSafeArea()` (`MobileShelfView.swift:135`, `MobileLibraryView.swift:113`) and the note's
  `tokens.surface.ignoresSafeArea()` (`MobileWriteView.swift:188`). What shows outside the clip is the window's own
  system background (white / black). The clip predates this run (batch 10, 2026-08-31) but only became visible when this
  run put the palette's room and the hued dark paper on the phone.
- Narrowest fix proposed (not made): bound the band's clip horizontally only — replace `.clipped()` with
  `.mask(Rectangle().ignoresSafeArea(edges: .vertical))` (or a clip shape whose path extends past the top and bottom
  edges), so the neighbours one width away stay hidden while each page's ground reaches the status bar, the home
  indicator and the keyboard. Painting the room behind the band instead would fix the roots but put sea-glass bands
  around her paper in a note — not that. Evidence after: re-capture c1, c3, c5 and c8 in light and dark and read
  (3, 30), (200, 860) and, with the keyboard up, (110, 500). If the keyboard-bar band stays bare after the fix, the bar's
  own ground is the rest (VM-137 owns the bar).
- FIXED — `67525b499` (the band's clip is sideways only, `MobileBandClip`); pin `MobileScreenEdgeGroundsTests`; re-capture:
  c1, c2, c3, c5, c8 in all eight part A combinations (read (3, 30), (200, 860) and, keyboard up, (110, 500)), and part B's
  b1, b4, b5, b8 and s03b in both its combinations (a pushed list's, Read's and Protection's grounds to the edges).

**W-A2 — The Bookcase path line, as built under P-47-27 (a): what gives way, measured.** A QUESTION FOR HER (already
hers: P-47-27, R-47-3).
- Captures: `*--c1-bookcase-rest` ×8 (and `*--c3-library-rows` at Terminal AX5).
- Seen: Study default "Home · Bookcase  ·  3 books" whole (13.2 pt), ending at 191.3 pt against the 🗑's 44 pt frame
  at ≈212.8 — ≈5.5 pt of slack beyond the 16 pt spacer, so a two-digit count (≈7–8 pt more at 13 pt) would cut the
  tail; this store holds 3 books, so the two-digit case was NOT exercised. Study AX5 (17.6 pt) "Home · Bookcase..." —
  the whole count gone. Terminal default "~/home/bookcase  ·…" — the count gone, a lone "·" left before the ellipsis.
  Terminal AX5 "~/home/book…" — the page word itself cut; the Library's line at Terminal AX5 likewise "~/home/libr…".
  No "Shelf" anywhere (R-47-3 holds). Every target stays on one 48 pt line.
- The standard: P-47-27 (a) as built — tail truncation, the count first and the wing's name last; her call which part
  gives way. Nothing to fix before she rules.

**W-A3 — Terminal's invisible marker column grows with her words and eats the book names at AX5.** THIS RUN'S DEFECT.
- Captures: `seaglass-terminal-light-ax5--c1-bookcase-rest`, `seaglass-terminal-dark-ax5--c1-bookcase-rest` and the two
  Terminal AX5 `k0` frames; at default `seaglass-terminal-*-default--c1-bookcase-rest`.
- Seen: Terminal book names start at 47.5 pt at default (Study's at 20) and at **83 pt at AX5**, leaving "jo…", "the…",
  "the…" for "journal", "the pocket guide", "the prince"; the reserved column is ≈18 pt at default and ≈55 pt at AX5.
- The standard: the role map (record §6, batch 1) puts markers (the ★, the ✓, the pick mark, ⑂) on `meta`, which holds
  at xxxLarge; a column reserved for a marker that marks nothing should not grow past the chrome's hold. §2: chrome holds
  at xxxLarge; her words keep growing — the marker is not her words.
- Where it comes from: `App/Variorum/VariorumMobile/Features/Shell/MobileShelfView.swift:269–274` — the Terminal
  `tokens.selectionMarker` ("› ") drawn at `.phoneType(.rowTitle, tokens)` with `.opacity(0)` (batch 1, `6b02c806c`,
  moved it to `rowTitle`).
- Narrowest fix proposed: hold the reserved marker at the chrome's cap — `.dynamicTypeSize(...DynamicTypeSize.xxxLarge)`
  on that one `Text` (the default layout byte-for-byte unchanged) or give it the `meta` role. This alone leaves Terminal
  AX5 names still cut by the trailing meta (W-A4).
- FIXED — `d974162f4` (the column takes `meta`, the role map's marker role; at the default size it narrows ≈ 2 pt); pin
  `MobileShelfMarkerColumnTests`; re-capture: `seaglass-terminal-{light,dark}-ax5--c1-bookcase-rest`, the two Terminal AX5
  `k0` frames, and `seaglass-terminal-{light,dark}-default--c1-bookcase-rest` (names start ≈ 45 pt, not 47.5).
- UPDATED (the walk's fixes, batch 2, piece 1 — `c72e65201`): the fixed tree's red (51.3 → 53.3 pt) was the PIN, not the column: the name is her words (full range) and its first glyph's side bearing (SF Mono Semibold "l", 0.089 em) grows ≈ 2.0 pt between xxxLarge and AX5 with the column level; the pin now compares the name's layout origin (`MobileShelfMarkerColumnTests`, red on old by ≈ 28 pt); no code changed, so the re-capture list above stands.

**W-A4 — At AX5 one-line rows cut her words: book names, Library titles and search hits.** ANOTHER TICKET'S — VM-218
("Every screen works with VoiceOver and at the largest text size"); the Library row's anatomy is VM-89's.
- Captures: `seaglass-*-ax5--c1-bookcase-rest` (Study "the p…" twice — the two books read the same; Terminal "jo…",
  "the…", "the…"), `seaglass-*-ax5--c3-library-rows` ("What's true…", "the voice sw…", "comments & c…"),
  `seaglass-*-ax5--c4-library-search*` ("swipe & c…", "swipe & ch…"), and the AX5 note titles "swi…" / "swip…"
  (`*-ax5--c5-note-write`, the masthead's layout — VM-148, recorded).
- Seen: names and titles keep growing (her words' class, as the sheet says) inside `lineLimit(1)` rows whose meta sits
  on the same line (the sheet's book row draws the meta UNDER the name, row 64).
- Not this run's to fix: the rows' anatomy at the accessibility sizes.

**W-A5 — The trash door is a colour emoji.** A QUESTION FOR HER.
- Captures: every root's path line (`*--c1-…`, `*--c3-…`, `*--c4-…`, `*--k0-…`) ×8.
- Seen: 🗑 is Apple's colour emoji U+1F5D1 (`MobileRecoveryDoors.trashGlyph`), its own grey-blue metal, 22.7 pt tall at
  default and 28.7 at AX5, beside the accent "+ New Note" and ⋯; `PhoneIconButtonStyle(tone: .muted)` cannot tint it.
- The standard: the sheet §B icon button "22 pt glyph in ink"; P-47-9 (a) built "🗑 an icon button"; AppSpec §12 keeps
  colour in the token layer. Options for her: (a) keep the emoji; (b) a monochrome glyph (an SF Symbol trash) taking the
  muted tone or ink, its spoken label unchanged.

**W-A6 — With the box focused at AX5, no book is left on screen.** A QUESTION FOR HER.
- Captures: `seaglass-*-ax5--c2-bookcase-box-focused` ×4.
- Seen: the box fills the region from the path line (110 pt) to ≈433 pt; not one book row, not "+ New Book", is visible
  (at default the three rows and "+ New Book" stay).
- The standard: §3's check ("the books region yielding but visible"); R27 (the writing floor outranks the books) as
  built by W-024 — the six-line floor in lines of the box's text at the CURRENT size, so at AX5 it takes everything.
  Options: (a) as built; (b) cap the floor's line height at xxxLarge, as chrome holds, so books keep at least a row;
  (c) the floor yields one book row at the accessibility sizes.

**W-A7 — The fields' caret is the system blue.** A QUESTION FOR HER (the sheet names no caret colour).
- Captures: `*--c2-bookcase-box-focused` (#0088FF light, #0091FF dark), `*--c4-library-search` (#0088FF / #7FC3FF
  mid-blink), s2.
- Seen: the quick-entry box's and the Library search's caret is iOS's default tint, while the editor's selection
  handles (c9) are the accent (#3B6A59 / #90C1AF) and the run tints the system switch with the accent.
- Options: (a) tint the fields with the accent (`.tint(tokens.accent)` in `phoneField`, `Shared/Theme/PhoneControls.swift:299`,
  and on the box's field); (b) leave the system blue.

**W-A8 — Terminal's Settings title breaks after "~/" at AX5.** A QUESTION FOR HER (P-47-13).
- Captures: `seaglass-terminal-{light,dark}-ax5--k1/k2/k3-settings-*` (6).
- Seen: "~/" alone on the first line, "settings" (≈46 pt mono) on the second; the header ≈140 pt tall; "done" 23 pt
  centred beside it; nothing cut. Study AX5's "Settings" (≈50 pt) holds one line.
- The standard: the sheet puts `screenTitle` in her words' class (no cap); P-47-13 keeps the path title muted. Options:
  (a) as built; (b) a path-shaped sheet title holds at xxxLarge like chrome; (c) one line with tail truncation.

**W-A9 — The corrected FAINT carries doors' words under 17 pt.** THIS RUN'S DEFECT.
- Captures: every `*--c3-library-rows` and `*--c4-*` (the Library filter row's unchosen words: #8B7F6A 3.37:1 on the
  room, #7E8376 3.34:1, dark #766F5F / #6B7168 ≈4.2:1 on black, at 13 pt); every `*--c5…c9-*` (the masthead's empty
  chips "no date", "more info", "lens" at 15 pt: #8B7F6A 3.93:1 on the paper, dark #766F5F 3.57:1).
- The standard: sheet §D — "Words under 17 pt need 4.5:1 … Faint never carries a sentence she has to read"; the phone
  layer's faint is "glyphs, placeholders, disabled words only". These are live doors, not disabled words. The sheet's
  §A/§B chip draws the empty chip in the corrected muted (`.chip.empty`) and the set chip in ink; the tab bar's and the
  Trash chips' unchosen words are already the corrected muted.
- Where it comes from: `App/Variorum/VariorumMobile/Features/Shell/MobileListingFilters.swift:194`
  (`selection == door ? tokens.ink : tokens.phone.faint`); `App/Variorum/VariorumMobile/Features/Write/MobileWriteView.swift:458,
  477, 496, 573` (the date, tags, more-info and lens chips' empty state in `tokens.phone.faint`) — batch 1's mechanical
  `tokens.faint` → `tokens.phone.faint`.
- Narrowest fix proposed: the filter row's unchosen words to `tokens.phone.muted` (one line; it serves the Archive's
  row too); the masthead's empty chips to `tokens.phone.muted` and, so set and empty stay apart, the set chips to
  `tokens.ink` (the sheet's two chip inks) — the chips' capsule rebuild stays VM-148's.
- FIXED — `36987c78e` (the filter row's unchosen words and the empty chips in the corrected muted, the set chips in ink —
  PROVISIONAL P-47-29; the same class swept: Note Actions' and Book Details' detail lines, the link row's "opens",
  Starred's "note"/"book", Create Book's tag paths, the Account sheet's tabs); pins `MobileFaintOnDoorsSourceTests`,
  `MobileFaintOnDoorsRenderedTests`; re-capture: c3, c4 (both files) and c5 in all eight part A combinations, and part B's
  r01, r03, r05b, r09 and s12 (r01's "note"/"book" now read in the corrected muted, not the faint §3's check names).

**W-A10 — The search field's placeholder is the system's grey, under the sheet's floor.** THIS RUN'S DEFECT.
- Captures: every `*--c3-library-rows` (and s2 under the iOS card).
- Seen: "Search notes, books…" in #C5C5C7 on white (1.72:1), #C2C2C1 on Terminal's paper (1.72:1), #515858 on the dark
  paper (2.45:1) — while the box's hint, a placeholder too, wears the corrected faint (#8B7F6A 3.93:1 / #766F5F 3.57:1).
- The standard: sheet §D — placeholders take the corrected faint and need 3:1; `phoneField` (this run's one field) sets
  the typed text's ink but not the prompt's.
- Where it comes from: `App/Variorum/VariorumMobile/Features/Shell/MobileLibraryView.swift:217`
  (`TextField(tokens.chromeLabel("Search notes, books…"), text: $query)` — the title becomes iOS's placeholder);
  `Shared/Theme/PhoneControls.swift:299` (`phoneField`).
- Narrowest fix proposed: pass the words as a `prompt:` `Text` in `tokens.phone.faint` (no rendered word changes); the
  other `phoneField` sites (the tag field, the book name, the protection fields — part B's captures) likely share it.
- FIXED — `7734f0f05` (`TextField(phonePlaceholder:text:tokens:)` at the search, the tag field and Create Book's name;
  `phoneField` hands the ink to `PeekableSecretField`, so every passphrase and twelve-words field; the Account sheet's
  seven shared fields NOT covered — run record §6); pins `MobileFieldPlaceholderRenderedTests`,
  `MobileFieldPlaceholderSourceTests`; re-capture: c3 in all eight part A combinations (and s2), and part B's r05 and r06.

**W-A11 — At Terminal AX5 the filter row shrinks "bookless".** ANOTHER TICKET'S — VM-93 (the row's rebuild, owner of
P-47-7's known issue).
- Captures: `seaglass-terminal-{light,dark}-ax5--c3-library-rows`, `…--c4-library-search*`.
- Seen: "bookless" at ≈13.6 pt (x-height 7.33 pt) between siblings at ≈17.6 (9.67 pt); no word cut; Study AX5 unshrunk.
- The standard: §3 c3 "no word shrunk or cut"; P-47-7 claims one unshrunk row at 375 and 402 pt and names only Terminal
  at 320 pt as the known issue. `MobileFilterRowGeometryTests.noFilterDoorIsShrunkToFitEvenAtDisplayZoom` measures at the
  default size only, so it cannot see this. For the record: P-47-7's known issue should also name Terminal at 402 pt at
  the accessibility sizes (the `shrinkingToFloor: true` at `MobileListingFilters.swift:193` is what keeps it on one row).

**W-A12 — No Library row shows a date.** ANOTHER TICKET'S — VM-89 ("Library rows show the title, the time and a line of
the note, and where it lives").
- Captures: every `*--c3-library-rows`, s2.
- Seen: titles only; §3's check expected "dates 13 corrected muted". The search hit's detail ("note") is the corrected
  muted.

**W-A13 — The ⑂ mark beside a fanned block is 7 pt tall.** ANOTHER TICKET'S — VM-188 (the visible badge) / VM-195 (the
marks' cluster), the record's T51/T52.
- Captures: every `*--c5-note-write` and `*--c6-*`, s1.
- Seen: at x 371–376 pt, 7.0 × 5.3 pt, a hairline grey (#6E675D light, #918979 dark) — on the `meta` role, but the
  glyph draws far under a 13 pt word. The comment mark ●1 (c7) reads at 13.7 pt in the comment ink, clear.

### Part A — not judged, and why

- **s0's lifted bar** (`seaglass-study-light-default--s0-pocket-guide-contents`): the bar drawn at 484–539 pt — the
  keyboard-up position c2 shows — with no keyboard on screen and the rows running on beneath it. The seed had typed into
  the Bookcase box just before; a seed capture, so not counted. Part B's b4 (the same contents) will show whether a
  pushed list can keep the bar lifted after the keyboard has gone.
- **c6, the take tint**: all four c6 captures are pixel-identical to c5 — no peek was captured, so the take tint and
  the pill have no evidence here (part B's f5/f6 show the pill).
- **c8, the caret on the paper**: no caret is visible in any c8 (blink phase or not placed); c9's accent handles are the
  only evidence of the editor's tint.
- **Tap areas** (44 pt targets, the 64 × 44 Done, the tools' touching 44s): drawn shapes only can be measured in a
  capture; the hit areas are the geometry pins' evidence, not this read's.
- **Interleaving in the Library**: only notes are in the first screen of "All".

### Part B

PENDING — part B's reader.

### Part B, set 1 — findings

Read 2026-11-19 (§4b rows B1–B9): the 76 captures of the second palette, Settings' flows, VM-54's flip and the re-seed,
on the tree before part A's fixes. Not one message line in any note capture of the set (teal c5–c9, s08, s14, and the
f-series' notes).

| Combination and test | Verdict in one line |
|---|---|
| `teal_rust-study-light-default` — the core (14) | The second palette's relations hold (paper #FFFFFF vs room #E1F4F2 1.14:1, accent #AE4028 ≥ 4.55:1 on its wash, every phone ink readable); part A's W-A1 (#FFFFFF strips), W-A5, W-A7, W-A9, W-A10, W-A12, W-A13 show identically; c8 CAUGHT the editor's caret (the accent, mid-blink); c6 not judged. |
| `teal_rust-study-dark-default` — the core (14) | Holds (dark faint #766F5F 3.49:1 on the hued paper #0C1D1B, the hardest case, clears 3:1); W-A1 (#000000 bands round the note and behind the keyboard bar), W-A5, W-A7, W-A9, W-A10 (#4E5A5C, 2.44:1), W-A12, W-A13; **W-B2** (the blue callout at 1.05:1 on the dark paper); c6 not judged. |
| `seaglass-study-light-default` — Settings' flows (16) + the re-seed (4) | R-47-2, the appearance choice (every surface, and back), Settings from the Library and a note, Protection on the Library's stack all MATCH; **W-B1** (the Trash's promise in the faint, s4b), **W-B3** (Delete Note… in the system red), **W-B4** (a doubled hairline), **W-B5** (the overlay scrim lightens in the dark override); W-A1 on Protection and in the dark override, W-A9 on the sheet's detail lines. |
| `seaglass-terminal-dark-default` — Settings' flows (16) | As Study light: everything MATCHES but W-B3 and W-B4 (both voices), W-B5 in dark; W-A1 shows as #FFFFFF strips once the app's choice is Light (s07, s08); W-A2 in s05's Terminal path ("~/home/bookcase  ·…", the Study-light run's). |
| `seaglass-study-light-default` — VM-54's flip (6) | MATCHES: every card edge, the chosen edge and the draft field's edge measured in their dark colours one second after the flip; no light token left anywhere; the pill: NO EVIDENCE (none caught; f6 a transition frame). |
| `seaglass-terminal-light-default` — VM-54's flip (6) | MATCHES as Study (chosen #2F7D5F → #6FBF94, edges #CBE2D9 → #1C332A); W-A1's #FFFFFF strip under the overlay's #FBFBF7 (f3); the pill: NO EVIDENCE. |

**Part A's findings that show in this set, and what is new about them** (not re-filed):
- **W-A1** — under teal & rust exactly as under sea-glass: light #FFFFFF 0–62 and 840–874 around the room #E1F4F2 (every
  teal root); dark #000000 bands 0–62 and 840–874 around the note's paper #0C1D1B and 487–553 behind the keyboard bar
  (teal c5, c7, c8, c9). NEW: it shows on Protection (s03b, #FFFFFF around the room) and under the takes and comments
  overlays (f3 Terminal: #FFFFFF 840–874 under the overlay's #FBFBF7); and the bands follow the app's CHOSEN appearance,
  not the simulator's (s07/s08: #FFFFFF in the Terminal-dark run set to Light, #000000 in the Study-light run set to
  Dark) — the window's own ground resolves in the override, so the clip is the whole mechanism there too.
- **W-A7** — NEW evidence: the editor's caret IS the accent (teal c8: #EBCFC9 = #AE4028 at 25% over white, #76554B =
  #E08D7B at 50% over the dark paper), while the box's and the search's caret stay the system blue (teal c2, c4) — under
  a rust accent the mismatch is starker than under sea-glass.
- **W-A9** — the same words in the faint under teal & rust (filter row 3.45:1 on #E1F4F2; chips 3.93 / 3.49:1); also
  Starred's "book"/"note" (s3b, s01) and Note Actions' detail lines (s12) — all in W-A9's swept list, fixed since.
- **W-A10** — teal & rust's dark placeholder #4E5A5C on #0C1D1B, 2.44:1 (a hex part A did not have); fixed since.
- **W-A2** — s05 (Study-light run, flipped to Terminal) shows "~/home/bookcase  ·…" exactly as part A's Terminal c1.
- **W-A5, W-A12, W-A13** — identical under teal & rust (the 🗑's grey-blue beside a rust accent; no dates; ⑂ 5.3 × 7.0 pt).

**W-B1 — The Trash's promise sentence is drawn in the corrected FAINT.** THIS RUN'S DEFECT.
- Captures: `seaglass-study-light-default--s4b-reseeded-trash` (set 2's `b1-trash-bar-top-edge`, `r14-trash`,
  `r14b-trash-notes-chip` will show it in all their combinations).
- Seen: "Deleted things wait here for 30 days, then they're gone." at 13 pt (`meta`) in #8B7F6A on the paper #FFFFFF —
  3.93:1 — under the Trash's title, while the row's own meta ("note  ·  30 days left") wears the corrected muted #6A6359.
- The standard: sheet §D — "Words under 17 pt need 4.5:1 … Faint never carries a sentence she has to read"; the phone's
  faint is "glyphs, placeholders, disabled words only; never a sentence"; sheet §A's meta role names "explainer
  sentences" in the corrected muted and draws this very sentence's kind ("Everything this note has on the 30-day
  clock.") in it. `RecoveryCopy.windowNote`'s own comment calls it "the promise stated where she can read it".
- Where it comes from: `App/Variorum/VariorumMobile/Features/Shell/MobileTrashView.swift:153–155`
  (`Text(tokens.chromeLabel(RecoveryCopy.windowNote)).phoneType(.meta, tokens).foregroundStyle(tokens.phone.faint)`) —
  batch 1 (`ccd481162`) carried the old `tokens.faint` across as `tokens.phone.faint`. The same construct holds the
  Archived room's promise, `MobileArchiveView.swift:105–107` (`RecoveryCopy.archivedForever`, set 2's b12/r15), and the
  empty Bookcase's sign-in sentence, `MobileShelfView.swift:194–195` (not captured). W-A9's fix swept doors' words, not
  sentences, so none of these moved (HEAD still reads `phone.faint` at all three).
- Narrowest fix proposed (not made): `tokens.phone.muted` on those sentence lines (the Trash's and the Archive's promise;
  the empty shelf's sign-in line), no word changed; a source pin in `MobileFaintOnDoorsSourceTests`' style naming the
  sentence sites. Evidence after: re-capture s4b / b1 / r14 / b12 / r15 and read the line's hex.
- FIXED — `a21110f9d` (with W-C3, one sweep: 19 sites → the corrected muted); pins `MobileFaintCarriesNoWordsSourceTests`, `MobileFaintOnDoorsRenderedTests.theTrashsPromiseClearsTheFloor`; re-capture: s4b, b1, r14, r14b, b12, r15 (read the promise line's hex: #6A6359 light, #948C7C dark).

**W-B2 — On teal & rust's dark paper the callout's blue wash is 1.05:1 — it reads by hue alone.** A QUESTION FOR HER.
- Captures: `teal_rust-study-dark-default--c7-callout-comment` (and c8, c9, where the callout's top shows).
- Seen: the wash #14202B behind block 2 on the paper #0C1D1B: 1.05:1. The same wash is 1.08:1 on sea-glass's dark
  paper #0F1A16, was 1.27:1 on the black room the note sat on before R-47-1, and is 1.14:1 on white in light. In the
  capture the frame is findable by its blue against the teal and by its 💡, not by its lightness; the text over it
  stays readable (12.91:1).
- The standard: §3b c7 — "the callout's wash … clear on the paper in light and dark"; sheet §D — "Fills and hairlines
  stay quiet on purpose. Paper on the room is 1.17:1" (the quietest fill the sheet draws). The wash is not this run's
  token: `MobileCallout.color` (`Features/Write/MobileCallout.swift:107–127`) is "the Mac palette's exact hexes",
  voice- and palette-independent; this run moved her prose onto the hued paper (P-47-16), which is what brought the
  paper's hue up to the wash. The Mac's editor sits on the same paper, so the Mac should read the same (not checked).
- Options for her: (a) as built — the Mac's exact washes, quiet by design; (b) the dark washes stepped away from the
  paper until they clear a floor against every shipped palette's dark paper (the phone inks' rule, applied to the five
  washes), Mac and phone alike; (c) a hairline edge on a callout frame in dark only.

**W-B3 — "Delete Note…" in the note's ⋯ sheet is the system red, not the alarm.** THIS RUN'S DEFECT.
- Captures: `seaglass-study-light-default--s12-note-actions-settings-row`,
  `seaglass-terminal-dark-default--s12-note-actions-settings-row` (set 2's `r09-note-actions` will show it too).
- Seen: "Delete Note…" / "delete note…" in #F23032 on the sheet's room #E5F0EC (3.43:1) and #FF4245 on black — iOS's
  red — where the Trash's "Delete Now" (s4b) wears the alarm #9B3B2F (5.88:1 on the same room). Terminal's alarm is
  #A33A2E / #E08A7C (`VoiceTokens`).
- The standard: sheet §D, the alarm row — "#9B3B2F / #D98A78 · unchanged; **replaces the literal red on Delete
  note…**"; sheet §E menu row — "A removing act wears the alarm ink, last"; the run's own component table (record §6) —
  "label `control` 17 in ink (alarm when removing)"; §3c s12 — "Delete Note… last in the alarm". Batch 2 adopted this
  sheet's rows onto `PhoneMenuRowStyle` (record §4 row 2.2, "Note Actions' rows the menu row") and kept the tint.
- Where it comes from: `App/Variorum/VariorumMobile/Features/Write/MobileNoteActions.swift:292–299` — `deleteRow`'s
  `actRow(…, tint: .red, role: .destructive)`.
- Narrowest fix proposed (not made): `tint: tokens.alarm` there (keep `role: .destructive`); the file's long note about
  `.red` rendering as the label colour in `layer.render` captures (306–318) is moot either way — the walk shows it red.
  A pin in the run's rendered-ink style: the delete row's title resolves to `tokens.alarm` in both voices and
  appearances (red-on-old: the system red).
- FIXED — `71ccdd4fc` (`tint: tokens.alarm`); pins `MobileNoteActionsAlarmTests`, `MobileLookSourceTests.noPhoneViewPaintsALiteralColour` (extended to a hue passed as an argument); re-capture: both `s12-note-actions-settings-row`, r09 (the title #9B3B2F / #A33A2E light, #D98A78 / #E08A7C dark).

**W-B4 — A doubled hairline in the note's ⋯ sheet above "Settings".** THIS RUN'S DEFECT.
- Captures: both `s12-note-actions-settings-row` (Study light, Terminal dark); set 2's `r09-note-actions` likely too.
- Seen: two hairlines 13.3 pt apart with nothing between them — 646.7–647.3 and 660.3–661.0 pt, both voices — between
  "Versions…" and "Settings".
- The standard: sheet §C/§E — one hairline between rows (or a group's gap); nothing in the sheet or the record draws an
  empty band between two rules.
- Where it comes from: `MobileNoteActions.swift` — the body's `VStack(spacing: 14)` (:102) draws `Divider()` after
  `versionsRow` (:108), then `undoRow` and `redoRow`, which render NOTHING with an empty structural-undo stack, then
  `settingsRow`, which opens with its OWN `Divider()` (:251) — two dividers one stack-spacing apart. `settingsRow` is
  this run's (VM-53 piece 5.4, `e622cbbb9`).
- Narrowest fix proposed (not made): draw `settingsRow`'s leading divider only when an undo or redo row renders above it
  (`door.undoLabel != nil || door.redoLabel != nil`); the 108 divider then separates Versions from Settings on its own.
  A pin: the sheet with an empty undo stack draws exactly two dividers (red-on-old: three).
- FIXED — `fb649d6a8` (Settings' own divider only under an undo/redo row); pin `MobileNoteActionsHairlineTests`; re-capture: both `s12-note-actions-settings-row`, r09 (one hairline between Versions… and Settings).

**W-B5 — The three UIKit overlays' scrim is the ink at 25%, so in dark it lightens the note.** ANOTHER TICKET'S — VM-152
(the takes, comments and block history become native sheets; their hand-built dim view goes with them).
- Captures: `seaglass-study-light-default--s09-appearance-dark-takes-overlay`, `…--f2-takes-cards-dark`,
  `…--f4-comment-draft-dark`, and the Terminal f2/f4.
- Seen: over the note behind the overlay, #454C47 on the dark paper #0F1A16 (a light veil, 2.02:1 brighter than the
  page) and #C5C6C4 over #FBFBF7 in light; the veil covers only the editor's region (from 283 / 326 pt down) — the
  masthead above it stays undimmed. It follows the appearance (the ink is dynamic), so it is NOT a colour left behind by
  the flip (VM-54 holds).
- Where it comes from: `dimView.backgroundColor = face.ink.withAlphaComponent(0.25)` —
  `Features/Takes/MobileTakesBrowserView.swift:295`, `Features/Write/MobileCommentsSheetView.swift:191`,
  `Features/Takes/MobileBlockHistorySheetView.swift:168` (all `0470aeedb`, 2026-08-03, before this run).

**Noted, not filed** (another reader's screen, or no rule to judge it by): Starred in Terminal lowercases her names
("walk note" where the Library says "Walk note" — `MobileStarredView.swift:127` runs the name through `chromeLabel`, as
the Mac sidebar's `rowTitle` does; set 2's r01); Protection's explainer sentences are 13 on an 18 pitch where §3f's r17b
expects 15 (set 2's); in Terminal the note's ⋯ sheet lowercases whole detail SENTENCES ("… for 30 days. you can put it
back …") while Protection keeps its sentences' capitals — a voice-grammar question, and no rendered word may change in
this run; the note's ⋯ sheet keeps its rows on the room while Settings' rows sit on the paper (the record's grounds
table built it so — her look); the overlays' "+ New take" and "✓ Chosen" draw ≈ 14 pt (VM-152's overlays; above 13).

**What I could not judge, and why**
- **The take tint and the pill on teal & rust's paper (c6) and the pill's edge across the flip (f5, f6):** no peek was
  caught — both teal c6 frames are pixel-identical to their c5, and f5 shows the chosen take with no pill; f6 is the
  system's light → dark cross-fade frame (paper #A8ACAB Study / #8A8F8B Terminal), shot the same second as the flip.
- **The comment mark under teal & rust on the fanned lesson / the seeded comment:** none was ever filed (the comment's
  Add sits under the keyboard, NOT-HITTABLE — VM-14); c7's own lesson mark ●1 was judged instead.
- **Tap areas** (44 pt targets, Done's 64 × 44, the menu rows' 64): only drawn shapes are measurable; the geometry pins
  are their evidence. The comment draft field DRAWS 40 pt tall (784–824) — VM-14 / VM-152's.
- **Settings opened from Starred:** s01 shows Starred's ⋯ menu open; the walk does not open Settings from there.
- **Teal & rust under Terminal or at AX5:** not in the set (Study, default size only).
- **Teal & rust's token values against `PaletteDerivation`:** measured from pixels, not computed from the rule (no code
  run here); they agree with the relations §2 asks for.
- **Whether the Mac shows W-B2 the same way:** inferred from the shared hexes and the Mac editor's paper, not seen.

### Part B, set 2 — findings

Read 2026-11-19 (§4c rows C1–C19): the bar's roads and VM-55's faces in Study light and Terminal dark, the wider pass's
first combination (Study light), on the tree before part A's fixes; code traced at HEAD `1973c98b7`.

**Question (a) — the one message line, and the missing m3.**
- **The line (m1, m2), both combinations:** drawn at the foot ABOVE the bar, never over its doors — on the Library root
  (m1) and on the Trash pushed from the Library (m2) at the same place, 721–784, its foot on the bar's hairline at 784;
  on the room (#E5F0EC / #000000) under the palette's hairline (#CBE2D9 / #1C332A); the words 15 in the corrected muted
  (#6A6359 5.08:1 / #8B9088 6.44:1), "Undo" 15 semibold in the accent (#3B6A59 5.31:1 / #90C1AF 10.43:1). One thing
  is not the sheet's: the words wrap to two lines, so the line is 63 pt, not one 44 pt line (W-C1).
- **The line was still on screen in m2** (both combinations) — its words and its Undo drawn.
- **The driver's own XCTest timings** (`final/logs/test40_shell-*.log`, test-relative seconds) settle the rest. Study
  light: the delete's confirm tapped at 258.81, the app idle at 259.10 (the removal is spoken here: the 6 s clock,
  `StatusCenter.dismissAfter = .seconds(6)`, `Shared/StatusCenter.swift:217`, re-armed in `place`, :375–381, runs out
  ≈265.1–265.5); m1 shot ≈259.8–260.2; the Trash door tapped at 262.57, idle 262.85; m2 shot ≈263.3–263.8; then
  `button("Undo")` (`onscreen`'s `waitForExistence(2.5)`) began at 263.81 and **its predicate was SATISFIED at 264.87**
  — the wait returned 1.4 s before its timeout and the driver counted the matches at 264.89, so the Undo WAS in the
  app's accessibility tree, found by XCUITest inside the line's passthrough window; then `tap(_:_:timeout: 2)` began a
  SECOND `waitForExistence` on the same element at 264.92, whose checks at 265.95 and 266.93 both FAILED (the element's
  debug description captured each time) → `MISSING the line's Undo` at 267.0. Terminal dark, the same shape: idle after
  the confirm at 259.22, the Undo found at 265.07, gone at 266.16. In both runs the Undo existed ≈5.8 s after the
  removal and was gone ≈6.9 s after — the 6 s clock straddled. Every wait in these logs takes ≈1.0 s to its first check,
  and the driver paid two back to back (the lookup's, then `tap`'s own re-wait) after m1's settle (0.7 s), the Trash
  tap's two waits (≈2.3 s) and m2's settle (0.5 s): ≈4.6 s of the 6 were gone when the Undo lookup began, ≈5.7 s at its
  first check, ≈6.8 s at the re-wait's first check.
- **So the evidence supports the DRIVER'S TIMING, not an app defect:** the line was up, its Undo reachable to the
  accessibility query in its own window, and its life simply ran out between the driver's two waits. Not proved by the
  walk: that a synthesized tap on the door lands — the window's `hitTest` passes only the door
  (`MobileMessageLine.swift:213–219`, `PassthroughView.hitTest` :314–320), and `MobileMessageLineHostTests` pins in
  process that the door's centre takes the touch; a tap at an element's hit point goes through that same `hitTest`.
- **What would settle it:** re-run m3 with the Undo tapped as soon as it is found — one `waitForExistence(timeout: 1)`
  then `tap()` with no second wait (or tap it from m1 before the Trash push, keeping m2 for the place), within ≈4 s of
  the confirm; then capture the Library row back and the Trash without the note.

| Run (test, combination) | Verdict in one line |
|---|---|
| `test40_shell`, `seaglass-study-light-default` (18 + m3 absent) | The bar at the foot on every pushed list with its owning tab's word; tab taps land on roots; no bar and no lifted line on Read, a note, the reader, Protection; the wing list as P-47-8; the one line above the bar — but **W-C2** (b10: the hidden Library search's keyboard over the Bookcase), **W-C1** (the line two lines tall), m3 not captured (timing); W-A1 (#FFFFFF under the bar), W-A9, W-A10, W-B1, W-A5, W-A12 as recorded. |
| `test40_shell`, `seaglass-terminal-dark-default` (18 + m3 absent) | The same verdicts; **W-C2** and **W-C1** both show; **W-C8** (her excerpt lowercased in Versions' rows); W-A1 as the #000000 strip above the paper on every pushed screen and the black bands round the note; W-A2, W-A3, W-B1 (3.55:1, two lines). |
| `test20_rest`, `seaglass-study-light-default` (24) | The ★ in its own token, Cancel semibold, fields 44.6, segmented choices 45, chips 32, Book Details' Delete in the alarm, Protection's sentences 13 per the sheet, the overlays nothing under 13 — **W-C3** (headers and sentences in the faint), **W-C4** (unchosen segment words 4.44:1), **W-C5** (disabled calm button 1.65:1), **W-C6** (tag hint cut), **W-C7** (Lenses' system hairline); W-B1, W-B3, W-B4, W-B5, W-A9, W-A10, W-A13 as recorded; OR / AND and the book's two "+" doors not on screen. |

**Earlier findings that show in this set, and what is new about them** (not re-filed):
- **W-A1** (since fixed) — NEW screens: every pushed screen in Terminal dark wears a #000000 strip 0–62 above its
  paper #0F1A16 (the lists b1, b4, b8, b12; the note b6; the reader b9); Read in Study light has #FFFFFF strips round the #FAF8F3 room and its last prose line
  cut at 840 (b5 / r04 / r04b); the message line's screens (m1, m2) and every pushed list in Study light show
  #FFFFFF 840–874 under the bar. On Study light's pushed lists the top strip happens to match (the paper is white).
- **W-A9** (since fixed) — r01's "book" / "note", r03's detail lines, r05b's tag paths, r09's detail lines, b12 / r15's
  "Notes" filter word, b6's empty chips — all on its sweep or re-capture list. W-C3 is what its sweep did not reach.
- **W-A10** (since fixed) — r05 "Name" and r06's tag hint in #C5C5C7 1.72:1 (the fix covers both sites); the Library
  search in m1 / b2 / w2.
- **W-B1** — the Trash's promise in b1 / r14 / r14b / m2 (Study 3.93:1; Terminal dark #6B7168 3.55:1 and wrapped to two
  lines) and the Archive's "kept — no clock" in b12 / r15 (3.93 / 3.55:1). HEAD still faint at all three of its sites.
- **W-B3, W-B4** — r09 is pixel-identical to s12: Delete Note… in #F23032 and the doubled hairline (both #CDE1D9).
  Book Details (r03) shows the right ink beside it: Delete Book… in the alarm #9B3B2F.
- **W-B5** — r11 / r12 / r13 in light: the veil #C9C8C6 over the prose from 283 pt, the masthead undimmed.
- **W-A13** — NEW screen: the Blocks sheet's ⑂ (r07), 5.3 × 7.0 pt at x 375.
- **W-A2, W-A3** (W-A3 since fixed) — Terminal's Bookcase line "~/home/bookcase  ·…" and names from 47.5 pt in b3, b7,
  b10, w1, w3.
- **W-A5, W-A7, W-A12** — the 🗑 emoji on every root's line; b11's caret the system blue; no dates on Library rows.
- **s0 (part A, not judged there)** — b4 is NORMAL (the bar at 785–840); b10 lifts the bar to exactly s0's 484–539 with
  a hidden field's keyboard drawn (W-C2), which makes a hidden page's live focus the likely road to s0's frame too.

**W-C1 — The one message line wraps to two lines: 63 pt, not one 44 pt line.** A QUESTION FOR HER.
- Captures: `seaglass-study-light-default--m1-line-library-root`, `…--m2-line-over-trash-bar`, and both
  `seaglass-terminal-dark-default--m1…` / `--m2…`.
- Seen: "Note moved to the Trash — 30 days to put it back." at 15 pt fills 21–308 pt on its first line and wraps "it
  back." to a second (737–768.7); with Undo's column (x 315–381) the line runs 721–784 = 63 pt (Terminal's mono wraps
  "to put it back." the same).
- The standard: sheet §E's receipt line — "One line, 44 tall, at the foot of the screen"; P-47-8 put the words on
  `controlInline` 15 (the sheet's own number). As built the face wraps on purpose: `MobileMessageLine.swift:159–163`
  (`.lineLimit(4)`, `.fixedSize(horizontal: false, vertical: true)` — "one line of them is the line's 44, and several
  keep clear of its edges"). The words are VM-61's (VM-55), and this run may change no rendered word.
- Options for her: (a) as built — the line grows by lines (63 pt for this receipt); (b) one line, tail-truncated (cuts
  "30 days to put it back.", the promise); (c) shorter receipt words in her wording pass, so the common receipts fit one
  44 pt line at 15 pt with Undo.

**W-C2 — A tab tapped from a pushed list over a searched Library raises the Library search's keyboard over the
Bookcase.** THIS RUN'S DEFECT (born of P-47-19's pop of the leaving stack).
- Captures: `seaglass-study-light-default--b10-bookcase-from-versions`, `…--b11-library-root-after`, and both
  `seaglass-terminal-dark-default--b10…` / `--b11…`; for contrast `…--b8-versions-listing-bar`, `…--b9-versions-reader-no-bar`
  (no keyboard).
- Seen: the road — the Library searched ("swipe" typed, the keyboard up), its hit opened (the note pushed; the keyboard
  goes), Note ▸ Versions… (the listing pushed, b8, no keyboard), a moment read and "‹ Versions" (b9, no keyboard), then
  "Bookcase" tapped: b10 is the Bookcase ROOT with its box at rest (hint, no caret, no ▋) and a software keyboard up,
  the bar lifted to 484–539 (hairline 483) — 300 pt off its foot — with nothing on the Bookcase focused; "Library"
  tapped: b11 shows the Library's search field holding "swipe" with its caret. Both combinations, identically.
- The standard: P-47-19 (a) — "the stack being left returns to ITS root … so a hidden stack always stands at its root
  (the band never reveals a pushed screen)"; a page she is not on must not take the keyboard; §2 puts the bar at the
  foot ("the room down to the home indicator") and records it riding above the keyboard only while the box or the
  search she is on is focused (VM-73's case) — here neither is on screen.
- Where it comes from (traced at HEAD; the restoring agent inferred, not traced in system source):
  `App/Variorum/VariorumMobile/Features/Shell/MobileShellView.swift:713–735` — `tabSelected` calls
  `popToRoot(leaving, animated: false)` (`libraryPath = NavigationPath()`) and then `selectPage(target)`. Popping the
  Library's stack back to its root makes the root's search field — first responder when its hit was pushed — first
  responder again, while that page is already sliding a screen-width away; the keyboard rises over the Bookcase and
  every keyboard-following frame (the bar, the line) lifts with it. b8 and b9 rule out a field left focused under the
  pushed screens: no keyboard shows there.
- Narrowest fix proposed (not made), two candidates, the walker to pick after confirming the restoring agent: (a)
  confined to P-47-19's road — in `tabSelected`, end editing (`UIApplication.shared.sendAction(#selector(UIResponder
  .resignFirstResponder), to: nil, from: nil, for: nil)`) once the leaving stack's unanimated pop has settled, so a
  responder restored on a page leaving the screen is let go before the keyboard shows (narrow in behaviour, but it races
  the restoration's timing); (b) leave nothing to restore — end editing as a route is pushed onto a stack (the Library's
  hit opens through `libraryPath.append`; `push(_:in:)` :650), which also stops a plain Back from re-raising the
  keyboard on the visible Library (a behaviour change on a road she sees — her word if (b)).
- Evidence after: re-walk b8–b11 (search, open the hit, Versions, read, "Bookcase"): b10 with no keyboard and the bar at
  785–840; b11 with the field unfocused (or focused only by her tap). A pin in a real scene window (the line host pin's
  shape): a focused text field in one stack's root, a route pushed, the shell's tab road to another page, assert no
  first responder after the run loop settles (red on old: the field is first responder again).
- FIXED — `05afd4b34` (the shell tells each page whether it is on screen; the Library's search gives the keyboard back while its page is hidden — a Back on screen keeps its restoration); pin `MobileHiddenPageKeyboardTests`; re-capture: b8–b11 in both combinations (b10 with no keyboard and the bar at 785–840; b11 with the field unfocused; look for a one-frame keyboard flicker at b10).

**W-C3 — The corrected faint still carries section headers and sentences W-B1's sweep does not name.** THIS RUN'S
DEFECT (batch 1's one-for-one `tokens.faint` → `tokens.phone.faint`, W-A9 and W-B1's class).
- Captures: `seaglass-study-light-default--r06-tags-sheet` ("Apply a tag", 13 semibold, #8B7F6A 3.37:1 on the room);
  `…--r06b-membership-sheet` ("Add to a book", 13 semibold, 3.37:1; "Editing here edits the note everywhere it appears.",
  13, 3.37:1); `…--r07b-blocks-leaving` (the tray's explainer, two lines, 3.37:1); `…--b8-versions-listing-bar` /
  `…--r10-versions` (Versions' explainer, three lines, #8B7F6A 3.93:1 on the paper; Terminal dark #6B7168 3.55:1, four
  lines); `…--b9-versions-reader-no-bar` (the moment's meta — "4 blocks · “…”", her excerpt — in the faint, 3.93 / 3.55:1,
  while the LISTING draws the same line in the corrected muted 5.93:1).
- The standard: sheet §D — "Words under 17 pt need 4.5:1 … Faint never carries a sentence she has to read"; the faint
  is "glyphs, placeholders, disabled words only"; sheet §A's section-header row draws "Add to a book" itself (and names
  "Apply a tag") in "SF Pro 13 semibold · corrected muted", and its meta row draws "Everything this note has on the
  30-day clock." in the corrected muted.
- Where it comes from (HEAD): `Features/Write/MobileNoteTags.swift:244` ("Apply a tag"), `:220` (a tag's path line);
  `Features/Write/MobileMembership.swift:321` ("Add to a book"), `:252` ("Editing here…"), `:296` ("smart");
  `Features/Write/MobileNoteTray.swift:613` (the tray's explainers), `:674` and `:701` (the tray rows' meta lines);
  `Features/Write/MobileVersions.swift:416` (the explainer), `:479` (the reader's meta); not captured but the same class:
  `Features/Write/MobileReferences.swift:264` (a file row's note), `Features/Shell/MobileLibraryView.swift:432` (the
  empty store's sign-in line), `Features/Shell/MobileQuickNote.swift:1191` (the box's hold note),
  `Features/Shell/MobileTagManager.swift:411` (a tag's path). The faint's legitimate uses stay: the box's hint and
  dashed edge (`MobileQuickNote.swift:1292, 1303`), the ○ pick mark (`MobileBlockList.swift:500`), the disabled "Use as
  Daily Journal" (`MobileBookDetails.swift:429`), the fields' placeholders (`PhoneControls.swift:310, 337`).
- Narrowest fix proposed (not made): `tokens.phone.muted` at those sites, landed with W-B1's three (one sweep, one pin):
  extend `MobileFaintOnDoorsSourceTests` to name every `phone.faint` site and the reason it may stay (glyph, placeholder,
  disabled) — red on old: the sites above. Re-capture r06, r06b, r07b, b8 / r10, b9 and read the hex.
- FIXED — `a21110f9d` (with W-B1, one sweep and one rule); pins `MobileFaintCarriesNoWordsSourceTests`, `MobileFaintOnDoorsRenderedTests.theTrashsPromiseClearsTheFloor`; re-capture: r06, r06b, r07b, b8 / r10, b9 (the corrected muted #6A6359 / #948C7C).

**W-C4 — The segmented choice's unchosen words fall under 4.5:1 on the system's track.** THIS RUN'S DEFECT (batch 2's
segmented choice, `91d406593`).
- Captures: `seaglass-study-light-default--r05-create-book`, `…--r05b-create-book-smart`, `…--r07-blocks-sheet`,
  `…--r07b-blocks-leaving` (the track over the room is #D7E1DE; "Journal Book", "Smart Book", "archived", "leaving" 15 in
  #6A6359 — **4.44:1**); and, measured by this reader on part A's captures, `seaglass-study-dark-default--k1-settings-top`
  (track #273030, "Light" / "Dark" #948C7C — **4.06:1**) and `seaglass-terminal-dark-default--k1-settings-top`
  (#8B9088 — **4.15:1**). Settings in light clears (#EEEEEF: 5.11:1 Study, 4.93:1 Terminal per part A's track).
- The standard: sheet §D — "Words under 17 pt need 4.5:1"; the segment words are 15 (the chip role). The track is the
  system's translucent fill, which darkens the room and lightens the dark paper — no token.
- Where it comes from: `App/Variorum/Shared/Theme/PhoneControls.swift:664–668` (`PhoneSegmentedControlBridge.updateUIView`:
  the unchosen words `tokens.phone.muted`, the thumb `tokens.surface`, the track left to the system).
- Narrowest fix proposed (not made): give the control a token track on which the corrected muted clears in every
  appearance — the room (`control.backgroundColor = UIColor(tokens.room)`: 5.08:1 Study light, 5.09:1 Terminal light,
  6.30 / 6.44:1 on black; the paper thumb still marks the choice), or keep the system track and set the unchosen words
  in ink; which of the two is a look call. Verify on device that iOS 26's control honours a background colour for its
  track. A pin in the run's rendered-ink style: the unchosen word's contrast over the control's own drawn track ≥ 4.5:1 in
  both voices × appearances (red on old: 4.44 / 4.06 / 4.15).
- NOT FIXED — traced (the walk's fixes, batch 2, piece 9): the track is iOS's own drawing; no per-instance road gives a token track short of a hand-built control; a question for her as P-47-30 in the run record's §5 (as built · the unchosen words in ink · a hand-built token track); no re-capture.

**W-C5 — The disabled calm button reads 1.65:1.** A QUESTION FOR HER.
- Captures: `seaglass-study-light-default--r05-create-book`, `…--r05b-create-book-smart` ("Create Book" before a name).
- Seen: the whole control at 35% — the fill #EEF5F3 on the room, the edge nearly gone, the word #B0C4BD: 1.65:1.
- The standard: sheet §D lists "disabled words" among the corrected faint's uses (3.37–3.93:1) — a disabled word is
  meant to stay readable, quieter; the build dims every phone control by the Mac's shared pages' precedent
  (`PhoneControlMetrics.opacity` → 0.35, `App/Variorum/Shared/Theme/PhoneControls.swift:108–113`, batch 2).
- Options for her: (a) as built — the Mac's 35% dim, one rule for every control; (b) the sheet's ink — a disabled
  control's word in the corrected faint at full opacity, its shape kept; (c) show the act only when it can act.

**W-C6 — The tag field's hint is cut mid-word at 17 pt.** A QUESTION FOR HER (P-47-6's precedent).
- Captures: `seaglass-study-light-default--r06-tags-sheet`.
- Seen: "type a tag — ↩ applies it (“/” nests: life/go…" — the field's prompt (`MobileNoteTags.swift:180`, "type a tag —
  ⏎ applies it (“/” nests: life/goals)") tail-truncated at the field's end (32–362 pt) at the field's 17 pt (P-47-14).
- The standard: P-47-6 settled the same case for the box's hint — "the longest of its own cuts that fits", no new words.
  Options: (a) as built (tail cut); (b) P-47-6's rule here ("type a tag — ⏎ applies it"); (c) new words in her wording
  pass.

**W-C7 — The Lenses sheet's divider is the system's grey, not the palette's line.** THIS RUN'S DEFECT (small — the
layer pass missed one divider).
- Captures: `seaglass-study-light-default--r08-lenses`.
- Seen: the hairline at 247.3 pt is #B4BCBB (the system separator over the room), where every other sheet's divider
  measures the palette's line (#CBE1D9 in r03, #CDE1D9 in r09).
- The standard: sheet §D — "the hairline 1.17:1 (1.36 on paper)", the palette's line; the run's other dividers wear
  `Divider().overlay(tokens.line)`.
- Where it comes from: `App/Variorum/VariorumMobile/Features/Takes/MobileLenses.swift:606` — a bare `Divider()`
  (predates the run).
- Narrowest fix proposed (not made): `.overlay(tokens.line)` on it; a source pin that every phone `Divider()` outside a
  `Menu` wears the line.
- FIXED — `c7b6f0459` (`Divider().overlay(tokens.line)`); pin `MobileLookSourceTests.everyPhoneDividerWearsTheLine`; re-capture: r08 (the hairline #CBE2D9 light).

**W-C8 — Terminal lowercases her words in Versions' rows.** A QUESTION FOR HER (predates the run; the screen's owner
is VM-147's umbrella, P-47-20's list).
- Captures: `seaglass-terminal-dark-default--b8-versions-listing-bar`, `…--b9-versions-reader-no-bar`.
- Seen: the moment's meta reads "4 blocks · “takes are for trying; choosing is deciding. the take with the ✓ ”" — her
  note says "Takes are for trying; CHOOSING is deciding. The take with the ✓"; her capitals are gone in both the listing
  and the reader. Study keeps them.
- Where it comes from: `Features/Write/MobileVersions.swift:437` and `:477` —
  `tokens.chromeLabel(MobileVersionsModel.rowMeta(item))`, and `rowMeta` quotes her preview (`:291–294`). Set 1 noted
  the same grammar on Starred's names ("walk note"); the Mac's Terminal sidebar lowercases titles too.
- Options for her: (a) as built — Terminal's chrome casing over the whole line; (b) the chrome pieces lowercased and her
  quoted words left as written; (c) no excerpt in Terminal's meta.

**Noted, not filed** (predates the run, recorded with an owner, or no rule to judge it by): the Archive's filter row
starts at 28.3 pt, 8 pt inside the gutter its title holds (the shared row's own 20 pt padding inside the Archive's 8 —
both from 2026-08-31; VM-93's row); the Trash's chip row clips at ≈392 pt, ≈10 pt short of the screen's edge; Book
Details' detail lines sit beside their labels, not under them (her look); the system toolbar's "Details · Read" wear the
system's label colour (#000000 / #F3F4F4), and the Versions reader stacks two back doors (P-47-20, her look); Read's
chapter label takes Terminal's mono on the voice-independent page; the Comments overlay's empty line at x 17 and Block
History's counts on their own lines (VM-152 / VM-41); the sheets that open full height with no grabber (VM-152); §3f's
"Takes" Trash chip and r17b's "sentences 15" are the walk doc's slips (the Trash lists six kinds by design; the sheet's
meta role is 13 for explainer sentences).

**What I could not judge, and why**
- **m3 — the Undo pressed:** not captured (the driver's timing, question (a)); whether the note comes back is VM-55's
  pins' evidence, not this walk's.
- **The OR / AND choice (r05b):** not on screen — it appears only with two or more tags picked, and the driver picked
  none.
- **A book's "+ New Note" / "+ New Chapter" (r02 / b4):** below the fold in the captured frame.
- **Tap areas** (rows ≥ 44, the Undo's 60 × 44, the wing row): drawn shapes only; the geometry pins are their evidence.
  Where rows have no separators (the wing list, the Tags sheet) even the drawn height is not measurable.
- **r17b's lower sections:** the page did not scroll (it fits); the frame is r17's.
- **The restoring agent in W-C2:** UIKit's input-view restoration on a pop, or SwiftUI's focus — inferred from the road
  (no keyboard in b8 / b9, the field focused again after the pop), not traced in system source; which of W-C2's two fix
  candidates holds depends on it, so the walker confirms it first (a one-line probe: log the first responder after
  `popToRoot(leaving, animated: false)` and again a run-loop turn later).
- **The other two wider-pass combinations** (`seaglass-terminal-dark-default--r*`, `seaglass-study-light-ax5--r*`): the
  other reader's; my rows carry sizes and hexes to compare against.

### Part B, set 3 — findings

Read 2026-11-19 (§4d rows D1–D13): the wider pass in Terminal dark and in Study light at AX5, on the tree before the
walk's fixes; code traced at HEAD `05afd4b34`. Not one capture is missing; nothing in either combination is drawn under
13 pt but the ⑂ glyph (W-A13) — Terminal's smallest words, the overlay's "take 2" and "+ new take", measure the meta
role's 13 (their ascenders 9.7 pt, as Starred's 13 pt "book").

| Combination | Verdict in one line |
|---|---|
| `seaglass-terminal-dark-default` — the wider pass (24) | All SF Mono but the system's own (the status bar, the Read page's serif by design); chrome lowercased; the dark inks exactly the table's — muted #8B9088 (5.46:1 on the paper, 6.44:1 on black), faint #6B7168 (3.55 / 4.19:1), ink #D6DAD2 (12.56 / 14.82:1), accent #90C1AF (8.84 / 10.43:1), the ★ #5B93DE, the alarm #E08A7C on Delete Book… and Empty Trash…; grounds the room #000000 under sheets and Protection, the paper #0F1A16 under every list, the cream #171511 on Read; no light line or light ground left on black. **No new finding.** Shown as recorded: W-A1, W-A9, W-A10, W-A13, W-B1, W-B3 (#FF4245), W-B4, W-B5 (#414A45), W-C3, W-C4 (Settings only), W-C5, W-C6, W-C7 (#323235), W-C8. |
| `seaglass-study-light-ax5` — the wider pass (24) | Her words grow ≈2.8× (row titles and prose ≈48 pt, screen titles ≈50, the Read title ≈58) and the chrome holds (paths 17.3, meta 17.6, Done, doors and the bar ≈23, chips and segment words ≈20, the ★ ×1.3); fields 44.7, segmented choices 45, chips 32.7, Settings' menu rows 44; **new: W-D1** (Book Details squeezed), **W-D2** (Create Book's tag list), **W-D3** (Protection's state lines — a question); W-A4's cuts on seven more screens; VM-152's overlays overlap their own text; W-A1, W-A9, W-A10, W-B1, W-B3, W-B4, W-C3, W-C4 (4.44:1), W-C5 as recorded. |

**Earlier findings that show in this set, and what is new about them** (not re-filed):
- **W-A1** (fixed since, `67525b499`) — Terminal dark: #000000 0–62 above the paper on every pushed screen (r02, r10, r14,
  r15); the overlays' paper stops at 840 over black (r11–r13); Read's card ends FLAT at 840 and clips its line mid-glyph
  (r04 / r04b, 12 of a 16.7 pt line). AX5: #FFFFFF 0–62 / 840–874 on Starred, the contents, Versions, Trash, Archived,
  Read (round #FAF8F3, the line clipped) and Protection (round the room).
- **W-A4** (VM-218) — seven more AX5 screens: Starred "the pocke…", the contents "blocks & typ…", Book Details "the pocket
  gu…" (inside W-D1), Tags "#pocket…", Books "the po…", Versions "Nov 19, 2026…" (the date and time that tell moments
  apart), Blocks (every preview cut at two lines, a one-sentence block included). Where a row wraps instead — the Trash's
  titles, the contents' book name, the sheet titles — her words stay whole.
- **W-A9** (fixed since, `36987c78e`) — Terminal dark: Starred's "book"/"note" 3.55:1, Book Details' and Note Actions'
  details 4.19:1 on the black sheets, Create Book's tag paths 4.19:1, Archived's "notes" 3.55:1. AX5: the same #8B7F6A at
  17.6 pt.
- **W-A10** (fixed since, `7734f0f05`) — Terminal dark #515858 2.45:1 on the dark paper ("name", the tag hint); AX5
  #C5C5C7 1.72:1 at ≈22.6 pt.
- **W-A13** — the Blocks sheet's ⑂: Terminal dark 5.3 × 7.0 pt #898E86; AX5 7.3 × 9.3 (held ×1.33 — still a 9 pt glyph
  beside 45 pt words).
- **W-B1** (fixed since, `a21110f9d`) — Terminal dark: the Trash's promise 3.55:1 (lowercased, two lines) and Archived's
  "kept — no clock" 3.55:1; AX5 3.93:1 at 17.6 pt, two lines.
- **W-B3** (fixed since, `71ccdd4fc`) — Terminal dark #FF4245, 6.12:1: readable, but iOS's red where Delete Book… (r03) and
  Empty Trash… (r14) wear the dark alarm #E08A7C; AX5 #F23032 3.43:1 at ≈23 pt.
- **W-B4** (fixed since, `fb649d6a8`) — both, at 646.7 and 660.3; at AX5 at the very same heights (the medium sheet's rows
  do not move).
- **W-B5** (VM-152) — Terminal dark #414A45 over the paper #0F1A16 on all three overlays; AX5 #C9C8C6 from 359.7 pt.
- **W-C3** (fixed since, `a21110f9d`) — the dark contrasts: #6B7168 on the black room 4.19:1 ("apply a tag", "add to a book",
  "editing here…", the tray's explainer), on the dark paper 3.55:1 (Versions' explainer). At AX5 #8B7F6A 3.37:1 / 3.93:1
  at 17.6 pt — the semibold headers then fall in the sheet's 3:1 tier for 17 pt semibold words; the regular sentences do
  not.
- **W-C4** (open at HEAD — `Shared/Theme/PhoneControls.swift:664–668` unchanged) — Terminal dark Settings (r16) 4.15:1 on
  #273030, confirmed. **New:** on the sheets that sit on the black room (Create Book r05 / r05b, Blocks r07 / r07b) the
  system's track resolves to **#1C1C1F** and the same #8B9088 reads **5.22:1 — clear**; in dark the defect is Settings'
  alone, whose controls sit on the paper rows (and Study dark's, part A's 4.06). AX5: 4.44:1 on #D7E1DE, 5.11:1 on #EEEEEF,
  the words ≈20 pt and whole.
- **W-C5** — Terminal dark: the disabled "create book" #364942 on its #050908 fill, **2.09:1**; AX5 1.65:1 at ≈23 pt.
- **W-C6** — Terminal dark: cut earlier, at "(“/”…" (mono 17). **AX5: NOT cut** — the hint is whole at ≈16.5 pt (its t
  11.0 pt tall against 11.3 at default): the system field shrinks its placeholder to fit, BELOW the field's own AX5 size
  (≈23 — P-47-14). Whether HEAD's prompt road (`TextField(phonePlaceholder:…)`, `7734f0f05`) still shrinks is not seen.
- **W-C7** (fixed since, `c7b6f0459`) — Terminal dark #323235 (the system separator over black; the palette's dark line is
  #1C332A); AX5 #B4BCBB, 1 pt.
- **W-C8** (a question) — where Terminal lowercases HER words in this set: Starred's names (r01, "walk note") and Versions'
  excerpt (r10). Where it does NOT: the Trash's rows keep her capitals ("A note for the message line" — `MobileTrashView`
  draws the title without `chromeLabel`, `MobileStarredView.swift:127` runs it through), the Blocks previews, the take
  cards, Block History's commit row and the Read page. **New:** her names read two ways inside one voice, screen by
  screen. (The store's book names are lowercase already, so their casing cannot be judged here. The app's sentences are
  lowercased on Book Details, Note Actions, the Trash, More Info, Lenses and Create Book while Protection's keep their
  capitals — set 1's grammar note.)
- **Not shown in this set:** W-A2, W-A3, W-A5, W-A6, W-A7, W-A8, W-A11, W-A12, W-B2, W-C1, W-C2 (no root path line but
  Starred's, which fits whole — "~/home/starred", "Home · Starred" at AX5 — no focused field, no message line, no callout).

**W-D1 — At AX5 Book Details stays squeezed in its medium detent: its title and her book's name are cut.** ANOTHER
TICKET'S — VM-218 ("Every screen works with VoiceOver and at the largest text size").
- Captures: `seaglass-study-light-ax5--r03-book-details` (twin `seaglass-study-light-default--r03-book-details`).
- Seen: the sheet's top at 415 pt as at the default size; the header reads **"Book De…"** (Iowan ≈52 pt on ONE line beside
  Done ≈23) and the identity block **"the pocket gu…"** (≈48); meta, Finish (detail two lines) and Delete Book… fit below.
  At the default size both read whole.
- The standard: sheet §A — the screen title and the row title "Scales: yes, full range"; `PhoneSheetHeader` gives the
  title two lines (`.lineLimit(2)`, `Shared/Theme/PhoneControls.swift`), and Create Book's header takes them at AX5 ("New
  / Book", r05) — here there is no room to take them.
- Where it comes from (HEAD): `App/Variorum/VariorumMobile/Features/Shell/MobileBookDetails.swift:262–285` — a plain
  `VStack` with no `ScrollView`, presented `.presentationDetents([.medium, .large])` at `Features/Shell/MobileBookView.swift:149`
  (both `d5a0c12c9`, 2026-08-09): at AX5 the stack is offered the medium detent's height and SwiftUI truncates its texts
  instead of overflowing. The large detent is a drag away (not captured).
- Class: ANOTHER TICKET'S (VM-218 — a sheet that needs to scroll, or to open large, at the accessibility sizes). This run's
  roles and the header's two lines behave where the sheet has the room.

**W-D2 — At AX5 Create Book's smart-book tag list breaks her tag's name mid-word, inside a 220 pt window.** ANOTHER
TICKET'S — VM-218.
- Captures: `seaglass-study-light-ax5--r05b-create-book-smart` (twin `seaglass-study-light-default--r05b-create-book-smart`;
  Terminal dark's r05b reads whole).
- Seen: the first row reads **"#machiav" / "elli"** — her tag's name (rowTitle ≈48 pt) wrapped between characters because
  its path "machiavelli" (17.6, one line) keeps its width on the same line; the list window shows a row and a half — the
  second row's "#pocket" with its path "pocket guide" **clipped by the window's foot** (≈633 pt), its "guide" off-window.
  The list scrolls, so nothing is lost, but a word broken inside itself is not "works at the largest size".
- The standard: sheet §A (her words grow — they do); VM-218.
- Where it comes from (HEAD): `Features/Shell/MobileCreateBook.swift:289–296` — `ScrollView { LazyVStack … }.frame(maxHeight:
  220)` (`c0b3c3da2`, 2026-08-09); the row `:316–329` — `HStack { the ✓ column; Text("#leaf").phoneType(.rowTitle);
  Text(path).phoneType(.meta).lineLimit(1); Spacer() }`.
- Class: ANOTHER TICKET'S (VM-218 — the row's anatomy and the window's height at the accessibility sizes; the path under the
  name, as the sheet's book row draws its meta, is the kind of rebuild that settles it).

**W-D3 — At AX5 Protection's state lines grow as her words: "You're in Standard." ≈47 pt and "This library doesn't
sync." ≈43 pt, beside doors held at ≈23.** A QUESTION FOR HER (P-47-8's role map).
- Captures: `seaglass-study-light-ax5--r17-protection`, `seaglass-study-light-ax5--r17b-protection-scrolled` (twins
  `seaglass-study-light-default--r17-protection` / `--r17b-protection-scrolled`).
- Seen: each wraps to two lines in Iowan (×2.75 and ×2.9 their default 17 and 15), while on the same page the explainers
  hold at 17.6 (meta), the doors at ≈23 (control) — and "Sign in to turn on sync.", the very next line of the sync
  section, at 17.6. At the default size the page reads as built (17 · 15 · 13), and Terminal dark's as built.
- The standard: sheet §A's two classes — "Her words (note body, titles, row titles, previews, comment and take text, the
  twelve words) scale across the whole range … Chrome (meta, controls, chips, headers, tabs, markers) scales up to
  xxxLarge and holds there". These two lines are the app's, not hers; P-47-8's role map (record §6, batch 1) put "the
  posture line … `rowTitle`" and the ruled sentences on the lock, Protection, library-missing and shared-account pages
  `rowPreview` — full-range roles — as a PROVISIONAL judgment.
- Where it comes from (HEAD): `App/Variorum/VariorumMobile/Features/Protection/MobileProtectionDoors.swift:570–572`
  (`ProtectionWords.postureLine` at `.rowTitle`); `Features/Protection/MobileProtectionScreen.swift:236–241`
  (`line(_:ink:)` at `.rowPreview`, which draws `ProtectionWords.accountLocalOnly`). The same rows of the role map cover the
  lock, library-missing and shared-account pages' sentences (not in this walk).
- Options for her: (a) as built — at the largest sizes her library's state reads loudest on the page; (b) the app's own
  state lines and ruled sentences hold at xxxLarge like chrome, their faces and default sizes unchanged (a hold at the
  sites, `.dynamicTypeSize(...DynamicTypeSize.xxxLarge)`, or a chrome-class twin of the two roles); (c) the posture line
  keeps its full range (it names her library's state) and the sync sentence takes `meta` like the line under it.

**What I could not judge, and why**
- **Tap areas** (44 pt targets, Done's 64 × 44, the chips' 44): drawn shapes only. Drawn heights that ARE measurable hold at
  AX5 — Settings' menu rows 44, the fields 44.7, the segmented choices 45, the chips' capsules 32.7.
- **The OR / AND choice (r05b) and a book's "+ New Note" / "+ New Chapter" (r02):** not on screen in either combination (no
  tag picked; below the fold).
- **Book Details at the large detent (W-D1)** and **the other take cards at AX5 (r11)**: the walk did not drag the sheet or
  scroll the overlay; still frames only.
- **W-C6 at HEAD:** the placeholder's road changed after these captures (`7734f0f05`); whether the AX5 shrink survives it
  needs a re-capture.
- **Whether her words reach their anchors' own AX5 sizes:** measured ×2.8 against the default twin (≈48 pt for a 17 pt row
  title); not compared against iOS's own table for the accessibility sizes.
- **Terminal at AX5, Study dark, teal & rust on these screens:** not in this set (part A and set 1 read the core screens in
  them; the wider pass ran in three combinations only).
