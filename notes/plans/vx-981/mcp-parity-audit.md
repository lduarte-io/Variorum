# The MCP parity audit (VX-368)

*Written in the VX-981 run, batch 5 (2026-11-19), against the catalog and the app at the run's final code tree (`558ca7101`). The method, the counts and the proposed tickets are also in the run record's BATCH 5 — RECORD (`notes/plans/fixes/vx-981-mcp-door-followups.md`).*

## For a later reader

**What this is.** Her ruling R-VX184-1 says the edit rung is "as capable as her at the keyboard", and R-13nb-14 sets the bar: within a grant's scope and rung the wire exposes the full model, and an exclusion needs an affirmative reason (the fence, or a feature she calls underbaked). This audit lists every act she has at the keyboard against the wire's 74 tools and, for each gap, proposes a ticket or a stated exception. It decides nothing: every recommendation below is hers to rule.

**The counts.** 91 act rows, covering all 243 capability declarations (each in exactly one row — the appendix) and the acts her app reaches through undeclared doors (17 rows are undeclared doors only; 7 more add undeclared doors to declared ones). Of the 91: 46 are covered by the wire (35 by one tool, 11 by composing tools), 10 are her ruled exceptions, 23 are gaps proposed as tickets (5 of them map to open tickets: VX-159 twice, VX-147, VX-145, VX-146 in part — so 18 new), and 12 are gaps proposed as stated exceptions. The reads table has 16 rows: 14 things she can see that a read-rung client cannot ask for (4 new tickets, the rest riding act-row or open tickets), 1 covered row, 1 ruled row. The ticket's five named gaps are all confirmed.

**The gaps that matter most.**
1. **The structural editing family** — extract, move a passage into a new take, the divide and merge ceremonies (copy-to-both, keep-below, pair by hand) and turning takes into blocks. These are the core of the block model; the wire divides and merges only by her default presets.
2. **Snippets.** The scraps area — the inspiration pool, one of the pillars — has no grant place at all, so a client can neither read nor write it. It is shared across wings, so a grant for it is a design question for her.
3. **Tags and books as configuration** — renaming a tag, word targets, pins, shelves, duplicating a book, a book's Arrivals. Most organizing an assistant would do is reachable; these are the holes in it.
4. **Reading a book in her order.** `list_notes` on a book lists the hand order, not the order the book shows (its sort, pinned notes first, its chapters), while its description says "in book order" — recorded as a bug below, not only a gap.

## How to read the tables

- `CR` is `App/Variorum/Variorum/Registry/CapabilityRegistry.swift`, `TC` is `Sources/VariorumMCP/MCPToolCatalog.swift`, `F/` is `App/Variorum/Variorum/Features/`, `CV/` is `App/Variorum/Variorum/Core/Views/`, `SH/` is `App/Variorum/Shared/`. A `CR:` line is the act's capability declaration; any other door is the line that calls the act's operation. A `TC:` line is the tool's `name:` line.
- **The rung rules** the proposals use, each read off the existing catalog:
  - (S) a structural gesture rides edit — `divide_block`, `merge_blocks`, `move_block`, `delete_block` (TC:1071–1136).
  - (W) a write that changes her words rides edit (`edit_take`, TC:1023); a take added beside hers rides suggest (`add_take`, TC:605).
  - (M) a mint rides write new — `create_note`, `create_book`, `create_section`, `insert_blocks` at the end (TC:785, 929, 1004, 1332).
  - (C) a copy rides read on the source and write new where it lands — `duplicate_note`, `copy_note_to_wing` (TC:1397, 1462).
  - (V) a move rides edit on the thing and write new where it lands — `move_note_to_wing`, `move_book_to_wing` (TC:1174, 1207).
  - (E) her state and metadata acts on a note or a book ride edit — `rename_note`, `set_entry_date`, `finish_book` … `delete_book`, `set_book_order` (TC:1777, 2243, 1854–1903, 2130).
  - (R) a book's collecting rule rides write new — `set_book_rule` (TC:2296; its order rides edit, A-809-17).
  - (L) a lens changes no word: making one rides suggest (`save_lens`, TC:742); deleting or adopting one rides edit (TC:1796, 2204).
  - (G) a gathering acts at edit on its own place (VX-639).
- **Recommendation words.** *Ticket* — a proposed ticket, with its shape. *Exception* — a proposed stated exception, with the affirmative reason R-13nb-14 asks for. *Ruled* — already hers by a ruling. *Covered* — a tool does it; *composed* — tools do it together, with what the composition loses.

## The acts, gaps first

### Gaps — proposed tickets

