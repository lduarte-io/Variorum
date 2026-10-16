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
- **THE RELEASE — her call (2026-10-15 15:58).** She said it to the coordinator directly, and it was relayed to us
  verbatim by the coordinator and by vx-336: *"ok. as originally planned, we will wait for x283 to merge in and then
  x283 will release a single release (0.9.7) covering both your work & their work. it should not bump the version
  again, since this one was not yet released. you can give the stage to x283 so they can walk and finish up their
  work"*. So:
  - VX-283 cuts ONE **0.9.7** after its merge, covering VX-336 and VX-283, and ends the window with the /Applications
    refresh.
  - **No version bump.** Main's `28ca7fd2` already set MARKETING_VERSION 0.9.7, and vx-336's release stopped
    mid-archive with nothing published.
  - Our section goes into the existing `Features/WhatsNew/ReleaseNotes-0.9.7.md`, above its Feedback section, in
    0.9.6's form (a bold lead line, then bullets, one line per bullet: the VX-343 trap). VX-336's lines stay as they
    are. Her notes review is waived (her overnight word).
  - The worked road is "THE RELEASE BRIEF" at the end of `notes/plans/fixes/vx-336-mcp-wire-tools-ai-docs.md` (its
    bump step doesn't apply). The notes commit is the one commit before `release.sh`, and the main freeze runs from it
    until the stamp.
  - Main is merged into this branch again before the merge ask.
  - This supersedes the 0.9.8 plan in the overnight state.
- **HER SECOND OVERNIGHT MANDATE (2026-10-16 ~06:44, verbatim, to the orchestrator):** *"I'll be sleeping finish
  everything and send the fresh install to the website overnight."* So VX-283 finishes in her absence, ruling
  provisionally where the run needs it: U2c → its window → the re-walk → ladder round 2 → closeout → merge. It then
  publishes the ONE 0.9.7 (VX-336 + VX-283) to the website per her 15:58 call, and ends the release window with the
  /Applications refresh under the coordinator's rule card. Her notes review stays waived.

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
  `ShellChromeTests.theOpenStripWindowIsHerSevenAndAHalf` *(renamed at R1-5 → `SidebarLayoutTests.theOpenListsTallestFormIsTheRoomDownToTheFooter`, the same file)*, `StarredScrollTests.theWindowIsOneConstantForBothScrollingSections`.
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
| U1 | VX-286 · VX-285 · VX-287 · VX-289 — the Open list's layout and closing | **PROVEN — awaiting U2's walk for P-U1e-1** (the fade ramp rides U2): U1 built + walked; U1b/U1c fix legs; U1d (her memo rulings) window GREEN (434/96, R-I/R-J red as named, 01:44–01:50) and re-walk HOLD on R0–R3, R5–R8 (R6 her scroll never pulled back); R4's 7–9-pt slice → P-U1e-1 built in U2's leg, verified by U2's window + walk. |
| U2 | VX-288 (+ the chip on the Open list's rows) — the drag, light version; + P-U1e-1 (VX-286's fade ramp) | **READY FOR STAGE — U2d window (pins/reverts/batch), then the re-walk.** U2d built F2 on main's own per-row API (P-U2d-1): pins `99565d41`, fix `63b8c191`, five revert trees named and built (R-W/R-X/R-Y/R-Z/R-Q), `u2d/window.sh` with every step's expected result; PROVISIONAL P-U2d-2 (the end zone takes the bottom padding — never absent). Synthetic drags cannot reach sidebar drops (the main-build control), so delivery is her hand check, first in her morning checklist. D5 (P-U1e-1) and D6 HOLD. |
| U3 | VX-121 · VX-175 · VX-20 · VX-245 (+ VX-359) — the Library and the red lint | **W1/W3/W4/W5 PROVEN.** U3b's band traced (U3c: the segmented pickers answered two ways after a search) → **P-U3c-1 built and PROVEN** (window 16:43–16:54: pins 23/3 green; R-P exactly 4 red; U3b's 103-suite batch 513 green). **OWED: D8's re-walk** on `vx283-u3c` (folded with U2b's). |
| Ladder | `fable-reviewer` at xhigh (her word, superseding opus at max), fresh per round, cross-model | **ROUND 1 DONE** (tip 448f9450; findings in the Ladder section, `9ef6fba3`): 0 BLOCKER · 0 MAJOR · 2 MINOR (R1-1 this table — fixed here; R1-2 sequencing — the windows owed) · 4 NIT (R1-3…6 → the implementer). Round 2 re-reviews the fixes + the U2/U3b window results. |
| Closeout | the merged-tip runs, canon deltas, tickets, MOBILE PARITY, handoff, merge, refresh | NOT-STARTED |

## Stage traffic log (oct13coordinator protocol)

*(The orchestrator appends each REQUEST / READY / GO / RELEASE here.)*

