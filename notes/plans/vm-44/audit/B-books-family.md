# VM-44 audit — reader B: the Bookcase and the books family

Read-only audit of `~/dev/variorum` at `main` 5dde1bcf9 (2026-11-12). The Mac's contract is `notes/SurfaceContracts.md` "The Bookcase and books" (its twelve bullets are cited as **SC-B1…SC-B12** in order: B1 Bookcase · B2 Arrivals · B3 Book Panel · B4 wing switcher · B5 book settings sheet · B6 membership choice sheet · B7 Delete/Archive/Duplicate/Trash/New Book · B8 badge family · B9 Private mark · B10 Outline follows · B11 the book's mode row · B12 pinned notes) and AppSpec §9 "Readings, intake, ownership".

**Path shorthand:** `P/` = `App/Variorum/VariorumMobile/Features/` · `S/` = `App/Variorum/Shared/` · `M/` = `App/Variorum/Variorum/` · `C/` = `Sources/VariorumCore/`.
**Evidence tags:** **V** = VERIFIED (I read the code; file:line given) · **I** = INFERRED (the basis is stated).
**Brain column:** Core · Shared · **Mac-local (hoist owed)**. Where a Mac face's words or pure rule live in `M/`, the phone can't reuse them until they're hoisted (MobileSoul §3).

---

## 0. The headline, in eight lines

1. **The phone has no Bookcase. It has a single flat list of every book from every wing.** No shelves, no strip, no solo/All, no Unshelved, no Welcome, no census, no order menu. `Queries.bookshelf(db)` is called with no wing, so all nine of her wings' books land in one list (V: `P/Shell/MobileShelfViewModel.swift:62-68`; `C/Queries/ShelfQueries.swift:57,101-107`). The shared brain that would drive the real Bookcase, `S/BookcaseBoard.swift`, is never used by the phone.
2. **Arrivals have no face at all, and they pile up invisibly.** The phone has no masthead door, no review, no count on a book row (it never reads `ShelfBook.arrivalCount`), no why-it-waits and no seat or dismiss. Every arrival from intake (her own phone tags and stars), from the daily Journal's `waitingAtDoor`, or from an AI client's `propose_notes_to_book` (it syncs in) is invisible on the phone (V: a grep for `arrival`, `seatArrival` and `dismissArrival` in `VariorumMobile/` finds only editor comments).
3. **Finish on the phone silently throws arrivals away.** Book Details' Finish acts with no confirm (`P/Shell/MobileBookDetails.swift:111-116`). But `lockReading` dismisses every pending arrival inside its transaction (AppSpec §9), and the Mac asks first whenever N > 0 (SC-B5). So on the phone she can make judgments, which are permanent, about arrivals she never saw.
4. **The 13i state family is missing.** There's no Seal, no Own, no outflow, no rule editor, no Collecting sentences, no membership choice sheet, no Duplicate, no two-choice delete, no badges, and no archive for any book except the daily Journal. Archived books can't be seen at all: the Archived room's books group returns `[]` (`P/Shell/MobileArchiveModel.swift:81`).
5. **Several existing faces follow retired rules.** Some examples:
   - "Pin to Shelf Top" and "Star" both appear on one book row, but both write the one union star (`P/Shell/MobileShelfView.swift:317-330` → `C/Operations/Operations+Appearance.swift:242-244`).
   - Gatherings are called "smart" or "Smart Book" everywhere.
   - The Finish caption says it "freezes its notes", but a finished book's text stays editable (AppSpec §7).
   - The daily Journal offers only Archive, never Delete (VX-436 was Mac-first).
   - The Today door's notes say "reopen it" on a sealed Journal, where Reopen refuses.
   - The starter entry says "One day, one entry.", but VX-797 allows several entries a day.
6. **Two refusals reach her as raw enum dumps.** Finish on a gathering ends in `wrongReadingKind`, and Reopen on a sealed book ends in `readingSealed`. Both fall through `DeletionRefusal.fallback` and render as "That couldn't be done — wrongReadingKind(…)." (V: `P/Shell/MobileBookDetails.swift:192-196,211-216` → `S/RecoveryActs.swift:194-246`).
7. **Wing-blind pickers produce wrong outcomes.**
   - The Smart Book tag picker lists every wing's tags (`allTags(db)`), but the book is minted in Home. A tag that exists only in another wing becomes a dead rule term (V: `P/Shell/MobileCreateBook.swift:58-64,145-153` → `C/Operations/Operations+Reading.swift` `normalizedRuleSpec`).
   - The note's "Add to a book" list shows every wing's books. Picking one from another wing refuses with "move the note here first", and the phone has no way to do that (V: `P/Write/MobileMembership.swift:88-104` → `S/OpsRefusalTable.swift:352-354`).
8. **Most Mac face brains for this family are Mac-local.** `CollectingCopy`, `BookStateDoorSet`, `BookArchiveDoorSet`, `BookStateCopy` (which includes `deleteVerb(kind)`, which PL-62 wrongly calls shared), `MembershipChoiceCopy`, `ArrivalsCopy`, `ArrivalsReviewCopy`, the pure `ArrivalsBulk`, `OwnershipBadgeCopy`, `DuplicateBookCopy`, `RuleEditorCopy`/`RuleEditorModel`, `ArchivedLineCopy`, `JournalBooks.shelvingNote`/`comesBackReceipt`, `BookRowMenu`'s table and `postDropPlan` all live under `M/`. The ops are all in core, so the catch-up is mostly faces plus hoists. The phone already keeps one forked copy (`MobileTodayDoor.shelvingNote`), and it is already stale.

---

## 1. Gap matrix

Status key: PRESENT · PARTIAL · STALE · ABSENT · RULED-EXCLUDED. Sizes are S, M or L for the face work, including any hoist named.

### A. The Bookcase (the phone's "Shelf" tab)

