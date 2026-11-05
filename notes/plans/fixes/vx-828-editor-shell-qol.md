# VX-828 — Run: editor & shell QoL

**STATUS: OPEN — kicked off 2026-11-05 (/architect-phase vx-828, the architect shape).**
Branch `vx-828-editor-shell-qol` from main 8ffdd8278 · worktree `~/dev/variorum-vx-828` · the Pro ·
coordinator `nov4coordinator` (stage protocol below). PR: VX-828, merge commit, at closeout.

## FOR A LATER READER

*(Written at closeout. Until then: the LIVE STATUS ledger below is the run's state; a resuming
session reads this file whole — the run is open.)*

---

## The run

Eleven members under the VX-828 umbrella (the sub-issue listing is the roster — pulled at kickoff,
2026-11-05): VX-798 · VX-800 · VX-806 · VX-823 (High) · VX-824 · VX-833 · VX-838 · VX-844, plus
riders seated at the kickoff sitting: VX-840 · VX-636 · VX-655. VX-841 was offered and declined
(stays Todo for a later wings run). No `Sync/`, no custody, no keychain, no MCP wire, no lockstep
anywhere in scope — **if any batch finds itself reaching one of those, it STOPS and reports.**

**Cast (her confirmation at kickoff — the standing default):** Fable orchestrates and cold-reviews
(`fable-reviewer` — mandatory anyway: VX-806/VX-655 are editor-seam class); `opus-implementer` at
xhigh builds every batch, one at a time, a fresh one per batch. One ladder over the run's whole
diff. Pin-before-fix binds PER MEMBER.

**Wave-1 peers (live now):** VX-805 (journal cluster — holds the Sync slot) and VX-809 (MCP door
ergonomics). Declared overlap seams: the capability REGISTRY (three-way — whoever merges second
re-runs `CapabilityRegistryTests` + `ShellChromeTests` after merging main in); Settings ▸ Tags and
the sidebar (vx-809); **the shared unused-tags query** (VX-840 here, VX-825 in vx-809 —
coordinator-settled 2026-11-05: **vx-809 OWNS the mint**; it sends this run the query's name, home
file and signature once its batch 1 settles, and batch E builds against that, never a twin).

## SITTING RECORD — kickoff, 2026-11-05

Decisions were put as question batches; she picked among presented options. Recorded faithfully:

