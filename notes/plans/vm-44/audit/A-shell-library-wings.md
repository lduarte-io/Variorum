# VM-44 audit — reader A: the shell, the Library, wings and finding things

Draft working record, not canon. Read-only audit of `~/dev/variorum` at `main` 5dde1bcf9 (2026-11-12).
Every claim is marked **VERIFIED** (the code was read; file:line given) or **INFERRED** (from what, said).

**Path shorthands.** `Shell/` = `App/Variorum/VariorumMobile/Features/Shell/` · `Write/` = `App/Variorum/VariorumMobile/Features/Write/` ·
`Shared/` = `App/Variorum/Shared/` · `MacLib/` = `App/Variorum/Variorum/Features/Library/` · `MacViews/` = `App/Variorum/Variorum/Core/Views/` ·
`Q/` = `Sources/VariorumCore/Queries/` · `Ops/` = `Sources/VariorumCore/Operations/` · `Dom/` = `Sources/VariorumCore/Domain/` ·
SC = `notes/SurfaceContracts.md` · MS = `notes/MobileSoul.md` (PL-n = its §6 ledger rows).

---

## 0. The headline

1. **The phone reads every wing at once, and has no way not to.** `WingState.readScope` is hard-wired to `nil` on iOS
   (`Shared/WingState.swift:52-58`) and the device wing memory is attached only `#if os(macOS)`
   (`Shared/AppBootstrap.swift:497-505`). Every phone listing passes no wing: Library, Bookless, Books/Shelf, Starred,
   Archived, Trash, the tag manager, the note's tag suggestions, the membership picker, search. Every phone mint lands
   in Home. VERIFIED (section 3.1 traces each read).
2. **"Hard to find items in the library" has five concrete causes**, all VERIFIED: the listing is the 200 most-recently-touched
   notes across all nine wings with a silent cut (`Shell/MobileLibraryViewModel.swift:77,318-320`;
   `Shell/MobileLibraryView.swift:419-422` admits there is no marker); untitled rows show a raw date as their name
   (`DisplayTitle.note`, `Shell/MobileLibraryViewModel.swift:480-483`); there is no body preview; search is the old
   title/date LIKE catalog capped at 20 per kind (`Q/ShelfQueries.swift:917-921`, called at `Shell/MobileLibraryViewModel.swift:357-358`),
   not the FTS5 index the phone already maintains; and there is no wing scope to narrow by.
3. **Everything needed for row previews is already in Core, except the read the Mac actually uses.** The lead/preview
   brain `NoteCardFace` is Core (`Dom/NoteCardFace.swift`); the P1-flat opening read `Queries.leadingBlockTexts` is Core
   (`Q/PostRender.swift:344-367`). The Mac Library's own card read `NoteCards.load` is Mac-app-local
   (`MacLib/LibraryListingReads.swift:99-176`) and is **not** flat in note length (its own sibling's record measures it at
   36 ms for a 20,000-block note — `MacLib/SidebarRowLeads.swift:16-22`).
4. **The chrome is Mac-sized.** Nearly every phone control is set in `tokens.small`, a fixed 11.5 pt; Terminal's body is
   a fixed 14 pt monospaced (`Shared/Theme/VoiceTokens.swift:293-296,329-332`); the phone defaults to Terminal
   (`VariorumMobile/Theme/MobileVoicePreference.swift:26-29`). Doors are bare `Text` buttons with no minimum hit
   area (tab bar `Shell/MobileShellView.swift:595-609`; path lines; filter row with `minimumScaleFactor(0.7)`,
   `Shell/MobileListingFilters.swift:183-205`). This is the mechanism behind "weirdly tiny font" and "tiny affordances".
5. **A wing swipe collides with the existing root swipe.** The Starred · Shelf · Library band already owns horizontal
   drags on every root surface (`Shell/MobileShellView.swift:261-263,338-387`). Her "quick swipe between wings" needs
   a design decision, not just a gesture (Q1).

---

## 1. Gap matrix

Status: PRESENT · PARTIAL · STALE · ABSENT · RULED-EXCLUDED. Size: S/M/L for the face work; a "hoist" note means
the brain must move to Core/Shared first.

### 1A. Shell and navigation

| # | Capability | Mac (contract pointer) | Phone | Phone file(s) | Brain lives | Ticket / ledger | Size | Note |
|---|---|---|---|---|---|---|---|---|
| A1 | Root surfaces | SC "The sidebar": Bookcase · Library · Pool · Snippets · Archived, Trash door, Open, Starred, AI | PARTIAL | `Shell/MobileShellView.swift:62-68`, `Shell/MobileShellBand.swift:61-64` | phone-local (pure `MobileShellBand`) | PL-63 | M | Phone has three roots: Starred · Shelf · Library. Pool and Snippets are Library filters; Archived is the Library's last row; Trash is a 🗑 on two path lines. VERIFIED |
| A2 | Root swipe band | n/a (phone-native) | PRESENT | `Shell/MobileShellView.swift:261-263,338-417` | phone-local | — | — | Pages only at stack roots; a swipe and a tab tap are one road (`selectPage`). VERIFIED. Collides with any wing swipe (Q1) |
| A3 | Tab bar face | n/a | STALE | `Shell/MobileShellView.swift:576-609` | phone-local | — | S | Text-only, 11.5 pt, no min tap area (12 pt above, 8 pt below the words); hidden on every pushed screen, so switching root means backing out first. VERIFIED |
| A4 | Type scale and tap targets | SC "The app" (tokens; Mac sizes) | STALE | `Shared/Theme/VoiceTokens.swift:293-406`; every Shell view | Shared (VoiceTokens) | MS §5.6, VM-9 (Dynamic Type audit) | M | Phone uses the Mac's fixed sizes: small 11.5 pt (both voices), Terminal body 14 pt mono (no Dynamic Type); Study body scales (`relativeTo: .body`). VERIFIED |
| A5 | Settings reachability | Settings is an app-level window (SC "The sidebar") | PARTIAL | `Shell/MobileShelfView.swift:246-256`, `Shell/MobileShellView.swift:219,266-268` | phone-local | — | S | Only the Shelf's path line has a Settings door; Library and Starred have none. VERIFIED |
| A6 | Trash door | SC "The sidebar" (Trash door on the Library masthead) | PARTIAL | `Shell/MobileRecoveryDoors.swift:45,88-100`; `Shell/MobileLibraryView.swift:206-208`; `Shell/MobileShelfView.swift:231-233` | Shared copy (`RecoveryCopy`) | — | S | Works; it is a 🗑 emoji in 11.5 pt muted ink. VERIFIED |
| A7 | Archived door | SC "The sidebar" (Archived is a sidebar item) | STALE | `Shell/MobileLibraryView.swift:94,174-190` | phone-local | — | S | The door is the LAST row under up to 200 notes (and the books under All). Unreachable without a long scroll. VERIFIED |
| A8 | Open list (several open notes) | SC "The Open list and Starred" | RULED-EXCLUDED | — | Mac-only (workspace) | MS §4.5 "workspace & windowing" | — | Each of the three stacks can hold one pushed note. INFERRED from the exclusion list |
| A9 | AI section, MCP marks, ⌥⌘O | SC "The AI section" ("Mac only") | RULED-EXCLUDED | — | Mac + MCP | MCPSpec | — | The MCP door is Mac-only by contract. VERIFIED (SC line 14 ends "Mac only.") |

