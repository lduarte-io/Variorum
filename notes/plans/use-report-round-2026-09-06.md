# The 2026-09-06 use-report round — 17l · 18c · 18d · 18e (EXECUTION PLAN)

**STATUS: READY TO KICK OFF — authored 2026-09-07 by Fable in a read-only planning session at the
author's ask.** Another session was mid-`pre-13x` while this was written, so **nothing shared was
touched**: this file, `notes/author-reports/2026-09-06-use-report.md` (her report, verbatim) and the
untracked screens folder `notes/plans/use-report-2026-09-06-screens/author/` (her twelve images) are
the ONLY new files, and none is committed. **The kickoff's first mechanical acts** (once `pre-13x`'s
session is out of the tree): commit these three; add the `.gitignore` line for the screens folder
(the per-round pattern, `.gitignore:13–28`); claim the four letters in `notes/plans/phase-17-standing-fixes.md`'s
allocation register (17l, pointing here) and in the master plan's Phase 18 row (18c · 18d · 18e,
pointing here); set the master plan's running-order row. Her sequencing: **this round runs NEXT, before
13u** (her words: *"This work will all be done pre 13u in my next phase"*).

**Source:** her report of 2026-09-06 — `notes/author-reports/2026-09-06-use-report.md`, her words
verbatim + the image manifest. **Cast:** hers at kickoff; the recommendation is in §6. **The reviews
owed:** the 17-entry review rule binds (CLAUDE.md / `notes/PhaseSizingGuidance.md` §5) — an Opus cold
review on every letter, a **Fable cold review on 17l, 18c and 18e** (each touches the editor seam or a
default's meaning); 18d's chrome may take Opus alone.

---

## 0. What this round is (one paragraph)

She spent an evening writing with takes and the app fought her three times in the same ten minutes:
Return stopped making blocks ("newlines make blocks: on" said the chip, and one block swallowed two
paragraphs), so she reached for divide; divide dragged every take onto both halves (the 13j default
she herself ruled and now reverses); and the ceremony she opened to keep the take on the first block
could not park the scissors at the end, arrived with the take unchecked, and looked "so ugly" that
using it was work. Around that core sit sixteen smaller annoyances she listed as a punchlist. This
round takes all of it, **grouped by kind and by seam**: **17l** — the defects (fixes; the standing
17 discipline); **18c** — divide's new default and the ceremony rebuilt (product: a canon delta she
ruled tonight); **18d** — the sidebar's note box, the title's return to the left, and the outline's
room (design changes she asked for); **18e** — markdown marks out of sight (a new editor capability).
Four letters, one plan file, one orchestrated run in that order; each letter closes on its own
dispositions. Her line to keep in view: *"overall I have to emphasize that the app is looking and
feeling great after the various rounds of changes."*

## 1. Where this sits — numbering, sequencing, the 13u fence

