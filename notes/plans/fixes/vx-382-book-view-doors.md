# VX-382 — Run: Book view doors & reds (VX-284 part B)

**STATUS: OPEN — kicked off 2026-10-18 (architect shape). Branch `vx-382-book-view-doors` · worktree
`~/dev/variorum-vx-382` · the Pro. Orchestrator session `vx-382`.** Members (sub-issues of VX-382), in order:
**VX-303 · VX-304 · VX-291 · VX-21 · VX-69 · VX-77 · VX-115.** Umbrella: VX-284 (`notes/plans/fixes/
vx-383-duplicate-note.md` §"The split" carries her rulings verbatim). Cast (her word 2026-10-17): Opus orchestrates,
`opus-implementer` builds, `opus-reviewer` cold-reviews — all at **xhigh**; no editor seam (VX-303/304 are routing
plus a landing that already exists — the tickets say so; if a trace reaches `EditorTextView`, `BlockRangeIndex` or
`PaneSurface`'s seam after all, say so to her before the ladder and owe a Fable round), no `Sync/`, custody or Keychain.
Runs WITHOUT her: VX-303's landing is ruled; VX-304's icon-or-label is the implementer's proposal, PROVISIONAL.

## KICKOFF PROMPT (paste into a fresh session on the Pro, in `~/dev/variorum`)

> /architect-phase vx-382 — Run: Book view doors & reds, part B of VX-284's split (her 2026-10-17 rulings are in
> `notes/plans/fixes/vx-383-duplicate-note.md` §"The split"; this file is your plan). Cast: Opus orchestrates,
> `opus-implementer` at xhigh, `opus-reviewer` at xhigh, fresh per unit/round. Mint the branch `vx-382-book-view-doors`
> and the worktree `~/dev/variorum-vx-382` from `origin/main`, push the branch, add your in-flight row atomically, and
> run everything from the worktree. Nothing in `Sources/VariorumCore/Sync/`, custody or the Keychain (VX-378 holds
> that slot). The stage: claim `Tools/stage` for every Mac batch and walk (no coordinator session is live at this
> writing; if one announces itself, route asks through it). VX-303 lands FIRST (the landing road), VX-304 rides it.
> Use the existing shell landing road (`ShellRouter.adopt(landing:)` → `PostDetailView.jump(to:)`); never invent a
> second landing authority; VX-360's seam is touched, not fixed. Her words rule; a decision a ticket leaves to the
> implementer is PROVISIONAL, recorded here and bundled for QUESTIONS at the merge. Close with CLAUDE.md's full ritual.

## Members and the rulings they carry (each ticket's body is the trace; her words are already on them)

- **VX-303** (High) — every book open door (five doors: `BookView.swift` ~:2710/:2734/:2765, `BookIndexView.swift:934`,
  `SpreadBookView.swift:335`) lands in **Write, at her block** — her ruling verbatim: *"it can land in Write at the
  block - more consistent and useful than the note's last used mode"* — through the search-hit road
  (`onOpenSearchHit` → `RootView` → `ShellRouter.adopt(landing:)` → `jump`), with her current place: Outline/spread =
  the editor under the caret when it's that note; Index = `edit.liveBlockID` + the `onSelectionChange` offset;
  nothing live = today's plain open. For the exact caret, an offset on `ShellRouter.BlockLanding` and `jump`. Riding
  along: the book never records her caret (`CommandRouter.noteFocusedBlock` writes only when `activePostID == postID`),
  so the note box's "edit here" lands where she last was in the note's own editor — fix with the same place. Pin: a
  book door's open lands at the live block; on old code at the note's start.