### 1B. The Library listing and its rows

| # | Capability | Mac (contract pointer) | Phone | Phone file(s) | Brain lives | Ticket / ledger | Size | Note |
|---|---|---|---|---|---|---|---|---|
| B1 | Listing depth | `Queries.catalogNotesPage` keyset pages, 80 then growing, "a page, never a cap" (`MacLib/LibraryCatalogModel.swift:941-1003`) | STALE | `Shell/MobileLibraryViewModel.swift:77,316-327` | Core (`Q/LibraryPaging.swift:78`) | KnownIssues "bounded windows show markers" (cited in-file) | M | Phone holds `observeLibrary(limit: 200)` and cuts silently; note 201 is unreachable except by title search. VERIFIED (`Shell/MobileLibraryView.swift:419-422`) |
| B2 | Re-fetch cost of the held listing | Mac pages one-shot | STALE | `Shell/MobileLibraryViewModel.swift:316-327` | Core | VX-618 | M | `observeLibrary` re-runs on every `container` write (`Q/Observations.swift:44-49`), i.e. at autosave rate while a note is open in another stack (both stacks stay alive). INFERRED; relevant to her lag report (perf reader) |
| B3 | Kind scopes | SC "The Library": All · Books · Notes · Blocks (`MacLib/LibraryCatalogModel.swift:30-42`) | PARTIAL | `Shell/MobileListingFilters.swift:57-92` | phone-local | her #85/#92 | S | Phone: All · Books · Notes · Bookless · Scraps. No Blocks scope (block-level matches, tagged blocks). VERIFIED |
| B4 | All = books + notes | Mac: books region above notes | PRESENT | `Shell/MobileLibraryViewModel.swift:153-251` | phone-local (pure `union`) | her #93(b) | — | Phone interleaves books by stamp; the stamp mapping is PROVISIONAL in-file. VERIFIED |
| B5 | View modes List · Cards · Timeline | SC "The Library" | ABSENT | — | Mac-local (`LibraryCatalogModel.Mode`) | PL-22 | M | Phone has one plain list. Cards is the Apple-Notes-shaped mode she asked for (section 3.2). VERIFIED |
| B6 | Row lead (what a row is called) | 13u3 UNIT B: title, else first words (cap 48), journal entry leads with its day (`Dom/NoteCardFace.swift`; `MacLib/LibraryCardName.swift:30-44`) | STALE | `Shell/MobileLibraryViewModel.swift:480-483` | Core (`NoteCardFace`); composition Mac-local, pure (hoist) | PL-26 (cap ~30 on phone) | S | Phone uses `DisplayTitle.note`: an untitled row's name is its raw `entry_date` ("2026-11-12") or its created day. VERIFIED (`Dom/DisplayTitle.swift:72-80`) |
| B7 | Row body preview | Cards: lead + 2-line continuation (`MacLib/LibraryCatalogView.swift:1281-1362`) | ABSENT | `Shell/MobileLibraryView.swift:478-518` | Core brain + Core flat read; Mac read is Mac-local | her high priority; PL-26 | M | Full analysis in section 3.2 |
| B8 | Row stamp | SC "List and Cards": `TimeStampFace` sort's own stamp, hover = whole fact | STALE | `Shell/MobileLibraryView.swift:488-492` | Core (`Dom/TimeStampFace.swift`); `LibrarySortFace` Mac-local (`MacLib/LibraryTimeFace.swift`) | VM-22, PL-35 | S | Phone prints the raw stored day key, only when the note is dated; undated rows show no time at all. SC says "the raw-day-key drift copy is dead". VERIFIED |
| B9 | Row tag chips | List row chips with ＋ / ✕ (`MacLib/LibraryCatalogView.swift:1370-1384`) | ABSENT | — | Mac-local pure (`TagChips.load`, `MacLib/LibraryListingReads.swift:183-207`) | — | S | Tags reachable only inside the note. VERIFIED |
| B10 | Owned-by badge on rows | SC "List and Cards" (owned notes badged) | ABSENT | — | Shared/Core (badge family) | VM-6 (4c) | S | Books reader owns the family. VERIFIED absent |
| B11 | Row menu | SC "Open list" menu list: Open Beside, New Window, Star, Rename, Move/Copy to Wing, Export, Close, Delete; Duplicate with/without Tags (AppSpec §9) | PARTIAL | `Shell/MobileLibraryView.swift:501-517` | Core ops | VM-30 (export) | M | Phone long-press: Star, Delete only. VERIFIED |
| B12 | Archive a note | AppSpec §9 `archiveContainer`; SC "Archived" | ABSENT | (none) | Core (`Ops/Operations+Container.swift:626`) | — | S | No phone door archives a note anywhere (grep: no `archiveContainer(` call in `VariorumMobile/`). The Archive room can only unarchive what the Mac archived. VERIFIED |
| B13 | Duplicate a note | AppSpec §9 `duplicateAsVersion(_:tags:)`, two doors | ABSENT | (none) | Core | PL-48 (VX-383) | S | VERIFIED (grep) |
| B14 | Note multi-select / bulk | Mac bulk row (`MacLib/LibraryBulkRow.swift`) | ABSENT | — | Mac-local | VM-31 (a design call first) | M | VERIFIED absent |
| B15 | Info / read-preview panel | `MacLib/LibraryInfoPanel.swift` | RULED-EXCLUDED | — | Mac-local | PL-19 (MS line 218: "NOT OWED … the Library's read-preview column (the phone's own library design)") | — | VERIFIED |
| B16 | Remembers where you were | SC "The Library remembers where you were" (VX-823) | PARTIAL | `Shell/MobileShellView.swift:196-243` | phone-local | — | S | Stacks stay alive, so scroll and query survive a tab trip (INFERRED from the always-built ZStack). The sort resets every launch: `sort` is plain model state, never stored (VERIFIED `Shell/MobileLibraryViewModel.swift:69`); the Mac remembers it locally |
| B17 | Empty states | Mac Library empty copy | PRESENT | `Shell/MobileLibraryViewModel.swift:97-149`, `Shell/MobileEmptyStore.swift:33-45` | phone-local | — | — | Honest store-empty vs no-bookless split. VERIFIED |
| B18 | Sort ▾ | SC "List and Cards": edited · created · date · title, direction local | PARTIAL | `Shell/MobileLibraryView.swift:264-304`, `Shell/MobileLibraryViewModel.swift:274-311` | Shared words (`Shared/LibrarySortWords.swift`) | PL-22 | S | Phone offers four stamps (incl. "last meaningful edit", which the Mac does not), newest-first only, no title, and the door shows only under All. VERIFIED |
| B19 | Day filter (`when ▾`) | SC "Search is the one finder" (calendar popover; edited-on union) | ABSENT | — | Core (`searchCatalog(editedOn:)`, `Dom/DayBounds.swift`); popover Mac-local | PL-22 (18h twin), VM-7 | M | VERIFIED absent |
| B20 | Timeline mode | SC §12 views; Mac `.timeline` | ABSENT | — | Core (`Q/Timeline.swift timelinePage`) | — | M | VERIFIED absent |

