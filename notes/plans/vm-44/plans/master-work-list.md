# VM-44 — the master work list (draft, not canon)

One deduplicated list of every piece of work the seven audits found, each a candidate ticket. Merged from
`audit/A-shell-library-wings.md`, `B-books-family.md`, `C-the-note.md`, `D-protection-sync-launch.md`,
`E-ledger-ticket-reconciliation.md`, `F-performance-trace.md`, `G-visual-metrics.md`, read against `her-words.md`,
MobileSoul §1–5 and PhaseSizingGuidance. Nothing here is approved; umbrellas and waves are the orchestrator's with her.

**How to read a row.**
- **Sources.** `A·B7` = audit A, gap-matrix row B7. `A§3.2` = audit A, section 3.2. `D·D-21`, `G·T1` = those audits' own row ids. `F 2A` = audit F's suspect 2A. E rows are cited by the ledger or ticket id they reconcile (PL-27, VM-2, #274). "absorbs" names the existing ticket the row replaces.
- **Brain.** *face only* = the brain is already in Core or Shared · *hoist owed* = the brain sits in Mac-app code and must move to Shared first · *new brain needed* = nothing to reuse (including Core fixes) · *n/a* = a measurement or build setting.
- **Size.** S / M / L as the audits sized the face work, hoist included. Never a time.
- **Mockup.** yes = a designer must draw it before it can be ticketed for build.
- **Ruling.** The question id in `sitting-1-questions.md` the row waits on.
- **Her priority.** HIGH = the row directly delivers something `her-words.md` names. "HIGH (lag)" = a traced cause of one of the two lags she named (audit F §10 ranks them). Prerequisites of HIGH rows are not marked; `dependency-notes.md` lists them.
- **INFERRED** carries over from the audit wherever the reader inferred rather than read.

**Counts** are at the end, under the table.

---

## App shell

| Id | Title | Kind | Area | What is wrong or missing | Sources | Brain | Size | Depends on | Mockup | Ruling | Her priority |
|---|---|---|---|---|---|---|---|---|---|---|---|
| W-001 | A phone type scale with Dynamic Type, layered over the shared voice tokens | Improvement | App shell | All chrome is the Mac's fixed 11.5 pt caption size (241 of 352 type sites); in Terminal 347 of 352 sites ignore Dynamic Type; the phone has no type tokens of its own and the build runs about 15 % smaller than its ratified mockups. | G§0, §1.1–1.4, §7; A·A4; C·E21; D·D-63; E·VM-9, #194; MobileSoul §5.6 — absorbs VM-9's Dynamic Type part | new brain needed (a phone layer in Shared/Theme) | L | — | yes | no | HIGH |
| W-002 | A spacing scale and a 44-pt touch-target rule | Improvement | App shell | 19 padding values and 7 radii with no metrics constant; 103 of 107 tappable control sites are under 44 pt, 57 of them 24 pt or less. | G§2, §4.1, §7; A§2; B§2.4; C§2.1 | new brain needed | M | W-001 | yes | no | HIGH |
| W-003 | One set of phone controls: buttons, fields, sheet headers, segmented choices | Debt | App shell | Five separately built "calm buttons", three field builds, ten hand-rolled sheet headers, five rows of plain words standing in for segmented controls; no Picker, Toggle or List anywhere. Bare 11.5-pt text buttons are the "tiny affordances". | G§4.4 items 3–7, §5.1; A§0 item 4 | new brain needed | M | W-001, W-002 | yes | no | HIGH |
| W-004 | Small muted and faint text readable; field fills visible | Improvement | App shell | In Terminal light, muted ink is 3.0:1 and faint 1.9:1 (174 text sites, mostly at 11.5 pt); field and button fills are 1.05:1 against the room, so they read as nothing. The tokens are shared with the Mac. | G§4.2; D§6 | new brain needed (phone layer over shared tokens) | S | W-001 | yes | no | |
| W-005 | The phone wears the synced palette (sea-glass), not Classic | Improvement | App shell | Every token read goes through the palette-less two-parameter resolver, so the phone always shows Classic while her Mac shows sea-glass; the ★ uses accent instead of the star token. | A·H2; C·E20; E·PL-22b, #199 (ThemeStore), #195 MINOR 3; G§4.2, §4.3, Q5 — part of VM-7 | hoist owed (ThemeStore; PaletteDerivation is Shared) | M | — | no | LK-2 | HIGH |
| W-006 | Study as the phone's default voice | Improvement | App shell | The phone defaults to Terminal (14-pt mono body, lowercased chrome) on its own unsynced switch; a fresh Mac store opens in Study. | A·H1, Q6; C·E20; E·PL-42 (VX-306) b (W-14); G§4.3, Q4 | face only | S | — | no | LK-1, LK-6 | HIGH |
| W-007 | A tab bar with real hit areas, reachable from pushed screens | Improvement | App shell | Three 11.5-pt words about 14 pt tall, inactive words at 1.9:1; hidden on every pushed screen, so changing root means backing out first. The tab names (shelf vs the Mac's Bookcase) ride the same decision. | A·A3, §2; G·T1, §5.7, Q3; B§3 | face only | S | W-001, W-002 | yes | LK-5, SW-1 | HIGH |
| W-008 | Settings reachable from every root and from a note | Improvement | App shell | Only the Shelf's path line has a Settings door; Library, Starred and Write have none. | A·A5; D§3.5, §4(d) | face only | S | — | yes | no | |
| W-009 | No empty system bar above the app's own masthead | Improvement | App shell | Pushed screens set no title and keep the system bar, so Write, Book, Trash, Archive, Versions and Read show an empty bar with a back chevron above the app's masthead (INFERRED from code). | G§5.5 | face only | S | W-003 | yes | no | |
| W-010 | Visible doors for acts that are long-press only today | Improvement | App shell | Pin, Star and Delete on rows, every tag act, reference Remove and lens rename/delete have no visible affordance; no swipe actions exist; tag-manager rows can't be tapped; destructive acts sit only in context menus. | G§5.2, §5.3, §5.8, T103; B§2.3 | face only | M | W-003 | yes | no | |
| W-011 | Haptics on the main acts | Improvement | App shell | No haptic feedback anywhere: choosing a take, deleting, sealing, filing a quick note, the band's page settle. | G§5.6 | face only | S | — | no | no | |
| W-012 | One message line on the phone: refusals, offers, receipts | Feature | App shell | Each screen keeps its own red error line and muted receipt; receipts never fade; the note's status line keeps the last report; Protection's receipts wait until the screen reopens; `receipt_style` is never read. | A·I1, I3, H4, Q3; C·N20, §2.9; D·D-27 (P-VM8-8); E·PL-22c, VM-4 §5 item 5 | hoist owed (`AppSession.status` and StatusCenter are macOS-only) | M | W-003 | yes | SW-6 | |
| W-013 | Refusals in words, never raw error dumps | Bug | App shell | 69 sites print `String(describing: error)`; Finish on a gathering, Reopen on a sealed book, rename, unseal and star refusals show text like "That couldn't be done — wrongReadingKind(…)". | A·I2; B§0.6, I3, I4, M2; C·N1, N5, §2.11; E·PL-40c, #195 MINOR 4 — part of VM-12 | face only (Shared OpsRefusalTable) | M | — (lands best after W-012) | no | no | |
| W-014 | VoiceOver labels and an audit | Improvement | App shell | No audit has run; Read and Tutorial carry no accessibility modifiers; the custom surfaces (badge, peek strip, seams) need labels before strangers use the app. | D·D-64; MobileSoul §5.6 — part of VM-9 | face only | M | W-003 | no | no | |
| W-015 | The phone remembers which wing it stands in | Feature | App shell | `WingState.readScope` is hard-wired to nil on iOS, and the device wing memory and dead-wing check attach only on macOS. | A·D3, §3.1 item 1; E·PL-45 — part of VM-6 (4a) | face only (Shared WingState) | S | — | no | no | HIGH |
| W-016 | Hoist the Mac's wing brains to Shared | Debt | App shell | WingsModel, WingSwitcherBrain, WingFollow and the move/copy confirm live in the Mac app; WingsModel speaks through the macOS-only status center. | A·D1, D2, D8, D10, §3.1 | hoist owed | M | W-012 (or a callback) | no | no | |
| W-017 | The wing switcher: a dropdown that fits nine | Feature | App shell | No way to see or change wings; a native menu fits Home plus eight with the current one marked, plus manage doors. | A·D1, §3.1 item 4; B·Q3; her words — part of VM-6 (4a) | hoist owed | M | W-015, W-016 | yes | SW-1, SW-2 | HIGH |
| W-018 | A quick swipe between wings | Feature | App shell | The Starred · Shelf · Library band already owns horizontal drags on every root surface. | A·D2, §0 item 5, Q1; B·Q3; her words | hoist owed (WingSwitcherBrain) | M | W-017 | yes | SW-1 | HIGH |
| W-019 | "in ‹wing›" on every root and the "Now in …" receipt | Feature | App shell | The Mac shows the wing always (VX-552) and says where a switch landed. | A·D6, §3.1 item 6 | hoist owed (WingFollow.nowIn; words are Shared) | S | W-015, W-012 | yes | no | |
| W-020 | The app's wing follows the opened note | Feature | App shell | The Mac's WingFollow has no phone twin; what happens to open stacks on a switch is unruled. | A·D10, Q2 | hoist owed | S | W-016 | no | SW-2 | |
| W-021 | New, rename and delete-unless-empty wings; Move Everything to Another Wing | Feature | App shell | None of the wing management doors exist on the phone. | A·D7; B·N1 | face only (Core ops; Shared WingWords) | M | W-017 | yes | no | |
| W-022 | The quick-entry box holds many paragraphs and never loses prose | Bug | App shell | The box holds one wrapped paragraph and ⏎ opens it (the old rule); her lost-prose report is the evidence; R-13u-4 (⏎ files, ⇧⏎ new paragraph) has no phone mapping because the soft keyboard has no ⇧⏎. E rates it high. | A·G2, G3, Q5; E·PL-27, PL-23-3, PL-41d, round-2 4.6, §8.12–8.13; VX-911 — lead item of VM-7 | new brain needed (a soft-keyboard mapping; CaptureKeys is NSEvent-shaped) | M | — | yes | SW-4 | |
| W-023 | The quick-entry box's face: typed text at body size, a visible edge, copy that fits | Improvement | App shell | Typed text is 11.5 pt (82 % of the Mac's own quick entry) inside a 1.9:1 dashed outline about 34 pt tall; at 14 pt the placeholder no longer fits one line; the tab bar rides between box and keyboard. | A·G7; G§3.1–3.5, §5.9, §7 item 2; E·#194, PL-24b; her words "the box looks awkward" | face only | M | W-001, W-024 | yes | SW-3 | HIGH |
| W-024 | Re-derive the shelf's layout arithmetic for the new type | Debt | App shell | MobileShelfLayout assumes one line of 11.5-pt text is 14 pt (test-pinned) and drives the box's line cap and the writing floor from it. | G§1.4 item 5, §3.1 | face only | S | W-001 | no | SW-3 | |
| W-025 | Capture microsyntax (`{#tag}`, `{t:"…"}`) when a quick note files | Feature | App shell | No phone file references the shared capture microsyntax; her words: "this is more for quicknotes on the phone". | A·G4; E·PL-32, #127(b) — part of VM-7 | face only (Shared CaptureMicrosyntax) | S | W-022 | no | no | |
| W-026 | The title suggestion chip on the quick-entry box | Feature | App shell | The Mac offers a suggested title; the phone doesn't. | A·G5 | face only (Core NoteCardFace.suggestedTitle) | S | W-022 | yes | no | |
| W-027 | Where a phone quick note lands, said in a receipt | Improvement | App shell | Always Home, bookless, untagged, and no receipt. The Mac's quick-entry band lands in the current wing; the Mac's pad lands in Home wearing the quicknote tag (VX-841). | A·G6; E·round-2 §6.6 (F2), §4 item 9 | face only | S | W-034, W-012, W-022 | no | SW-5 | |
| W-028 | After a Castle re-lock the quick note writes through a stale session | Bug | App shell | The box binds to a session once, but every unlock makes a new one; after the first relock it mints, flushes the old registry and registers undo through the old session (mechanism traced; consequence not run). | F§12.1 | face only | S | — | no | no | |
| W-029 | Capture from outside the app | Feature | App shell | The Mac has its global quick-note pad; the phone has no widget, Shortcuts action or share-sheet door. | A·G8, Q9 | face only (Core importPost) | M | W-022 | yes | SC-2 | |
| W-030 | The phone's icon is the wrong mark | Bug | App shell | A floppy disk on a cloud, with empty dark and tinted slots; the brand mark is the sea-glass cards. | D·D-67 | n/a (assets) | S | — | no | no | |
| W-031 | The home screen probably reads "VariorumMobile" | Bug | App shell | No display name is set in the project (INFERRED). | D·D-68 | n/a (build settings) | S | — | no | no | |

## Library & sidebar

| Id | Title | Kind | Area | What is wrong or missing | Sources | Brain | Size | Depends on | Mockup | Ruling | Her priority |
|---|---|---|---|---|---|---|---|---|---|---|---|
| W-032 | One row anatomy per object (a note row, a book row) in every list | Improvement | Library & sidebar | A book row is built two ways (Shelf vs Library); a note row four ways (Library, book, Archive, Trash). | G§4.4 items 1–2 | face only | M | W-003 | yes | LS-1 | |
| W-033 | Every listing scoped to the current wing | Feature | Library & sidebar | Library, Pool, books, Starred, Archived, Trash, the tag manager and search read all nine wings at once; same-name books and tags from different wings look identical. | A·D4, D12, §3.1, E12, F1; B·A2; E·PL-45, PL-42 (13i-a) b — part of VM-6 (4a) | face only | M | W-015 | no | no | HIGH |
| W-034 | New notes, books and tags are born in the current wing | Feature | Library & sidebar | Every phone mint (new note, quick note, Today, new book, new tag) lands in Home. | A·D5, G6; B·N2; E·PL-69 | face only | S | W-015 | no | no | HIGH |
| W-035 | Wing-blind pickers mint twin tags, dead rule terms and refused book offers | Bug | Library & sidebar | A note's tag suggestions list every wing's paths and a tap mints a same-path twin in the note's wing; the gathering tag picker writes terms that resolve only in Home (dead terms); the add-to-book sheet offers other wings' books, which refuse with "move the note here first" — a road the phone lacks. | A·D11; B·B5, H2, §0 item 7 | face only (Core `allTags(_:wingID:)`, `effectiveWing(ofPost:)`) | S | — (each picker can read its own note's or book's wing) | no | no | |
| W-036 | Move or copy a note to another wing | Feature | Library & sidebar | No phone door; the Mac's confirm names the books the note leaves behind. | A·D8; C·N18 | hoist owed (WingDestinationSheet, WingNoteDoors) | M | W-016 | yes | no | |
| W-037 | The Library pages instead of silently stopping at 200 notes | Bug | Library & sidebar | The listing is the 200 most recently touched notes across all wings, cut with no marker; older notes are reachable only by title search. | A·B1; E§4 (unrecorded); F§5, §12.3 | face only (Core catalogNotesPage) | M | — | no | no | HIGH |
| W-038 | A flat, length-capped "first words for these notes" read in Core | Feature | Library & sidebar | The Mac's card read is Mac-local and grows with note length (36 ms at 20,000 blocks); Core's flat read returns each leading block whole, a memory risk on the phone (INFERRED). | A§3.2 | new brain needed | S | — | no | no | |
| W-039 | Hoist the card composition (LibraryCardName, SidebarRowLeads) | Debt | Library & sidebar | Written against the Mac's catalog hit; `Queries.library` doesn't select `profile`, so the phone can't apply the journal rule. | A§3.2, E13 | hoist owed | S | — | no | no | |
| W-040 | Library rows show first words and a preview, like Apple Notes | Feature | Library & sidebar | A row is one line: the stored title, else the raw entry date, then the same raw date again; no body preview. | A·B5, B6, B7, §3.2; E·PL-26; her words | face only (after W-038, W-039) | M | W-037, W-038, W-039, W-001 | yes | LS-1 | HIGH |
| W-041 | Stamps in the Mac's time words, the exact time reachable (rows and the note) | Improvement | Library & sidebar | Rows print the raw day key and only when the note is dated; the note's masthead shows no stamp at all. | A·B8; C·N15; E·PL-22d, PL-35 (stamp half), VM-22 — absorbs VM-22 | face only (Core TimeStampFace; LibrarySortFace is Mac-local) | M | W-040 | yes | no | |
| W-042 | Sort: title, the Mac's stamps, a remembered direction, offered beyond All | Improvement | Library & sidebar | Four stamps newest-first only, no title sort, only under All, and the sort resets every launch. | A·B16, B18; E·PL-22d | face only | S | W-037 | yes | no | |
| W-043 | The "edited on this day" filter | Feature | Library & sidebar | Absent; the Mac's calendar popover answers "notes edited on this day". | A·B19; E·PL-22d — part of VM-7 | face only (Core); the popover is Mac-local | M | W-037 | yes | no | |
| W-044 | A Timeline view of the Library | Feature | Library & sidebar | The phone has one plain list; the Mac has a Timeline mode over Core's timeline read. | A·B20 | face only (Core timelinePage) | M | W-037 | yes | no | |
| W-045 | Tag chips on Library rows | Feature | Library & sidebar | Tags are reachable only inside the note. | A·B9 | hoist owed (TagChips.load) | S | W-040 | yes | no | |
| W-046 | Archive a note from the phone | Feature | Library & sidebar | No phone door archives a note; the Archived room can only unarchive what the Mac archived. | A·B12; C·N7 | face only | S | — | no | no | |
| W-047 | Duplicate a note, with or without its tags | Feature | Library & sidebar | Neither duplicate door exists on the phone. | A·B13; C·N8; E·PL-48 (VX-383) | hoist owed (NoteDuplicate act, DuplicateCopy) | S | — | no | LS-4 | |
| W-048 | The note row menu as one table | Feature | Library & sidebar | Long-press offers Star and Delete only; the Mac's list is Rename, Star, Move/Copy to Wing, Export, Duplicate, Archive, Delete. | A·B11 | hoist owed (the Mac's row table) | M | W-046, W-047, W-036, W-233 | yes | no | |
| W-049 | Note multi-select and bulk acts | Feature | Library & sidebar | No selection mode in the Library; VM-31 says a design call comes first. | A·B14; E·VM-31, PL-13e, PL-64 — absorbs VM-31 | hoist owed (LibraryBulkRow) | M | W-048 | yes | no | |
| W-050 | The Archived room one tap away | Improvement | Library & sidebar | Its door is the last row under up to 200 notes and every book. | A·A7, §2 | face only | S | — | yes | no | |
| W-051 | The Pool shows notes a gathering holds, with a count and a reveal | Improvement | Library & sidebar | Bookless lists only loose notes; notes a gathering shows vanish with no count and no door. | A·E1; E·PL-43c | face only | S | — | yes | no | |
| W-052 | The Snippets room: all snippets, groups, search and the Mac's acts | Feature | Library & sidebar | One group at a time, no "all", no search, rows not tappable, no edit, delete, move to group or tags; block-tag editing held Mac-side by an earlier phone ruling. | A·E3, E4; E·PL-18c, §3 | hoist owed (the Snippets surface model) | M | — | yes | LS-3 | |
| W-053 | The Library's filter and room names follow the Mac | Improvement | Library & sidebar | Wording: "Bookless", "Scraps", "pool:", "+ new scrap", "bookless filter", "more info"; the Bookless empty line still describes a retired rule (VM-5 PROVISIONAL "No bookless notes — every note is in a book."). | A·E2, §2; B·H8; C·N19; E·VM-12, VM-5 handoff | face only | S | — | no | LS-3 | |
| W-054 | The Starred page: per wing, untitled rows named, a design pass | Improvement | Library & sidebar | An unstyled list of every wing's stars; untitled notes show a date; the kind is a faint word; starred books on the Shelf float with no ★. | A·E12, E13; B·A11; E·PL-63, PL-61 | hoist owed (SidebarRowLeads via W-039) | M | W-033, W-039 | yes | no | |
| W-055 | Trash multi-select | Feature | Library & sidebar | The Mac's VX-671 selection has no phone face. | A·E9; E·PL-64 | face only (Shared RecoveryActs) | S | W-049 | yes | no | |
| W-056 | Trash sweep: empty blocks with no history | Feature | Library & sidebar | The Mac's sweep door has no phone twin. | A·E10; E·VM-39 — absorbs VM-39 | face only | S | — | no | no | |
| W-057 | The Trash shows "empty" before it loads | Bug | Library & sidebar | The empty line draws before the first value arrives. | A·E11; E·VM-33 — absorbs VM-33 | face only | S | — | no | no | |
| W-058 | The Private mark on the phone | Feature | Library & sidebar | A note or book she marked Private on the Mac shows no sign of it on the phone; no door sets or clears it. | C·N12; D·D-59, D-60; E·PL-52, PL-69; B·J3 | face only (Core store truth); the mark's face is Mac-local | S | — | yes | LP-8 | |

