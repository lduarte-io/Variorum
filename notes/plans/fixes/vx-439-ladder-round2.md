# VX-439 — ladder round 2 (cold review of the L1 fixes, `opus-reviewer`, fresh)

**Diff under review:** the L1 fix commits (`Part of VX-439 L1:` — `07c3fdd48` M-1, `fd4dcddc9` M-2, `af28362b8` m-1,
`f102a6522` m-2, `8c8048c1c` m-3, `f0d6b38dc` m-5, `7f83b689f` m-7, `6c8816e13` m-4, `6398b8b2f` n-2, `77d7232fa` n-4,
the stage records `bf91cd0ba`/`3081640c5`/`162679f09`) and the merge `2b33e8bb6`, in `~/dev/variorum-vx-439`
(branch `vx-439-run-sidebar-bar-export-quick-wins`, tip `744b27ade`).
**Anchor:** `notes/plans/fixes/vx-439-sidebar-bar-export-quick-wins.md` (LIVE STATUS "L1", the Ledger's "LADDER ROUND 1
DISPOSITIONS", THE EVIDENCE SLICE); round 1's findings `vx-439-ladder-round1.md`.
**Status:** COMPLETE — 0 BLOCKER · 0 MAJOR · 3 MINOR · 4 NIT (summary at the foot).

## Scope note (said first, per the brief)

L1 adds no file CLAUDE.md names as the editor seam (`EditorTextView`, `BlockRangeIndex`, `PaneSurface`, the read tier),
nothing under `Sources/VariorumCore/Sync/`, no custody/keychain code, no default's meaning. The nearest touch: m-2 adds
ONE integer line inside `EditorViewModel.storageDidEdit` (`findTextGeneration &+= 1`, line 1313) — the storage's edit
transaction, beside N14's `overlayGeometryGeneration` bump. It reads no text, queries no geometry (the TK2 estimation
hazard that method's own comment warns of), runs before the `suppressEditProcessing` guard exactly as N14's counter
does, and changes no identity, layout or storage behaviour. I judge it does not re-spawn the round as `fable-reviewer`;
it is named here (and belongs with the round-1 seam touches in her bundle — R2-2) so the orchestrator can decide.

## Findings (severity-ranked)

No BLOCKER. No MAJOR. (Severities stated with a round 3 in mind: nothing below changes data, an invariant, or a
default's meaning; the one code finding is a display-only regression in a sync-race state.)

### MINOR

**R2-1 [MINOR] · `App/Variorum/Variorum/Features/Library/SidebarRowLeads.swift:70-73` (M-1's fix) over
`Sources/VariorumCore/Queries/PostRender.swift:338-345` · the fix routes the sidebar's HELD read through
`Queries.leadingBlockTexts`, which THROWS on a gap — so one gap in any listed untitled note's first three slots ends
the observation, and the rows' live preliminary titles freeze until the row set changes. The old road tolerated it.**
- *Mechanism (traced, then run).* `leadingBlockTextsSQL` LEFT-JOINs `block` and both takes, so a slot whose block is
  dead, or whose chosen and default takes are both unresolvable, yields a row whose `text` is SQL NULL; the read
  decodes it as non-optional `String.fetchAll`, and GRDB's `FastDatabaseValueCursor` → `fastDecode` throws
  `RowDecodingError.valueMismatch` on NULL (`.build/checkouts/GRDB.swift/GRDB/Core/StatementColumnConvertible.swift`,
  `fastDecode`/`_valueMismatch`). `SidebarRowLeads.read` lets it propagate; the column's
  `.task(id: noteRowIDs) { for try await … observe { SidebarRowLeads.read } … } catch { }`
  (`SidebarView.swift:451-462`) then leaves the loop — the observation is gone, `rowLeads` keeps its last value (a note
  she types into no longer renames its row; a newly listed untitled row gets no lead) until `noteRowIDs` changes, and
  the very next start throws again while the gap stands. The old road (`NoteCards.load`: an INNER `JOIN block`, and
  `COALESCE(…, '')`) skipped the dead block and read the dead take as `""`. Run here on the branch's core (scratch probe
  `…/scratchpad/gapprobe`, a path dependency on this worktree): healthy note → `["first words here","second","third"]`;
  a live placement over a tombstoned block → **`leadingBlockTexts` THREW** ("could not decode String from database value
  NULL"), the old window → `["second","third"]`; a live block whose only take is tombstoned → **THREW**, the old window
  → `["first words here","","third"]`. SyncSpec §5 is the rule this breaks: "Read-side code must tolerate
  referenced-but-not-yet-arrived rows across batches (render gaps, never crash) — rare, but designed-for." Both shapes
  are cross-batch apply states (a block tombstone and its placement's, or a take's tombstone and its block's default
  re-point, landing in different rounds).
- *Two pre-existing facts this exposes (not the fix's to own, but the pin must not repeat them):*
  `leadingBlockTexts`' own doc says "Gaps contribute nothing (`renderPost`'s rule — render gaps, never crash), so the
  result may be shorter" — false, it throws; and the pin that claims to prove it,
  `LeadingBlockTextsTests.theBoundedReadResolvesEachSlotExactlyAsRenderPostDoes` leg (4) "a tombstoned BLOCK under a
  live placement", is HOLLOW: its raw `UPDATE block SET deleted_at` fires `cascade_block_tombstone`
  (`Persistence/Triggers.swift:36-48`), which tombstones the placement too, so the leg never holds a gap. The new
  `SidebarRowLeads.swift` header repeats the false consequence ("a live placement over a DEAD block … takes a slot as
  a gap").
- *Red-on-old pin.* App side (`SidebarRowLeadsTests`): an untitled listed note whose FIRST slot is a gap (tombstone the
  block, then revive its placement — the cascade's undo; or tombstone the only take) — `SidebarRowLeads.read` must
  still answer, leading with the next slot's words. Red on the current tip (throws), green on the pre-M-1 code
  (`NoteCards.load`) and green after the fix. Core side, if the fix lands in the query: leg (4) re-staged with a REAL gap
  (revive the placement after the block's tombstone) — red now (throws), green after.
- *Fix (the orchestrator's pick).* (a) In the core query, decode `String?` and drop NULLs — exactly what its doc and
  `renderPost`'s `.compactMap(\.text)` already promise (a gap still spends its `LIMIT` slot, as the sidebar header
  says); this also cures the same throw in `BookViewModel.readCardPreviews` (where one gap blanks every card preview in
  the batch) and `TitleQuickfill.opening`. Or (b), local: `(try? Queries.leadingBlockTexts(…)) ?? []` per note in
  `SidebarRowLeads.read`, so a gapped note keeps its date name and the others keep leading. (a) is the honest one; it
  touches a core query outside `Sync/` and outside the editor seam. Either way correct the `SidebarRowLeads` header's
  consequence sentence.

**R2-2 [MINOR] · run record, THE MORNING BUNDLE (items 1–19) vs the Ledger's "LADDER ROUND 1 DISPOSITIONS" and THE
EVIDENCE SLICE · four dispositions say "bundled" and are not in the bundle — one of them an author-only call that must
be made BEFORE the PR merges.**
- *Evidence (repo state).* The dispositions read: **M-3** "the ~11 MB in BRANCH HISTORY is hers to rule … Bundle item.";
  **n-1 / n-3 / n-5** "BUNDLED"; the reviewer's **editor-seam scope note** "the two lines are NAMED in the morning bundle
  so she can order a Fable pass"; the evidence slice's "the General pane's 7-row glance is hers (one Settings visit,
  bundle)". The bundle's items are 1–18 plus "19. (grows)": item 18 is M-2; none is M-3's history question, the
  journal-profile title offer (n-1), the Library's second per-note export door "Markdown with Takes…" (n-3), the
  one-turn faint-text swap (n-5), the two editor-seam file touches (`EditorTextView.swift`'s `isFindBarVisible`
  override, `EditorView.swift`'s selection-delegate tail call — and, since L1, `storageDidEdit`'s one counter line in
  `EditorViewModel.swift:1313`), or the General glance. (`grep` of the record: "M-3", "11 MB", "Markdown with Takes",
  "Fable pass" occur only in the Ledger and the L1 NOT-YOURS line.)
- *Why it matters.* M-3 is the load-bearing one: merges are merge commits and history is never rewritten without her
  word, so if the question never reaches her the default outcome — 11 MB of walk captures and two full Debug
  `UserDefaults` dumps carried into `main` permanently — happens by omission at the merge. The others are her taste
  calls and the members' outstanding use-shaped evidence (CLAUDE.md sizing: a batch closes on use-shaped evidence, never
  a pin alone).
- *Fix.* Append the five items to THE MORNING BUNDLE now (M-3 first and marked "before the PR"), each in her words'
  register with the choice it asks. No code; no pin (a repo-state check, round 1's M-3 precedent).

**R2-3 [MINOR] · run record THE EVIDENCE SLICE "NOT-REACHED, final" + `SettingsShapeTests.swift:186-190`,
`DiagnosticsPaneTests.swift:76-80` (m-4's disposition) · the slice's account of what carries the unreached legs is
wrong in two places and silent on a third, and the pins' comments now point at evidence that will not come.**
- *"The live toggle flip therefore rests on its pins + revA's red."* revA holds no VX-589 pin and no VX-589 revert: its
  nine suites / ten reds are exactly the L1 pins (`scratchpad/l1/stage-logs/revA.log`: SidebarRowLeads,
  QuickEntryWingLabel, BrowserNavKeys, FindReadout ×2, SidebarNoteRowMenu ×2, OpenListDragMount, OpenListDragFace,
  NoteExport). VX-589 is a feature resting on `OpenListStarredFilterTests` (6) and its headless replica — say that.
- *"VX-425's Move-confirm ask needs a second wing and rests on its mounted pin."* No mounted pin presents the confirm:
  m-3's mounted pin (`aMoveFromTheRowReasksWhichWingItsDoorsAndIndicatorRead`) takes the confirm-LESS road (a bookless
  note — `moveAsk` returns nil and moves at once) and calls the column's `onDone` oracle directly; the
  `.wingMoveConfirm` alert itself is pinned only by source-reads (`theNoteActsRunTheSharedRoads`,
  `theColumnsWingDoorsHandTheReaskAndBothReadsAreKeyedOnIt`).
- *Silent:* m-4's disposition folded "VX-425's three asks" into the slice; the slice reports Delete (receipts) and the
  Move confirm (not reached), and says nothing of the sidebar row's **Rename…** alert — neither seen nor listed
  NOT-REACHED (capture `54-es-renamemenu.png`, by its name the planned leg, shows the Settings search instead). Also
  M-2's L1 line promised the look "both voices"; capture 50 is the Study voice only (token-driven, so harmless — but
  the record should say one voice).
- *The pins' comments* (m-4's honesty half) now read "the live look at the fold is OWED to the run's evidence slice";
  the slice ran and recorded the General pane NOT-REACHED (its interior takes no synthetic clicks; captures 54/55 both
  show the search results, never the pane). The sentence should name where the look now lives — her one Settings visit,
  as a bundle item (R2-2) — or it will stand as a promise nobody is carrying.
- *Fix.* Correct the slice's two attributions and add the Rename line (reached or not) in place; re-point the two pin
  comments at the bundle item. Record/comment only; no pin.

### NIT

- **R2-n1 · run record STATUS banner (lines 5–8) and LIVE STATUS "Walks" line (line 689–691)** — after `744b27ade` both
  still say the evidence slice is pending / "NOT-STARTED"; the slice ran (THE EVIDENCE SLICE section). The resiliency
  protocol's LIVE STATUS is the bout's truth; flip both (and the banner's "then round 2" once this round's file lands).
- **R2-n2 · `Features/Library/OpenListDrag.swift:277-282`** — `OpenListRowHalves`' doc still says the halves are "Live
  only while THIS list's own drag is in flight (`state.dragging`, set when the drag begins, cleared …)"; since m-7 the
  liveness is `dragInFlight(among:)` (began here AND its row still drawn). The modifier's own comment says so; the type
  doc should too.
- **R2-n3 · closeout canon list (m-6's disposition)** — the list was written before M-2 and does not name VX-552 at
  all: the wing label now sits beside THREE current-wing mint doors (the two quick-entry bars and the toolbar's New Note,
  PROVISIONAL bundle 18). If the closeout gives VX-552 a contract line (SurfaceContracts §The app or the wing switcher's
  "the app's one wing follows the focused pane's note" line), it should say all three.
- **R2-n4 · run record WALK PART 1 / WALK PART 2 headers (lines 847, 981)** — round 1's M-3 fix list asked for "the
  record's two 'gitignored' sentences" to be corrected; both headers still say the captures were gitignored ("…,
  gitignored"; "…, gitignored until the debris sweep") although the M-3 disposition itself records they were committed
  (`e8594fec8`, `aed5708c1`) and only untracked at `080e15a08`. One parenthetical each.

## Per-round-1-finding verdicts

- **M-1 — FIX HOLDS, with a NEW problem it introduced (R2-1).** The words now come through `Queries.leadingBlockTexts`
  (`SidebarRowLeads.swift:70-73`): one `LIMIT`-stopped `idx_cblock_order` seek per untitled note. Measured here on the
  branch's core: 0.161 ms at 3 blocks, 0.161 ms at 20,000 — flat. The pin (`theReadsWordsAreBoundedSeeks…`) traces the
  read's statements and plans; red under R-M1 at the stage (revA: 3 issues — the window, no `LIMIT`, the full sort),
  green fixed. The disposition's "narrows its observation" was examined and recorded unavailable with a sound reason
  (the autosave's full-record `container`/`variant` updates SET every column, so no column region tells them from a
  rename, which must wake the read). The new road throws on a gap where the old one did not — R2-1.
- **M-2 — FIX HOLDS.** `RootView.swift:295-311` (the item at :301): a `.navigation` item right after the toolbar's New Note, the bars' words
  and hover from the shell's `WingsModel` (`currentName` = `session.wing.currentID`, the wing `createPost` mints into),
  muted, `lineLimit(1)`, ≤160 pt, `sharedBackgroundVisibility(.hidden)`; no literal colour. Pin red under R-M2 (revA:
  "no item"). Seen live (capture 50: "in Home" beside the toolbar pair and on the band). PROVISIONAL, bundle 18. C-552-1
  corrected in place in three places.
- **M-3 — DISPOSITION PARTLY HONORED.** The tip is clean (`git ls-files walk-shots-vx439` = 0; `.gitignore:90`
  `walk-shots-*/`), files kept on disk. But the history question — hers, before the merge — is not in the bundle (R2-2),
  and the walk headers' "gitignored" stands uncorrected (R2-n4).
- **m-1 — FIX HOLDS.** `PageTurnKeys.textIsFirstResponder` (the app's one answer, read only by the page-turn and
  ⌘←/⌘→ monitors — grep) now counts a first responder that is or sits inside a `WKWebView` (ancestor walk); a generic
  `NSTextInputClient` test rightly refused. Pin mounts a real `WKWebView` as first responder; red under R-W (revA: 3 —
  the rule false, ⌘←/⌘→ navigated, the non-vacuity leg's count) and green fixed; its non-vacuity leg proves the monitor
  live.
- **m-2 — FIX HOLDS.** `FindReadout.MatchCache` keyed on (needle incl. options, text generation); `findTextGeneration`
  bumps in `storageDidEdit`, which the storage delegate calls for every `.editedCharacters` edit (`EditorView.swift:
  886-896`) — typing, undo, replace, projections, sync applies — before the suppression guard, so no text change escapes
  it; the model is per post, so the counter never spans two texts. The binary search is right because the scan's
  matches ascend and never overlap, and it agrees with the old `firstIndex(of:)` on an overlapping hand selection (both
  nil). Pins: the pure counting pin red under R-C (headless replica 4/34 and revA 4 issues); the real-editor pin red
  under R-C (revA) and its edit leg red under R-G alone (revB: "4 of 4" not read, one scan not two) — the generation's
  necessity proven separately. The record's false "a find step is itself a whole-note walk" is retracted in place
  (LIVE STATUS VX-441 line, the file header).
- **m-3 — FIX HOLDS.** `wingActGeneration` folded into both one-shot keys (`noteRowsWingKey`, `openWingsKey`); one
  `wingActDone` handed to `WingNoteDoors` and `.wingMoveConfirm`, each of which calls `onDone` only AFTER its awaited
  act (`WingsModel.swift:385-405, 418-430` — the calls at :391, :402, :428), so the re-ask reads the moved row. Mounted pin red under R-D (revA: 3), the
  wiring pin red (1). The mounted pin takes the confirm-less road; the confirm's `onDone` is carried by the source-read
  wiring pin (noted in R2-3 only for the record's wording).
- **m-4 — DISPOSITION PARTLY HONORED.** The honesty half landed (both pin comments no longer cite a capture that shows
  MCP). The live half ran as the evidence slice: VX-569's title-Tab GREEN live; VX-589's toggle and the General pane NOT
  reached (a walk-driver limit, honestly said); VX-425's asks partly — the slice's attributions are wrong and Rename is
  unmentioned, and the pins' comments now point at the slice that did not deliver (R2-3); the General glance is not in
  the bundle (R2-2). VX-424's hand check stays bundle 11 (present).
- **m-5 — FIX HOLDS.** `.disabled("never executed — the VX-604 host-crash class; re-enabled by the VX-603/604 work")`
  with the why in the doc; the stage read it SKIPPED (fixed2.log:1571-1572), so the 267-suite run includes it honestly.
- **m-6 — DISPOSITION HONORED** (closeout work, recorded in the Ledger with its list; not yet due). Add VX-552 (R2-n3).
- **m-7 — FIX HOLDS (pin-first, NOT hollow as a guard).** Pin written on existing API first; red under R-L (revA: the ✕'s
  click eaten — the latch's halves live), green with `dragInFlight(among:)` (began here AND its row still drawn), the
  halves' only liveness reader (grep: no other `dragging != nil` consumer). The record keeps the reviewer's question —
  whether AppKit ever withholds `.ended` after the source row goes — SPECULATIVE, which is honest: the pin proves the
  guard's consequence under a latched drag, not that the latch occurs. Type doc lags (R2-n2).
- **n-1 / n-3 / n-5 — DISPOSITION NOT HONORED as recorded** ("BUNDLED", absent from the bundle — R2-2).
- **n-2 — FIX HOLDS.** `couldNotWrite(fileName:reason:)` appends the system's sentence (trimmed, closed with a period);
  the unchanged words lead. Pin red under R-N (revA: 1) and headless (old FAIL / new PASS).
- **n-4 — FIX HELD at L1; stale again after the evidence slice** (R2-n1).
- **The reviewer's editor-seam scope note — DISPOSITION NOT HONORED as recorded** ("NAMED in the morning bundle" —
  absent; R2-2). L1's one added seam-adjacent line is in the scope note above.

## Clean bill

- **The merge `2b33e8bb6`** is a clean auto-merge: `git show --cc` carries no resolution hunk; the five shared files
  keep both sides; no L1 file was in main's delta; the 267-suite window ran on the merged tree.
- **The stage evidence matches the record line for line:** `fixed1/2/3` = 585 + 492 + 485 = 1,562 tests in 267 suites,
  all passing; `revA` = 58 tests / 9 suites with exactly the ten named tests red (24 issues incl. 4 warnings); `revB` =
  8 / 1 with exactly `theEditorScansOncePerTextAndAnEditRecounts` red; every named revert patch in
  `scratchpad/l1/reverts/` is the pre-fix code exactly (read each one).
- **P1 on the sidebar read** is now flat in a note's length (measured above), the window function gone from the held
  observation; P2/P3 untouched (no new live surface, reads off main through `session.database`).
- **No change** under `Sources/VariorumCore/Sync/`, no custody/keychain, no schema or migration, no §9 operation's
  semantics; no write added anywhere in L1 (every fix is a read, a view modifier, a key-routing answer, a copy string or
  a cache).
- **Registry discipline** intact: the toolbar label is a label, not a door (no glass, no action); every new string is
  sentence case; no literal colour in any L1 line; the new `fixedSize`-free texts carry `lineLimit(1)`.
- **The red-on-old discipline** held per fix: each bug-class fix has a named behavioral revert that goes red on exactly
  its pin, and m-7 ran pin-first with its hollow contingency written before the stage.
- **Commit hygiene:** no `Co-Authored-By`/`Claude-Session` lines in `dd469951e..HEAD`; `git diff --check` clean on
  `App/` and `Sources/`.
- **Record honesty where it was owed:** the false P1 justification (VX-441) and the false capture claim (VX-589) are
  each retracted IN PLACE with strike-through and the ladder's id, not silently rewritten.

**Status:** COMPLETE — 0 BLOCKER · 0 MAJOR · 3 MINOR (one code: R2-1; two record: R2-2, R2-3) · 4 NIT. No round 3 is
earned by severity; R2-1's fix needs its red-on-old pin and the orchestrator's line-by-line check, and R2-2's M-3 item
gates the PR.

## Per-round-1-finding verdicts

(filling in)

## Clean bill

(filling in)
