# VX-440 — ladder round 1 (cold review, Fable, 2026-10-28)

Diff reviewed: `origin/main...HEAD` on `vx-440-sheets-history-clarity` (tip `e2e8e9dca`), 70 files,
~5,500 insertions. Anchor: `notes/plans/fixes/vx-440-sheets-history-clarity.md` (no "Review foci"
section exists; the three per-batch "For the reviewer" concern lists were each checked explicitly —
dispositions in the clean bill). Canon read: CLAUDE.md + auto-loaded set, MCPSpec IN FULL,
SurfaceContracts in full, TEXTKIT2_NOTES §0–3, the relevant AppSpec §7/§9 operations.
Headless verification run in this session: core `swift test` FULL — VariorumCoreTests **3500/467
PASSED (5 known issues)**, StringsWorkbook 32/4 PASSED, VariorumMCPTests 431/79 with the ONE standing
load flake (`MCPHarnessTimeLimitTests.aPeerThatNeverAnswersInitializeFailsTheConnectNamedAndBounded`,
24 s vs its 15-s bound under full-run load; re-run alone 3/3 in 2.2 s — no MCP-target code in this
diff), matching the record byte-for-period; targeted run of the five new/edited core suites
(VersionsInCompareTests · BringBackCommitAsTakeTests · RestoreCostTests · TrashAndArchiveTests ·
MCPShareTests) 61/61 green; `xcodebuild build-for-testing` (vx440-b3 DerivedData) **TEST BUILD
SUCCEEDED** at the tip. Mac-suite RUNS and the four red-on-old Mac runs remain PENDING the stage
window (the record's run lists are correctly specified: suite TYPE names, expected counts, the
red-on-old SHAs `34c21e938` · `c9d0b3c66` · `7715a4a3d` · `0d963ce22`).

## Findings