## Search

| Id | Title | Kind | Area | What is wrong or missing | Sources | Brain | Size | Depends on | Mockup | Ruling | Her priority |
|---|---|---|---|---|---|---|---|---|---|---|---|
| W-059 | Body-text search over the index the phone already keeps | Feature | Search | Search is the old title/date catalog: 20 per kind, every wing, scrap hits dropped, no passages, an 11.5-pt hand-rolled field with no cancel; the FTS5 index is maintained but never queried. | A·C1, C2, C3, C8; E·PL-2, PL-47b, PL-49 (VX-83); VX-819; G§5.4 | hoist owed (LibrarySearchQuestion, LibrarySearchModel) | L | W-015, W-060 | yes | LS-2 | HIGH |
| W-060 | Hoist the Mac's search model to Shared | Debt | Search | LibrarySearchQuestion and LibrarySearchModel are pure (Foundation/GRDB/Observation/Core) but Mac-local. | A·C3 | hoist owed | M | — | no | no | |
| W-061 | Search facets: archived, commits, a Blocks scope | Feature | Search | None of the Mac's facets; no Blocks scope; the Archived room can't be searched. | A·B3, C4, C9 | face only (Core) | M | W-059 | yes | no | |
| W-062 | `#tag` narrowing and the tag offer chip | Feature | Search | Absent. | A·C5 | face only (Core) | M | W-059 | yes | no | |
| W-063 | The search order door | Feature | Search | Absent. | A·C6 | face only (Core) | S | W-059 | no | no | |
| W-064 | A search hit lands at its block with the match selected | Feature | Search | A block hit opens its note at the top. | A·C7; E·PL-47b | face only (Shared SearchLanding) | M | W-059, W-132 | no | no | |
| W-065 | Search inside a book | Feature | Search | The Mac's book masthead has a bare 🔍; the phone has none. | B·C13 | face only | M | W-059 | yes | no | |
| W-066 | A ⌘K equivalent | Feature | Search | The Mac's palette has no phone road. | A·C10, Q8 | hoist owed (the capability registry) | M | — | yes | SC-3 | |