- 2026-10-16 07:04 GO `vx283-u2c` (90 min, folded); G1 failed → the main-build control folded in at the coordinator's yes (07:09–07:12); RELEASED 07:12:31 with the control's own instance still up (the slip — quit at ~07:13, the store re-verified, prefs clean; told).
- 2026-10-15 17:06 GO `vx283-u2b` (25 min; HID idle 528 s at the GO, her clearance standing); RELEASED 17:08:32 — "dev store restored + verified, prefs diff clean, posture Standard/unlocked, castle-W1 untouched".
- 2026-10-15 16:43 GO `vx283-u3c` (25 min); RELEASED 16:54:31 — "dev store restored + verified, prefs diff clean, posture Standard/unlocked, castle-W1 untouched".
- 2026-10-15 15:59 GO `vx283-walk` (15:58:41, 65 min); the walk 15:59–16:21; SEAM, continue pre-given; the U3c probe folded in 16:23–16:25; RELEASED 16:25:43 — "dev store restored + verified, prefs diff clean, posture Standard/unlocked, castle-W1 untouched".
- 2026-10-15 15:32 GO `vx283-u2` (the coordinator; HID idle 3 h, her word "Now, I'm off the Pro"). 15:31:45 claimed (95 min). 15:50:46 RELEASED at the SEAM — "dev store restored + verified, prefs diff clean, posture Standard/unlocked, castle-W1 untouched"; the stage to `vx336-release` (0.9.7). REQUEST sent: `vx283-walk` (≈55 min) after it.

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
pins changed BY HER ASK, edited in place with a VX-285 annotation:** `ShellChromeTests.theOpenStripWindowIsHerSevenAndAHalf` *(renamed at R1-5 → `SidebarLayoutTests.theOpenListsTallestFormIsTheRoomDownToTheFooter`, the same file)*,
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
- E3 — R-K named below before it was applied; applied, prebuilt into `DerivedData/vx283-u2-rk` (TEST BUILD SUCCEEDED
  on `5e1f43eb`'s code; patch `notes/plans/vx283-screens/u2/reverts/R-K.patch`, gitignored), restored by `git checkout
  --`, `git diff` empty: DONE. To be REBUILT on the tip after E4 (the ramp), so the revert tree is HEAD minus R-K only.
- E4 — **P-U1e-1, the orchestrator's added piece (VX-286):** the fade's strength ramps over the row's text padding —
  DONE (`6bc31673`, its own commit; the section below the reverts); R-N named below BEFORE it is applied (this
  commit) — **R-N is NOT yet in the tree.**
- E5 — the three trees on the tip `b24c209e` (the code of `6bc31673`): `DerivedData/vx283-u2` (HEAD), `-rk` (R-K
  re-applied on the tip), `-rn` (R-N) — each TEST BUILD SUCCEEDED, each revert restored by `git checkout --`, **no
  revert is in the tree** (`git diff` empty); patches `u2/reverts/R-K.patch`, `R-N.patch` (gitignored): DONE.
- E6 — **READY FOR STAGE (≈15 min)** — the script `notes/plans/vx283-screens/u2/window.sh` (gitignored), from
  `App/Variorum/`, in order: (0) `pre` — strict pgreps, "tree clean", the Debug prefs exported, the dev store's three
  files copied to `u2/store-before/<UTC>/` with zero dev instances; (1) `batch` — `test-without-building` on
  `DerivedData/vx283-u2` with one `-only-testing:VariorumTests/<Suite>` per line of `u2/batch-suites.txt` (**144
  suites**: every top-level suite of the 63 test files referencing `SidebarLayout|SidebarView|SidebarGeometry|
  SidebarSectionWindow|RootView(|ShelfView|BookDragSource|BookDragChip|OpenListDrag|OpenNoteDragToken|DragChip|
  DragTitleChip|OpenListDrop`, + `NoLiteralColourTests`, `ChromeLineLimitTests`, `CapabilityRegistryTests`,
  `DragTypeDeclarationTests`, `WorkspaceNavigationTests`' suites; U1d's 96 all among them) — expected all green but
  the known `BookCollectingDoorsTests.theSettingsDoorIsOneActOnBothRoads` (VX-115, red on main, untouched here),
  the env-gated harnesses skipped (record the "Test run with N tests" line AND the skipped lines); (2) `mount` —
  `OpenListDragMountTests` + `SidebarSectionWindowMountTests` `-test-iterations 3`, expected 3/3 green; (3) `rk` —
  R-K's products, `OpenListDropRuleTests` + `OpenListDropDoorTests` + `OpenListDragMountTests`, expected RED exactly
  the 16 named under R-K; (4) `rn` — R-N's products, `SidebarSectionWindowRuleTests` + `SidebarSectionWindowMountTests`,
  expected RED exactly the 4 named under R-N; (5) `restore` — the store copied back + `cmp`, prefs diffed (added keys
  deleted by hand, `defaults import`, re-export, diff clean), castle-W1 untouched; then delete `DerivedData/vx283-u2-rk`
  and `-rn` (keep `vx283-u2` for the walker); release.
- **What only the WALK can prove** (a drag cannot be posted in the test host): a real drag (`cliclick dd/dm/du`)
  shows the 2-pt ring line where the drop will land and the title CHIP under the cursor (no offset); a drop on the row
  just below, a long downward drop, the end zone and an upward drop land where the line said, with the SETTLE; no line
  (and a slide-back) over the dragged row's own place; a file dropped on the list still imports (the column's own
  drop); the ✕, click, right-click and ⌘⇧n still work on the rows; the Bookcase's book drag still shows its chip at
  the cursor (the shared move) — both voices; and for P-U1e-1, R4 at 5 · 7 · 9 · 12 pt short in two rooms and O-1's
  state (the orchestrator's message).

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

**P-U1e-1 — THE ORCHESTRATOR'S ADDED PIECE (VX-286; the ruling "U1d — THE ORCHESTRATOR'S EYE AND RULING ON THE
RE-WALK", `796a2f25`), riding this leg as its own commit `6bc31673`:** the edge fade's STRENGTH reaches full over the
row's own text padding, not over the half row; the depth (the half row) and the ease-in stay.
- **The measurement (offscreen, scratchpad only — `ImageRenderer` at 4×, the row's own shape: a 13-pt title in the
  navigation font, 8 pt side padding, centred in the row):** the line box is **16 pt** in both voices (Study
  `.system(size: 13)`, Terminal the same size monospaced: `NSLayoutManager.defaultLineHeight` 16.0, ascender 12.57,
  descender 2.74, no leading), so the row's text padding is `(rowHeight − 16) / 2` = **7 pt at 30, 4 pt at 24**. The
  first INK, both voices, regular and semibold, over "export: it's all yours" / "Hdlkbt fgjpqy" / "note 7": **7.25–7.5 pt
  above a 30-pt row's bottom** (the descenders) and 9.25–10.5 below its top; **4.25–4.5 above a 24-pt row's bottom**
  and 6.25–7.5 below its top. So the padding ends before any ink at every pitch, voice and weight (the orchestrator's
  "≈ 6 pt" is these two, 7 and 4, per pitch).
- **The build (`Core/Views/SidebarLayout.swift`):** `rowTextLineHeight = 16` (the measured line box, its reason at the
  line); `edgeFadeRampDistance(rowHeight:)` = `max(1, (rowHeight − 16) / 2)`; `edgeFades(_:depth:ramp:)` — the
  strength is `min(1, beyond / ramp)`, the ramp read from the pitch the depth is half of unless one is given (so
  `SidebarSectionWindow.swift` and every caller are untouched). Consequences: R4 at 30 pt — 5 pt short eases (5/7 of
  the cap), 7 · 9 · 12 whole; at 24 pt, 4 pt beyond is whole; the first fade past the 0.5-pt slack is 7 % (30 pt) /
  12.5 % (24 pt) of the cap — a ramp over a few points, never a pop; O-1's ≈4-pt band now fades whole at 24 pt.
- **PROVISIONAL P-U1e-1** (the orchestrator's; recorded there). P-U1d-2 ("linear over the half row") is SUPERSEDED by
  it — linear over the text padding.
- **The pins (`VariorumTests/SidebarSectionWindowTests.swift`) — changed IN PLACE by the ruling, each annotated:**
  `theFadeIsAlwaysHalfARowDeepAndItsStrengthEasesIn` (4 pt above: 4/7; 3 pt below: 3/7; 8 pt below: whole; the first
  fade < 10 %; the ease's step bounded by 0.1/7 per 0.1 pt); `theFadeIsNeverFullySolid` (the compact 5-pt state is
  whole AT THE CAP now; a new 3-pt faint state, 3/4 of the cap); the mounted `aShallowOverflowFadesTheWholeHalfRowFaintly`
  (the strength is `beyond / ramp`). **NEW `theFadeIsWholeBeforeTheClipReachesInk`** — the line box 16; the ramp 7 at
  30, 4 at 24; at the MEASURED first ink (7.25 / 9.25 at 30, 4.25 / 6.25 at 24) both edges whole; R4's 5 · 7 · 9 · 12 pt
  short at 30 (5/7, 1, 1, 1). Headless replica (the real `SidebarLayout.swift` + the RuleTests' bodies, scratchpad):
  **8734 checks, 0 failed**; under R-N **exactly the three pure pins below red**.
- **THE REVERT, named BEFORE it is applied — R-N** (the orchestrator's message called it "R-K"; R-K was already this
  leg's drop-rule revert, so the ramp's is **R-N**): in `edgeFades`, `strength: min(1, beyond / max(reach, 1))` →
  `strength: min(1, beyond / depth)` (U1d's half-row ramp). Products: `DerivedData/vx283-u2-rn`. Expected RED, exactly:
  `SidebarSectionWindowRuleTests.theFadeIsWholeBeforeTheClipReachesInk`, `.theFadeIsAlwaysHalfARowDeepAndItsStrengthEasesIn`,
  `.theFadeIsNeverFullySolid`, `SidebarSectionWindowMountTests.aShallowOverflowFadesTheWholeHalfRowFaintly`; every
  other pin of the two suites GREEN.

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

### U3b — the controls row, stable (VX-175 — P-U3-5, the walk's W2 F-1 and F-2)

**Implementer:** Opus 5.5 at xhigh (fresh session, 2026-10-15). Worktree `~/dev/variorum-vx-283`, DerivedData
`App/Variorum/DerivedData/vx283-u3b` (the revert tree's `vx283-u3b-rv`). **Not done by this session (the record's first
line, per the brief):** any stage work (the batch, the revert run, the re-walk of W2) — until the orchestrator hands
over a claim; the sidebar (not mine).

**LIVE STATUS (per piece)**
- S0 — the trace, verified on this tip (`bf09054b`): DONE (below).
- S1 + S2 — the rule reads stable widths; the widths measured and handed down; the relevance label one line: DONE
  (`3ab7ad9e`). Headless `build-for-testing` green on `vx283-u3b` (cloned from `vx283-u2`); no new warning in the three
  files (the two `probeSpace` Sendable warnings are the pre-existing pair U3 recorded).
- S3 — the pins: DONE (`ed58c2ac`), compiled in the same build. All PENDING the stage window.
- S4 — the revert tree **R-S** (named below, before it was applied): DONE — applied from the committed tip `a4a68295`,
  `DerivedData/vx283-u3b-rv` APFS-cloned from `vx283-u3b` and built (`build-for-testing` succeeded; the log shows
  `LibraryControlsFlow.swift` and `LibraryCatalogView.swift` recompiled), RESTORED by `git checkout --` the two files,
  `git diff --quiet` empty. **No revert in flight.** The window script `notes/plans/vx283-screens/u3b/window.sh`
  (gitignored) written. **R-S REBUILT — DONE** (after `1fc34c2e`, a test-only premise check in the sweep pin: every
  room's catalog must be the width it asked for): `vx283-u3b` rebuilt (`build-for-testing` succeeded); the same two
  edits applied from the committed tip `0c4708a7`, `vx283-u3b-rv` re-cloned from it and built (succeeded; both reverted
  files recompiled), RESTORED, `git diff --quiet` empty. **No revert in flight.**
- **S5 — READY FOR STAGE** (≈15 min; ≈11 without the optional step). `window.sh` from any directory, in order:
  `pre` (instances, App/ clean, prefs export, the store's three files into `u3b/store-before/<UTC>/`) · `batch` (≈6
  min — `test-without-building` on `vx283-u3b`, **103 suites** = every suite in the 45 test files naming a type of the
  three changed sources (`LibraryControlsFlow*`, `LibraryControlsStableWidths`, `LibraryCatalogView` and its row types,
  `LibraryInfoPanel`/`LibraryPanelOracle`/`LibraryProbeSlot`/`LibraryPanelLayout`/`LibraryPreview`), the catalog's
  source-read pins, `ChromeLineLimitTests` (a `fixedSize` was added) and every `RootView(` mount — `u3b/suites.txt`,
  `u3b/files.txt`; expected all green, the opt-in rig suites SKIPPED) · `rv` (≈3 min — R-S on `vx283-u3b-rv`, the three
  VX-175 suites; expected RED exactly as R-S names; then `vx283-u3b-rv` deleted) · `mount` (OPTIONAL, ≈4 min — the
  mounted suite ×2, a flake check) · `restore` (the store copied back + `cmp`; the prefs keys the suites ADDED deleted
  by name, `prefs-before` imported, re-exported and diffed — it prints PREFS CLEAN or not; castle-W1 counted). The
  geometry print lines land in `u3b/logs/{batch,rv}-geometry.txt` (the in-app widths the offscreen harness can only
  estimate). Then **the re-walk of W2** (P-U3-5 item 5): both voices, panel open/closed, typing, a list scroll, the 1240
  default — `vx283-u3b` holds the products.

**PROVISIONAL (mine — options for the orchestrator's bundle; `notes/QUESTIONS.md` left to the merging session, the
shared-ledger rule):**
- **P-U3b-1 — the floor includes the field's bezel.** "The placeholder string measured in the field's own font" is
  read as the width at which the FIELD shows its whole prompt: the cell's size (the prompt's 199.05 pt + the rounded
  bezel's ≈12.5 = 211.5, Terminal) — the same number U3's pins read as "the prompt's width". Options: (a) the cell's
  size [built]; (b) the bare text width (≈12.5 pt less — at the threshold the prompt's last characters clip under the
  bezel).
- **P-U3b-2 — Timeline is judged without sort and when** (unchanged from U3): a mode switch may re-flow the row
  (List two lines, Timeline one, at some widths). Options: (a) judge the controls present [kept — the ruling's
  stability set is typing, a sort pick and a search; a mode change is her act and changes the row's contents]; (b)
  always count sort + when at their widest, so a mode change never re-flows either (Timeline then two lines wherever
  List is, though one would fit).

**S0 — THE TRACE (this tip; offscreen measures from a scratch `NSHostingController` probe in the voices' own `small`
faces — the numbers in brackets).**
- **F-1.** `LibraryControlsFlow.swift:148` (before) took the field's ideal as `sizeThatFits(.unspecified)`. A
  `.roundedBorder` field answers with its `NSTextFieldCell`'s `cellSize` — the PLACEHOLDER's width while empty, the TYPED
  TEXT's once she types [Terminal 211.5 → 40.5 pt for "wing"; Study 175 → 38; the bare cell gives the same numbers].
  The decision (`:90` → `:77`, `field >= fieldIdeal − 0.5`) then passed for a field squeezed to its typed word's
  width. And the relevance label (`LibraryCatalogView.swift`, the `isSearching` branch) had no line limit and no
  `fixedSize` [its width at a zero proposal: 0, 266 pt tall — one character per line], so in the HStack's
  least-flexible-first order (`:51-65`) it took a share of what was left. At the default window with the panel open
  (631 pt), typing: when 53 · mode 180 · scope 228.5 · the label ≈62 (three lines) · the field ≈68 — total 631, the
  field ≥ its 40-pt "ideal" → ONE line. Empty: the ideal is 211.5 → two lines. So every keystroke re-flowed the row
  (the walker's "relevanc / e · best / first", Terminal).
- **F-2.** The same input: the decision compares the field's HStack share with its live ideal, and the sort slot's
  live words feed the share (title · A–Z 103 · date · … 160 · edited · … 174 · created · … 181 · relevance 157, Terminal).
  The old rule's one-line threshold, by these numbers, moves from ≈856 pt (title) to ≈934 pt (created) and to ≈699 pt
  once typed. The walker's room was ≈951 pt (the capture's column reads ≈999 pt wide at a ≈240-pt sidebar) and the
  in-app Terminal row runs ≈20 pt wider than this harness (U3's first window measured the field 222 at the 981-pt room
  where these numbers give 242; Study matched exactly, 268), so Terminal sat a few points from its threshold and any
  moving input flipped it. **Not traced:** which input moved on "nothing but a scroll of the list" (the decision's only
  moving inputs were the field's ideal and the sort's words; neither is a scroll's) — the fix removes every moving
  input but the width, so it no longer matters which.

**S1 + S2 — THE BUILD (`3ab7ad9e`, P-U3-5 items 1–4).**
- `LibraryControlsFlowRule.Child` loses `ideal` and gains `floor` (the field's) and `widest` (a changing label's).
  `fitsOneLine(_ children:width:spacing:)` counts each `widest` child as a RIGID control of that width, distributes
  the line as the HStack does, and passes only if it fits AND the floor child keeps its floor. The PLACEMENT is
  unchanged — the HStack's distribution with LIVE widths, so a wide window is byte-for-byte as before; since the live
  label is never wider than counted, and in the HStack's order a narrower fixed child only leaves the field more, a
  line judged to fit never puts the field under its floor (pinned over every width 300–1400 and every form).
- `LibraryControlsFlow` reads the two numbers as LAYOUT VALUES (`FloorKey`, `WidestKey`; `.libraryControlsFloor(_:)`
  on the field, `.libraryControlsWidest(_:)` on both sort-slot branches) — never asking the field.
- `LibraryControlsStableWidths` (new, same file): `fieldFloor` = the prompt through an `NSTextFieldCell` configured
  as the field draws (rounded bezel, editable, the field's font, the prompt as placeholder) — the empty field's own
  ideal by construction, no magic number; `sortWidest` = the widest of every sort × direction as the `sort ▾` door
  draws it (`chromeLabel(doorLabel) + " ▾"`, rounded up to a whole point as a `Text` sizes itself, + `VoicedMenu`'s
  10-pt chrome) and the relevance label (no chrome). The font is the voice's `small`, resolved in the view's own
  `fontResolutionContext` (`Font.resolve(in:).ctFont`); memoized per face + strings, so a keystroke re-renders
  without re-measuring. Measured: Terminal floor 211.5, widest 181 ("created · newest first ▾"); Study 175 / 134.
- `LibraryCatalogView`: `static let searchPrompt` (one home for the field and its floor — the tutorial's source pin
  still finds "Search books, notes, blocks" in this file); the relevance label `.lineLimit(1)` + `.fixedSize()` (P-8:
  never a wrapped label; it holds its words, so it is a fixed child like the door). **The sort door and `when ▾`
  already carried `.lineLimit(1)` + `.fixedSize()` at their homes** (`VoicedMenu`, `Theme/VoiceControls.swift:160-161`;
  `LibraryWhenDoor.swift:158-159`) and `when ▾`'s words never vary (`LibraryDayFace.closedLabel`), so neither needed a
  change or a `widest`. A DEBUG probe `LibraryProbeSlot.sortSlot` (`LibraryInfoPanel.swift`) on both branches.
- **What the decision now gives** (by the offscreen numbers; the mounted pins print the in-app ones): one line from
  ≈934 pt (Terminal) / ≈834 pt (Study) of row width, whatever is typed or picked. The default window (210-pt sidebar):
  panel OPEN (631) — two lines, both voices; CLOSED (981) — one line, both voices (Terminal's in-app margin ≈7 pt by
  U3's measure). A wider sidebar (the dev store's ≈240) can take Terminal's closed row to two lines — stably.
- **Unchanged by the ruling, said so:** Timeline drops sort and when, so its row is judged without them and may be one
  line where List's is two — a MODE change is her act and changes the row's contents (U3's `inTimelineLineTwoIsTheModeAlone`
  stands); the ruling's stability set is typing, a sort pick and a search.

**S3 — THE PINS (`ed58c2ac`, `VariorumTests/LibraryControlsFlowTests.swift`).**
- `LibraryControlsFlowRuleTests` (pure): U3's `oneLineOnlyWhileTheFieldKeepsItsPromptAndTheLineFits` CHANGED IN PLACE
  by the ruling (the decision takes the children; the same three claims), U3's `row` gains the field's `floor` and the
  sort's `widest: 181` (every other U3 pin's numbers unchanged); NEW `theDecisionIsOneAnswerPerWidthWhateverTheSortSlotShows`
  (×2 voices: every form, every width 300–1400 by 0.5 — one answer, one threshold), `aOneLineRowNeverPutsTheFieldUnderItsFloor`
  (×2), `atTheMeasuredWidthsTheDefaultWindowHasOneAnswerPerPanelState`.
- `LibraryControlsStableWidthsTests` (new, app-hosted, no window): `theFloorIsTheEmptyFieldsOwnIdealNeverTheTypedText`
  (×2 — against the SwiftUI field's own ideal; the typed one ≥ 50 pt smaller), `theSortSlotIsCountedAtItsWidestForm`
  (×2 — every real `LibrarySortMenu` form and the relevance label ≤ the counted widest, the widest equal to it: keeps
  `voicedMenuChrome` and the rounding honest).
- `LibraryControlsGeometryTests` (mounted; its seeded titles now carry several words so typed questions keep the
  selected row listed and the panel open): **RED ON OLD (R-S)** `typingWithThePanelOpenNeverChangesTheLineCount` (×2 —
  typed for real through the field editor, "pick" → … → past the prompt; the line count, the field ≥ its prompt, the
  relevance label ≤ 20 pt tall, the row in its column; also the counted floor = the MOUNTED empty field's own cell
  width; a fallback to the binding road is logged if keystrokes do not reach the model in the host),
  `withThePanelClosedEachWidthHasOneLineCount` (×2 — rooms 760…1000 by 20, seven states each: three sort forms, a
  typed word, a question past the prompt, empty), `withThePanelOpenTheDefaultWindowHasOneLineCount` (×2 — the seven
  states plus all eight sort × direction forms). U3's six cells unchanged (guards).

**R-S — THE BEHAVIOURAL REVERT (named before it is applied; from the committed tip):**
1. `LibraryControlsFlow.swift`, `arrangement(…)`: `floor: subview[FloorKey.self],` → `floor: subview[FloorKey.self].map
   { _ in subview.sizeThatFits(.unspecified).width },` (the old ideal road, on the same child) and `widest:
   subview[WidestKey.self])` → `widest: nil)`.
2. `LibraryCatalogView.swift`, the relevance label: delete `.lineLimit(1)` and `.fixedSize()`.
Products `DerivedData/vx283-u3b-rv` (an APFS clone of `vx283-u3b`, then `build-for-testing`); `vx283-u3b` untouched.
Restore: `git checkout --` the two files, then `git diff --quiet`. **Expected RED, exactly:** the six new mounted cells
(`typingWithThePanelOpenNeverChangesTheLineCount`, `withThePanelClosedEachWidthHasOneLineCount`,
`withThePanelOpenTheDefaultWindowHasOneLineCount`, ×2 voices); GREEN: every pure pin, both stable-widths tests, U3's six
mounted cells. (If the field-editor cell stays green on old, the keystroke road does not move the field's cell in the
harness — recorded as such; the binding-road cells carry the red.)

#### U2 + U3b — THE STAGE WINDOW (run by the orchestrator, claim `vx283-u2` 15:31:45 → SEAM, RELEASED 15:50:46)

The coordinator's GO came at 15:32 (her word at ~10:55: "Now, I'm off the Pro"). Products were the tip-built trees
(`vx283-u2`, `vx283-u3b`, both built at `8dbae3d6` code; the revert trees prebuilt). The pre-GO state: no instances
(strict forms), no sims, load 5.5. The superseded trees `vx283-u1d` and `vx283-u3` were deleted first (5.3 GB).
- **U2 `window.sh`:**
  - pre: tree clean at `0ddb357e`, store copied (`store-before/20261015T213200Z`), prefs exported.
  - **batch: 722 tests / 144 suites, exactly ONE red:** `BookCollectingDoorsTests.theSettingsDoorIsOneActOnBothRoads`
    (VX-115, red on main, untouched here). 9 skipped, all opt-in harnesses.
  - **mount: `OpenListDragMountTests` + `SidebarSectionWindowMountTests` green on five passes.** The `-test-iterations 3`
    run took 73 s (three repeats; Swift Testing prints one summary), plus two separate runs at 24.5 s each, 14/2 each.
  - **R-K: exactly the 16 named RED, the 9 named GREEN** (25 tests / 3 suites; `logs/rk.log`). Tree deleted.
  - **R-N: exactly the 4 named RED** (`theFadeIsWholeBeforeTheClipReachesInk`,
    `theFadeIsAlwaysHalfARowDeepAndItsStrengthEasesIn`, `theFadeIsNeverFullySolid`,
    `aShallowOverflowFadesTheWholeHalfRowFaintly`); the other 23 green (27 / 2; `logs/rn.log`). Tree deleted.
  - restore: the three files byte-identical even before the copy-back (the suites write their own stores), restored
    + `cmp`. The nine added keys (`currentBlock.*`, `surfaceSize.outline.*`) deleted, import, re-export: PREFS CLEAN.
  - **U2's test part is GREEN, and every pin is red-on-old as named.**
- **U3b `window.sh`:**
  - pre: `App/` clean at `0ddb357e`, store `store-before/20261015T214144Z`.
  - **batch: 511 tests / 103 suites, ONE red — U3b's own pin
    `LibraryControlsGeometryTests.withThePanelClosedEachWidthHasOneLineCount`, both voices.** Its other five mounted
    cells, both stable-widths tests, every pure pin and U3's six cells are green.
  - The sweep (`logs/batch.log`, `[VX-175 U3b sweep]` lines), with the room = the catalog width − 48:
    - **Terminal 940 and 960:** the four sort states (edited·newest, title·A–Z, created·newest, created·oldest) are TWO
      lines (56 pt); typed a word, typed past the prompt and EMPTY AGAIN are ONE line (24 pt).
    - **Study 840, 860 and 880:** the same split.
    - Every other room has one answer per voice: two lines at or below 920 (Terminal) and 820 (Study), one line from 980
      (Terminal) and 900 (Study).
    - The states run in order (edited·newest → title → created·newest → created·oldest → a typed word → past the
      prompt → empty again). So **"empty again" (the field empty, the last pick created·oldest) is one line, where
      "created·oldest" before the typing was two.** Either the slot still shows something other than the door after
      the field clears, or the row's answer depends on its history.
  - **R-S: the six named cells RED** (3 mounted tests × 2 voices; 19 tests / 3 suites; `logs/rv.log`), the rest green.
    But **the closed-panel cell is red on BOTH sides**, for different cells:
    - on old, "typed a word" went one line with the field under its prompt (173 of 211.5 / 138.5 of 175) across the
      sweep;
    - on the fix, the field is never under its floor, but the band above remains.
  - So the fix closed W2's F-1/F-2 everywhere the pins reached except this band. The pin is not hollow: it
    discriminates, and it shows the fix incomplete. Tree deleted.
  - restore: identical before copy-back, restored + `cmp`; nine added keys deleted; PREFS CLEAN; castle-W1 present.
- **Why it matters in use:** the dev store's ≈240-pt sidebar puts Terminal's closed row at ≈951, inside the band. So
  W2's flip on typing would still show there. **D8 is deferred** to a re-walk after U3c (below); the walk carries
  D1–D7.
- RELEASE line sent at the SEAM: "dev store restored + verified, prefs diff clean, posture Standard/unlocked, castle-W1
  untouched". The coordinator's word at the SEAM was "release for vx336-release": vx-336's 0.9.7 window runs before
  our walk.
- **The merge from main (branch-only, during the release window):** `6860bd54` merges `origin/main` at **`591bb8e8`**.
  Its message names `9e6df7b4`; the two commits past it are VX-336 release-brief notes only. There was one conflict,
  `.gitignore`, resolved with both screens lines kept; `CommandRouter.swift` auto-merged.
- **A record slip:** commit `d9741021`'s message says it carries this section and the U3c ruling. It carried only the
  LIVE STATUS rows and the stage log (an Edit refused unseen); this section lands in the next commit.

#### U3c — THE ORCHESTRATOR'S RULING ON THE CLOSED-PANEL RED (2026-10-15 ~15:55 — a TRACE-FIRST leg, a fresh implementer)

The window's red is a real residual of P-U3-5, not a hollow pin (above). P-5 applies: this is the third pushback on
VX-175's row (U3's W2, U3b, now this). So **no guessed fix.** A fresh `opus-implementer` at xhigh runs a trace-first
leg on the merged tip, in the U1c shape (trace, propose, the architect rules, then build).
- **T1 — read the code (headless).** Find what differs between a sort state and the typed / empty-again states, at
  one catalog width, in the controls row and its container:
  - `LibraryCatalogView`'s row: the `isSearching` branch, and whether `isSearching` / `searchState.isAnswering`
    persists after `ask("")`;
  - any child that appears, disappears or changes its reported floor, widest or ideal width;
  - `LibraryControlsFlow`'s `arrangement` and its decision inputs, and any Layout cache;
  - the harness's `pick` / `ask` settle: is the read taken before the async `search()` re-renders?
  Name each candidate with file:line.
- **T2 — a DEBUG-only probe (headless build), then READY FOR STAGE.** Add a narrowed mounted probe: ONE room per voice
  inside the band (Terminal 950, Study 860), the seven states in the sweep's order plus a sort pick after "empty
  again". For each state, print `isSearching`, the slot's branch, each subview's floor / widest / `sizeThatFits` ideal,
  the proposal width, the decision, and the measured height, read after a settle that waits for the search to land.
  Build-for-testing into `DerivedData/vx283-u3c`, commit, push, and END THE TURN with the exact window (≈10 min). The
  orchestrator runs it at the next claim.
- **T3 — THE PROPOSAL** (after the run): the traced mechanism with file:line; the fix shape inside P-U3-5 and VX-175's
  composition ruling (search · scope / mode · sort · when as ONE Layout, never `ViewThatFits`); the pin, red-on-old,
  named with its revert. **Nothing is built before the orchestrator rules.** If the mechanism is the harness (a read
  before the settle) and the product is stable, say so: the pin is fixed, and the product is not.
- The cast: one implementer at a time; the U2 walker (D1–D7) may run beside it, since a walker is not an implementer
  (precedent: U1d's walk beside U2's build).

### U3c — the trace leg

**Implementer:** a fresh Opus 5.5 at xhigh (2026-10-15), worktree `~/dev/variorum-vx-283`, DerivedData
`App/Variorum/DerivedData/vx283-u3c`. **Not done by this session (the record's first line, per the brief):** no
`xcodebuild test`, no app launch, no stage (the probe runs in the orchestrator's window); T3 (the proposal) waits for
the probe's output and the orchestrator's resume; NO product fix and NO pin change — the only product lines are a
DEBUG-only trace hook, off unless the probe turns it on.

**LIVE STATUS (per piece)**
- T1 — the headless trace: DONE (this commit, below). It PROVES the row's answer has a history (two identical view
  states, two answers) and narrows the moving input to the live AppKit answers P-U3-5 left un-stabilized; the
  arithmetic on the batch's own in-app widths points at the SCOPE picker. Which control, and why, is the probe's.
- T2 — the probe: DONE (`944cfd46`) — `LibraryControlsFlowTrace` (DEBUG-only, silent unless a probe sets its sink) +
  the env-gated suite `LibraryControlsU3cProbe` (asserts nothing); `build-for-testing` green on `vx283-u3c`
  (`notes/plans/vx283-screens/u3c/logs/bft3.log`, no warning in either file); the window script
  `notes/plans/vx283-screens/u3c/window.sh` (gitignored). **READY FOR STAGE — the window below.** Its output PENDING.
- T3 — the proposal: DONE (`822ff4d1`, below); RULED P-U3c-1 (`ae582c53`).
- B1 — the pins, red-first: DONE (`032ee08a`) — `aSearchNeverSqueezesTheSegmentedControlsOrFlipsTheRow` ×2, the pure
  GUARD `atTheProbesInAppWidthsTheDefaultWindowIsOneLineClosed`, the stale "≈934 / ≈834" comment annotated in place.
- B2 — the fix: DONE (`378e2261`) — the two `.fixedSize(horizontal: true, vertical: false)` lines; `build-for-testing`
  green on `vx283-u3c`.
- B3 — R-P prebuilt: DONE — the two `.fixedSize(horizontal: true, vertical: false)` lines deleted from the committed
  tip `378e2261` (the diff: exactly those two `-` lines), `DerivedData/vx283-u3c-rv` APFS-cloned from `vx283-u3c` and
  built (`build-for-testing` succeeded, `LibraryCatalogView.swift` recompiled — `u3c/logs/bft-rv.log`), RESTORED by
  `git checkout --`, `git diff --quiet` empty. **No revert in flight.** `vx283-u3c` holds the fix (`bft-fix.log`; the
  only warning in the file is the pre-existing `probeSpace` one).
- B4 — the window script: DONE — `notes/plans/vx283-screens/u3c/window.sh` (gitignored) gains `pins` · `rp` · `batch`;
  `pre` (now checks both trees) and `restore` kept; `probe` kept, not part of this window. **READY FOR STAGE — the fix
  window below.** Its results PENDING.

**THE BUILD (P-U3c-1, as ruled at `ae582c53`).**
- **The pins, red-first (`032ee08a`, no product line):**
  - NEW `LibraryControlsGeometryTests.aSearchNeverSqueezesTheSegmentedControlsOrFlipsTheRow` (×2 voices): the panel
    closed, Terminal 950 / Study 860, the catalog resized to the room; created · oldest → "pick" → "" → a sort pick
    (edited · newest), through the sweep's own `Rig`; after each, the premise (the catalog is the room + 48 wide), both
    NSSegmentedControls mounted, each drawn at no less than its intrinsic width − 0.5, and the row's height equal to
    the first step's. It prints `[VX-175 U3c pin]` per step. Red on the pre-fix tree by the probe's own trace (states
    4/5/7/8: the scope control at 227 / 220.5 of 254 and the row at 24 after the search).
  - NEW pure GUARD `LibraryControlsFlowRuleTests.atTheProbesInAppWidthsTheDefaultWindowIsOneLineClosed` over
    `inApp(_:)` — the probe's in-app rigid rows (Terminal scope 262…280 · mode 224…230 · slot 174 counted 181 · when 53
    · floor 211.5; Study 264…280 · 230 · 127 counted 134 · 48 · 175): 981 one line and 631 two in both voices; the old
    band's rooms (950 / 860) two lines; Terminal 976 ✗ / 978 ✓, Study 889 ✗ / 892 ✓ (the rule's exact thresholds
    977.0 / 890.5 — the ruling's ≈977.5 / ≈891 less the floor's half-point slack; a Python replica of `distribute` +
    `fitsOneLine` computed them); no flip back over 300…1400. A GUARD (the rule does not change).
  - The stale "≈934 / ≈834" doc comment on `atTheMeasuredWidthsTheDefaultWindowHasOneAnswerPerPanelState` ANNOTATED in
    place (an italic U3c note after it: the offscreen numbers, the in-app ones, the "≈20 pt wider" was the scope
    picker); the pin's numbers unchanged. The file header gains a U3c paragraph.
- **The fix (`378e2261`):** `LibraryCatalogView.swift` — `.fixedSize(horizontal: true, vertical: false)` after
  `.pickerStyle(.segmented)` and before `.frame(maxWidth: 280)` on scope (`:659`) and before `.frame(maxWidth: 230)` on
  mode (`:685`), each with its reason at the line. Nothing else in the product. The trace hook and the probe stay.

**THE FIX WINDOW — READY FOR STAGE (≈15 min; products `vx283-u3c` = `378e2261` + `vx283-u3c-rv` = R-P).** `window.sh`
from any directory, in order:
1. `pre` (≈1 min) — the strict `pgrep`s; App/ clean; both trees present; prefs exported; the store's three files into
   `u3c/store-before/<UTC>/`.
2. `pins` (≈3 min) — `LibraryControlsFlowRuleTests` + `LibraryControlsStableWidthsTests` + `LibraryControlsGeometryTests`
   on `vx283-u3c` → `logs/pins.log`. **Expected: ALL GREEN** — "Test run with 21 tests in 3 suites passed" (U3b's R-S
   run printed 19 for these suites; +2 new functions); the sweep and the new pin green in both voices (`logs/pins-geometry.txt`:
   the new pin's four steps one height each — two lines at 950 / 860 — and the segmented controls at 254 / 216 Terminal,
   256 / 225 Study).
3. `rp` (≈3 min) — the same three suites on `vx283-u3c-rv` → `logs/rp.log`; then `vx283-u3c-rv` deleted. **Expected
   RED, exactly:** `aSearchNeverSqueezesTheSegmentedControlsOrFlipsTheRow` ×2 (the row 56 → 24 after "pick"; the scope
   control squeezed) and `withThePanelClosedEachWidthHasOneLineCount` ×2 (the band, as at U3b's window). **GREEN:** every
   pure pin incl. the new guard, the stable-widths tests, U3's six cells, `typingWithThePanelOpenNeverChangesTheLineCount`
   and `withThePanelOpenTheDefaultWindowHasOneLineCount`.
4. `batch` (≈6 min) — U3b's 103-suite list (`u3b/suites.txt`) on `vx283-u3c` → `logs/batch.log`. **Expected: ALL
   GREEN** (U3b's run: 511 tests with the sweep the only red; now ≈513, the opt-in rig/harness suites SKIPPED as before).
5. `restore` (≈1 min) — the store copied back + `cmp`; the added prefs keys deleted, import, re-export, diff (PREFS
   CLEAN); castle-W1 counted.
Then D8's re-walk on `vx283-u3c` (the ruling's list: both voices, panel open/closed, typing, a list scroll, a sort pick,
the 1240 default, and the scope control after a search — never cramped).

**T1 — THE TRACE (this tip; the product code is U3b's `8dbae3d6` plus the DEBUG hook; paths under
`App/Variorum/Variorum/` unless named).**
1. **What the seven states change.** `pick` sets the model's sort (and direction) and settles — it spawns NO search
   (`VariorumTests/LibraryControlsFlowTests.swift:484-488`); the door reads `model.sort` / `model.direction` directly
   (`Features/Library/LibraryCatalogView.swift:709-711`). `ask` sets `model.query`, AWAITS `model.search()`, then
   settles (`:476-480`); `search()` → `read(…)` awaits the DB read and lands it before returning
   (`Features/Library/LibraryCatalogModel.swift:609-613, 629-700` — `searchState.land`, `:665-667`). So when `ask`
   returns, `isSearching` already answers the new question. **No read precedes a landing** (the ruling's harness
   candidate, ruled out by reading).
2. **`isSearching` does not persist after `ask("")`.** `LibrarySearchQuestion.read("")` returns nil
   (`Features/Library/LibrarySearchModel.swift:73`); `land(question: nil)` sets `question = nil` (`:310`);
   `isAnswering` is `question?.hasWords == true` (`:258`), which `isSearching` reads (`LibrarySearchRouting.swift:22`).
   So "empty again" draws the DOOR branch (`LibraryCatalogView.swift:708-722`) with query "", sort `createdAt`,
   direction `asc` — exactly the model inputs of "created · oldest". **PROVEN: two identical view states, two answers
   (56 vs 24 pt) — the row's answer has a history.** The sweep shows it a second way: "empty again" at Terminal 940
   read ONE line, then the WIDER room 960 + "edited · newest" read TWO. No function of width alone does that.
3. **The read itself.** The row's height is an `onGeometryChange` record (`LibraryInfoPanel.swift:670-679` on
   `LibraryCatalogView.swift:740`), written only when the frame CHANGES. A fresh 24 after a 56 is a real record; but
   "empty again"'s 24 may be "no change since typed past the prompt" or a change not yet delivered after the 0.35-s
   settle. The probe reads twice: as the sweep read, and after a settle that waits for the row to hold still.
4. **The decision's inputs** (`Features/Library/LibraryControlsFlow.swift:208-219`). P-U3-5 stabilized two: the
   field's floor (`FloorKey`, `LibraryCatalogView.swift:641`) and the sort slot (`WidestKey` on BOTH branches,
   `:707`/`:721` → `counted`, `LibraryControlsFlow.swift:97-101`: rigid at its widest, flexibility 0 — identical in
   either branch, so the slot's branch cannot move the decision). **Still LIVE:** (i) every child's FLEXIBILITY, its
   own answer at ∞ minus its answer at 0 (`:210-213`), which sets the distribution ORDER (`:83-85`); (ii) every
   non-counted child's width answer at a share (`:214`) — the field (a `.roundedBorder` `TextField`, an NSTextField,
   in `.frame(maxWidth: 320)`, `LibraryCatalogView.swift:639`), scope and mode (segmented `Picker`s,
   NSSegmentedControls, in `.frame(maxWidth: 280)` / `(maxWidth: 230)`, `:650`/`:673`), and `when ▾` (a fixed SwiftUI
   label, `LibraryWhenDoor.swift:155-160` — stable); (iii) the proposal. Through a `maxWidth`-only frame a child's
   width at share p is max(its own answer at min(p, cap), min(p, cap)): **below its natural width a control takes ITS
   OWN answer** — an AppKit control's say. The layout keeps no cache (`cache: inout ()`); SwiftUI's own caching of
   subview answers sits outside it.
5. **The arithmetic on the batch's in-app widths** (`u3b/logs/batch-geometry.txt`). At the mount (catalog 1029,
   closed: row 981) Terminal's field read 222 with the door at "edited · newest first ▾" (174, live — the door's
   measure is pinned honest by `theSortSlotIsCountedAtItsWidestForm`) and `when ▾` 53: 981 − 40 − 174 − 53 − mode −
   scope = 222 ⇒ mode + scope = 492 ⇒ **scope ≈ 262–270** (mode ≤ its 230 cap) where the offscreen harness measured
   228.5 — this IS U3b's "the in-app Terminal row runs ≈20 pt wider". With scope ≈ 262–270 the decision's threshold
   (sort counted 181, `when` 53, field floor 211.5, spacing 40) falls at ≈ 967–978: two lines at 960, one at 980 —
   **exactly the sort states.** Study's sort states (two at 880, one at 900) need scope ∈ (≈264, ≈277] by the same
   sum. So **the SORT states obey the decision**, with the scope control answering ≈262–277 (and, in Study, mode
   served before scope — scope first cannot reach that band). **The TYPED states and "empty again" do not**, and two
   fits exist (every permutation of the three flexible children checked): **(A)** the same order, the scope's answer
   two-valued — one line at Terminal 940 / two at 920 needs scope ∈ (≈219, ≈232.5], Study 840 / 820 needs (≈224,
   ≈237] — the offscreen harness's own 228.5 / 233; or **(B)** the ORDER flipping, scope served before mode after a
   search (its flexibility, its own ∞-minus-zero answer, dropping under mode's), with scope ∈ (≈223, ≈243] in Terminal
   and (≈248, ≈268] in Study — Study's fits ONE scope width ≈265 in both states, Terminal's needs a ~2-pt move (inside
   the slop of these widths). No fit keeps scope at ≈262 in Terminal's typed states with the order unchanged. **Either
   way the moving input is a live AppKit answer P-U3-5 did not stabilize — the scope picker's width or the
   flexibilities that order the distribution.** Arithmetic, not proof: the probe's decision steps print the order (the
   step sequence) and what each child took.
6. **Where a two-valued answer could come from** (candidates, unproven — the probe's AppKit lines and per-pass child
   answers tell them apart): (a) the NSSegmentedControl's reported size follows how it was last LAID OUT (its frame /
   segment widths) — a feedback loop through the row's own placement: placed wide, it answers wide (two lines hold);
   once squeezed, it answers squeezed (one line holds); (b) SwiftUI's cached subview answers outliving the branch
   change or the text change; (c) a window resize (an AppKit layout pass) and a SwiftUI-driven update measuring the
   control by different roads.
7. **A second road to the decision, recorded (not the band's):** `placeSubviews` re-decides at `bounds.width`
   (`LibraryControlsFlow.swift:198`), and a `VStack(alignment: .leading)` places the row at its REPORTED width, not
   its proposal. In the band the one-line row reports its full proposal (the field absorbs the rest under its 320
   cap) and the two-line row re-decides at ≈610 → two lines again, so it cannot make the band; the probe prints both
   passes anyway.

**T2 — THE PROBE (`944cfd46`).** `LibraryControlsFlowTrace` (`LibraryControlsFlow.swift`, `#if DEBUG`, a `sink` that is
nil unless the probe sets it — the `SidebarSectionTrace` precedent): for every arrangement the layout computes, the
pass (`size p=…` / `place b=… p=…`), the decision REPLAYED through the real `fitsOneLine` with each child's width
answer recorded as asked (`[i] offered→taken` — the counted slot never asks), the answer next to `arrange`'s, the
frames and size, and each child's narrowest / widest / flexibility / ideal (`.unspecified`) / floor / widest. The
suite `LibraryControlsU3cProbe` (`VariorumTests/LibraryControlsFlowTests.swift`, after the sweep — it reuses the
sweep's own mount and `Rig`; no existing pin's line touched; enabled only by `TEST_RUNNER_VARIORUM_U3C_PROBE=1`, so
every batch skips it): ONE room per voice (Terminal 950, Study 860); the sweep's seven states verbatim, then the
ruling's sort pick after "empty again", then (an addition) a relayout at the same width — resize +20 and back, no
state change. Per state it prints `isSearching`, the slot's branch, the query, the sort, the read generations, the
height AS THE SWEEP READ IT and again after a landed settle (≥2 more settles until no read is in flight and the row
held still), AppKit's account of the two segmented controls (frame, intrinsic, fitting, distribution, segment widths,
font) and the field (frame, intrinsic, cell, editing), and every distinct trace line since the act (×count) plus the
last. Three roads × two voices: `fromBelow` (the sweep's approach — the room reached from 40 pt below, two lines in
both voices on the sweep's log), `fromAbove` (straight from the mount's wide one-line row — does the starting line
count persist?), `fromBelowUntraced` (the trace OFF — the layout byte-for-byte as in use: does tracing perturb?).

**THE WINDOW — READY FOR STAGE (≈10 min; products `DerivedData/vx283-u3c` at `944cfd46`).** `window.sh` (from any
directory), in order:
- `pre` — the strict `pgrep`s, App/ clean, the products present, prefs exported, the store's three files into
  `u3c/store-before/<UTC>/`.
- `probe` (≈3–4 min) — `TEST_RUNNER_VARIORUM_U3C_PROBE=1 xcodebuild -scheme Variorum -destination 'platform=macOS'
  -derivedDataPath DerivedData/vx283-u3c test-without-building -only-testing:VariorumTests/LibraryControlsU3cProbe`
  (from `App/Variorum/`) → `u3c/logs/probe.log`; it prints the "Test run with N tests" line (expected 6 test cases in
  1 suite, passing — the probe asserts nothing), then extracts `logs/probe-lines.txt` (every `[VX-175 U3c` line) and
  `logs/probe-summary.txt` (one line per state: the facts and both heights).
- `restore` — the store copied back + `cmp`; the prefs keys the suite ADDED deleted by name, `prefs-before`
  imported, re-exported, diffed (PREFS CLEAN or not); castle-W1 counted.
Then the orchestrator resumes this session with the logs' paths for T3.

