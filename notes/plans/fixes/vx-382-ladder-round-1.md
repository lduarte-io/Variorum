# VX-382 — ladder round 1 (cold review, opus-reviewer)

**Reviewer:** a fresh `opus-reviewer` session, zero implementation context, running `notes/REVIEW_PROMPT.md`
verbatim over the run's whole diff — `git diff origin/main...HEAD` at tip `ff7c0fea3` (branch
`vx-382-book-view-doors`, origin/main 329937920 folded in). Anchor: `notes/plans/fixes/vx-382-book-view-doors.md`
(the plan has no "Review foci" section). Read in full: the run record, CLAUDE.md + its auto-loaded canon, every
changed source and test file, and the code each change leans on (`CommandRouter`, `CurrentBlockMemory`,
`ShellRouter`, `RootView`'s landing road, `PostDetailView.onAppear`/`jump`, `EditorViewModel.applyProjection`/
`applyFocusSeeds`/`updateCaretContext`/`caretIdentity`, `EditorProjectionPolicy.decide`, `BookIndexEditModel`,
`BookViewModel`'s reveal/landing slots, `AutosaveCoordinator.flushNow`, `AppSession.flushExistingAutosave`,
`WriteTakesPanel`/`TakesViewModel.teardown`, `CommitBar.boxCell`). Run: `swift test --filter
BlockTOCTakesCountTests` — 2/2 passed. No `xcodebuild test` (the stage is coordinator-held).

## Scope check (first, as the brief asks)