| # | Act | Her door | §9 op | Wire | Rung by the rules | Open ticket | Recommendation |
|---|---|---|---|---|---|---|---|
| 1 | Extract a span into its own block (⌘⇧E) | CR:248; `F/Editor/EditorSurfaceController.swift:328` | `extract` | none | edit (S) | — | Ticket: `extract_block` — block_id and the span's words (a prefix or suffix of the shown take, matched exactly once as `divide_block` matches), the new block placed beside with its lineage edge; one client-named undo |
| 2 | Move the selected words into a new take | CR:312; `F/Editor/EditorSurfaceController.swift:2831` | `moveSpanToNewTake` | none | edit (W — it rewrites her take) | — | Ticket: `move_span_to_take` — take_id and `old_str` (exactly once, `edit_take`'s replace match); the passage leaves the take for a new take on the block, the quiet savepoint first; one undo |
| 3 | Divide choosing takes… and its presets: keep takes below, copy takes to both, choose per take (⌥⌘⇧D) | CR:242; `F/Editor/EditorSurfaceController.swift:3318` | `divideW`, `divideDuplicating` | none — `divide_block` (TC:1071) is keep-on-top, her ⌘⇧D default | edit (S) | VX-159 (names choose-per-take; copy-to-both and keep-below are the same sheet) | Ticket: fold the two presets into VX-159 — `divide_block` gains `takes: "top" \| "bottom" \| "both"` beside the per-take form |
| 4 | Merge choosing takes… — pair by hand, only the two shown (⌥⌘⇧M) | CR:270; `F/Editor/MergeArrangement.swift:190` | `mergeCeremony` | none — `merge_blocks` (TC:1093) is "bring every take", her ⌘⇧M default | edit (S) | VX-159 | Ticket: VX-159 as filed |
| 5 | Rename a tag (and its subtree) | Settings ▸ Tags, undeclared: `F/Settings/AppSettingsView.swift:1328` | `renameTag` | none — `replace_tag` (TC:1528) moves applications, it renames nothing | edit on the tag's wing (`replace_tag`'s scope) | — | Ticket, with her call on one point: the rename reaches every wearer, hidden ones too (P-VX196-8's "the act is the book's" posture, ratified at #218, would read it as the tag's act); the answer names nothing hidden |
| 6 | A note's word target; a book's word target and note limit | note: `F/Takes/TakesBottomBar.swift:625`, `F/Editor/CommitBar.swift:485`; book: CR:2227, `CV/BookRowMenu.swift:423` | `setPostWordTarget`, `setReadingWordTarget`, `setReadingMaxPosts` | none (a book's two are READ by `list_books`, `Sources/VariorumMCP/MCPBookRules.swift:37`) | edit (E) | — | Ticket: `set_word_target` — note_id or book_id, words or null; book_id also takes `max_notes`; `read_note` gains the note's target |
| 7 | Snippets: add, edit, delete, archive a snippet; a new group; copy a snippet into a draft; move a block there | CR:728, 743; `F/Pool/SnippetsSurface.swift:336`; `F/Editor/EditorViewModel.swift:3414` | `createPool`, `newBlock` on a pool, `poolDragCopy`, `deleteBlock` | none — no grant place reaches the scraps room (P-13nb-U1-4: a pool answers as unshared), and it is shared across wings | no rung today: it needs a grant place | — | Ticket, her design call first: a Snippets grant place, then the existing tools read and write it (tagging a snippet stays out — row 45) |
| 8 | Put back a note, a book or a chapter from the Trash | undeclared Put back rows: `F/Library/LibraryViewModel.swift:209`, `SH/RecoveryActs.swift:131`, `:145`; chapter `F/BookView/BookStructureModel.swift:229` | `restoreContainer`, `restoreReading`, `restoreSection` | none — the wire's way back from its own `delete_note` is her ⌥⌘Z; `put_back` (TC:2225) is the note's tray only | edit (`restore_comment`'s rung, TC:1584) | — | Ticket: `restore_note` / `restore_book` / `restore_chapter` by an id the client read before the delete or deleted itself (`restore_comment`'s precedent), inside the 30 days; one undo |
| 9 | Archive a block; unarchive it from the tray | CR:390; `F/Tray/TrayPanel.swift:563` | `archiveBlock`, `unarchiveBlock` | none | edit (`archive_take`'s rung, TC:1634) | — | Ticket: `archive_block` / `unarchive_block`, and the tray's Archived view in `read_note`'s `with_tray` |
| 10 | Pin a note to the top of a book / unpin | CR:2189; `CV/PinNote.swift:67` | `setMembershipPinned` | none (pins are not read either) | edit (E — a book's order, `move_note_in_book`'s rung, TC:1938) | — | Ticket: `pin_note_in_book`, and `pinned` on `list_notes(book_id)` rows |
| 11 | Move a take earlier or later in its fan | CR:541, 547; `F/Takes/TakesStructureController.swift:659` | `reorderTake` | none | edit (S — the fan's order) | — | Ticket: `move_take` — after or before another take of its block, or first or last |
| 12 | Move a take into a block below; turn every take into blocks (⌥⌘⏎, ⇧⌥⌘⏎) | CR:654, 660 | `takeToBlockBelow`, `takesToBlocks` | none — composable as `insert_blocks` + `archive_take`, but without the lineage edge and as two undos | edit (`insert_blocks` past the end, TC:1332) | — | Ticket: `take_to_block` (one take, or a block's whole fan) — AR-1's mint-copy with the source archived, one undo |
| 13 | Rename a lens; duplicate it; change its picks; promote a lens to a note | CR:681; `F/Takes/LensesBoardView.swift:877`; `F/Takes/TakesViewModel.swift:1652`, `:1902` | `renameLens`, `duplicateLens`, `setLensChoice`, `promoteLens` | none (`save_lens` makes one, TC:742) | rename and picks: edit (L); duplicate: suggest (L); promote: read + write new (C) | — | Ticket: `update_lens` (name, picks by take_ids), `duplicate_lens`; `promote_lens` as its own (a copy of the note read through the lens) |
| 14 | A callout frame on a block (⌥⌘C) | CR:1387 | `updateBlockPresentation` | none (not read either) | edit (`set_block_name`'s rung, TC:1153) | VX-147 | Ticket: VX-147 as filed |
| 15 | Attach, remove or reorder a reference beside a note | `F/References/ReferencesViewModel.swift:103`, `:154` | `addReference`, `removeReference`, `reorderReference` | none (not read either) | attach: write new (M); remove, reorder: edit | VX-146 (reads only) | Ticket: widen VX-146 to URL references written on the wire; a file reference stays hers (row 30's exception note) |
| 16 | Restore a saved version into the note; promote a saved version | `SH/VersionActs.swift:67`, `:79` | `restoreNoteVersion`, `promoteNoteVersion` | none — `unlink_versions` on a saved version's link refuses in words (P-915-B6-2, #273 open) | edit | VX-145 | Ticket: VX-145 as filed. Note for it: the restore takes the Delete Now road with no undo entry, so a wire form needs an undo the operation does not have |
| 17 | Put back a released original; bring a lineage relative's text back as a take | CR:978, 984; `SH/RecoveryActs.swift:288`; `F/History/CommitsFaceModel.swift:949` | `placeBlock`, `bringBackFromLineage` | none | put back: edit (`put_back`'s rung); bring back: suggest (W — a take beside hers) | — | Ticket: `put_back` takes a released original's block_id; `add_take` takes a lineage source (`from_take_id` or `from_commit_id`, the label and parent kept) — row 48's exact form too |
| 18 | Duplicate a book (shallow, or with copies) | CR:2200; `F/Readings/DuplicateBook.swift:120` | `duplicateReading` | none | read on the book + write new on its wing (C) | — | Ticket: `duplicate_book` (an owned book with copies only, as her door) |
| 19 | Diverge a note for one book | CR:1930; `SH/AppSession.swift:535` | `divergePostForReading` | none — composable (`duplicate_note` into the book, `remove_note_from_book`, `move_note_in_book`) but not into the exact slot and as three undos | read on the note + edit on the book | — | Ticket (low): `diverge_note_for_book` |
| 20 | Shelves: make, rename, glyph, default, order, delete; a book's shelf and place | CR:2248–2302; `F/Shelf/ShelfViewModel.swift:467` | the shelf operations, `setReadingShelf`, `placeReading` | none — `list_books` carries no shelf | edit on a wing grant (shelves are per wing) | — | Ticket (low): a book's shelf on `list_books`, `set_book_shelf`, and a shelf family on a wing grant |
| 21 | Rename a wing | CR:2502; `CV/WingsModel.swift:260` | `renameWing` | none | edit on the wing (E) | — | Ticket (low): `rename_wing` on a wing grant |
| 22 | A book's journal trait; a gathering's hide-owned setting | CR:2460, 2483 | `setJournalTrait`, `setReadingHideOwned` | none (neither is read) | edit on the place (E, G) | — | Ticket (low): both on the wire, read back on `list_books` (the trait is not fenced — VX-163) |
| 23 | Compare's outline note (an outline minted from a draft) | `F/Takes/CompareBoardView.swift:1066` | `mintOutlinePost` | none — `create_note` + `link_versions` gives the version link but not the outline's per-block lineage | read on the draft + write new on its wing (C) | — | Ticket (low): `create_outline_note` |

### Gaps — proposed exceptions

| # | Act | Her door | §9 op | Wire | Rung by the rules | Open ticket | Recommendation |
|---|---|---|---|---|---|---|---|
| 24 | Arrivals: add or dismiss a waiting note, one or in bulk | CR:1974–2013; `F/BookView/BookArrivals.swift:475`, `:551` | `seatArrival`, `dismissArrival` | none | edit on the book (E) | — | Exception: the door is built so a client proposes and she judges — "an AI proposal is never a seat on any road" (MCPSpec, VX-811); a wire seat would be that seat by another road, and a dismissal decides a pair for her forever. Reading what waits is a ticket (reads row 2) |
| 25 | Use as Daily Journal | CR:2233; `CV/BookRowMenu.swift:474` | `setDailyJournalBook` | none | edit on the book (E) | — | Exception: it moves the fence — every member of the daily Journal is fenced (13n-c U1), so the act would fence or unfence notes; R-VX184-2's reason for Private |
| 26 | Bind a gathering into a book | CR:2047; `F/Readings/BookRowActs.swift:31` | `convertSmartReadingToCurated` | none | edit on the gathering (G) | — | Exception: VX-639 (her RB-7) keeps "a gathering's finish, its notes' membership and its rule" as they are; binding makes its membership real |
| 27 | Make a wing; delete an empty wing; move everything to another wing | CR:2496, 2508, 2579 | `createWing`, `deleteWing`, `moveWingContents` | none | make: no place to act under; delete: edit on the wing (E); move everything: edit + write new (V) | — | Exception: a wing is the widest grant place — no grant can name a wing not yet made, and deleting one removes the place its grants stand on; moving everything composes from `move_book_to_wing` and `move_note_to_wing` |
| 28 | Delete forever: a deleted comment, Delete Now, Empty Trash, the empty-block sweep | CR:1367, 1203, 1211, 1223; `SH/RecoveryActs.swift:448`; `CV/CommentsPanel.swift:458` | the purge road (`requestPurge`) | none | edit (E) | — | Exception: permanent, with no way back, while every wire act is one client-named ⌥⌘Z (P-VX195-1, P-VX196-1, ratified at #218) |
| 29 | Structural undo and redo (⌥⌘Z, ⇧⌥⌘Z) | CR:1238, 1250 | the undo stack | none | no place: the stack is the session's | — | Exception: the stack is her session's and holds her acts beside every client's, so a client's undo could walk back hers; a client's way back is an inverse tool, its recovery `list_my_activity` |
| 30 | Settings and appearance, and the per-note segmentation chip | `F/Settings/AppSettingsView.swift:1015`; `F/Editor/EditorViewModel.swift:3338` | the setting operations, `setSegmentationDefault` | none | no place: settings are the library's | — | Exception: her room's configuration, not writing; a client picks its own block boundaries by sending `blocks`. A file reference (row 15) stays hers on the same footing — its security-scoped bookmark is this Mac's permission |
| 31 | Grants, approvals, the MCP pane and its dials; the AI section; ⌥⌘O; the share doors | CR:2893–2955, 2989–3130, 1269 | the grant operations | none | no place: the consent is the library's | — | Exception: the door's consent — a client's write must never widen its own reach (P-13nb-U4-16), and a mint grants nothing (`create_gathering`, P-771-2) |
| 32 | Library-level acts: export the library, send it to another Mac, back up, the plaintext export, the search index, crash reports, Lock Library Now | CR:2685, 2825, 2788–2809, 2836, 2842, 2854, 2861, 3203 | backup, export, protection and index operations | none | no place above a wing | — | Exception: no grant place sits above a wing, and protection is CastleRules' and hers; the registry keeps these off ⌘K on purpose |
| 33 | Seeded restores and the tour | CR:2706–2777 | the seeders | none | no place above a wing | — | Exception: app seeding over the whole library (the field guide's restore deletes and re-seeds) |
| 34 | The Canvas: arrange cards, the bank | CR:777, 783 | `setCanvasPosition` | none | edit (S), were it shipped | — | Exception: Debug-only (SurfaceContracts, the note's mode row) |
| 35 | View and navigation: modes, panes, splits, windows, find bars, history and lineage faces, the Book Panel, wing switching, the helper | 45 declarations (the appendix, row 35) | none — view state | `show_in_app` (TC:2335) for seven targets | read | — | Exception: her window's state, not the store; the wire's one road into her view is an offer she takes (R-13nb-23, VX-676) |

### Ruled exceptions (hers by a ruling)

| # | Act | Her door | §9 op | Wire | Ruling |
|---|---|---|---|---|---|
| 36 | Private, on a note or a book | CR:2975, 2981; `CV/PrivateMark.swift:262` | `setNotePrivate`, `setBookPrivate` | none | R-VX184-2 — no MCP road writes `ai_private_at` |
| 37 | Seal or unseal a note; seal or unseal a book | CR:1278, 2084, 2090; `F/Readings/BookStateDoors.swift:791` | `lockPost`, `sealReading`, `unsealReading` | none (`reopen_book` says unsealing is hers, TC:1866) | R-VX184-2 — no road writes `sealed_at` |
| 38 | Own Its Notes… / Stop Owning | CR:2096, 2102; `F/Readings/BookStateDoors.swift:797` | `setReadingOwned` | none | R-VX184-2 — no road writes `owned` |
| 39 | A gathering's rule | CR:2031 on a gathering; `F/Readings/RuleEditor.swift:432` | `setReadingQuerySpec` | `set_book_rule` answers the gathering sentence (TC:2296) | VX-639 (her RB-7, "the rule staying hers"); A-648-5, ratified |
| 40 | Move a gathering to another wing | CR:2571 on a gathering | `moveReadingToWing` | `move_book_to_wing` refuses it (TC:1207) | A-809-16 / P-809-11, ratified at #262 ("a deliberate departure from R-VX184-1's parity, hers to flip") |
| 41 | Delete the daily Journal; move it to another wing | CR:2114, 2571 on the Journal | `deleteReading`, `moveReadingToWing` | both refuse (the shared Journal fences, MCPSpec) | R-805-5 |
| 42 | ⌘J — today's entry; a new entry in the daily Journal | CR:2591; `F/BookView/BookStructureModel.swift:840` | `createOrOpenJournalEntry`, `newJournalEntry` | none — the daily Journal answers the one not-shared shape | the fence (VX-163's keys, 13n-c U1): the daily Journal is never a grant place, its entries per ask only |
| 43 | Delete an owned book together with its notes; archive it with its notes | CR:2114, 2129 (the owned book's second choice); `F/Readings/BookStateDoors.swift:828`, `:806` | `deleteReadingWithNotes`, `archiveReadingWithNotes` | none — `delete_book` and `archive_book` are book-only | P-VX196-3, ratified at #218 |
| 44 | Delete a tag; delete the unused tags | CR:2870, 2880 | `deleteTag`, `deleteUnusedTags` | none — `remove_tag` says deleting a tag is the author's alone (TC:1495) | MCPSpec, VX-764 ("the deletion, which stays hers"); P-771-12 kept as built at #258 |
| 45 | Tag a block or a snippet | CR:697 | `applyTag` on a block | none — `apply_tag` takes notes | R-13nb-14: block-level tags named out at her word ("an underbaked idea"); VX-128 open |

### Covered by composing tools

A covered row's rung is its tool's own, as `TC` declares it; no open ticket covers any of these rows.

| # | Act | Her door | §9 op | Wire | What the composition loses |
|---|---|---|---|---|---|
| 46 | New take (branch), blank take, blank take as chosen, diverge here (⌘T, ⌥⌘T, ⇧⌥⌘T) | CR:420, 426, 432, 789 | `branchVariant`, `newBlankVariant` | `add_take` (TC:605) + `choose_take` (TC:2183) | the branch's parent link; the take wears the client's label |
| 47 | Merge selected blocks, delete selected blocks, the three split-at-newlines acts, Make Block, Delete in Every Take, Replace All in Every Take | CR:560, 581, 601, 608, 615, 254, 276, 1457 | `merge`, `deleteBlock`, `divide`, `splitBlockAtNewlines`, `editTakesAtomically` | repeated `merge_blocks`, `delete_block`, `divide_block`, `edit_take` | one undo each, not one for the whole act |
| 48 | Bring back a commit as a take | CR:934; `F/History/CommitsFaceModel.swift:825` | `bringBackCommitAsTake` | `read_note` with_commits + `add_take` | the parent link and the commit's name as label (row 17's ticket) |
| 49 | Shift a date a day earlier (⌥⌘J) | CR:2679 | `shiftEntryDate` | `set_entry_date` (TC:2243) | nothing |
| 50 | Copy in / Move in at the membership choice | CR:2154, 2160 | `copyPostIntoReading`, `movePostIntoReading` | `duplicate_note` with book_id (TC:1397); `remove_note_from_book` + `add_note_to_book` | one undo |
| 51 | Make a book from a gathering | CR:2053 | `createReading` with the rule | `create_book` + `set_book_rule` | nothing |
| 52 | Tag every member with the book's outflow | `F/Readings/RuleEditor.swift:464` | `tagAllMembers` | `apply_tag` with `note_ids` (TC:909) | one undo |
| 53 | Collect a note into a gathering | `F/Shelf/ShelfViewModel.swift:652` | `collectPostIntoSmartReading` | `apply_tag` / `set_starred` | nothing |
| 54 | The quick note; file without opening (⌘⇧N, ⌘⏎) | CR:1834, 1882 | `importPost`, `fileAsQuicknote` | `create_note` with wing "" and the quicknote tag | nothing |
| 55 | Lenses: new takes everywhere; a write column | `F/Takes/TakesViewModel.swift:1958`, `:1304` | `branchAllFans` | `add_takes` (TC:647) | the parent links |
| 56 | Make a tag with no wearer yet (Settings ▸ Tags) | `F/Settings/AppSettingsView.swift:1314` | `createTag` | `apply_tag` makes a missing tag on first use | a tag with no wearer |

### Covered by a tool

| # | Act | Her door | §9 op | Wire |
|---|---|---|---|---|
| 57 | New note; a new note in a book (⌥⌘N) or a gathering | CR:2586, 2427, 2394 | `createPost`, `newPostInReading`, `newPostInGathering` | `create_note` (TC:785) |
| 58 | Import… a file or a folder | CR:2608 | `importDocument`, `importBook` | `import_document` (TC:858) |
| 59 | Find and export at her keyboard: ⌘K, a book's search, Copy All Takes, Copy full text, Export Note…, Export Block | CR:2596, 2384, 636, 2617, 2650, 1393 | reads | `search` (TC:412), `read_note` (TC:333), `export_note` (TC:444) — the reads table |
| 60 | Rename a note | CR:1177 | `renameContainer` | `rename_note` (TC:1777) |
| 61 | Delete a note; delete the selected notes | CR:1122, 1143 | `deleteContainer` | `delete_note`, `note_ids` (TC:2032) |
| 62 | Archive or unarchive a note | CR:1157, 2477 | `archiveContainer`, `unarchiveContainer` | `archive_note`, `unarchive_note` (TC:2051, 2061) |
| 63 | Duplicate with tags / without tags | CR:1070, 1076 | `duplicateAsVersion` | `duplicate_note` with `with_tags` (TC:1397) |
| 64 | Move or copy a note to another wing (⌥⌘L, ⇧⌥⌘L) | CR:2533, 2542 | `moveNoteToWing`, `copyNoteToWing` | `move_note_to_wing`, `copy_note_to_wing` (TC:1174, 1462) |
| 65 | Move a book to another wing | CR:2571 | `moveReadingToWing` | `move_book_to_wing` (TC:1207) — books; a gathering and the Journal are rows 40–41 |
| 66 | Star or unstar a note, book or gathering | CR:1896 | `setStarred` | `set_starred` (TC:2079) |
| 67 | Set a note's date | `F/Editor/EditorViewModel.swift:3382` | `setEntryDate` | `set_entry_date` (TC:2243) |
| 68 | Save a version (⌘⇧S) | CR:1019 | `saveNoteVersion` | `save_version` (TC:2260) |
| 69 | Tag or untag a note; a gathering's "remove #tag" | CR:759, 2360 | `applyTag`, `removeTag` | `apply_tag`, `remove_tag` (TC:909, 1495) |
| 70 | Commit (⌘S); restore a commit; name a commit | CR:1232, 927, 948 | `commit`, `restoreCommit`, `renameCommitPoint` | `save_commit`, `restore_commit`, `rename_commit` (TC:2160, 1732, 1757) |
| 71 | Choose a take; step to the previous or next take (⌘⏎, ⌃⌘←, ⌃⌘→) | CR:438, 444, 450 | `chooseVariant` | `choose_take` (TC:2183) |
| 72 | Archive, unarchive, lock, unlock, delete or label a take | CR:456, 526, 514, 520, 668 | `archiveVariant` … `setTakeLabel` | `archive_take` … `set_take_label` (TC:1609–1715) |
| 73 | Put back a take or a block from the note's tray | CR:853; `F/Tray/TrayPanel.swift:601` | `restoreVariant`, `restoreBlock` | `put_back` (TC:2225) |
| 74 | Divide at the cursor (⌘⇧D) | CR:217 | `divide` (keep-on-top on a fan) | `divide_block` (TC:1071) |
| 75 | Merge blocks (⌘⇧M) | CR:260 | `merge` (every take along) | `merge_blocks` (TC:1093) |
| 76 | New block at the end; new block below (⌘⇧⏎) | CR:319, 330 | `newBlock` | `insert_blocks` (TC:1332) — the end at write new, anywhere at edit |
| 77 | Delete a block | CR:360 | `deleteBlock` | `delete_block` (TC:1136) |
| 78 | Move a block, within a note or to another | `F/TOC/BlockTOCView.swift:445` | `moveBlock`, `reorder` | `move_block` (TC:1113) |
| 79 | Name a block | `F/TOC/BlockTOCView.swift:371` | `setBlockName` | `set_block_name` (TC:1153) |
| 80 | Comments: add, save an edit, delete, restore | CR:1333, 1339, 1351, 1357 | the comment operations | `add_comment(s)`, `edit_comment`, `delete_comment`, `restore_comment` (TC:629–718, 1560, 1584) |
| 81 | Formatting: bold … outdent; Paste Without Line Breaks | CR:1546–1640 | markdown is the take's text | `edit_take` (TC:1023) |
| 82 | Save choices as a lens (⌘⇧L); delete a lens; make a lens the note | CR:466; `F/Takes/TakesViewModel.swift:1998`, `:1872` | `createLens`, `deleteLens`, `adoptLensPreservingChosen` | `save_lens`, `delete_lens`, `adopt_lens` (TC:742, 1796, 2204) |
| 83 | Mark or unmark two notes as versions in Compare | `F/Takes/CompareBoardView.swift:984`, `:1025` | `markPostsAsVersions`, `unmarkPostsAsVersions` | `link_versions`, `unlink_versions` (TC:1246, 1299) — finer, by named pairs |
| 84 | New book | `F/Readings/ReadingsViewModel.swift:74` | `createReading` | `create_book` (TC:929) |
| 85 | Rename, finish, reopen, archive, unarchive or delete a book | CR:2215, 2072, 2078, 2129, 2135, 2114 | the reading operations | `rename_book` … `delete_book` (TC:1830–1903) |
| 86 | A book's rule, outflow and new-matches dial (Edit…) | CR:2031; `F/Readings/RuleEditor.swift:432` | `setReadingQuerySpec`, `setReadingOutflow`, `setReadingIntakeSeating` | `set_book_rule` (TC:2296) |
| 87 | Save as This Book's Order | `F/BookView/BookSettingsSheet.swift:481` | `setReadingSort` | `set_book_order` (TC:2130) |
| 88 | Manage Notes…; add a note to a book; Remove or Release | CR:2221, 2175 | `addPostToReading`, `removePostFromReading` | `add_note_to_book`, `remove_note_from_book` (TC:979, 1917) |
| 89 | Chapters: add, rename, delete, move; file a note; move a note up or down | `F/BookView/BookStructureModel.swift:213`; CR:2328–2352 | the section operations, `assignPostToSection`, `reorderReadingPost` | `create_section`, `rename_chapter`, `delete_chapter`, `move_chapter`, `file_note_in_chapter`, `move_note_in_book` |
| 90 | A new gathering; save a book's filter as a gathering | CR:2466 | `createReading` with a rule, `saveFilterAsGathering` | `create_gathering` (TC:953) |
| 91 | A gathering's rename, archive, unarchive, delete, star and order | the book doors on a gathering | as rows 85–87 | the book tools at edit on its place (VX-639) |

## What she can see that a read-rung client cannot ask for

| # | What she sees | Wire read | Open ticket | Recommendation |
|---|---|---|---|---|
| 1 | A book's notes in the order the book shows — its sort, pinned notes first, chapter by chapter | `list_notes(book_id)` lists the hand order, `(position, id)` (`Sources/VariorumMCP/MCPReadTools.swift:886`); a gathering lists in its own order | — | Ticket, with the bug below: list in `Queries.assembleReading`'s order, the one order home |
| 2 | What waits at a book's Arrivals: who, why, since when | none — `set_book_rule` counts waiters, `propose_notes_to_book` answers `changed: false` for one | — | Ticket: `list_arrivals` at read, readable rows only, with why-it-waits |
| 3 | Whether a note or a book is starred | none — `set_starred` answers `changed` | — | Ticket (with row 4 of this table): `starred` on `list_notes` and `list_books` rows |
| 4 | Whether a take is locked; whether a note is sealed | none — a refusal is the only way to learn | — | Ticket: `locked` per take and `sealed` per note on `read_note`'s JSON |
| 5 | Pinned notes in a book | none | — | Row 10's ticket |
| 6 | A book's shelf; the Bookcase's shelves | none | — | Row 20's ticket |
| 7 | A note's word target | none (a book's target and limit are read) | — | Row 6's ticket |
| 8 | Callout frames | none | VX-147 | VX-147 as filed |
| 9 | References beside a note | none | VX-146 | VX-146 as filed |
| 10 | Deleted comments (the panel's fold) | none | VX-148 | VX-148 as filed |
| 11 | The tray's Archived view; released originals | `with_tray` reads the leaving section only (`Sources/VariorumMCP/MCPNoteStructure.swift:565`) | — | Rows 9 and 17's tickets |
| 12 | The Trash and its 30-day clocks | none (`list_my_activity` names the client's own deletes) | — | Row 8's ticket |
| 13 | Snippets | none | — | Row 7's ticket |
| 14 | A wing's tag vocabulary (Settings ▸ Tags) | only tags worn by notes it can read, row by row | — | Ticket (low): `list_tags` over the tags notes in reach wear (derivable now, so no new bit); the whole vocabulary is P-809-9's residual question, hers |
| 15 | Covered: a note's text and takes, commits, lineage, versions, lenses, the tray's leaving section, books and their collecting facts, wings, search with commits and archived things, plain text, the document format, archived notes and books, the client's own activity | `read_note`, `list_note_lineage`, `list_books`, `list_wings`, `search`, `export_note`, `list_notes`, `list_my_activity` | — | Covered |
| 16 | Ruled out: the daily Journal, Private things, and other clients' activity | the fence answers one not-shared shape; `list_my_activity` lists its own client only | — | Ruled (the fence, 13n-c U1; R-VX184-2; P-VX261-1) |

The library's settings (the segmentation default and the rest) are not read either; they ride row 30's exception.

## The five gaps the ticket names

All five are confirmed against today's catalog — no tool reaches any of them:

1. **Move a span to a new take** — confirmed: no tool calls `moveSpanToNewTake`; row 2.
2. **Rename a tag** — confirmed: no tool calls `renameTag`; `replace_tag` (TC:1528, VX-812) swaps applications across a wing and renames nothing; row 5.
3. **Extract** — confirmed: no tool calls `extract`; row 1.
4. **The copy-takes divide** — confirmed: no tool calls `divideDuplicating`; `divide_block` (TC:1071) is keep-on-top only; row 3.
5. **Word targets** — confirmed for every write: no tool calls `setPostWordTarget`, `setReadingWordTarget` or `setReadingMaxPosts`. A book's target and limit are READ (`list_books`, `MCPBookRules.swift:37–38`); a note's is not; row 6.

The tickets the brief lists: VX-145 (row 16), VX-146 (row 15, reads row 9), VX-147 (row 14, reads row 8), VX-148 (reads row 10) and VX-159 (rows 3–4) each cover a gap. VX-161 (a setting about search results and AI) and VX-316 (an icon on commits an AI made) are on the MCP board but cover none of these acts.

## Acts the wire has that her keyboard does not

- **`replace_tag`** (TC:1528) — one tag swapped for another across a wing; her nearest road is tagging note by note.
- **`link_versions` by named block pairs and `unlink_versions` by one link** (TC:1246, 1299) — finer than Compare's mark and unmark.
- **`save_lens` by a label** (TC:742) — no keyboard twin.
- **`propose_notes_to_book`** (TC:566) — a client's act by nature: she seats directly.
- **An undo her own door lacks** — `move_note_to_wing`, `move_book_to_wing` and `set_starred` wrap her undo-less doors with one client-named entry (MCPSpec); `set_entry_date`'s undo likewise (her date doors take none, AppSpec §9 `shiftEntryDate`).
- **Reading aids** — `sha256` digests, `ids_only` pages, `fan_sha256`, `list_my_activity`: not acts, the client's way to check its own work.

## Found while auditing — bugs, not gaps (traced in the code, not run; nothing fixed)

1. **`list_notes` on a book does not list "in book order".** Its description says "With book_id: that book's notes in book order" (TC:299). The listing is `bookPage`, keyset-paged `ORDER BY rp.position, c.id` (`Sources/VariorumMCP/MCPReadTools.swift:886–905`) — the hand order. A book whose order is a sort (`set_book_order`'s entry_date, created_at, last_touched or last_major_revision) shows its notes in that sort; a pinned note floats to the top of its chapter; a chaptered book shows its notes chapter by chapter. AppSpec §9 puts the order in one home, `Queries.assembleReading`, "everywhere the order renders", and the gathering listing does read it (`MCPReadTools.swift:970`). So a client reading a date-sorted or pinned book gets a different order than she sees, and the description says it is hers. The VX-808 record saw it and pointed it here ("parity is VX-368's audit"). The fix's shape: page `assembleReading`'s order, keeping VX-859's id-resume cursor.
2. **A small description gap (a nit).** `list_wings` names the tools that take its `wing_id` as "create_note, create_book, import_document, list_notes, move_note_to_wing and show_in_app" (TC:503–504); `create_gathering`, `copy_note_to_wing`, `replace_tag` and `move_book_to_wing` take one too (each says `list_wings` gives it). Incomplete, not false.

## Appendix — every capability declaration, by row

Each of the registry's 243 declarations (`Capability.swift`'s `CapabilityID`, every case declared once in `CR`) appears in exactly one row. `editRule`, `moveBookToWing`, `deleteBook` and `archiveBook` sit in their covered rows; their ruled targets (a gathering, the daily Journal, an owned book's second choice) are rows 39–43. Rows with no id here are undeclared doors, cited in their rows.

- row 1: `extract`
- row 2: `moveSelectionToTake`
- row 3: `divideWithCeremony`
- row 4: `mergeWithCeremony`
- row 6: `setBookExtent`
- row 7: `deleteScrap`, `archiveScrap`
- row 9: `archiveBlock`
- row 10: `pinNoteInBook`
- row 11: `moveTakeEarlier`, `moveTakeLater`
- row 12: `takeToBlockBelow`, `takesToBlocks`
- row 13: `renameLens`
- row 14: `callout`
- row 17: `putBackLineageBlock`, `bringBackLineageAsTake`
- row 18: `duplicateBook`
- row 19: `divergeForBook`
- row 20: `newShelf`, `renameShelf`, `setShelfGlyph`, `makeDefaultShelf`, `moveShelfToStart`, `moveShelfToEnd`, `deleteShelf`, `moveBookToShelf`, `sendBookToTop`, `sendBookToBottom`
- row 21: `renameWing`
- row 22: `setJournalTrait`, `setReadingHideOwned`
- row 24: `seatArrival`, `dismissArrival`, `addAllArrivals`, `dismissAllArrivals`, `addSelectedArrivals`, `dismissSelectedArrivals`
- row 25: `useAsDailyJournal`
- row 26: `bindIntoBook`
- row 27: `newWing`, `deleteWing`, `moveWingContents`
- row 28: `deleteCommentForever`, `deleteNow`, `emptyTrash`, `deleteEmptyBlocks`
- row 29: `structuralUndo`, `structuralRedo`
- row 31: `mcpApproveClient`, `mcpDenyClient`, `mcpChangeClientAccess`, `mcpRevokeClient`, `mcpRevokeGrant`, `mcpCopySetupCommand`, `mcpGrantAccess`, `mcpShareAnotherPlace`, `mcpAnswerAsk`, `mcpAllowHere`, `mcpShareHere`, `mcpShareNotes`, `mcpShareBook`, `mcpShareThisNote`, `mcpShowSharing`, `mcpChangeGrant`, `mcpOpenAsk`, `mcpSettings`, `mcpAllowRebind`, `mcpDeclineRebind`, `mcpTakeShowAsk`, `mcpDismissShowAsk`, `mcpOpenTrailPlace`, `mcpShowTrailDetails`, `mcpDismissTrailEntry`, `mcpClearTrail`, `mcpSetTrailDial`, `showLastAIChange`
- row 32: `exportLibrary`, `handOffLibrary`, `backUpNow`, `chooseBackupFolder`, `forgetBackupFolder`, `exportPlaintextLibrary`, `checkSearchIndex`, `rebuildSearchIndex`, `sendCrashReport`, `deleteCrashReport`, `lockLibraryNow`
- row 33: `restoreTutorial`, `restoreSampleLibrary`, `restorePrinceBook`, `restoreJekyllBook`, `restoreReadme`, `restoreClassicsGathering`, `takeTour`
- row 34: `toggleCanvasBank`, `returnCardToBank`
- row 35: `showTakes`, `closeAllTakes`, `pageFanBack`, `pageFanForward`, `diffAgainstChosen`, `showOriginBlock`, `showNoteTray`, `showBlockHistory`, `compareCommits`, `showBlockLineage`, `compareLineageWithNow`, `goToLineageWing`, `showNoteVersions`, `compareWithLatestVersion`, `previousBlock`, `nextBlock`, `blockComments`, `revertComment`, `findInPost`, `findNext`, `findPrevious`, `findAndReplace`, `useSelectionForFind`, `showSpellingPanel`, `checkSpelling`, `switchMode`, `openNote`, `navigateBack`, `navigateForward`, `closeNote`, `closeAllNotes`, `toggleSidebar`, `openBeside`, `closeSplit`, `openInNewWindow`, `openPeerPost`, `openBookAtNote`, `showBookPanel`, `openBookSettings`, `previousNoteInBook`, `nextNoteInBook`, `switchWing`, `goToWing`, `toggleSeams`, `helper`
- row 36: `markNotePrivate`, `markBookPrivate`
- row 37: `sealPost`, `sealBook`, `unsealBook`
- row 38: `ownBook`, `unownBook`
- row 42: `todaysEntry`
- row 44: `deleteTag`, `deleteUnusedTags`
- row 45: `tagBlock`
- row 46: `newTake`, `blankTake`, `blankTakeAsChosen`, `divergeHere`
- row 47: `mergeSelectedBlocks`, `deleteSelectedBlocks`, `splitEveryNewlineIntoBlocks`, `splitBlockAtNewlines`, `splitSelectedBlocksAtNewlines`, `makeBlock`, `deleteInEveryTake`, `replaceAllInEveryTake`
- row 48: `bringBackCommitAsTake`
- row 49: `shiftEntryDateEarlier`
- row 50: `copyIn`, `moveIn`
- row 51: `makeBookFromGathering`
- row 54: `quickNote`, `fileWithoutOpening`
- row 57: `newPost`, `newNoteInBook`, `newNoteInGathering`
- row 58: `importFiles`
- row 59: `findAnything`, `searchThisBook`, `copyAllTakes`, `exportCaretBlock`, `copyForAI`, `exportNote`
- row 60: `renameNote`
- row 61: `deleteNote`, `deleteSelectedNotes`
- row 62: `archiveNote`, `unarchiveNote`
- row 63: `duplicateNoteWithTags`, `duplicateNoteWithoutTags`
- row 64: `moveNoteToWing`, `copyNoteToWing`
- row 65: `moveBookToWing`
- row 66: `toggleStar`
- row 68: `saveNoteVersion`
- row 69: `tagNote`, `removeRuleTag`
- row 70: `commitTake`, `restoreCommit`, `renameCommit`
- row 71: `chooseTake`, `previousTake`, `nextTake`
- row 72: `archiveTake`, `unarchiveTake`, `lockTake`, `deleteTake`, `labelTake`
- row 73: `restoreTake`
- row 74: `divide`
- row 75: `merge`
- row 76: `addBlockAtEnd`, `insertBlockBelow`
- row 77: `deleteBlock`
- row 80: `addComment`, `saveComment`, `deleteComment`, `restoreComment`
- row 81: `formatBold`, `formatItalic`, `formatStrikethrough`, `formatCode`, `formatAddLink`, `formatHeading`, `formatBulletList`, `formatChecklist`, `formatIndent`, `formatOutdent`
- row 82: `saveChoicesAsLens`
- row 85: `renameBook`, `finishBook`, `reopenBook`, `archiveBook`, `unarchiveBook`, `deleteBook`
- row 86: `editRule`
- row 88: `manageBookNotes`, `removeFromBook`
- row 89: `fileNoteInChapter`, `moveNoteUpInBook`, `moveNoteDownInBook`, `moveChapterUpInBook`, `moveChapterDownInBook`
- row 90: `saveFilterAsGathering`
