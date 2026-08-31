# The Library filter batch — KIND FILTERS + THE ARCHIVE'S INHERITED SET
*(brief; written 2026-08-31 by the Fable orchestrator; her rulings at
QUESTIONS #85 and #92)*

**Her rulings, binding:**
- **#85 (2026-08-30, verbatim):** *"Archived is a comparatively rare
  option, and it needs the same filters that the regular library has. the
  mockup only had bookless and scraps but those are less useful than
  'books' 'posts', etc. so I'd want to see that kind of sorting on the
  library, which is more important because it's where you see
  everything."*
- **#92(a) (2026-08-31):** the "books" filter lists **BOOKS AS ROWS** —
  the Library becomes the true everything-surface: her books themselves as
  openable rows; "posts" lists notes; scraps stays.
- **#92(b):** the width budget gives at the **SORT — it shrinks to a
  glyph**; everything stays on one visible row (she declined horizontal
  scrolling, moving sort to the search row, and measure-first).

**Read in full, yourself:** `CLAUDE.md` · `notes/MobileSoul.md` §2–§4 ·
`notes/QUESTIONS.md` #85/#92 · `notes/plans/mobile-batch-6c-record.md` +
`-cold-review.md` (the rooms this lands on; the Archive was shaped for
this row) · the code: `MobileLibraryView.swift` (`filterRow`,
`filterDoor`, the sort menu and its `.all`-only rule),
`MobileLibraryViewModel.swift` (`Filter`), `MobileArchiveView/Model`
(6c's), `MobileShelfView/Faces` (the book-row rendering brain you will
REUSE, never fork), `MobileBookView` (where a book row opens), and the
`Queries` the listings read.

## Deliverables

1. **THE ONE FILTER BRAIN.** One phone component (declaration + renderer)
   serving BOTH the Library and the Archive room — her §10.2 note's
   letter: "one filter brain, not two". Phone-local is correct here (the
   Mac's sidebar is a different mechanism; no Mac twin exists — not a
   MobileSoul §3 hoist case; say so in the record).
2. **THE LIBRARY'S VOCABULARY.** The row gains the kind doors:
   **books · notes** joining **all · bookless · scraps**. Two calls
   inside this, both PROVISIONAL (log them):
   - **The door says "notes", not "posts"** — the 13f K5 sweep renamed
     post→note in ALL UI strings (the model keeps `post`); her #85 said
     "posts" while describing kinds, and shipping the app's own UI noun is
     the K5-consistent reading. One string if she re-words.
   - **`bookless` stays as a door** — she called the provenance filters
     "less useful", not wrong; removing a shipped door is a bigger act
     than adding the kind doors. If the row cannot fit at the widths below,
     STOP AND REPORT with measurements rather than dropping a door
     (door-count changes are hers — the R22/R25 precedent).
3. **BOOKS AS ROWS (#92(a)).** Filtering to books lists her books as
   openable rows — name + the Shelf's meta through the EXISTING
   `MobileShelfFaces` brain (reuse; never a second row-rendering rule),
   opening into the book exactly as the Shelf's rows do. The listing reads
   the same core query the Shelf reads (windowed if the Shelf's is; a
   book list past the window shows the standing truncation marker). The
   sort question for book rows: the sort control renders only on `.all`
   today — keep that availability rule (sort stays a `.all` affordance;
   the books listing orders as the Shelf orders). PROVISIONAL; log it.
4. **THE SORT GLYPH (#92(b)).** The sort menu's door becomes a compact
   glyph (an icon door with an accessibility label carrying the full
   verb), same menu behind it, same `.all`-only availability rule.
   **Measure the finished row** at 320 (Display Zoom) · 375 · 402 pt and
   at AX sizes, on the real mounted surface — the design record's flagged
   risk is width, and the proof is frames-in-bounds plus no clipped door
   (the 4.5d discipline: assert `bounds.width == barWidth`-class facts,
   never constants against themselves).
5. **THE ARCHIVE INHERITS THE SET — with a MODEL FACT to verify first.**
   Her #85: the Archive gets the same filters. **Verify at the schema:
   `reading` carries NO `archived_at`** (AppSpec §7 — readings finish and
   delete; they do not archive), so an Archive "books" door would be a
   door that can never have content — the P-2 class. The adjudicated
   shape: the Archive room renders the SAME component with the doors
   whose kind CAN exist there (archived notes; verify whether archived
   scraps/pool blocks list in this room or only in per-note surfaces —
   the Mac's Archived is NOTES only, the post-13l ruling — and match it),
   and the record states the model fact + logs the gap as a QUESTIONS
   candidate for her (if she ever wants book-archiving, that is a schema
   event and nobody's to improvise). If your reading of the schema
   differs, STOP AND REPORT rather than inventing an archived-books
   surface.
6. **NOT THIS BATCH:** the per-note tray (6b, briefed separately); any
   `Sources/`, `App/Variorum/Shared/`, `App/Variorum/Variorum/`,
   `EditorBrain/`, schema, or build-config change — the kind filters are
   FACES over existing core queries; if a needed query does not exist in
   core, STOP AND REPORT (a new core query is a fenced change this batch
   must not make).

## Pins & discipline

Real mounted surfaces for every door; the sort glyph driven (menu opens,
a sort applies); books rows driven (a tap reaches the book); the Archive's
component driven with its reduced door set asserted (and asserted AGAINST
doors that cannot act — no empty "books" door renders there); width
measurements pinned at the three widths with real frames; P1: every
listing windowed + marker; red-on-old for any bug-class fix; PROVISIONALs
(the "notes" noun · bookless-stays · the sort availability rule · the
Archive's reduced set) in `notes/plans/mobile-batch-filters-record.md`,
written as you go.

## Environment (binding)

The standing block: own simulator (iPhone 17 family, newest iOS 26
runtime; 16-series sims are iOS 18.3, invalid), armed
`ApplicationAccessibilityEnabled`, private `-derivedDataPath`, simulator
deleted at the end; full mobile suite at the end — **the baseline is the
FIX WAVE RESULTS final line in `notes/plans/mobile-batch-6c-cold-review.md`**
(read it; quote your own line); never sweep `Package.resolved`; never
touch the real store; never quit the live Mac app; no Release builds,
installs, or pushes; pathspec-limited commits with the standing trailer.
R28: your cold review dispatches from your report.
