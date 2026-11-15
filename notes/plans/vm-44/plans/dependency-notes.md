# VM-44 — dependency notes (draft, not canon)

The raw constraints a planner needs before grouping the work list into umbrellas and waves. No umbrellas or waves are
proposed here — that is the orchestrator's, with her. W- ids are rows in `master-work-list.md`; SW-/LS-/BK-/NT-/LP-/FR-/
LK-/PD-/SC- ids are questions in `sitting-1-questions.md`. Every constraint names the audit fact it rests on; INFERRED
carries over where the reader inferred.

---

## 1. Hard ordering constraints

These follow from code facts the audits verified; a different order either doesn't work or does the work twice.

### Wings first, for anything that lists or mints
1. **The current wing comes before every scoped read and every wing-aware mint.** `WingState.readScope` returns nil on iOS and the device memory attaches only on macOS (A·D3, `Shared/WingState.swift:52-58`, `Shared/AppBootstrap.swift:497-505`). Until W-015 lands, every read stays all-wing. Waiting on it: W-033, W-034, W-017, W-019, W-229, W-100, W-054 (through W-033), W-067 (through W-033).
2. **Phone search needs a wing.** Every FTS read takes `SearchScope(wingID:)` by construction (A·C8, `Sources/VariorumCore/Domain/SearchQuery.swift:233-251`). W-059 follows W-015 unless LS-2 rules a cross-wing exception.
3. **The wing switcher's brain speaks through a seam the phone doesn't have.** WingsModel reports through `session.status`, which sits inside `#if os(macOS)` (A·I1, `Shared/AppSession.swift:693-853`). So W-012 (or a callback) comes before W-016, which comes before W-017, W-018, W-020 and W-036.
4. **The wing-blind pickers don't need the switcher.** Each picker can read its own note's or book's wing (`effectiveWing(ofPost:)`, `allTags(_:wingID:)`; A §3.1). W-035 can land before any wing face — and it is creating twin tags and dead rule terms today (§3).

### Type before any screen is resized
5. **A phone type scale must be layered over the shared tokens before any screen is resized.** The phone has no type tokens of its own and wears the Mac's `VoiceTokens` unchanged (G§1.1); the Mac reads the same tokens, so changing them in place changes the Mac (D§6). W-001 comes first; then W-002; then W-003; then every screen-level row (W-007, W-023, W-149, W-211, W-032, W-148, W-067, W-096, W-040).
6. **The shelf's layout arithmetic is pinned to 11.5 pt.** `MobileShelfLayout.smallLineHeight = 14` (one line of 11.5-pt text) drives the quick-note box's line cap and the writing-floor guarantee, and it is test-pinned against the real fonts (G§1.4 item 5, `MobileShelfLayout.swift:88-117, 214-221`). W-024 rides W-001 and comes before W-023, W-242 and any home-screen change from SW-3.
7. **The box's copy doesn't fit at a larger size.** At 14 pt the 42-character placeholder runs past the 338 pt the box leaves (G§3.2). W-023 needs shorter copy or a wrap rule; the copy names ⏎'s behaviour, so it follows SW-4 and W-022.
8. **Contrast is a token change too.** muted and faint fail at small sizes in light mode (G§4.2) and the tokens are shared (D§6): W-004 is part of the same phone layer as W-001.

### Previews need a different listing
9. **Row previews need card facts the phone's listing doesn't carry.** `Queries.library` doesn't select `profile`, so the journal rule can't apply (A§3.2, `Sources/VariorumCore/Queries/Timeline.swift:229-231`); `catalogNotesPage` does, and also ends the silent 200 cut. So W-037 comes before W-040; W-038 (a flat, capped Core read) and W-039 come before it too.
10. **Previews must not ride the held observation.** The phone's listing re-fetches on every container write; reading previews inside it would re-read them at autosave rate (A§3.2; F§7). Decide W-037 and W-240 together.
11. **Book-list naming needs the same hoist.** W-079 and W-054 reuse the composition W-039 moves.

### The lock
12. **The idle dial does nothing until leaving stops locking.** Under Castle every leaving locks and clears `leftAt`, so `locksOnReturn` can never fire (D-24, `MobileRelock.swift:126-145`; E§0 item 5). W-187 before (or with) W-188.
13. **No copy may promise a device-lock behaviour before the probe.** The public signals are unproven on a device (D§2.5). W-190 before the LP-2 wording.
14. **The quick note's stale session is independent of the grace window.** Even with a window, Lock Now and a lapsed window still relock, and the box stays bound to the old session (F§12.1). W-028 doesn't wait for W-187.
15. **"Lock" is about to mean three things on the phone.** The note's seal is "Lock Note", takes lock, and Lock Library Now arrives (C·N5). Settle NT-4 before W-189's copy.

