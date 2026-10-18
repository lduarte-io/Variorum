# VX-382 — Run: Book view doors & reds (VX-284 part B)

**STATUS: AWAITING KICKOFF — written 2026-10-17 at her VX-284 split sitting; the run ticket exists (VX-382, Todo),
its branch and worktree are minted by ITS orchestrator at kickoff.** Members (sub-issues of VX-382), in order:
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

## LIVE STATUS

*(The orchestrator fills this at kickoff.)*
