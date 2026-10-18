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
| U1a — VX-303 (the landing road) | NOT STARTED |
| U1b — VX-304 (the box door + Index takes) | NOT STARTED |
| U2 — VX-291 · VX-21 · VX-69 · VX-77 · VX-115 | NOT STARTED |
| Review ladder (opus-reviewer, whole diff) | NOT STARTED |
| Closeout (canon deltas, tickets, PR, handoff) | NOT STARTED |