| # | Capability | Mac (contract pointer) | Phone status | Phone file(s) | Brain | Ticket / ledger | Size | Note |
|---|---|---|---|---|---|---|---|---|
| A1 | Books home: one listing of a wing's books | SC-B1; `S/BookcaseBoard.swift` | PARTIAL | `P/Shell/MobileShelfView.swift:191-220`; `MobileShelfViewModel.swift:62-79` | Core `Queries.bookshelf` + Shared `BookcaseBoard` (unused by phone) | PL-45; VM-6 (4a) | M | V: a flat list of book rows, then `+ New Book`, then the Today fallback row, inside a scroll region capped at ~8 rows (`MobileShelfLayout`). |
| A2 | Bookcase scoped to ONE wing | SC-B4 ("the whole surface re-scopes per wing"); `bookshelf(_:wingID:)` | ABSENT | `MobileShelfViewModel.swift:66` | Core | PL-45; VM-6 (4a); her words "no different wings (!!)" | M (after the shell's wing switcher) | V: `wingID` nil means the all-wings read (`C/Queries/ShelfQueries.swift:101-107`). I: same-name books in two wings both list with nothing to tell them apart (cross-wing twins are legal since VX-816). |
| A3 | Shelf strip: starred shelf leading, solo / All, ⋯ overflow filter | SC-B1 | ABSENT | — | Shared `BookcaseBoard` (`BookcaseScope`); core `shelf` rows | PL-45; VM-6 (4a) | L | V: no phone code reads or writes a `shelf` row (`createShelf`, `setReadingShelf` etc. have 0 call sites). Shape is open question Q1. |
| A4 | Unshelved at the top of All under its own collapsible header; Welcome holds the seeded content | SC-B1 | ABSENT | — | Shared `BookcaseBoard` | PL-45 | (in A3) | V. |
| A5 | Order: a–z (digit-aware, the default) or last edited; starred float first; "my order" stepped back | SC-B1 §24; `S/BookcaseBoard.swift:31-43` | STALE | `S/ShelfOrder.swift:39-54` via `P/Shell/MobileShelfFaces.swift:117-121` | Shared (both rules exist; the phone uses the retired one) | PL-45 | S | V: phone order is starred (NOCASE) → journal-trait books → the rest. Sorting uses case-sensitive `<` and isn't digit-aware ("Zebra" before "apple", "Book 10" before "Book 2"). There's no order menu. |
| A6 | № census popover with solo filters (books, gatherings, finished, owned, living, with arrivals) | SC-B1 | ABSENT | — | Shared `BookcaseBoard` | PL-45 | M | V. The path line's "Shelf · N books" counts gatherings as books (`MobileShelfView.swift:227`). |
| A7 | The `details` switch (hide row meta and arrival counts) | SC-B1 | ABSENT | — | Shared | PL-45 | S | Low value on a phone; a design call. |
| A8 | Honest row counts ("N notes · M archived") | SC-B1 | PARTIAL | `MobileShelfFaces.swift:70-88` | Core | PL-45 | S | V: shows "N notes / entries" with no archived count. Gatherings say "smart" (A9). |
| A9 | The gathering's word ("gathering", never "smart") | AppSpec §7 `reading.kind`; SC-B1/B7 | STALE | `MobileShelfFaces.swift:74-76`; also `P/Write/MobileMembership.swift:277-283`, `MobileCreateBook.swift:263-281` | phone-local | PL-62 (a) | S | V: "smart" on shelf rows, in the membership sheet and in the create sheet. |
| A10 | Arrival count on a book row | SC-B1 (census "with arrivals"); `C/Queries/ShelfQueries.swift:17-21` | ABSENT | `MobileShelfView.swift:266-351` | Core (already delivered in `ShelfBook.arrivalCount`) | PL-45; VM-42 | S | V: the phone never reads `arrivalCount`. |
| A11 | Star mark on starred book rows; the virtual starred shelf (books only, drop to star) | SC-B1 | PARTIAL | `MobileShelfView.swift:282-296` | Shared `BookcaseBoard.starred` | PL-45; PL-63 | S | V: starred books float to the top but wear no ★, so the float is unexplained. The phone's separate Starred page lists notes and books. |
| A12 | Shelf ops: create, rename, Set Glyph, Make Default, Delete (books go to unshelved), reorder | SC-B1; `C/Operations/Operations+Shelf.swift` | ABSENT | — | Core ops | PL-45 | M | V: 0 call sites. Q9. |
| A13 | Move a book to a shelf; the context mint lands on the solo'd shelf (`createReading(shelfId:)`) | SC-B1; AppSpec §9 Bookcase ops | ABSENT | `MobileCreateBook.swift:129-154` | Core | PL-45 | S | V: create passes no `shelfId`. |
| A14 | Book-row drag, drop outlines, false-offer rule | SC-B1 | ABSENT | — | — | — | — | Any iOS drag needs a named coordinate space (MobileSoul §5.9). Menus may serve the phone instead (a design call). |
| A15 | The book row menu as ONE registry table (VX-829): Open · Star · Rename… · Book Settings… · Duplicate · Edit Rule · Manage Notes… · Bind / Make a Book · Length & Extent… · Use as Daily Journal · Export · state doors · Archive · Delete · Move to Shelf · Move to Wing | SC-B1; `M/Core/Views/BookRowMenu.swift` | PARTIAL | `MobileShelfView.swift:317-350` (long-press: Pin/Unpin · Star/Unstar · Delete Book… or Archive) | Mac-local (`BookRowMenu`, `BookStateDoorSet`, `BookArchiveDoorSet`) — hoist owed | PL-45; VM-6 | M | V: on the Library's book rows there's no long-press at all (`P/Shell/MobileLibraryView.swift:348-379`). Starred-page rows offer only Unstar. A book's acts are split between the long-press and the Details sheet. |
| A16 | The Pin door retired into Star (the union star) | SC-B1 ("the Mac's Pin door is retired into Star"); AppSpec §9 | STALE | `MobileShelfView.swift:317-330`; `MobileShelfFaces.swift:108-110`; `MobileShelfViewModel.swift:122-131` | Core (`setShelfPinned` = `setStarred`) | PL-45; PL-61 | S | V: two doors write one truth (`C/Operations/Operations+Appearance.swift:242-244`). Pressing "Pin to Shelf Top" flips Star to "Unstar" too. |

### B. Creating a book or a gathering

| # | Capability | Mac (contract pointer) | Phone status | Phone file(s) | Brain | Ticket / ledger | Size | Note |
|---|---|---|---|---|---|---|---|---|
| B1 | New Book door + sheet (Name, Cancel, Create Book) | SC-B7 (VX-561) | PRESENT | `P/Shell/MobileCreateBook.swift:179-363` | Core `createReading` | — | — | V. The Name field isn't focused on arrival (V: no `@FocusState` in the file), unlike the Mac's. |
| B2 | Create Journal Book (journal trait, entry-date desc) | SC-B7; `M/Features/Shelf/ShelfView.swift:421-426` | PRESENT | `MobileCreateBook.swift:135-144` | Core | — | — | V: same shape as the Mac's. The code comment says "ascending" but the code (and the Mac) use `.desc`. |
| B3 | Create Gathering… with the rule editor inline (tags, ★ starred, AND/OR, NOT, nesting) | SC-B1, SC-B5; `M/Features/Readings/MintGatheringSheet.swift`, `RuleEditor.swift`; `C/Domain/RuleEditing.swift` | PARTIAL | `MobileCreateBook.swift:145-154,295-362` | Core `RuleEditing`/`RuleGrammar`; Mac-local `RuleEditorModel`/`RuleEditorCopy` — hoist owed | PL-43 (b); VM-6 (4b) | M | V: the "Smart Book" kind offers tags only, any-of / all-of. No star term, no NOT, no nesting. It writes a v1 draft that core normalizes to v2. |
| B4 | Gathering vocabulary at birth | AppSpec §7; SC-B7 | STALE | `MobileCreateBook.swift:263-281` | phone-local | PL-62 (a) | S | V: "Smart Book"; the caption reads "A smart book collects notes by these tags". |
| B5 | The rule's tag vocabulary is the target wing's | AppSpec §7 `tag` (per-wing); `normalizedRuleSpec` | STALE (defect) | `MobileCreateBook.swift:58-64` | Core `allTags(_:wingID:)` | new | S | V: the picker lists every wing's tags (`allTags(db)`, nil wing) while the mint is Home (`:132,139,150`). Core resolves a path in Home only, so a tag that exists only in another wing becomes a dead term (I: dead terms match nothing, per AppSpec §7). The same path in two wings shows two rows that toggle together, because selection is keyed by path. |
| B6 | Name guard per wing (VX-816) | AppSpec §9 | PRESENT | `MobileCreateBook.swift:132,139,150` | Core | PL-69 | — | V: passes `inWing: ""`. |

### C. A book's view, its modes, notes inside it

| # | Capability | Mac (contract pointer) | Phone status | Phone file(s) | Brain | Ticket / ledger | Size | Note |
|---|---|---|---|---|---|---|---|---|
| C1 | Book front: the note list with chapter headers (≈ Outline's navigator) | SC-B10/B11; phone P35 | PARTIAL | `P/Shell/MobileBookView.swift`; `MobileBookViewModel.swift:90-139` | Core `assembleReading` | — | — | V: a bounded window of 300 with a marker. Rows are tap-only. |
| C2 | The book's modes Outline · Index · Book · Read, with the order dial on one line | SC-B11 | PARTIAL | `MobileBookView.swift:134-151` (toolbar: Details · Read) | Mac-local | — | L | V: the phone has the contents list and Read (scroll). There's no Index (the editable-in-place block list), no Book (spread) and no Read ▸ Pages. Q4. |
| C3 | Order dial ("Manual order ▾" / "as collected ▾"), a read-time override plus save | SC-B11; `setReadingSort` | ABSENT | — | Core | — | S–M | V: 0 call sites. |
| C4 | Reorder notes in a book (Move Up/Down, drag), stopping at the pinned-group edge | SC-B12; `reorderReadingPost`; `M/…/BookStructureModel` `postDropPlan` | ABSENT | — | Core op; Mac-local `postDropPlan` — hoist owed | — | M | V: 0 call sites. |
| C5 | Note-title menu in a book (Open · Star · Rename · Move/Copy to Wing · Export · Archive · Delete · Move to Chapter ▸ · Pin to Top / Unpin · Remove from This Book / Release) | SC-B11 (VX-802, VX-901) | ABSENT | `MobileBookView.swift:245-266` | Mac-local table | VM-42 (the pin) | M | V: note rows are plain Buttons with no `.contextMenu`. |
| C6 | Naming of untitled rows in a book (several entries a day must be told apart) | SC Library (VX-580: the one derivation, first words); her "preview like Apple Notes" | STALE | `MobileBookViewModel.swift:280-283`; `MobileBookView.swift:250-259` | Core `DisplayTitle` / `NoteCardFace` | PL-26 | S | V: an untitled entry's title falls to the raw day key (`C/Domain/DisplayTitle.swift:77`), and the row repeats the raw key as its trailing date: "2026-11-12 … 2026-11-12". I: two same-day entries (VX-797) read identically. |
| C7 | The book views' empty states, one home (archived gathering · live gathering matching nothing · book) | SC-B7 (VX-45) | STALE | `MobileBookView.swift:100-105` | Mac-local (`M/Features/BookView/BookEmptyState.swift`) — hoist owed | PL-62 | S | V: one sentence, "No notes in this book yet.", for every kind. |
| C8 | `+ New Note` in a book (born in the book's wing; outflow rides) | SC-B11; AppSpec §9 `newPostInReading` | PRESENT | `MobileBookView.swift:189-213`; `MobileBookViewModel.swift:232-244` | Core | — | — | V. The doors sit at the foot of the list, so on a long book they're far down and the refusal renders beside them. |
| C9 | `+ new entry` in a journal-trait book (dated today) and in THE daily Journal (`newJournalEntry`, several a day) | AppSpec §9 `newJournalEntry` (VX-797); `M/Features/BookView/BookStructureModel.swift:816-905` | STALE | `MobileBookViewModel.swift:232-244` | Core op; Mac-local composition — hoist owed | PL-68 | S | V: the phone mints an undated note through `newPostInReading(id)` with no profile or date in every book, the daily Journal included. The Mac mints a dated entry (`newPostInReading(…, entryDate:)`, or `newJournalEntry` on the Journal). |
| C10 | `+ new note` in a gathering (the gathering mint — the note is tagged to satisfy the rule; NOT terms allowed) | SC-B1, SC-B11 (VX-616) | ABSENT | `MobileBookViewModel.swift:219-221` | Mac-local (`M/Features/BookView/GatheringNoteDoor.swift`) — hoist owed | PL-43 (e) | M | V: `showsBookDoors` is `kind == .book` only. |
| C11 | Step to the previous / next note within a book ("note N of M · chapter") | SC "The app" keyboard (VX-563); SC-B10 (VX-724) | ABSENT | `P/Shell/MobileShellView.swift:457-468` | Mac-local | — | M | V: the `.note` route carries no book context, so a note opened from a book doesn't know its book. Q7. |
| C12 | Book Panel: the TOC beside a membered note, switcher for shared notes, "appears in N gatherings", Remove/Release, drags with menu twins | SC-B3 | PARTIAL | `P/Write/MobileMembership.swift` (the masthead chip's "Books" sheet) | Mac-local `BookPanelModel` | VM-6 (the sitting's named item) | L | V: the sheet lists the books and gatherings holding the note, with add / remove / diverge. There's no TOC, no position and no pins. Q7. |
| C13 | Book-scoped search (the masthead's bare 🔍) | SC Library ("A book's masthead rests as a bare 🔍…") | ABSENT | — | Core search | PL-2 / PL-49 | M | Flag: likely the search reader's. |
| C14 | Read the book continuously | SC-B10 (Read ▸ Scroll) | PRESENT | `P/Read/MobileReadView.swift` | Shared / phone | — | — | V: pinned order renders by construction. |
| C15 | Book export (Markdown / PDF) | `M/Core/Views/BookRowMenu.swift` (`exportMarkdown`, `exportPDF`) | ABSENT | — | Core `Queries.exportReading` | VM-30 (adjacent) | M | V: no phone caller. Flag: the export reader's. |

### D. Chapters

| # | Capability | Mac (contract pointer) | Phone status | Phone file(s) | Brain | Ticket / ledger | Size | Note |
|---|---|---|---|---|---|---|---|---|
| D1 | Create a chapter | AppSpec §9 `createSection` | PRESENT | `MobileBookView.swift:160-171`; `MobileBookViewModel.swift:250-262` | Core | — | — | V. An empty chapter renders a header. |
| D2 | Rename a chapter | `renameSection` | ABSENT | — | Core | — | S | V: 0 call sites. |
| D3 | Delete / restore a chapter | `deleteSection` / `restoreSection` | ABSENT | — | Core | — | S | V. |
| D4 | Reorder chapters | `reorderSection` | ABSENT | — | Core | — | S–M | V. |
| D5 | Put a note in a chapter (Move to Chapter ▸; a new note into a chapter) | `assignPostToSection`; `newPostInReading(section:)` | ABSENT | — | Core | `notes/plans/mobile-batch-10-record.md:333` (named gap); VM-4 plan §5 item 5 (placement is hers) | S | V: a chapter made on the phone can only be filled from the Mac. |
| D6 | The chapterless group reads "unfiled" | SC-B2 ("reads 'unfiled' everywhere") | STALE | `MobileBookViewModel.swift:190-193` | — | — | S | V: unfiled entries trail with no header at all. |
| D7 | Tag-grouped sectioning (`grouping_tag_id`) renders | AppSpec §7 | PRESENT | `MobileBookViewModel.swift:196-204` | Core | — | — | V. |

### E. Pins within a book

| # | Capability | Mac (contract pointer) | Phone status | Phone file(s) | Brain | Ticket / ledger | Size | Note |
|---|---|---|---|---|---|---|---|---|
| E1 | Pinned notes float above the book's sort (within their chapter) everywhere the order renders | SC-B12; AppSpec §9 `setMembershipPinned` | PRESENT (by construction) | `MobileBookViewModel.swift:99` | Core `assembleReading` | PL-71 | — | V: one order home. |
| E2 | Pin to Top / Unpin | SC-B12 | ABSENT | — | Core op | VM-42; PL-71 | S | V: 0 call sites, so a Mac-pinned note can't be unpinned on the phone. |
| E3 | Muted pin mark (on the tables of contents only) | SC-B12 | ABSENT | `MobileBookView.swift:245-266` | — | VM-42 | S | V: `ReadingEntry.pinned` is never read, so a pinned group sits at the top unexplained. Q6. |
| E4 | A finished book's pin refusal names the reopen road | SC-B12 | ABSENT | — | Shared refusal table | VM-42 | S | Comes with E2. |

### F. Gatherings, rules, intake

| # | Capability | Mac (contract pointer) | Phone status | Phone file(s) | Brain | Ticket / ledger | Size | Note |
|---|---|---|---|---|---|---|---|---|
| F1 | A gathering assembles and lists | AppSpec §7; PL-4 | PRESENT | `MobileBookView.swift`, `MobileReadView.swift` | Core | PL-4 | — | V (words aside, A9). |
| F2 | Rule editor (a gathering's or a living book's rule; the Collecting "Edit…" door) | SC-B5 | ABSENT | — | Core `RuleEditing`; Mac-local `RuleEditorModel`/`RuleEditorCopy` (`M/Features/Readings/RuleEditor.swift:42,148`) — hoist owed | PL-43 (b); VM-6 (4b) | L | V: `setReadingQuerySpec` has 0 call sites; Details documents "TAGS — DISPLAY ONLY" (`MobileBookDetails.swift:19-22`). Q8. |
| F3 | A gathering's empty save refuses and offers Delete | SC-B5; `gatheringRequiresRule` | ABSENT | — | Shared refusal table | PL-44 | S | With F2. |
| F4 | Collect door (tag or star an existing note into a gathering), with a receipt that names the star and the honest archived tail | SC-B1 (collect door); VX-381 | STALE | `P/Write/MobileMembership.swift:119-138` | Core `collectPostIntoSmartReading` → `SmartCollectResult` | VM-21; PL-49 | S | V: the receipt "Added by tagging … collects by filter" names no star on a ★-only collect, and overclaims on an archived gathering. |
| F5 | Pickers mark "(archived)" | SC-B5 | STALE | `MobileMembership.swift:88-104,314-319` | — | VM-21 | S | V: lists `Queries.readings` including archived books, unmarked. |
| F6 | Bind a gathering into a book | SC-B11 (VX-616); `convertSmartReadingToCurated` | ABSENT | — | Core op; Mac-local `BindCopy` | PL-43 (e) | M | V. |
| F7 | Make a Book from a gathering (a sibling book carrying the rule) | `M/Features/Readings/BookRowActs.swift:45` (`spawnBook`) | ABSENT | — | Mac-local (`spawnBook`, `ShelfViewModel.spawnPrefill`) — hoist owed | PL-43 (e) | M | V. |
| F8 | Save a book's filter as a gathering | AppSpec §9 `saveFilterAsGathering` | ABSENT | — | Core | — | M | Needs a book filter surface first. |
| F9 | A gathering's three-state hide-owned | SC-B5 | ABSENT | — | Core `setReadingHideOwned`; Mac-local `HideOwnedChoice` | PL-44 | S | V. |
| F10 | Intake hears the phone's own tag and star acts | AppSpec §9 intake | PRESENT (by construction) | `P/Write/MobileNoteTags.swift:110` → `S/TypedTagPath` | Core | PL-43 | — | I: the one application road. The phone says nothing when a tag seated or belled a note somewhere. |
| F11 | The intake dial (`intake_seating`: join quietly or wait at Arrivals) | SC-B5 ("New matches: …") | ABSENT | — | Core `setReadingIntakeSeating` | PL-44 | S | V. |
| F12 | Starred-gathering seed occasion | PL-43 (d); `S/StarredGatheringSeeder.swift` | ABSENT | `P/Shell/MobileFirstWriteFurniture.swift` | Shared | PL-43 (d); VM-6 (4b) | S | V: no call. |

### G. Arrivals

| # | Capability | Mac (contract pointer) | Phone status | Phone file(s) | Brain | Ticket / ledger | Size | Note |
|---|---|---|---|---|---|---|---|---|
| G1 | Arrivals door on a book's masthead (calm when nothing waits, present when something does) | SC-B2 | ABSENT | `MobileBookView.swift:134-151` | Core counts | VM-42; PL-43 (a); PL-71 | S | V. |
| G2 | The review area (rows oldest-first; title, why-it-waits, since-when; Add / Dismiss; opening never seats; its acts never close it) | SC-B2 | ABSENT | — | Core `seatArrival`/`dismissArrival` + `ArrivalProvenance`; Mac-local `BookArrivalsModel`, `ArrivalsCopy` (`M/Features/BookView/BookArrivals.swift:82`), `ArrivalsReviewCopy` — hoist owed | VM-42 | L | V. Q5. |
| G3 | Why-it-waits from `arrival_provenance` (proposed by ‹client› + reason · rule brought it · tagged · starred · catch-up · journal filing · owned elsewhere · wing mend) and since-when | SC-B2; `C/Models/ArrivalProvenance.swift` | ABSENT | — | Core model; the words are Mac-local (`ArrivalsReviewCopy`) — hoist owed | VM-42; PL-71 | S (after the hoist) | V. |
| G4 | AI-proposed arrivals (`propose_notes_to_book`) shown where they land | AppSpec §9 `proposeNotesToBook`; `notes/MCPSpec.md` | ABSENT | — | Core | PL-71 ("needs nothing" is true for the WIRE only; the face is G2/G3's) | (in G2) | I: proposals sync in (provenance encrypted) and are invisible on the phone. The only place to judge one is the Mac. |
| G5 | Ownership arms on a waiting row (Copy in · Move in · Dismiss; "owned by" / "also in") | SC-B2, SC-B6 | ABSENT | — | Core ops; Mac-local `MembershipChoiceCopy` | PL-44 | M | V. |
| G6 | Bulk judging (multi-select; Add all · Dismiss all; Add N · Dismiss N; one message per press; Dismiss all confirms) | SC-B2 | ABSENT | — | Mac-local pure `ArrivalsBulk` (`M/Features/BookView/ArrivalsReviewRules.swift:176`) — hoist owed | VM-42; VM-31 (the multi-select design) | M | V. The Mac's ↑ ↓ ⏎ ⌫ keyboard walk needs a touch-native equivalent (swipe actions?), which is a design call. |
| G7 | Archived waiters visible and seatable; the per-book archived line (Unarchive + Remove/Release) | SC-B2 | ABSENT | — | Mac-local `ArchivedLineCopy` (`M/Features/BookView/BookArchived.swift:48`) | VM-6 (4d) | M | V. |
| G8 | Finish dismisses waiters, and its confirm says "N waiting at Arrivals will be dismissed" when N > 0 | SC-B5; AppSpec §9 `lockReading` | STALE (hazard) | `P/Shell/MobileBookDetails.swift:111-116,386-407` | Mac-local `BookStateCopy.finish` / `waitingLine` (`M/Features/Readings/BookStateDoors.swift:213-226`) | PL-44 | S | V: Finish acts at once with no confirm. I: from AppSpec §9, those dismissals are judgments she never saw. |
| G9 | The daily Journal's "waiting at the door" note names the books and the road | `M/…/BookStructureModel.swift` `JournalWaitingCopy` | STALE | `P/Shell/MobileTodayDoor.swift:73-75` | Mac-local — hoist owed | PL-44 | S | V: the phone's sentence names no book, and there's no door to judge from. |

### H. Membership and ownership (the note's "Books" sheet)

| # | Capability | Mac (contract pointer) | Phone status | Phone file(s) | Brain | Ticket / ledger | Size | Note |
|---|---|---|---|---|---|---|---|---|
| H1 | See the books and gatherings holding a note | SC-B3 | PRESENT | `P/Write/MobileMembership.swift:88-104,268-306` | Core `readingsContaining` | — | — | V. Gatherings are labelled "smart". |
| H2 | Add to a book | AppSpec §9 `addPostToReading` | PARTIAL | `MobileMembership.swift:106-116,308-327` | Core | — | S | V: the picker is `Queries.readings(db)`, every wing. A book in another wing refuses `crossWingMembership`, whose sentence "move the note here first" names a door the phone lacks (`S/OpsRefusalTable.swift:352-354`). Archived books are listed unmarked. |
| H3 | Membership choice sheet (Copy in / Move in with the severed books listed, or Copy in only; the edit law said at the door) | SC-B6 | ABSENT | `MobileMembership.swift:172-188` | Core `copyPostIntoReading`/`movePostIntoReading` + `OwnershipDecision`; Mac-local `MembershipChoiceCopy` (`M/Core/Views/MembershipChoice.swift:46`) — hoist owed | PL-44; VM-6 (4c) | M | V: ownership refusals fall through to the shared sentence ("…it can come in as a copy, or move in…") with no door to do either. |
| H4 | Remove from This Book / Release on an owned book, saying when the note is now bookless | SC-B7; AppSpec §9 `removePostFromReading` | STALE | `MobileMembership.swift:140-150,294-301` | Core | PL-44 | S | V: always "remove". The receipt "the note itself is untouched" never says the note went to the Pool. |
| H5 | A gathering row's "remove #tag" | SC-B7 | ABSENT | `MobileMembership.swift:82-84` | — | — | S | V: gathering rows carry no remove. |
| H6 | Diverge for this book | AppSpec §9 `divergePostForReading` | PRESENT | `MobileMembership.swift:154-163` | Shared `AppSession.divergeForBook` | — | — | V. The door is drawn on gathering rows and then refuses (`:286-292`), the P-2 smell. |
| H7 | Manage Notes… (add many notes to a book) | `BookRowMenu` `manageNotes` | ABSENT | — | Mac-local | VM-31 (adjacent) | M | V. |
| H8 | The bookless word ("Pool") | AppSpec §7 note | STALE | `MobileMembership.swift:270-273` | — | — | S | V: "it lives in the Library's bookless filter". Flag: the Library reader may own Pool naming. |

### I. Book settings and the state doors

| # | Capability | Mac (contract pointer) | Phone status | Phone file(s) | Brain | Ticket / ledger | Size | Note |
|---|---|---|---|---|---|---|---|---|
| I1 | One settings pane for a book and a gathering | SC-B5 | PARTIAL | `P/Shell/MobileBookDetails.swift` | Mac-local `BookSettingsModel`/`BookSettingsFace` (`M/Features/BookView/BookSettingsSheet.swift:236,308`) — hoist owed | VM-6 (4c) | L | V: the phone's "Book Details" (medium detent) carries rename-by-tapping-the-name · meta · Finish/Reopen · Use as Daily Journal · Delete (or Archive on the Journal). |
| I2 | Collecting sentences ("Gathers from" · "New matches" · "Notes written here are tagged") + Edit… | SC-B5 | ABSENT | — | Mac-local `CollectingCopy` (`BookSettingsSheet.swift:75`) — hoist owed | PL-44 | M | V. |
| I3 | Finish / Reopen (assembly frozen, intake paused, text editable) | SC-B5; AppSpec §7 `locked` | STALE | `MobileBookDetails.swift:386-407` | Core; Mac-local `BookStateDoorSet` (`BookStateDoors.swift:85`) | PL-44; PL-45 F-U4-6 | S | V: the caption "freezes its notes" contradicts "text editable". There's no confirm (G8). The row is drawn on gatherings too; `lockReading` throws `wrongReadingKind` there (`C/Operations/Operations+Reading.swift:355-356`), which lands as the raw "That couldn't be done — wrongReadingKind(…)." (`S/RecoveryActs.swift:244-246`). |
| I4 | Seal… / Unseal (the confirm lists forks; sealing finishes too) | SC-B5 | ABSENT | — | Core `sealReading`/`unsealReading`; Mac-local `BookStateCopy` | PL-44 | M | V. On a sealed book the phone's Reopen refuses `readingSealed` (`Operations+Reading.swift:387`), which surfaces as a raw dump, because `DeletionRefusal` has no arm for it (`MobileBookDetails.swift:211-216`). |
| I5 | Own Its Notes… / Stop Owning (the confirm lists the copies) | SC-B5 | ABSENT | — | Core `setReadingOwned` | PL-44 | M | V. |
| I6 | Outflow chooser (several tags, any, none) | SC-B5 | ABSENT | — | Core `setReadingOutflow`; Mac-local `OutflowChooser` | PL-44 | M | V. |
| I7 | Word target / max posts (Length & Extent…) | AppSpec §9 `setReadingWordTarget` / `setReadingMaxPosts` | ABSENT | — | Core | LK5 deferral (`MobileBookDetails.swift:34`) | S | V. Q10. |
| I8 | Journal trait on / off | AppSpec §9 `setJournalTrait` | ABSENT | — | Core | — | S | V. |
| I9 | Use as Daily Journal | AppSpec §9 `setDailyJournalBook` | PRESENT | `MobileBookDetails.swift:183-186,409-430` | Core | — | — | V: same render rule as the Mac (`M/Core/Views/BookRowMenu.swift:245-248`). |
| I10 | Shared-with row + Share… (MCP grants) | SC-B5 | RULED-EXCLUDED* | — | — | PL-55; PL-71 | — | *A design record, not MobileSoul §4.5: the phone runs no MCP server. Confirm at design. |
| I11 | The wing row ('In "‹wing›". Moving the book takes its notes with it.' + Move to Wing ▾) | SC-B5 (VX-829) | ABSENT | — | Core `moveReadingToWing`; Shared `WingWords` | PL-45 | M | V. Comes with N1. |
| I12 | While archived, the Collecting pane leads with the visible pause | SC-B5 | ABSENT | — | — | — | S | V. |
| I13 | Rename a book (per-wing guard) | AppSpec §9 | PRESENT | `MobileBookDetails.swift:130-138` | Core | PL-69 | — | V. The rename door is tapping the name (undiscoverable). |

### J. Badges and marks

| # | Capability | Mac (contract pointer) | Phone status | Phone file(s) | Brain | Ticket / ledger | Size | Note |
|---|---|---|---|---|---|---|---|---|
| J1 | The badge family (the shared mark inside a book, "owned by "X"" outside it, the navigator's "sealed" chip) + the `ownership_badges` switch | SC-B8 | ABSENT | — | Mac-local `OwnershipBadgeCopy`/`OwnershipBadgeFace` (`M/Core/Views/OwnershipBadge.swift:34,65`) — hoist owed; Core `ownershipFacts` | PL-44 | M | V: no owned / sealed face anywhere in the phone's book family. |
| J2 | Sealed told apart from finished | SC-B8 | STALE | `P/Shell/MobileShelfFaces.swift:59-61` | — | — | S | V: one " ✓" for both. Nothing on the phone says "sealed". |
| J3 | The Private mark (closed eye) on book rows | SC-B9 | ABSENT | — | Mac-local | PL-69 | — | I: its gate is an approved MCP client, and grants are local-only, so the gate can never be met on the phone. Flag: the MCP reader's call. |

### K. Archive, delete, restore, duplicate

| # | Capability | Mac (contract pointer) | Phone status | Phone file(s) | Brain | Ticket / ledger | Size | Note |
|---|---|---|---|---|---|---|---|---|
| K1 | Delete a book (to the Trash; its notes stay) | SC-B7 | PRESENT | `P/Shell/MobileShelfView.swift:157-170`; `MobileBookDetails.swift:149-164` | Core | — | — | V. |
| K2 | A gathering's door, confirm and receipt say "Gathering" (VX-611) | SC-B7 | STALE | `MobileShelfFaces.swift:142-143`; `MobileShelfViewModel.swift:194` | Mac-local `BookStateCopy.deleteVerb(_:)` (`M/Features/Readings/BookStateDoors.swift:192`) — hoist owed. PL-62 calls it shared; it isn't. | PL-62 (a) | S | V. The Trash ROW kind word is already right through the shared `RecoveryCopy.rowKind(item)`. |
| K3 | An owned book's two choices (book only, or book and its N notes), with the honest member split ("stays archived") | SC-B7 | ABSENT | — | Core `deleteReadingWithNotes`; Mac-local copy | PL-44; VM-6 (4c) | S–M | V: book-only delete, worded "Its notes stay in the library." |
| K4 | Archive any book or gathering (an owned book asks with the twin confirm) | SC-B7; AppSpec §9 book archive | ABSENT | — | Core `archiveReading` / `archiveReadingWithNotes`; Mac-local `BookArchiveDoorSet` (`BookStateDoors.swift:138`) | VM-6 (4d) | S–M | V: only the daily Journal can be archived on the phone. |
| K5 | The Archived surface's Books group (Open · Unarchive · Delete Book… / Delete Gathering…), "kept, with no countdown" | SC-B7 | ABSENT | `P/Shell/MobileArchiveModel.swift:81`; `MobileArchiveView.swift:34-44` | Core `archivedReadings` | VM-6 (4d); PL-44 | M | V. Her 2026-10-04 walk mistook this hole for a sync bug (`notes/plans/vm-4-mobile-catch-up.md` §4). |
| K6 | Unarchive's receipt ("…it's back on the Bookcase.") and the "(archived)" marks | SC-B7 | ABSENT | — | Mac-local (`BookStateDoors.swift:539`) | VM-6 (4d) | S | V. |
| K7 | Trash: a book row's "and N notes"; Put back's whole-book receipt | SC-B7 | PARTIAL | `P/Shell/MobileTrashView.swift:240-334` | Shared `RecoveryCopy.bookRowNotes` / `bookPutBackWhole` | PL-44 | S | V: the whole-book receipt rides the shared `TrashPutBack` (`S/RecoveryActs.swift:158`). The row's "and N notes" is drawn only on the Mac (`M/Features/Library/RecoveryView.swift:1248`). |
| K8 | Duplicate Book… (shallow or with copies; owned: copies only; never a gathering) | SC-B7; AppSpec §9 `duplicateReading` | ABSENT | — | Core; Mac-local `DuplicateBookCopy` (`M/Features/Readings/DuplicateBook.swift:28`) | PL-44; VM-6 (4c) | S–M | V. |
| K9 | Restore a deleted book (Put back) | AppSpec §9 `restoreReading` | PRESENT | `MobileTrashModel.swift:116-123` | Shared `TrashPutBack` | PL-3 / PL-11 | — | V. |

### L. The daily Journal

| # | Capability | Mac (contract pointer) | Phone status | Phone file(s) | Brain | Ticket / ledger | Size | Note |
|---|---|---|---|---|---|---|---|---|
| L1 | Open today (⌘J's twin: the Journal row's ✎ badge, else a fallback row), opening the day's FIRST entry and ensuring, designating and starring the Journal | AppSpec §9 `shelveInDailyJournalBook` (VX-797) | PRESENT | `P/Shell/MobileShelfView.swift:400-456`; `MobileTodayDoor.swift:37-54` | Core | PL-68 | — | V. The badge is 11.5 pt text in a small chip. |
| L2 | Several entries a day: a fresh "New Entry" door | AppSpec §9 `newJournalEntry` | ABSENT | `MobileBookViewModel.swift:232-244` | Core | PL-68 | S | V: the only in-Journal mint is undated (C9). Q11. |
| L3 | Shift a dated note's day (⌥⌘J) | AppSpec §9 `shiftEntryDate` | ABSENT | — | Core | PL-68 | S | V: 0 call sites. Flag: probably the Write reader's ⋯ menu. |
| L4 | Delete beside Archive on the daily Journal (VX-436) | SC-B7 | STALE | `MobileShelfFaces.swift:162-166`; `MobileShelfView.swift:337-349`; `MobileBookDetails.swift:262-267` | Core | PL-68 | S | V: Delete is hidden entirely on the Journal ("until the mobile catch-up", SC-B7). |
| L5 | Comes-back receipt when a day brings an archived Journal back ("The Journal is back on the Bookcase.") | SC-B7; `M/…/BookStructureModel.swift:1003-1010` | ABSENT | `MobileTodayDoor.swift:37-54` | Mac-local `JournalBooks.comesBackReceipt` — hoist owed (`S/BookArchiveCopy.journalCameBack` is already shared) | VM-6 (4d) | S | V. |
| L6 | Shelving notes (finished · SEALED · full · gathering · waiting at the door · refused) | `M/…/BookStructureModel.swift:1017-1069` | STALE | `MobileTodayDoor.swift:61-79` | Mac-local `JournalBooks.shelvingNote`; the phone keeps a forked copy (MobileSoul §3's drift class) | PL-44 | S | V: there's no sealed arm (it says "reopen it from its book details", and Reopen refuses on a sealed book). It says "is a smart book", and the waiting note names no book. |
| L7 | The starter Journal's entry copy | phone-only (R27b, PROVISIONAL) | STALE | `MobileStarterJournal.swift:127-137` | phone-local | VM-35 (adjacent) | S | V: "One day, one entry." contradicts VX-797. |
| L8 | The 'daily' marker, keeper, wing-aware entry and cross-wing mend | AppSpec §9; SyncSpec §7 | PRESENT (by construction) | — | Core | PL-68 | — | I: shared core. |
| L9 | Archive the daily Journal | AppSpec §9 | PRESENT | `MobileShelfViewModel.swift:209-218` | Core | — | — | V. The receipt names Today's Entry as the road back (true). |

### M. Stars

| # | Capability | Mac (contract pointer) | Phone status | Phone file(s) | Brain | Ticket / ledger | Size | Note |
|---|---|---|---|---|---|---|---|---|
| M1 | Star / Unstar a book (the union star) | AppSpec §9 | PRESENT | `MobileShelfView.swift:325-330`; `MobileStars.swift` | Core | PL-61 | — | V (it sits beside the retired Pin, A16). |
| M2 | Star refusal words | the shared refusal table | STALE | `MobileStars.swift:204-205` | Shared `OpsRefusalTable` | — | S | V: `"Refused: \(error)"`, a raw enum dump. |
| M3 | A starred ARCHIVED book is a dead end | — | STALE (dead end) | `P/Shell/MobileStarredView.swift`; `MobileBookDetails.swift:79-97,254-268` | — | PL-63 | S | V: `Queries.starred` keeps archived readings (`C/Queries/AppearanceQueries.swift:291-305`, which filters only `deleted_at`), and archiving never unstars. So the Journal she archived on the phone still opens from Starred, but its Details sheet is EMPTY, because Details reads `bookshelf`, which drops archived books. There's no way to unarchive. |

### N. Wings, for books

| # | Capability | Mac (contract pointer) | Phone status | Phone file(s) | Brain | Ticket / ledger | Size | Note |
|---|---|---|---|---|---|---|---|---|
| N1 | Move a book (with its notes) to another wing; Move Everything to Another Wing | SC-B4; AppSpec §9 `moveReadingToWing` / `moveWingContents` | ABSENT | — | Core; Shared `WingWords` | PL-45; VM-6 (4a) | M | V: 0 call sites. Depends on the shell's wing switcher (the shell reader). |
| N2 | Books and notes are born in the wing she stands in | SC-B4 | ABSENT | `MobileCreateBook.swift:132,139,150`; `MobileTodayDoor.swift` (`standingWing` default "") | Core | PL-45; PL-69 | — | V: every phone mint passes Home. |

### O. Seeding and the pocket guide's book facts

| # | Capability | Mac (contract pointer) | Phone status | Phone file(s) | Brain | Ticket / ledger | Size | Note |
|---|---|---|---|---|---|---|---|---|
| O1 | The Welcome shelf + arrangement on the first-write road | SC "The app" seed set; `S/SampleLibrary/SampleLibraryWelcome.swift` | ABSENT | `P/Shell/MobileFirstWriteFurniture.swift` | Shared | PL-45; VM-6 (4d); QUESTIONS #178 | S | V: the phone never calls `SampleLibraryWelcome.arrange*` (the Mac calls it at `M/LaunchFurniture.swift:159`). |
| O2 | The pocket guide's "getting around" book facts | — | STALE | `P/Tutorial/MobileTutorialSeeder.swift:279-291` | — | PL-46; PL-61; VM-28 | S | V: it teaches Pin ("a long press on a book row pins or unpins it"), "a smart book", and "starred things sit above everything", and says nothing about shelves, Arrivals or gatherings. Flag: the onboarding reader. |

**Counts by status (118 rows):** PRESENT 20 · PARTIAL 11 · STALE 24 · ABSENT 62 · RULED-EXCLUDED 1. The one RULED-EXCLUDED is I10, starred because it rests on a design record rather than a §4.5 ruling. Three PRESENT rows (E1, F10, L8) are present only by construction through core.

---

## 2. What's there but behind

The phone's existing faces in this area, judged as a daily user would meet them.

1. **The Shelf is a shoebox.** These problems compound with her nine wings:
   - Every wing's books share one list (V, A2).
   - The list sorts journal-trait books second, case-sensitively, and without digit-awareness (V, A5).
   - It sits in a scroll region capped at about eight rows above the half-screen quick-note box (`MobileShelfLayout`).
   - `+ New Book` is the LAST row inside that bounded scroll (`MobileShelfView.swift:191-220`), so with many books it's out of sight until she scrolls the small region to its end.
   - Starred books float with no ★ to say why (A11).
   - Gatherings read "smart" with no count (A9).
   - Same-name books from different wings are indistinguishable (I).
2. **One truth, two doors.** A book's long-press offers both "Pin to Shelf Top" and "Star". They are the same write since 13i-d (A16), so pressing one silently flips the other's label. The pocket guide still teaches Pin (O2).
3. **A book's acts are scattered.** The long-press carries Pin, Star, and Delete or Archive. The Details sheet carries rename (by tapping the name, which is undiscoverable), Finish/Reopen, Use as Daily Journal, and Delete or Archive. Library book rows carry nothing, and Starred rows carry only Unstar. The Mac solved this with one table (VX-829).
4. **Book Details is behind and partly wrong:**
   - The Finish caption contradicts the contract ("freezes its notes").
   - Finish has no confirm, yet it silently dismisses waiting arrivals (G8).
   - Finish is drawn on gatherings and refuses with a raw enum dump (I3).
   - Reopen on a sealed book refuses with a raw enum dump (I4).
   - The sheet is empty for an archived book (M3).
   - There's one delete choice, and no Archive except on the Journal.
   - Every act row is 11.5 pt text (`S/Theme/VoiceTokens.swift:296,332,369,406`: `small` is a fixed 11.5 pt with no Dynamic Type). This is exactly her "weirdly tiny font" / "button affordances are absolutely tiny".
5. **The contents list is a dead end.**
   - Note rows have no long-press: no pin, no chapter move, no remove, no archive.
   - Untitled journal entries show the raw day key twice ("2026-11-12 … 2026-11-12"), so several entries on one day can't be told apart (C6). Her "preview more like Apple Notes so I know what each note is" applies here as much as in the Library.
   - Unfiled notes trail with no "unfiled" header (D6).
   - A chapter made here can't be filled (D5).
   - There's one empty-state sentence for books and gatherings alike (C7).
   - The doors and their refusals sit at the foot of a list that can be 300 rows long.
6. **New notes in a journal are wrong.** In the daily Journal (and in any journal-trait book), "+ New Note" mints an UNDATED note with no journal profile. The Mac mints a dated entry, or a fresh `newJournalEntry` on THE Journal (C9, L2). On the phone the Journal fills with dateless notes whose rows read as their creation day, which is the same row-naming problem as item 5.
7. **The membership sheet misleads:**
   - It offers every wing's books, and the cross-wing refusal points at a road the phone lacks (H2).
   - Archived books are unmarked (F5).
   - Ownership refusals explain a ceremony the sheet can't perform (H3).
   - "remove" never becomes "Release" and never says the note is now in the Pool (H4).
   - Diverge is drawn on gatherings and then refuses (H6).
   - The collect receipt overclaims (F4, VM-21).
8. **The Today door's words are forked and stale.** The phone keeps its own copy of the Mac's `JournalBooks.shelvingNote` (L6). There's no sealed arm, it still says "smart book", the waiting note names no book, and there's no comes-back receipt (L5). The starter entry still promises "One day, one entry." (L7).
9. **Intake runs, but the phone shows nothing of it.** Her phone tags and stars do seat and bell notes in living books (F10). A phone-filed entry can wait at an owned Journal's door. AI proposals arrive by sync. None of this is visible: no count, no door, no receipt (G1–G4). The one road that touches waiters, Finish, deletes them unseen (G8).
10. **Small wording debts:**
    - Star refusals dump raw enums (M2).
    - The book-delete door and confirm say "Book" on a gathering (K2).
    - "bookless filter" is used where the app says Pool (H8).
    - The path line's "N books" counts gatherings (A6).

---

## 3. Flow notes: how she gets around the books family on the phone today

**The shell** (V: `P/Shell/MobileShellView.swift`, `MobileShellBand.swift`). There are three roots in one horizontal swipe band, ‹ Starred · **Shelf** · Library ›, with a text tab bar. Each root has its own `NavigationStack`, and pushes hide the tab bar.

**Shelf (home):**
- The path line carries "Shelf · N books", the Trash door, `+ New Note` and `Settings`, all 11.5 pt text.
- Below it are the book rows, bounded at about eight rows, then `+ New Book`, then the Today fallback row when no Journal is on the shelf.
- Below those is the quick-note box (one line at rest, about half the screen when focused).
- The daily Journal's row carries the `✎ today` badge.

**Roads:**
- **Open a book:** tap its row. This pushes the contents (`MobileBookView`). The toolbar carries **Details** (a medium-detent sheet) and **Read** (pushes the continuous Read view). Tap a note row to push Write.
- **Book-level acts:** long-press the row (Pin · Star · Delete/Archive), or open the book → **Details** (rename by tapping the name · Finish/Reopen · Use as Daily Journal · Delete/Archive).
- **Make a book:** scroll the bounded books region to its end → `+ New Book` → sheet (Book · Journal Book · Smart Book; Smart shows a tag list with any/all) → Create. This lands on the new book's contents.
- **Make a chapter:** book → scroll to the foot of the list → `+ New Chapter` → alert. **Put a note in a chapter:** impossible on the phone.
- **Add a note to a book:** from inside the note, tap the masthead chip ("in X") → the Books sheet → "+ ‹book›", or "‹gathering› (by tagging)".
- **Today:** tap the `✎ today` badge on the Journal row → the day's first entry opens for typing.
- **See archived books:** impossible, except an archived book that's still starred, reached from the Starred page with an empty Details sheet (M3).
- **Judge arrivals, seal, own, duplicate, move to a wing, manage shelves, reorder notes, pin:** impossible.
- **Get a deleted book back:** Shelf → the path line's Trash door → Put back. This works; it's the shared road.

**Where it's awkward:**
- Book acts are split across two surfaces (item 3 above).
- The creation and chapter doors are at the bottoms of scrolling lists rather than in chrome.
- A note opened from a book loses the book: no position, no next/previous, no chapter, and the way back is the system back gesture only (C11).
- Every root already owns the horizontal swipe, which collides with her ask for "a quick swipe" between wings (Q3).
- Every door is 11.5 pt text without a button shape, consistent with her "tiny affordances" note.

---

## 4. Open questions for the author (real product calls only)

**Q1. What shape does the Bookcase take on the phone?** The 13i sitting ruled "the Bookcase/shelf strip as a list" (`notes/plans/phase-13i-sitting-record-2026-09-30.md` §18 item 5) but not the form.
- (a) A horizontally scrolling chip row of shelves (starred · Unshelved · each shelf · All) above the book list, with solo as the default.
- (b) One sectioned list, shelves as collapsible headers (All only), with solo reached by tapping a header.
- (c) A two-level road: Bookcase → a shelf's books.

**Q2. Does the R27 half-screen writing area still own the home screen once shelves and nine wings arrive?** Today the books get at most about eight rows above the quick-note box.
- (a) Keep R27 as ruled; the Bookcase lives inside the bounded region.
- (b) Give the Bookcase the screen, with quick entry as a one-line bar at the foot (the Mac's own posture) that expands on focus.
- (c) Split by context: the bounded region when the store has few books, the full screen past a threshold.

**Q3. Her "quick swipe between wings" collides with the existing Starred ‹ Shelf › Library swipe band.** This is cross-reader; the shell/wings reader will meet it too.
- (a) The wing swipe lives only on the masthead's wing name or strip; the band keeps the root swipe.
- (b) Retire the root swipe band (the tab bar stays) and give the horizontal swipe to wings.
- (c) Wings change by the dropdown only; no swipe.

**Q4. Which of the book's modes does the phone carry?** Today it has the contents list ≈ Outline and Read ▸ Scroll.
- (a) Keep the two and add Index as an "edit in place" list (the block-level book editor).
- (b) Add Read ▸ Pages (a paged reader) and stop there.
- (c) The contents list stays the only mode surface, and the Mac-only modes go on the ruled-exclusion list.

**Q5. Where do Arrivals live on the phone, and what is bulk judging there?**
- (a) A count chip in the book's toolbar that pushes a full-screen review, with swipe-to-Add / swipe-to-Dismiss rows and an Edit-mode multi-select for Add N / Dismiss N (ties to VM-31).
- (b) An "Arrivals — N waiting" section at the top of the book's contents, judged in place.
- (c) A sheet over the contents, (a)'s grammar at a medium detent.

**Q6. Does the phone's contents list wear the pin mark?** The Mac draws it on the tables of contents only, never on the calm page, and the phone's contents list IS its TOC.
- (a) Yes, a muted pin on the row.
- (b) No mark; a small "pinned" group header instead.
- (c) No mark at all (the Mac's calm-page rule applied to the whole phone).

**Q7. What is the Book Panel's phone shape, including next/previous within a book?** VM-6 names this as the sitting's item.
- (a) The masthead chip's Books sheet grows into it: the book's TOC with the note marked, the switcher for shared notes, pins and Release.
- (b) A thin book strip on a note opened from a book ("note 3 of 12 · Chapter"), with ‹ › to step and a tap to open the TOC.
- (c) Both.

**Q8. How much of the rule editor does the phone get?** Her complexity-test doctrine is MobileSoul §4.
- (a) The full boolean tree (the shared `RuleEditing` brain).
- (b) A simplified face over v2 rules: any / all of tags + "starred" + "not #tag", with nesting shown read-only and editable on the Mac.
- (c) Rules stay see-only on the phone (the Collecting sentences), editable only on the Mac. The doctrine flags this as "do it on the Mac", so it needs her ruling.

**Q9. Shelf management on the phone.**
- (a) Full: create, rename, glyph, delete, reorder shelves, and move a book to a shelf.
- (b) See and file only: solo shelves and move a book to a shelf; shelf structure is Mac-made.
- (c) See only.

**Q10. Extents (word target, max posts): does LK5's v1 deferral still stand?**
- (a) Keep them absent.
- (b) Show progress only (read).
- (c) Full editing in the settings pane.

**Q11. Where does the Journal's "New Entry" (several a day) live, beside the `✎ today` badge that opens the day's first?**
- (a) The Journal's contents foot ("+ New Entry"), the Mac's own placement.
- (b) Also on the Journal row as a second badge.
- (c) The quick-note box gains a "to Journal" filing.

**Q12. How should untitled notes be named in a book's list?** This is her "preview like Apple Notes" ask; it overlaps the Library reader.
- (a) The Library's one derivation (first words), with the day in the meta.
- (b) Day + time for journal entries, first words elsewhere.
- (c) A two-line row: first words, plus a body preview.

---

### Boundaries with other readers (flagged, not owned here)

- **Shell / wings:** the wing switcher itself (A2, N1 and I11 depend on it).
- **Library:** the Library's book rows, the Pool naming (H8), the Starred page's design (PL-63), untitled-row naming (C6/Q12).
- **Note / Write:** the masthead chip that hosts H1–H6, and ⌥⌘J's shift-date door (L3).
- **Recovery:** the Trash rows (K7) and the Archived room (K5).
- **Onboarding:** the pocket guide (O2).
- **Export:** book export (C15).
- **MCP:** the Private mark (J3), and the open question of whether any AI face reaches the phone.
- **Contradiction to watch:** PL-62 says `BookStateCopy.deleteVerb(_:)` is a shared seam. It is Mac-local (`M/Features/Readings/BookStateDoors.swift:173,192`), so any reader planning on "the phone just passes the kind" needs a hoist first.