- **VX-304** — the left note box (`Core/Views/SidebarNoteBox.swift`) gains an **open in Write** door in EVERY book mode
  (selected state beside "edit here"; live state on the box itself), landing through VX-303's road; icon or short
  label is the implementer's PROVISIONAL proposal (the ↗ glyph matches the title's "open ↗"; hover "Open in Write at
  this block"); "edit here" stays. Index: takes badges on blocks (`TOCRow.hasFan` is loaded; Outline's badge is the
  precedent), an in-place Takes sheet (`WriteTakesPanel(session:postID:blockID:)` over the book, flush pending
  autosave first; "Open Takes mode" refuses inside a book as Outline's does), "Takes" + "open in Write here" in the
  box for the live block; Outline → Index carries the live block (`BookAnchor` returns a `LandingTarget`). Pins: the
  badge, the sheet on the live block, the box door's landing, the mode switch's landing. Walk both voices on the dev
  store's bilingual-style book. The after-launch remainder is VX-300.
- **VX-291** — the Outline card's ▸ gets a ~22-pt hit box (`.contentShape` after the frame), a 13–14-pt glyph, the
  voiced hover wash; the ▾ twin the same box; grow outward, keep `BookOutlineHeights`' learned height; Index's chapter
  fold ▸/▾ (`BookIndexView.swift:867–874`) in the same pass (PROVISIONAL — "if she agrees"; recommended yes). Guards:
  `BookOutlineLandingTests`, `OutlineRoomTests`, `BookOutlineFacesTests`, `BookOutlineCostTests` + a visual check.
- **VX-21** — Book Panel grips only under manual order (the false-offer class); the Manual-order toast stays for
  non-drag roads. Record: `notes/plans/librarywalkpolish.md` VR-127.
- **VX-69** — the order popover takes the Escape key (menu semantics' last gap).
- **VX-77** — `OutlineRoomTests.bothColumnsChromeStaysInsideThemAtTheirFloors` is red on main (the Index chapter panel
  clips its ink at the 240-pt floor); the pin exists and is red — the trace is the work; a later main-side change
  regressed the floor behavior.
- **VX-115** — `BookCollectingDoorsTests`' door pin expects `[.openBookSettings]`; `BookView` has offered
  `.searchThisBook` beside it since 13o U3. Test-only: add the second door to the pin.

## Suggested units (the orchestrator re-sizes at kickoff and records it here)

1. **U1 — the landing road:** VX-303, then VX-304 (one session each, or one if the first lands small). Walk both voices.
2. **U2 — the small fixes and the reds:** VX-291 · VX-21 · VX-69 · VX-77 · VX-115. One Mac batch over every suite
   that exercises the changed source files (the book view family, OutlineRoom, BookCollectingDoors, the registry walk).

## Overlaps to respect (the runway's §2 conflict map, as of 2026-10-17)

- **The shell's landing road** (`ShellRouter.adopt`, `RootView`): VX-360 (Backlog, the dropped-request bug) is NOT
  fixed here; use the road as it is; the record says where a second request in one frame could still be dropped.
- **VX-383 (part C)** adds registry capabilities (the duplicate doors) in `CapabilityRegistry.swift`; this run may add
  none or one (VX-304's box door is surface-local — the registry grows only if a routed door is added). If both touch
  the registry, rebase carefully; the registry walk's sampled contexts are the usual collision.
- **VX-381 (part A)** touches gathering doors, operations and the Settings scene — no shared file expected.
- **The Index chapter panel** (VX-77) and **Index's note box doors** (VX-304) are the same surface: land VX-77 first
  if U2 runs before U1 finishes, else re-run `OutlineRoomTests` after U1.

## Environment traps (carried verbatim into every brief)

Instance checks use `pgrep -fl 'Variorum.app/Contents/MacOS'` AND discriminate by PATH (the test host matches
mid-run); treat real-store instances by STORE, not path — NEVER quit/kill one; no Release builds or /Applications
refreshes while one lives; `xcodebuild build-for-testing` compiles without the runner; Mac tests from
`App/Variorum/`, suite-level `-only-testing` only, confirm the "Test run with N tests" line; zsh `pipestatus`;
NEVER add a custom build configuration; suites running beside a live session flash the test host's windows on
screen; backups WAL-safe with UTC names, ALWAYS before touching the real store (this run never touches it);
screenshots in gitignored dirs only; never `git checkout` over uncommitted work; commit per piece and push after
every commit (`notes/SessionResiliencyProtocol.md`); synchronous foreground waits only — poll a log with
`grep -q '<EXIT LINE>' <log> && break; sleep 5` in a loop, never `tail -f | grep -m1`; never force-push, never
rewrite history; commits name their member and `Part of VX-382`, with NO attribution trailer of any kind. The dev
store's Castle credentials, if a lock screen appears, are `~/.variorum/dev-castle.env` (never invent, never commit).

## KICKOFF RECORD (2026-10-18, the orchestrator — session `vx-382`)

- **Seating:** branch `vx-382-book-view-doors` cut from `origin/main` at 745884f27, pushed; worktree
  `~/dev/variorum-vx-382`; in-flight row flipped on main (dd18259fe). Preflight complete (CLAUDE.md canon, master
  plan, TICKETS.md, QUESTIONS.md tail — latest bundle #229 — this file, the resiliency protocol, the workflow
  transition, her split rulings in the VX-383 record). SyncSpec/TEXTKIT2/MCPSpec not read: no sync, custody or
  editor-seam scope; the escape clause above stands.
- **Cast as run:** she launched this orchestrator with `/architect-phase` (a Fable session) — the plan's
  "Opus orchestrates" line is noted, the implementer/reviewer cast is exactly as she ruled: `opus-implementer` at
  xhigh, `opus-reviewer` at xhigh, fresh per unit/round, cross-checked by the orchestrator. Recorded, not re-litigated.
- **Sizing (the orchestrator's call):** THREE implementer sessions — **U1a = VX-303** (the landing road, every door),
  **U1b = VX-304** (rides U1a's road; its walk covers U1 whole), **U2 = VX-291 · VX-21 · VX-69 · VX-77 · VX-115**
  (small fixes and reds, one batch). One ladder over the run's whole diff after U2. Strictly sequential.
- **The stage this window:** coordinated by session `oct18coordinator` — NO direct `Tools/stage claim`; the
  orchestrator sends REQUEST/READY, the coordinator answers GO with the exact claim line, RELEASE + result line after.
  Implementers NEVER claim or run `xcodebuild test` outside a granted window — they build headless
  (`swift build`/`swift test`/`xcodebuild build`/`build-for-testing` are always legal) and tell the orchestrator when
  they are READY for a window, with the suite list. Windows queued: `vx-382-u1a` (batch), `vx-382-u1b` (batch + walk,
  both voices), `vx-382-u2` (batch + walk), ladder batches as needed. Pin red-on-old verification (revert → run →
  restore) happens INSIDE the unit's window, committed before any revert per the resiliency addendum.
- **Riders:** none offered — the member set is her own 2026-10-17 split ruling and the run executes without her.
- **Overlaps:** VX-381 (gatherings & tags) is live on this machine — it owns `Operations+SmartCollect`,
  `Operations+Tag`, the gathering doors, `CalmButtonStyle` and the Settings scene's `.opening` arm this window; this
  run does not edit those files (if a change there seems needed, stop and report to the orchestrator). VX-378 holds
  the Sync/-custody slot (we touch none). The shell landing road is USED, never changed in kind; VX-360's
  dropped-second-request seam is touched, not fixed — the record notes where a second landing in one frame could
  still drop. No second landing authority. Merges serialize via the coordinator.
- **Path correction from the 2026-10-13 traces:** `BookView.swift`, `BookIndexView.swift`, `SpreadBookView.swift`,
  `BookNoteBox.swift`, `BookAnchor.swift` live under `App/Variorum/Variorum/Features/BookView/`;
  `SidebarNoteBox.swift` under `App/Variorum/Variorum/Core/Views/`; `ShellRouter.swift` and `RootView.swift` at
  `App/Variorum/Variorum/`. Line numbers in the briefs are from the 2026-10-13 read-only trace — RE-VERIFY on the tip.

## IMPLEMENTER BRIEFS (each unit: read this file IN FULL first — the member bullets above, the environment traps,
your brief; work ONLY in `~/dev/variorum-vx-382` by absolute path; commit per piece naming the member +
`Part of VX-382`, NO attribution trailer, push after every commit; LIVE STATUS flipped in the same commit as each
piece — `notes/SessionResiliencyProtocol.md`'s checkpoint protocol binds from the first commit. No fix without a
self-traced mechanism; every bug-class fix lands with a red-on-old pin verified by revert. The stop-and-report lines:
any edit to `EditorTextView`, `BlockRangeIndex` or `PaneSurface` internals (consuming existing callbacks like
`onSelectionChange` is legal); any edit to VX-381's files above; any schema or `Sync/` line. A design fork the plan
does not decide → propose to the orchestrator BEFORE building that half.)

### U1a BRIEF — VX-303 (Bug, High, pre-launch): every book open door lands in Write, at her block

Her report: *"when you click open in editor it brings you to the top of the option"* — and her correction: the door
*"doesn't carry your block so it doesn't follow the existing deep-link canon rule, it just doesn't work."* A bug
against AppSpec §12's R-18l-1 ("deep links keep their targets"). **Her ruling (2026-10-13, verbatim):** *"VX-303 is
definitely pre launch, and I think it can land in Write at the block - more consistent and useful than the note's
last used mode."* So every book open door lands in **Write, at her block** (the search-hit road; `jump` forces
Write), never the note's remembered mode.

- **The five doors (2026-10-13 trace, re-verify):** `BookView.swift` ~:2710 (the expanded header), ~:2734 and ~:2765
  (the collapsed card's body and its open ↗), `BookIndexView.swift` ~:934 ("Open in the full editor"),
  `SpreadBookView.swift` ~:335. Today all five pass only the note id through `.variorumOpenPost`
  (`RootView.swift` ~:453) — a plain note-open, so R-18l-1 shows the note's start.
- **The road that already exists:** `onOpenSearchHit` (`BookView.swift:75` → `RootView.swift` ~:1274 →
  `ShellRouter.adopt(landing:)` → `PostDetailView.jump(to:)`). Send every door through it with her current place:
  Outline/spread = the editor under the caret (`editorRouter.editing`'s caret block and offset) when it's that note;
  Index = `edit.liveBlockID` + the offset from `PaneSurfaceView`'s `onSelectionChange`; nothing live = today's plain
  open. For the exact caret (not just the block's start) add an offset to `ShellRouter.BlockLanding`
  (`ShellRouter.swift` ~:155) and `jump`. No second landing authority; VX-360 is not fixed here.
- **Riding along (same cause):** the book never records her caret — `CommandRouter.noteFocusedBlock` writes only when
  `activePostID == postID`, and only a note's own editor registers (`registerDetail`), so the note box's "edit here"
  (`BookView.swift` ~:1131) lands where she last was in the note's OWN editor, not where she just was in the book.
  Fix with the same place.
- **Pins (red on old, verified by revert):** a book door's open lands at the live block (old code: the note's start);
  per-door coverage or a parameterized pin over the five doors; the edit-here rider pinned too.
- **Verification:** builds headless; the Mac batch (your pins' suites + every suite exercising the changed source —
  grep the tests for the changed types) runs in the `vx-382-u1a` window the orchestrator arranges. Tell the
  orchestrator READY with the suite list. No walk this unit (U1b's covers U1).

### U1b BRIEF — VX-304 (Improvement, Medium, pre-launch): the note box's "open in Write" door + Index takes

Her addition (verbatim): *"wait but you can't see the "open ↗" next to the note title very easily if it's a long
note even if your carat is in the right place. can you add it somewhere in this menu on the left? either as an icon
or as something else?"* And: *"you can make a ticket for the smallest useful version of the rest of book view so
index can get take badges and that open in write here would be good."* The after-launch remainder is VX-300.

- **The box door:** the left note box (`Core/Views/SidebarNoteBox.swift`) gains an **open in Write** door in EVERY
  book mode — selected state beside "edit here"; live state (Outline, the spread, Index's live block) on the box
  itself. It lands in Write at her caret's block through U1a's road. "Edit here" (edits INSIDE the book) stays —
  this door LEAVES for the note's own editor. **Icon or short label is YOUR proposal, PROVISIONAL** (the ↗ glyph
  matches the title's "open ↗"; hover "Open in Write at this block") — record your choice and reasoning in this file.
- **The Index slice:** (1) takes badges on Index blocks (`TOCRow.hasFan` is loaded — `TakesQueries.swift` ~:297;
  Index draws blocks at `BookIndexView.swift` ~:1589–1690; Outline's badge is the precedent). (2) an in-place Takes
  sheet: `WriteTakesPanel(session:postID:blockID:)` over the book, pending autosave flushed first; the panel's "Open
  Takes mode" refuses inside a book as Outline's does. (3) the box gains "Takes" + "open in Write here" for the live
  block ("open in Write here" = `edit.liveBlockID` + the `onSelectionChange` offset through U1a's road). (4) Outline
  → Index carries the live block (`BookIndexView.swift` ~:712–729 already consumes block landings; `BookAnchor`
  returns a `LandingTarget` for this arm).
- **Pins (red on old):** an Index block with takes wears the badge; the sheet opens on the live block's takes; "open
  in Write here" lands at the live block; a mode switch Outline → Index lands at the block.
- **Verification:** the `vx-382-u1b` window = the Mac batch + THE U1 WALK in both voices on the dev store's
  bilingual-style book (screenshots in a gitignored dir; the walk covers U1a's doors too). READY to the orchestrator
  with the suite list and whether the walk changes the dev store's posture (it should not — no Castle, no reset).

### U2 BRIEF — VX-291 · VX-21 · VX-69 · VX-77 · VX-115 (the small fixes and the reds)

Work the member bullets above (§"Members and the rulings they carry") — they are complete. Additional trace from the
tickets:

- **VX-291 (XS):** the ▸ is `Text("▸")` at `tokens.small` (11.5 pt), faint ink, `.padding(.horizontal, 2)` —
  a ~11×14-pt target INSIDE the card's own Button, so a near miss opens the note. The ▾ twin (~:2694) is ~17×18 pt
  with `VoicedButtonStyle(.quiet)`. Fix per the bullet (22-pt `.contentShape` AFTER the frame, 13–14-pt glyph, voiced
  hover wash, both states one control, grow OUTWARD keeping `BookOutlineHeights`' learned height — the 46-pt chrome
  constant ~:173–206). Index's chapter fold ▸/▾ (`BookIndexView.swift` ~:867–874) in the same pass — PROVISIONAL
  (recommended yes), record it. Guards: `BookOutlineLandingTests`, `OutlineRoomTests`, `BookOutlineFacesTests`,
  `BookOutlineCostTests` + the walk's visual check in both voices.
- **VX-21 (Bug):** grips only under manual order (the false-offer class — §12's rule: a drop outline lights only
  where the drop would act); the Manual-order toast stays for non-drag roads. Required reading:
  `notes/plans/librarywalkpolish.md`'s VR-127 row. Pin red-on-old.
- **VX-69:** the order popover (the Bookcase masthead's order ▾) takes the Escape key — menu semantics' last gap.
- **VX-77 (Bug, red on main):** `OutlineRoomTests.bothColumnsChromeStaysInsideThemAtTheirFloors` fails — "Index
  chapter panel clipped at its 240-pt floor: ink at 0.0 pt". The test is untouched since 18d; a later main-side
  change regressed the floor behavior. **The pin exists and is red — the trace is the work:** find the regressing
  mechanism (bisect if needed — never guess), fix the behavior, the existing pin goes green. No new pin needed; name
  the traced mechanism in the commit.
- **VX-115 (Test-only):** `BookCollectingDoorsTests`' door pin expects `[.openBookSettings]`; `BookView` has offered
  `.searchThisBook` beside it since 13o U3 (main 90c081c4). Add the second door to the pin — a staleness fix, no
  behavior change, no red-on-old owed (the fix IS the test).
- **Ordering inside the unit:** VX-77 first (OutlineRoomTests must be green before VX-291's chrome rides the same
  surface), then VX-291, then the rest. Re-run `OutlineRoomTests` at the end regardless (U1 touched Index).
- **Verification:** the `vx-382-u2` window = the Mac batch over every suite exercising the changed sources + a short
  walk (both voices where a face changed: the ▸/▾, the grips, the popover). READY with the suite list.

## LIVE STATUS

| Piece | State |
|---|---|
| Kickoff (seating, in-flight row, Linear In Progress, coordinator announce, briefs) | DONE 2026-10-18 |
| U1a — VX-303 (the landing road) | IN-PROGRESS — piece 1 (seams) 482549002 · piece 2 (the fix) 7cbaf633b · pins committed, compiling (build-for-testing green) — batch + red-on-old PENDING the `vx-382-u1a` window; the edit-here rider awaits the orchestrator's ruling on R-1 (§U1a RECORD) |
| U1b — VX-304 (the box door + Index takes) | NOT STARTED |
| U2 — VX-291 · VX-21 · VX-69 · VX-77 · VX-115 | NOT STARTED |
| Review ladder (opus-reviewer, whole diff) | NOT STARTED |
| Closeout (canon deltas, tickets, PR, handoff) | NOT STARTED |

## U1a RECORD — VX-303 (implementer: opus-implementer, 2026-10-18)

**Not done yet (kept current):** the edit-here rider (design fork R-1 below, awaiting the orchestrator's ruling —
not built); red-on-old and the Mac batch (PENDING the `vx-382-u1a` window). No walk this unit (U1b's covers U1).

### The trace, re-verified on the tip (a87980768)

- The five doors: `BookView.swift` ~:2710 (expanded header), ~:2734 / ~:2765 (collapsed card body / its open ↗),
  `BookIndexView.swift` ~:934, `SpreadBookView.swift` ~:335 — each posted `.variorumOpenPost` with the note id only;
  `RootView` (~:454) turned it into `router.pendingSelection = .post(id)` → `adopt` with no landing → a plain open, so
  R-18l-1's first-open rule showed the note's START in its remembered mode. Confirmed by reading.
- The road: `BookView.onOpenSearchHit` → `RootView` (~:1274) `open(.post, blockID:, find:, in: pane)` →
  `ShellRouter.adopt(landing:)` parks a `BlockLanding` → `PostDetailView(initialBlockID:)` → `jump(to:)`, which reads
  the block's start in `Queries.renderPost` and forces `mode = .write`. `BlockLanding` carried no offset.
- Her place: Outline/spread mount the book's one editor (`BookViewModel.liveFocusedPostID`); `EditorRouter.editing`
  is the editor under the caret and `EditorViewModel.caretIdentity()` (existing, read-only) gives (block, offset).
  Index: `BookIndexEditModel.liveBlockID`/`livePostID`; its live `PaneSurfaceView` passed no `onSelectionChange`, so
  nothing reported the pane's caret.
- The rider: `CommandRouter.noteFocusedBlock` (~:247) returns at `guard activePostID == postID` — in a book no detail
  is registered, so book carets never reach `CurrentBlockMemory`; `BookView.editHere` (~:1131) reads
  `currentBlock(for:)` = the note's OWN editor's memory. "edit here" renders only in the box's `.selected` state
  (`SidebarNoteBox.editDoor`), i.e. exactly when NO note is live — so "the same place" as the doors' (a LIVE place)
  is always nil at that moment: the rider needs the book's place REMEMBERED past the live state. That is R-1.

### Pieces

1. **Seams, behavior-neutral** (commit below): `ShellRouter.BlockLanding.offsetInBlock` + `adopt(…offset:)` +
   `landingOffset(for:)` (parked/expired/spent with the landing, `landingFind`'s shape); `PostDetailView
   .initialOffsetInBlock` + `jump(to:offsetInBlock:find:)` via the pure `PostDetailView.landingOffset` (clamped to the
   block's length; nil = the block's start, every existing road unchanged); `RootView`'s road widened; the pure brain
   `Features/BookView/BookOpenDoor.swift` (not yet consulted); the Index's live block + pane caret reported to
   `BookViewModel` (`noteIndexLiveBlock` / `noteIndexCaret`, `@ObservationIgnored`; the pane's existing
   `onSelectionChange` consumed — no `PaneSurface` edit); the five buttons now call ONE function,
   `BookView.openInWrite(_:)`, whose body is TODAY'S broadcast (so this commit changes no behavior), published in
   DEBUG as `BookOutlineGeometry.openDoors` (the focus door's pattern) for the pins.
2. **The doors carry her place** — DONE 7cbaf633b: `openInWrite` consults `BookOpenDoor.place`, flushes the
   note's pending typing (`flushExistingAutosave` — the store must hold the text the caret's offset is measured in
   before `jump` reads it), and rides `onOpenSearchHit(postID, block, offset, nil)`; nothing live ⇒ the same road
   with no block (a plain open); no road (a hostless book) ⇒ nothing (the search passage's rule; the old broadcast
   was app-wide). Red-on-old = revert 7cbaf633b ALONE (piece 1 keeps every seam the pins call).
3. **The pins** — committed with this record flip, compiling (build-for-testing green; runs PENDING the window):
   `VariorumTests/BookOpenDoorTests.swift` — `BookOpenDoorRuleTests` (pure: the brain per mode, the clamped landing
   offset, the offset riding the park; new-API, not red-on-old by construction), `BookOpenDoorMountTests` (per mode
   — outline · spread · index — through a mounted book with the road captured: the live note's door rides with
   (block 2, her offset), another note's door — the collapsed card's case — rides plainly; RED ON OLD expected: nothing
   rides, the door broadcast), `BookOpenDoorShellTests` (the real shell: the note left in Lenses opens in WRITE with
   the caret at block 2's start + 9; RED ON OLD expected: Lenses / no Write caret at her place).

### Recorded edges (not fixed here)

- **VX-360's seam, touched not fixed** (`pendingSelection`'s `onChange` writes its own value, so the second of two
  requests in one frame is dropped): the doors no longer ride `pendingSelection` — they call `RootView.open` →
  `ShellRouter.adopt` directly, as the search passages do — so a door's OWN request is outside that drop. Where a
  door's landing can still be lost: a `pendingSelection` request (⌘K, a broadcast, back/forward) adopted in the same
  frame AFTER the door's adopt expires its park (rule one — a navigation expires the park) and the later navigation
  wins; a door carrying a place awaits one flush before its adopt, which widens that window by a turn.
- **The collapsed card's two doors are always plain opens** (focus implies expansion, so its note is never live) —
  their coverage is the mount pin's "another note" arm, a non-regression line, not red-on-old.
- **Spread in its Takes form:** the active page mounts the takes board, not an `EditorViewModel`, so no editor is
  under the caret for that note — the door opens plainly (the brief names the editor under the caret only).
- **The open tail:** a caret in the Outline editor's open tail (no block yet) has no `caretIdentity` — plain open.
- **Nothing live ⇒ the remembered mode still decides** (the brief's "today's plain open"); her ruling's "never the
  note's remembered mode" is met wherever a place rides. Flagged for the orchestrator, not re-opened.

### R-1 — the edit-here rider's design fork (PROPOSED to the orchestrator; NOT built)

The plan says "fix with the same place", but at the press of "edit here" nothing is live (above), so the book's
place must be REMEMBERED. Where it lives is not decided by the plan:

- **(A) — recommended.** `CommandRouter.noteFocusedBlock`: a report for a note OTHER than the active detail's feeds
  the per-note MEMORY (`currentBlocks.remember`) and nothing else — the observed identity and its offset stay the
  active detail's (the guard's documented purpose: "a background pane's caret is not 'the block you're in' for the
  panel beside the foreground one"). Plus the Index's live pane reports through the same door (ReadEditPane's
  precedent). Then `editHere` (which already reads `currentBlock(for:)`) and the Index landing's entry caret
  (`PaneCaretLanding.entering`) land where she was in the book, with no new state. Spec ground: `CurrentBlockMemory`'s
  own doctrine — ONE current block per note, every surface reports, every mode enters on it. Visible side effect (the
  reason it is a ruling, not a fix): R-18l-1's RE-open this run (`sessionFact`) would also restore a place she last
  had in the book (or in a Compare/Lenses peer column) — arguably exactly "restores where you were", but it reaches a
  door outside the book.
- **(B)** A book-scoped memory on `BookViewModel` (per note, session-only), fed by the Index pane's report and, for
  Outline/spread, by a NEW caret callback out of the inline `EditorView`/`EditorViewModel` (the book cannot hear the
  editor's caret offset otherwise without sampling it at transitions, which races the editor's teardown). No effect
  outside the book; costs an editor-adjacent hook.
- **(C)** Leave the rider as recorded and fold it into VX-304/VX-300 (the box's own door redesign).

### ORCHESTRATOR RULINGS on U1a (2026-10-18, repo-first before the build proceeds)

- **R-U1a-1 — R-1 is ruled (A), PROVISIONAL.** Grounds: (1) the ticket's own trace names the `noteFocusedBlock`
  gate as the mechanism and says "fix with the same place" — (A) is that fix; (2) `CurrentBlockMemory`'s doctrine is
  ONE current block per note, every surface reports — (A) extends the one existing authority, while (B) mints a
  sibling memory AND needs an editor-adjacent hook (this run's stop line); (3) (C) defers ruled scope the member
  bullet carries, with (A) cheaply available. The visible side effect (an R-18l-1 re-open this run may restore a
  place she last had in the book or a Compare/Lenses peer column) is read as consistent with R-18l-1's own words —
  "restores the page she left" — and goes to her bundle as a PROVISIONAL, options (B)/(C) recorded above.
  **Two guards required with (A):** (i) mount-time/programmatic selection noise from a non-active surface must not
  clobber a fresher remembered place — verify what fires reports for non-active notes at mount and guard it (the
  N14/starved-host class: state computed before first display is garbage); (ii) a pin that a non-active note's
  report feeds the per-note memory WITHOUT changing the active detail's observed identity (the guard's documented
  purpose preserved).
- **R-U1a-2 — every book open door forces WRITE, nothing-live included; PROVISIONAL only in that it amends the
  brief's letter.** Her recorded ruling is unconditional — "every book open door lands in Write, at her block …
  never in the note's remembered mode" — and her complaint's screenshot WAS a Lenses-at-top door. The brief's
  "nothing live = today's plain open" was the planner's fallback sketch and conflicts with the sentence it quotes
  for the MODE half; the spec outranks the sketch. So: a door with no live place opens the note IN WRITE with the
  plain open's PLACE behavior (the session's first open at the start per R-18l-1; a re-open's restored page, now
  shown in Write) — no scroll override is invented, only the mode is forced. If the landing road cannot carry
  mode-without-block cleanly, the implementer proposes before building. (A door falling back to the REMEMBERED
  block when nothing is live was considered and deliberately NOT built — first-open-at-start would be violated and
  the doors' spec says live place; recorded for her bundle beside VX-300.)