### Capture
16. **The capture rebuild comes before its riders.** W-025, W-026 and W-027 all act at the filing that W-022 rebuilds (A·G2–G6; E·PL-27, PL-32). W-162 lands on the same hand-off.
17. **The words band sits above the quick entry.** D-07 places it there; W-194 follows SW-3 and W-023.

### The note
18. **Return before its switch.** W-126 follows NT-1 and W-125; W-127 does not wait (C·E6: "the repair a phone user most needs today").
19. **Search landing needs a find face.** A block hit lands "in Write at the block, match selected, find armed" (A·C7); W-064 follows W-132's find half and shares `LandingTarget` with W-090 (E·PL-19c).
20. **The restore insurance can land in today's history.** W-181 is a one-call wiring in `MobileBlockHistory.swift:483` (C·H4); it doesn't wait for W-183.
21. **Compare comes after v1** by her word; W-177 shares the LineDiff hoist with W-186.

### Books
22. **The Bookcase before what lives on it.** W-069, W-121 and the shelf half of W-072 follow W-067.
23. **The settings pane before its rows.** W-097, W-098, W-099, W-112, W-113 and W-100 are rows of W-096.
24. **The membership choice sheet before ownership.** W-113 and W-102 use W-108's copy-or-move grammar.
25. **Arrivals before its arms.** W-102, W-103 and W-104 follow W-101. **W-105 does not** — it needs only the Mac's `BookStateCopy` finish words (B·G8).
26. **One book menu before the acts that live in it.** W-093, W-094, W-116 and W-118 are entries in W-070's table (B·A15).
27. **Multi-select once.** W-055, W-103 and W-111 reuse the selection grammar W-049 designs (VM-31 "a design call first"; B·G6).

### Sync and the device
28. **A current phone build before anything that needs her phone to sync.** Main is at sync marker 15 (`Sources/VariorumCore/Sync/SyncSchema.swift:170`); her phone build is probably marker 14 (E§0 item 1, INFERRED). W-209 comes before W-238 on her real store, W-260, W-210 (VX-672 is "blocked on VM-32") and any acceptance that needs sync.
29. **Measure before choosing among the lag fixes.** Every lag mechanism is traced in code, but the sizes are suspected (F§10), and the perf walk never runs the observation, the shell, the push or the keyboard (F§9). W-238 (and W-254 for repeatable numbers) comes before ranking W-241, W-242, W-243, W-247, W-244, W-245, W-248 and W-251. W-239, W-240, W-250 and W-249 are traced as P1 shapes and don't need the trace to be designed.
30. **The edit-trace experiment retires at the device queue's close** (VM-13c): W-214 after W-260.

---

## 2. Shared code several rows wait on

The hoists (brains in Mac-app code that must move to `Shared/` first, MobileSoul §3), and what waits on each.

