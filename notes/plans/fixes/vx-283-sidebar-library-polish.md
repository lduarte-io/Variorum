# VX-283 — Run: Sidebar & Library polish

**STATUS: OPEN — kicked off 2026-10-14 (afternoon), TRIMMED at her kickoff triage to nine members.** Run ticket
**VX-283** (project *v1 release readiness*) · branch `vx-283-sidebar-library-polish` · worktree
`~/dev/variorum-vx-283` on the Pro · PR `VX-283: …` (merge commit only). Shape: `/architect-phase vx-283`, at her
word. Orchestrator: session **vx-283** (Opus 5.5 — the runway's cast rule: *"I decided to orchestrate with Opus to
reduce load on Fable and make sure there was enough for reviews"*).

**Cast — her word at kickoff (2026-10-14, the question tool):** "xhigh builds, max reviews". So:
`opus-implementer` at **xhigh**, ONE fresh session per unit, strictly sequential; the ladder's cold reviews are
**`opus-reviewer` at max**, fresh per round, running `notes/REVIEW_PROMPT.md` verbatim (same-model: the
orchestrator arbitrates against the spec). **SUPERSEDED for the ladder by her word (2026-10-14, evening, verbatim): *"you can use fable xhigh to review
instead of opus at max if you werent already going to."*** So the cold reviews are **`fable-reviewer` at xhigh**,
fresh per round, `notes/REVIEW_PROMPT.md` verbatim — the CROSS-MODEL flow (CLAUDE.md "Two reviews"): Fable makes the
final call on each finding after the Opus implementer's agree/dispute; the implementer applies the confirmed fixes
(red-on-old each, the suite green); the next fresh reviewer re-checks them; a final round's fixes get the
orchestrator's line-by-line check; Fable writes a fix itself only for a finding it marks FINDER-FIXES (no `Sync/`
lines here). No editor seam, `Sync/`, custody or default's-meaning content is
expected, so no Fable round is owed; if a unit's diff reaches one of those after all, the orchestrator says so
to her before the ladder. No agent runs concurrently with another.

**Her walk rule — her word at kickoff (2026-10-14, verbatim):** *"I want you to have an opus on xhigh walk with
screenshots of the areas where the UI changed - especially the tab bar, which is having its scroll fixed +
getting taller. it should look right after it's done."* So **every unit closes on a WALK by a fresh Opus at
xhigh** (not the unit's implementer) with screenshots of every area its diff changed, the Open list ("the tab
bar") above all; the orchestrator LOOKS at every screenshot before the unit's record closes, and anything that
does not look right goes back to a fix leg and is re-walked. Screenshots live in `notes/plans/vx283-screens/uN/`
(gitignored); their absolute paths go to her in the unit's report (never an Artifact — her standing rule).

The kickoff is the runway's VX-283 section (`notes/plans/vx-33-release-runway.md`, as trimmed on `main` at
`5911d1db`), plus its §2 conflict map and §3 rules for every run. Each member's ticket body carries its own trace;
the briefs below quote what binds.

## Her kickoff triage (2026-10-14, verbatim — the record of the trim)

Her opening ask: *"I want to triage what's most important for launch because this run seems huge. can you tell me
all the members of this and give me suggestions? I think that trimming export might be possible / good. I want to
know which of these you think are quick / important / good to keep in."*

The orchestrator's table (all sixteen members, sized as scope only) recommended keeping the Open list asks, the
Library's first-use defects and the red lint; trimming VX-70 (except the Open list's own rows), VX-19, VX-167 and
VX-289's selection model; VX-122 her call; the exports trimmable but small. Her answers (the question tool):
- **Exports:** "Trim both (Recommended)" — VX-125 and VX-126 to after launch.
- **Other trims:** "VX-70 + VX-19 + VX-167 (Recommended)", "VX-289's multi-select (Recommended)", "VX-122 (Library
  revivals)", and in her own words: *"I don't want to contort VX-123 to be fixed incorrectly when it's really a
  sync issue. so we can wait on that one and 122 - those are niche nits. we don't need to do VX-19 either. file a
  ticket for the half of 289 that we aren't doing but close all now is good."*
- **Effort:** "xhigh builds, max reviews (Recommended)".

Her confirming list differed in two places (it kept VX-70 and cut VX-245); asked, she ruled:
- **VX-70:** "Only on the Open list's rows (Recommended)" — the compact chip rides VX-288 on the Open list's rows;
  VX-70's other row types are Parked.
- **VX-245:** "Keep (Recommended)".

**Linear, done at kickoff:** VX-123 · VX-122 · VX-19 · VX-167 · VX-70 · VX-125 · VX-126 moved off the run, the
Pre-launch label removed, state Parked, her words on each as a comment (VX-123/122/19/167/70 also leave the *v1
release readiness* project; VX-125/126 keep *13n*). **VX-344 born** (Parked): VX-289's selection half. VX-289
retitled to Close All; VX-288 notes the chip; the run and its nine members In Progress.

## The members (the ledger — one row each, every row owned)

| Ticket | What | Unit | Status |
|---|---|---|---|
| VX-286 | The Open list's scroll bar draws over the ✕ (Starred's ★ too) | U1 | NOT-STARTED |
| VX-285 | The Open list grows into the sidebar's free space, stopping above the sync footer | U1 | NOT-STARTED |
| VX-287 | Close Note = ⇧⌘W, landing on the next note in the Open list | U1 | NOT-STARTED |
| VX-289 | Close All (the selection half → VX-344) | U1 | NOT-STARTED |
| VX-288 | The Open list drag, the light version: drops land where they look, an insertion line, an end zone, a settle, the compact chip on its rows | U2 | NOT-STARTED |
| VX-121 | Toasts cover the Bookcase's quick-entry box | U3 | NOT-STARTED |
| VX-175 | The Library's controls row pushes the info panel off the 1240-pt default window | U3 | NOT-STARTED |
| VX-20 | The dark heading band (her #188(m): the bands match) | U3 | NOT-STARTED |
| VX-245 | The line-limit lint red on main — its six non-MCP sites | U3 | NOT-STARTED |
| VX-359 | The View menu's doubled separator after Close Split (born at U1b's F-3 trace — `EditorCommands.swift:1023`, `07d9f583`; a one-line rider, the orchestrator's call, told to her) | U3 | NOT-STARTED |

## Her rulings that bind this run (verbatim where she wrote them)

- **VX-285** (2026-10-13): *"I don't like that the open tabs cut off like this - they should extend further down if
  there's the space for it (though they should always stop before the syncing area begins."* Her notes: *"Open
  tabs should extend the full height of the screen that they can (until the synced portion of the bottom row
  starts, wherever that is)"*. **Starred keeps its ~7** (her own earlier words, `SidebarLayout.swift:151-154`), so
  the shared constant splits.
- **VX-286** (2026-10-13): *"also, the scroll bar on there goes over the x out button"* · *"the tab close x gets
  hidden behind the scroll"*.
- **VX-287** (2026-10-13, verbatim): *"for command W - can we do shift command W? i like that better than control,
  it's more natural to type. i think landing in the next note on the list is perfect-that way you can close them
  all quickly."* Close Note = **⇧⌘W**; **⌘W keeps closing the window, unchanged**; the pane lands on **the next
  note in the Open list**. Fallbacks (PROVISIONAL, the implementer's call per the ticket): on the last row, the
  previous note; the list empty, the Library. **Verify ⇧⌘W is free FIRST** (menus, the capability registry, the
  note-only and quick-note windows); if it collides, STOP and report — never rebind silently.
- **VX-289:** *"close all now is good"* — Close All only, landing by VX-287's rule; closing stays VIEW-ONLY (the
  note itself is untouched — `SidebarView.swift:109-115`).
- **⇧⌘W VS MACOS WINDOW TABS — her ruling at U1's stopped window (2026-10-14, the question tool):** the window's
  step 1 measured that once two Variorum windows are merged into native window tabs, AppKit adds File ▸ Close
  Window on ⇧⌘W and takes the key (View ▸ Close Note loses its equivalent there; one ordinary window is free —
  `notes/plans/vx283-screens/u1/p0/`). Offered (a) keep ⇧⌘W and turn native window tabs off, (b) ⌃⌘W, (c) keep ⇧⌘W
  and accept it, she chose **"Keep ⇧⌘W, live with it"**: in a tabbed window ⇧⌘W is macOS's Close Window; Variorum
  changes nothing about window tabbing. Not a finding for the walk or the ladder.
- **THE ✕ ON THE NOTE YOU'RE LOOKING AT — her ruling at U1's READY (2026-10-14, the question tool):** asked
  *"Clicking a row's ✕ (or right-click ▸ Close) on the note you're currently looking at: today the row disappears but
  the note stays on screen with no row. Should it behave like ⇧⌘W and move you to the next note?"*, she chose **"Yes,
  same as ⇧⌘W"** — closing the open note's row moves the pane to the next note (else the previous, else the
  Library), like closing the active tab in Safari; a ✕ on any other row just removes that row, as today. This
  supersedes P-U1-2's "the ✕ and right-click Close still close the row only". **PROVISIONAL edge (the orchestrator,
  P-U1-5):** a row whose note the OTHER pane of a split shows moves that pane in place, focus kept (Close All's
  P-U1-3 road); the focused pane's takes the shell's open-note road as ⇧⌘W does.
- **VX-288** (2026-10-13): *"the dragging between open notes in there needs to be smoother - it should be as smooth
  as the editor drag with a nice little line showing as you hover and a nice fit / snap into place because right
  now it feels janky to use."* Her ruling on the shape: **the light version first** (the ticket's shape S); her walk
  decides whether the M shape (lift-and-settle) is still wanted. The chip: "Only on the Open list's rows".