- **R-828-1 (VX-800 — the ticket's reserved judgment call, "lineage edges"):** her pick — **"Any
  live edge to a live block"** counts as history and keeps an empty block out of the sweep. The
  floor stands as the ticket wrote it: no savepoints, no comments, no non-empty take, no name, no
  callout frame. Junk blocks (empty Return-chained leftovers) have no edges, so the sweep still
  catches them.
- **R-828-2 (VX-838 — the pane's shape, hers to pick):** her pick — **the pane NAMES its wing in
  its header ("Tags — in ‹wing›") and FOLLOWS the app's wing live** (the "one wing follows the
  focused note" family). A selector for managing another wing's tags is a possible later addition,
  not this run's.
- **R-828-3 (riders):** she first took all four offered and asked, verbatim: *"how many tickets
  already in this run? if it's very full, i want your recommendtations on what to include"* — the
  answer (8 members, 5 batches, +4 riders = 12) came with the recommendation to take the three
  fixes riding already-open surfaces and skip the one new face; her pick — **VX-840 + VX-636 +
  VX-655 join; VX-841 skipped** (eleven tickets, still five batches).
- **R-828-4 (VX-840's home — a conflict surfaced to her explicitly):** VX-840's ticket carries her
  Nov 4 word that it "JOINS VX-809's run as VX-825's app-side twin". With that conflict named, her
  pick — **"Keep it in VX-828"** (the Settings ▸ Tags pane is already open here via VX-838). VX-825
  keeps the reach-scoped wire answer in vx-809; the shared unused-tags query coordinates at the
  merge seam. vx-809 was told to drop VX-840 from its batch 5; the ticket carries the comment.
- **Cast:** standing default confirmed (question 4; no redirect).

## THE LEDGER

| # | Ticket | What | Batch | Status |
|---|---|---|---|---|
| 1 | VX-806 (M) | Return mid-word snaps instead of refusing (editor seam) | A | VERIFIED 2026-11-05 (suites 281/28 green, red-on-old by revert, walk all legs both voices; pin hygiene 99fd1dd58) — PENDING: clean red re-show of revert 1 (next window) + phone suites at the merge gate |
| 2 | VX-655 (L, rider) | list-exit Return: retraction lands inside the flight | A | VERIFIED 2026-11-05 (order pin red-on-old by revert 3, checklist walk clean, stale neighbor pin re-pointed 58e655834) |
| 3 | VX-824 (M) | ⌘digit contextual — wings from the keyboard (RULED: shape a) | B | NOT-STARTED |
| 4 | VX-833 (M) | wing switch navigates to the wing's BOOKCASE; switcher right-aligned | B | NOT-STARTED |
| 5 | VX-844 (L) | wing indicator marquee (car-radio), never crossing the column line | B | NOT-STARTED |
| 6 | VX-823 (HIGH) | the Library remembers scroll + selection on return from a note | C | NOT-STARTED |
| 7 | VX-800 (M) | Trash sweep door: delete forever every empty no-history block | D | IN-PROGRESS — design fork PROPOSED (Batch D, D0); the build waits on the orchestrator's ruling |
| 8 | VX-636 (L, rider) | the "gone from the app" receipt draws over the bottom Trash row | D | NOT-STARTED (its intended shape is stated in D0 for redirect) |
| 9 | VX-798 (M) | spellcheck: ⌘; / ⌘: chords + Edit ▸ Spelling and Grammar home | E | NOT-STARTED |
| 10 | VX-838 (M, Bug) | Settings ▸ Tags names + follows the wing (RULED: R-828-2) | E | NOT-STARTED |
| 11 | VX-840 (L, rider) | Settings ▸ Tags: delete-every-unused-tag door | E | NOT-STARTED |

Batch order: **A → D → C → B → E** (domain/ops-heavy first, chrome after; order may flex at the
orchestrator's call, recorded here when it does).

## BINDING PRINCIPLES — the 13b constitution (copied verbatim per the architect skill; the
application notes in `.claude/skills/architect-phase/SKILL.md` bind the same way)

- **P-1 — One capability registry.** Every user-facing act is declared exactly once: verb, scope
  (block/take/post/book), per-mode availability rule, its doors (menu / context / bar / shortcut /
  palette), and its refusal copy. Surfaces render their doors FROM the registry; gating is data,
  never per-view if-statements. A registry-walk test asserts every declared door exists and every
  rendered door is declared. This kills the D3/D4 class structurally — the capability matrix stays
  green by construction instead of by audit.
- **P-2 — Fire-and-DO (R115).** A rendered door either performs the act — including any mode-switch
  choreography, done visibly for the user — or delivers the operations layer's real refusal. A door
  that can never act in its context isn't rendered. Lecture-and-redirect is retired.
- **P-3 — One text surface, one liveness authority.** ONE TK2 surface component (live + read modes;
  one measurement brain — the width-gated remeasure; the shared canary) that every pane composes;
  the live editor core's identity machinery (`BlockRangeIndex`, crystallization) becomes its live
  mode, not a sibling implementation. "What text does this pane show, and is it live" is answered
  by ONE pure, unit-tested authority (`PaneTextAuthority`); views never re-derive it. Its
  invariants stated as code: exactly one live pane; the live pane is buffer-authoritative; read
  panes are projection-authoritative once caught up.
- **P-4 — Broadcasts carry signals, never decisions.** NotificationCenter may announce that
  something happened (mode changed, post opened); no listener derives business state or
  availability from a broadcast, and no flow's correctness depends on broadcast ordering.
  Cross-feature flows route through composition. (Stage 0's survey enumerates today's notification
  bus; Stage 1 disciplines it.)
- **P-5 — The friction doctrine (R116).** Repeated pushback against a rule marks an
  under-architected feature. The response is never another patch: write the feature's DESIGN MEMO —
  intended behavior whole, edge cases enumerated on paper, refusal wordings, undo story — get the
  author's rulings on the product-flavored edges, then build to the memo. Happy path ships first,
  but the edges are *decided at design time*, not discovered by the author. First two memos owed:
  **merge** and **the W ceremony**.
- **P-6 — The tutorial is the executable spec (R113).** The guided tutorial flow is the contract
  for every happy path. It stays green — automated where the harness allows, screenshot-walked
  otherwise — and any change that breaks a tutorial step is a regression by definition.
- **P-7 — Find bugs before she does.** Every layer keeps a proactive harness: the ops-layer soaks
  (exist), the board/view-model invariant soak (Stage 1), the registry walk (P-1), the per-batch
  scripted screenshot walkthrough. Red-on-old stays absolute: no bug-class fix without a pin that
  fails on the pre-fix code.
- **P-8 — Standing law, consolidated.** P1–P3 performance invariants bind the rebuilt layer exactly
  as they bind the substrate (invalidation ∝ realized rows; one live editor; virtualized long
  views). Overlays, never rendering attributes. Chrome `fixedSize` texts always carry a `lineLimit`
  (the b6dae25 class). `Theme/VoiceControls.swift` is THE chrome vocabulary. Complexity lives in
  the store; restraint lives in the UI.
- **P-9 — No god objects in the frontend either.** A view model mixing board layout, text
  authority, and gesture routing splits by concern (`TakesViewModel` at 890 lines is the standing
  counterexample). Same hygiene rule as the substrate, applied where it was being waived.

## BATCH BRIEFS (each self-contained; the implementer reads ONLY its batch section + the sections
named in it + ENVIRONMENT TRAPS + CHECKPOINT RULES below)

### Batch A — the editor seam: VX-806 + VX-655

**Required reading before any edit:** `notes/TEXTKIT2_NOTES.md` (whole), AppSpec §7's
"Segmentation / the Return key" note and §9's split taxonomy, QUESTIONS #92 (all three edges),
`App/Variorum/Shared/EditorBrain/TypedReturn.swift`,
`Sources/VariorumCore/Domain/BoundarySnapping.swift`, and for VX-655 the "VX-649 TRACE" section of
`notes/plans/fixes/vx-648-launch-week.md`. This batch is EDITOR-SEAM CLASS: the cold review is
Fable's; the orchestrator never touches these files.

**VX-806 (Improvement, Confirmed).** Her report (2026-11-04, screenshot): with the segmentation
chip on, Return mid-word toasts "No legal cut spot for that here…". Her words: *"normally when you
try to make a newline in the middle of a word, it just moves the whole word down, but with this it
just denies it. standardize it?"* The contract to build (the ticket's fix shape — it supersedes
QUESTIONS #92(b)'s built behavior, which was "the divide door's own refusal, spoken"):
- A caret INSIDE a word: the structural Return's cut snaps to the word's edge through
  `BoundarySnapping` (S4-22's one cut brain) **such that the whole word rides down into the new
  block** — i.e. the cut lands at the word's start. If `BoundarySnapping`'s settle semantics would
  pick the word's END for a late-in-word caret, this door still carries the word down (her sentence
  governs the Return door); say so in the record if the two diverge, with the mechanism.
- Where the snap settles on the block's very START (her screenshot's case: caret one character into
  the first word, after an opening quote): fall through to the block-start arm — an empty block
  ABOVE — instead of refusing.
- Where it settles on the block's very END: the end arm — an empty block BELOW.
- `invalidCut`/`nothingToDo` must no longer be reachable from a mid-word caret with the chip on.
  QUESTIONS #92(b)'s one-word-block case (no legal interior cut) now lands an arm, not a refusal.
- Untouched: ⇧⏎ (in-block newline), the chip OFF (Return-as-content), crystallization/the open
  tail (#92(c)), selections (#92(a) — not this gesture), the list door (the intercept order at
  `EditorTextView.insertNewline(_:)` stays: list door first).
Pins: red-on-old state-transition tests on the Return planner (mid-word → divide at word start;
first-word caret → start arm; one-word block → arm not refusal), verified by behavioral revert.

**VX-655 (Improvement, Confirmed — the rider; same seam, same review).** Traced at VX-648 batch 1
(commit 0d68f95f6): on the list-exit ⏎, `retractListContinuationNewline` (R1-3, QUESTIONS #94)
deletes the continuation's newline SYNCHRONOUSLY, and the empty block that replaces it lands only
when `runStructural` returns — a frame-scale blank (~20 ms). Fix the ORDER: the retraction lands
INSIDE the structural flight (surgery on `EditorViewModel.swift` / `EditorSurfaceController.swift`
beside #94's undo shape). The undo story must stay whole (#94's shape — verify by reading its
registration). Pin: an order assertion red on old (if the order is genuinely unpinnable headless,
STOP and report to the orchestrator before building — do not land an unpinned fix).

**Acceptance evidence:** the state-transition pins + core `swift test` green headless; the
orchestrator's hands-on walk (chip on: mid-word Return in several positions, a one-word block, the
opening-quote case, a checklist exit) rides the run's walk window before the batch's record closes.
**This batch touches `App/Variorum/Shared/` ⇒ the merge-gate window adds the phone suites.**

#### Batch A — LIVE STATUS (implementer: Opus, fresh session, 2026-11-05)

**Not done by this batch (by the brief):** NO `xcodebuild test`, NO Debug launch, NO walk (all
stage-gated — the orchestrator's window); app-target pins are compiled (`build-for-testing`) and
their red-on-old is BY CONSTRUCTION, each named below for the orchestrator's behavioral revert.

| Piece | What | Status |
|---|---|---|
| A1 | VX-806 core: `BoundarySnapping.wordStart(enclosing:in:)` — the floor of the one legal-cut set for a caret strictly inside a word (never `settle`) + 6 core pins in `BoundarySnappingTests` | DONE (d6d9ddd4a) — `swift test --filter BoundarySnappingTests` 43/43 green headless |
| A2 | VX-806 app: `TypedReturn.act`'s mid-word arm (word start → divide there; blank prefix → the start arm) + the planner's exact-cut entry `plan(divideAtExactCut:world:)` + the controller dispatch + pins (`TypedReturnTests`, `StructuralGesturePlannerTests`, `ReturnKeyTraceTests`) | DONE (a34b51244) — Mac `build-for-testing` TEST BUILD SUCCEEDED; the phone target (`VariorumMobile`, generic iOS Simulator, compile only) BUILD SUCCEEDED over the Shared change; no warning in a touched file. The app pins' RUN is PENDING (the orchestrator's stage window) |
| A3 | VX-655: the list-exit retraction moves INTO the flight (a store write inside `insertEmptyBlock`'s op body, landed on the surface by the divide seam in the landing turn; the claim no longer mutates; the exit names its block) + the order pin + the #94 undo-shape guard | DONE (69ad4c1ab) — Mac `build-for-testing` TEST BUILD SUCCEEDED, no warning in a touched file (Mac-only files: the phone target is untouched by A3). The pins' RUN is PENDING (the orchestrator's stage window) |
| A4 | Self-assessment + the record's closing sections (below) | DONE (this commit) |

#### Batch A — IMPLEMENTER SELF-ASSESSMENT (Opus, 2026-11-05)

**Not done (first line, by the brief):** no app-suite RUN, no red-on-old revert RUN, no walk, no
Debug launch — all stage-gated, all the orchestrator's (listed below with exact names). No `Sync/`,
custody or keychain file touched. No canon or shared ledger touched (the drafts are below). Every
other piece of the batch is built and compiles on both targets.

**VX-806 — the mechanism, as traced on the pre-fix tree.** ⏎ with the chip on and a caret inside a
word: `TypedReturn.act` answered `.divideAtCaret` (the prefix and suffix both hold text), the act
re-derived it and called `invokeGesture(.divideAtCursor)`, and the planner's `divide(atCaret:)`
SETTLED the caret through `snapToInteriorBoundary` — the nearest member of the word-rule's interior
legal set, with the gentle pull. Three wrong outcomes followed from that one choice: (1) a one-word
block (her screenshot: the caret one character into a block that is one quoted word) has NO interior
member, so the plan was `.refusal(.nothingToDo)` and the key spoke "No legal cut spot for that
here…" — on a fanned block the keep-on-top road's nil-cut refusal instead (`runKeepOnTopDivide`'s
guard, with the ceremony hint); (2) a caret late in a word is nearer the NEXT word's start, so the
cut went there and the caret's word stayed behind; (3) a one-letter sentence opener exactly
`settlePull` before the word wins settle's exact tie (#161), carrying that letter down too.
**The settle-vs-her-sentence divergence the brief asked to be named: it is (2) and (3).** Her
sentence governs this door, so the Return's mid-word cut is the FLOOR of the legal set, never its
nearest member.

**VX-806 — the fix, one pointer per piece.**
- `Sources/VariorumCore/Domain/BoundarySnapping.swift` — `wordStart(enclosing:in:)`: nil unless the
  graphemes on both sides of the caret are non-whitespace; else the greatest `.word` boundary ≤ the
  caret (the caret's word's start, or `0` when only whitespace precedes the word). Always a member of
  the one legal-cut set, so S4-22's grid holds by construction.
- `App/Variorum/Shared/EditorBrain/TypedReturn.swift` — the new arm, after the trailing-whitespace
  end arm and the list-line rule: a blank prefix before the word's start ⇒ `.emptyBlock(.above)` (the
  block pushed down whole — her screenshot, any first word, a one-word block); otherwise the new
  `.divideAtWordStart(entryIndex:blockID:cut:)`. **The end arm is unreachable from a mid-word caret**
  (the word stands after its own start), so the brief's "settles on the block's very END" case has no
  road here — the existing trailing-whitespace arm remains the end arm, untouched.
- `App/Variorum/Shared/EditorBrain/StructuralGesturePlanner.swift` — `plan(divideAtExactCut:world:)`:
  `.divideAtCursor`'s plan with the cut TAKEN when it is a legal interior cut (else settled as the menu
  door's — unreachable from the key; the planner never asserts). The front refusals (invalid
  selection, seal, tail) moved into one `frontRefusal` both entry points share, byte-identical.
