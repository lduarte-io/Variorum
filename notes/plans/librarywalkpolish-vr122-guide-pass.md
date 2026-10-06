# VR-122 — the field guide's full currency pass (librarywalkpolish, a PRE-0.9.2 GATE)

**NOT DONE (first line, per the contract):** PENDING — written at close.

**Her instruction (verbatim, the issue):** "I also want to be sure that the field guide is up to date
fully from all of these changes + the 13i changes. Let's make sure either you or a subagent runs
through the field guide at the end right before release - both so any new users get a good guide
during the beta phase and to ensure that the version I'm rewording is the most up to date possible."

**Who / where:** `opus-implementer`, 2026-10-05/06, worktree `~/dev/variorum-17y` (branch `main`),
DerivedData `App/Variorum/DerivedData/17y-vr122`. Authorized write surface: the seed CONTENT in
`App/Variorum/Variorum/Features/Tutorial/TutorialSeeder.swift` + this record + test files. Zero
`Sync/`, schema, custody, `Shared/`, mobile.

**Read in this session's own context (never delegated):** CLAUDE.md + its auto-loaded canon (AppSpec
§12 the standing surface); `notes/plans/librarywalkpolish.md` whole (R-LWP-1…6 as amended,
VR-113…122); `notes/plans/17y-sitting-rulings-2026-10-05.md` whole (R-17y-1…10); the 17 file's 17y
kickoff + RUN RECORD (incl. CANON DELTAS OWED), the B3 RECORD and the B-WALK BRIEF + RECORD;
`notes/plans/librarywalkpolish-ladder-round1.md` (the lesson-7 reword + its one VR-122 note);
`TutorialSeeder.swift` WHOLE (every chapter, lesson body and staged take) + the privacy chapter's
copy (`Shared/PostureCopy.swift` §7 constants); the guide's suites (`TutorialWalkTests`,
`TutorialBooksChapterTests`, `TutorialBuildFlavorTests`, `TutorialFurnitureFoldTests`); and the CODE
behind every claim in doubt (cited per row below).

## LIVE STATUS (flipped per commit; PENDING = unverified)

| # | piece | status |
|---|---|---|
| 0 | This record: the audit table (every lesson × verdict × anchor) + the fix list + the judgment list | DONE (this commit) |
| 1 | The red pins, committed AHEAD of the seed edits, run red on the shipped seed | PENDING |
| 2 | The seed edits (F-1…F-12), the pins green | PENDING |
| 3 | END: the tutorial spine + seeder + books-chapter + ritual suites + the seed pin + the shipped-shape core fold | PENDING |
| 4 | Record close (NOT-DONE first line, counts, diff size) | PENDING |

## HOW EACH CLAIM WAS JUDGED

Every lesson's sentences were read against the surface 0.9.2 SHIPS — the Release build (Canvas
gone, the note row six modes ⌘1–⌘6, "my order" + Send to Top/Bottom hidden), the 17y faces (the
Arrivals icon, "Arrivals", "unfiled", "Cards", the starred shelf, the cross-wing follow, the
searchable pickers, the inline book mint), the 13i family (wings, shelves, gatherings/arrivals,
owned/finished/sealed, book archive, the daily Journal) and this pass's VR-113…119. **TRUE** = every
claim checked holds on the shipped code (the anchor names the code or the green pin that executes
it). **STALE-FIXED** = at least one claim was FALSE of the shipped surface (wrong door, wrong word, a
retired or Release-hidden capability taught, or a flow that cannot run where the guide puts the
reader) — corrected in the seed with functional words only (her register kept; 13s re-voices).
**JUDGMENT-FOR-HER** items (J-n) are recorded, never built: tone, emphasis, or teaching something
new.

## THE AUDIT TABLE — 41 lessons + the 5 books-chapter rituals

