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

## HER OVERNIGHT MANDATE (2026-10-18, mid-U1b — verbatim)

> *"I want you to run ruling provisionally overnight. I'm going to sleep. You can merge to main when you're done -
> if other sessions finish first that's fine, merge in the order you finish in. if you finish, I want you to leave
> me with a handoff AND separately a completed block of everything that was done (including if new items were
> minted during the run) in this sort of format:"* — followed by the VX-382 member checklist in the runway's
> checkbox format (one `- [ ]` row per member under the part-B heading).

Applied: PROVISIONAL-and-continue through U2, the ladder and the closeout; the PR merges to `main` at the finish
(closeouts serialize — merge in finish order with the other live efforts); the closeout delivers BOTH the author
handoff (`notes/handoffs/vx-382-handoff.md`) AND, separately, the completed checkbox block — every member `[x]` with
its outcome, plus any tickets MINTED during the run listed in the same block.

## THE NIGHT'S MERGE & RELEASE PROTOCOL (her word via the coordinator, 03:3x MDT — recorded at relay)

Her word (the coordinator's relay): the Pro stays fully available overnight; **VX-381, VX-382 and VX-348 merge to
main in finish order; ONLY THE LAST of the three to merge mints ONE release (0.9.8, the only bump) covering all
three**; VX-378 never mints (a release may carry it if merged by then). Mechanics, binding this run's closeout:
merges serialize through the coordinator (the ask carries branch, tested tree, tip; the tree must contain main
fdce74de3 — so the closeout merges latest main INTO the branch first); first/second merger: merge, close out, remove
worktree + branch, stop — no release, no bump, no /Applications refresh; the LAST merger mints the release + the
folded /Applications refresh under a coordinator GO (A1 rail, zero-instance, codesign) — the coordinator says
explicitly who is last. **Before the merge ask: land this run's own section in `ReleaseNotes-0.9.8.md` on this
branch** (one-line bullets, the 10-16 precedent) so the last merger's notes cover all three runs. Note beside her
standing release rule (notes drafted → presented → approved): tonight's explicit overnight word IS the
authorization; the notes stay strictly factual one-liners and she reads the assembled file in the morning.

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
| U1a — VX-303 (the landing road) | VERIFIED 2026-10-18 (`vx-382-u1a` window) — red-on-old A·B·C red as planned, both guard probes red, tree restored clean between each; batch `Test run with 1590 tests in 259 suites` — 4 issues + 5 known: VX-115's standing red (BookCollectingDoorsTests) + `DestructiveUndoWarningTests.redoNeverAsks` (the known VX-167 parallelism flake, signature :141–143); VX-77's standing red did NOT reproduce (passed). 9 skipped (2 disabled suites). §U1a RECORD → batch results. Code tip f0d1b414f |
| U1b — VX-304 (the box door + Index takes) | VERIFIED 2026-10-18 (windows `vx-382-u1b` + `vx-382-u1b-walk`) — red-on-old B·C·D + both guard probes red as planned; batch 1998 tests / 332 suites: standing reds only (VX-115; VX-167's redoNeverAsks, red alone, same signature) + FINDING D-2, FIXED ab3db8f19 (the departing Outline ate the reveal) — 64-suite family 308/64 green (4 known), its red-on-old red; OutlineRoomTests PASSED; THE U1 WALK: Study 11 rows PASS (W1/W3 not walked — same road, pinned), Terminal 6 face/act rows PASS; posture restored, 0 instances, 0 GiB pruned (nothing superseded). §U1b RECORD |
| U2 — VX-291 · VX-21 · VX-69 · VX-77 · VX-115 | BUILT except the VX-21 re-cut — **R-U2-A STOPPED at its inventory step** (the Book Panel has ONLY chapter grips, 0.9.2 and now; her Journal bars were chapter ⠿s — §R-U2-A inventory; ac24bedbf stands, awaiting the re-rule). R-U2-B BUILT 8b38c88bb (test-only `.aqua` pinning). VX-291 · VX-69 · VX-115 (accepted) built; `build-for-testing` green. Every run + THE U2 WALK PENDING the `vx-382-u2` window (REVISED sequence in §U2 RECORD; VX-21 rows held). Implementer: opus-implementer, fresh, 2026-10-18 |
| Review ladder (opus-reviewer, whole diff) | NOT STARTED |
| Closeout (canon deltas, tickets, PR, handoff) | NOT STARTED |

## U1a RECORD — VX-303 (implementer: opus-implementer, 2026-10-18)

**Not done in this unit:** the walk (U1b's walk covers U1, per the brief); the spread's Takes form stays out of the
memory (guard (i), recorded remainder). Red-on-old and the batch are DONE — §Batch results.

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

4. **The rulings' seams and the pins, pins first** — e3d44a189 (behavior-neutral): the road carries ONE value,
   `BookOpenDoor.Landing` (note · block · offset · find · MODE); `ShellRouter.ModeLanding` parked beside the block
   landing in the same `adopt` (rule one/two kept; one generation per park) + `landingMode(for:)`;
   `PostDetailView.initialMode` (arrives in the named mode; writes the note's mode memory when it differs — the
   switch's own write, which a mount's first assignment never fires); `CommandRouter.duringCaretPlacement` (a depth)
   bracketing `EditorViewModel.applyProjection`'s initialRender arm (the fill's END + the focus seeds — the ONLY
   editor lines touched: a bracket around three existing statements); `BookIndexEditModel.caretReportIsHers` (the
   Index pane's going-live placement — its `string` write's END and a landing's armed place — is not hers; a click's
   place is; her edit ends a placement an empty take never reported); the Index pane's caret reaches the router
   through that test. The pins, reworked: see §the pins below.
5. **R-U1a-2 — every door names Write** — DONE 406fb417c: `openInWrite` rides with `mode: .write` on both arms; a
   nothing-live note arrives with the plain open's PLACE (R-18l-1), in Write.
6. **R-U1a-1's opt-in seam** — e7cd4fdd9 (behavior-neutral): `noteFocusedBlock(…, remembersOtherNotes:)`, default
   false; the editor (`updateCaretContext`) and the Index pane host opt in.
7. **R-U1a-1 — the memory** — DONE 74c632b61: the other-note arm feeds `currentBlocks.remember` only — never the
   observed identity or its offset (guard (ii)) — and only for an opted-in reporter, outside a placement bracket,
   with a block (guard (i)). "Edit here" (which already reads `currentBlock(for:)`) lands where she was in the book.

### Guard (i), verified — what fires a report for a note no detail shows, at mount

- **The book's inline editor (Outline, the spread's Write form):** `applyProjection`'s `.initialRender` arm — the
  fill parks the insertion point at the document's END and `renderFull` reports it (the arm's own comment names it);
  then `applyFocusSeeds` — the book's caret seed (a CLICK's place, or a bare focus's 0 = the note's very start, row
  44), a parked `WriteIntent` ("edit here" in Outline/spread), the find seed. All synchronous inside the arm, all now
  inside `duringCaretPlacement` → never remembered for another note. Cost recorded: a click-focus's seed (her place)
  is dropped with them (the editor cannot tell it from a bare focus's); her NEXT caret move or keystroke records it.
  Re-renders while mounted (`fullRender`/`differential`/forced) restore her caret by identity and report it again —
  her place, unbracketed by design.
- **The book Index's pane:** going live, `makeNSView`'s `string =` reports the take's END, then the armed landing
  reports its place (`.start` / `.offset(remembered)` for a landing; `.offset(click)` for a click). Filtered by
  `caretReportIsHers`: the END and a landing's place never feed; a click's place does; everything after does.
- **The Takes board (the spread's Takes form; a non-key window's Takes mode):** its N9 entry reads the MOUNTED
  detail's `focusedBlock`, so a note no detail shows enters on its FIRST slot, and the live pane reports that
  placement (`notePaneSelection`). Unguardable without Takes code → the board does NOT opt in: its other-note
  reports keep today's drop. Recorded remainder (owner: VX-300 / the orchestrator): the spread's Takes form neither
  feeds nor clobbers the memory.
- **The shadow `InlineEditorSurface`** (the Outline's second model): no projection, no caret — reports nothing.

### The pins (`App/Variorum/VariorumTests/BookOpenDoorTests.swift`; runs PENDING the window)

- `BookOpenDoorRuleTests` — pure: the place rule per mode, the clamped landing offset, the offset and the MODE riding
  the one park (new API — not red-on-old by construction).
- `BookPlaceMemoryTests` — the router: another note's opted-in report feeds its memory while the mounted detail's
  observed fact and offset stay put (guard (ii)); a default reporter feeds nothing; a placement bracket feeds nothing
  while the detail's own reports in it land (guard (i)); the Index pane's placement rule.
- `BookOpenDoorMountTests` (outline · spread · index) — the live note's door rides (block 2, her offset, Write);
  another note's (the collapsed card's case) rides (no block, Write); guard (i) at the mount (the seed / the landing
  not remembered); the Index arm's pane move IS remembered.
- `BookOpenDoorShellTests` — the real shell: Write at her caret over a note left in Lenses (and its mode memory
  says Write after); the NOTHING-LIVE door: Write, at the start (the session's first open), never Lenses.
- `BookEditHereRiderTests` — the spread: the note's own editor left her at block 1 + 2; she writes at block 3 + 4 in
  the book, clicks out, presses "edit here" → block 3 + 4.

### Red-on-old plan (each family by ITSELF, tree committed first, restored exactly after)

| Family | Revert | Run | Expected red |
|---|---|---|---|
| A — the doors carry her place (piece 2) | in place: `BookView.openInWrite`'s body → piece 1's, byte for byte: `NotificationCenter.default.post(name: .variorumOpenPost, object: nil, userInfo: ["postID": postID])` (7cbaf633b no longer reverts cleanly — e3d44a189/406fb417c re-shaped the same lines) | `BookOpenDoorMountTests` alone, then `BookOpenDoorShellTests` alone (the reverted door broadcasts app-wide) | Mount: nothing rides (all three modes). Shell: Lenses at the start / not opened if another window claimed the broadcast |
| B — R-U1a-2, Write forced | `git revert --no-commit 406fb417c` | `BookOpenDoorMountTests`, `BookOpenDoorShellTests` | Mount: every ride's `mode` is nil. Shell nothing-live arm: Lenses. (Shell live arm stays green: its block landing forces Write via `jump` — expected) |
| C — R-U1a-1, the memory | `git revert --no-commit 74c632b61` | `BookPlaceMemoryTests`, `BookEditHereRiderTests`, `BookOpenDoorMountTests` | Router feed: B's memory nil. Rider: lands block 1 + 2 (the note's own editor's place). Mount index arm: her pane move not remembered. (`aSurfacesOwnPlacement…` fails too — its premise needs the memory arm; expected) |
| Guard (i) probe — the bracket | in place: delete `, caretPlacementDepth == 0` in `CommandRouter.noteFocusedBlock`'s other-note arm | `BookPlaceMemoryTests`, `BookOpenDoorMountTests` | Router: the bracketed placement replaces b5/30. Mount outline/spread: the seed is remembered |
| Guard (i) probe — the Index filter | in place: `caretReportIsHers` → `return true` first line | `BookPlaceMemoryTests`, `BookOpenDoorMountTests` | The Index placement rule's false arms; mount index arm: the landing's placement remembered |

Restore each with `git checkout -- <file>` (safe: the tree is committed) or `git revert --abort`; `git diff` clean
against the tip (ed0c887d6 at this writing) before the next family.

### Batch results — the `vx-382-u1a` window (2026-10-18; logs in the gitignored `scratchpad/u1a/`)

Each family from the committed tree (code = f0d1b414f; the tip's 4f3388db1 is record-only), restored to a clean
`git diff` before the next. Zero app instances before, between and after.

- **A — the doors' road** (door body → piece 1's broadcast, in place). `BookOpenDoorMountTests` alone: 6 issues —
  each mode's live door `rode: []` (:520) and other-note door (:529); premises, guard (i) and the Index memory arm
  green. `BookOpenDoorShellTests` alone: 4 issues — the note opened, but `activeMode` = `.lenses` (:627, :674) and
  no Write caret (`caret nil`, :630, :677). Red for the planned reason.
- **B — forced Write** (`git revert --no-commit 406fb417c`). Mount: 6 issues — every ride carries `mode: nil`.
  Shell: the nothing-live arm 2 issues (Lenses, caret nil); the live arm GREEN (its block landing forces Write via
  `jump`) — as planned.
- **C — the memory** (`git revert --no-commit 74c632b61`). `BookPlaceMemoryTests` 4 issues (B's memory nil at :199,
  :208; the placement pin's premise at :234, :243); `theIndexPanesGoingLivePlacementIsNotHers` green (the filter is
  not in C — expected); Mount: the Index arm's "her move is remembered" (:508); `BookEditHereRiderTests` 2 issues —
  the book's caret not remembered (:758) and "edit here" landed `(block 1, offset: 2)`, the note's own editor's place
  (:777). Red for the planned reason.
- **Guard probe — the bracket** (`caretPlacementDepth == 0` deleted): 3 issues — the bracketed placement replaced
  b5/30 (:234) and the outline and spread mounts remembered the focus seed (:484).
- **Guard probe — the Index filter** (`caretReportIsHers` → `true`): 4 issues — the END, the landing's place and the
  click arrival's END counted as hers (:263, :266, :276); the Index mount arm remembered the landing (:499).
- **Green batch** (`only-testing.args`, 259 suites): `Test run with 1590 tests in 259 suites failed after 845.666
  seconds with 9 issues (including 5 known issues)`. 9 tests skipped (two disabled suites: the VX-144 capture
  harness and the opt-in unkeyed-oracle suite — their traits say so). All five VX-303 suites passed. The 4 issues:
  - `BookCollectingDoorsTests.theSettingsDoorIsOneActOnBothRoads` — VX-115's standing red (`BookView
    .surfaceCapabilities == [.openBookSettings]`, :101). U2's member.
  - `DestructiveUndoWarningTests.redoNeverAsks` — 3 issues at :141–143 (slots one block, redoDepth 1, no "Redid")
    — the KNOWN flake VX-167 (Parked: red only under in-process parallelism; VX-184's record measured it red alone
    2/2). Here, alone: 1 pass, 1 fail — same signature. Not attributed to this unit; recorded, nothing restored.
  - `OutlineRoomTests.bothColumnsChromeStaysInsideThemAtTheirFloors` (VX-77's standing red) PASSED in this batch —
    recorded for U2, which owns it.

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
  under the caret for that note — the door carries no place (in Write, R-U1a-2); and the board neither feeds nor
  clobbers the note's memory (guard (i), above).
- **The open tail:** a caret in the Outline editor's open tail (no block yet) has no `caretIdentity` — plain open.
- ~~Nothing live ⇒ the remembered mode still decides~~ — RULED R-U1a-2, built 406fb417c: every door lands in Write.
- **Relaunch:** another note's memory is persisted at a BLOCK change only (`CurrentBlockMemory.remember`); its
  offset within the block is persisted at the active detail's leave/quit only, so after a relaunch a book-edited
  note's memory keeps the right block with the offset of its last block change — the hard-quit class the memory
  already accepts.
- **R-18l-1's re-open:** a note re-opened this run restores a place she last had in the book (R-U1a-1's recorded
  consequence — PROVISIONAL, her bundle).

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

### FABLE LINE-CHECK — the two editor-adjacent edits (2026-10-18, the orchestrator, after the U1a build)

The implementer flagged its two `EditorViewModel`/`CommandRouter` edits for a Fable look (neither file is the plan's
stop trio — `EditorTextView`/`BlockRangeIndex`/`PaneSurface` were NOT reached, so no Fable ladder round is owed and
nothing goes to her first; the look happened anyway, hunks read in full). VERDICT — sound, four grounds: (1) guard
(ii) holds STRUCTURALLY: `noteFocusedBlock`'s other-note arm returns before `focusedBlockIdentity`/`focusedOffset`;
(2) guard (i) is three exclusions (opt-in reporter · `duringCaretPlacement` depth over the initialRender arm's three
statements, active path untouched · block-less reports named nothing) with pins that BITE — the two guard probes
delete each exclusion and name the exact pins that must then fail; an async-escaping mount report would land outside
the bracket and the mount pins would catch it; (3) cost (P1/P8): `currentBlocks` is `@ObservationIgnored` on the
router and `remember` is a dict write per report with `UserDefaults` only on block/take change — the active path's
own measured policy (~100 µs per block change, 17o b), so the per-caret-move opt-in wakes nobody; (4) `initialMode`
writing the remembered mode at mount mirrors the existing jump road's net effect (landing in Write leaves Write
remembered), closing the gap only because mount's first assignment skips the usual write. Known accepted cost,
recorded: a click-arrival seed during mount is dropped with the bare-focus seeds; her next caret act records it.
Ladder note: the final reviewer-cast call is made at ladder time with the whole diff in view; these two hunks carry
this check either way.

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

## U1b RECORD — VX-304 (implementer: opus-implementer, 2026-10-18)

**Not done yet (PENDING the `vx-382-u1b` window):** the red-on-old runs, the green Mac batch and THE U1 WALK — the stage
is coordinator-held; everything to here was built and verified headless.

### The trace, re-verified on the tip (37bb72404)

- The box (`Core/Views/SidebarNoteBox.swift`) had ONE door, "edit here", rendered only in `.selected`; the live state
  rendered the editor's bar (`CommitBar(axis: .box)`, Outline/spread — its grid carries "Takes") or, in Index (no
  editor), the facts. No road out to Write from the box in any state: the book's "open ↗" stood only by each note's
  title in Outline/the spread, which scrolls away in a long note (her report).
- Index's pane (`BookIndexPaneNote.blockView`) drew no takes mark at all; `TOCRow.hasFan` was loaded and unread
  there. The Outline's precedent is the read tier's AppKit badge "⑂N" at the prose column's right edge
  (`ReadBadgeOverlay`), a click opening the block's takes.
- Index had no takes door of any kind: the live pane is a `PaneSurfaceView` (no editor, no ⑂, no bar), and ⌘⇧T
  reaches no handler there.
- **The live pane cannot host a sheet that edits its take** — traced, the reason for P-U1b-4: `PaneSurfaceView` is
  BUFFER-AUTHORITATIVE while live (`updateNSView`: "never clobber the surface under the caret"), so a take the
  panel edits never reaches a live Index pane, and her next keystroke there would autosave the pane's pre-sheet text
  over the panel's edit. And a second concurrent `AutosaveCoordinator.flushNow` returns at once while the first's
  write is in flight (it takes the batch and clears `pending` before it awaits), so "flush, then present" must own
  its flush rather than ride `blur()`'s detached one.
- The click-over (`BookView.switchMode` → `BookViewModel.carryPlace` → `BookAnchor.currentPost`) carries a NOTE id
  into `pendingReveal` only; Index's `landOrSeed` already consumes a BLOCK landing (`pendingLanding` → `edit
  .requestLiveBlock`, the Read click's road) and enters the block at the note's remembered caret
  (`PaneCaretLanding.entering`) — which, since R-U1a-1, holds her Outline caret.

### Pieces

1. **Seams, behavior-neutral** (this commit): `Queries.TOCRow.activeVariantCount` (the same `renderPost` slot as
   `hasFan`; a hand-built row's default agrees with its flag) + its core pin `BlockTOCTakesCountTests`;
   `NoteBoxDoor.openInWrite` / `.openTakes` (published nil); `SidebarNoteBox.onOpenInWrite` / `.onOpenTakes`
   (not rendered yet) and `RootView`'s pass-through; `BookViewModel.pendingIndexTakes` + `requestIndexTakes` /
   `consumeIndexTakes` (unconsumed); `BookAnchor.Place.livePostID/liveBlockID` + the pure `BookAnchor.landing`
   (unread); `carryPlace(…, livePostID:, liveBlockID:)` (accepted, unread); DEBUG oracles —
   `BookOutlineGeometry.modeDoors` (the tabs' one act, `switchMode`), `BookIndexGeometry.takesBadges` /
   `.takesSheets` (published by C). Builds headless (`build-for-testing` green).
2. **The pins** — committed (compiling against piece 1; runs PENDING the window):
   `VariorumTests/BookNoteBoxDoorsTests.swift` — `BookNoteBoxOpenDoorTests` (per mode — outline · spread · index —
   through a mounted book with the box's door and the road captured: SELECTED (spread, Index) rides the note + Write;
   LIVE rides block 2 + her offset + Write; the Index-live box hands Takes, Outline/spread's none),
   `SidebarNoteBoxDoorFacesTests` (both voices, the column at its default width, a wrapping title: the faces drawn —
   "open" in every state, "door" beside it while selected, "takes" in the Index-live case — and the door's frame
   WHOLE inside the box), `BookIndexTakesTests` (the ⑂2 badge on the fanned block only; the box's Takes on the live
   block: the sheet on that block, her letter written before the sheet read the store, shown on the panel's chosen
   card, the live pane released, "Open Takes mode" refusing — non-regression; the request slot with nothing live),
   `BookCarryLiveBlockTests` (the pure rule; the model's parked block landing; the mounted click-over through the
   published mode door: block 2 LIVE in the Index at her caret). Core: `BlockTOCTakesCountTests` (green — new API).
3. **B — the box door** — committed (see the commit naming it): `SidebarNoteBox` draws "open ↗" — SELECTED in the
   door row beside "edit here" (the bar's bordered-cell grammar, the same height as the filled door), LIVE trailing the
   title (the book's own voiced title door, in the accent); hovers per state (`NoteBoxCopy.openDoor*`); DEBUG face
   "open" + the frame oracle. `BookView.openDoor(report)` hands `NoteBoxDoor.openInWrite` = the book's ONE open door
   (`openInWrite`) for the box's note, read at the PRESS; none without a landing road (P-2). Red-on-old: B reverted ⇒
   `BookNoteBoxOpenDoorTests` (every `openInWrite` nil) and `SidebarNoteBoxDoorFacesTests` (no "open" face, no frame).
4. **C — Index badges + the in-place sheet** — committed (see the commit naming it): `BookIndexPaneNote` overlays
   "⑂N" (`TOCRow.activeVariantCount`) on every block with takes, hung `takesBadgeGap` (6) outside the row's trailing
   edge at the first line (`readTierTop`), both tiers — an overlay, so no prose moves; a press asks the book's ONE
   takes slot (`BookViewModel.requestIndexTakes`). `BookIndexView` takes the slot (`takeTakesRequest`, on appear and
   on change): `BookIndexEditModel.releaseForTakesSheet` (the live pane released synchronously, then the leaving
   note's and the sheet note's pending text WRITTEN, awaited — not `blur()`'s detached flush), then presents
   `WriteTakesPanel(session:postID:blockID:onClose:)` as its own sheet (DEBUG: `BookIndexGeometry.takesSheets`).
   `BookView.takesDoor(report)` hands `NoteBoxDoor.openTakes` only in Index with a live note (the block read at the
   press); `SidebarNoteBox` draws "Takes" in the door row while live with no bar (P-U1b-5; DEBUG face "takes"); the
   doors are re-handed on a mode change, FOCUSED panes only (`.onChange(of: structure.mode)` — a switch can leave the
   report equal; an unfocused pane's nil would decline the box under a focused pane showing the same book — the
   VX-143 gain-only rule's reason).
   "Open Takes mode" in the panel refuses inside a book unchanged (`requestMode`: no detail mounted). Red-on-old: C
   reverted ⇒ `BookIndexTakesTests` (no badge, no Takes door, no sheet), the Index arm's `openTakes` line in
   `BookNoteBoxOpenDoorTests`, the Index-live "takes" face in `SidebarNoteBoxDoorFacesTests`.
5. **D — Outline → Index carries the live block** — committed (see the commit naming it): `BookView.switchMode`
   reads `liveCaretBlock()` (the editor under the caret, only for the book's live note — `openPlace`'s rule) and
   hands it to `carryPlace`, which now asks the pure `BookAnchor.landing`: leaving OUTLINE with her caret live in
   the carried note parks `pendingLanding` (note + block) beside the reveal; every other arm carries the note alone
   and leaves the slot as before. Index's `landOrSeed` already consumes it (`edit.requestLiveBlock`, the Read
   click's road) and enters the block at the note's remembered caret (`PaneCaretLanding.entering` — her Outline
   move is in the memory since R-U1a-1). Red-on-old: D reverted ⇒ `BookCarryLiveBlockTests`' model pin
   (`pendingLanding` nil) and mounted pin (no live pane in the Index).

### PROVISIONAL choices (her bundle at the merge)

- **P-U1b-1 — the door's face is the book's own words, "open ↗"** (not a bare ↗, not a new "write" word): one act,
  one face — the box shows exactly the door she could not find by the title, so she recognizes it; hover names where
  it lands ("Open in Write at this block" while live; "Open this note in Write" while selected — no caret, so the
  plain open's place, R-U1a-2). Options not built: a bare "↗" glyph (smallest, least discoverable); "write ↗" (names
  the mode, but a second word for one act).
- **P-U1b-2 — placement, as the brief places it**: SELECTED — beside "edit here" in the box's door row (the state's two
  ways in, side by side: edit here, in the book · open ↗, out to Write); LIVE (every mode) — trailing the note's title
  on the box's identity line, where the book's own "open ↗" stands by its title, at zero height cost (the live box's
  bar fills the rail's height — the 18d floor the walk measured in Terminal). Option not built: one placement for
  both states (by the title) — the brief names "beside edit here" for the selected state.
- **P-U1b-3 — Index badges read "⑂N"**, the Outline badge's own count and face family, hung just outside the block's
  trailing edge (the Outline's "column right + 6" rule); a click opens the in-place sheet on that block.
- **P-U1b-4 — opening the sheet RELEASES the Index's live pane first** (synchronously, then her pending text is
  written before the panel reads the store): a live pane cannot adopt the panel's edits (traced above), so it stands
  read-cheap under the sheet; the box shows the note selected, and "edit here" returns her to her place (R-U1a-1's
  memory). Option not built: re-live the block when the sheet closes (the landing road scrolls the block to the
  pane's top — a visible jump after a sheet; a no-scroll re-live needs a new edit-model road).
- **P-U1b-5 — the Index-live box's "Takes" sits in the box's door row** (where "edit here" stands while selected), in
  the bar's own cell grammar; Outline and the spread keep their bar's Takes door (no second one).

### Recorded edges (not built here)

- **The spread → Index click-over carries the note only** — the brief names the Outline arm; the spread mounts the same
  editor, so extending it is one arm of `BookAnchor.landing` if ruled.
- **⌘⇧T in Index** (a routed door) is not added — the registry grows only for a routed door (VX-300's remainder).

### Commits (all on `vx-382-book-view-doors`, pushed)

a45d93a6c (A · seams) · 030e96915 (the pins) · 28fd701f1 (B · the box door) · a0c59c10f (C · Index badges + the
sheet) · a12df00ce (D · the carry) · 6ee8a8ec2 (P-8's line policy on the two new `fixedSize` sites) · the
focused-pane guard on C's mode republish (self-review: the VX-143 gain-only class).

### Verified headless (no stage)

- `xcodebuild build-for-testing` green after every piece (logs `scratchpad/u1b/build-*.log`); no new warning on a
  touched line.
- Core `swift test`: VariorumCoreTests **2897 tests / 338 suites passed** (incl. `BlockTOCTakesCountTests`); the app
  helpers' 40/6 passed; VariorumMCPTests 362/68 with ONE red — `MCPHarnessTimeLimitTests
  .aPeerThatNeverAnswersInitializeFailsTheConnectNamedAndBounded`'s wall-clock bound (`< 15 s`, took 19.4 s under
  the full parallel run) — re-run ALONE: 3/3 passed in 2.2 s. A load-bound timing pin in a target this unit does
  not touch (no MCP source reads `TOCRow`/`blockTOC`); recorded, not attributed.
- `ChromeLineLimitTests`' rule replicated locally over `App/Variorum/Variorum` (0 offenders after 6ee8a8ec2).

### Red-on-old plan (each family by ITSELF, from the committed tree, restored with `git checkout -- <file>` and a clean `git diff` before the next)

In-place edits (the pieces share files with later commits, so `git revert` of B or C does not apply cleanly; D's
one line is in place too, to keep its record hunk out of it):

| Family | In-place revert | Run | Expected red |
|---|---|---|---|
| B — the box door | `BookView.openDoor(_:)`: insert `return nil` as its first line; `SidebarNoteBox`: delete the line `if let onOpenInWrite { rowOpenDoor(onOpenInWrite) }` and make `if state.isLive, let onOpenInWrite {` read `if state.isLive, false, let onOpenInWrite {` | `BookNoteBoxOpenDoorTests`, `SidebarNoteBoxDoorFacesTests` | Door: every `#require(…openInWrite)` fails (selected spread/index; live all three). Faces: "open" 0 and no door frame, both voices, every case |
| C — the Index's takes | `BookIndexPaneNote.takesBadge`: `if row.hasFan {` → `if false, row.hasFan {`; `BookView.takesDoor(_:)`: `return nil` first; `BookIndexView.takeTakesRequest`: `return` first; `SidebarNoteBox`: `if state.isLive, bar == nil, let onOpenTakes {` → `if state.isLive, false, bar == nil, let onOpenTakes {` | `BookIndexTakesTests`, then `BookNoteBoxOpenDoorTests` (index arm) and `SidebarNoteBoxDoorFacesTests` | Badge nil; the box hands no Takes (`#require`); the request never taken (no sheet); the index arm's `openTakes != nil` line; the Index-live "takes" face 0 |
| Guard probe — the flush | `BookIndexEditModel.releaseForTakesSheet`: delete the `if let leaving … { await … }` block and the `_ = await session.flushExistingAutosave(…)` line | `BookIndexTakesTests.theBoxsTakesOpensTheLiveBlocksTakesInPlaceHerTypingFirst` | "her typing was written before the sheet read the store" (the 500 ms debounce has not fired at the sheet's appearance); the card likely lacks the letter |
| Guard probe — the release | same function: delete `authority.blur()` | the same test | "the Index's live pane was released for the sheet" |
| D — the carry | `BookViewModel.carryPlace`: delete the line `if target.blockID != nil { pendingLanding = target }` | `BookCarryLiveBlockTests` | Model: `pendingLanding` nil; mount: no editable Index pane on block 2 after the click-over |

Not red-on-old by construction (new API, recorded as U1a's rule tests were): `BookCarryLiveBlockTests
.leavingOutlineNamesHerBlockAndNothingElseDoes` (pure), `BlockTOCTakesCountTests` (core, already green).

### THE U1 WALK — the plan for the `vx-382-u1b` window (U1a's doors + edit-here, U1b's box door, badges, sheet, carry)

Screens to `scratchpad/u1b/screens/` (gitignored). Region captures only (`screencapture -x -R…`), never full-screen.
Every key through `Tools/WalkKit/keys.sh <devpid> '…'`, every click through `Tools/WalkKit/click.sh <devpid> x y`;
acts ≥ 2 s apart (the guard's self-trip); re-read every point from a fresh capture after any voice flip; popovers
driven by CLICKS (cliclick's keyboard never reaches a popover).

0. **Gate.** Run the claim line verbatim. `pgrep -fl 'Variorum.app/Contents/MacOS'` — her `/Applications` app must
   be ABSENT (`guard.sh` exits 3 otherwise: stop and report, never quit hers). Grants: `guard.sh --author` OK, and a
   one-line `osascript` AX probe. Build helpers: `swiftc -O -o Tools/WalkKit/wl2 Tools/WalkKit/wl2.swift` (gitignored)
   and `walk-cap`/`walk-scroll` into `scratchpad/u1b/bin/`.
1. **Launch** the batch's Debug product (`…/DerivedData/Variorum-dkbmlpshalzxqeftsymzimjxpdhl/Build/Products/Debug/
   Variorum.app`) with `open -n`; pid by PATH; dismiss What's New if it shows (same MARKETING_VERSION 0.9.7 as main —
   it should not). If a Castle lock screen shows: `source ~/.variorum/dev-castle.env`, unlock with exactly those
   values, NOTHING else. Record the starting posture: voice (Settings ▸ Appearance via AX — read, don't click), the
   appearance default (`defaults read io.lduarte.Variorum.debug appearanceChoice`).
2. **The book.** On the Bookcase, find the bilingual-style book (the Portuguese-titled import, e.g. "o ladrão de
   raios", from the capture — ⌘K → its name → ⏎ if the row is not in view). Opens in Outline.
3. **Voice 1 (the starting voice) — U1a's doors (routing; one voice suffices):**
   - W1 Outline: unfold a note, click mid-sentence in its 2nd block; press the expanded header's "open ↗" → capture:
     Write, caret line in that block. ⌥⌘[ back.
   - W2 Outline: a COLLAPSED card's "open ↗" (nothing live) → capture: Write, at the note's start. Back.
   - W3 Index: click into a block mid-text (live pane), the column row's ⋯ ▸ "Open in the full editor" → capture:
     Write at that block. Back.
   - W4 Book (spread): click into the page's 2nd block; the page header's "open ↗" → capture: Write at that block. Back.
   - W5 edit-here rider (spread): click into block 3; click out (the spread's empty margin) → the box shows
     "edit here" + "open ↗" (capture = also U1b's selected face) → "edit here" → capture: the caret back in block 3.
4. **U1b — the box door, voice 1:**
   - W6 Outline live: click into a block → the box's title line wears "open ↗" (capture the box) → press it →
     capture: Write at that block. Back.
   - W7 Index selected (a column row clicked, nothing live) → the box row [edit here][open ↗] (capture) → "open ↗" →
     capture: Write (the plain open's place). Back.
   - W8 Index live: click into a block → the box: title "open ↗" + the "Takes" cell (capture) → title "open ↗" →
     capture: Write at that block and caret ("open in Write here"). Back.
5. **U1b — the Index's takes, voice 1:**
   - W9 badges: Index pane — a block with takes wears "⑂N" right of its first line, one-take blocks nothing (capture;
     if the book has no fanned block, make one via Outline's bar "Takes" → "＋ new take (branch)", and DELETE it at
     the end through the same panel's ⋯ ▸ Delete — content restored).
   - W10 the badge → the in-place sheet over the book (capture) → "Open Takes mode" → the refusal toast (capture) →
     (the panel dismisses itself, as over the Outline).
   - W11 the box's "Takes" on a live block → the sheet on THAT block (capture: the header names it) → Close → the box
     shows the note SELECTED (the live pane released — capture).
6. **U1b — the carry, voice 1:** W12 Outline: click into a note's 2nd block mid-sentence → the masthead's "Index" tab
   → capture: Index with that block LIVE (the ring) at her caret.
7. **Voice 2:** Settings ▸ Appearance ▸ the other voice (AX radio); re-capture the FACES only: W5' (selected row),
   W6' (Outline live title door), W8' (Index-live box with Takes), W9' (badges), W10' (the sheet). Then restore the
   starting voice (AX), and re-read it to verify.
8. **Restore & quit:** no typing was done; delete any take W9 minted; the dev store stays UNLOCKED; appearance
   default unchanged (verify `defaults read`); quit by identity (`tell application id "io.lduarte.Variorum.debug" to
   quit`), then `pgrep -fl 'Variorum.app/Contents/MacOS'` EMPTY before reporting. The stage is NOT released by me.

### Batch results — the `vx-382-u1b` window, red-on-old + batch half (2026-10-18; logs in the gitignored `scratchpad/u1b/`)

Each family from the committed tree (99e0634e4), in place, restored with `git checkout -- <file>` to a clean
`git diff` before the next. Zero app instances before and after.

- **B — the box door** (`redB.log`): 7 issues — `openInWrite` nil at the selected `#require` (spread, index :316) and
  the live one (outline :331); faces "open" 0 and no door frame in both voices (:458, :472). Red as planned.
- **C — the Index's takes** (`redC.log`): 7 issues — the index arm's `openTakes` (:343); the "takes" face 0 in both
  voices (:465); the badge nil (:507); the box hands no Takes (:539); the request never taken — no sheet (:600) and
  the slot unconsumed (:603). Red as planned.
- **Guard probe — the flush** (`probe-flush.log`): 2 issues — the store lacked her letter when the sheet appeared
  (:558) and the panel's chosen card lacked it (:568). Red as planned.
- **Guard probe — the release** (`probe-release.log`): 1 issue — the Index's live pane was NOT released (:572). Red
  as planned.
- **D — the carry** (`redD.log`): 3 issues — `pendingLanding` nil (:654); no live pane in the Index (:687, :688). Red —
  BUT see FINDING D-2: the mounted pin is red on the full tree too.
- **Green batch** (`batch.log`, 332 suites): `Test run with 1998 tests in 332 suites failed after 1029.719 seconds with
  20 issues (including 14 known issues)`; 15 skips (the two disabled suites — the VX-144 capture harness and the
  opt-in unkeyed-oracle suite — plus their tests). The 14 known issues are the suites' own `withKnownIssue`s
  (`CommentPanelHostLifecycleTests` ×9 — VX-229's recorded runner retention; `IndexTierMetricsTests` ×4;
  `TakesFindBoardTests` ×1). The 6 non-known:
  - `BookCollectingDoorsTests.theSettingsDoorIsOneActOnBothRoads` — VX-115's standing red (:101). U2's member.
  - `DestructiveUndoWarningTests.redoNeverAsks` — 3 issues :141–143; re-run ALONE (`undo-alone.log`): red again, the
    same signature — the known VX-167 flake (VX-184's record measured it red alone 2/2). Not attributed.
  - **`BookCarryLiveBlockTests.outlineToIndexLandsWithHerBlockLiveAtHerCaret` — 2 issues (:687 pane nil, :688) — a
    FINDING (D-2 below); red alone too (`carry-alone.log`).**
  - `OutlineRoomTests.bothColumnsChromeStaysInsideThemAtTheirFloors` (VX-77) PASSED.
  - All other VX-304 suites passed (the box door per mode, the faces in both voices, the badge and both sheet roads).

### FINDING D-2 — the departing Outline eats the click-over's reveal (traced; FIX BUILT, verification PENDING the walk window)

Traced with temporary prints (`diag-carry*.log`; reverted): after the mode door, the carry HAD parked the reveal and the
block landing (note + block 2; the memory held block 2 at 9). Then the departing OUTLINE's `.onChange(of:
model.pendingReveal)` fired in the switch's own update — `landOutlineReveal` ran with `structure.mode == .index` — and
`consumeReveal()` cleared BOTH; the Index's `landOrSeed` found nothing and SEEDED on the focused note. So the
note-level Outline → Index carry has only ever "worked" by that seed's accident (`focusedPostID`), and a block could
never ride it. **Fix (in this commit):** `landOutlineReveal` acts only while Outline IS the mode (`guard structure.mode
== .outline`) — W21's own contract ("the arriving surface consumes"); every road that lands the Outline arrives with
the mode already Outline (the tabs, `takeChapterRequest`'s `switchMode`). Pin: the mounted carry pin, red on the full
pre-fix tree (batch + alone + diagnostic). Owed in the walk window BEFORE the walk: `BookCarryLiveBlockTests` green, then
the reveal/landing family (`scratchpad/u1b/fixD2-suites.args`, 64 suites — every suite reading `pendingReveal`,
`carryPlace`, the reveal/chapter landings, the book surfaces); red-on-old for D-2 = delete the guard line.
Recorded, not fixed (out of the slice): the SAME departing-consumer class stands in `SpreadBookView.landReveal`,
`PagedReadView`'s `.onChange(of: pendingReveal)` and the flow's `reveal:` — a carry out of those modes is likewise
eaten on the way out and the arriving Index/Outline falls back to its seed (the note carry survives through the
standing anchor; no block rides those arms today, by the brief's letter). Owner: the orchestrator / VX-300.

### D-2 verified — the `vx-382-u1b-walk` window (2026-10-18; logs `scratchpad/u1b/fixD2-batch.log`, `redD2.log`)

- **Green on the tip (ab3db8f19):** the 64-suite reveal/landing family (`fixD2-suites.args`, incl. `BookCarryLiveBlockTests`)
  — `Test run with 308 tests in 64 suites passed after 226.453 seconds with 4 known issues` (the suites' own
  `withKnownIssue`s). `BookCarryLiveBlockTests` passed (0.43 s).
- **Red-on-old (the guard line deleted in place, restored to a clean diff):** `BookCarryLiveBlockTests` — 2 issues,
  `pane != nil` (:687) and the caret (:688). Red for the traced reason.

### D-2's CLASS SWEEP — the leaving-mode reveal-eat class (a departing book surface consumes the reveal a click-over parked for the ARRIVING one)

| Instance (switch out of) | Host / consumer | Disposition | Mechanism today |
|---|---|---|---|
| Outline → any mode | `BookView.landOutlineReveal` via the Outline's `.onChange(of: pendingReveal)` | **FIXED** (ab3db8f19) — acts only while `structure.mode == .outline`. Pin: `BookCarryLiveBlockTests.outlineToIndexLandsWithHerBlockLiveAtHerCaret` (red on old, green on the tip) | — |
| Book (the spread) → any mode | `SpreadBookView.landReveal` via `.onChange(of: model.pendingReveal)` | **SAFE for the block today, recorded** | The spread arm of `BookAnchor.landing` carries the NOTE only (no block rides it — the brief's letter). If its departing `onChange` eats the reveal (whether it fires on the way out is UNVERIFIED for this host — the Outline's did), arriving at INDEX still lands the note: `carryPlace` wrote `standingAnchorPostID`, and `landOrSeed`'s seed reads `focusedPostID` then it. Arriving at OUTLINE has no seed: an eaten reveal would leave the Outline at its own scroll — a possible NOTE-carry miss, recorded for VX-300 |
| Read ▸ Pages → any mode | `PagedReadView` `.onChange(of: model.pendingReveal)` → `consumeReveal()` | **SAFE for the block today, recorded** | Same as the spread: the read arm carries the note only; Index re-seeds on the standing anchor; the Outline arrival is the same possible note miss (UNVERIFIED) |
| Read ▸ Scroll → any mode | `ReadingFlowView`'s `reveal:` / `onRevealLanded` → `consumeReveal()` | **SAFE for the block today, recorded** | Same; and the flow's own block door (`onWake` → `requestLanding` + `mode = .index`) parks its landing WITHOUT a carry, so it is not this class |

Future block-carry out of the spread or Read (one more arm of `BookAnchor.landing` each) must first give that surface
the same mode guard — owner **VX-300** (the book view's after-launch remainder).

### THE U1 WALK — verdicts (dev store, Debug build `Variorum-dkbmlpshalzxqeftsymzimjxpdhl` from the tip; the book "o ladrão de raios"; screens `scratchpad/u1b/screens/`)

Gate: her `/Applications` app absent (`guard.sh` OK throughout), no What's New sheet (same 0.9.7), no lock screen.
Starting posture: voice Study, appearance `system`.

**Study (voice 1):**
- W2 collapsed card's "open ↗" (nothing live) → Write at the note's start (block 1/3) — **PASS** (`W2-card-open`).
- W4 the spread page's "open ↗" with the editor live → Write at block 2/3 — **PASS** (`W4-study-page-open-result`).
- W5 the rider: the spread's box SELECTED [edit here][open ↗] → "edit here" → live at block 2/3, where she last was —
  **PASS** (`W4-spread`, `W5-study-edit-here`).
- W6 Outline live: the box's title wears "open ↗" (block 2/3 in the where-line) → Write at block 2/3 — **PASS**
  (`W6-study-live-box`, `W6-study-box-open-result`).
- W7 face: the SELECTED box's row [edit here][open ↗] — **PASS** (seen under the sheets and after them).
- W8 Index live (o museu, block 2): box with title "open ↗" + the "Takes" cell → "open ↗" → Write at block 2/3 —
  **PASS** (`W8-study-index-live`, `W8-study-open-here-result`).
- W9 badges: ⑂4 · ⑂3 · ⑂3 · ⑂3 · ⑂2 · ⑂2 · ⑂2 right of each fanned block's first line, nothing on one-take blocks —
  **PASS** (`W12-study-carry`). No take minted (the book is fanned already).
- W10 a ⑂3 badge → the in-place sheet on THAT block (a escola, its 3 takes) — **PASS**; the badge-click geometry risk is
  SETTLED (the overlay hangs outside its block and takes the click) (`W10-study-badge-sheet`).
- W10b the panel's "Open Takes mode" inside the book → the refusal toast "Open a note first — the modes live inside a
  note." and the panel dismissed itself (Outline's behaviour) — **PASS** (`W10b-study-open-takes-mode`).
- W11 the box's "Takes" on the live block (abertura block 3) → the sheet on block 3 (4 takes); under it the box is
  SELECTED (the live pane released, P-U1b-4) — **PASS** (`W11-study-sheet`).
- W12 Outline, caret in block 3 at "par|te" → the Index tab → Index arrives with block 3 LIVE, caret at "par|te" —
  **PASS** (D-2's fix in use) (`W12-pre`, `W12-study-carry`).
- **Not walked:** W1 (Outline's expanded-header "open ↗") and W3 (Index row ⋯ ▸ "Open in the full editor") — the same
  `BookView.openInWrite` road W6 (Outline arm) and W8 (Index arm) walked, pinned per door by U1a's
  `BookOpenDoorMountTests`/`BookOpenDoorShellTests` (green in this unit's 332-suite batch).

**Terminal (voice 2 — the faces):**
- W6′ Outline live box with the title "open ↗" — **PASS** (`T-W6-pre`). (The box's footer scrolls under the Terminal
  identity lines — the 18d-recorded Terminal floor fact, unchanged; the title door adds no height.)
- W12′ Outline (block 2, "qu|e") → Index: block 2 LIVE at "qu|e" — **PASS** (`T-W12-carry`).
- W8′ Index-live box: title "open ↗" + "takes" cell — **PASS**; W9′ badges — **PASS** (`T-W12-carry`). Taste note: on
  a line that runs to the column's edge the ⑂ badge sits its 6 pt gap from the last character ("amigos.⑂2") — legible,
  recorded for her eye.
- W10′ badge → the sheet on that block; W7′ the SELECTED row under it — **PASS** (`T-W10-badge-sheet`).
- W7′ act: the selected box's "open ↗" → Write (a re-open this session: the restored block 2/3, R-18l-1 + R-U1a-1) —
  **PASS** (`T-W7-selected-open-result`).

Restore: voice back to Study (read back in Settings ▸ General), appearance `system` (`defaults read` after), no typing
and no take minted, no Castle/lock, app quit by bundle id, `pgrep -fl 'Variorum.app/Contents/MacOS'` EMPTY.

**Prune:** nothing superseded under this worktree — it has no `App/Variorum/DerivedData/` (its builds use the shared
per-workspace cache `~/Library/Developer/Xcode/DerivedData/Variorum-dkbmlpshalzxqeftsymzimjxpdhl`, the current build,
kept), U1a's reverts were in place (no revert-build cache), and Xcode already keeps only the two newest xcresults. **0
GiB freed.** Seen, not touched (not this worktree's): two untagged caches `Variorum-dwsllegayujwheeyiqdaxidevnxh`
(22 MB) and `Variorum-fpwbhptcstaitjfwausnqrbvbqqe` (88 MB), both 2026-10-17 19:23, no `info.plist` — the
coordinator's to judge.

## U2 RECORD — VX-291 · VX-21 · VX-69 · VX-77 · VX-115 (implementer: opus-implementer, fresh, 2026-10-18)

**Not done yet (PENDING the `vx-382-u2` window):** every red-on-old run, the green Mac batch, VX-77's two confirming
runs and THE U2 WALK — the stage is coordinator-held; everything here is built and verified headless.

### VX-77 — the archaeology (headless, 2026-10-18; the window confirms)

**Verdict (headless): no main-side code change restored the floor, because no product regression caused the red —
the red was the TEST HOST'S APPEARANCE.** The window's two runs decide it (below); until then this is the leading
hypothesis with a traced mechanism, not a closed finding.

- **The pin reads LUMINANCE, not geometry.** `leftmostInkX` (OutlineRoomTests.swift:43, copied from
  BookOrderConversionTests) returns the first pixel with luminance < 0.6 in x < 40. "Ink at 0.0 pt" is pixel 0 —
  which a DARK room is (both voices' dark rooms are black by R51). The test host IS the dev-store app: its
  `AppearanceController` (VariorumAppDelegate) applies the dev domain's `appearanceChoice` as `NSApp.appearance` at
  launch, so a dev domain left on `dark` renders every pin window dark (`tokens(for: scheme)` / `.fallback(for:)`).
- **The dev domain WAS on dark through the red window.** VX-83's walker (2026-10-08 ~00:24, `vx-83-search-followup.md`
  §WALK EXECUTION) recorded the FOUND posture "`appearanceChoice` dark" and restored it to dark (restore-what-you-found).
- **The red's dated pattern fits it and fits nothing in the code:** red on 2026-10-07 — VM-5's isolated run on
  b6113a66 (**2 issues** = (a) the Index panel AND (b) Read's contents column, a different surface, both at 0.0),
  VX-75's regression (19:42+; 3 issues — these 2 + `BookOrderConversionTests.theNavigatorsChromeStaysInsideItsColumn`,
  the same scan on a third surface), VX-92's regression (night). Green from 2026-10-09 on — 13n-a's stage run
  (11:08, BookOrderConversionTests green), the 13n-b closeout's whole target twice (2026-10-10, 4,212/687: only VX-115
  and VX-149 red), every whole-target run since, and this run's two wide batches (259 and 332 suites). The machine
  today: system appearance Light (no `AppleInterfaceStyle`, no auto-switch); dev domain `appearanceChoice` = `system`.
- **The code archaeology found no fixer.** Between VX-92's red (main e80762bb6) and the 13n-b green (b847a3f4b) the
  Index column's render tree changed only by: `.tourAnchor` on the note rows and mode tabs (13s-b — inert outside a
  tour), the Index footer's receipt slot predicate (`hostsQuietReceipt:` — opacity only), and `QuietReceiptLine`'s
  door buttons (drawn only while a receipt speaks; an idle slot is zero-width). `BookFilterBar`, `BookIndexGrouping`,
  `SideColumn`, `BookArrivals` are untouched since b6113a66; the masthead only GAINED chrome since (13o's 🔍). A
  product regression would also not explain (b) — Read's contents column shares no chrome with the Index panel.
- **One puzzle, recorded:** VX-92's record names only OutlineRoomTests red though its runbook expected the navigator
  pin too; a dark host would redden both. Its log is gone with its worktree; the window's probe answers it.

**What the window must confirm (both runs `OutlineRoomTests` + `BookOrderConversionTests`, alone):**
1. **On the tip, dev domain `system` (today's posture):** `bothColumnsChromeStaysInsideThemAtTheirFloors` GREEN.
2. **The probe — the dev domain set to `dark`** (`defaults write io.lduarte.Variorum.debug appearanceChoice dark`,
   restored to `system` right after and read back): expected RED at "ink at 0.0" on (a) AND (b) — the VM-5
   signature exactly — and the navigator pin red too. If so, VX-77 is **DISMISSED AS HOLLOW** (no product
   regression; the pin's verdict depends on the shared dev domain's appearance) — no product code change, the
   ticket closes as not-a-product-red. If the probe stays green, the hypothesis is falsified and VX-77 reopens on
   the original path (bisect in a later window — never a guess).

**Not built (the brief's rule: never "fix" a green test) — offered for the orchestrator's ruling:** the pins' own
robustness — `window.appearance = NSAppearance(named: .aqua)` in the three luminance-scan mounts (OutlineRoomTests'
`mountBook` and `withReadHost`, BookOrderConversionTests' navigator pin) would make the scan's verdict independent of
the host's posture (the "suites share real UserDefaults" class CLAUDE.md names). A test-only change, red-on-old by the
same dark probe. Owner if not ruled in: a Tests & tooling ticket.

### VX-291 — the fold control (built; runs PENDING the window)

- **Trace (re-read on the tip):** the Outline card's ▸ (`BookView.collapsedPostCard`) was `Text("▸")` at the voice's
  11.5-pt small size, faint, 2 pt of padding — measured off the font: 7.1×14 + 4 = **~11×14 pt**, inside the card's
  own Button, so a near miss opened the note. The expanded header's ▾ (`postHeader`) was a different control (a
  `VoicedButtonStyle(.quiet)` word, ~17×18). The Index's chapter fold (`BookIndexView.chapterRow`) was the bare
  11.5-pt glyph in a plain Button.
- **Built:** ONE control, `Features/BookView/BookFoldDisclosure.swift` — a 13-pt glyph in the quiet ink inside a
  **22-pt square that is the target** (`.contentShape` after the frame) and wears the voiced hover wash
  (`tokens.wash`, radius 4 — `VoicedButtonStyle`'s grammar); the square GROWS OUTWARD — negative padding pulls the
  row's footprint back to 12×13 (≤ the replaced glyph's 14-pt line), so no row grows: the Outline card keeps the
  height `BookOutlineHeights` learned (the 46-pt chrome constant), and the Index chapter row's baseline math keeps
  its height to a fraction of a point (computed off the fonts: the 13-pt glyph's baseline sits ~11.1 pt under the
  footprint's top, the 11.5-pt title's ~11.1–11.3 under its own; the walk eyes it). The
  overhang (5 pt a side) is under every host's spacing (6 · 6 · 8), so the target never reaches a title. Used by
  the card's ▸, the header's ▾ and the Index chapter fold.
- **PROVISIONAL (her bundle):** P-U2-1 — the Index chapter fold takes the same control (the ticket's "if she agrees",
  the plan's recommended yes). P-U2-2 — both glyphs wear the QUIET ink (the ▾'s, `tokens.muted`) where the ▸ wore
  `faint`: one control, one ink. P-U2-3 — the expanded header's title sits ~5 pt further left (the ▾'s footprint
  went from the voiced word's ~17 pt to the control's 12) and the Index chapter title ~5 pt further right (7 → 12);
  the card's title moves ~1 pt.
- **Evidence (a taste row — a geometry oracle + the walk, not red-on-old):** DEBUG `BookFoldGeometry` (each control's
  TARGET and FOOTPRINT rectangles, owned per 18k C4, released with the Outline's and the Index's oracles);
  `VariorumTests/BookFoldDisclosureTests.swift` — the card's ▸ and the header's ▾: target ≥ 22², grown outward past
  the footprint on all four sides, footprint ≤ the replaced 11.5-pt glyph's line, ▸ and ▾ the same box; the Index
  chapter folds the same. On the pre-fix tree nothing reports (red by absence, recorded — no oracle existed). The
  walk checks the size, the hover wash and a click in the overhang (both voices).

### VX-21 — the Book Panel's grips (built; runs PENDING the window)

- **Trace:** the panel's only grip is the chapter row's ⠿ (`BookPanelView.chapterRow`; note rows never wore one — the
  row drags). `BookPanelBrain.chapterGripDrawn(chapterCount:)` read the count alone (17y B2's lone-chapter rule), so a
  stamp-ordered book (her Journal, entry date) with ≥2 chapters drew ⠿ on every chapter row while no note there can be
  placed by hand (a re-place speaks the Manual-order refusal, `dropOutcome`'s `.needsManualOrder`).
- **Built (the ruling's letter — the plan bullet + VR-127):** `chapterGripDrawn(chapterCount:manualOrder:)` =
  `manualOrder && chapterCount > 1`; the view passes `snapshot.reading?.sortField == .manual`. Kept, deliberately:
  every row still drags; the stamp-order re-place still speaks the Manual-order refusal with its road ("non-drag
  roads" read as the gripless note-row drops, which keep their toast); the row menus keep their doors (Move Up/Down
  already hide in a stamp order, `noteMove`). DEBUG `BookPanelGripProbe.drawn[sectionID]` (the probe pattern).
- **PROVISIONAL P-U2-4 (a fact the trace surfaced, for her eye):** a CHAPTER's drag still acts under a stamp order
  (chapter order is the book's own whatever `sort_field` says — `reorderSection` never consults it), so the hidden ⠿
  hides a working handle there; the chapter still drags by its row and its menu's Move Chapter Up/Down stand.
  (a) BUILT — grips only in manual order (the ruling's letter; "a grip" reads as "arrange by hand", the Bookcase's
  P-17y-B2-1 idiom). (b) keep the chapter grip in every order (it acts) and close VX-21 as about NOTE rows only.
- **Recorded edge, not built:** the book view's NAVIGATOR draws the same ⠿ on its chapter rows (`BookView` navigator)
  in every order — the same sibling class if (a) stands; one line, the orchestrator's call (VX-300 or a ticket).
- **Pins (`BookPanelDragGateTests`):** `aGripDrawsOnlyWhereTheBookIsPlacedByHand` (pure) and
  `theMountedPanelDrawsNoGripUnderAStampOrderAndBothInManual` (the mounted panel, entry-date order: neither chapter row
  draws; switched to manual: both do). `aLoneChapterDrawsNoGrip` re-stated in manual order (a justified edit — the
  signature grew).

### VX-69 — the order popover's Escape (built; runs PENDING the window)

- **Trace:** the Bookcase's order popover (VR-115) is the app's own drawing in the board's overlay, not an `NSMenu`, so
  AppKit routes no Esc to it; its closes were the board-local click catcher, the board leaving (`.onDisappear`), the
  window resigning key and the app resigning active (`reportsMenuLifeEnds`) — #188(d)'s "there is no Escape key for it
  yet".
- **Built:** `MenuLifeReporter.swift` gains `MenuEscape.closes(keyCode:modifiers:)` (pure: Esc alone; Shift/Caps Lock
  don't change it; a ⌘/⌥/⌃ chord passes on) and `View.closesOnEscape(while:_:)` — an inert catcher view whose LOCAL
  keyDown monitor (the `PageTurnKeyMonitor`/`WingSwitcherKeyCatcher` shape) closes the menu on an Esc in ITS window and
  consumes it, mounted only while open and inside the background (the board's identity never changes with the
  menu's state). `ShelfView` mounts it beside `reportsMenuLifeEnds`: `.closesOnEscape(while: model.orderOpen) {
  model.orderMenuLifeEnded() }`. No `ShelfViewModel` edit (VX-381 holds that file's open diff).
- **PROVISIONAL P-U2-5:** the Esc is CONSUMED (menu semantics — it closes the menu and does nothing else, wherever the
  keyboard is: the quick entry keeps its text); the № census is a remembered float (#188(b)), never a menu — Esc
  leaves it.
- **Pins (`BookcaseMastheadPopoverTests`):** `escAloneIsAMenusCloseKey` (pure, new API) and
  `escClosesTheOrderPopoverAndLeavesTheCensus` (the mounted board, an Esc keyDown sent through `NSApp.sendEvent` to
  the board's window — the `PagesArrowKeysHostTests` road).

### VX-115 — the stale door pin (test-only; green PENDING the window)

- `BookCollectingDoorsTests.theSettingsDoorIsOneActOnBothRoads` pinned `BookView.surfaceCapabilities ==
  [.openBookSettings]`; the declaration is now `[.openBookSettings, .searchThisBook, .newNoteInGathering]` (13o U3's 🔍
  AND VX-217's "+ new note" — the brief's "add `.searchThisBook`" alone would still be red). **Deviation from the
  brief's letter, recorded:** the pin now reads `contains(.openBookSettings)` — its claim is that the gear's act is
  declared; the full declared ⇔ rendered set is `CapabilityRegistryTests`' walk, and `BookSearchTests` pins its own
  door the same way. No behavior change; no red-on-old owed.

### Commits (U2, all on `vx-382-book-view-doors`, pushed)

ce2316433 (VX-77 archaeology record) · a8e774ea5 (VX-291) · ac24bedbf (VX-21) · ef0405784 (VX-69) · 18e121a08 (VX-115)
· this record commit (U2 BUILT; `BookFoldGeometry`'s unused pin door dropped).

### Verified headless (no stage)

`xcodebuild build-for-testing` green after every piece (`scratchpad/u2/build-*.log`; no warning on a touched file).
No core (`Sources/`) line touched — no `swift test` owed. No `EditorTextView`/`BlockRangeIndex`/`PaneSurface`, no
VX-381 file (`ShelfViewModel` deliberately untouched), no schema, no `Sync/`.

### THE `vx-382-u2` WINDOW — the plan (run IN ORDER, foreground, from `App/Variorum/`; logs to the gitignored `scratchpad/u2/`)

**No revert is in flight now.** Each red-on-old family runs from the committed tree, in place, restored with
`git checkout -- <file>` and a clean `git diff` before the next (the tree is committed, so the restore is safe).

| # | Family | In-place revert | Run (`test-without-building` after an incremental `build-for-testing`) | Expected |
|---|---|---|---|---|
| 0 | VX-77 confirm (no revert) | — (dev domain `appearanceChoice` read first: expect `system`) | `OutlineRoomTests` + `BookOrderConversionTests` alone | GREEN — `bothColumnsChromeStaysInsideThemAtTheirFloors` passes |
| 1 | VX-77 probe — the dark host | `defaults write io.lduarte.Variorum.debug appearanceChoice dark` (zero app instances first) | the same two suites | RED "ink at 0.0" on (a) the Index panel AND (b) Read's column (2 issues — VM-5's signature) + the navigator pin. Restore `appearanceChoice` to the FOUND value and read it back BEFORE the next row |
| 2 | VX-21 | `BookPanelModel.chapterGripDrawn`: `manualOrder && chapterCount > 1` → `chapterCount > 1` | `BookPanelDragGateTests` | RED: the pure pin's stamp-order arms (3) and the mounted pin's stamp-order arm; manual arms + `aLoneChapterDrawsNoGrip` green |
| 3 | VX-69 | `ShelfView`: delete the line `.closesOnEscape(while: model.orderOpen) { model.orderMenuLifeEnded() }` | `BookcaseMastheadPopoverTests` | RED: `escClosesTheOrderPopoverAndLeavesTheCensus`'s first arm (the popover stays open); the census arm and `escAloneIsAMenusCloseKey` green |
| 4 | VX-291 guard probe (the pin bites) | `BookFoldDisclosure`: delete the two negative `.padding` lines | `BookFoldDisclosureTests` | RED: "grew OUTWARD" and "footprint ≤ the replaced line" on every control (the footprint IS the 22-pt box); the 22² claim green |
| 5 | **Green batch** | — | `xcodebuild test-without-building -scheme Variorum -destination 'platform=macOS' $(cat scratchpad/u2/only-testing.args)` — **125 suites** (`scratchpad/u2/suites.txt`: every suite whose file names a changed type — the book view / Index / Book Panel / Bookcase board / menu-life family — plus the lints, the registry walk, OutlineRoom, BookOrderConversion, the Bookcase-mounting shell suites and the tours) | GREEN except, possibly, `DestructiveUndoWarningTests.redoNeverAsks` (VX-167's parked load-flake — re-run ALONE before attributing). `BookCollectingDoorsTests` GREEN (VX-115). `OutlineRoomTests` GREEN. Anything else red is a finding |

VX-291 has no red-on-old by construction (a taste row: a NEW oracle — nothing reports on the pre-fix tree).

### THE U2 WALK — the plan (dev store, the batch's Debug product, no posture change; screens `scratchpad/u2/screens/`)

Gate as U1's (§THE U1 WALK step 0–1): the claim line verbatim; `pgrep -fl 'Variorum.app/Contents/MacOS'` — her
`/Applications` app ABSENT (else stop, never quit hers); grants checked (`guard.sh --author`, an AX probe); launch
`~/Library/Developer/Xcode/DerivedData/Variorum-dkbmlpshalzxqeftsymzimjxpdhl/Build/Products/Debug/Variorum.app` with
`open -n`, pid by PATH; dismiss What's New if it shows; a Castle lock screen ⇒ `~/.variorum/dev-castle.env` values
only. Record the starting posture (voice via Settings ▸ General/Appearance — read; `defaults read
io.lduarte.Variorum.debug appearanceChoice`). Every key through `Tools/WalkKit/keys.sh <pid> '…'` (Esc = `key code
53`), every click through `Tools/WalkKit/click.sh <pid> x y`; region captures only (`screencapture -x -R…`); acts ≥2 s
apart; re-read points from a fresh capture after any voice flip.

**Voice 1 (the starting voice):**
- **W1 — the Outline ▸ (VX-291):** a chaptered book in Outline (the seeded sherlock — ⌘K → its name → ⏎). Capture a
  collapsed card's head (the 13-pt ▸). Hover the ▸ → capture the 22-pt wash. Click at a point INSIDE the 22-pt box but
  OUTSIDE the old glyph (≈ 4 pt left of the glyph's left edge, or ≈ 6 pt below its centre) → the note UNFOLDS in place
  (never opens in Write) → capture.
- **W2 — the ▾ (VX-291):** the now-expanded header's ▾: hover → capture the same box; click in its overhang → the note
  collapses back to its card → capture (the card's height unchanged by eye against W1's).
- **W3 — the Index chapter fold (VX-291, P-U2-1):** the Index tab; a chapter row's ▾ — hover → capture; click its
  overhang → the chapter folds → capture; again → unfolds.
- **W4 — the Book Panel grips (VX-21):** open a sherlock story in Write (⌘K → its title → ⏎); show the Book Panel
  (the pane's book icon / ⌘K "Book Panel"); capture: ⠿ on the chapter rows (manual order — read the book's order
  label first; expect manual). In the book's Outline: the navigator's `order · … ▾` → "Entry date ↑" → the menu again
  → "Save as This Book's Order". Back to the story's Book Panel → capture: NO ⠿ on any chapter row. RESTORE: the
  navigator's `order ▾` → "Manual order" → "Save as This Book's Order" → its label reads manual again; the panel's ⠿
  back (capture). (`saveOrder` writes `sort_field`/`sort_dir` only — positions untouched, so the restore is exact.)
- **W5 — the order popover's Esc (VX-69):** the Bookcase; click `order · … ▾` → the popover open (capture); Esc
  (`keys.sh … 'key code 53'`) → closed (capture). Then click into the quick entry, type `abc` (keys.sh), open order ▾,
  Esc → the popover closes AND the quick entry still reads `abc` (capture); clear the field (select-all + delete via
  keys.sh) — nothing is filed. Then № (the census float) open → Esc → it STAYS (capture) → № again to close it (its
  found state restored).

**Voice 2 (flip via Settings ▸ Appearance's voice radio, AX):** re-capture the FACES only — W1's ▸ at rest + hover,
W2's ▾ hover, W3's chapter fold hover, W4's grips (manual) present. Then restore the starting voice and read it back.

**Restore & quit:** sherlock's order back to manual (W4, verified); no note filed, no text typed into a note; voice and
`appearanceChoice` as found (read back); quit by identity (`tell application id "io.lduarte.Variorum.debug" to quit`);
`pgrep -fl 'Variorum.app/Contents/MacOS'` EMPTY before reporting. The stage is NOT released by the implementer.

### ORCHESTRATOR RULINGS on U2 (2026-10-18, repo-first before the window)

- **R-U2-A — VX-21's gate is CAPABILITY-SHAPED, PROVISIONAL: a grip renders exactly where the drop would act.**
  VR-127's own sentence is the rule — *"you shouldn't see draggable bars when you can't drag"* (her words, the
  librarywalkpolish ledger row; her observed case was her Journal under Entry date, "where no row can be placed by
  hand"). The row's parenthetical remedy "(grips render only when the book's order is manual)" was the sketch
  written before U2's trace fact that a CHAPTER's drag still acts under a stamp order (`reorderSection` is
  order-independent; smart readings have no sections at all). Her principle outranks the sketch where they diverge
  — the same shape as R-U1a-2. So: NOTE-ROW grips render under manual order only (a note drop cannot land in a
  derived order — the false offer she named); CHAPTER grips render in every order (their drop acts); the
  Manual-order toast stays for non-drag roads on notes. The implementer first CONFIRMS the panel's grip inventory
  (which rows carry grips today, which its ac24bedbf fix gated, and which grips her Journal case actually showed —
  the record should explain her complaint, not argue with it) and re-cuts to this rule, pins adjusted (red-on-old:
  a derived-sort panel shows no NOTE grips while chapters keep theirs; old code shows note grips). CONSEQUENCE:
  the book-view navigator's chapter ⠿ is honest in every order and stays UNCHANGED. If the inventory check shows
  the panel has ONLY chapter grips (so her Journal case cannot have been note rows), STOP and report before
  re-cutting — the ruling's premise would be wrong and I re-rule. For her bundle as P-U2-4 (options: the letter —
  every grip manual-only; this ruling; chapters-everywhere plus note grips too with drop-to-manual conversion).
- **R-U2-B — the three luminance-scan pins become host-appearance-independent (test-only), built as the LAST
  commit.** The VX-77 class (a walker leaves the dev domain dark; three geometry pins read black rooms as "ink at
  0.0" and cry regression) ends structurally: the scan pins pin their windows to `.aqua`. Window order: row 0
  (today's posture) green → the dark probe WITH the `.aqua` commit reverted in place → RED at "ink at 0.0" (the
  hypothesis's confirmation AND the pinning's red-on-old) → restore the commit → the same suites under dark
  defaults → GREEN (host-independent) → restore `appearanceChoice` as found, read back. If the dark probe does NOT
  go red, the VX-77 hypothesis is wrong: drop the `.aqua` commit entirely and VX-77 returns to the original path
  (bisect, never guess).
- **VX-115's contains-style pin is ACCEPTED** (`contains(.openBookSettings)` — the full door set is the registry
  walk's job; `BookSearchTests`' idiom; the brief's "add the second door" was written before VX-217's third door
  existed).

### R-U2-A — the grip inventory (the ruling's FIRST step): **STOPPED — the panel has ONLY chapter grips** (implementer, 2026-10-18)

Per the ruling's own stop clause, VX-21 is NOT re-cut; ac24bedbf stands untouched until the orchestrator re-rules.

- **Which rows carry grips — today (HEAD) AND as shipped in 0.9.2 (0bdbe70ef, her report's build), read from the
  source:** the Book Panel draws exactly ONE grip glyph, the ⠿ on CHAPTER rows (`BookPanelView.chapterRow`,
  `Text("\u{283F}")`, drawn by opacity when ≥2 chapters — `chapterGripDrawn`). NOTE rows draw no grip in either
  build — they are `.draggable` (gripless; the 17y B2 trace's own words: "Note rows (no grip; the row drags)").
  Across EVERY book surface the only ⠿ sites are chapter-shaped too: the book navigator's chapter rows
  (`BookView.swift` ~:736 — unconditional) and the Outline's chapter headings (`chapterHeader` ~:2092 —
  unconditional). No note row wears a grip anywhere, in 0.9.2 or now.
- **What ac24bedbf gated:** the Book Panel's chapter ⠿ only (`manualOrder && chapterCount > 1`) — it could gate
  nothing else, there being nothing else.
- **Her Journal case, explained (her words, the VR-127 issue verbatim — `notes/source/github-issues-export-2026-10-06
  .json`):** *"in the journal, you can't reorder the entries since they're date ordered, but you still see the
  draggable bar which isn't really true. that should be corrected so that you don't see draggable bars when you
  can't drag."* The bars she saw can only have been CHAPTER ⠿s — her Journal carries chapters (the panel draws them at
  ≥2; the navigator and the Outline's headings draw them at any count). They sit in the list beside the ENTRIES she
  tried to reorder, so they read as entry handles; the entries themselves (gripless, still draggable) refuse a
  re-place under Entry date with the Manual-order toast. The issue's line "the panel's note rows still render grips"
  was the intake's misreading: the rows DRAG, the grips are the chapters'. And the chapter ⠿s she saw DO act under
  that sort (`reorderSection` never reads `sort_field`).
- **So R-U2-A's cut has no note-row grip to hide**, and its "chapter grips in every order" half would put her
  observed bars back exactly as she reported them. Options for the re-rule (none built):
  (a) **as built** (ac24bedbf): the panel's chapter ⠿ hides under a stamp order — her words honoured ("no draggable
  bars" there); costs a visible handle on a drag that still acts (the chapter row still drags and its menu's Move
  Chapter Up/Down stand). Siblings: the navigator's and the Outline headings' ⠿ would want the same rule for one
  grammar (not built).
  (b) **chapter ⠿ everywhere, the NOTE rows' drag made honest instead**: under a stamp order a note row's drag still
  starts (it must, to file into ANOTHER chapter — the legal half), so "can't drag" holds only for a re-place; no glyph
  is involved. This leaves her bars on screen.
  (c) **the bars made unmistakably the chapters'** (a design change — e.g. the ⠿ only on the chapter row's hover, or
  moved to the heading's trailing edge) in every order — a taste call for her.

### R-U2-B — the `.aqua` pinning (BUILT 8b38c88bb, test-only)

`window.appearance = NSAppearance(named: .aqua)` in the three luminance-scan mounts: `OutlineRoomTests.mountBook`
(:221 — every OutlineRoom mount), `OutlineRoomTests.withReadHost` (:526), `BookOrderConversionTests
.theNavigatorsChromeStaysInsideItsColumn` (:337). `build-for-testing` green. Its in-place revert for the window: delete
those three lines (no later commit touches either file, so `git revert --no-commit 8b38c88bb` is equivalent).

### THE `vx-382-u2` WINDOW — REVISED sequence (supersedes rows 0–1 above; rows 2–5 unchanged except row 2)

Zero app instances before every dev-domain write; read `appearanceChoice` FIRST and restore exactly that value.

| # | Step | Run | Expected |
|---|---|---|---|
| 0 | today's posture (`appearanceChoice` as found — `system` at this writing), the tip | `OutlineRoomTests` + `BookOrderConversionTests` alone | GREEN |
| 1 | `defaults write io.lduarte.Variorum.debug appearanceChoice dark` + R-U2-B reverted in place (the three `.aqua` lines deleted) | the same two suites | RED "ink at 0.0" on (a) the Index panel AND (b) Read's column (VM-5's 2 issues) + the navigator pin — the hypothesis CONFIRMED and R-U2-B's red-on-old. **If NOT red: stop — drop 8b38c88bb (revert commit) and VX-77 returns to bisect** |
| 1b | R-U2-B restored (`git checkout -- <both files>`, clean diff), dark defaults kept | the same two suites | GREEN — host-independent |
| 1c | `appearanceChoice` restored to the found value, read back | — | — |
| 2 | **VX-21 — HELD for the re-rule** (as built, the family stands as written above; a re-cut rewrites it) | `BookPanelDragGateTests` | per the re-rule |
| 3–5 | VX-69 family · VX-291 guard probe · the 125-suite green batch — as written above | | |

The walk's W4 (the Book Panel grips) likewise waits on the re-rule; W1–W3 and W5 stand as written.
