# VM-44 phone atlas — screen inventory (Phase B checklist)

Drawn from the code on `main` @ `5dde1bcf9` (`App/Variorum/VariorumMobile/`, `App/Variorum/Shared/`). Paths below are relative to `App/Variorum/VariorumMobile/` unless they start with `Shared/`. **Capture** names the PNG the walk writes (`atlas/screens/<prefix><name>.png`); `—` means Phase B captures it by a named manual step or it is optional. Tags: **[seed]** needs the seeded store · **[act]** the walk performs a small reversible act to reach it · **[opt]** optional / staged state · **[dbg]** Debug build only · **[edge]** reachable only in an unusual store state.

Totals: **113 rows (A–I)** — 89 ordinary surfaces/states (83 with a named walk capture, 6 confirm-then-Cancel alerts or incidental lines captured by hand), and 24 optional / edge / debug-only (the protection lobby family, failure faces, prompts). Plus 7 key-screen variants × 2 secondary passes and 4 recordings.

**PHASE B PRIMARY PASS — RESULTS (2026-11-12, Study voice by launch argument, light, default text size; iPhone 17 Pro sim, iOS 27.0).** 113 rows: **90 captured ✓, 1 partial (F9), 22 not captured** — 3 ordinary rows (A1 the opening frame passed before the first capture · B8 no status line fired · C7 the driver found no `+ new scrap` button) and 19 optional / edge / Debug rows left as planned (E16 F6 F11 G5 G8 H7–H12 I1–I8). Two sub-parts also missed: C16's per-row Delete Now confirm and E4's Add a Link alert (no button exposed to the driver). 112 PNGs in `screens/` (the first pass's wrong shots are in `screens/_superseded/`; first-pass evidence the re-run overwrote is in `findings/`). Extra captures beyond the rows: `01-starred-after-first-write`, `33-library-search-body-word-ferry`, `84-note-tray-leaving`/`-archived`, `96-*-xxxl-text` (XXXL Dynamic Type). Every capture was checked by eye; the twelve words are redacted in `00-first-launch` and `00-words-card-redacted`. Bugs and observations: `walk-findings.md`. Section J (secondary passes) run — see its results block. Section K: all four clips recorded (`recordings/`, raw + `-trim`).

Passes: PRIMARY = every row, Study voice, light (the brief). SECONDARY (key screens only: Library, quick entry focused, a note in Write, a book, Settings) = Study dark, Terminal light. The phone cannot wear the sea-glass palette at all (see Findings F1), so every capture shows the voice's Classic colours.

## A. Launch and first open (fresh install, before the seed)

| # | Screen / state | Owner | Capture |
|---|---|---|---|
| A1 | Opening (quiet first frame while the store opens off-main) | `MobileStoreFailureView.swift` (`MobileStoreOpeningView`) | NOT CAPTURED — the opening frame passed before the first capture (the first frame the walk caught was already the words card); `00-first-launch.png` is that frame, redacted |
| A2 | New library's twelve-words card ("I've written them down") — **redact the words** | `Features/Protection/MobileRoadFaces.swift` (`MobileLibraryWordsCard`) | ✓ `00-words-card-redacted.png` (words redacted; also `00-first-launch.png`, redacted) |
| A3 | Empty shelf ("No books yet — Today's Entry starts your journal." + sign-in line, today fallback row, + new book) | `Features/Shell/MobileShelfView.swift`, `MobileEmptyStore.swift` | ✓ `01-empty-shelf.png` |
| A4 | Empty Library ("No notes yet." + door + sign-in line) | `Features/Shell/MobileLibraryView.swift` | ✓ `01-empty-library.png` |
| A5 | Empty Starred page | `Features/Shell/MobileStarredView.swift` | ✓ `01-empty-starred.png` |
| A6 | Quick entry focused on an empty store | `Features/Shell/MobileQuickNote.swift` (`MobileQuickNoteBox`) | ✓ `01-empty-quick-entry-focused.png` |
| A7 | First write typed | same | ✓ `01-first-write-typed.png` |
| A8 | Library / shelf after the first-write furniture lands (starter Journal + the Prince) | `Features/Shell/MobileFirstWriteFurniture.swift`, `MobileStarterJournal.swift`, `Shared/SampleLibrary/` | ✓ `01-library-after-first-write.png`, `01-shelf-after-first-write.png`, `01-starred-after-first-write.png` |

## B. The shell: band, tab bar, shelf, quick entry

| # | Screen / state | Owner | Capture |
|---|---|---|---|
| B1 | Shelf at rest: path line (`~/shelf · N books` / `Shelf · N books`), 🗑 door, `+ New Note`, `Settings`; book rows (name + meta); `✎ today` badge on the Journal row; `+ new book` row; tab bar `Starred · Shelf · Library` | `Features/Shell/MobileShelfView.swift`, `MobileShellView.swift` (tab bar) , `MobileShelfFaces.swift` | ✓ `10-shelf-rest.png` |
| B2 | Shelf books region scrolled (bounded list scrolls inside itself; all nine wings' books in ONE flat list) | `MobileShelfView.swift`, `MobileShelfLayout.swift` | ✓ `10-shelf-books-scrolled.png` |
| B3 | Book row long-press menu (Pin/Unpin · Star/Unstar · Delete Book…) | `MobileShelfView.swift` (`.contextMenu`) | ✓ `11-shelf-book-longpress-menu.png` |
| B4 | Journal row long-press menu (Archive in Delete's place) | same | ✓ `11-shelf-journal-longpress-menu.png` |
| B5 | Delete Book confirm alert | `MobileShelfView.swift` (`.alert`) | ✓ `15-delete-book-confirm.png` (cancelled) |
| B6 | Create Book sheet (Notes · Journal · Smart-from-tags kinds, tag picker) | `Features/Shell/MobileCreateBook.swift` | ✓ `12-create-book-sheet.png` |
| B7 | Today fallback row (`✎ today's entry`) when no Journal on the shelf | `MobileShelfView.swift` | ✓ `01-empty-shelf.png` |
| B8 | Shelf status lines (report / error / star refusal) | `MobileShelfView.swift` | NOT CAPTURED — incidental; no report/error/refusal line fired during the walk |
| B9 | Quick entry at rest (one line, hint "new note — just start typing · ⏎ opens it", Terminal's blinking block cursor) | `MobileQuickNote.swift` (`MobileQuickNoteBox`) | ✓ `20-quick-entry-at-rest.png` |
| B10 | Quick entry focused + keyboard (the box expands to ~half the screen) | same + `MobileShelfLayout.swift` | ✓ `21-quick-entry-focused-keyboard.png` |
| B11 | Quick entry with text (indicator + `open ↵` door), one and two lines | same | ✓ `22-quick-entry-typed.png`, `22-quick-entry-typed-two-lines.png` (wrapped line; Return opens the note — see walk-findings W1) |
| B12 | Quick entry → note opened in Write | `MobileShellView.swift` → `Features/Write/MobileWriteView.swift` | ✓ `23-quick-entry-opened-note.png` |
| B13 | Shelf after the box files on leaving (box empty again) | `MobileQuickNote.swift` (`fileOnLeaving`) | ✓ `24-shelf-after-quick-note-filed.png` |
| B14 | Starred page (★ rows, book/note kind, long-press Unstar) | `Features/Shell/MobileStarredView.swift`, `MobileStars.swift` | ✓ `14-starred-page.png` |
| B15 | Band swipe between pages (mid-gesture / landed) | `MobileShellView.swift`, `MobileShellBand.swift` | ✓ `14-after-band-swipe-left.png` (landed on Library) |
| B16 | Settings door → Settings sheet | `Features/Shell/MobileSettingsView.swift` | ✓ see H (`90-settings-sheet.png`) |

## C. Library

| # | Screen / state | Owner | Capture |
|---|---|---|---|
| C1 | Library at rest, All filter (path line, 🗑, `+ New Note`, search field, filter row with sort glyph, rows = title + day, books interleaved) | `Features/Shell/MobileLibraryView.swift`, `MobileLibraryViewModel.swift`, `MobileListingFilters.swift` | ✓ `30-library-rest-all.png` |
| C2 | Library scrolled (the "one bunch" — every wing's notes together) | same | ✓ `30-library-scrolled-1.png`, `30-library-scrolled-2.png` |
| C3 | Filter: Books (books as rows, `MobileShelfFaces` meta) | same | ✓ `31-library-filter-books.png` |
| C4 | Filter: Notes | same | ✓ `31-library-filter-notes.png` |
| C5 | Filter: Bookless (the Pool's phone home) | same | ✓ `31-library-filter-bookless.png` |
| C6 | Filter: Scraps (pool picker Menu, `+ new scrap`, scrap rows with tags) | `Features/Shell/MobileScraps.swift` | ✓ `31-library-filter-scraps.png` |
| C7 | New Scrap alert | `MobileScraps.swift` | NOT CAPTURED — the driver found no button for `+ new scrap` (the door is visible at the foot of `31-library-filter-scraps.png`); alert not opened |
| C8 | Sort menu (Menu) | `MobileLibraryView.swift` (`sortMenu`), `MobileListingFilters.swift` (`MobileSortDoor`) | ✓ `32-library-sort-menu.png` |
| C9 | Search focused (keyboard) | `MobileLibraryView.swift` | ✓ `33-library-search-focused.png` |
| C10 | Search results ("lighthouse": hits across wings) | same | ✓ `33-library-search-lighthouse.png` (+ `33-library-search-body-word-ferry.png`, walk-findings W6) |
| C11 | "Nothing found." | same | ✓ `33-library-search-nothing-found.png` |
| C12 | Note row long-press menu (Star · Delete Note…) | `MobileLibraryView.swift` (`.contextMenu`) | ✓ `34-library-note-longpress-menu.png` |
| C13 | Delete note confirm alert | `MobileLibraryView.swift` (`.alert`) | ✓ `34-library-delete-note-confirm.png` (cancelled) |
| C14 | Archived row (trailing) → Archive room | `MobileLibraryView.swift`, `Features/Shell/MobileArchiveView.swift`, `MobileArchiveModel.swift` | ✓ `35-archive-room.png` (door reached via the Bookless filter — under All it is the last of ~150 rows) |
| C15 | Trash door → Trash room (kind filter, sort, Put back · Delete Now, window note, Empty Trash) | `Features/Shell/MobileTrashView.swift`, `MobileTrashModel.swift`, `MobileRecoveryDoors.swift` | ✓ `36-trash-room.png`, `36-trash-room-scrolled.png` |
| C16 | Trash destructive confirms (Delete Now / Empty Trash) | `MobileTrashView.swift` | ✓ `36-trash-empty-confirm.png` (cancelled); the per-row Delete Now confirm NOT CAPTURED — the row's `Delete Now` is not exposed as its own button to XCUITest (nothing was deleted) |
| C17 | Trash from the Shelf's 🗑 (second renderer) | `MobileShelfView.swift` | ✓ `13-trash-from-shelf.png` |

## D. Books

| # | Screen / state | Owner | Capture |
|---|---|---|---|
| D1 | Book contents (name, `Details`, `Read`, `+ New Note`, `+ New Chapter`, rows) — Essays (pinned membership) | `Features/Shell/MobileBookView.swift`, `MobileBookViewModel.swift` | ✓ `40-book-essays-contents.png` |
| D2 | Book Details sheet (name = rename door, meta, Finish/Reopen, tags display, Use as Daily Journal, Delete Book… / Archive) | `Features/Shell/MobileBookDetails.swift` | ✓ `41-book-details-sheet.png`, `48-book-details-lighthouse.png` |
| D3 | Rename Book alert · Delete Book confirm | `MobileBookDetails.swift` | ✓ `41-book-rename-alert.png` (cancelled); Delete Book confirm = `15-delete-book-confirm.png` |
| D4 | Read view (calm continuous column across the book's notes) | `Features/Read/MobileReadView.swift`, `MobileReadPage.swift` | ✓ `42-book-read-view.png`, `42-book-read-view-scrolled.png` |
| D5 | Book with chapters (section labels) — Blog drafts | `MobileBookView.swift` | ✓ `43-book-chapters.png` |
| D6 | New Chapter alert | `MobileBookView.swift` | ✓ `43-new-chapter-alert.png` |
| D7 | The daily Journal book (dated entries) | `MobileBookView.swift` | ✓ `44-book-daily-journal.png` |
| D8 | A gathering (Quotes — rule-assembled) | `MobileBookView.swift` | ✓ `45-gathering-quotes.png` |
| D9 | A living book with 3 WAITING arrivals (Ideas inbox) — the phone has no Arrivals surface (Finding F4) | `MobileBookView.swift` | ✓ `46-book-ideas-inbox-arrivals.png` (no arrival is visible — walk-findings W15) |
| D10 | A finished book (Letters — ✓ state on the name) | `MobileBookView.swift`, `MobileShelfFaces.swift` | ✓ `47-book-finished-letters.png` |
| D11 | Fiction-wing book with three chapters + pinned scene | `MobileBookView.swift` | ✓ `48-book-lighthouse-chapters-pinned.png` (the pinned scene carries no mark) |
| D12 | The Prince (sample library furniture) | same | ✓ `49-book-the-prince.png` |
| D13 | An empty book ("No notes in this book yet.") — Taxes 2025 ▸ Receipts | same | ✓ `49-book-empty-receipts.png` |

## E. A note in Write (masthead, chips, sheets)

| # | Screen / state | Owner | Capture |
|---|---|---|---|
| E1 | Write at rest: title (rename door), copy · find · seal · ⋯ corner, membership chip, chip flow date · tags · more info · blocks · lens, prose with comment markers, callout frame, takes badge | `Features/Write/MobileWriteView.swift` (`MobileWriteScreen`), `MobileEditorTextView.swift`, `MobileBlockDecor.swift`, `Features/Takes/MobileTakesChrome.swift` | ✓ `50-note-write-rest.png` |
| E2 | Membership sheet ("Books", Add to a book, remove, diverge, smart) | `Features/Write/MobileMembership.swift` | ✓ `51-note-membership-sheet.png` |
| E3 | Tags sheet (apply/remove, type-a-tag field) | `Features/Write/MobileNoteTags.swift` | ✓ `52-note-tags-sheet.png` |
| E4 | More Info sheet (references, `+ add a link`) + Add a Link alert | `Features/Write/MobileReferences.swift` | ✓ `53-note-more-info-sheet.png`; the Add a Link alert NOT CAPTURED — the driver found no button for `+ add a link` |
| E5 | Blocks sheet (list, Select → picking mode, delete blocks, jump) | `Features/Write/MobileBlockList.swift`, `MobileBlockSelection.swift` | ✓ `54-note-blocks-sheet.png`, `54-note-blocks-picking.png` |
| E6 | This Note's Tray inside the Blocks sheet (Leaving · Archived, Put back · Delete Now) | `Features/Write/MobileNoteTray.swift` | ✓ `84-note-tray-in-blocks-sheet.png`, `84-note-tray-leaving.png`, `84-note-tray-archived.png` |
| E7 | Lenses sheet (save the current view as a lens…, rename, delete, restore, fallback notice) | `Features/Takes/MobileLenses.swift` | ✓ `55-note-lenses-sheet.png` |
| E8 | Note Actions sheet ⋯ (Undo/Redo rows, Save a Version, Versions…, Delete Note…) | `Features/Write/MobileNoteActions.swift`, `MobileUndoDoor.swift` | ✓ `56-note-actions-sheet.png` (no Undo/Redo rows — nothing to undo at that moment) |
| E9 | Entry Date alert | `MobileWriteView.swift` | ✓ `57-note-entry-date-alert.png` |
| E10 | Rename Note alert | `MobileWriteView.swift` | ✓ `58-note-rename-alert.png` |
| E11 | Find in Note (system find navigator) | `MobileEditorViewModel.swift` (`findInteraction`) | ✓ `59-note-find-navigator.png` |
| E12 | Copy Note receipt | `Features/Write/MobileNoteClipboard.swift` | ✓ `59-note-copied-receipt.png` |
| E13 | Sealed note (state line + `Unlock Note` door) | `MobileWriteView.swift` | ✓ `80-note-sealed.png` |
| E14 | Versions screen (moments of one note: Restore · Promote · Delete) | `Features/Write/MobileVersions.swift` | ✓ `83-versions-screen.png`, `85-versions-with-saved-version.png` |
| E15 | Delete Note confirm (from ⋯) | `MobileNoteActions.swift` | ✓ `56-note-delete-confirm.png` (cancelled) |
| E16 | Undo warning alert (destructive undo) | `MobileWriteView.swift`, `MobileNoteActions.swift` | NOT CAPTURED — optional; needs a destructive undo staged first |

## F. The editor (keyboard up)

| # | Screen / state | Owner | Capture |
|---|---|---|---|
| F1 | Keyboard up, bar at rest `Aa · ⑂ · ⋯` (UIToolbar inputAccessoryView) | `Features/Write/MobileKeyboardBar.swift` | ✓ `60-editor-keyboard-bar-rest.png` |
| F2 | Formatting strip expanded (× B I S ⟨⟩ # • ☑ ⇥ ⇤ link — eleven acts) | same | ✓ `61-editor-formatting-strip.png` |
| F3 | Heading long-press menu (Heading 1–n, Clear Heading) | same (`UIMenu`) | ✓ `61-editor-heading-menu.png` |
| F4 | Block ⋯ menu (Comments… · Name Block… · Commit Take · New Block Below · Divide Block · Merge with Previous · Callout ▸ · Archive Block) | `Features/Write/MobileBlockMenu.swift` | ✓ `62-editor-block-menu.png` |
| F5 | Callout submenu (toggle, colours, Emoji…, Remove) | `MobileBlockMenu.swift`, `MobileCallout.swift` | ✓ `62-editor-callout-submenu.png` |
| F6 | Callout Emoji prompt (owned sheet, emoji keyboard) | `Features/Write/MobileEmojiField.swift` | NOT CAPTURED — optional (the emoji prompt); not walked |
| F7 | Name Block prompt (UIAlertController) | `MobileEditorViewModel.swift` (`promptForText`) | ✓ `62-editor-name-block-prompt.png` (cancelled) |
| F8 | Comments sheet (overlay: list, draft, submit, deleted/restore) | `Features/Write/MobileCommentsSheetView.swift`, `MobileComments.swift` | ✓ `63-comments-sheet.png` |
| F9 | Selection edit menu (system + Takes… · Extract Selection · Make Block from Selection) | `Features/Takes/MobileEditMenuSeam.swift` | PARTIAL `64-editor-selection-edit-menu.png` — the word is selected (handles) but the edit menu had not appeared at the capture |
| F10 | Structural receipt row with bare `Undo` (after New Block Below) | `MobileWriteView.swift` (receipt row), `MobileStructural.swift` | ✓ `65-editor-structural-receipt-undo.png` — the receipt reads "New block added below — type away." with NO Undo door; `65-editor-after-undo.png` therefore shows the same state (the empty block stays) |
| F11 | Divide / Merge refusal or destructive confirm alerts | `MobileStructural.swift`, `MobileRefusalRoads.swift` | NOT CAPTURED — optional; a refusal/confirm needs a staged divide/merge |
| F12 | Keyboard down after editing | `MobileWriteView.swift` | ✓ `66-editor-keyboard-down.png` |
| F13 | Today's entry opened for writing (keyboard up, empty entry) | `MobileShelfView.swift` (`✎ today`), `MobileTodayDoor.swift` | ✓ `86-today-entry-keyboard.png` |
| F14 | Very long note (~40k words): top and deep-scrolled | `MobileEditorTextView.swift` (TK2 viewport) | ✓ `81-long-note-top.png`, `81-long-note-scrolled.png` |
| F15 | Heavy-fan note: 4 takes, 2 comments, ⚓ callout, reference, deleted block | Write surface | ✓ `82-note-heavy-fan-callout-comments.png`, `82-note-heavy-fan-scrolled.png` |

## G. Takes

| # | Screen / state | Owner | Capture |
|---|---|---|---|
| G1 | Takes badge on a fanned block (corner badge, gutter marker) | `Features/Takes/MobileTakesChrome.swift` | ✓ `70-takes-badge-on-fanned-block.png` |
| G2 | Swipe-peek with the pill (‹ › choose) | `MobileTakesChrome.swift` (`MobileTakesPillView`), `MobileTakesController.swift` | ✓ `71-takes-peek-pill.png` |
| G3 | Takes browser (cards, labels, state, choose, footer: Branch this one · Blank take · All Takes to Blocks; archived takes section) | `Features/Takes/MobileTakesBrowserView.swift`, `MobileTakesBrowser.swift` | ✓ `72-takes-browser.png` |
| G4 | Take card ⋯ menu (History… · Label Take… · Lock/Unlock · Move Up/Down · Take to New Block Below · Archive Take · Delete Take) | `MobileTakesBrowserView.swift` | ✓ `73-take-card-menu.png` |
| G5 | Archived take card menu (Unarchive Take · Label Take…) | `MobileTakesBrowserView.swift` (`MobileArchivedTakeCardView`) | NOT CAPTURED — optional; the archived take sits on one block of “Walking as a writing tool” and was not walked |
| G6 | Block History sheet (four regions: takes, commits, lineage, archived) | `Features/Takes/MobileBlockHistorySheetView.swift`, `MobileBlockHistory.swift` | ✓ `74-block-history-sheet.png` |
| G7 | Label Take prompt | `MobileEditorViewModel.swift` | ✓ `73-take-label-prompt.png` (cancelled) |
| G8 | Card editor (editing a take inside the browser) | `MobileTakesBrowserView.swift` (`takes.browser.cardEditor`) | NOT CAPTURED — optional; not walked |

## H. Settings and its sheets

| # | Screen / state | Owner | Capture |
|---|---|---|---|
| H1 | Settings sheet: Voice (Terminal · Study), Sync row (signed out), Protection…, Acknowledgments, Tags ▸ Manage Tags, Diagnostics (Record edit trace, Edit trace…), [dbg] Tutorial (Open/Restore the pocket guide), [dbg] Performance (Seed the 100k fixture), [dbg] TK2 Spike | `Features/Shell/MobileSettingsView.swift`, `Shared/SyncStatusViews.swift` (`SyncStatusRow`) | ✓ `90-settings-sheet.png`, `90-settings-sheet-swiped.png` (identical — the sheet does not scroll); at XXXL text: `96-settings-xxxl-text.png`, `96-settings-xxxl-text-swiped.png`, `96-shelf-xxxl-text.png` (chrome text does not grow — walk-findings W19) |
| H2 | Tag manager (tree, `+ new tag`, Rename… · New Child Tag… · Delete…) + its three alerts | `Features/Shell/MobileTagManager.swift` | ✓ `91-tag-manager.png`, `91-tag-manager-row-menu.png`, `91-tag-rename-alert.png` (cancelled; New Child Tag… / Delete… alerts not opened) |
| H3 | Acknowledgments sheet | `Features/Protection/MobileAcknowledgmentsSheet.swift` | ✓ `92-acknowledgments.png` |
| H4 | Edit trace sheet | `Features/Write/MobileEditTrace.swift` (`MobileEditTraceView`) | ✓ `93-edit-trace.png` |
| H5 | Account sheet, signed out (sign-in form — **never typed into**) | `Shared/AuthViews.swift`, `Shared/Theme/SharedPageStyle.swift` | ✓ `94-account-sheet-signed-out.png` (opened from Protection ▸ Sign in…; the dev store's Settings Sync row has no sign-in door; never typed into) |
| H6 | Protection screen (account section signed out, passphrase section, twelve-words section, check-my-secret door, crossings "use castle…") | `Features/Protection/MobileProtectionScreen.swift`, `MobileProtectionDoors.swift` | ✓ `95-protection-screen.png`, `95-protection-screen-scrolled.png` |
| H7 | Set passphrase sheet (hint line, 12-char floor) | `MobileProtectionDoors.swift` (`MobileSetPassphraseSheet`) | NOT CAPTURED — optional; not opened (no Castle surface touched) |
| H8 | Twelve-words look panel | `MobileProtectionScreen.swift` (`MobileWordsLookPanel`) | NOT CAPTURED — optional; not opened (it shows the twelve words) |
| H9 | Secret check sheet | `MobileProtectionDoors.swift` (`MobileRoadSecretCheckSheet`) | NOT CAPTURED — optional; not opened |
| H10 | Crossing confirm sheet (use castle…) | `MobileProtectionDoors.swift` (`MobileRoadCrossingConfirmSheet`) | NOT CAPTURED — optional; “Use Castle…” not opened (no Castle move on this pass) |
| H11 | Pocket guide replace confirm alert | `MobileSettingsView.swift` | NOT CAPTURED — optional, Debug |
| H12 | TK2 Spike full-screen cover | `Spike/SpikeScreen.swift` | NOT CAPTURED — optional, Debug |

## I. Protection lobby family and failure faces (edge states — not reachable on a Standard, signed-out library in ordinary use)

| # | Screen / state | Owner | How it is reached | Capture |
|---|---|---|---|---|
| I1 | Road lock view (the lobby: passphrase / words / Face ID roads) | `MobileRoadFaces.swift` (`MobileRoadLockView`) | only in Castle, after a relock (on leaving / after time away); needs a passphrase set + "use castle…" | NOT CAPTURED — edge; Castle only (the library stays Standard) |
| I2 | Road interlude (rule 21 notice, key-file offer) | `MobileRoadFaces.swift` (`MobileRoadInterludeCard`) | after an unlock that owes it | NOT CAPTURED — edge |
| I3 | No-key-file sheet (rule 27) | `MobileRoadFaces.swift` (`MobileNoKeyFileSheet`) | a quiet open with no key file anywhere | NOT CAPTURED — edge |
| I4 | Library missing (three doors) | `Features/Protection/MobileLibraryMissingView.swift` | marker present, store gone | NOT CAPTURED — edge; destructive to stage |
| I5 | Pre-design store face + start-fresh confirm | `MobileRoadFaces.swift` | a pre-design store planted in the slot | NOT CAPTURED — edge |
| I6 | Store failure (retry) | `MobileStoreFailureView.swift` | an open that fails | NOT CAPTURED — edge |
| I7 | Signed-out Castle sheet · sign-out sheet · account confirm sheet | `MobileProtectionDoors.swift`, `MobileProtectionScreen.swift` | account states (never signed in here) | NOT CAPTURED — edge; never signed in |
| I8 | App-switcher snapshot redaction | `Features/Shell/SnapshotPrivacy.swift` | scene inactive | NOT CAPTURED — optional; XCUIScreen captures the springboard, not the app-switcher snapshot |

## J. Secondary passes (key screens only)

Study dark (`simctl ui appearance dark`, `ATLAS_VOICE=study`, prefix `dark-`) and Terminal light (`ATLAS_VOICE=terminal`, prefix `terminal-`), via `VM44CaptureVariants/test01_coreSet`: `V1-shelf` · `V2-quick-entry-focused` · `V3-library` · `V4-note-write` · `V5-editor-keyboard-bar` · `V6-formatting-strip` · `V7-settings`. Optional third: Study light at a large Dynamic Type size (prefix `xl-`) to show whether the "tiny font" scales.

**SECONDARY PASSES — RESULTS (2026-11-12).** Both run; 14 files in `screens/variants/`, named `<primary name>--<look>.png`, all checked by eye: `10-shelf-rest` · `21-quick-entry-focused-keyboard` · `30-library-rest-all` · `50-note-write-rest` · `60-editor-keyboard-bar-rest` · `61-editor-formatting-strip` · `90-settings-sheet`, each `--study-dark` and `--terminal-light`. `test01_coreSet`'s Settings shot missed in both looks (the pop back from the note had not landed); a settings-only method (`VM44CaptureVariants/test02_settings`) re-ran it once and caught both. Driver logs: `variants/walk-log-*.txt`. The optional XXXL-text look ran inside the primary pass instead (`96-*-xxxl-text`, walk-findings W19). Findings: walk-findings W24–W26.

## K. Recordings (short clips)

| Clip | Test | What it shows |
|---|---|---|
| `rec-01-tap-into-quick-entry.mp4` | `VM44CaptureRecordings/test01_tapIntoQuickEntry` | tap into the box → region expands → keyboard → typing |
| `rec-02-quick-entry-to-note.mp4` | `…/test02_quickEntryToNote` | typed box → `open ↵` → the note in Write |
| `rec-03-open-long-note.mp4` | `…/test03_openLongNote` | search hit → the ~40k-word note opens → fast scroll |
| `rec-04-scroll-library.mp4` | `…/test04_scrollLibrary` | Library scroll down and back |

**K results:** all four recorded (`rec-0N-….mp4` raw with the springboard lead-in; `rec-0N-…-trim.mp4` from just before the act). Measured from frames (`findings/W18-…`): the box → note open shows a ~0.7 s freeze mid-push (rec-02, 23.6–24.3 s in the raw clip); tapping into the box expands it with the keyboard inside one 0.5 s frame (rec-01, ~19.5 s); the 40k-word note opens with its text already drawn inside the push (rec-03, ~25 s — the later 5 s still is the test's own pause); the Library scroll is smooth at 1 fps sampling (rec-04).

## Findings from the code read (for the planners)

- **F1 — the phone cannot wear the sea-glass palette (or any palette).** Every token site on the phone calls the palette-less two-parameter resolver `VoiceTokens.resolve(voice:dark:)` (`VariorumMobileApp.swift:57`, `MobileShellView.swift:179`, `MobileSettingsView.swift:76`, `MobileWriteView.swift:180`; `MobileEditorStyle` likewise), which returns the voice's shipped "Classic" set; nothing in `VariorumMobile/` reads `theme_palette` / `Queries.ThemeSettings` / `PaletteTint`. The Mac's store-level sea-glass default (VX-710, `Queries.ThemeSettings.unsetStorePalette = .seaglass`) never reaches the phone.
- **F2 — the phone's voice is device-local and defaults to Terminal** (`Theme/MobileVoicePreference.swift`, UserDefaults key `io.lduarte.variorum.mobile.themeVoice`; LK2, by design), while the Mac's fresh-store default is Study. The walk sets Study per launch through the argument domain.
- **F3 — no Lock Now door anywhere on the phone.** The only lock roads are automatic (`Features/Protection/MobileRelock.swift`: lock when Variorum leaves the screen; lock after time away — Castle only). `MobileShellView.swift:95` still documents "`canLock` for the Lock Now door", but nothing renders one (the 13p notice bar it lived on "left with today's road at VX-329 U1"). The Mac has `ProtectionCopy.lockNowLabel` = "Lock Library Now".
- **F4 — no wings and no shelves on the phone; no Arrivals surface.** The shelf lists `Queries.bookshelf(db)` with no wing scope: every wing's books in one flat list (duplicate names across wings — legal per-wing twins — appear side by side, indistinguishable); Bookcase shelves are not rendered; the Library is likewise unscoped. Books mint in Home only (`MobileCreateBook.swift`, VX-816). Nothing in `VariorumMobile/` reads arrivals, so waiting arrivals can be neither seen nor judged on the phone.
- **F5 — the "tiny font" has a visible source:** nearly every chrome label (path lines, tab bar, quick-entry hint and field, filters, chips, Settings rows) is `tokens.small`; the quick-note `TextField` itself is `.font(tokens.small)` (`MobileQuickNote.swift`, box). To confirm against the captures.
- **F6 — the "pale band" candidate:** the keyboard bar is a `UIToolbar` installed as the text view's `inputAccessoryView` (`MobileKeyboardBar.swift`); on iOS 26/27 a toolbar draws its own full-width backdrop behind the glass buttons. Hypothesis for the captures (`60-…`, `61-…`) to confirm or kill.
- **F7 — Settings is a non-scrolling `VStack` + `Spacer`** (`MobileSettingsView.swift:89`): on a 6.3-inch phone the lower sections (Diagnostics, and the Debug rows) may fall off the bottom with no way to reach them. To confirm in `90-settings-sheet`.
- **F8 — temporary diagnostics ship in Release:** the "E1 settling experiment (temporary; mobile round 2)" — *Record edit trace* / *Edit trace…* — sits outside `#if DEBUG` in Settings. Debug-only leftovers still present: the TK2 Spike door + `Spike/` folder (its own header says "THROWAWAY; deleted at stage close"), the pocket-guide and 100k-fixture doors.
- **F9 — book screens on the phone are read-and-open only:** no row long-press in `MobileBookView` (no move, pin, remove-from-book, chapter assignment); the Book Details sheet deliberately omits extents, chapters/reorder, sort, filter, convert (its header says so).