## Books

| Id | Title | Kind | Area | What is wrong or missing | Sources | Brain | Size | Depends on | Mockup | Ruling | Her priority |
|---|---|---|---|---|---|---|---|---|---|---|---|
| W-067 | The Bookcase on the phone: shelves, solo and All, Unshelved, Welcome, the census | Feature | Books | A flat list of every wing's books in a scroll region of about eight rows, with + New Book as its last row; the shared Bookcase brain is never used; the path line counts gatherings as books. | B·A1, A3, A4, A6, A7, A8, A11, §2.1; E·PL-45 — part of VM-6 (4a) | face only (Shared BookcaseBoard) | L | W-033, W-003 | yes | BK-1, SW-3 | |
| W-068 | Books sort a–z (digit-aware) or by last edited | Bug | Books | Starred, then journal-trait books, then the rest, case-sensitive and not digit-aware ("Zebra" before "apple", "Book 10" before "Book 2"); no order menu. | B·A5 | face only (Shared BookcaseBoard has the rule) | S | — | no | no | |
| W-069 | Shelf management | Feature | Books | No phone code reads or writes a shelf: no create, rename, glyph, delete, reorder, move a book to a shelf. | B·A12, A13 | face only (Core) | M | W-067 | yes | BK-7, BK-1 | |
| W-070 | One book menu on every book row | Feature | Books | A book's acts are split between the long-press and Details; Library book rows have none; Starred rows only Unstar. | B·A15, §2.3 | hoist owed (BookRowMenu, BookStateDoorSet, BookArchiveDoorSet) | M | W-010 | yes | no | |
| W-071 | Retire "Pin to Shelf Top" (it is the star) | Bug | Books | Two doors write one star, so pressing Pin flips Star's label too. | B·A16, M1; E·PL-45, PL-61 | face only | S | — | no | no | |
| W-072 | The New Book sheet: name focused, born on the solo'd shelf | Improvement | Books | The name field isn't focused on arrival; the mint passes no shelf. | B·B1, A13 | face only | S | W-067, W-034 | no | no | |
| W-073 | Say "gathering", never "smart", everywhere | Improvement | Books | Wording: shelf rows, the create sheet, the membership sheet, and the delete door, confirm and receipt ("Delete Book…" on a gathering); the Trash's empty-name placeholder uses the kind-only word. | B·A9, B4, K2; E·PL-62 a (see Contradictions settled) | hoist owed (BookStateCopy.deleteVerb) | S | — | no | no | |
| W-074 | Create a gathering with the full rule editor; edit a living book's rule | Feature | Books | The phone's "Smart Book" offers tags only, any-of or all-of; no star, NOT or nesting; rules can't be edited after; an empty save doesn't refuse. | B·B3, F2, F3; E·PL-43 b, PL-44 — part of VM-6 (4b) | hoist owed (RuleEditorModel, RuleEditorCopy) | L | W-035 | yes | BK-6 | |
| W-075 | The book's modes: Index, Book, Read ▸ Pages | Feature | Books | The phone has the contents list and Read ▸ Scroll only. | B·C2 | hoist owed | L | — | yes | BK-2 | |
| W-076 | The order dial in a book | Feature | Books | No read-time order override or save. | B·C3 | face only (Core setReadingSort) | S | — | yes | no | |
| W-077 | Reorder notes in a book | Feature | Books | No Move Up/Down or drag; the Mac stops at the pinned group's edge. | B·C4, A14 | hoist owed (postDropPlan) | M | — | yes | no | |
| W-078 | A note's menu inside a book | Feature | Books | Note rows are tap-only: no pin, Move to Chapter, Remove/Release or Archive. | B·C5, §2.5 | hoist owed (the Mac's table) | M | W-077, W-081, W-091 | yes | no | |
| W-079 | Untitled entries in a book read as the same raw date twice | Bug | Books | "2026-11-12 … 2026-11-12": two same-day entries can't be told apart. | B·C6, Q12; her words | face only (after W-039) | S | W-039 | yes | LS-1 | HIGH |
| W-080 | The book's empty states, one per kind | Improvement | Books | One sentence for books and gatherings alike. | B·C7 | hoist owed (BookEmptyState) | S | — | no | no | |
| W-081 | Chapters: rename, delete and restore, reorder | Feature | Books | Only create exists. | B·D2, D3, D4 | face only (Core) | M | — | yes | no | |
| W-082 | Put a note in a chapter | Feature | Books | A chapter made on the phone can only be filled from the Mac. | B·D5; E·VM-4 §5 item 5 (chapter door) | face only (Core) | S | W-081 | yes | BK-10 | |
| W-083 | Unfiled notes under an "unfiled" header | Improvement | Books | Unfiled entries trail with no header. | B·D6 | face only | S | — | no | no | |
| W-084 | The book's doors in chrome, not at the foot of a long list | Improvement | Books | + New Note, + New Chapter and their refusals sit below up to 300 rows. | B·C8, §2.5, §3 | face only | S | — | yes | no | |
| W-085 | New notes in a journal book are dated entries | Bug | Books | The phone mints an undated note in every book, the daily Journal included, so the Journal fills with dateless rows. | B·C9, §2.6 | hoist owed (BookStructureModel's journal composition) | S | — | no | no | |
| W-086 | New Entry in the daily Journal (several a day) | Feature | Books | The Today door opens the day's first entry; nothing mints a second. | B·L2; E·PL-68 | face only (Core newJournalEntry) | S | W-085 | yes | BK-9 | |
| W-087 | New note in a gathering (tagged to fit its rule) | Feature | Books | The doors show only on books. | B·C10; E·PL-43 e | hoist owed (GatheringNoteDoor) | M | — | no | no | |
| W-088 | Step to the previous or next note in a book | Feature | Books | A note opened from a book doesn't know its book: no "note N of M", no next or previous. | B·C11; E§4 item 6 (VX-724), VX-563 | hoist owed | M | — | yes | BK-5 | |
| W-089 | The Book Panel on the phone | Feature | Books | The masthead's Books sheet lists books but has no contents, position, switcher or pins. | B·C12 — VM-6's named sitting item | hoist owed (BookPanelModel) | L | W-088 | yes | BK-5 | |
| W-090 | Read surfaces open Write at the tapped block | Feature | Books | The book Read opens a note by id only, at its top. | E·PL-19c, PL-21-4 | face only (Shared LandingTarget) | M | — | no | no | |
| W-091 | Pin a note to the top of a book; the pin mark | Feature | Books | A Mac-pinned note can't be unpinned on the phone; the pinned group sits at the top unexplained. | B·E2, E3, E4; E·PL-71 — part of VM-42 | face only (Core) | S | — | no | BK-4 | |
| W-092 | The collect receipt and "(archived)" marks in pickers | Bug | Books | The receipt names no star on a ★-only collect and overclaims on an archived gathering; archived books appear unmarked in pickers. | B·F4, F5; E·VM-21, PL-49 (VX-381) — absorbs VM-21 | face only | S | — | no | no | |
| W-093 | Bind a gathering into a book | Feature | Books | Absent. | B·F6; E·PL-43 e | hoist owed (BindCopy) | M | W-070 | no | no | |
| W-094 | Make a book from a gathering | Feature | Books | Absent. | B·F7 | hoist owed (spawnBook) | M | W-070 | no | no | |
| W-095 | Save a book's filter as a gathering | Feature | Books | Needs a book filter surface first. | B·F8 | face only (Core) | M | — | yes | no | |
| W-096 | One settings pane for a book or gathering, with the Collecting sentences | Feature | Books | "Book Details" carries rename-by-tapping-the-name (undiscoverable), Finish/Reopen, Use as Daily Journal and Delete; no Collecting sentences; empty for an archived book; no pause line. | B·I1, I2, I12, I13 — part of VM-6 (4c) | hoist owed (BookSettingsModel/Face, CollectingCopy) | L | W-003 | yes | no | |
| W-097 | The outflow chooser | Feature | Books | Absent. | B·I6; E·PL-44 | hoist owed (OutflowChooser) | M | W-096 | yes | no | |
| W-098 | The intake dial, a gathering's hide-owned, the journal trait | Feature | Books | Three book-settings rows the phone lacks. | B·F9, F11, I8 | hoist owed (HideOwnedChoice) | S | W-096 | no | no | |
| W-099 | A book's word target and note limit | Feature | Books | Deferred at LK5. | B·I7, Q10 | face only (Core) | S | W-096 | no | BK-8 | |
| W-100 | Move a book to another wing | Feature | Books | The book settings' wing row ("In ‹wing›. Moving the book takes its notes with it.") has no phone face. | A·D9; B·N1, I11 | face only | M | W-015, W-096 | yes | no | |
| W-101 | Arrivals: the door and count, the review, why it waits | Feature | Books | Nothing on the phone shows arrivals — from her own phone tags and stars, the Journal's door, or an AI's proposals; no count on a book row; the phone never says a tag seated or belled a note. | B·G1–G4, A10, F10, §0 item 2, §2.9; E·PL-43 a, PL-71 — absorbs VM-42 with W-091 | hoist owed (ArrivalsCopy, ArrivalsReviewCopy, BookArrivalsModel) | L | — | yes | BK-3 | |
| W-102 | Copy in or Move in on a waiting row | Feature | Books | The ownership arms on a waiting row are absent. | B·G5 | hoist owed (MembershipChoiceCopy) | M | W-101, W-108 | yes | no | |
| W-103 | Judging arrivals in bulk | Feature | Books | Add all, Dismiss all, Add N, Dismiss N; the Mac's keyboard walk needs a touch twin. | B·G6 | hoist owed (ArrivalsBulk) | M | W-101, W-049 | yes | BK-3 | |
| W-104 | Archived waiters and the book's archived line | Feature | Books | Absent. | B·G7 | hoist owed (ArchivedLineCopy) | M | W-101 | yes | no | |
| W-105 | Finish dismisses waiting arrivals without asking | Bug | Books | Finish acts at once; the operation dismisses every waiting arrival in its transaction — judgments she never saw. | B·G8, §0 item 3 | hoist owed (BookStateCopy.finish, waitingLine) | S | — | no | no | |
| W-106 | Finish and Reopen: the right caption, not on gatherings, worded on a sealed book | Bug | Books | "Freezes its notes" is wrong (text stays editable); Finish is drawn on gatherings then refuses; Reopen on a sealed book refuses raw. | B·I3, I4 | face only | S | W-013 | no | no | |
| W-107 | The Today door's words in one shared home | Bug | Books | The phone keeps a stale fork of the Mac's journal words: "smart book", "reopen it" on a sealed Journal (Reopen refuses), the waiting note names no book, no comes-back receipt. | B·G9, L5, L6, §2.8; E·PL-44 b | hoist owed (JournalBooks.shelvingNote, comesBackReceipt, JournalWaitingCopy) | S | — | no | no | |
| W-108 | The membership choice sheet (copy in, or move in) | Feature | Books | Ownership refusals explain a ceremony the sheet can't perform. | B·H3; E·PL-44 — part of VM-6 (4c) | hoist owed (MembershipChoiceCopy) | M | — | yes | no | |
| W-109 | Remove says "Release" on an owned book and where the note went; a gathering row's "remove #tag" | Improvement | Books | Always "remove"; the receipt never says the note went to the Pool; gathering rows carry no remove. | B·H4, H5 | face only | S | — | no | no | |
| W-110 | Diverge is offered on gathering rows, then refuses | Bug | Books | A door drawn where it can't act. | B·H6 | face only | S | — | no | no | |
| W-111 | Manage Notes (add many notes to a book) | Feature | Books | Absent. | B·H7 | hoist owed | M | W-049 | yes | no | |
| W-112 | Seal and unseal a book | Feature | Books | Absent; the confirm lists forks and sealing finishes too. | B·I4; E·PL-44 | face only (Core) and hoist owed (BookStateCopy) | M | W-096 | yes | no | |
| W-113 | Own a book's notes; stop owning | Feature | Books | Absent; the confirm lists the copies. | B·I5; E·PL-44 | face only (Core) and hoist owed (copy) | M | W-096, W-108 | yes | no | |
| W-114 | The badge family: owned, shared, sealed told apart from finished | Feature | Books | No owned or sealed face anywhere; one " ✓" for both finished and sealed; the `ownership_badges` switch is unread. | B·J1, J2; A·B10 | hoist owed (OwnershipBadgeCopy, OwnershipBadgeFace) | M | — | yes | no | |
| W-115 | An owned book's two delete choices | Feature | Books | Book-only delete, worded "Its notes stay in the library." | B·K3 | face only (Core) and hoist owed (copy) | S | W-113 | no | no | |
| W-116 | Archive any book or gathering | Feature | Books | Only the daily Journal can be archived on the phone. | B·K4; E·PL-47 (13i-e) — part of VM-6 (4d) | hoist owed (BookArchiveDoorSet) | S | W-070 | no | no | |
| W-117 | Archived books in the Archived room | Feature | Books | The room's books group returns nothing, so archived books are invisible on the phone (her walk once mistook this for a sync bug). | A·E7; B·K5, K6; E·PL-47 (13i-e) — part of VM-6 (4d) | face only (Core archivedReadings) | M | W-050 | yes | no | |
| W-118 | Duplicate a book | Feature | Books | Absent. | B·K8 | hoist owed (DuplicateBookCopy) | S | W-070 | no | no | |
| W-119 | Delete beside Archive on the daily Journal | Improvement | Books | Delete is hidden on the Journal "until the mobile catch-up" (VX-436 was Mac-first). | B·L4; E·PL-68 | face only | S | — | no | no | |
| W-120 | A starred archived book is a dead end | Bug | Books | It opens from Starred with an empty Details sheet and no way to unarchive. | B·M3 | face only | S | — | no | no | |
| W-121 | The Welcome shelf arrangement on the first write | Feature | Books | The phone never arranges the seeded content on a Welcome shelf. | B·O1; E·#178 | face only (Shared SampleLibraryWelcome) | S | W-067 | no | no | |
| W-122 | A book's Trash row says "and N notes" | Improvement | Books | Drawn only on the Mac. | B·K7 | face only (Shared RecoveryCopy) | S | — | no | no | |
| W-123 | The starter Journal still promises "One day, one entry." | Improvement | Books | Wording: VX-797 allows several entries a day. | B·L7 | face only | S | — | no | no | |

## Editor

| Id | Title | Kind | Area | What is wrong or missing | Sources | Brain | Size | Depends on | Mockup | Ruling | Her priority |
|---|---|---|---|---|---|---|---|---|---|---|---|
| W-124 | Keystrokes during a divide or merge can corrupt the store | Bug | Editor | The edit gate never reads the structural flight; a keystroke or autocorrect in the settle window can resurrect a moved half or land in a released block. | C·E10, §2.5; E·VM-2, PL-40d — absorbs VM-2 | face only | S | — | no | no | |
| W-125 | Return as a structural act on the phone | Feature | Editor | Return mid-note is a newline inside the block; only Return at the very end opens a new paragraph; the shared TypedReturn has no phone caller; no in-block newline door. | C·E3, E4; E·PL-21-1, PL-31; VX-806 — part of VM-7 | face only (Shared TypedReturn) | M | — | yes | NT-1 | |
| W-126 | The per-note "newlines make blocks" switch | Feature | Editor | The phone honours the note's segmentation but can't set it. | C·E5 | hoist owed (SegmentationFaceCopy) | S | W-125 | yes | NT-1 | |
| W-127 | "Make every newline a block" and "Split this block at its newlines" | Feature | Editor | The repair a phone user most needs today, given Return. | C·E6; E·PL-21-2 | face only (Core) | S | — | no | no | |
| W-128 | Backspace at a paragraph's start merges; backspace beside an empty block removes it | Feature | Editor | ⌫ at a block's start refuses with a sentence naming Merge with Previous; an empty block can't be removed by ⌫. | C·E7; E·PL-24e, PL-40a, #111(c), VM-1 | face only (Shared SeamCarvePlan) | M | — | no | NT-2 | |
| W-129 | A cross-block edit says where every block went | Improvement | Editor | The receipt is a bare Undo with no words. | C·E8, B19; E·PL-23-1 | hoist owed (CrossBlockEditCopy) | S | W-012 | no | no | |
| W-130 | Paste as plain text | Feature | Editor | No paste-plain door. | C·E14; E·PL-24a, VM-1 | face only (Shared PlainPaste) | S | — | no | no | |
| W-131 | Smart quotes, dashes and spellcheck agree with the Mac | Improvement | Editor | The phone writes curly quotes and em dashes the Mac's Write never would; no spellcheck setting or one-shot check. | C·E15, E16, §2.15; VX-438 — absorbs VX-438 | hoist owed (SpellcheckLevel) | S | — | no | NT-9 | |
| W-132 | Find to the decided rules, and takes-aware replace | Feature | Editor | Find is the system navigator with replace switched off; U7's sameness and chosen-takes rules are unverified. | C·E17; E·PL-1d, PL-39-1, #199 (FindReplaceGate) | hoist owed (FindReplaceGate) | M | — | yes | NT-14 | |
| W-133 | Block seams and the editing indicator drawn from the synced settings | Feature | Editor | No phone reader of either setting. | C·E22; E·PL-21-5 | face only | S | W-212 | no | no | |
| W-134 | The keyboard bar without the pale band | Improvement | Editor | A full-width opaque surface band sits behind three iOS 26 glass circles — two backgrounds for three buttons (INFERRED to be her "pale band"). | G§3.4, §7 item 3, Q2; A§4; C§2.3; her words | face only | S | — | yes | LK-4 | HIGH |
| W-135 | The formatting strip's acts large enough to press | Improvement | Editor | Eleven acts at 28×38 pt, her R22/R25 trade made knowing it breaks 44. | C·E12; G·T56, Q1 | face only | M | W-134 | yes | LK-3, LK-4 | HIGH |
| W-136 | Block acts reachable with the keyboard down | Improvement | Editor | Block ⋯ needs the caret and the keyboard (or the edit menu); reading with the keyboard down there's no block door except ⑂ and ●n. | C§3, §2.4 | face only | M | — | yes | no | |
| W-137 | Divide presets on a fanned block | Feature | Editor | Keep-on-top only. | C·B3; E·PL-21-3 | face only (Core) | M | — | yes | NT-7 | |
| W-138 | Merge with next, or select blocks then merge | Feature | Editor | Only Merge with Previous; no merge among the block list's bulk acts. | C·B5, B17; E·VM-4 §5 item 5 (merge vocabulary) | face only | M | — | yes | NT-8 | |
| W-139 | Retire the phone's forked brains | Debt | Editor | The carry-all merge, the callout palette's private hex table, and the take-structure and block-selection copy are phone copies of Mac brains. | C·B5, C7; G§4.2; E·VM-1 | hoist owed (FannedDefaults and the rest) | M | — | no | no | |
| W-140 | New Block Below's receipt offers Undo | Bug | Editor | The stack holds "New Block" since R-13u-3, but the receipt offers no Undo and its comment says the opposite. | C·B9; E·PL-23-4 | face only | S | — | no | NT-12 | |
| W-141 | Reorder blocks | Feature | Editor | No way to move a paragraph except cut and paste, which mints new blocks and loses identity. | C·B12 | face only (Core reorder) | M | — | yes | no | |
| W-142 | Move a block to Snippets | Feature | Editor | Absent. | C·B13 | face only (Core) | S | W-052 | no | LS-3 | |
| W-143 | Block tags | Feature | Editor | Absent on the phone; whether they exist at all is her open question (VX-128). | C·B15; VX-128 | face only | M | — | no | NT-15 | |
| W-144 | The block list's bulk bar: merge, split at newlines, tag, move | Feature | Editor | Select and delete only. | C·B17, M5 | face only | M | W-138, W-127 | yes | NT-8 | |
| W-145 | The undo door mis-speaks and its Redo can act on a different entry | Bug | Editor | A quiet press says "Undid: X" and offers a Redo that acts on another entry (Urgent on Linear). | C·B18; E·VM-16, PL-55 — absorbs VM-16 | face only (Shared StructuralUndoCopy) | S | — | no | no | |
| W-146 | The undo warning says "It is saved first" | Improvement | Editor | Wording: the Mac says "committed". | C·B18; E·VM-20, PL-56 — absorbs VM-20 | face only | S | — | no | no | |
| W-147 | Probe: do fan badges pile at block 1 on long notes | Bug | Editor | INFERRED unlikely from the badge's geometry; the probe is owed. | C·T1; E·VM-17 — absorbs VM-17 | face only | S | — | no | no | |
| W-148 | Native sheets for takes, comments and block history | Improvement | Editor | Three hand-built overlays: fixed top, no grabber, no swipe to dismiss, not modal for VoiceOver, a 24-pt Done. | C§2.8; G§4.5, T57, T64, T69 | face only | M | W-003 | yes | no | |
| W-149 | A calmer note masthead | Improvement | Editor | Four 14×14 icon doors in faint ink, six 14-pt-tall chips 4 pt apart, and a status line that never fades and pushes the prose down. | C§2.1, §2.9; G·T38–T50, §7 item 4 | face only | M | W-001, W-002, W-012 | yes | no | HIGH |
| W-150 | The note ⋯ sheet carries the Mac's note acts | Feature | Editor | Five rows today; the Mac's note menu adds Duplicate ×2, Export, Private, Make every newline a block, the date picker, shift date, Move/Copy to Wing, Archive. Composition only: each act is its own row. | C§2.10 | face only | M | W-046, W-047, W-036, W-127, W-153, W-154, W-058, W-233 | yes | no | |
| W-151 | Rename a note in a real field, with room for the title | Improvement | Editor | A system alert; errors print raw; the title is one line (about 30 characters of room). | C·N1; E·PL-24b | face only | S | W-149 | yes | no | |
| W-152 | Title quickfill | Feature | Editor | The Mac offers the first line or date faintly; the phone doesn't. | C·N2 | hoist owed (TitleQuickfill) | S | W-151 | no | no | |
| W-153 | A calendar for the entry date | Improvement | Editor | She types "2026-08-09" into an alert. | C·N3, §2.14 | face only (Core EntryDatePickerDay) | S | — | yes | no | |
| W-154 | Shift a dated note's day | Feature | Editor | Absent. | C·N4; B·L3; E·PL-68 | face only (Core shiftEntryDate) | S | W-153 | no | no | |
| W-155 | The note seal's word | Improvement | Editor | Wording: the phone says "Lock Note" and "unseal" drifts in shared copy; the Mac and books say Seal; "lock" also names take locks and the library lock. | C·N5, Q4; E·VM-12 ("unseal" drift) | face only | S | — | no | NT-4 | |
| W-156 | Copy for AI | Feature | Editor | Absent; possibly not applicable, since the phone has no AI door. | C·N11 | hoist owed (CopyForAI) | S | — | no | LP-8 | |
| W-157 | Star a note from inside it | Feature | Editor | Starring is a Library long-press only. | C·N13 | face only | S | — | no | no | |
| W-158 | Word count and the note's word target | Feature | Editor | Absent. | C·N14; E·PL-35 | face only (Shared TextMetrics) | S | W-149 | yes | no | |
| W-159 | A Read mode for one note | Feature | Editor | The phone's Read exists for books only. | C·M2; E·PL-18b, PL-19a, PL-38b | face only (Shared FlowParagraph; the paged view is Mac-local) | M | — | yes | NT-6 | |
| W-160 | A note's modes: the mode row, per-note memory, one current block | Feature | Editor | No mode row, no current-block memory, no arrival flash. | C·M1; E·PL-19a, PL-19b, PL-39-2/3 | face only | M | W-159 | yes | NT-6 | |
| W-161 | The date chip reads a field the view doesn't observe | Bug | Editor | It refreshes only because the title changes in the same pass. | F§12.5 | face only | S | — | no | no | |
| W-162 | After the quick-note hand-off the caret lands at the start | Bug | Editor | She must tap to the end to keep writing. | F 2F, §12.2 | face only | S | W-022 | no | no | |
| W-163 | A Release-side identity-boundary belt | Debt | Editor | Both platforms carry only the Debug oracle. | E·round-2 §6.7 | new brain needed | S | — | no | NT-17 | |
| W-164 | The editor debt backlog | Debt | Editor | One editability authority, the silent keyboard drop, the MINOR/NIT backlog, the flush-caller sweep, the `.opening` arm check; its wording items ride W-053 and W-013. | C·E1; E·VM-12, round-2 §3 row 5 — absorbs VM-12 | face only | M | — | no | no | |
| W-165 | Closing the comments sheet keeps a half-typed comment | Bug | Editor | Close clears the field; only a refused draft survives. | C·C2, Q10; E·VM-18 — absorbs VM-18 | face only (Shared CommentDraftPark) | S | — | no | NT-11 | |
| W-166 | The comment placeholder sits at the text origin | Bug | Editor | A hand-placed label at (8, 10). | C·C3; E·VM-14 — absorbs VM-14 | face only | S | W-168 | no | no | |
| W-167 | "Delete forever…" on a deleted comment | Feature | Editor | The fold and Restore exist; the purge door doesn't. | C·C4; E·PL-46 (VX-179) | face only | S | — | no | no | |
| W-168 | The comments panel's writing grammar | Improvement | Editor | Not the Mac's one writing surface (click anywhere to add, edit in place). | C·C1; E·PL-25 | hoist owed (CommentComposition) | M | W-148 | yes | no | |
| W-169 | The comment draft field is probably under the keyboard | Bug | Editor | The comments overlay has no keyboard handling (INFERRED; device check owed). | C·C6; G§5.9 | face only | S | — | no | no | |
| W-170 | The comment marker and callout glyph follow the gutter rule | Improvement | Editor | ●n sits at the last line's end at 10.5 pt; the callout emoji takes room inside the text measure; the Mac draws both in the gutter and never moves the measure (VX-782). | C·C5; E·PL-10 (i)(ii), round-2 §6.2, §4 item 9 | face only | S | — | yes | NT-10 | |
| W-171 | This note's tray as two views with a filter | Improvement | Editor | The phone stacks sections behind a chip called "blocks"; the leaving explainer renders the shrunk Mac sentence. | C·R1; E·PL-21-6, PL-14(e) | hoist owed (TrayFilter) | M | — | yes | no | |
| W-172 | Light/dark flip leaves stale borders | Bug | Editor | Borders on take cards, the takes pill and the comment draft resolve once, with no trait-change hook (INFERRED). | G§4.3 | face only | S | — | no | no | |
| W-173 | Text selection: holding makes the page scroll up | Bug | Editor | Her round-2 report ("holding it down makes you scroll upwards, the exact opposite"); the one-minute experiment never ran (E rates it high). | E·round-2 batch 9(e), VM-13 | face only | M | W-260 | no | no | |

## Takes & Lenses

| Id | Title | Kind | Area | What is wrong or missing | Sources | Brain | Size | Depends on | Mockup | Ruling | Her priority |
|---|---|---|---|---|---|---|---|---|---|---|---|
| W-174 | Branch any take from its card | Feature | Takes & Lenses | Branch acts only on the displayed take; she must swipe to it first. | C·T5 | face only | S | — | no | no | |
| W-175 | Copy all takes | Feature | Takes & Lenses | Absent. | C·T6; E·PL-1c, PL-10c, #199 (TakeClipboard) | hoist owed (TakeClipboard) | S | — | no | no | |
| W-176 | A blank take chosen at once | Feature | Takes & Lenses | Absent; low value. | C·T7 | face only | S | — | no | no | |
| W-177 | Diff a take against the chosen one | Feature | Takes & Lenses | Absent; Compare-class. | C·T8, Q11 | hoist owed (LineDiff) | M | — | yes | SC-1 | |
| W-178 | The lens-aware show filter on takes | Feature | Takes & Lenses | Absent. | C·T10; E·PL-53 (VX-168) | face only (Core LensTakeFilter) | M | — | yes | NT-13 | |
| W-179 | AI-labelled take labels shortened the Mac's way | Improvement | Takes & Lenses | The Mac's truncation face is unused on the phone. | C·T12 | face only (Core TakeLabelFace) | S | — | no | no | |
| W-180 | Name a commit as it's made; rename it later; one filing per press | Feature | Takes & Lenses | Commit is unnamed, and a double tap makes two. | C·H1, H2; E·PL-28b | face only (Core renameCommitPoint, SavepointName) | S | — | yes | NT-5 | |
| W-181 | Restores insure the words they replace | Bug | Takes & Lenses | Her ruling (#274) is unwired on the phone: a restore replaces the buffer with no savepoint of what it replaced. | C·H4; E·VM-43, #274 addendum 2 — absorbs VM-43 | face only | S | — | no | no | |
| W-182 | Bring back a commit as a take | Feature | Takes & Lenses | Absent. | C·H5; E·PL-62 b | face only (Core) | S | — | no | no | |
| W-183 | The commits face: reading pane, all-takes rail, compare against now | Feature | Takes & Lenses | The phone keeps the Block History face the Mac retired, two levels deep behind a take card's ⋯, while Commit lives in the block ⋯. | C·H3, H6, §2.7; E·VM-41, PL-70, PL-53 (VX-143), PL-19e, #192 — absorbs VM-41 with W-184 | hoist owed (CommitsFaceModel, CommitsFaceCopy) | L | — | yes | NT-5 | |
| W-184 | The lineage face: the family, Put back, bring back from lineage | Feature | Takes & Lenses | Only "came from" with Put back. | C·H7; E·VM-41, PL-70 | hoist owed (LineageFaceModel, LineageFaceCopy) | L | W-183 | yes | NT-5 | |
| W-185 | Move a selection into a new take | Feature | Takes & Lenses | Absent. | C·B8; E·PL-34 | face only (Core) | S | — | no | no | |
| W-186 | Compare, after v1 | Feature | Takes & Lenses | Ruled excluded; her 2026-11-12 word reopens it for after v1 ("notes as different tabs that you can swipe between and still have the notes line up block by block"). | C·M4, T8, V2, §1i; her words | hoist owed (PostAlignment, CompareComposition, LineDiff, VersionCompareDoor) | L | — | yes | SC-1 | after v1 (her word) |

## Castle & sync

| Id | Title | Kind | Area | What is wrong or missing | Sources | Brain | Size | Depends on | Mockup | Ruling | Her priority |
|---|---|---|---|---|---|---|---|---|---|---|---|
| W-187 | Backgrounding keeps the library open a while; a full close locks | Improvement | Castle & sync | Under Castle every background (an app switch, a notification) locks, drops the key, closes the store and rebuilds the shell; the idle-minutes check is dead code. Her ruling is decision 18; the lock-on-background rule traces to a planner's item, not her words. | D·D-23, D-24, §2; E§0 item 5; F 1A, 6A; her words | face only (Shared RoadCrossingsModel, DeviceSettings.idleLockMinutes; phone MobileRelock) | M | — | no | LP-1, LP-2 | HIGH |
| W-188 | The idle-lock dial on "On this iPhone" | Feature | Castle & sync | The model, the choices and the copy are shared and ready; only the face is missing — and it does nothing until leaving stops locking. | D·D-21; E·VM-25 — absorbs VM-25 with W-189 | face only | S | W-187 | yes | LP-1, LP-6 | HIGH |
| W-189 | Lock Library Now on the phone | Feature | Castle & sync | No Lock Now anywhere, though a code comment promises one. | D·D-22, §2.3; E·VM-25; her words | face only (RoadCrossingsModel.lockNow) | S | — | yes | LP-5 | HIGH |
| W-190 | Probe whether iOS reliably says the phone locked | Debt | Castle & sync | Nothing observes device lock; the public signals are unproven on a device. | D§2.5 | n/a (a device probe) | S | W-238 | no | LP-2, PD-2 | |
| W-191 | After a relock she comes back where she was | Improvement | Castle & sync | A relock tears down the shell; she returns to the Shelf with empty stacks and her note gone ("probably the sharpest part of 'damn'", INFERRED). | D·D-25, §2.1 step 4; F 6A | face only | M | W-187 | no | LP-4 | |
| W-192 | The app switcher shows note text under Castle | Improvement | Castle & sync | Only privacy-marked spans are covered, and the lock lands after the snapshot. | D·D-28, §2.1 step 6, §2.7 Q3 | face only (SnapshotPrivacy) | S | W-187 | no | LP-3 | |
| W-193 | The creation words card may show in the app switcher | Bug | Castle & sync | The card draws outside the `.ready` arm where the redaction is attached (INFERRED; moot once W-194 lands). | D·D-06 (new finding) | face only | S | — | no | no | |
| W-194 | A calm first open: the words move into the phone's band card | Improvement | Castle & sync | A fresh phone shows twelve words before anything else, with no Copy; a Mac user adding the phone gets words for a library the join is about to replace; a phone-only user who skipped them must make New Words before turning on sync (INFERRED). | D·D-06, D-07, D-45, D-39; E·VM-23, PL-50 (VX-307) a, PL-24d, PL-41c — absorbs VM-23; part of VM-28 | face only (Shared WordsBand) | M | W-023 | yes | FR-1, SW-3 | |
| W-195 | Rule 3's passphrase reminder on the phone | Feature | Castle & sync | A library born on the phone is never asked for a passphrase. | D·D-08, §3 item 3; E·VM-28 | face only (Shared PassphraseReminderModel) | S | W-194 | yes | FR-1 | |
| W-196 | The E6 card (the account's passphrase never typed here) | Feature | Castle & sync | Absent. | D·D-09; E·PL-59 b — part of VM-28 | face only | S | W-194 | yes | no | |
| W-197 | A Copy door for the twelve words | Feature | Castle & sync | No Copy on the creation card or New Words; the Mac's concealed copy has no phone twin. | D·D-13, Q8; E·PL-24d | new brain needed (an iOS concealed, expiring copy) | S | — | no | LP-9 | |
| W-198 | Leaving Castle on the phone: Use Standard and the follow out | Feature | Castle & sync | A phone-only Castle user can't leave Castle; if the account leaves Castle elsewhere the phone dead-ends. Held for her phone wording (F-PH-2). | D·D-16, D-18; E·PL-50 (VX-307) b, PL-51 (VX-329) b — part of VM-28 | face only | S | — | no | LP-7 | |
| W-199 | Rule 21's "this Mac" sentences said rightly on the phone | Improvement | Castle & sync | Wording (F-PH-1): her CastleRules sentences say "this Mac" when shown on the phone. | D·D-04 — part of VM-28 | face only | S | — | no | LP-7 | |
| W-200 | The keystone line on the Protection screen | Improvement | Castle & sync | "While Variorum is open and unlocked…" has no phone home. | D·D-26; E·VM-26 — absorbs VM-26 | face only | S | — | no | no | |
| W-201 | The Protection screen leads with "Sync this library" for a Mac user adding the phone | Improvement | Castle & sync | The join door sits at the bottom of a long scroll after four sections; the road crosses three surfaces in about twelve taps. | D·D-11, §4(b), Q3 | face only | M | — | yes | FR-2 | |
| W-202 | Sync state visible outside Settings | Feature | Castle & sync | Nothing on the Shelf, Library or Starred says whether the phone is caught up, and it syncs only while open. | D·D-37, §3 item 7 | face only (Shared SyncStatusViews) | M | — | yes | no | |
| W-203 | Keep the store and key file out of the iPhone's device backup | Bug | Castle & sync | A phone that hasn't followed into Castle, and its iCloud device backup, stay Apple-openable. | D·D-29; E·VM-15 — absorbs VM-15 | face only (Shared FilePlanStoreLeaf) | S | — | no | no | |
| W-204 | The sync row's door after keys were replaced opens the wrong place | Bug | Castle & sync | It opens the Account sheet, but the follow lives in Protection (INFERRED; the same on the Mac). | D·D-41 | face only | S | — | no | no | |
| W-205 | Syncing while the app isn't open | Feature | Castle & sync | No background refresh or push; the phone syncs only while open, plus one round on leaving. | D·D-44 | new brain needed | L | — | no | no | |
| W-206 | The library-missing face offers only Start a New Library | Improvement | Castle & sync | The Mac's Restore and Open doors have no phone road; its busy line is a hard-coded "Starting…". | D·D-03 | face only | S | W-207 | no | SC-4 | |
| W-207 | Library doors on the phone: Look inside, Open Library, Restore, Previous Libraries, Send | Feature | Castle & sync | Deferred to the mobile catch-up by a provisional (P-VX306-U3-18), not a ruled exclusion. | D·D-30; E·PL-42 (VX-306) a, PL-48 (13x) | face only (Shared LookInsideModel, CopyDoorsModel) | L | — | yes | SC-4 | |
| W-208 | The Protection wording pass (VM-8's held faces) | Improvement | Castle & sync | Wording: follow-locked doors hidden rather than refusing, "your backups" on a phone that keeps none, the doorless "You're in Castle." line, the twice-told follow notice, VM-28's "saving…" sentence. | D·D-15, D-19; E·VM-8 bundle 7–9, #242, VM-28 | face only | S | — | no | LP-10 | |
| W-209 | A current build on her phone (sync marker 15), then VM-32's round | Bug | Castle & sync | Main is at sync marker 15 (deployed Nov 7–8); her phone build is VM-8's (marker 14), so it probably refuses the mirror (INFERRED — confirm on her phone first). | E§0 item 1, §4 item 1, VM-32; D·D-75 — absorbs VM-32 | n/a (an install and a round) | S | — | no | PD-3 | |
| W-210 | A phone sync round after a book purge takes minutes | Bug | Castle & sync | Blocked on a current phone build. | E·VX-672; D§6 — absorbs VX-672 | new brain needed (Sync/) | M | W-209 | no | no | |

## Settings & onboarding

| Id | Title | Kind | Area | What is wrong or missing | Sources | Brain | Size | Depends on | Mockup | Ruling | Her priority |
|---|---|---|---|---|---|---|---|---|---|---|---|
| W-211 | A Settings screen that scrolls and groups | Improvement | Settings & onboarding | A fixed stack with no scroll; every row but the voice rows is a 14-pt-tall word; it fits only because its text can't grow. | D§3 item 5; G§5.11, T100; A§2 | face only | M | W-001, W-003 | yes | no | |
| W-212 | Writing and document settings on the phone | Feature | Settings & onboarding | No rows for default segmentation, savepoint cadence and pruning, seams, the editing indicator, the takes and ownership switches. | A·H5, H6, H11; C·E22; E·PL-11f, PL-21-5 — absorbs VM-11 (its M14 measure moves to W-252) | face only | M | W-211 | yes | no | |
| W-213 | An appearance setting (system, light, dark) | Feature | Settings & onboarding | The phone follows the system only. | A·H3 | face only | S | W-211 | no | no | |
| W-214 | Release ships a temporary edit-trace experiment | Debt | Settings & onboarding | "Record edit trace" is not behind Debug; VM-13 retires it at the device queue's close. | A·H9; D·D-71; E·VM-13c; F§9 | n/a | S | W-260 | no | no | |
| W-215 | Settings search | Feature | Settings & onboarding | The Mac's nine panes are searchable; the phone's sheet isn't. | A·H7; E·PL-36 | hoist owed (SettingsShape catalog) | S | W-211 | no | SC-7 | |
| W-216 | A crash-report opt-in | Feature | Settings & onboarding | No MetricKit anywhere; no Diagnostics opt-in. | D·D-62, Q6; A·H9; E·PL-47 (13r) a — part of VM-9 | new brain needed | M | — | no | SC-6 | |
| W-217 | Two "Protection…" rows stacked in Settings | Bug | Settings & onboarding | The row's door and a standing button both show while sync reads locked or not-yet (her word: a bug). | D·D-38; E·VM-27 — absorbs VM-27 | face only | S | — | no | no | |
| W-218 | The tutorial teaches the retired divide default | Bug | Settings & onboarding | Wording: "copied onto both halves" while the phone divides keep-on-top; its test pin is wrapped as a known issue. | C§2.13; D·D-49; E·VM-3, PL-23-5, PL-40b — absorbs VM-3 | face only | S | — | no | no | |
| W-219 | The pocket guide in Release, with a door | Feature | Settings & onboarding | A Release phone has no tutorial; the guide's doors are Debug-only (PB1-1 left the product door to her). | A·H10; D·D-49 | face only | S | — | yes | FR-5 | |
| W-220 | The guide's books facts brought up to date | Improvement | Settings & onboarding | It teaches Pin, "a smart book" and "starred things sit above everything", and says nothing of shelves, Arrivals or gatherings. | B·O2; E·PL-61, PL-46 (17y) | face only | S | W-219 | no | no | |
| W-221 | The guide's protection chapter (three lessons and the compromise page) | Feature | Settings & onboarding | The phone's chapter is the one-lesson copy from before the Castle rebuild. | D·D-35; E·PL-59 b — part of VM-28 | face only | M | W-219 | no | no | |
| W-222 | A welcome card and a phone tour | Feature | Settings & onboarding | No welcome card; the tour is "Mac-only" in SurfaceContracts but not on MobileSoul's exclusion list. | D·D-46, D-47, D-10, §6 | hoist owed (TourEngine, TourScript, if a tour) | L | W-194 | yes | FR-1 | |
| W-223 | The launch seed set on the phone | Feature | Settings & onboarding | The phone seeds only the Prince and the starter Journal: no readme letter, field guide, empty starred notes or disclaimer snippet; the starred-gathering seeder is never called. | D·D-48; B·F12; E·PL-43d, PL-46, #146 | hoist owed (BirthFurnitureSeeders, the readme) | M | — | no | FR-4 | |
| W-224 | Restore doors for the seeded books in Release | Feature | Settings & onboarding | Only Debug can restore the Prince, Sherlock, Jekyll and the classics. | D·D-51; E·VM-29, PL-17, PL-65, #155(ii) — absorbs VM-29 | face only (Shared SeededBookRestore) | M | — | no | no | |
| W-225 | The starter Journal's launch fact misses the account latch | Bug | Settings & onboarding | The Journal arm uses `storeWasEmptyAtLaunch` without the latch the Prince arm uses. | E·VM-35 — absorbs VM-35 | face only | S | — | no | no | |
| W-226 | What's New on the phone | Feature | Settings & onboarding | Absent. | D·D-52, Q5; E·PL-47 (13r) b | hoist owed (Mac-local notes per version) | S | — | no | FR-3 | |
| W-227 | A door on the Mac pointing to the phone app | Feature | Settings & onboarding | No Mac text mentions the iPhone app. | D·D-53, Q3 (c) | face only (Mac) | S | — | no | FR-2 | |
| W-228 | The empty state names only half the sync road | Improvement | Settings & onboarding | Wording: "Settings ▸ Sync signs you in" — then Protection ▸ Sync this library goes unsaid. | D·D-50 | face only | S | W-201 | no | no | |
| W-229 | The tag manager per wing | Feature | Settings & onboarding | It lists every wing's tags; new root tags land in Home. | A·F1, F2 | face only | S | W-015 | no | no | |
| W-230 | Delete every unused tag | Feature | Settings & onboarding | The Mac's sweep has no phone twin. | A·F3; E·VM-40 — absorbs VM-40 | face only | S | W-229 | no | no | |
| W-231 | Make a gathering from tags; re-parent a tag | Feature | Settings & onboarding | Absent. | A·F4 — part of VM-6 (4b) | face only | M | W-229 | yes | no | |

## Import & export

| Id | Title | Kind | Area | What is wrong or missing | Sources | Brain | Size | Depends on | Mockup | Ruling | Her priority |
|---|---|---|---|---|---|---|---|---|---|---|---|
| W-232 | What the phone's Copy copies | Improvement | Import & export | The phone copies chosen-takes Markdown with no title, tags or takes (her R15); the Mac's Copy full text is the document format that re-imports whole. | C·N10; D·D-54, Q9 | face only (Core variorumDocumentText) | S | — | no | NT-3 | |
| W-233 | Export a note through the share sheet | Feature | Import & export | No share sheet anywhere on the phone. | C·N9; D·D-55; MobileSoul §5.7 | hoist owed (the NoteExport act) | M | — | no | no | |
| W-234 | Export a book (Markdown, PDF) | Feature | Import & export | Absent. | B·C15 | face only (Core exportReading) | M | W-233 | no | no | |
| W-235 | Export the library | Feature | Import & export | Absent; the PDF road is Mac-local. | D·D-56 | face only (Core); PDF hoist owed | M | W-233 | no | no | |
| W-236 | The plaintext export road | Feature | Import & export | No document-picker road for the plaintext copy or the scheduled Markdown export. | D·D-32; E·VM-30, PL-20 — absorbs VM-30 | face only (Shared PlaintextExportModel) | M | — | no | no | |
| W-237 | Import a file or folder through Files | Feature | Import & export | No file importer, document types or open-URL handling. | D·D-57, Q9 (c) | face only (Core importDocument, importBook) | M | — | no | SC-5 | |

## Performance

| Id | Title | Kind | Area | What is wrong or missing | Sources | Brain | Size | Depends on | Mockup | Ruling | Her priority |
|---|---|---|---|---|---|---|---|---|---|---|---|
| W-238 | The device performance session on her phone | Debt | Performance | No on-device run of the 100k fixture or of her real store exists; the nine-flow trace plan is written and needs her phone and her word. | F§11; E·PL-15 (perf leg), PL-21-7, PL-22e, VX-68 — part of VM-13 | n/a (a measurement) | M | W-209 | no | PD-1, PD-2 | HIGH (lag) |
| W-239 | Owner adoption scans every table on every launch and unlock | Bug | Performance | Full-table updates with no `owner_id` index run at each services start, holding the one runner and writer just as she reaches for the box. | F 3A, §8 P1.3, §10 lag 1 #1 | new brain needed (Core fix) | M | — | no | no | HIGH (lag) |
| W-240 | The Library's held lists re-run corpus-sized queries on every write, even off screen | Bug | Performance | The listing's sort can't use its index (a full scan per write); the always-held Pool query tests every note against every gathering's rule; both re-run at autosave pace and re-render the hidden Library twice per pause. | A·B2; F 1E, §5, §7, §8 P1.1–P1.2; VX-618 — absorbs VX-618 | new brain needed (Core fix) | M | W-037 (decide together) | no | no | HIGH (lag) |
| W-241 | The box-to-note hand-off: silent store work, keyboard down then up | Bug | Performance | One to four serial store writes run before the push with no feedback; the keyboard drops, the box collapses, the push slides and the keyboard rises again. | F 2A, 2B, §10 lag 2 #1–#2 | face only | M | W-238 | no | no | HIGH (lag) |
| W-242 | Tapping into the box re-lays out all three pages | Bug | Performance | The split animation, a field that reshapes while taking focus, and keyboard avoidance re-proposing all three root pages, the hidden Library included. | F 1B, §10 lag 1 #2; G§3.3 | face only | M | W-238, W-024 | no | no | HIGH (lag) |
| W-243 | Opening a note reads it twice and lays out its chrome three times | Bug | Performance | A liveness read, a full read, then the observation's first fetch reads the whole note again; the chips read every book and every tag in the store. | F 2C, §4, §8 P1.7 | face only | M | W-238 | no | no | HIGH (lag) |
| W-244 | Typing in a note re-reads the whole note at every pause | Bug | Performance | The note's observation watches whole tables, so every autosave (and every write anywhere) re-runs the full projection and the open note does whole-note main-thread work per pause; never measured, because the perf walk doesn't start the observation. | F§4, §7, §8 P1.5 | new brain needed (the observation's shape, Core/Shared) | L | W-238 | no | no | |
| W-245 | Chrome lays out every fanned block on every update | Bug | Performance | Document-wide chrome forces layout for every fanned block, not the viewport. | F§4, §8 P1.6 | face only | M | W-238 | no | no | |
| W-246 | The 3-second sync aftershock re-delivers the open note | Bug | Performance | A push bumps `sync_version`, which the note's projection carries, so the whole note re-delivers just as she starts typing. | F 2E, §10 lag 2 #4 | new brain needed (Core query shape) | M | W-244 | no | no | HIGH (lag) |
| W-247 | Twin editor models and editor save coordinators never released | Bug | Performance | The Write screen builds seven models on every struct init (twins SUSPECTED); the phone never releases an editor's autosave coordinator, so the registry grows by one per note opened. | F 2D, §12.4, §10 lag 2 #5; C§2.16; E·PL-40e; VM-1 (row 74) | face only | S | W-238 | no | no | HIGH (lag) |
| W-248 | Up to three mounted editors keep full cost; a tab switch re-reads a long note | Bug | Performance | Each stood-down editor keeps its storage, two observation loops and its chrome; a swipe back to a tab with a long note re-reads it whole. | F§4 (switching), §8 P3 | face only | M | W-238 | no | no | |
| W-249 | Leaving a note or the app repeats savepoint work on the one serial runner | Bug | Performance | Back from a long note, teardown and the leaving savepoint hold the runner the box's first mint waits on; leaving the app runs savepoints up to three times plus a network round before the lock. | F 1D, 6B, 6C, §10 lag 1 #4 | face only | M | — | no | no | HIGH (lag) |
| W-250 | The purge janitor scans for tombstones after every clean sync round | Bug | Performance | Full scans of container, reading and block after every round, and a round follows every typing pause. | F 3B, §8 P1.4 | new brain needed (Core Sync/ fix) | M | — | no | no | |
| W-251 | Control Center and banners re-render the whole app | Bug | Performance | Every active↔inactive flip changes the redaction reason for the whole tree (SUSPECTED). | F§6 | face only | S | W-238 | no | no | |
| W-252 | Measure the book Read hitch at 100k (M14) | Debt | Performance | A whole note is one realized row in the book Read; the 312 ms hitch is measured only on the simulator. | E·round-2 §6.1; F§5 — from VM-11 | n/a (a measurement) | S | W-238 | no | no | |
| W-253 | A first catch-up's save holds the writer for minutes | Bug | Performance | About 4–5 minutes on her corpus; her word on VX-497 is "don't close it". | D·D-43; E·VX-497 — absorbs VX-497 | new brain needed (Core) | L | — | no | no | |

## Tests & tooling

| Id | Title | Kind | Area | What is wrong or missing | Sources | Brain | Size | Depends on | Mockup | Ruling | Her priority |
|---|---|---|---|---|---|---|---|---|---|---|---|
| W-254 | Perf instruments for the phone | Debt | Tests & tooling | No signposts or timing logs; the perf walk never runs the observation, shell, push or keyboard; the shelf test never counts Library wakes; the 100k fixture is Debug-only and one wing. | F§9 | n/a | M | — | no | no | |
| W-255 | The privacy manifest and the export-compliance key | Debt | Tests & tooling | Both absent; App Store Connect will ask on every upload (INFERRED). | D·D-65, D-66 | n/a (build settings) | S | — | no | no | |
| W-256 | Build-number stamping and a TestFlight road | Feature | Tests & tooling | Version fixed at 1.0 (1); the release script is Mac-only; installs go by devicectl; the sync row's out-of-date face has no update door. | D·D-69, D-70, D-37 — part of VM-9 | n/a | M | — | no | no | |
| W-257 | A Debug install replaces her Release app | Debt | Tests & tooling | Debug and Release share one bundle id (INFERRED consequence). | D·D-72; F§11 | n/a (build settings) | S | — | no | no | |
| W-258 | The rescue-point caret test is red on main | Bug | Tests & tooling | The one standing phone red. | D·D-73; E·VM-24 (VM-34, VM-36, VM-37, VM-38 already marked duplicates) — absorbs VM-24 | n/a | S | — | no | no | |
| W-259 | A stale first responder desyncs the editor in tests | Bug | Tests & tooling | A test-posture gap. | E·VM-19 — absorbs VM-19 | n/a | S | — | no | no | |
| W-260 | The device queue: VM-13's remaining walks | Debt | Tests & tooling | M16 drag, the D9 23-pt strip, the emoji-sheet overlap, the swipe band's pan, the landing-law pin on a real text view, the cross-block gesture matrix, a dark-toggle re-walk (the Face ID walk is done). | E·VM-13b, PL-23-2, PL-24c, PL-22e — absorbs VM-13 | n/a (her hands) | M | W-209 | no | PD-2 | |
| W-261 | Stale comments and docs in the phone code | Debt | Tests & tooling | Lock Now promised in a comment; "her words" on the planner's item; "structural undo stays Mac-side"; MobileLaunchPathTests' stale doc. | C§2.6; D§3 item 9, §6; F§9, §12.6 | n/a | S | — | no | no | |
| W-262 | The parity ledger and canon pointers tidied | Debt | Tests & tooling | Duplicate PL numbers, rows filed under §7, status cells lagging the tree; MobileSoul §7 and CLAUDE.md still name the retired mobile worktree; VX-909's mobile line has no ledger row. | E§5, §4 item 8 | n/a (canon, at her word) | S | — | no | SC-8 | |
| W-263 | Trace the leaving-savepoint twin on the phone's book faces | Debt | Tests & tooling | No trace recorded. | E·PL-41b | n/a | S | — | no | no | |

---

## Counts

**263 rows.** By kind: Feature 133 · Improvement 57 · Bug 54 · Debt 19.

| Area | Rows | Feature | Improvement | Bug | Debt |
|---|---|---|---|---|---|
| App shell | 31 | 10 | 13 | 5 | 3 |
| Library & sidebar | 27 | 16 | 7 | 3 | 1 |
| Search | 8 | 7 | 0 | 0 | 1 |
| Books | 57 | 38 | 9 | 10 | 0 |
| Editor | 50 | 22 | 14 | 11 | 3 |
| Takes & Lenses | 13 | 11 | 1 | 1 | 0 |
| Castle & sync | 24 | 9 | 9 | 5 | 1 |
| Settings & onboarding | 21 | 14 | 3 | 3 | 1 |
| Import & export | 6 | 5 | 1 | 0 | 0 |
| Performance | 16 | 0 | 0 | 14 | 2 |
| Tests & tooling | 10 | 1 | 0 | 2 | 7 |

- **Her priority:** 31 HIGH — 22 that directly deliver what she named (W-001, W-002, W-003, W-005, W-006, W-007, W-015, W-017, W-018, W-023, W-033, W-034, W-037, W-040, W-059, W-079, W-134, W-135, W-149, W-187, W-188, W-189) and 9 traced causes of her two named lags (W-238, W-239, W-240, W-241, W-242, W-243, W-246, W-247, W-249). Compare (W-186) is marked "after v1 (her word)".
- **Mockup needed:** 107 rows.
- **Her ruling needed:** 87 rows, across 68 of the 70 sitting questions (NT-16 and SC-9 hold no row).
- **Size:** S 139 · M 108 · L 16.
- **Brain:** face only 165 · hoist owed 64 · new brain needed 17 · n/a (measurements, build settings) 17.
- The brief's Area list has no MCP area: the Private mark sits under Library & sidebar and Copy for AI under Editor.

---

## Existing tickets: where each lands

Every VM ticket open on the board was found still owed except VM-13's Face ID walk (E); none was silently done.

| Ticket | Disposition | Rows |
|---|---|---|
| VM-1 (hand-ins bundle) | Dissolve; close when every row has a home (its own rule) | W-128, W-130, W-175, W-139, W-121, W-247 (row 74), W-197 (the copy-all doors) |
| VM-2 | Absorbed | W-124 |
| VM-3 | Absorbed | W-218 |
| VM-4 (catch-up umbrella) | Close or re-point at VM-44's approval (E); its §5 held calls move to the sitting | SW-6, NT-8, BK-10, FR-3 (and #139(f), now stale) |
| VM-6 (13i family umbrella) | Split into rows | 4a: W-015, W-033, W-017, W-067, W-100 · 4b: W-074, W-231, W-223 (starred gathering) · 4c: W-096, W-108, W-114, W-115, W-118 · 4d: W-116, W-117, W-121, W-107 |
| VM-7 (editor and capture umbrella) | Split into rows | W-022, W-025, W-125, W-005, W-041, W-043, W-175, W-012 |
| VM-9 (beta readiness umbrella) | Split into rows | W-001 (Dynamic Type), W-014, W-256, W-216, W-226, W-255, W-030, W-031 |
| VM-11 | Absorbed; M14 split off | W-212, W-252 |
| VM-12 (debt umbrella) | Absorbed; wording items split | W-164, W-053 ("more info"), W-155 ("unseal"), W-013 |
| VM-13 (device queue) | Absorbed; the Face ID walk is discharged (VM-8) | W-260, W-238 (perf leg), W-214, W-173 |
| VM-14 | Absorbed | W-166 |
| VM-15 | Absorbed | W-203 |
| VM-16 | Absorbed | W-145 |
| VM-17 | Absorbed | W-147 |
| VM-18 | Absorbed (Needs Lillian) | W-165 |
| VM-19 | Absorbed | W-259 |
| VM-20 | Absorbed | W-146 |
| VM-21 | Absorbed | W-092 |
| VM-22 | Absorbed | W-041 |
| VM-23 | Absorbed | W-194 |
| VM-24 | Absorbed | W-258 |
| VM-25 | Absorbed | W-188, W-189 (and W-187, which makes the dial mean something) |
| VM-26 | Absorbed | W-200 |
| VM-27 | Absorbed | W-217 |
| VM-28 (protection cards umbrella) | Split into rows | W-194, W-195, W-196, W-221, W-198, W-199, W-208 |
| VM-29 | Absorbed; widen the title to "seeded books" (E) | W-224 |
| VM-30 | Absorbed | W-236 |
| VM-31 | Absorbed (design first) | W-049 |
| VM-32 | Absorbed; fold in the marker-15 install (E) | W-209 |
| VM-33 | Absorbed | W-057 |
| VM-34, VM-36, VM-37, VM-38 | Already Duplicate of VM-24 on Linear; nothing to do | — |
| VM-35 | Absorbed | W-225 |
| VM-39 | Absorbed | W-056 |
| VM-40 | Absorbed | W-230 |
| VM-41 | Absorbed | W-183, W-184 (with W-182, W-180) |
| VM-42 | Absorbed | W-101, W-091 |
| VM-43 | Absorbed | W-181 |
| VX-68 (typing-flicker watch) | Hand to the device session (E) | W-238 |
| VX-128 (block tags, hers) | Rides the ruling | W-143 |
| VX-438 (smart quotes, Needs Lillian) | Absorbed | W-131 |
| VX-497 | Absorbed | W-253 |
| VX-618 | Absorbed | W-240 |
| VX-672 | Absorbed | W-210 |

Ledger rows E marked DISCHARGED or STALE (PL-1a, PL-1b, PL-3, PL-5, PL-6, PL-8, PL-9, PL-10b, PL-10 (iii), PL-11a–e, PL-12, PL-13a/b/c/d, PL-14, PL-15 build and walk, PL-16, PL-18a, PL-19f, PL-22a, PL-24d, PL-25b, PL-28a, PL-37, PL-38a, PL-41a, PL-41c, PL-41d, PL-42 (VX-306) c, PL-42 (13i-a) a, PL-50 (VX-99), PL-51 (VX-329) a, PL-57, PL-58, PL-59 a, PL-66, PL-67, PL-72, PL-73) need no row; W-262 carries the ledger's own clean-up. PL-7 (the 13h folder bridge) stays a watch line with no ticket (E).

---

## Contradictions settled

1. **The "pale band around the quick click buttons" — which surface.** C guessed the quick-entry band; A and G said the Write keyboard bar. **A and G are right about what exists:** the quick-entry box's only control is the "open ↵" text door (`App/Variorum/VariorumMobile/Features/Shell/MobileQuickNote.swift:1283-1304`, checked), so no group of quick buttons sits there; the keyboard bar paints an opaque `face.surface` band behind three iOS 26 glass circles (G, `MobileKeyboardBar.swift:515-517`). That she *meant* the keyboard bar is still INFERRED — LK-4 asks her to confirm.
2. **Who ruled "lock on background".** E (§0 item 5, §2) treats the lock-on-leaving rule as a recorded rule of hers; D says it was a planner's item. **D is right:** `notes/plans/phase-13p-note-protection.md:605-635` lists "(g) Re-lock on background as the phone's re-lock dial …" among the planner's expansion items under her rider, whose only verbatim words are "make sure that the mobile plan is thoroughly updated … some people will be mobile only users"; `MobileRelock.swift:5-9` mislabels item (g) as "her words" (checked). Her own ruling is decision 18. `her-words.md` already carries this correction.
3. **The gathering word in the Trash.** E (PL-62 a) says the phone's Trash labels call `RecoveryCopy.rowKind(item)` "without the gathering fact"; B (K2) says the Trash row's word is already right. **B is right:** `MobileTrashView.swift:258,273,317` call the item form, which passes `item.isGathering` (`App/Variorum/Shared/RecoveryCopy.swift:141-142,157-158`, checked). One site E's claim does fit: the empty-name placeholder at `MobileTrashView.swift:301` uses the kind-only form, so an untitled gathering reads "(empty book)". The real gap is the Shelf's delete door, confirm and receipt — "Delete Book…" (`MobileShelfFaces.swift:142-143`) and `movedToTrashReceipt(.book)` (`MobileShelfViewModel.swift:194`), checked — carried by W-073.
4. **Look inside and Open Library on the phone.** E (PL-42 (VX-306) a) calls their absence "DISCHARGED as ruled"; D (D-30) calls it "a deferral, not a ruled exclusion". **D is right:** P-VX306-U3-18 is a PROVISIONAL that defers the door to "the mobile catch-up's" (`notes/plans/vx-306-castle-open-road.md:2308-2310`, checked). W-207 carries it; SC-4 asks her.
5. **The sync marker.** Not contradicted, but load-bearing: `Sources/VariorumCore/Sync/SyncSchema.swift:170` reads `lockstepVersion = 15` (checked). That her installed phone build is marker 14 stays INFERRED from the records (E §0 item 1).
6. **Snippets: owed or excluded.** A treats the Snippets room as owed work; E points out that her gate words put "snippets" on the not-replicated list. Not a code contradiction but a canon one: MobileSoul §4.5's ruled list names only "the scraps drag-into-note door", and §4.3 names "scraps viewing" as see-your-data. Left to her as LS-3.
7. **The tour.** SurfaceContracts calls the tour "Mac-only"; MobileSoul §4.5 doesn't list it (D §6). Left to her inside FR-1.
8. **Which Mac surface the phone's quick note mirrors.** E compares it with the Mac's pad (lands in Home wearing the quicknote tag, SurfaceContracts.md:18, checked); A compares it with the Mac's quick-entry band (lands in the current wing). Both Mac facts hold; which twin the phone's box is becomes SW-5.
9. **VM-25.** E says the idle dial "would not help, because the leaving lock fires first"; D says "only the face is missing". Both hold: the dial's face is missing, and `locksOnReturn` can never fire while every Castle leaving locks (D-24). Recorded as a dependency (W-188 waits on W-187).
10. **Library re-fetch at autosave rate.** A marked it INFERRED; F traced it in code. F's traced finding stands.
11. **Line numbers for the phone's Terminal default** differ slightly across A, C, E and G (`MobileVoicePreference.swift:26-33`); the fact is the same.
12. **`BookStateCopy.deleteVerb`.** The ledger (PL-62) calls it shared; B found it Mac-local (`App/Variorum/Variorum/Features/Readings/BookStateDoors.swift:173,192`). Taken as B reports; W-073 carries the hoist.
