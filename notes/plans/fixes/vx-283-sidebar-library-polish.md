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

**HER OVERNIGHT MANDATE (2026-10-15 ~00:35, verbatim):** *"I am going to sleep, rule provisionally overnight in my
absence and leave me a handoff in the morning. you or 336 can merge in last (whoever gets there gets there), whoever
does should have a release build ready, write notes on what was updated (I don't have to review those notes, it's
fine), and push a release to the website so I can try the new things out tomorrow morning."* So: overnight every
non-author-only call is PROVISIONAL-and-continue (recorded, bundled for the handoff); the run continues through the
ladder and the closeout; **whichever of VX-283 / VX-336 merges LAST** bumps the version, builds the release, writes
the notes itself (her review waived for this release — the 0.9.3/0.9.5 one-off exception, her word) and publishes to
stargazing.tech by the proven road (memory: Variorum release publishing). The handoff `notes/handoffs/vx-283-handoff.md`
is waiting for her in the morning.

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
| U1 | VX-286 · VX-285 · VX-287 · VX-289 — the Open list's layout and closing | **U1d (her two memo rulings: follow only on her acts; the fade reshaped) — READY FOR STAGE** (≈15 min): the 96-suite batch, the mount suite ×5, R-I and R-J (prebuilt), the restore — the U1d section's LIVE STATUS. Then the re-walk of R2–R6. |
| U2 | VX-288 (+ the chip on the Open list's rows) — the drag, light version | **IN-PROGRESS** — headless build (the U2 section's LIVE STATUS) |
| U3 | VX-121 · VX-175 · VX-20 · VX-245 (+ VX-359) — the Library and the red lint | **READY FOR STAGE — the closing window** (≈15 min; the U3 section's Q6): the first window's batch green but for two of my own pins (test defects, fixed headless — test files only); R-ALL prebuilt in `vx283-u3-revert` and the tree restored; `vx283-u3` holds the current products for the walker |
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
- Q5 — the residual's fix + the pin fault (headless, AFTER the window — the orchestrator told in the report): DONE
  (this commit) — headless `build-for-testing` green; the re-run PENDING a short window (Q6).
- Q7 — the orchestrator's ruling on P-U1b-5 (the settle derived from the rail's ONE transition constant, pinned):
  DONE (this commit) — headless `build-for-testing` green; its pins run in Q6.
- Q6 — the re-run window: DONE (claim `vx283-u1b2` 21:40:19 → released 21:43:09) — **NOT GREEN: the Starred pin is
  still red** (2 pt short — "THE RE-RUN'S RESULTS" below). **STOPPED at the orchestrator's rule** ("if anything
  besides VX-245's lint is red, record it exactly and stop"): nothing fixed; NOT READY FOR WALK; awaiting the
  orchestrator. Store and prefs restored and verified.