### 1C. Search — the one finder

| # | Capability | Mac (contract pointer) | Phone | Phone file(s) | Brain lives | Ticket / ledger | Size | Note |
|---|---|---|---|---|---|---|---|---|
| C1 | Body-text search (FTS5) | SC "Search is the one finder" | ABSENT | — | Core (`Q/SearchQueries.swift:217,261`; `SearchComposer`, `SearchQueryParser`) | PL-2, PL-47b, PL-49 | L | The phone's store maintains the index through shared triggers but never queries it. INFERRED from PL-47b ("the phone inherits v1_22's derived FTS index") |
| C2 | What phone search is today | — | STALE | `Shell/MobileLibraryViewModel.swift:345-395`, `Shell/MobileLibraryView.swift:520-559` | Core (`Q/ShelfQueries.swift:917`) | — | — | `searchCatalog`: titles, entry dates, named blocks, scrap first lines; "prose content search stays out of scope" (doc at `Q/ShelfQueries.swift:870-876`); 20 per kind cap, silent; scrap hits dropped (`:364-366`); all wings. VERIFIED |
| C3 | Answer sheet (passages under notes, honest counts, every "all N ›") | SC "Search is the one finder" | ABSENT | — | Core reads; `LibrarySearchQuestion`/`LibrarySearchModel` Mac-local but pure (Foundation/GRDB/Observation/Core imports — hoist) | PL-47b | L | VERIFIED imports at `MacLib/LibrarySearchModel.swift:27-30` |
| C4 | Facets: archived, + commits, mode facets, Blocks scope | SC "Search…" (R-819-1, VX-72) | ABSENT | — | Core (`SearchQuery.includesSavepoints`, visibility) | PL-49 | M | |
| C5 | `#tag` narrowing and tag offer chip | SC "Search…" (VX-84a) | ABSENT | — | Core (`SearchTagOffer`, `catalogNotesPage(narrowing:)`) | PL-49 | M | |
| C6 | Search order door | SC "Search…" (R-819-2) | ABSENT | — | Core (`searchGroups(order:)`) | — | S | |
| C7 | Land at the match | SC "Search…": Write at the block, match selected, find armed | ABSENT | — | Shared (`Shared/SearchLanding.swift`, written for the phone too) | PL-47b | M | Phone opens a block hit's note at the top, never at the block (`Shell/MobileLibraryViewModel.swift:385-395`). Needs the phone's find face (editor reader) |
| C8 | Search needs a wing | `SearchScope(wingID:)` required (`Dom/SearchQuery.swift:233-251`) | ABSENT | — | Core | — | — | Every FTS read is per wing by construction; a phone search face either rides a wing face or needs a ruled cross-wing exception (Q4). VERIFIED |
| C9 | Search the Archived room | Archived is searchable separately (`MacLib/ArchivedView.swift` header, her B2) | ABSENT | — | Core facet | — | S | |
| C10 | ⌘K palette | AppSpec §12 ("⌘K is the palette"), passages under titles | ABSENT | — | Mac-local registry | — | M | A product call (Q8) |

### 1D. Wings (section 3.1 has the trace and the build list)

| # | Capability | Mac (contract pointer) | Phone | Phone file(s) | Brain lives | Ticket / ledger | Size | Note |
|---|---|---|---|---|---|---|---|---|
| D1 | Wing switcher (dropdown) | SC "The wing switcher" (masthead ▾, ⌘L sheet) | ABSENT | — | Core reads/ops; `WingsModel` Mac-local (`MacViews/WingsModel.swift`, speaks through the macOS-only `StatusCenter`) — hoist | PL-45, VM-6 (4a) | M | VERIFIED |
| D2 | Quick wing swipe / cycle | Mac masthead word cycles (`WingSwitcherBrain.next(after:in:)`) | ABSENT | — | Mac-local but pure (`MacViews/WingSwitcherBrain.swift`, imports Foundation only) — hoist | — | M | Conflicts with the root band (Q1) |
| D3 | Current wing, remembered per device | `Shared/WingState.swift:60-74` | ABSENT | `Shared/AppBootstrap.swift:497-505` | Shared | PL-45 | S | `attachMemory` and `revalidate` run only `#if os(macOS)`; `readScope` is `nil` on iOS. VERIFIED |
| D4 | Wing-scoped reads (every listing) | SC "The wing switcher": "the whole surface re-scopes per wing" | ABSENT | listed in 3.1 | Core (every read takes `wingID:`) | PL-45 | M | VERIFIED per read in 3.1 |
| D5 | Mints land in the current wing | Mac quick entry lands where she stands (`App/Variorum/Variorum/Features/Shelf/QuickEntryBar.swift:205-208`) | ABSENT | `Shell/MobileTodayDoor.swift:94-97`, `Shell/MobileQuickNote.swift:714-718`, `Shell/MobileTagManager.swift:163`, PL-69 (create book passes Home) | Core (`wingId:` params) | PL-69 | S | Every phone mint is Home. VERIFIED |
| D6 | "in ‹wing›" label and "Now in …" receipt | SC "The app" (VX-552/833/844) | ABSENT | — | Shared words (`Shared/WingWords.swift`); `WingFollow.nowIn` Mac-local | — | S | |
| D7 | New / rename / delete-unless-empty wing; Move Everything to Another Wing | SC "The wing switcher"; AppSpec §9 Bookcase ops | ABSENT | — | Core (`Ops/Operations+Wing.swift:28,47,71,98`; `Ops/Operations+WingBookMove.swift:161`); words Shared (`WingWords.notEmpty`) | PL-45 | M | |
| D8 | Note Move to Wing / Copy to Wing | SC "The wing switcher" (tag adoption R-13ia-1; stay-behind memberships listed) | ABSENT | — | Core (`Ops/Operations+WingMove.swift:63,180`); confirm Mac-local (`MacViews/WingDestinationSheet.swift`) | PL-45 | M | |
| D9 | Book Move to Wing | AppSpec §9 `moveReadingToWing` | ABSENT | — | Core (`Ops/Operations+WingBookMove.swift:68`) | VM-6 | S | Books reader overlap |
| D10 | The app's wing follows the opened note | SC "The wing switcher" (`App/Variorum/Variorum/Workspace/WingFollow.swift`) | ABSENT | — | Mac-local | — | S | Design call on the phone (Q2) |
| D11 | Cross-wing leaks today | AppSpec §7 wing note: "Wings isolate totally" | STALE | `Write/MobileNoteTags.swift:58-67,75,250-263`; `Write/MobileMembership.swift:94-95` | Core guards exist | — | S | (a) a note's tag suggestions list every wing's paths; tapping one applies by path in the note's own wing, which MINTS a twin tag there (`Shared/TypedTagPath.swift:143-151`). (b) The membership sheet lists every wing's books; picking another wing's book hits `crossWingMembership`, whose own doc says "no face reaches it" (`Ops/OperationError.swift:318-321`). VERIFIED reads; the user-facing outcome is INFERRED |
| D12 | Same names across wings | per-wing names are legal twins (AppSpec §9 VX-816; tag `uq_tag_path_live(wing_id, path)`) | STALE | `Shell/MobileShelfViewModel.swift:66`, `Shell/MobileTagManager.swift:54` | — | — | S | In the phone's flat all-wing lists two "journal" books or nine `quicknotes` tags read identically. INFERRED from the unscoped reads |