- **VX-175:** pre-launch at her word (2026-10-13, the runway §6).
- **VX-20:** her #188(m) ruling — **the bands match**: in dark, the List's pinned "books"/"notes" heading must not
  draw as a warm grey band (#2F2D29) across the black room; it matches the old List's own heading, which sits
  almost on the room (the record: `notes/plans/librarywalkpolish-ladder-round1.md` §THE ONE FINDING; QUESTIONS
  #188(m)).
- **VX-121:** the ticket's class statement — ANY toast over the Bookcase collides with the quick-entry band; the
  placement rule keeps toasts clear of it.

## THE ARCHITECTURAL RULES — binding (the 13b constitution P-1…P-9, copied verbatim per `/architect-phase`)

- **P-1 — One capability registry.** Every user-facing act is declared
  exactly once: verb, scope (block/take/post/book), per-mode availability
  rule, its doors (menu / context / bar / shortcut / palette), and its
  refusal copy. Surfaces render their doors FROM the registry; gating is
  data, never per-view if-statements. A registry-walk test asserts every
  declared door exists and every rendered door is declared. This kills the
  D3/D4 class structurally — the capability matrix stays green by
  construction instead of by audit.
- **P-2 — Fire-and-DO (R115).** A rendered door either performs the act —
  including any mode-switch choreography, done visibly for the user — or
  delivers the operations layer's real refusal. A door that can never act in
  its context isn't rendered. Lecture-and-redirect is retired.
- **P-3 — One text surface, one liveness authority.** ONE TK2 surface
  component (live + read modes; one measurement brain — the width-gated
  remeasure; the shared canary) that every pane composes; the live editor
  core's identity machinery (`BlockRangeIndex`, crystallization) becomes its
  live mode, not a sibling implementation. "What text does this pane show,
  and is it live" is answered by ONE pure, unit-tested authority
  (`PaneTextAuthority`); views never re-derive it. Its invariants stated as
  code: exactly one live pane; the live pane is buffer-authoritative; read
  panes are projection-authoritative once caught up.
- **P-4 — Broadcasts carry signals, never decisions.** NotificationCenter
  may announce that something happened (mode changed, post opened); no
  listener derives business state or availability from a broadcast, and no
  flow's correctness depends on broadcast ordering. Cross-feature flows
  route through composition. (Stage 0's survey enumerates today's
  notification bus; Stage 1 disciplines it.)
- **P-5 — The friction doctrine (R116).** Repeated pushback against a rule
  marks an under-architected feature. The response is never another patch:
  write the feature's DESIGN MEMO — intended behavior whole, edge cases
  enumerated on paper, refusal wordings, undo story — get the author's
  rulings on the product-flavored edges, then build to the memo. Happy path
  ships first, but the edges are *decided at design time*, not discovered by
  the author. First two memos owed: **merge** and **the W ceremony**.
- **P-6 — The tutorial is the executable spec (R113).** The guided tutorial
  flow is the contract for every happy path. It stays green — automated
  where the harness allows, screenshot-walked otherwise — and any change
  that breaks a tutorial step is a regression by definition.
- **P-7 — Find bugs before she does.** Every layer keeps a proactive
  harness: the ops-layer soaks (exist), the board/view-model invariant soak
  (Stage 1), the registry walk (P-1), the per-batch scripted screenshot
  walkthrough. Red-on-old stays absolute: no bug-class fix without a pin
  that fails on the pre-fix code.
- **P-8 — Standing law, consolidated.** P1–P3 performance invariants bind
  the rebuilt layer exactly as they bind the substrate (invalidation ∝
  realized rows; one live editor; virtualized long views). Overlays, never
  rendering attributes. Chrome `fixedSize` texts always carry a `lineLimit`
  (the b6dae25 class). `Theme/VoiceControls.swift` is THE chrome vocabulary.
  Complexity lives in the store; restraint lives in the UI.
- **P-9 — No god objects in the frontend either.** A view model mixing
  board layout, text authority, and gesture routing splits by concern
  (`TakesViewModel` at 890 lines is the standing counterexample). Same
  hygiene rule as the substrate, applied where it was being waived.

**Application notes (the skill's precisions, binding the same way):** P-1's scope is the ROUTED vocabulary —
Close Note and Close All are routed acts (a menu item + a shortcut + the Open list's right-click), so they are
declared in the registry and their doors render from it; surface-local doors that already work are not
retro-declared. Storage-coupled code stays feature-side; parity refactors keep pre-move names compiling (zero
test edits as the parity proof). The overlay/sink delivery law binds the drag's insertion line (it refreshes on
every input axis — hover, scroll, list change — never computed before layout exists).

## The run's surfaces and overlaps (declared at kickoff)

- **Owned:** the sidebar's Open list and Starred sections (`Features/Library/SidebarView.swift`, `Core/Views/SidebarLayout.swift`),
  `Workspace/WorkspaceModel.swift` (close / close-all / the landing after a close; `move` and its drop arithmetic), the capability
  registry's new Close Note / Close All entries and their menu (`EditorCommands`) and context doors; the toast
  host's placement over the Bookcase (`Registry/StatusToast.swift` and its host); the Library's controls row (`Features/Library/LibraryCatalogView.swift` and its row components); the
  Library List's pinned heading face (`LibraryListHeader` in `Features/Library/LibraryListFace.swift`); the six `.fixedSize()` sites of VX-245.
- **Zero `Sync/`, custody, Keychain, schema or editor-seam lines.** Castle (VX-305) holds the one Sync/-custody
  slot. If a unit's trace reaches the editor seam (`EditorTextView`, `BlockRangeIndex`, `PaneSurface`), STOP and
  report — that changes the cast.
- **Overlap — VX-336** (session vx-336, live): its surfaces are `Sources/VariorumMCP/`, the ops it wraps, the MCP
  navigator, Compare's show target, `TutorialSeeder`'s MCP chapter, `ShellActions`' undo copy. None is ours. If a
  unit must edit `ShellActions` or the navigate-away road (`.variorumNotesDeleted` → `WorkspaceModel.notesDeleted`),
  the orchestrator tells vx-336 first; whichever merges second merges main in first.
- **Overlap — VX-284** (not yet kicked off): `ShellRouter.adopt(landing:)` is its landing road; Close Note's
  landing uses the EXISTING open-note road, never a new landing authority.
- The navigate-away road is VX-246's (merged); Close Note does not ride it (closing is view-only, the note lives).

## The units (acceptance units — one implementer session each; the evidence named up front)

**U1 — the Open list's layout and closing: VX-286 · VX-285 · VX-287 · VX-289.**
- VX-286: move the side padding inside the scroll content (or `.contentMargins`) on BOTH scrolling sections (Open
  and Starred), so the overlay scroll bar rides in the existing margin, never over ✕ or ★.
- VX-285: a PURE `SidebarLayout` function for the Open list's max height = the outer scroll's visible height −
  the measured height above the list − bottom padding, floored at a few rows (short windows fall back to the
  outer scroll); the `count <= 7` sizing switch becomes "the rows fit". Starred keeps its ~7 (the shared constant
  splits). The two pins that change BY HER ASK are edited in place with an annotation naming VX-285:
  `ShellChromeTests.theOpenStripWindowIsHerSevenAndAHalf`, `StarredScrollTests.theWindowIsOneConstantForBothScrollingSections`.
- VX-287: one Close Note act (registry entry + a menu item + ⇧⌘W) that removes the row AND moves the focused pane
  to the next note in the Open list (fallbacks as ruled above). ⇧⌘W collision check FIRST, recorded.
- VX-289: Close All (registry entry; the Open list's right-click + a menu twin), landing by VX-287's rule.
- **The tickets' traces (read-only, 2026-10-13, against an older main — VERIFY each against this tip; paths under
  `App/Variorum/Variorum/`):**
  - VX-285: the list's scroll view is capped at row height × 7.5 = 225 pt (`Features/Library/SidebarView.swift:749-752`,
    `Core/Views/SidebarLayout.swift:160,182-191`); the half row is deliberate (the 8th row clips mid-text by design).
    The empty space below is the outer last-resort scroll's unused room (`SidebarView.swift:283-311`); the sync
    footer sits OUTSIDE that scroll (`RootView.swift:584-601`).
  - VX-286: macOS overlay scroll bars draw over the scroll view's trailing edge; each row fills the full width and
    the ✕ sits only 8 pt in (`SidebarView.swift:435-446`, `:811-815`); the 12-pt side margin is applied OUTSIDE the
    scroll view (`:761`), so the bar lands on the ✕. Starred's ★ overlaps the same way past 7 stars (`:491-503`,
    `:552-556`).
  - VX-287: no close-note shortcut exists. The ✕ (`SidebarView.swift:811`) and the right-click Close (`:868`) call
    `WorkspaceModel.closeNote` (`Workspace/WorkspaceModel.swift:342-345`), which removes the ROW ONLY — an on-screen
    note stays shown with no row until opened again (which re-adds the row, `:283-286`). The app never binds ⌘W
    (`EditorCommands.swift:158-340`), so ⌘W is the system's File ▸ Close (closes the window). Context for the
    collision check: ⌘W is on the reserved list (`notes/plans/vx-156-grant-ux-brief.md:424`); the note-only and
    quick-note windows keep ⌘W closing them (the pad's "⌘W files it", `notes/plans/phase-13u3-faces.md:1432`);
    ⌃⌘W was checked free on 2026-10-11 (`brief:430`).
  - VX-289: there is no selection model (out of scope now — VX-344); the highlight is the pane's current note
    (`SidebarView.swift:779-781`), a plain click navigates (`:839`). `WorkspaceModel.move` already takes several rows.
- **Evidence:** pure-function + model tests (the height function; close-and-land: next / previous / empty →
  Library; Close All) red-on-old where a bug is fixed (VX-286's padding if a layout pin can see it; VX-285's cap);
  the registry walk green with the new doors; the Mac batch over every suite that exercises a changed source file;
  then **the Opus walk** (below) — the Open list with many notes open in a tall window (it runs to just above the
  sync footer and stops there) and in a short one (falls back to the outer scroll), the scroll bar in the margin
  with every ✕ clear, Starred past 7 stars with every ★ clear, ⇧⌘W pressed repeatedly (each lands on the next
  note; the last falls back), Close All, ⌘W still closing the window — in Study and Terminal, light and dark.

**U2 — the drag: VX-288 (the light version) + the compact chip on the Open list's rows.**
- Keep the system drag; fix the drop arithmetic (a drop on the lower half of a row lands AFTER it; the row just
  below is reachable; downward drops no longer land one row short); an END ZONE reaches the last slot; a 2-pt
  ring-colour insertion line on hover (the book navigator's precedent, `BookView.swift:838-876`); an animated
  settle on the move; the compact title chip at the cursor (R-LWP-3's precedent, the Bookcase's chip).
- **The ticket's trace (read-only, 2026-10-13 — verify against this tip):** the list uses the system drag —
  `.draggable` plus a drop target on each row (`Features/Library/SidebarView.swift:844-853`); no hover feedback, the
  drag image is a snapshot of the whole row, the move isn't animated (`Workspace/WorkspaceModel.swift:382-385`).
  **The bug under the jank:** every drop lands BEFORE the row under the pointer — dropping on the row just below does
  nothing (`move([0], toOffset: 1)`), every downward drop lands one row short, the last slot can't be reached (no end
  zone); the tests check only the move arithmetic (`VariorumTests/WorkspaceNavigationTests.swift:226-275`) and their
  comment still describes the old List drag. Precedents: the editor's block drag (direct mouse tracking, a pure
  midpoint rule, a 2.5-pt ring-colour bar — `BlockDecor.swift:448-460`, `:1156-1191`, `:1268-1305`); the book
  navigator (a 2-pt ring-colour line on the hovered row + a 28-pt end zone — `BookView.swift:838-876`); the
  Bookcase's compact title chip under the cursor (R-LWP-3).
- **Evidence:** the drop arithmetic pinned RED-FIRST on the old code (`WorkspaceNavigationTests` — and its stale
  List-drag comment corrected); the Mac batch; **the Opus walk** with real drags (`cliclick dd/dm/du`):
  screenshots mid-drag showing the line and the chip, after-drop orders for a drop on the row just below, a long
  downward drop, the end zone, and an upward drop — both voices.

**U3 — the Library and the red lint: VX-121 · VX-175 · VX-20 · VX-245.**
- VX-245: `.lineLimit(1)` for a label, `.lineLimit(nil)` with the reason where it is prose — per site; the lint
  `ChromeLineLimitTests.everyBareFixedSizeStatesItsLinePolicy` is the red-to-green pin (check first that it is red
  on this tip and that the MCP two are already gone, VX-281).
- VX-121: toasts over the Bookcase anchor clear of the quick-entry band. **PROVISIONAL (the orchestrator's ruling,
  P-U3-1):** anchor ABOVE the band (same horizontal centre), as a placement rule the toast host reads — never a
  per-toast offset. A pure placement function pinned red-on-old if the host's geometry allows.
- VX-175: at the 1240-pt default window with the info panel open, nothing is pushed off the window and the search
  field never squeezes to a sliver. **PROVISIONAL (P-U3-2), on the in-repo `ViewThatFits` precedent
  (`LibraryBulkRow`, UXR1-3):** the controls row stays one line when it fits; otherwise it becomes two lines — the
  search field on its own full-width line, the scope/mode/sort/when controls on the next. Her eye at the walk
  decides; the implementer may come back with a better composition BEFORE building it (the architect rules).
- VX-20: the List's pinned heading in dark matches the old List's own heading (the voice's own colours — the room
  plus its hairline — the ladder record's option 2), light unchanged. The List-face rig's dark switch
  (`TEST_RUNNER_VARIORUM_LIBRARY_LIST_FACE_APPEARANCE=dark`) is the evidence tool; a pin on the colour source if
  the face exposes one.
- VX-359 (rider, born at U1b): delete the extra `Divider()` at `EditorCommands.swift:1023` (SwiftUI already separates command groups); a source-read or menu-structure pin if one is honest; the walk captures the View menu.
- **Evidence:** the lint red→green; the pins named above; the Mac batch; **the Opus walk** — the Bookcase with a
  refusal toast up (clear of the box), the Library at 1240 pt with the info panel open in Study and Terminal (and
  at a wide window, unchanged), the List's pinned heading in dark in both voices, the six lint sites' surfaces
  where reachable (the bulk row, the search picker, Takes' show faces).

**The ladder** over the whole run's diff after U3: fresh `opus-reviewer` at max per round, `notes/REVIEW_PROMPT.md`
verbatim; round 2 re-reviews the fixes; a new BLOCKER/MAJOR earns round 3; cap three. **The closeout** per
CLAUDE.md, incl. the /Applications refresh at a zero-instance window unless the coordinator folds it.

## The walk protocol (her rule — binding for every unit)

1. The unit's implementer finishes headless work and its stage window (Mac batch + red-on-old), commits, pushes,
   and ends its turn with the unit's LIVE STATUS row at `READY FOR WALK`.
2. The orchestrator spawns a FRESH Opus at xhigh (never the implementer) briefed ONLY by this file's unit section +
   this protocol + the stage protocol, on the orchestrator's claim line from the coordinator ("walk" said plainly
   in the REQUEST).
3. The walker builds/launches the Debug app from this worktree's DerivedData (`vx283-uN`), seeds whatever state the
   rows need through the dev store's own doors (never her real store), and captures EVERY changed area in Study
   and Terminal (light and dark where the unit names it) into `notes/plans/vx283-screens/uN/`, named
   `<row>-<voice>-<appearance>.png`. Region captures for the sidebar (a whole-window capture shrinks the Open
   list's ✕ to a few pixels — crop or capture at 2× the sidebar's rect).
   **The dev store is restored after every walk (the coordinator's ask, 2026-10-14):** opening and closing notes
   writes to it (close-time auto-savepoints, touch stamps). BEFORE the first launch, with zero dev instances
   running, copy the three store files — `variorum.sqlite`, `variorum.sqlite-wal`, `variorum.sqlite-shm` from
   `~/Library/Containers/io.lduarte.Variorum.debug/Data/Library/Application Support/Variorum-dev/` — into a
   uniquely named folder inside this worktree's gitignored `notes/plans/vx283-screens/uN/store-before/` (never the
   store's own `Backups/`). AFTER the last quit, with zero dev instances, copy them back and verify with `cmp`
   each file byte-identical to the copy. Never touch the folder's key files, `Backups/` or `Previous Libraries/`.
   Debug prefs: `defaults export io.lduarte.Variorum.debug` before; after, `defaults import` then re-export and
   diff against the before-export (import MERGES, so a key the walk added must be deleted by hand). The RELEASE
   line says: "dev store restored + verified, prefs diff clean, posture Standard/unlocked, castle-W1 untouched".
4. The walker writes its WALK RECORD into the unit's section (each row: what was done, what the screenshot shows,
   HOLDS / DOES NOT HOLD), commits it (screenshots stay gitignored), pushes, releases the claim, and reports.
5. The orchestrator opens every screenshot. Anything that does not look right → a fix leg (the implementer resumed
   or a fresh one), then a re-walk of those rows. The unit closes only when the screenshots look right.

## Stage protocol for implementers and walkers (binding)

The Pro's stage is coordinated by the session **oct13coordinator** (her kickoff word: *"message the oct13coordinator
to claim whatever stage you need at any point in time."*). **Only the orchestrator talks to it.**
- Headless `swift build` / `swift test` and `xcodebuild build` / `build-for-testing` never need the stage — run them
  freely in this worktree with `-derivedDataPath App/Variorum/DerivedData/vx283-uN`.
- **EVERY `xcodebuild test` (Mac or simulator), every Debug-app launch and every walk needs a HELD claim.** At that
  point: commit, push, write `READY FOR STAGE — <what>, ≈<minutes>` on the unit's LIVE STATUS row, report to the
  orchestrator exactly what the window will run, and END YOUR TURN. The orchestrator requests the window and, on
  the coordinator's GO, sends the exact claim line (the coordinator's form: `Tools/stage release --who
  coord-for-vx283 && Tools/stage claim --who <name> …`) — never claim without it; a FREE stage is never an
  invitation. Release the claim the moment the window's work is done (`Tools/stage release`) and report the
  release in one line, saying whether the dev store and the Debug prefs were restored. `Tools/stage status` exits
  1 while a claim is held — never put it in an `&&` chain.
- **Debug prefs:** export them before a window (`defaults export io.lduarte.Variorum.debug <file>`); after it,
  `defaults import` MERGES rather than replaces, so re-export after importing and diff against the pre-window export.
- **Walkers:** if a system popup appears that you can't dismiss, STOP and report exactly what it says (the
  coordinator passes it to her).