- **Why four letters and not one.** Her instruction anticipated a split (*"You might have to split it
  into multiple different phases because there's a lot of items"*), and CLAUDE.md's 17/18 rule splits
  it for us: **17 is fixes and tech debt; 18 is product advancement** (her R-cor-13). The newline bug,
  the ring ignoring its setting, the landing family, the stale titles, the alignment defects are
  fixes → **17l**. Reversing the divide default and rebuilding the ceremony changes what "divide"
  means and looks like → **18c**. Re-homing the book's block menu into the sidebar, un-centering the
  title, giving the outline room and a memory → **18d**. Concealing markdown marks is a new editor
  capability with a design question → **18e**. Letters are allocation order, not priority; the running
  order (§6) is 17l → 18c → 18d → 18e because 17l's crystallization fix and 18c's default are the two
  she named as the pain ("especially the newlines not making blocks bug… AND the divide menu /
  ceremony being such a mess in appearance and functionality + the autocarry of takes with divide").
- **Sizing guidance, stated rather than silently exceeded** (`notes/PhaseSizingGuidance.md`): 17l
  carries ~19 defect rows across four surfaces — run as **four one-surface batches**, each its own
  implementer session (rule 1), each closing on USE (rule 3). 18c is one phase-sized unit (the
  ceremony rebuilt) plus a composition. 18d holds two phase-sized units (the sidebar box; the outline
  room + memory) under one theme — at the line, not over it. 18e is one unit. A session that finds a
  second unit in its way hands off with a record.
- **Precedents this file follows:** the Act 10 correction round (`notes/plans/act10-correction-round.md`
  — her report answered row by row, one surface per session, walked in use before a record closes;
  its rules C-1…C-7 bind here by reference, §7) and the 13j fanned-defaults batch (`FannedDefaults.swift`
  — a default changed by COMPOSING an existing operation, zero core change; 18c repeats the shape).
- **THE 13u FENCE — what this round deliberately does NOT take** (read `notes/plans/phase-13u-feel-and-polish.md`
  and the master plan's `### 13u` section before touching the editor seam):
  - **Cross-block delete (her selection-across-a-boundary refusal, image 8)** — 13u1 item 5, ruled and
    fenced; she said so herself (*"I think that's supposed to be addressed in 13u with automerge?"*).
    Nothing here touches `CrossBlockEditPlanner`, the refusal grammar, or the fanned matrix.
  - **The O(N²) family, the churn pair, the arm-then-hand-off residual** — 13u1's. 17l's crystallization
    fix lands in `BlockRangeIndex.verdict` and `EditorViewModel`'s tail road; it must not widen into
    those rows. If the fix needs `StructuralGesturePlanner`, stop and record.
  - **Pane stability (13u2 item 1)** — the general trace stays 13u2's. Two SPECIFIC members of that
    family are built here because she named them (rows 16 · 32): the take pane's stale height after a
    big deletion, and the outline's remembered surface sizes made persistent. 13u2 inherits what remains.
  - **The title cut-off (13u2 item 13 + row 93)** — 17l's row 19 widens the title's measure and
    re-anchors it left; that very likely satisfies item 13's letter. The 13u2 kickoff decides whether
    to mark it BUILT HERE; this round only records what it changed.
  - **P39b** (`WriteTakesPanel` constructing `TakesViewModel`) — 13u2's. 18d's sidebar-box composition
    must not add a sibling violation (a feature holding another feature's view model); §4.3 says how.

## 2. THE LEDGER — her items, every one a row

Status vocabulary (the correction round's): OPEN · TRACED · FIXED(pin) · RECORDED · DEFERRED(owner) · HERS.
"Traced" below means **traced by READING, unproven** — the hallucination guard makes the pin the first
act of every fix, never the trace. Rows quote her words short; the report has them whole.

| # | Her words (short) | Surface | Traced mechanism / architect's read (file:line) | Letter · batch | Status |
|---|---|---|---|---|---|
| 1 | "newlines to make new blocks is NOT working properly at all. I was in write mode… had several new lines, and it was not making new blocks" (image 4: block 3/3, 472w, two paragraphs, chip ON) | Write's tail road | The open-tail gesture fires ONLY at the exact UTF-16 document end while no tail region exists (`BlockRangeIndex.verdict`, `BlockRangeIndex.swift:144–152`). Two everyday states defeat it invisibly — §3.1 has the full trace | 17l · a | TRACED |
| 2 | "dividing automatically bringing the take along to both items was so annoying… if you divide, the takes should automatically stay on the top block" | Divide (fanned) default | 13j J4's `divideDuplicating` default (`FannedDefaults.swift:9–15`; `EditorSurfaceController.swift:487`, `TakesStructureController.swift:437`). Her ruling reverses it: KEEP-ON-TOP, composable from `Operations.divideW` with every other take parked at its end — §4.2 | 18c · 1 | HERS (ruled) |
| 3 | "the scissors couldn't be placed at the end of the block" | Divide ceremony (placement) | The end IS a legal slot by design (`DivideWCeremony.legalCutPositions`, `:231–234`; `WTake.parkedAtEnd`, `:165`; `WCutPlacement.flowItems` ends with `.slot(end)`), so the defect is downstream — three candidates in §3.4 | 18c · 1 | TRACED |
| 4 | "the take was automatically not selected so it would've just disappeared. Takes should automatically be selected… and should automatically have the scissors at the end" | Divide ceremony (defaults) | `DivideWCeremony.State` seeds only the SEED take as marked (`:207`), others unmarked with a propagated proposal. Her ruling: all checked, non-seed parked at the end — §4.2 | 18c · 1 | HERS (ruled) |
| 5 | "the divide ceremony page was so ugly with the spacing between the words, the way that you have to scroll to get the different takes, just overall" (image 5) | Divide ceremony (face) | The token flow's FIXED 9-pt slot between every word (`CutFlowGeometry.slotWidth`, `:44` — the QoL-round L1 trade); takes stacked in a 240–420 pt ScrollView (`DivideWSheet.swift:90–98`); system fonts, stacked explainers. A rebuild behind a mockup gate — §4.2 | 18c · 2 | OPEN (mockup gate) |
| 6 | "the take mode always shows a ring around what piece you're editing - it doesn't follow the preference on cursor being enough, wanting background wash, or ring" | Every pane host (Takes/Lenses/Compare/Canvas/Read-edit) | `PaneSurface.swift:705–711` strokes `tokens.ring` whenever `isLive`, reading no setting; Write honors `EditingIndicatorStyle` in `BlockDecor.renderIndicator` (`BlockDecor.swift:507–531`); the enum is `Enums.swift:86` | 17l · c | TRACED |
| 7 | "switching from takes to write doesn't leave you where your cursor was, if you were in the middle of a particularly long block" | The one current block (Takes → Write) | `FocusedBlock` carries no caret offset (`BlockHistoryPane.swift:131–135`); `CurrentBlockMemory` persists "block\|variant" only (`:44`); Write's arrival lands at the block's START (`EditorViewModel.bareArrivalLanding`, `:1729–1734`) | 17l · b | TRACED |
| 8 | "open takes mode in write from the takes menu is also not automatically navigating you to where you the take is" | Write's fan panel → Takes mode | `WriteTakesPanel.swift:68–76` posts `pendingTakesLanding = .bloom` and switches; `TakesChoreographer.consumeLandings` (`:159–176`) blooms + focuses the pane but the article column never SCROLLS — `TakesBoardView`'s single-column article has no scroll-to (the only `scrollPosition`s are the fan strips', `:1001/:1055`) | 17l · b | TRACED |
| 9 | "the hitbox for adjusting the size of the left bar… is also too small and difficult - sometimes it's the regular pointer, sometimes it's the I looking pointer" | `ShellSplit` divider | A 1-pt line with a 9-pt invisible grip drawn as an OVERLAY of the line (`ShellSplit.swift:97–110`); the detail view is the next HStack sibling and sits above the grip's right half, so hover/drag reach ~half of 9 pt and the editor's I-beam wins under the pointer | 17l · d | TRACED |
| 10 | (implicit in image 1) the "Fill code … From Messages" popover appears when the title is clicked | Masthead title field | The title `TextField`'s PROMPT is the note's date — an all-digit string (`PostTitleLabel`, `PostDetailView.swift:588`); hypothesis: AppKit's one-time-code AutoFill heuristic reads the digit prompt as a code field. Lookup + fix in §4.1 (d) | 17l · d | OPEN (hypothesis) |
| 11 | punchlist 1: "I don't like the title being aligned in the middle. it should be aligned to the left again so it starts where 'in no book' is, and… extend at least as far as the middle centered title can extend right now" | Masthead title | Act 10 rows 4/19 centered it (`PostDetailView.swift:592–594, 625`: `.multilineTextAlignment(.center)` + `.frame(maxWidth: 380, alignment: .center)`); her ruling supersedes those rows | 17l · d | HERS (ruled) |
| 12 | punchlist 2: "When you click on the title the placeholder text shifts upwards (the date)" | Masthead title | The two faces (`Text` at `:601`, `TextField(prompt)` at `:588`) share a measure but not a height/baseline; the plain-style field's prompt sits on a different baseline | 17l · d | TRACED |
| 13 | punchlist 3: "'This note' is misaligned from write, takes, compare, etc. Open is also misaligned from the tabs" | Sidebar headers | `SidebarView.header()` pads `groupPadding + rowPadding` (`:298–303`) while the rail rows pad `groupPadding` and their text starts at the row chrome's inset (`:459–480`; the › marker rides only the current row) — image 4 measures the header ~14 pt inboard of the row text | 17l · d | TRACED |
| 14 | punchlist 11: "the chosen green line doesn't go all the way down on a long block" (image 6) | Takes, stack style | `TakeCardFrame` draws the 3-pt `tokens.chosen` bar as an HStack SIBLING of the pane (`TakesBoardView.swift:1360–1378`); with the pane's height published asynchronously (`PaneSurface` `$height`) the bar can size against a stale height. Candidate fix: draw it as an `.overlay(alignment: .leading)` of the card so it is the card's height by construction | 17l · c | TRACED |
| 15 | punchlist 10: "when you haven't written anything, you can't write in the takes mode… you should be able to make a first block there" (image 3) | Takes / Lenses empty state | The "＋ new block" door exists (`TakesBoardView.swift:535`, `model.addBlockAtEnd()` → `TakesStructureController.swift:74`) but is gated `if !slots.isEmpty` (`:530`); the empty state offers only "Start writing (Write mode)" (`:513–520`); Lenses mirrors it (`LensesBoardView.swift:469`) | 17l · c | TRACED |
| 16 | punchlist 13: "when you delete a lot of text from a take, sometimes it won't recompute and will leave an empty gap in there until you switch modes and come back" | Take pane height | `PaneSurface` publishes a MEASURED height and re-converges only when an occasion asks (`reconvergeIfDiverged`, `:1146–1156`; the coalesced sink `deliverMeasuredHeight`, `:1031–1047`); after a large deletion TK2's estimate may not have shrunk when the measure runs (TEXTKIT2 §2 — the estimate moves under you), and no later occasion re-measures until a remount. A 13u2 item-1 family member, built here because she named it | 17l · c | TRACED |
| 17 | punchlist 12: "you can't mark two posts as versions if one has no blocks yet" (image 2) | Compare's "mark as versions" | `Operations.markPostsAsVersions` anchors the `version_of` edge on each post's FIRST block (`Operations+Versions.swift:100–125`; the block-level anchor is KnownIssues row 31 / QUESTIONS #19), so a blockless post throws `postHasNoBlocks`; Compare then dumps the RAW error (`Refused: postHasNoBlocks(id: …)`) — a copy defect on its own (the J8 copy-truth rule; `VersionActs.swift:96` has words for the restore road only) | 17l · d | TRACED (shape PROVISIONAL) |
| 18 | punchlist 14: "renaming a note won't rename it on the sidebar until you click on something else" (image 9) | Open strip titles | `WorkspaceModel.resolveTitles` is a ONE-SHOT read re-run only when `titleSubjectsKey` changes (`SidebarView.swift:259–260`; `WorkspaceModel.swift:382–446`) — a rename changes no subject, so the strip stays stale until a selection change | 17l · d | TRACED |
| 19 | punchlist 15: "changing date on a journal note or other note doesn't change its auto display name" (image 11) | Masthead display title | `PostTitleLabel.refresh()` is a one-shot read `.task(id: postID)` (`PostDetailView.swift:646–657`); `updateEntryDate` never re-runs it, so a nameless note's date-derived title (`Queries.noteDisplayTitle`, `TakesQueries.swift:195`) stays at the old day. Same class as row 18 — ONE fix (§4.1 (d)) | 17l · d | TRACED |
| 20 | punchlist 8: "Opening in write from blocks puts your cursor in the right place but doesn't move you there" | Blocks → Write | The workbench's "open in write" (`BlocksWorkbenchView.swift:877`, `onJump`) lands a `WriteIntent`; `EditorViewModel.applyWriteIntent` (`:1743–1760+`) sets the selection and does not scroll the caret into view (the arrival road at `:1702–1707` scrolls; the intent road does not) — verify, then land both roads on ONE primitive (`JumpPrimitive.jump(toOffset:)`, `JumpPrimitive.swift:102`) | 17l · b | TRACED |
| 21 | punchlist 5: "on the index, the number of notes per chapter should be better aligned with the ... menu" (image 7) | Book Index column | The chapter header's count is a trailing `Text` (`BookIndexView.swift:352–354`, horizontal padding 8); the note row's `Menu("⋯")` (`:521–525`, `.borderlessButton`, mini) carries a disclosure chevron, so the ⋯ glyph sits inboard of the count's trailing edge | 17l · d | TRACED |
| 22 | punchlist 4: "the outline needs a bit more generous spacing on a book - the chapters feel too tightly clustered and the panel with the chapter names should also be draggable to be a bit bigger" | Book navigator | `BookView.navigator`: rows in a `VStack(spacing: 2)` (`:368–373`), the column fixed at `.frame(width: 190)` (`:645`) | 18d · 3 | HERS (ruled) |
| 23 | punchlist 6: "The block menu should move to being where the 'this note, write, lenses, compare, etc.' menu is, measured to take up the same amount of room, and should show 'no note selected'" (image 10) | Book editing modes + sidebar | The focused note's bar rides a 190-pt right gutter in Outline (`EditorView(barPlacement: .side)` → `CommitBar(axis: .vertical)`, `EditorView.swift:113–125`; `BookView.swift:1597–1615`) and floats at the right in the paged Book mode (image 10); the sidebar shows no rail for a book (`SidebarView.railGroup`, `:453`) | 18d · 1 | HERS (ruled) |
| 24 | punchlist 7: "I need a setting where you don't see the markdown marks… disappear unless you're at the edge editing them or turn seeing them back on" | Live editor (both platforms' brain) | `MarkdownFaceCore` colors markers `palette.marker` on the STORAGE (`MarkdownFaceCore.swift:183–194`); the read tiers already hide them (`FlowParagraph.swift:86`, `inlinePresentationIntent`). No concealment exists in the live editor — §4.4 | 18e | OPEN (design) |
| 25 | punchlist 9: "remembering the length of notes so it can be perfect after the first time" | Book Outline surfaces | `BookViewModel.rememberedSurfaceSizes` is SESSION-only (`BookViewModel.swift:389–395`); `SurfaceSizeMemory` likewise (`StableSurface.swift:25–32`); the settle/width rules (R1-1) already make a persisted memory safe | 18d · 4 | HERS (ruled) |
| 26 | punchlist 16: "table of contents in read mode for a note is horizontally limited and not changable, should be adjustable" (image 12) | Note Read contents column | `ReadModeView.swift:140` `.frame(width: NoteIndexColumn.width)` = 340 fixed (`NoteIndexColumn.swift:38`); `SideColumn` (draggable, remembered) exists for TRAILING panels only (`SideColumn.swift`) | 18d · 3 | HERS (ruled) |
| 27 | (from row 17) Compare speaks a raw `OperationError` for the versions refusal | Compare | see row 17 | 17l · d | TRACED |
| 28 | (from row 1) the bottom bar's block label reads "block 3/3" while the surface looks like the end of the note — nothing tells her the caret is inside the last block rather than at the note's end | Write's bottom bar | A FACE consequence of row 1; fixed by row 1's mechanism, recorded so the walk checks the bar's honesty afterwards | 17l · a | RECORDED |
| 29 | "selecting a sentence and trying to delete it and it rejecting due to blocks" (image 8) | Cross-block delete | 13u1 item 5 — fenced (§1) | — | DEFERRED (13u1) |
| 30 | (from row 23) the paged Book mode's floating card "won't be at the bottom when you're in that book editing mode" | Book paged mode | the same re-home (row 23) | 18d · 1 | HERS (ruled) |
| 31 | (architect's rider on row 1) the "Takes" button in Write's bottom bar opens the fan PANEL (`openCaretFan`, `EditorViewModel.swift:2374–2388`), whose take card is a PANE — a pane never crystallizes by design (`ReturnKeyTraceTests` (d)). If she was typing in the card under the block, "newlines make blocks" was never in play there | Write fan panel | a kickoff question (§5 Q1), not a fix | 17l · a | OPEN (ask) |
| 32 | (architect's rider on row 16) the general pane-stability trace | Takes/Read/Outline panes | 13u2 item 1 — fenced | — | DEFERRED (13u2) |
| 33 | (from row 26) the leading-edge draggable seam is needed twice (rows 22 · 26) | `Core/Views` | build the leading variant of `SideColumn` ONCE (the hoist-at-next-touch rule), both surfaces consume it | 18d · 3 | OPEN |

## 3. The traces (the architect's read — by reading, never by running; the pin decides)

### 3.1 Row 1 — why Return stopped making blocks (the one she called "hugely annoying")

**The designed gesture.** Type-time crystallization only ever plans over the OPEN TAIL — text after the
last block (`CrystallizationPlanner.swift` header; `SegmentationRules.crystallizedBoundary`). The tail
opens by exactly one gesture: **a single newline typed at the exact UTF-16 document end while no tail
region exists** — `BlockRangeIndex.verdict` returns `.openTail` iff `tailLength == nil && !entries.isEmpty
&& range.length == 0 && range.location == documentLength && replacementIsSingleNewline && segmentation
!= .oneBlock` (`BlockRangeIndex.swift:144–152`; the ratified Phase 7 gesture, re-pinned at 13d A15,
`ReturnKeyTraceTests` (b)). Every other newline is I4 content of the block it lands in. The tail's
leading newline run folds back into the last block as content (the k−1 rule — `attachLeadingTailRunIfNeeded`,
`EditorViewModel.swift:1306–1338`); the idle mint (2 s) closes a non-empty tail (`kindForDurabilityMint`);
**nothing closes an EMPTY tail** except deleting its separator (`.closeTail`, `:154–158`) or the initial
render (`renderFull(preserveTail: false)`, `:663`; every later full render preserves it, `:669/:679`).

**The two states that defeat it — invisibly, because the surface's bytes look identical either way:**

- **S1 — an open, EMPTY tail lingers.** She types "…and now", presses ⏎ at the end (the tail opens; the
  ⏎ IS the separator), then pauses to think — the idle mint plans nothing over "" — or presses ⏎ again
  (the run folds into the block; the tail stays open and empty). The document now ends with the
  separator, and the last visible line is blank. **Any click at the end of the last text line lands the
  caret BEFORE the separator** (offset `lastEnd`) — the ordinary way to "go back to the end". ⏎ there:
  `tailLength == 0` is not nil → not `.openTail`; the location is not inside `tailRange` (which starts at
  `lastEnd + 1`) → a block edit → **content**. The paragraph she types next is content too. Each extra
  ⏎ she tries adds a blank line inside the block — image 4's two blank lines, "several new lines".
- **S2 — the tail is closed and the last block ends with a content newline** (the k−1 rule's normal
  product: "para\n"). The last visible line is again blank; the same click lands before that newline
  (offset `documentLength − 1`); ⏎ is not at `documentLength` → content.

Both share one shape: **the gesture is keyed to the last UTF-16 offset, while her notion of "the end of
the note" is the end of the last visible text.** The chip ("on") and the bar ("block 3/3") are both
truthful and both useless to her at that moment (row 28).

**Ruled out by the evidence, to be re-checked by the pin:** `one_block` (the chip reads ON; the chip and
the verdict read the same `header.effectiveSegmentation`, `CommitBar.swift:624` / `EditorViewModel.swift:1350`);
MarkdownActs' Return intercept (`.continueList`, `MarkdownActs.swift:388` — list leads only; her text is
prose); ⇧⏎ (declines the tail by ruling, `SoftNewlineTests`). **To be ruled in or out by HER (§5 Q1):**
row 31 — the fan panel's take card is a pane and never crystallizes.

**The fix, as options (the implementer pins S1 and S2 first, then chooses; the spec's letter — "Enter
at the exact document end opens the tail" — is a Phase 7 gesture description, not an invariant; I4 is
untouched by every option because a newline that lands as content stays content):**

- **F1 (recommended) — the gesture recognizes the EFFECTIVE end.** In `verdict`: a single newline typed
  (a) at `lastEnd` while an EMPTY tail is open → return a new verdict `.enterOpenTail` (or reuse
  `.openTail` with a flag): the editor DECLINES the insertion and moves the caret to `documentLength` —
  zero bytes change, she is now in the tail she already opened; her next keystrokes are tail text.
  (b) inside the trailing newline run of the last block while no tail exists (S2) → the run's LAST
  newline becomes the separator: the block's stored text loses one trailing "\n" (an autosave), the
  tail opens empty at the same surface bytes — the leading-run attachment run in reverse — and the
  caret lands in the tail. Surface bytes never move under her caret in either half.
- **F2 (belt) — an empty tail never lingers.** Close an empty tail when the caret leaves it or at the
  idle tick (the separator's byte then becomes the last block's trailing content — S2's shape — so F2
  alone only moves the problem; it is a belt under F1(b), not a fix).
- **F3 — a face.** If any state remains where ⏎ at the visible end stays content, the bottom bar's label
  must say so ("inside block 3 — ⏎ at the note's end starts a new block") — the P-2 honesty class;
  hopefully unnecessary after F1.

**Pins (red on old by construction, in the `EditorSessionTests` / `ReturnKeyTraceTests` harness — real key
events through the real AppKit path, as A15's trace did):** (1) seed `["alpha"]`; ⏎ at 5 (the tail opens);
`setSelectedRange(5)` (the click's landing); ⏎; type "beta"; ⏎; type "gamma" → blocks `["alpha", "beta"]`
+ tail "gamma" (idle → `["alpha","beta","gamma"]`); pre-fix: one block `"alpha\n\nbeta\ngamma"`.
(2) seed `["alpha\n"]` (a trailing content newline, tail closed); caret at 5; ⏎ + "beta" + ⏎ + "gamma" →
two new blocks. (3) the standing pins stay green: ⏎ at the true end still opens the tail; ⏎ mid-block is
content; ⇧⏎ declines; `one_block` never opens. (4) the k−1 spacing pins (`CrystallizationTests`) unchanged
— typed blank lines still persist as content. **Then the walk:** her exact scenario on the dev store —
write a paragraph, ⏎, think, click at the end of the last line, ⏎, write — a new block every time, the
bar reading "open tail" while she types the new paragraph.

### 3.2 Rows 7 · 8 · 20 — the landing family (one memory, three doors, no offset, no scroll)

`CommandRouter.focusedBlock` is the ONE current block across modes (Act 10 batch C, row 39); its memory
is `CurrentBlockMemory` (persisted `"blockID|variantID"`, `CurrentBlockMemory.swift:44`). Three roads read
it and each stops one step short:

- **Takes → Write (row 7):** `bareArrivalLanding` returns the block's START offset (`EditorViewModel.swift:1729–1734`)
  because the fact carries no caret offset; `scrollRangeToVisible` follows (`:1705`). She was mid-block
  in a long take; Write lands her at its first word.
- **Blocks → Write (row 20):** `applyWriteIntent` (`:1743`) computes the exact offset and sets the
  selection; verify whether it scrolls — her report says it does not. The arrival road scrolls with
  `scrollRangeToVisible`, which on TK2 before layout can leave the caret off-screen (TEXTKIT2 §2; the
  Phase 6 hybrid jump exists precisely for this — `JumpPrimitive.jump(toOffset:textView:scrollView:)`,
  `JumpPrimitive.swift:94–140`).
- **Write's fan panel → Takes (row 8):** `consumeLandings` blooms and focuses (`TakesChoreographer.swift:159–176`)
  and the article column has no scroll-to at all (only the fan strips page, `TakesBoardView.swift:1001/:1055`).

**The fix, one shape:** `FocusedBlock` gains `utf16Offset: Int?` (reported by Write's caret context at
`EditorViewModel.swift:2544` and by the live pane's selection in Takes at `TakesViewModel.swift:521`;
persisted as a third field — old memories without it read as offset nil → the block start, today's
behavior). Every landing consumes it: Write lands at `range.location + min(offset, length)` and reveals
via `JumpPrimitive` (with the arrival's one next-turn retry when the window lags); the Takes board's
article gains a `ScrollViewReader`/`scrollPosition(id:)` over its slots and scrolls the landed slot to
the top band once per landing (the typewriter room already exists, `:582`); `LandingTarget.utf16Offset`
(`LandingTarget.swift:21–37`) is the same idea one door over — reuse its name. **Pins:** the memory
round-trips the offset; `bareArrivalLanding` returns start+offset (clamped); the Blocks→Write intent's
caret rect is inside the scroll view's visible rect on a 250-paragraph fixture (the latency-pin
fixture); the board's requested scroll id equals the landed slot (a model-level pin — KnownIssues row 43
records that the real-click rig cannot mount the whole workbench, so the board's scroll is walked, not
rigged). **The walk:** Write mid-block → ⌘2 → ⌘1 lands on the same word; Blocks "open in write" on a far
block scrolls there; the fan panel's "Open Takes mode" arrives with that block bloomed AND in view.

### 3.3 Rows 18 · 19 — chrome titles are one-shot reads

`PostTitleLabel` reads the stored title and the display title ONCE per note (`.task(id: postID)`,
`PostDetailView.swift:646–657`); `WorkspaceModel.resolveTitles` reads the open set ONCE per change of the
SET (`titleSubjectsKey`, `WorkspaceModel.swift:382`; the trigger `SidebarView.swift:259`). Neither watches
the rows, so a rename (row 18) or a date change on a nameless note (row 19) shows only where the write
happened. **One fix:** a bounded observation of the `container` rows in question (title, entry_date,
created_at — the three inputs of `DisplayTitle.note`) — `ValueObservation` over the open set for the
strip, over the one note for the masthead — so a sync pull's rename lands too. Cost ∝ open notes, never
the corpus (P1). **Pins:** an observation test on the query (rename → the strip's title map changes
without a subject change; date set → `noteDisplayTitle` changes and the label's `displayed` follows);
the walk covers the Library rows and the Journal navigator, which have their own observations.

### 3.4 Row 3 — the scissors and the end slot

By design the end is placeable: `legalCutPositions` = `BoundarySnapping.boundaries(in:granularity: .word)`
"ends included (the parking slots)" (`DivideWCeremony.swift:226–234`); `flowItems` ends with `.slot(end)`;
`WCutPlacement.wordStep(forward:)` from the last boundary stays at `boundaries.last`. So one of three
links is broken — **pin each, in this order, before touching anything:** (i) `legalCutPositions(of:
"Alpha beta.")` contains `11` (the end after the terminator) — if the word scanner stops before trailing
punctuation, the end is absent and the ceremony's own doc is wrong; (ii) `CutFlowGeometry.make(...)`
lays the end slot out at the last line's end — `size.width = min(widest, width)` (`CutFlowGeometry.swift:105`)
can clip a slot when the LAST line is the widest, and the view frames the flow to `geometry.size`
(`DivideWSheet.swift:329`), so a slot past the frame is outside the hit shape; (iii) `nearestSlot(to:)`
resolves a point to the right of the last token to the end slot (`:112–124`). Her screenshot shows the ✂
resting one slot short — between "escape" and "simultaneously." — the exact picture (ii) would paint.
Whichever pin reds is the defect; if all three pass, the fault is in `WCutFlow`'s gesture wiring
(`DivideWSheet.swift:347–356`). In 18c the rebuilt face makes this moot for the pointer (the ✂ lands by
character hit-testing), but the pure brains keep their pins.

## 4. The four letters

### 4.1 — 17l · the evening's defects (FIXES; the standing-17 discipline, four one-surface batches)

**Goal.** Every defect row above FIXED with its pin, or DISMISSED AS HOLLOW, or DEFERRED with an owner —
and each batch WALKED on the dev-store Debug build before its record closes.

**Batch a — "blocks are born by typing" (Write's tail road).** Rows 1 · 28 · 31. The §3.1 pins first
(both states); then F1 (a)+(b) in `BlockRangeIndex.verdict` + the editor's verdict handling
(`EditorViewModel.storageDidEdit` / the gate, the `.openTail` arm at `:1054`), F2 as a belt if the trace
wants it; the bottom bar's honesty checked (row 28). **Editor seam → Fable review.** The identity oracle
runs per keystroke in DEBUG (13l) — expect it. The macOS-26 widening rule binds any attribute stamp
(TEXTKIT2 §3): F1(b) moves a block's range by one unit — stamp the block-ID attribute over the verdict's
range, never the report's. Evidence: the pins + her scenario walked (a paragraph, ⏎, pause, click back
to the end, ⏎, write → a new block), captured to `…-screens/batch-a/`.

**Batch b — the landing family.** Rows 7 · 8 · 20 per §3.2. Files: `BlockHistoryPane.swift:131`
(`FocusedBlock`), `CurrentBlockMemory.swift`, `CommandRouter.noteFocusedBlock` (`:126`), `EditorViewModel`
(`:1702–1707`, `:1729`, `:1743–1770`, `:2544`), `TakesViewModel.swift:521`, `TakesChoreographer.swift:159–176`,
`TakesBoardView.swift` (the article ScrollView, `:503–560`), `JumpPrimitive.swift`. The Act 10 "one
current block" pins (`CurrentBlockMemory`'s) ride unmodified — the offset is additive. **Editor
seam-adjacent → Fable review.**

**Batch c — the Takes faces.** Rows 6 · 14 · 15 · 16. (6) `PaneSurface` takes the indicator style through
its appearance push (models never read `@AppStorage`; the setting is `ThemeStore.settings.editingIndicator`,
`ThemeStore.swift:60`): `.off` → the rest hairline only; `.outline` → today's ring; `.background` → a wash
fill in the pane's frame (BlockDecor's background grammar). Every host follows — Takes, Lenses, Compare,
Canvas (`CanvasView.swift:799` names the pane as the ONE ring's owner), and the Read edit pane's own
overlay ring (`ReadEditPane.swift:148`) folds into the same rule. R22's reason for the ring ("among many
editable surfaces, the ring is how you know which is live") is recorded in the disposition; her ruling
is that the preference governs. (14) `TakeCardFrame` — the bar as an overlay of the card frame; a
geometry pin (bar height == card height on a 40-line take). (15) the "＋ new block" door in the empty
state of Takes AND Lenses (the minted pane takes the ring; "Nothing here yet" stays as the line above the
door); an empty first block is legal (I10 — a live variant with empty text) and Write treats it as block 1
(⏎ at its end opens the tail). (16) trace first — measure the published height after a 30-line deletion
in a pane; if the estimate lags, run `ensureLayout(for: documentRange)` on the PANE after a shrinking edit
(a pane is one take — bounded by the take, P1 holds) then remeasure; pin: the published height shrinks
within one turn. Evidence: the walk in both voices, the indicator setting cycled through all three.

**Batch d — the chrome singles.** Rows 9 · 10 · 11 · 12 · 13 · 17 · 18 · 19 · 21 · 27.
- (9) `ShellSplit.divider`: the grip becomes a real layout participant over the seam (a ZStack with
  `.zIndex(1)`, ≥ 12 pt wide, `.contentShape` explicit), the cursor via a tracking-area-backed hover so
  the editor's I-beam never wins inside the grip; push/pop balanced. Pin: the grip's frame width (a
  DEBUG geometry oracle, the `SidebarGeometry` pattern) + a hands-on walk.
- (10) the Messages fill-code popover: ONE Sonnet lookup (the CLAUDE.md lookup exception) for how macOS
  26 decides a text field is eligible for one-time-code AutoFill and how an app opts a field out
  (`textContentType`, `NSTextField.contentType`, `isAutomaticTextCompletionEnabled`); the hypothesis to
  test first is the all-digit DATE prompt (`TextField(displayed, …)`, `PostDetailView.swift:588`). If the
  prompt is the trigger, the fallback needs no API: render the date as a `Text` overlay behind an
  empty-prompt field. Evidence: the walk with a fresh SMS code on the machine (hers — a kickoff ask, §5).
- (11) the title LEADS: its leading edge = row two's leading edge (`MastheadRowTwo`'s path chip, "in no
  book"); its measure runs right until the icon cluster's leading edge minus the row gap — at least as far
  as today's centered measure reaches (centre + 190). Both faces share the frame; `.multilineTextAlignment`
  → leading. The DEBUG oracle `MastheadGeometry.titleMidX` / `titleFrame` (`:612–619`) and the rows-4/19
  pins are REWRITTEN to the new rule (leading-edge equality with the path chip; width ≥ the old right
  extent; still "never under the icons", row 80). Her ruling supersedes Act 10 rows 4/19 — record the
  delta in the closeout.
- (12) one explicit height for both title faces (the title font's line height) and one baseline; pin:
  `titleFrame.midY` equal in the `Text` and `TextField` faces.
- (13) ONE leading-edge constant for a group header and its rows' text (`SidebarView.header()`'s
  `groupPadding + rowPadding` vs the rail rows' inset): "this note" aligns with Write/Takes…, "Open" with
  the tabs; the top area's icon rows keep their own grammar. Geometry pin via `SidebarGeometry`.
- (17)+(27) `markPostsAsVersions` on a blockless post — **PROVISIONAL shape, her call (§5 Q6):**
  (a, recommended) mint the blockless post's first block (empty) inside the same transaction and anchor
  the edge on it — the link exists at once, the post shows one empty block; (b) refuse in words with a
  door ("This note has no text yet — write a first line, then mark them as versions"); (c) a
  container-level anchor is a schema change and is not this round's. Either way Compare stops speaking
  the raw error: `VersionActs.words` gains the case and Compare's door uses it (the J8 copy-truth pin:
  the receipt claims only what the op did). Pins: (a) → the edge exists, `versionPeerPosts` finds the
  peer, the minted block has one live variant; the refusal wording pin.
- (18)+(19) §3.3's observation; pins there.
- (21) the chapter count and the ⋯ share ONE trailing column (`menuIndicator(.hidden)` on the row menu,
  or a fixed trailing column both rows use); geometry pin: trailing edges equal.
Evidence: the walk of every row, both voices; captures per row.

**17l's pins summary:** every bug-class row lands red-on-old (the behavioral-revert form where a code
revert is impractical — the 17a precedent); rows 11 · 13 are taste corrections she ruled and need geometry
oracles, not red-on-old.

### 4.2 — 18c · divide keeps the takes on top (PRODUCT: the default reversed; the ceremony rebuilt)

**Her ruling (verbatim, 2026-09-06):** *"I know I said that should be the default, but I honestly believe
now that if you divide, the takes should automatically stay on the top block that you divided."* And on
the ceremony: *"Takes should automatically be selected in the divide ceremony to come along with and
should automatically have the scissors at the end."*

**Batch 1 — the default + the ceremony's defaults + the end slot (mechanics; one session).**
- **THE KEEP-ON-TOP DEFAULT, composed — zero core change.** The Mac's fanned divide (`EditorSurfaceController.swift:419–500`,
  `TakesStructureController.swift:437`) stops calling `divideDuplicating` and calls `Operations.divideW(blockID,
  cuts:)` (`Operations+Structural.swift:320`) with: the DISPLAYED take's cut = the gesture's snapped position
  (`BoundarySnapping`, S4-22 — unchanged); **every OTHER active take's cut = its text's UTF-16 length —
  parked at the END**, which by S4-22 ruling 2 rides that take WHOLE into the FIRST block. Result: B's fan
  = the displayed take's first half (chosen, per the per-side rendered rule at `Operations+Structural.swift:~403`)
  + every other take whole; C's fan = the displayed take's second half (chosen); A released to lineage
  preserved whole (the W resolution; reversible via `placeBlock`, ⌥⌘Z). The composition lives in
  `Shared/` beside `CarryAllMerge` (`FannedDefaults.swift:38`) — `KeepOnTopDivide.compose(displayedID:,
  cut:, fan:) -> [String: Int]?` — so the phone can adopt it. Edge cases the composition must speak: an
  EMPTY other take cannot park (`legalCutPositions` = [] — `divideW` refuses an empty take's cut as
  `invalidCut`) → leave it UNMARKED (it stays on A in lineage) and count it in the receipt; the displayed
  take's cut at its own start/end refuses as today ("nothing to divide"); the F-3 guard (displayed take
  gone from the live fan) → `takesChangedDivide`. Receipt (`FannedDefaultsCopy.divided` rewritten under the
  J8 copy-truth pin): "Block divided — the take you were in split across both blocks; N other takes stayed
  on the first. ⌥⌘Z undoes." **Canon delta drafted for the closeout (applied by the closeout, not
  composed):** AppSpec §9's `divideDuplicating` paragraph gains the 2026-09-06 supersession for the MAC's
  default (the op stays in core, the phone's shipped default until its own ruling); OverallModel §7's
  merge/divide paragraph unchanged; `FannedDefaults.swift`'s header updated. **The phone (§5 Q2):** one
  brain argues both flip (MobileSoul §3); her ruling tonight was about the Mac — PROVISIONAL: the Mac
  flips now, the composition ships in `Shared/`, the phone's flip is a MobileSoul parity row unless she
  rules both at the kickoff. **Does the Mac keep a "duplicate" door?** Not asked for; default: the
  duplicate road retires from the Mac's menus (the ceremony remains the deliberate door, ⌥⌘⇧D, and can
  express any other arrangement); her call if she wants it kept.
- **THE CEREMONY'S DEFAULTS:** `DivideWCeremony.State` seeding (`DivideWCeremony.swift:177–215`) marks EVERY
  live active take; the seed's cut at the gesture's snapped position; every other take's cut = its end
  (parked → whole into the first block); the `CutPropagation` proposal survives as the ⌥←/→ strong-boundary
  step and (optionally) a faint ghost slot — never the default position. `confirmBlocker` (`:87–110`) is
  untouched and correct: with the seed cut mid-text the confirm is live; if she parks the seed too, the
  "second block would be born without a take" refusal speaks. Confirming the sheet UNCHANGED reproduces
  the new default byte-for-byte (the instant divide and the ceremony agree — the S4-23 shape for merge,
  mirrored). Pins: the seeding matrix; instant-default == unchanged-ceremony on a three-take block.
- **THE END SLOT (row 3):** §3.4's three pins in order; fix the link that reds.
- Mobile note for the record: `divideDuplicating` remains the phone's default (Q-M2, built 2026-08-09,
  the parity chain's Stage A) until its catch-up adopts the shared composition; nothing in `VariorumMobile`
  is touched by this letter.
- **Review: Fable** (a default's meaning + `Operations` composition).

**Batch 2 — the ceremony's FACE, rebuilt behind a MOCKUP GATE (one session after her approval).**
Her verdict: *"so ugly with the spacing between the words, the way that you have to scroll to get the
different takes, just overall."* The causes are known: the token flow's fixed 9-pt inter-word slots
(`CutFlowGeometry.slotWidth`, the QoL round's L1 trade for cut-independent layout), a 240–420-pt scrolling
stack of takes (`DivideWSheet.swift:90–98`), three stacked explainers, system fonts. **Direction for the
mockup (a self-contained local HTML in `…-screens/18c-mockup/`, per her never-publish-artifacts rule; she
approves before a line of SwiftUI):**
1. **Real prose, natural spacing.** Each take renders as prose in the voice's body face; the ✂ is an
   overlay glyph in the inter-word gap at the cut, drawn without widening the gap (the layout stays
   cut-independent — L1's lesson kept — because the glyph overlays instead of occupying). Pointer placement
   by character hit-testing on the rendered prose (`characterIndex(for:)` on a read-cheap TK2 surface, or
   the flow geometry with a space-width slot and the glyph overlaid), snapped to the take's legal set
   through the one brain (`CutFlowGeometry.nearestSlot` semantics, bounded by the take's length — P1).
   Strong boundaries keep their extra catch.
2. **Takes side by side, not stacked:** two or three columns at the sheet's width, the seed take first and
   emphasized; the sheet sized to the window (a large sheet, or a full-window modal like the merge
   ceremony's grammar); no inner scroll for ≤ 3 takes, columns scroll individually beyond.
3. **A calm header per take** replacing the checkbox row: `take · shown here · ✂ at the end → whole take
   stays on the first block` as one status line; the checkbox stays (unchecking still means "stays on the
   original, in lineage"), styled in the voice.
4. **Explainers folded:** one line ("Each ✂ splits its take; ✂ at the very end keeps the whole take on the
   first block") with the long form behind `?` — the Shortcuts & Dictionary helper's grammar.
5. **The confirm blocker** keeps its sentence, in the voice's warning color; the buttons in the voice.
**Pins:** the pure brains (`WCutPlacement`, `CutFlowGeometry`, `DivideWCeremony.State`) keep every test;
the new hit-test path pins that a click at character k lands the nearest legal slot and that the end
slot is reachable by click, drag and → (row 3's regression); a performance pin at her real scale (four
3,000-word takes — the L1 measurement: one mount + one click well under a second). **Evidence:** the
walk — open the ceremony on a three-take block, park, split, confirm, ⌥⌘Z — captured in both voices.
**Review: Fable** (the ceremony is a structural door).

### 4.3 — 18d · the sidebar's note box, the outline's room, the note's memory (DESIGN, her rulings)

**Batch 1 — the book's block menu moves into the sidebar (rows 23 · 30; her item 6, verbatim in §0's
report).** Today the focused note's bar rides a right gutter in Outline (`EditorView(barPlacement: .side)`
→ `CommitBar(axis: .vertical)` in a 190-pt column, `EditorView.swift:113–125`; `BookView.swift:1597–1615`)
and floats at the right in the paged Book mode. **Her ruled shape:** when a BOOK is open in an EDITING
mode (Outline · Index · Book — never Read), the sidebar shows a **box in the place the "this note" rail
occupies for a note, the SAME HEIGHT as that rail box** (the rail group's height — `SidebarGeometry.railGroupHeight`
exists in DEBUG; make it one shared constant/measurement), holding the focused note's bar arranged
vertically; with nothing focused (or after clicking out) it reads **"no note selected"** (calm, muted).
The right gutter's BAR retires; whether the unfocused rows' details line (the calm facts of row 13) stays
in the gutter or moves into the box is hers (§5 Q4 — recommendation: the box shows the SELECTED note's
facts when it is not live and the bar when it is; the gutter retires whole and the prose measure
recentres). **Architecture rule (CLAUDE.md, the P39 refinement):** the sidebar never constructs or holds
the book's `EditorViewModel`; `RootView` composes — the book publishes its live focused note through the
router's existing detail registration (`CommandRouter.registerDetail`, `:47`) or a parent-owned slot, and
the sidebar RENDERS a bar view it is handed (rendering a sibling's view is legal composition). The
vertical `CommitBar` must FIT the box's height: measure it; if it exceeds the rail's height at any window
size, the box scrolls internally — it never grows. **Pins:** a geometry oracle (box height == rail group
height); "no note selected" renders when `liveFocusedPostID == nil`; the bar renders for the focused
postID; the paged Book mode shows no floating card. **Walk:** Outline/Index/Book with and without a
focused note, both voices, narrow window.

**Batch 2 — (moved to 17l batch d: the title's return to the left is a one-surface chrome correction and
runs with the masthead's other two rows.)**

**Batch 3 — the outline's room (rows 22 · 26 · 33).** (a) Build the LEADING-edge variant of `SideColumn`
once in `Core/Views` (the shared Mac-chrome home; the hoist rule) — a draggable, remembered seam whose
panel sits on the left (the Blocks workbench's `WorkbenchSeam` is the sibling pattern); the width brain
(`SideColumnLayout.width`) is already pure and pinned — the leading variant adds its mirror pin. (b) The
book navigator (`BookView.swift:368–420`, fixed `.frame(width: 190)` at `:645`) becomes that column:
remembered width (`bookNavigatorWidth`), minimum 190, maximum ~360; chapter rows at a generous pitch
(the sidebar's 30-pt pitch as the reference; chapter groups separated by the mockup grammar's spacing).
(c) The note Read mode's contents column (`ReadModeView.swift:140`, `NoteIndexColumn.width` = 340 fixed)
becomes the same column: remembered width, minimum ~240, so long first lines stop truncating mid-word
(the correction round's row 6 named the same picture). **Pins:** the leading width brain; geometry pins
for row pitch and the two columns' remembered widths across remount. **Walk:** drag both seams, relaunch,
widths remembered.

**Batch 4 — remembered note lengths (row 25).** `BookViewModel.rememberedSurfaceSizes` (`:389–395`) and
`SurfaceSizeMemory` (`StableSurface.swift:25–32`) are session-only; persist per note in a LOCAL-ONLY store
(never synced): UserDefaults keyed `surfaceSize.<postID>` = `"w|h|voice|fontSize"` (the `CurrentBlockMemory`
precedent) — or, if the count of remembered notes argues for it, a local-only SQLite table (its own schema
commit, no lockstep — local-only tables are never on the wire). Safety comes free: R1-1's settle rule
adopts the real size whether taller or shorter, and `stableSurfaceWidthTolerance` refuses a memory taken
at another width — so a stale memory can never hold a permanent gap or reserve at the wrong width. Cost
∝ the open book's notes (P1). **Pins:** a memory read back after model re-init; the width-mismatch
refusal; a memory shorter than reality settles up. **Walk:** open Sherlock, land on a far story, relaunch,
land again — no adjustment.

**Review:** Opus (chrome and composition; no editor seam, no `Sync/`). If batch 1's composition touches
`EditorViewModel`'s lifecycle, add Fable.

### 4.4 — 18e · markdown marks out of sight (a NEW editor capability; design first)

**Her ask (verbatim):** *"I need a setting where you don't see the markdown marks - it's honestly annoying
to have to always see them. I want markdown items to disappear unless you're at the edge editing them or
turn seeing them back on, it's annoying to see the underscores on the bold all the time."*

**Where the marks come from today.** `MarkdownFaceCore.restyle` (`MarkdownFaceCore.swift:107–200`) styles
the touched LINES on the STORAGE — never a TK2 rendering attribute (TEXTKIT2 §3) — coloring each span's
`markers` in `palette.marker` and the content bold/italic/strike/code-chip/link. The read tiers already
hide markers (`FlowParagraph.swift:86`, `inlinePresentationIntent`; the Read page in image 12 shows the
italic without its asterisks). Nothing conceals in the LIVE editor.

**Design options (the sitting rules one; §5 Q5):**
- **(a) FADE — recommended first form.** With the setting on, markers render in the paper color (or ~0
  alpha) everywhere EXCEPT the span the caret is in or the selection touches, where they show in the
  marker color — "at the edge editing them" in her words. Zero layout change: the marks still occupy
  their width (a faint gap), caret math, identity ranges and the widening rule are all untouched;
  TK2-safe; the per-keystroke cost is the existing line restyle plus two lines on a caret move (the old
  and new caret lines) — ∝ the edit, P1. The gap is the honest cost; record it for her.
- **(b) COLLAPSE.** Markers take no width outside the caret's span (a zero-advance font / `kern`, or a
  tiny size). The width changes as the caret moves — the "view jumps when text attributes update" class
  (TEXTKIT2 §3) and a caret that lands beside a re-expanding mark. Identity ranges are still untouched
  (attributes only) but geometry moves under her; a follow-on if she wants the gap gone after living with
  (a).
- **(c) True concealment** via `NSTextContentStorage` element rewriting — custom `NSTextElement`s hit
  runtime assertions (TEXTKIT2 §3); not an option.
**The setting:** `markdown_marks` ∈ {`shown`, `hidden`} in the `setting` table (enum, no prose — the 14b
column promise holds; synced like every document setting) with a face in Settings ▸ Editor and the
editor's `Aa` menu; default `shown` (today's behavior). The reveal rule is a pure function (caret range ×
spans → the marker ranges to show) in `MarkdownFaceCore` so BOTH platforms get the brain (the phone's
face is a mobile row). The tutorial's formatting lesson gains one sentence. **Pins:** the pure reveal
rule; `restyle` with a caret range → the caret span's markers colored and every other span's faded; a
caret-move test in the harness restyles exactly two lines; the setting round-trips; the read tiers
unchanged; the phone's suite untouched. **Evidence:** the walk — type `**bold**`, move away, the
asterisks fade; click back inside, they return; toggle the setting. **Review: Fable** (editor seam).

## 5. THE KICKOFF SITTING — her decisions, bundled (nothing here is decided by a batch)

1. **Row 1's scenario (a question, not a ruling):** when Return stopped making blocks, were you typing on
   the page itself, or in the take card that opens under a block from the bar's "Takes" button? (The
   card is a pane and never crystallizes by design — row 31.) And do you recall clicking back to the end
   of the last line before pressing Return, versus typing continuously? Either answer sharpens batch a's
   pin; the fix covers both traced states regardless.
2. **The divide default's reach:** the Mac flips to KEEP-ON-TOP now (your ruling). Does the phone flip
   with it (one brain, MobileSoul §3) or at its catch-up? And does the Mac keep a "divide, duplicating
   takes" door anywhere, or does the ceremony alone cover the other arrangements? (Recommendation: phone
   at catch-up via the shared composition; no duplicate door on the Mac.)
3. **The ceremony mockup — a GATE:** batch 2 of 18c builds nothing until you approve the HTML mockup
   (side-by-side takes, real prose, the ✂ overlay, the folded explainers).
4. **The sidebar box:** (a) does the right gutter retire WHOLE (the unfocused rows' facts line too), or
   only its bar? (b) "no note selected" — your words as the copy? (c) in the paged Book mode, the box
   replaces the floating card entirely?
5. **Markdown marks:** FADE first (marks keep their width, faint) or COLLAPSE first (no width, geometry
   moves with the caret)? Where does the switch live — the `Aa` menu, Settings, both?
6. **Versions with a blockless note:** mint the empty first block and link at once (recommended), or a
   legible refusal with a door?
7. **The ring setting's reach:** the editing-indicator preference governs every live pane — Takes,
   Lenses, Compare, Canvas, the Read edit pane — not only Takes? (Recommendation: yes; R22's "many
   editable surfaces" reason recorded.)
8. **The title:** the measure runs right until the icon cluster; the left edge is the path chip's — as
   you said. This supersedes Act 10 rows 4/19 (the centered title); the 13u2 kickoff decides whether
   13u2 item 13 is thereby BUILT.
9. **Fill-code popover (row 10):** the walk needs a fresh SMS code on the Mac to confirm the fix — yours
   to trigger during the batch-d walk.
10. **Cast:** §6's recommendation, yours to redirect.

## 6. Cast, order, and the reviews (recommendation — her call at kickoff)

- **Shape:** one Fable orchestrator for the whole round (her practice for 17 entries — *"letting Opus run
  things on its own leads to an absolute mess"*, `PhaseSizingGuidance.md` §5), fresh implementer sessions
  per batch, fresh cold reviewers per ladder round. **Order:** 17l (a → b → c → d) → 18c (1 → mockup gate
  → 2) → 18d (1 → 3 → 4) → 18e. Each LETTER closes on its own dispositions before the next opens (the
  17-entry closing rule; an 18 letter closes with the standing ritual); 18e is the most separable — she
  may hold it.
- **Implementers:** Fable on 17l batch a, 18c and 18e (the seam and the default); Opus is acceptable on
  17l batches b–d and 18d under the Fable orchestrator (her stated practice: Opus implementers only under
  a Fable orchestrator).
- **Reviews (R-cor-14):** an Opus cold review on every letter; a Fable cold review on 17l, 18c, 18e.
  `notes/REVIEW_PROMPT.md` verbatim; the ladder's three-round cap; every finding dispositioned in this
  file; the hallucination guard (pin before fix; a pin green on both sides dismisses the finding).
- **Zero `Sources/VariorumCore/Sync/`, zero schema** expected across the round (18d batch 4's optional
  local-only table would be the one schema commit — local-only, no lockstep; the marker stays where
  `pre-13x` leaves it). If anything reaches `Sync/`, stop and report — the standing Fable rider.

## 7. Process (binding on every batch)

- **The correction round's rules C-1…C-7 bind by reference** (`notes/plans/act10-correction-round.md` §2b):
  one surface per implementer session · the acceptance gate is USE, not mount · no install refresh without
  a walk · a ruling delivered whole or its residue is the record's first line · scalpel never axe · calm
  chrome · quality is the bar.
- **The standing-17 rules** (`notes/plans/phase-17-standing-fixes.md` "Standing rules for every entry"):
  pin before fix; measure before believing a number; no product invention (a fix that needs a decision the
  spec does not make goes to `notes/QUESTIONS.md` — the next free number at kickoff; #90 is claimed by
  `pre-13x`); schema commits alone.
- **Session resiliency** (`notes/SessionResiliencyProtocol.md`): the orchestrator reads it at kickoff;
  every implementer brief RESTATES the checkpoint rules in its own text — commit per piece, a LIVE STATUS
  block in this file from the first commit, push after each commit, synchronous foreground waits only,
  one agent at a time.
- **Records live HERE:** batch briefs and records append under §9 as the round runs (the correction
  round's shape); the ladder's findings and dispositions likewise. Her verbatim report is never edited.
- **No commit trailer** (her 2026-09-04 rule): no `Co-Authored-By`, no `Claude-Session` lines.
- **Walk tooling:** `cliclick` + `Tools/WalkKit/` on the DEV-STORE Debug build (`io.lduarte.Variorum.debug`)
  only — never `/Applications/Variorum.app`. Captures to `notes/plans/use-report-2026-09-06-screens/<batch>/`.
- **The install refresh** follows the round's last walk (or each letter's, at her word): Release build →
  `/Applications` at a zero-instance window, the A1 backup first (the correction-round handoff's recipe).

## 8. Environment traps, baselines, coordination

- **Baselines at open:** the last recorded finals are the Act 10 correction round's (core 1525/165 · Mac
  2106/378 · spine 72/10; marker 7) — `pre-13x` is adding tests and will move the marker to 8 at its
  lockstep event. **Read `pre-13x`'s closeout for the true numbers and the marker before believing these;
  verify with your own runs.** The carry-forward flake rules stand (the Phase-12 latency pin reds under
  load; `CanvasDragTrackingTests` is load-flaky — KnownIssues rows 27–28).
- **The 13j environment traps bind verbatim** (by reference: `notes/plans/phase-13j-deletion-and-trash.md`);
  13l's identity oracle runs per keystroke in DEBUG on both platforms; the macOS-26 widening rule
  (TEXTKIT2 §3) binds every attribute stamp; the real-click rig cannot mount whole surfaces (KnownIssues
  row 43) — pin brains, walk faces.
- **Coordination with `pre-13x`:** this round starts only after `pre-13x` closes (her sequencing has it
  before 13y and before this); if `pre-13x`'s tail is still in the tree at kickoff, the kickoff waits —
  two sessions in one tree is the resiliency protocol's one forbidden shape.
- **Coordination with 13u (§1's fence):** at each letter's close, the closeout lists which 13u items this
  round touched (item 13 via row 11; item 1's family via rows 16 · 25) so the 13u1/13u2 kickoffs inherit
  decisions, never discoveries.
- **KnownIssues:** row 31 (the block-level version anchor) is TOUCHED by row 17 — amend its text if (a) is
  chosen (a blockless post now gains an anchor block); nothing else in that file changes unless a row is
  deferred out of this round, which then needs an owner.

## 9. Obligations at close (per letter, then the round)

**Each letter:** every ledger row it owns dispositioned (FIXED with its named pin · DISMISSED AS HOLLOW ·
DEFERRED with an owner in `KnownIssuesAndTechDebt.md`); the ladder complete or capped with its residue
recorded for her; the suite green (core + Mac + the tutorial spine; the iOS build green — 18c/18e touch
`Shared/`); the walk captured; for 17l a dispositions block copied into `phase-17-standing-fixes.md`'s
17l entry; for 18c the canon delta applied EXACTLY as ruled (AppSpec §9's divide-default paragraph;
§14's dated delta; `FannedDefaults.swift`'s header); for 18e AppSpec §12's formatting sentence gains the
setting.

**The round:** the master plan's pointer + running order moved on; the 17 register and the 18 row updated;
`notes/QUESTIONS.md` carries her ratify list (the PROVISIONALs: the versions shape, the phone's divide
flip, the gutter's retirement, the concealment form); the MOBILE PARITY LINE in `notes/MobileSoul.md`
(the divide composition, the reveal brain, the offset-carrying landing, the indicator-follows-setting
rule — the phone owes faces; Compare/the sidebar box/the outline room are not owed); the author handoff
`notes/handoffs/use-report-round-2026-09-06-handoff.md` with her checklist at the top (launch, restore the
field guide if lessons changed, the walk list in order); the install refreshed after the last walk; the
closeout paragraph in the master plan (the previous one archived — the lean-docs rule); push.

## 10. Image manifest

See `notes/author-reports/2026-09-06-use-report.md` (the manifest table maps every file in
`notes/plans/use-report-2026-09-06-screens/author/` to its ledger row).

---

## LIVE STATUS

*(The orchestrator writes here from the first commit: the letter and batch in flight, the last commit,
what is verified, what is next. Empty until kickoff.)*

## Records

*(Batch briefs, batch records, ladder findings and dispositions append here in run order — the
correction round's shape.)*
