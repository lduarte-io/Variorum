# The 2026-09-06 use-report round — 17o · 18c · 18d · 18e · 18f (EXECUTION PLAN, v2)

**STATUS: READY TO KICK OFF (v2, 2026-09-07 — solidified at her follow-up; v1 was the read-only draft
of the same night).** Runs NEXT, before 13u (her sequencing). **Run shape, her ruling:** a classic
`/architect-phase` — a **Fable orchestrator** that stays LEAN (briefs by pointer, repo-first records,
no hands-on verification of every batch), **Opus implementers** doing all the coding, **Fable cold
reviews** on the letters that touch the editor seam or a default's meaning, Opus reviews elsewhere.
**The paste-ready kickoff prompt is §6.** The mockups she asked for are
`notes/plans/use-report-2026-09-06-mockups/ceremony-and-note-box.html` (open it in a browser; four
figures: Divide choosing takes · Merge choosing takes · the sidebar's note box · This Note's Tray).

**Sources:** her report of 2026-09-06 and her follow-up of 2026-09-07 —
`notes/author-reports/2026-09-06-use-report.md`, both verbatim, with the image manifest (twelve files
in the untracked `notes/plans/use-report-2026-09-06-screens/author/`, three more pasted in chat and
described there). **Kickoff's first mechanical acts:** add the `.gitignore` line for the screens folder
(the per-round pattern, `.gitignore:13–28`); claim the letters — **17o** in
`notes/plans/phase-17-standing-fixes.md`'s allocation register (17l · 17m · 17n were claimed by pre-13x's
closeout on 2026-09-07 — v1 of this file said 17l; the letter moved, nothing else did), **18c · 18d · 18e · 18f** in the master
plan's Phase 18 row — each pointing HERE; set the master plan's running-order row; commit.

---

## 0. What this round is (one paragraph)

She spent an evening writing with takes and the app fought her three times in ten minutes: Return
stopped making blocks in the middle of a note (the chip said on; one block swallowed two paragraphs),
so she reached for divide; divide dragged every take onto both halves (the 13j default she ruled and
now reverses); and the ceremony she opened to keep the take on the first block could not park the
scissors at the end, arrived with the take unchecked, and looked "so ugly" that using it was work.
Around that core sit ~twenty smaller annoyances she listed as a punchlist, plus five design asks she
added the next night (the tray, the sidebar's note box, the ceremonies' names and presets, the bulk
"make every newline a block", the snippets editor). This round takes all of it, **grouped by kind and
by seam** into five letters run as one round: **18c** Return makes blocks (the typing model — her
biggest pain, first) · **18f** Divide choosing takes / Merge choosing takes (the ceremonies rebuilt to
the mockup) · **17o** the defects · **18d** the sidebar's note box, the tray, the outline's room · **18e**
markdown marks faded. Her line to keep in view: *"overall I have to emphasize that the app is looking
and feeling great after the various rounds of changes."*

## 1. Her rulings (2026-09-06 + 2026-09-07 — verbatim-faithful; SETTLED unless marked PROVISIONAL)

- **U-1 — NEWLINES MAKE BLOCKS, ANYWHERE IN WRITE.** *"newlines to make new blocks is NOT working
  properly at all"* … *"I was writing in Write, but in the middle of Write, so I had paragraphs above
  and below. I want it to work on newlines even when you're in the middle of write."* → Return makes a
  block wherever the caret is: at a block's end, a new block below; inside a block's text, a divide at
  the caret. Today's model only crystallizes at the note's END (§4.1). This is a typing-model change,
  built as **18c**.
- **U-2 — DIVIDE KEEPS THE TAKES ON THE TOP BLOCK.** *"I know I said that should be the default, but I
  honestly believe now that if you divide, the takes should automatically stay on the top block that
  you divided."* Supersedes the 13j J4 duplicate default on the Mac — and, her follow-up: **the phone
  flips too** (*"the phone divide should update to match this default divide behavior"*).
- **U-3 — THE CEREMONY OPENS WITH EVERY TAKE CHECKED AND THE ✂ AT THE END.** *"Takes should
  automatically be selected in the divide ceremony to come along with and should automatically have the
  scissors at the end."*
- **U-4 — THE NAMES.** *"'divide choosing takes' should replace 'divide ceremony', since it's clearer.
  same with merge - should be a button, not just a shortcut, and should say 'merge choosing takes'."*
- **U-5 — THREE PRESETS EASY, THE CUSTOM SELECTOR DELIBERATE.** *"the phone should offer three options
  (somehow, not sure how to not make it crowded): 1. all takes stay with the top block 2. all takes stay
  with the bottom block 3. all takes go on both. I think those options should feel easily available in
  the divide ceremony for ease and the custom selector should be something you really have to choose to
  do."* → The Mac's sheet gets the same first row (the mockup's figure A); the phone's face is its
  parity row.
- **U-6 — A "MAKE ALL NEWLINES BLOCKS" BUTTON.** *"that automatically just leaves any take at the top
  paragraph of its block (aka, if you had a multi paragraph block now the top paragraph is a block with
  all the takes)."* Her reason: fixing a note written with the chip off meant *"a lot of divides to run"*
  and, under the duplicate default, deleting an extra take between each.
- **U-7 — THE RING FOLLOWS THE PREFERENCE.** *"the take mode always shows a ring around what piece
  you're editing - it doesn't follow the preference on cursor being enough, wanting background wash, or
  ring."*
- **U-8 — THE TITLE LEADS.** *"it should be aligned to the left again so it starts where 'in no book' is,
  and it should be able to extend at least as far as the middle centered title can extend right now to
  support longer titles."* Supersedes Act 10 rows 4/19.