- **Leave alone:** the dev store's `Backups/safety-copies/castle-W1-20261013` is her undispositioned repro — never
  touch it. Any Castle or credential step uses `~/.variorum/dev-castle.env` exactly.
- **Castle phase 2 (VX-306):** once it merges and migrates the dev store, a Debug build from a branch cut before it
  can't open the dev store — the orchestrator merges main into this branch before any walk after that point (the
  coordinator asks at the GO).
- Mac tests from `App/Variorum/`: `xcodebuild -scheme Variorum -destination 'platform=macOS' test` with
  suite-level `-only-testing` only; confirm the "Test run with N tests" line (it COUNTS SKIPPED tests — read the
  skipped lines); zsh `pipestatus`. Never add a custom build configuration.
- Walks drive the DEV-store Debug build only (`io.lduarte.Variorum.debug`) with `cliclick` for the pointer and
  `Tools/WalkKit/keys.sh` for every key (`guard.sh` before every step; read `Tools/WalkKit/README.md` first). After
  every Debug launch, dismiss a What's New sheet with its own button if one shows (expected, never a finding).
  Leave the dev store as found: Standard, unlocked. If it greets you with a lock screen, the dev credentials live at
  `~/.variorum/dev-castle.env` (source it; never echo, log, capture or commit the values); if anything about
  posture is unexpected, stop, release cleanly, report.
- **Never** touch her real store or `/Applications/Variorum.app`; never quit or kill an instance you did not launch.
  Instance checks, the coordinator's STRICT forms: `pgrep -lx Variorum` and `pgrep -lf "MacOS/Variorum$"` (the
  loose `-f "Variorum.app/Contents/MacOS"` matches headless xcodebuild lines), then discriminate by PATH.
- Before a behavioural revert (red-on-old proof): commit first, name the revert in the LIVE STATUS, restore by
  `git checkout -- <file>` from the commit, verify by `git diff`.

## Environment traps (carried verbatim into every brief)