### 1E. Pool, Snippets, Archived, Trash, Starred

| # | Capability | Mac (contract pointer) | Phone | Phone file(s) | Brain lives | Ticket / ledger | Size | Note |
|---|---|---|---|---|---|---|---|---|
| E1 | Pool (bookless notes) | SC "The sidebar" (Pool); `Q/ShelfQueries.swift:505-520` loose + tucked | PARTIAL | `Shell/MobileLibraryViewModel.swift:329-343` | Core | — | S | Phone lists `.loose` only; notes a gathering shows ("tucked") have no reveal under Bookless. VERIFIED |
| E2 | Pool / Snippets names | AppSpec §7 container note: UI says "Snippets" and "Pool"; `App/Variorum/Variorum/Features/Pool/SnippetsSurface.swift:20-60` ("pool"/"scrap" appear in NO string) | STALE | `Shell/MobileListingFilters.swift:71-79`; `Shell/MobileScraps.swift:266,291,326,340-351` | Shared-able copy | PL-19 ("the Snippets vocabulary + groups") | S | Phone says "Bookless", "Scraps", "pool: …", "+ new scrap", "No scraps yet". Its Bookless empty line still describes the retired "smart book collects = held" rule (`Shell/MobileListingFilters.swift:127-141`). VERIFIED. Naming is Q7 |
| E3 | Snippets view | `SnippetsSurface` groups rail, all-snippets listing, search snippets | PARTIAL | `Shell/MobileScraps.swift:236-318` | Mac-local | PL-19 | M | One group at a time (picker only when several), no "all snippets", no search, rows are not tappable. VERIFIED |
| E4 | Snippet acts | edit, delete, Move to Group, Tags…, open as editor, new/rename/delete group | ABSENT | — | Core ops; surface model Mac-local | PL-19; phone "ruling 3" keeps block-tag editing Mac-side (`Shell/MobileScraps.swift:20-22`) | M | Ruling 3 predates the complete-app bar (MS §1) — worth re-asking (Q7) |
| E5 | Mint a snippet | Snippets entry cue | PRESENT | `Shell/MobileScraps.swift:198-222,320-353` | Core | — | — | An alert with a field. VERIFIED |
| E6 | Archived notes room | SC "Archived" | PRESENT | `Shell/MobileArchiveModel.swift`, `Shell/MobileArchiveView.swift` | Core (`observeArchivedPosts`) | — | — | List, Unarchive, Open; window 200 + marker. VERIFIED |
| E7 | Archived books group | AppSpec §9 Book archive; `MacLib/ArchivedView.swift` header | ABSENT | `Shell/MobileListingFilters.swift:94-119` | Core (`observeArchivedReadings`) | VM-6 (4d) | S | VERIFIED |
| E8 | Trash room | SC "Doors" / 13j | PRESENT | `Shell/MobileTrashModel.swift`, `Shell/MobileTrashView.swift` | Shared (`TrashPutBack`, `TrashPurge`) | PL-3/PL-11 | — | Kind filter, oldest-first, Put back, Delete Now, Empty Trash. VERIFIED |
| E9 | Trash multi-select | VX-671 (`Shared/RecoveryActs.swift:340-346`) | ABSENT | — | Shared | PL-64 | S | |
| E10 | Trash empty-block sweep | AppSpec §9 `sweepEmptyTrashBlocks` (VX-800) | ABSENT | — | Shared (`Shared/RecoveryActs.swift:347-352,555-580`) | VM-39 | S | |
| E11 | Trash honest empty | VX-670 | STALE | `Shell/MobileTrashView.swift:84` | — | VM-33 | S | Draws "empty" before the first value (ticket). INFERRED from VM-33 |
| E12 | Starred page | SC "The Open list and Starred" (Starred per wing: `App/Variorum/Variorum/Features/Stars/StarsModel.swift:49`) | PARTIAL | `Shell/MobileStarredView.swift`, `Shell/MobileStars.swift:130-148` | Core (`Q/AppearanceQueries.swift:291,314`) | PL-61, PL-63 | M | All wings; she asked for a design pass (PL-63). VERIFIED |
| E13 | Starred row names | VX-580: untitled sidebar rows lead with first words (`MacLib/SidebarRowLeads.swift`) | STALE | `Shell/MobileStars.swift:186` | Mac-local pure (`SidebarRowLeads`) — hoist | — | S | Untitled starred notes show a date. VERIFIED face; Mac Starred using row leads INFERRED from `MacLib/SidebarView.swift:518-524` |

### 1F. Tags manager

| # | Capability | Mac (contract pointer) | Phone | Phone file(s) | Brain lives | Ticket / ledger | Size | Note |
|---|---|---|---|---|---|---|---|---|
| F1 | Browse / create / child / rename / delete | SC "The sidebar" (Settings ▸ Tags) | PARTIAL | `Shell/MobileTagManager.swift:52-212` | Core ops | — | — | Works, but over every wing's tags at once (`observeTags()` unscoped, `:54`); new root tags land in Home (`:163`). VERIFIED |
| F2 | "Tags — in ‹wing›", follows the wing | SC "The sidebar" (R-828-2) | ABSENT | — | Core (`observeTags(wingID:)`) | — | S | |
| F3 | Delete N unused tags | SC "The sidebar" (VX-840) | ABSENT | — | Core (`deleteUnusedTags`, `Q/UnusedTagQueries.swift`) | VM-40 | S | |
| F4 | Make a Gathering from tags; re-parent | SC "The sidebar"; Settings pane blurb (`App/Variorum/Variorum/Features/Settings/SettingsShape.swift:343-345`) | ABSENT | — | Core | VM-6 (4b) | M | |