| chapter · lesson | verdict | claims checked → anchor (code / ruling / pin) |
|---|---|---|
| welcome · **start here** | TRUE | Bookcase noun (`SidebarView.areas`); Help ▸ Restore Tutorial… (`.restoreTutorial`, Help group `EditorCommands` CommandGroup after `.help`); the answer "appears briefly at the bottom of the window" (refusal toasts; receipts the QUIET line that fades — `QuietReceiptLine`, 18i); ⌘/ helper (`.helper` "Shortcuts & Dictionary"); chapters "listed to the left" (the book navigator/Index column/Read contents column are leading columns) |
| welcome · **getting around** | **STALE-FIXED** (F-1, F-2) | **F-1** "The sidebar has four places" — FALSE: five areas since the post-13l polish round (`SidebarView.areas`: Bookcase · Library · Pool · Snippets · Archived). **F-2** Library "with a List and a Timeline view" — the views are List · Cards · Timeline (`LibraryCatalogModel.Mode.label`; "Cards" is R-17y item (d)'s word). TRUE: the dashed box (`QuickEntryBar.placeholder` "new note — just start typing · ⏎ opens it…"); ⌘K/⌘N/⌘J (registry); the mode sentence DERIVES from `PostMode` (Release "six modes … ⌘1–⌘6", Debug seven — `TutorialBuildFlavorTests`); first open is WRITE (`PostDetailView` `?? .write`; S4-20 — see J-17 on AppSpec's stale line); ⌘2/⌘1 Takes/Write (`PostMode.declaredOrder`) |
| welcome · **the workspace** | **STALE-FIXED** (F-3, F-4) | **F-3** "⌘[ and ⌘] walk back and forward" and "(⌘[ and ⌘] are the same doors)" — FALSE since 13u4 UNIT S1: ⌘[/⌘] are Outdent/Indent, back/forward are ⌥⌘[ / ⌥⌘] (`.navigateBack`/`.navigateForward` shortcutLabels; PROVISIONAL #130; AppSpec §12 keyboard family). **F-4** "Right-click any note or book ▸ “Toggle Star”" — the ROW reads Star/Unstar (`StarDoor.title` → `StarCopy.rowTitle`); "Toggle Star" is the ⌘K act's verb only. TRUE: Open Beside / View ▸ Open Beside / View ▸ Close Split / File ▸ New Window / Open in New Window (registry + `EditorCommands`); one live pane; ⌘⇧1–9 + ✕ row (`.openNote`); the context bar's three doors (`ContextBarDoors.Door` back · book · forward) + the ⌫ badge; the masthead tag field + ⌘⇧I (pins `theWorkspaceLessonTeachesTheMastheadTagDoor`); the star cap fifteen (`Operations.starLimit`); the quick note ⌘⇧N / ⏎ files / ⇧⏎ / ⌘⏎ / tagged quicknote → the Quicknotes gathering (pins `…QuicknotesLanding`, `…CaptureKeys`); "Windows & panes" group (`HelperView`) |
| writing · **blocks & typing** | TRUE | crystallization; the Return model with the chip on, ⇧⏎ in-block newline, "newlines make blocks" switch (`OpsRefusalCopy` chipOn/chipOff; AppSpec §7 segmentation); ⌘⇧B seams (`.toggleSeams`); the bottom bar's block + word counts |
| writing · **shaping blocks** | **STALE-FIXED** (F-5) | **F-5** "Write and Takes alike; the block ▾ menu in the bottom bar also has ＋ New block at the end of the note" — that row is on TAKES' block ▾ only (`TakesBottomBar` "＋ New block at the end of the note"; Write's `CommitBar.blockMenu` has New block below, not at the end). TRUE: ⌘⇧K Make Block (pin `makeBlockFreesTheLonelyMiddleSentence`); ⌘⇧⏎ both editors (pin `newBlockBelowMintsUnderTheFocusedBlockInBothEditors`); "the named block" + Name… on a Blocks row (`BlocksWorkbenchView` rowMenu); Block ▸ Callout (Block menu, `.callout`) |
| writing · **formatting** | **STALE-FIXED** (F-6) | **F-6** "Format ▸ Heading ▸ 2" — the submenu's rows read "Heading 1/2/3" (`MarkdownActs.headingRows`). TRUE: ⌘B/⌘I, strike + inline code in the FORMAT menu (`EditorCommands` CommandMenu "Format"); right-click "Format" (`MarkdownActs.menuTitle`); Bullet List / Add Link; checkbox click; the book's Outline · Index · Book · Read row (`BookView.bookMasthead`); Read renders markdown (pin `theFormattingLessonIsWrittenInTheVocabularyItTeaches`) |
| takes · **your first take** | **STALE-FIXED** (F-7) | **F-7** the flow cannot run where the guide puts her: a note opens in WRITE the first time (`PostDetailView`), and in Write ⌘T mints the take with only a receipt ("New take added on this block — ⌘⇧T shows the takes.", `EditorViewModel.mintCaretTake`) — no take "appears beside it", and Write's bar has no "＋ take" (`CommitBar`; it is `TakesBottomBar`'s "+ take"). The fix sends her to Takes (⌘2) first. TRUE: ⌘T / ⌥⌘T (registry); the one ring |
| takes · **choosing & the board** | **STALE-FIXED** (F-8) | **F-8** the same flow: in Write, ⌘⏎ and ⌃⌘←/→ only OPEN the takes panel (`EditorView.handleRouted` — choose/step → `openCaretFan`); stepping, paging (⌥⌘←/→) and the "style:" menu are the Takes board's (`TakesBoardView.header`). The fix names Takes (⌘2). TRUE: ⌘⏎ / ⌘⇧T / ⌃⌘←→ / ⌥⌘←→ (registry); style: Stack · Carousel · Margin grid · Slot split; ⎋ closes every fan; four staged takes (pin `actReadyStagingIsInPlace`) |
| takes · **keeping takes safe** | TRUE | ⌘S name field + ⏎ skip (pin `theSavingLessonTeachesTheNameAndTheSkipKey`); history beside commit on both bars (`CommitBar` `BlockHistoryPath.doorLabel`; Takes bar); ⌘⇧A archive + "archived · 1" door + Unarchive (pin `archiveLeavesTheBoardAndUnarchiveBringsItBack`); the cadence switch in Settings ▸ Writing (`SettingsPane.writing`, `SavepointCadenceCopy` — its three choices, the ~2 h backstop, the insurance note) |
| structure · **divide** | TRUE | ⌘⇧D, the word-edge snap (S4-22); keep-on-top default (U-2); ⌥⌘⇧D the ceremony; divide NATIVE in Takes + block ▾ Divide, Extract/Make Block/Merge carried to Write (`TakesStructureController.runStructuralDoor`); ⌥⌘Z (pins `divideCuts…`, `divideFromTakes…`) |
| structure · **divide choosing takes** | TRUE | the sheet's four presets (AppSpec §9; 18f); per-take ✂ / parking (pins `theCeremonyCuts…`, `theCeremonyParks…`) |
| structure · **extract & make block** | TRUE | ⌘⇧E edge spans + word snap; Make Block for a middle span; both carried from Takes (pins `extractPulls…`, `aLateStartSelection…`) |
| structure · **merge** | TRUE | the rendering join R-13u4-3; ⌘⇧M; carry-all default; ⌥⌘⇧M presets + pairing; three-or-more = two answers (U-16) (pins `mergeJoins…`, `mergingAFannedBlock…`, `theMergeCeremonyPairs…`) |
| structure · **the two undos** | TRUE | ⌘Z / ⌥⌘Z / ⇧⌥⌘Z (registry); J7's sign; the overwrite undo ASKS + insures (pin `structuralUndoInsuresTextTypedAfterTheAct`) |
| deleting · **deleting blocks** | TRUE | every door from its own constant (pin `everyDoorTheChapterNamesIsADoorTheAppHas`); the acts executed (`aWholeParagraphSelection…`, `theTwoScratchParagraphs…`, `commandZAfterTheLessonsDelete…`) |
| deleting · **archive · delete · scraps** | TRUE | the three fates + Block ▸ Archive/Delete Block + the ⋯ Move out row (same pin; `theThreeVerbsSendTheirBlocks…`) |
| deleting · **the tray & the Trash** | TRUE (+J-10) | the tray views + filter + Put back; the Library's Trash (masthead icon) + Archived; purge doors Trash-only (pins `theTrayPutsBack…`, `thePurgeDoorsAreTrashOnly…`, `theLessonItselfGoesToTheTrash…`) |
| deleting · **what a block leaves behind** | TRUE | history beside commit; Came from + Bring back; See original from divide…; deleted takes' ⋯ ▸ Delete Take; the family clock (pins `theDividedBlocksPast…`, `theDeletedSpareTake…`, `theOriginalMovesOntoTheFamilysClock…`) |
| where things go · **the five places** | TRUE (+J-10) | every place from its own constant (pin `everyPlaceTheChapterNamesIsAPlaceTheAppHas`, `theFivePlacesAreFivePlaces…`); Right-click ▸ Archive (`LibraryCatalogView` row menu `.archiveNote`) |
| where things go · **saving a moment** | TRUE | ⌘S / ⌘⇧S; history beside commit; note ▾ ▸ Versions… (`CommitBar` note menu) (pin `theTwoSavesKeepTwoSizesOfMoment`) |
| where things go · **what a copy carries** | TRUE | (pins `theCopyLessonsPractice…`, `aVersionHoldsThePlacedParagraphs…`) |
| where things go · **the two exits** | TRUE | (pins `theTwoExitsLandInTwoDifferentPlaces`, the fanned matrix suite) |
| keeping it private · **What's true in every mode** | TRUE | copy §7 verbatim from `ProtectionCopy` (pin `TutorialPrivacyChapterTests`); Shared copy — not this pass's write surface; 13s's mockup-first territory (R-17y-8) |
| keeping it private · **Standard and Castle: what you must keep** | TRUE | the same; "the book “Encryption Explained” on this shelf" holds — it is still seeded and shelved on Welcome beside the guide (R-17y-8 left it until 13s) |
| ways of looking · **read** | TRUE | READ ⌘3, edit · read faces, outline button, continuous · pages, Aa − / Aa + (`ReadModeView`) |
| ways of looking · **lenses** | TRUE | ＋ column ▸ Open “the other reading”, 💾, ✓ Make this the note (`LensesBoardView`); the staged lens (pin `adoptingTheOtherReading…`) |
| ways of looking · **compare & versions** | TRUE (+J-8) | follow this note's order · related blocks only (on at open — `CompareBoardView.relatedOnly = true`) · make outline note · Diff Save… · Mark/Unmark/Duplicate as Version (`LibraryCatalogView` row menu) (pins `theVersionTwin…`, `outlineMints…`, `compareHonesty…`) |
| ways of looking · **blocks** (Release) / **blocks · canvas** (Debug) | TRUE | DERIVED from `PostMode.buildKeepsCanvas` (`TutorialBuildFlavorTests`); the workbench's rows ↑ ↓ + ⋯ Move to top/bottom/block #… + the bulk bar's merge · tag ▾ · move out ▾ · archive · delete + the panel's open in write · see takes · history (`BlocksWorkbenchView`) |
| library of things · **comments & tags** | **STALE-FIXED** (F-12) | **F-12** "in Write, pointing at an uncommented block offers a quiet ＋ in the left margin" — RETIRED at 13l (her 8c rider: "I need the comment + on the left removed"; `BlockDecor` — the hover add-a-comment chip is GONE). TRUE: the // prefix (`VoiceTokens.commentPrefix`); the margin card/badge opens the panel; ⌘⇧' ; the comments button on both bars; tags on the masthead + ＃ field + ⌘⇧I + Settings ▸ Tags' Make a Gathering… (pin `theCommentsAndTagsLessonTeachesTheMastheadTagField`) |
| library of things · **pool & scraps** | **STALE-FIXED** (F-9) | **F-9** "right-click a snippet row — here, in the side panel, or on a canvas card" — the Snippets area's Canvas face is OFF in Release (17y (p), `PoolDetailView.Mode.faces(keepingCanvas:)`; the CANON DELTA OWED). TRUE: the groups column + all snippets + Scraps button + Move to Group + the dashed box (pin `thePoolAndScrapsLessonSpeaksTheSurfacesVocabulary`); ⌥-drag the fan (pin `scrapsDragCopyOut…`) |
| library of things · **export — it's all yours** | TRUE | the Library row's Export ▸ Markdown… / Markdown with Takes… / PDF…; File ▸ Export Block as Markdown… / Export Library… (File importExport group); the Bookcase row's Export Markdown…/PDF… (`ShelfView.bookMenu`); backups + the second folder (pin `theExportLessonTeachesWhereBackupsLive…`) |
| library of things · **the seal** | TRUE | refusals spoken; Unseal on note ▾ (pin `theSealRefusesOutLoud…`; `CommitBar` note menu) |
| library of things · **three ways of working** | TRUE | conceptual; its practice fan (pin `threeWaysLessonCarriesItsPracticeFan`) |
| books · **the classics walk** | TRUE | the three kinds; Welcome holds the guide + Sherlock + the classics gathering; #classics; the "owned by" mark (badges default ON — `AppearanceQueries` `ownershipBadges`); Help ▸ Restore “…Jekyll…” (`.restoreJekyllBook`, R-17y-8) (pins `lessonOneTheThreeKinds`, R1) |
| books · **a book from the inside** | **STALE-FIXED** (F-10) | **F-10** "Three views of a book share the toggle at the top" — FALSE: four — Outline · Index · Book · Read (`BookView.bookMasthead` modeTab ×4; the book INDEX since pre-13u Act 10 wave 2c, editable in place since the correction round — `BookIndexEditModel`). TRUE: ＋ new chapter / ＋ new note; the chapter menu Rename… · Move Chapter Up/Down · Delete Chapter (`BookView.chapterMenu`); Read's Scroll · Pages; a finished book opens into Read (`BookStructureModel.defaultMode`); Length & Extent… on the Bookcase row; the row's progress (`ShelfView` row facts, details shown by default — `BookcasePrefs`); the note's own target (pin `pagesFlipTheGuide…`) |
| books · **membership, not ownership** | TRUE (+J-6) | the edit law + ritual R2 (pins `lessonTwoTheEditLaw`, R2); "+ New Book" (`ShelfView` masthead); the chip's Add to Book (`MembershipChoiceCopy` "Add to Book", ALWAYS drawn since 17y (o)); Delete Book…; 30 days + Put back |
| books · **gatherings & arrivals** | TRUE (+J-5, J-7) | ＋ New Book ▸ Create Gathering… (`RuleEditorCopy.mintTitle`); Bind into a Book… (gathering row menu); keeps collecting; the Arrivals icon "beside the book's settings gear" (`BookView.bookMasthead` — `BookArrivalsDoor` before the gear, R-17y-1/2); add / copy in / dismiss (pins `lessonThreeGatherings`, `lessonFourArrivals`, R3) |
| books · **owned, finished, sealed** | TRUE | Own Its Notes… / Finish / Seal… / Reopen / Unseal on the row + in Book Settings…; Release / Remove from This Book (`RemoveFromBookCopy`, book view rows); the owned delete's two choices (pins `lessonFiveOwned`, `lessonSix…`, `lessonEightDeleting`, R4) |
| books · **the bookcase** | **STALE-FIXED** (F-11) | **F-11** the strip sentence "All, then each shelf by name" — the strip reads All · **starred** · the shelves (`BookcaseStrip.names`; R-17y-9's virtual shelf; the round-2 ladder's one VR-122 note); the star sentence now says starred books gather there too. TRUE (since the F-BW-1 reword): A–Z or last edited (`offeredOrderModes`); the shelf menu Rename… · Set Glyph… · Make Default · Delete Shelf… (books → Unshelved); Move to Shelf; Star floats first; the place/finder boundary (pins `lessonSevenTheBookcase`, `noLessonTeachesADoorThisReleaseHides`, R5) |
| books · **the journal & the pool** | TRUE | ⌘J / Today's Entry (Bookcase masthead); archive, can't delete, comes back (13i-e + her post-close ruling; pin `lessonNineTheDailyJournal`); the Pool's tuck + "show" + the seeded quicknote (pin `lessonTenThePool`) |
| books · **wings** | TRUE (+J-4) | the switcher on the Bookcase masthead + New Wing…; Move/Copy to Wing on note rows, Move to Wing on the book row (`WingsModel`, `ShelfView.bookMenu`) (pin `lessonElevenWings`) |
| books · ritual **R1** the classics walk | TRUE | pin `ritualOneTheClassicsWalk` |
| books · ritual **R2** membership by hand | TRUE | pin `ritualTwoMembershipByHand` |
| books · ritual **R3** the gathering's life | TRUE | pin `ritualThreeTheGatheringsLife` |
| books · ritual **R4** ownership's boundary | TRUE | pin `ritualFourOwnershipsBoundary` |
| books · ritual **R5** the shelf gesture | TRUE (extended with F-11) | pin `ritualFiveTheShelfGesture` — gains the starred shelf's truth |

