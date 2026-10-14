# VX-283 — Run: Sidebar & Library polish

**STATUS: OPEN — kicked off 2026-10-14 (afternoon), TRIMMED at her kickoff triage to nine members.** Run ticket
**VX-283** (project *v1 release readiness*) · branch `vx-283-sidebar-library-polish` · worktree
`~/dev/variorum-vx-283` on the Pro · PR `VX-283: …` (merge commit only). Shape: `/architect-phase vx-283`, at her
word. Orchestrator: session **vx-283** (Opus 5.5 — the runway's cast rule: *"I decided to orchestrate with Opus to
reduce load on Fable and make sure there was enough for reviews"*).

**Cast — her word at kickoff (2026-10-14, the question tool):** "xhigh builds, max reviews". So:
`opus-implementer` at **xhigh**, ONE fresh session per unit, strictly sequential; the ladder's cold reviews are
**`opus-reviewer` at max**, fresh per round, running `notes/REVIEW_PROMPT.md` verbatim (same-model: the
orchestrator arbitrates against the spec). No editor seam, `Sync/`, custody or default's-meaning content is
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
| U1 | VX-286 · VX-285 · VX-287 · VX-289 — the Open list's layout and closing | READY FOR STAGE — the ⌘⇧W menu check by AX, the Mac batch (215 suites), two behavioural reverts; ≈50 min (the U1 section's P5 plan) |
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
- P0 — the ⇧⌘W collision check (VX-287's FIRST step): IN-PROGRESS — the app-code sweep is DONE and FREE (below);
  the system-provided half (AppKit's own File-menu items under window tabbing) is PENDING an external lookup and the
  stage window's AX enumeration of the Debug app's menus.
- P1 — VX-286 (the scroll bar rides in the margin, Open + Starred): DONE (`2f2daba2`) — headless build green; its
  mounted pin and the behavioural revert are PENDING the stage window.
- P2 — VX-285 (the Open list grows to the sync footer; the constant splits): DONE (`2f2daba2` — the same commit as
  P1; the two share `SidebarView.openGroup`'s lines) — headless build green; pins + revert PENDING the stage window.
- P3 — VX-287 (Close Note ⌘⇧W, landing next / previous / the Library): DONE (`9292d1db`) —
  headless build-for-testing green; its pins PENDING the stage window; the chord's system half PENDING (P0).
- P4 — VX-289 (Close All Notes: the Open list's right-click + the View-menu twin): DONE (same commit as P3 — one
  landing rule, one set of pins) — headless green; pins PENDING the stage window.
- P5 — the stage window: **READY FOR STAGE** — the plan below (≈50 min); nothing of it has run. No revert is in
  flight; the tree is clean at the commit carrying this line.

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
  Library. **Not changed:** the ✕ and the right-click "Close" keep closing the ROW only (the shipped act, its help
  "the note itself is untouched") — whether a ✕ on the shown note's own row should also move the pane on is hers to
  ask for; recorded, not built.

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

**Headless evidence (no stage):** `xcodebuild … -derivedDataPath DerivedData/vx283-u1 build-for-testing` → TEST
BUILD SUCCEEDED on `9292d1db`'s code (no new warning in a touched file).

**P5 — THE STAGE WINDOW PLAN (≈50 min; run in this order; the record flips per step):**
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
   keyEquivalent\(for|RootView\(|CapabilityContext\(` (86 files → 215 top-level suites, incl. the six new ones);
   `pipestatus` checked; the "Test run with N tests" line AND its skipped lines recorded.
3. *The red-on-old reverts (≈10 min) — each named here before it starts, restored by `git checkout --
   App/Variorum/Variorum/Features/Library/SidebarView.swift`, verified by an empty `git diff`:*
   - **R-A (VX-285):** in `openGroup`, `.frame(maxHeight: maxHeight)` → `.frame(maxHeight:
     SidebarLayout.scrollingSectionMaxHeight(rowHeight: rowHeight))` and the `fixedSize` `vertical:` →
     `shown.count <= SidebarLayout.scrollingSectionWindow`. Run `-only-testing:VariorumTests/OpenListLayoutMountTests`.
     Expected: `inATallColumnTheListRunsDownToTheFooterAndStops` and `inAShortColumnTheListTakesItsFloorAndTheColumnScrolls`
     RED; `bothScrollingSectionsKeepTheirBarInTheMargin` green.
   - **R-B (VX-286):** delete both `.padding(.horizontal, Self.scrollingSectionMargin)` lines and put
     `.padding(.horizontal, Self.groupPadding)` back on the two sections' VStacks (where the "(VX-286: …)" comments
     stand). Same suite. Expected: `bothScrollingSectionsKeepTheirBarInTheMargin` RED.
4. *Release (≈2 min).* Dev store copied back with zero dev instances and `cmp`-verified per file; prefs `defaults
   import` → re-export → diff against `prefs-before.plist` (delete any key the window added); `Tools/stage release`;
   the one-line release report ("dev store restored + verified, prefs diff clean, posture Standard/unlocked,
   castle-W1 untouched").

## Ladder

*(Findings and dispositions land here, repo-first, before any fix session sees them.)*