### 1G. Quick entry and capture

| # | Capability | Mac (contract pointer) | Phone | Phone file(s) | Brain lives | Ticket / ledger | Size | Note |
|---|---|---|---|---|---|---|---|---|
| G1 | The home capture box | SC "The app" (Bookcase quick entry); `Features/Shelf/QuickEntryBar.swift` | PRESENT | `Shell/MobileQuickNote.swift` | phone-local model; Core `importPost` | — | — | The phone's own ruled shape: mints after ~1 s, then autosaves; typing → saving → ✓ saved; files on leaving the Shelf or backgrounding. VERIFIED (`:25-37,704-735`) |
| G2 | ⏎ files · ⇧⏎ paragraph · many paragraphs (R-13u-4) | AppSpec §12; `QuickEntryBar.swift:223` | STALE | `Shell/MobileQuickNote.swift:56,1125-1127` | rule Shared-able; `CaptureKeys` is NSEvent-shaped | PL-27 (her lost-prose report), VM-7 | M | Phone: ⏎ opens; the box holds one wrapped paragraph. The soft keyboard has no ⇧⏎, so the rule needs a phone mapping (Q5). VERIFIED |
| G3 | ⌘⏎ / "File" files without opening; one filing per flight | SC "Keyboard family" (VX-911, VX-928) | ABSENT | — | Mac-local model | — | S | The phone's mint-as-you-type makes "file without opening" a different act (Q5) |
| G4 | Capture microsyntax `{#tag}` `{t:"…"}` | SC "Capture microsyntax" ("the phone's face is the mobile catch-up's") | ABSENT | — | Shared (`Shared/CaptureMicrosyntax.swift`, `Shared/TypedTagPath.swift`) | PL-32, VM-7 | S | No phone file references it (grep). VERIFIED |
| G5 | Title suggestion chip | `QuickEntryBar.swift:41-54` (`NoteCardFace.suggestedTitle`) | ABSENT | — | Core | PL-26 | S | |
| G6 | Landing wing and receipt naming where it landed | QuickEntryBar lands in the current wing; receipts name the landing | ABSENT | `Shell/MobileQuickNote.swift:714-718` | Core | — | S | Always Home, bookless, untagged; no receipt. VERIFIED |
| G7 | Box face | — | STALE | `Shell/MobileQuickNote.swift:1228-1274` | phone-local | — | S | Dashed faint border, 11.5 pt text, one line until focused then ~half screen. Her "the box looks awkward". VERIFIED |
| G8 | The quick-note pad (global hotkey, Home + quicknote tag, "Home ▾") | SC "The quick note (the pad)" | ABSENT | — | Mac-local | — | — | A Mac panel by nature; an iOS-native analog is a product call (Q9) |

### 1H. Settings rows (non-protection)

| # | Capability | Mac (contract pointer) | Phone | Phone file(s) | Brain lives | Ticket / ledger | Size | Note |
|---|---|---|---|---|---|---|---|---|
| H1 | Theme (voice) | SC "The app": two voices, Study the fresh-store default, synced `theme_voice` | PARTIAL | `Shell/MobileSettingsView.swift:108-114`; `Theme/MobileVoicePreference.swift:26-36` | phone-local by ruling (LK2) | PL-22 | S | Phone keeps its own unsynced voice, default Terminal. The Mac's fresh default is Study. VERIFIED (Q6) |
| H2 | Palette (17 + custom; sea-glass default) | SC "The app" (VX-710) | ABSENT | — | Shared (`Shared/Theme/PaletteDerivation.swift`, 4-param `VoiceTokens.resolve`) | PL-22, VM-7 | M | The phone calls the palette-less 2-param resolver (`Shared/Theme/VoiceTokens.swift:237-244`), so it never wears the Mac's sea-glass. VERIFIED |
| H3 | Appearance (system / light / dark) | SC "The app" (local preference) | ABSENT | — | — | — | S | Phone follows the system only. VERIFIED (no control) |
| H4 | Receipt style (toast · quiet · off) | SC "Messages…" (synced `receipt_style`) | ABSENT | — | Core (`Q/AppearanceQueries.swift:34,165`) | VM-4 §5 item 5 (hers) | S | Q3 |
| H5 | Default segmentation | AppSpec §7 setting; Settings ▸ Writing | ABSENT | `Write/MobileEditorViewModel.swift:2301` | Core | VM-11 | S | Honoured, not settable. VERIFIED |
| H6 | Savepoint cadence and pruning | Settings ▸ Writing | ABSENT | — | Core | VM-11, PL-11(f) | S | |
| H7 | Settings search | Mac nine searchable panes (`SettingsShape.swift`) | ABSENT | — | Mac-local catalog | PL-36 (candidate) | S | |
| H8 | Acknowledgments | Settings ▸ Acknowledgments | PRESENT | `Shell/MobileSettingsView.swift:172-182` | Shared copy | PL-72 | — | |
| H9 | Diagnostics | Settings ▸ Diagnostics (crash reports opt-in) | STALE | `Shell/MobileSettingsView.swift:208-292` | — | PL-47(a) | S | Release shows a "temporary" edit-trace experiment ("Record edit trace", "Edit trace…"), not behind `#if DEBUG`; no crash-report opt-in. VERIFIED |
| H10 | Help / the pocket guide door | Help ▸ guide doors (SC "The app") | ABSENT | `Shell/MobileSettingsView.swift:294-372` | — | PB1-1 (hers) | S | Open/restore the guide are DEBUG-only. VERIFIED. Onboarding reader's |
| H11 | Editor / Takes / ownership rows | SettingsShape rows `seams`…`hideOwnedDefault` | ABSENT | — | — | VM-11 | — | Other readers' surfaces; listed so the Settings face is designed whole |

### 1I. Messages

| # | Capability | Mac (contract pointer) | Phone | Phone file(s) | Brain lives | Ticket / ledger | Size | Note |
|---|---|---|---|---|---|---|---|---|
| I1 | One status seam with kinds (refusal · offer · receipt) | SC "Messages carry a kind…"; `Registry/StatusCenter.swift` | ABSENT | per-surface slots in every Shell view | Mac-only: `AppSession.status` sits inside `#if os(macOS)` (`Shared/AppSession.swift:693-853`, `:734`) | VM-4 §5 | M | Phone surfaces each keep a red `lastError` line and a muted `receipt` line above the tab bar. VERIFIED. Hoisting `WingsModel` and others needs a phone seam |
| I2 | Refusals in words | SC: "a door that did nothing speaks a refusal" in words | STALE | `Shell/MobileLibraryViewModel.swift:325,341,379,404`; `Shell/MobileScraps.swift:138,167,186,218`; `Shell/MobileShelfViewModel.swift:77,89,129,139,229` | Shared (`OpsRefusalTable`) | — | S | Several phone paths print `String(describing: error)` (a raw enum dump) in the red slot. VERIFIED |
| I3 | Receipt lifetime | Mac receipts fade / quiet line | PARTIAL | `Shell/MobileLibraryViewModel.swift:466-477` | — | — | S | A Library receipt stays until the next delete; no fade. VERIFIED (only writer is the delete) |

