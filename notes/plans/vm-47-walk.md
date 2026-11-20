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
| 10 | The core under teal & rust | part B's `teal_rust-…` k0–c9 | PENDING | PENDING |
| 11 | Settings: the voice flipped | s04 s05 | PENDING | PENDING |
| 12 | Settings: the appearance | s06–s11 | PENDING | PENDING |
| 13 | A note's door to Settings | s12 s13 s14 | PENDING | PENDING |
| 14 | Protection | s03b s03c, b13, r17 r17b | PENDING | PENDING |
| 15 | The bar on pushed lists | b1, b4, b8, b12, r02, r14, r15 | PENDING | PENDING |
| 16 | A tab tapped from a pushed list | b2 b3 b7 b10 b11 | PENDING | PENDING |
| 17 | No bar | b5, b6, b9, b13 | PENDING | PENDING |
| 18 | The wing door's list | w1 w2 w3 | PENDING | PENDING |
| 19 | The one message line | m1 m2 m3 | PENDING | PENDING |
| 20 | VM-54's flip | f1–f6 (×2 voices) | PENDING | PENDING |
| 21 | Starred | r01 (×3) | PENDING | PENDING |
| 22 | A book's contents | r02, b4, s0 | PENDING | PENDING |
| 23 | Book Details | r03 | PENDING | PENDING |
| 24 | A book's Read page | r04 r04b, b5 | PENDING | PENDING |
| 25 | Create Book | r05 r05b | PENDING | PENDING |
| 26 | The note's sheets | r06 r06b r06c r07 r07b r08 | PENDING | PENDING |
| 27 | Note Actions | r09, s12 | PENDING | PENDING |
| 28 | Versions | r10, b8, b9 | PENDING | PENDING |
| 29 | The three UIKit overlays | r11 r12 r13 | PENDING | PENDING |
| 30 | Trash | r14 r14b, b1, m2 | PENDING | PENDING |
| 31 | Archived | r15, b12 | PENDING | PENDING |

**Which PROVISIONAL calls each part shows.** Part A: P-47-1 (the sheet's numbers as a set), P-47-4, P-47-5 (dark), P-47-6,
P-47-7, P-47-8 (batch 1's role map), P-47-9, P-47-10, P-47-12, P-47-13 (Settings' header), P-47-14, P-47-16, P-47-17,
P-47-21, P-47-22, P-47-24, P-47-25, P-47-26, P-47-27; R-47-1, R-47-2 and R-47-3 (was P-47-28) as built. Part B: P-47-5 (teal & rust's
dark card), P-47-8 (VM-55's faces), P-47-11, P-47-13 (Create Book's Cancel), P-47-14 (the tag field), P-47-16 and P-47-17
under a second palette, P-47-18, P-47-19, P-47-20, P-47-21 (on pushed lists), P-47-22, P-47-23, P-47-27, VM-54's flip.
**Not shown:** P-47-15 (the lobby — the only lobby face this store shows is the words card, never captured), P-47-7's
320 pt case (Display Zoom — simctl cannot set it; the geometry pins are its evidence), VM-27's doored sync states (the store
never syncs; `MobileSettingsProtectionDoorTests` is that evidence), a second wing (the phone has no wing management — the
wing list shows Home alone).

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
