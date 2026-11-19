# VM-47 — the run's one walk: what the captures show

**Run:** VM-47, "Sizes and look" (branch `vm-47-sizes-and-look`, worktree `~/dev/variorum-vm-47`). **Tree walked:** code
`b20b04fad` (batches 1–5, the ladder's fixes, VM-55's re-land). **Record:** `notes/plans/vm-47-sizes-and-look.md` — §3 "One
walk for the whole run" (the brief), §4 rows W.0–W.8 (LIVE STATUS), §5 (the PROVISIONAL calls this walk looks at).

## FOR A LATER READER

PENDING — written when both parts are read (what was seen, what was this run's and was fixed, what is another ticket's,
what is hers).

## How the walk runs

- **Instruments** (gitignored, never committed): `notes/plans/vm-47-screens/instruments/VM47FinalWalkDriver.swift` (class
  `VM47FinalWalk`; its header names every capture and every label it looks up) and `walkfinal.zsh` (the runbook; its header
  is the plan). They supersede the four unrun pairs beside them (`walk*.zsh`, `VM47Walk*Driver.swift`).
- **Device:** `vm47-walk` (iPhone 17 Pro, iOS 26.2), created by part A, kept shut down across the seam, deleted at part B's
  end. A fresh simulator dev store (Debug build), signed out, never synced; the words card on the first launch is pressed
  through and never captured.
- **Captures:** `notes/plans/vm-47-screens/final/` (gitignored), named `<palette>-<voice>-<appearance>-<default|ax5>--<step>-<what>.png`;
  per-step contact sheets in `final/sheets/` (`walk_sheets`), full-size bands in `final/crops/` (`walk_crop`).
- **Part A** (expected 99): the seed (s0–s2); the core under the sea-glass as a fresh library reads it (no palette written)
  × Study/Terminal × light/dark × default/AX5 — k1–k3 Settings top to bottom as the voice is written, k0 the ⋯ open, c1 the
  Bookcase at rest, c2 the box focused, c3 the Library, c4 search typed and its results, c5 a note in Write; at the default
  size also the paper check c6 (take tint), c7 (a callout's wash and the comment mark), c8 (caret), c9 (selection wash).
- **Part B** (expected 182), most important first: the core under teal & rust (Study light and dark, default, with the paper
  check); Settings' flows (s01–s14, Study light default and Terminal dark default); the bar's roads and VM-55's faces
  (b1–b13, w1–w3, m1–m3, the same two combinations); VM-54's flip (f1–f6, once per voice); the wider pass (r01–r17b) at
  Study light default, Terminal dark default and Study light AX5.
- **Not reachable / not capturable:** the sync row's doored states (VM-27 — the store never syncs; its mounted pin
  `MobileSettingsProtectionDoorTests` is that evidence); Display Zoom 320 pt (P-47-7 — simctl cannot set it; the geometry
  pins are its evidence); a second wing (the phone has no wing management — the wing list shows Home alone); the lobby's
  placeholder look (P-47-15 — the only lobby face this store shows is the words card, never captured).