**Counts (90 rows):** PRESENT 8 · PARTIAL 13 · STALE 17 · ABSENT 49 · RULED-EXCLUDED 3.
PRESENT: A2 B4 B17 E5 E6 E8 G1 H8. PARTIAL: A1 A5 A6 B3 B11 B16 B18 E1 E3 E12 F1 H1 I3.
STALE: A3 A4 A7 B1 B2 B6 B8 C2 D11 D12 E2 E11 E13 G2 G7 H9 I2. RULED-EXCLUDED: A8 A9 B15. The rest ABSENT.
(C2 and C8 describe the search road as it stands and the wing constraint on it; they are not separate builds.)

---

## 2. What's there but behind

- **The Library is a flat, capped, all-wing feed.** 200 newest-touched notes from all nine wings, books from all
  wings interleaved by stamp, no marker for the rest (`Shell/MobileLibraryViewModel.swift:77,318`;
  `Shell/MobileLibraryView.swift:419-422`). A note she has not touched recently is gone from the Library unless
  she remembers its title.
- **Untitled notes read as dates, twice.** The title slot shows the raw entry date and the trailing slot shows
  the same raw `YYYY-MM-DD` again; an undated untitled note shows its created day with no time at all
  (`Shell/MobileLibraryView.swift:483-492`). The Mac retired both the date-led row (13u3 UNIT B) and the raw
  day key (SC "List and Cards").
- **Search finds titles, not writing.** It is the pre-13o catalog: LIKE over titles and dates, named blocks,
  scrap first lines (then drops the scrap hits), 20 per kind, every wing, no snippets, and a block hit opens
  its note at the top (`Shell/MobileLibraryViewModel.swift:345-395`).
- **The chrome is too small to read or press.** 11.5 pt is the default chrome size everywhere (path lines,
  filter row, search field, tab bar, quick-note box, empty states, receipts). Terminal's 14 pt monospaced body
  is the row title size. Doors have no minimum hit area. The filter row may shrink its words to 70 %
  (`Shell/MobileListingFilters.swift:193`) at Display Zoom. VERIFIED.