- Q8 — the orchestrator's ruling P-U1b-6 (`a5f0eea1`): IN-PROGRESS. **Plan:** (1) pure
  `SidebarLayout.revealOffset(row:rows:rowHeight:window:depth:)` — the EXACT content offset (row top = row ×
  rowHeight, the half-row clearance where more lies beyond, clamped to `[0, max(0, content − viewport)]` of the window
  as read, nil when clear); `revealAnchor` RETIRES (its pins rewritten on the offset); (2) the modifier applies it
  ABSOLUTELY — `.scrollPosition($position)` on the section's scroll view, `position.scrollTo(y:)` in a transaction
  with animations disabled — the proxy no longer reveals (it did nothing else in either section); (3) re-asks on the
  current row, the viewport, the CONTENT height, the row height, the mount's first reading, plus the derived settled
  ask; never on an offset-only change; (4) pins: the exact offsets (above · below · the ends · a viewport shorter than
  a row · the pitch flip's before/after windows) and idempotence; the mounted Starred pin; **R-F** (the application
  reverted to the proxy's anchor road, prebuilt) expected RED on the Starred pin. The offscreen probe re-run WITH a
  row-height flip before the window.
  **Built (this commit):** `SidebarLayout.revealOffset` (pure, exact, clamped, idempotent); `revealAnchor` RETIRED;
  `SidebarSectionWindow` applies the offset through `.scrollPosition($position)` + `position.scrollTo(y:)` in an
  unanimated transaction; both sections' `ScrollViewReader`s are gone (the proxy did nothing else); re-asks on the
  current row, the viewport, the content height, the row height, the mount's first reading, plus the derived settled
  ask. Pure pins rewritten on the offset (×10 + the beat ×2): exact above (135) · below (5) · the ends (350, 0, the
  row before last 335) · a window shorter than a row (the row's top, 300) · the pitch flip's two windows (45 at 30 pt,
  36 at 24 pt; the re-run's resting 34 → 36; 36 → nil) · idempotence from every window (four window/pitch shapes).
  Headless `build-for-testing` green. **The offscreen probe WITH the flip** (current + 30 → 24 in one animated update,
  the rail's own beat): the ninth star lands at 36…216 — exactly the end, clear — from rest and from mid-list, and
  24 → 30 lands clear too.
  **PROVISIONAL P-U1b-7 — a content change from a row closing elsewhere does not re-ask.** The ruling lists the
  content height as an axis (the pitch flip's signal); built, it re-asks on a content change only when the row COUNT
  did not change — a ✕ on another row while she has scrolled away would otherwise pull the list back to the current
  row ("her own scrolling is never pulled back"). A pitch flip keeps the count, so it still re-asks (and the row-height
  axis re-asks anyway). Options: (a) content changes with an unchanged count [built]; (b) every content change (the
  ruling's literal list, with the ✕ pull-back); (c) content changes only while a settled ask is pending.
  **R-F — prebuilt, restored:** the application reverted to the proxy's anchor road (a `ScrollViewReader` inside the
  modifier, the anchor fraction `(row × pitch − target) / (viewport − pitch)` through `proxy.scrollTo(id, anchor:)`,
  unanimated; no `.scrollPosition`) — patch `notes/plans/vx283-screens/u1b/reverts/R-F.patch` applied, built into
  `DerivedData/vx283-u1b-rf` (green), restored by `git checkout --`; **no revert is in the tree** (`git diff` empty).
- Q9 — the window: DONE (claim `vx283-u1b3` 21:53:35 → released 21:56:35) — **NOT GREEN, STOPPED at the
  orchestrator's rule; nothing fixed. The result INVERTS the ruling's expectation: HEAD's absolute `ScrollPosition`
  road rests short; R-F's proxy road (with every new axis) is GREEN.**
  - **The batch** (93 suites, products at `a347f992` = HEAD's code): **"✘ Test run with 413 tests in 93 suites failed
    after 85.803 seconds with 2 issues."** 411 passed · 2 failed · no skipped lines. (1) VX-245's lint
    (`ChromeLineLimitTests.swift:104`, U3's, on main). (2) **`starredFadesWhereMoreLiesBeyondAndNowhereWhenItHolds
    Everything` (`SidebarSectionWindowTests.swift:544`) STILL RED:** "the ninth star revealed: EdgeFades(top: 12.0,
    bottom: 1.5) over ScrollWindow(offset: 34.5, viewport: 180.0, content: 216.0)" — 1.5 pt short of 36. Every other
    U1b pin green (the return rested at 248.69 of 249 — non-integer again; the shorter window 210 → clear).
  - **R-F** (prebuilt — the application on the proxy's anchor road, everything else of P-U1b-6 kept): **"✔ Test run
    with 6 tests in 1 suite passed after 10.384 seconds."** — ALL GREEN, **the Starred pin included** (expected RED).
    The return rested at 249.16. `DerivedData/vx283-u1b-rf` deleted; `vx283-u1` kept.
  - **Reading (untraced — for the orchestrator, not acted on):** the axes are what fixed it (R-F carries them all);
    the absolute road itself is what still misses. The leading suspect is `ScrollPosition`'s VALUE semantics: a
    re-ask computing the same target (36) as the binding already holds (`position.scrollTo(y: 36)` from the first
    ask) may change nothing SwiftUI can see, so after the flip nudges the real offset to 34.5 the identical re-ask
    never reaches the scroll view; the proxy's `scrollTo` is imperative and lands every time. Untested; the offscreen
    probe (which passed with `ScrollPosition`) has no lazy-stack re-estimate after the flip.
  - **Options (none built):** (a) keep every axis (P-U1b-6's half that R-F shows works) and apply through the proxy
    (R-F's road, as prebuilt — green); (b) keep the absolute road but force a distinct value per ask (e.g. reset the
    position before `scrollTo(y:)`) — needs a trace first; (c) both roads.
  - **Restore:** the dev store's three files byte-identical before the copy-back, copied back from
    `store-before/20261015T035344Z/`, `cmp`-verified; prefs: 9 keys ADDED (deleted; one `surfaceSize.outline.*` key
    needed a second delete after the import), 2 CHANGED (the idle-sweep mark, the backup log) — import, re-export,
    diff CLEAN (1602 = 1602); `castle-W1-20261013` untouched; zero dev instances throughout.
- **P-U1b-7 — ACCEPTED (a) by the orchestrator (2026-10-14, the Q9 GO):** a content-height change re-asks only when
  the row count did not change, so a ✕ on another row never pulls her scrolled list back.
- Q10 — the orchestrator's ruling on Q9 (`8a77431d`, ruled (a)): **R-F's road is HEAD** — every trigger, the pure
  `revealOffset`, the derived settled backstop and P-U1b-7 stay; the application goes through the proxy (a
  `ScrollViewReader` inside `SidebarSectionWindow`, the exact offset turned into the proxy's anchor, unanimated); the
  `ScrollPosition` state removed; the bookkeeping class hoisted to the top level (`SidebarSectionMemory`), which also
  clears the build's isolated-conformance warning on the generic modifier (present since Q2). No pin changed (the
  mounted pins never touched `ScrollPosition`). DONE (this commit) — `DerivedData/vx283-u1` rebuilt from it, green.
- **R-G — prebuilt, restored:** ONLY the content-height and row-height re-asks dropped (the geometry action's `||
  (content changed && !rowsChanged)` arm; `onChange(of: rowHeight)` keeps `refreshFades` but no longer asks), all else
  kept — patch `notes/plans/vx283-screens/u1b/reverts/R-G.patch` applied, built into `DerivedData/vx283-u1b-rg`
  (green), restored by `git checkout --`; **no revert is in the tree** (`git diff` empty).
- Q11 — the window: DONE (claim `vx283-u1b4` 22:05:11 → released 22:08:15) — **NOT GREEN, STOPPED; nothing fixed.
  The Starred pin is red on HEAD — the SAME code that ran green as R-F in the Q9 window: the pin is FLAKY (timing),
  so neither road has been shown to fix it.**
  - **The batch** (93 suites, products at `1b51bc56` = HEAD's code): **"✘ Test run with 413 tests in 93 suites failed
    after 86.239 seconds with 2 issues."** 411 passed · 2 failed · no skipped lines. (1) VX-245's lint
    (`ChromeLineLimitTests.swift:104`). (2) **`starredFadesWhereMoreLiesBeyondAndNowhereWhenItHoldsEverything`
    (`:544`) RED:** "EdgeFades(top: 12.0, bottom: 0.5) over ScrollWindow(offset: 35.5, viewport: 180.0, content:
    216.0)" — 0.5 pt short of 36 (the clear test's slack is 0.5, the fade's own floor 0.5, so 0.5 counts as a fade).
    Every other U1b pin green (the return rested at 249.33 of 249; the shorter window exact).
  - **R-G** (prebuilt — only the content-height and row-height re-asks dropped): "✘ Test run with 6 tests in 1 suite
    failed after 10.400 seconds with 1 issue." — the Starred pin **RED** ("bottom: 1.0 over offset 35.0"), the other
    five green. As expected — but HEAD is red too, so R-G proves nothing against it. `DerivedData/vx283-u1b-rg`
    deleted; `vx283-u1` kept.
  - **The Starred readings so far (offset of a max 36, after the flip):** Q2 code 35 · Q5/Q7 code 34 · the
    ScrollPosition road 34.5 · the proxy road with every axis 36 (Q9's R-F, green) then **35.5** (this batch) · R-G
    35. Non-integer resting offsets keep appearing on the Open list's return too (248.58 · 248.69 · 249.16 · 249.33 —
    inside the slack). **Reading (untraced):** the row lands a fraction short or over by a timing-dependent amount
    after the flip — something keeps moving the offset after the last reveal (an animated scroll or clip-view
    adjustment riding the 0.22-s transition, or a reading that never reports the final frame). A NEW TRACE is needed
    (the orchestrator's rule: a fresh successor takes it). Leads: instrument the Starred window's readings over time
    after the flip (does a final reading arrive? does the offset drift after the settled ask?); the offscreen probe
    (its flip lands exactly 36 every time — what differs: the real column's outer scroll, the fit test's two
    measurements, the lazy re-estimate with 9 starred rows of which one is unrealized).
  - **Restore:** the dev store's three files byte-identical before the copy-back, copied back from
    `store-before/20261015T040520Z/`, `cmp`-verified; prefs: 9 keys ADDED (deleted; one `surfaceSize.outline.*` key
    needed a second delete after the import), 2 CHANGED (the idle-sweep mark, the backup log) — import, re-export,
    diff CLEAN (1602 = 1602); `castle-W1-20261013` untouched; zero dev instances throughout.

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
   SidebarSectionWindowMountTests SidebarSectionWindowRuleTests SidebarSmokeTests SidebarTransitionBeatTests
   (added at Q7 — the 93rd) StarActingTests
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

**Q5 — THE RESIDUAL, TRACED AND FIXED (headless, after the window):**
- **The mechanism, measured offscreen** (the scratchpad probe — a standalone process, a never-shown window, no app,
  store or prefs — now with the column's own animation): when a current-row change and a viewport change ride ONE
  animated transaction (`withAnimation(.easeInOut(duration: 0.22))`, the rail's), a `scrollTo` issued during the
  transition is resolved against the scroll view's PRESENTATION frame — the pre-animation height — and once the
  animation ends no reading arrives (SwiftUI's model already holds the target height). **[CORRECTED at U1c, P-U1c-1:
  the second half is REFUTED for this road — the U1c probe AND the mounted rig read EVERY frame of the beat, the last
  at the settled height (`vp 180.002 → 180.000`), and the settled backstop reads that fresh window and lands exactly
  ("T3 — THE MOUNTED RIG'S FACTS" (2)). The residual was the trigger's per-reading 0.5-pt step threshold skipping the
  ease's tail, not a missing reading.]** Q2's modifier, the
  owed-until-a-clear-reading variant tried first, and the old reveal ALL rested wrong: e.g. the last row revealed at
  offset 249 (= 600 − the OLD 351) while the viewport settled at 251 — the row hidden. That is the window's 1-pt
  Starred residual and, at a larger amplitude, very likely the walker's O-1 (a 15-pt cut).
- **The fix** (`SidebarSectionWindow.swift`): every reveal request (mount's first reading, a current-row change, a
  viewport-height change) asks TWICE — at once, and again `transitionSettle` (300 ms, past the 0.22-s rail
  animation) later, through an `onChange` on a bumped `@State` so the second ask runs with the section's FRESH rows,
  current row and pitch; a later request supersedes an earlier one's second ask (an episode counter). Both scrolls are
  issued UNANIMATED (a transaction with animations disabled), so a scroll lands on the layout it was computed against.
  The probe, re-run: every step clear, the three animated ones included (349…600, 349…540, 354…585).
- **P-U1b-5 — the settle delay: RULED (a) by the orchestrator (2026-10-14), with the coupling.** An immediate ask +
  one ask after the column settles; in an animated arrival the row may sit short for that moment, then settles in.
  The ruling's condition: the wait is never a free-standing number — a hard-coded settle beside the rail's literal
  0.22 would drift silently the day the motion changed. **Built (Q7):** `SidebarLayout.railTransition` (0.22 s) names
  the column's ONE transition beat — both of `SidebarView`'s `.animation` modifiers (`value: railPostID`, `value:
  noteBox == nil`) read it, and the note box's comment names it instead of the number; `transitionSettleMargin`
  (0.08 s: the transition's last frame landed and its reading delivered) is named with its reason;
  `SidebarLayout.transitionSettle` = beat + margin (0.30 s, unchanged in effect); `SidebarSectionWindow.
  transitionSettle` is `.seconds(SidebarLayout.transitionSettle)`. **Pins** (`SidebarTransitionBeatTests`): the settle
  strictly later than the beat (and exactly beat + margin, the section's wait equal to it); a source read that every
  `.animation(` in `SidebarView.swift` reads `SidebarLayout.railTransition` with no literal duration left, and that the
  section window's wait reads the derived settle with no `.milliseconds(` of its own. Not coupled, deliberately: the
  Library info panel's `LibraryCatalogView.panelAnimation` (also 0.22 s) — another surface's motion (row 24's PANEL
  half, U3's file), not the sidebar's beat.
- **The pin fault:** `theOpenListFadesOnlyTheEdgesWithMoreBeyond`'s mid-list step now opens row 15 (index 14,
  420…450), below the 351-pt list's fold.

**THE RE-RUN'S RESULTS (Q6 — 2026-10-14 21:40–21:43, products at `dffcde59`, HEAD's code; log
`notes/plans/vx283-screens/u1b/logs/batch-q6.log`, gitignored):**
- **The batch** (93 suites, `test-without-building`): **"✘ Test run with 410 tests in 93 suites failed after 86.579
  seconds with 2 issues."** 408 passed · 2 failed · **no skipped lines**.
  1. `ChromeLineLimitTests.everyBareFixedSizeStatesItsLinePolicy` (`:104`) — VX-245's lint, U3's, red on main (as
     before).
  2. **`SidebarSectionWindowMountTests.starredFadesWhereMoreLiesBeyondAndNowhereWhenItHoldsEverything`
     (`SidebarSectionWindowTests.swift:516`) — STILL RED:** "the ninth star revealed: EdgeFades(top: 12.0, bottom:
     2.0) over ScrollWindow(offset: 34.0, viewport: 180.0, content: 216.0)" — the last starred row (192…216) rests
     **2 pt short** of the window's end (36), the bottom edge fading 2 pt. (Before Q5 it read 35 — 1 pt short.)
- **Everything else U1b pins is green:** the pure rules ×9 and the beat ×2; `returningToTheNoteYouWereInRevealsItsRow`
  (resting at 249.006 of 249), `aShorterListKeepsTheCurrentRowInView` (204.0 — exact), the walker's road, the
  ⇧⌘W landing, `theOpenListFadesOnlyTheEdgesWithMoreBeyond` (the pin fault fixed).
- **What differs in the red case — an UNTRACED hypothesis, not acted on:** only the Starred step changes its ROW
  HEIGHTS inside the transition (the open adds the rail and a fourth Open row, so the column's pitch flips 30 → 24;
  Starred's window goes 225 → 180, its content 270 → 216), and its target row was never realized at the new pitch
  before the reveal. The Open-list pins (no pitch flip at 900 pt) land exact, and the offscreen probe (fixed 30-pt
  rows) never showed it. So the proxy's `scrollTo(id, anchor:)` may resolve the lazy stack's STALE position estimate
  for that row — and even the settled second ask (300 ms later) lands short, after which nothing asks again. To trace
  before any fix (the probe can reproduce a pitch flip offscreen).
- **Options for the orchestrator (none built):** (a) after the settled ask, keep asking on READINGS while the row is
  not clear (bounded; settle-time only, so it never fights her); (b) scroll by an exact OFFSET computed from the row
  model (`ScrollPosition.scrollTo(y:)`), not the proxy's id lookup; (c) both.
- **Restore:** the dev store's three files byte-identical before the copy-back (the test host writes no store), copied
  back from `store-before/20261015T034027Z/`, `cmp`-verified each. Prefs: 9 keys ADDED (deleted by hand; one
  `surfaceSize.outline.*` key needed a second delete after the import), 2 CHANGED (`IdleCommitSweepMark.Variorum-dev`,
  `variorum.backup.log`); `defaults import` of `prefs-before-q6.plist`, re-export, diff CLEAN (1602 = 1602).
  `castle-W1-20261013` untouched (the only safety copy); zero dev instances throughout.

#### U1b — THE RE-WALK PLAN (the orchestrator's; her walk rule — a fresh Opus at xhigh)

Products: `App/Variorum/DerivedData/vx283-u1/Build/Products/Debug/Variorum.app` (U1b's tree, rebuilt at `dffcde59`).
Screens to `notes/plans/vx283-screens/u1b/walk/`, named `<row>-<voice>-<appearance>.png`, sidebar rows as REGION
captures at native resolution (as U1's walk did), a whole-window capture beside each. Store copy + prefs export
FIRST (the walk protocol), restored + diffed LAST.

- **R0 — preconditions** (strict pgreps empty; AX + Screen Recording trusted; prefs exported; the three store files
  copied with zero dev instances; posture noted).
- **R1 — seed:** open ~18 notes (the Open list overflows at the tallest window), star 9+.
- **R2 — F-2, the edge fade, Open list.** Tallest window. (a) Scrolled to the TOP: no fade at the top edge, a fade
  at the bottom edge (more below). (b) Scrolled to the MIDDLE: both edges fade; the partial rows fade into the room,
  no letters sliced under the "Open" header. (c) Scrolled to the BOTTOM: the top fades, the bottom does not. Capture
  each; zoom crops of each edge so the fade (or its absence) is legible. Hover a row inside the fade band: its ✕ is
  still reachable (the fade takes no clicks).
- **R3 — F-2, Starred.** With 9+ stars: at its top, only the bottom fades (the half row softened, still reading
  "there is more"); scrolled to its end, only the top fades. Capture both.
- **R4 — the voices and dark.** R2(b) and R3's captures in Terminal light, Study dark, Terminal dark: the fade
  matches each room exactly (no grey band, no seam, no visible gradient box against the column).
- **R5 — F-1, the current row always wholly in view.** (a) TWENTY rapid opens from the Library (the walker's O-1
  road — open, capture the sidebar, next): every time the current row is fully visible, never cut by the edge or
  under the fade. (b) The Library and BACK to the note you were in (the deterministic road): the row is revealed.
  (c) ⇧⌘W and a ✕ landing deep in the list: the landed row is fully in view. (d) Resize the window shorter while a
  note deep in the list is current: the row stays in view. Capture each; any cut row is DOES NOT HOLD.
- **R6 — her own scrolling is never pulled back.** Scroll the Open list away from the current row by hand and wait
  a few seconds: it stays where she put it.
- **R7 — nothing regressed:** W2's tall list still stops just above the footer; the scroll bar still in the margin
  beside the ✕ (one capture each in Study light).
- **R8 — restore and release** (copy the store back + `cmp`; prefs import / delete added keys / re-export / diff;
  posture Standard, unlocked, castle-W1 untouched; `Tools/stage release --who vx283-u1b-walk`).

Each row's line: what was done · the file(s) · HOLDS / DOES NOT HOLD (+ what's wrong). Then OBSERVATIONS.

The coordinator's rules bind (a system popup you can't dismiss → stop and report its words; What's New dismissed; never `claude mcp list` or any MCP client). ⇧⌘W in a window merged into macOS tabs is macOS's Close Window by her ruling — walk in an ordinary window.

#### U1b — RE-WALK RECORD

**Walker:** a fresh Opus 5.5 at xhigh (not an implementer of U1/U1b/U1c), 2026-10-14 23:38 → 2026-10-15 00:05, on the
orchestrator's claim `vx283-u1b-walk`; the Debug app `App/Variorum/DerivedData/vx283-u1/…/Variorum.app` (built 23:16
from the branch, not rebuilt), PID 95179, discriminated by path. Screens in the gitignored
`notes/plans/vx283-screens/u1b/walk/` (sidebar rows as 2× region captures of the sidebar rect, `-window` captures
beside them, `-zoom-*` 2× nearest-neighbour crops of the edges). Every image cited was opened and looked at.

- **R0 — preconditions.** Both strict pgreps empty before launch; her app absent (the guard); the host `AX: true
  SCREEN: true`. Store copy + prefs export were the orchestrator's (`u1b-walk/store-before/`, `prefs-before.plist`),
  not redone. Posture at launch: Standard, unlocked (the Bookcase came up, no lock screen), voice **Study**,
  appearance **follow system** (light). No What's New sheet showed. Window AX-sized to its tallest, 1380 × 1010 at
  (60, 36). · HOLDS.
- **R1 — seed.** The store had 14 notes open and 1 star; 8 more starred through Library ▸ right-click ▸ Star (9
  starred); the twenty opens of R5(a) filled the Open list to its 20-row cap. · done.
- **R2 — the edge fade, Open list (Study light, tallest window).** (a) top — `R2a-study-light.png`
  (+`-window`, `-zoom-top`, `-zoom-bottom`): "o museu" whole under the header, no top fade; "the seal" at the bottom
  fades into the room, legible as a ghost. (b) middle — `R2b-study-light.png` (+`-zoom-top`, `-zoom-bottom`): the
  current row "wings" fades under the header (the pill and letters soften upward), "sharing from where you are"
  fades at the bottom; no hard slice either edge. (c) bottom — `R2c-study-light.png` (+`-zoom-top`, `-zoom-bottom`):
  "owned, finished, sealed" fades at the top, the last row whole, no bottom fade. The ✕ inside the fade band:
  `R2-xfade-study-light-1-hover.png` (pointer on the faded "the seal" row's ✕ — its tooltip "Close (…)" shows) →
  click → `-2-after.png` (the row gone, "export" slid into the band, the pane unmoved). The fade matches the room,
  no band or seam, in every capture. · HOLDS — **but see O-2** (a shallow overflow under ~12 pt reads as a slice).
- **R3 — Starred (Study light, 9 stars).** `R3-top-study-light.png`: at its top, quicknotes + 6 whole rows, the
  half row "what the door is" faded (still reads "there is more"), no top fade. `R3-end-study-light.png`: at its end,
  "seeing, answering, undoing" faded at the top, "Standard and Castle: what…" whole, no bottom fade. · HOLDS.
- **R4 — the voices and dark.** Voice and appearance flipped in Settings (window moved clear of the sidebar).
  **Terminal light** — `R4-R3top-terminal-light.png` / `R4-R3end-terminal-light.png` (Starred top/end: right),
  `R4-R2a-terminal-light.png` / `R4-R2c-terminal-light.png` and `R6-terminal-light-t03.png` (Open top: "o museu"
  whole, "export…" faded at the bottom) — the fade matches the warm room. **Terminal dark** —
  `R4-R3top-terminal-dark.png`, `R4-R3end-terminal-dark.png`, `R4-R2a-terminal-dark.png`, `R4-R2c-terminal-dark.png`:
  fades into the black room, no grey band, no seam. **Study dark** — `R4-R3top-study-dark.png` (Starred top right),
  `R4-R3end-study-dark.png`, `R4-R2a-study-dark.png` (Open top right), `R4-R2c-study-dark.png` (Open end right). The
  colour match holds in all four rooms. **But** the Open list's "middle" gesture (to the top, then one wheel line
  down) lands REPRODUCIBLY at ~5 pt short of the end in both Study rooms (`R4-R2b-study-dark.png`,
  `R4-repro-study-dark-t05/-t15/-t45.png` — stable for 4.5 s — `-zoom-top`, `-zoom-bottom`;
  `R4-repro-study-light.png` the same in light): the current row "what always asks" is **sliced through its
  descenders** at the bottom edge ("alwavs") under a ~5-pt partial fade, and the top row "wings" reads crisp in dark
  (a barely visible fade in light) with four rows above it. The Terminal "middle" captures
  (`R4-R2b-terminal-light.png`, `R4-R2b-terminal-dark.png`) landed at the end instead, so no Terminal middle state
  was captured. · **DOES NOT HOLD** for the shallow-overflow state (O-2); HOLDS for the colour match in every room.
- **R5 — the current row always wholly in view.** (a) TWENTY rapid opens from the Library (⌥⌘[ back, click a
  title, capture at 2.6 s; ~5 s per open; 17 new rows appended at the bottom, 3 opens of rows already in the list —
  "Standard and Castle…", "what the door is", "wings" — revealed under the header mid-list): `R5a-01-study-light.png`
  … `R5a-20-study-light.png` (+`-window` each; `R5a-19-study-light-zoom-top/-bottom.png`). **20 of 20 show the
  current row wholly in view**, never cut, never under a fade; the row above a mid-list reveal is the faded partial.
  (b) The Library and back: `R5b-study-light-0-opened` (the last row "connecting a client" opened) → `-1-scrolled-away`
  (Open list scrolled to its top by hand) → `-4-library` → ⌥⌘[ `-5-back-from-library`: the row revealed whole at the
  bottom; also note→note ⌥⌘[ / ⌥⌘] (`-2-library` landed on the previous note "wings", revealed; `-3-back`, revealed).
  (c) ⇧⌘W on the last row → `R5c-study-light-1-shiftcmdw` (landed on "how much, where, how long", whole); the ✕ on
  that current row → `R5c-study-light-2-x-landing` (landed on "what always asks", whole). (d) Window to 640 then 480
  tall with "what always asks" current: `R5d-study-light-640.png` / `-480.png` (the column overflows; the outer scroll
  at its top, Starred revealing the same note whole), `R5d-study-light-480-outer-scrolled.png` (+`-window`; the outer
  column scrolled down: the Open list at its 3½-row floor, the current row whole at its bottom, the partial row
  faded at its top), `R5d-study-light-640b.png` (back to 640: the same, whole). · HOLDS.
- **R6 — her own scrolling is never pulled back.** Scrolled wholly away (the current row off-view):
  `R6-study-light-bottom-t2/-t5/-t10/-t20.png` stayed 20 s; `R6-study-light-mid-t0…t20.png` stayed 20 s; a Terminal
  light 85-s timed series (`r6series/p-*.png`) stayed. **But three times the list WAS pulled back to the current row
  with no input:** (1) Study light — `R2b-study-light.png` ("wings" under the top fade) → 6 s later
  `R6-study-light-after-wait.png` (the list moved ~16 pt so "wings" sat whole with the half-row clearance — the
  reveal's exact landing; a whole-sidebar diff shows only the Open list changed); (2) Terminal light — scrolled to
  the top: `R6-terminal-light-t03/-t1/-t3.png` at the top, then `-t6/-t12.png` back at the end with the current last
  row whole; (3) Terminal light, a timed series (`r6series/s-*.png`, scroll at 23:56:50): at the top until ~17 s, back
  at the end by ~19 s. Also the first Terminal-light R4 pass's Open captures (`R4-R2a/-R2b/-R2c-terminal-light.png`,
  each 2–3 s after a scroll to the top or middle) all show the end state. Intermittent — the trigger not found
  (three tries in a row did not reproduce it). · **DOES NOT HOLD.**
- **R7 — nothing regressed (Study light).** `R7-study-light-tall.png` (+`-window`): the tall list stops just above
  the sync footer, the last row whole, no row under the footer, no empty band. `R7-study-light-scrolling.png`
  (captured mid-scroll): the overlay bar at x ≈ 440–453 px of the 480-px sidebar, every ✕ ending by ~420 px — clear
  in the margin. · HOLDS.
- **R8 — restore and release.** Quit MY instance by identity (`tell application id … to quit`); both strict pgreps
  empty after. With zero dev instances the three store files were copied back from `u1b-walk/store-before/` and
  `cmp`-verified byte-identical each (the `.sqlite` was already identical; `-wal` and `-shm` had changed). No new
  file in `Backups/` (its mtime Oct 14 09:17); `castle-W1-20261013` untouched (its files Oct 13). Prefs: the walk
  ADDED 27 keys (`currentBlock.*` ×23, `surfaceSize.outline.*` ×4 — each deleted by hand) and CHANGED 7
  (`openNotes.remembered.ids`/`.recency`, both window frames, `appearanceChoice`, the backup log, the idle-sweep
  mark); `defaults import` of `prefs-before.plist`, re-export (`u1b-walk/prefs-after-restore.plist`), diff CLEAN
  (1602 = 1602, none added, removed or changed). The voice is a store setting, restored with the store copy;
  appearance restored by the import (`system`). Posture Standard/unlocked throughout. · HOLDS.

**OBSERVATIONS (outside the verdicts — for the orchestrator's eye):**
- **O-1 — the pull-back (R6).** The only visible pattern: the list snaps to the reveal's exact landing (row whole,
  half-row clearance), some seconds after her scroll, with nothing touched. Untraced guess only: something
  periodic or deferred perturbs the column's viewport, and P-U1c-1's "ANY viewport change re-reveals" turns it into
  a pull-back. The first R4 Terminal pass (straight after the voice flip) did it on every scroll.
- **O-2 — a shallow overflow slices.** The fade's depth follows the overflow (the pins' `EdgeFades(bottom: 1.5)`
  shape), so when only a few points lie beyond an edge the fade is a few points deep and a row there reads
  **sliced**, not faded — the very look F-2 set out to remove (`R4-repro-study-dark-zoom-bottom.png`: the current
  row's descenders cut, ~5-pt fade). In the same state the top edge, with four rows above, shows no visible fade in
  dark (`-zoom-top`). Reproduced in Study dark and Study light by "to the top, then one wheel line".
- **O-3 — a fully faded partial row leaves a blank band.** When a partial row's text lies entirely in the outer half
  of the bottom fade, nothing of it shows: `R5a-19-study-light-zoom-bottom.png` — ~23 pt of empty room between the
  last whole row and the footer hairline with more rows below (pixel-measured: no ink between the row and the
  hairline). The list reads as ending there; no "there is more" signal at that edge.
- **O-4 — the top partial row's letters show their lower half, faintly** (`R2b-study-light-zoom-top`,
  `R2c-study-light-zoom-top`): sliced by the clip but faded to a ghost — reads soft, not unfinished, in all four rooms.
- **O-5 — ⌥⌘[ from a note goes to the previous NOTE in history**, not the Library (`R5b-study-light-2-library` is
  "wings") — the history's normal behaviour, noted only because R5(b)'s "the Library and back" needed a sidebar click.
- **O-6 — a plain click on a Library row's tag chip does not open the note** (my first twenty-open pass clicked at
  x = 450 pt, on the chips, and opened nothing; the pass was discarded and re-run on the titles). Not a finding.
- The ✕ shows on every row at rest; a hover over the ✕ inside a fade band shows its tooltip.

#### U1b — THE ORCHESTRATOR'S RULING ON THE RE-RUN'S RED (2026-10-14 ~21:55 — P-U1b-6)

The Starred pin rests 2 pt short after the row pitch flips 30 → 24 mid-transition. **The mechanism, read in the
code:** `reveal()` computes an ANCHOR FRACTION from the window as last read (`revealAnchor`'s `room = viewport −
rowHeight`) and applies it through `proxy.scrollTo(id, anchor:)`, which resolves the row through the lazy stack's
own idea of where that row sits. Mid-transition both inputs are stale — the fraction was computed against the old
viewport/pitch, the lazy position against rows not yet laid out at the new pitch — so the landing is wrong by
whatever drifted. More asks on the same road only repeat the stale arithmetic. **Option (a) (keep asking with a
limit) is NOT taken** — polling over a wrong mechanism.

**RULED (b), with every input axis (the overlay/sink delivery law):**
1. A pure `SidebarLayout.revealOffset(row:rows:rowHeight:window:depth:) -> CGFloat?` — the EXACT content offset that
   puts the row wholly in view and clear of the fades (row top = `row × rowHeight`; the same half-row clearance rule
   as today), clamped to `[0, max(0, content − viewport)]` of the window as read; nil when the row already stands
   clear (idempotent — a second reveal from the result moves nothing). It replaces `revealAnchor`'s fraction;
   `revealAnchor` and its pins retire or become thin wrappers — the implementer's call.
2. Apply it ABSOLUTELY: the section's scroll view takes a `ScrollPosition` (`.scrollPosition($position)`;
   `position.scrollTo(y:)`), unanimated — never the proxy's id lookup. (Check nothing else in the sidebar relies on
   the proxy for that section; keep any other road intact.)
3. Re-ask on EVERY input axis: the current row changing; the measured VIEWPORT changing; the measured CONTENT height
   changing (this is the pitch flip's own signal — the rows re-laid at 24 pt arrive as a new content height); the
   row height changing; the mount's first measured reading. The settled ask (P-U1b-5, the derived beat) stays as a
   backstop. Her own scrolling is still never pulled back: no reveal fires from an offset-only change.
4. Pins: the pure rule's exact offsets (above, below, the ends, a viewport shorter than a row, the pitch flip's
   before/after windows), idempotence; the mounted Starred pin GREEN with the flip; R-F — revert the application to
   the proxy's anchor road — red on the Starred pin.

#### U1b — THE ORCHESTRATOR'S RULING ON Q9 (2026-10-14 ~22:00 — P-U1b-6 AMENDED)

Q9 inverted my prediction: on HEAD's absolute `ScrollPosition` road the Starred pin still rests 1.5 pt short, while
R-F — every P-U1b-6 trigger KEPT, only the application put back on the proxy's anchor road — went **6/6 green, the
Starred pin included**. So the half of my ruling that carried the fix is the EVERY-INPUT-AXIS re-ask (content height,
row height, viewport, current row, mount), and the half I named as the mechanism (the proxy road's stale arithmetic)
was **wrong as the cause**: a direct `proxy.scrollTo` re-issued on each fresh reading converges, while a
`ScrollPosition` set again to the value it already holds is most likely a no-op to SwiftUI (the implementer's
reading, untraced — recorded, not pursued). **Item 2 of P-U1b-6 (apply absolutely through `ScrollPosition`) is
WITHDRAWN.** RULED (a): keep every trigger, the pure `revealOffset`, the settled backstop and P-U1b-7; apply through
the proxy (the R-F patch becomes HEAD).

**The proof the triggers are the fix (the hallucination guard):** a new revert **R-G** — drop the content-height and
row-height re-asks only, keep everything else — must turn the Starred pin RED; and the Q6 re-run (pre-P-U1b-6 code)
already recorded it red. If R-G stays green, the fix is unexplained and the leg stops again.

#### U1b — THE ORCHESTRATOR'S RULING ON Q11 (2026-10-14 ~22:15 — P-U1b-8, the friction doctrine applied)

Q11: HEAD (the proxy road, the code R-F ran GREEN in Q9) rested the ninth star 0.5 pt short; across six runs the
resting offset after the pitch flip read 34 · 34.5 · 35 · 35 · 35.5 · 36 of 36, and the Open list's return lands at
248.58…249.33 of 249. **A sub-2-pt drift that SwiftUI's scroll settles into after the transition, varying run to run**
— the pin flakes on it. Four fix legs have now chased the same sub-pixel number; that is the friction doctrine's
signal that the RULE is mis-shaped, not that another patch is owed. **What the eye sees:** the visible defect the
walker found (O-1) was a row cut by ~20 pt; the pins that catch THAT class — the return to your note, the shorter
window, the walker's road — went red on the old reveals (R-D: "row 20 hidden", "row 16 hidden") and are green now.
What remains is ≤ 2 pt, inside a row's own vertical padding at either pitch (the compact row is 24 pt, its text
~16 pt tall): no glyph is ever under it.

**RULED:** the rules' "half a point" (`SidebarLayout.fadeSlack`, private, 0.5) becomes ONE named, internal constant
**`SidebarLayout.edgeSlack = 3`** with its reason at the line — *an edge with less than this beyond it is AT that edge:
it does not fade, and a row within it of clear counts as clear (no reveal fires for it); 3 pt is inside the compact
24-pt row's vertical padding, so no glyph is ever under the remainder*. Both `edgeFades` and `revealOffset` read it;
the pins' tolerances read the SAME constant (never a literal 0.5). The untraced drift is recorded here as a known
residual of SwiftUI's post-transition settling — not pursued (invisible; a trace would be a rabbit hole with no
user value). **The orchestrator makes this change itself** (small, at adjudication); the stage window then runs the
93-suite batch and the mount suite **five times** (`-test-iterations 5`) as the flake's stability evidence; the
re-walk is the visual evidence.

#### U1b5 — THE WINDOW (run by the orchestrator, claim `vx283-u1b5` 22:12:27–22:16:19, RELEASED) and the TRACE LEG

**Result under `be4e4c0f` (the 3-pt slack):** the 93-suite batch — `✘ Test run with 413 tests in 93 suites failed after
87.910 seconds with 2 issues` (VX-245's lint; the Starred pin). The mount suite × 5 (`-test-iterations 5`): the Starred
pin red 4 of 5, resting at offsets **31.5 · 32 · 32 · 32.5** of 36 (bottom fade 3.5–4.5) — WIDER than under the 0.5-pt
rule (34–36). Dev store restored + cmp-verified, the suites' 9 added prefs keys deleted, the prefs diff clean (1602 =
1602), castle-W1 untouched, zero instances. Logs: `notes/plans/vx283-screens/u1b5/logs/`.

**Reading:** the shortfall GROWS with the slack — so it is not fixed-size settling noise; it is motion that keeps going
after the re-asks stop (a bigger slack stops them sooner). **P-U1b-8 was a guess and is REVERTED (`13e36041`).** The
orchestrator's best hypothesis, UNTRACED and offered to the trace only: the column's implicit `.animation(…railTransition,
value: railPostID)` animates the scrolling sections' FRAME heights too; the viewport shrinks over the beat with the top
held, each mid-animation reading re-asks only while the row is past the slack, and the last frames' small steps leave an
error the re-asks never see — while the settled backstop may read a stale `memory.window` if no reading arrives at the
end.

**THE TRACE LEG (P-5's friction doctrine, the hallucination guard):** five legs have chased this number with fixes built
ahead of a traced mechanism. No more fixes until the mechanism is traced. A FRESH implementer (trace-first) instruments
the Starred section in the mounted rig across the ninth star's open — every geometry reading (time, offset, viewport,
content), every reveal request and its trigger, the computed target, what `scrollTo` is called with, and every offset
change after the last reveal — establishes WHEN the geometry reaches its final values, WHETHER a reading arrives after
the transition, and WHAT moves the offset after the last reveal; then PROPOSES a fix with that evidence (candidates to
weigh, not to assume: the scrolling sections' frames taken OUT of the rail's implicit animation so their geometry
arrives once; the settled reveal forced to read fresh geometry; another the trace shows). The architect rules before
it is built. The instrumentation is DEBUG-only and is removed (or kept as an oracle) by the ruling.

### U1c — the trace leg

**Implementer:** a fresh Opus 5.5 at xhigh (2026-10-14, night), worktree `~/dev/variorum-vx-283`, DerivedData
`App/Variorum/DerivedData/vx283-u1`. **Not done by this session (first line, per the brief):** NO FIX is built — the
leg traces and PROPOSES; the architect rules before anything ships. Any stage work waits for the orchestrator's claim.

**LIVE STATUS (per piece)**
- T0 — this section: DONE (`3ffad691`).
- T1 — the headless offscreen probe (a standalone process, never-shown window; the column's implicit animation on the
  sections' frames and the 30 → 24 pitch flip, as the real column has them): DONE (`43a002dd`) — findings below ("T1 —
  WHAT THE PROBE ESTABLISHED"); the mounted rig's confirmation is T3's.
- T2 — the DEBUG-only instrumentation in `SidebarSectionWindow` (`SidebarSectionTrace`, a sink off by default: every
  reading, request + trigger, reveal + inputs + the anchor handed the proxy, settled check) + the env-gated harness
  `SidebarSectionWindowMountTests.traceTheNinthStarsOpen` (`TEST_RUNNER_VARIORUM_U1C_TRACE=1`; asserts nothing; the
  Starred pin's road with the trace, the pin's oracle per `SectionRig.settle`-shaped iteration, AppKit's frame /
  clip-bounds / document-frame notifications from Starred's scroll view, the moment the settle WOULD return, to 1.5 s):
  DONE (`43a002dd`) — headless `build-for-testing` green (`DerivedData/vx283-u1`), no new warning in a touched file.
  The only shipping-path change is two `StaticString` labels threaded through `requestReveal`/`reveal`. **Grown
  (`2e011d0f`):** the harness's UNDRIVEN twin `traceTheNinthStarsOpenUndriven` (no forced layout — the frames come
  from the display, as in use) and the PROPOSED pin `theNinthStarIsClearTheMomentTheBeatEnds` (env-gated
  `TEST_RUNNER_VARIORUM_U1C_PIN=1` until the ruling); `build-for-testing` green again, products in
  `DerivedData/vx283-u1`.
- T1b — the candidates measured in the probe (scratchpad copies only; nothing in the repo): DONE — below ("T1b").
- T3 — the stage window: **DONE** (claim `vx283-u1c` 22:40:31 → released 22:42:12, the coordinator's GO line) — it
  **CONFIRMS the probe on all four of the ruling's conditions** ("T3 — THE MOUNTED RIG'S FACTS" below).
- T4 — the proposal: RULED by the orchestrator (2026-10-14 ~22:40, conditional on T3 — met): **(c1), recorded as
  P-U1c-1** ("U1c — THE ORCHESTRATOR'S RULING" below).
- T5 — P-U1c-1 built: DONE (`6c8b0d37` code + pins; `4e8a5f08` the record — Q5 corrected, the oracles' disposition)
  — headless `build-for-testing` green, no new warning in a touched file; the pure pin's arithmetic checked headless
  against the real `SidebarLayout.swift` (all 8 cadences land 36; the R-H patch ends short at 7 of 8); the probe on the
  ruled modifier: the mounted pin's logic GREEN 3/3, the rig-settle replica reads 36 3/3, 4 backstop timers a beat
  (the discrete requests) where there were 23–36. Write-up below ("T5 — P-U1c-1, AS BUILT"). The mounted runs are T7's.
- T6 — R-H + R-H′ prebuilt: DONE — each patch (`notes/plans/vx283-screens/u1c/reverts/R-H.patch`, `R-Hp.patch`,
  gitignored) applied, built into `DerivedData/vx283-u1c-rh` / `-rhp` (both TEST BUILD SUCCEEDED), restored by
  `git checkout --` from `4e8a5f08`; **no revert is in the tree** (`git diff` empty). R-H = `readingAsk`'s viewport arm
  back to `abs(new.viewport − old.viewport) > 0.5` AND the modifier's `.revealNow` back to `requestReveal("viewport")`
  (HEAD's arm whole — why, in "T5 — P-U1c-1, AS BUILT"); R-H′ = the threshold only. `DerivedData/vx283-u1` rebuilt
  headless from HEAD (green, no new warning in a touched file).
- T7 — the closing window: **DONE** (claim `vx283-u1c2` 23:00:00 → released 23:06:36, the coordinator's GO line;
  products at `7513cec4` = `6c8b0d37`'s code; logs `notes/plans/vx283-screens/u1c/logs/t7-*.log`, gitignored):
  1. **The batch** (93 suites, `test-without-building`): **"✘ Test run with 418 tests in 93 suites failed after 91.597
     seconds with 2 issues."** Skipped: the two env-gated U1c harnesses only. (a) VX-245's lint
     (`ChromeLineLimitTests.everyBareFixedSizeStatesItsLinePolicy`, `ChromeLineLimitTests.swift:104`) — expected, U3's.
     (b) **UNEXPECTED — `OpenListCloseShellTests.theMenuActsLandThePaneThroughTheShell` (`OpenListCloseTests.swift:479`):
     "Expectation failed: router.workspace.openNotes.ids == [a.id, b.id, c.id]" — observed `[…0000, …0002, …0001]`,
     i.e. the order [a, c, b]** where [a, b, c] was expected. **Green 3/3 alone** in the same window
     (`-only-testing:VariorumTests/OpenListCloseShellTests -test-iterations 3`: "✔ Test run with 1 test in 1 suite
     passed"). A FLAKE in U1's own pin — ours to fix, in the leg after the walk (the orchestrator's word). First
     suspicion, untraced: the shell's open-notes order seeded from persisted state (`openNotes.remembered.*`) shared
     through the test host's REAL `UserDefaults` with another suite of the batch. P-U1c-1 touches no workspace code.
  2. **The mount suite ×5:** **"✔ Test run with 9 tests in 1 suite passed after 59.561 seconds"** — the seven ungated
     tests green in all five iterations (the Starred pin, the walker's-road pin and the new mounted pin among them);
     the two harnesses skipped. SwiftUI's `[Invalid Configuration]` lines: 70 across the five iterations (T3: 196 over
     three with the harnesses) — not grown.
  3. **R-H** (HEAD's viewport arm whole), Rule + Mount suites ×3: **red as named** —
     `anEasedShrinkEndsWithTheRowExactlyAtTheEdgeAtEveryCadence` RED 3/3 (7 issues each: 7 of 8 cadences),
     `aReadingAsksOnlyWhatMovesTheRow` RED 3/3 (the 0.002-pt step), `theNinthStarIsClearTheMomentTheBeatEnds` RED, the
     Starred pin RED 1 of 3; the walker's-road pin green. Final line "✘ Test run with 23 tests in 2 suites failed after
     36.428 seconds with 18 issues" (the last repetition's count).
  4. **R-H′** (the threshold only), ×3: the two pure pins RED 3/3; the mounted pins GREEN 3/3 — as predicted (the
     commit-scheduled backstop lands the row ≈40–60 ms after the beat, before the mounted pin's window): the pure pin
     is the deterministic red-on-old proof, the mounted pin the use-shaped one.
  5. **Restore:** the dev store's three files byte-identical before the copy-back, copied back from
     `store-before/`, `cmp`-verified each; prefs: 9 keys ADDED (`currentBlock.*` ×5, `surfaceSize.outline.*` ×4 —
     deleted), 2 CHANGED (`variorum.backup.log`, `IdleCommitSweepMark.Variorum-dev`) — import, re-export, diff CLEAN
     (1602 = 1602); `castle-W1-20261013` untouched; zero dev instances throughout; `DerivedData/vx283-u1c-rh` and
     `-rhp` deleted, `vx283-u1` kept for the walker.
- **U1c CLOSED for its acceptance (P-U1c-1 built, pinned red-on-old, the mount suite 5/5).** Open, owned: the
  `OpenListCloseShellTests` batch flake (the leg after the walk); the walk itself (the walker's).

**T1 — WHAT THE PROBE ESTABLISHED** (scratchpad `u1c-probe/`: `main.swift` compiled with the REAL
`Core/Views/SidebarLayout.swift` and the instrumented REAL `Features/Library/SidebarSectionWindow.swift`, the app's own
Swift flags — Swift 6, default isolation MainActor, approachable concurrency, `-D DEBUG`; a column mirroring
`SidebarView`: Starred's 9 rows, the 5 areas, the rail inserted with `.transition(.opacity)`, the Open list with VX-285's
two measurements, the fit test's pitch, the column's implicit `.animation(.easeInOut(duration: railTransition), value:)`;
900-pt window, 3 → 4 open rows; the flip is ONE plain mutation, as `workspace.select` is. Each section's scroll view is
an AppKit `HostingScrollView`; the probe observes its frame, clip bounds and document frame by notification):
1. **The content height jumps ONCE at the commit** (270 → 222 → 216 inside 5 ms — the rows re-laid at 24). **The
   viewport moves FRAME BY FRAME through the beat** (225 → 224.936 → 224.855 … → 180.000 over ≈0.24 s; the
   `HostingScrollView`'s frame steps on the 0.5-pt pixel grid beside it), **its top held** (the clip origin does not
   move with it).
2. **The three reveals at the commit (`content`, `current`, `rowHeight`) all answer NONE:** the window they read is
   still 225 tall, so the ninth row (192…216) stands clear in it. Nothing has to scroll until the shrinking viewport
   passes the row's bottom.
3. **Re-asks fire only on readings whose viewport step since the PREVIOUS reading exceeds 0.5 pt** (the trigger's
   `abs(new.viewport − old.viewport) > 0.5`). An ease-in-out's first and last frames step less than that; only the fast
   middle re-asks. Each re-ask lands the row at the end of THAT frame's viewport (anchor 1.0, the offset rounded to the
   0.5-pt pixel grid), and the next frames keep shrinking the viewport under the fixed offset. **After the last re-ask,
   nothing moves the offset: the viewport's tail (all steps < 0.5 pt) shrinks under it, and the row ends cut by the
   tail's sum** — 15 pt at a fine 2-ms forced-layout cadence (offset 21 of 36); at the rig's cadence (its settle loop's
   forced layout every ≈30 ms) **31 · 34.5 · 35** of 36 in three runs — the mounted rig's own spread (34–36; and under
   the 3-pt slack 31.5–32.5, because a bigger slack makes more of the middle's re-asks answer NONE, so the last
   effective one comes earlier).
4. **A reading DOES arrive at the end** (`vp 180.002 → 180.000`, then an unchanged reading), and **the settled
   backstop reads that FRESH final window and lands the row EXACTLY** (target 36, anchor 1.0 → offset 36) — in every
   probe run. It fires `transitionSettle` (0.30 s) after the LAST request, i.e. ≈0.45–0.5 s after the commit.
5. **The rig's red is a RACE, reproduced:** a verbatim replica of `SectionRig.settle(minimum: 0.5)` (five unchanged
   iterations AND half a second) returned at **0.517 s reading offset 34.5** in run 2 — and the backstop fired **0.2 ms
   later** and landed 36; in runs 1 and 3 the backstop fired first (the settle returned at 0.735 s, reading 36). So the
   pin reads before or after the backstop by chance: Q9's green (R-F) and Q11's red on the SAME code are this race.
   In use there is no early reader: the row sits cut for ≈0.2–0.3 s after the beat, then snaps (unanimated) into place.

**T1b — THE CANDIDATES, MEASURED IN THE PROBE** (scratch copies of the modifier or the column; `cut` = 216 − (offset +
viewport) over the ninth row, read from every reading; an AppKit 1-ms poll of a marker heading the areas group gives
where the groups below Starred actually ARE, frame by frame):
- **(a) Starred's frame chain OUT of the implicit animation** (`.transaction { $0.animation = nil }` after its
  `.fixedSize`): the viewport jumps 225 → 180 in ONE reading; all three commit-time reveals answer target 36 and the row
  lands at once. **The visual cost, measured:** Starred's bottom snaps 269 → 224 at the commit while the areas below
  glide 288 → 243 over the beat — a band opening to **64 pt** (the separator's 19 + 45) under Starred and closing over
  0.22 s: the section SNAPS while everything under it eases (row 24's sidebar half: *"nothing on the left ever
  snaps"*). Also seen in that run, unexplained: the section's content settled at **221**, not 216 (the lazy stack's
  estimate for its once-unrealized ninth row surviving the un-animated pass) — 5 pt of content below the last row, so a
  bottom fade would draw.
- **(b) the settled reveal forced to read fresh geometry:** the trace shows it ALREADY does — a reading arrives at the
  beat's very end (`vp 180.002 → 180.000`), the backstop reads it and lands exactly. Its defect is its TIMING (0.30 s
  after the last request, ≈0.2–0.27 s after the beat ends), not its input. (b) would change nothing.
- **(c1) the viewport arm of the trigger re-asks on EVERY reading whose viewport differs** (`new.viewport !=
  old.viewport` in place of `abs(new.viewport − old.viewport) > 0.5`; nothing else changed): the row lands at exactly
  **36 on the beat's final reading**, 1–2 ms after it (+0.227…0.247 s), in **4/4 runs** at both the rig's cadence and
  the fine one — before the backstop and before the rig's settle can return. Mid-beat it trails the shrink by ONE
  reading (a reading shows the shrink before that reading's reveal lands): transient cuts of 1.25–7.4 pt at the probe's
  irregular cadence; at a display's 120 Hz one mid-ease frame steps ≈2–3.5 pt.
- **(c4) `.defaultScrollAnchor(.bottom, for: .sizeChanges)`** (the scroll view holding its bottom on a resize): does
  NOT hold through the animated resize — cut 4.5 and 12.5 pt at the beat's end. Rejected.
- **The proposed pin's logic, run in the probe** (forced layout + 4-ms turns for 1 s; the row must stand where it
  settles 100–150 ms after the viewport reaches its settled height): **HEAD RED 4/4** (offsets 22–28.5 standing there);
  **(c1) GREEN 4/4**.

**T3 — THE MOUNTED RIG'S FACTS** (2026-10-14 22:40–22:42, products at `57d7911d`'s code; `TEST_RUNNER_VARIORUM_U1C_TRACE=1
TEST_RUNNER_VARIORUM_U1C_PIN=1 xcodebuild … test-without-building -only-testing:VariorumTests/SidebarSectionWindowMountTests
-test-iterations 3`; log `notes/plans/vx283-screens/u1c/logs/t3-mount-x3.log`, gitignored): **"✘ Test run with 9 tests
in 1 suite failed after 48.513 seconds with 13 issues"** — no skipped tests (the env gates opened). Per repetition:
`returning…` ✔✔✔ (resting 248.98 · 249.07 · 249.09 of 249), `aShorterList…` ✔✔✔, `aCloseNoteLanding…` ✔✔✔,
`theOpenListFades…` ✔✔✔; **`aNewNoteOpenedFromThePlaces…` ✔✘✘** (the Open list's window ends at 599.41 / 599.34 of 600 —
bottom fade 0.59 / 0.66: the same tail on the Open list, which earlier windows saw inside the slack); **the Starred pin
✘✘✘** (offsets 34 · 35 · …); **the proposed pin ✘✔✘** (rep 1: offset 34.5 standing from +0.361 to +0.404 s, the beat
ended at +0.261 s, the window settles at 36); both harnesses ✔ ×3 (they assert nothing). Six traces (three driven by
`SectionRig.settle`'s forced layout, three UNDRIVEN — frames from the display only):

| run | viewport changes in the beat (≤ 0.5 pt) | AppKit frame cadence | last effective re-ask | offset when the beat ends (vp 180.000) | settle would return | backstop fires → lands |
|---|---|---|---|---|---|---|
| 1 driven | 38 (6) | 6.1 ms | +0.260 s at vp 180.238 → target 35.76 | **36** (cut 0 — the lucky case) | +0.508 s | +0.567 s → NONE |
| 2 driven | 48 (14) | 5.0 ms | +0.234 s at vp 181.483 → 34.52 | **34.5** (cut 1.5) | +0.512 s | +0.546 s → 36 |
| 3 driven | 47 (18) | 5.2 ms | +0.224 s at vp 182.843 → 33.16 | **35** (cut 1.0) | +0.527 s | +0.550 s → 36 |
| 4 undriven | 53 (14) | 4.4 ms | +0.235 s at vp 181.168 → 34.83 | **35** (cut 1.0) | +0.529 s | +0.546 s → 36 |
| 5 undriven | 49 (15) | 5.0 ms | +0.234 s at vp 182.049 → 33.95 | **34** (cut 2.0) | +0.506 s | +0.550 s → 36 |
| 6 undriven | 49 (15) | 5.0 ms | +0.243 s at vp 181.131 → 34.87 | **35** (cut 1.0) | +0.505 s | +0.552 s → 36 |

- **(1) per-frame viewport readings through the beat — CONFIRMED:** 38–53 viewport changes per beat, every AppKit frame
  (4.4–6.1 ms) reported, driven or not; the content jumps once at the commit (270 → 222 → 216, as in the probe — the 222
  is eight rows re-laid at 24 beside the ninth, unrealized row still estimated at 30); the three commit-time reveals
  answer NONE against the still-225-tall window.
- **(2) a final reading at the end — CONFIRMED:** every run reads `vp 180.000` as the beat's last frame, and the settled
  backstop reads that fresh window (`off 34.5 vp 180 → target 36`) and lands exactly. **Q5's claim that "once the
  animation ends no reading arrives" is REFUTED for this road** (corrected at Q5 below).
- **(3) the proposed pin red on HEAD — CONFIRMED:** red 2 of 3 in its own runs; red exactly when the tail manifests —
  5 of the 6 traces ended the beat 1–2 pt short. The one exact landing (run 1) is the predicted lucky case: a ≥ 0.5-pt
  final step whose re-ask computed at vp ≤ 180.25, so the pixel grid rounded its target (35.76) up to 36.
- **(4) the race — CONFIRMED, and lopsided in the mounted rig:** `SectionRig.settle` would return at +0.505–0.529 s and
  the backstop fires at +0.546–0.567 s (the last request + ≈0.31 s) — AFTER the settle in all six runs; the Starred pin
  therefore reads the pre-backstop offset every time (red 3/3 here; Q9's lone green is run 1's lucky landing or a
  slower settle).
- **Undriven = in use:** the display-only runs (4–6) show the same tail (cut 1–2 pt for ≈0.28 s, then a 1–2-pt snap),
  so what she sees is a small, brief cut and a hop; the rig's forced layout changes nothing material.
- **Observed, not this leg's:** SwiftUI logs `[Invalid Configuration] <OnScrollGeometryChange Modifier> tried to update
  multiple times per frame` (28) and `Geometry action is cycling between duplicate values` (168) — ≈10 per Starred
  mount, 26–42 on the walker's-road test. **Pre-existing:** every earlier window's log carries them, R-D's (the pre-U1b
  reveals) included (34). Untraced; the closing window checks that (c1) does not grow the count.
- **Restore:** the dev store's three files byte-identical before the copy-back (the test host writes no store), copied
  back from `store-before/` and `cmp`-verified each; prefs: none added, 2 CHANGED (`variorum.backup.log`,
  `IdleCommitSweepMark.Variorum-dev`) — `defaults import`, re-export, diff CLEAN (1602 = 1602); `castle-W1-20261013`
  untouched; zero dev instances throughout.

#### U1c — THE ORCHESTRATOR'S RULING (2026-10-14 ~22:40 — P-U1c-1, conditional on T3; the condition met)

*Verbatim in substance from the orchestrator's GO message:* if T3 confirms the probe (per-frame viewport readings
through the beat, a final reading at the end, the proposed pin red on HEAD, and the race), build **(c1)**, recorded as
**P-U1c-1**: the viewport re-ask fires on ANY change of viewport (`new.viewport != old.viewport`). **Sub-call 1 — the
backstop: KEEP it, scheduled only by the DISCRETE triggers** (the current row, the content height with P-U1b-7, the row
height, the mount's first reading). **Sub-call 2 — the per-frame viewport re-ask calls `reveal()` DIRECTLY** (no
backstop Task per frame). Ungate `theNinthStarIsClearTheMomentTheBeatEnds`. Add the clock-free pure pin (the trigger as
a `SidebarLayout` decision run through a simulated eased shrink on the 0.5-pt grid; red on the old 0.5-pt step rule,
green on any change). Correct the record's Q5 claim. The trace sink and the two harnesses: kept DEBUG/env-gated as
oracles if cheap and tidy, else removed — the implementer's call, recorded. Then rebuild headless, prebuild **R-H** (the
trigger back to `abs(…) > 0.5`; expected red: the ungated pin and the pure pin), commit and push per piece, and end at
READY FOR STAGE for the closing window (the 93-suite batch + the mount suite `-test-iterations 5` + R-H + the restore;
expected: only VX-245's lint red in the batch, the mount suite 5/5 green, R-H red as named).

**T5 — P-U1c-1, AS BUILT** (`6c8b0d37`):
- `Core/Views/SidebarLayout.swift`: **`ReadingAsk`** (`none` · `revealNow` · `request`) and the pure
  **`readingAsk(old:new:rowsChanged:)`** — a content change > 0.5 pt under an unchanged row count is a DISCRETE
  `request` (the pitch flip; P-U1b-7's guard kept); otherwise ANY viewport change is `revealNow`; an offset-only change
  (her scroll) is `none`. The F-1 comment's stale "applied absolutely" (withdrawn at Q10) now says "landed through the
  section's proxy".
- `Features/Library/SidebarSectionWindow.swift`: the geometry action asks `readingAsk` — `request` → `requestReveal`
  (reveal now + the settled backstop), `revealNow` → `reveal` DIRECTLY (sub-call 2: no backstop Task per frame); the
  mount's first reading stays a request before it. The backstop is scheduled only by the DISCRETE requests (sub-call
  1): the current row, the content height, the row height, the mount. The header comment says so (and loses a broken
  half-sentence a previous edit left behind).
- **The oracles — KEPT (the implementer's call, per the ruling):** the DEBUG `SidebarSectionTrace` sink (off unless a
  pin or a probe installs it; its notes are autoclosures, so an off sink builds no string; compiled out of Release) and
  the two env-gated harnesses (`traceTheNinthStarsOpen` / `…Undriven`, `TEST_RUNNER_VARIORUM_U1C_TRACE=1`) — they are
  what settled this after five legs, they cost nothing in a batch (gated off), and the next change to the beat or the
  trigger can re-run them with one variable. The shipping path keeps only the two `StaticString` labels.
- **Pins:** `SidebarSectionWindowRuleTests.aReadingAsksOnlyWhatMovesTheRow` (the decision's cases) and
  **`…anEasedShrinkEndsWithTheRowExactlyAtTheEdgeAtEveryCadence`** — CLOCK-FREE: the content re-laid in one step (216),
  the viewport easing 225 → 180 over `railTransition` (smoothstep) with its top held, every reveal on the 0.5-pt grid,
  at cadences 2 · 3 · 4 · 5 · 6 · 8.33 · 10 · 16.67 ms; on P-U1c-1 the ninth row ends at 36 at all eight; on the old
  rule (R-H) it ends at 27 · 32.5 · 34.5 · 34.5 · 35.5 · 35.5 · 35.5 · 36 — red at seven (checked headless against the
  real `SidebarLayout.swift`, the R-H line patched in a scratch copy). **`SidebarSectionWindowMountTests.
  theNinthStarIsClearTheMomentTheBeatEnds` UNGATED** (now on `rig.pump`, `SectionRig`'s own turn, made file-visible).
- **R-H's shape, and a deviation stated:** the ruling names R-H as "the trigger back to `abs(…) > 0.5`; expected red:
  the ungated pin and the pure pin". Under sub-call 2 a threshold-ONLY revert would leave the backstop scheduled by the
  commit-time discrete requests alone — it then fires at the commit + 0.30 s, ≈40–60 ms after the beat ends, and lands
  the row BEFORE the mounted pin's 100–150-ms window, so the mounted pin would read green for a reason that is not the
  fix. **So R-H restores HEAD's viewport arm WHOLE** — the 0.5-pt step threshold in `readingAsk` AND the viewport arm
  scheduling its backstop (`requestReveal`) — the trigger exactly as it stood; both pins red. The threshold-only
  variant is prebuilt beside it as **R-H′** (expected: the pure pin red, the mounted pin observed — likely green, by the
  mechanism just stated), so the window shows which pin is the deterministic one.

**T4 — THE PROPOSAL (DRAFT — PENDING T3's mounted confirmation; nothing built):**
- **The traced mechanism, in one breath:** the rail's implicit animation delivers Starred's 45-pt viewport shrink as a
  stream of per-frame readings with its top held; the trigger re-asks only when ONE reading's viewport step exceeds 0.5
  pt, so the ease's slow tail — every step below that — shrinks the viewport under an offset nothing moves again, and
  the row ends the beat cut by the tail's sum; the settled backstop lands it exactly but 0.30 s after the last request,
  which is after the rig's settle can return (the flake) and, in use, a visible ≈0.2–0.3-s cut followed by a snap. The
  3-pt slack widened it because a bigger slack makes more of the middle's re-asks answer NONE.
- **RECOMMENDED — (c1):** the viewport arm re-asks on every reading whose viewport differs at all (the content arm and
  its unchanged-count guard, P-U1b-7, stay). The 0.5-pt step threshold protected nothing a viewport change can do: her
  scroll moves only the offset (still never a re-ask); `revealOffset` is idempotent (nil while the row is clear), so a
  re-ask per frame scrolls only while the row is actually cut; P1 holds (O(rows) per reading, rows ≤ the Open cap 20 /
  the star cap, ≈25–60 readings a beat). Effect: the row rides the shrinking edge through the beat (one reading behind)
  and stands exactly at the edge when the beat ends. The Open list shares the modifier, so its own tail (the
  248.58…249.33-of-249 landings in U1b's windows) goes too. **Two sub-calls for the architect:** (i) the backstop —
  keep it as ruled (P-U1b-5; in this road it then reads clear and does nothing), or retire it (the trace shows the
  beat's final reading DOES arrive, refuting Q5's "no reading arrives after the transition" for this road — T3 to
  confirm in the mounted rig); (ii) every viewport re-ask today goes through `requestReveal`, so (c1) schedules one
  sleeping backstop Task per frame of the beat — keep (cheap, superseded by the episode counter), or let the viewport
  arm call `reveal` directly.
- **Not recommended:** (a) — exact, but the section snaps while the column eases (the 64-pt band) and the content
  settled 5 pt long in the probe; (b) — addresses nothing; (c4) — does not hold.
- **The pins:** (1) **`SidebarSectionWindowMountTests.theNinthStarIsClearTheMomentTheBeatEnds`** — WRITTEN, env-gated
  until the ruling (the fix's commit removes the gate): RED on HEAD, GREEN on (c1) in the probe 4/4 each; red-on-old by
  reverting the trigger's one line. (2) To write with the fix — a PURE pin: the trigger as a `SidebarLayout` decision,
  driven through a simulated ease-in-out shrink (top held, the 0.5-pt pixel grid AppKit rounds the offset to), asserting
  the row ends exactly at the edge — deterministic, no clock; red under the revert to the consecutive-step rule. (3) The
  existing `starredFadesWhereMoreLiesBeyondAndNowhereWhenItHoldsEverything` stops flaking: the landing (≈+0.25 s)
  precedes the rig's settle's ≥ 0.5-s return.

#### U1c — the batch flake (`OpenListCloseShellTests.theMenuActsLandThePaneThroughTheShell`) — TRACED; STOPPED (a product-side race in the shell's adoption road, not test hygiene)

**Not done (first line):** no pin and no fix. The mechanism lives in `RootView`'s `pendingSelection` adoption, the
ShellRouter seam (VX-284's lane), so the leg stops and reports per the orchestrator's rule. Headless trace only, no
stage used.
- **The suspicion, tested and REJECTED:** under the test host the shell never restores or writes the remembered strip.
  `RootView.swift:532-535` returns before `restoreRememberedOpenNotes`, so `remembersOpenNotes` stays false and
  `rememberOpenNotesIfClaimed` writes nothing (`WorkspaceModel.swift:603-606`). No real-`UserDefaults` road reaches
  this shell's order.
- **Cross-suite broadcasts, checked and RULED OUT for this run:**
  - The two global roads exist and are real hazards:
    - `.variorumNotesDeleted` → `workspace.notesDeleted` closes rows (`RootView.swift:482-485`, `WorkspaceModel.swift:491-498`).
    - `.variorumOpenPost` overwrites `pendingSelection` (`:459-462`).
  - A test `RootView` gets its own private `WindowRegistry` (`RootView.swift:172`), so it claims EVERY global
    navigation broadcast. `TwoWindowMountTests` posts `.variorumOpenPost` for an `.incrementing` id …0001
    (`WindowsTests.swift:385-386`), and the `NoteDeletion` suites post …0000.
  - But the batch log shows NO other test running during the flaky test's 5.551 s (`t7-batch.log`, lines 647–659:
    suites ran one at a time), and neither broadcast can produce [a, c, b].
- **The mechanism (by elimination, strongly corroborated):**
  - `WorkspaceModel.select` appends the row itself (`WorkspaceModel.swift:199-203`, `OpenNotes.opened` appends once),
    so the strip's order IS the order of `select` calls. [a, c, b] therefore means b's `select` never ran at its step.
  - The road is `RootView.swift:441-445`: `.onChange(of: router.pendingSelection) { adopt(pending…);
    router.pendingSelection = nil }`. The action writes the very value it observes.
  - The test (`OpenListCloseTests.swift:473-478`) writes the next request the moment the previous adoption is visible,
    which can fall in the SAME frame as that re-entrant update. SwiftUI then refuses the extra invocation.
  - The red run's log carries exactly that warning, 65 ms in: `[Invalid Configuration] onChange(of:
    Optional<SidebarSelection>) action tried to update multiple times per frame`.
  - b's request is LOST, and `pendingSelection` stays `.post(b)` (nothing nils it), so b's settle times out after
    300 × ≈15 ms ≈ 4.5 s — the run took 5.551 s against 0.55–1.6 s when green.
  - The test then requests c: an `onChange` (b → c) adopts c, giving [a, c]. Then `= b` adopts b, giving [a, c, b].
- **The correlation:** the red run has the warning once. Six green runs of the same test have zero (T7's alone ×3;
  the batches of U1b's Q6, Q9 and Q11, U1b's first window, and U1b5's).
- **Product reach:** a request lost this way also leaves `pendingSelection` STUCK on its destination, so a later door
  asking for the SAME destination changes nothing SwiftUI can see. That stays true until some other destination is
  asked for. The doors that write `pendingSelection`: ⌘⇧W / Close All's menu acts (VX-287/289, this run's), ⌘⇧1–9, the
  creation acts (⌘N/⌘J/the tutorial), the palette, `.variorumOpenPost`. A human can hardly land two writes inside one
  frame; code can (a door writing right after an adoption, a broadcast beside a door). Latent. No report from her.
- **Options (for the orchestrator; none built):**
  - (a) **Product fix in the adoption road** — VX-284's lane, or a ticket: requests carry a distinct token, or the
    router hands requests to the shell's adoption directly rather than through an `onChange` that writes its own
    observed value. The test then passes as written.
  - (b) **Test-side only, in our lane:** the pin waits a display frame (or until the shell has seen `pendingSelection
    == nil`) before issuing its next request. This hides the race rather than fixing it.
  - (c) Both: (a) as a ticket, (b) now so the batch stops flaking.
  - **The deterministic pin, either way:** a mounted `RootView` whose observer of `workspace.focusedSelection` writes
    the next `pendingSelection` inside the same update that adopted the previous one. Red when the request is lost
    (b never adopted, `pendingSelection` stuck). Unbuilt.

#### U1c — the orchestrator's ruling on the batch flake (2026-10-14 ~23:20)

Ruled **(c)**: the PRODUCT race is real (traced, latent) and outside this run's lane — **VX-360** filed (Bug, Confirmed,
Medium, *v1 release readiness*, related VX-284/VX-287; fix shape and deterministic pin in the ticket). The test-side
half is done by the orchestrator (`OpenListCloseTests.settleAdoption`: wait until the pane shows the target AND the
shell has cleared its request, then a frame, before the next request) — the pin's subject is the landing ORDER, not the
race. Evidence owed: the shell pin + the suites that ran around it in the batch, on a short window after the walk.

#### U1 — THE DESIGN MEMO (P-5, the friction doctrine; 2026-10-15 ~00:15, after the re-walk)

**Why a memo:** the sidebar's scrolling sections have had six fix legs since U1's walk (F-1's reveal, F-2's fade, the
settle beat, the withdrawn absolute road, the reverted slack, the every-reading re-ask). The re-walk (record above)
holds on every row but two: **R6 — her own scroll is pulled back** (three times, seconds after a hand scroll, no input)
and **R4/O-2/O-3 — the fade's SHAPE** (a shallow fade over a few points reads as a slice through the letters; a partial
row hidden under the fade's solid outer half leaves an empty band above the footer with no "there is more"). The
orchestrator's eye on `R2b-study-light.png` (the middle state — reads right), `R4-repro-study-dark-zoom-bottom.png`
(the slice) and `R5a-19-study-light-zoom-bottom.png` (the empty band) agrees. Repeated patches mean the feature's
behaviour was never written whole — so here it is.

**THE BEHAVIOUR, WHOLE (proposed):**
1. **When the list moves by itself — FOLLOW, not every change.** The list FOLLOWS the current note after a discrete
   act — a note opened, a landing (⇧⌘W, ✕, Close All, back/forward), the section's first appearance. While following,
   anything that moves the row (the rail's beat, the pitch flip, a resize, content changing) keeps it wholly in view
   (P-U1c-1's every-reading re-ask). **The moment she scrolls by hand, following stops**, and nothing moves the list
   again until her next discrete act. Detected from the scroll view's own phase (a hand scroll is `.interacting` /
   `.decelerating`; the app's reveals are not). This supersedes P-U1b-2's "including a window resize after she
   scrolled away" — the root of R6. Her principle wins: never pulled back.
2. **The edges — her taste call (three shapes):**
   - **(A) The fade, reshaped:** the full half-row depth whenever more than a hair lies beyond (never a shallow
     few-point fade — O-2), its STRENGTH easing in over the first few points of scroll instead of its depth (so it
     still doesn't pop), and never fully solid at the very edge (a hint of the partial row always shows — O-3).
   - **(B) Whole rows, no fade:** scrolling snaps to row boundaries, so no row is ever cut under a header; the
     bottom keeps a half row as the "there is more" signal (Starred's own 7½ idiom).
   - **(C) The plain clip, as before U1:** no fade (Starred has looked this way since 13u2; F-2 was the
     orchestrator's critique, not hers). Lowest risk.

Asked of her at this memo; the build follows her answers (U1d). U3 runs meanwhile (independent surfaces).

### U3 — the Library and the red lint (VX-121 · VX-175 · VX-20 · VX-245 · VX-359)

**Implementer:** Opus 5.5 at xhigh (fresh session, 2026-10-15). Worktree `~/dev/variorum-vx-283`, DerivedData
`App/Variorum/DerivedData/vx283-u3`. **Not done by this session (the record's first line, per the brief):** the
screenshot walk (a fresh walker's); any stage work until the orchestrator hands over a claim; VX-175's build until
the orchestrator rules on its composition (below — the brief's composition does not fit the window the ticket names).

**LIVE STATUS (per piece)**
- Q1 — VX-245 (the six bare `fixedSize` sites): DONE (`21c28027`) — the lint's offenders confirmed on the tip
  `3fa8ebd6` by a line-for-line replica of `everyBareFixedSizeStatesItsLinePolicy` (90 sites, exactly the six the
  record names; the two MCP sites already gone, VX-281); each now states `.lineLimit(1)` (all six are labels — no
  prose site among them); the replica reads 0 offenders. The lint itself (the red-to-green pin, red on the tip by
  its own batch 418) — PENDING the stage window.
- Q2 — VX-359 (the View menu's trailing `Divider()`): DONE (this commit) — F-3's trace re-verified on this tip: the
  note group `CommandGroup(before: .toolbar)` ended with `Divider()` after Close Split (`EditorCommands.swift:1023`,
  `07d9f583`), and SwiftUI adds its own separator at the boundary to the next group (Toggle Sidebar's), so two drew
  back to back. Deleted, with a comment at the line. **Class sweep:** every `CommandGroup`/`CommandMenu` in the file
  read for a leading or trailing `Divider()` at its own level — none other (the Lock Library Now and Find dividers
  sit INSIDE their groups, before an item). **Pin:** `ViewMenuSeparatorTests.theViewMenuHasNoDoubledOrDanglingSeparators`
  (new) — reads the REAL View menu in the test host (the `AppMenuServicesTests` precedent: owner rebuild + validate,
  hidden items dropped, the menu printed), no doubled / leading / trailing separator, and it reached Close Split.
  RED ON OLD planned as **R-V** (the `Divider()` restored after Close Split) — PENDING the stage window, as is its green.
- Q3 — VX-121 (toasts clear of the quick-entry band): DONE (this commit) — headless build-for-testing green.
  **The trace (this tip):** the shell's one host was `RootView`'s `paneRow.overlay(alignment: .bottom) {
  StatusToast(…).padding(.bottom, 46) }` (`RootView.swift:262-272` before) — a fixed 46 pt above the pane row's foot.
  The Bookcase's foot is the ⌘K hint bar (≈26 pt, `ShelfView.hintBar`) with the quick-entry band directly above it
  (`ShelfView.swift:238`; the bar is `QuickEntryBar` — the dashed box, 12-pt inner and 10-pt outer air ≈ 64 pt), so
  the band spans ≈26–90 pt above the foot and the card resting at 46 pt sits ON the box. The Library's identical bar
  sits at ITS foot (`LibraryCatalogView.swift:225`, 0–64 pt) — covered the same way. **The fix — a rule the host
  reads:** `StatusToastPlacement.bottomInset(hostHeight:keepClearTops:resting:)` (pure, `Registry/StatusToast.swift`)
  = the resting 46 pt, or just above the highest kept-clear band (8-pt clearance), never lower than resting; a band
  marks itself with `statusToastKeepClear()` (an anchor preference); the host is ONE modifier,
  `statusToastHost(_:tokens:resting:)` (`overlayPreferenceValue` → a `StatusToastLayer` view that alone re-renders
  as toasts come and go), which `RootView` now uses in place of the fixed overlay. `QuickEntryBar` marks its WHOLE
  band (box, title chip, refusal line, air). Same horizontal centre as before (the overlay's own). The note-only
  window's host (`NoteWindowView`, resting 24 pt) is untouched — it never draws a quick-entry band.
  **PROVISIONAL P-U3-3 (mine):** the marker sits on the shared `QuickEntryBar`, so the LIBRARY's band is kept clear
  too, not only the Bookcase's — the ticket's class ("any toast … collides with the quick-entry band") on the one
  component that draws it. Options: (a) the band marks itself — both surfaces [built]; (b) the Bookcase's bar only
  (the Library's toasts keep covering its box); (c) a per-surface host inset (rejected — the ruling's "never a
  per-toast offset"). **Pins:** `StatusToastPlacementRuleTests` (pure ×5, guards) and `StatusToastPlacementShellTests`
  (a mounted `RootView` in a 1240 × 800 window, a refusal up, the card read against every kept-clear band in one
  `.global` space through `StatusToastOracle` — DEBUG, owner-keyed by the 18k C4 rule: the card on the Bookcase and
  on the Library sits ABOVE its band (clearance kept, not floating) at the band's centre; on a note it rests at 46
  pt). **RED ON OLD planned as R-T:** `RootView`'s host line restored to the old fixed overlay (`.overlay(alignment:
  .bottom) { if let item = session.status.current { StatusToast(item: item, tokens: theme.tokens(for: scheme),
  onDismiss: { session.status.clear() }).padding(.bottom, 46) } }`) — expected RED: the Bookcase and Library cells;
  the note cell green. All PENDING the stage window.
- Q4 — VX-20 (the dark pinned heading): DONE (this commit) — headless build-for-testing green. **The trace:**
  `LibraryListHeader` (`Features/Library/LibraryListFace.swift:90-142` before) drew its PINNED background from
  `LibraryListHeaderMaterial` — an `NSVisualEffectView(.headerView, .withinWindow)` — in every appearance: the light
  parity (#FFFEFF beside the native header's, batch 1), a warm grey band (#2F2D29) in dark (the ladder record's
  § THE ONE FINDING). **The fix (her #188(m), the orchestrator's reading — option 2):** the colour source is ONE pure
  decision, `LibraryListHeader.pinnedFace(tokens:dark:)` — DARK → `.voice(fill: tokens.surface, hairline:
  tokens.line)`: the paper the List itself draws on (the catalog's `.background(tokens.surface)`) with the voice's
  hairline edge to edge at the header's foot, replacing the material, its shade and its shadow lines; LIGHT →
  `.material`, byte-for-byte the old face. The header reads the theme store + colour scheme from the environment
  (the call sites unchanged). No literal colour. **PROVISIONAL P-U3-4 (mine) — which voice colour is "the room":**
  `surface`, the colour the List draws on, because under a palette the dark paper carries the palette's hue (18g)
  while `room` stays black — so `room` would draw a BLACK band over a hued list, the defect again in another colour.
  Options: (a) `surface` [built]; (b) `room` (black in dark, as the ruling's words literally name it — identical to
  (a) only without a palette); (c) `card` (the old native heading's slightly-lighter look, #191B19 over #0D0E0D —
  a faint band kept on purpose). **Pin:** `LibraryListHeaderDarkFaceTests` (dark × both voices → the voice's paper +
  hairline; dark under the lavender palette → that palette's paper; light × both voices → the material, guards).
  **RED ON OLD planned as R-D:** `pinnedFace` answering `.material` in every appearance (the old face) — expected RED:
  the two dark cells ×2 voices; light green. **The rig's dark pass** (evidence, the brief's tool): `theFace` +
  `theFaceUnderManyBooks` under `TEST_RUNNER_VARIORUM_LIBRARY_LIST_FACE=1` + `…_APPEARANCE=dark`, once under R-D
  (label `before`) and once fixed (label `after`), the `BWALK|` log chunks reassembled into
  `notes/plans/vx283-screens/u3/rig/` — the geometry dump's "uniform horizontal runs" give the pinned band's rgb.
  All PENDING the stage window.
- Q5 — VX-175 (the controls row): DONE (this commit) — built to the orchestrator's ruling (76ccfc45: (C) on a
  one-identity `Layout`); headless build-for-testing green (the two `probeSpace` Sendable warnings in the build are
  pre-existing — the same two lines warn in this session's first build, before any VX-175 edit). **Built:**
  `Features/Library/LibraryControlsFlow.swift` (new) — `LibraryControlsFlowRule` (pure: `distribute`, the HStack's
  own least-flexible-first equal-share distribution; `fitsOneLine`, one line only if the line fits AND the field
  (child 0) keeps at least its ideal — its prompt's width; `arrange`, both arrangements, each line distributed as an
  HStack, left-aligned, children centred on their line) and `LibraryControlsFlow: Layout` (the field, scope, then
  mode · sort · when; it asks each subview for its narrowest, widest, ideal and per-width size, and places by the
  rule; `lineOneCount` 2). `LibraryCatalogView.header`'s controls `HStack(spacing: 10)` is now
  `LibraryControlsFlow(spacing: 10, lineSpacing: 8)` over the SAME views in the same order (no control's
  construction changed — the source-read pins on that file keep their strings); the field and the row gain DEBUG
  probes (`LibraryProbeSlot.searchField` / `.controls`, read as `LibraryPanelOracle.searchFieldFrame` /
  `.controlsFrame`). The minimum the row now reports is its WIDER LINE, never the sum, so the column no longer
  overflows into the panel. One honest note: the field's ideal is what SwiftUI reports for it — its prompt, in the
  harness; if a long typed query grows it, the row may re-flow while she types, keeping her caret (the reason for
  the one-identity layout). **Pins:** `LibraryControlsFlowRuleTests` (pure ×8, guards — wide = the HStack's widths;
  the field squeezed first; the decision; the 631-pt wrap with every frame; the wide one-line frames; 981 = one
  line; the ideal / minimum queries; Timeline's mode alone) and the geometry oracle `LibraryControlsGeometryTests`
  (the real catalog mounted at the default window's library width, 1029 pt, both voices): with the panel open the
  catalog and the panel's right edge stay inside the window, the row stays left of the panel's divider, the field
  keeps its prompt's width — **RED ON OLD planned as R-L** (`LibraryControlsFlow(spacing: 10, lineSpacing: 8) {` →
  `HStack(spacing: 10) {` in `LibraryCatalogView.header`); guards: panel closed at 1029 → one line, the field whole;
  1229 pt (a 1440 window) → one line, the field 320 at the header's 24-pt inset. All PENDING the stage window.
- Q6 — the stage window: **FIRST WINDOW RUN AND STOPPED** (claim `vx283-u3` 00:50:28–00:56:58, RELEASED; steps 0–1 of the
  plan below, then stopped on the orchestrator's rule — two unexpected reds, both in MY new pins). No revert ran.
  - **Step 1, the batch** (`test-without-building` on `vx283-u3`, tip `a4ef7665`, 187 suites; log gitignored at
    `notes/plans/vx283-screens/u3/batch.log`): **"✘ Test run with 1113 tests in 187 suites failed after 246.959 seconds
    with 2 issues."** Skipped (by design): the opt-in rig suite and the 18k C4 singleton-windows suite. GREEN among the
    rest: `ChromeLineLimitTests` (**VX-245's lint red→green** — red on the tip by batch 418), `ViewMenuSeparatorTests`,
    `StatusToastPlacementRuleTests`, `LibraryListHeaderDarkFaceTests`, `LibraryControlsFlowRuleTests` but one cell,
    `LibraryBulkRowGeometryTests`, and **`LibraryControlsGeometryTests` ×6** — measured: at 1029 pt with the panel open
    the row is two lines (610 × 56 pt) in both voices, the field 320 pt (prompt 211.5 Terminal / 175 Study), the panel
    at x 680–1029 (inside); at 1029 closed one line (field 222 / 268); at 1229 one line, the field 320 at x 24
    (controls 1097 / 1045 wide). **The toast cells on the Bookcase and the Library GREEN** — measured: the card's foot
    8 pt above the band's top (780 vs 788; 806 vs 814), centred on it.
  - **RED 1 (my pin, a test defect):** `LibraryControlsFlowRuleTests.theIdealIsOneLineAndTheMinimumIsTheWiderLine`
    (`LibraryControlsFlowTests.swift:116`) — "Expectation failed: minimum.size.width == max(75 + 10 + 228, 180 + 10 +
    174 + 10 + 53)", the values printing `427.0` and `427`. Mechanism: inside `#expect` the right-hand `max(…)` of
    integer literals was typed `Int`, and the macro's comparison of a `CGFloat` with an `Int` answered false. The
    layout's number is right.
  - **RED 2 (my pin, a test defect):** `StatusToastPlacementShellTests.aToastOverANoteRestsWhereItAlwaysHas`
    (`StatusToastPlacementTests.swift:200`) — "the toast rests 46 pt above the window's foot (card foot 838.0 of
    832.0)", off by 52. Mechanism: the cell measured against the HOSTING VIEW's height (832), but in this harness the
    shell's foot sits 52 pt lower in the same `.global` space (the Bookcase band's foot read 858 in an 832-pt host).
    The Bookcase / Library cells compare card and band in one space and are unaffected.
  - **Observation (not chased, the orchestrator's word):** in this mount — a titled 1240 × 800 window whose content
    view reads 832 tall — `RootView` lays out with its foot ≈52 pt below the host's height in `.global`. A harness
    fact; no product claim rests on it.
  - Restore: the store's three files byte-identical before the copy-back (the host writes no store), copied back and
    `cmp`-verified; the suites ADDED 9 prefs keys (`currentBlock.*` ×5, `surfaceSize.outline.*` ×4) — deleted, imported,
    re-exported, diff clean; zero instances; `castle-W1` untouched.

- **THE TWO FIXES (this commit, test files only — no product line):** RED 1 — the expected value typed `CGFloat`
  (`let widerLine: CGFloat = max(…)`, a comment at the line). RED 2 — the note cell measures from the SHELL's own
  frame in the same `.global` space as the card: the mount wraps `RootView` in the test's own `.onGeometryChange`
  reader (the `BookcaseQuickEntryPlacementTests.RootFrame` precedent), and the cell asserts the card's foot rests 46 pt
  above the shell's foot (the pane row — the toast's host — runs to the shell's foot: `ShellSplit`'s detail fills
  the height, nothing below it). Not the host layer's own frame through a DEBUG probe, as first suggested: that probe
  would sit in product code (`StatusToastLayer`), and the walker runs on the CURRENT products (the orchestrator's
  test-files-only rule) — the shell's frame answers the same question from the test. The cell stays a GUARD green on
  both sides (the old fixed overlay also rested 46 pt above the same foot). `vx283-u3` rebuilt headless
  (build-for-testing succeeded, no warning in the two files). PENDING the closing window.

- **R-ALL PREBUILD — STARTING (named before it is applied):** from the committed tip `4f8d1097`, the four reverts
  exactly as step 3 below names them (R-V `EditorCommands.swift`, R-T `RootView.swift`, R-D `LibraryListFace.swift`,
  R-L `LibraryCatalogView.swift`) applied to the working tree; `DerivedData/vx283-u3-revert` cloned from `vx283-u3`
  (APFS clone) and built there with `build-for-testing` — `vx283-u3` is never touched by the revert (the walker's
  products). Restore: `git checkout --` the four files, then `git diff` empty. A successor reading this with a dirty
  tree: the reverts are in flight — restore them before anything else. **DONE:** applied, cloned, built
  (`build-for-testing` succeeded in `vx283-u3-revert`; the log shows the four reverted files compiled), RESTORED —
  `git checkout --` the four files, `git diff --quiet` empty. No revert in flight.
- **THE CLOSING WINDOW — READY FOR STAGE (≈15 min; tip `<this commit>`, product code unchanged since `e6ed9b66`):**
  0. Preconditions (≈3 min): the two strict `pgrep`s; `defaults export … notes/plans/vx283-screens/u3/prefs-before-w2.plist`;
     with zero dev instances, the three store files into `notes/plans/vx283-screens/u3/store-before/<UTC stamp>/`.
  1. The fixed pins (≈2 min), `vx283-u3`, `test-without-building -only-testing:VariorumTests/LibraryControlsFlowRuleTests
     -only-testing:VariorumTests/LibraryControlsGeometryTests -only-testing:VariorumTests/StatusToastPlacementRuleTests
     -only-testing:VariorumTests/StatusToastPlacementShellTests` — every suite of the two touched test files (they share no
     helper with any other file). Expected: all green.
  2. The rig's dark pass, fixed (≈3 min), `vx283-u3`: `TEST_RUNNER_VARIORUM_LIBRARY_LIST_FACE=1
     TEST_RUNNER_VARIORUM_LIBRARY_LIST_FACE_APPEARANCE=dark TEST_RUNNER_VARIORUM_LIBRARY_LIST_FACE_LABEL=after xcodebuild …
     -derivedDataPath DerivedData/vx283-u3 test-without-building -only-testing:VariorumTests/LibraryListFaceRigTests`, the
     log reassembled by `notes/plans/vx283-screens/u3/tools/bwalk_extract.py` into `u3/rig/after`.
  3. R-ALL (≈5 min), `vx283-u3-revert`, `test-without-building -only-testing:VariorumTests/ViewMenuSeparatorTests
     -only-testing:VariorumTests/StatusToastPlacementShellTests -only-testing:VariorumTests/LibraryListHeaderDarkFaceTests
     -only-testing:VariorumTests/LibraryControlsGeometryTests` — expected RED exactly as step 3 of the first plan names
     (ViewMenuSeparator's one test; the Bookcase + Library toast cells, the note cell green; the four dark-face cells,
     light green; the panel-open controls cell ×2 voices, closed / wide green); then the rig again with `…_LABEL=before`
     → `u3/rig/before`. Then `rm -rf App/Variorum/DerivedData/vx283-u3-revert` (`vx283-u3` kept for the walker).
  4. Release (≈2 min): the store copied back and `cmp`-verified; prefs: delete the keys the suites added, import,
     re-export, diff clean; `Tools/stage release --who <claim>`; the one-line release result.

(The plan below as first written.)

**Q6 — THE STAGE WINDOW PLAN (≈25 min; run in this order; the record flips per step; all commands from
`App/Variorum/`, DerivedData `vx283-u3`, zsh `pipestatus` checked, the "Test run with N tests" line AND its skipped
lines recorded):**
0. *Preconditions (≈3 min).* `pgrep -lx Variorum`; `pgrep -lf "MacOS/Variorum$"` (discriminate by PATH; never touch a
   `/Applications` instance). `defaults export io.lduarte.Variorum.debug notes/plans/vx283-screens/u3/prefs-before.plist`.
   With ZERO dev instances, copy `variorum.sqlite{,-wal,-shm}` from the dev container's `Variorum-dev/` into
   `notes/plans/vx283-screens/u3/store-before/<UTC stamp>/` (never the key files, `Backups/`, `Previous Libraries/`;
   castle-W1 untouched). No app is launched in this window — the test host only.
1. *The batch (≈9 min incl. the incremental build).* `xcodebuild -scheme Variorum -destination 'platform=macOS'
   -derivedDataPath DerivedData/vx283-u3 test $(sed 's#^#-only-testing:VariorumTests/#'
   ../../notes/plans/vx283-screens/u3/suites.txt)` — **187 suites** from the 96 test files matching
   `SearchPicker|TakesShow(Copy|Door|Popover)|LibraryBulkRow|StatusToast|QuickEntry(Bar|Copy|Model|OpeningFocus)|LibraryList(Face|Header|Lead|Row|Separator)|LibraryBookOutline|LibraryInfoPanel|LibraryNotePreview|LibraryOutlineRowView|LibraryPanelLayout|LibraryPanelOracle|LibraryPreview|LibraryProbeSlot|LibraryControlsFlow|LibraryCatalogView|EditorCommands|RootView\(|ShelfView\(|ChromeLineLimit|ViewMenuSeparator|NSApp\.mainMenu`
   (every type of every changed source file, the two shell roots, the menu readers; the list and the file list are
   saved, gitignored, at `notes/plans/vx283-screens/u3/{suites,files}.txt`). It includes `ChromeLineLimitTests` (the
   VX-245 lint — red on the tip by batch 418, so green here is its red→green), `ViewMenuSeparatorTests`,
   `StatusToastPlacementRuleTests`, `StatusToastPlacementShellTests`, `LibraryListHeaderDarkFaceTests`,
   `LibraryControlsFlowRuleTests`, `LibraryControlsGeometryTests`, `LibraryBulkRowGeometryTests`. The opt-in rig suite
   rides as SKIPPED (expected).
2. *The rig's dark pass, fixed (≈3 min).* `TEST_RUNNER_VARIORUM_LIBRARY_LIST_FACE=1
   TEST_RUNNER_VARIORUM_LIBRARY_LIST_FACE_APPEARANCE=dark TEST_RUNNER_VARIORUM_LIBRARY_LIST_FACE_LABEL=after xcodebuild
   … test -only-testing:VariorumTests/LibraryListFaceRigTests > <log>`; then `python3 -I
   ../../notes/plans/vx283-screens/u3/tools/bwalk_extract.py <log> ../../notes/plans/vx283-screens/u3/rig/after`;
   record the `after-<voice>-geometry.txt` "uniform horizontal runs" row of the pinned header band (expected: the
   voice's dark `surface`, not #2F2D29).
3. *The red-on-old reverts — ONE combined revert build, **R-ALL = R-V + R-T + R-D + R-L** (each pin's subject is its
   own file and the expected reds are disjoint; named here before it starts) (≈8 min):*
   - **R-V** `EditorCommands.swift`: the three `// VX-359: …` comment lines after Close Split's `.disabled(…)` →
     `Divider()`.
   - **R-T** `RootView.swift`: `.statusToastHost(session.status, tokens: theme.tokens(for: scheme))` → `.overlay(alignment:
     .bottom) { if let item = session.status.current { StatusToast(item: item, tokens: theme.tokens(for: scheme),
     onDismiss: { session.status.clear() }).padding(.bottom, 46) } }`.
   - **R-D** `LibraryListFace.swift`: `pinnedFace`'s body `dark ? .voice(fill: tokens.surface, hairline: tokens.line) :
     .material` → `.material`.
   - **R-L** `LibraryCatalogView.swift`: `LibraryControlsFlow(spacing: 10, lineSpacing: 8) {` → `HStack(spacing: 10) {`.
   Run `-only-testing:` `ViewMenuSeparatorTests`, `StatusToastPlacementShellTests`, `LibraryListHeaderDarkFaceTests`,
   `LibraryControlsGeometryTests`. **Expected RED:** ViewMenuSeparator's one test (two separators in a row after Close
   Split); the Bookcase + Library toast cells (the note cell green); the dark face cells ×2 voices ×2 tests (light ×2
   green); the controls panel-open cell ×2 voices (panel closed / wide green). Then the rig's dark pass again with
   `…_LABEL=before` → `rig/before` (expected: the band's grey, or the snapshot's own reading of the material —
   recorded as read). **Restore:** `git checkout -- App/Variorum/Variorum/EditorCommands.swift
   App/Variorum/Variorum/RootView.swift App/Variorum/Variorum/Features/Library/LibraryListFace.swift
   App/Variorum/Variorum/Features/Library/LibraryCatalogView.swift`, then `git diff --quiet` (empty).
4. *Release (≈2 min).* Dev store copied back with zero dev instances and `cmp`-verified per file; prefs `defaults
   import` → re-export → diff against `prefs-before.plist` (delete by hand every key the suites ADDED); `Tools/stage
   release`; the one-line release report ("dev store restored + verified, prefs diff clean, posture Standard/unlocked,
   castle-W1 untouched") and the turn ends at once.

**Q5 — VX-175: THE COMPOSITION QUESTION (for the orchestrator's ruling; nothing built).** The brief's P-U3-2 puts the
search field alone on line 1 and scope · mode · sort · when on line 2. Measured, line 2 alone does not fit the very
window the ticket names in Terminal:
- **The room** at the 1240-pt default with the info panel open (the `LibraryBulkRowGeometryTests.room` arithmetic):
  1240 − sidebar 210 − seam 1 = 1029; panel `LibraryPanelLayout.width` = 349; list 679 − the header's 2 × 24 padding
  = **631 pt** (617 pt at the 230-pt sidebar the 13n-c walk had). Panel closed: 981 pt.
- **The controls' widths** — a standalone SwiftUI harness (scratch, not committed: the row's own controls rebuilt with
  each voice's `small` font, the segmented pickers' labels, `VoicedMenu`'s chrome for sort, the when door's chrome),
  cross-checked against the 13o capture `notes/plans/13o-screens/01-library.png` (Terminal, 1440 pt: field 320, scope
  253 in its 280 frame, mode 216 in its 230, sort 163 + 10, when 43 + 10 — the harness agrees within ~10 pt) and
  against the 13n-c walk's push (92 / 136 pt at 617 pt ⇒ a real one-line minimum of ≈709 / ≈753, ≈75 pt above the
  harness's 639 / 675: the real field's floor is a sliver of ≈75 pt where the harness's is 1 pt; everything else
  agrees). Minimum widths, Terminal / Study:
  - **(A) the brief's line 2 — scope · mode · sort · when: 665 / 629 pt.** Terminal overflows the 631-pt room by ≈35
    pt (the panel still pushed off at the default window); Study fits by 2 pt (and overflows by ≈12 at a 230-pt
    sidebar). Holding it would need a third line (field / scope · mode / sort · when) — a four-row header.
  - **(B) field · sort · when / scope · mode:** line 1 = 407 / 357 (the field floored at 160), line 2 = 419 / 432.
    Fits with ≈200 pt to spare; but sort and when JUMP from the row's end to before scope whenever the window crosses
    the break.
  - **(C) field · scope / mode · sort · when — RECOMMENDED:** line 1 = 399 / 403, line 2 = 427 / 386. Fits with ≈200
    pt to spare, both voices. The one-line ORDER is kept — the row just breaks after scope, so nothing jumps when it
    re-flows — and the break falls on the row's own seam: field and scope say WHAT is searched (the field's own words
    name scope's kinds, "Search books, notes, blocks…"); mode · sort · when say HOW it is shown, and sort and when
    already stand down WITH the mode (Timeline hides both — `model.showsCatalogControls`).
- **The mechanism (a second, smaller call):** `ViewThatFits` (the `LibraryBulkRow` precedent) builds each candidate
  separately, so the row would hold TWO search fields and swap them as it re-flows — and the re-flow's commonest
  trigger is the info panel OPENING on a row click while the field may hold her caret (the column narrows ⇒ two
  lines ⇒ a fresh field, caret gone). RECOMMENDED instead: a small two-line flow `Layout` over ONE set of subviews
  (field, scope, then the mode · sort · when group) — the field keeps its identity and caret across the re-flow; one
  line places them as today's `HStack` does (the trailing group at its maximum first, scope up to its 280, the field
  the rest up to 320 — the HStack's own least-flexible-first order, so a wide window is unchanged); the break is a
  pure function (one line iff the field's ideal + scope's minimum + the group's minimum + spacing ≤ the room),
  pinned headless. The field's ideal is its own prompt's width, so "never a sliver" reads "the field never truncates
  its own words while the row is one line" — PROVISIONAL, and no magic number. At the default window the row is one
  line with the panel closed (≈887 / ≈814 of 981 pt) and two with it open; with the panel open it stays two lines up
  to ≈1,570 pt (Terminal) / ≈1,500 pt (Study) — the range where today's one line squeezes the field toward its
  sliver (the 13n-c walk's 1380-pt "just fits").
- **Evidence planned once ruled:** the row extracted into its own view (`LibraryControlsRow`, the `LibraryBulkRow`
  shape, so it is measurable); a geometry oracle `LibraryControlsRowGeometryTests` (both voices, at the 631-pt room
  and at a wide 1181-pt room: the row fits; at the room the field ≥ its prompt; at the wide room one line) — RED ON
  OLD by behavioural revert (today's flat `HStack` at 631 pt reports its overflowing minimum); the break function's
  pure pins; the walk's captures at 1240 with the panel open and at a wide window, both voices.

#### U1 — HER RULINGS ON THE MEMO (2026-10-15 ~00:30, the question tool) — U1d builds to them

- **Auto-scroll:** asked *"After you scroll the Open list (or Starred) by hand, when should the list move by itself
  again?"*, she chose **"Only on your next act"** — the list keeps the current note in view after an open, ⇧⌘W, ✕,
  Close All or back/forward; once she scrolls by hand it stays where she put it until her next one of those;
  resizing the window never pulls it back. (The memo's item 1 as written; P-U1b-2's resize clause superseded.)
- **The edges:** asked *"How should a scrolled list's cut-off rows look at the top and bottom edges?"*, she chose
  **"The fade, reshaped"** — always half a row deep when there's more beyond, easing in (its strength, not its depth)
  so it doesn't pop, never fully solid so a hint of the next row always shows. (The memo's (A).)

#### U3 — THE ORCHESTRATOR'S RULING ON VX-175's COMPOSITION (2026-10-15 ~00:30 — P-U3-2 amended)

The implementer measured the brief's two-line split against the 1240-pt default with the info panel open (631 pt for
the controls): line 2 (scope · mode · sort · when) needs ~665 pt in Terminal — still pushes the panel off. **RULED (C):**
**search · scope** on line 1, **mode · sort · when** on line 2 (both ~400 pt, ~200 pt spare in both voices; the one-line
order kept — the row wraps after scope; the split falls where the controls already group). **Mechanism RULED:** a small
two-line `Layout` over ONE set of views, never `ViewThatFits` (which builds two search fields and swaps them on the
re-flow the info panel's opening triggers — dropping her caret); one line exactly as today's HStack when it fits; the
wrap decision a pure function (one line only if the field keeps at least its placeholder width); a red-on-old geometry
pin.

#### U3 — THE CLOSING WINDOW (run by the orchestrator in the folded claim `vx283-u3-walk`, 01:13:58 → SEAM 01:22:25)

Run from the U3 section's plan, verbatim commands (logs `notes/plans/vx283-screens/u3/logs-w2/`, gitignored):
1. The fixed pins on `vx283-u3`: `✔ Test run with 19 tests in 4 suites passed` (LibraryControlsFlowRuleTests,
   LibraryControlsGeometryTests, StatusToastPlacementRuleTests, StatusToastPlacementShellTests).
2. The List-face rig's dark pass, fixed: `✔ Test run with 5 tests in 1 suite passed` → `u3/rig/after/` (the
   orchestrator's eye on `after-terminal-manybooks.png`: the pinned "books"/"notes" headings sit on the room's own
   surface with the hairline, no grey band; the controls row wraps cleanly at the rig's width).
3. **R-ALL** on `vx283-u3-revert`: `✘ Test run with 10 tests in 4 suites failed … with 13 issues`, EXACTLY as named —
   R-L: the panel-open controls cell red in both voices (root wider than the window, the panel past the edge, the
   field under its prompt), closed/wide GREEN · R-D: both dark-face tests red ×2 voices, light GREEN · R-T: the
   Bookcase and Library toast cells red, the note cell GREEN · R-V: the separator test red. The rig again on the revert
   tree → `u3/rig/before/`. `vx283-u3-revert` DELETED.
4. Restore: the three store files copied back and `cmp`-verified; prefs diff clean (1602 = 1602); castle-W1 untouched;
   zero instances. SEAM pinged; the coordinator said continue (vx-336's closeout not READY); the walk followed.

#### U3 — THE WALK PLAN (the orchestrator's; her walk rule — a fresh Opus at xhigh)

Products: U3's Debug app, `App/Variorum/DerivedData/vx283-u3/Build/Products/Debug/Variorum.app`. Screens to
`notes/plans/vx283-screens/u3/walk/`, `<row>-<voice>-<appearance>.png`; region captures at native resolution for the
controls row, the toast and the heading, whole-window beside each. Store copy + prefs export done by the orchestrator
before the walker starts (the walk protocol); restored + diffed by the walker at the end.

- **W1 — VX-121, the toast above the quick entry.** On the Bookcase, raise a REFUSAL toast (any door that refuses —
  e.g. a structural undo with nothing to undo, or an import of a non-Variorum file through File ▸ Import…): the toast
  sits ABOVE the quick-entry box at the same centre, never on it. The same in the Library (its quick-entry bar). A note
  pane's toast where it was (unchanged). Both voices.
- **W2 — VX-175, the controls row.** The window at the app's 1240-pt default width. The Library with the info panel
  CLOSED: the controls on one line, as before. Click a note row so the panel OPENS: the row wraps to two lines —
  search · scope / mode · sort · when — the panel wholly inside the window, its Open button and text unclipped, the
  search field never a sliver. Type a few letters into the search field, then open and close the panel: the caret and
  the text survive the re-flow. At a wide window (≈1600 pt) with the panel open: one line, unchanged. Study and
  Terminal.
- **W3 — VX-20, the dark heading.** The Library's List in DARK with enough rows that the pinned "books"/"notes"
  heading floats: no warm grey band; it reads as the room's own surface with its hairline, in Study and Terminal.
  Light: unchanged from before (compare with one light capture).
- **W4 — VX-359.** The View menu open: one separator after Close Split, not two.
- **W5 — VX-245's surfaces where reachable:** the Library's bulk row (pick two or more notes) at 1240 pt; a search
  picker (e.g. a Move/Add to Book picker); Takes' show ▾ face. Labels sit on one line, nothing blows the window wider.
- **W6 — restore and release** (copy the store back + `cmp`; prefs: delete added keys, import, re-export, diff;
  posture Standard, unlocked, castle-W1 untouched; release; END THE TURN AT ONCE with the release line).

#### U3 — WALK RECORD

**Walker:** a fresh Opus 5.5 at xhigh (2026-10-15 01:23–01:45), claim `vx283-u3-walk` (held by the orchestrator).
Products `DerivedData/vx283-u3` (product code `e6ed9b66`), launched by path (pid 63327, the only dev instance; her
app absent throughout). Host: AX true, Screen Recording true. At launch: no lock screen (Standard, unlocked), no
What's New sheet, voice **Study**, appearance **follow system** (= light). Window set to **1240 × 900** (read back
from System Events: 1240 wide). The voice was flipped in Settings ▸ General ▸ Theme and the appearance in its
Appearance row (both via AX), so no relaunch. W1's refusal: File ▸ Import… on an empty folder ("Couldn't import
“empty-import” — it holds no .md, .txt or .variorum files." — a refusal, nothing minted). Screens (gitignored):
`notes/plans/vx283-screens/u3/walk/`, a whole-window capture + a native-resolution region per state.

- **W1 — the toast above the quick entry.** Bookcase, Library and a note (2026-10-11, Write), Study + Terminal,
  light. · `W1-bookcase-{study,terminal}-light{,-region}.png`, `W1-library-{study,terminal}-light{,-region}.png`,
  `W1-note-study-light{,-region}.png` · **HOLDS.** Bookcase: the card sits ≈18 pt clear of the dashed box, centred
  on it (both voices; Terminal's card wraps to two lines and still clears). Library (panel closed, Study): above its
  box at the box's centre, over the list's last row. Note: rests just above the bottom bar, where it always has.
  (Library with the panel OPEN, Terminal: clear of the box too, but see O-3 on its centre.)
- **W2 — the controls row at 1240.** · `W2-closed-study-light*`, `W2-open-study-light*`, `W2-typed-open-study-light*`,
  `W2-typed2-open-study-light-region`, `W2-typed-closed-study-light*`, `W2-typed-reopen-study-light*`,
  `W2-wide-open-study-light*`, `W2-open-bulk-terminal-light*`, `W2-closed-terminal-light*`,
  `W2-closed-relayout-terminal-light-region`, `W2-typed-closed-terminal-light*`, `W2-typed-reopen-terminal-light-region`,
  `W2-typed-open-terminal-light*`, `W2-closed-terminal-dark-region`, `W2-closed-focused-terminal-dark-region`,
  `W3-terminal-dark.png` · **DOES NOT HOLD.** What holds: Study, panel closed, empty field → one line, the field
  showing its whole prompt; panel opened by a row click → two neat lines (search · scope / mode · sort · when), the
  panel wholly inside the window, Close/Open/its prose unclipped, the field ≈320 pt; closing the panel with text typed
  → one line, the text, the caret and the focus ring kept; 1600-pt window, panel open → one line, unchanged. What
  does not: **(F-1) typing in the field while the panel is open collapses the row to ONE line with the field a
  sliver (≈57 pt, just the typed word) and the sort label wrapped onto three lines** — Study "relevance / · best /
  first", Terminal mid-word "relevanc / e · best / first" (`W2-typed-open-study-light-region`,
  `W2-typed2-open-study-light-region`, `W2-typed-open-terminal-light-region`). Reproduced on every keystroke, both
  voices; a re-layout from a row click brings back the two lines (`W2-typed-reopen-*`). The text and caret survive
  every re-flow. Likely mechanism (read, not traced): `LibraryControlsFlow.swift:148` reads the field's ideal as
  `sizeThatFits(.unspecified)`, which for a TextField holding text is the TEXT's width, not the prompt's — so once
  the typed text is shorter than the prompt, `fitsOneLine` passes and the field is distributed down to its text,
  and the sort label (no line limit) is squeezed into wrapping. **(F-2) In Terminal at 1240 the closed-panel row is
  not reliably one line:** empty field, panel closed → two lines (`W2-closed-terminal-light*`, kept through a
  1250→1240 resize, `W2-closed-relayout-*`); later, in dark, the same state read one line (`W2-closed-*-terminal-dark-*`),
  then two lines again after nothing but a scroll of the list (`W3-terminal-dark.png`). With text typed it is one
  line (`W2-typed-closed-terminal-light*`). So in Terminal the default window sits on the wrap threshold and the row
  — and the whole List under it — jumps a line with incidental state. Study read one line every time.
- **W3 — the dark heading.** Library ▸ List scrolled so "notes" pins, dark, Terminal then Study; one light capture
  (Study). · `W3-terminal-dark{,-region}.png`, `W3-study-dark{,-region}.png`, `W3-study-light{,-region}.png` ·
  **HOLDS.** Sampled: Terminal dark — the pinned band #0D0F0D = the List's paper and the header above it, a #303230
  hairline at its foot; Study dark — #1A1712 = the List's paper, hairline #39352F. No #2F2D29 grey band in either.
  Light — the native material, near-white #FFFFFF with its soft #DBDBDB shadow line (the light branch is
  `.material`, unchanged).
- **W4 — the View menu.** Opened by AX in Study light. · `W4-viewmenu-study-light.png` · **HOLDS.** One separator
  after Close Split (the AX item list reads "… Open Beside, Close Split, ⟨separator⟩, Toggle Sidebar …").
- **W5 — VX-245's sites.** The Library's bulk row (2 notes selected by ⌘-click) at 1240, Study (panel open) and
  Terminal (panel open and closed); the Add to Book picker (the "in no book" chip on 2026-10-11); Takes' show ▾ on
  "a escola" (a note with a lens). · `W5-bulk-study-light{,-region}.png`, `W2-open-bulk-terminal-light*`,
  `W2-closed-terminal-light.png`, `W5-picker-study-light.png`, `W5-takesshow-study-light{,-region}.png` · **HOLDS.**
  "2 notes selected" + Tag · Untag · Share 2 notes with AI… · Delete 2 notes…, each label on one line, the row inside
  the column; the show popover's inline lens pickers ("english readings — a escola ▾", "another lens ▾") each on one
  line in a popover that fits them. **Not reached:** `SearchPicker.swift:503` (the arrangement buttons) draws only
  in the MCP grant sheet, left alone by the coordinator's rule; the Add to Book picker (no arrangements) draws its
  rows on one line.
- **W6 — restore.** See below.

**OBSERVATIONS (not verdicts):**
- **O-1** Two-line row (panel open): line 2 starts ≈7 pt right of the field's left edge — the segmented mode
  control draws its pill inset inside its frame (`W2-open-study-light-region`). Small, visible.
- **O-2** With the panel open and a query typed, the answer band's echo reads "“w…g”" / "“w…gs”" for a 4–5 letter
  query (Terminal, `W2-typed-*-terminal-*`). Not U3's code.
- **O-3** With the info panel open, the Library toast centres on the whole pane row, not on the quick-entry box, so
  it straddles the list/panel seam and covers some panel prose (`W1-library-terminal-light-region.png`). Clear of
  the box, as ruled; horizontally the same centre as before U3.
- **O-4** The Add to Book picker opens over the chip's own popover, which shows through at the picker's right edge,
  and its left edge pokes into the sidebar (`W5-picker-study-light.png`). Not U3's code.
- **O-5** Selection and the info panel persist across Bookcase ↔ Library navigation (the panel was still open
  when I came back). Noted only because it changes which W2 state a return lands in.

**RESTORE (W6):** my instance quit by bundle id; zero dev instances (`pgrep -lx Variorum`, `pgrep -lf
"MacOS/Variorum$"` both empty). Store: `variorum.sqlite` unchanged, `-wal`/`-shm` changed by the walk → the three
copied back from `notes/plans/vx283-screens/u3-walk/store-before/`, each `cmp`-identical. The launch's routine
dev-store backup under `Backups/` was left as is (that folder is not ours to touch); `castle-W1-20261013` present,
untouched; key files and `Previous Libraries/` untouched. Prefs: the walk ADDED one key
(`postMode.B48D5133-…`) — deleted; `defaults import` of `prefs-before.plist`; re-export diffed against it: no added,
removed or changed keys — CLEAN (`appearanceChoice` = system). The voice was returned to Study in-app and the store
restore carries it regardless. Posture Standard, unlocked.

#### U3b — THE ORCHESTRATOR'S RULING ON THE WALK'S W2 (2026-10-15 ~01:55 — P-U3-5, a FRESH implementer)

The walk (record above) holds W1/W3/W4/W5; **W2 (VX-175) does not**: **F-1** — typing with the panel open collapses the
row to one line, the field a ~57-pt sliver, the sort label wrapping onto three lines (Terminal breaks a word); **F-2** —
Terminal at 1240 with the panel closed flips between one and two lines on incidental state (a list scroll, an empty
vs typed field), its default sitting on the threshold. The walker's read, untraced: `LibraryControlsFlow.swift:148`
takes the field's ideal from `sizeThatFits(.unspecified)` — for a field holding text that is the TEXT's width, not
the prompt's — and the sort label carries no line limit.

**RULED — the wrap decision reads STABLE widths only:**
1. The field's floor is its PROMPT's width (the placeholder string measured in the field's own font), handed to the
   layout explicitly (a `LayoutValueKey` on the field, or a parameter) — never the typed text's width.
2. The one-line test counts the sort label at the WIDEST it can read (every sort field × direction × the search's
   relevance form, measured in the voice's font) — so a sort or search change never flips the row. `when ▾` likewise
   if its label varies.
3. The sort (and when) labels get `.lineLimit(1)` (P-8) — never a wrapped label.
4. Result to pin: the decision is a pure function of the column width + the voice's stable widths; at 1240 the row
   is ONE stable answer per voice and panel state (Terminal panel-closed may be two lines — stable is the point);
   typing never changes the line count. Red-on-old: today's `ideal` road re-flows on typed text (a mounted pin typing
   into the field with the panel open — the walker's F-1).
5. Evidence: the pins + the batch over the changed files' suites + a re-walk of W2 (both voices, panel open/closed,
   typing, a list scroll, the 1240 default).

#### U1d — THE BRIEF (her two rulings, built; a FRESH implementer)

Build to "U1 — HER RULINGS ON THE MEMO" and "U1 — THE DESIGN MEMO" above, on top of U1c's code
(`SidebarSectionWindow`, `SidebarLayout.revealOffset`/`readingAsk`/`edgeFades`):
1. **FOLLOW (R6).** A section FOLLOWS its current row after a discrete act — the current row changing (an open, a
   landing: ⇧⌘W, ✕, Close All, back/forward) and the section's first appearance. While following, every input that
   moves the row re-asks (P-U1c-1). **A hand scroll ends following** — detected from the scroll view's phase
   (`onScrollPhaseChange`: `.interacting` / `.decelerating` are hers; the app's unanimated `scrollTo` is not) —
   and nothing moves the list until the next discrete act. Write the follow state as a PURE model (inputs: a
   discrete act, a phase change, a reading) so it pins without a mouse; the mounted pin drives a hand scroll if the
   harness can (a real scroll-wheel event via the WalkKit-style injector is NOT allowed in tests — use the model
   seam), and asserts a viewport change while not following moves nothing. Red-on-old: on U1c's code the same
   sequence re-reveals.
2. **THE FADE, RESHAPED (O-2/O-3).** Depth = the full half row whenever more than the 0.5-pt slack lies beyond (never
   a few-point fade); STRENGTH eases in with the content beyond (e.g. full strength once a half row lies beyond —
   the implementer's PROVISIONAL number, recorded) so it doesn't pop; and NEVER fully solid at the very edge (the
   outermost opacity capped below 1 — PROVISIONAL value, chosen by eye in both voices and appearances and recorded —
   so a hint of the partial row always shows; O-3's empty band can't happen). Pure-rule pins for depth, strength and
   the cap; the overlay still draws from the room token, takes no clicks.
3. Evidence: the batch over the changed files' suites + the mount suite × 5 + the reverts naming each rule; then a
   re-walk of R2–R6's rows (the fades in all four rooms, the shallow-overflow state R4 reproduced, the twenty opens,
   the hand-scroll-then-wait for R6 with waits of 20 s+), by a fresh walker.

### U1d — follow and the reshaped fade

**Implementer:** a fresh Opus 5.5 at xhigh (2026-10-15, overnight), worktree `~/dev/variorum-vx-283`, DerivedData
`App/Variorum/DerivedData/vx283-u1d`. Builds to "U1 — HER RULINGS ON THE MEMO" on U1c's code. **Not done by this
session (first line):** any stage work until the orchestrator hands over a claim; the re-walk (a fresh walker's).

**LIVE STATUS (per piece)**
- D0 — this section: DONE (`931eaf5b`).
- D1 — the pure follow model (`SidebarLayout.SectionFollow`) + pure pins: DONE (`74a7d787`) — the pure replica green
  headless (below); the suite's run PENDING the stage window.
- D2 — the fade reshaped (`SidebarLayout.EdgeFade`/`edgeFades`/`edgeFadeCap`) + pure pins; the cap chosen by eye
  offscreen (0.8): DONE (`74a7d787`) — replica green headless; the run PENDING.
- D3 — the modifier wired to both (`onScrollPhaseChange`; the DEBUG phase seam) + the mounted pins: DONE (`74a7d787`)
  — headless `build-for-testing` green (`DerivedData/vx283-u1d`, no warning in a touched file); the runs PENDING.
- D4 — the reverts R-I and R-J, each named below BEFORE it was applied: DONE — each patch applied, built
  (`DerivedData/vx283-u1d-ri`, `-rj`: TEST BUILD SUCCEEDED), restored by `git checkout --`; **no revert is in the tree**
  (`git diff` empty). Patches: `notes/plans/vx283-screens/u1d/reverts/R-I.patch`, `R-J.patch` (gitignored).
  **All three trees REBUILT at `d5900981`** (a test-only rig fix: `SectionRig.scrollView(_:)` now finds a section's
  AppKit scroll view by its own scroll reading — clip height = viewport, document height = content, both equal at
  rest per U1c's trace — instead of assuming a SwiftUI-global ↔ AppKit-window convention no pin had verified): each
  TEST BUILD SUCCEEDED, each revert restored, `git diff` empty. `DerivedData/vx283-u1d` holds HEAD's products.
- D5 — **READY FOR STAGE** (≈15 min), the script `notes/plans/vx283-screens/u1d/window.sh` (gitignored), from
  `App/Variorum/`, in order: (0) `pre` — strict pgreps, the Debug prefs exported, the dev store's three files copied
  to `u1d/store-before/<UTC>/` with zero dev instances; (1) `batch` — `xcodebuild … -derivedDataPath
  DerivedData/vx283-u1d test-without-building` with one `-only-testing:VariorumTests/<Suite>` per line of
  `u1d/batch-suites.txt` (96 suites: every top-level suite of the 32 test files referencing `SidebarLayout|SidebarView|
  SidebarGeometry|SidebarSectionWindow|RootView(` + `NoLiteralColourTests`, `ChromeLineLimitTests`,
  `CapabilityRegistryTests`; the new `SidebarSectionFollowTests` among them) — expected ALL green, the "Test run with
  N tests" line and its skipped lines recorded; (2) `mount` — `SidebarSectionWindowMountTests -test-iterations 5`,
  expected 5/5 green (the two U1c harnesses skipped); (3) `ri` — R-I's products, `SidebarSectionFollowTests` +
  `SidebarSectionWindowMountTests`, expected RED exactly the three R-I names below; (4) `rj` — R-J's products,
  `SidebarSectionWindowRuleTests` + `SidebarSectionWindowMountTests`, expected RED exactly the three R-J names below;
  (5) `restore` — the store copied back and `cmp`-verified, prefs diffed (added keys deleted by hand, `defaults
  import`, re-export, diff clean), castle-W1 untouched; the two revert DerivedData folders deleted; release.

**THE TRACE (R6 — U1c's tip, `App/Variorum/Variorum/…`).** Every road that moved a section by itself was gated by
nothing but "an offset-only reading asks nothing": `Features/Library/SidebarSectionWindow.swift`'s geometry action
asked `SidebarLayout.readingAsk` — ANY viewport change → `reveal` at once (P-U1c-1), a content change > 0.5 pt under an
unchanged row count → `requestReveal` — and `onChange(of: rowHeight)` and the settled backstop asked again
unconditionally. None of them knew whether HER hand had moved the list since the last act. So after a hand scroll,
any later reading whose viewport or content changed snapped the list back to the current row — by design for a resize
(P-U1b-2, "including a window resize after she scrolled away"), and by the same road for whatever perturbed the
column with no input in the re-walk (three pull-backs; that perturbation is NOT identified — candidates such as the
lazy stack re-estimating rows her scroll realized, or a footer row's height, are untraced guesses and were not
pursued: the gate closes the whole class, whatever the source). The mechanism, as inputs → wrong state: [act: current
row revealed] → [hand scroll: offset-only, asks nothing] → [any reading with a viewport/content change, or a pitch
change, or a pending settled check] → `reveal()` → `proxy.scrollTo(current)` → her list pulled back.

**THE PROBE (headless, a standalone process with a never-shown window — `notes/plans/vx283-screens/u1d/phase-probe.swift`,
gitignored):** which inputs SwiftUI's `onScrollPhaseChange` reports on macOS 27 —
- the reveal's unanimated `proxy.scrollTo` (a `disablesAnimations` transaction): NO phase change (idle throughout);
- an animated `proxy.scrollTo`: `idle → animating → idle` (the app's, never hers);
- a LEGACY line-unit wheel burst (no phase fields — WalkKit's `walk-scroll` shape, a mouse wheel): `idle →
  interacting` BEFORE its first offset change, `→ idle` ≈100 ms after its last event; every new burst (≥100 ms apart)
  reports again, including one issued 20 ms after an app reveal;
- a phased trackpad gesture (began/changed/ended): `idle → interacting → idle` at the gesture's end;
- a programmatic clip-view scroll and a frame-height change: no phase.
So the scroll view's phase separates her hand from the app's own scrolls for both a wheel and a trackpad, and the
walker's `walk-scroll` produces a real hand phase.

**THE BUILD (`74a7d787`).**
- `Core/Views/SidebarLayout.swift` (pure): **`SectionFollow`** — `following` (true from the first appearance);
  `act()` (follow again); `phase(hers:)` (a hand phase ends following; any other phase — idle, the app's animated
  scroll — changes nothing, so her scroll's END is not an act); `gate(_ ask:)` (the ask itself while following,
  `.none` while not). **`EdgeFade`** (`depth` · `strength` · `opacity = strength × edgeFadeCap`) and `EdgeFades` of two;
  **`edgeFades`** reshaped: past the 0.5-pt slack an edge fades the FULL `depth` (half a row), its strength
  `min(1, beyond / depth)`; **`edgeFadeCap = 0.8`**. `revealOffset` reads the fades' depths (unchanged answers: the
  reveal only ever differed where the old depth was shallow, and there the row was "below" either way — the replica's
  idempotence sweep and the eased-shrink cadences agree).
- `Features/Library/SidebarSectionWindow.swift`: `SidebarSectionMemory.follow`; the geometry action routes
  `readingAsk` through `follow.gate`; `onScrollPhaseChange` → `observe` → `follow.phase(hers: isHandScroll(phase))`
  (`isHandScroll`: interacting or decelerating); `onChange(of: current)` → `follow.act()` then the request; the mount's
  first reading is an act; the pitch's request and the settled check pass `follow.gate` first. The overlay paints the
  room from each edge's `opacity` down to nothing over its `depth`. The DEBUG phase seam (`SidebarSectionPhaseSeam`):
  the section hands its owner a feeder that runs the SAME `observe` the phase callback runs; the trace notes phases
  and `following`.
- `Features/Library/SidebarView.swift`: both sections pass `phaseSeam: sectionPhaseSeam(…)`; the DEBUG oracle files
  each feeder in `SidebarGeometry.sectionPhaseFeeds` keyed by the column's workspace (cleared by `forgetSections`).
- What the walk must prove that no pin can: the seam calls `observe` directly, so `onScrollPhaseChange` being attached
  to the section's scroll view is proven only by a real hand scroll (the re-walk's R6 with `walk-scroll`).

**THE CAP, CHOSEN BY EYE (P-U1d-3).** An offscreen render (`notes/plans/vx283-screens/u1d/cap/`, gitignored — the
probe source `fade-probe-main.swift`, the real `SidebarLayout.swift` compiled beside it; the four rooms' room / ink /
muted / accent / wash from `VoiceTokens`; rows at 24 pt) of three states at caps 1.0 · 0.9 · 0.8 · 0.7 · 0.6:
O-2's shallow overflow (5 pt beyond), O-3's partial row with its text in the fade's outer half (12 pt of it showing)
and R2b's middle (partial rows at both edges). Looked at: `cmp-O3-partial-b.png`, `zoom-O3-partial-b.png`,
`zoom-R2b-middle-t.png`, `cmp-R2b-middle-t.png`, `cmp-O2-shallow-b.png`. At 1.0 the partial row's letters fade to
nothing toward the edge (all but gone in both dark rooms — O-3's empty band). At **0.8** a faint ghost of the row
reads in all four rooms — her "a hint" — while the clipped edge of the letters still reads soft. At 0.7 and 0.6 the
ghost grows and the clip line through the letters starts to read crisp again (the slice F-2 removed). 0.9 leaves a
10% hint, near invisible on black. Built: 0.8. Options: (a) 0.8 [built]; (b) 0.7 (more hint, a crisper clip); (c) 0.9
(less hint, invisible in dark). Note: a sliver of a partial row thinner than its row's top padding (≲ 6 pt) shows no
ink under any cap — that is the clip, not the fade.

**PROVISIONALs (U1d):**
- **P-U1d-1 — re-selecting the note already shown is not an act.** The act is a CURRENT-ROW CHANGE; a door that
  re-selects the very note the pane shows (⌘⇧N for its own ordinal, ⌘K to itself) changes nothing, so a list she
  scrolled stays put. Options: (a) no act [built — no current change, no reveal]; (b) every navigation request is an
  act, even to the same note (needs a request token from the shell — `ShellRouter`, not this lane).
- **P-U1d-2 — the strength's ease: linear over the first half row beyond the edge** (`min(1, beyond / depth)`; a
  half-point past the slack it is 3–4%, so nothing pops). Options: (a) linear over the half row [built]; (b) over a
  whole row; (c) a smoothstep over the half row.
- **P-U1d-3 — the cap, 0.8** (above).
- **P-U1d-4 — each section follows on its own.** A hand scroll in the Open list ends the Open list's following only;
  Starred, untouched, keeps following its current row (through a resize, say). Options: (a) per section [built — her
  "it stays where you put it" names the list she scrolled]; (b) a hand scroll in either section stops both.
- Ruled, not provisional: her scroll's END does not resume following (her words: "until your next one of those"); a
  resize while FOLLOWING still keeps the row in view (the memo's item 1, P-U1c-1 unchanged).

**PINS (`App/Variorum/VariorumTests/SidebarSectionWindowTests.swift`; all PENDING the stage window):**
- NEW `SidebarSectionFollowTests` (pure ×5): `aSectionFollowsFromItsFirstAppearance`;
  `aHandScrollEndsFollowingUntilHerNextAct` (RED under R-I); `onlyInteractingAndDeceleratingAreHerHand`;
  **`herScrollStaysWhereSheLeftItThroughEveryLaterChange`** (R6 played through the model — a resize shorter, the
  content re-laid under the same count, a resize taller, the pitch's request, the settled check: her offset 0 holds;
  her next act reveals at 95 — RED under R-I: 204, 204, 95); `whileFollowingAResizeKeepsTheRowInView`.
- `SidebarSectionWindowRuleTests`: `anEdgeFadesOnlyWhereContentLiesBeyondIt` ADJUSTED (the values are `EdgeFade`s —
  her ruling; meaning unchanged); `theFadeEasesInWithTheContentBeyondTheEdge` **REWRITTEN by her ruling** as
  `theFadeIsAlwaysHalfARowDeepAndItsStrengthEasesIn` (4 and 8 pt beyond: depth 15, strengths 4/15 and 8/15; the ease
  monotone with no step — RED under R-J: depths 4 and 8, strength 1); NEW `theFadeIsNeverFullySolid` (the cap in
  (0.5, 1); no edge above it anywhere; O-2's 5 pt beyond = depth 12 at 5/12 × cap — RED under R-J);
  `everyRowLandsClearOfTheFadesFromAnyWindow` and `anEasedShrink…EveryCadence` ADJUSTED to read `.depth` / `.none`
  (meaning unchanged).
- `SidebarSectionWindowMountTests`: `theOpenListFadesOnlyTheEdgesWithMoreBeyond` and
  `starredFadesWhereMoreLiesBeyondAndNowhereWhenItHoldsEverything` ADJUSTED to compare `EdgeFade`s (`.whole(depth)` —
  every edge there has a half row or more beyond; meaning unchanged); `openRowTrouble` reads the fades' depths; NEW
  **`aHandScrollIsNeverPulledBackUntilHerNextAct`** (20 notes at 900 pt, row 16 current and revealed; the phase seam
  `.interacting` + the clip view to 0 + `.idle`; the window to 840 pt then back to 900: her offset 0 holds both times;
  her next act — note 17 opened — lands it clear — **RED ON OLD under R-I**: the 840-pt shrink re-reveals); NEW
  **`aShallowOverflowFadesTheWholeHalfRowFaintly`** (the list hand-scrolled to 5 pt short of its end: the bottom fade
  is the whole half row at strength beyond/depth, opacity < 1 — **RED ON OLD under R-J**: a 5-pt fade). Rig helpers:
  `SectionRig.scrollView(_:)`, `.handScroll(_:to:)`. The existing U1/U1b/U1c pins otherwise unchanged
  (`aShorterListKeepsTheCurrentRowInView` reads "while following" now — nothing scrolled by hand there).

**Headless evidence:** `build-for-testing` → TEST BUILD SUCCEEDED (`DerivedData/vx283-u1d`, the `74a7d787` code; no
warning in a touched file). The PURE pins replicated line for line against the real `SidebarLayout.swift`
(`notes/plans/vx283-screens/u1d/pure-replica-main.swift`, gitignored): **8715 checks, 0 failed**; with R-J's patch 5
failed (exactly the reshape checks); with R-I's 6 failed (exactly the follow checks); the U1b/U1c-era rule checks
green under both.

**THE REVERTS (named before they are applied; each prebuilt into its own DerivedData and restored by `git checkout
--` from the commit, `git diff` empty after):**
- **R-I (R6 — follow):** `SidebarLayout.SectionFollow.phase(hers:)` loses its `if hers { following = false }` — her
  hand never ends following, i.e. U1c's behaviour. Products: `DerivedData/vx283-u1d-ri`. Expected RED:
  `SidebarSectionFollowTests.aHandScrollEndsFollowingUntilHerNextAct`, `.herScrollStaysWhereSheLeftItThroughEveryLaterChange`,
  `SidebarSectionWindowMountTests.aHandScrollIsNeverPulledBackUntilHerNextAct`.
- **R-J (O-2/O-3 — the fade):** `edgeFades` back to U1b's eased DEPTH at full strength (`EdgeFade(depth: min(depth,
  beyond), strength: 1)`) and `edgeFadeCap = 1`. Products: `DerivedData/vx283-u1d-rj`. Expected RED:
  `SidebarSectionWindowRuleTests.theFadeIsAlwaysHalfARowDeepAndItsStrengthEasesIn`, `.theFadeIsNeverFullySolid`,
  `SidebarSectionWindowMountTests.aShallowOverflowFadesTheWholeHalfRowFaintly`.

#### U1d — THE STAGE WINDOW (run by the orchestrator, claim `vx283-u1d` 01:44:58–01:50:37, RELEASED)

`u1d/window.sh` as written: **batch** `✔ Test run with 434 tests in 96 suites passed` (the two env-gated U1c harnesses
skipped) · **mount × 5** `✔ … 11 tests in 1 suite passed` · **R-I** (her hand never ends following) `✘ 16 tests, 10
issues` — exactly `aHandScrollEndsFollowingUntilHerNextAct`, `herScrollStaysWhereSheLeftItThroughEveryLaterChange`,
`aHandScrollIsNeverPulledBackUntilHerNextAct` · **R-J** (U1b's fade) `✘ 26 tests, 11 issues` — exactly
`theFadeIsAlwaysHalfARowDeepAndItsStrengthEasesIn`, `theFadeIsNeverFullySolid`,
`aShallowOverflowFadesTheWholeHalfRowFaintly`. Revert trees deleted. Store restored + cmp-verified; the suites' 9 prefs
keys deleted, diff clean (1602 = 1602); castle-W1 untouched. The orchestrator's eye on the cap sheets
(`u1d/cap/`): 0.8 shows a faint ghost of a half-hidden row in all four rooms — P-U1d-3 accepted.

#### U1d — THE RE-WALK PLAN (a fresh Opus at xhigh; her rule)

U1b's re-walk rows R0–R8 (above), on `DerivedData/vx283-u1d`, screens to `notes/plans/vx283-screens/u1d/walk/`, with:
R4 — the shallow-overflow state reproduced ("to the top, then one wheel line down") in all four rooms (the row fades
over the whole half row, faintly — never a slice); R5 — the twenty rapid opens, and R5a's half-hidden partial row
(a faint ghost, never an empty band); **R6 — a hand scroll with `walk-scroll`, then waits of 20 s, 60 s and 90 s with no
input, the list staying where she left it; then a resize while scrolled away (stays); then her next act (an open) —
the list follows again**; R7 regressions (the footer stop, the bar beside the ✕).

#### U1d — RE-WALK RECORD

**Walker:** a fresh Opus 5.5 at xhigh (not an implementer of any U1 leg), 2026-10-15 01:51 → 02:16, on the
orchestrator's claim `vx283-u1d-walk`; the Debug app `App/Variorum/DerivedData/vx283-u1d/…/Variorum.app` (built 01:39,
not rebuilt), PID 78993, discriminated by path. Screens in the gitignored `notes/plans/vx283-screens/u1d/walk/`
(sidebar rows as 2× region captures of the sidebar rect 60,36 240×1010; `-window` beside the key ones; `-zoom-*` 3×
nearest-neighbour crops of the edges). Every image cited was opened and looked at; the edge verdicts are also
pixel-measured (luminance per scanline across the row band). Hand scrolls are `walk-scroll` (line units) plus a
scratch pixel-unit twin of it (`pxscroll`, the same CGEvent wheel road with `.pixel` units — for exact offsets).

- **R0 — preconditions.** Both strict pgreps empty; her app absent; the host `AX: true SCREEN: true`. Store copy +
  prefs export were the orchestrator's (`u1d-walk/`), not redone. Posture at launch: Standard, unlocked (the
  Bookcase came up), voice **Study**, appearance **follow system** (light); no What's New sheet showed. Window AX-set
  to 1380 × 1010 at (60, 36). · HOLDS.
- **R1 — seed.** 14 notes open + 1 star at launch; the twenty opens of R5a filled the Open list to its 20-row cap;
  8 notes starred through Library ▸ right-click ▸ Star (9 starred: `R3-seeded-study-light.png`). · done.
- **R2 — the Open list's three states (Study light).** Top `R6-study-light-d-1-after-open.png` / `R2a-study-light.png`
  (the first row whole under the header, no top fade; the bottom partial row "the bookcase" / "gatherings & arrivals"
  a faint ghost); middle `R2b-study-light.png` (+`-zoom-top`: "how to use it" a ghost under the header); end
  `R2c-study-light.png` / `R6-study-light-a-t90.png` (the top partial faded, the last row whole, no bottom fade). The
  ✕-inside-the-fade click was NOT re-walked (time). · HOLDS — but see O-1 (the middle state's bottom).
- **R3 — Starred (9 stars).** `R3top-<room>.png`: at its top, 7 whole rows and the half row "what the door is" a
  faint ghost, no top fade; `R3end-<room>.png`: at its end, "seeing, answering, undoing" a ghost under the header, the
  last row whole, no bottom fade — all four rooms (`R3top-<room>-zoom-bottom.png`, `R3end-<room>-zoom-top.png`). ·
  HOLDS (the half row is clipped through its letters but faded to a ghost — U1b's O-4 look, reads soft).
- **R4 — the shallow overflow, four rooms.** The Library-view list does not overflow at 1010 pt, so the state was
  made exactly: hand scroll to the end, then ONE pixel-unit wheel event of 5 px up — the list 5 pt short of its end
  (the R-J pin's state): `R4shallow-study-light.png`, `-terminal-light`, `-terminal-dark`, `-study-dark` (+`-zoom-top`,
  `-zoom-bottom` each). In every room the last row "export: it's all yours" is WHOLE, descenders intact, lightening
  faintly toward the edge; the top row softened by the full-strength top fade; the fade matches each room (no band,
  seam or box, black rooms included); each stayed put 14 s (`-t14`, byte-identical). · HOLDS for the 5-pt state.
  **But the same edge 7–9 pt short of the end SLICES** — `R4shallow7-study-light.png` / `R4shallow9-study-light.png`
  (+`-zoom-bottom`): the bottom row (here the current row, its wash pill) is cut by a hard horizontal edge through its
  descenders and pill — reads "exnort: it's all vours". Measured: at 7 pt beyond the content at the clip line keeps
  ~60% of its contrast (bold ink 53 → 131 at the edge, room 247; the pill 230 → 247 in one scanline); at 9 pt ~53%.
  That is the formula as built — opacity at the edge = (beyond / 15) × 0.8 = 0.37 at 7 pt, 0.48 at 9 pt — so the
  half-row-deep fade is there but too weak at the clip to soften a cut through letters. The same look met naturally
  in Starred: `R5d-study-light-1010-zoom-starred.png` (Starred hand-scrolled to its end in the Library view, then a
  note opened — the pitch 30 → 24 left it a few points short): "What's true in everv mode", the descenders cut under
  a light fade. · **DOES NOT HOLD** for overflows of roughly 6–12 pt (the clip falls through descenders while the
  eased strength is still low) — measured in Study light only (the other rooms not re-captured at 7–9 pt; their row
  pitch reads the same in the captures, so the same cut is expected there, unproven).
- **R5 — the current row wholly in view.** (a) TWENTY rapid opens from the Library (sidebar ▸ Library, a title
  click, capture at 2.6 s; ~7 s per open; 18 new rows appended at the bottom, 2 re-opens revealed mid-list — "what
  the door is", "seeing, answering, undoing"): `R5a-01-study-light.png` … `R5a-20-study-light.png` (+`-window` each).
  **20 of 20 show the current row wholly in view**, never cut, never under a fade. **The half-hidden partial row is a
  faint GHOST, never an empty band:** `R5a-19-study-light-zoom-bottom.png` ("the bookcase" readable at ~20–35%
  contrast down to the clip, where U1b's capture had 23 pt of empty room) and `R5a-10-study-light-zoom-top.png` (the
  top partial a ghost under the header); the same ghost in all four rooms (`R2a-<room>-zoom-bottom.png`,
  `R2b-<room>-zoom-top.png`). (c) A deep row opened from the list (`R5c-study-light-0-opened-deep.png`, "the seal",
  whole) → ⇧⌘W → `R5c-study-light-1-shiftcmdw.png` (landed on "export: it's all yours", whole). (d) Following, the
  window to 640 then 480 and back to 1010 (`R5d-study-light-640.png`, `-480.png`, `-1010.png`): at 640 and 480 the
  column overflows and the Open list sits below the fold (the outer column not scrolled — not re-checked there); back
  at 1010 the current row is whole at the list's bottom. (b) not re-walked (time). · HOLDS.
- **R6 — her own scrolling is never pulled back.** (1) The current row revealed near the top, then `walk-scroll`
  40 lines down (the current row off-view): `R6-study-light-a-before.png` → `-t02`, `-t10`, `-t20`, `-t40`, `-t60`,
  `-t90.png` — **the six captures BYTE-IDENTICAL** through 90 s, HID idle 89 s at the end (no input). (2) To the top
  then one wheel line (a middle state, the current row off-view above): `R6-study-light-b-t02/-t20/-t60.png`
  byte-identical through 60 s. (3) Then a resize while scrolled away — 1010 → 760 (`R6-study-light-c-resize760-t02/
  -t10.png`, `-window`: the offset kept, the current row still off-view, not revealed) → back to 1010
  (`-back1010-t02`, `-t20.png`): **byte-identical to the pre-resize capture**, and stayed 20 s more. (4) Her next act
  — ⌘⇧1 opening "o museu", off-view above: `R6-study-light-d-0-before-act.png` → `-d-1-after-open.png`: the list
  FOLLOWED to the top, the row whole, the bottom partial a ghost. Also in Terminal light (where U1b's pull-backs were
  met right after a voice flip): to the top after the flip, `R6-terminal-light-top-t02/-t25.png` byte-identical; and
  every room's shallow state stayed 14 s. · HOLDS.
- **R7 — nothing regressed (Study light).** `R7-study-light-tall.png` (+`-window`, `-zoom-bottom`): the tall list stops
  just above the sync footer, the last row whole, nothing under the footer. `R7-study-light-scrolling.png`
  (+`-zoom`, captured mid-scroll): the overlay bar at x ≈ 442–453 px of the 480-px sidebar, every ✕ ending by ~420 px
  — in the margin beside the ✕. · HOLDS.
- **R8 — restore and release.** MY instance quit by identity (`tell application id … to quit`); both strict pgreps
  empty after. With zero dev instances the three store files were copied back from `u1d-walk/store-before/` and each
  `cmp`-verified byte-identical (the `.sqlite` was already identical; `-wal` and `-shm` had changed). No new file in
  `Backups/` (its mtime Oct 14 09:17); `castle-W1-20261013` untouched (its files Oct 13). Prefs: the walk ADDED 18
  `currentBlock.*` keys (each deleted by hand) and CHANGED 6 (`openNotes.remembered.ids`/`.recency`, both window
  frames, the backup log, the idle-sweep mark); `defaults import` of `prefs-before.plist`, re-export
  (`u1d-walk/prefs-after-restore.plist`), diff CLEAN (1602 = 1602, none added, removed or changed). The voice (a store
  setting) and appearance (`system`) were also set back in Settings before quitting. Posture Standard/unlocked
  throughout. · HOLDS.

**OBSERVATIONS (outside the verdicts — for the orchestrator's eye):**
- **O-1 — a sliver no deeper than a row's top padding still leaves an empty band.** The middle state ("to the top,
  then one wheel line") in the Library view lands with ~4 pt of the next row in view — its top padding, no ink:
  `R2b-<room>-zoom-bottom.png` (all four rooms) and `R6-study-light-b-zoom-bottom.png` show the last whole row
  ("the classics walk" / "membership, not ownership") UNFADED, then ~26 pt of plain room down to the footer hairline,
  with two to seven rows below — pixel-measured, no ink in the band. The bottom reads as the list's end (the end
  state's own gap is ~20 pt). The implementer recorded this edge ("a sliver thinner than its row's top padding shows
  no ink under any cap — that is the clip, not the fade"); it is O-3's empty band in a narrower offset window. Her
  ruling's "a hint of the next row always shows" is not met there; whether it matters is a call above the walk.
- **O-2 — R4's slice is the strength ease meeting the clip** (the DOES NOT HOLD above): at the edge the paint is
  `strength × 0.8` with strength = beyond / half-row, so between ~6 and ~12 pt beyond the cut through descenders keeps
  half or more of its contrast. At ≥ 15 pt beyond the edge keeps 20% (the cap — a faint clipped ghost, reads soft);
  at ≤ ~5 pt the clip falls in the row's bottom padding (nothing to slice). So the visible slice lives in a band of
  offsets a hand scroll lands in often.
- **O-3 — Starred keeps its points across the pitch flip after a hand scroll.** Hand-scrolled to its end in the
  Library view (30-pt rows), Starred in the note view (24-pt rows) sits a row short of its end, both edges faded —
  by design under the follow rule (not following; no current row in Starred), noted because that is how it met O-2's
  slice without any further input.
- O-4 — at 640/480 pt the outer column overflows and the Open list is below the fold; R5(d) checked the row only
  after returning to 1010 (U1b's walk had scrolled the outer column; not repeated).
- The fade takes the room's colour in all four rooms — no grey band over black in either dark room
  (`R4shallow-*-dark-zoom-*`, `R2a-*-dark-zoom-bottom.png`).

### U2 — the drag (VX-288, the light version + the compact chip on the Open list's rows)

**Implementer:** a fresh Opus 5.5 at xhigh (2026-10-15, overnight), worktree `~/dev/variorum-vx-283`, DerivedData
`App/Variorum/DerivedData/vx283-u2`. **Not done by this session (first line):** any stage work (the Mac batch, the
behavioural revert's run) until the orchestrator hands over a claim; the walk (a fresh walker's — the line, the settle
and the chip are walk evidence); edge auto-scroll during a drag (the M shape, out of scope).

**LIVE STATUS (per piece)**
- E0 — this section + the trace verified on this tip: DONE (this commit).
- E1 — the pure drop rule (`SidebarLayout.OpenListDrop`: the gap under the pointer, the onMove destination with the
  false-offer nil, the line's place, the end zone's height) + its pure pins (`OpenListDropRuleTests` ×14 in the new
  `VariorumTests/OpenListDragTests.swift`) + the stale List-drag comments corrected (`WorkspaceNavigationTests`): DONE
  (this commit) — a headless REPLICA (the real `SidebarLayout.swift` + `OpenNotes` compiled beside the pins' bodies,
  scratchpad only): 1165 checks, 0 failed; with R-K's patch (below) 229 failed. The suite's run PENDING the window.
- E2 — the delivery (one drop delegate on the list's rows + the end-zone band; the drag state; the insertion line as
  an overlay above the edge fade; the settle) + the chip (the Bookcase's grab canvas moved to `Core/Views/`, reused) +
  the door, face and mounted pins: DONE (`5e1f43eb`) — headless `build-for-testing` green; the runs PENDING the window.
- E3 — R-K named below BEFORE it is applied (this commit); then prebuilt into `DerivedData/vx283-u2-rk` and restored:
  IN-PROGRESS — **R-K is NOT yet in the tree.**

**THE TRACE (this tip, `9643aaf6`; paths under `App/Variorum/Variorum/`):** the Open row drags with the system drag
and each row is its OWN drop target (`Features/Library/SidebarView.swift:1032-1041`): `.draggable(OpenNoteDragToken)`
and `.dropDestination(for: OpenNoteDragToken.self) { tokens, _ in … moveOpenNotes(fromOffsets: [source], toOffset:
target) }` where `target` is the index of the row UNDER the pointer — the drop location is ignored. In the onMove
convention (`Workspace/WorkspaceNavigation.swift:361-382`, `destination` = a PRE-move gap index), `toOffset: target` is
always the gap BEFORE that row. So, inputs → wrong state: [a, b, c, d], drag a onto b → `move([0], 1)` → the insertion
shifts left by the one moved row before it → index 0 → **nothing changes** ("the row just below is unreachable");
drag a onto d → `move([0], 3)` → [b, c, a, d] — **one row short** of where she aimed, for every downward drop; no
target exists after d → **the last slot is unreachable** (no end zone). The move is applied UNANIMATED
(`Workspace/WorkspaceModel.swift:505-508`), there is no hover feedback, and the drag image is the system's snapshot of
the whole row. The pins (`VariorumTests/WorkspaceNavigationTests.swift:226-275`) check only `OpenNotes.move`'s
arithmetic, and their comment still says "the drag route itself is AppKit's inside the List" — the List is long gone.

**THE DESIGN (being built; PROVISIONALs listed as they land):**
- The drop rule is PURE (`SidebarLayout.OpenListDrop`): a pointer's y over the rows names a GAP (0…rows) — the lower
  half of a row is the gap AFTER it, the upper half the gap BEFORE it, below the last row the end; the onMove
  destination IS that gap, and it is nil at the dragged row's own two gaps (the drop would change nothing — §12's
  false-offer rule: no line, and the drop is refused so the image slides back).
- ONE drop delegate on the list's scroll CONTENT (its location is the content's own space — the row arithmetic needs
  no scroll offset), plus an END ZONE band under the rows; the system drag stays (`.draggable` with a preview).
- The insertion line: 2 pt in the ring token, the book navigator's precedent, as an OVERLAY on the list (above the
  edge fade), placed from the pointer's place in the VIEWPORT + the list's scroll offset + the rows + the pitch — so
  it re-derives on every input axis (hover, scroll, list change) and never before a reading exists.
- The settle: the move lands inside an animation on the column's one beat (`SidebarLayout.railTransition`).
- The chip: the Bookcase's compact title chip at the grab point (R-LWP-3's `BookDragSource` canvas), moved to the
  shared home and reused on the Open list's rows only.

**THE BUILD (`ff91d897` the rule, `5e1f43eb` the delivery and the chip; paths under `App/Variorum/Variorum/`):**
- `Core/Views/SidebarLayout.swift` — `OpenListDrop` (pure): `gap(at:rowHeight:rows:)` (the half of the row decides;
  the midpoint counts as lower, as the editor's block drag settles; above the rows 0, below them the end);
  `gap(for: Hover, offset:…)` (a hover is held in the VIEWPORT — `.rows(viewportY:)` — or `.end`);
  `destination(gap:dragged:rows:)` (the onMove destination IS the gap; nil at the dragged row's own two gaps or off the
  list); `lineTop(hover:dragged:rows:rowHeight:window:)` (the line's top in the viewport, every input an argument; nil
  with no hover, no drag of this list's, no reading, no pitch or a no-change gap; held inside the rows at both ends and
  inside the window); `endZoneHeight(…)` (the room under the rows above the bottom padding, from VX-285's own two
  measurements, capped at 28 pt; 0 when the rows fill the list or before measurement).
- `Features/Library/OpenListDrag.swift` (NEW) — `OpenListDragState` (`@Observable`: which row a drag of THIS list's
  began on, the hover, the list's window copied in only while a drag hovers — an ordinary scroll re-renders nothing);
  `OpenListDropDoor` (`types`, the `settle` animation, `proposal` — `.move` where the line is drawn, `.forbidden`
  where a drop changes nothing so the image slides back — `perform` and the one landing act `land(token:atGap:…)`);
  `OpenListRowsDrop` / `OpenListEndZoneDrop` (`DropDelegate`s); `OpenListInsertionLine` (the overlay: 2 pt,
  `tokens.ring`, across the rows' width, placed by LAYOUT so its frame is where it draws, no hits, hidden from
  accessibility; a DEBUG tap reports its global frame).
- `Features/Library/SidebarView.swift` — the token gains `listID` (and goes `nonisolated` + `Sendable`, the
  Bookcase tokens' shape; `contentType` named once); `@State openListDrag`; the list's CONTENT carries the one drop
  (`.contentShape` + `.onDrop(…OpenListRowsDrop)`); a non-DEBUG `onScrollGeometryChange` feeds the state (the line's
  scroll axis); `.overlay { openListLine(shown) }` right after `SidebarSectionWindow` — ABOVE the edge fade; the END
  ZONE (`openListEndZone`) is the group's last child under the list (Color.clear, its own drop); the row trades
  `.draggable` + its per-row `.dropDestination` for `ChipDragSource` (the payload records the drag's start and names
  the list) with `Self.openRowChip` as its image. DEBUG oracles: `SidebarGeometry.openListDrags` / `openListLines` /
  `openListEndZones` (keyed by the column's workspace, cleared by `forgetSections`).
- `Core/Views/DragChipCanvas.swift` (NEW) + `Features/Shelf/ShelfView.swift` — **the Bookcase's chip machinery
  MOVED to the shared home at its second consumer** (CLAUDE.md's placement rule): `DragChipPlacement` (the pure
  placement, verbatim), `DragChipCanvas` (the private `GrabCanvas`, verbatim), `DragTitleChip` (the chip's face, a
  `font` parameter), `ChipDragSource` (the grab-tracking drag source, generic). A parity move: `BookDragChip`,
  `BookDragSource.chipCenter` / `.placement` / `.canvas` keep their names and answers (now forwarding), and
  `BookDragSource`'s body rides `ChipDragSource`; `BookcaseDragFaceTests` untouched. **A file outside the declared
  lanes (`ShelfView.swift`), touched only by this parity move — said here for the orchestrator.**
- **Not touched:** `SidebarSectionWindow.swift` (no hook was needed — P-U2-1 below), `WorkspaceModel.move`/
  `OpenNotes.move` (their arithmetic was right; the bug was the gap fed to them), `ShellActions`, `ShellRouter.swift`,
  the editor seam, `Sync/`, custody, schema.

**PROVISIONALs (U2):**
- **P-U2-1 — following and the drag (the brief's ask).** A drop is neither her ACT (it changes no current row) nor
  her HAND (it reports no scroll phase), and it never scrolls the list: the rows rearrange in place under the pointer;
  a list that FOLLOWS keeps following (a later resize, rail or pitch change keeps the current row in view, as ruled); a
  list she scrolled away stays where she put it. During the drag nothing moves the list either (no phase, no geometry
  change; edge auto-scroll is the M shape, out of scope). Consequence, stated: a row moved from below the current row
  to above it shifts the current row down one — it can sit under the bottom fade until her next act or a following
  input. No hook into `SidebarSectionWindow` was needed. Options: (a) [built]; (b) a drop ends following like a hand
  scroll (then even a resize leaves a shifted current row cut); (c) a drop re-reveals the current row at once while
  following (the list can jump up to a row right after the drop, under the pointer, fighting the settle).
- **P-U2-2 — the end zone's extent:** the room under the rows, capped at the book navigator's 28 pt; absent when the
  rows fill the list (scrolled to its end, the last row's lower half is the end slot). Options: (a) [built]; (b) all
  the room below the list down to the footer; (c) a fixed 28-pt zone always in the layout (it would move the list's
  stop above the footer — VX-285's ruled height — and U1's pins).
- **P-U2-3 — a drop acts only on the list its drag began in** (the token names its list): a row dragged in from
  another window's Open list is refused there, with no line. Before, the row-level target moved that window's row of
  the same note if it had one. Options: (a) refuse [built]; (b) accept, moving this window's row of that note;
  (c) accept and OPEN the note in this window's list at the drop (new behaviour).
- **P-U2-4 — the settle:** `.snappy` over the column's one beat (`SidebarLayout.railTransition`, 0.22 s — her
  "snap into place"). Options: (a) [built]; (b) `.easeInOut` over the beat (the rail's curve); (c) a spring with a
  visible bounce.
- **P-U2-5 — the chip's face:** the row's title alone, semibold in the sidebar's navigation font, on the surface with
  a hairline (the Bookcase chip's look at the sidebar's register); no ordinal, no wing name. Options: (a) [built];
  (b) the Bookcase's body size; (c) carry the ⌘⇧n ordinal.
- **P-U2-6 — the line's reach and layer:** across the rows' full width (the wash's rectangle — the book navigator's
  span), drawn ABOVE the edge fade (a line at a faded edge is never dimmed); a boundary just past a scrolled edge
  shows AT that edge. Options: (a) [built]; (b) under the fade, inside the scroll content; (c) inset to the rows' text
  edge (the editor's bar spans the text).
- **A known edge, not provisional:** a drag released OUTSIDE the list leaves the list's `dragging` stale until its
  next drag begins — harmless (the hover clears on exit, and a drop is decided by the PAYLOAD's list id), except that a
  row dragged in from another window's list after such a cancel would draw a line where the drop then does nothing.
  The session-end callback that would clear it (`onDragSessionUpdated`) was deliberately not used: its order against
  `performDrop` is unverified, and the wrong order would break every drop.

**PINS (`App/Variorum/VariorumTests/OpenListDragTests.swift`, NEW; all PENDING the stage window):**
- `OpenListDropRuleTests` ×14 (pure): the half names the gap; **the row just below is reachable · a downward drop no
  longer lands one row short · the last slot is reachable** (the ticket's three, RED ON OLD); an upward drop; the
  dragged row's own gaps offer nothing; **every drop lands beside the row under the pointer** (exhaustive: 1…6 rows,
  every dragged row, every target, both halves at six depths — RED ON OLD); the line on the boundary; the line follows
  the hover · a scroll under a still pointer · a change of the list (the delivery law, pure); no line before a reading
  or without a drag of its own; the line stays inside the window; the end zone's height.
- `OpenListDropDoorTests` ×8: a drop lands where its line was drawn (RED ON OLD); the end zone lands the last slot
  (and the last row over it offers nothing); a drop on its own place offers nothing and moves nothing; a drop acts only
  on its own list (P-U2-3); a scroll under a still pointer moves the gap through the state; moving between the rows and
  the end zone never blanks the line (either exit order); **a release reads the PAYLOAD from a real `NSItemProvider`
  and lands it** (the whole road after AppKit, short of the pointer); a release that offers nothing refuses and ends the
  drag.
- `OpenListDragFaceTests` ×2: the Open row's chip rendered at three grab points — its ink centred on the grab, whole,
  one line (`BookcaseDragFaceTests`' render helpers); a source read — the row drags through `ChipDragSource` with its
  chip and has NO `dropDestination` of its own; the list's content is the one drop; the end zone and the line are
  wired; the Bookcase reads the same machinery and no second canvas exists.
- `OpenListDragMountTests` ×3 (a mounted column, `SidebarSectionWindowTests`' host shape, its own rig):
  **`theLineDrawsWhereTheDropWouldLandOnEveryAxis`** — the overlay/sink law AS DRAWN: the line where the rule says;
  the hover moving; the list's clip view scrolled 1.5 rows under a STILL pointer (redrawn where the rule now says, and
  it really moved); a row above closing (re-derived); the list changing so the gap under the pointer becomes the
  dragged row's own (the line goes); the pointer on the dragged row (none); the drag leaving (none).
  **`aDropSettlesInPlaceAndNeverMovesTheList`** (P-U2-1 — exact behaviour: the current row revealed, a drop above it,
  the window's offset unchanged; scrolled to the top, a drop leaves it there). **`theEndZoneTakesTheRoomUnderTheRows…`**
  — 28 pt directly under the rows, inside the column above the footer's air; absent with twenty rows.

**Headless evidence:** `build-for-testing` → **TEST BUILD SUCCEEDED** (`DerivedData/vx283-u2`, `5e1f43eb`'s code; no
warning in a touched line — the three in `ShelfView.swift` are older `Text +` lines). The pure suite replicated
against the real `SidebarLayout.swift` + `OpenNotes` (scratchpad): **1165 checks, 0 failed**; under R-K **229 failed —
exactly the 11 pure pins named below**. The `fixedSize` lint replicated over the tree: 90 sites, 0 offenders.

**THE REVERT (named BEFORE it is applied; prebuilt into its own DerivedData, restored by `git checkout --` from the
commit, `git diff` empty after):**
- **R-K (the traced bug — drop-before-the-row-under-the-pointer, no end slot):** in `Core/Views/SidebarLayout.swift`,
  `OpenListDrop.gap(at:)` — the three lines from `guard row < rows else { return rows }` through `return within >=
  rowHeight / 2 ? row + 1 : row` become `return min(row, rows - 1)`. Products: `DerivedData/vx283-u2-rk`. Expected
  RED, exactly (16): `OpenListDropRuleTests` — `theHalfOfTheRowUnderThePointerNamesTheGap`,
  `theRowJustBelowIsReachable`, `aDownwardDropNoLongerLandsOneRowShort`, `theLastSlotIsReachable`,
  `anUpwardDropLandsWhereItLooks`, `everyDropLandsBesideTheRowUnderThePointer`,
  `theLineSitsOnTheBoundaryTheHoverNames`, `theLineFollowsTheHover`, `theLineFollowsAScrollUnderAStillPointer`,
  `theLineFollowsAChangeOfTheList`, `theLineStaysInsideTheWindow`; `OpenListDropDoorTests` —
  `aDropLandsWhereTheLineWasDrawn`, `aScrollUnderAStillPointerMovesTheGap`,
  `movingBetweenTheRowsAndTheEndZoneKeepsTheLine`, `aReleaseReadsThePayloadAndLandsIt`; `OpenListDragMountTests` —
  `theLineDrawsWhereTheDropWouldLandOnEveryAxis`. GREEN (the rule's other arms): `theDraggedRowsOwnGapsOfferNothing`,
  `noLineBeforeTheListIsReadOrWithoutADragOfItsOwn`, `theEndZoneIsTheRoomUnderTheRowsCapped`,
  `theEndZoneLandsTheLastSlot`, `aDropOnItsOwnPlaceOffersNothingAndMovesNothing`, `aDropActsOnlyOnTheListItsDragBeganIn`,
  `aReleaseThatOffersNothingRefuses`, `aDropSettlesInPlaceAndNeverMovesTheList`, `theEndZoneTakesTheRoom…`.

#### U1d — THE ORCHESTRATOR'S EYE AND RULING ON THE RE-WALK (2026-10-15 ~02:25 — P-U1e-1)

The re-walk holds R0–R3, R5, R6 (her scroll never pulled back — byte-identical through 90 s, a resize, and following
again on her next act), R7, R8. **R4 holds at 5 pt short and DOES NOT HOLD at 7–9 pt short**: the orchestrator's eye on
`u1d/walk/R4shallow7-study-light-zoom-bottom.png` — "export: it's all yours" cut through its descenders under a fade
still weak (the walker measured ~60 % contrast at the cut at 7 pt). `R5a-19-study-light-zoom-bottom.png` — the
half-hidden row now a faint ghost — reads right. **The mechanism (the walker's O-2, matching the formula as built):**
the strength ramps over a half row (12–15 pt) while the clip reaches ink at ~6 pt (inside the row's own padding), so
between ~6 and ~12 pt beyond, the clip cuts ink under a weak fade.

**RULED (P-U1e-1, PROVISIONAL):** the fade's STRENGTH reaches full over the row's own top text padding (a named
constant measured from the row's text inset at each pitch — ≈ 6 pt; the implementer records the measured value),
not over the half row — so by the time the clip can touch ink, the fade is at full strength (its 0.8 cap). The depth
stays the half row; the ease-in stays (a ramp over a few points of scroll, never a pop). This also gives O-1's
near-empty band (≈4 pt of a row's padding beyond the edge) a visible fade over the last whole row's foot — the
"there is more" hint. Rides U2's leg as a separate piece (U2's implementer already works in `SidebarLayout.swift`):
pure pins for the ramp, R-K (revert to the half-row ramp) red on them; U2's walk re-checks R4 at 5/7/9/12 pt short in
two rooms and O-1's state.

## Ladder

*(Findings and dispositions land here, repo-first, before any fix session sees them.)*
