# VM-44 — the Great Mobile Catch-up: the plan

**Ticket: VM-44 (team VM) · Project: Mobile — the catch-up & launch · Branch: `vm-44-mobile-catchup` ·
Worktree: `~/dev/variorum-vm-44`**

**Status: APPROVED by the author, 2026-11-15** — "22 is fine, composition is fine." (and, on the one ordering
question put to her: "writing in wave 3 is fine."). This file is the approved composition: 22 umbrellas in six
waves. Each umbrella is one Linear umbrella ticket in team VM with 5–10 member tickets; the wave an umbrella
belongs to is said here and in the umbrella's description, nowhere else.

The record this plan stands on is `notes/plans/vm-44/` (README first): her words (`her-words.md`), her rulings
sorted by surface (`plans/sitting-1-rulings.md`), the work list whose row ids (W-001 … W-263) are cited below
(`plans/master-work-list.md`), the dependency notes, the seven audits, and the mockups
(`design/mockups/*.html`, drawn on `design/sketches/sizing-sheet.html`).

## The rules every umbrella inherits

- **Her rulings govern** (`plans/sitting-1-rulings.md`); where they are silent, options go to her, nothing is
  invented. The look is the Mac's — Study, sea-glass — at phone-right sizes; words are short and plain; no line
  for ordinary acts, a line with Undo only when something leaves the page, and for refusals.
- **Brains live in Core or `Shared/`; the phone owns faces** (MobileSoul §3). A row whose brain is still in
  Mac-app code hoists it first (`plans/dependency-notes.md` §2 lists who waits on which hoist).
- **Each umbrella runs as a RUN** under CLAUDE.md's phase rules: one branch and PR per umbrella, pin before
  fix per member, the cold review over the whole diff; a Fable cold review wherever the diff touches the editor
  seam, custody or `Sync/`.
- **One protection-or-sync umbrella per wave** (marked ⚑ below), and the umbrellas of one wave keep out of each
  other's files (`plans/dependency-notes.md` §5); where two must touch one file, the wave's coordinator
  serializes their merges.
- **Evidence:** every umbrella closes on use-shaped evidence on her phone or a simulator walk, never on a pin
  alone. From wave 1 on, the timing readout (umbrella 3) is run before and after anything that claims to be
  faster.
- **Mockups are the starting point, not a pixel contract**; each member ticket names its mockup file. Lines of
  copy that are drafts (`design/wording-list-*.md`) wait for her wording pass before they ship.

## Wave 1 — foundations

| # | Umbrella | Work-list rows | Mockups |
|---|---|---|---|
| 1 | **Sizes and look** — the phone type layer (13 · 15 · 17 · 20 · 24) over the shared tokens, spacing and 44 pt targets, one set of controls, the palette and voice following her library, the tab bar, Settings as a scrolling grouped list | 001 002 003 004 005 006 007 008 009 024 172 211 213 217 | sizing-sheet · lock-and-protection (Settings) · home-wings-capture (the bar) |
| 2 | **Wings underneath** — the phone remembers its wing; every listing scoped to it; new things born in it; the wing-blind pickers fixed; the one message line and refusals in words; the tag manager per wing | 012 013 015 016 019 033 034 035 229 | home-wings-capture · library-and-search |
| 3 | **Timing and the two lags** ⚑ — timing markers and a readout FIRST (the markers at tap on the capture box, keyboard up, file, note on screen, unlock, library ready; run on her phone before any fix); then the launch scan, the Library's re-reading on every write and its paging, notes read twice on open, the unreleased editor models, the leaving savepoint work, the keystroke-during-divide corruption | 254 238 239 240 037 243 247 249 124 | — (audit F) |
| 4 | **Fixes to what's there** — restores keep the replaced words; the undo door; Finish asks before dismissing arrivals and its captions; the tutorial's retired lesson; "gathering" not "smart"; books sort; the retired pin door; small dead ends; the red tests | 181 145 146 105 106 218 073 068 071 057 092 110 120 147 161 258 259 | a-book (the Finish confirm) |

## Wave 2 — the shell

| # | Umbrella | Work-list rows | Mockups |
|---|---|---|---|
| 5 | **Home, wings and capture** — the wing title swipe and dropdown, the app following a note's wing, wing management behind a ⋯, the Bookcase-first home, the capture box (several paragraphs, File and Open, the helper keys, a way to put the keyboard away, where a note lands), the Today button, visible doors for long-press acts | 010 017 018 020 021 022 023 025 026 027 107 162 241 242 + the capture keyboard's dismissal (her report) | home-wings-capture |
| 6 | **The Library** — rows with a preview, stamps, sort and the day filter, one row anatomy, the row menu (archive, duplicate, move or copy to wing), multi-select, the room names, the Starred page | 032 036 038 039 040 041 042 043 045 046 047 048 049 050 051 053 054 | library-and-search |
| 7 | **Trash, Archived, Snippets, tags** — Snippets with view, add, edit, delete; archived books' home; the two sweeps; Undo after deleting a tag and counts in the tag list; move a block to Snippets | 052 055 056 117 122 142 230 231 | trash-archive-tags · library-and-search (Snippets) |
| 8 | **The lock** ⚑ — the probe of what iOS tells the app when the phone locks, FIRST; the library stays open in the background for the dial's minutes and a full close locks; the dial; the lock icon on the home screen; "back to where I was" after an unlock; leaving Castle from the phone; the stale session after a re-lock; the backup exclusion; the words card out of the app switcher | 028 187 188 189 190 191 193 198 199 200 203 204 208 | lock-and-protection · home-wings-capture (the icon) |

## Wave 3 — books and writing