## THE FIX LIST (functional words only — 13s re-voices)

| F | lesson | was | becomes |
|---|---|---|---|
| F-1 | getting around | "The sidebar has four places." | "five places" + "ARCHIVED keeps the notes and books you set aside — forever, no clock." |
| F-2 | getting around | "with a List and a Timeline view" | "with List, Cards and Timeline views" |
| F-3 | the workspace | "⌘[ and ⌘] walk back and forward…" · "(⌘[ and ⌘] are the same doors)" | ⌥⌘[ and ⌥⌘] in both places |
| F-4 | the workspace | "Right-click any note or book ▸ “Toggle Star”" | "▸ “Star”" |
| F-5 | shaping blocks | "the block ▾ menu in the bottom bar also has ＋ New block at the end of the note" | "in Takes, the block ▾ menu…" |
| F-6 | formatting | "Format ▸ Heading ▸ 2" | "Format ▸ Heading ▸ Heading 2" |
| F-7 | your first take | "Click into that paragraph and press ⌘T…" | "Press ⌘2 for Takes, click into that paragraph and press ⌘T…" |
| F-8 | choosing & the board | "Open its fan (⌘⇧T), step through…" | "In Takes (⌘2), open its fan (⌘⇧T), step through…" |
| F-9 | pool & scraps | "— here, in the side panel, or on a canvas card —" | "— here, or in the side panel —" |
| F-10 | a book from the inside | "Three views of a book share the toggle at the top." | "Four views…" + one INDEX sentence |
| F-11 | the bookcase | "All, then each shelf by name" · the star sentence | "All, then starred, then each shelf by name" + what starred is; starred books also gather on starred |
| F-12 | comments & tags | "…and in Write, pointing at an uncommented block offers a quiet ＋ in the left margin right where its note would sit." | the retired clause removed |