**The standard every capture is judged against:** the sizing sheet (`notes/plans/vm-44/design/sketches/sizing-sheet.html`)
— the grounds (her prose and lists on the paper; bars, sheets and section bands on the room; dark: the room black, the paper
carries the hue), §A the type roles (13 · 15 · 17 · 20 · 24; nothing under 13; Terminal's prose two under), §B the touch
rule (44 × 44; the tab cell a third × ≥ 56), §C spacing and row heights, §D the two corrected inks (muted ≥ 4.5:1, faint
≥ 3:1; faint never a sentence), §E the core components (sheet header, menu row, chip, receipt line, tab bar), and the token
values.

**Classification of a finding:** THIS RUN'S DEFECT (fixed narrowly after the part's claim is released, a test where one can
hold it, a commit per fix with the mechanism, re-captured) · ANOTHER TICKET'S (named from the record's inventories or
`notes/TICKETS.md`) · A QUESTION FOR HER (the record's §5, with the capture ids). Hard lines for a fix: no edit to
`Shared/Theme/VoiceTokens.swift`, `MobileEditorTextView.swift`, `MobileEditorViewModel.swift`, `Shared/EditorBrain/` or
`Sources/`; the Mac's look unchanged; no rendered word changed; VM-55's behaviour and words unchanged.

## Screen by screen

Each row: the captures (step ids; A = part A's eight combinations unless named), what the batches asked the walk to check
there, what is seen, and the verdict. "Seen" and "Verdict" are PENDING until the part's captures are read.

| # | Screen | Captures | What to look at | Seen | Verdict |
|---|---|---|---|---|---|
| 1 | The seed | s0 s1 s2 | the pocket guide on the Bookcase's stack; the fanned lesson with a saved version and a comment; the Library after | PENDING | PENDING |
| 2 | Bookcase at rest | c1 (A ×8; B teal ×2) | ONE path line: the wing door "Home · Shelf · N books" / "~/home/shelf · N books", 🗑, + New Note (15), ⋯ — every target 44, what truncates in Terminal (P-47-9, P-47-27); the page word "Shelf" under the tab "Bookcase" (P-47-28); books on the paper (R-47-1); row names 17 / meta 13, Terminal two under (P-47-4); the box's hint on one line at the note body size (P-47-6, batch 1); the bar: the chip on Bookcase, the others corrected muted, ≥ 56, the hairline, the room to the home indicator (P-47-21); nothing under 13 pt | PENDING | PENDING |
| 3 | Bookcase, the box focused | c2 | the box open at the body size; the keyboard; the bar above it (P-47-21's keyboard note — VM-73's row) | PENDING | PENDING |
| 4 | The ⋯ menu on a root | k0 (A ×8), s01, s02 | the system menu at the ⋯ (P-47-22); "Settings" voiced; the glyph in the accent, 44 × 44 | PENDING | PENDING |
| 5 | Settings, top to bottom | k1 k2 k3 (A ×8), s03, r16 | the sheet header (muted path title, Done semibold — P-47-13); groups named on the room, rows on the paper, hairlines from the gutter; Look: the voice choice and the appearance choice in the Mac's words, no line beneath (P-47-24, P-47-25, P-47-26); the ONE Protection door (VM-27); the sync row's doors 44; scrolls and nothing clips at AX5, Terminal included | PENDING | PENDING |
| 6 | Library | c3 | rows on the paper; the field's surround, the filter row and the path line on the room; the five filter words at 13, 44 tall, the sort glyph (P-47-7, P-47-10); the wing door "Home · Library"; the chip on Library | PENDING | PENDING |
| 7 | Library search | c4, c4-results | the field's typed text (control 17 — P-47-14: grows to xxxLarge and holds, so AX5 = xxxLarge); hit rows on the paper | PENDING | PENDING |
| 8 | A note in Write | c5 (A ×8; B teal ×2), s08, s14, b6 | the masthead on the paper (P-47-17): title 24 (Terminal 22) at true size, the four tools as 22 pt glyphs in ink with touching 44 pt areas, the membership chip, the five chips 44 tall (P-47-12); her prose 17/27 (Terminal 15/25) on the paper (P-47-16); no bar | PENDING | PENDING |
| 9 | The paper checks | c6 c7 c8 c9 (A ×4 default; B teal ×2) | on the paper, light and dark, two palettes: the take tint (a peek, the pill), a callout's wash, the comment mark, the caret, the selection wash (piece 3.10) | PENDING | PENDING |
| 10 | The core under teal & rust | B: c1–c9, k0–k3 at Study light and dark | the inks under a palette (P-47-5 — teal & rust's dark card is the hardest); her words on the paper, chrome on the palette's room | PENDING | PENDING |
| 11 | Settings: the voice flipped | s04 s05 (B ×2) | R-47-2: the choice writes the library's voice — the sheet re-voices at once, the Bookcase behind it follows | PENDING | PENDING |
| 12 | Settings: the appearance | s06–s11 (B ×2) | this phone's choice reaching the sheet, a root, the UIKit editor and a UIKit overlay; the simulator's own word; Follow system | PENDING | PENDING |
| 13 | A note's door to Settings | s12 s13 s14 (B ×2) | the note's ⋯ sheet with its Settings row (44); Settings over the note; Done back on the note | PENDING | PENDING |
| 14 | Protection | s03b s03c, b13, r17 r17b | on the VISIBLE stack (from the Library — P-47-23); no bar (P-47-18); its top edge (P-47-20) | PENDING | PENDING |
| 15 | The bar on pushed lists | b1, b4, b8, b12, r02, r14, r15 | the bar on the room under a paper page; the chip on the owning tab; each top edge (W-009, P-47-20) | PENDING | PENDING |
| 16 | A tab tapped from a pushed list | b2 b3 b7 b10 b11 | each lands on a ROOT; the stack left is back at its root (P-47-19) | PENDING | PENDING |
| 17 | No bar | b5 (Read), b6 (a note), b9 (a moment read), b13 (Protection) | P-47-18 | PENDING | PENDING |
| 18 | The wing door's list | w1 w2 w3 (B ×2) | VM-55's face on this run's layer: the sheet header, rows at 17 in ink, the ✓ at 13 in the accent (P-47-8); a pick lands on the Bookcase | PENDING | PENDING |
| 19 | The one message line | m1 m2 m3 (B ×2) | the receipt line (sheet §E): one line 44 tall, words 15 corrected muted, Undo 15 semibold in the accent with a 44 pt area, on the room with the hairline; clear of the bar on a root (m1) and on a pushed list (m2 — meeting 2); after Undo the note is back (m3) | PENDING | PENDING |
| 20 | VM-54's flip | f1–f6 (B ×2 voices) | after light → dark with the surface on screen: the take cards' edges, the comment draft's edge, the pill's edge in the dark colours | PENDING | PENDING |
| 21 | Starred | r01 (B ×3) | the ★ in its own token (blue) on a note and a book; rows on the paper; "Home · Starred" + ⋯; the chip on Starred | PENDING | PENDING |
| 22 | A book's contents | r02, b4 | the name 20; rows; the system bar with Details · Read (P-47-20); the bar | PENDING | PENDING |
| 23 | Book Details | r03 | the sheet header; the menu rows | PENDING | PENDING |
| 24 | A book's Read page | r04 r04b, b5 | the cream page (voice-independent), the voice's own room around it; serif 17/27, titles 25/21, page meta 13 (its own ink, recorded at batch 1) | PENDING | PENDING |
| 25 | Create Book | r05 r05b | the header with Cancel (P-47-13); the name field; the kind's segmented choice (segments sized by their words); the calm button | PENDING | PENDING |
| 26 | The note's sheets | r06 r06b r06c r07 r07b r08 | Tags (the field), membership, More Info, Blocks (its segmented choice), Lenses: one family — header, Done, fields, rows, inline acts | PENDING | PENDING |
| 27 | Note Actions | r09, s12 | menu rows 64 with detail lines, the Settings row 44, Delete in the alarm | PENDING | PENDING |
| 28 | Versions | r10, b8, b9 | the listing (the bar), the reader (no bar), the "‹ Versions" door | PENDING | PENDING |
| 29 | The three UIKit overlays | r11 r12 r13 | hit areas only (structure is VM-152's); at AX5 how the fixed frames hold (VM-152) | PENDING | PENDING |
| 30 | Trash | r14 r14b, b1, m2 | the filter chips in a sideways row, the chosen one on the wash (P-47-11); row acts | PENDING | PENDING |
| 31 | Archived | r15, b12 | the room and its promise; the bar | PENDING | PENDING |

## Which PROVISIONAL calls each part shows

- **Part A:** P-47-1 (the sheet's numbers, as a set), P-47-4, P-47-5 (dark), P-47-6, P-47-7, P-47-8 (batch 1's role map),
  P-47-9, P-47-10, P-47-12, P-47-13 (Settings' header), P-47-14, P-47-16, P-47-17, P-47-21, P-47-22, P-47-24, P-47-25,
  P-47-26, P-47-27, P-47-28; R-47-1 and R-47-2 as built.
- **Part B:** P-47-5 (teal & rust's dark card), P-47-8 (VM-55's faces), P-47-11, P-47-13 (Create Book's Cancel), P-47-14 (the
  tag field), P-47-16 and P-47-17 under a second palette, P-47-18, P-47-19, P-47-20, P-47-21 (on pushed lists), P-47-22 (on
  Starred and the Library), P-47-23, P-47-27 (the wing door's line in both voices), VM-54's flip.
- **Not shown:** P-47-15 (the lobby — never captured), P-47-7's Terminal-320 case (Display Zoom), VM-27's doored states.

## Findings

PENDING — each with its captures and its class.