- **U-9 — THE TRAY: LEAVING vs ARCHIVED TOP-LEVEL, BLOCKS vs TAKES UNDER EACH.** *"you should be able to
  select if you want to see leaving, if you want to see blocks or takes under leaving, and separetly if
  you want to see archived (archived v. leaving should be top level, with block or takes as a filter
  under each one."* (Mockup figure D.)
- **U-10 — THE SIDEBAR'S NOTE BOX.** *"The block menu should move to being where the 'this note, write,
  lenses, compare, etc.' menu is, measured to take up the same amount of room, and should show 'no note
  selected' when you haven't clicked into anything or you've clicked out of something."* … *"I want the
  note box with the block menu and other information to be well designed and useful and it's more of a
  new area."* (Mockup figure C; the design §5.4.)
- **U-11 — MARKDOWN MARKS OUT OF SIGHT, FADE FIRST.** *"I want markdown items to disappear unless you're
  at the edge editing them or turn seeing them back on"* … *"I think fading them is a good start I
  suppose."* → FADE is the first form (18e); collapse is the recorded follow-on (§5.5 explains both).
- **U-12 — REMEMBERED NOTE LENGTHS.** *"I see no reason why we wouldn't add in remembering the length of
  notes so it can be perfect after the first time."*
- **U-13 — THE OUTLINE'S ROOM.** *"the chapters feel too tightly clustered and the panel with the chapter
  names should also be draggable to be a bit bigger"* · *"table of contents in read mode for a note is
  horizontally limited and not changable, should be adjustable."*
- **U-14 — THE RUN SHAPE.** *"I will be letting a Fable orchestrator run this and I want Opus to fix the
  defects and handle the coding"* · *"I want to use a classic /architect-phase style of running this, I
  don't want the orchestrator's context window to become bloated and I don't need the orchestrator to
  verify everything"* · on the snippets editor: *"only opus to fix this item."*
- **U-15 — THE PUNCHLIST** (rows 6–33 of the ledger, her words there) and the follow-up's small ones:
  the tag field collapses after use (*"if there's a tag already applied this new tag template shouldn't
  just sit here by default, it should collapse after you click out of it"*); the divider's white top
  (*"the line that separates the left pane from the main editor is white for just a tiny bit at the
  top"*); the header/highlight crowding (*"the highlight on the mode you're in and the words 'this note'
  or 'open' is very close to touching and the items in that pane should all be aligned"*); the snippets
  editor (*"it just opens a whole note with several different snippets but not even the snippet that i
  right clicked on"* … *"you can't tag snippets but there's a tag on there"*).

## 2. Where this sits — numbering, sequencing, the 13u fence

- **Five letters, why.** CLAUDE.md's rule splits fixes (17) from product (18) — her R-cor-13. The
  typing model (18c), the ceremonies (18f), the sidebar box + tray + room (18d) and the markdown setting
  (18e) change what the app IS; the rest are defects (17o). Letters are allocation order. **Running order:
  18c → 18f → 17o → 18d → 18e** — her two named pains first; 18e is the most separable (she may hold it).
- **Sizing (`notes/PhaseSizingGuidance.md`), stated:** 18c is one phase-sized unit (the typing model)
  plus a composition and a bulk op; 18f one (the sheet rebuilt) plus naming; 17o ~24 defect rows in
  four one-surface batches; 18d two phase-sized units under one theme (the box; the room + memory) plus
  the tray — AT the line; 18e one. One implementer session per batch; a session that finds a second unit
  hands off with a record.
- **Precedents:** the Act 10 correction round (her report answered row by row; one surface per session)
  and the 13j fanned-defaults batch (a default changed by COMPOSING an existing op — 18c repeats it).
- **THE 13u FENCE — what this round deliberately does NOT take** (read the master plan's `### 13u`
  section and `notes/plans/phase-13u-feel-and-polish.md`'s fold + addenda before touching the seam):
  - **Cross-block delete (image 8)** — 13u1 item 5, ruled and fenced; she said so herself. Nothing here
    touches `CrossBlockEditPlanner`, the refusal grammar, or the fanned matrix.
  - **The O(N²) family, the churn pair, the arm-then-hand-off residual** — 13u1's. 18c's Return road is
    an INTERCEPT at the key (like ⇧⏎'s), deliberately NOT a rewrite of `BlockRangeIndex`'s tiling (§5.1
    says why); if a session finds it must change the index's regions, it stops and records.
  - **Pane stability (13u2 item 1)** — the general trace stays 13u2's; two named members are built here
    (rows 16 · 25).
  - **The title cut-off (13u2 item 13 + row 93)** — row 11's fix very likely satisfies it; the 13u2 kickoff
    decides; this round records what it changed.
  - **P39b** (`WriteTakesPanel` constructing `TakesViewModel`) — 13u2's; 18d's composition adds no sibling
    violation (§5.4 says how).

## 3. THE LEDGER — her items, every one a row

Status vocabulary: OPEN · TRACED · FIXED(pin) · RECORDED · DEFERRED(owner) · HERS. "Traced" means traced
by READING, unproven — the pin is the first act of every fix. Rows quote her short; the report has them
whole. Image numbers are the report's manifest.

| # | Her words (short) | Surface | Traced mechanism / architect's read (file:line) | Letter · batch | Status |
|---|---|---|---|---|---|
| 1 | "newlines to make new blocks is NOT working… I was writing in Write, but in the middle of Write" (image 4: block 3/3, 472w, two paragraphs, chip ON) | Write's Return | Type-time crystallization exists ONLY at the note's end (the open tail); Return inside or at the end of any other block is I4 content by design (`BlockRangeIndex.verdict`, `:144–152`; `SegmentationRules.crystallizedBoundary`). At the LAST block the exact-end gesture is defeated by an empty open tail / a trailing content newline (§4.1) — the same picture. Her ruling U-1 makes Return structural everywhere | 18c · 2 | HERS (ruled) |
| 2 | "if you divide, the takes should automatically stay on the top block" | Fanned divide default | 13j J4's `divideDuplicating` (`FannedDefaults.swift:9–15`; `EditorSurfaceController.swift:487`; `TakesStructureController.swift:437`; the phone's door). U-2: KEEP-ON-TOP, composed from `Operations.divideW` with every other take parked at its end — §5.1 | 18c · 1 | HERS (ruled) |
| 3 | "the scissors couldn't be placed at the end of the block" | Ceremony placement | The end IS legal by design (`DivideWCeremony.legalCutPositions`, `:231–234`; `WTake.parkedAtEnd`, `:165`; `flowItems` ends with `.slot(end)`) — three downstream candidates, §4.4 | 18f · 1 | TRACED |
| 4 | "Takes should automatically be selected… and should automatically have the scissors at the end" | Ceremony defaults | `DivideWCeremony.State` seeds only the seed take marked (`:207`), others unmarked with a propagated cut. U-3 | 18f · 1 | HERS (ruled) |
| 5 | "so ugly with the spacing between the words, the way that you have to scroll to get the different takes, just overall" (image 5) | Ceremony face | The token flow's FIXED 9-pt slot between every word (`CutFlowGeometry.slotWidth`, `:44`); a 240–420-pt scrolling stack (`DivideWSheet.swift:90–98`); system fonts, stacked explainers. Rebuilt to mockup figure A — §5.2 | 18f · 2 | HERS (mockup) |
| 6 | "the take mode always shows a ring… it doesn't follow the preference" | Every pane host | `PaneSurface.swift:705–711` strokes `tokens.ring` whenever `isLive`, reading no setting; Write honors `EditingIndicatorStyle` (`BlockDecor.swift:507–531`; `Enums.swift:86`) | 17o · c | TRACED |
| 7 | "switching from takes to write doesn't leave you where your cursor was" | Takes → Write | `FocusedBlock` has no caret offset (`BlockHistoryPane.swift:131–135`); `CurrentBlockMemory` persists "block\|variant" (`:44`); Write lands at the block START (`EditorViewModel.bareArrivalLanding`, `:1729–1734`) | 17o · b | TRACED |
| 8 | "open takes mode in write from the takes menu is also not automatically navigating you to where the take is" | Fan panel → Takes | `WriteTakesPanel.swift:68–76` posts `.bloom` + switches; `TakesChoreographer.consumeLandings` (`:159–176`) blooms + focuses but the article never SCROLLS (no scroll-to in the single column; only the fan strips page, `TakesBoardView.swift:1001/:1055`) | 17o · b | TRACED |
| 9 | "the hitbox for adjusting the size of the left bar… too small… sometimes the I looking pointer" | `ShellSplit` divider | A 1-pt line with a 9-pt grip as an OVERLAY (`ShellSplit.swift:97–110`); the detail is the next HStack sibling above the grip's right half, so hover/drag reach ~half of it and the editor's I-beam wins | 17o · d | TRACED |
| 10 | (image 1) "Fill code … From Messages" appears when the title is clicked | Masthead title | The field's PROMPT is the note's date — all digits (`PostDetailView.swift:588`); hypothesis: AppKit's one-time-code AutoFill heuristic reads a digit prompt as a code field. Lookup + fix §5.3 (d) | 17o · d | OPEN (hypothesis) |
| 11 | punchlist 1: title left-aligned from "in no book", at least as long as today's centered measure | Masthead title | Act 10 rows 4/19 (`PostDetailView.swift:592–594, 625`). U-8 | 17o · d | HERS (ruled) |
| 12 | punchlist 2: "When you click on the title the placeholder text shifts upwards" | Masthead title | Two faces (`Text` `:601`, `TextField(prompt)` `:588`) share a measure, not a height/baseline | 17o · d | TRACED |
| 13 | punchlist 3 + follow-up: "'This note' is misaligned from write, takes…; Open… from the tabs"; "the highlight… is very close to touching… the items in that pane should all be aligned" | Sidebar headers | `header()` pads `groupPadding + rowPadding` = 20 (`SidebarView.swift:298–303`) and sits INSIDE `railGroup`/`openGroup`, which already pad `groupPadding` (`:483`, `:544`) → the header lands 12 pt inboard of the row text (`rowChrome`'s inset is `rowPadding`, `:330–342`). The header's `.frame(height: 22, alignment: .bottomLeading)` leaves no air above the first row's wash | 17o · d | TRACED |
| 14 | punchlist 11: "the chosen green line doesn't go all the way down" (image 6) | Takes stack | `TakeCardFrame` draws the 3-pt bar as an HStack SIBLING of the pane (`TakesBoardView.swift:1360–1378`); the pane's height publishes asynchronously, so the bar can size against a stale height. Fix: an `.overlay(alignment: .leading)` of the card | 17o · c | TRACED |
| 15 | punchlist 10: "you should be able to make a first block there" (image 3) | Takes/Lenses empty state | "＋ new block" exists (`TakesBoardView.swift:535` → `addBlockAtEnd` → `TakesStructureController.swift:74`) but is gated `!slots.isEmpty` (`:530`); Lenses mirrors (`LensesBoardView.swift:469`) | 17o · c | TRACED |
| 16 | punchlist 13: "delete a lot of text from a take… empty gap… until you switch modes" | Take pane height | `PaneSurface` re-converges only on an occasion (`reconvergeIfDiverged`, `:1146–1156`; the coalesced sink `:1031–1047`); after a large deletion TK2's estimate may lag the measure (TEXTKIT2 §2) and nothing re-measures until remount. A 13u2 item-1 member, built here | 17o · c | TRACED |
| 17 | punchlist 12: "you can't mark two posts as versions if one has no blocks yet" (image 2) | Compare | `markPostsAsVersions` anchors on each post's FIRST block (`Operations+Versions.swift:100–125`; KnownIssues row 31) → `postHasNoBlocks`; Compare dumps the RAW error (`VersionActs.swift:96` words the restore road only) | 17o · d | TRACED (shape PROVISIONAL) |
| 18 | punchlist 14: "renaming a note won't rename it on the sidebar until you click on something else" (image 9) | Open strip | `WorkspaceModel.resolveTitles` is a ONE-SHOT read re-run only when `titleSubjectsKey` changes (`SidebarView.swift:259–260`; `WorkspaceModel.swift:382–446`) | 17o · d | TRACED |
| 19 | punchlist 15: "changing date… doesn't change its auto display name" (image 11) | Masthead title | `PostTitleLabel.refresh()` is a one-shot `.task(id: postID)` (`PostDetailView.swift:646–657`); `updateEntryDate` never re-runs it (`Queries.noteDisplayTitle`, `TakesQueries.swift:195`). Same class as 18 — one fix (§4.3) | 17o · d | TRACED |
| 20 | punchlist 8: "Opening in write from blocks puts your cursor in the right place but doesn't move you there" | Blocks → Write | `BlocksWorkbenchView.swift:877` (`onJump`) → a `WriteIntent`; `applyWriteIntent` (`:1743+`) sets the selection and (verify) does not scroll; the arrival road (`:1702–1707`) uses `scrollRangeToVisible`, which lands short on TK2 before layout — `JumpPrimitive.jump` (`JumpPrimitive.swift:102`) is the exact road | 17o · b | TRACED |
| 21 | punchlist 5: "the number of notes per chapter should be better aligned with the ... menu" (image 7) | Book Index column | The count is a trailing `Text` (`BookIndexView.swift:352–354`); the note row's `Menu("⋯")` (`:521–525`) carries a disclosure chevron, so ⋯ sits inboard of the count | 17o · d | TRACED |
| 22 | punchlist 4: the outline's spacing; the chapter panel draggable | Book navigator | `BookView.navigator` rows in `VStack(spacing: 2)` (`:368–373`); fixed `.frame(width: 190)` (`:645`). U-13 | 18d · 3 | HERS (ruled) |
| 23 | punchlist 6: the block menu into a sidebar box, the rail's height, "no note selected" (image 10) | Book editing modes + sidebar | The bar rides a 190-pt right gutter in Outline (`EditorView.swift:113–125`; `BookView.swift:1597–1615`) and floats at the right in the paged Book mode; the sidebar shows no rail for a book (`SidebarView.railGroup`, `:453`). U-10; design §5.4; mockup figure C | 18d · 1 | HERS (ruled) |
| 24 | punchlist 7: a setting to hide markdown marks unless editing them | Live editor (shared brain) | `MarkdownFaceCore` colors markers `palette.marker` on the storage (`:183–194`); the read tiers already hide them (`FlowParagraph.swift:86`). U-11: fade first — §5.5 | 18e | HERS (ruled) |
| 25 | punchlist 9: remember note lengths | Book Outline surfaces | `BookViewModel.rememberedSurfaceSizes` session-only (`:389–395`); `SurfaceSizeMemory` likewise (`StableSurface.swift:25–32`). U-12 | 18d · 4 | HERS (ruled) |
| 26 | punchlist 16: the Read contents column adjustable (image 12) | Note Read | `ReadModeView.swift:140` `.frame(width: NoteIndexColumn.width)` = 340 fixed (`NoteIndexColumn.swift:38`); `SideColumn` exists for TRAILING panels only. U-13 | 18d · 3 | HERS (ruled) |
| 27 | (from 17) Compare speaks a raw `OperationError` | Compare | see 17 | 17o · d | TRACED |
| 28 | (from 1) the bar reads "block 3/3" while the page looks like the end of the note | Write's bottom bar | A face consequence of the tail model; 18c's model makes the bar honest by construction (a new block is a real block) | 18c · 2 | RECORDED |
| 29 | "selecting a sentence and trying to delete it and it rejecting due to blocks" (image 8) | Cross-block delete | 13u1 item 5 — fenced | — | DEFERRED (13u1) |
| 30 | (from 23) the paged Book mode's floating card | Book paged mode | the same re-home | 18d · 1 | HERS (ruled) |
| 31 | (architect's rider) the Write bar's "Takes" opens the fan PANEL (`openCaretFan`, `EditorViewModel.swift:2374–2388`), whose card is a pane that never crystallizes | Fan panel | ANSWERED by her: she was on the page, not in the card. Row retired | — | RECORDED |
| 32 | (rider on 16) the general pane-stability trace | panes | 13u2 item 1 — fenced | — | DEFERRED (13u2) |
| 33 | (from 26) the leading-edge draggable seam is needed twice (22 · 26) | `Core/Views` | build the LEADING variant of `SideColumn` once; both consume it | 18d · 3 | OPEN |
| 34 | follow-up: the tray reorganized (image 14) | This Note's Tray | `TrayPanel.swift` (1,110 lines): two fixed sections — "Leaving — on the 30-day clock" (blocks, then a "▸ N deleted takes" fold, then originals riding a family's countdown) and "Archived — kept, no clock" (`RecoveryCopy.tray*` strings; sections at `:117–119`, the fold `:256–264`). U-9; mockup figure D | 18d · 2 | HERS (ruled) |
| 35 | follow-up: "divide choosing takes" replaces "divide ceremony"; "merge choosing takes" a BUTTON | Names + doors | Verbs at `CapabilityRegistry.swift:186` ("Divide with Ceremony…") and `:214` ("Merge with Ceremony…"); sheet titles `DivideWSheet.swift:66` ("Divide into takes"), `MergeCeremonySheet.swift:48` ("Merge blocks — pair their takes"); the merge ceremony has NO menu button today — ⌥⌘⇧M only (the block ▾ menu at `CommitBar.swift:492–507` lists Divide/Extract/Make Block/Merge/New block below/Delete). Tutorial + helper strings (`TutorialSeeder.swift:688`, `HelperView.swift:300`) | 18f · 1 | HERS (ruled) |
| 36 | follow-up: the three presets easy, custom deliberate; the phone offers the three | Both ceremonies | Mockup figures A/B; the phone's face is a parity row (§5.2) | 18f · 2 (+ mobile row) | HERS (ruled) |
| 37 | follow-up: "make all newlines blocks" (takes stay with the top paragraph) | Note ▾ / block ▾ menus | No such op exists; composable from `divide` (single-take, in place) and the keep-on-top `divideW` composition inside one `withCompound` (`UndoStack.swift:190`) — §5.1 (3) | 18c · 3 | HERS (ruled) |
| 38 | follow-up: the snippets editor opens "a whole note… but not even the snippet that i right clicked on" (image 15's context) | Snippets area | `BlocksAreaView.swift:508–510`: the card's "Open in the Snippets editor" calls `openPool(area.activePool.id)` — the ACTIVE group's pool (the default "Snippets" when browsing all groups), NOT `item.poolID` (her snippet lives in the tutorial's "tutorial scraps" pool, `TutorialSeeder.swift:41`) — and lands on no block (`RootView.swift:671` → `openHere(.pool(id))`). The header's "open as editor" (`:223`) is the same call, correctly scoped to the active group | 17o · e | TRACED (**Opus only**, her word) |
| 39 | follow-up: "you can't tag snippets but there's a tag on there" | Snippets area | Block tags ARE the model's (`block_tag`; "block-level tags primarily serve the pool"); the card menu has "Tags…" (`SnippetsCopy.tagsRow`, `BlocksAreaView.swift:511–513` → `BlockTagAssignmentSheet`, `BlockTagViews.swift:68`) — so a door exists; the tag she saw was the tutorial's seeded one. Trace where she looked for the door (the pool EDITOR's masthead has no `#`?) and make the door findable where the tag shows | 17o · e | TRACED (Opus only) |
| 40 | follow-up: the tag field should collapse after clicking out; the `#` reopens it (image 15) | Masthead `#` door | `MastheadTagCluster.swift` — the inline field (`:222`) stays open while `fieldOpen`; trace what flips it closed (submit? focus loss?) — her rule: focus loss with a tag already applied collapses it | 17o · d | TRACED |
| 41 | follow-up: the sidebar/editor divider is white for a bit at the top (image 16) | `ShellSplit` divider | The divider `Rectangle` spans the HStack; the window's toolbar band above the detail (`VariorumApp.swift:255–286`, `.unifiedCompact`; `RootView.swift:174–201`) is where the short white segment sits — the sidebar column's top row starts under the band while the line does not; trace which view paints white there | 17o · d | TRACED |

## 4. The traces (the architect's read — by reading, never by running; the pin decides)

### 4.1 Row 1 — why Return stopped making blocks, and why the fix is a model change

**The designed gesture.** Type-time crystallization only ever plans over the OPEN TAIL — text after the
LAST block (`CrystallizationPlanner.swift`; `SegmentationRules.crystallizedBoundary`). The tail opens by
one gesture: a single newline typed at the exact UTF-16 document end while no tail exists
(`BlockRangeIndex.verdict` → `.openTail`, `BlockRangeIndex.swift:144–152`; the ratified Phase 7 gesture,
re-pinned at 13d A15, `ReturnKeyTraceTests` (b)). **Every other newline — including Return at the end of
block 2 of 3, or inside any block — is I4 content of the block it lands in.** So in the middle of a note
the chip's promise ("each finished paragraph becomes its own block as you type past it") was never true:
the machinery has no position but the end. That is her scenario exactly (*"paragraphs above and
below"*), and it is not a bug in the tail road — it is the tail road's scope.

**At the very end, a second trap (kept for the record; moot once 18c lands, the fallback fix if 18c is
ever deferred):** an EMPTY open tail lingers after one Return and a pause (the idle mint plans nothing
over ""; nothing closes an empty tail but deleting its separator, `:154–158`), or the last block ends with
a content newline (the k−1 rule, `attachLeadingTailRunIfNeeded`, `EditorViewModel.swift:1306–1338`). Either
way the last visible line is blank, a click at the end of the text lands the caret BEFORE that last
character, and Return there is content — image 4's "several new lines". The narrow fix (F1): recognize
the EFFECTIVE end (`lastEnd` with an empty tail open → move the caret into the tail, no bytes change; inside
a trailing newline run → the run's last newline becomes the separator, bytes unchanged). Pins for it are
written in v1's record (this file's git history, `a45ee0cc`).

**The model change (U-1), in one sentence:** with the chip ON, **Return makes a block wherever the caret
is** — at a block's end, a new block below (the shipped New Block Below, ⌘⇧⏎, `insertBlockBelowCaret`,
`EditorSurfaceController.swift:667–683`, on the plain key); inside a block's text, a divide at the caret
(the shipped `divideAtCursor`; single-take in place, fanned → the keep-on-top default); Shift-Return stays
the content newline (13d A15, `SoftNewlineTests`); with the chip OFF (`one_block`) Return stays content.
Built as an INTERCEPT at the key in `EditorTextView` (the `isSoftNewlineKey` precedent: decide before the
gate, route to the structural door or fall through), so `BlockRangeIndex`'s tiling is untouched — the 13u1
fence holds. Consequences and options are §5.1.

### 4.2 Rows 7 · 8 · 20 — the landing family (one memory, three doors, no offset, no scroll)

`CommandRouter.focusedBlock` is the ONE current block across modes (Act 10 batch C, row 39); its memory
is `CurrentBlockMemory` (`"blockID|variantID"`, `:44`). Three roads read it and each stops one step short:
Takes → Write lands at the block's START (`bareArrivalLanding`, `EditorViewModel.swift:1729–1734`) because
the fact has no caret offset; Blocks → Write (`applyWriteIntent`, `:1743+`) computes the offset, sets the
selection and (verify) does not scroll — and the arrival road's `scrollRangeToVisible` (`:1705`) lands short
on TK2 before layout (TEXTKIT2 §2; `JumpPrimitive.jump(toOffset:textView:scrollView:)`,
`JumpPrimitive.swift:94–140`, is the Phase 6 hybrid jump built for exactly this); the fan panel → Takes
landing blooms and focuses (`TakesChoreographer.swift:159–176`) and the article column has no scroll-to at
all. **One fix:** `FocusedBlock` gains `utf16Offset: Int?` (reported by Write's caret context,
`EditorViewModel.swift:2544`, and by the live pane's selection, `TakesViewModel.swift:521`; persisted as a
third field — old memories read as nil → the block start); every landing consumes it: Write lands at
`range.location + min(offset, length)` and reveals through `JumpPrimitive` (with the arrival's next-turn
retry); the board's article gains a `ScrollViewReader`/`scrollPosition(id:)` over its slots and scrolls
the landed slot to the top band once per landing (the typewriter room already exists, `:582`).
`LandingTarget.utf16Offset` is the same idea one door over — reuse the name.

### 4.3 Rows 18 · 19 — chrome titles are one-shot reads

`PostTitleLabel` reads once per note (`.task(id: postID)`, `PostDetailView.swift:646–657`);
`WorkspaceModel.resolveTitles` once per change of the SUBJECT SET (`titleSubjectsKey`,
`WorkspaceModel.swift:382`; the trigger `SidebarView.swift:259`). Neither watches the rows, so a rename or a
date change shows only where the write happened. **One fix:** a bounded `ValueObservation` over the
`container` rows in question (title · entry_date · created_at — `DisplayTitle.note`'s three inputs): the
open set for the strip, the one note for the masthead — a sync pull's rename lands too. Cost ∝ open notes.

### 4.4 Row 3 — the scissors and the end slot

By design the end is placeable (`legalCutPositions` = `BoundarySnapping.boundaries(.word)` "ends
included", `DivideWCeremony.swift:226–234`; `flowItems` ends `.slot(end)`; `wordStep(forward:)` stays at
`boundaries.last`). Pin, in order: (i) `legalCutPositions(of: "Alpha beta.")` contains 11; (ii)
`CutFlowGeometry.make` lays the end slot INSIDE `geometry.size` — `size.width = min(widest, width)`
(`CutFlowGeometry.swift:105`) can clip a slot when the LAST line is the widest, and the flow is framed to
`geometry.size` (`DivideWSheet.swift:329`); her screenshot shows the ✂ one slot short — (ii)'s picture;
(iii) `nearestSlot(to:)` resolves a point right of the last token to the end. If all pass, the fault is
`WCutFlow`'s gesture wiring (`:347–356`). 18f's rebuilt face lands the ✂ by character hit-testing, but the
pure brains keep their pins.

### 4.5 Row 38 — the snippets editor opens the wrong pool

`BlocksAreaView.cardMenu` (`:508–510`): `Button(SnippetsCopy.openRow) { if let pool = area.activePool {
openPool(pool.id) } }` — the ACTIVE group, not the card's `item.poolID`; and `openHere(.pool(id))`
(`RootView.swift:671`) lands nowhere in particular. Browsing "all groups", the active pool is the default
"Snippets" pool; her snippet lives in the tutorial's own pool ("tutorial scraps", `TutorialSeeder.swift:41`).
**Fix:** `openPool(item.poolID)` + a landing on `item.block.blockID` (a `WriteIntent`/`LandingTarget`
into the pool editor — the Blocks → Write road, which row 20 fixes to scroll). The header's "open as
editor" keeps the active group. Pin: opening from a card in group B while group A is active opens B with
the caret in the clicked block.

## 5. The five letters

### 5.1 — 18c · Return makes blocks (the typing model; U-1 · U-2 · U-6)

**Goal.** With the chip on, every Return makes a block, wherever the caret is; the fanned-divide default
keeps the takes on top on both platforms; a note written with the chip off is repaired by one command.

**Batch 1 — the keep-on-top composition (zero core change) + the phone's flip.**
- `KeepOnTopDivide.compose(displayedID:cut:fan:) -> [String: Int]?` in `App/Variorum/Shared/` beside
  `CarryAllMerge` (`FannedDefaults.swift:38` — the pattern): the displayed take's cut = the gesture's
  snapped position (`BoundarySnapping`, S4-22 unchanged); **every other live ACTIVE take's cut = its
  text's UTF-16 length — parked at the END**, which by S4-22 ruling 2 rides that take whole into the FIRST
  block. Handed to `Operations.divideW(blockID, cuts:)` (`Operations+Structural.swift:320`). Result: B's fan
  = the displayed take's first half (chosen — the per-side rendered rule, `:~403`) + every other take
  whole; C's fan = the displayed take's second half (chosen); A released to lineage preserved whole
  (reversible, ⌥⌘Z). **Edges the composition speaks:** an EMPTY other take cannot park (`legalCutPositions`
  = []; `divideW` refuses `invalidCut`) → left unmarked, it stays on A in lineage, counted in the receipt;
  the displayed take's cut at its own start/end refuses as today; the F-3 guard → `takesChangedDivide`. A
  sibling `compose(keepBelow:)` (every other take parked at its START — U-5's second preset) lands with
  it; the third preset IS `divideDuplicating`.
- The Mac's fanned-divide sites (`EditorSurfaceController.swift:419–500`, `TakesStructureController.swift:437`)
  call the composition instead of `divideDuplicating`; the receipt (`FannedDefaultsCopy.divided`, the J8
  copy-truth pin): *"Block divided — the take you were in split across both blocks; N other takes stayed
  on the first. ⌥⌘Z undoes."*
- **The phone flips in the same batch (U-2, her follow-up):** `MobileEditorViewModel`'s fanned-divide door
  (the parity-chain Stage A site; `grep -n divideDuplicating App/Variorum/VariorumMobile`) calls the shared
  composition; its pin and the iOS suite green. The phone's three-preset FACE is 18f's parity row.
- **Canon delta drafted for the closeout:** AppSpec §9's `divideDuplicating` paragraph gains the 2026-09-06
  supersession — the default on BOTH platforms is keep-on-top; `divideDuplicating` stays in core as the
  "copy takes to both" preset; `FannedDefaults.swift`'s header updated. Pins: the composition's matrix
  (2/3/5 takes, an empty other take, a locked other take); instant default == ceremony-unchanged on a
  three-take block (18f's pin, shared).

**Batch 2 — Return makes a block, anywhere (the intercept).**
- **The rule (chip ON — `header.effectiveSegmentation != .oneBlock`):** Return with the caret **at the END
  of a block's text** (trailing whitespace ignored; any block, last included) → `insertBlockBelowCaret`'s
  shape (an empty block after it, the caret in it — the shipped ⌘⇧⏎ road, `EditorSurfaceController.swift:667–683`,
  through `runStructural`: one flight, flush first, store-led rewrite, caret by identity). Return **INSIDE
  a block's text** → `divideAtCursor` at the caret through the one snapping rule (single-take: in place, A
  keeps identity; fanned: the keep-on-top composition; the caret lands at the START of the second block —
  "the paragraph I just started"). Return **at the START of a block** (before any text) → an empty block
  ABOVE it, caret staying in the text block (the everyday "push this paragraph down") — or refuse; the
  implementer picks the first unless the seam argues. Return **in an EMPTY block** → nothing happens (never
  a second empty block; recorded, not spoken). Return **inside an open tail** (a tail exists only after a
  paste/drop now) → the tail's own road, unchanged. **⇧⏎ → content, always** (A15). **Chip OFF → content**
  (today). A sealed note → the structural door's own refusal, spoken.
- **Where:** an intercept in `EditorTextView` on the Return key BEFORE `insertNewline:` reaches the gate
  (the `isSoftNewlineKey` precedent — `EditorTextView.swift`, the soft-newline flag), deciding from the
  caret's block and offset (`model.caretBlockID` / the index's entry range) and dispatching to the
  structural doors; `BlockRangeIndex.verdict`'s `.openTail` arm stays for pasted tails and is otherwise
  unreachable from typing. **Do not rewrite the index's regions** (the 13u1 fence). The MarkdownActs Return
  intercept (`.continueList`, `MarkdownActs.swift:388` — list continuation) runs FIRST and keeps its
  behavior: inside a list, Return continues the list; a second Return on an empty item ends the list AND
  makes the block (the two intercepts compose in that order; pin it).
- **The empty-block question (PROVISIONAL → QUESTIONS for her ratify list):** a Return she then abandons
  leaves an empty block. **(ii, recommended first build)** it stays — an empty paragraph, as in every
  editor; seam-backspace removes it (the A7 carve, `deleteBlock(requiring: .emptyWithNothingUnshown)`);
  Blocks/Index show it as "(empty block)". **(i, follow-on if empties annoy her)** an empty block minted by
  Return that loses the caret with no text, no take, no comment is removed quietly through the SAME
  precondition — a tombstone (30-day, tray-visible) by the 13j doctrine; a purge would need her ruling.
  Never (iii) a positional open gap in the index — that is seam surgery, 13u1's.
- **The k−1 spacing rule (QUESTIONS #12, 2026-07-12) narrows by consequence:** typed newline runs no
  longer reach the tail, so "typed blank lines persist as content" now holds only for ⇧⏎ inside a block;
  pasted runs keep the rule unchanged. Recorded as a supersession for her ratification, never silently.
- **Pins that must go RED on old and green after** (`ReturnKeyTraceTests`' real-key harness): (1) seed
  `["alpha","beta","gamma"]`, caret at the end of "beta", ⏎, type "new" → `["alpha","beta","new","gamma"]`
  (the middle case — her scenario); (2) caret inside "beta" after "be", ⏎ → `["alpha","be","ta","gamma"]`
  with the caret at "ta"'s start; (3) a fanned middle block, ⏎ inside its displayed take → keep-on-top
  (B carries the others whole); (4) ⏎ at the end of the LAST block → a new block, no open tail
  (`!hasOpenTail`); (5) ⏎ in an empty block → no change; (6) ⇧⏎ mid-block → content (A15's pin stays
  green); (7) `one_block` → content; (8) a list item's ⏎ → continues the list; (9) her S1 scenario (⏎,
  pause 2 s, click at the end of the last line, ⏎, type) → a new block every time. **Pins that the ruling
  RETIRES, named and cited, never silently:** `ReturnKeyTraceTests` (b) "⏎ opens the tail at the document
  end" and B2's tail-from-typing setup (rebuilt over a pasted tail); any `EditorSessionTests` /
  `CrystallizationTests` case whose premise is a TYPED tail (the planner's pure tests over bulk/idle stay).
  The implementer lists every retired pin in the batch record with the ruling beside it.
- **Evidence:** her scenario walked on the dev store by the implementer (write, ⏎ in the middle, type;
  ⏎ at the end; ⇧⏎; a list), captured to `…-screens/18c-2/`; the bar reading "block k/N" honestly (row 28).
- **Review: Fable** (the editor seam). **Implementer: Opus**, per her cast — the brief RESTATES the seam
  rules (the identity oracle runs per keystroke in DEBUG and kills the process on identity corruption; the
  macOS-26 widening rule for any attribute stamp; `runStructural` is the ONE structural door; the
  intercept never touches `BlockRangeIndex`).

**Batch 3 — "Make every newline a block" (U-6).**
- **Core op `splitBlockAtNewlines(blockID)`** in `Operations+Structural.swift`, ONE transaction per block
  (atomic; a pin per shape): find the break points in the block's DISPLAYED take (the chosen; `Queries`
  gives it); **breaks = newline runs**, with ONE exception — a run of exactly one newline between two
  LIST-LEAD lines (`MarkdownSyntax.isListLead`) is not a break, so lists stay whole (PROVISIONAL; her
  ratify list); each piece edge-trimmed by `SegmentationRules.trimmedPiece` (the K8 law: a list lead keeps
  its indent). **Single-take block:** successive in-place `divide`s at each break (A keeps identity as the
  first paragraph). **Fanned block:** the first break is a keep-on-top `divideW` (the displayed take cut
  there, every other take parked at the end) → B = paragraph 1 + every other take whole (*"the top
  paragraph is a block with all the takes"* — her words exactly), C = the rest as one take; then C splits in
  place at the remaining breaks. Blank lines vanish into separators (they were content; the separator
  renders the paragraph break). A block with no break is a no-op (no touch, no churn). Sealed → refuses.
  Registers ONE structural undo entry per block with the exact-row redo (the 13c rule: `register(redo:)`
  is required, never defaulted).
- **Doors:** the note ▾ menu — **"Make every newline a block"** (all blocks, one `withCompound` — one ⌥⌘Z,
  `UndoStack.swift:190`); the block ▾ menu — **"Split this block at its newlines"**; the Blocks workbench's
  bulk bar gets the same verb for a selection (the 13e multi-select). Receipt: *"12 blocks from 3 — every
  take stayed with its top paragraph. ⌥⌘Z undoes."* (counts from the op's own result — the 13e rule).
- **Pins:** the break rule (runs; the list exception; trailing/leading whitespace); single-take 3-paragraph
  → 3 blocks in order, A's identity kept; fanned (3 takes, 3 paragraphs) → B holds [p1, t2, t3] with p1
  chosen, then p2, p3 single; the compound's one undo restores every row; sealed refuses; sync: ordinary
  ops (no `Sync/` change).
- **Review: Fable** (core structural op). Implementer Opus.

### 5.2 — 18f · Divide choosing takes · Merge choosing takes (U-3 · U-4 · U-5; mockup figures A/B)

**Her verdict on today's sheet, verbatim:** *"so ugly with the spacing between the words, the way that
you have to scroll to get the different takes, just overall"* … *"I want there to be a pretty good plan for
how it can look better because I was just displeased with it."* The mockup IS the plan for how it looks;
this section is what it does.

**Batch 1 — the mechanics: names, doors, defaults, presets, the end slot.**
- **Names (U-4):** the verbs become **"Divide choosing takes…"** (`CapabilityRegistry.swift:186`) and
  **"Merge choosing takes…"** (`:214`); the sheet titles follow (`DivideWSheet.swift:66`,
  `MergeCeremonySheet.swift:48`); the tutorial lesson and the helper (`TutorialSeeder.swift:688`,
  `HelperView.swift:300`) and `FannedDefaultsCopy`'s sentences re-word; the word "ceremony" leaves every
  UI string (the code's type names may keep it). The field guide's changed lesson is her one restore act
  at the end (the standing handoff item).
- **Doors:** "Merge choosing takes…" becomes a BUTTON beside Merge — the block ▾ menu (`CommitBar.swift:492–507`),
  the Takes board's ⌘-click selection bar, the Blocks workbench's bulk bar; ⌥⌘⇧M stays. The same for
  "Divide choosing takes…" beside Divide.
- **The arrangement row (U-5) — the sheet's FIRST control, four options in this order:** **Keep takes on
  the top block** (selected on open — the default the instant divide uses) · **Keep takes on the bottom
  block** · **Copy takes to both** · **Choose per take…**. Choosing a preset places every ✂ (top: seed at
  the gesture, others at the END; bottom: others at the START; both: the duplicate shape — the sheet
  confirms through `divideDuplicating`, not `divideW`); the one sentence under the row says what will
  happen in counts (*"The take you were in splits at the ✂. 2 other takes stay whole on the top block; the
  bottom block starts with one take."*). **Confirming the sheet unchanged reproduces the instant default
  byte-for-byte** (pin). "Choose per take…" reveals the checklist — every take CHECKED, non-seed ✂ at the
  end (U-3) — with today's whole vocabulary (parking at both ends, ⇥ between takes, ←/→ and ⌥←/→,
  the confirm blocker) on the new surface; `CutPropagation`'s proposal survives as the ⌥←/→ strong step,
  never the default position. `DivideWCeremony.State` (`:177–215`) gains the preset + seeds all marked.
- **The merge sheet's row:** **Bring every take** (selected — the carry-all default) · **Only the two
  shown** (plain pair; the others stay in lineage) · **Pair by hand…** (the shipped S4-23 pairing UI).
- **The end slot (row 3):** §4.4's pins in order; fix the link that reds.
- **The phone's parity row (write it into `notes/MobileSoul.md` at the close):** the phone's fanned divide
  offers the three presets as a bottom sheet of three plain rows in the same words, with "Choose per
  take…" as a fourth, quieter row — her note *"not sure how to not make it crowded"* answered by ONE
  sheet, no inline controls; the phone never gets the hand-placement surface (her 2026-08-03 mobile-gate
  rule: the ceremonies need no mobile replication). Built at the mobile catch-up, not here.
- **Review: Fable.** Implementer Opus.

**Batch 2 — the FACE, built to mockup figure A (and B's header).**
- **Real prose, natural spacing.** Each take renders as prose in the voice's body face (`tokens.body`), no
  inter-word slots; the ✂ is an overlay glyph on the inter-word gap at the cut — the layout never moves
  when it does (the L1 lesson kept by overlaying instead of occupying). Pointer placement by character
  hit-testing on the rendered take (a read-cheap TK2 surface's `characterIndex(for:)`, or the flow geometry
  at a normal space width with the glyph overlaid), snapped to the take's legal set through the ONE brain
  (`nearestSlot`'s semantics: row first, then distance, strong slots pull) — bounded by the take's length.
- **Side by side.** Up to three columns at the sheet's width (the seed first, emphasized by a warmer
  border); more than three → columns of equal width, each scrolling on its own; never a vertical stack
  you scroll to find the second take. The sheet sizes to the window (a large sheet; the merge sheet's
  grammar), `minWidth` ~900.
- **The two halves shown, not explained:** the seed take's text tints top/bottom around the ✂ (two calm
  paper tints; a two-swatch legend in the card's footer); a whole-take card tints entirely and its
  status line says *"✂ at the end — this whole take stays on the top block"*; an unchecked take dims and
  its footer says *"original block · lineage"*.
- **One status line per take** (*"✂ splits here — 41 words above, 38 below"*), the take's badges (shown
  here · ✓ chosen · locked) in the header; the checkbox appears only in "Choose per take".
- **Explainers folded:** ONE sentence under the arrangement row; the keyboard legend behind `?` (the
  Shortcuts & Dictionary helper's grammar); the confirm blocker in the footer's left slot in the warning
  color only when it applies; *"The original block stays whole in Block History → Came from."* as the
  footer's resting line (13f W10a's promise kept).
- **Voice tokens throughout** (`VoiceTokens`, `CalmGrammar`), both voices, light and dark-ready.
- **Pins:** the pure brains keep every test (`WCutPlacement`, `CutFlowGeometry` if retained,
  `DivideWCeremony.State`, the preset seeding matrix); the hit-test path: a click at character k lands the
  nearest legal slot; the end slot reachable by click, drag and → (row 3's regression); a performance pin
  at her scale (four 3,000-word takes: one mount + one click well under a second — the L1 measurement's
  bar); the geometry pin: the ✂ overlay never changes the take's line count.
- **Evidence:** the implementer's walk — open on a three-take block, each preset, "Choose per take", park,
  split, confirm, ⌥⌘Z — captured both voices; her acceptance at the end.
- **Review: Fable** (a structural door's face). Implementer Opus.

### 5.3 — 17o · the evening's defects (FIXES; the standing-17 discipline; four one-surface batches)

**Goal.** Every defect row FIXED with its pin, or DISMISSED AS HOLLOW, or DEFERRED with an owner — each
batch walked by its implementer on the dev-store Debug build, captured, before its record closes.

**Batch b — the landing family.** Rows 7 · 8 · 20 per §4.2. Files: `BlockHistoryPane.swift:131`
(`FocusedBlock`), `CurrentBlockMemory.swift`, `CommandRouter.noteFocusedBlock` (`:126`), `EditorViewModel`
(`:1702–1707`, `:1729`, `:1743–1770`, `:2544`), `TakesViewModel.swift:521`, `TakesChoreographer.swift:159–176`,
`TakesBoardView.swift` (the article, `:503–560`), `JumpPrimitive.swift`. The Act 10 "one current block" pins
ride unmodified (the offset is additive). Pins: the memory round-trips the offset; `bareArrivalLanding` =
start + clamped offset; the Blocks → Write caret rect inside the visible rect on a 250-paragraph fixture;
the board's requested scroll id == the landed slot (model-level — KnownIssues row 43: the rig cannot mount
the whole board; walked). **Review: Fable** (seam-adjacent).

**Batch c — the Takes faces.** Rows 6 · 14 · 15 · 16. (6) `PaneSurface` receives the indicator style
through its appearance push (models never read `@AppStorage`; the setting is
`ThemeStore.settings.editingIndicator`, `ThemeStore.swift:60`): `.off` → the rest hairline only; `.outline`
→ today's ring; `.background` → a wash fill in the pane's frame. Every host follows — Takes, Lenses,
Compare, Canvas (`CanvasView.swift:799`), the Read edit pane's own overlay (`ReadEditPane.swift:148`).
R22's reason for the ring is recorded in the disposition; her ruling governs. (14) `TakeCardFrame` — the
bar as an overlay of the card; geometry pin (bar height == card height on a 40-line take). (15) the "＋ new
block" door in the EMPTY state of Takes AND Lenses (the minted pane takes the ring); an empty first block
is legal (I10 — a live variant with empty text); 18c's Return rule makes it a normal block. (16) trace
first — measure the published height after a 30-line deletion in a pane; if the estimate lags, run
`ensureLayout(for: documentRange)` on the PANE after a shrinking edit (a pane is one take — P1 holds)
then remeasure; pin: the published height shrinks within one turn. Evidence: the walk in both voices, the
indicator setting cycled through all three. **Review: Opus** (Fable if the pane's authority code moves).

**Batch d — the chrome singles.** Rows 9 · 10 · 11 · 12 · 13 · 17 · 18 · 19 · 21 · 27 · 40 · 41.
- (9) `ShellSplit.divider`: the grip a real layout participant over the seam (a ZStack, `.zIndex(1)`,
  ≥ 12 pt, explicit `.contentShape`), the cursor via a tracking-area-backed hover so the editor's I-beam
  never wins inside the grip; push/pop balanced. Pin: the grip's frame (a DEBUG oracle, the
  `SidebarGeometry` pattern) + the walk.
- (10) the Messages fill-code popover: ONE Sonnet lookup (the CLAUDE.md lookup exception) for how macOS 26
  decides a text field is eligible for one-time-code AutoFill and how an app opts a field out
  (`textContentType` / `NSTextField.contentType` / the completion flags); test the digit-prompt hypothesis
  first; the API-free fallback: render the date as a `Text` overlay behind an empty-prompt field. Evidence:
  the walk with a fresh SMS code on the machine (hers to trigger).
- (11) the title LEADS: its leading edge = row two's leading edge (`MastheadRowTwo`'s path chip); its
  measure runs right until the icon cluster's leading edge minus the row gap — at least as far as today's
  centered measure reaches (centre + 190); both faces share the frame; `.multilineTextAlignment(.leading)`.
  The DEBUG oracle (`MastheadGeometry`, `:612–619`) and the rows-4/19 pins are REWRITTEN to the new rule
  (leading-edge equality; width ≥ the old right extent; still "never under the icons"). Her ruling
  supersedes Act 10 rows 4/19 — the closeout records the delta.
- (12) one explicit height for both title faces (the title font's line height) and one baseline; pin:
  `titleFrame.midY` equal across the faces.
- (13) headers inside a padded group pad `rowPadding` only (row 13's mechanism); one leading edge for a
  header and its rows' text; the header gains air above the first row's wash (a 30-pt pitch for the header
  row, the text bottom-aligned with ~6 pt below); "this note" ↔ Write, "Open" ↔ the tabs. Geometry pin.
- (17)+(27) `markPostsAsVersions` on a blockless post — **PROVISIONAL, her call (§7 Q3):** (a, recommended)
  mint the blockless post's first block (empty) in the same transaction and anchor on it — the link exists
  at once; (b) refuse in words with a door. Either way Compare stops speaking the raw error:
  `VersionActs.words` gains the case; Compare's door uses it (the J8 copy-truth pin). Pins: (a) → the edge
  exists, `versionPeerPosts` finds the peer; the wording pin. KnownIssues row 31's text amended if (a).
- (18)+(19) §4.3's observation; pins there.
- (21) the chapter count and the ⋯ share ONE trailing column (`menuIndicator(.hidden)` on the row menu, or
  a fixed trailing column both rows use); pin: trailing edges equal.
- (40) `MastheadTagCluster`: the inline field collapses on focus loss when the note already carries a tag
  (and after ⏎ applies); the `#` reopens it; a note with NO tags may keep the field open on first click
  (her words are about the already-tagged case). Pin: focus loss with an applied tag → `fieldOpen == false`.
- (41) trace which view paints the short white segment above the divider (the toolbar band vs the
  sidebar column's top inset); the divider's line runs the full height the sidebar column runs. Pin: a
  capture-diff or a geometry oracle on the line's frame; the walk.
Evidence: every row walked, both voices, captured. **Review: Opus.**

**Batch e — the Snippets area (rows 38 · 39; "only opus to fix this item").** (38) §4.5's fix: the card
door opens the CARD's pool and lands on the clicked block (the `WriteIntent`/`LandingTarget` road);
`SnippetsCopy.openRow` may read "Open this snippet in its editor". (39) find where she looked for a tag door
on a snippet (the pool editor's masthead? the card?), make the existing "Tags…" door findable where the tag
chip shows (the chip itself as the door is the calm answer), and confirm the tutorial's seeded tag is the
one she saw. Pins: the pool/landing pin (§4.5); the door's presence. **Review: Opus.** Implementer Opus.

### 5.4 — 18d · the sidebar's note box, the tray, the outline's room, the note's memory (U-9 · U-10 · U-12 · U-13)

**Batch 1 — THE SIDEBAR'S NOTE BOX (her "new area"; mockup figure C — the binding shape).**
- **When it shows.** A BOOK is open in an EDITING mode — Outline, Index, Book (the paged editing mode) —
  never in the book's Read tab, and never for a note (a note keeps the "this note" rail). The box stands
  exactly where the rail stands, **at the rail's height** (the rail group's measured height —
  `SidebarGeometry.railGroupHeight` exists in DEBUG; promote it to ONE shared constant/measurement both
  views read), so the Open strip below never moves between a note and a book, or between the box's states.
  Per window (the `ShellRouter`'s state, 13f's multi-window rule).
- **Three states, one height:**
  1. **No note selected** — header "this note" in the accent register; centered, muted: *"no note
     selected"* with the quiet hint *"click a note in the book to see its controls here"*. Shown on the
     book's open, after clicking out of a note (a click on the book's empty column or the navigator's
     chapter row), and after the focused note closes.
  2. **Selected, not live** (a row clicked; the note expanded read-cheap) — the note's IDENTITY and FACTS:
     title (`Queries.noteDisplayTitle`, serif, two lines max), *"chapter 2 · 5 of 12 in this book"* (the
     book's structure the navigator already holds), then three fact lines — words · blocks / ⑂ takes on N
     blocks / *"edited Sep 4 · saved Sep 2"* (date-only stamps, the recovery family's rule; `last_touched_at`
     and the last commit — reuse the gutter's cadence, `BookOutlineRows.gutterLine`, never a per-frame
     query) — and ONE door at the bottom, **"edit here ⏎"**, which makes the note live at its current block
     (`LandingTarget` through the book's `requestLiveBlock`, `BookIndexEditModel.swift:118`).
  3. **Live** (the caret is in the note) — the identity line stays (title · chapter · position · *"block 3
     of 41"*, the bar's `caretLabel`), a small "editing" mark in the ring color at the corner, then THE BAR
     as a two-column grid at the sidebar's pitch: `block ▾` · `Takes` / `commit ⌘S` (primary) · `history` /
     `note ▾` · `comments` / one wide row `Aa · newlines make blocks · on` (the formatting slide-out +
     the chip, as the vertical bar composes them today); the footer: *"112w block · 3,214w note"* (the
     `WordTargetFace`) and `?`. The block ▾ and note ▾ menus are TODAY's menus unchanged
     (`CommitBar.blockMenu`, `noteMenu`); every row is the same act the bar performs now.
- **What retires.** The right gutter's BAR (`EditorView(barPlacement: .side)`'s `CommitBar(axis: .vertical)`,
  `EditorView.swift:113–125`) and the paged mode's floating card. **Her call (§7 Q2):** whether the
  unfocused rows' details line in the gutter (Act 10 row 13's calm facts) retires too — the architect's
  recommendation is YES (state 2 carries the facts now; the prose recentres on the full width) — or stays.
- **Architecture (the P39 refinement, CLAUDE.md):** the sidebar never constructs or holds the book's
  `EditorViewModel`. `RootView` composes: the book publishes `selectedPostID` / `liveFocusedPostID` (its
  own model already has them) and the live editor registers with the router as every detail does
  (`CommandRouter.registerDetail`, `:47`); `RootView` builds the box's content — the facts view from the
  book's published ids, the bar from the registered live editor — and hands the sidebar a view to RENDER
  (rendering a sibling's view is legal composition). No new cross-feature reference; P39b untouched.
- **Fit.** The vertical bar today is ~9 rows; the box holds the header, the identity line, 3 bar rows +
  1 wide, and a footer inside the rail's height at the sidebar's minimum width (180) — the mockup shows
  it at 230. If a state overflows at the minimum width, the box scrolls internally; it never grows.
- **Pins:** a geometry oracle — box height == rail group height, in every state, both voices; state 1
  renders "no note selected" when `liveFocusedPostID == nil && selectedPostID == nil`; state 2's door lands
  the live editor at the note's current block; state 3's rows dispatch the same acts as the bar (reuse the
  bar's own tests); the paged mode shows no floating card; the note's rail unchanged (its pins ride).
- **Evidence:** the walk — Outline/Index/Book with nothing, a selected note, a live note; click out; narrow
  window; both voices. **Review: Opus** (Fable if the composition touches the editor's lifecycle).

**Batch 2 — THIS NOTE'S TRAY, reorganized (U-9; mockup figure D).** `TrayPanel.swift`: ONE top-level
segmented choice — **Leaving (N)** · **Archived (N)** — with the counts; under it ONE filter row shared by
both — **all · blocks · takes** — whose counts follow the view; the explainer one line per view (*"On
the 30-day clock. Put back keeps a row; Delete Now ends its days early."* / *"Kept, no clock. Archiving a
block or a take keeps it here with no countdown."*); every card names its kind (block · take · of block 3 ·
original riding a family's countdown — the leaving section's three populations, unchanged in what they
are); the "▸ N deleted takes" fold retires (the filter is the fold); Put back / Delete Now where they were
(the 13j doctrine: Delete Now on a take here only, never in the writing flow). Remembered: the last view
and filter per session. Pins: the filter's pure rule over the tray snapshot (`TrayModel.Snapshot`); the
counts; the fold gone; every Put back/Delete Now pin rides. **Review: Opus.**

**Batch 3 — the outline's room (rows 22 · 26 · 33).** (a) The LEADING-edge variant of `SideColumn` in
`Core/Views` (the hoist rule; `SideColumnLayout.width` is pure and pinned — the leading variant adds its
mirror pin); (b) the book navigator becomes that column (remembered `bookNavigatorWidth`, min 190, max
~360; chapter rows at a generous pitch — the sidebar's 30-pt pitch as the reference; chapter groups
separated by the mockup grammar's spacing); (c) the note Read contents column becomes the same column
(remembered, min ~240) so long first lines stop truncating mid-word. Pins: the width brain; row pitch;
widths remembered across remount. **Review: Opus.**

**Batch 4 — remembered note lengths (U-12).** Persist `BookViewModel.rememberedSurfaceSizes` and
`SurfaceSizeMemory` per note in a LOCAL-ONLY store: UserDefaults `surfaceSize.<postID>` =
`"w|h|voice|fontSize"` (the `CurrentBlockMemory` precedent); a local-only SQLite table only if the count
argues (its own schema commit; local-only, no lockstep). Safety is already built: R1-1's settle rule
adopts the real size taller or shorter; `stableSurfaceWidthTolerance` refuses a memory at another width.
Pins: a memory read back after re-init; the width-mismatch refusal; a shorter memory settles up.
**Review: Opus.**

### 5.5 — 18e · markdown marks faded (U-11)

**Her lean, verbatim:** *"I think fading them is a good start I suppose."* **Ruled first form: FADE.**

**What the two forms are (her question, answered here so the record holds it):** today
`MarkdownFaceCore.restyle` colors every span's markers in the muted marker color on the storage
(`:183–194`) — the `**`, `_`, `~~`, backticks and link brackets are always visible. **FADE:** the markers
render in the paper color (invisible against the page, or at a whisper of alpha) everywhere EXCEPT the span
the caret is in or the selection touches, where they show in the marker color — you see `**bold**` only
while you are inside it. Nothing moves: the marks still take their width, so a faded `**` leaves a small
gap of paper where it sits; caret math, identity ranges, the widening rule are all untouched; TK2-safe;
cost ∝ the edit plus two lines on a caret move. **COLLAPSE:** the markers take NO width outside the caret's
span (a zero-advance font or negative kern), so `**bold**` reads as `bold` with no gap — and the width
comes BACK when the caret enters the span, so the text after it shifts right by the marks' width as you
arrive and left as you leave. That is the "view jumps when text attributes update" class TEXTKIT2 §3
records, and it puts the caret beside a mark that is re-expanding under it. Identity is still untouched
(attributes only), but the geometry moves under her hands. Fade first; collapse a follow-on if the gaps
annoy her after living with fade. True concealment through content-storage element rewriting is out
(custom `NSTextElement`s assert).

**Build:** the reveal rule is a pure function (caret/selection range × the line's spans → the marker
ranges to SHOW) in `MarkdownFaceCore` — both platforms get the brain; `restyle` takes the caret range and
the setting; a caret move restyles the old and new caret lines only. **The setting:** `markdown_marks` ∈
{`shown`, `hidden`} in the `setting` table (enum, no prose — the 14b column promise; synced like every
document setting); faces in Settings ▸ Editor and the editor's `Aa` menu; default `shown`. The read tiers
unchanged (they already hide). The tutorial's formatting lesson gains one sentence; the phone's face is a
mobile row. **Pins:** the pure reveal rule; `restyle` with a caret range → the caret span's markers in the
marker color, every other span's in the paper color; a caret-move test restyles exactly two lines; the
setting round-trips; the read tiers' pins unchanged; the phone's suite untouched. **Evidence:** type
`**bold**`, move away — the asterisks fade; click back inside — they return; toggle the setting.
**Review: Fable** (editor seam). Implementer Opus.

## 6. THE KICKOFF PROMPT (paste-ready — the same text she was given in chat)

> You are the **Fable orchestrator** for **the 2026-09-06 use-report round — 17o · 18c · 18d · 18e · 18f**,
> run in the classic `/architect-phase` shape: you hold the architect mandate over the author's rulings,
> you spawn a FRESH Opus implementer session per batch, you keep repo-first records, you run the review
> ladder, and you bundle her questions. **You stay lean:** you do not read source files whole (briefs point
> at file:line; the implementer reads), you do not walk every batch yourself (the implementer walks its own
> rows on the dev-store Debug build and captures them; you verify by reading the record and the captures,
> spot-checking only where a record is thin), and you hand off with a record when your own context nears
> ~500k tokens. Her acceptance is ONE walk at the end on the refreshed `/Applications` build.
>
> **READ IN FULL, in this order:** `CLAUDE.md` and the canon it loads · **this plan, every section**
> (`notes/plans/use-report-round-2026-09-06.md`) · her two reports verbatim
> (`notes/author-reports/2026-09-06-use-report.md`) · **the mockups** — open
> `notes/plans/use-report-2026-09-06-mockups/ceremony-and-note-box.html` in a browser; figures A–D are
> the binding shapes for 18f and 18d · `notes/plans/phase-17-standing-fixes.md` (the philosophy, the
> standing rules, the register) · the master plan's `### 13u` section and the 13u plan's fold + addenda
> (the fence in §2 — what you must NOT take) · `notes/plans/act10-correction-round.md` §2b (C-1…C-7,
> binding by reference) · `notes/PhaseSizingGuidance.md` · `notes/SessionResiliencyProtocol.md` ·
> `notes/handoffs/pre-13x-handoff.md` (the tree you inherit: the marker, the baselines, anything open) ·
> `notes/KnownIssuesAndTechDebt.md` (rows 27–28 flake rules; row 31 the version anchor; row 43 the rig).
> Copy the P-1…P-9 constitution into this file's Records section verbatim, as every architect-phase does.
>
> **FIRST MECHANICAL ACTS:** the `.gitignore` line for `notes/plans/use-report-2026-09-06-screens/`; claim
> **17o** in the standing-fixes register and **18c · 18d · 18e · 18f** in the master plan's Phase 18 row,
> each pointing at this plan; the master plan's running-order row; a LIVE STATUS block at the end of this
> file; commit and push. Run the baselines yourself (core `swift test`, the Mac suite, the tutorial spine,
> the iOS build) and record them — the plan's numbers are the last recorded finals, not yours.
>
> **CAST:** Opus implements EVERY batch (her word); you are Fable; cold reviewers per the plan — **Fable on
> 18c, 18f, 17o batch b, 18e**; Opus on 17o c/d/e and 18d — `notes/REVIEW_PROMPT.md` verbatim, a fresh
> reviewer per round, the ladder's three-round cap, every finding dispositioned in this file. The
> hallucination guard binds: pin before fix; a pin green on both sides dismisses the finding.
>
> **ORDER:** 18c (batch 1 the keep-on-top composition + the phone's flip → batch 2 Return makes blocks →
> batch 3 make every newline a block) → 18f (batch 1 names/doors/presets/end slot → batch 2 the face to
> mockup A/B) → 17o (b landing family → c Takes faces → d chrome singles → e Snippets, Opus only) → 18d
> (1 the note box to mockup C → 2 the tray to mockup D → 3 the outline's room → 4 remembered lengths) →
> 18e (fade). Each LETTER closes on its own dispositions before the next opens; she may hold 18e.
>
> **EVERY IMPLEMENTER BRIEF RESTATES, in its own text:** the checkpoint rules (commit per piece, push after
> each, synchronous waits, one agent at a time, a record in this file); one surface per session (hand off
> if a second appears); the acceptance gate is USE — walk your own rows on the dev-store Debug build
> (`io.lduarte.Variorum.debug`, `cliclick` + `Tools/WalkKit/`, never `/Applications`), capture per row to
> `notes/plans/use-report-2026-09-06-screens/<letter-batch>/`; red-on-old for every bug-class row; no
> product invention (a decision the spec does not make → QUESTIONS, the next free number — #90 is
> `pre-13x`'s); the 13u fence; for 18c and 17o-b the seam rules (the identity oracle runs per keystroke in
> DEBUG and kills the process on identity corruption; clamp any attribute stamp to the verdict's range —
> TEXTKIT2 §3; `runStructural` is the one structural door; never touch `BlockRangeIndex`'s regions); no
> commit trailer lines (her 2026-09-04 rule); zero `Sources/VariorumCore/Sync/`, zero lockstep.
>
> **HER OPEN QUESTIONS are §7 of the plan** — three remain (the versions shape; the gutter's retirement;
> the phone's default flip timing is settled — same batch). Bundle anything new for one sitting; never
> decide product in a batch.
>
> **AT EACH LETTER'S CLOSE:** dispositions per row; the suites green (+ the iOS build for 18c/18e/anything
> in `Shared/`); the canon deltas the plan drafted, applied exactly as ruled (18c: AppSpec §9's divide
> default + §7's segmentation-trigger paragraph; 18f: the ceremony names; 18e: §12's formatting sentence);
> for 17o a dispositions block copied into the standing-fixes file. **AT THE ROUND'S CLOSE:** the standing
> ritual whole — master plan pointer + closeout paragraph (the previous archived), QUESTIONS' ratify list,
> the MOBILE PARITY LINE in `notes/MobileSoul.md` (the divide presets sheet, the reveal brain, the offset
> landing, the indicator rule), the author handoff `notes/handoffs/use-report-round-2026-09-06-handoff.md`
> with her checklist at the top (launch; restore the field guide — the divide lesson changed; the walk list
> in order), the `/Applications` refresh after the last walk at a zero-instance window with the A1 backup
> first, push.

## 7. Her remaining questions (bundle for one sitting; everything else in §1 is settled)

1. **The versions refusal on a blockless note (row 17):** mint the empty first block and link at once
   (recommended), or a legible refusal with a door?
2. **The book's right gutter:** with the bar gone to the sidebar box, does the unfocused rows' facts line
   retire too (recommended — state 2 of the box carries the facts) or stay beside the prose?
3. **Return's empty block (18c batch 2):** the first build leaves an abandoned empty block as an empty
   paragraph (recommended); the quiet-removal follow-on if it annoys you. And the k−1 typed-blank-line rule
   narrowing to ⇧⏎ — ratify.
4. **"Make every newline a block" and lists:** a single newline between two list lines is NOT a break
   (lists stay whole) — ratify.
5. **The ring setting's reach:** every live pane (Takes, Lenses, Compare, Canvas, Read-edit) — yes?
6. **The 13u2 handover:** row 11 likely closes 13u2 item 13 — the 13u2 kickoff's call; nothing needed now.

## 8. Process (binding on every batch)

- **The correction round's C-1…C-7 bind by reference** (`notes/plans/act10-correction-round.md` §2b) —
  **with ONE amendment, hers (U-14):** C-2's second half ("the orchestrator walks the same rows hands-on")
  is replaced by *the implementer walks and captures; the orchestrator verifies by record and capture,
  spot-checks only where thin; the author walks once at the end.* C-3 stands: no install refresh without
  that final walk.
- **The standing-17 rules** (`phase-17-standing-fixes.md`): pin before fix; measure before believing a
  number; no product invention; schema commits alone.
- **The lean orchestrator:** briefs by pointer (file:line from this plan), never whole-file reads; records
  appended here per batch (brief → record → dispositions); the ladder's findings and dispositions here;
  a handoff to a successor orchestrator at ~500k tokens (`notes/SessionResiliencyProtocol.md` — the
  recovery half is the orchestrator's; implementer briefs restate the checkpoint half).
- **Session resiliency** binds every session; **no commit trailer** lines; **walk tooling** on the
  dev-store Debug build only; captures per batch under `…-screens/<letter-batch>/`.
- **The install refresh** follows the round's last walk, at a zero-instance window, the A1 backup first.

## 9. Environment traps, baselines, coordination

- **Baselines at open:** read `notes/handoffs/pre-13x-handoff.md` for the true finals and the lockstep
  marker (pre-13x moved it 7 → 8 at its event); the last recorded finals before it were the Act 10
  correction round's (core 1525/165 · Mac 2106/378 · spine 72/10). **Run your own.** Flake rules stand
  (KnownIssues rows 27–28).
- **The 13j environment traps bind verbatim** (by reference: `notes/plans/phase-13j-deletion-and-trash.md`);
  the identity oracle per keystroke in DEBUG on both platforms; the macOS-26 widening rule; the real-click
  rig cannot mount whole surfaces (row 43) — pin brains, walk faces.
- **Coordination with 13u (§2's fence):** each letter's closeout lists which 13u items it touched (item
  13 via row 11; item 1's family via rows 16 · 25) so the 13u1/13u2 kickoffs inherit decisions.
- **KnownIssues:** row 31 amended if the versions shape (a) is chosen; anything deferred out of this round
  needs an owner there.

## 10. Obligations at close (per letter, then the round)

**Each letter:** every row it owns dispositioned (FIXED with its named pin · DISMISSED AS HOLLOW · DEFERRED
with an owner); the ladder complete or capped with its residue recorded; the suites green; the walks
captured; the canon deltas applied exactly as ruled; 17o's dispositions block copied into the
standing-fixes file. **The round:** the master plan's pointer and running order moved on; the 17 register
and the 18 row updated; QUESTIONS' ratify list (the PROVISIONALs: the versions shape · the empty-block
rule and the k−1 narrowing · the list exception · the gutter's retirement); the MOBILE PARITY LINE; the
author handoff with her checklist at the top; the install refreshed after the last walk; the closeout
paragraph in the master plan; push.

## 11. Image manifest

`notes/author-reports/2026-09-06-use-report.md` — every file in `…-screens/author/` mapped to its row;
images 14–16 (pasted in chat) described there.

---

## LIVE STATUS

*(The orchestrator writes here from the first commit: the letter and batch in flight, the last commit,
what is verified, what is next. Empty until kickoff.)*

## Records

*(The P-1…P-9 constitution first; then batch briefs, batch records, ladder findings and dispositions,
in run order.)*