## JUDGMENT-FOR-HER (recorded, never built — her 13s re-voicing list)

- **J-1** The № census popover (VR-115: its six solos, composing within a solo'd shelf) is taught nowhere; lesson 7 could carry one sentence.
- **J-2** The Cards ⇄ scope honesty switches (VR-114: Cards moves the scope to Notes; All moves you off Cards) are untaught; getting around now NAMES Cards only.
- **J-3** The starred shelf's drop-to-star gesture (R-17y-9) — F-11 names the word and what it shows; whether to teach the drop is hers.
- **J-4** The cross-wing follow ("Now in “X”.") and the Open list's wing marks (17y (f)) — "wings" stays true without them; teaching them is new content.
- **J-5** The Arrivals icon's calm/presence states and "a waiting note opens when you click its name — opening never adds it" (17y (h)) — lesson 4 names the door only.
- **J-6** The add picker's inline mint ('New book “X”', 17y (o)) — the membership ritual makes its second book through ＋ New Book; the picker could make it in place.
- **J-7** The rule builder's searchable "+ tag" with create-in-place (17y (g)) — the gathering ritual works either way.
- **J-8** Duplicate as Version now carries the note's tags (17y (c)) — "compare & versions" says "a whole copy (takes and all)"; "and its tags" is hers to add or not.
- **J-9** "unfiled" (R-17y-4) appears in no lesson; the books chapter could name the chapterless state.
- **J-10** BOOK archive (13i-e) beyond the daily Journal: "the five places" and "the tray & the Trash" describe Archived as a notes room; books archive there too (Archived's BOOKS group).
- **J-11** List nesting ⌘] / ⌘[ (13u4 S1) is untaught in "formatting".
- **J-12** The echo F-1 creates: getting around's "five places" (the sidebar) and the map chapter's "the five places" (where things are) — two different fives; a re-voice candidate.
- **J-13** The Takes orientation (F-7/F-8) is said lesson by lesson; a chapter-level orientation sentence is a re-voice choice.
- **J-14** The Book Panel (13i-d — the right-side book TOC on every membered note, its switcher, Remove/Release, drags) is taught nowhere.
- **J-15** (NOT the guide — routed to the orchestrator) the ⌘/ helper's own drift: its "The note's bars" group still teaches the RETIRED tag-card fold ("The ＃ icon folds them away and back (⌘⇧I does the same)", "tag cards (top bar)") and its Windows row says "right-click ▸ Toggle Star" (the row reads Star). `HelperView.swift` is not seed content — outside this session's write surface.
- **J-16** The quick note's menu-bar mark: the guide writes ✏︎, the helper ◻, the item is SF Symbol `square.and.pencil` — cosmetic, hers.
- **J-17** (canon, routed to the orchestrator) AppSpec §12 says Takes is "the first-open default"; the code (`PostDetailView` `?? .write`), S4-20 and the guide say WRITE — AppSpec's line is the stale one.

## THE RE-SEED CONSEQUENCE (one line, as scheduled)

These are seed-CONTENT edits: a fresh store is born with the new words; her real store's guide
re-seeds via Help ▸ Restore Tutorial… at the arc's close (already scheduled in
`notes/plans/librarywalkpolish.md` § THE SHAPE OF THE PASS), and a 0.9.1-minted guide and a
0.9.2-minted guide differ in content, so the pairwise furniture fold keeps both across that version
boundary (the fold judges content identity — the standing B-DEDUPE consequence).