Instance checks use `pgrep -fl 'Variorum.app/Contents/MacOS'` AND discriminate by PATH (the test host matches
mid-run); treat real-store instances by STORE, not path — NEVER quit/kill one; no Release builds or /Applications
refreshes while one lives; `xcodebuild build-for-testing` compiles without the runner; Mac tests from
`App/Variorum/`, suite-level `-only-testing` only, confirm the "Test run with N tests" line; zsh `pipestatus`;
NEVER add a custom build configuration (Xcode builds SPM package dependencies RELEASE under any configuration not
named exactly "Debug" — silently stripping VariorumCore's DEBUG-gated oracles); suites running beside a live
session flash the test host's windows on screen; backups WAL-safe with UTC names, ALWAYS before touching the real
store (this run never touches it); screenshots in gitignored dirs only; never `git checkout` over uncommitted work;
commit per piece and push after every commit (`notes/SessionResiliencyProtocol.md`); synchronous foreground waits
only — poll a log with `grep -q '<EXIT LINE>' <log> && break; sleep 5` in a loop, never `tail -f | grep -m1`;
never force-push, never rewrite history; commits name their member and `Part of VX-283`, with NO attribution
trailer of any kind.

## LIVE STATUS

| Unit | Members | State |
|---|---|---|
| U1 | VX-286 · VX-285 · VX-287 · VX-289 — the Open list's layout and closing | FIX LEG U1b: the window ran (21:24–21:29) — batch 408 tests, 3 red: the lint (U3's VX-245, on main), one U1b pin fault, one real F-1 residual (Starred's revealed last row 1 pt short after the pitch flip); R-D/R-E red where needed. Q5 (headless): the residual's fix + the pin fault, then a short re-run window, then the re-walk. F-3 → VX-359 (U3 rider). |
| U2 | VX-288 (+ the chip on the Open list's rows) — the drag, light version | NOT-STARTED |
| U3 | VX-121 · VX-175 · VX-20 · VX-245 — the Library and the red lint | NOT-STARTED |
| Ladder | `opus-reviewer` at max, fresh per round | NOT-STARTED |
| Closeout | the merged-tip runs, canon deltas, tickets, MOBILE PARITY, handoff, merge, refresh | NOT-STARTED |

## Stage traffic log (oct13coordinator protocol)

*(The orchestrator appends each REQUEST / READY / GO / RELEASE here.)*

## Unit records

*(Each unit's implementer writes its section here: the traced mechanism with file:line, the pins (red-on-old, how
verified), the diff summary, headless counts, the stage window's Mac counts, PROVISIONAL calls, anything for the
author — PENDING until verified. The walker appends the WALK RECORD under it.)*

### U1 — the Open list's layout and closing (VX-286 · VX-285 · VX-287 · VX-289)

**Implementer:** Opus 5.5 at xhigh (fresh session, 2026-10-14). Worktree `~/dev/variorum-vx-283`, DerivedData
`App/Variorum/DerivedData/vx283-u1`. **Not done by this session (the record's first line, per the brief):** the
screenshot walk (a fresh walker's, after the stage window); any stage work until the orchestrator hands over a claim.

**LIVE STATUS (per piece)**
- P0 — the ⇧⌘W collision check (VX-287's FIRST step): **DONE — RULED.** The app-code half is FREE; the system half
  measured a collision in TABBED windows only (AppKit's own File ▸ Close Window ⇧⌘W takes the chord there — the
  window of 15:03–15:06), and **her ruling "Keep ⇧⌘W, live with it"** (f606484fb, "⇧⌘W VS MACOS WINDOW TABS") settles
  it: ⇧⌘W ships; in a tabbed window it is macOS's Close Window; nothing about window tabbing changes.
- P1 — VX-286 (the scroll bar rides in the margin, Open + Starred): DONE (`2f2daba2`) — VERIFIED: green in the
  batch, RED under **R-B** (both sections, gap 0), green restored.
- P2 — VX-285 (the Open list grows to the sync footer; the constant splits): DONE (`2f2daba2`) — VERIFIED: green in
  the batch, RED under **R-A** (tall 225 pt; short 180 pt ≠ the 84-pt floor), green restored.
- P3 — VX-287 (Close Note ⌘⇧W, landing next / previous / the Library): DONE (`9292d1db`) — VERIFIED green in the
  batch, EXCEPT the registry walk's `noActIsUnavailableInEveryContext` (RED for `.closeNote` and `.closeAllNotes` —
  my gates were missing from the walk's sampled contexts); the fixture is fixed HEADLESS after the window (P7) and
  its one-suite run is PENDING.
- P4 — VX-289 (Close All Notes): DONE (`9292d1db`) — VERIFIED as P3 (the same walk line is the one PENDING).
- P6 — her ruling at READY, "THE ✕ ON THE NOTE YOU'RE LOOKING AT" (f02f63cb): DONE (`bc80a9fb`) — VERIFIED: green
  in the batch, RED under **R-C** (the pane stayed on the closed note), green restored.
- P5 — the stage window: **DONE (the second window, claim `vx283-u1` 20:02:37 → released 20:12:05).** The batch and
  the three reverts ran (results below); the store and prefs restored and verified. No revert in flight.
- P7 — the walk's sampled contexts (`CapabilityRegistryTests.sampledContexts` gains the two close gates — the
  justified-edit ritual every gate has followed): DONE (`9b1938c1d`) — headless build-for-testing
  green; **PENDING one stage run of `-only-testing:VariorumTests/CapabilityRegistryTests` (≈3 min — it can ride the
  walker's window).**

**P5 — THE STAGE WINDOW'S RESULTS (2026-10-14 20:02–20:12, tip `f606484fb` — code identical to `5887cf43`):**
- **The batch** — `xcodebuild … -derivedDataPath DerivedData/vx283-u1 test` with 216 `-only-testing` suites (the
  86-file selection): **"✘ Test run with 1326 tests in 216 suites failed after 220.351 seconds with 3 issues."**
  1323 passed · 2 failed · 1 skipped — the skipped lines: `Suite "13n-c U4 — asks wait + the keyboard, captured (a
  harness)" skipped` / `Test captureTheAsksAndTheKeyboard() skipped` (an env-gated capture harness, by design).
  - **RED, MINE — `CapabilityRegistryTests.swift:105:13`** (`noActIsUnavailableInEveryContext`), two issues:
    "Expectation failed: reachable — .closeNote can act SOMEWHERE" and "… .closeAllNotes can act SOMEWHERE". The
    walk samples contexts and asks each act to be reachable in one; mine need a FULL window plus a note in the pane
    / an open row, and no sampled context had both. Fixed headless after the window (P7) — not inside it.
  - **RED, PRE-EXISTING — `BookCollectingDoorsTests.swift:101:9`** (`theSettingsDoorIsOneActOnBothRoads`):
    "Expectation failed: BookView.surfaceCapabilities == [.openBookSettings] — the book masthead's gear is the book's
    own door". `BookView.surfaceCapabilities` has declared `[.openBookSettings] + [.searchThisBook] +
    [.newNoteInGathering]` since 13o U3 and VX-217; the pin still expects one. Neither file is touched by this run,
    and both are byte-identical to `origin/main` (`git diff HEAD origin/main` empty for them) — red on main; for the
    orchestrator to ticket.
- **R-A (VX-285)** — the 7½-row cap and the `count <= 7` switch restored in `openGroup`;
  `OpenListLayoutMountTests`: **RED** `inATallColumnTheListRunsDownToTheFooterAndStops` (list 225 pt in a 735-pt
  column — "list.height > window7 + row.height", "list.maxY >= floorOfFooter - 1.5") and **RED**
  `inAShortColumnTheListTakesItsFloorAndTheColumnScrolls` (180 pt ≠ 3½ × 24); `bothScrollingSectionsKeepTheirBarInTheMargin`
  green. Restored (`git checkout --`, `git diff` empty).
- **R-B (VX-286)** — the margin back outside both scroll views; same suite: **RED**
  `bothScrollingSectionsKeepTheirBarInTheMargin` ×2 (open: scroll (12, 206) = row (12, 206); starred the same — gap 0);
  the two VX-285 pins green. Restored, `git diff` empty.
- **R-C (the ✕ ruling)** — `SidebarView.closeRow`'s body back to `workspace.closeNote(noteID)`;
  `OpenListRowCloseDoorTests`: **RED** `theXOnTheNoteYouAreInMovesThePaneToTheNextNote` (`OpenListCloseTests.swift:381`
  "focusedSelection == .post("c")", `:384` "departed == ["b"]") and **RED**
  `theXOnTheLastRowLandsOnThePreviousThenTheLibrary` (`:390`, `:392`); the other-row pin and the source read green.
  Restored, `git diff` empty.
- **Restore:** the dev store's three files byte-identical before the copy-back (the test host writes no store);
  copied back from `store-before/<stamp>/` and `cmp`-verified. The suites wrote real Debug prefs (9 keys ADDED —
  `surfaceSize.outline.*`, `currentBlock.*`; 3 CHANGED — a surface size, the backup log, the idle-sweep mark): the
  added keys deleted by hand, `defaults import` of `prefs-before-w2.plist`, re-export, diff clean. No new backup;
  `castle-W1-20261013` untouched; no app launched beyond the test host; zero dev instances at release.

**P0 — the ⇧⌘W check, the app's own half (2026-10-14, on `a2a27a10`) — FREE:**
- `EditorCommands.keyEquivalent(for:)`: no `w` chord of any modifier set.
- every `.keyboardShortcut(` call site in `Variorum/` and `Shared/`: no `"w"` at all (⌘W is not bound by the app —
  it is the system's File ▸ Close, which closes the window, and stays so).
- every `NSMenuItem(… keyEquivalent:)`: all `""` (MarkdownActs ×3, EditorTextView, CalloutMenu ×2, PaneSurface).
- the registry's declared labels: none carries W.
- the key overrides: `EditorTextView.performKeyEquivalent` (⌘S + the non-consuming ⌘Z/⇧⌘Z hint arm); the `keyDown`
  trio (`EditorTextView` ⇧⏎ + the flight's deferral, `PaneSurface` ⇧⏎, `CaptureTextView` ⏎/⇧⏎) — key
  equivalents never reach `keyDown`.
- the local monitors: `CommentPanelKeys` (⌘⏎, ⎋), `PageTurnKeys` (unmodified ←/→), `WingSwitcherKeys` +
  `OneWingChord` (⌘L, ⎋, ⌘-up), `DivideWSheet` (passes every ⌘/⌃ event), `CalmAsks` / `ProtectionController`
  (observe only), `PressReporter` / `PaneFocusCatcher` (mouse).
- the system hot key table: [.quickNote] ⌃⌥⌘N only.
- the note-only window (`NoteWindowView`) and the quick-note pad (`QuickNoteView`) bind no W; ⌘W keeps closing them
  (the pad's "closing files it too"). Close Note is gated to a FULL key window, so ⇧⌘W is grey there.
- **The system half — PENDING:** AppKit's `MenuCommands.loctable` carries "Close Tab" / "Close Window" / "Close
  All", i.e. AppKit re-titles File ▸ Close and may insert a "Close Window" item while a window is in a native tab
  group. Whether that item wears ⇧⌘W (and whether it appears in this SwiftUI app) is being checked; if it does,
  that is a collision in the tabbed state and goes to the orchestrator BEFORE the chord ships.
  The external lookup (one Sonnet subagent, read-only) came back INCONCLUSIVE: no Apple source says AppKit (rather
  than each app) inserts File ▸ Close Window, nor which chord it wears; ⇧⌘W for Close Window is the convention
  (Safari, Chromium's own menu code, Pages's two items under tabs), and ⇧⌘W is not on Apple's system-wide shortcut
  list. So the system half is decided by MEASUREMENT: the stage window's FIRST step enumerates the Debug app's
  File / View / Window menus by AX — one window, then two windows merged into tabs (Window ▸ Merge All Windows) —
  and looks for any other item wearing ⇧⌘W. A hit = STOP and report before the batch runs.

**P0 — THE SYSTEM HALF, MEASURED (the stage window, 2026-10-14 15:03–15:06, the Debug build of `5887cf43`; the
listings and a capture in the gitignored `notes/plans/vx283-screens/u1/p0/`):**
- **ONE window** (File / View / Window enumerated by AX with each menu OPEN): File ▸ Close **⌘W**, File ▸ Close All
  **⌥⌘W**; View ▸ **Close Note ⇧⌘W** (ours; grey on the Bookcase, as designed) and View ▸ Close All Notes (keyless).
  Nothing else wears W. ⇧⌘W is free here.
- **TWO windows merged into tabs** (File ▸ New Window, then Window ▸ Merge All Windows): AppKit RE-TITLES and ADDS
  File-menu items by itself — File ▸ **Close Window ⇧⌘W** (AX: `AXMenuItemCmdChar` W, `AXMenuItemCmdModifiers` 1),
  File ▸ Close All (⌥⇧⌘), File ▸ **Close Tab ⌘W** (AX name "Close"), File ▸ Close Other Tabs (⌥⌘W) — and our View ▸
  Close Note **LOSES its key** (`AXMenuItemCmdChar` missing, modifiers 1): AppKit resolves the duplicate in its own
  item's favour. The capture `p0/file-menu-two-tabs.png` shows "Close Window ⇧⌘W" and "Close Tab ⌘W". So in any
  tabbed window ⇧⌘W would CLOSE THE WHOLE WINDOW (every tab), never close a note. (A SwiftUI `WindowGroup` window
  tabs by the system's default; nothing in the app sets `allowsAutomaticWindowTabbing` / `tabbingMode`.)
- **THE CALL IS HERS (never rebound silently).** Options: **(a)** keep ⇧⌘W and turn native window tabbing OFF for
  Variorum (`NSWindow.allowsAutomaticWindowTabbing = false` at launch — Window ▸ Merge All Windows, Show Tab Bar and
  the Close Window/Close Tab pair leave the app; a feature removed, hers to rule); **(b)** her rejected alternative
  ⌃⌘W (checked free on 2026-10-11; re-sweep owed) — ⇧⌘W then stays AppKit's Close Window in tabbed windows, matching
  Safari/Finder; **(c)** keep ⇧⌘W and accept the tabbed-state loss (⇧⌘W closes the window there) — not recommended:
  a destructive-feeling surprise in exactly the state she might use. Everything else in U1 is independent of the
  chord (the act, its menu item, the ✕ ruling, the layout) and stands.
- Restore: the dev store's three files were already byte-identical after the quit (the launch wrote nothing); copied
  back from `store-before/<stamp>/` and `cmp`-verified anyway. The Debug prefs changed four keys (the window frame,
  the backup log, the idle-sweep mark, What's New's last version) — `defaults import` of `prefs-before.plist`, re-export,
  diff clean (none added, none removed, none changed). No new file in `Backups/`; `castle-W1-20261013` untouched; the
  dev store opened Standard/unlocked (no lock screen) and was left so; the extra tab was closed and the tab bar hidden
  before the quit (by identity); zero dev instances at release.

**P1 — VX-286, the trace verified on this tip (`a2a27a10`):** each row fills the group's width with the ✕ only
`rowPadding` (8 pt) in (`SidebarView.swift:435-446` rowChrome, `:811-815` the ✕); the group's `groupPadding` (12 pt)
was applied OUTSIDE the scroll view (`:761`), so the scroll view's trailing edge was the rows' and macOS's overlay
bar drew on the ✕; Starred the same (`:491-503`, `:523`, the ★ at `:552-556`). **The fix:** the margin moved INSIDE
both scroll views as the scroll content's padding (`scrollingSectionMargin` = the group's own 12 pt), the headers
carry the margin themselves; the rows land on the same edge at the same width. **Pin:**
`OpenListLayoutMountTests.bothScrollingSectionsKeepTheirBarInTheMargin` (each section's scroll view reaches a whole
margin past its first row; the rows still sit one margin in) — RED ON OLD expected (gap 0), PENDING.

**P2 — VX-285, the trace verified on this tip:** the strip's scroll view was capped at `rowHeight × 7.5`
(`SidebarView.swift:749-752`, `SidebarLayout.swift:160,182-191`) whatever the window; the empty room below was the
outer last-resort scroll's (`SidebarView.swift:283-311`); the sync footer is OUTSIDE that scroll (the column's
`bottom`, composed by `RootView.statusRows` at `RootView.swift:594-611`). **The fix:** a pure
`SidebarLayout.openListMaxHeight(visibleHeight:listTop:bottomPadding:rowHeight:)` = the outer scroll's visible height
− the list's MEASURED top in the column content's named space − the content's bottom padding, rounded down, floored
at `openListFloorRows` (3½); `openListRowsFit` replaces the `count <= 7` switch. The shared window SPLIT:
`scrollingSectionWindow` (7) and its `scrollingSection…` functions are Starred's alone; `openStripWindow` /
`openStripMaxHeight` are gone; the fit test still counts the strip at seven (`openListFitRows` — VX-285 changes how
far the list grows, never when the column compresses). Two measurements feed it (`columnScrollHeight` on the outer
scroll, `openListTop` on the list) — nothing above the list depends on its height, so no feedback loop. **The two
pins changed BY HER ASK, edited in place with a VX-285 annotation:** `ShellChromeTests.theOpenStripWindowIsHerSevenAndAHalf`,
`StarredScrollTests.theWindowIsOneConstantForBothScrollingSections`. **New pins:** `OpenListHeightTests` (pure ×4)
and `OpenListLayoutMountTests.inATallColumnTheListRunsDownToTheFooterAndStops` (RED ON OLD expected: 225 pt and
empty column below) + `…inAShortColumnTheListTakesItsFloorAndTheColumnScrolls` (RED ON OLD expected: 7½ rows, not
3½) — PENDING.

**PROVISIONAL P-U1-4 — the floor's number.** The record says "floored at a few rows" and names none. Built: 3½ rows
(three and the half row that says there is more — Starred's own idiom). Options: (a) 3½ [built]; (b) 3 whole rows;
(c) 5½. Her eye at the walk decides.

**P3 — VX-287, Close Note (⌘⇧W).** The trace, verified on this tip: no close-note shortcut existed; the ✕
(`SidebarView.swift:811`) and the right-click Close (`:868`) call `WorkspaceModel.closeNote` (`:360-363` on this tip),
which removes the ROW only — an on-screen note stays shown with no row until opened again (`visit` re-adds it,
`:301-304`); the app binds no ⌘W (`EditorCommands.keyEquivalent`), so ⌘W is the system's File ▸ Close. **Built:**
- the registry: `.closeNote` ("Close Note", app scope, `[.menuBar]`, "⌘⇧W" — the registry's own glyph order, as
  ⌘⇧D/⌘⇧N read), gated `windowKind == .full && focusedPaneShowsNote` (a new `CapabilityContext` fact, wired in
  `RootView.wireWorkspace` to the KEY window's `workspace.closeNoteTarget`, the `canStarCurrent` shape) — grey on a
  place, a book or a scraps container, and in the note-only and quick-note windows (⌘W keeps closing those);
- the menu: View ▸ Close Note (⌘⇧W) under the Open Notes submenu (the ticket: "a View-menu item"), its key in
  `EditorCommands.keyEquivalent`; the ⌘/ helper's "Windows & panes" row and its "the Open list" entry;
- the act: `WorkspaceModel.closeFocusedNote()` closes the focused pane's row and RETURNS the landing —
  `landingAfterClosing` over the pure `OpenNotes.neighbour(ofClosing:skipping:)`: the next row in STRIP order, else
  the previous, else `.library`; the door (`EditorCommands.closeNote(in:)`) routes it through the EXISTING open-note
  road — `ShellRouter.pendingSelection`, adopted by `RootView` via `ShellRouter.adopt` (⌘⇧1–9's road) — so no new
  landing authority, no `ShellRouter.swift` edit (VX-284's lane), and ShellRouter's RULE ONE (only `adopt` calls
  `select` from outside the workspace) holds. Arriving is an ordinary navigation, so the closed note's
  savepoint-on-leave fires like any departure. VIEW-ONLY: no row of the store is written.
- **PROVISIONAL P-U1-1 (the ticket's fallbacks, kept):** the last row lands on the previous note; an empty list on
  the Library. Options: (a) next → previous → Library [built]; (b) next → the Library (never backwards); (c) next →
  previous → the Bookcase.
- **PROVISIONAL P-U1-2 (two edges the ruling does not reach):** (i) in a SPLIT, a candidate the other pane shows is
  passed over (a split never shows one note twice — landing on it would move the FOCUS and speak the same-note
  refusal instead); (ii) a note shown with NO row (its ✕ pressed while it stayed on screen) is still closable — the
  pane leaves it, landing on the LAST row (it reads as sitting past the end, where a re-open would put it). Options
  for (ii): (a) closable, lands on the last row [built]; (b) ⌘⇧W grey without a row; (c) closable, lands on the
  Library. ~~**Not changed:** the ✕ and the right-click "Close" keep closing the ROW only~~ — **SUPERSEDED by her
  ruling at READY** ("THE ✕ ON THE NOTE YOU'RE LOOKING AT", *"Yes, same as ⇧⌘W"*): built as P6 below. (With it,
  (ii)'s rowless note becomes rarer — a ✕ on the shown note now moves the pane — but it stays reachable: a ✕ on the
  OTHER pane's note in a split leaves that pane on the Library, never rowless.)

**P4 — VX-289, Close All Notes.** The trace: no selection model (VX-344 holds that half); `OpenNotes.close` closes
one row. **Built:** `.closeAllNotes` ("Close All Notes", `[.menuBar, .contextMenu]`, keyless — the ruling named the
doors; the verb says "Notes" because bare "Close All" is the system's File-menu word for closing WINDOWS), gated
`windowKind == .full && openNoteCount > 0`; the doors: every Open row's right-click (after "Close";
`SidebarView.openListMenuCapabilities` — the walk's union gains it as its own line, a JUSTIFIED EDIT of
`theContextMenusRenderExactlyTheDeclaredContextDoors`; the shared note-row grammar is untouched, so the Library's and
the Pool's rows do not grow it) and View ▸ Close All Notes. The act: `WorkspaceModel.closeAllNotes()` empties the list
(`OpenNotes.closeAll`) and returns the focused pane's landing (the Library when it showed a note — VX-287's rule with
the list empty); the menu routes it through `pendingSelection`, the right-click through the column's own selection
binding (which the shell adopts through the same `RootView.adopt`). **PROVISIONAL P-U1-3:** the OTHER pane of a
split, if it shows a note, lands on the Library IN PLACE with the focus kept (`notesDeleted`'s road, VX-246) —
"all" includes the pane she is not in, and a closed note left on screen with no row is the state the ticket names.
Options: (a) every note-showing pane lands [built]; (b) only the focused pane lands; (c) Close All also folds the
split back to one pane.

**Pins (P3/P4), all PENDING the stage window:** `OpenListLandingTests` (pure ×8: next, last → previous, only → nil,
strip order not recency, the split's pass-over, the rowless note, repeated presses close them all, closeAll),
`WorkspaceCloseActTests` (×9: the row leaves and the pane has not moved until the door routes it; last → previous →
Library; the closed note departs on landing; nothing to close on a place or a scraps container; the split's landing;
Close All from a note, from a place, with a split; closing writes nothing to the store or the outbox),
`OpenListCloseDoorTests` (×6: declared + keyed ⌘⇧W + the helper; ⌘W untaken; Close All's two doors and not the
note-row grammar; the row menu renders the registry's verb (source read); the two gates), and
`OpenListCloseShellTests.theMenuActsLandThePaneThroughTheShell` (a mounted `RootView`: ⌘⇧W's act lands next, then
previous, Close All lands the Library, the menu's gates follow, the notes untouched). New acts, so exact-behaviour
pins — no red-on-old owed (the brief).

**P6 — her ruling at READY: the ✕ (and right-click ▸ Close) on the note you're looking at behaves like ⇧⌘W**
(the record's "THE ✕ ON THE NOTE YOU'RE LOOKING AT", f02f63cb). The traced defect: the ✕ (`SidebarView.swift`'s
openRow ✕) and right-click "Close" called `workspace.closeNote(noteID)` — the row-only primitive — so on the note the
focused pane showed, the row left and the note stayed on screen with no row. **Built:**
- `WorkspaceModel.closeRow(_:)` — closes the row; when the FOCUSED pane shows that note it RETURNS that pane's landing
  (`landingAfterClosing`: next · previous · Library — ⇧⌘W's rule; `closeFocusedNote` is now `closeRow` on the
  focused note, one act); when ANOTHER pane of a split shows it, that pane lands on the Library IN PLACE with the
  focus kept (**PROVISIONAL P-U1-5, the orchestrator's** — Close All's P-U1-3 road; the Library rather than the next
  note because an in-place landing is never a note — `select`'s own assert — so a next-note in-place landing would
  widen that contract; options: (a) the Library in place [built]; (b) the next note in place, widening `select`'s
  assert; (c) focus moves to that pane and it lands by ⇧⌘W's road); a row no pane shows just closes (nil). The
  row-only primitive `closeNote` keeps its contract (`SavepointOnLeaveTests.closingAnOpenStripRowIsNotALeaving`
  stays green; a comment there now says the ✕ door no longer calls it bare).
- **The route, without touching `ShellRouter.swift`:** the ✕ and right-click ▸ Close both call ONE static door act,
  `SidebarView.closeRow(_:in:selection:)`, which hands the landing to the column's own selection binding — whose
  setter IS `RootView.adopt(_, in: focusedPane)` (`RootView.swift:714-721`), the very call `pendingSelection`'s
  adoption makes (`:441-445`) and so the same `ShellRouter.adopt` → `WorkspaceModel.select` road ⇧⌘W takes; no new
  landing authority, no RootView or ShellRouter edit for it. (Close All's right-click already rode the same binding.)
- The ✕'s help: "Close this row — the note itself is untouched (closing the note you're in moves you on to the
  next)"; the ⌘/ helper's "the Open list" entry says the ✕ and ⌘⇧W both move you on.
- **Pins:** `WorkspaceCloseActTests` +3 (the shown note's row names ⇧⌘W's landing; another row moves nothing; the
  other pane's note lands that pane in place, focus kept) and **`OpenListRowCloseDoorTests` (×4) — the RED-ON-OLD
  pin:** `SidebarView.closeRow` driven through a binding built exactly as `RootView.selectionBinding` is
  (`ShellRouter.adopt` into the focused pane): the ✕ on the shown note lands the pane on the next note and departs
  the closed one; on the last row the previous, then the Library; on any other row nothing moves; and a source read
  that both doors run the one act and none closes bare. **R-C** (the window's step 3) reverts the door's act to the
  old `workspace.closeNote(noteID)`; expected RED: `theXOnTheNoteYouAreInMovesThePaneToTheNextNote` and
  `theXOnTheLastRowLandsOnThePreviousThenTheLibrary` (the pane still shows the closed note). All PENDING.

**Headless evidence (no stage):** `xcodebuild … -derivedDataPath DerivedData/vx283-u1 build-for-testing` → TEST
BUILD SUCCEEDED on `9292d1db`'s code (no new warning in a touched file).

**P5 — THE STAGE WINDOW PLAN (≈55 min; run in this order; the record flips per step):**
0. *Preconditions (≈3 min).* `pgrep -lx Variorum`; `pgrep -lf "MacOS/Variorum$"` — discriminate by PATH, never touch
   a `/Applications` instance. The host's Accessibility trust checked before any System Events call (WalkKit's rule).
   `defaults export io.lduarte.Variorum.debug notes/plans/vx283-screens/u1/prefs-before.plist`. With ZERO dev
   instances, copy `variorum.sqlite{,-wal,-shm}` from the dev container's `Variorum-dev/` into
   `notes/plans/vx283-screens/u1/store-before/<UTC stamp>/` (the walk protocol's restore rule; never the key files,
   `Backups/` or `Previous Libraries/`; castle-W1 untouched).
1. *The ⌘⇧W check's SYSTEM half (≈8 min) — FIRST, before anything ships on the chord.* `open -n
   App/Variorum/DerivedData/vx283-u1/Build/Products/Debug/Variorum.app` (dismiss What's New by its own button).
   By System Events on that PID: open File, then View, then Window, enumerating each item's name +
   `AXMenuItemCmdChar` + `AXMenuItemCmdModifiers` (⇧⌘ = 1) with the menu OPEN (AppKit re-titles File ▸ Close on
   validation), ⎋ after each. Then File ▸ New Window, Window ▸ Merge All Windows (two tabs), and enumerate File and
   Window again. **Any item other than View ▸ Close Note wearing W with modifiers 1 ⇒ a COLLISION: restore the store
   and prefs, release, STOP and report — the chord does not ship.** Free ⇒ record the listing here. Quit the dev
   instance by identity (`tell application id "io.lduarte.Variorum.debug" to quit`), re-check both pgreps.
2. *The Mac batch (≈25 min).* From `App/Variorum/`: `xcodebuild -scheme Variorum -destination 'platform=macOS'
   -derivedDataPath DerivedData/vx283-u1 test` with one `-only-testing:VariorumTests/<Suite>` per suite of every test
   file that exercises a changed source — the files matching `SidebarLayout|SidebarView|SidebarGeometry|OpenNotes|
   openNotes|closeNote|EditorCommands\.|HelperView|CapabilityRegistry\.doored|menuRendered|contextMenuCapabilities|
   keyEquivalent\(for|RootView\(|CapabilityContext\(` (86 files → 216 top-level suites, incl. the seven new ones);
   `pipestatus` checked; the "Test run with N tests" line AND its skipped lines recorded.
3. *The red-on-old reverts (≈15 min) — each named here before it starts, restored by `git checkout --
   App/Variorum/Variorum/Features/Library/SidebarView.swift`, verified by an empty `git diff`:*
   - **R-A (VX-285):** in `openGroup`, `.frame(maxHeight: maxHeight)` → `.frame(maxHeight:
     SidebarLayout.scrollingSectionMaxHeight(rowHeight: rowHeight))` and the `fixedSize` `vertical:` →
     `shown.count <= SidebarLayout.scrollingSectionWindow`. Run `-only-testing:VariorumTests/OpenListLayoutMountTests`.
     Expected: `inATallColumnTheListRunsDownToTheFooterAndStops` and `inAShortColumnTheListTakesItsFloorAndTheColumnScrolls`
     RED; `bothScrollingSectionsKeepTheirBarInTheMargin` green.
   - **R-B (VX-286):** delete both `.padding(.horizontal, Self.scrollingSectionMargin)` lines and put
     `.padding(.horizontal, Self.groupPadding)` back on the two sections' VStacks (where the "(VX-286: …)" comments
     stand). Same suite. Expected: `bothScrollingSectionsKeepTheirBarInTheMargin` RED.
   - **R-C (her ✕ ruling, P6):** the body of `SidebarView.closeRow(_:in:selection:)` → `workspace.closeNote(noteID)`
     (the door's act before the ruling — the row alone). Run `-only-testing:VariorumTests/OpenListRowCloseDoorTests`.
     Expected: `theXOnTheNoteYouAreInMovesThePaneToTheNextNote` and `theXOnTheLastRowLandsOnThePreviousThenTheLibrary`
     RED (the pane still shows the closed note); `theXOnAnyOtherRowJustRemovesIt` green; the source read green.
4. *Release (≈2 min).* Dev store copied back with zero dev instances and `cmp`-verified per file; prefs `defaults
   import` → re-export → diff against `prefs-before.plist` (delete any key the window added); `Tools/stage release`;
   the one-line release report ("dev store restored + verified, prefs diff clean, posture Standard/unlocked,
   castle-W1 untouched").

#### U1 — THE WALK PLAN (the orchestrator's; her walk rule — a fresh Opus at xhigh, screenshots of every changed area)

Products: the Debug app from U1's tree, `App/Variorum/DerivedData/vx283-u1/Build/Products/Debug/Variorum.app`
(bundle `io.lduarte.Variorum.debug`, the DEV store). If the product is missing or older than the U1 tip, build it
headless first (`xcodebuild -scheme Variorum -destination 'platform=macOS' -derivedDataPath DerivedData/vx283-u1
build`, run from `App/Variorum/`) — a build needs no claim, a launch does. Screens go to
`notes/plans/vx283-screens/u1/`, named `<row>-<voice>-<appearance>.png`. **Sidebar rows are REGION captures** at
the display's native 2× (`screencapture -x -R x,y,w,h <file>` in points, the sidebar's rect read from `walk-cap`'s
window bounds) — a whole-window capture shrinks the ✕ to a few pixels. A whole-window capture rides beside each
row for context. Hover state (the ✕ shows on the hovered row) needs the pointer parked on the row before capture
(`cliclick m:x,y`, then capture).

- **W0 — preconditions.** Strict instance checks (`pgrep -lx Variorum`; `pgrep -lf "MacOS/Variorum$"`) show no
  dev instance. The host's Accessibility + Screen Recording trust (WalkKit README's CHECK THE HOST FIRST). Debug
  prefs exported. The dev store's three files copied to `notes/plans/vx283-screens/u1/store-before/` (the walk
  protocol). Note the posture: Standard, unlocked, the voice and appearance it had.
- **W1 — launch and seed.** Launch, dismiss What's New. Open at least 15 notes so the Open list overflows
  (Library rows, ⌘K, whatever the dev store offers; every write is undone by the store restore). Star at least 9
  notes for W4 (the same).
- **W2 — the tall list (VX-285), Study light.** The window at its tallest. Capture the sidebar: the Open list runs
  down to just above the sync footer and stops there; no row hides under the footer; no empty band between the list
  and the footer when the rows overflow. Then with fewer notes open (say 4): the list hugs its rows.
- **W3 — the scroll bar (VX-286).** Scroll the Open list with `walk-scroll` and capture DURING the scroll (overlay
  bars show only while scrolling): the bar sits in the margin and every ✕ is clear of it. Park the pointer on a
  row next to the bar so its ✕ shows, and capture. Same for Starred (W4's stars) — the ★ clear of the bar.
- **W4 — Starred keeps its 7.** With 9+ stars, Starred shows about 7½ rows and scrolls in place; capture.
- **W5 — the short window.** Shrink the window's height until the list can't fit its rows: it keeps at least 3½
  rows, the sidebar's outer scroll carries the rest, the sync footer is never covered. Capture.
- **W6 — ⇧⌘W repeatedly (VX-287).** Open a note from the MIDDLE of the list. Press ⇧⌘W (via `keys.sh`) and
  capture: its row is gone and the pane shows the NEXT note. Press again a few times (capturing each). From the
  LAST row: the pane lands on the PREVIOUS note. Keep pressing until the list is empty: the pane lands on the
  Library. ⇧⌘W with the Library showing does nothing (the menu item is grey — capture the View menu).
- **W7 — the ✕ (her ruling).** Reopen several notes. A ✕ on the row of the note you're looking at moves the pane
  to the next note; a ✕ on any OTHER row only removes that row (the pane stays). Right-click ▸ Close behaves the
  same. Capture before and after each.
- **W8 — Close All Notes (VX-289).** From the Open list's right-click (capture the menu open) and from View ▸ Close
  All Notes: the list empties, the pane lands on the Library.
- **W9 — the View menu and ⌘W.** Capture View ▸ showing Close Note ⇧⌘W and Close All Notes. Then File ▸ New
  Window and ⌘W: only that window closes (⌘W is unchanged).
- **W10 — the other voice and dark.** Repeat W2, W3 and W4's captures in Terminal light, then Study dark and
  Terminal dark (Settings ▸ Appearance; prefs are restored after).
- **W11 — restore and release.** Quit YOUR instance. Copy the three store files back, verify each with `cmp`.
  `defaults import`, re-export, diff against the W0 export (delete any key the walk added). Posture Standard,
  unlocked, castle-W1 untouched. Release (`Tools/stage release --who vx283-u1-walk`) — or hand back to the orchestrator if it says the claim continues.

Each row's WALK RECORD line: what was done · the screenshot file(s) · HOLDS / DOES NOT HOLD (and what's wrong).

Notes for the walker: the coordinator's popup rule binds (a system popup you can't dismiss → stop, report its
words). ⇧⌘W in a window merged into macOS TABS is macOS's Close Window by her ruling — not a finding; walk in an
ordinary window. The products' tip: the U1 tree at `358f4e04` (the last code change, P7, is test-only).

#### U1 — WALK RECORD

**Walker:** a fresh Opus 5.5 at xhigh (not U1's implementer), 2026-10-14 20:16–, on the orchestrator's claim
`vx283-u1-walk`; the Debug app `App/Variorum/DerivedData/vx283-u1/…/Variorum.app` (built 20:13 from the U1 tree, not
rebuilt), PID 93969, discriminated by path. Screens in the gitignored
`notes/plans/vx283-screens/u1/walk/` (sidebar rows as 2× region captures of the sidebar rect, a `-window` capture
beside each). Every image below was opened and looked at before its verdict.

- **W0 — preconditions.** Both strict pgreps empty before launch; her app absent (the guard); the host
  `AX: true SCREEN: true`. The store copy (`walk-store-before/`) and prefs export (`walk-prefs/before.plist`) were the
  orchestrator's, not redone. Posture at launch: Standard, unlocked (no lock screen; the Bookcase came up), voice
  **Study**, appearance **follow system** (`appearanceChoice = system`, the system light). No What's New sheet showed.
  · HOLDS.
- **W1 — launch and seed.** The window resized by AX to its tallest (1380 × 1010 at (60, 36) — the screen's visible
  frame caps it there). The store already had 14 notes open; 12 more opened from the Library (the list sits at the
  ruled 20-row auto-close cap, `OpenNotes.trackedCap` — so 20 rows, not 26, is the most it ever holds); 8 notes starred
  through the Library rows' right-click ▸ Star (9 starred with quicknotes). One misclick opened "wings" in a note
  window (closed by AX at once; that note was not starred). · done.
- **W2 — the tall list (VX-285), Study light.** `W2-study-light.png` (+`-window`; a note open, "this note" shown, the
  column compressed): the list runs from its header down to just above the sync footer, the last row ("owned,
  finished, sealed", highlighted) whole, ~11 pt clear of the footer's hairline, the rows above scrolled under the
  header. `W2-study-light-bookcase.png` (+`-window`; on the Bookcase): the same — 15 whole rows, the list stops
  ~15 pt above the footer, nothing under it, no empty band. With 5 notes open, `W2-study-light-fewrows.png`
  (+`-window`): the list hugs its 5 rows (no scroll; the room below is the column's own). · HOLDS.
- **W3 — the scroll bar (VX-286).** `W3-study-light-open-scrolling.png` (+`-window`), captured mid-scroll with the
  pointer on the ✕ column: the overlay bar draws at x 221–226.5 pt of the 236-pt sidebar, every ✕ ends by ~210 pt —
  ~12 pt of clear margin, no ✕ touched (pixel-measured, zoomed — see W10). `W3-study-light-starred-scrolling.png`: Starred's bar
  in the same margin, every ★ clear by ~13 pt. · HOLDS.
- **W4 — Starred keeps its 7.** `W2-study-light.png` / `W2-study-light-bookcase.png` (rest) and
  `W4-study-light-starred-end.png` (scrolled to its end): with 9 stars Starred shows 7 whole rows and the half row
  ("what the door is" cut mid-text), scrolls in place to "What's true in every mode", the rest of the column unmoved.
  · HOLDS.
- **W5 — the short window.** `W5-study-light-640.png` (window 640 tall): the list shrinks to ~6½ rows and still
  stops above the footer. `W5-study-light-480.png` (+`-window`, 480 tall): the column overflows; the outer scroll
  clips at the footer's top edge (a row's text cut there, never drawn under the footer).
  `W5-study-light-480-outer-scrolling.png` / `-outer-scrolled.png`: the outer column scrolled to its end — the list
  holds its 3½-row floor (three whole rows + the half row), the outer bar in the margin clear of ✕ and ★, the footer
  uncovered. · HOLDS.
- **W6 — ⇧⌘W repeatedly (VX-287).** From "what always asks" (mid-list, `W6-study-light-0-start*`), ⇧⌘W via
  `keys.sh`: `W6-…-1*` the row gone, the pane on "how much, where, how long" (the next); `-2*` "connecting a client";
  `-3*` "what the door is". From the LAST row "owned, finished, sealed" (`-4-lastrow-open`): ⇧⌘W landed on the
  PREVIOUS, "the bookcase" (`-5-from-last*`). 15 more presses closed backwards to one row, "o museu" (`-6-onerow*`,
  shown in its remembered Read mode); the last press emptied the list and the pane landed on the **Library**, the Open
  section gone (`-7-empty-library-window`). With the Library showing, View ▸ Close Note ⇧⌘W and Close All Notes are
  GREY (`-8-view-menu-library`; AX `enabled false` for both), and a ⇧⌘W press changed nothing — the window stayed
  (`-9-library-after-shiftcmdw-window`). · HOLDS.
- **W7 — the ✕ (her ruling).** 5 notes open, the pane on row 2 "how to use it" (`W7-…-1-before-x-shown*`, pointer
  parked on its ✕): the ✕ on that row → the row gone, the pane on "sharing from where you are", the next (`-2*`). The
  ✕ on row 1 "seeing, answering, undoing" (another row) → that row gone, the pane stayed on "sharing" (`-3*`).
  Right-click on the shown note's row (`-4-rightclick-shown-menu`: Open Beside · Open in New Window · Unstar · Close ·
  Close All Notes) ▸ Close → the pane on "what always asks", the next (`-5*`). Right-click on the other row "how much"
  (`-6-rightclick-other-menu`) ▸ Close → that row gone, the pane stayed (`-7*`). · HOLDS.
- **W8 — Close All Notes (VX-289).** 4 notes open; right-click on a row (`W8-study-light-1-rightclick-menu`, the menu
  open: … Close · Close All Notes) ▸ Close All Notes → the list emptied, the Open section gone, the pane on the
  Library (`-2-after-rightclick-closeall-window`). 3 notes reopened; View ▸ Close All Notes (AX menu press) → the same
  (`-3-after-menu-closeall-window`). · HOLDS.
- **W9 — the View menu and ⌘W.** `W9-study-light-1-view-menu-notes-open`: with notes open, View ▸ Close Note ⇧⌘W and
  Close All Notes are ENABLED (AX `enabled true`), under Open Notes (⌘⇧1–9). File ▸ New Window opened a second
  window (1240 × 840; `-2-new-window`, `-2-original-window`); ⌘W (via `keys.sh`) closed ONLY that window — AX then
  listed one window, the original 1380 × 1010, the app still running (`-3-after-cmdw-window`). · HOLDS.
- **W10 — the other voice and dark.** Voice flipped by AX in Settings ▸ General (Theme), appearance likewise
  (Appearance ▸ Dark). With 18 notes re-opened: **Terminal light** — `W2-terminal-light.png` (note open) and
  `W2-terminal-light-bookcase.png` (+`-window`s): the list runs to just above the footer and stops;
  `W3-terminal-light-open-scrolling.png` / `-starred-scrolling.png`: the bar in the margin, every × and ★ clear.
  **Terminal dark** — `W2-terminal-dark-bookcase.png` (+`-window`), `W3-terminal-dark-open-scrolling.png`,
  `W3-terminal-dark-starred-scrolling.png`: the same, the bar a light grey on the black room. **Study dark** —
  `W2-study-dark-bookcase.png` (+`-window`), `W2-study-dark-note.png` (+`-window`), `W3-study-dark-open-scrolling.png`,
  `W3-study-dark-starred-scrolling.png`, and one ⇧⌘W in dark (`W6-study-dark-shiftcmdw*`: "membership, not
  ownership" → "a book from the inside", the next). Starred shows 7 whole rows + the half row in every voice and
  appearance (W4). Pixel-measured in all four W3 Open captures: the ✕ ink ends at 417–418 px, the bar spans 442–453 px
  of the 472-px (2×) sidebar — a constant **12-pt** clear margin in both voices and both appearances. Margins, the
  footer and the row edges are consistent across all four. · HOLDS.
- **W11 — restore and release.** Appearance set back to Follow system in Settings (AX; `appearanceChoice = system`),
  voice back to Study. Quit MY instance by identity (`tell application id "io.lduarte.Variorum.debug" to quit`); both
  strict pgreps empty after. With zero dev instances, the three store files copied back from `walk-store-before/` and
  `cmp`-verified byte-identical each. No new file in `Backups/` from this walk (`safety-copies/` last modified 18:36,
  before the walk); `castle-W1-20261013` untouched (its files still Oct 13). Prefs: the walk ADDED 18 `currentBlock.*`
  keys (deleted by hand) and CHANGED 9 (`currentBlock.*` ×3, `openNotes.remembered.ids`/`.recency`, both window frames,
  the backup log, the idle-sweep mark); `defaults import` of `before.plist`, re-export (`walk-prefs/after-restore.plist`),
  diff CLEAN (1602 = 1602 keys, none added, removed or changed). Posture Standard/unlocked throughout (no lock screen
  ever). Claim `vx283-u1-walk` released 20:41:26. · HOLDS.

**OBSERVATIONS (outside the verdicts — for the orchestrator's eye):**
- **O-1 — once, the newly opened note's row was left half-hidden at the list's bottom edge.** On the 18th rapid open
  (W10's re-seed: ⌥⌘[ back to the Library, click a row, ~4.5 s per open), the highlighted current row ("the seal") sat
  cut at the bottom of the Open list — only its top ~10 pt showing, a row-sliver at the top too — and STAYED so after
  settling (`OBS-study-light-current-row-cut.png`, re-captured seconds later, same). The very next open revealed its
  row whole (`OBS-study-light-current-row-cut-2.png`), as did every other open, ⇧⌘W, ✕ and right-click landing in the
  walk (~40). One in ~40, not reproduced. Untraced — a guess only: the reveal may run before the list's newly measured
  height settles (the height now comes from two measurements). It does not look right when it happens.
- **O-2 — the column's row height jumps as rows close.** At 1010 pt tall, with 5 rows open the whole sidebar is
  compressed (24-pt rows) and with 4 it relaxes to 30-pt rows, so a single ✕ in W7 re-flowed every section (Starred,
  the places, "this note"). The record says the fit test still counts the strip at seven by design; noting how it
  reads in use.
- **O-3 — the scroll offset is kept across states**, so the top row often sits half under the "Open" header and the
  gap above the footer varies (~11–22 pt) with the offset; never an awkward band, never a row under the footer.
- **O-4 — the 20-row cap** (ruled, `trackedCap`) means a 1010-pt window overflows only past ~15 rows (on a place) or
  ~13 (a note open).
- **O-5 — the View menu shows a doubled separator** between Close Split and Toggle Sidebar (two separators in a row in
  AX; two hairlines in `W6-study-light-8-view-menu-library` / `W9-…-1-view-menu-notes-open`). Probably pre-existing,
  not U1's — untraced.
- **O-6 — the floor (P-U1-4):** 3½ rows at the 480-pt window reads clearly as "a list with more" (`W5-…-outer-scrolled`);
  no reason seen to change it.
- The ✕ shows on every row at rest, with no hover change; the ⇧⌘W/✕ landings also scroll Starred to the landed note
  when starred (nice). The one-row and empty-list states look right (the section header goes with the last row).

#### U1 — THE ORCHESTRATOR'S EYE (her walk rule's step 5, 2026-10-14 ~20:50)

Opened every REGION capture of a changed area (17 of the 71 files; the rest are whole-window context duplicates of
the same states): W2 Study light tall + few rows, W2 Terminal dark, W3 Open scrolling in all four voice ×
appearance pairs, W3 Starred Terminal dark, W4, W5 at 480 and 640, W6 a landing, W7 a ✕ landing, W8's right-click
menu, W9's View menu, both O-1 captures.

**Looks right:** the list runs to just above the sync footer and stops (no row under it, no band); the scroll bar
rides in the margin with every ✕ and ★ clear, in both voices and both appearances; Starred holds its ~7½; the 3½-row
floor at 480 pt with the outer scroll carrying the rest; the menus read "Close Note ⇧⌘W" / "Close All Notes" and
right-click "Close" / "Close All Notes"; the landings are right.

**Does NOT look right yet (U1's fix leg, U1b):**
- **F-1 (the walker's O-1) — the CURRENT row can sit cut at the list's bottom edge.** Once in ~40 opens (the 18th
  rapid open from the Library) the newly opened note's highlighted row showed only its top ~10 pt and stayed so after
  settling (`OBS-study-light-current-row-cut.png`; the clean repeat `-2`). The note she just opened must always be
  wholly in view. Trace the reveal (scroll-to-row vs. the list's measured max height settling — the walker's guess,
  untraced) and fix by mechanism; pin what can be pinned (a pure reveal decision, or the re-reveal on a height change);
  the evidence is the re-walk's repeated rapid opens.
- **F-2 — a scrolled section slices its partial row through the letters right under its header.** Open (W2 Study
  light: "Standard and Castle:…" under "Open"; W5: "2026-10-12"; W6) and Starred (W4: "seeing, answering, undoing"
  under "Starred"; W2 Terminal dark: the top starred row butting the header) — a hard clip that reads unfinished,
  above all beside the taller Open list. Starred did it before U1 too; her rule is that it look right. **PROVISIONAL
  (the orchestrator's ruling, P-U1-6):** both scrolling sections get a short EDGE FADE (about half a row) at whichever
  edge has content beyond it — the top only when scrolled down, the bottom only when more lies below — drawn from the
  voice's room token (the Bookcase strip's edge-fade idiom; an overlay/mask, never a per-row attribute; no literal
  colour). A partial row then fades instead of being cut. Starred's ruled ~7½-row window and the half row's "there is
  more" signal stay; rows never move. Her eye on the re-walk decides.
- **F-3 (the walker's O-5) — the View menu shows a doubled separator after Close Split** (W9's capture). U1 edited
  that menu; trace whether U1's Divider (or a hidden item beside it) doubles it, and remove the double. If it is
  older than U1 and not adjacent to U1's lines, record it and leave it.
- Not taken: O-2 (the whole column's pitch flips 30 ↔ 24 pt as the Open count crosses the fit test's threshold —
  her VX-285 ask moved height, not compression; the record's `openListFitRows` rationale stands), O-3's resting
  scroll offset (F-2 is its visible half), O-4 (the 20-row cap), O-6 (the floor reads well).

**U1b — the fix leg's acceptance:** a FRESH implementer (U1's is past the context guideline), briefed by this section +
U1's section; pins where the mechanism allows; the Mac batch over the changed files' suites on a claim; then a
re-walk of W2/W3/W4/W5 in the scrolled states (Study + Terminal, light + dark) and twenty rapid opens for F-1, plus
W9's menu — by a fresh Opus walker; U1 closes when those screenshots look right.

### U1b — the fix leg (F-1 · F-2 · F-3)

**Implementer:** a fresh Opus 5.5 at xhigh (2026-10-14, evening), worktree `~/dev/variorum-vx-283`, DerivedData
`App/Variorum/DerivedData/vx283-u1` (U1's tree, reused). **Not done by this session (first line, per the brief):**
the screenshot re-walk (a fresh walker's); F-3's separator is RECORDED AND LEFT (older than U1, not adjacent to its
lines — below); any stage work until the orchestrator hands over a claim.

**LIVE STATUS (per piece)**
- Q0 — this record + F-3's trace and disposition: DONE (this commit).
- Q1 — F-1 + F-2's pure brain (`SidebarLayout`: `ScrollWindow`, `edgeFades`, `revealAnchor`) + its pure pins
  (`SidebarSectionWindowRuleTests` ×9): DONE (this commit) — headless `build-for-testing` green; the run PENDING the
  stage window.
- Q2 — the view: one shared scrolling-section window for Open AND Starred (`SidebarSectionWindow` — the edge fade,
  the reveal on a current-row change, on mount and on every viewport-height change; the DEBUG oracles) + the mounted
  pins (`SidebarSectionWindowMountTests` ×6): DONE (this commit) — headless `build-for-testing` green; the runs and
  the reverts PENDING the stage window. The full write-up (trace, build, pins, PROVISIONALs) lands with Q3.
- Q3 — headless evidence: DONE. `build-for-testing` green for HEAD (`DerivedData/vx283-u1`, the Q2 code) and for
  both reverts, PREBUILT so the window only runs tests: R-D's products in `DerivedData/vx283-u1b-rd`, R-E's in
  `DerivedData/vx283-u1b-re` (each patch applied, built, restored by `git checkout --`, `git diff` empty). The
  patches: `notes/plans/vx283-screens/u1b/reverts/R-D.patch`, `R-E.patch` (gitignored). After a pin fix (`ab1880cb`,
  `62d5a4a1` — the fade pins read the depth at the CURRENT pitch, since opening a note can flip 30 ↔ 24) all three
  trees were REBUILT at `62d5a4a1`'s code, each green; **no revert is in the tree** (`git diff` empty).
- Q4 — the stage window: **DONE** (claim `vx283-u1b` 21:24:11 → released 21:29:47, the GO's line). Results below
  ("THE WINDOW'S RESULTS"): the batch 408 tests, **3 red** — the lint (U3's VX-245, red on main), one PIN FAULT (the
  Open fade pin's mid-list row needs no scroll) and one REAL RESIDUAL of F-1 (Starred's revealed last row 1 pt short
  after the pitch flip); R-D and R-E red where the brief needs them. Store and prefs restored and verified; the two
  revert trees deleted (the coordinator's ask).
- Q5 — the residual's fix (headless, after the window, told to the orchestrator): IN-PROGRESS — the reveal stays
  owed until a reading shows the row clear (bounded re-issues), and its scroll is issued without animation; the pin
  fault fixed; then a short re-run window.

**F-3 — THE DOUBLED SEPARATOR: OLDER THAN U1, NOT ADJACENT — RECORDED AND LEFT (the brief's rule).**
- The View menu's note group is `EditorCommands`' `CommandGroup(before: .toolbar)` (`EditorCommands.swift:954`). It
  ENDS with a `Divider()` after Close Split (`:1023`), and the next items (Toggle Sidebar, then the `after: .sidebar`
  group's Find Anything… / Switch Wing…, `:485`) belong to other command groups, which SwiftUI separates with its
  own separator — so the menu draws the group's trailing `Divider()` AND the group boundary's separator back to back:
  the two hairlines between Close Split and Toggle Sidebar in `W9-study-light-1-view-menu-notes-open.png` (the
  walker's AX read: two separators in a row).
- `git blame`: that trailing `Divider()` is `07d9f583` (2026-07-30, 13f batch 4 — the split's doors), unchanged since.
  U1's View-menu lines (`9292d1db`, `:999-1011`) are the two buttons Close Note / Close All Notes inserted BETWEEN the
  Open Notes submenu and the pre-existing `Divider()` at `:1012`; U1 added no `Divider()` anywhere in the file (its
  whole `EditorCommands` diff: a capability-list line, the `keyEquivalent` case, the two buttons, the two static
  acts). Between U1's last line and the doubled pair stand `:1012`'s divider, Open Beside and Close Split — not
  adjacent. So the double has shown on `main` since 2026-07-30.
- **For the orchestrator:** the fix is one line (delete `:1023`'s trailing `Divider()`; the group boundary keeps
  its own separator) — a ticket's, not this leg's.

**F-1 — THE TRACE (U1's tip `358f4e04`, `App/Variorum/Variorum/…`):**
- The Open list's only reveal was `Features/Library/SidebarView.swift:844-849` — `.onChange(of:
  workspace.openNotes.recency.first) { proxy.scrollTo(newest) }`: anchor nil, i.e. "the minimum scroll that makes
  the row wholly visible", computed against the viewport standing WHEN the scroll is processed. Nothing ever ran it
  again.
- That viewport is `.frame(maxHeight: openListMaxHeight)` (`:824`), a pure function (`:284-288`) of two MEASURED
  `@State` values (`columnScrollHeight`, `openListTop` — `:219-220`) that `onGeometryChange` writes (`:336-338`,
  `:835-837`), i.e. a layout pass AFTER the change that moved them, and of `rowHeight` (`:277-280`), itself a function
  of the measured column height and the row count.
- Opening a note from a place inserts the rail (`:310-312`): `openListTop` grows by the rail's whole group, and the
  fit test gains seven rail rows (`:263-268`) — in the walk's 1010-pt window that flips the column's pitch 30 → 24
  (the O-1 captures' rows are 24 pt) — all under the rail's 0.22-s animation (`:359`). So the list's viewport changes
  height AFTER the reveal was issued, and a scroll view that changes height keeps its top: a row revealed at the
  bottom of the taller, pre-settle viewport is cut by the difference, and stays cut. Which pass the scroll lands in is
  timing — hence once in ~40.
- A second road to the same end, DETERMINISTIC: back to the note she was already in (⌥⌘[ to the Library, then
  back). `OpenNotes.opened` (`Workspace/WorkspaceNavigation.swift:318-320`) leaves `recency.first` where it is, so
  the reveal never runs — while the Library's taller list (no rail) has clamped the offset, and the rail's return
  shrinks the viewport under the row: hidden. A third: on mount (launch, a new window) `onChange` never fires for the
  initial value, so a restored strip's current note below the fold opens hidden.
- Starred had the same class: a minimal `scrollTo` on a selection change (`:558-564`), its viewport `7.5 × rowHeight`
  (`:554`) shrinking when the pitch flips.
- **Headless corroboration (no stage: a standalone probe process with an offscreen, never-shown window, built in the
  session scratchpad — no app, no store, no prefs):** `onScrollGeometryChange` reports once initially (old = new)
  and on every change; `scrollTo(id, anchor:)` lands the row's top at `y × (viewport − rowHeight)`; a viewport that
  shrinks keeps its offset. With the OLD reveal, the current row (row 18 of 20) went from wholly visible at the bottom
  edge to wholly hidden after a 251 → 191-pt shrink (window 319…510, the row at 540…570), and stayed hidden after a
  grow-then-shrink (the Library round trip: window 90…341); with the NEW window every step ended with the row clear
  of the fades (e.g. 394…585 after the shrink, 334…585 after the round trip).

**F-1 + F-2 — THE BUILD** (`c3140a92f` pure, `871d86982` view):
- `Core/Views/SidebarLayout.swift` (pure): `ScrollWindow` (offset · viewport · content), `EdgeFades`,
  `edgeFadeRows` = 0.5, `edgeFades(_:depth:)` (each edge as deep as the content beyond it, capped at the half row;
  nothing below half a point), `revealAnchor(row:rows:rowHeight:window:depth:)` (nil when the row stands wholly in
  view clear of both fades; else the `UnitPoint.y` that lands it one fade's depth inside the edge it was beyond —
  none past the first row or the last).
- `Features/Library/SidebarSectionWindow.swift` (NEW — one modifier for BOTH sections, so they cannot drift):
  `onScrollGeometryChange` → the window (held by reference: a scroll's frames re-render nothing) and the fades
  (state: re-renders only when they change); the reveal runs when OWED (mount, a current-row change) or when the
  viewport's height changed; `onChange(of: current)` makes it owed and asks at once from the window as last read.
  The fade is an OVERLAY painted from `tokens.room` (the column's own background): no hits, hidden from
  accessibility, rows never move.
- `Features/Library/SidebarView.swift`: Starred and the Open list apply it inside their `ScrollViewReader`s (Open's
  `current` = the selection's note when it has a row, `currentOpenRow`; Starred's = the starred item the selection
  names); the two old reveals are gone; DEBUG oracles — each section's window from its OWN `onScrollGeometryChange`
  (independent of the modifier, so a revert still measures), and the fades the modifier drew (`SectionDraw.window` /
  `.fades`).
- **Consequences, stated:** (1) the Open list's reveal follows the CURRENT row, not the newest — every open takes the
  pane's focus, so the newcomer is the current row; a ✕ on a newest row that is NOT the current one no longer scrolls
  the list to the next-newest (it did; it pulled the current row away). (2) The current row is revealed on mount.
- **PROVISIONAL P-U1b-1 — the reveal's air.** With F-2's fades, a minimal reveal would leave the current row under
  the bottom fade, half washed out; so it lands one fade's depth (half a row) inside an edge that has more beyond it
  (none at the list's ends). Options: (a) a fade's depth of air [built]; (b) the old minimal reveal, under the fade;
  (c) a whole row of air.
- **PROVISIONAL P-U1b-2 — which height changes re-reveal.** Every viewport-height change re-reveals the current row,
  including a window resize after she scrolled the current row out of view (a scroll of hers is never pulled back —
  a scroll changes no height). Options: (a) every height change [built — "wholly in view after … a height change",
  the brief]; (b) only when the row was in view before the change; (c) only the app's own changes (the rail, the
  pitch), never a resize.
- **PROVISIONAL P-U1b-3 — the fade eases in.** Each edge's depth is the content beyond it, capped at the half row,
  so the top fade grows over the first half row of scroll instead of popping in whole. Options: (a) eased [built];
  (b) full depth the moment anything lies beyond; (c) full depth with an animated arrival.
- **PROVISIONAL P-U1b-4 — overlay, not the strip's mask.** The Bookcase strip's fade (`BookcaseStrip.names`) is an
  alpha MASK over content that rests on the room; the sidebar's is the same gradient PAINTED FROM `tokens.room` as an
  overlay — it reads identically (the room is what a mask would reveal) and draws from the voice's room token
  directly, with no `.black`/`.clear` alpha stops and no reliance on a shape's default fill. Options: (a) the room
  overlay [built]; (b) the strip's mask, verbatim; (c) a shared fade helper for both (touches the Bookcase — another
  surface).

**Pins (all PENDING the window):**
- `SidebarSectionWindowRuleTests` ×9 (pure): the half-row depth; the edges fade only where more lies beyond; the
  fade eases in; a window holding everything fades nowhere; a clear row is left alone; a row under the bottom fade is
  revealed clear of it; first/last land on the edges; **the reveal is a fixed point from every window** (every row,
  three window sizes, every 7 pt of offset: lands clear, and a second ask moves nothing); nothing before a reading.
- `SidebarSectionWindowMountTests` ×6 (a mounted column bound to the workspace exactly as `RootView` binds it):
  `returningToTheNoteYouWereInRevealsItsRow` (**RED ON OLD expected**, R-D — the deterministic road);
  `aShorterListKeepsTheCurrentRowInView` (**RED ON OLD expected** under R-D AND under R-E alone — the mechanism);
  `aNewNoteOpenedFromThePlacesLandsWhollyInView` (the walker's road — exact-behaviour; the old code raced, so R-D's
  result is recorded as observed, not claimed); `aCloseNoteLandingRevealsTheNextRowClearOfTheFades`
  (exact-behaviour — the old minimal reveal reached that row too, so GREEN under R-D is expected: not a red-on-old
  pin); `theOpenListFadesOnlyTheEdgesWithMoreBeyond` and
  `starredFadesWhereMoreLiesBeyondAndNowhereWhenItHoldsEverything` (F-2's geometry oracle — **RED under R-D**, no
  fade recorded).

**THE STAGE WINDOW (≈25 min; run in this order, from `App/Variorum/`; the record flips per step):**
0. *Preconditions.* `pgrep -lx Variorum`; `pgrep -lf "MacOS/Variorum$"` (discriminate by path; never touch a
   `/Applications` instance). `defaults export io.lduarte.Variorum.debug
   notes/plans/vx283-screens/u1b/prefs-before.plist`. With ZERO dev instances, copy `variorum.sqlite{,-wal,-shm}`
   from the dev container's `Variorum-dev/` into `notes/plans/vx283-screens/u1b/store-before/<UTC stamp>/` (never the
   key files, `Backups/`, `Previous Libraries/`; castle-W1 untouched).
1. *The batch* — `xcodebuild -scheme Variorum -destination 'platform=macOS' -derivedDataPath DerivedData/vx283-u1
   test-without-building` + one `-only-testing:VariorumTests/<Suite>` per line of
   `notes/plans/vx283-screens/u1b/batch-suites.txt` (92 suites: every top-level suite of the 31 test files that
   reference `SidebarLayout|SidebarView|SidebarGeometry|SidebarSectionWindow|RootView(`, plus `NoLiteralColourTests`,
   `ChromeLineLimitTests` and `CapabilityRegistryTests` — P7's pending run rides here). The 92:
   AscentDoorTests AscentRoutingTests BookAnchorTests BookCarryTests BookChooserOrderTests BookNoteBoxSubjectTests
   BookPanelActingTests BookPanelBrainTests BookPanelDeclarationTests BookRowMenuTests CapabilityRegistryTests
   CaptureFocusReattachTests CaptureHostsUndoFilingTests CaptureTourFocusTests CaptureUndoHistoryTests
   CaptureUndoSyncTests ChromeLineLimitTests ContextBarTests CreationTargetTests DebugOracleOwnershipTests
   DebugOracleScopingTests DebugOracleTwoWindowTests DivergeDoorTests DragTypeDeclarationTests IAAndTrashShapeTests
   IndependentWorkspaceTests MultiBookEditNoteRuleTests MultiBookEditNoteTriggerTests NavigationDoorsTests
   NavigationHistoryTests NoLiteralColourTests NoteBoxCompositionTests NoteBoxCopyTests NoteBoxGeometryTests
   NoteBoxHeightTests NoteBoxSlotTests NoteBoxStateTests NoteDeleteConfirmEdgeTests NoteDeletionActTests
   NoteDeletionDeclarationTests NoteDeletionNavigateAwayTests NoteOnlyWindowTests OneTimeCodeAutoFillTests
   OpenListCloseDoorTests OpenListCloseShellTests OpenListHeightTests OpenListLandingTests OpenListLayoutMountTests
   OpenListRowCloseDoorTests OpenNotesTests PagedAnchorReportTests PaneBookBlurTests PaneFocusCatcherTests
   PaneHeldModeTests PaneLayoutTests PaneMountTests PaneMountWindowTests PaneSplitDoorTests PaneSplitModelTests
   PaneUnmountTests PostDetailModeMemoryTests PostDetailRoutingTests QuickEntryLaunchFocusTests ShellChromeTests
   ShellLandingDoorTests ShellLandingMountTests ShellLandingRuleTests SidebarLayoutTests
   SidebarSectionWindowMountTests SidebarSectionWindowRuleTests SidebarSmokeTests StarActingTests
   StarDeclarationTests StarTargetingTests StarredScrollLayoutTests StarredScrollMountTests TourEndCardAsideGateTests
   TourEndCardTests TourEngineTests TourEntryTests TourPoolTuckTests TourScriptTests TourSpotlightTests
   TutorialCurrencyTests TwoWindowMountTests WindowRegistryTests WindowUnmountTests WingSwitcherTests
   WorkspaceCloseActTests WorkspaceModelTests WorkspaceNamingTests WriteTakesPanelTests.
   `pipestatus` checked; the "Test run with N tests" line AND its skipped lines recorded. (The products are
   `62d5a4a1`'s code — HEAD's code; `test` instead of `test-without-building` would only re-check them.)
2. *R-D (prebuilt — the pre-U1b reveals in BOTH sections, U1b's oracles kept)* — `… -derivedDataPath
   DerivedData/vx283-u1b-rd test-without-building -only-testing:VariorumTests/SidebarSectionWindowMountTests`.
   Expected RED: `returningToTheNoteYouWereInRevealsItsRow`, `aShorterListKeepsTheCurrentRowInView`,
   `theOpenListFadesOnlyTheEdgesWithMoreBeyond`, `starredFadesWhereMoreLiesBeyondAndNowhereWhenItHoldsEverything`;
   GREEN: `aCloseNoteLandingRevealsTheNextRowClearOfTheFades`; observed: `aNewNoteOpenedFromThePlacesLandsWhollyInView`.
3. *R-E (prebuilt — only the viewport-height re-reveal removed)* — the same with `DerivedData/vx283-u1b-re`.
   Expected RED: `aShorterListKeepsTheCurrentRowInView`; observed: `returningToTheNoteYouWereInRevealsItsRow` (it
   turns on which callback lands first); the rest GREEN.
4. *Release.* The dev store copied back with zero dev instances and `cmp`-verified per file; prefs `defaults import`
   → delete any key the suites added → re-export → diff against `prefs-before.plist`; `Tools/stage release`; the
   one-line release report. (The known red `BookCollectingDoorsTests.theSettingsDoorIsOneActOnBothRoads` is VX-115's
   and not in this batch.)

**THE WINDOW'S RESULTS (2026-10-14 21:24–21:29, products at `62d5a4a1`, HEAD's code; logs in the gitignored
`notes/plans/vx283-screens/u1b/logs/`):**
- **The batch** (92 suites, `test-without-building`): **"✘ Test run with 408 tests in 92 suites failed after 84.583
  seconds with 3 issues."** 405 passed · 3 failed · **no skipped lines**. P7's `CapabilityRegistryTests` GREEN (its
  pending run, closed).
  1. `ChromeLineLimitTests.everyBareFixedSizeStatesItsLinePolicy` (`ChromeLineLimitTests.swift:104`) — the bare
     `.fixedSize()` sites `Core/Views/SearchPicker.swift:503`, `Features/Takes/TakesShowFaces.swift:185`,
     `Features/Library/LibraryBulkRow.swift:93/101/109`, … — **VX-245, U3's member, red on main**; no U1b file.
  2. `SidebarSectionWindowMountTests.theOpenListFadesOnlyTheEdgesWithMoreBeyond` (`:431`) — "mid-list" read
     `EdgeFades(top: 0, bottom: 15)`. **A PIN FAULT, not the code's:** the pin opened row 10 (index 9, 270…300), which
     stands clear in the 351-pt list at offset 0 (the bottom fade covers 336…351), so nothing scrolls and nothing
     lies above. The mid-list step must open a row below the fold (index 14, 420…450).
  3. `SidebarSectionWindowMountTests.starredFadesWhereMoreLiesBeyondAndNowhereWhenItHoldsEverything` (`:455`) —
     after opening the ninth star's note: window offset **35** of a max **36** (viewport 180, content 216), so the
     last starred row (192…216) is **cut by 1 pt** and the bottom edge fades 1 pt. **A REAL RESIDUAL OF F-1.** The
     open brought the rail and flipped the pitch 30 → 24 under the column's 0.22-s animation
     (`SidebarView.swift:359`, `.animation(_, value: railPostID)`); the reveal's `scrollTo` was issued inside that
     animated transition and landed against an intermediate layout; `reveal()` cleared `revealOwed` the moment it
     ISSUED the scroll, and the re-check fires only on a viewport-HEIGHT change, so the settled reading (35 of 36)
     was never asked again. The same signature, below the half-point slack, elsewhere: `returning…` passed resting at
     offset 248.58 of 249; R-D's and R-E's walker road rested at 248.19 and 248.47. This is very likely the walker's
     O-1 itself at a larger amplitude (a scroll landing mid-animation).
- **R-D** (prebuilt: the pre-U1b reveals in both sections, U1b's oracles kept) — "✘ Test run with 6 tests in 1
  suite failed after 10.256 seconds with 9 issues": **RED** `returningToTheNoteYouWereInRevealsItsRow` (row 20 of 20
  at 570…600, the window 0…351 — hidden); **RED** `aShorterListKeepsTheCurrentRowInView` (row 16 at 450…480, the
  window 129…420 — hidden); **RED** `aNewNoteOpenedFromThePlacesLandsWhollyInView` (the walker's road, observed: the
  window 248.19…599.19 — cut 0.81 pt); **GREEN** `aCloseNoteLandingRevealsTheNextRowClearOfTheFades` (as predicted —
  exact-behaviour only); **RED** both fade pins (no fade recorded — "at rest: nil", ×3 and ×3).
- **R-E** (prebuilt: only the viewport-height re-reveal removed) — "✘ Test run with 6 tests in 1 suite failed after
  10.233 seconds with 5 issues": **RED** `aShorterListKeepsTheCurrentRowInView` (the window 144…435 — the named
  pin); **RED** `returning…` (observed: 0…351 — the current-row reveal answered from the Library's stale window, and
  nothing re-revealed); **RED** the walker's road (248.47…599.47, the bottom fade 0.53); **RED** the Open fade pin (the
  pin fault above); **RED** the Starred pin (offset 0 — no reveal at all without the height trigger); **GREEN** the
  landing.
- **Restore:** the dev store's three files byte-identical before the copy-back (the test host writes no store),
  copied back from `store-before/20261015T032420Z/`, `cmp`-verified each. Prefs: the suites ADDED 9 keys (5
  `currentBlock.*`, 4 `surfaceSize.outline.*` — deleted by hand, one needing a second delete) and CHANGED 2
  (`IdleCommitSweepMark.Variorum-dev`, `variorum.backup.log`); `defaults import` of `prefs-before.plist`, re-export
  (`prefs-after-restore.plist`), diff CLEAN (1602 = 1602). `Backups/safety-copies/` holds only `castle-W1-20261013`,
  untouched; no new backup. Zero dev instances throughout; `DerivedData/vx283-u1b-rd` and `-re` deleted;
  `vx283-u1` kept for the walker. Claim released 21:29:47.

## Ladder

*(Findings and dispositions land here, repo-first, before any fix session sees them.)*