- `App/Variorum/Variorum/Features/Editor/EditorSurfaceController.swift` — `runTypedReturnAct`'s
  `.divideAtWordStart` arm → `applyStructural(plan(divideAtExactCut:))`: the plain divide or the
  keep-on-top road, with the visible snap, through `runStructural` (the one structural door).
- Untouched, by construction and by guard pins: ⇧⏎; the chip off; crystallization / the open tail;
  selections; the list door and its intercept order at `EditorTextView.insertNewline(_:)`; a caret at a
  word's EDGE (the ordinary settled divide); the menu ⌘⇧D (its settle is S4-22's, unchanged).

**VX-655 — the mechanism (VX-649's trace, re-read on this tree).** On the exit ⏎,
`EditorViewModel.runTypedReturn` called `retractListContinuationNewline()` BEFORE scheduling the act —
an ordinary surface deletion (`OrdinaryInputEdit.apply`) inside the keystroke — and the empty block
that replaces the line landed only when the act's flight returned (a turn later, plus the flight's
flush + mint + render latency). The line was off the screen for exactly that gap.
**The order was pinnable headless** (the brief's stop condition did not fire): holding the writer
makes the flight observable, and the surface text at the claim's turn and mid-flight is a plain
string assertion.

**VX-655 — the fix.** Nothing mutates at the claim any more; the claim decides against the
unretracted surface, which answers the same `.emptyBlock(.below)` (the caret sits at the block's end
behind a newline — trailing whitespace). The claim passes the exit's block id to the act
(`scheduleTypedReturn(listExitBlockID:)` — so a click between claim and act can never point the
retraction at another block's newline). At the act's turn `listContinuationRetraction(entryIndex:
blockID:)` — the old predicate, now a pure read — names the take and its text without the newline;
`insertEmptyBlock`'s op body writes it (`ops.autosave`, charDelta 1 — the surface road's cost) ahead
of `newBlock`, in the same serialized runner body. The fresh projection's first half is then a strict
prefix of the surface's old text — exactly the divide seam's shape — so the ONE seam edit that lands
the block turns the newline still on screen into the new block's separator: the page's bytes never
change, the caret never moves off its line, store and surface agree at the landing, the DEBUG oracle
sees them equal. **#94's undo shape is whole:** the retraction was never structural and is not now
(⌥⌘Z takes the "New Block", the list still ends at its last item); the text stack changed only by
subtraction — the retraction is no longer a text-undo registration, so R2-3's named gap (two
registrations for one keystroke) is closed; the lead deletion stays the one, cleared by the rewrite
exactly as before. Write order: the take's own guards (live, active, unlocked, unsealed) answer in
`autosave` first, so a refusal writes nothing; a `newBlock` failing AFTER it (a seal or a dead note
landing between the two transactions by sync) leaves the store retracted and the surface not, healed
by the deferred delivery `runStructural`'s defer applies — the same end state the surface road had.

