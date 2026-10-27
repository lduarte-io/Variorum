# VX-439 — ladder round 1 (cold review, `opus-reviewer`)

**Diff under review:** `git diff dd469951e..HEAD` in `~/dev/variorum-vx-439` (branch `vx-439-run-sidebar-bar-export-quick-wins`, tip `8261e96a6`).
**Anchor:** `notes/plans/fixes/vx-439-sidebar-bar-export-quick-wins.md` (the run record + its Review foci).
**Status:** COMPLETE — 3 MAJOR · 7 MINOR (one SPECULATIVE) · 5 NIT. No BLOCKER.

## Scope note (said first, per the reviewer brief)

The diff touches the editor-seam FILES, narrowly: `Features/Editor/EditorTextView.swift` gains an
`isFindBarVisible` override on `TypewriterScrollView` (the live editor's own scroll view, +15 lines), and the live
editor's selection delegate (`EditorView.swift:880`, `textViewDidChangeSelection`) gains a tail call to
`EditorViewModel.refreshFindReadout()`, which reads `textView.string` and the selection on every selection change. No
text-storage, layout or identity code changed. Her kickoff word chose the Opus reviewer ("no editor seam — the takes
cluster moved to VX-601"); whether this narrow touch re-spawns the round as `fable-reviewer` is the orchestrator's
call. I checked the one hazard that touch could carry (a per-keystroke whole-document read): `textView.string` on a
TK2 `NSTextView` measured O(1) and forces no copy on the next edit (scratch harness: 0.17 µs per read at 1M chars;
interleaved read+edit 458 µs vs 459 µs without the read) — so no finding sits on the per-keystroke path. Finding m-2
is the per-FIND-STEP cost, which is chrome-side.

## Findings (severity-ranked)

### MAJOR

**M-1 [MAJOR] · `App/Variorum/Variorum/Features/Library/SidebarRowLeads.swift:53` + `SidebarView.swift:440-451` (VX-580) ·
the sidebar's held first-words read re-runs a document-scale query at autosave rate (P1).**
- *Mechanism.* `SidebarView` holds `session.database.observe { SidebarRowLeads.read(db, noteIDs:) }` keyed on the
  Open + starred note rows. `AppDatabase.observe` (`AppDatabase.swift:266`) is `ValueObservation.tracking(fetch)`: it
  tracks everything the fetch reads. The fetch reads `container` (and, for any unnamed row, `NoteCards.load` reads
  `container_block`/`block`/`variant`). AppDatabase's own note at `:272-279` records that "`container` is stamped per
  edit by a full-record update (`registerTextChange`), so any fetch reading it re-runs at autosave rate" — which is why
  the region-named twin `observe(tracking:)` exists (13n-c Stage B R2-1). So every autosave of ANY note (the 500 ms
  debounce while she types) re-runs the read. For each untitled, non-journal listed note — very often the note she is
  typing in — the read is `NoteCards.load`, whose `ROW_NUMBER() OVER (PARTITION BY container_id …) … WHERE n <= 3`
  materializes EVERY block of the note (with `substr` over each block's text) before the outer filter. Measured on a
  replica of the exact statement shape in sqlite3 (scratchpad `nc/`): **3-block note 0.2 ms; 19,997-block note 36 ms** —
  linear in the note's size, at autosave rate, while the sidebar is on screen (always, in Write). P1: "No operation's
  cost may scale with total document or corpus size."
- *Red-on-old pin.* A P1 pin on `SidebarRowLeads.read`: an untitled note of ~20k blocks vs one of 3 blocks — either the
  ratio (old: ~180×; any bounded read is ~1×, so a generous threshold such as < 5× is stable), or, the house precedent,
  a query-plan/statement pin (`db.trace` the statements the read issues; old: a window function over the partition;
  new: a `LIMIT`-stopped scan riding `idx_cblock_order`). Optionally a second pin that the observation is woken by named
  regions rather than every `container` stamp.
- *Fix.* Read each unnamed row's opening through `Queries.leadingBlockTexts(db, containerID:, blocks:
  NoteCards.blockWindow)` — the flat, query-plan-pinned read `TitleQuickfill` already uses (`PostRender.swift:297-330`:
  "0.017 ms at 20,000 blocks … FLAT in the note's length") — and feed `NoteCardFace.card` as now (same brain; check the
  gap/`""` slot semantics agree). Consider `observe(tracking:)` with named regions so a titled sidebar is not re-read
  per keystroke at all.
- *Pre-existing, for a ticket (not this run's to fix):* `NoteCards`' header (`LibraryListingReads.swift:33-37`) claims
  the window function makes "a 10,000-block note cost the same as a three-block one". The measurement above falsifies
  it; the Library pays it one-shot per page (and per keystroke under a day filter, per that file's own "accepted
  ceiling"). `MorningListTests`' block-bound pin is green on both sides of the cost question (it proves the RESULT is
  bounded, not the work). VX-580 is what moved this read onto a held, autosave-rate observation.

**M-2 [MAJOR] · `App/Variorum/Variorum/RootView.swift:283-293`; record C-552-1 / LIVE STATUS VX-552 (VX-552) · the
ticket's "New Note button" carries no wing label; the call's premise is false.**
- *Mechanism.* The ticket is titled "The wing you're in is always visible beside the New Note button". The window
  toolbar HAS a New Note button (`ToolbarItem(placement: .navigation)`, `square.and.pencil` — the very door VX-426 gave
  its first tooltip this run, icon table row 2), visible on every surface, and it mints into the current wing
  (`library.createPost()` → `LibraryViewModel.swift:109` `session.wing.currentID`). C-552-1 / the LIVE STATUS justify
  covering only the quick-entry bars as "the two doors that mint into the current wing; ⌘N is a menu item" — the
  toolbar button is neither, so the premise is falsified and the literal door her ticket names is unlabeled. A-439-6
  itself named "the Bookcase quick-entry band's and/or the toolbar's".
- *Pin.* Design-row class (the walk's capture is the evidence, as the run's own VX-552 row says); a source-read pin
  in `QuickEntryWingLabelTests`' shape that the toolbar's New Note item composes the wing label would be red on old.
- *Fix.* Label the toolbar New Note door with the same `QuickEntryCopy.wingLabel(wings?.currentName ?? WingWords.home)`
  face (muted, `lineLimit(1)`), or — if toolbar room makes that a taste call — put it in her morning bundle as an
  explicit question rather than recording the member DONE on a premise that does not hold.

**M-3 [MAJOR] · `walk-shots-vx439/` (48 files, 11 MB; commits `e8594fec8`, `aed5708c1`) · the walk's captures are
COMMITTED and pushed, though the record says "gitignored".**
- *Mechanism.* `git ls-files walk-shots-vx439 | wc -l` = 48: 40+ PNGs, two full Debug-app `UserDefaults` dumps
  (`prefs-before.plist`/`prefs-after.plist`, ~289 KB each — hundreds of per-note keys of the dev store), and exported
  dev-store note files. `.gitignore`'s pattern is `.walkshots-*/` (line 85), which `walk-shots-vx439/` does not match.
  CLAUDE.md's environment traps: "screenshots in gitignored dirs". Because merges are merge-commits only and history is
  never rewritten without her word, a plain `git rm` before the PR still carries all 11 MB into `main`'s history via the
  branch's commits — permanently.
- *Pin.* Not a code bug (no red-on-old); a repo-state check (`git ls-files walk-shots-vx439` empty) is the evidence.
- *Fix.* Her call before the merge (history rewrites are author-only): either authorize rewriting the branch to drop the
  two commits' binary payload, or accept it; in both cases `git rm -r --cached walk-shots-vx439`, add `walk-shots-*/` to
  `.gitignore`, and correct the record's two "gitignored" sentences.

### MINOR

**m-1 [MINOR] · `App/Variorum/Variorum/Workspace/BrowserNavKeys.swift:107-110` + `Core/Views/PageTurnKeys.swift:56-59` +
`Features/References/ReferencePanel.swift:242-251` (VX-560, review focus 5) · ⌘←/⌘→ are taken from text inputs
inside the reference panel's web pane.**
- *Mechanism.* The window-wide monitor consumes ⌘← whenever `PageTurnKeys.textIsFirstResponder` is false — i.e. the
  first responder is not an `NSText` or `NSTextField`. The reference panel's URL pane is a plain, fully interactive
  `WKWebView()` in the same window. Click into a text input on the referenced page (a search box) → the window's first
  responder is the `WKWebView` (neither `NSText` nor `NSTextField`) → ⌘← (her line-start key, which WebKit would honour
  in the input) is consumed and `RootView.navigate(.back)` moves the PANE back, off her note. Her scope call was
  "outside a text view only".
- *Red-on-old pin.* A window holding a `WKWebView` loaded with `<input autofocus>` made first responder: send ⌘← via
  `NSApp.sendEvent` (the suite's own road) → expect no `direction` delivered. Old: `.back` delivered.
- *Fix.* Treat a `WKWebView` first responder (and, more generally, any responder that takes text input — check
  `NSTextInputClient` conformance) as "text holds the keyboard" for VX-560's monitor. (The page-turn monitor has the same
  blind spot but only while `read ▸ pages` is up; its fix can ride the same helper.)

**m-2 [MINOR] · `Features/Editor/FindReadout.swift:103-116`, `EditorViewModel.swift:431-443` (VX-441) · a whole-note
re-scan on the main thread at every find step; the record's P1 justification is false.**
- *Mechanism.* Each ⌘G selects the next match → `textViewDidChangeSelection` → `FindReadout.face` passes its gates →
  `ranges(of:in:)` walks the whole note. Measured (scratch harness, the same loop and options): **0.3 ms at 10k words,
  2.6 ms at 100k words** (linear; ~25 ms at 1M), on main, per step. The record and the file header say this is fine
  because "a find step — itself a whole-note walk"; it is not — `NSTextFinder`'s find-next searches forward from the
  selection to the NEXT match (O(gap)), so the readout adds a document-scale cost to a gesture that had none. The COUNT
  needs one O(n) scan per (needle, text) — that part is her ask; repeating it per step is not. Also: with the bar up,
  every non-empty hand selection (each ⇧→) reads the find pasteboard (an IPC round-trip) before the gates can fail.
- *Red-on-old pin.* Pure: a counting seam around the scan — N steps over unchanged text and needle scan once (old: N).
- *Fix.* Cache the match ranges keyed by (needle, options, a text generation — the editor's edit counter or the
  storage's length+change token); a step is then a binary search. Cache the needle on the find pasteboard's
  `changeCount`.

**m-3 [MINOR] · `SidebarView.swift:452-459` + `Core/Views/WingsModel.swift:377-392` (VX-425) · the note rows' wing
read is never re-asked after a move from the row itself.**
- *Mechanism.* `noteRowWingIDs` is a ONE-SHOT read keyed on `noteRowsWingKey` (rows + current wing). `WingNoteDoors`'
  contract says "After an act (the one-shot listings re-ask; held ones need nothing)" via `onDone`; the sidebar passes
  no `onDone` (and `.wingMoveConfirm` none). Move a non-shown Open row's note Home → "Work" from its row: rows and
  current wing are unchanged, so the key is unchanged and the read never re-runs — the same row's Move/Copy to Wing ▸
  now lists "Work" (the note's own wing) and omits Home. The pre-existing wing indicator (`openRowWings`, same key
  shape) goes stale the same way, now reachable from the row.
- *Pin.* A mounted sidebar (the suite's rig) with two wings: move a row's note via the doors' act, then read what the
  row's doors would list (a DEBUG oracle for `fromWing`, or the indicator's oracle) — old: stale.
- *Fix.* Pass `onDone` to both `WingNoteDoors` and `.wingMoveConfirm` that bumps a generation folded into
  `noteRowsWingKey` (and `openWingsKey`), or hold both reads as observations.

**m-4 [MINOR] · run record LIVE STATUS / WALK PART 2 "NOT-REACHED"; `SettingsShapeTests.swift:182`,
`DiagnosticsPaneTests.swift:73` · members carried on pins where the use-shaped evidence is missing (CLAUDE.md sizing:
"a batch closes only on use-shaped evidence, never a pin or mount smoke alone").**
- VX-424: drag delivery to the halves has no synthetic road — her hand check (bundle 11) is the ONLY evidence the fix
  works at all; the member must not close before it.
- VX-589: the live toggle was not reached, and the General cap edit (6 → 7) was justified in both pins' comments by
  "the walk captures the pane" — it did not (`walk-shots-vx439/33-settings-general.png` shows the MCP pane). The fold
  those pins guard is unverified with the seventh row.
- VX-569: the live title click + Tab was not reached (mounted pins only).
- VX-425: the three sidebar-hosted asks (Rename alert, Delete confirm, cross-wing Move confirm) were never pressed live;
  their pins are source-reads (the walk exercised Delete through the note ▾ door, and listed the row menu).
- *Fix.* Walk legs owed at closeout (or named explicitly as hers), and the pins' "the walk captures the pane" comments
  corrected until a capture exists.

**m-5 [MINOR] · `App/Variorum/VariorumTests/NoteExportTests.swift:207-278` (`NoteExportMenuGateTests`, W-439-1) · a
probe suite that has never executed stays live in the tree.**
- *Mechanism.* The record: its one stage run crashed the test host before its first line; it was then EXCLUDED by hand
  from batch 2's 495-suite list; it "stays in the tree, unverified". Nothing marks it — the next full-suite run (any
  later effort's) meets an unannounced, never-green suite whose failure mode is a host crash.
- *Fix.* `@Suite(.disabled("W-439-1 / VX-603 — probe never executed; see the VX-439 record"))` or remove it until
  VX-603 picks it up. (Not a bug pin — hygiene.)

**m-6 [MINOR] · canon (closeout duty) · door names and contract lines this run changed that the plan's owed-edit list
does not name.** The plan names only A-439-7 (VX-332's SurfaceContracts line) and A-439-15 (VX-424's drop sentence).
Also stale after this run: SurfaceContracts §The app "Help ▸ Take the Tour re-enters any time" (now "Take the
Onboarding Tutorial"); MCPSpec's guide line "reaches a library only through Help ▸ Restore Tutorial…" (now "Restore
Field Guide…"); the Keyboard family line (⌘←/⌘→ alternates); the Open list contract (the row menu now carries Rename ·
Move/Copy · Export · Delete — the recorded no-Delete decision reversed at her ask; Starred's note rows the same; the
"Hide starred notes from Open" display filter; the half-row drop); Copy full text's paragraph (Export Note… and the
bulk export's per-note files are now the format's clients too). Fix: add these to the closeout's canon list (contract
lines in place + one pointer each, the two-file rule).

**m-7 [MINOR · SPECULATIVE] · `Features/Library/OpenListDrag.swift` `OpenListRowHalves.body` (`.allowsHitTesting(state.dragging
!= nil)`) (VX-424) · the halves' liveness rests on the session-end delivery alone.** If a drag's `.ended` phase is ever
not delivered (e.g. the source row is removed mid-drag by a close in another window or a sync apply), `dragging` stays
set and every row's halves stay hit-testable — the R-G mechanism the run itself proved (the ✕'s click eaten) — until
the next drag of that list ends. I cannot trace AppKit's session delivery after source removal, hence SPECULATIVE; a
cheap belt is to require the dragged note still be in `rows` (`state.dragging.map(rows.contains) == true`).

### NIT

- **n-1 · `Features/Takes/TitleQuickfill.swift:47-55` (VX-569)** — the offer ignores the journal profile, so an untitled
  ⌘J entry's title field offers its first words, while the sidebar and the Library treat "a daily entry's day [as] its
  identity" (`SidebarRowLeads.swift:48`). Only an offer (Tab required), but one rule in two places; her call.
- **n-2 · `Core/Views/NoteExport.swift:87-91` (VX-125)** — a failed write says "Couldn't write … try another folder" and
  drops the error, so a full disk or a permission refusal is indistinguishable; say the reason (the bulk export's
  `lastError` road does).
- **n-3 · `Features/Library/LibraryCatalogView.swift:1400`** — the Library row keeps Export ▸ "Markdown with Takes…"
  (`exportPost`, no header) beside the sidebar's new Export Note… (header + the same body): two per-note markdown
  exports whose bytes differ by one line. Ruled to stay (A-439-2); worth one line in her bundle.
- **n-4 · run record LIVE STATUS** — "Ladder: NOT-STARTED" is right, but "Walks (orchestrator, per batch): NOT-STARTED"
  is stale (both walks ran), the STATUS banner still reads overnight-open, and batch 2's member lines still say
  "PENDING the stage run" under a header saying VERIFIED.
- **n-5 · `Features/Takes/PostDetailView.swift:868-875` (VX-569)** — the faint words swap from the date to the offer a
  turn after the field opens (the read is async), a one-frame change of the text the 17y B2 (n) "nothing moves" pin
  was about; harmless, but the pin now only covers a wordless note (`MastheadLayoutTests` deliberate edit).

## Review foci — each addressed

1. **VX-126/VX-125 byte-identity, round trip, the format's one home.** Clean. `bulkExportManifest`'s per-note files are
   `variorumDocumentText` (`Export.swift:411`); `Pools/` and `Readings/` keep `exportPost`/`exportReading`.
   `NoteExport.contents` reads the same serializer. `DocumentFormatRoundTripTests.aLibraryExportReimportsEveryNote…`
   proves file == Copy full text, re-import through `VariorumDocumentFolder.note` → `importDocument`, tags/takes/title
   ride, re-export == file bytes; run headless here: **27 tests / 3 suites green** (with `ExportProjectionTests`,
   `Phase13SurfaceQueryTests`). No file under `Domain/` and no import code is in the diff — VX-502's acceptance seam is
   untouched. (Consequence flagged for her already: the insurance export reads the same manifest — bundle 7.)
2. **VX-424 both directions, one boundary one gap, old pins edited not deleted.** Clean. `aDownByOneDropLands`,
   `anUpwardDropLandsOnTheHalfItIsReleasedOn`, `oneBoundarysTwoHalvesDrawOneLine` + the door's two; `gap(.after(i)) = i+1`
   makes row k's lower and row k+1's upper name gap k+1, and `lineTop` is gap-based, so the line cannot move crossing
   a boundary. The four old subject pins are renamed and restated with "VX-424 — edited in place" annotations; none
   removed (diff of `@Test` lines). Delivery evidence: see m-4.
3. **Registry discipline (P-1/P-2).** New acts declared once — `.exportNote` (menuBar · palette · bottomBar ·
   contextMenu), `.newNoteInBook` (menuBar · palette · surface), `.renameNote` (contextMenu) — and every new renderer
   reads the registry verb; the walk's union and R118 exemption edits are annotated. Mint refusals are the operations
   layer's (`NewNoteInBookTests.onAFinishedBookTheKeyRefusesInTheOperationsWords`); Export's empty/write refusals are
   door-level by necessity (no op). No new door rendered where it can never act (the gathering's "+ new chapter" is the
   walk's pre-existing nit). ⌘←/⌘→ are recorded as `alternateShortcutLabel`, not as a menu key — correct (see m-1).
4. **VX-332 — can the ask steal?** No, by trace. Every mount takes `CaptureOpeningFocus`: waits for the window; drops
   when any other responder holds the window's keyboard (`.someoneElse`) or a sheet is attached; `standsDown` keeps a
   tour mount from asking at all. Checked the wing switch (it re-mounts the Bookcase via `.id("bookcase-\(wingID)")`:
   a switcher still up as a sheet → drop; as a popover it is another window, and the main window's first-responder
   change does not take its key status) and the unfocused-pane Bookcase (the live pane's editor holds the keyboard →
   drop). Pins: the faithful-revert red on the navigation-back cell; the never-steal and tour guards.
5. **VX-560 — can ⌘←/⌘→ reach a text first responder?** Not for any `NSText`/`NSTextField` (field editors included —
   `BrowserNavKeysTests.aTextFieldKeepsCommandArrow…`); sheets and popovers are other windows (`event.window` check).
   YES for a text input inside the reference panel's `WKWebView` — m-1.
6. **VX-589/VX-580 display-only, P3.** Display-only holds: `openListRows` filters the drawn rows only (`stripGap`
   traced through hidden-row cases — the landing is right); `rowLeads` and the title `offer` are derived projections in
   view state, never written (rename still seeds from the stored title). P3 untouched (no new live surface). But the
   held read behind `rowLeads` breaks P1 — M-1.
7. **Literal colours / `fixedSize` + `lineLimit`.** Clean: no literal colour in any added line (only `Color.clear` hit
   shapes); both new `fixedSize` texts (the readout, the wing label) carry `lineLimit(1)`.
8. **VX-441 — zero text-storage/layout/identity changes.** Clean: the container override calls super and reports a
   change; the delegate's tail call runs after `settleMarkdownCaret`/`updateCaretContext` unchanged; incremental
   searching stays off (pinned). Per-keystroke cost is O(1) (measured — the scope note); the per-step scan is m-2.

## Clean bill

- No change under `Sources/VariorumCore/Sync/`, no custody/keychain code, no schema or migration, no §9 operation's
  semantics changed; every write rides an existing operation (`renameContainer`, the book/gathering mints, the wing
  doors, `NoteDeletion.fire`); export paths write no row (pinned, outbox 0).
- VX-125's act: flush pending typing → one off-main read → save panel → atomic write → receipt; a cancel is silent; an
  empty note refuses before the panel; archived and sealed notes export. ⌥⌘S's collision sweep holds
  (`NoteVersionsPaneTests`' `s`-chord sweep updated deliberately; ⇧⌘E stays Extract's).
- VX-570: the foot/flow mints now share one `mint(_:reveal:)` with each door's prior focus/reveal behaviour preserved
  (foot: focus only; flow and ⌥⌘N: focus + reveal); the request is a fresh token handed only to the live pane's book
  and consumed once; `footMint` matches the foot's own choice (gathering → planner, journal trait/daily → entry).
- VX-553: `BookFootDoors.book` reproduces the old conditions exactly (entry vs note, none when finished) and moves
  restore after the pair; old order chapter · restore · note confirmed in the removed code.
- VX-602: menu, palette and registry carry the new names from one source each; the confirm question follows; guide
  content deliberately untouched and flagged (bundle 3/10).
- VX-426: every changed tooltip leads with the door's name in sentence case; the table's scope matches the ruling.
- VX-569: the offer reads through the flat `Queries.leadingBlockTexts` (3 slots); Tab is taken only on an empty field
  with an offer; nothing is applied without her ⏎.
- Commit hygiene: no `Co-Authored-By`/`Claude-Session` trailers in any of the run's commits; `git diff --check` clean.
- The second-merger step (VX-502 merged in at `0a30e8b09`) touched no shared file; the export seam's pins ran green on
  the merged tree (record) and the core three ran green here.

## Suites wanted at the stage (the reviewer cannot run `xcodebuild test`)

None was needed to establish the findings above (each is traced in code, measured in a scratch harness, or a repo-state
fact). After fixes: `SidebarRowLeadsTests` + the new P1 pin (M-1); `BrowserNavKeysTests` + the WKWebView pin (m-1);
`FindReadoutTests` + the scan-count pin (m-2); `SidebarNoteRowMenuTests` / `OpenListDragTests` (m-3, m-7);
`QuickEntryWingLabelTests` (M-2); `SettingsShapeTests`, `DiagnosticsPaneTests` once the General pane is captured (m-4).