**T3 — THE PROPOSAL (from `u3c/logs/probe-lines.txt`; the run: the orchestrator's window 16:23–16:25, every road,
both voices, the sweep's read = the settled read, traced = untraced). Nothing built.**

1. **WHAT MOVES — exactly one pair of children: the two SEGMENTED PICKERS' minimum answer.** Read off the size pass at
   the room in each state (`size p=950` Terminal, `size p=860` Study), the children's own answers (`n` = narrowest, at a
   zero proposal; `ideal` = `.unspecified`):

   | | state 4 created · oldest | state 5 typed a word | state 7 empty again | state 8 sort pick |
   |---|---|---|---|---|
   | Terminal scope `[1]` n / ideal | **262** / 262 | **228.5** / 262 | **228.5** / 262 | **262** / 262 |
   | Terminal mode `[2]` n / ideal | **224** / 224 | **180** / 224 | **180** / 224 | **224** / 224 |
   | Study scope `[1]` n / ideal | **264** / 264 | **233** / 264 | **233** / 264 | **264** / 264 |
   | Study mode `[2]` n / ideal | **230** / 230 | **189** / 230 | **189** / 230 | **230** / 230 |
   | decision · height | false · 56 | true · 24 | true · 24 | false · 56 |

   Every other input is constant across the four states: the PROPOSAL (the size pass is at the room in all of them);
   the field `[0]` (n 0, widest 320, floor 211.5 / 175 — its ideal follows the text, 211.5 → 40.5, but nothing reads
   it since P-U3-5); the sort slot `[3]` (counted at 181 / 134 in both branches); `when` `[4]` (53 / 48). The SAME
   view in the SAME model state answers in two MODES: **rigid** (its minimum = its natural width = its ideal) or
   **compressible** (its minimum = the NSSegmentedControl squeezed — AppKit's frame reads 227 / 220.5 against an
   intrinsic of 254 in states 5–7, Terminal; 225 / 206.5 against 256 / 225 in Study). Its ideal and AppKit's
   intrinsic / fitting widths (254 · 216 Terminal, 256 · 225 Study, distribution `fillEqually`) never change.

   **Which DECISION input moves** (`LibraryControlsFlow.swift:208-219` → `fitsOneLine`, `:114-122`):
   - the pickers' **TAKEN width** at the decision's shares (`:214`): Terminal at 950 offers scope 225.3 — it takes
     262 rigid (field left 188.7 < 211.5 → two lines) or 228.5 compressible (field 222.2 ≥ 211.5 → one line); Study at
     860 offers scope 204 / 212.7 — it takes 264 or 233, and mode 230 or 212.7;
   - their **FLEXIBILITY**, hence the **ORDER** (`:210-213` → `:83-85`): Terminal's order holds ([4] when · [2] mode ·
     [1] scope · [0] field — flex 6/18 rigid, 50/51.5 compressible); **Study's flips** — rigid, mode is flex 0 and goes
     FIRST at a 1/5 share (164 → takes 230); compressible, flex 41 and it goes after `when` (212.7 → 212.7).
   - NOT the proposal, NOT the field, NOT the slot, NOT `when`. P-U3-5 stabilized the field and the slot; the two
     pickers were the decision's remaining live inputs, and they are two-valued.

   **When it switches (the trace's evidence — every state's FIRST arrangement already carries the new mode, so the
   switch happens in the ACT, before this layout runs; our placement only follows it — AppKit's frame 254 → 227 →
   220.5 → 254 — it is not a feedback loop through the row):**
   - **ON at the first act that lands a search** (state 5: the field's text changes, the answer lands, the catalog
     swaps the list for the answer sheet and adds the band). **It outlives the search** because nothing the cleared
     search does touches the pickers: the scope picker reads `model.scope`, `model.editedOn` and
     `model.searchState.bookState` (`LibraryCatalogView.swift:644-660`), the mode picker `model.mode` (`:664-673`) —
     all unchanged across states 4–8. States 6 and 7 (the question longer, then cleared: the band gone, the list back,
     the DOOR re-inserted with the very label of state 4) leave the mode where it is. The pickers' answer is not a
     function of their inputs: it is SwiftUI's own sizing mode for the AppKit-backed segmented control, held between
     updates.
   - **OFF at a sort pick** (state 8) — its one effect on the row is the sort door's LABEL changing (`LibrarySortMenu`
     → `VoicedMenu`, an AppKit-backed `Menu`, `LibraryCatalogView.swift:709-721`; 181 → 174 pt). The door's
     re-insertion at state 7 with an unchanged label does not reset it.
   - **Why SwiftUI flips the control's mode on exactly those two events is not observable from our side** (AppKit's
     numbers never move; the two answers are SwiftUI's — the rigid one is AppKit's intrinsic 254 + 8, the compressible
     one its squeezed minimum 220.5 + 8). Not traced further, deliberately: the fix below removes the dependence, so
     the result does not need it. (A side fact, every state: an ideal-size pass lays the row out at its one-line ideal,
     `size p=nil` / `place b=1104` — a hosting-view measurement; it never reaches the visible frames.)