| # | Umbrella | Work-list rows | Mockups |
|---|---|---|---|
| 9 | **The Bookcase** — shelves as a chip row, full shelf management behind a ⋯, one book menu, the new-book sheet, archive and duplicate a book, move a book to a wing, the Welcome shelf | 067 069 070 072 100 116 118 119 121 | a-book · home-wings-capture |
| 10 | **Inside a book** — contents rows, chapters, pins, reorder, the journal's dated entries and "+ New entry", a new note in a gathering, the book strip at a note's foot, Read opening at the tapped block | 076 077 078 079 080 081 082 083 084 085 086 087 088 089 090 091 123 | a-book |
| 11 | **Search** — full-text search over the index the phone already keeps, the matching passage, facets, tag narrowing, the order door, the all-wings switch (the Mac's twin is VX-987), landing at the block | 059 060 061 062 063 064 | library-and-search |
| 12 | **Writing** (the editor seam) — Return makes a block and backspace joins, the one capsule and its quick row (Undo, Redo, Comment, Commit), the formatting strip as a setting, block acts with the keyboard down, merge with next, paste as plain text, quotes and spelling like the Mac | 125 126 127 128 129 130 131 134 135 136 138 140 | note-write · sketches/LK-4-LK-3-keyboard-bar |

## Wave 4 — depth

| # | Umbrella | Work-list rows | Mockups |
|---|---|---|---|
| 13 | **The note's top and sheets** — the masthead, the note's menu, rename and title quickfill, a real date picker and the day shift, Seal, word count and target, native sheets, the blocks list with reorder and its bulk bar, the tray, seams and the editing indicator, find, long-note jumps, the writing and document settings | 132 133 139 141 144 148 149 150 151 152 153 154 155 157 158 164 171 212 | note-write · sketches/NT-5-history-and-commit |
| 14 | **Book settings, rules and states** — one settings sheet with the Collecting sentences, the simple rule editor, the outflow and the dials, the word target and note limit, Seal, Own and its two delete choices, the membership choice sheet, the badge family, bind and spawn | 074 093 094 095 096 097 098 099 108 109 112 113 114 115 | a-book |
| 15 | **Arrivals** — the count, the full-screen review with why-it-waits, judging in bulk, copy in or move in on a waiting row, archived waiters, Manage notes | 101 102 103 104 111 | arrivals |
| 16 | **Speed, second pass** ⚑ — what the timing numbers rank: typing in long notes, fanned-block layout, the sync aftershock, mounted editors, the purge janitor, the slow rounds | 210 244 245 246 248 250 251 252 253 | — (audit F) |

## Wave 5 — the rest of v1

| # | Umbrella | Work-list rows | Mockups |
|---|---|---|---|
| 17 | **Takes, commits and history** — the visible badge and the foot pill, the takes sheet's acts, naming a commit, bring back as a take, the History and lineage sheet | 174 175 176 179 180 182 183 184 185 | takes-and-history |
| 18 | **Comments and callouts** — the sheet with the keyboard up, the unsent draft, deleted comments and Delete forever, the marks, the callout chooser | 165 166 167 168 169 170 | comments-and-callouts |
| 19 | **First run and joining** ⚑ — the calm first open with the band cards, the passphrase asks, "I already use Variorum" in the welcome card and the one-sheet join, sync state in view, the launch seed set and its restore doors, a door on the Mac pointing at the phone app | 194 195 196 201 202 223 224 225 227 228 | first-run-and-joining |
| 20 | **Export and share** — Copy, export a note (which file), a book, the library, the unencrypted copy; the Private eye; Copy for AI | 058 156 232 233 234 235 236 | export-and-share |

## Wave 6 — launch

| # | Umbrella | Work-list rows | Mockups |
|---|---|---|---|
| 21 | **The pocket guide and the tour** — the guide rewritten for the phone as a seeded book (her wording pass), the short tour as band cards, re-enterable from Help | 219 220 221 222 | first-run-and-joining |
| 22 | **Launch readiness** — the VoiceOver and text-size audit, haptics, in-app crash reporting, What's New, the privacy manifest and export-compliance key, build stamping and TestFlight, the device queue, the leftovers | 011 014 173 214 216 226 255 256 257 260 261 262 263 | lock-and-protection (Settings rows) |

## After v1 (not scheduled here)

Compare — two takes first (W-177), then notes as tabs lined up block by block (W-186;
`design/mockups/compare-concept.html`) · import through Files (W-237) · capture from outside the app (W-029) ·
Settings search (W-215) · the library doors (W-206, W-207) · syncing while the app is closed (W-205) · a book's
Index and paged reader (W-075) · a single note's Read mode and mode row (W-159, W-160) · the Timeline (W-044) ·
search inside a book (W-065) · the lens-aware takes filter (W-178) · a book as a folder of notes (VX-1000).

## Rows closed without a ticket

Done in the sitting: W-030, W-031 (VM-46), W-209 (VM-45). Ruled away: W-066 (no command palette; search is the
one finder), W-137 (one divide default), W-143 (block tags are VX-128's question, not the phone's), W-163 (the
Debug oracle stays the only belt), W-192 (the app switcher shows the page as today), W-197 (no Copy door for
the twelve words).

## Canon deltas owed at this plan's merge

- `notes/MobileSoul.md`: Compare reopened for after v1 (§4.5's exclusion); the phone's reading of the re-lock
  rule (open in the background for the dial's minutes; a full close locks); the retired worktree line.
- `notes/SurfaceContracts.md`: none yet — the phone's surfaces enter it as each umbrella ships them.

## The tickets

Minted from this plan; each umbrella's members are listed in `notes/plans/vm-44/plans/minted/`.