- **[MINOR] · Sources/VariorumCore/Queries/NoteVersions.swift:307 (`observeLatestNoteVersion`) +
  Features/Takes/PostDetailView.swift:661 · the classifier's automatic-index cost is now paid at
  autosave cadence, not per summons · mechanism: every autosave coalesce writes the owning
  `container` row (`registerTextChange` — `last_touched_at`), the held observation's region includes
  `container`, so `noteVersionStamps` re-executes per coalesce while a note's detail is mounted; for
  a note that HAS a version candidate, the classifier's EXISTS makes SQLite build its automatic
  partial index over the library's `version_of` edges once per execution (the record's own B1-2 cost
  note) — work ∝ the library's version links, at typing cadence, where every prior
  `versionHistoryPredicate` consumer was a summoned pane. Not a wrong output (no pin possible);
  an architectural/P1-pressure finding with the degradation traced. The record names it "a closeout
  ticket candidate" but FOR THE CLOSEOUT does not carry it · fix: mint the ticket at closeout
  (Performance · Debt — e.g. a real partial index `edge(type) WHERE type='version_of'`, or anchoring
  the classifier's EXISTS on the indexed edge legs), and add the line to the closeout's owed list so
  it cannot evaporate. No code change required this round.

- **[MINOR] · App/Variorum/Variorum/Features/BookView/BookView.swift:2937 (`NavigatorChapterLabel`)
  · the book NAVIGATOR's collapsed one-note chapter row keeps VX-356's exact Study gap · mechanism
  (traced in code this session): `noteMarked` renders only `if noteMarked,
  !tokens.selectionMarker.isEmpty { NavigatorMarker(…) }` — Study's marker is empty by design, and a
  chapter row's name is always semibold + ink-rule, so outside Outline's viewed wash the open/focused
  note's collapsed chapter row is pixel-identical to every other in Study: the same defect class the
  run just confirmed REAL and fixed on the Book Panel (B3-6/7) · the run's own record names it a
  ticket candidate (batch 3 concern 5) · fix: mint the ticket at closeout (Books · Improvement ·
  Confirmed by trace); it is red-on-old pinnable exactly as `BookPanelOpenNoteMarkTests` pins the
  panel. Deliberately NOT a this-round fix (one surface per the record; her P-440-12 face is still
  provisional).

- **[MINOR] · guide content (TutorialSeeder's MCP lesson 5 card) · the card is now incomplete for
  gatherings · mechanism: VX-189 drew "Share with AI…" on a gathering's row and Book Settings, so the
  card's "Right-click a note in the Library, or a book on the Bookcase or in the Library, and choose
  Share with AI…" is true but no longer the whole truth · the record defers it to VX-648's seam
  (`TutorialSeeder.swift` is that run's file this window) / the VX-234 copy pass — correct call, but
  it must not be dropped · fix: one line in the closeout's owed list naming the card and the owner
  (VX-234 or a VX-648 rider); no code change this round.

- **[NIT] · App/Variorum/Variorum/Features/Tray/BlockHistoryPane.swift (CommitReadingSheet, the
  header's Close) · `Button("Close")` is the one unvoiced chrome word on the new sheet — every
  sibling door on this pane and in the sheet goes through `tokens.chromeLabel` (Terminal's chrome
  casing misses exactly this word) · fix: `Button(tokens.chromeLabel("Close"))`.

- **[NIT] · App/Variorum/Variorum/Features/ReadMode/ReadModeView.swift:1098 (`ReadPageBlock`) ·
  `.help(onOpenInEdit == nil ? "" : "Click to edit…")` leans on AppKit suppressing an empty tooltip ·
  fix preference: apply the help conditionally (or leave — behavior is correct today).

- **[NIT] · App/Variorum/Variorum/Registry/ShellActions.swift (`paletteEntries(listing:noteHasSavedVersion:)`)
  · the `= true` default is permissive: a future caller that forgets the argument lists "Compare with
  Latest Version" for a note with no moment (the press then refuses honestly, so P-2 bends but
  behavior stays honest) · deliberate for pin stability (`WingPaletteDoorsTests` counts) and
  documented; recorded here so the next palette-facts refactor folds the fact into
  `WingPaletteDoors.Facts` instead.

## Hollow / weighed and NOT raised

- **`unmarkPostsAsVersions` keeps the bare-unlink semantics in core** (the record's "a belt the
  ladder may weigh"). Weighed: every reachable door to a saved version's unmark now promotes
  (Compare's card asks) or cannot reach one (the Library's "Unmark Versions with…" picker fences
  `archived_at IS NULL`; the wire has `link_versions` only, and reads refuse version ids; the phone
  has no unmark door). No input → wrong-state road exists, so no red-on-old pin could exist — a core
  refusal would be a belt, and deferring it out of a no-MCP batch (a new `OperationError` case hits
  the wire-refusal sweep) is sound. The deliberate unlink stays pinned
  (`NoteVersionsTests.adeliberateUnmarkStillUnlinksAVersion`).
- **Compare seating a moment of another wing** (13i-d U5's fence vs `noteVersionStamps` having no
  wing fence): traced — versions RIDE every wing move (`Operations+WingMove.swift:155`,
  `Operations+MCPWingMove.swift:142`, the book move's sweep), so a cross-wing moment of a live note
  is not a reachable state; the stamps read matching `noteVersions`' own (also wing-fence-free) shape
  is consistent, and `versionPeerSplit.otherWings` is untouched.
- **The read-in-full sheet lays out a whole moment as ONE `Text`** (batch 2 concern 5): cost is the
  summoned moment's own length, paid once — the same class as Read rendering the block; P1 (corpus /
  document scaling) is untouched. Named, not split.

## Clean bill (checked and found solid)

- **`bringBackCommitAsTake` (the new §9 operation):** mirrors `branchVariant`'s posture exactly as
  claimed — verified side-by-side in `Operations+Variant.swift` (`insertFanVariant`'s check order:
  live block → `ensurePlacementUnlocked` → source `liveVariant` with archived/locked allowed; ONE
  `variant` insert, no touch/churn/undo) — label normalization is byte-identical to
  `setTakeLabelRows`' (`StoredText.stripped` + trim + empty→nil), fan-end via `newBlankVariant`'s own
  `MAX(fan_position)` road, one transaction, S1-shaped (one row; the standing outbox trigger
  captures), I5/I10 untouched; 9 state-transition pins ran green, refusal pins exact
  (`commitNotFound`/`variantNotFound`/`blockNotFound`/`lockedPost`). The op is reachable only from
  live takes' commit rows (regions 2–4 wire no read-in-full), so the unplaced-lineage-block arm
  matches `branchVariant`'s own posture and is unreachable from the UI. AppSpec §9's owed line is
  drafted in FOR THE CLOSEOUT.
- **`noteVersionStamps` ≡ `noteVersions` (the one classifier):** the candidate UNION (note's
  placements past tombstones, both edge arms unfenced, version-side placement live) can only narrow,
  and the classifier decides every candidate; equivalence pinned across merge/archiveBlock/
  deleteBlock/unmark/promote/Trash (`theStampsFollowTheListingAcrossTheAnchorsShapes`, ran green),
  with an EXPLAIN-plan pin for the note-driven cost (`SEARCH theirs USING INDEX idx_cblock_order`,
  edge index seeks, no SCAN).
- **VX-437:** the declassify leak's trace is real and the pin is correctly shaped (RED on old: the
  bare unlink lands → the moment leaves Versions and rows onto Archived; GREEN on new: the press arms
  the P-440-5 confirm and writes nothing); promote-on-confirm runs the standing `promoteNoteVersion`
  through `VersionActs.promote` (receipt/refusals in the family's words); the ordinary peer's unmark
  is byte-unchanged and pinned.
- **VX-331:** `restoreCost`'s population-2 window is exactly `deletedTakes`' (`deleted_at >= cutoff`,
  same purge fence, same `>=` edge — `TrashWindow.cutoffStamp`); `now` REQUIRED and plumbed from
  `session.now`; the red-on-old pin ran RED headless at `c42ab4b84` and GREEN at the fix per the
  record, and the whole suite ran green here including the boundary (`>=`) leg.
- **VX-244:** both arms traced apart and real (the article's `"takes-main"` column id never in
  `columns` → `pick`'s silent first guard; Lenses' `.main` → J38 refusal); the fix is the switcher's
  own rule (`column.kind != .main`) at the one menu-build site; `pick`'s `.main` refusal arm
  untouched and still driven by its standing pin; 3 pins with an acting scratch-column control.
- **The restore landing (batch 2.4):** NO editor-seam file touched (`EditorTextView` /
  `BlockRangeIndex` / `PaneTextAuthority` unchanged — verified against the diff stat); the wash rides
  the existing decor overlay (`arrivalFlashSink` — an overlay, never a rendering attribute, per
  TEXTKIT2 §3's guidance); first line only, measured at the settle hop inside the viewport;
  `RestoreLanding` is a value on the router (`CompareLanding`'s precedent, P-4: a signal heard on
  CHANGE only, inert unconsumed, cleared with its detail — pinned); the DETAIL-editor-only claim
  holds STRUCTURALLY (`attach(textView:scrollView:)` — inline book/pool editors attach with
  `scrollView: nil`; `consumeRestoreLanding` guards `scrollView != nil`); Takes lands only on the
  board (`host == .takes, landingEnabled`), after `noteProjectionArrived`, only once the slot shows
  the restored words and only on the chosen take; patience/typing/wrong-take drops verified in code;
  the `.restore` flash bypassing the mode-switch setting is PROVISIONAL P-440-8 with her options
  recorded.
- **Block History clarity:** her ruled structure intact (four regions, every take sectioned, Restore
  per row at the line's end, no purge door, the history button unmoved — the tester's move stays
  DECLINED); the sheet is one read-cheap selectable `Text`, never an editor; the pre-split warning
  asked inside the sheet (an alert cannot present over it); both foot doors dismiss first;
  `expandedPreview` keeps paragraphs, drops leading blanks, appends no ellipsis (pinned, the VX-144
  lesson); the two `CommitsPageLedgerTests` edits are justified and documented, VX-144's surviving
  clauses named.
- **VX-611:** one rule (`BookStateCopy.deleteVerb(_:)` / `deleteDoorLabel`), all four renderers +
  the rule editor's gate hover through it, with a source-reflection guard pin so no renderer can
  re-glue the registry's verb; the registry's ONE declared verb kept (P-1, the
  `CollectingCopy.openVerb` precedent); the Trash's row-scoped sentences all through
  `RecoveryCopy.rowKind(_:isGathering:)` with defaulted parameters keeping every shipped caller and
  the phone byte-identical; `TrashItem.isGathering` read from the same statement (no second read);
  the kind FILTER and Empty Trash counts deliberately unchanged (P-440-13 records the options).
- **VX-616:** the foot is data (`BookFootDoors.gathering()` = `[.newNote]`, pinned); books'
  foot byte-unchanged; "Bind into a Book…" and the hand-drag teaching offer untouched; B3-4 (the
  unreachable `.createChapter` follow-up retired whole) verified reachable-by-no-road — its own
  commit, revertible alone; the bind's own words byte-kept and pinned
  (`theBindWordsSayTheTruthAtEveryCount`); the registry walk untouched (comment-only edit); the
  tutorial's chapter sentences are about books (P-6 checked).
- **VX-189:** faces only, verified — no wire tool, no grant-semantics change (`insertMCPGrant`'s
  gathering arm reads the unchanged `mcpGatheringFacts`), no new reach; `mcpFencedBookIDs` is now the
  exact complement of `mcpGrantableBooksSQL` ∪ `mcpGrantableGatherings` on the SAME two fence
  fragments (verified in SQL: `(daily OR private)` vs `NOT daily AND NOT private`), red-on-old pin
  ran red/green headless; `MCPGrantPrefill.reading(_:)` is the ONE kind switch so a gathering's door
  can never open a book's place; the row caption keeps settings-class words (no "AI", pinned);
  Change…/Revoke untouched (the pane's and popover's, VX-549's); Private/Seal/Own untouched; the
  MCPSpec delta superseding P-VX185-2/MB-18 is drafted in the record for the closeout, with her
  verbatim 2026-10-28 word. The three `MCPShareFacesTests` flips are marked DELIBERATE in place.
- **VX-356:** the trace is honest (the panel's own doc premise — weight and ink say it — has nothing
  to give on a chapter row, so defect not design); the fix is token-only, an overlay inside the row's
  frame (no geometry moved), Terminal byte-unchanged; the brain's rule is pure and pinned with a
  mounted probe (both legs red-on-old on Study).
- **The versions/Compare design (batch 1):** `.noteVersion` is its own destination so R-440-2's
  clauses hold structurally (no detail registers → no "this note" rail, ⌘⇧S greys/speaks, no Open-list
  row, no per-note memory — `rowMoved` writes only local geometry; `pageTarget` never set); every
  shell arm covered (RootView listener + detail arm, WorkspaceModel title/`notesDeleted` incl. a
  version pane leaving with its note, WorkspaceNaming, StarTargeting nil, TourPlaces `.elsewhere`,
  `selectionKey` is a task-id only, never persisted/parsed); the one-press door's fact is
  router-owned, note-scoped, cleared on register/unregister, re-read AT THE PRESS with an honest
  refusal on the race; File greys / `note ▾` hides / ⌘K drops — three doors, one act
  (`VersionCompareDoor`), declared once in the registry with ONE justified walk-context edit;
  moments order after ordinary peers (P-440-2, pinned), columns date-named by derivation (V6, no
  title write), arrive sealed → read-only; versions ride wing moves so no cross-wing seat; the
  promote confirm is ONE copy shared by Compare's unmark and the band (P-440-5, pinned).
- **Record discipline:** every pin named in the unit records exists with the exact claimed test
  count (CompareVersionsTests 6 · VersionDoorsTests 11 · ShowTakeDoorTests 3 ·
  BlockHistoryClarityTests 6 · RestoreLandingTests 6 · GatheringKindWordTests 5 ·
  BookPanelOpenNoteMarkTests 2 · VersionsInCompareTests 4 · BringBackCommitAsTakeTests 9); the three
  full-suite verification claims reproduce exactly; the in-flight row, the VX-648 serialization
  clause, and the canon-owed drafts are in place. Commits are clean of trailers and per-piece.
- **Caveats outside my reach this round (the orchestrator's stage window):** all Mac-suite runs, the
  four Mac red-on-old runs, the walk rows, both voices' faces, the VX-356 fill's contrast on the
  panel surface, and the iOS compile of the shared files (`VersionsCopy` / `VersionActs` /
  `RecoveryCopy` / `RecoveryActs` / core `TrashItem` — all additive or defaulted, source-compatible
  by inspection).

**Verdict: no BLOCKER, no MAJOR. Three MINOR (all dispositions, no code change required this
round: two closeout tickets + one owed copy line), three NITs (one one-line voice fix worth taking
with any round-2 work).**