2. **THE FIX SHAPE — inside P-U3-5 and the one-Layout ruling (C), never `ViewThatFits`: stabilize the last two live
   inputs AT THEIR SOURCE.** Each segmented Picker gets `.fixedSize(horizontal: true, vertical: false)` before its
   existing frame (`LibraryCatalogView.swift:649-650`: `.pickerStyle(.segmented)` · NEW `.fixedSize(horizontal: true,
   vertical: false)` · `.frame(maxWidth: 280)`; the same at `:672-673` with `230`). A horizontally fixed picker answers
   its IDEAL at every proposal — the probe shows that ideal constant in every state of both voices — so its minimum,
   its taken width at any share and its flexibility become functions of the voice alone: the decision reads stable
   widths only, as P-U3-5 ruled. Zero changes to `LibraryControlsFlow`, the rule, the field's floor or the slot's
   widest; ONE set of views, one Layout. What it changes, said plainly:
   - the band resolves to the RIGID answer — today's sort states', the answer the row gives at mount and after every
     sort pick. Thresholds by the probe's in-app widths: **Terminal ≈977.5, Study ≈891** of row width (two lines below,
     one at and above, whatever is typed, picked or searched). The 1240 default with a 210-pt sidebar (row 981): ONE
     line closed in both voices (Terminal by ≈3.5 pt — stable, a function of width only); two lines with the panel
     open (631). The dev store's ≈240-pt sidebar (row ≈951): Terminal closed is TWO lines — stably (P-U3-5 item 4's
     "stable is the point");
   - **the placement stops cramping the segmented controls**: after a search today the scope control is drawn at
     220.5–227 pt against its natural 254 (Study's mode at 206.5 against 225); fixed, they always draw at their
     natural width inside their 280 / 230 frames — as they already do in the rigid mode (AppKit frame 254 in a
     262–280 slot), so a wide window is unchanged;
   - the row's honest minimum rises by the pickers' squeeze (line 2: mode 224 + sort 181 + when 53 + spacing = 478 pt
     Terminal, was 434 compressible) — far inside the 631-pt room at the default with the panel open;
   - P-8: the swept lint is the BARE `.fixedSize()` (`ChromeLineLimitTests`); the two-argument form is out of its scope
     by its own text, and a segmented control is not a label that can wrap — said at the line.
   **Rejected:** (F2) hand the pickers' natural widths down as layout values (a `FloorKey` twin) — the decision would be
   stable but the PLACEMENT would still squeeze the controls after a search, and Study's order flip would survive in
   the live distribution; (F3) `.frame(minWidth: …)` numbers — magic, per voice; (F4) `ViewThatFits` — ruled out.
   **The trace hook and the probe suite:** PROPOSED to stay as an oracle (DEBUG-only, silent unless set; the suite
   env-gated, asserts nothing — the U1c `SidebarSectionTrace` precedent, P-U1c-1) — the architect's call; deleting
   both is a clean two-file removal.

3. **THE PIN — red-on-old, with its behavioural revert.**
   - **NEW (mounted, the mechanism's own mark):** `LibraryControlsGeometryTests.aSearchNeverSqueezesTheSegmentedControlsOrFlipsTheRow`
     (×2 voices). The panel closed, ONE room per voice inside today's band (Terminal 950, Study 860); the acts
     created · oldest → typed a word → empty again → a sort pick (the probe's states 4, 5, 7, 8, through the sweep's
     own `Rig`); after each: (a) the row's height equals the first state's, and (b) each NSSegmentedControl in the
     mount (found as the probe finds them) draws at no less than its intrinsic width − 0.5 (never squeezed). Expected
     on the fix: two lines throughout, scope 254 / 256 and mode 216 / 225 throughout.
   - **The sweep** `withThePanelClosedEachWidthHasOneLineCount` (×2) — red on today's tip (the U3b window), expected
     GREEN on the fix, unchanged.
   - **Behavioural revert R-P (named before it is applied):** delete the two `.fixedSize(horizontal: true, vertical:
     false)` lines in `LibraryCatalogView.swift` (nothing else). Products `DerivedData/vx283-u3c-rv` (an APFS clone,
     then `build-for-testing`). **Expected RED, exactly:** the new pin ×2 (typed a word and empty again read 24 pt, the
     scope control 227 / 220.5 of 254 — Study 225 of 256) and the sweep ×2 (the band). **GREEN on both sides:** every
     pure rule pin, both stable-widths tests, U3's six mounted cells, `typingWithThePanelOpenNeverChangesTheLineCount`
     and `withThePanelOpenTheDefaultWindowHasOneLineCount` (at 631 the row is two lines in either mode).
   - **Optional, the architect's call:** a pure pin documenting the in-app widths — the rule over the probe's rigid
     rows (Terminal scope 262…280, mode 224…230; Study 264…280, 230) gives one line at 981 and the thresholds 977.5 /
     891 — a GUARD on the default window's margin; the existing pure pins keep their offscreen numbers (their
     `atTheMeasuredWidths…` comment's "≈934 / ≈834" is stale and would be annotated in place).
   - **Evidence after the build:** the new pin + the sweep green, R-P red as named, the batch over the changed file's
     suites (`LibraryCatalogView`'s — U3b's 103-suite list), then D8's re-walk (both voices, panel open/closed, typing,
     a list scroll, a sort pick, the 1240 default — and a look at the scope control after a search: never cramped).

#### U3c — THE ORCHESTRATOR'S RULING ON T3 (2026-10-15 ~16:50 — P-U3c-1)

**Accepted as proposed.** The mechanism is traced to the input that moves. The two segmented pickers (scope, mode)
answer either RIGID (minimum = ideal) or COMPRESSIBLE (the AppKit control squeezed below its natural width). The
mode is the same model state either way: a landed search turns COMPRESSIBLE on, nothing the cleared search does turns
it off, and a sort pick (the slot's label changing) turns it off. That moves the width each picker takes at its share,
and in Study the serving order too. Every other input is constant in the trace. Why SwiftUI flips the mode on exactly
those two events is not visible from our side. The fix does not depend on it: it removes the picker's freedom to answer
two ways.
- **P-U3c-1 (PROVISIONAL, the orchestrator's):** each segmented Picker in the Library's controls row takes
  `.fixedSize(horizontal: true, vertical: false)` before its existing frame (`LibraryCatalogView.swift` scope and mode).
  So its width is its ideal in every state, and P-U3-5's "the wrap reads stable widths only" extends to the pickers.
  - **Consequences, accepted:** the band resolves to the rigid answer, the row's answer at mount and after every sort
    pick (thresholds ≈977.5 Terminal / ≈891 Study). The 1240 default with a 210-pt sidebar is one line closed (Terminal
    by ≈3.5 pt, stable) and two lines open. A wider sidebar can make Terminal's closed row two lines, and it stays two
    (P-U3-5 allows it). After a search the segmented controls are no longer squeezed. Line 2's minimum rises to 478
    pt, still inside the 631-pt open room.
  - The lint is unaffected (it sweeps only the bare `.fixedSize()`).
- **The pins, pin first (red-first commit, then the fix):**
  - NEW `LibraryControlsGeometryTests.aSearchNeverSqueezesTheSegmentedControlsOrFlipsTheRow` (×2 voices, as proposed);
  - the existing sweep `withThePanelClosedEachWidthHasOneLineCount` must go green UNCHANGED;
  - **the optional pure guard pin: YES**, with the stale "≈934 / ≈834" comment annotated in place (not rewritten).
- **R-P (the behavioural revert, named now):** delete the two `.fixedSize(horizontal: true, vertical: false)` lines,
  nothing else. Products `DerivedData/vx283-u3c-rv`. Expected RED, exactly: the new pin ×2 and the sweep ×2. GREEN:
  everything else named in T3 §3.
- **The trace hook and the probe suite STAY as an oracle** (the U1c precedent): DEBUG-only, silent unless a probe sets
  the sink, env-gated. The ladder may disagree.
- **The window (READY FOR STAGE when built):** the new pin and the sweep on `vx283-u3c`; R-P on `vx283-u3c-rv`; U3b's
  103-suite batch on `vx283-u3c`; restore. Then **D8's re-walk** (a fresh Opus, both voices, panel open/closed, typing,
  a list scroll, a sort pick, the 1240 default, and the scope control after a search) folds with U2b's re-walk where
  the timing allows.

#### U3c — THE FIX WINDOW (run by the orchestrator, claim `vx283-u3c` 16:43:26 → RELEASED 16:54:31)

`u3c/window.sh`: pre (App/ clean at `48a02c3b`, both trees present, store `store-before/20261015T224326Z`, prefs
exported) → **pins: 23 tests / 3 suites ALL GREEN** on `vx283-u3c` (the new
`aSearchNeverSqueezesTheSegmentedControlsOrFlipsTheRow` ×2, the sweep `withThePanelClosedEachWidthHasOneLineCount` ×2
UNCHANGED and now green, the pure guard `atTheProbesInAppWidthsTheDefaultWindowIsOneLineClosed`; `logs/pins.log`,
`pins-geometry.txt`) → **R-P: exactly the four named RED** (the new pin ×2, the sweep ×2), the other 19 GREEN
(`logs/rp.log`); tree deleted → **batch: U3b's 103 suites, 513 tests, ALL GREEN** (the opt-in harnesses skipped as
before; `logs/batch.log`) → restore (identical before copy-back, `cmp`; nine added keys deleted; PREFS CLEAN;
castle-W1 present). **U3c is PROVEN by tests and red-on-old;** VX-175's closing evidence is D8's re-walk on
`vx283-u3c` (folded with U2b's re-walk).

#### U2 + U3b — THE WALK PLAN (the folded `vx283-u2` claim's walk; a fresh Opus at xhigh; her rule)

Products: U2's Debug app `DerivedData/vx283-u2` (the drag + P-U1e-1 + the R1 fixes) for D1–D7; U3b's
`DerivedData/vx283-u3b` (relaunch) for D8. Screens to `notes/plans/vx283-screens/u2/walk/`. Store copy + prefs by the
orchestrator before; restored + diffed by the walker after.

- **D1 — the line and the chip.** Open ~10 notes. Start a drag on an Open row (`cliclick dd:` then `dm:` in small
  steps): capture mid-drag over the upper half of a row and over the lower half — a 2-pt ring-colour line between
  rows exactly where the drop would land, never at the dragged row's own gap; the drag image is the title chip AT the
  cursor (no offset). Both voices.
- **D2 — the four drop cases**, each before/after captured: a drop on the row JUST BELOW (lower half — it moves one
  down; this was the dead drop); a long DOWNWARD drop (lands exactly where the line showed — no longer one short); the
  END ZONE below the last row (reaches the last slot); an UPWARD drop. Each lands with a short settle (no jump).
- **D3 — a no-op drop** (on its own gap): no line shows; nothing moves.
- **D4 — nothing regressed on the rows:** click opens, ✕ closes (her ✕ rule), right-click menu, ⇧⌘W; a FILE dropped
  on the list still imports (as before U2); the Bookcase's own book drag chip unchanged (one capture).
- **D5 — P-U1e-1 (the fade ramp):** the shallow-overflow state at ~5, 7, 9 and 12 pt short in Study light and Terminal
  dark — never a slice through letters at any of them (the row fades); O-1's state (≈4 pt of a row's padding beyond):
  the last whole row's foot shows a fade hint.
- **D6 — the one-row → two-row growth** (the R1 implementer's observation): with ONE note open and the list following,
  open a second note — watch for a brief wobble of the rows (capture a short burst); it should end exact.
- **D7 — following and the drag (P-U2-1):** while following, drag a row from below the current row to above it — the
  list does not jump; then a hand scroll away, a drag, a wait — nothing pulls back.
- **D8 — U3's W2 re-check on U3b's build** (relaunch on `vx283-u3b`): the 1240-pt default, Study and Terminal — panel
  closed (one stable answer per voice; Terminal may be two lines, but it must not flip on a list scroll or on
  typing); panel open: two lines; TYPE into the search field with the panel open — the row keeps its two lines, the
  field never a sliver, the sort label one line; switch sort (edited → created → title) — no flip.
- **D9 — restore and release.**

#### U2 + U3b — WALK RECORD

**Walker:** a fresh Opus 5.5 at xhigh (no implementer of any VX-283 leg), 2026-10-15 15:59 → 16:21, on the
orchestrator's claim `vx283-walk` (not claimed, stolen or released by the walker). Product: the tip-built
`App/Variorum/DerivedData/vx283-u2/…/Debug/Variorum.app` (not rebuilt), launched with `open -n`, **PID 55680**,
told apart by its path; her app absent throughout; the host `AX: true SCREEN: true`. Posture at launch: Standard,
unlocked (the Bookcase came up), voice Study, appearance follow system (light); **no What's New sheet showed**. The
window was 1380 × 900 at (60, 36) for D1–D6, 1380 × 700 for one D1 variation, and 1380 × 620 for D7. **The sidebar
rect is 60,36,236,H** (H = the window height), captured as 2× region captures. Screens are in the gitignored
`notes/plans/vx283-screens/u2/walk/`; every image cited was opened and looked at. D5's verdicts are also
pixel-measured (luminance per scanline at the clip). **D8 is DEFERRED to U3c's re-walk.** The `vx283-u3b` product
was not launched.

- **D1 — the line and the chip · the chip HOLDS; the line DOES NOT HOLD (no line is ever drawn).**
  - The chip: the row's title chip sits centred on the grab point, at the cursor with no offset, in both voices:
    `D1-study-light-upper-wide.png`, `D1-study-light-lower-wide.png`, `D1-noteview-study-light-mid-zoom.png`,
    `D1-terminal-dark-mid-zoom.png`.
  - The line: across every mid-drag capture there is no 2-pt ring line between the rows, in the upper half, the
    lower half or the end zone, in Study light or Terminal dark. A pixel scan of the rows' band found no line pixels.
  - Seven honest variations, all the same:
    - 12 steps at 120 ms;
    - a 700-ms press-hold, then 250-ms steps;
    - after a window resize;
    - with the list overflowing and hand-scrolled (the 700-pt window);
    - out of the list into the content and back in;
    - in a note view;
    - in Terminal dark.
  - AppKit's log shows `kCoreDragTrackingInWindow` all through the drag, so the drag session is live.
  - **CONTROL:** in the same session, the same `cliclick dd/dm/du` road dragging the Bookcase book "starred notes"
    over the Welcome shelf chip lights that target's green ＋ badge (`D4f-bookcase-chip-study-light.png`). So synthetic
    drags do reach SwiftUI drop targets in this window. The Open list's targets never draw a line.
  - Whether its delegate is never reached, or answers `.forbidden`, cannot be told from outside. The code fact the
    orchestrator may want: `perform` refuses when `dragging != nil` and `lineTop == nil`, so whatever keeps the line
    from drawing also refuses the drop.
- **D2 — the four drop cases · DOES NOT HOLD (no drop lands).** In each case the before and after are
  byte-identical, and in the `after-t0` / `-t03` frames the chip slides back to its origin (the system's refused
  drop). The settle is therefore unobservable.
  - (a) Row 2 onto row 3's lower half: `D2a-study-light-strip.png` (before · mid · t0 · t0.3 s · after).
  - (b) Row 1 down onto row 8's upper half; (c) row 2 into the end zone; (d) row 10 up onto row 4's upper half:
    `D2bcd-D3-study-light-strip.png`, plus each `D2{b,c,d}-study-light-{before,mid,after-t0,after-t03,after}.png`.
- **D3 — a no-op drop (row 3 onto its own gap) · HOLDS, VACUOUSLY.** No line shows and nothing moves
  (`D3-study-light-*.png`). But no line shows anywhere, so this row cannot discriminate.
- **D4 — nothing regressed on the rows · HOLDS for click · ✕ · right-click · ⇧⌘W · the Bookcase chip; the FILE DROP
  is NOT PROVEN.**
  - Click opens: "a escola" opened in Write, its row washed (`D4a-click-opens-study-light-window.png`).
  - ✕ closes a non-current row, and the current row is kept (`D4b-x-strip-study-light.png`).
  - Right-click menu: Open Beside · Open in New Window · Star · Close · Close All Notes
    (`D4c-rightclick-menu-study-light.png`).
  - ⇧⌘W closes the current note and lands on the next row (`D4d-shiftcmdw-strip-study-light.png`).
  - The Bookcase book drag shows its title chip at the cursor (`D4f-bookcase-chip-study-light.png`).
  - The file drop: a cliclick drag of a probe `.md` from a Finder window onto the Open list showed no file image at
    the cursor (`D4e-filedrop-mid-terminal-dark.png`), nothing landed (`D4e-filedrop-after-terminal-dark-window.png`),
    and ⌘K finds no "walk import probe" (`D4e-filedrop-palette-check.png`). The Finder-side drag most likely never
    began, so this is inconclusive either way. The Finder window was closed and the probe file lives only in the
    scratchpad.
- **D5 — P-U1e-1, the fade ramp · HOLDS in Study light and Terminal dark.**
  - Setup: "export: it's all yours" (descenders p and y; here also the current row with its wash) was appended by ⌘K
    as the last row. The note view's list overflows at 30-pt rows. Each state is a hand scroll to the end, then ONE
    pixel-unit wheel event N px up (`pxscroll`).
  - Unfaded ink contrast at the glyph tops: Study 0.83 (ink 38 on the pill's 230); Terminal 216 on 31.
  - **5 pt short:** the descenders are whole and end ~2.5 pt above the clip, eased (0.37 at their foot).
  - **7 · 9 · 12 pt short:** the clip cuts the descenders (7, 9) or the letters' feet (12). But the ink AT the clip
    scanline keeps only 0.16–0.17 contrast in Study (≈ 20 % of unfaded, the 0.8 cap), and 37–47 on 7–8 in Terminal
    (≈ 17–21 %). It reads as a faint ghost, against U1d's ~60 % at 7 pt.
  - Files: `D5-{5,7,9,12}-{study-light,terminal-dark}.png` (+`-zoom-bottom`, `-zoom-top`) and
    `D5-12-study-light-window-window.png`.
  - **O-1's state** (the list at its top, ≈4 pt of the next row's padding beyond the edge): the last whole row's
    glyph foot lightens over its bottom ~4 pt (Study 134 → 156, contrast 0.46 → 0.37; Terminal 142 → 114). It is a
    faint hint, clear in the zooms and subtle at 1× (`D5-O1-{study-light,terminal-dark}-zoom-bottom.png`). The ~10 pt
    of empty room to the clip below it remains.
- **D6 — the one-row → two-row growth · HOLDS (no wobble; ends exact).**
  - Method: Close All Notes, one note opened, then a second by ⌘K, captured as a 40-frame burst at ~60 ms
    (`D6burst/b00…b39.png`; `D6-burst-terminal-dark-strip.png`; the key frames stacked in
    `D6-burst-terminal-dark-frames.png`).
  - Row 1 sits at the same y in every frame.
  - The new row arrives over ~2 frames:
    - b23: a sliver of its wash under the list's growing edge, its letter tops sliced
      (`D6-b23-terminal-dark-zoom.png`);
    - b24: whole, its foot faded;
    - b25: settled.
  - b25 = b26 = b39 byte-identical.
- **D7 — following and the drag (P-U2-1) · "nothing pulls back" HOLDS; "the list does not jump after a drop" is NOT
  WALKABLE (no drop lands).**
  - Following, with row 6 of 8 current (620-pt window, Terminal dark), a drag of row 8 to above row 6: the list
    stayed put, but the drop was refused like D2's, so the shifted current row of P-U2-1 never arose
    (`D7-2-following-drag-terminal-dark-strip.png`).
  - Then a hand scroll to the top (`walk-scroll`), a drag attempt, and a 20-s wait with no input: byte-identical to
    the scrolled capture (`D7-3-scrolled-away-…`, `D7-4-scrolled-drag-…-{mid,after}`, `D7-5-scrolled-t20-…`; the
    strip `D7-scrolled-strip-terminal-dark.png`).
- **D8 — DEFERRED** to the re-walk after U3c (the orchestrator's ruling; not launched).
- **D9 — restore · DONE.**
  - My instance was quit by identity, and both strict pgreps were empty after.
  - The store, with zero dev instances: `variorum.sqlite` was already identical. `-wal` and `-shm` had changed; all
    three were copied back from `u2/walk/store-before/` and each `cmp` is byte-identical. No new file in `Backups/`
    (newest 15:32, before the walk).
  - `castle-W1-20261013` is untouched (its files dated Oct 13).
  - Prefs: the walk ADDED 9 `currentBlock.*` keys (each deleted by hand) and CHANGED 7 (`openNotes.remembered.ids` /
    `.recency`, both window frames, `appearanceChoice`, the backup log, the idle-sweep mark). After `defaults import`
    of `prefs-before.plist` and a re-export (`u2/walk/prefs-after-restore.plist`), the diff is CLEAN: 1602 = 1602,
    none added, removed or changed. `appearanceChoice` reads `system`; the voice (a store setting) returned with the
    store.
  - Posture Standard/unlocked throughout. The claim was left to the orchestrator.

**OBSERVATIONS (outside the verdicts, for the orchestrator's eye):**
- **O-1 — the Open list takes no drop under a real system drag (the D1/D2 finding, restated as the one thing to
  read first).** The drag starts (the chip shows, AppKit tracks it in the window), but the line never draws and
  every release slides back. The pins drive `land` / `perform` and the state directly, short of AppKit (the record's
  own "a drag cannot be posted in the test host"). This walk is the only evidence on the delivery road, and it says
  the delivery does not happen under cliclick, while a sibling SwiftUI drop target does. A hand drag by the author
  would settle whether it is cliclick-specific.
- **O-2 — at a 620-pt window, while following, the current row settles under the bottom fade.** "what the door is"
  (8 of 8, compact 24-pt rows) has its text eased over its lower half (216 → 156) and its wash cut by the footer
  hairline. Stable on a re-capture after 2 s, byte-identical (`D7-0-following-terminal-dark.png` + `-zoom-bottom`).
  U1's "the current row wholly in view, clear of the fades" is not met at this height (U1's scope, not U2's; the
  list has ~85 pt there).
- **O-3 — the hover marquee widens the wash to the column's edge.** Hovering a truncated current row scrolls its
  title (`MarqueeText`) and hides ⌘⇧6 and its ✕. The wash then runs to the sidebar's edge with no right margin, the
  title cut at its left ("› ı, where, how long"): `D7-1-current-mid-terminal-dark-zoom.png`, against the rest state
  `D7-1-current-mid-rest-terminal-dark-zoom.png`. This is probably pre-existing and by design; it is noted because
  the cut-left title reads as a glitch in a still.
- **O-4 — D6's transitional slice:** one ~60-ms frame (b23) shows the arriving row's letter tops clipped by the
  list's growing edge. In motion it reads as a slide-in.
- **O-5 — the end of one long fast drag (D2c) drew the chip ~18 pt above the cursor** (`D2bcd-D3-study-light-strip.png`,
  the 5th panel); every other mid frame has it at the cursor. This is likely the drag image lagging the last
  synthetic moves; low confidence.
- **O-6 — the bottom fade band carries a ±1 luminance dither,** visible only in a 3× zoom
  (`D5-O1-study-light-zoom-bottom.png`) and invisible at 1×.

#### U2 — THE ORCHESTRATOR'S EYE ON THE WALK (2026-10-15 ~16:30; her walk rule's step 5)

The walk's restore was verified by the orchestrator: the three files `cmp`-same, prefs 0 differ, castle-W1 present,
no instance. Then, under the coordinator's pre-given "continue", the U3c probe ran in the same claim (below), and the
claim was RELEASED at 16:25:43.
- **The drag does NOT land. Confirmed by eye** on `D1-study-light-lower-wide.png` and `D2a-study-light-strip.png`:
  - the chip ("o museu", "2026-10-08") rides at the cursor;
  - no line draws anywhere in the rows;
  - the release slides the chip back, and the list is unchanged.
  The walker's control is `D4f-bookcase-chip-study-light.png`: the same `cliclick` road over a Bookcase target lights
  its ＋, so a synthetic system drag reaches SwiftUI drop targets in this window. **This is a REGRESSION against main:**
  main's per-row `.draggable` / `.dropDestination` landed, if janky (her "janky"); this build lands nothing. The
  pins could not see it: no pin posts a real drag (the U2 section's "What only the WALK can prove"). → **U2b**,
  below.
- **D5 (P-U1e-1) HOLDS by eye** on `D5-7-study-light-zoom-bottom.png`: at 7 pt short, "export: it's all yours" is cut
  at its descenders, but faded to a ghost (the walker measured ~17–21 % of the ink's contrast at the clip, against
  U1d's ~60 %). It reads soft, not sliced. P-U1e-1 is accepted on the walk.
- **O-2 (the 620-pt window, the current last row under the footer's edge) — seen** on
  `D7-0-following-terminal-dark-zoom-bottom.png`: "› what the door is" sits under a soft bottom edge, its wash cut by
  the footer hairline. There the list is at its floor (~85 pt, compact rows), so the sidebar's OUTER scroll carries
  the rest (U1's W5). The follow reveals inside the list's own scroll only. So at a window short enough to need the
  outer scroll, the outer scroll can leave the row partly hidden. This is U1's scope and a rare height, born of F-1
  (the orchestrator's finding, not one of her rulings). **It is ticketed at the closeout** (Low, Library & sidebar)
  unless U2b's leg finds it is cheap and inside its seam. O-3…O-6 are recorded as observations: O-3 is the marquee's
  existing design; O-4 and O-5 are transitional; O-6 is invisible at 1×.
- D4's file drop is inconclusive (the Finder drag never began) and is OWED in U2b's re-walk. D3 and D7's drop half
  cannot be walked until a drop lands.

#### U2b — THE ORCHESTRATOR'S RULING (2026-10-15 ~16:30 — a TRACE-FIRST leg on the drag that does not land)

P-5 and the hallucination guard apply: no guessed fix. A fresh `opus-implementer` at xhigh runs it AFTER U3c's leg
(one implementer at a time), in the U1c shape.
- **T1 — the code trace (headless).** Why a real system drag over the Open list never draws the line or lands. Name
  each candidate with file:line, and enumerate every gate between AppKit's drag session and `OpenListDrop`'s line:
  - **(a) the payload's type vs what the drop delegate validates.** A custom `UTType`'s export and declaration;
    `validateDrop` / `info.hasItemsConforming(to:)`; what the drag source actually registers (the chip's preview road
    may build its own `NSItemProvider`).
  - **(b) the "a drag of its own" gate.** Is the list's `dragging` state ever set by a real drag start? Is the list's
    identity (`listID`) stable across the body re-evaluations a drag causes? `perform` refuses whenever
    `dragging != nil` and `lineTop == nil`.
  - **(c) the hit area.** Is the delegate attached where the pointer is, or does an overlay (the fade, the line's own
    canvas, the scroll view) take the drop first?
  - **(d) anything the U2 build changed from main's working per-row road.**
  The control (the Bookcase's drop targets react to the same synthetic drag) bounds the search: the difference lies in
  the Open list's own wiring.
- **T2 — a DEBUG-only trace, then READY FOR STAGE.** Log every delegate call (validateDrop / dropEntered / dropUpdated
  / dropExited / performDrop) with the info's types and the gate's inputs (`dragging`, `listID`, hover, gap, lineTop)
  to a file or the unified log under a fixed subsystem. The test host cannot post a drag, so the window is a short
  orchestrator-driven run in the Debug app: launch, one `cliclick` drag over the Open list, then read the trace.
  Write the exact commands into a gitignored `notes/plans/vx283-screens/u2b/window.sh`, build into
  `DerivedData/vx283-u2b`, commit, push, and END THE TURN.
- **T3 — THE PROPOSAL:** the mechanism with file:line, the fix, and a pin for the mechanism's testable part,
  red-on-old by a named revert (e.g., the registered type identifiers equal the validated ones; the list's identity
  survives a re-evaluation). Nothing is built before the ruling. **Acceptance is the re-walk** (D1–D4, D7 with real
  drags, both voices), since only a real drag proves the road.
- **The floor, named now:** if no fix makes the system drag land, U2's drag returns to main's per-row road, which is
  shipped behaviour that lands. That is a restore, not new behaviour. Its line, its chip and its settle become a
  ticket. A drag that never lands does not ship in 0.9.7.

#### U3c — THE PROBE'S RESULT (the orchestrator, in `vx283-walk`'s fold, 16:23–16:25; `u3c/logs/probe.log`, 824 trace lines)

`window.sh` pre (App/ clean at `34304a6b`, store `store-before/20261015T222336Z`) → probe (exit 0, 3 tests / 1 suite,
6 cases) → restore (identical before copy-back, `cmp`; no keys added; PREFS CLEAN; castle-W1 present).
**The band reproduces on EVERY road, in both voices** (`fromBelow`, `fromAbove`, `fromBelowUntraced`; Terminal 950,
Study 860):
- states 1–4 (the four sort forms): 56 pt;
- 5–6 (typed; `isSearching` true, the relevance label): 24;
- **7, "empty again" (`isSearching` FALSE, the sort door, sort createdAt asc — the same model state as state 4): 24**;
- **8, a sort pick after it: 56**; 9, a relayout: 56.
The sweep's read equals the settled read in every state, so **the harness is not the cause**. The trace isn't
disturbing the layout either (the untraced road agrees). The row's answer has a history. A search moves an input the
decision reads, the input outlives the search, and a sort pick resets it. Which child's numbers move is in the trace
lines (each subview's narrowest / widest / flexibility / ideal / floor / widest-key, the steps' order, the proposal),
for the implementer's T3.

### U2b — the trace leg

**Implementer:** a fresh Opus 5.5 at xhigh (2026-10-15, afternoon), worktree `~/dev/variorum-vx-283`, DerivedData
`App/Variorum/DerivedData/vx283-u2b`. **Not done by this session (first line):** no stage work of any kind (no
`xcodebuild test`, no launch, no walk); no fix (T3 waits for the trace run and the ruling); placed after U3c's probe
result rather than directly under the U2b ruling, so that block keeps its own heading.

**LIVE STATUS (per piece)**
- B0 — T1, the headless trace (below): DONE (`a73a891b`).
- B1 — T2, the DEBUG-only instrument (`OpenListDragTrace`) + its probes: DONE (`688f79c7`).
- B2 — `DerivedData/vx283-u2b` built (`build-for-testing`, TEST BUILD SUCCEEDED, the code of `688f79c7`, no warning in
  a touched file) + `notes/plans/vx283-screens/u2b/window.sh` (gitignored, `zsh -n` clean): DONE.
- B3 — **READY FOR STAGE — U2b trace run, ≈10 min** (`d60087ee`); RUN 17:06–17:08 by the orchestrator (`68a7f5f4`).
- B4 — T3, THE PROPOSAL (`#### U2b — T3, THE PROPOSAL` below): DONE (this commit). Nothing built; the ruling next.

#### T1 — the code trace: every gate between AppKit's drag session and the line (paths under `App/Variorum/Variorum/`)

The line draws only when `OpenListDragState.lineTop` is non-nil (`Features/Library/OpenListDrag.swift:131-135` →
`Core/Views/SidebarLayout.swift:659-669`). Its guard needs FOUR inputs at once: a `hover` (written only by the two
delegates' `dropEntered`/`dropUpdated`), a `dragged` row (`dragging`, written only by `began`), a measured `window`,
and a gap that changes something. The same nil decides the proposal (`OpenListDrag.swift:155`: `.move` where a line
is, `.forbidden` everywhere else), and `.forbidden` means AppKit never calls `performDrop`, so the image slides back.
So "no line anywhere" plus "every release slides back" is ONE observation: `lineTop` stayed nil for the whole drag.
The gates, in the order a drag meets them:

1. **The drag source's payload — where `dragging` is set. CANDIDATE G1, the leading one.** `began(noteID)` runs
   INSIDE the payload closure (`Features/Library/SidebarView.swift:1120-1122`), which reaches SwiftUI as
   `.draggable(payload())`'s `@autoclosure` (`Core/Views/DragChipCanvas.swift:129`). The whole design assumes SwiftUI
   evaluates that autoclosure when the drag BEGINS. **Nothing has ever proven it.**
   - The claim's only source is the Bookcase's note (`Features/Shelf/ShelfViewModel.swift:106-112`: "evaluates when
     the drag BEGINS (pinned: mounting a board evaluates none)"). Its pin proves only the negative: mounting
     evaluates nothing. The positive was never walked: librarywalkpolish's ladder round 1 lists "the strip outlines
     under a real drag" under NOT DONE (1), and 17y's W-4/W-5 rows say "NOT walked".
   - Apple documents no timing for `draggable(_:)`'s payload. The one API whose page says its payload closure "is
     called when a drag operation begins" is the newer `dragContainer(for:in:_:)` (macOS 26). This comes from the
     leg's one Sonnet lookup (external facts, read-only), which found no report either way for `draggable`.
   - **The walk's own AppKit log points the same way** (the walker's `log show` of PID 55680, 16:02:03, kept in the
     orchestrator's scratchpad `u2w/drag-log.txt`). At drag start the drag pasteboard receives our type only as a
     PROMISE: `PromiseDataUsingBlock … flavor: 'io.lduarte.variorum.open-note-row'`, beside SwiftUI's file-promise
     flavors. Through the whole tracking loop that follows (`kCoreDragTrackingInWindow` every ~0.46 s) no
     `data requested for type io.lduarte.variorum.open-note-row` appears. So the value is produced only when a
     consumer loads it, and the only consumer is `perform`'s `loadTransferable`.
   - **If the autoclosure is that lazy, every observation follows.** `dragging` is nil while the drag hovers →
     `lineTop` → nil (`SidebarLayout.swift:662`, `guard let hover, let dragged`) → no line, and `.forbidden` → no
     `performDrop` → the payload is never loaded → `began` never runs → `dragging` stays nil. That covers the rows
     and the end zone alike (both read the same state), both voices, a resize, an overflowing list and a note view:
     exactly the walk's D1/D2.
   - **Why main landed:** main's road needed no drag-start state. A per-row `.dropDestination(for:)` accepts by TYPE
     alone and loads the payload at the drop (main `591bb8e8`, `SidebarView.swift:844-853`).
   - **A latent twin outside this lane, if G1 holds:** the Bookcase's W-5/NIT-3 outlines read `dragInFlight`, which
     is set inside the same lazy autoclosure (`ShelfViewModel.swift:115-118`). A first drag would light no outline,
     and every later drag would read the PREVIOUS drop's payload. The walk's control can't tell: "starred notes" was
     dragged over its OWN shelf, where no outline is due, and the green ＋ is the system's copy badge, not the
     outline. **A ticket at the closeout if the trace confirms G1.**
2. **The source's allowed operations. CANDIDATE G2 — a second gate in series, latent behind G1.** The delegate
   proposes `.move` (`OpenListDrag.swift:155`). On macOS, SwiftUI's Transferable drag source allows COPY only by
   default. The SDK says so: macOS 27's `DragConfiguration.OperationsWithinApp.init(allowCopy: true, allowMove:
   false, allowDelete: false)`, and Apple's `DragConfiguration` page: "By default, only copy is allowed. To support
   drag-to-move … `allowMove: true`" (the lookup). AppKit intersects the destination's operation with the source's
   mask, so `.move` against a copy-only source is NONE: no `performDrop`, and a slide-back. **This would refuse every
   drop even once a line draws.** Main's road never met it: `.dropDestination` proposes copy (the walk's control
   shows the green ＋).
3. **(a) The payload's type vs what the delegate validates — not the cause, by reading.** The token's type
   `io.lduarte.variorum.open-note-row` (`SidebarView.swift:806`, `UTType(exportedAs:)`, a `CodableRepresentation`
   at `:808-810`) is declared in `App/Variorum/VariorumInfo.plist` `UTExportedTypeDeclarations` (conforms to
   `public.data`; pinned by `DragTypeDeclarationTests`). The drag pasteboard carries that exact identifier (the log
   above). Both delegates register and validate the same one type (`OpenListDrag.swift:144`, `:213-215`,
   `:246-248`; `SidebarView.swift:860`, `:991`). Main used the same identifier and landed. The trace logs
   `hasItemsConforming` and the drag pasteboard's types at `validateDrop` and `dropEntered`, so a mismatch would
   show anyway.
4. **(b) The "a drag of its own" gate — G1 is its first half; the identity half is not the cause.** `dragging` is the
   gate (above). `listID` (`OpenListDrag.swift:56`, `@ObservationIgnored let … = UUID()`) lives on the instance
   SwiftUI keeps in `@State openListDrag` (`SidebarView.swift:229`). A body re-evaluation builds and discards a fresh
   `OpenListDragState()`, but the payload closure and both delegates read the KEPT instance. And `listID` is read
   only at `land` (`OpenListDrag.swift:195`), which no hover depends on. `perform`'s refusal
   (`OpenListDrag.swift:175-178`) needs `dragging != nil`, so with G1 it never even forms. The pins never saw any of
   this: every door and mount pin calls `state.began(…)` itself (`VariorumTests/OpenListDragTests.swift:277`, `:293`,
   `:315`, … `:662`), so the gate's real writer was never in a pin's road.
5. **(c) The hit area — unlikely, by reading.** The rows' delegate sits on the LazyVStack inside the ScrollView
   (`SidebarView.swift:851-861`, `.contentShape(Rectangle())` before `.onDrop`). Both overlays above it take no hits:
   the edge fade (`Features/Library/SidebarSectionWindow.swift:206`, `:328` `.allowsHitTesting(false)`) and the line
   (`OpenListDrag.swift:303`). The end zone is a separate target OUTSIDE the scroll view
   (`SidebarView.swift:982-999`) and failed the same way in D2c, which argues for a gate both delegates share (G1/G2)
   over a hit-test peculiar to the ScrollView. The column-level import drop (`SidebarView.swift:381`, `.fileURL` +
   `.plainText`) was also there on main, around the per-row targets that landed. The trace logs the AppKit view
   chain under the pointer, with each view's registered drag types, so a registration or hit gap would show.
6. **(d) What changed from main's working road** (main `591bb8e8` → this tip):
   - (i) the hover now DEPENDS on drag-start state that only the payload writes (G1); main had no such state;
   - (ii) a DropDelegate proposing `.move`/`.forbidden` replaces `.dropDestination`'s implicit copy (G2);
   - (iii) one `onDrop(of:delegate:)` on the content replaces per-row targets;
   - (iv) the preview became the chip canvas (`ChipDragSource`; the Bookcase's own machinery, moved);
   - (v) the token gained `listID` and went `nonisolated` + `Sendable` with a static `contentType`;
   - (vi) U1b's `SidebarSectionWindow` wraps the scroll view (a `ScrollViewReader`, the fade overlay) and VX-286's
     margin moved inside the scroll.
   (i) and (ii) are each sufficient by themselves to refuse every drop. (iii)–(vi) stay unexplained only if the trace
   shows no delegate call at all.

**T1's verdict:** the reading makes **G1 near-certain as the reason no line ever draws, and G2 near-certain as the
reason no drop would land even with a line.** Neither is "beyond doubt": G1 rests on SwiftUI's undocumented timing,
inferred from AppKit's promise log, and G2 on an SDK default plus the intersection rule. So T2's run must CONFIRM both.
It does so with probes that test the fix's two halves without building one (below).

#### T2 — the instrument (`688f79c7`; DEBUG only, nothing in a Release path; no fix in it)

`OpenListDragTrace` (`Features/Library/OpenListDrag.swift`, the `#if DEBUG` tail) is **OFF unless the marker file
`~/Library/Containers/io.lduarte.Variorum.debug/Data/Library/Caches/vx283-u2b-drag.on` exists**. The window's `pre`
clears it, `launch` writes it and `restore` removes it, so no test run and no other launch writes a line.
- **Where the lines go:** every line goes to BOTH
  - the file `~/Library/Containers/io.lduarte.Variorum.debug/Data/Library/Caches/vx283-u2b-drag.log` (each line
    stamped wall-clock ms + system uptime + the flags in force); and
  - the unified log, subsystem **`io.lduarte.variorum.vx283-u2b`**, category `openListDrag`, level notice, public. It
    interleaves there with AppKit's own `DragAndDrop` lines.
- **The read commands:**
  - `cat ~/Library/Containers/io.lduarte.Variorum.debug/Data/Library/Caches/vx283-u2b-drag.log`
  - `log show --start '<launch time>' --debug --info --style compact --predicate 'processIdentifier == <PID> AND
    (subsystem == "io.lduarte.variorum.vx283-u2b" OR category == "DragAndDrop" OR category == "Pasteboard")'`
  - `window.sh read` runs both: `u2b/logs/trace.log`, `trace-counts.txt` (per drag), `trace-key.txt`,
    `unified-<pid>.log`.
- **What it logs:**
  - the rows' and the end zone's `validateDrop` (the answer, `hasItemsConforming`, and the drag pasteboard's TYPES —
    never its data, since reading data would resolve the promise and change the road), `dropEntered`, `dropUpdated`
    (one line per CHANGE of its answer, the repeats counted), `dropExited` and `performDrop`, each with the gate's
    inputs: `dragging`, the dragged index, `listID`, `hover`, the window, the gap, `lineTop`, rows and pitch;
  - the source: `SOURCE payload evaluated` (with `main=` and `dragging` before), `SOURCE preview appeared`;
  - `STATE began` / `ended`;
  - `DOOR perform` (gap, `knownNothing`, the providers' types), its `loadTransferable` outcome, `DOOR land` / `land
    REFUSED`;
  - `LINE drawn at` / `LINE gone`;
  - `COLUMN import drop performed` (the outer `.fileURL`/`.plainText` target);
  - `ENDZONE laid out`;
  - the AppKit HIT CHAIN under the pointer: each view's class and its registered drag-type count, `+OURS` where
    `io.lduarte.variorum.open-note-row` is registered. It's taken at the preview's appearance and at each Open
    row's hover-enter;
  - **every Open row's frame in SCREEN points** (`ROW n=<ordinal> id=… screen=x,y,w,h`, re-logged when the app or
    window becomes active), which is what the window aims from.
- **The marker's words are FLAGS**, re-read on every call, so the window changes them between drags:
  - `trace` observes only.
  - **Probes for T1's two gates.** They test each half of a fix without building one; they are not product
    behaviour, never ship, and are marker-gated:
    - `load` — a delegate's `dropEntered` loads the payload at once, so if loading works mid-drag the source's
      payload closure, and so `began`, runs WHILE the drag hovers;
    - `copy` — the proposal offers `.copy` where it would offer `.move`.
  - Two SOURCE flags are read once at LAUNCH (each attaches a modifier to every Open row at body time; with neither,
    the row is exactly as shipped):
    - `session` logs `onDragSessionUpdated`'s phases (macOS 26);
    - `allowmove` attaches `DragConfiguration(allowMove: true)`.

#### The window — `notes/plans/vx283-screens/u2b/window.sh` (run from anywhere; every path is absolute)

`window.sh pre` → `window.sh drag` → `window.sh restore`. Products: `DerivedData/vx283-u2b`.
- **pre**
  - the strict pgreps (expect none) and `guard.sh --author`;
  - App/ clean;
  - the product present;
  - Debug prefs exported to `u2b/prefs-before.plist`;
  - the dev store's three files copied to `u2b/store-before/<UTC>/`;
  - the marker and the trace cleared.
- **drag** — about 3 min of pointer driving, all `cliclick`, no keys. Every press is preceded by `guard.sh <pid> x y`.
  1. `launch "trace"`: write the marker, `open -n` the product, wait for the `ROW n=5` lines, activate it, and save a
     full-screen launch capture to `u2b/caps/` (a What's New sheet would show there; if one blocks, `aim` fails and
     stops — dismiss it with its own button and run the rest by hand).
  2. `aim`, the conversion check: move to row 2's computed centre from two rows above. It needs row 2's own `HOVER
     n=2 id=…` line before any press, else STOP.
  3. Five drags, each the same path. Press row 2 (30 % in, mid-height) → down to row 3's LOWER quarter-line (the gap
     after row 3, "the row just below"), hold 0.8 s → row 5's UPPER quarter-line, hold → back to row 3's lower,
     hold → release. A sidebar-region capture (cursor included) is taken at each hold, and before, at release +0,
     +0.3 s and +1.5 s (`u2b/caps/<drag>-*.png`), with a before/after pixel diff:
     - **A** `trace`
     - **B** `trace load`
     - **C** `trace load copy`
     - `quit` (SIGTERM to the PID), then `launch "trace session allowmove"` + `aim`
     - **D** `trace session allowmove`
     - **E** `trace session allowmove load`
     - `quit`
  4. `read`.
- **restore**
  - quit if still alive;
  - the trace copied, then the marker and trace removed from the container;
  - the store copied back + `cmp`;
  - added prefs keys deleted, `defaults import`, re-export, the diff printed ("PREFS CLEAN");
  - castle-W1 counted.

The sub-steps run by hand too: `launch "<flags>"` · `aim` · `seg <label> "<flags>"` · `quit` · `read`. The aim needs
no `walk-cap`: it comes from the trace's own ROW lines and is verified by the row's own HOVER line before any press.

#### What each answer means (read `logs/trace-counts.txt` first, then `trace-key.txt`)

- **A — the shipped road:**
  - **G1 CONFIRMED** if: `validateDrop → true`, `dropEntered`, and `dropUpdated → forbidden` with `dragging=nil`;
    NO `SOURCE payload evaluated` (and no `STATE began`) anywhere in A; no `performDrop`; the after capture
    unchanged.
  - **G1 REFUTED** if `SOURCE payload evaluated` + `STATE began` land at the drag's START, before the first
    `dropEntered`. Then:
    - if `lineTop` is non-nil and the answer is `→ move` with `LINE drawn`, but no `performDrop`: G2 alone refuses
      the drop, and a LINE drawn that the capture doesn't show is a separate render fault.
  - **No ROWS/END line at all → H1** (registration or hit-test). Read the hit chains:
    - no view `+OURS` → a registration gap;
    - the hosting view `+OURS` → SwiftUI's own hit test.
  - **`validateDrop → false` → (a)**, the type. Read `dragPboard=` and `conforms=`.
  - **`COLUMN import drop performed` → the outer import target took the drop.**
- **B — load + .move:**
  - **The load works mid-drag** if `PROBE load → success`, then `SOURCE payload evaluated` + `STATE began` WHILE
    hovering, then `→ move` with `lineTop` set and `LINE drawn`. Loading on entry is then a viable G1 fix. At the
    release:
    - **no `performDrop` (a slide-back) → G2 CONFIRMED**;
    - **`performDrop` + `DOOR land` → G2 HOLLOW.**
  - **The load doesn't work mid-drag** if `PROBE load → FAILURE`, or the outcome arrives only at exit or release
    (the lookup found a macOS 15 forum report of exactly that). Loading on entry is then not a G1 fix.
- **C — load + .copy:**
  - **`performDrop` + `DOOR land` and the list changed → copy lands**, so G2's fix is to propose `.copy` (the cursor
    shows the ＋, as main's road did).
  - Still refused → something else; read the log.
- **D — the source's session:**
  - **`SESSION … phase=initial` / `active` before the first `dropEntered` → `onDragSessionUpdated` is a viable
    drag-start signal for G1.** Its `ended` phase could also clear `dragging` (the U2 record's known edge).
  - No SESSION lines → not viable.
  - The delegates still answer `forbidden` (the logger sets no state).
- **E — load + .move with `allowMove` on the source:**
  - **`performDrop` + `DOOR land` (where B was refused) → `allowMove` makes `.move` legal**, G2's other fix. The
    log also shows the ORDER of `SESSION phase=ended(…)` against `ROWS performDrop` (the U2 record's unverified
    order).
  - Refused → `allowMove` doesn't open `.move` to a DropDelegate.

#### U2b — THE TRACE RUN (the orchestrator, claim `vx283-u2b` 17:06:13 → RELEASED 17:08:32; `u2b/logs/trace.log`, `trace-counts.txt`, `trace-key.txt`, `u2b/caps/`)

`window.sh` pre (GUARD OK, the author idle 540 s; App/ clean at `d60087ee`; store `store-before/20261015T230613Z`) →
the steps run by hand (`launch trace`, then the launch capture looked at: no What's New sheet, 13 Open rows; a system
notification banner sat at the top right, clear of the sidebar) → `aim` OK (row 2 `D4C23B6A` at 133,413) → drags
A, B, C → quit → `launch "trace session allowmove"` → aim OK → drags D, E → quit → read → restore (identical before
copy-back, `cmp`; no keys added; PREFS CLEAN; castle-W1 present). GUARD OK at every press, no interference. **No
drag landed (all five lists byte-identical).**
- **A (the shipped road): `payload=1 preview=1 began=1`, then ZERO delegate calls** (validate 0, entered 0, updated 0,
  exited 0, perform 0). **G1 is REFUTED:** the payload is evaluated on the main thread at the drag's start
  (`SOURCE payload evaluated … dragging(before)=nil`, `STATE began` at 17:06:47.39). The list knows its own drag; the
  delegate is never asked.
- **The hit chains (CORRECTED by T3 and the ruling below — `[reg 0]` reads zero even under working targets, so it is NOT the mechanism): every view under the pointer reports `[reg 0]`.** That is
  `PlatformGroupContainer ← DocumentView ← HostingClipView ← HostingScrollView ← PlatformContainer ← …`, at the rows
  (100,527), (133,704) and at the preview's start. The instrument marks `+OURS` where a view registers our type, and
  **no `+OURS` appears anywhere. No AppKit view in the Open list's hit chain is registered for ANY dragged type**, so
  AppKit's tracking never offers the drag to SwiftUI's drop machinery there. The Bookcase's targets react to the same
  road (the walk's control), so the failure is the Open list's registration, not the synthetic drag.
- **D (session + allowMove): the same zero delegate calls.** The session's phases arrive (`initial` at 17:07:53.907,
  then `active` every ~0.35 s; `loc` cycles 0…29 in the source's own coordinate space), and `ended with operation
  cancel` comes at the release. **G2 is moot while the delegate is never called.** It stays a second gate to fix
  with the first (the SDK's copy-only default).
- **B, C, E — the SECOND drag of each launch never started:** `payload=0 preview=0 began=0`, and the mid-drag captures
  show NO chip (`B-mid1-row3lower.png`, `E-mid1-row3lower.png` against `A-`/`D-mid1`, by the orchestrator's eye). So
  load/copy (B, C) and load under allowMove (E) were NOT tested. **A second finding: after one cancelled drag, the
  next press-and-move on a row does not begin a drag.** It is not yet known whether that is the product (a stale
  `dragging` never cleared, since no delegate's `ended`/`exit` ran; the row's gesture gated) or the road (the walk's
  seven variations each started a drag, but with other acts between them). It is owed to T3: the proposal must name
  it, and the re-walk must drag twice in a row.

#### U2b — T3, THE PROPOSAL (the implementer, after the trace run; nothing built — the ruling first)

**First line: no code was built for T3.** One script fix, gitignored: `window.sh read` called zsh's BUILTIN `log`,
not `/usr/bin/log`, so both `unified-*.log` files hold only "too many arguments". It is fixed for the next window.
The file trace (`trace.log`) is complete.

**What the run PROVED (from `trace.log`):**
- **The source works.** At the drag's start the payload is evaluated on the main thread and `began` runs (A
  17:06:47.394, D 17:07:53.892). The chip preview appears, and in D the session reports `initial` → `active` (×27)
  → `ended with operation cancel` 1.8 s after the release.
- **The rows' drop delegate is NEVER CONSULTED:** zero `validateDrop`, which SwiftUI calls before anything else.
  So the delegate attached at `SidebarView.swift:863` (the line numbers here are at `d60087ee`, with the trace hooks
  in) is not reached at all. It is not being reached and then answering `.forbidden`.
- **The `[reg 0]` hit chain proves less than it seems.** The chain under the rows runs up to the ROOT
  `AppKitWindowHostingView[reg 0]`. That same root hosting view carries drop targets that are live in this window:
  the Bookcase's `dropDestination`s react to the same `cliclick` road (the walk's control, same build), and the
  column's import `onDrop` (`SidebarView.swift:381`) sits in the root's own graph. So on macOS 27 SwiftUI's drop
  registration is not visible through `NSView.registeredDraggedTypes` at all: it lives on the window or in SwiftUI's
  own routing. The run cannot say that "no view under the pointer is registered" is the mechanism. What it does show
  is the result: the drag is never offered to this delegate. (The instrument's `+OURS` test is therefore
  uninformative. I designed that test; T1 trusted the reading.)

**1 — Why the delegate is never offered the drag: the candidates.** The placements, compared:
- **Ours:** a legacy `onDrop(of:delegate:)` on the `LazyVStack` at the ROOT of the ScrollView's content
  (`SidebarView.swift:847` `ScrollView {` → `:848` `LazyVStack` → `:862-864` `.contentShape(Rectangle())` +
  `.onDrop(of: OpenListDropDoor.types, delegate: OpenListRowsDrop(…))`). Around the ScrollView:
  - U1b's `SidebarSectionWindow` wraps it in a `ScrollViewReader`, with an overlay that has
    `.allowsHitTesting(false)` (`SidebarSectionWindow.swift:143-207`, `:328`; attached at `SidebarView.swift:889`);
  - the line's overlay, also `.allowsHitTesting(false)` (`:895`; `OpenListDrag.swift`'s `OpenListInsertionLine`);
  - the end zone, a second legacy delegate outside the ScrollView (`:922` → `:993-994`).

  The hit chain shows the content hosted in SwiftUI's scroll machinery, nested twice: the Open list's
  `HostingScrollView` → `DocumentView` → `PlatformGroupContainer`, inside the sidebar's outer last-resort scroll.
- **Main's road, which landed:** `.draggable(token)` + a Transferable `.dropDestination(for: OpenNoteDragToken.self)`
  ON EACH ROW, inside the same `ScrollViewReader { ScrollView { LazyVStack { ForEach … } } }`, nested in the same
  outer scroll (main `591bb8e8` `SidebarView.swift:740-748`, `:844-853`).
- **The Bookcase's working targets:** `BookcaseDropSite`, a Transferable `.dropDestination(for:) … isTargeted:` on
  each strip name, header and row (`Features/Shelf/BookcaseStrip.swift:88-100`). Its import drop is a legacy
  delegate on the BOARD, outside its ScrollView (`Features/Shelf/ShelfView.swift:187` scroll, `:219-229` drop).
- **The book navigator,** the precedent U2 cited for the line: a Transferable `.dropDestination(for:) … isTargeted:`
  on each row, its 2-pt `tokens.ring` line drawn as an overlay at the hovered row's TOP, and a 28-pt end zone that is
  also a `dropDestination` (`Features/BookView/BookView.swift:838-855`, `:861-875`).
- **The Blocks area:** a legacy `onDrop` on the ScrollView itself, outside its content
  (`Features/Pool/BlocksAreaView.swift:370`, `:397`).

**The pattern:** every live drop target INSIDE a scroll's content in this app is a Transferable `dropDestination` on
a row or item. Every legacy `onDrop` sits ON or ABOVE a scroll view. Ours is the only legacy delegate inside a
scroll's content, and the only target of any kind on a scroll content's ROOT. The candidates, none proven alone:
- **C1 — placement:** a drop modifier on the scroll content's ROOT is not routed once the content is hosted in the
  scroll's `PlatformGroupContainer` (`:862-864`). Taps on a container usually reach a root modifier, so this is the
  least likely of the three.
- **C2 — the API inside scroll content:** on macOS 27, the legacy `onDrop(of:delegate:)` road is never routed
  inside a ScrollView's content, while the Transferable `dropDestination` road is. No in-app precedent either way;
  this is the fact the pattern above points at.
- **C3 — type routing on the legacy road:** the legacy road may filter by the drag pasteboard's declared types, and
  ours is present only as a PROMISE beside SwiftUI's private `dyn.*` flavors (the walk's AppKit log). The
  Transferable road matches Transferable drags itself.
- **Not a candidate:**
  - the section window's and the line's overlays: both have hit testing off, and main had a `ScrollViewReader` too;
  - the type's declaration: `VariorumInfo.plist`, and main used the same identifier.

**2 — The second drag that never starts:**
- **NOT our stale `dragging`.** Nothing on the source path reads it (`SidebarView.swift:1120-1146`,
  `Core/Views/DragChipCanvas.swift:116-132`). And in B, C and E the press never became a drag inside SwiftUI's
  source: no payload, no preview, no session.
- **What the evidence draws:**
  - in this window, both failures were the SAME row (row 2), pressed again 5 s after its own drag was REJECTED;
  - in the walk, every consecutive drag started, and each was on a DIFFERENT row: D2a row 2 → D2b row 1 → D2c row 2
    again, with D2b between and ~30 s after D2a → D2d row 10 → D3 row 3 (`D2bcd-D3-study-light-strip.png`, the
    chip in every mid panel);
  - an Apple forum thread (801278, iOS 26, via the lookup) reports exactly this: the same item's drag closure does
    not fire again after a rejected drop, working on iOS 18.

  So the candidate is **SwiftUI's drag source refusing to restart on the SAME source view right after its own
  session ended in cancel**: a framework behaviour, not our code.
- **The one difference that is the road's alone:** `cliclick dd:` warps the pointer and presses, with no
  mouse-moved, so the row sees no hover between the drags. A hand never does that.
- **Product or road is UNDECIDED.** The next window decides it (steps below). If it is the product, the fold-in fix
  (PROVISIONAL, built only on the ruling) is:
  - give the row's drag-source content a fresh identity when its session ends. An inner `.id(dragGeneration)` on
    the content carrying the drag, never the row's outer `.id(noteID)` that the section window's `scrollTo` reads.
  - the trigger is `onDragSessionUpdated` (macOS 26), proven in this run to deliver `ended with operation cancel`.
    The same callback clears `dragging`, which also closes U2's known stale-`dragging` edge.

**3 — The fix (inside the ruled light version; the chip stays on the Open list's rows only).** Move the Open list's
drop onto the road that is proven on this very list and in this window:
- **F1, recommended:** each Open row carries a Transferable drop, in the macOS 26 session form:
  - `dropDestination(for: OpenNoteDragToken.self, isEnabled:action:)`;
  - `onDropSessionUpdated { session in … }` for the hover, whose `DropSession.location` is the pointer in the ROW's
    space;
  - `dropConfiguration { _ in … }` for the operation.

  The hover goes in as `state.hoverRows(contentY: CGFloat(index) * rowHeight + session.location.y)`, which is the
  same content-space input the pure rule already takes. So `SidebarLayout.OpenListDrop` (the half-row rule, the
  false-offer nils, the line's place, the end zone's height), `OpenListInsertionLine` and every pure and mount pin
  stay as they are. The other pieces:
  - **the end zone** becomes the same Transferable destination (the book navigator's own end zone is one);
  - **the action** receives the decoded tokens, so no `loadTransferable` and none of R1-4's "accepted and silent"
    cases;
  - **G2:** the destination asks for `.move` where the line is drawn and `.forbidden` elsewhere, and the row's
    source declares `.dragConfiguration(DragConfiguration(allowMove: true))`, the SDK's own road to a move (copy-only
    is the macOS default);
  - **the session's end** clears `dragging` (via `onDragSessionUpdated`, folded in from item 2);
  - the legacy `OpenListRowsDrop` / `OpenListEndZoneDrop` delegates go; `OpenListDropDoor.perform` takes tokens.
- **F2, the proven fallback inside the light version** (if F1's session location does not arrive while hovering):
  the book navigator's road exactly. A per-row Transferable `dropDestination(for:action:isTargeted:)` marks the
  hovered row; the line sits at that row's TOP and the drop lands BEFORE it (the gap = the row's index, through the
  same `destination` rule, so no line at the dragged row's own two gaps); the 28-pt end zone takes the last slot.
  Line and landing always agree. The half-row refinement is what is lost: to put a row just below its neighbour you
  hover the row after the neighbour. `.copy` is the operation, main's road and the same badge.
- **The floor, unchanged:** main's per-row road (a drop before the hovered row, no line, no settle); its line, chip
  and settle become a ticket.

**4 — The pins:**
- **An AppKit-level "a view under the rows registers the row type" pin CANNOT be written.**
  `registeredDraggedTypes` reads 0 at every level of this window's chain, even above live targets, and the test host
  cannot post a drag. **Only the walk proves delivery.**
- **P-T3-1 (source read, red-on-old):**
  - the Open row's own drop is the Transferable road (inside `openRow`: `dropDestination(for: OpenNoteDragToken.self`
    and `onDropSessionUpdated` — or, under F2, `isTargeted:`);
  - no `onDrop(of:` anywhere in `openGroup`;
  - the row's source carries `dragConfiguration(DragConfiguration(allowMove: true))` (F1).

  RED on the current tree: it has `.onDrop(of: OpenListDropDoor.types, delegate: OpenListRowsDrop(` and no
  `allowMove`. Named revert R-T: restore `:862-864`'s legacy attachment → red. `OpenListDragFaceTests.
  theRowDragsItsChipAndTheListIsTheOneDrop` is edited in place by the ruling, annotated: its "no row is its own drop
  target" assertion inverts, because the rows are the targets again and the location now decides the half.
- **P-T3-2 (pure, red-on-old by a named revert), F1:** the row-local location → the gap, for every row and both
  halves: `OpenListDrop.contentY(row:yInRow:rowHeight:)` = index × pitch + y, fed to `gap(at:)`. Revert R-U: drop the
  index term (every row maps to row 0's gaps) → red. Under F2: `gap(forTargetedRow:)` = the row's index, and the
  existing `destination` rule's own-gap nils.
- **P-T3-3 (state, red-on-old):** the session's end clears the drag: `began(a)` → `sessionEnded()` → `dragging ==
  nil`, and a foreign row hovering after a cancel draws no line (U2's known edge, now pinnable). Revert R-V: the
  `.ended` handling removed → red.
- **The door pins that build an `NSItemProvider`** (`aReleaseReadsThePayloadAndLandsIt`,
  `aReleaseThatOffersNothingRefuses`) move to the token-taking door, edited in place.
- **The mount pins** (`OpenListDragMountTests`) drive `began` and the hover through the state, as before. They prove
  the line DRAWS where the rule says. They cannot prove delivery.
- **G2's mask has no headless pin.** Only a real drop proves `.move` is allowed; P-T3-1 pins the declaration.

**5 — A second window IS needed before building** (two unknowns: F1's per-row session location while hovering, and
whether the second-drag failure is the product). It is a short PROBE build:
- **The probe build** goes into `DerivedData/vx283-u2c`. It keeps the T2 instrument and adds two DEBUG-only,
  launch-flagged roads: `rowsdd` (F1 as specified above, with `allowmove` on the source) and `navigator` (F2).
  With neither flag the build is the shipped tree.
- **launch `trace rowsdd`:**
  - **G1** (the gate): row 2 → row 3's lower quarter, hold, then row 5's upper quarter, hold, then release at
    row 5's upper quarter. Expect `SESSION`/`DROP-SESSION` lines carrying the location, `LINE drawn`, the action,
    `DOOR land`, and the list changed.
  - **G2, drag twice in a row, after an ACCEPTED drop:** the row now at row 2 is pressed again at once (warp, no
    move) → down → release.
  - **G3, drag twice in a row, after a REJECTED drop:** row 4 → release over its own place (`.forbidden`, a
    slide-back); then row 4 at once, no move.
  - **G4:** the same as G3, but between the two drags `cliclick m:` off the list and back onto row 4 (a hover cycle,
    as a hand makes).
  - **G5:** the same as G3, but wait 10 s between the drags.
- **launch `trace navigator`:**
  - **H1:** row 2 → row 5's middle → release; expect the line at row 5's top and a landing before it.
  - **H2:** the end zone: release below the last row; expect the last slot.
  - **H3:** drag twice in a row (as G3).
- **Reading the results:**
  - G1 landing with lines → F1 is confirmed.
  - G1 with no session location but a landing → F1 is out; F2 if H1 and H2 land.
  - G3 fails and G4 starts → the road (cliclick's warp). Nothing to fix; the re-walk drags with a hover between.
  - G3 and G4 fail, G5 starts → the product, time-bound.
  - All three fail → the product; the fold-in fix above.
- **Its window script:** `u2c/window.sh`, the same shape, run as pre · drag · restore. It calls `/usr/bin/log`
  explicitly. It aims from the trace's ROW lines, as this run did; this run proved the aim (AIM OK ×2).

**The probe window's alternative, for the orchestrator to weigh:** build F1 at once, with F2 and the generation
workaround held in reserve, and make its first stage window the confirmation (G1–G5 on the product build). It costs
less if F1 works, and the same as the probe road if it does not. I recommend the PROBE road: two unknowns, both on
an API this app has never used, and the ruling asked to confirm before building.

#### U2b — THE ORCHESTRATOR'S RULING ON T3 (2026-10-15 ~17:35 — P-U2b-1; the build is leg U2c, a FRESH implementer)

**The correction is accepted.** The trace run's `[reg 0]` reads zero up to the root hosting view, under targets that DO
work (the Bookcase), so on macOS 27 SwiftUI's drop registration is not visible through `registeredDraggedTypes`. The
record's "no view is registered" (the trace run's section) is therefore NOT the mechanism; that line stands corrected
here. What the run proves stands: the source works, and the delegate is never consulted (zero `validateDrop`). The
discriminating fact is the pattern T3 found: every working drop inside scroll content in this app is a per-row
Transferable `.dropDestination`, and ours is the only legacy `onDrop(of:delegate:)` inside scroll content, on a
content root.
- **P-U2b-1 (PROVISIONAL, the orchestrator's): build F1 DIRECTLY, with no probe build.** The product's first window
  OPENS with the drag checks, before any batch, so a failed F1 costs a short window, the same as the probe would, and
  no throwaway DEBUG roads are built. F1 per T3 §3:
  - each Open row's Transferable `dropDestination(for: OpenNoteDragToken.self, isEnabled:action:)`;
  - `onDropSessionUpdated` mapping the row-local location to content (`index × rowHeight + location.y`) into the
    unchanged pure half-row rule and the line overlay;
  - `dropConfiguration` answering `.move` where the line is drawn, `.forbidden` elsewhere;
  - the source's `DragConfiguration(allowMove: true)` (G2);
  - the end zone the same kind of drop;
  - the session's end clears `dragging`;
  - the legacy delegates removed.
  The chip stays on the Open rows only; the light version, as ruled.
- **F2 is PRE-RULED as the next build if F1's drag check does not land:** the book navigator's road exactly (per-row
  `isTargeted:`, the line at the hovered row's top, the drop before that row, the end zone for the last slot). No
  new ruling is needed. **The floor stays main's per-row road.**
- **The second drag:** the inner-identity fix is NOT built now. F1 clears `dragging` at the session's end. The window's
  G3/G4/G5 decide road vs product: G3 fails but G4 starts = the road (the re-walk hovers between drags); G3/G4 fail but
  G5 starts = product, time-bound; all three fail = product. If it is the product, the inner `.id(dragGeneration)`
  fix (T3 §2) is PRE-RULED as a micro-leg, its pin the same window's G-steps.
- **The pins (pin first, red-first commit):** P-T3-1 (source read; revert R-T), P-T3-2 (pure: the row-local location
  maps to the right gap for every row and both halves; revert R-U), P-T3-3 (state: the session's end clears `dragging`;
  revert R-V). The in-place edits are annotated: `theRowDragsItsChipAndTheListIsTheOneDrop` inverts its "no row is its
  own drop target" assertion, and the two `NSItemProvider` door pins move to the token-taking door. G2's operation
  mask has no headless pin; the walk proves it. Every other pure and mount pin of U2 must stay green UNCHANGED (the
  half-row rule is untouched).
- **The T2 instrument stays** (DEBUG-only, marker-gated, as the U3c oracle), with `read` using `/usr/bin/log` (T3's
  script fix), so the product window can read a trace. The ladder may ask for it to go.
- **THE WINDOW (one claim, folded; `u2c/window.sh`):**
  1. **the drag checks first** — G1–G5 per T3 §5 on the product build, traced;
  2. if G1 lands: the U2 pins and the three new ones on `vx283-u2c`, then R-T / R-U / R-V on their prebuilt trees,
     then the 144-suite batch (`u2/batch-suites.txt` plus any suite file the leg adds);
  3. restore;
  4. SEAM;
  5. the RE-WALK (a fresh Opus at xhigh): U2's D1–D4 and D7 with real drags, both voices, every drag done TWICE IN A
     ROW (with a hover between the pair, per G4's answer), and D8 on `vx283-u3c`.
  If G1 does not land: restore, release, and build F2.

### U2c — the build (F1, as P-U2b-1 rules)

**Implementer:** a fresh Opus 5.5 at xhigh (2026-10-15, evening), worktree `~/dev/variorum-vx-283`, DerivedData
`App/Variorum/DerivedData/vx283-u2c` (+ the revert trees `-rt`, `-ru`, `-rv`). **Not done by this session (first
line):** no stage work of any kind — no `xcodebuild test`, no launch, no walk; the window's drag checks, the pins' runs,
the reverts' runs and the batch are the orchestrator's window (`u2c/window.sh`). F2 and the second-drag micro-leg are
NOT built (pre-ruled, held for the window's answers).

**LIVE STATUS (per piece)**
- C0 — this section opened (`5589be29`); the SDK's session-form API confirmed (below): DONE.
- C1 — the pins, red-first, no product line: DONE (`51253c7c`).
- C2 — F1, the fix: DONE (`e93e4246`); `build-for-testing` → TEST BUILD SUCCEEDED on `DerivedData/vx283-u2c`, no
  warning in a touched file; the headless replica green (below).
- C3 — the three revert trees, each named below BEFORE it was applied (`9b7a63bc`), applied to the tip `9b7a63bc`
  (whose code is `e93e4246`'s), built (`build-for-testing` → TEST BUILD SUCCEEDED ×3: `DerivedData/vx283-u2c-rt`,
  `-ru`, `-rv`; logs `u2c/logs/bft-r{t,u,v}.log`; patches `u2c/reverts/R-{T,U,V}.patch`, gitignored), each restored by
  `git checkout -- <file>` with `git diff` empty after: DONE. **No revert is in the tree.**
- C4 — `notes/plans/vx283-screens/u2c/window.sh` (gitignored; `zsh -n` clean; its count logic dry-run on a synthetic
  trace) + **READY FOR STAGE — U2c window (drag checks → pins/reverts/batch), ≈30 min, then the re-walk**: DONE (this
  commit). The window below.

**The SDK, confirmed before a session-form call was written** (Xcode 27, `MacOSX.sdk`, SwiftUI's
`arm64e-apple-macos.swiftinterface` and its `.swiftdoc`). Every API exists as T3 assumed; nothing was built around a
gap:
- `dropDestination<T>(for:isEnabled: Bool = true, action: ([T], DropSession) -> Void)` — macOS 26 (`:2720`);
- `onDropSessionUpdated(_: (DropSession) -> Void)` and `dropConfiguration(_: (DropSession) -> DropConfiguration)` —
  `@available(iOS 27.0, macOS 26.0)` (`:2727`, `:2729`);
- `DropSession` — `phase` (`entering · active · exiting · ended(DropOperation) · dataTransferCompleted`),
  `location: CGPoint`, `suggestedOperations`, `itemsCount` (`:11073`). Its doc comment: **"The location of the drag in
  the coordinate space of the drop view"** — the row's own space, T3's assumption, now the SDK's word;
- `DropConfiguration(operation:)` (`:15069`); the doc: "The closure that provides the configuration is called
  frequently to allow specifying different operations for different drop locations in a view";
- `onDropSessionUpdated`'s doc: "called when the closest drop session in the child view hierarchy becomes active" —
  so it wraps the `dropDestination` (applied after it), the documented example's order for `dropConfiguration` too;
- `dragConfiguration(_: DragConfiguration)` + `DragConfiguration(allowMove:)`; `OperationsWithinApp.init(allowCopy:
  true, allowMove: false, …)` — copy-only by default on macOS (`:19938`, `:32514`);
- `onDragSessionUpdated(_: (DragSession) -> Void)`, `DragSession.Phase.ended(DropOperation)` on macOS (`ending` is
  macOS-unavailable) (`:4177`, `:32509`).

**THE BUILD (`e93e4246`; paths under `App/Variorum/Variorum/`):**
- `Core/Views/SidebarLayout.swift:631-639` — `OpenListDrop.contentY(row:yInRow:rowHeight:)` = index × pitch + the
  row-local y (the rows abut: `LazyVStack(spacing: 0)` with horizontal padding only, each row `rowChrome`'s
  `.frame(height: rowHeight)`, the first at the top). The half-row rule (`gap(at:)`, `destination`, `lineTop`,
  `endZoneHeight`) is untouched.
- `Features/Library/OpenListDrag.swift` (rewritten around the same state, door and line):
  - `OpenListDragState` (`:66-183`): new `hoverRow(_:yInRow:rowHeight:)` (the pure mapping, then the unchanged
    `hoverRows(contentY:)`); `leftRow(_:)` (clears only a hover THAT row wrote — `rowSource`, the row the last update
    came from: each row is its own drop now, so the next row's entry may arrive before the last one's exit — the end
    zone's precedent); `dragSessionUpdated(_ phase: DragSession.Phase)` (its `.ended` calls `ended()`; any other phase
    changes nothing). `began`'s R1-4 known-edge note is replaced by what now holds.
  - `OpenListDropDoor` (`:187-270`): `types` gone (nothing reads it); new `configuration(_:rows:rowHeight:)` =
    `DropConfiguration(operation: proposal(…).operation)` (the one decision; `proposal` unchanged); `perform` takes the
    DECODED tokens (`[OpenNoteDragToken]`, `animation:` defaulting to the settle) — synchronous, no item provider, no
    `loadTransferable`, so R1-4's "accepted and silent" cases shrink to the rows changing between the last update and
    the release (`land` re-validates); `land` unchanged.
  - `OpenListRowDrop` (`:276-321`, NEW, a `ViewModifier`): `.dropDestination(for: SidebarView.OpenNoteDragToken.self,
    isEnabled: true) { tokens, session in … }` — the action refreshes the hover from ITS OWN location, then `perform`;
    `.onDropSessionUpdated` — `entering`/`active` → `hoverRow(index, yInRow: location.y, …)`, every other phase →
    `leftRow(index)`; `.dropConfiguration` — the hover refreshed too (P-U2c-1), then `OpenListDropDoor.configuration`.
  - `OpenListEndZoneDrop` (`:325-360`, NEW): the same form, `hoverEnd` / `leftEnd`.
  - The `DropDelegate`s `OpenListRowsDrop` / `OpenListEndZoneDrop` REMOVED (the end zone's name now belongs to its
    modifier). `OpenListInsertionLine` unchanged.
  - The instrument (`#if DEBUG`, `:405-652`) KEPT, marker-gated as before (`vx283-u2b-drag.on` / `.log`, subsystem
    `io.lduarte.variorum.vx283-u2b` — names unchanged), re-hooked: `<site> DROP-SESSION phase=… loc=… suggested=…
    items=… · <gate>` and `<site> CONFIG → move|forbidden|copy …`, each ONE line per change of what the site decides
    (phase, dragging, gap, line), the identical ticks folded into a count; `<site> ACTION phase=… loc=… tokens=[row@list]`;
    `DOOR perform … tokens=…`, `DOOR land` / `land REFUSED`; `LINE drawn` / `gone`; `SOURCE payload evaluated`, `SOURCE
    preview appeared`, `SESSION row=… phase=… loc=…` (the source's drag session); `STATE began`, `STATE the drag session
    ended (…)`, `STATE ended`; `ENDZONE laid out`; `COLUMN import drop performed`; `ROW n=… screen=…` and `HOVER n=…`.
    Sites are `ROW n=<ordinal>` and `END`. U2b's probes `load`, `session`, `allowmove` RETIRED (no `DropInfo` to load
    from; the session hook and `allowMove` are the product); `copy` KEPT as a diagnostic (the configuration offers COPY
    where it would offer MOVE — the window's optional `g1copy`).
- `Features/Library/SidebarView.swift`: the scroll content's `.contentShape(Rectangle())` + legacy `.onDrop(of:
  delegate:)` removed (`:857-859` keeps a note); the end zone carries `.modifier(OpenListEndZoneDrop(…))` (`:989`);
  `openRow` (`:1138-1151`) carries `.dragConfiguration(DragConfiguration(allowMove: true))`, `.onDragSessionUpdated {
  … openListDrag.dragSessionUpdated(session.phase) }` (+ the DEBUG `SESSION` line) and `.modifier(OpenListRowDrop(state:,
  index: ordinal - 1, rows: workspace.openNotes.shown, rowHeight:, workspace:))`; U2b's `OpenListDragTraceSource` gone.
  `openRow` grew ~470 characters; the source reads that bound it by a prefix still reach its context menu
  (`Button("Close")` at 6 475 of `theXAndRightClickCloseBothRunTheOneAct`'s 8 000; the body ends at 7 098).
- **Not touched:** `SidebarSectionWindow.swift`, `OpenNotes.move` / `WorkspaceModel.move`, the chip
  (`DragChipCanvas.swift`, `ChipDragSource`), the line, `ShelfView.swift`, `ShellActions`, `ShellRouter.swift`, the
  editor seam, `Sync/`, custody, schema.

**A consequence of F1, stated (the ruled shape's geometry, not a provisional):** the drop targets are the ROWS, so the
Open list's 12-pt side margins (`scrollingSectionMargin`, inside the scroll) take no drop — a pointer there is over no
row, the hover clears, no line draws and a release there slides back. Main's per-row road had the same; U2's
content-root delegate had covered the margins. The line spans exactly the rows' width, so line and target agree.

**PROVISIONAL (U2c), one:**
- **P-U2c-1 — the drop side's non-entering phases clear the row's own hover** (`exiting`, `ended`,
  `dataTransferCompleted` → `leftRow(index)`), and the configuration closure refreshes the hover too. The SDK states
  neither the order of a tick's `onDropSessionUpdated` against its `dropConfiguration` nor whether `ended` precedes the
  action; the build is order-proof by construction: the action re-derives its gap from its own session location before
  the door, `leftRow` never clears another row's hover, and the source's session end (which clears everything) may land
  before or after the drop. Options: (a) [built]; (b) refresh only in `onDropSessionUpdated` (a configuration could
  answer one tick stale at a boundary); (c) clear on `exiting` only (an `ended` over a row would leave the hover until
  the source's session end clears it). The window's trace shows the real order.

**THE PINS (`VariorumTests/OpenListDragTests.swift`, `51253c7c` — red-first, no product line):**
- **P-T3-1** `OpenListDragFaceTests.eachRowIsATransferableDropAndItsSourceAllowsTheMove` (source read): `openRow`
  carries `.modifier(OpenListRowDrop(`, `.dragConfiguration(DragConfiguration(allowMove: true))` and an
  `.onDragSessionUpdated {` into `openListDrag.dragSessionUpdated(`; `openGroup` and `openListEndZone` carry no
  `onDrop(of:`; the end zone carries `.modifier(OpenListEndZoneDrop(`; BOTH modifiers' bodies (in `OpenListDrag.swift`)
  carry `.dropDestination(for: SidebarView.OpenNoteDragToken.self, isEnabled:`, `.onDropSessionUpdated {` and
  `.dropConfiguration {` answering `OpenListDropDoor.configuration(`; no `: DropDelegate` remains in the drag file.
  **The reading of the ruling's "inside `openRow`":** the drop's three calls live in the `OpenListRowDrop` modifier
  beside the door (P-9 — `SidebarView` is ~1 500 lines), applied inside `openRow`; the pin reads both. Red on the
  pre-fix tree at runtime (it compiles there).
- **P-T3-2** `OpenListDropRuleTests.aRowsOwnLocationNamesTheGapForEveryRowAndBothHalves` (pure: 1…8 rows × both pitches
  × every row × fractions 0, .05, .3, .49, .5, .7, .95 — `contentY` = index × pitch + y, and `gap(at:)` of it is the gap
  beside THAT row) + its state road `OpenListDropDoorTests.aRowsOwnLocationDrawsTheLineAndLandsThere` (a list scrolled
  45 pt; row 4, 20 pt down → gap 5, the line at 104, `.move`, the release lands n0 after n4).
- **P-T3-3** `OpenListDropDoorTests.theDragSessionsEndClearsTheDrag`: `began(a)` + a line → `.active` keeps the drag →
  `.ended(.cancel)` clears `dragging` and the hover → a foreign hover after it draws no line and is offered `.forbidden`
  (U2's known edge, pinned) → `.ended(.move)` clears too.
- **Guards (new behaviour, not red-on-old):** `movingBetweenRowsNeverBlanksTheHover` (either arrival order between two
  rows; a row's late exit leaves the end zone's hover) and `aSessionEndBeforeTheDropsActionStillLands` (the source's end
  first, then the action: it lands — green on both sides of R-V by design).
- **Edited in place by the ruling, annotated:** `theRowDragsItsChipAndTheListIsTheOneDrop` → renamed
  **`theRowDragsItsChipAndIsItsOwnDrop`** (the old name would contradict the body — R1-5's class): "no row is its own
  drop target" INVERTS to `row.contains(".modifier(OpenListRowDrop(")`, and "the list's rows are one drop target"
  (`delegate: OpenListRowsDrop(`) is withdrawn. `aReleaseReadsThePayloadAndLandsIt` and
  `aReleaseThatOffersNothingRefuses` take the decoded tokens (no `NSItemProvider`, no polling; `animation: nil`).
- **Unchanged:** every other pure, door and mount pin of U2 (the half-row rule, the line on every axis, the end zone,
  the settle-in-place) and every `SidebarSectionWindow` pin. **No suite was added or renamed** — the new pins join the
  existing four suites, so `u2/batch-suites.txt` needs no line.
- **The red-first commit does not COMPILE the test target on the pre-fix tree** (P-T3-2/P-T3-3 and the edited door pins
  name the fix's new API — `contentY`, `hoverRow`/`leftRow`, `dragSessionUpdated`, the token-taking `perform`); only
  P-T3-1 is runtime-red there. Each pin's runtime red-on-old is its named revert tree below.
- **No headless pin for delivery or for G2's mask:** `registeredDraggedTypes` reads 0 even above live targets and the
  test host cannot post a drag. Only the window's G1–G5 and the re-walk prove that AppKit offers the drag to the rows and
  that `.move` is allowed.

**Headless evidence:** `build-for-testing` → TEST BUILD SUCCEEDED (`DerivedData/vx283-u2c`, `e93e4246`'s code; log
`u2c/logs/bft.log`). A replica (scratchpad only): the REAL `SidebarLayout.swift`, the real `OpenNotes` struct, the real
`OpenListDragState` + `OpenListDropDoor` cut from `OpenListDrag.swift` (non-DEBUG), a two-line `WorkspaceModel` stub,
and the bodies of P-T3-2 (both), P-T3-3, the two guards and the two edited door pins — compiled with `swiftc
-swift-version 6 -default-isolation MainActor`: **1035 checks, 0 failed**; with R-U applied **789 failed, all in P-T3-2's
two pins** (784 pure, 5 state); with R-V **4 failed, all in P-T3-3**.

**THE REVERTS — named BEFORE any is applied** (each applied to the committed tip, built with `build-for-testing` into
its own DerivedData, then restored by `git checkout -- <file>`, `git diff` empty after; the patches kept gitignored in
`u2c/reverts/`):
- **R-T (P-T3-1 — the legacy attachment restored, the shape the pin guards against).** In `SidebarView.swift`:
  `openRow` loses `.dragConfiguration(DragConfiguration(allowMove: true))` and the three-line
  `.modifier(OpenListRowDrop(…))`; `openGroup`'s scroll content regains, after its horizontal padding,
  `.contentShape(Rectangle())` + `.onDrop(of: [OpenNoteDragToken.contentType], isTargeted: nil) { _ in false }` — the
  legacy `onDrop(of:)` form (the delegate types no longer exist, so the stand-in accepts nothing; the pin reads the
  attachment, not its delegate). Products `DerivedData/vx283-u2c-rt`. Expected on `OpenListDragFaceTests` (3 tests):
  **RED exactly** `eachRowIsATransferableDropAndItsSourceAllowsTheMove` and `theRowDragsItsChipAndIsItsOwnDrop`; GREEN
  `theOpenRowsChipIsItsTitleAtTheGrabPoint`.
- **R-U (P-T3-2 — the index term dropped).** In `SidebarLayout.swift`, `OpenListDrop.contentY`'s body
  `CGFloat(row) * rowHeight + yInRow` → `yInRow` (every row maps to row 0's gaps). Products `DerivedData/vx283-u2c-ru`.
  Expected on `OpenListDropRuleTests` + `OpenListDropDoorTests` (15 + 12 = 27 tests): **RED exactly**
  `OpenListDropRuleTests.aRowsOwnLocationNamesTheGapForEveryRowAndBothHalves` and
  `OpenListDropDoorTests.aRowsOwnLocationDrawsTheLineAndLandsThere`; the other 25 GREEN (incl. the two guards and P-T3-3
  — they drive `hoverRows(contentY:)` or read only the hover's presence).
- **R-V (P-T3-3 — the session's end handling removed).** In `OpenListDrag.swift`, `OpenListDragState.dragSessionUpdated`
  loses its one `ended()` call (the guard and the DEBUG line stay). Products `DerivedData/vx283-u2c-rv`. Expected on
  `OpenListDropDoorTests` (12 tests): **RED exactly** `theDragSessionsEndClearsTheDrag`; the other 11 GREEN (incl.
  `aSessionEndBeforeTheDropsActionStillLands`, green on both sides by design).

**THE WINDOW — `notes/plans/vx283-screens/u2c/window.sh`** (u2b's proven helpers: `ourpid` by the exact binary path,
`guard.sh --author` then `guard.sh <pid> x y` before every press, the aim from the instrument's own `ROW n=… screen=…`
lines verified by the row's `HOVER` line, `/usr/bin/log`). Run `pre` → `drag` → `pins` → `rt` → `ru` → `rv` → `batch`
→ `restore`, then SEAM, then the re-walk (P-U2b-1's step 5). Each step's EXPECTED result is written in the script's
header and here:
- **pre** — the strict pgreps print nothing; `GUARD OK`; "App/ clean at <tip>"; all four products present
  (`vx283-u2c`, `-rt`, `-ru`, `-rv`); the Debug prefs exported; the store's three files copied to
  `u2c/store-before/<UTC>/`; the marker and the trace cleared.
- **drag** — `launch "trace"` (a launch capture; a What's New sheet would stop `aim` — dismiss it with its own button)
  → `aim` (AIM OK) → G1 … G5, each with before / mid / after region captures in `u2c/caps/`, the ids of rows 1–6 before
  and after, a pixel bbox of the change, and a VERDICT line (two witnesses: the latest `ROW` line of the expected row,
  and the drag's own `DOOR land row=<pressed>` line) → `read`.
  - **G1** — row 2 pressed → row 3's lower quarter, hold 0.8 s → row 5's upper quarter, hold → release there.
    EXPECT: `ROW n=3 DROP-SESSION phase=entering|active loc=(x,≈22)` and `ROW n=5 … loc=(x,≈7)` (the location in the
    ROW's space, 0…pitch), `CONFIG → move` at both holds, `LINE drawn`, `ROW n=5 ACTION`, `DOOR perform gap=4`, `DOOR
    land … from=1 to=4`, the source's `SESSION … phase=ended(move)` → **"VERDICT G1 LANDED"** (the pressed note at row
    4). **If G1 does not land, the script STOPS after G1** (the ruling: restore, release, build F2). The counts say
    why: `dsess=0` → the session form is not offered the drag either → F2 as pre-ruled; `dsess>0`, `cfg.move>0`,
    `line>0` but `action=0` → the drop arrives and the MOVE is refused → the OPTIONAL `window.sh g1copy` (one drag like
    G1 with the `copy` flag; if it lands, the source's mask refuses `.move` despite `allowMove` — F2 proposes `.copy`);
    a location outside 0…pitch or the wrong gap → the session's location is not the row's space (report it).
  - **G2** — after that ACCEPTED drop, the row now at row 2 pressed AT ONCE (a warp, no move) → row 3's lower quarter →
    release. EXPECT the drag starts (`payload`, `preview`, `SESSION initial`) and **"G2 LANDED"** (at row 3).
  - **G3** — row 4 → row 5's upper quarter → back to row 4's lower quarter (both its own gap; the detour only makes
    sure a drag BEGINS) → release: EXPECT `CONFIG → forbidden`, no ACTION, a slide-back, "G3a unchanged — as
    expected"; then row 4 AT ONCE → row 2's upper quarter → **"G3b LANDED"** (at row 2), or the drag never starts
    (`payload=0 preview=0` in G3b).
  - **G4** — as G3, but between the two drags the pointer leaves the list (into the content) and comes back onto row 4
    (a hover cycle, as a hand makes); G4b → row 5's lower quarter: **"G4b LANDED"** (at row 5).
  - **G5** — as G3, with a 10-s wait between the drags; G5b → row 2's lower quarter: **"G5b LANDED"** (at row 3).
  - **"AT ONCE" is the soonest the guard allows** (a deviation from T3 §5's letter, recorded): every `cliclick` act
    resets HIDIdleTime and the guard wants ≥ 2 s idle (WalkKit's SELF-TRIP rule), so the second press waits for HID
    idle ≥ 2 s (`waitidle`, ≤ 6 s; a human keeps resetting it and the guard then stops the window — never retried) —
    ≈2 s after the release, against U2b's failing B at 5 s and G5's 10 s.
  - **Reading G3–G5 (the ruling):** G3b fails but G4b starts = the ROAD (the re-walk hovers between drags); G3b and G4b
    fail but G5b starts = the PRODUCT, time-bound; all three fail = the PRODUCT → the pre-ruled micro-leg (the inner
    `.id(dragGeneration)`), these G-steps its pin; all three land = neither.
  - **read** — `u2c/logs/trace.log`; `trace-counts.txt` per drag (from its begin to the next — the source's session end
    lands ~1–2 s after a release): `payload preview began src.session src.ended dsess cfg.move cfg.forbidden cfg.copy
    action perform land refused line st.ended column`; `trace-key.txt`; `unified-<pid>.log`.
- **pins** — on `vx283-u2c`: `OpenListDropRuleTests` (15) · `OpenListDropDoorTests` (12) · `OpenListDragFaceTests` (3)
  · `OpenListDragMountTests` (3) · `SidebarSectionWindowRuleTests` + `SidebarSectionWindowMountTests` (27): EXPECT
  **"Test run with 60 tests in 6 suites" passed**, no skips.
- **rt / ru / rv** — each on its own tree, exactly the RED and GREEN lists under THE REVERTS above (R-T 2 red of 3; R-U
  2 red of 27; R-V 1 red of 12); each step deletes its tree after.
- **batch** — `u2/batch-suites.txt` (144 suites; no line added — no suite was added or renamed) on `vx283-u2c`: EXPECT
  all green but `BookCollectingDoorsTests.theSettingsDoorIsOneActOnBothRoads` (VX-115, red on main, untouched); ≈728
  tests (722 at the last U2 batch + U2c's six; more if a listed suite grew since); the skips the opt-in harnesses only
  (9 last time) — record the "Test run with N tests" line AND the skipped lines.
- **restore** — quit by PID (a missed synthetic mouse-up keeps AppKit's drag loop open: the script names the `sample`
  check and the second `du`); the trace copied, the marker + trace removed; the store copied back + `cmp` ×3; the added
  prefs keys deleted, `defaults import`, re-export: "PREFS CLEAN"; "castle-W1 present: 1". KEEP `DerivedData/vx283-u2c`
  for the re-walk.

#### U2c — THE WINDOW (the orchestrator, claim `vx283-u2c` 07:04:37 →; `u2c/logs/trace.log`, `trace-counts`, `u2c/caps/`)

`window.sh` pre (GUARD OK, the author idle ~13.9 h — she is asleep; App/ clean at `ab535ab2`; four products; store
`store-before/20261016T130437Z`) → `launch trace` (PID 28528; the launch capture looked at: no What's New sheet, 13
Open rows) → `aim` OK (row 2 `D4C23B6A` at 133,413) → **G1: DID NOT LAND.**
- **G1's counts:** `payload=1 preview=1 began=1 src.session=21 src.ended=1` · **`dsess=0`** · `cfg.*=0` · `action=0` ·
  `perform=0` · `land=0` · `line=0`. The source's session runs (initial → active ×21 → ended with cancel), but **no
  per-row drop session update ever arrives**. F1's session-form `dropDestination` is never consulted, exactly as the
  legacy delegate wasn't. Per the ruling, F1 is refuted under this road.
- **G3–G5 run anyway** (they test the SOURCE only; within the claim's stated scope):
  - G3a (row 4, ~30 s after G1) STARTED;
  - **G3b (row 4 again ~2 s after its cancel) did NOT start** (no payload, no session);
  - G4a (row 4 again, after a hover off the list and back) started a session (22 updates; the payload not re-evaluated);
  - G4b started;
  - **G5a (row 4 again, after a 10-s wait) did NOT start**;
  - G5b started.
  So a press on the same row right after a cancelled drag starts every OTHER time, whatever the wait. Road or product
  is still undecided (no drop has landed on this road yet, so "after an accepted drop", G2, is untested).
- restore (07:1x): the store identical before copy-back, `cmp`; no keys added; PREFS CLEAN; castle-W1 present; no
  instance. The pins, R-T/R-U/R-V and the batch did NOT run (pointless on a road that does not land).
- **THE DISCRIMINATOR OWED BEFORE F2 (the orchestrator's call):** F1, the legacy delegate AND F2 are all SwiftUI drops
  on rows inside the sidebar's Open list. F2's and main's per-row `.dropDestination(…isTargeted:)` belong to the API
  family the Bookcase strip uses, and the strip works under this road (the walk's control). But the Open list sits in
  the SIDEBAR, and no drop on this road has ever landed there. So before building F2: **main's own Debug build
  (`a7c0a25f`, headless into `DerivedData/vx283-main`), the same `cliclick` drag on its Open list.**
  - Main's drag lands → this branch broke the drop (the container, the source's chip road, or the API); F2 plus a
    bisect of the branch's sidebar changes.
  - Main's drag does not land → synthetic drags cannot reach sidebar drops, and the walk road is invalid for this
    question. Then the evidence has to come another way, and this is said plainly in the morning handoff.

#### U2c — THE MAIN-BUILD CONTROL (the same claim, 07:09–07:12, the coordinator's yes; `u2c/main-control/`)

Main's own Debug build (`a7c0a25f`; the branch carries no `Sources/` diff, so no schema the store doesn't know), headless
into `DerivedData/vx283-main`. A fresh copy of all FIVE store files (3 db + 2 key json, `main-control/store-before/
20261016T130945Z`) → launch (the 0.9.7 What's New sheet, dismissed with its own Continue) → the same rows as the
branch (row 2 at y≈412, pitch 30). Then three `cliclick` drags of row 2 (each with a hover before the press) → row 3's
lower quarter → row 5's upper quarter → release.
- **Main's drag DID NOT LAND either:** its default drag image rides at the cursor (`c1-mid-*.png`), the rows never react,
  and the list is unchanged after each release (`c1`, `c2`, `c3` changed-bbox None). Main's per-row
  `.dropDestination` (the road her hands used, her "janky", landing before the row under the pointer) is NOT reached by
  the synthetic road. **So synthetic `cliclick` drags cannot reach drop targets in the window's sidebar, on main or
  this branch.** The walk's D1/D2 "does not land" (and U2b's and U2c's zero delegate/session calls) are this road's
  limit, NOT evidence that U2 broke the drag. The Bookcase control lit its ＋ because its targets sit in the main
  content, not the sidebar.
- **The second drag:** on main, consecutive drags of the same row each STARTED (`c2`, `c3` show the image). Those
  presses came after a hover. U2c's G4a (after a hover) also started, while G3b and G5a (pressed with no hover) did not.
  **The every-other-press pattern is the road's press-without-hover** (T3's reading), not a product fault. A hand always
  hovers before it presses. Recorded, no fix.
- **THE RESTORE AND A SLIP:** the control script's `restore` called its own `quit` without execute permission, so it
  restored the store and RELEASED the claim (07:12:31) with the control's own instance (PID 32411) still up. It was
  caught at once: that instance was quit at ~07:13, then all five files were re-checked. They were `cmp`-identical
  before the re-copy (the app wrote nothing), re-copied and verified, prefs re-checked after the quit: PREFS CLEAN.
  Zero instances, castle-W1 untouched, `vx283-main` deleted. The coordinator was told the same.

#### U2 — THE ORCHESTRATOR'S RULING AFTER THE CONTROL (2026-10-16 ~07:20 — P-U2d-1, the drag's evidence standard and the build)

- **P-U2d-1 (PROVISIONAL, the orchestrator's, in her overnight absence): build F2 (pre-ruled), the book navigator's road,
  on MAIN's own per-row API** — `.dropDestination(for: OpenNoteDragToken.self, action:isTargeted:)` on each Open row:
  - the 2-pt ring line at the targeted row's top;
  - the drop lands before that row (main's own landing, which her hands have used);
  - an end-zone drop below the last row for the last slot;
  - the settle;
  - no line and no move on the dragged row's own place.
  The source keeps the chip at the cursor and `dragging` set at the payload's evaluation (proven at drag start by U2b's
  run) and cleared at the source session's `ended` (proven delivered). Dropped:
  - the macOS 26 session form (F1: `onDropSessionUpdated`, `dropConfiguration`), unproven by any hand;
  - `DragConfiguration(allowMove:)` (main's copy default, for parity);
  - the half-row refinement (with its pure-rule parts and pins, retired and annotated, no dead code);
  - the U2b trace instrument (stripped; history keeps it).
  F2 is main's proven landing plus her asked-for line, end zone and settle. That makes it the most defensible ship
  that cannot be verified by the synthetic road.
- **THE EVIDENCE STANDARD for the sidebar drop:** no synthetic road reaches it, as main's own control proves. So
  acceptance is:
  - the pins (the targeted row → the line and the gap; the landing; the end zone; the own place);
  - the source parity with main's per-row road;
  - the walk on everything a synthetic road CAN see: the chip at the cursor, the rows' click / ✕ / right-click / ⇧⌘W
    unchanged, D5/D6 already held, and D8 for U3c.
  **Her hand check is the FIRST item of her morning checklist**: drag an Open row down one, down several, to the end,
  and up. It names the one-commit fallback (main's road exactly) if any drop fails.
- The build is leg **U2d**, a FRESH implementer (U2c's is at its context cliff).

### U2d — the build (F2, as P-U2d-1 rules)

**Implementer:** a fresh Opus 5.5 at xhigh (2026-10-16, morning, under her second overnight mandate), worktree
`~/dev/variorum-vx-283`, DerivedData `App/Variorum/DerivedData/vx283-u2d` (+ one tree per named revert,
`vx283-u2d-r<letter>`). **Not done by this session (first line):** no stage work of any kind — no `xcodebuild test`, no
launch, no walk. The pins' runs, the reverts' runs and the batch are the orchestrator's window (`u2d/window.sh`), and
the hand check that proves delivery is hers (the morning checklist's first item, P-U2d-1).

**LIVE STATUS (per piece)**
- F0 — this section opened; the SDK confirmed (below): DONE (`766f7d61`).
- F1 — the pins, red-first, no product line: DONE (`99565d41`).
- F2 — the fix (F2 on main's per-row API; the instrument stripped): DONE (`63b8c191`); `build-for-testing` → TEST BUILD
  SUCCEEDED on `DerivedData/vx283-u2d`, no warning in a touched file; the headless replica green (below).
- F3 — the trees: DONE.
  - The five reverts were named below (`5be9360c`) before any was applied.
  - Each was then applied to the tip `5be9360c` (whose code is `63b8c191`'s), its patch kept in `u2d/reverts/R-{W,X,Y,Z,Q}.patch`
    (gitignored), and the replica run on it.
  - Each was built with `build-for-testing` → TEST BUILD SUCCEEDED ×5: `DerivedData/vx283-u2d-rw`, `-rx`, `-ry`, `-rz`,
    `-rq` (logs `u2d/logs/bft-r{w,x,y,z,q}.log`).
  - Each was restored by `git checkout -- <file>`, with `git diff` empty after. **No revert is in the tree**, and the
    replica on the restored tree is green again (26 / 0).
  - All six products are present (the app and the `.xctestrun`). The superseded `vx283-u2c`, `-rt`, `-ru`, `-rv`
    trees are deleted. `vx283-u3c` is kept for D8.
  - **The replica per revert agrees with the hand-traced lists to the test** (its scope is the Rule + Door suites and
    the two face source reads, never the mounted pins):
    - R-W: red exactly (a);
    - R-X: red exactly the 18 named Rule + Door tests (the 19th, the mounted line pin, is the window's);
    - R-Y: red exactly the two named Door tests (the third, mounted, is the window's);
    - R-Z: red exactly `theDragSessionsEndClearsTheDrag`;
    - R-Q: red exactly the pure end-zone pin (the mounted one is the window's).
- F4 — `notes/plans/vx283-screens/u2d/window.sh` (gitignored; `zsh -n` clean; its five-file list dry-run read-only against the dev store's folder) + **READY FOR STAGE — U2d window (pins/reverts/batch), then the re-walk**: DONE (this commit). The window below.

**The SDK, confirmed before a line was written** (Xcode 27.0 27A266a, `MacOSX.sdk`, SwiftUI's
`arm64e-apple-macos.swiftinterface`):
- `dropDestination<T>(for payloadType: T.Type = T.self, action: @escaping (_ items: [T], _ location: CGPoint) -> Bool,
  isTargeted: @escaping (Bool) -> Void = { _ in }) -> some View` (`:2709-2713`). It carries `@available(macOS,
  introduced: 13.0, deprecated: 100000.0, …)`, the far-future form that emits no warning at a macOS 26 target, and
  `@_disfavoredOverload`. With a `Bool`-returning two-parameter action plus an `isTargeted:` closure, the call can
  resolve to this overload only. It is main's own road (main's `SidebarView.swift` Open row; `BookView.swift:840-850`
  and the end zone `:873-875`).
- `onDragSessionUpdated(_: (DragSession) -> Void)`, macOS 26 (`:32505-32509`): kept, per the ruling.
- `Animation` is `Equatable` (SwiftUICore's interface `:24678`), so the settle can be pinned by value.

**THE BUILD (`63b8c191`; paths under `App/Variorum/Variorum/`):**
- `Core/Views/SidebarLayout.swift:578-683`, the pure rule (`OpenListDrop`), rewritten for F2:
  - `Hover` is `.row(Int)` (the TARGETED row) or `.end` (`:607-612`);
  - `gap(for:rows:)` (`:626-631`): a targeted row names the slot BEFORE it (its own index — main's landing), and the
    end zone names the slot after the last row; a row off the list, or no rows, names nothing;
  - `destination(gap:dragged:rows:)` (`:638-642`): unchanged (nil at the dragged row's own two gaps, i.e. its own row
    targeted or the row right after it);
  - `lineTop(hover:dragged:rows:rowHeight:window:)` (`:654-664`): the line centred on the targeted row's TOP (the end
    zone's: the last row's bottom), held inside the rows and the window, and gated as before (it now also guards
    `rowHeight > 0` itself, which `gap(at:)` used to guard);
  - `endZoneHeight` (`:674-682`) per P-U2d-2 (below).
  - Removed: `gap(at:rowHeight:rows:)` (the half-row rule), `contentY(row:yInRow:rowHeight:)`,
    `gap(for:offset:rowHeight:rows:)` and `Hover.rows(viewportY:)`.
- `Features/Library/OpenListDrag.swift` (653 → 283 lines):
  - `OpenListDragState` (`:64-146`): `Target` (`:68-81`) is `.row(noteID)` or `.end`. The row is held by its NOTE, so
    a list change re-derives where that row stands (main's landing names the row the same way). `targeted(_:_:)`
    (`:116-123`): a target replaces whatever stood, and an un-target clears only the target IT set (the next row's
    `true` may arrive before this row's `false`). `began` / `read` / `dragSessionUpdated` / `ended` / `lineTop` are
    unchanged in meaning.
  - `OpenListDropDoor` (`:149-209`): `perform(_:onto:state:workspace:animation:)` (`:164-174`). The release is named by
    the drop that took it (its own row or the end zone), never by the hover state, and resolved against the rows as they
    stand. `perform` ends the drag and hands off to `land`, which is unchanged but records the DEBUG oracle `Landing`
    (`lastLanding`, `:198-208`: the move and the animation it rode — the settle's only observable). `proposal` and
    `configuration` are removed: main's API has no proposal, and the system's copy applies.
  - `OpenListRowDrop` (`:216-229`) and `OpenListEndZoneDrop` (`:234-246`): each a classic
    `.dropDestination(for: SidebarView.OpenNoteDragToken.self) { tokens, _ in OpenListDropDoor.perform(tokens, onto: …,
    state: state, workspace: workspace) } isTargeted: { state.targeted(…, $0) }`. They sit beside the door (P-9).
  - `OpenListInsertionLine` (`:251-283`) is unchanged, less its trace lines.
  - Removed: the instrument `OpenListDragTrace` (the whole `#if DEBUG` tail) and the `UniformTypeIdentifiers` import.
- `Features/Library/SidebarView.swift`:
  - `openRow` (`:1042`) keeps `ChipDragSource` with `began(noteID)` at the payload's evaluation (`:1116-1121`) and
    `.onDragSessionUpdated` (`:1124-1126`), and carries `.modifier(OpenListRowDrop(state: openListDrag, noteID: noteID,
    workspace: workspace))` (`:1129`). `.dragConfiguration(DragConfiguration(allowMove: true))` is removed, as is every
    trace hook (the payload's and the preview's notes, the ROW-frame logger, the `.onHover` aim check).
  - `openListEndZone` (`:982`) is always present while the list shows, with `OpenListEndZoneDrop(state:workspace:)`.
  - The column's bottom padding (`:336`) applies only while the list is absent (P-U2d-2).
  - The import drop's trace line is removed (the drop is byte-identical to main's again), and two comments are
    corrected.
- **Not touched:** `SidebarSectionWindow.swift`, `OpenNotes.move` / `WorkspaceModel.move`, the chip
  (`DragChipCanvas.swift`), `ShelfView.swift`, the line's placement, `ShellActions`, `ShellRouter.swift`, the editor
  seam, `Sync/`, custody, schema.

**A consequence of F2, stated (P-U2d-1's own parity, not a provisional).** On main's API the drop accepts by type
alone, and the system's copy applies (the source's default). So the cursor shows the copy badge over every row,
the dragged row's own place included. There:
- no line draws;
- a release moves nothing, so the image slides back.

There is no "forbidden" cursor: that needed the session form's configuration. A half-row placement is also out of
reach. To put a row just below its neighbour, you drop it on the row after that neighbour (or in the end zone when the
neighbour is last). The line always shows that slot first.

**PROVISIONAL (U2d), one — P-U2d-2, the end zone's extent (supersedes P-U2-2).** P-U2-2's zone was the room under the
rows, capped at 28 pt, and it was absent once the rows filled the list. That worked only because the last row's lower
half was then the end slot. F2 has no half row, so a list that scrolls would have no road to the last slot at all. That
is her usual state: the walk's 13 rows overflowed the list in a note view at a 900-pt window.

What is built: the zone is the room under the rows, capped at 28 pt, PLUS the column's bottom padding (12 pt).
- The padding moves into the zone while the list shows. The column drops its own padding then (`SidebarView.swift:336`),
  and the zone's last 12 pt ARE the padding. So the column's layout is byte-identical in every state. VX-285's list
  height and every U1 layout pin are untouched, because the list's frame and the content's total height are the same.
- The zone is never absent while the list shows. At its smallest it is the padding's 12 pt, directly under the list's
  bottom edge, above the footer.
- Its line (the end) draws at the list's bottom edge, held inside the window, as U2 built it.

Options:
- (a) [built] the room under the rows (≤ 28) + the bottom padding.
- (b) P-U2-2 unchanged: the last slot is unreachable while the list scrolls, which is main's behaviour there.
- (c) the book navigator's exact road, a 28-pt tail inside the scroll content. It changes the list's content height, so
  the bottom fade would stand over the last row and the reveal's fixed point would move. That is U1's proven geometry.

(a) is small (12 pt; 13f W11a's lesson called 14 pt "nothing"), but it is the room that exists without taking any of
VX-285's ruled height. Her hand check covers it ("to the end").

**THE PINS (`VariorumTests/OpenListDragTests.swift`, `99565d41` — red-first, no product line).** Thirty tests in four
suites: Rule 11 · Door 13 · Face 3 · Mount 3.
- **(a) `OpenListDragFaceTests.eachRowIsATargetedDropOnMainsRoadAndNoSessionFormRemains`** (a source read). It checks:
  - `openRow` carries `.modifier(OpenListRowDrop(state: openListDrag, noteID: noteID`, `openListDrag.began(noteID)` and
    `.onDragSessionUpdated {` → `openListDrag.dragSessionUpdated(`;
  - the end zone carries `.modifier(OpenListEndZoneDrop(`;
  - BOTH modifiers carry `.dropDestination(for: SidebarView.OpenNoteDragToken.self) {`, `} isTargeted: {`, and
    `OpenListDropDoor.perform(tokens, onto: <.row(noteID) | .end>, state: state, workspace: workspace)` — no
    `animation:` argument, so the door's settle applies;
  - none of `onDropSessionUpdated` / `dropConfiguration` / `DragConfiguration` / `dragConfiguration` / `isEnabled:`
    appears in `openRow`, `openGroup`, `openListEndZone` or anywhere in `OpenListDrag.swift`;
  - no `onDrop(of:` on the list, no `: DropDelegate`, and no `OpenListDragTrace` in either file.

  It is **runtime-red on the pre-fix sources**: the face-only replica run against `99565d41`'s `SidebarView.swift` +
  `OpenListDrag.swift` is RED on it, and `theRowDragsItsChipAndIsItsOwnDrop` is GREEN there.
- **(b), the pure rule:**
  - `theTargetedRowNamesTheSlotBeforeItAndTheEndZoneTheLast` (every row of 1…8; off-list and empty);
  - `everyDropLandsBeforeTheTargetedRow` (exhaustive: 1…6 rows, every dragged row, every target and the end zone,
    including the own place);
  - `everySlotIsReachedByExactlyOneTarget` (the ticket's three in F2's terms, plus an upward drop and the top);
  - `theLineSitsAtTheTargetedRowsTop`;
  - `theLineRidesTheTargetedRowThroughAScroll`.
- **(c), the state and the door:**
  - `aTargetChangeMovesTheLine` (pure);
  - `aTargetChangeMovesTheLineAndAnUntargetClearsOnlyItsOwn` (either order; a row's late un-target leaves the end zone's);
  - `theActionLandsBeforeTheTargetedRowWithTheSettle` (the `Landing` oracle reads the settle, `== .snappy(duration:
    railTransition)`);
  - `theDragSessionsEndClearsTheDrag` (edited in place);
  - `aScrollMovesTheLineWithItsTargetedRow` (the window is copied in only while a target stands);
  - and a guard of the per-row road, `theTargetIsTheRowsNoteSoAListChangeRederivesTheLine` (not red-on-old: the road is
    new).
- **P-U2d-2:** `theEndZoneIsTheRoomUnderTheRowsCappedAndTheBottomPadding` (renamed from
  `theEndZoneIsTheRoomUnderTheRowsCapped`, so the name says what the body asserts — R1-5's class) and the mounted
  `theEndZoneIsAlwaysUnderTheRowsAndNeverPastTheFooter` (renamed from `theEndZoneTakesTheRoomUnderTheRowsAndNothingMore`:
  with room, 28 + 12 pt right under the rows, inside the column; with twenty rows, 12 pt right under the list, down to
  the footer's edge).
- **Edited in place, annotated in the file** (their subject survives, their API went):
  - Rule: `theDraggedRowsOwnGapsOfferNothing` (its last two lines name the own-place targets), `theLineFollowsAChangeOfTheList`,
    `noLineBeforeTheListIsReadOrWithoutADragOfItsOwn`, `theLineStaysInsideTheWindow`.
  - Door: `aDropLandsWhereTheLineWasDrawn`, `theEndZoneLandsTheLastSlot`, `aDropOnItsOwnPlaceOffersNothingAndMovesNothing`,
    `aDropActsOnlyOnTheListItsDragBeganIn`, `movingBetweenTheRowsAndTheEndZoneKeepsTheLine`, `aReleaseReadsThePayloadAndLandsIt`,
    `aReleaseThatOffersNothingRefuses`, `theDragSessionsEndClearsTheDrag`, `aSessionEndBeforeTheDropsActionStillLands`.
  - Mount: `theLineDrawsWhereTheDropWouldLandOnEveryAxis` (targets by note; the line rides its row through the 1.5-row
    scroll; the list-change and own-place steps kept).
- **UNCHANGED:**
  - `theOpenRowsChipIsItsTitleAtTheGrabPoint` (the chip);
  - `theRowDragsItsChipAndIsItsOwnDrop`: its assertions unchanged; its second message's half-row clause and its pointer
    to the retired P-T3-1 corrected, annotated;
  - `aDropSettlesInPlaceAndNeverMovesTheList` (`land` is unchanged);
  - every `SidebarSectionWindow` pin (the fade, the section window) and every close/menu/⇧⌘W pin (no file touched).
  - Not touched at all: the column's file-import drop (now byte-identical to main's).
  - `WorkspaceNavigationTests`' stale comment ("the half of the row under the pointer") is corrected. It is comment
    only; the body is unchanged.
- **RETIRED by P-U2d-1** (their subject no longer exists; deleted, and listed in the file's header):
  - the half-row rule's `theHalfOfTheRowUnderThePointerNamesTheGap`, `theRowJustBelowIsReachable`,
    `aDownwardDropNoLongerLandsOneRowShort`, `theLastSlotIsReachable`, `anUpwardDropLandsWhereItLooks`,
    `everyDropLandsBesideTheRowUnderThePointer`, `theLineSitsOnTheBoundaryTheHoverNames`, `theLineFollowsTheHover`,
    `theLineFollowsAScrollUnderAStillPointer` and `aScrollUnderAStillPointerMovesTheGap` (a still pointer's height
    naming the gap). Their subjects in F2's terms are the new (b) pins and `aScrollMovesTheLineWithItsTargetedRow`.
  - U2c's session-form P-T3-1 `eachRowIsATransferableDropAndItsSourceAllowsTheMove`, P-T3-2
    `aRowsOwnLocationNamesTheGapForEveryRowAndBothHalves` + `aRowsOwnLocationDrawsTheLineAndLandsThere`, and the guard
    `movingBetweenRowsNeverBlanksTheHover` (its subject is now (c)'s un-target pin).

  That is fourteen tests.
- **Their runs:** no suite was added or renamed, so `u2/batch-suites.txt` needs no line. Pins (b) and (c) and the edited
  door pins name the fix's API (`Hover.row`, `Target`, `targeted`, `perform(onto:)`, `Landing`), so the test target
  compiles only on the fix. Their runtime red-on-old is the named reverts below. No headless pin and no synthetic road
  reaches delivery (U2c's main-build control). Her hand proves it.

**Headless evidence:**
- `build-for-testing` → TEST BUILD SUCCEEDED (`DerivedData/vx283-u2d`, `63b8c191`'s code; log `u2d/logs/bft.log`). The
  one warning in a file this leg touched is the older `WorkspaceNavigationTests.swift:699` (`try` without a throw, a
  line this leg did not touch).
- A replica, in the scratchpad only, compiled with `swiftc -swift-version 6 -D DEBUG`. It holds the REAL
  `SidebarLayout.swift`, the real `OpenNotes`, the real `OpenListDragState` + `OpenListDropDoor` cut from
  `OpenListDrag.swift`, stubs for `WorkspaceModel` and the token, and the bodies of all 24 Rule + Door pins plus the two
  face source reads run against the real files. Result: **26 tests, 545 checks, 0 failed**.

**THE REVERTS — named BEFORE any is applied.** Each is applied to the committed tip, built with `build-for-testing` into
its own `DerivedData/vx283-u2d-r<letter>`, then restored by `git checkout -- <file>` with `git diff` empty after. The
patches are kept, gitignored, in `u2d/reverts/`. The expected lists below are traced by hand from each pin's body:
- **R-W (pin (a) — P-U2d-1's dropped move configuration restored).** In `SidebarView.swift`'s `openRow`, re-add
  `.dragConfiguration(DragConfiguration(allowMove: true))` on the line before `.onDragSessionUpdated {` (U2c's shape).
  Products: `vx283-u2d-rw`. Expected on `OpenListDragFaceTests` (3):
  - **RED exactly** `eachRowIsATargetedDropOnMainsRoadAndNoSessionFormRemains`;
  - GREEN `theOpenRowsChipIsItsTitleAtTheGrabPoint` and `theRowDragsItsChipAndIsItsOwnDrop`.
- **R-X (pins (b) and (c)'s landing — the targeted row names the slot AFTER it, the half-row road's lower arm as the
  whole rule).** In `SidebarLayout.swift`'s `OpenListDrop.gap(for:rows:)`, the `.row` arm `(0..<rows).contains(index) ?
  index : nil` becomes `(0..<rows).contains(index) ? index + 1 : nil`. Products: `vx283-u2d-rx`. Expected on
  `OpenListDropRuleTests` + `OpenListDropDoorTests` + `OpenListDragMountTests` (27):
  - **RED exactly 19:**
    - Rule: `theTargetedRowNamesTheSlotBeforeItAndTheEndZoneTheLast`, `everyDropLandsBeforeTheTargetedRow`,
      `everySlotIsReachedByExactlyOneTarget`, `theDraggedRowsOwnGapsOfferNothing`, `theLineSitsAtTheTargetedRowsTop`,
      `aTargetChangeMovesTheLine`, `theLineRidesTheTargetedRowThroughAScroll`, `theLineFollowsAChangeOfTheList`,
      `theLineStaysInsideTheWindow`;
    - Door: `aDropLandsWhereTheLineWasDrawn`, `aDropOnItsOwnPlaceOffersNothingAndMovesNothing`,
      `aScrollMovesTheLineWithItsTargetedRow`, `theTargetIsTheRowsNoteSoAListChangeRederivesTheLine`,
      `movingBetweenTheRowsAndTheEndZoneKeepsTheLine`, `aTargetChangeMovesTheLineAndAnUntargetClearsOnlyItsOwn`,
      `theActionLandsBeforeTheTargetedRowWithTheSettle`, `theDragSessionsEndClearsTheDrag` (its first line reads c's
      top), `aSessionEndBeforeTheDropsActionStillLands`;
    - Mount: `theLineDrawsWhereTheDropWouldLandOnEveryAxis`.
  - **GREEN 8:** `noLineBeforeTheListIsReadOrWithoutADragOfItsOwn`,
    `theEndZoneIsTheRoomUnderTheRowsCappedAndTheBottomPadding`, `theEndZoneLandsTheLastSlot`,
    `aDropActsOnlyOnTheListItsDragBeganIn`, `aReleaseReadsThePayloadAndLandsIt`, `aReleaseThatOffersNothingRefuses`,
    `aDropSettlesInPlaceAndNeverMovesTheList`, `theEndZoneIsAlwaysUnderTheRowsAndNeverPastTheFooter`.
- **R-Y (pin (c) — an un-target clears whatever stands).** In `OpenListDrag.swift`'s `OpenListDragState.targeted(_:_:)`,
  `} else if target == which {` becomes `} else {`. Products: `vx283-u2d-ry`. Expected on `OpenListDropDoorTests` +
  `OpenListDragMountTests` (16):
  - **RED exactly 3:** `aTargetChangeMovesTheLineAndAnUntargetClearsOnlyItsOwn`,
    `movingBetweenTheRowsAndTheEndZoneKeepsTheLine`, `theLineDrawsWhereTheDropWouldLandOnEveryAxis` (row 7's late
    un-target clears row 9's target, so `#require(lineTopInList)` fails);
  - the other 13 GREEN.
- **R-Z (pin (c) — the source session's end no longer clears the drag; U2c's R-V, re-run on F2).** In
  `OpenListDragState.dragSessionUpdated(_:)`, its one `ended()` call is removed (the guard stays). Products:
  `vx283-u2d-rz`. Expected on `OpenListDropDoorTests` (13):
  - **RED exactly** `theDragSessionsEndClearsTheDrag`;
  - the other 12 GREEN, including `aSessionEndBeforeTheDropsActionStillLands` (green on both sides by design).
- **R-Q (P-U2d-2 — U2's end zone exactly).** In `SidebarLayout.swift`'s `endZoneHeight`, the unmeasured arm `return
  bottomPadding` becomes `return 0` and `return bottomPadding + max(…)` becomes `return max(…)`. In `SidebarView.swift`,
  the column's `.padding(.bottom, workspace.openNotes.shown.isEmpty ? SidebarLayout.contentBottomPadding : 0)` becomes
  `.padding(.bottom, SidebarLayout.contentBottomPadding)`. Products: `vx283-u2d-rq`. Expected on
  `OpenListDropRuleTests` + `OpenListDragMountTests` (14):
  - **RED exactly 2:** `theEndZoneIsTheRoomUnderTheRowsCappedAndTheBottomPadding`,
    `theEndZoneIsAlwaysUnderTheRowsAndNeverPastTheFooter` (28 ≠ 40 with room; with twenty rows a 0-pt zone ≠ 12);
  - the other 12 GREEN.

**THE WINDOW — `notes/plans/vx283-screens/u2d/window.sh`** (gitignored; every path absolute, run from anywhere). It is
U2c's shape with no drag steps, because no synthetic road reaches a sidebar drop. Run `pre` → `pins` → `rw` → `rx` → `ry`
→ `rz` → `rq` → `batch` → `restore`, then SEAM, then the re-walk. Each step's EXPECTED result is in the script's header
and here:
- **pre**
  - The strict pgreps (`pgrep -lx Variorum`, `pgrep -lf "MacOS/Variorum$"`) print NOTHING. The step STOPS if either finds
    an instance, so the store is never copied under a live one.
  - "GUARD OK (author: …)" (`guard.sh --author`).
  - "App/ clean at <tip> — no revert in flight".
  - All six products present: `vx283-u2d`, `-rw`, `-rx`, `-ry`, `-rz`, `-rq`, each with its app and `.xctestrun`.
  - "prefs exported" (`u2d/prefs-before.plist`).
  - **"5 files copied"** to `u2d/store-before/<UTC>/`: `variorum.sqlite`, `-wal`, `-shm`, and the two
    `variorum-keys-*.json` (the main-control's five).
- **pins** — on `vx283-u2d`: `OpenListDropRuleTests` (11) · `OpenListDropDoorTests` (13) · `OpenListDragFaceTests` (3) ·
  `OpenListDragMountTests` (3) · `SidebarSectionWindowRuleTests` (16) + `SidebarSectionWindowMountTests` (11) ·
  `OpenListLayoutMountTests` (3; P-U2d-2 claims the column's layout unchanged). EXPECT exit 0 and **"Test run with 60
  tests in 7 suites passed"**, no skips, no ✘.
- **rw / rx / ry / rz / rq** — each on its own tree, exactly the RED and GREEN lists under THE REVERTS above:
  - R-W: 1 red of 3;
  - R-X: 19 red of 27;
  - R-Y: 3 red of 16;
  - R-Z: 1 red of 13;
  - R-Q: 2 red of 14.

  Each step deletes its tree after it runs.
- **batch** — `u2/batch-suites.txt` (144 suites; no line added, since no suite was added or renamed) on `vx283-u2d`.
  EXPECT all green, except `BookCollectingDoorsTests.theSettingsDoorIsOneActOnBothRoads` (VX-115, red on main,
  untouched here) if it is still red there. ≈725 tests: 722 at the last U2 batch, less U2's 27 drag pins, plus U2d's
  30; more if a listed suite grew since (the merge from main, U3c). The skips are the opt-in harnesses only (9 last
  time). Record the "Test run with N tests" line AND the skipped lines.
- **restore**
  - FIRST it waits until `pgrep -lf "MacOS/Variorum$"` is EMPTY (≤ 90 s; the test host is the dev-store app and quits
    after each run). If an instance remains it ABORTS and touches nothing ("ABORT: …"); never kill.
  - It then `cmp`s the five files against the copy, one line each ("identical" / "DIFFERS").
  - It copies the three db files back and `cmp`s them ("restored + verified" ×3).
  - The key files are never written. A key file that differs prints "WARNING … — report it, never copied".
  - The added prefs keys are deleted, `defaults import`, re-export: **"PREFS CLEAN"**.
  - "castle-W1 present: 1".
  - KEEP `DerivedData/vx283-u2d` for the re-walk.
- **The re-walk** (P-U2d-1's evidence standard): everything a synthetic road CAN see.
  - The chip at the cursor.
  - The rows' click / ✕ / right-click / ⇧⌘W unchanged.
  - The file drop on the list still importing (U2's D4, owed), but only if the road reaches it. The column's import
    drop is a sidebar drop too, so it is more likely her hand's. U2d left that drop byte-identical to main's.
  - The end zone's 12 pt under a scrolling list leaving the layout unchanged (a capture of the list's foot above the
    footer against U2's walk).
  - D8 on `vx283-u3c`.
- **Her hand check** stays first in her morning checklist: drag an Open row down one, down several, to the end (the end
  zone, in a list that scrolls too) and up. The one-commit fallback is main's road exactly.

#### U2d — THE WINDOW'S TEST PART (the orchestrator, claim `vx283-u2d` 08:04:32 →; `u2d/logs/`)

`window.sh` pre (GUARD OK; App/ clean at `1e3fad6b`; six products; all FIVE store files copied, `store-before/
20261016T140432Z`) → **pins: 60 tests / 7 suites ALL GREEN** (the 2 skips are U1c's opt-in traces, pre-existing) → the
reverts:
- **R-X: exactly the 19 named RED, the 8 named GREEN** (27 / 3 suites);
- **R-Y: exactly 3 red of 16**;
- **R-Z: exactly 1 red of 13**;
- **R-Q: exactly 2 red of 14**;
- **R-W: GREEN on its prebuilt tree, a METHOD artifact, not a hollow pin.** Pin (a) is a source read (`#filePath`,
  `OpenListDragTests.swift:588`), so it reads the WORKTREE at run time, and the worktree was clean. So R-W was applied to
  the worktree itself (`u2d/reverts/R-W.patch`, one line), `OpenListDragFaceTests` was run on `vx283-u2d`: **exactly 1
  red of 3** (`eachRowIsATargetedDropOnMainsRoadAndNoSessionFormRemains`, `OpenListDragTests.swift:698`), then
  `git checkout -- App`, `git diff` empty (`logs/rw-worktree.log`). Lesson for every later source-read pin: its red-on-old
  runs with the revert IN the worktree, never from a prebuilt tree.
Every revert tree was deleted after its step.

**Batch: 725 tests / 144 suites, the ONE red VX-115's `BookCollectingDoorsTests.theSettingsDoorIsOneActOnBothRoads`**
(red on main, untouched). Restore: pgrep empty first; all five files `cmp`-identical to the copy; nine added keys
deleted; PREFS CLEAN; castle-W1 present. **U2d is PROVEN by its pins and reverts.** The landing itself is unwalkable
(the main-build control); the re-walk covers the source side, the rows, the footer edge and D8.
## Ladder

*(Findings and dispositions land here, repo-first, before any fix session sees them.)*

### Round 1 — the cold review (fable-reviewer at xhigh, 2026-10-15, on tip `448f9450`; `notes/REVIEW_PROMPT.md` verbatim, the whole run's diff `origin/main...HEAD`)

**No BLOCKER, no MAJOR.** Every traced mechanism in the diff checks out against the record, CLAUDE.md and the
canon; the arithmetic of the load-bearing pure functions (`openListMaxHeight`, `revealOffset`, `edgeFades` + the
P-U1e-1 ramp, `readingAsk`, `SectionFollow`, `OpenListDrop.gap/destination/lineTop/endZoneHeight`,
`StatusToastPlacement.bottomInset`, `LibraryControlsFlowRule`) was re-derived by hand in this review and matches
the pins. No "Review foci" section exists for this run (checked), so none were owed. Findings, severity-ranked
(`[severity] · where · what · evidence · fix`):

- **[MINOR] R1-1 · this record, the top LIVE STATUS table (lines ~375–384) · stale at the tip, contradicting the
  record's own sections — a successor hazard, not a code defect.** Evidence: the U1 row still reads "U1d … READY
  FOR STAGE" while the U1d section records the stage window DONE (claim `vx283-u1d` 01:44:58–01:50:37) and the
  re-walk DONE (ruled at "THE ORCHESTRATOR'S EYE AND RULING ON THE RE-WALK"); the Ladder row still reads
  "`opus-reviewer` at max" though the kickoff block records her supersession to `fable-reviewer` at xhigh; the
  orchestrator handoff sends a successor to "LIVE STATUS first". Fix: refresh the table (U1 closed but for
  P-U1e-1's visual re-check riding U2's walk; U2/U3b READY FOR STAGE; Ladder round 1 done). Doc-class — no pin.
- **[MINOR] R1-2 · this record, §U2 E6 + §U3b S5 · the ladder ran AHEAD of U2's and U3b's stage windows — this
  review must not be mistaken for their evidence.** Evidence: every U2 pin (`OpenListDropRuleTests` /
  `DoorTests` / `FaceTests` / `MountTests`), R-K, R-N, and U3b's three mounted cells + R-S have never executed
  under xcodebuild on any tip; the only runs are scratchpad replicas (1165 / 8734 checks), gitignored and gone;
  P-U1e-1's visual acceptance (R4 at 5·7·9·12 pt) is owed to U2's walk. The record is honest (PENDING / READY FOR
  STAGE throughout). Fix: none in code — run the two windows and walks exactly as E6/S5 name them before closing
  the units, and read their results against the named expectations (round 2's first job if one runs).
- **[NIT] R1-3 · `Core/Views/SidebarLayout.swift` `revealOffset` (≈ :453–472) · not a fixed point for viewports
  strictly between one row and ~two rows.** Traced: pitch 30, depth 15, viewport 45, a mid-list row — the
  below-branch lands `offset = bottom + 15 − 45 = top`; at that window `above` is true (`top < offset + 15 −
  0.5`), so the next ask answers `top − 15`, and the one after that `top` again: alternating asks bounce the
  offset 15 pt. UNREACHABLE today (the Open list floors at 3½ rows = 84 pt compact; Starred's window is 7½ rows;
  the fixed-point pin's smallest window is 105 pt), so no red exists on any reachable road — a higher severity
  would be hollow. Fix (optional): widen the `viewport <= rowHeight` arm to `viewport < rowHeight + 2 × depth`,
  or name the bound in a comment beside `everyRowLandsClearOfTheFadesFromAnyWindow`.
- **[NIT] R1-4 · `Features/Library/OpenListDrag.swift` `OpenListDropDoor.perform` (≈ :149–163) + `OpenListDragState`
  · the record's "known edge" (a drag released outside leaves `dragging` stale; a foreign token then draws a line
  and the accepted drop lands nothing) lives ONLY in this record — the code carries no note of it**, and the same
  silent-accept shape covers a failed `loadTransferable`. The disposition (avoiding `onDragSessionUpdated`'s
  unverified ordering) is reasonable; no deterministic pin short of injecting a failing provider. Fix: land the
  known-edge note as a comment at `began(_:)`/`perform` so the next touch sees it.
- **[NIT] R1-5 · `VariorumTests/ShellChromeTests.swift` `theOpenStripWindowIsHerSevenAndAHalf` (≈ :114) · the
  pin's NAME now contradicts its claim** — it asserts the list grows PAST the old 7½-row cap; only the annotation
  explains. Fix: rename at the next touch (e.g. `theOpenListsTallestFormIsTheRoomDownToTheFooter`).
- **[NIT] R1-6 · `Features/Library/LibraryControlsFlow.swift` `LibraryControlsStableWidths.measure` (≈ :289–304)
  vs the field's `.frame(maxWidth: 320)` in `LibraryCatalogView.header` · the floor and the cap are independent
  numbers:** a future prompt/voice whose cell measures > 320 would make `fitsOneLine` false at EVERY width (the
  field can never reach its floor — it answers at most 320), silently pinning the row at two lines forever.
  Current prompts measure 175 / 211.5 — far inside. Fix (optional): clamp the floor at the field's own max, named
  once, or a stable-widths pin asserting `fieldFloor` < the cap.

**CLEAN BILL (checked and found solid):**
- **Scope fence:** zero `Sources/VariorumCore`, `Sync/`, custody, Keychain, schema or editor-seam lines in the
  diff (verified from the diff stat, not the record); shared ledgers (master plan, TICKETS, QUESTIONS, AppSpec)
  untouched per the worktree rule; no forbidden commit trailers; `Part of VX-283` on the commits.
- **VX-285/286 (U1):** `openListMaxHeight`'s two-measurement shape (no feedback loop — nothing above the list
  reads its height), the 3½-row floor, `openListFitRows` deliberately 7; the margin moved INSIDE both scroll
  views with headers carrying their own; the two her-ask pin edits annotated in place; R-A/R-B/R-C ran red
  exactly as named in U1's window.
- **VX-287/289:** `neighbour(ofClosing:skipping:)` pure and correct (next → previous → nil, pass-over, the
  rowless note past-the-end); `closeRow`/`closeAllNotes` view-only (`closingNeverTouchesTheStore` pins store AND
  outbox); the landing rides the EXISTING `pendingSelection`/`adopt` road — no ShellRouter edit, RULE ONE held;
  the departure fires savepoint-on-leave (pinned, `departed == ["b"]`); both registry acts declared once with
  honest gates, doors rendered from the registry, the walk fixtures extended by the justified-edit ritual; ⌘W
  untouched; the ⌘/ helper and row help updated truthfully.
- **The ✕ ruling:** one static act for both doors + a source-read pin that no door closes bare; R-C red as named.
- **F-1/F-2's final shape (U1b→U1d + P-U1e-1):** `revealOffset` exact and idempotent on every reachable window
  (hand-checked: landing clearances, the last/first-row zero-clearance cases, the clamp); `readingAsk`'s
  per-frame viewport arm with P-U1b-7's count guard; `SectionFollow` gating EVERY reveal road (reading, pitch,
  settled check) with per-section state; the fade reshaped — full half-row depth, strength over the measured text
  padding (ramp 7/4 pt — full before the clip reaches ink at 7.25/4.25 pt), cap 0.8, room token only (P-8);
  the eased-shrink pin's smoothstep/pixel-grid model matches the trace; the episode-superseded backstop is sound;
  held-by-reference memory keeps her scroll from re-rendering anything. The five-leg ladder's discipline
  (trace-first, reverts prebuilt and named, the friction doctrine invoked) is exemplary.
- **VX-288 (U2):** the pure drop rule's onMove arithmetic verified by hand ([a,b,c,d] drags: after-b = `move([0],2)`
  → [b,a,c,d]; the end zone = gap 4; own-gap nils); the false-offer rule at the line AND the proposal
  (`.forbidden` slides back); a foreign-list drop refused by the payload's listID with `land` re-validating
  against FRESH rows after the async load; the end zone bounded by VX-285's own measurements (never past the
  footer); the drag state re-renders only the line; P-U2-1's follow interaction reasoned and stated; the chip
  machinery's move to `Core/Views` is a verbatim parity move (forwarding names, `BookcaseDragFaceTests`
  untouched) landing exactly on CLAUDE.md's second-consumer rule, with the one out-of-lane file (`ShelfView`)
  declared to the orchestrator in the record.
- **VX-121:** the placement is a pure rule read by ONE host; bands self-mark via anchor preference (both
  quick-entry surfaces by construction — P-U3-3); never lower than resting; pins compare card and band in one
  `.global` space, and the note cell's first-window harness fact was traced and fixed test-side only. R-T ran red
  as named in U3's closing window.
- **VX-20:** `pinnedFace` is one pure decision — dark = the voice's `surface` + hairline (palette-aware, P-U3-4's
  reasoning sound), light byte-for-byte the material; R-D red ×4 as named; the rig's dark pass sampled the room's
  own paper (#0D0F0D / #1A1712), the #2F2D29 band gone.
- **VX-175 (U3 + U3b):** the one-identity `Layout` (never `ViewThatFits` — the caret survives, walked); the wrap
  decision reads STABLE widths only (the prompt through the field's own cell, the sort slot at its widest form,
  the relevance label one-lined per P-8), memoized per face; the minimum reported is the wider line, never the
  sum; Timeline's exemption stated (P-U3b-2). R-L ran red as named in U3's closing window; U3b's own
  cells await their window (R1-2).
- **VX-245:** all six sites now state `.lineLimit(1)` (labels all); the lint's red→green recorded in U3's window.
  **VX-359:** the trailing `Divider()` deleted with a class sweep; the pin reads the REAL menu with hidden items
  dropped; R-V red as named.
- **P1/P-8 discipline:** every new per-frame computation is bounded by the 20-row cap / the star cap or memoized;
  no corpus-proportional cost anywhere; no word-level tracking; no text copied across entities; no literal colour
  in any new chrome (room/ring/surface/line/star tokens throughout); DEBUG oracles owner-keyed and cleared per
  column (`forgetSections`), nothing oracle-shaped in Release paths.
- **Dispositions already owed elsewhere, correctly not re-flagged here:** the `BookCollectingDoorsTests` red on
  main (VX-115), the shell adoption race (VX-360, filed with the fix shape and the deterministic pin), VX-344
  (parked selection half), and the walkers' O-observations the orchestrator ruled on in-run.

### Ladder round 1 — the implementer's dispositions (Opus 5.5 at xhigh, a fresh session, 2026-10-15)

**Not done by this session (first line):** R1-1 and R1-2 (the orchestrator's); any stage work — no `xcodebuild test`,
no app launch (the pins below compile in both window trees and run in U2's / U3b's windows). Every fix here is a
comment, a rename or a guard: no reachable behaviour changes, so no red-on-old is owed (R1-6 says why in its row).

- **R1-3 — AGREE.** Re-traced by hand: pitch 30, depth 15, viewport 45, row 5 of 10 from offset 0 → 150 (= top); at
  150 `above` holds (150 < 150 + 15 − 0.5) → 135; at 135 `below` holds → 150 again. The band, exactly: a row with a
  row on each side bounces whenever `rowHeight < viewport < rowHeight + 2 × depth − fadeSlack` (two rows less half a
  point, the depth being the half row); **the first and last rows bounce too, under `rowHeight + depth − fadeSlack`**
  (traced at viewport 35: the last row 265 ↔ 255, the first 10 ↔ 0 — so this row's first draft, "two-row lists and
  the end rows are a fixed point at every viewport", was WRONG and was corrected before commit). Unreachable on
  every SETTLED window: only a section whose content runs past its window has a fade, a section scrolls only at
  the Open list's 3½-row floor or Starred's 7½, and a section hugging its rows fades nowhere (every row answers
  nil). **Observation for the orchestrator (not fixed — outside the comment's scope):** a frame stream CAN cross
  the band — a one-row Open list growing to two on an open (the new row appended, current, the content stepping
  first) asks on every frame while following; traced by hand at viewports 35 → 47 in 3-pt frames (the clip view
  assumed to clamp each frame's offset to the content's end) it answers 25, 15, 19, 15, then nil, so
  IF that growth animates the row could wobble a few points for a few frames; the stream ends on its settled
  reading (no fades, nil), so nothing is left standing. Fix: the bound named in a comment at `revealOffset` (+ one
  pointer line at the fixed-point pin) — no behaviour change.
- **R1-4 — AGREE.** Re-traced: `began(_:)` arms `dragging`; only a drop on THIS list's targets clears it (`ended()`
  in `perform`), so a release elsewhere leaves it; a foreign token then reads the stale row as "a drag of this
  list's" (`lineTop`'s `dragged`), the line draws, `perform` accepts, and `land` refuses on the payload's list id —
  accepted, nothing lands, no slide-back. The same silent accept covers a failed `loadTransferable` and a `land`
  that re-validates against fresh rows to nothing. Fix: the known edge as comments at `began(_:)` and `perform`.
- **R1-5 — AGREE.** The pin's name says "seven and a half"; its body asserts the room down to the footer and growth
  PAST the old 7½-row cap. Note: the test lives in `SidebarLayoutTests` (in `ShellChromeTests.swift`), not the
  `ShellChromeTests` suite the record's citations name; the suite-level `-only-testing` lists already carry
  `SidebarLayoutTests` in both windows, so no list change. Fix: renamed to
  `theOpenListsTallestFormIsTheRoomDownToTheFooter` (the reviewer's name); the earlier citations stay as history,
  with a "renamed at R1-5" note.
- **R1-6 — AGREE (as a GUARD).** Re-traced: the floor (`fieldFloor`, the prompt through the field's cell) and the cap
  (`.frame(maxWidth: 320)`) were independent numbers; a floor over the cap makes `fitsOneLine` false at every width.
  No red-on-old is possible on a reachable road: the prompt is one constant and both voices' `small` faces are fixed
  11.5-pt faces (no text-size setting) — measured 211.5 / 175, far inside 320. Fix: the cap named once
  (`LibraryCatalogView.searchFieldMaxWidth`), read by the field's frame AND handed to the stable widths, whose floor
  is clamped at it; pins that each voice's floor is ≤ the cap and that a prompt measuring past the cap is clamped to
  it (that pin is red without the clamp by construction — a guard's own contract, not a reachable bug).

**LIVE STATUS (this leg, per piece)**
- D0 — the dispositions above: DONE (`9fefb8bb`).
- D1 — R1-3's comment (`SidebarLayout.revealOffset`'s doc + a pointer at `everyRowLandsClearOfTheFadesFromAnyWindow`):
  DONE (`b5823d77`; its commit names VX-286 alone where the earlier reveal commits named VX-285 + VX-286).
- D2 — R1-4's comments (`OpenListDragState.began(_:)` and `OpenListDropDoor.perform`): DONE (`4f8b0dff`).
- D3 — R1-5's rename (`SidebarLayoutTests`, `ShellChromeTests.swift`) + the record notes at the two earlier
  citations: DONE (`eda748a4`).
- D4 — R1-6's guard + pins: DONE (this commit). `LibraryCatalogView.searchFieldMaxWidth` (320, the one name) — the
  field's `.frame(maxWidth:)` and `LibraryControlsStableWidths.row(…, fieldMaxWidth:, …)` → `measure(…, fieldMaxWidth:)`,
  `fieldFloor = min(cell width, fieldMaxWidth)` (the memo keyed on it too). The test file's three replicas of the
  field / its cap (`LibraryControlsStableWidthsTests.field`, `LibraryControlsGeometryTests.promptWidth`, the wide-window
  guard's 320) read the name. NEW pins in `LibraryControlsStableWidthsTests` (U3b's window list carries the suite):
  `theFloorIsWithinTheFieldsCap` (×2 voices — floor ≤ cap, the UNCLAMPED prompt already ≤ cap, floor = the whole
  prompt: the clamp does not engage today) and `aPromptPastTheCapIsClampedSoTheRowCanStillBeOneLine` (a 3× prompt:
  unclamped > cap and `fitsOneLine` false at every width 300…3000 — the premise; clamped = cap and one line at 1400).
  `build-for-testing` into `DerivedData/vx283-u3b`: **TEST BUILD SUCCEEDED** (every touched file recompiled; the one
  warning in a touched file is the pre-existing `probeSpace` Sendable line). Runs PENDING U3b's window.
- D5 — headless `build-for-testing` on the tip `8dbae3d6`: `DerivedData/vx283-u3b` **TEST BUILD SUCCEEDED** (log
  `u3b/bft-r1.log`) and `DerivedData/vx283-u2` **TEST BUILD SUCCEEDED** (log `u2/logs/bft-r1.log`) — DONE. **No suite-list
  change:** no suite was added or renamed (R1-5 renames a TEST inside `SidebarLayoutTests`, on both lists; R1-6's pins
  join `LibraryControlsStableWidthsTests`, on U3b's list). **The revert trees were NOT rebuilt** (`vx283-u2-rk`,
  `-rn`, `vx283-u3b-rv` stand on their earlier tips, without this leg's four commits): their named RED/GREEN lists are
  unaffected — R1-3/R1-4 are comments, the renamed test is in none of the reverted runs' suites, and R1-6's two pins
  are absent from `-rv` (on a rebuilt `-rv` they would be GREEN: neither reads R-S's two edits). The pins' runs
  PENDING U2's / U3b's windows; this leg is otherwise CLOSED.

### Round 2 — the cold review (fable-reviewer at xhigh, 2026-10-16, on tip `5147b7e5`; `notes/REVIEW_PROMPT.md` verbatim, the whole run's diff `origin/main...HEAD`)

**No BLOCKER, no MAJOR — and no new BLOCKER/MAJOR, so no round 3 is earned.** Round 2's anchor: round 1's six
findings and their dispositions, re-checked in code; plus everything landed since round 1's tip (the R1 fix leg
D0–D5, U3c's trace + fix, U2b's trace, U2c, U2d, and the window records). The `448f9450..HEAD` churn in
`Sources/VariorumCore` and `VariorumMCP` was verified to be origin/main's own (VX-336), arriving via the merge
`6860bd54` — the run's diff (`origin/main...HEAD`) stays entirely inside `App/Variorum` + `.gitignore` + the two
run-record files. No "Review foci" section exists (re-checked). Findings:

- **[MINOR] R2-1 · this record, the LIVE STATUS table + the stage traffic log · stale at the tip again (R1-1's
  class recurring).** Evidence: the U2 row reads "READY FOR STAGE — U2d window (pins/reverts/batch), then the
  re-walk" while "U2d — THE WINDOW'S TEST PART" records that window RUN AND COMPLETE (pins 60/7 green, the reverts
  exactly as named, batch 725/144, restore clean); the U1 row still leads "PROVEN — awaiting U2's walk for
  P-U1e-1" though its own tail (and the walk record's D5 + the orchestrator's eye) records that acceptance; the
  stage traffic log's last row is `vx283-u2c` 07:04 — the `vx283-u2d` claim (08:04:32 →) has no GO/RELEASE row
  and its section leaves the claim unclosed on paper. The handoff sends a successor to LIVE STATUS first. Fix:
  refresh the two rows and append the u2d traffic entries at the next record touch. Doc-class — no pin.
- **[MINOR] R2-2 · §U2d + §U3c (sequencing — R1-2's successor) · two pieces of owed evidence this review must not
  be mistaken for.** (1) **Her hand check of the drag's delivery**: no real pointer has ever exercised U2d's drop
  on this build — the U2 walk proved synthetic drags do not reach sidebar drops, the pins stop short of AppKit
  delivery by design, and the main-build control proved only the API class's reachability, never that THIS build's
  drop lands. Until her hand lands one, "the drop lands" rests on parity reasoning alone (the record says exactly
  this; the morning checklist's first item). (2) **The U2d re-walk including D8 on `vx283-u3c`** — named as
  VX-175's closing evidence (P-U3c-1's in-use verdict) — has not run. Also riding the closeout: the orchestrator's
  own O-2 ruling ("ticketed at the closeout" — the 620-pt window's current row under the footer's edge) must not
  be dropped there. Fix: none in code — run both before the units close; ticket O-2 at closeout as ruled.
- **[NIT] R2-3 · `LibraryCatalogView.swift` ≈:659-660 / :685-686 · the pickers' frame caps are dead weight with
  zero headroom** — with `.fixedSize(horizontal: true)` (U3c's fix) the `.frame(maxWidth: 280 / 230)` can no
  longer squeeze, only under-report: a voice or metrics change pushing a picker's natural width past its cap
  (Study's mode picker already measures exactly 230 of 230) would overlap its neighbour silently by the excess.
  R1-6's independent-numbers class, one layer up. No reachable red today (the 10-pt spacing absorbs a hair; the
  mounted pin's ≥-intrinsic assertion stays green either way). Fix (optional, next touch): drop the caps, or pin
  each picker's natural ≤ its cap beside the stable-widths pins.
- **[NIT] R2-4 · `LibraryControlsFlow.swift` ≈:134 `arrange` · `single` is computed unconditionally** — the
  full-width distribution (one `sizeThatFits` probe per child) runs on the two-line road too, where it is unused.
  Bounded (5 children, per layout pass); cleanliness only. Fix: compute it lazily inside the one-line branch.

**CLEAN BILL (checked and found solid):**
- **Round 1's dispositions, each verified in code:** D1 — R1-3's bound named at `revealOffset`
  (`SidebarLayout.swift:454-472`, including the implementer's corrected first/last-row band) + the pointer at the
  fixed-point pin; D2 — R1-4's known-edge comments at `began(_:)`/`perform`, and the edge itself NARROWED
  product-side by the session-end clearing (U2c, kept by U2d); D3 — the rename
  `theOpenListsTallestFormIsTheRoomDownToTheFooter` with the old name's note; D4 — R1-6's clamp: the cap named
  once (`searchFieldMaxWidth`, :181), read by the field's frame AND handed into `fieldFloor = min(cell, cap)`,
  both guard pins present and RUN (U3b's 511-test batch, then U3c's 513-green batch).
- **U2d, the final drag shape, hand-verified end to end:** `gap`/`destination`/`lineTop`/`endZoneHeight`
  re-derived (the line at gap × pitch − 1, clamped into the rows and the window; own-place nils; the end zone
  = padding + min(28, room), never absent, unmeasured ⇒ the padding alone); the door (`perform` names the DROP's
  own target, never the hover state; ends the drag either way; `land` re-validates against FRESH rows and refuses
  a foreign listID ⇒ slide-back); the false-offer rule held at the line (a foreign drag — `dragged` nil — and the
  own place draw nothing); the state (an un-target clears only its own; the window copied in only while a target
  stands, so her scroll re-renders nothing; the session's end clears the drag wherever the release fell);
  P-U2d-2's padding hand-off (the column drops its own padding exactly while the list shows — the content height
  byte-identical, and the mount pin ran in the window); P-U2-1 holds by construction (a drop is neither an act
  nor a phase, so no reveal road fires) and by its mounted pin.
- **The U2d pins and reverts:** exhaustive pure coverage through the REAL `OpenNotes.move` (every list 1…6 ×
  every dragged row × every target and the end zone); the door, source-read and mounted pins' arithmetic
  re-derived by hand and correct; the five reverts named BEFORE application with hand-traced red lists, and the
  window's results match them exactly — including R-W's prebuilt-tree green correctly diagnosed as a METHOD
  artifact (a source-read pin reads the worktree) and re-run with the revert in the worktree: 1 red of 3.
- **U3c:** the traced mechanism (a segmented picker answering in two modes in one model state after a landed
  search) closed by `.fixedSize(horizontal:)` ahead of the frames, so P-U3-5's "the wrap reads stable widths
  only" now holds for every changing child; the mounted pin asserts both controls at no less than intrinsic width
  and a stable row height across the probe's exact state road; R-P red ×4 as named; the previously-red sweep pin
  UNCHANGED and now green (the pin was not weakened to pass); the probe suite env-gated and assertion-free.
- **The scope fence, re-verified from the diff itself:** zero core, `Sync/`, custody, Keychain, schema or
  editor-seam lines in the run's diff; shared ledgers untouched; 154 commits, zero forbidden trailers.
- **`SidebarSectionWindow` re-read cold:** the proxy-anchor conversion `a = (rowTop − target) / (viewport −
  rowHeight)` re-derived and exact (clamps correct at both ends and at `viewport ≤ rowHeight`); the follow gate
  covers EVERY reveal road (reading, pitch, settled check) with `act()` on current-change and mount; episode
  supersession sound; a new row appended lands via the discrete request's settle backstop; every probe, seam and
  oracle DEBUG-gated (`sectionReport` / `sectionPhaseSeam` return nil in Release — checked at the source).
- **The close family re-traced:** `closeRow`/`closeAllNotes`/`neighbour` view-only (the store AND outbox pin is
  real — read), landings through the one adopt road, other panes in place with focus kept, pass-over and
  rowless-note semantics exact; the ⌘⇧W table entry and registry gates as declared.
- **VX-121/VX-20 re-sampled:** the toast placement pure (max(resting, host − highest band + 8)), ONE keep-clear
  mark inside `QuickEntryBar` (both surfaces by construction), the host at `RootView`; `pinnedFace` token-only
  (dark = the voice's surface + hairline; light byte-kept). No literal colour in any new chrome; every new
  per-frame computation bounded or memoized (P1); no word-level tracking; no text copied across entities.

### Ladder round 2 — the reviewer's note on the ladder's close

Round 2 raised no BLOCKER and no MAJOR, so the ladder closes at two rounds. R2-1 and R2-2 are the orchestrator's
(record currency; sequencing — the owed hand check, the re-walk with D8, and O-2's closeout ticket). R2-3 and
R2-4 are optional next-touch cleanliness for the implementer; neither needs a pin (R2-3 is a guard of R1-6's
class — a natural-≤-cap pin would be red only by construction) and neither blocks closeout.