| Hoist (where it lives today) | Rows waiting on it |
|---|---|
| The status seam: `AppSession.status` / StatusCenter (macOS-only, `Shared/AppSession.swift:693-853`) | W-012, then W-016, W-019, W-129, W-027, W-149 |
| Wing brains: WingsModel, WingSwitcherBrain, WingFollow, WingDestinationSheet, WingNoteDoors (`App/Variorum/Variorum/Core/Views/`) | W-017, W-018, W-020, W-019, W-036 (one hoist row: W-016) |
| Card composition: LibraryCardName, LibraryCardRead, SidebarRowLeads; NoteCards.load is Mac-local and not flat (rewrite as W-038) | W-040, W-079, W-054, W-045 (TagChips.load) |
| Search model: LibrarySearchQuestion, LibrarySearchModel | W-059 and every search row after it (one hoist row: W-060) |
| Theme: ThemeStore (#199) | W-005 (with #195 MINOR 3's unsynchronised `MobileEditorStyle.voice`) |
| The book row table and state doors: BookRowMenu, BookStateDoorSet, BookArchiveDoorSet, BookStateCopy (incl. `deleteVerb`, `finish`, `waitingLine`) | W-070, W-073, W-105, W-112, W-113, W-115, W-116, W-093, W-094, W-118 |
| Book settings: BookSettingsModel/Face, CollectingCopy, OutflowChooser, HideOwnedChoice | W-096, W-097, W-098 |
| Ownership words: MembershipChoiceCopy, OwnershipBadgeCopy/Face, DuplicateBookCopy | W-108, W-102, W-114, W-118 |
| Arrivals: ArrivalsCopy, ArrivalsReviewCopy, ArrivalsBulk, BookArrivalsModel, ArchivedLineCopy | W-101, W-103, W-104 |
| Rules: RuleEditorModel, RuleEditorCopy | W-074 |
| Journal words: JournalBooks.shelvingNote, comesBackReceipt, JournalWaitingCopy, BookStructureModel's journal mint | W-107, W-085 (the phone's forked copy is already stale) |
| Book faces: BookEmptyState, GatheringNoteDoor, BindCopy, spawnBook, postDropPlan, BookPanelModel | W-080, W-087, W-093, W-094, W-077, W-089, W-088 |
| Editor words and gates: CrossBlockEditCopy, SegmentationFaceCopy, FindReplaceGate (#199), TitleQuickfill, SpellcheckLevel | W-129, W-126, W-132, W-152, W-131 |
| Takes and history: TakeClipboard (#199), LineDiff, CommitsFaceModel/Copy, LineageFaceModel/Copy, TrayFilter, CommentComposition | W-175, W-177, W-183, W-184, W-171, W-168 |
| Compare: PostAlignment, CompareComposition, LineDiff, VersionCompareDoor | W-186 (after v1) |
| Note acts: NoteDuplicate / DuplicateCopy, the NoteExport act, CopyForAI, the Mac's note-row table | W-047, W-233, W-156, W-048 |
| Onboarding: BirthFurnitureSeeders, the readme, TourEngine / TourScript, the What's New notes | W-223, W-222, W-226 |
| The phone's own forks to retire into shared brains: carry-all merge (FannedDefaults), the callout palette's hex table, MobileTakeStructureCopy, MobileBlockSelectionCopy | W-139 |

Brains already shared and simply unused on the phone (no hoist, just a face): BookcaseBoard, TypedReturn, SeamCarvePlan, PlainPaste, CaptureMicrosyntax, SearchLanding, LandingTarget, WordsBand, PassphraseReminderModel, RoadCrossingsModel (idle dial, Lock Now), PlaintextExportModel, SeededBookRestore, StarredGatheringSeeder, SampleLibraryWelcome, CommentDraftPark, RecoveryActs (multi-select, the empty-block sweep), RecoveryCopy (book rows), PaletteDerivation.

---

## 3. Items that should not wait for a redesign

Data loss, sync breaks, security exposure, or acts that make judgments she never saw. Her standing word for this
planning effort is "we shouldn't start writing code (unless you can't run the app because something is broken …)",
so these are first in line once code is allowed — not a licence to start now.

| Row | Why it can't wait | Evidence |
|---|---|---|
| W-209 A current build on her phone (sync marker 15), then VM-32's round | Her phone is probably not syncing at all (marker 14 against a marker-15 mirror). Installing a build is not writing code, and it may be her "can't run the app" exception — PD-3. | E§0 item 1 (INFERRED); `SyncSchema.swift:170` = 15 |
| W-124 Keystrokes during a divide or merge can corrupt the store | A keystroke or autocorrect during a divide or merge can corrupt the store (measured at the VM-5 stability pass). | C·E10; E·VM-2 |
| W-181 Restores insure the words they replace | Her ruling (#274) is unwired: a restore replaces words with no savepoint of them. | C·H4; E·VM-43 |
| W-105 Finish dismisses waiting arrivals without asking | Finish on the phone dismisses every waiting arrival unseen — permanent judgments she never saw. | B·G8 |
| W-035 Wing-blind pickers mint twin tags, dead rule terms and refused book offers | Tapping a suggested tag mints a twin tag in another wing; the gathering picker writes dead rule terms — both into her real store today. | A·D11; B·B5 |
| W-145 The undo door mis-speaks and its Redo can act on a different entry | Redo can act on a different entry than the one named (Urgent on Linear). | C·B18; E·VM-16 |
| W-028 After a Castle re-lock the quick note writes through a stale session | After a relock the box mints and registers undo through a dead session (mechanism traced, consequence not run). | F§12.1 |
| W-203 Keep the store and key file out of the iPhone's device backup | A sibling phone's store and key file ride the iOS device backup, Apple-openable. | D·D-29; E·VM-15 |
| W-193 The creation words card may show in the app switcher | The twelve words may appear in the app-switcher snapshot (INFERRED). | D·D-06 |
| W-022 The quick-entry box holds many paragraphs and never loses prose | Her lost-prose report — but it needs SW-4 first. | E·PL-27 |
| W-165 Closing the comments sheet keeps a half-typed comment | A half-typed comment is lost on close — but it needs NT-11 first. | C·C2; E·VM-18 |
| W-218 The tutorial teaches the retired divide default | Teaches a default the phone no longer has (her flagged beta risk). | E·VM-3 |
| W-037 The Library pages instead of silently stopping at 200 notes | Not data loss, but notes past the 200 newest are unreachable except by title search. | A·B1; F§12.3 |

---

## 4. Seams that need special handling

From CLAUDE.md: at most one `Sync/`-or-custody effort at a time; a Fable cold review for any `Sync/` or editor-seam diff.

- **`Sources/VariorumCore/Sync/`:** W-250 (PurgeJanitor), W-210 (VX-672). Likely also W-253 (VX-497) and possibly W-246 if its fix lands in the sync bookkeeping rather than the query (both INFERRED — the readers didn't place the fix). W-239 runs in the services' sync start; if its fix needs an index, that is a schema change (its own commit; SyncSpec §12 decides whether it's a lockstep event).
- **Custody and the lock:** W-187, W-188, W-189, W-191, W-192, W-193, W-194, W-197, W-195, W-196, W-198, W-203, W-207, W-206. These can't run beside a `Sync/` effort.
- **The editor seam (the phone's `MobileEditorTextView`, `MobileEditorViewModel`, `Shared/EditorBrain`):** W-124, W-125, W-126, W-128, W-130, W-131, W-132, W-244, W-245, W-243, W-247, W-248, W-162, W-161, W-173, W-164, W-163.
- **Shared with the Mac:** every row touching `Shared/Theme/` (W-001, W-004, W-005) and every hoist in §2 changes code the Mac compiles; they collide with any Mac effort in the same files.

---

## 5. Natural clusters — rows that touch the same files and would collide if run in parallel

| Cluster | Files (phone paths under `App/Variorum/VariorumMobile/Features/` unless noted) | Rows |
|---|---|---|
| Shared look | `Shared/Theme/VoiceTokens.swift`, `Shared/Theme/SharedPageStyle.swift`, `Write/MobileEditorStyle.swift`, `VariorumMobile/Theme/MobileVoicePreference.swift` | W-001, W-002, W-003, W-004, W-005, W-006 |
| Shell and navigation | `Shell/MobileShellView.swift`, `Shell/MobileShellBand.swift`, `Shell/MobileShellRouter.swift`, `VariorumMobile/VariorumMobileApp.swift` | W-007, W-018, W-017, W-008, W-009, W-187, W-191, W-192, W-193, W-251, W-088 |
| Wing plumbing | `Shared/WingState.swift`, `Shared/AppBootstrap.swift`, every listing's call site | W-015, W-033, W-034, W-035, W-229, W-054, W-067, W-059 |
| Home screen and capture | `Shell/MobileShelfView.swift`, `Shell/MobileShelfLayout.swift`, `Shell/MobileQuickNote.swift`, `Shell/MobileShelfFaces.swift`, `Shell/MobileShelfViewModel.swift`, `Shell/MobileTodayDoor.swift` | W-022, W-023, W-024, W-025, W-026, W-027, W-028, W-242, W-241, W-067, W-068, W-071, W-070, W-194, W-107, W-119, W-073 |
| The Library | `Shell/MobileLibraryView.swift`, `Shell/MobileLibraryViewModel.swift`, `Shell/MobileListingFilters.swift`, `Shell/MobileScraps.swift`, `Shell/MobileStarredView.swift`, `Shell/MobileStars.swift`, `Shell/MobileArchive*.swift`, `Shell/MobileTrash*.swift` | W-037, W-240, W-040, W-041, W-042, W-043, W-044, W-045, W-048, W-049, W-050, W-051, W-052, W-053, W-054, W-055, W-056, W-057, W-117, W-059 |
| Core listing reads | `Sources/VariorumCore/Queries/Timeline.swift`, `ShelfQueries.swift`, `PostRender.swift`, `Observations.swift`, `LibraryPaging.swift` | W-037, W-240, W-038, W-060 |
| The editor seam | `Write/MobileEditorViewModel.swift`, `Write/MobileEditorTextView.swift`, `Write/MobileStructural.swift`, `Shared/EditorBrain/` | the editor-seam list in §4, plus W-127, W-129, W-133, W-140, W-141 |
| The note's masthead and sheets | `Write/MobileWriteView.swift`, `Write/MobileNoteActions.swift`, `Write/MobileChipFlow.swift`, `Write/MobileNoteTags.swift`, `Write/MobileMembership.swift`, `Write/MobileReferences.swift`, `Write/MobileBlockList.swift`, `Write/MobileNoteTray.swift`, `Write/MobileNoteClipboard.swift` | W-149, W-150, W-151, W-152, W-153, W-154, W-155, W-157, W-158, W-058, W-232, W-156, W-046, W-047, W-036, W-144, W-171, W-035, W-108, W-109, W-110, W-092, W-159, W-160 |
| Keyboard bar and block menu | `Write/MobileKeyboardBar.swift`, `Write/MobileBlockMenu.swift`, `Takes/MobileEditMenuSeam.swift` | W-134, W-135, W-136, W-137, W-138, W-180, W-142, W-125 (the in-block newline door) |
| Takes and history overlays | `Takes/MobileTakesBrowser*.swift`, `Takes/MobileTakesChrome.swift`, `Takes/MobileBlockHistory*.swift`, `Write/MobileUndoDoor.swift` | W-148, W-174, W-175, W-176, W-177, W-178, W-179, W-180, W-181, W-182, W-183, W-184, W-185, W-145, W-146, W-147, W-172, W-245 |
| Comments and callouts | `Write/MobileComments.swift`, `Write/MobileCommentsSheetView.swift`, `Write/MobileBlockDecor.swift`, `Write/MobileCallout.swift` | W-165, W-166, W-167, W-168, W-169, W-170, W-139 (callout palette), W-172 |
| Books | `Shell/MobileBookView.swift`, `Shell/MobileBookViewModel.swift`, `Shell/MobileBookDetails.swift`, `Shell/MobileCreateBook.swift` (and `Write/MobileMembership.swift`) | every Books row; W-074 and W-035 share `MobileCreateBook.swift` |
| Protection | `Protection/MobileRelock.swift`, `Protection/MobileProtection*.swift`, `Protection/MobileRoadFaces.swift`, `Shared/Protection/` | every Castle & sync row except W-209, W-210, W-205 |
| Settings and tags | `Shell/MobileSettingsView.swift`, `Shell/MobileTagManager.swift` | W-211, W-212, W-213, W-214, W-215, W-216, W-217, W-219, W-224, W-226, W-229, W-230, W-231, W-202 |
| Onboarding seeders | `Shell/MobileFirstWriteFurniture.swift`, `Tutorial/MobileTutorialSeeder.swift`, `Shell/MobileStarterJournal.swift`, `Shell/MobileEmptyStore.swift` | W-218, W-220, W-221, W-223, W-225, W-123, W-121, W-228, W-222 |
| Project and assets | `Variorum.xcodeproj/project.pbxproj`, `VariorumMobile/Assets.xcassets`, a new privacy manifest | W-030, W-031, W-255, W-256, W-257 |
| Every screen at once | `Shared/AppSession.swift` (status), `Shared/OpsRefusalTable.swift`, every view's own error and receipt lines (69 raw-dump sites) | W-012, W-013 — these touch nearly every file above, so they collide with every other cluster |
| Core performance | `Sources/VariorumCore/Operations/OwnerIdentity.swift`, `Sources/VariorumCore/Sync/PurgeJanitor.swift`, `Shared/AppServices.swift`, `Shared/SyncSession.swift`, `Sources/VariorumCore/Queries/TakesQueries.swift` | W-239, W-250, W-246, W-244, W-253, W-210 |

Three overlaps worth naming:
- **The home screen is the most crowded file set.** Capture, the Bookcase, the words band, two of her lag fixes and the Today door all live in `Shell/MobileShelf*` and `MobileQuickNote.swift`, and SW-3 decides their shared layout.
- **The wing plumbing touches every listing.** Scoping the reads edits the Library, Shelf, Starred, Trash, Archive, tag manager and membership call sites — the same files the Library, Books and Settings clusters edit.
- **`MobileShellView.swift` is shared by navigation and the lock.** The tab bar, the wing swipe, the relock landing and the snapshot cover all edit it, and the lock rows also need the one custody slot.

---

## 6. Prerequisites of the HIGH rows

The work list marks HIGH only on rows that directly deliver what she named. These unmarked rows sit in front of them:

| HIGH row | Unmarked prerequisites |
|---|---|
| W-017, W-018 | W-012, W-016 |
| W-040 Library rows show first words and a preview, like Apple Notes | W-038, W-039 (and W-037, itself HIGH) |
| W-079 Untitled entries in a book read as the same raw date twice | W-039 |
| W-059 Body-text search over the index the phone already keeps | W-060 |
| W-023 The quick-entry box's face: typed text at body size, a visible edge, copy that fits | W-024 |
| W-188 The idle-lock dial on "On this iPhone" | W-187 (itself HIGH) |
| W-007, W-149, W-135 | W-001, W-002 (HIGH), W-003 |
| W-238 The device performance session on her phone | W-209 |
| W-242 Tapping into the box re-lays out all three pages | W-024 |