**Pins — and exactly what makes each red on the pre-fix tree (the orchestrator's behavioral
reverts).**
| Pin (suite TYPE · test) | Red on old because | Behavioral revert that shows it |
|---|---|---|
| `BoundarySnappingTests` · the six `wordStart` pins | (new function — compile-red on old; behavior pinned, not revert-pinned) | — (core, ran green headless 43/43) |
| `TypedReturnTests` · `aCaretInsideAWordDividesAtThatWordsStart` | old act answered `.divideAtCaret` for every mid-word caret | delete the VX-806 `if let wordStart …` block in `TypedReturn.act` → `.divideAtCaret(...)` observed |
| `TypedReturnTests` · `aCaretInsideTheFirstWordPushesTheBlockDown` | same — `.divideAtCaret` (whose door then cut `“Hello`/`there`) | same revert |
| `TypedReturnTests` · `aOneWordBlockLandsTheStartArmNeverARefusal` | same — `.divideAtCaret` (whose door refused `nothingToDo`) | same revert |
| `TypedReturnTests` · `trailingWhitespaceStillCountsAsTheEnd`, `leadingWhitespaceStillCountsAsTheStart` | RE-POINTED (the ruled supersession of #92(b)) — their caret-4 / caret-3 lines go red | same revert |
| `TypedReturnTests` · `theRoadsAWordsInsideDoesNotReach` | GREEN ON BOTH SIDES (guard) | — |
| `PlannerExactCutTests` · `aLegalCutIsTakenExactlyNeverReSettled` | the Return's divide rode the menu door's settle (cut 4, "I" rides down) | make `exactInteriorCut` return `snapToInteriorBoundary(cut, in: text)` → `snappedCut: 4` observed |
| `PlannerExactCutTests` · `aFannedBlockSeedsTheKeepOnTopRoadWithTheExactCut` | same revert → `activeCut: 4` | same |
| `PlannerExactCutTests` · `everyOtherAnswerOfTheDivideDoorStands`, `anIllegalCutSettlesAsTheMenuDoorsDoes` | GREEN ON BOTH SIDES (guards) | — |
| `TypedReturnKeyTests` · `aReturnInsideAWordCarriesTheWholeWordDown` | old key stored `["alpha beta", "gamma", "delta"]` (settled to 11) | the `TypedReturn.act` revert above |
| `TypedReturnKeyTests` · `aReturnInsideAOneWordBlockPushesItDownInsteadOfRefusing` | old key refused (`nothingToDo`, statusMessage set), store untouched | same |
| `TypedReturnKeyTests` · `aReturnInsideAFannedOneWordBlockPushesItDownToo` | old key refused on the keep-on-top nil-cut guard | same |
| `TypedReturnKeyTests` · `theListExitsRetractionLandsInsideTheFlightNeverAheadOfIt` | R1-3 deleted the newline at the claim: the claim-turn and mid-flight assertions read `"- one\ngamma"` | restore the claim-time retraction: paste the pre-fix `retractListContinuationNewline()` (`git show 7e7de0b02:App/Variorum/Variorum/Features/Editor/EditorViewModel.swift`, lines 1797–1828) back into `EditorViewModel` and call it as `if afterListExit { retractListContinuationNewline() }` ahead of `let act = typedReturnAct()` in `runTypedReturn` → the claim-turn `#expect` reads `"- one\ngamma"` (the act then finds nothing to retract, and the end state is the old one) |
| `TypedReturnKeyTests` · `theListExitsUndoStoryIsNinetyFoursWhole` | GREEN ON BOTH SIDES (#94's shape guard) | — |
| HYGIENE (after the revert window's seven `.ips`) · `aReturnInsideAFannedOneWordBlockPushesItDownToo`, `aReturnInsideAOneWordBlockPushesItDownInsteadOfRefusing`, `aReturnInsideAWordCarriesTheWholeWordDown`, `theListExitsRetractionLandsInsideTheFlightNeverAheadOfIt` | every raw subscript on store slots / index entries now sits behind a `try #require` count guard (the un-indexed expects run first), so a red road fails CLEAN instead of trapping the host in `Array._checkSubscript`. Red-on-old was already shown (a crash is red); the CLEAN red-on-old re-show is PENDING the orchestrator's next stage window | revert 1 again → the fanned and one-word pins fail at their `#require`, no `.ips` |

**Addendum (after the orchestrator's stage run, 2026-11-05 — 281 tests, 280 green):**
`NestedListDoorTests` · `returnAtDepthContinuesThenOutdentsThenExits` (`WalkBuildRoundTests.swift`) is
RE-POINTED by the VX-655 supersession: its post-exit-press assertion pinned R1-3's claim-time
intermediate `"- milk\n  - almond"`; it now reads `"- milk\n  - almond\n"` (only the lead goes at the
keystroke), the store assertion `["- milk\n  - almond", ""]` stands unchanged, and a landed-state
assertion was added (`"- milk\n  - almond\n"` — the newline is the new block's separator). Red-on-old
is satisfied by the same revert as `theListExitsRetractionLandsInsideTheFlightNeverAheadOfIt` (the
claim-time retraction restored → the keystroke-turn `#expect` reads `"- milk\n  - almond"`). The sweep
of both app test targets for other assertions pinning the claim-time intermediate found none: the
other list-exit pins assert only after a flush (`ListContinuationTests` ·
`anEmptyListItemExitsTheListAndThenTheKeyMakesTheBlock`, `TypedReturnKeyTests`' list pins), the
remaining post-press surface asserts are continuations, and the take pane's exit (`aTakePaneContinuesListsToo`)
never reaches the typed-return claim.

**Headless suites at the END (at f7b7ae24c, the batch's last code is a34b51244/69ad4c1ab):** full core
`swift test` — `VariorumCoreTests` 3655 tests / 492 suites PASSED (5 known issues; the VX-781 pin
belt suite among them, passed); `StringsWorkbookTests` 32/4 PASSED; `VariorumMCPTests` 549/100 with
4 issues, all in the MCP socket harness (`MCPHarnessTimeLimitTests`, `MCPDiscoverProbeServerTests`,
`MCPStopRoadsServerTests`, `MCPStopEndsConnectionGrantsServerTests` — "got no answer to its
initialize") while the VX-809 worktree ran its own MCP server suites on this machine at the same
moment; those four re-run alone (`swift test --skip-build --filter …`): 17 tests / 4 suites PASSED in
2.6 s. This batch touches no MCP code. Mac `build-for-testing` (Variorum scheme) and the phone
target's compile (VariorumMobile, generic iOS Simulator) both SUCCEEDED.

**PENDING (the orchestrator's stage window).** (1) App suites, by TYPE (`-only-testing` takes a zsh
array of these): `TypedReturnTests` · `ReturnKeyTraceTests` · `SoftNewlineTests` ·
`TypedReturnKeyTests` · `PlannerFixtureTests` · `PlannerDivideTests` · `PlannerExactCutTests` ·
`PlannerExtractTests` · `PlannerMakeBlockTests` · `PlannerMergeTests` · `PlannerPrecedenceTests` ·
`PlannerGraphemeTests` — and the neighbours the diff can reach: `ListContinuationTests` ·
`NestedListDoorTests` (the list-exit pins in `WalkBuildRoundTests.swift`) · `DivideExtractGestureTests`
· `StructuralRewriteDoorTests` · `DifferentialApplyTests` · `FannedDefaultsTests` ·
`CommandDeleteLineTraceTests` · `BlockDeletionAndRedoTests` · `CrossBlockCompoundTests` ·
`ReturnKeyUndoSignTests` · `WriteFloatingViewportTests` · `WriteTopAirTests` · `SeamEditHappyPathTests`
· `SeamEditFallbackTests` · `SeamEditNonSeamGeometryTests` · `SeamEditRetainedByteTests`. (2) The phone
suites at the merge gate (Shared changed: `MobileStructuralTests` · `MobileTakeStructureTests` at
least — the planner's `.divideAtCursor` and `snapToInteriorBoundary` are byte-unchanged for them).
(3) The red-on-old reverts per the table. (4) The walk: chip on — Return early, mid and late in a
word; in a first word; after an opening quote in a one-word block; in a fanned one-word block; a
checklist exit (`- [ ] item`, ⏎, ⏎ — the line must not blink); both voices.

**PROVISIONAL — proposed here (the QUESTIONS entry lands at the merge moment).**
- **P-828-6 — where the caret lands when the word rides down.** BUILT (a): the divide door's own
  landing — the successor's start (the word's start; the existing "snap-and-proceed, visibly"
  contract), and on the start arm the pushed-down block's start (the arm's existing landing). This is
  also where an ordinary editor's caret sits after ⏎ (the start of the new line). Alternative (b): the
  caret rides INSIDE the word at its offset (`Hel|lo` stays `Hel|lo` on the new line) — new landing
  code on both arms. (c) (b) on the divide arm only.

**For the orchestrator's canon pass (DRAFTED — not applied; the two-file rule).**
- AppSpec §7, the Segmentation / Return-key note: "a divide at the caret inside its text
  (single-take in place; fanned → keep-on-top)" → "a divide at the caret inside its text — a caret
  INSIDE a word divides at that word's start so the whole word rides down, and where that word starts
  the block the block is pushed down with an empty block above (VX-806); single-take in place,
  fanned → keep-on-top"; the pointer list gains VX-806.
- AppSpec §9's "One snapping rule serves every cut" stays true as written (the Return's cut is drawn
  from BoundarySnapping's legal set), but S4-22's GENTLE SETTLE no longer chooses the Return's
  mid-word cut — her VX-806 sentence does (the floor). Whether §9 should name that exception in place
  is the orchestrator's call; the menu ⌘⇧D keeps the settle (and #161 stays open for it).
- QUESTIONS #92(b): SUPERSEDED by VX-806 (her 2026-11-04 report, ruled through the ticket) — a
  one-word block's mid-word Return lands the start arm. #94(a)'s R2-3 gap note: closed by VX-655.
- AppSpecRecord: the dated entry + the narrative under §7 (the Return key) and §9 (divide).

**Self-assessment.** CONFIDENT: both mechanisms (read on this tree, line by line, before any edit);
the cut's legality (a floor of the legal set, pinned for every caret of five texts); the seam shape of
the VX-655 landing (traced through `StructuralSeamEdit.derive`'s divide arm — prefix 5 ≤ old length 6,
retained bytes `- one`, replace (5,1) → `"\n"`, the oracle's per-entry text check); #94's undo shape
(traced: `newBlock` registers the only structural entry; the rewrite clears the text stack on both
roads). FLAGS FOR THE COLD REVIEWER: (a) the retraction's store write now precedes the mint as a
second transaction inside one runner body — not one transaction (no public compound-transaction
road; `editTakesAtomically` would add an undo entry and insurance commits, breaking #94's shape) —
the partial-failure window is described above; (b) the claim's decision now runs on the UNRETRACTED
surface — argued equivalent (trailing whitespace is the end), pinned by the list-exit suites; (c)
`TypedReturn.act` now scans the block once at the claim for a mid-word caret (`wordStart` →
`boundaries`), O(the caret's block) — P1 holds, the keystroke never reads the document; (d) the
Return door and the menu ⌘⇧D now answer a mid-word caret differently (floor vs settle) — by the
brief's "her sentence governs the Return door", stated in canon draft above.

**Files touched (the whole batch):** `Sources/VariorumCore/Domain/BoundarySnapping.swift` ·
`Tests/VariorumCoreTests/BoundarySnappingTests.swift` · `App/Variorum/Shared/EditorBrain/TypedReturn.swift`
· `App/Variorum/Shared/EditorBrain/StructuralGesturePlanner.swift` ·
`App/Variorum/Variorum/Features/Editor/EditorSurfaceController.swift` ·
`App/Variorum/Variorum/Features/Editor/EditorViewModel.swift` ·
`App/Variorum/Variorum/Features/Editor/EditorTextView.swift` (comment only) ·
`App/Variorum/VariorumTests/TypedReturnTests.swift` · `App/Variorum/VariorumTests/StructuralGesturePlannerTests.swift`
· `App/Variorum/VariorumTests/ReturnKeyTraceTests.swift` · this record.

### Batch D — the Trash: VX-800 + VX-636

**Required reading:** AppSpec §9 "Deletion, restoration, the tray" + the purge design pointer
(`notes/plans/phase-13j-purge-memo.md` §4f — S2's one bend), SurfaceContracts "The Bookcase and
books" Delete/Trash bullet (the vx-678 multi-select rows, the one status seam),
`notes/plans/fixes/vx-678-trash-purge-resurrection.md` (the Delete Now road's shape),
`App/Variorum/Variorum/Features/Library/RecoveryView.swift` (the Trash surface) and the existing
purge-intent operations.

**VX-800 (Improvement, Confirmed).** Her ask: *"delete all empty blocks with no history from
trash."* One sweep door in the Trash: permanently delete — the Delete Now shape, tombstone-side
purge intents + the purge horizon, NEVER a raw DELETE — every trashed block that is empty with no
history. **The predicate (R-828-1, ruled at kickoff):** a trashed block qualifies when it has no
savepoints (no `commit_point` on any of its variants), no comments (no `block_comment` rows), no
non-empty take (every variant's `working_text` empty), no `name`, no `presentation` frame, **and no
live edge to a live block** (any live `edge` row linking it to a block that is itself live keeps it
out — the lineage tree VX-827 is building faces for stays whole). Edges among dead blocks don't
save it. The exact row-level reading of "no comments"/"empty" is the implementer's to propose in
the record BEFORE building (the architect rules on it — the in-batch fork rule); the predicate is a
pure function with exact-rows tests. The door: confirmed each time like the other delete-forever
doors, the confirm counting what it will sweep; a swept block is never counted back by Put back
(the vx-678 law); registry-declared; the receipt speaks on the one status seam.

**VX-636 (Bug, Confirmed — the rider).** After Delete for Good, the quiet receipt "The note is gone
from the app now — the app's own cleanup removes the bytes." draws OVER the bottom visible Trash
row's text instead of in its own band (the one status seam's placement rule; seen at VX-601's A2
walk). Give the Trash's receipt line its own band (the Pool-foot `QuietReceiptLine` idiom is the
family). Pin where the geometry is pinnable; otherwise the walk verifies and the record says so.

**Acceptance evidence:** exact state-transition tests on the predicate and the sweep op (purge
intents minted, horizon honored, restore interplay) + the orchestrator's walk of the door and the
receipt band.

#### Batch D — LIVE STATUS (implementer: Opus, fresh session, 2026-11-05)

**Not done by this batch (so far):** D2–D5 (below). The fork was RULED (22a8da5d4) and the build
follows it. No `xcodebuild test`, no Debug launch, no walk (all stage-gated — the orchestrator's
window, by the brief). No `Sync/`, custody or keychain file will be touched (the purge-intent op lives in
`Operations/`; `PurgeJanitor.anyFamilyEverSynced` and `LocalPurge` are only CALLED, as every Trash
purge door already calls them).

| Piece | What | Status |
|---|---|---|
| D0 | Preflight (the brief's reading list, read in full) + THE DESIGN FORK below | DONE (057d58114) — RULED (22a8da5d4, "Batch D — THE FORK'S RULING") |
| D1 | VX-800 core: the pure predicate (`Domain/EmptyBlockSweep.swift`) + the candidate/facts read and its named-region observation (`Queries/EmptyBlockSweepQueries.swift`) + exact-rows pins (`Tests/VariorumCoreTests/EmptyBlockSweepTests.swift`, 10) | DONE (cdb514168) — `swift test --filter EmptyBlockSweepTests` 10/10 green headless. Mutation probes M1–M3 ANNOUNCED here (this commit), each an UNCOMMITTED edit to the facts SQL in `Sources/VariorumCore/Queries/EmptyBlockSweepQueries.swift` on the committed tree, restored by `git checkout --` (git is the honest mid-probe state; no prerevert dir needed): M1 comments counted live-only (`AND bc.deleted_at IS NULL`) → expect `historyKeepsAnEmptyBlockOutAndMetadataDoesNot` red; M2 edges counted live-only (`AND e.deleted_at IS NULL`, both arms) → expect `aLinkToALivingBlockKeepsItOutAndALinkToADeadOneDoesNot` + `everyEdgeShapeIsReadByTheOtherSidesLifeAlone` red; M3 takes counted live-only (`AND v.deleted_at IS NULL` in `worded_takes`) → expect `theJunkShapeQualifiesAndAnyWordedTakeStaysOut` red. Results PENDING (next commit) |
| D2 | VX-800 core: the sweep operation (intents + horizon, act-time re-check) + transition tests | NOT-STARTED |
| D3 | VX-800 app: registry declaration, the door, the confirm case, the count observation, receipts, app pins | NOT-STARTED |
| D4 | VX-636: the Trash's message band + pins | NOT-STARTED |
| D5 | Self-assessment + the record's closing sections | NOT-STARTED |

#### Batch D — THE DESIGN FORK (D0: VX-800's predicate, door, confirm and undo story — proposed for the orchestrator's ruling BEFORE any build)

**The candidate set — which rows the sweep may consider at all.** Exactly the Trash's own BLOCK rows:
`Queries.trash(db, now:, kinds: [.block], wingID: <the wing the Trash shows>)`, unwindowed, and not
narrowed by the kind picker (Empty Trash's scope: a door over this wing's whole Trash). Reusing the
listing's arm (no twin SQL) inherits: the 30-day window; the wing fence; the stamp-aware purge-intent
fence (a row already going is not re-taken); and — load-bearing — **the cascade-victim exclusion**: a
block that died WITH its note (same stamp) is part of that note's one row and is never swept alone
(sweeping it would break the note's whole Put back). Notes, books, snippet groups, takes and
preserved originals are never candidates (a preserved original is LIVE).

**The predicate (R-828-1), row-level. A candidate qualifies iff ALL six hold:**
1. **Empty:** no `variant` row of the block — ANY status (active/archived), ANY tombstone state (live,
   the block's cascade stamp, or deleted on its own stamp earlier) — has `working_text <> ''`. Empty =
   zero-length, byte-exact: the codebase's own empty test (the seam carve's
   `variant.workingText.isEmpty`, `Operations+Deletion.swift:325`). ALL variant rows, because the purge
   family takes all of them (`PurgeFamily.expandBlock`): a take deleted earlier with words in it is
   words the sweep would destroy.
2. **No savepoints:** no `commit_point` row on ANY variant of the block (any variant state; quiet or
   manual alike; `commit_point` has no tombstone). The junk shape passes: an empty, never-committed
   take never earns a quiet savepoint (`isDirty` is false for it, `Operations+Variant.swift:639`); a
   take that once held words and was saved fails — as it should.
3. **No comments:** no `block_comment` row on the block — ANY row, live or tombstoned, any stamp. Every
   comment row is retrievable: Put back revives the stamp-matched ones, and an individually deleted
   one stays "visible and resurrectable" in the deleted fold (AppSpec §7's `block_comment` note). The
   alternative reading ("only revivable ones" = live or the block's stamp) would purge a resurrectable
   comment — rejected.
4. **No name:** `block.name IS NULL` (the ops normalize whitespace-only to NULL; a non-NULL `''`,
   unreachable through the ops, counts as a name — conservative).
5. **No callout frame:** `block.presentation IS NULL` (any non-NULL value, even malformed JSON that
   READS as plain, keeps it out — conservative).
6. **No link to a living block** (her "any live edge to a live block"): no `edge` row of ANY type
   (`derived_from` either direction, `version_of`) naming the block on one side whose OTHER side is a
   `block` row with `deleted_at IS NULL` (an archived block is live). **The edge row's own tombstone
   is NOT consulted, deliberately:** deleting a block cascade-tombstones every edge it has
   (`cascade_block_tombstone`, `Triggers.swift:44`), so for a trashed block a literally-live edge is
   all but unreachable and the clause would be vacuous; and the lineage readers (`strandedOriginals`,
   `PurgeFamily.joinStrandedOriginals`) read `derived_from` PAST edge tombstones ("lineage is a fact
   about what happened"). This reading also makes the sweep safe BY CONSTRUCTION: the purge family
   joins any live, unplaced, unarchived original whose every descendant is in the family
   (`joinStrandedOriginals`) — under (6) no swept block can be directly linked to a living block, so
   the sweep can never take a living original's words with it. Edges to dead or absent blocks don't
   save it (ruled); a self-edge doesn't count.

**NOT history** (outside her floor; the purge family takes them with the block): `block_tag`
applications, take labels, a locked take, `canvas_layout` / `lens_choice` rows, `block.archived_at`,
`last_container_id`.

**The readings that are genuinely mine — options (each PROVISIONAL until ruled):**
- **P-828-7 — the edge clause.** (a) PROPOSED: any edge row, whatever its own tombstone, to a live
  block (above). (b) Only edges live or tombstoned on the block's OWN stamp (what Put back revives) —
  it would honor a deliberately unlinked version link (`removeVersionOf` / `unmarkPostsAsVersions`
  tombstone `version_of` on their own stamp), but it would sweep an empty block whose `derived_from`
  to a live original died on a third stamp, and if that block were the original's last descendant
  `joinStrandedOriginals` would purge the LIVING original with it. (c) (a) for `derived_from`, (b) for
  `version_of`.
- **P-828-8 — "empty".** (a) PROPOSED: zero-length `working_text` only. (b) Whitespace/newlines-only
  also counts as empty.
- **P-828-9 — block tags.** (a) PROPOSED: not history (her floor's list is the list). (b) Any
  `block_tag` row keeps the block out.

**The pure function and its tests.** `Domain/EmptyBlockSweep` — one pure rule over a block's counted
facts (non-empty takes, savepoints, comments, name, presentation, links to living blocks), exact-rows
tested; `Queries` gathers the facts for the Trash's block rows in ONE statement (indexed per-candidate
counts: `idx_variant_block`, `idx_commit_variant`, `idx_block_comment_block`, `idx_edge_source` /
`idx_edge_target`) — cost ∝ the Trash's block rows (a summoned surface), never the corpus (P1).

**The act — ONE operation in the Delete Now shape** (`Operations.sweepEmptyTrashBlocks(_ ids:)` in
`Operations+Purge.swift`): ONE write transaction that re-reads the predicate over the confirm's ids
INSIDE it (the `deleteBlock`-precondition lesson: a check made outside the transaction is a snapshot —
a block put back, re-deleted as a cascade victim, or written by a sync apply in the pause drops out),
takes `confirm ids ∩ still-qualifying` (never more than she confirmed — the bulk Delete Now's picked ∩
present rule, not Empty Trash's take-everything-now), and mints one purge intent per taken block
through `mintPurgeIntents` (its dedupe, refusals and already-purged skip — one implementation, never
two). No raw DELETE: the bytes go by the existing roads — `LocalPurge` at once on a never-synced
install (her round-11 ruling: the local sweep runs before the receipt, as every Trash purge door does),
the janitor at the horizon otherwise (purge memo §4f). Nothing left ⇒ a refusal, nothing written. It
answers the taken ids (the receipt's count). No touch, no churn (`requestPurge`'s posture).

**The undo story — none, exactly the vx-678 roads.** No ⌥⌘Z entry (`requestPurge`'s own reason: "the
confirm is the guard … an undo whose inverse raced the janitor would be a door that sometimes lies");
confirmed every time (round 10). A swept block is never counted back by Put back: the rows leave the
listing at the intent write (the stamp-aware fence) and so leave the pick (the listing's prune) —
plus a BELT: the model drops the swept ids from the pick at the act's answer, so no stale bulk Put back
can name one; on a never-synced install the rows are physically gone before the receipt speaks, so a
stale road meets `blockNotFound` and is never counted back; a PEER's Put back that lands before the
intent arrives is the existing staleness rule (13j B1 — the family never purges, the intent completes
unhonored), unchanged.

**The door.** A registry-declared `.surface` capability, app scope, the `.deleteNow` / `.emptyTrash`
shape (verb "Delete Empty Blocks"; `RecoveryView.surfaceCapabilities` gains it, so the surface-walk
union keeps it Trash-only). In the Trash's controls row, left of Empty Trash, danger role, compact. Its
label carries the count it takes, sentence case like the bulk row: "Delete 3 empty blocks…" / "Delete
1 empty block…" (the ellipsis = the confirm it asks every time). Help: "Every empty block with no
history goes for good — asked to confirm every time".
**Count 0 (P-2's frame): NOT rendered** — a door that can never act in its context isn't rendered
(Empty Trash's own visibility rule). The count comes from a dedicated held observation of the
candidate query on a NAMED region (`observe(tracking:)` — re-fetched on a reader after each commit,
never on the writer: VX-670's lesson), keyed to the wing, independent of the kind filter. The race
(drawn at 3, all put back in the pause) answers with the refusal below — a door that did nothing
speaks a refusal.

**The words (drafts — PROVISIONAL P-828-10, hers to tune):**
- Confirm, N > 1: "Delete these 3 empty blocks for good? None holds any words, savepoints, comments, a
  name, a callout or a link to a living block. They skip the rest of their 30 days — there's no putting
  them back." N = 1: "Delete this empty block for good? It holds no words, savepoints, comments, name,
  callout or link to a living block. It skips the rest of its 30 days — there's no putting it back."
- Receipt, the bulk Delete Now's three populations: "3 empty blocks are gone from the app now — the
  app's own cleanup removes the bytes." / "… — the bytes follow once every synced device has caught
  up." / "… — anything that once synced finishes clearing after you next sign in; the rest the app
  cleans up now." N = 1: "The empty block is gone from the app now — …".
- Fewer qualify at act time than she confirmed: the receipt counts what really went (Empty Trash's
  rule — "the receipt says what really went, never what the confirm guessed").
- Refusal, nothing left: "None of those empty blocks are in the Trash any more — nothing was deleted."
- The receipt and refusal ride the Trash's existing message slot (its `receipt` / `lastError` — the
  road every Trash door speaks on today), which VX-636 gives its own band.

**VX-636's intended shape (stated now so the ruling can redirect it — not a fork).** The Trash's
message slot moves from `.overlay(alignment: .bottom)` on the `List` (`RecoveryView.swift:905`, the
mechanism: an overlay draws OVER the list's last visible row) to a laid-out FOOT BAND below the list —
the Pool's `PoolReceiptFoot` shape: a hairline, then the line, present only while something speaks
(no reserved blank line). Precedence is ArchivedView's: the Trash's own error (alarm voice) → its own
receipt (muted) → else the one status seam's `QuietReceiptLine` (so a seam receipt — ⌥⌘Z's "Undid…" —
speaks here too, instead of nowhere). Pins: the pure precedence decision, and a HOSTED geometry pin
(the line's frame lies wholly below the list's frame; red on the overlay) — which needs one internal
`model:` init parameter on `RecoveryView` (its `@State` model is unreachable from a test today). If
that seam is declined, the walk verifies the band and the record says so.

**ASKED OF THE ORCHESTRATOR (one ruling unblocks D1–D4):** P-828-7 / -8 / -9; the words (P-828-10 —
or leave them PROVISIONAL); the act's `ids ∩ still-qualifying` rule; count 0 = not rendered; the pick
belt; and whether VX-636 may take the `model:` init seam for its geometry pin.

### Batch C — the Library remembers (VX-823, HIGH)

**Required reading:** SurfaceContracts "The Library" (whole section) and "The app"'s Open-list
follow idiom; `notes/plans/phase-18l-navigation-feel.md` (the note-side memory pattern this
mirrors); TEXTKIT2_NOTES' 18l-c U8 HARNESS fact (a bound SwiftUI ScrollView re-applies its last
scrollTo on relayout — the trap for programmatic restores); the Library feature folder
(`App/Variorum/Variorum/Features/Library/`).

Her ask: *"what's the lift on you keeping where you were in the library after entering a note and
leaving it? it's kinda driving me crazy to not have this."* Session-scoped position memory:
opening a note from a Library row and coming back restores the list to the same place, the row you
left from selected. The memory anchors on the row's ID, re-resolved into the CURRENT sort on
return — never a pixel offset (the list virtualizes on a keyset sort); search state and the day
filter ride along; List and Cards both. A row deleted or filtered away since: land the list where
the row would have been (nearest surviving neighbor), never throw. The same courtesy for a book's
Index/Outline rides ONLY if genuinely cheap — if not, the record says so and the orchestrator
tickets it. P1 binds: the restore reads rows proportional to the viewport, never walks the corpus.

**Acceptance evidence:** focused view-model tests (anchor resolution across sort/search/filter
changes, the deleted-row fallback) + the orchestrator's hands-on walk (List, Cards, with a search
live, with the day filter on).

### Batch B — wings from the keyboard & the switcher: VX-824 + VX-833 + VX-844

**Required reading:** SurfaceContracts "The app" (keyboard family; the wing label VX-552/VX-644
lines) and "The Bookcase and books" (the wing switcher bullet); the registry
(`App/Variorum/Variorum/Registry/` — `CapabilityRegistry.swift`, `ShortcutCatalog.swift`),
`App/Variorum/Variorum/Core/Views/WingSwitcherBrain.swift`, `ShellRouter.swift`; VX-738's label
cleanup record (`notes/plans/fixes/vx-736-hotfix-101.md` J5, R-736-6) for VX-844's widths.

**VX-824 (RULED — her sitting word on the ticket, shape (a)):** ⌘digit is CONTEXTUAL — inside a
note it stays the mode row (⌘1–⌘7 Debug, ⌘1–⌘6 Release, untouched); while NO note holds the keys
(the VX-560 "while no text input holds the keyboard" family, plus the note-focus condition) ⌘N
switches to wing N in SWITCHER ORDER (`wing.position`, Home first). Registry-declared with the
chord said where the registry speaks. A ⌘digit naming a wing that doesn't exist: propose the
behavior (quiet no-op vs refusal) in the record before building — PROVISIONAL, the P-2
door-that-did-nothing rule is the frame.

**VX-833 (RULED — her final call on the ticket):** switching wings NAVIGATES — the switcher's pick
and the ⌘digit chord land in that wing's **BOOKCASE**, one rule for both roads (*"let's just keep
landing in the bookcase. i want it to be consistent and the ticket is there for the preference
eventually anyway"* — VX-834 is the eventual preference). And the "in ‹wing›" switcher sits
RIGHT-ALIGNED in the sidebar's top bar, never crossing the vertical divider into the content area.
The existing follow ("the app's one wing follows the focused pane's note", the "Now in …" receipt)
is untouched — this rules the DELIBERATE switch only.

**VX-844 (RULED — ellipsis explicitly declined):** a wing name longer than its space SCROLLS within
the space it has, car-radio style, never crossing the 240-pt column line (R-736-6 sized the default
widths). Animate ONLY while the name overflows (no standing timer on the common case — P8);
cadence/loop shape is the implementer's to propose in the record (PROVISIONAL).

**Acceptance evidence:** the registry-walk test green with the new declarations; routing tests for
the contextual chord (in-note vs no-note); the orchestrator's walk (chords, switcher pick lands in
the Bookcase, the marquee on a long wing name in both voices).

### Batch E — spellcheck & Settings ▸ Tags: VX-798 + VX-838 + VX-840

**Required reading:** SurfaceContracts "The app" (keyboard family, the status seam);
`EditorBehaviorSettings.swift` (the A24 three-level design — its §3 crash pairing note BINDS:
completion stays off whenever continuous checking is on; TEXTKIT2_NOTES "Spell check / completion"
is the why); the registry files; the Settings Tags pane (tag management's home — find it from
`SettingsShape.swift`); `Operations` deleteTag (§9's structural-undo entry "Delete Tag").

**VX-798.** Her asks (2026-11-04): a one-time spellcheck on a chord, and the menu home back. Build
both: (1) the macOS-standard pair — ⌘; (Check Document Now / step to next misspelling) and ⌘:
(Show Spelling and Grammar panel) — wired via the responder chain's `checkSpelling(_:)` /
`showGuessPanel(_:)`, one press running a check pass WITHOUT turning the continuous level on;
(2) an Edit ▸ Spelling and Grammar group carrying those items (a SwiftUI-lifecycle menu bar doesn't
carry AppKit's — add them back). The A24 setting is untouched; registry-declared; chords work in
every live editor (Write, panes, the capture box — say in the record which responders answer).

**VX-838 (Bug; RULED R-828-2):** the pane NAMES its wing in its header ("Tags — in ‹wing›") and
FOLLOWS the app's wing live on a wing switch — no stale vocabulary. (Root bug: a wing-scoped list
never said which wing it was.)

**VX-840 (the rider; R-828-4 seated it here).** Her ask: a door to delete every tag not currently
on a note. In Settings ▸ Tags: list every tag in the wing with ZERO live applications (`post_tag`
and `block_tag` alike, live rows only), show them checked, delete the checked ones in ONE confirmed
act; each deletion is the existing `deleteTag` (subtree rules, the ⌥⌘Z "Delete Tag" entry — the
bulk act's undo shape is the implementer's to propose in the record before building: N entries vs
one compound; PROVISIONAL). **Trash-only wearers (her lean on the ticket, adopted as the run's
PROVISIONAL):** a tag whose only applications sit on trashed rows is NOT unused (they'd revive with
a restore) — it does not list. **The shared-query seam (coordinator-settled):** vx-809's VX-825 OWNS
the unused-tags query's mint and sends its name, home file and signature to this run; batch E
CONSUMES that function (the true-count form), never mints a twin. If vx-809 hasn't merged when E
opens, build against the named signature and the merge-in reconciles. The signature lands in this
record when it arrives; if E opens before it has, the implementer STOPS at this piece and asks the
orchestrator.

**Acceptance evidence:** exact-rows tests on the unused-tags query (live/trashed/block-tag cases) +
pane tests for the wing follow + the orchestrator's walk (the chords in Write and a pane; the menu
group present; the pane following a wing switch; the unused-tags door end to end with ⌥⌘Z).

## ENVIRONMENT TRAPS (carried into every batch brief VERBATIM)

- Branch from main ≥ 8ffdd8278 (carries VX-781's PIN BELT). Core `swift build` prints 7 EXPECTED
  "dependency not used by any target" warnings — not a regression. `PinBeltTests` rides every
  `swift test`. Moving ANY pinned dependency version is AUTHOR-ONLY (P-781-4, CLAUDE.md).
- **No `Sources/VariorumCore/Sync/`, custody or keychain** — out of this run's scope; reaching one
  means STOP and report.
- **The stage:** every `xcodebuild test` run (Mac or simulator), every Debug launch, every walk and
  every dev-store act goes through `nov4coordinator` (REQUEST what/minutes/claim early · READY ping
  · GO only from the coordinator with the exact claim line · RELEASE + one result line with
  EXECUTED counts per suite — "Executed 0" is no verdict). Headless `swift build` / `swift test` on
  the core package is free, always.
- `-only-testing` takes a zsh ARRAY of suite TYPE names, never file names. Mac tests run from
  `App/Variorum/`; NEVER add a custom build configuration (non-"Debug" builds the packages Release
  and strips the DEBUG oracles).
- Instance guards use the strict forms `pgrep -lx Variorum` and `pgrep -lf "MacOS/Variorum$"`;
  treat real-store instances by STORE, never quit or kill one; no Release builds or /Applications
  refreshes while one lives.
- After any Debug launch, dismiss a What's New sheet if one shows (VX-237 is open).
- A diff touching `App/Variorum/Shared/` adds the PHONE SUITES (simulator) to the merge-gate
  window — batch A does; budget it.
- Registry overlap with vx-805/vx-809: whoever merges second re-runs `CapabilityRegistryTests` +
  `ShellChromeTests` after merging main in.
- Walks: dev-store Debug build only (`io.lduarte.Variorum.debug`), `cliclick` + `Tools/WalkKit/`,
  under a HELD stage claim. The dev store's content is the agents' to manage; its Castle
  credentials are `~/.variorum/dev-castle.env` ONLY (no batch here should need them).
- Never `git checkout` over uncommitted work; never `git add -A` in the shared worktree (pathspec
  adds only); the scratchpad is NOT crash-durable — pre-revert copies live inside the worktree in a
  gitignored, uniquely named dir, and commit before you revert.
- Screenshots in gitignored dirs. Push after every commit. Never rewrite pushed history.

## CHECKPOINT RULES (the resiliency protocol, restated — binding from the FIRST commit)

Commit per coherent piece, push after every commit; write this file's LIVE STATUS row flip in the
same commit as each piece (`DONE (hash)` · `IN-PROGRESS — exactly what remains` · `NOT-STARTED`);
unverified claims marked PENDING and flipped when the run completes; synchronous foreground waits
only (poll with `grep -q '<EXIT LINE>' <log> && break; sleep 5` loops — `tail -f | grep -m1` hangs
after the line has landed); implementers spawn NO subagents except at most one Sonnet for EXTERNAL
facts, read-only; every death and resume noted here; no revert starts until this record names it
and the pre-revert copies exist.

## THE LADDER

*(Opens when the batches close: a fresh `fable-reviewer` runs `notes/REVIEW_PROMPT.md` VERBATIM
over the run's whole diff, zero framing; findings land here repo-first; cross-model flow per
CLAUDE.md — the reviewer makes final calls, the implementer applies confirmed fixes red-on-old,
round 2 re-reviews; hard cap three rounds.)*

## PROVISIONALS SEEDED (QUESTIONS entries land at the merge moment, per the parallel-work rule)

- P-828-1: ⌘digit naming a nonexistent wing — quiet no-op vs refusal (batch B proposes).
- P-828-2: the marquee's cadence/loop shape (batch B proposes).
- P-828-3: VX-840 — a tag whose only wearers are in the Trash is NOT unused (her lean on the
  ticket, adopted; batch E builds it).
- P-828-4: VX-840's bulk delete undo shape — N "Delete Tag" entries vs one compound (batch E
  proposes).
- P-828-5: VX-823 — whether the book Index/Outline courtesy rides (batch C assesses; if skipped,
  it's a ticket at closeout).
- (VX-806 supersedes QUESTIONS #92(b)'s built answer — #92 gets its update at the merge moment.)
- P-828-6: VX-806 — where the caret lands when the word rides down: BUILT (a) the divide door's own
  landing (the word's start on the new block; the start arm's block start); alternatives (b) the
  caret rides inside the word at its offset, (c) (b) on the divide arm only (batch A proposes —
  its self-assessment).
- P-828-7: VX-800 — the edge clause's reading: (a) any edge row, whatever its own tombstone, to a
  live block; (b) live-or-own-stamp edges only; (c) (a) for derived_from, (b) for version_of (batch D
  proposes (a) — its D0 fork, awaiting the orchestrator's ruling).
- P-828-8: VX-800 — "empty" = zero-length (a) vs whitespace-only too (b) (batch D proposes (a)).
- P-828-9: VX-800 — a block tag is not history (a) vs keeps the block out (b) (batch D proposes (a)).
- P-828-10: VX-800 — the door's label, confirm, receipt and refusal words (batch D drafts them, D0).

#### Batch A — ORCHESTRATOR VERIFICATION (stage window "vx-828-batchA", 2026-11-05)

Part 1 (suites): 281 tests / 28 suites — 280 green + ONE stale neighbor pin
(`NestedListDoorTests.returnAtDepthContinuesThenOutdentsThenExits`, pinning R1-3's claim-time
intermediate that VX-655 supersedes), re-pointed by the implementer (58e655834, sweep found no
siblings), re-run green (18/2 with `ListContinuationTests`). Two anonymous warnings at
`Date.swift:37` (harness noise, no test attributed); the early sqlcipher decrypt errors are the
test host meeting the locked dev store at launch (pre-existing).

Part 2 (red-on-old reverts) STARTING — three behavioral reverts per the pin table, each an
UNCOMMITTED edit on the committed tree at 58e655834 (git checkout restores; no prerevert dir
needed, git diff is the honest mid-revert state): R1 bypass the TypedReturn mid-word arm;
R2 exactInteriorCut → settle; R3 restore the claim-time retraction from 7e7de0b02. Results follow.

Part 2 (reverts) DONE — all three red-on-old CONFIRMED, each restored to the committed state
(`git status` clean after each):
- R1 (TypedReturn mid-word arm bypassed): 8 red — the 3 TypedReturnTests pins, the 2 re-pointed
  whitespace pins, the 3 TypedReturnKeyTests key pins; the VX-655 order pin stayed green.
- R2 (exactInteriorCut → settle): both exact-cut pins red; both guards green.
- R3 (claim-time retraction restored from 7e7de0b02): theListExitsRetractionLandsInsideTheFlight
  NeverAheadOfIt red (claim-turn + mid-flight), the re-pointed NestedListDoorTests pin red the same
  way; the #94 undo guard and every end-state pin green.

**Batch E's shared-query signature (arrived from vx-809, its batch 1 closed at 54831417f):**
`Queries.tagSubtreeIsWorn(_ db: Database, tagID: String, scope: Queries.TagWearerScope) throws ->
Bool` in `Sources/VariorumCore/Queries/TagUsageQueries.swift` (tests `TagUsageQueriesTests`).
VX-840's unused = `!tagSubtreeIsWorn(db, tagID:, scope: .library(countingTrashRevivable: true))`
per wing — the `countingTrashRevivable: true` arm IS P-828-3's lean (a Trash-revivable wearer keeps
the tag worn); WORN is subtree-honest by the materialized path (deleteTag's own rule). Whoever
merges second re-runs TagUsageQueriesTests on the merged tree.

Also for the merge gate (coordinator): merge main ≥ be17fb632 in first (VX-853 — verify-pins
no-arg guard; a NOTE from verify-pins = bookkeeping-only lockfile drift, restore with
`git checkout HEAD -- <file>`, never commit it; DRIFT still means stop).

Part 3 (the walk) DONE — Debug dev store (io.lduarte.Variorum.debug), scratch note "vx828 walk A",
all legs green: (a) mid-word Return carries the word down ("beta" rode whole, caret at the new
block's start — P-828-6 (a) seen); (b) first-word caret lands the start arm ("beta gamma" pushed
down whole); (c) HER CASE — the quoted one-word block pushes down with an empty block above, NO
refusal toast; (d) the fanned one-word block (⑂2) pushes down whole, badge riding, no keep-on-top
nil-cut refusal; (e) the checklist exit leaves "- [ ] item" whole with the caret on its own line
below, no artifact (the frame-blank itself is the pin's evidence, not a still's); (f) both voices —
the store rests in STUDY (legs a–e ran there); the Terminal leg re-exercised the start arm
identically; the voice was restored to Study and the app quit clean (zero instances). Walk notes
stay in the dev store (content is the agents'). One machinery note: cliclick resets the HID idle
clock, so back-to-back click.sh calls under ~2 s trip guard.sh's someone-at-the-machine stop —
space pointer acts ≥3 s (idle climbed 30→42 s clean, nobody at the machine).

**ONE FINDING (batch A, test hygiene — not a product defect):** the revert-1 runs left SEVEN
Variorum .ips (01:55:15–01:57:43, all io.lduarte.Variorum.debug, EXC_BREAKPOINT): under the
reverted old code, `TypedReturnKeyTests.aReturnInsideAFannedOneWordBlockPushesItDownToo`'s closure
Array-subscripts the store slots the old road never minted — red-on-old BY CRASH (host trap), not a
clean #expect. Fix owed (implementer): #require the count before indexing so the pin fails clean
when red; its clean red-on-old re-shows in the next stage window (one revert, one suite) — PENDING.

**SECOND FINDING from the window (the coordinator's catch, triaged together): the 01:55:15 .ips is
a DIFFERENT class — filed as VX-855 (Bug · Suspected · Castle & sync · High).** SIGSEGV in the
SQLCipher codec on a pool reader under `PurgeJanitor.collectRoots ← LocalPurge.sweep`, no test
frame on any thread; the host was the re-point re-run's (launched 01:54:59, its 18/2 pass recorded
~01:55:03, crash at +4.4 s = TEARDOWN after the pass). Suspected: the launch-time purge sweep's
in-flight reader races the pool/codec teardown. Not this run's regression (no purge/pool/
protection code in the diff); the coordinator hands VX-855 to vx-809 (VX-818's teardown
neighborhood). This run FILED: VX-855.

#### Batch D — THE FORK'S RULING (orchestrator, 2026-11-05 — build to this)

1. **P-828-7 edge clause: (a) CONFIRMED** — any edge row to a live block, whatever the edge's own
   tombstone. Two reasons, both the implementer's, adopted: the deletion cascade tombstones a dead
   block's edges, so a live-edges-only reading would make R-828-1's protection vacuous by
   construction; and (a) makes the sweep UNABLE to strand-and-purge a live released original
   through `joinStrandedOriginals` — the exact hazard class (b) opens. (c) adds complexity with no
   traced need.
2. **P-828-8 empty: (a) CONFIRMED** — zero-length only, the seam carve's own empty test: ONE
   app-wide meaning of "empty block", and whitespace is content she owns (U-19's precedent).
   PROVISIONAL stands; if real Trashes keep whitespace-only husks, that's her call later.
3. **P-828-9 block tags: (a) CONFIRMED** — not history. Her floor named savepoints, comments,
   takes, name, frame; R-828-1 added edges; tags are metadata whose application on an empty block
   protects nothing worth a refusal. PROVISIONAL stands.
4. **P-828-10 words: stand as drafted, PROVISIONAL** — sentence-case checked; her wording eye gets
   them at the handoff (a Wording follow-up is cheap).
5. **ids ∩ still-qualifying: CONFIRMED** — the act never deletes more than the confirm showed her;
   fewer is the race's honest answer, spoken as the drafted refusal.
6. **Count 0 ⇒ door not rendered: CONFIRMED** — P-2's letter and Empty Trash's own precedent.
7. **The pick belt: CONFIRMED.**
8. **VX-636 `model:` init parameter: YES** — internal, test-only injection with production behavior
   unchanged by default; it buys the geometry pin red-on-old, which outranks a walk-only verify.

Also confirmed with reasons, from the proposal's body: the candidate set is the Trash's own block
rows (unwindowed, un-narrowed by the kind picker — her "all"), inheriting the wing fence, the
stamp-aware intent fence and the CASCADE-VICTIM EXCLUSION — a block that died with its note is
never swept alone, so a note's whole-restore is never broken by this door; the in-transaction
predicate re-check; LocalPurge before the receipt; no ⌥⌘Z (the requestPurge posture), confirm
every time. Build D1–D5.