- **Vocabulary has drifted from the Mac:** Shelf (Mac: Bookcase), Bookless (Pool), Scraps / pool / scrap
  (Snippets / group / snippet), "smart book" and "hand-picked book" in the Today door's notes
  (`Shell/MobileTodayDoor.swift:70`; the Mac's words are gathering / book). VERIFIED.
- **The quick-note box behaves on an old rule.** ⏎ opens; one paragraph only; no microsyntax; lands in Home
  untagged; dashed, faint, 11.5 pt (PL-27, PL-32). Her lost-prose report is PL-27's evidence.
- **Archived is one-way on the phone.** It can unarchive, but nothing on the phone archives a note, and
  archived books do not show at all (B12, E7).
- **Messages are scattered and sometimes raw.** Each screen speaks in its own two lines above the tab bar;
  some print Swift error dumps; receipts never fade (I1–I3).
- **Settings is a debug-era sheet.** Voice, sync, protection, acknowledgments, tags, and a temporary edit-trace
  experiment shipping in Release. No palette, appearance, receipts, writing or cadence rows; no help door in
  Release (H1–H11).
- **Starred is an unstyled list** of every wing's stars, untitled notes named by date, "note"/"book" as a faint
  kind word (`Shell/MobileStarredView.swift`). PL-63 already records her ask for a design pass.

## 3. The two high-priority items

### 3.1 Wings on the phone

**Her words:** "I have 9, so UI options should work well with many. a quick swipe between them and also a dropdown
option would be nice." And at kickoff: "there are no different wings (!!) so everything just shows up in one bunch".

**What the phone lists today, read by read (all VERIFIED; every read is called with no wing, and each Core read
documents nil as "every wing"):**

| Surface | Read | Phone call site | Effect with 9 wings |
|---|---|---|---|
| Library All / Notes | `observeLibrary(limit: 200)` → `Queries.library` (`Q/Observations.swift:50-62`; `Q/Timeline.swift:211-213` "nil = every wing … (the phone's among them)") | `Shell/MobileLibraryViewModel.swift:318-320` | top 200 across all wings |
| Library Bookless | `Queries.poolPosts(limit:)` | `Shell/MobileLibraryViewModel.swift:334-336` | every wing's loose bookless notes |
| Library Books, Shelf | `Queries.bookshelf(db)` (`Q/ShelfQueries.swift:57`) | `Shell/MobileShelfViewModel.swift:66` | every wing's books in one list; the Shelf's ~8-row region scrolls through all of them (`Shell/MobileShelfLayout.swift:69`) |
| Library search | `Queries.searchCatalog(db, query:)` | `Shell/MobileLibraryViewModel.swift:357-358` | every wing |
| Starred | `Queries.starred(db)` (the Mac calls `starred(db, wingID:)`, `Features/Stars/StarsModel.swift:49`) | `Shell/MobileStars.swift:133,148` | every wing's stars |
| Archived | `observeArchivedPosts(limit:)` | `Shell/MobileArchiveModel.swift:93` | every wing |
| Trash; Empty Trash | `observeTrash(…)` with no wing; Empty Trash counts through `session.wing.readScope` = nil (`Shared/RecoveryActs.swift:412,458,522`) | `Shell/MobileTrashModel.swift:94-97` | every wing; Empty Trash empties every wing's Trash (consistent with what it shows) |
| Tag manager | `observeTags()`, `allTags` | `Shell/MobileTagManager.swift:54,67,181` | every wing's tags; same path repeats per wing |
| Note tag suggestions | `allTags(db)` | `Write/MobileNoteTags.swift:75` | other wings' paths offered; tapping one mints a same-path twin in the note's wing (`Shared/TypedTagPath.swift:143-151`) |
| Add-to-book sheet | `Queries.readings(db)` | `Write/MobileMembership.swift:94-95` | other wings' books offered; the op refuses `crossWingMembership` |
| New note / quick note / Today / new tag / new book | `createPost` / `importPost` / `createTag` with default `wingId: ""` | `Shell/MobileTodayDoor.swift:94-97`, `Shell/MobileQuickNote.swift:714-718`, `Shell/MobileTagManager.swift:163`, PL-69 | always Home |

**Why:** the 13i-d U5 record deliberately left the phone "in Home, unscoped" until the catch-up gave it a wing face
(PL-45; `Shared/WingState.swift:20-21,47-58`). `readScope` returns `currentID` on macOS and `nil` otherwise, and the
bootstrap attaches the device memory and the dead-wing revalidation only on macOS (`Shared/AppBootstrap.swift:497-505`).

**What already exists to build on**

- *Shared, compiled into iOS today:* `WingState` (current wing, wing count, `switchTo`, `attachMemory`
  under key `wing.current`, `revalidate`, `readScope`) — `Shared/WingState.swift`; `WingWords` (the "Home" word,
  the lesson sentence, `contents`, `notEmpty`) — `Shared/WingWords.swift`; the refusal table rows for wing errors
  (`Shared/OpsRefusalTable.swift:352` for `crossWingMembership`).
- *Core:* `Queries.wings` (switcher order, Home virtual and first by convention) `Q/WingQueries.swift:105`;
  `wingIsLive`, `wingContents` `:168`, `effectiveWing(ofPost:)` `:214`, `effectiveWing(ofReading:)` `:226`, `wingName`
  `:235`, `versionPeerSplit`; ops `createWing` / `renameWing` / `deleteWing` / `assertWingNameIsFree`
  (`Ops/Operations+Wing.swift:28,47,71,98`), `moveNoteToWing` / `copyNoteToWing` (`Ops/Operations+WingMove.swift:63,180`),
  `moveReadingToWing` / `moveWingContents` (`Ops/Operations+WingBookMove.swift:68,161`). Every listing read above
  takes `wingID:`; FTS search requires one (`Dom/SearchQuery.swift:233-251`).
- *Mac-local, hoist owed:* `WingSwitcherBrain` (pure, Foundation only; `next(after:in:)` is exactly a "swipe to the
  next wing" rule) `MacViews/WingSwitcherBrain.swift`; `WingsModel` (track/adopt with revalidation, rows,
  `destinations(from:)`, mint/rename/delete asks, move/copy with receipts) `MacViews/WingsModel.swift` — it speaks
  through `session.status`, which is macOS-only, so it needs the phone's message seam (I1) or a callback;
  `WingFollow` (the wing follows the opened note, "Now in …"); `WingDestinationSheet` (the move/copy confirm with
  the stay-behind list).

**What a phone wing face needs (no code proposed — the parts, so tickets can be cut):**
1. The current wing per device: attach `WingState` memory and revalidation on iOS; make `readScope` return the
   current wing (one Shared line); a held `Queries.wings` observation so a wing deleted elsewhere returns her Home.
2. Every read in the table above re-scoped to the current wing (Snippets stay the one shared room, SC "Search…";
   the Trash and Archived per wing, PL-45).
3. Every mint in the current wing (D5) — new note, quick note, new book, new tag; the Today door already follows
   the Journal's wing in Core.
4. The switcher face: a dropdown listing Home + 8 with the current one marked, plus "manage" doors (new, rename,
   delete-unless-empty with `WingWords.notEmpty`, Move Everything). Nine rows fit a native menu without filtering.
5. The quick swipe: a gesture that does not fight the Starred · Shelf · Library band (Q1).
6. Always-visible "in ‹wing›" on the root path lines (the Mac's VX-552 law) and the "Now in …" receipt.
7. Per-note and per-book Move / Copy to Wing doors with the Mac's confirms (stay-behind books named).
8. The cross-wing leaks in D11 close by construction once reads are scoped.
9. A decision on stacks: what happens to notes already pushed on the three stacks when the wing changes (Q2).

Ticket home: VM-6 phase 4a names "the wing switcher + per-wing Archived/Trash + move/copy doors"
(`notes/plans/vm-4-mobile-catch-up.md:291`).

### 3.2 Library row previews

**Her words:** "showing preview more lot apple notes so i know what each note is."

**What a phone row shows today (VERIFIED `Shell/MobileLibraryView.swift:478-518`):** one line — the name from
`DisplayTitle.note` (stored title, else the raw `entry_date` string, else the created day) in `tokens.body`, and on
the right the raw `entry_date` again in `tokens.small` when the note is dated. No first words, no preview, no
time for undated notes, no tags, no books. Long-press offers Star and Delete.

**What the Mac shows (VERIFIED):**
- *List* (`MacLib/LibraryCatalogView.swift:1386-1445`): one line — the lead from `NoteCardFace` (her typed title;
  else the note's first words capped at 48 characters; a journal entry leads with its day), the stated day beside
  it, the tag chips with ＋/✕, the sort's own stamp right-aligned in `TimeStampFace` words (hover = the whole fact),
  owned-by badge, archived mark, and the AI marks. Words are read only for rows that would otherwise be a bare
  date (`MacLib/LibraryCardName.swift:75-99`).
- *Cards* (`MacLib/LibraryCatalogView.swift:1281-1362`) — the Apple-Notes shape: lead line (lead, stamps, badges,
  books it is in) and under it a **two-line preview** that carries on from the lead rather than repeating it, or
  "no text yet" (`LibraryCardName.previewLine`), then tags on hover.

**Which query supplies the Mac's preview, and where it lives:**
- The Library's words come from `NoteCards.load(db, postIDs:, includingBooks:)` — **Mac-app-local**
  (`MacLib/LibraryListingReads.swift:99-176`): one statement over the handed ids, a `ROW_NUMBER()` window keeping
  each note's first 3 blocks (`blockWindow = 3`), each cut by `substr` to 220 characters (`snippetLimit`), using
  Core's `renderedTakeTextSQL` / `renderedTakeJoinSQL`; book names ride along for Cards. Its imports are
  Foundation/GRDB/Core only, so it is hoistable.
- The composition (`LibraryCardName.card`, `previewLine`, `LibraryCardRead.plan`) is Mac-local and pure
  (`MacLib/LibraryCardName.swift:26-100`), and it is written against `Queries.CatalogHit`, not the
  `TimelineItem` the phone lists. `Queries.library` does not even select `profile`, so the phone's rows cannot
  apply the journal rule today (`Q/Timeline.swift:229-231`); `catalogNotesPage` returns `CatalogHit` with
  `profile` and `storedTitle`.
- The brain itself, `NoteCardFace`, is **Core** (`Dom/NoteCardFace.swift`), with `leadCap = 48` (PL-26 says the
  phone's number is ~30) and `sourceLimit = 400`.

**Is the cost viewport-bounded (P1)?**
- *Across rows:* yes on the Mac — the words are read for the near pages only (`loadNearExtras`, pages of 80,
  `MacLib/LibraryCatalogModel.swift:1122-1160`) and only for rows that draw them.
- *Within a note:* **no, for `NoteCards.load`.** The window function numbers every placement of each listed note
  before keeping three. The Mac's own sidebar record measured it: "0.2 ms at 3 blocks, 36 ms at 20,000"
  (`MacLib/SidebarRowLeads.swift:16-22`), which is why the sidebar switched to Core's
  `Queries.leadingBlockTexts`.
- *The flat Core alternative:* `Queries.leadingBlockTexts(db, containerIDs:, blocks:)` (`Q/PostRender.swift:344-367`)
  is one `LIMIT`-stopped, index-ordered seek per note, measured flat in note length (0.017 ms at 20,000 blocks).
  Caveat for the phone: its SQL returns each leading block's **whole** `working_text`, with no `substr`
  (`Q/PostRender.swift:297-313`); `SidebarRowLeads` cuts to 220 characters only after fetching. A note whose
  first block is very large (one-block segmentation, a long paste) would move that whole text per row — a
  memory question on the phone (MS §2). INFERRED risk, not measured.
- *A second Core option:* `Queries.notePickerNotes(ids:)` (`Q/ShelfQueries.swift:1301`) already returns a
  160-character first-block snippet per note, flat (correlated `LIMIT 1`), but only one block and only
  unarchived notes.
- *The phone's own constraint:* its listing is a **held** observation that re-fetches on every container write
  (B2). Reading previews inside that observation would re-read them at autosave rate; the Mac reads its words
  one-shot per page. INFERRED from `Q/Observations.swift:44-49`.

**So the phone needs:** a listing that carries the card facts (title, profile, entry date, created) — `catalogNotesPage`
fits and also fixes B1's cap; a bounded, flat, text-capped "leading texts for these rows" read in Core (today's
pieces: `leadingBlockTexts` + a `substr`, or a hoisted `NoteCards` rewritten flat); the `NoteCardFace` composition
hoisted out of `LibraryCardName` (or re-written against `TimelineItem`); the phone's own cap (~30, PL-26); and a
row face — her call between a List with a preview line and Cards (Q10).

---

## 4. Flow notes — how she moves today

**Launch.** The app opens on the Shelf, the middle of the band (`Shell/MobileShellBand.swift:61-64`). Top line:
"Shelf · N books" (every wing's books), 🗑, "+ New Note", "Settings" — all 11.5 pt. Under it the books region
(about 8 rows, scrolls inside itself) and at the bottom the quick-note box, one line until tapped, then about
half the screen. The tab bar reads `starred · shelf · library`. VERIFIED (`Shell/MobileShelfView.swift:80-245`).

**Between roots.** A horizontal swipe on any root moves Starred ← Shelf → Library; the tab bar does the same.
Leaving the Shelf files whatever is in the quick-note box (`Shell/MobileShellView.swift:407-417,536-540`). Inside a
pushed note or book the band is off and the tab bar is hidden, so changing root is back-back-then-swipe.

**Finding a note.** Library → type in "Search notes, books…" (titles and dates only) or scroll the newest 200;
filters All · Books · Notes · Bookless · Scraps; the sort glyph appears only under All. Tap a row → Write, pushed
on the Library stack. A search hit on a named block opens its note at the top.

**Archived and Trash.** Trash from 🗑 on the Shelf or Library line. Archived is the very last row of the Library
listing, after up to 200 notes (and every book under All). Neither has a wing scope.

**Settings.** Only from the Shelf line; a sheet. Tags are a second sheet inside it (Settings ▸ Manage Tags).

**Awkward points:** the 200 cap with no "more"; untitled rows that are all dates; Archived buried at the bottom;
Settings only from one root; every control 11.5 pt with text-sized hit areas; the swipe band means any further
horizontal gesture on a root surface competes with it; a note opened in one stack stays mounted while she
works in another (`Shell/MobileShellView.swift:10-15`), which keeps the held Library observation busy.

**Cross-reader notes.** Her lag ("going to the quick entry box … from the quick entry box into a note") is the
performance reader's; B2 is a candidate contributor. "A whole pale band around the quick click buttons" most
likely means the Write keyboard bar's surface band (`Write/MobileKeyboardBar.swift:495-516`) — the editor reader's;
INFERRED, worth confirming with her. Book-level surfaces (Shelf rows, shelves, Arrivals, badges, book search,
book archive doors) are the books reader's; the wing face touches them all.

---

## 5. Open questions for the author

1. **The wing swipe vs the root swipe.** A horizontal swipe on Starred / Shelf / Library already changes page.
   (a) Swipe on the top path line (or a wing strip under it) changes wing; the rest of the screen keeps paging.
   (b) Wings change by a dropdown and a swipe on the tab bar; roots keep the full-screen swipe.
   (c) The wing becomes the full-screen swipe and Starred / Shelf / Library become taps only.
2. **What a wing switch does to open screens.** (a) Every stack pops to its root in the new wing (the Mac's
   "a deliberate switch lands in the wing's Bookcase", VX-833). (b) Root pages re-scope; a pushed note stays
   open and its wing shows as "in ‹its wing›" (the Mac's follow, `WingFollow`). (c) Switching is allowed only
   from a root surface.
3. **`receipt_style` on the phone** (already held in `notes/plans/vm-4-mobile-catch-up.md` §5 item 5).
   (a) The phone honours the synced setting with its own quiet line. (b) The phone always uses a quiet line and
   ignores the setting. (c) The phone shows toasts like the Mac's toast style.
4. **Search before wings, or across wings.** Core search requires a wing. (a) Ship search only after the wing
   face, scoped to the current wing. (b) Ship search first over Home only. (c) Rule an "all wings" phone search
   as a named exception to "wings isolate totally".
5. **⏎ in the capture box on a keyboard with no ⇧⏎** (R-13u-4 was ruled "for both platforms"; PL-27).
   (a) ⏎ makes a new paragraph; a visible File / Open button files. (b) ⏎ files and opens (today); paragraphs
   only by paste. (c) ⏎ files without opening and clears the box for the next note; Open is a button.
6. **The phone's voice.** It is phone-local by your LK2 ruling and defaults to Terminal, while a fresh Mac store
   defaults to Study and syncs `theme_voice`. (a) Keep phone-local, default Study. (b) Keep phone-local, default
   Terminal. (c) Follow the synced store voice, with the phone switch writing it.
7. **Names and reach of the two Library filters.** (a) Adopt the Mac's words: Pool, Snippets, groups. (b) Keep
   Bookless / Scraps on the phone. And for Snippets: (i) view + add only, block tags still Mac-side (today's
   "ruling 3"), or (ii) the Mac's acts (edit, delete, move to group, tags).
8. **A ⌘K equivalent.** (a) None; search is the one finder. (b) Search also lists commands. (c) A per-screen
   "…" action sheet carries the acts the palette reaches.
9. **Capture from outside the app** (the Mac has the global quick-note pad). (a) None; the home box is the door.
   (b) A widget or Shortcuts action that files into Home's quicknotes, like the pad. (c) The share sheet as an
   import door.
10. **The row shape she asked for.** (a) Cards as the only Library face (title, two preview lines, stamp).
    (b) List with one preview line under the title. (c) A List / Cards toggle like the Mac's.