The diff touches NO `Sources/VariorumCore/Sync/`, custody or Keychain line, no schema, and no setting's default.
It does NOT touch the named editor seam (`EditorTextView`, `BlockRangeIndex`, `PaneSurface`, the read tier). It
DOES touch two editor-ADJACENT spots: `EditorViewModel.applyProjection`'s `.initialRender` arm (three existing
statements wrapped in `CommandRouter.duringCaretPlacement`) and `updateCaretContext`'s report call (one new
argument), plus `CommandRouter.noteFocusedBlock`'s other-note arm. A Fable line-check of exactly these hunks is on
record (the plan's §FABLE LINE-CHECK). I read them in full and found them sound (clean bill below). One behaviour
MEANING moves: R-U1a-1 changes what an R-18l-1 re-open restores (a place she last had in the book) — recorded
PROVISIONAL for her bundle; not a default's meaning in the CLAUDE.md sense as I read it, but the orchestrator's
call. I did not judge the round out of my mandate.

## Findings (severity-ranked)

No BLOCKER. No MAJOR. Three MINOR, five NIT.

### R1-1 · MINOR · SPECULATIVE (the firing is unmeasured for this host) — D-2's class sweep omits the INDEX as a departing reveal-eater

- **Where:** `App/Variorum/Variorum/Features/BookView/BookIndexView.swift:748` (`.onChange(of: model.pendingReveal)
  { _, _ in landOrSeed() }`) with `landOrSeed` at :795–811; the sweep table in the record
  (§"D-2's CLASS SWEEP"); the fix it mirrors at `BookView.swift:2052`.
- **What's wrong:** the record's sweep of "a departing book surface consumes the reveal a click-over parked for the
  ARRIVING one" lists four departures (Outline — fixed; the spread, Read ▸ Pages, Read ▸ Scroll — recorded) and
  leaves out the Index, the one departing consumer whose eat is UNCONDITIONAL: `landOrSeed` consumes the reveal
  whenever its note is in `model.entries` — always true for a carry inside the book — and unlike the spread and
  Pages, the arriving OUTLINE has no seed to mask a miss (the record's own words: "Arriving at OUTLINE has no seed:
  an eaten reveal would leave the Outline at its own scroll").
- **Evidence (traced, by the measured analogy):** `BookView.switchMode` (:1298–1307) → `carryPlace(from: .index)`
  parks `pendingReveal = indexAnchorPostID ?? standing` → `structure.mode = .outline`. D-2's window trace MEASURED
  that the departing Outline's `.onChange(of: pendingReveal)` fires in the switch's own update with the mode
  already changed; the Index host has the identical shape (an `onChange` on the same slot, attached in the
  departing subtree's own body). If it fires the same way: `landOrSeed` runs, `consumeReveal()` clears the slot and
  scrolls the departing Index; the arriving Outline's `.onAppear { landOutlineReveal }` (now mode-guarded, :2052)
  finds `pendingReveal == nil` and lands nothing. Two shipped roads ride exactly this shape: the mode tabs'
  Index → Outline click-over (W21) and the Index row menu's "Show in Outline" (`BookView.swift:275–281`:
  `focus` + `requestReveal` + `mode = .outline` in one handler — a far-down note would arrive focused but
  off-screen). Neither landing is pinned: no test names `onEditInOutline`, and the one mounted Index → Outline
  round trip (`BookLeavingSavepointTests` ~:448–456) asserts the Index's selection and the Outline's live editor —
  which `model.focus` carries on its own — never the Outline's landing scroll.
- **Pin (red-on-old if the analogy holds):** mount the book in Index (the `BookNoteBoxDoorsTests` host), select a
  note far down a long book (so the Outline's own scroll cannot coincide), switch through the published
  `BookOutlineGeometry.modeDoors[...] (.outline)`; assert the Outline consumed the reveal (slot nil AND the
  note's anchor at the landing's top via `BookOutlineGeometry.anchorTops`). A second arm through the
  `onEditInOutline` closure. If both pins are GREEN on the tip, the analogy is false and this finding is hollow —
  record that and amend the sweep table to say the Index was checked.
- **Proposed fix:** the same guard in `landOrSeed`'s reveal arm (`guard structure.mode == .index` before the
  consume — `BookIndexView` holds `structure`); OR, structurally, close the class instead of guarding consumers one
  at a time: `switchMode` knows `newMode`, so `carryPlace` can stamp the reveal with its ARRIVING mode and every
  consumer takes only a reveal addressed to it (five consumers, one rule — today one is guarded and three are
  "recorded"). Either way, add the Index row to the sweep table. Note for the record too: the D-2 guard newly
  DELIVERS Outline-departure reveals to Read ▸ Scroll (`ReadingFlowView`'s `reveal:`, `BookView.swift:335`) where
  they used to be eaten (the spread and Pages masked it with their focus seeds) — W21's intended carry, but a
  behaviour change on a surface no pin or walk row covered.

### R1-2 · MINOR — R-U1a-1's guard (i) drops her CLICK into an Outline/spread note; the "cannot tell" premise is falsifiable

- **Where:** `EditorViewModel.swift:874–882` (the bracket over `applyFocusSeeds`), `CommandRouter.swift` the
  other-note arm (`caretPlacementDepth == 0`), and the premise in the record (§Guard (i), verified: "a
  click-focus's seed (her place) is dropped with them (the editor cannot tell it from a bare focus's)").
- **What's wrong:** clicking into a read-cheap note in the Outline (or the spread) is the ordinary way into it —
  `ReadPostView`'s `onFocusRequest` → `model.focus(entry.postID, caret: offset)` (`BookView.swift:2734`,
  `SpreadBookView.swift:391`). That click's place reaches the editor as `pendingCaretSeed`, lands inside the
  mount's bracket, and is never remembered. So after "click in at block 3, read, click out", two of the run's
  three roads miss her click: the box's "edit here" (reads `currentBlock(for:)` — the older place or none) and the
  Outline → Index carry's OFFSET (`PaneCaretLanding.entering(currentBlock…)` finds a different block ⇒ block 3's
  START). Only the live "open ↗" is right (it reads the live caret). The Index already treats a click as hers
  (`makeLive(…, placedByHer: true)`), so the two surfaces disagree about the same act.
- **Evidence:** `BookViewModel.focus` (`BookViewModel.swift:1007–1011`) DOES tell them apart — a click passes
  `caret`, a bare focus passes nil and is stored as `caret ?? 0`. The distinction is erased one step later
  (`EditorView.swift:85` hands the editor a bare `Int`). So "the editor cannot tell" is true of the editor only,
  not of the system the bracket serves. The mount pin enshrines the drop:
  `BookOpenDoorMountTests.theLiveNotesDoorCarriesHerBlockAndCaret` (outline/spread arm) calls
  `model.focus(x, caret: range.location + inside)` — the CLICK road — and asserts `currentBlock(for: x) == nil`
  under the label "the mount's own placement (the focus seed) is not remembered".
- **Pin (red on the tip):** the Outline mounted (`BookEditHereRiderTests`' host, mode `.outline` or `.spread`), the
  note's memory first set elsewhere (block 1 at 2, as the rider pin does); `model.focus(x, caret:
  block3.location + 4)` with NO caret move after; `model.focus(nil)`; the box's `editHere()` → expect the editor
  live at block 3, offset 4. Today it lands at block 1 + 2.
- **Proposed fix:** carry the click bit with the seed — e.g. `BookViewModel` keeps `caretSeedIsClick` (caret
  non-nil), `EditorView` passes it beside `pendingCaretSeed`, and `applyFocusSeeds` runs the seed arm's
  `updateCaretContext()` OUTSIDE the bracket when the seed is a click (the fill's END and the bare-focus 0 stay
  bracketed). Re-label the mount pin's outline/spread arm accordingly (a bare `model.focus(x)` for the guard, a
  click for the new pin). This edits two editor-adjacent lines; or rule the cost as accepted and record it in her
  bundle beside R-U1a-1 with the asymmetry named — today the record calls it a cost without saying the Index
  behaves the other way.

### R1-3 · MINOR — the "her typing lands first" flushes return early while a debounced write is in flight

- **Where:** `BookIndexEditModel.releaseForTakesSheet` (`BookIndexEditModel.swift:194–201`) and
  `BookView.openInWrite` (`BookView.swift:1231–1247`), both over `AppSession.flushExistingAutosave`
  (`AppSession.swift:307–311`) → `AutosaveCoordinator.flushNow` (`AutosaveCoordinator.swift:142–150`).
- **What's wrong:** `releaseForTakesSheet`'s doc names the hazard as its reason to await — "a second concurrent
  `flushNow` returns at once while the first's write is still in flight (it takes the batch and clears `pending`
  before it awaits)" — and promises "every pending text … is WRITTEN before this returns". The awaited call has
  the same hole: if the coordinator's own 500-ms debounce (or `goLive`'s migration flush, a detached
  `flushNow`) has already taken the batch, `pending` is empty, `flushNow` returns at once, and
  `flushExistingAutosave` returns `false` (`!isDirty`, which counts `flushesInFlight`) — a result both callers
  discard (`_ =` / bare `await`). The sheet then reads the pre-write store; the door's `jump` measures the block
  against pre-write lengths (its clamp then lands the caret short of where she typed).
- **Evidence:** `flushNow` :145–150 (`let batch = pending; pending = [:]; guard !batch.isEmpty else {
  notifySettled(); return }`), `isDirty` :92 (`!pending.isEmpty || flushesInFlight > 0`). Window: the write's
  duration, a few ms — narrow, and the sheet self-heals on the next delivery unless she types in the panel first
  (then the panel autosaves its stale buffer over the committed text). The same helper semantics sit under
  `CopyForAI`, `NoteDeletion`, `BlockHistoryPane`, `ShellActions` — a pre-existing class this run's comment
  claims to close and does not.
- **Pin:** a session, a note, text recorded on its coordinator; hold the DB writer from a background thread
  (a long `db.write` sleep) and let `flushNow` start (so `flushesInFlight == 1`); call `releaseForTakesSheet(on:)`
  (or `flushExistingAutosave`) and on return read `variant.working_text` — red today (the old text), green once
  the helper waits for settle.
- **Proposed fix:** make the helper wait while `flushesInFlight > 0` (the coordinator already has
  `notifySettled`/`observe(onSettled:)`), so every flush-first door gets the guarantee its comment states; or at
  minimum correct the comment here and ticket the helper (Tests & tooling / Editor area). Not a reason to hold
  the merge.


### R1-4 · NIT — `BookView.onOpenSearchHit` now carries every open door; the name says "search hit"

- `BookView.swift:75–81` (the property), `:127` (the init), `RootView.swift:1283–1295` (the host). Since VX-303 the
  closure is the book's ONE landing road — the five open doors, the box's "open ↗", and the search passages — and
  takes a `BookOpenDoor.Landing` with a mode. A reader of `RootView`'s book composition sees "search hit" wiring the
  open doors. Rename (e.g. `onLand`) — one production host, the pins. Clarity only.

### R1-5 · NIT — `Queries.TOCRow` can now hold a contradictory pair

- `Sources/VariorumCore/Queries/TakesQueries.swift:299–319`. `hasFan` stays a stored `public let` beside the new
  `activeVariantCount`, so a hand-built row may say `hasFan: true, activeVariantCount: 1`; the doc's "the two never
  disagree" holds for the `blockTOC` road only. The Index draws the badge on `hasFan` and the count from
  `activeVariantCount`, so a contradictory row would draw "⑂1". Derive `hasFan` from the count (keep the init's
  nil-count default), or document that the init trusts its caller. Core API, cheap, no behaviour today.

### R1-6 · NIT — `WriteTakesPanel` gains a third feature constructing it directly

- `BookIndexView.swift:726`. Before this run only `Features/Editor/EditorView` built it (the Outline's panel rides
  `EditorView`); now `Features/BookView` builds it too. CLAUDE.md: "A view consumed by two features moves to the
  shared home … at the next touch." `BookView` already constructs `EditorView` and `TakesBoardView` directly, so
  the precedent predates this run — ticket the move (with its siblings) rather than doing it in this ladder.

### R1-7 · NIT · SPECULATIVE (unmeasured) — the box's Index "Takes" cell is a word-sized target in a full-width cell

- `SidebarNoteBox.swift` `takesDoor` (`Button(…).fixedSize().frame(maxWidth: .infinity)…contentShape`) copies
  `CommitBar.boxCell`'s grammar exactly, so the Button's own bounds are the word "Takes" and the rest of the
  bordered cell is, by W-1's own measured lesson in this run (a macOS button counts a press only inside its own
  bounds), likely dead to a click. Inherited: the bar's cells have the same shape and nobody has reported them. A
  click pin at the cell's edge decides it; if real, one ticket fixes both (put the frame inside the label, as
  `rowOpenDoor` already does).

### R1-8 · NIT — record hygiene for the closeout

- `notes/plans/fixes/vx-382-book-view-doors.md`: the U1b RECORD and the U2 RECORD still open with "Not done yet
  (PENDING the … window)" while LIVE STATUS says VERIFIED; the U2 VX-291 "Built" bullet still describes the
  pre-W-1 shape ("negative padding pulls the row's footprint back") and the window plan still says "VX-291 has no
  red-on-old by construction" — 4d8367ec5's overlay shape and its red-on-old pin
  (`aClickInTheOverhangUnfoldsTheNote`) supersede both. Annotate so the record reads as shipped.

## Clean bill — load-bearing things checked and found solid

- **Guard (ii) is structural.** `CommandRouter.noteFocusedBlock`'s other-note arm (`CommandRouter.swift:293–299`)
  returns before `focusedBlockIdentity`/`focusedOffset` are touched; only `currentBlocks.remember` runs, and only
  for an opted-in reporter with a block outside a bracket. Pinned (`BookPlaceMemoryTests`).
- **The bracket is complete for its arm.** `EditorProjectionPolicy.decide` returns `.initialRender` whenever
  `!loaded`, busy or not, so a deferred or window-less first projection (`pendingProjection`) still lands inside
  the bracket; the bare-arrival arm's async `claim()` retry runs only on the DETAIL editor (`scrollView != nil`),
  whose reports take the active arm; the depth unwinds by `defer`. The book's re-renders while mounted restore her
  caret by identity and report it unbracketed — her place, by design.
- **The Index placement filter** (`caretReportIsHers`): traced the END report, a landing's place (`.start`/
  `.end`/`.offset`/`.select`, clamped as the pane clamps), a click's own place, an empty take (END == start),
  `.leave`, `.unchanged` (clears), and her edit (clears). Sound; the red-on-old probes bite.
- **One landing road, no second authority.** The five doors and the box door call `BookView.openInWrite` →
  `RootView.open` → `ShellRouter.adopt`, the search passages' road. Offset and mode ride the ONE park
  (`ShellRouter.park`): parked only by a navigation, expired by the next, spent at the mount, one generation bump
  per park, `ModeLanding` only for `.post`. Other `.variorumOpenPost` callers (Arrivals, the chip, Compare, the
  duplicate receipt) are separately-ruled doors and untouched.
- **The landing offset is measured in one text on both ends.** The Outline/spread editor's `caretIdentity` (its
  index entries), the Index pane (`row.variantID`, the chosen take), and `jump`'s `renderPost` all read the chosen
  take's `working_text`; `BlockRangeIndex.range(ofEntryAt:)` excludes the separator, so
  `PostDetailView.landingOffset`'s clamp never crosses into the next block.
- **R-U1a-2 and R-18l-1 coexist.** `initialMode` forces Write and writes the mode memory a switch would; the
  nothing-live door keeps the plain open's PLACE because `registerDetail`'s first-open/re-open rule
  (`notesOpenedThisRun`, `sessionFact`) is untouched. Pinned end to end (`BookOpenDoorShellTests`, both arms).
- **D-2's guard is safe for the Outline's own landings.** Every road that lands the Outline arrives with the mode
  already Outline (the tabs; `takeChapterRequest` → `switchMode` sets it synchronously before
  `requestChapterReveal`; `onEditInOutline` sets it in the same handler); `.onAppear` re-runs the landing on mount.
- **P1.** Per keystroke the new work is O(1) (`noteIndexCaret`, a dict write in `remember`, `UserDefaults` only on
  a block/take change); `caretIdentity` (O(one note's blocks)) runs only at a press or a mode switch; the badge
  is one overlay per REALIZED row; nothing scales with the corpus.
- **The Index takes.** `releaseForTakesSheet` releases the live pane synchronously before any await (P-U1b-4's
  buffer-authority hazard closed; the release probe bites); the request slot is taken once and refuses a block-less
  target; "Open Takes mode" refuses inside a book (pinned). `TOCRow.activeVariantCount` rides the same `renderPost`
  slot as `hasFan` and matches the Outline badge's own count (`EditorViewModel.swift:3883`); archived takes are not
  counted — `swift test --filter BlockTOCTakesCountTests` 2/2 passed in this session.
- **VX-291.** The button's own frame IS the 22-pt square (an overlay of a hidden 12×13 footprint), so W-1's class
  is closed by construction, and the overhang (5 pt) is under every host's spacing (6, 8). The ▸ and ▾ now claim
  the same footprint, so the title's offset from the control is equal in both states (it was ~11 vs ~17).
- **VX-21.** The gate reads the stored `sort_field` — the same fact the panel's drop refusal reads — and honours
  R-U2-A2's letter; the siblings are unchanged by ruling.
- **VX-69.** The catcher mounts only while the popover is open, removes its monitor when its view leaves the
  window, consumes only Esc events of ITS window (the ⌘K palette is a `.sheet` window, untouched), and passes
  ⌘/⌥/⌃ chords.
- **VX-77 / R-U2-B.** The three luminance scans now pin `.aqua`; the target's other pixel-reading pins already pin
  their appearance or compare relatively (`SearchPickerPanelGeometryTests`, `LibraryListFaceTests`,
  `CalmButtonDisabledFaceTests`, `CommentTextAreaTests`) — the sweep is complete. Dismissal-as-hollow is the
  hallucination guard applied correctly.
- **VX-115.** `BookView.surfaceCapabilities` is three doors (verified); `contains` was ruled; the registry walk owns
  set equality.
- **Spec and rules.** §12's badge only on fanned blocks; decorations never move prose (an overlay); tokens only; no
  shouty caps; P-8's line policy on every new `fixedSize` label; no registry capability added (VX-383's overlap
  respected); no VX-381 file touched (`ShelfViewModel` untouched); no `Sync/`, custody, schema or seam-trio line.
  The run's PROVISIONALs (R-U1a-1, R-U1a-2, P-U1b-1…5, P-U2-1…5) are recorded for her bundle; no canon delta is
  owed before the closeout.

## DISPOSITIONS (the orchestrator, same-model arbitration against the spec — 2026-10-18)

- **R1-1 — CONFIRMED AS SPECULATIVE, pin decides.** The sweep's "SAFE today" verdict missed the Index's own
  departure consumer; the reviewer's mounted Index → Outline pin is built FIRST. Red ⇒ apply D-2's mirror (the mode
  guard on `landOrSeed` — the reviewed shape; a mode-stamped reveal is the deeper cut and goes to VX-300's note if
  not taken). Green ⇒ hollow — record in the sweep table, no fix. Either way the sweep table gains the Index row
  and the Read ▸ Scroll delivery note (intended W21 behavior, now stated with its no-pin status).
- **R1-2 — CONFIRMED, fix.** The "the editor cannot tell" premise was wrong (`BookViewModel.focus` distinguishes a
  click; the bit dies at `EditorView` ~:85). Her click IS her place — the run's own theme. Fix: carry the click bit
  with the seed so a CLICK-arrival feeds the memory inside the bracket; a bare focus stays dropped. The reviewer's
  red-on-tip pin lands with it. The mount pin's "mount noise" arm is re-worded to bare-focus-only.
- **R1-3 — CONFIRMED AS A PRE-EXISTING CLASS, ticketed; the comment fixed in-run.** `flushNow`'s
  nothing-pending-while-a-write-flies early return is the shared helper's own class, not this run's regression; the
  run's sin is a doc comment claiming the hazard closed. In-run: correct the comment to name the open window.
  Closeout mints the helper ticket (Bug · Suspected · Editor; the reviewer's pin sketch rides the ticket body).
- **R1-4 — RECORD-ONLY.** The `onOpenSearchHit` name predates the run's widening; a rename tonight is churn
  against two sibling merges for zero behavior. Noted for VX-300's body.
- **R1-5 — RECORD-ONLY.** `TOCRow`'s init shape is the query layer's standing idiom; the new count rides it.
  Noted for VX-300's body.
- **R1-6 — RECORD + TICKET.** Constructing `WriteTakesPanel(session:postID:blockID:)` from the book is RENDERING a
  sibling's view — legal under CLAUDE.md's own words ("the prohibition binds STATE AND OWNERSHIP, never
  rendering"). The shared-home rule bites at the panel FILE's next touch, which this run did not make. Closeout
  mints the move ticket (Low · Debt).
- **R1-7 — CONFIRMED AS SPECULATIVE, probe decides.** The W-1 class's idiom checks the cell's click frame; if only
  the word answers, the W-1 overlay fix applies to the cell. The walk's W11 clicked the word, so the live road
  works either way — this is about the cell's dead zone.
- **R1-8 — FIX.** Record hygiene: the stale PENDING headers flip and the VX-291 notes catch up to the W-1 shape.

One fix leg (a fresh implementer) applies R1-1's pin-then-decide, R1-2, R1-3's comment, R1-7's probe-then-decide
and R1-8; its new pins verify in one short stage window; the orchestrator's line-by-line check closes the ladder
at round 1 (0B/0M — the standing precedent) unless a fix uncovers more.

## FIX LEG RECORD (opus-implementer, fresh, 2026-10-18 — the dispositions above are its warrant, nothing more)

**Not done yet:** every in-window run (the R1-1 decider, the R1-2 red-on-old, the R1-7 probe and the guard batch) —
the stage is coordinator-held; this leg builds headless and reports READY. **No revert is in flight.**

| Item | State |
|---|---|
| R1-1 — the Index → Outline decider pin | PIN BUILT (see the commit naming it; `build-for-testing` green) — `BookNoteBoxDoorsTests.swift` › `BookIndexToOutlineCarryTests.theOutlineArrivesOnTheCarriedNote` (args: `modeTabs` through the published mode door, `showInOutline` replaying the row menu closure's three statements); a 40-note book, note 25 landed in the Index, then the road → the Outline must put `page-<note 25>` at its top (`BookOutlineGeometry.anchorTops`, ≤ 4 pt). **The verdict is PENDING the window.** If RED: the fix is ONE line atop `BookIndexView.landOrSeed` — `guard structure.mode == .index else { return }` (D-2's mirror) — and its red-on-old is deleting that line. If GREEN: hollow, no code change. The sweep table (plan file §D-2's CLASS SWEEP) gained the Index row (PENDING the verdict) and the Read ▸ Scroll delivery note |
| R1-2 — her click into an Outline/spread note is her place | **FIX BUILT** (the commit naming it; `build-for-testing` green; runs PENDING the window). Mechanism (traced): `BookViewModel.focus(_:caret:)` knows a click (caret passed) from a bare focus (nil ⇒ 0), but `EditorView` handed the editor a bare `Int`, and `applyFocusSeeds` ran inside `applyProjection`'s placement bracket, so `noteFocusedBlock`'s other-note arm dropped the click's report with the mount's own. Fix: `BookViewModel.caretSeedIsHers` (set by `focus`, cleared with the seed) → `EditorView(caretSeedIsHers:)` → `EditorViewModel.pendingCaretSeedIsHers`; `applyFocusSeeds` answers whether the seed it placed was hers, and the initialRender arm calls `updateCaretContext()` once more AFTER the bracket when it was — the fill's END and a bare focus's 0 stay bracketed; detail/pool editors pass the default `false` (no change). Red-on-old = in place, `if seedWasHers { updateCaretContext() }` → `if false, seedWasHers { updateCaretContext() }` (EditorViewModel, the initialRender arm) — both new pins must go red (memory block 1 + 2 / the Index at the block's start); the mount pin's bare-focus arm stays green either way. PINS (pin-first commit 87fc8fa82): `BookEditHereRiderTests.aClickIntoTheNoteIsHerPlaceForEditHere` (the reviewer's pin — the spread, the note's own editor left her at block 1 + 2, her CLICK at block 3 + 4 with no move after, click out, "edit here" ⇒ block 3 + 4; red on the tip: block 1 + 2) and `BookCarryLiveBlockTests.aClickIntoOutlineThenIndexLandsAtTheClick` (the carry's half — a click at block 2 + 9 in Outline, the mode tabs to Index ⇒ block 2 live at 9; red on the tip: its start). The mount pin's outline/spread arm (`BookOpenDoorMountTests.theLiveNotesDoorCarriesHerBlockAndCaret`) re-worded: guard (i) is now asserted on a BARE focus, her place made by her own caret move |
| R1-3 — the flush comments name the open window | **DONE** (comment-only; the commit naming it) — `BookIndexEditModel.releaseForTakesSheet`'s doc no longer promises every pending text WRITTEN: it names the window (`flushNow` takes its batch and clears `pending` before awaiting, so a write already in flight — the 500-ms debounce, a detached flush — leaves the awaited flush nothing to do while that write lands; the helper's `false` is not consulted), and `BookView.openInWrite`'s "her typing lands first" paragraph names the same window (the clamp lands the caret short). No helper semantics changed; the helper class is ticketed at closeout (Bug · Suspected · Editor, the reviewer's pin sketch in its body) |
| R1-7 — the box's Index "Takes" cell's click frame | **PROBE BUILT** (the commit naming it; `build-for-testing` green; **verdict PENDING the window**) — `BookNoteBoxDoorsTests.swift` › `SidebarNoteBoxTakesCellClickTests.aPressAnywhereInTheCellOpensTheTakes` (both voices): the Index-live box alone in W-1's click rig (`SharedIconRig` — a real down/up), the cell's rect read off the box's own published frame (no new oracle); a CONTROL press on the word must open the takes (proves the coordinates), then a press 4 pt inside the cell's LEFT border. GREEN ⇒ the whole cell answers — record, no change. RED (control green, edge red) ⇒ only the word answers: apply the PREPARED FIX below in the window, the probe goes green, its red-on-old is restoring today's `takesDoor` body |

**R1-7's PREPARED FIX (applied ONLY if the probe's edge press is red; `SidebarNoteBox.takesDoor`, W-1's overlay
idiom applied to the cell).** Today's body is `Button(word).buttonStyle(VoicedButtonStyle(.quiet)).lineLimit(1)
.fixedSize().frame(maxWidth: .infinity).frame(height: 24).background(surface).overlay(stroke).contentShape(...)` — the
Button's own frame is the word's. The fix lays the CELL out bare and rides the Button in an overlay whose LABEL fills
the cell, so the button's own frame is the cell:

```swift
let door = Color.clear
    .frame(maxWidth: .infinity)
    .frame(height: Self.takesCellHeight)
    .background(tokens.surface, in: RoundedRectangle(cornerRadius: 6))
    .overlay {
        Button(action: act) {
            Text(tokens.chromeLabel(NoteBoxCopy.takesDoor))
                .lineLimit(1)
                .fixedSize()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
        .help(NoteBoxCopy.takesDoorHelp)
    }
    .overlay(
        RoundedRectangle(cornerRadius: 6).stroke(tokens.line, lineWidth: 1).allowsHitTesting(false))
```

The word, its font, its muted ink and its place are unchanged; the voiced hover wash then covers the whole cell (the
target — W-1's own grammar, the fold control's wash fills its 22-pt square); recorded for her eye if built.
`CommitBar.boxCell` (the bar's cells) shares the inherited shape — NOT touched here (the disposition names the box's
cell only); a ticket at closeout if the probe is red.
| R1-8 — record hygiene in the plan file | **DONE** (the commit naming it) — the U1b and U2 RECORD headers flipped from "Not done yet (PENDING …)" to VERIFIED (the old text kept, named as the pre-window state); the stale "runs PENDING the window" sub-headers flipped (U1a's pins ×2, U1b's pins, D-2's header, VX-77/VX-291/VX-21/VX-69/VX-115); VX-291's "Built" bullet gains the AS-SHIPPED W-1 overlay shape (hidden footprint + the button in an overlay, its own frame the 22-pt square), its Evidence bullet and the window plan's "no red-on-old by construction" line both name W-1's red-on-old click pin `aClickInTheOverhangUnfoldsTheNote` |
