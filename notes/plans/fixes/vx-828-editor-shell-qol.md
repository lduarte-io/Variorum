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
| 1 | VX-806 (M) | Return mid-word snaps instead of refusing (editor seam) | A | VERIFIED 2026-11-05 (suites 281/28 green, red-on-old by revert, walk all legs both voices; pin hygiene 99fd1dd58; clean red re-show DONE in the batch D window — fails at plain #expects, zero traps, zero new .ips) — PENDING: phone suites at the merge gate |
| 2 | VX-655 (L, rider) | list-exit Return: retraction lands inside the flight | A | VERIFIED 2026-11-05 (order pin red-on-old by revert 3, checklist walk clean, stale neighbor pin re-pointed 58e655834) |
| 3 | VX-824 (M) | ⌘digit contextual — wings from the keyboard (RULED: shape a) | B | VERIFIED 2026-11-05 (13 real-NSEvent pins green, R-B1 red-on-old; walk both voices — chained quick-entry presses, ⌘9 refusal verbatim, in-note stays the mode row) |
| 4 | VX-833 (M) | wing switch navigates to the wing's BOOKCASE; switcher right-aligned | B | VERIFIED 2026-11-05 (landing pins green, R-B2/R-B2b red-on-old; walk — chord lands both voices, the follow never lands; remaining door witnesses at the merge gate) |
| 5 | VX-844 (L) | wing indicator marquee (car-radio), never crossing the column line | B | VERIFIED 2026-11-05 (10 label pins incl. hosted geometry, R-B3/M-B4 red-on-old; the ticker SEEN ticking both voices, clipped at the line; seam/floor/fullscreen at the merge gate) |
| 6 | VX-823 (HIGH) | the Library remembers scroll + selection on return from a note | C | VERIFIED 2026-11-05 (windows 1+2: 38+3 suites green, R-C1..3 + R-C4b run — road pin hollow, recorded; the fix red-on-old by the CROSS-WINDOW LIVE PAIR; walk primary legs green both voices) — PENDING: the deferred walk legs at the merge gate |
| 7 | VX-800 (M) | Trash sweep door: delete forever every empty no-history block | D | VERIFIED 2026-11-05 (window vx-828-batchD: 18 suites/196 green incl. the 7 app pins; walk both voices — count honest, cancel, filter-proof, receipt, door gone at 0) — PENDING: phone suites at the merge gate |
| 8 | VX-636 (L, rider) | the "gone from the app" receipt draws over the bottom Trash row | D | VERIFIED 2026-11-05 (geometry pin green; red-on-old by revert R-D4 — both geometry #expects red on the overlay, restored green; the band verified in the walk, both voices) |
| 9 | VX-798 (M) | spellcheck: ⌘; / ⌘: chords + Edit ▸ Spelling and Grammar home | E | VERIFIED 2026-11-05 (SpellingDoorTests green, R-E1 red on all five surfaces; walk — ⌘; selects one-shot, the panel's Change lands through the input path under the identity oracle) |
| 10 | VX-838 (M, Bug) | Settings ▸ Tags names + follows the wing (RULED: R-828-2) | E | VERIFIED-BY-PINS 2026-11-05 (mounted follow pin green, R-E2 the true red-on-old; the LIVE Settings walk blocked by words-guard fail-closed ×3 — deferred to the merge gate) |
| 11 | VX-840 (L, rider) | Settings ▸ Tags: delete-every-unused-tag door | E | VERIFIED-BY-PINS 2026-11-05 (core 7 + app 7 pins green, M-E1..3 + R-E3 red as predicted; live sweep walk deferred to the merge gate — fixture husk-tag prepared, unused in Home) |

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

**Not done by this batch (first line, final):** NO app-suite RUN (the 9 new app pins and their
neighbours), NO red-on-old revert RUN for VX-636 (R-D4), NO walk, NO Debug launch — all stage-gated,
all the orchestrator's (listed exactly in the self-assessment). No canon or shared ledger touched
(drafts below); no `notes/QUESTIONS.md` edit (P-828-7…10 land at the merge moment). No `Sync/`,
custody or keychain file touched (the op lives in `Operations/`; `PurgeJanitor.anyFamilyEverSynced`
and `LocalPurge` are only CALLED, as every Trash purge door already calls them).

| Piece | What | Status |
|---|---|---|
| D0 | Preflight (the brief's reading list, read in full) + THE DESIGN FORK below | DONE (057d58114) — RULED (22a8da5d4, "Batch D — THE FORK'S RULING") |
| D1 | VX-800 core: the pure predicate (`Domain/EmptyBlockSweep.swift`) + the candidate/facts read and its named-region observation (`Queries/EmptyBlockSweepQueries.swift`) + exact-rows pins (`Tests/VariorumCoreTests/EmptyBlockSweepTests.swift`, 10) | DONE (cdb514168) — `swift test --filter EmptyBlockSweepTests` 10/10 green headless. Mutation probes M1–M3 ANNOUNCED here (this commit), each an UNCOMMITTED edit to the facts SQL in `Sources/VariorumCore/Queries/EmptyBlockSweepQueries.swift` on the committed tree, restored by `git checkout --` (git is the honest mid-probe state; no prerevert dir needed): M1 comments counted live-only (`AND bc.deleted_at IS NULL`) → expect `historyKeepsAnEmptyBlockOutAndMetadataDoesNot` red; M2 edges counted live-only (`AND e.deleted_at IS NULL`, both arms) → expect `aLinkToALivingBlockKeepsItOutAndALinkToADeadOneDoesNot` + `everyEdgeShapeIsReadByTheOtherSidesLifeAlone` red; M3 takes counted live-only (`AND v.deleted_at IS NULL` in `worded_takes`) → expect `theJunkShapeQualifiesAndAnyWordedTakeStaysOut` red. **RESULTS (all three red as predicted, each restored by `git checkout --`, `git status` clean, 10/10 green again):** M1 → `historyKeepsAnEmptyBlockOutAndMetadataDoesNot` red, 3 issues (and STRONGER than predicted: under a live-only count even the COMMENTED block qualifies — the block's own deletion cascade-tombstones its comments on its stamp, so live-only would sweep every commented block); M2 → both lineage pins red (the divide's half, tombstoned on its own stamp, and the version/ancestor/peer-stamp/archived shapes all read 0 living links); M3 → `theJunkShapeQualifies…` red AND both lineage pins red (the cascade tombstones every take of a deleted block, so a live-only take count would call EVERY trashed block empty — the worded source and "A dead block." both became sweepable). The any-row readings are load-bearing, not cautious. |
| D2 | VX-800 core: `Operations.sweepEmptyTrashBlocks(_:)` (`Operations+Purge.swift` — one write: the predicate re-read inside it over every wing, confirm ids ∩ still-qualifying, intents through `mintPurgeIntents`, empty answer = nothing written) + 5 transition pins in `EmptyBlockSweepTests` | DONE (this commit) — `EmptyBlockSweepTests` 15/15 green headless: one intent per taken block, no undo entry, rows leave the Trash at once, LocalPurge takes never-synced bytes and a Put back then meets `blockNotFound` (`theSweepMintsOneIntentPerTakenBlockAndTheBytesFollow`); a server-seen family keeps its bytes for the horizon (`aSyncedFamilyWaitsForTheHorizon`); put back / re-died as a cascade victim / worded by a sync-shaped write / already fenced / a newcomer — only the untouched confirmed block taken (`theActTakesOnlyWhatTheConfirmShowedThatStillQualifies`); nothing left writes nothing, not even an outbox row (`nothingLeftWritesNothing`); the sweep never takes a living block, with the CONTRAST that a direct purge of a block linked to two live released originals takes both originals' words (`theSweepNeverTakesALivingBlock` — the P-828-7 (a) rationale, pinned) |
| D3 | VX-800 app: `CapabilityID.deleteEmptyBlocks` + its registry entry (`.surface`, app scope, verb "Delete Empty Blocks"); `RecoveryView.surfaceCapabilities` gains it; the door in the Trash's controls row left of Empty Trash, drawn only while `emptyBlockIDs` is non-empty (`RecoveryView.showsDeleteEmptyBlocksDoor`), label "Delete N empty blocks…"; the model's own named-region observation (`startEmptyBlocks`, wing-keyed, never filter-narrowed); `TrashPurge.Confirm.deleteEmptyBlocks(ids)` through the ONE confirm host, `TrashPurge.confirmEmptyBlocks` (the op, then the local sweep before the receipt), `RecoveryRefusal.noEmptyBlocksLeft`; the pick belt (`dropFromPick`); the words in `RecoveryCopy` (P-828-10 drafts verbatim); app pins `App/Variorum/VariorumTests/TrashEmptyBlockSweepTests.swift` (7) | DONE (043b8420d) — Mac `build-for-testing` TEST BUILD SUCCEEDED, 0 errors, no warning in a touched file. The app pins' RUN is PENDING (the orchestrator's stage window). The phone target (`VariorumMobile`, generic iOS Simulator, compile only) BUILD SUCCEEDED over the Shared change, no warning in `RecoveryActs.swift` / `RecoveryCopy.swift` |
| D4 | VX-636: `RecoveryView.body` = the list + a laid-out message BAND below it (hairline + line, drawn only while something speaks; order: refusal → receipt → the seam's `QuietReceiptLine`) replacing the `.overlay(alignment: .bottom)` on the `List`; the pure `TrashMessageFoot.line(error:receipt:quietSpeaks:)`; the DEBUG frame oracle `TrashFootProbe` + `trashFootProbe(_:)`; the internal `model:` init seam (ruled); pins `App/Variorum/VariorumTests/TrashMessageBandTests.swift` (2) | DONE (9a251a8ea) — Mac `build-for-testing` TEST BUILD SUCCEEDED, no warning in a touched file. Run + red-on-old PENDING (the orchestrator's stage window; revert R-D4 named in the self-assessment) |
| D5 | Self-assessment + the record's closing sections + the end-of-batch headless suite | DONE (this commit) — full core `swift test` at 9a251a8ea: `VariorumCoreTests` 3670 tests / 493 suites PASSED (5 known issues; +15 / +1 over batch A's 3655/492 = `EmptyBlockSweepTests`; PinBeltTests rides inside, passed); `StringsWorkbookTests` 32/4 PASSED; the 7 known "dependency not used" warnings (14 lines — build + test print each); `VariorumMCPTests` 549/100 with 2 issues, both the MCP socket harness (`MCPStopRoadsServerTests` "claude-code got no answer to its initialize"; `MCPHarnessTimeLimitTests` the VX-685 bound) — re-run ALONE (`swift test --skip-build --filter "MCPStopRoadsServerTests\|MCPHarnessTimeLimitTests"`): 9 tests / 2 suites PASSED in 2.2 s. This batch touches no MCP code |

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

#### Batch D — IMPLEMENTER SELF-ASSESSMENT (Opus, 2026-11-05)

**Not done (first line, by the brief):** no app-suite RUN, no VX-636 red-on-old revert RUN, no walk,
no Debug launch — all stage-gated, all the orchestrator's (listed below with exact names). No canon,
QUESTIONS or other shared ledger touched (drafts below). No `Sync/`, custody or keychain file. Every
other piece is built, compiles on both targets, and its headless half is green.

**VX-800 — what was missing (an Improvement, no bug mechanism).** The Trash offered only per-row
Delete Now, the VX-671 pick and Empty Trash, so the junk the editor's own roads leave there — the
seam carve's empty blocks (`deleteBlock(requiring: .emptyWithNothingUnshown)`), abandoned
Return-chained empties — could only go one row at a time or with everything else. Built to the
fork's ruling (22a8da5d4), one pointer per piece:
- `Sources/VariorumCore/Domain/EmptyBlockSweep.swift` — R-828-1 as ONE pure rule over counted facts.
- `Sources/VariorumCore/Queries/EmptyBlockSweepQueries.swift` — `Queries.emptyTrashBlocks` (the
  candidate set = `Queries.trash`'s own block arm, unwindowed, unfiltered — so the window, the wing
  fence, the stamp-aware intent fence and the cascade-victim exclusion are inherited, never twinned),
  `Queries.emptyBlockSweepFacts` (each count's ruled row-level reading, one statement driven by the
  given ids), `Queries.emptyBlockSweepTables` + `AppDatabase.observeEmptyTrashBlocks` (named region —
  re-fetched on a reader, never on the writer).
- `Sources/VariorumCore/Operations/Operations+Purge.swift` — `sweepEmptyTrashBlocks(_:)`: one write;
  the predicate re-read inside it over every wing; confirm ids ∩ still-qualifying; intents through
  `mintPurgeIntents` (one implementation); an empty answer = nothing written; no undo entry.
- `App/Variorum/Shared/RecoveryActs.swift` — `TrashPurge.Confirm.deleteEmptyBlocks(ids)` (through the
  ONE confirm host), `TrashPurge.confirmEmptyBlocks` (the op, then `sweepLocalPurge` before the
  receipt — round 11), the three-population receipt bit read AFTER the op over exactly what it took,
  `RecoveryRefusal.noEmptyBlocksLeft`.
- `App/Variorum/Shared/RecoveryCopy.swift` — the P-828-10 words, verbatim as drafted.
- `App/Variorum/Variorum/Registry/Capability.swift` + `CapabilityRegistry.swift` — `.deleteEmptyBlocks`,
  `.surface`, app scope, verb "Delete Empty Blocks".
- `App/Variorum/Variorum/Features/Library/RecoveryView.swift` — the model (`emptyBlockIDs`,
  `startEmptyBlocks`, `adoptEmptyBlocks`, `requestDeleteEmptyBlocks`, the confirm branch, the pick belt
  `dropFromPick`); the view (`surfaceCapabilities` gains it, `showsDeleteEmptyBlocksDoor`, the
  count-labelled danger button left of Empty Trash, its wing-keyed `.task`).

**VX-636 — the mechanism, traced on this tree.** `RecoveryView.list` hung its message slot on the
`List` as `.overlay(alignment: .bottom)` (it was `RecoveryView.swift:975` before this batch): an
overlay draws on top of the list's OWN frame and claims no layout room, so whichever row sat at the
bottom of the viewport was written over — her VX-601 A2 sighting after Delete for Good. **The fix:**
`RecoveryView.body` is now `VStack(spacing: 0) { list; messageFoot }` — the line in its own band
LAID OUT below the list (a hairline, then the line, drawn only while something speaks: the Pool's
`PoolReceiptFoot` shape), its order ArchivedView's (`TrashMessageFoot.line`: this surface's refusal →
its receipt → the seam's `QuietReceiptLine`). The geometry oracle is DEBUG-only (`TrashFootProbe` /
`trashFootProbe(_:)`, the `BaselineProbe` idiom) and the test reaches the shipping view through the
ruled internal `model:` init parameter (production passes nothing).

**Pins — and exactly what makes each red (the orchestrator's revert window).**
| Pin (suite TYPE · test) | Red on old because | Behavioral revert that shows it |
|---|---|---|
| `EmptyBlockSweepTests` (core, 15) | new feature — compile-red on old; their STRENGTH was shown by mutation probes M1–M3 on the new SQL (all red as predicted, D1's row) | — (ran green headless; M1–M3 done) |
| `TrashEmptyBlockSweepTests` (app, 7) | new feature — compile-red on old (no `.deleteEmptyBlocks`, no door, no `emptyBlockIDs`) | — (run PENDING) |
| `TrashMessageBandTests` · `theReceiptSpeaksInItsOwnBandNeverOverTheRows` | the overlay sits INSIDE the list's frame (`foot.minY < list.maxY`) and the list never gives up height (`list.height == idle.height`) | **R-D4:** in `RecoveryView.swift` replace `body`'s `VStack(spacing: 0) { list; messageFoot }.background(tokens.room)` with `list.overlay(alignment: .bottom) { messageFoot }` (keep the trailing `.coordinateSpace(name: TrashMessageFoot.space)`) → expect exactly the two geometry `#expect`s red; the idle "no band" and premise lines stay green. Restore by `git checkout --`, rebuild, re-run green |
| `TrashMessageBandTests` · `theBandSaysTheRefusalThenTheReceiptThenTheSeamElseNothing` | GREEN ON BOTH SIDES for its refusal/receipt order (the old inline overlay kept it); the `.quiet` arm is new | — (guard) |

**PENDING (the orchestrator's stage window).**
1. Mac suites, by TYPE (a zsh array): `TrashEmptyBlockSweepTests` · `TrashMessageBandTests` — and
   the neighbours the diff reaches: `TrashMultiSelectTests` · `TrashFirstPaintTests` ·
   `TrashPurgeDoorsTests` · `TrashConfirmEdgeTests` · `TrashPurgeSharedLayerTests` ·
   `TrashSurfaceTests` · `TrashPoolHonestyTests` · `SnippetGroupTrashTests` · `IAAndTrashShapeTests` ·
   `RecoveryDoorsTests` · `CapabilityRegistryTests` · `ShellChromeTests` · `ChromeLineLimitTests`
   (and `TutorialWalkTests` if the window allows — it touches the Trash's surface capabilities).
2. Revert R-D4 (above), one suite, then restore.
3. The phone suites at the merge gate (Shared changed): `MobileTrashTests` · `MobileNoteTrayTests` ·
   `MobileVersionsTests` (the confirm gained an arm the phone never raises).
4. The walk (dev store, both voices): mint empty blocks (a Return chain, then backspace-carve them or
   Delete Block them), a worded block, an empty block with a comment, a divide's emptied half (linked
   to its living source); open the Trash — the door reads "Delete N empty blocks…" with N = only the
   true empties; Cancel; confirm — the receipt speaks in the BAND below the rows with enough rows to
   fill the viewport (VX-636: never over the last row); the door disappears at 0; the commented / linked
   / worded blocks stay; a kind filter (Notes) does not hide or narrow the door.

**PROVISIONAL (QUESTIONS entries at the merge moment).** P-828-7 (a), P-828-8 (a), P-828-9 (a) — built
as ruled, "PROVISIONAL stands" on -8/-9 per the ruling; P-828-10 the words, verbatim as drafted.

**For the orchestrator's canon pass (DRAFTED — not applied; the two-file rule).**
- SurfaceContracts, "The Bookcase and books" Delete bullet — after the multi-select sentence, ADD:
  "Delete N empty blocks… takes every Trash block row that is empty with no history — no take with
  words, no savepoint, no comment row, no name, no callout, no link to a living block — drawn only
  while it would take one, confirmed every time with the count, purge intents only, no ⌥⌘Z; the
  Trash's messages speak in their own band below the rows (VX-800, VX-636, R-828-1,
  `notes/plans/fixes/vx-828-editor-shell-qol.md`)."
- AppSpec §9 "Deletion, restoration, the tray" — ADD the op line: "**sweepEmptyTrashBlocks(blockIDs)**
  — the Trash's empty-block sweep: in one transaction it re-reads R-828-1's predicate over the
  Trash's own block rows (never a cascade victim; the window and the intent fence) and mints one
  purge intent per given block that still qualifies — never more than the confirm named; nothing
  left writes nothing; no undo entry (VX-800)."
- AppSpecRecord: the dated entry + the narrative under §9 (purge) and §12 (the Trash).
- MOBILE PARITY: nothing mobile-visible (the phone's Trash draws no sweep door; the Shared confirm
  case compiles into it unreached) — a VM twin is a candidate ticket, the orchestrator's call.

**Self-assessment.** CONFIDENT: the predicate's row-level readings (exact rows on every shape incl.
hand-built edges; M1–M3 prove each any-row reading load-bearing — live-only readings would sweep
commented, linked and even WORDED trashed blocks, because the deletion cascade tombstones a block's
takes, comments and edges on its own stamp); the act's safety (the in-transaction re-check, the
stale-pause shapes, nothing-left writes nothing, and the living-original contrast pin showing what
the edge clause forecloses); the VX-636 mechanism (an overlay claims no layout room — read in the
code, not inferred). FLAGS FOR THE COLD REVIEWER: (a) the open Trash now holds a THIRD observation
(the sweep's count) on a named region that includes `variant` — it re-fetches on a reader at
autosave rate while the Trash is open, ∝ the Trash's block rows (the listing's own posture);
(b) the act re-reads over EVERY wing and intersects with the confirm's ids (wing-scoped at ask
time) — a wing switch inside the confirm cannot widen it; (c) the receipt's population bit is read
AFTER the op (argued in `deleteEmptyBlocks`' doc: the intent write moves no seq rows and the local
sweep has not run; a never-synced family an hourly sweep took in between reads never-synced, which
it was); (d) the band's `.quiet` arm is new behavior — a seam receipt now speaks in the Trash
instead of nowhere (the stated D0 shape, unredirected by the ruling); the band appears and
disappears with the message (no reserved line — the Pool's rule), so the list's bottom edge moves
by one line when a message speaks; (e) a stale bulk Put back of a swept block on a SYNCED install
(intent standing, bytes waiting) would still revive it through `restoreBlock`'s void-the-intent belt
— the pick belt closes that road on this device; a peer's earlier Put back is 13j B1's staleness rule,
unchanged; (f) no ⌥⌘Z, by the ruling.

**Files touched (the whole batch):** `Sources/VariorumCore/Domain/EmptyBlockSweep.swift` (new) ·
`Sources/VariorumCore/Queries/EmptyBlockSweepQueries.swift` (new) ·
`Sources/VariorumCore/Operations/Operations+Purge.swift` ·
`Tests/VariorumCoreTests/EmptyBlockSweepTests.swift` (new) · `App/Variorum/Shared/RecoveryActs.swift` ·
`App/Variorum/Shared/RecoveryCopy.swift` · `App/Variorum/Variorum/Registry/Capability.swift` ·
`App/Variorum/Variorum/Registry/CapabilityRegistry.swift` ·
`App/Variorum/Variorum/Features/Library/RecoveryView.swift` ·
`App/Variorum/VariorumTests/TrashEmptyBlockSweepTests.swift` (new) ·
`App/Variorum/VariorumTests/TrashMessageBandTests.swift` (new) · this record.

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

#### Batch C — LIVE STATUS (implementer: Opus, fresh session, 2026-11-05)

**Not done (first line, final):** NO app-suite RUN (the 25 new app pins and their Library
neighbours), NO behavioural revert run (R-C1 · R-C2 · R-C3), NO walk, NO Debug launch — all
stage-gated, all the orchestrator's (listed exactly in the self-assessment). No canon / QUESTIONS /
shared-ledger edit (drafts below). No `Shared/`, no `Sync/`, custody or keychain file; no core
(`Sources/`) file. P-828-5's book courtesy NOT built (ruled, VX-856).

| Piece | What | Status |
|---|---|---|
| C0 | Preflight (the brief's list, read in this session's own context: the run record's named sections, SurfaceContracts "The Library" whole + "The app" incl. the Open-list follow line, `phase-18l-navigation-feel.md` (kickoff, R-18l-1/2, the U0c brief + RECORD whole), TEXTKIT2_NOTES' 18l-c U8 HARNESS fact and its neighbours, the Library feature folder's catalog files, `SidebarSectionWindow.swift` (the follow idiom), Takes' `ArticlePlace`/`ArticleRestore` docs) + THE TRACE + THE DESIGN FORK | DONE (cd50d6ed7) — RULED (bae4324aa, "Batch C — THE FORK'S RULING") |
| C1 | The place: a pure resolver (the remembered on-screen rows + neighbourhood → the landing row and its `into` in the CURRENT listing) + exact pins | DONE (this commit) — `Features/Library/LibraryPlace.swift` (capture · resolve · `anchorY` · `isSettled` · `depth` · the `Order` lookups · `Surface`) + `VariorumTests/LibraryPlaceTests.swift` (11 pure pins). Mac `build-for-testing` TEST BUILD SUCCEEDED (`App/Variorum/DerivedData/vx828c-bft1.log`); the RUN is PENDING (app-hosted — the orchestrator's window) |
| C2 | The model: remember on leave · restore on mount (the in-place re-ask to the place's depth) · a new question / wing drops it · the return mark (per Q2's ruling) + model pins | DONE (this commit) — `Features/Library/LibraryCatalogPlace.swift` (NEW: `LibraryPlaceMemory` — per-pane places, marks, the views' reports, the re-ask token; the model's `placeOrder` · `notePlace` · `rowOpened` · `listingAppeared` · `placeLanding` · `owesReturn`); `LibraryCatalogModel.swift` (`placeMemory`; `search()` = `questionChanged()` + the new `startOver()`; `reread(noteDepth:groupDepth:)`; the mark's clear roads in `clickNoteRow` / `selectBook` / `modeChanged` — a mode switch also drops the places, see the self-assessment); `LibraryPlace.swift` (+ `Surface.isSameKind`, the remembered surface); `VariorumTests/LibraryReturnPlaceTests.swift` (9 model pins). `build-for-testing` TEST BUILD SUCCEEDED (`DerivedData/vx828c-bft3.log`, no warning in a touched file); the RUN is PENDING |
| C3 | The view: the rows' content-space reports + the scroll memory on the three scroll views (List column · Cards · the answer sheet) + the unbound landing and its hold; mounted pins (red on old: the remount lands at the top) | DONE (this commit) — `Features/Library/LibraryPlaceScroll.swift` (NEW: `libraryPlaceScroll` — the window by reference, the rest watch, the unbound `ScrollViewReader` landing + its hold; `libraryPlaceRow` — the content-space frame); `LibraryCatalogView.swift` (`placeKey`; the mount's `.task` → `listingAppeared`; every row-open door → `rowOpened`; `isSubject` = the panel's subject OR the mark; the List column and the Cards named + tracked); `LibraryBooksRegion.swift` (`LibraryPagedNotes.placeKey` + the rows' reports); `LibrarySearchSheet.swift` (`placeKey`, the groups' and books' reports, the sheet tracked); `RootView.swift` (`placeKey: pane.raw` — one line); `VariorumTests/LibraryReturnPlaceMountTests.swift` (5 mounted pins, compile on the pre-fix tree — their red-on-old is runnable as-is). `build-for-testing` TEST BUILD SUCCEEDED (`DerivedData/vx828c-bft3.log`). Window part 1: 3 mounted pins RED ON NEW — all three FIXTURE (a stale oracle row; raw offsets compared across lazy mounts; a region frame the sheet never publishes), traced and fixed in the pins only (00569c8ce — "THREE MOUNTED PINS RED ON THE NEW TREE" below); the re-run PENDING (the window) |
| C4 | Self-assessment, the end-of-batch core `swift test`, the app `build-for-testing` | DONE (this commit) — core `swift test` at 27bfde19e: `VariorumCoreTests` 3670 tests / 493 suites PASSED (5 known issues — batch D's count, unchanged: this batch touches no core file; PinBeltTests rides inside); `StringsWorkbookTests` 32/4 PASSED; the 7 known "not used by any target" warnings (14 lines, build + test); `VariorumMCPTests` 549/100 with 3 issues, all the MCP SOCKET-HARNESS class batch D met (`MCPDiscoverProbeServerTests`, `MCPPreInitializeWindowTests`, `MCPHarnessTimeLimitTests` — the VX-685 bound) — re-run ALONE (`swift test --skip-build --filter …`): 16 tests / 3 suites PASSED in 2.3 s. This batch touches no MCP code. App `build-for-testing` TEST BUILD SUCCEEDED (`DerivedData/vx828c-bft3.log`) |
| C5 | THE WALK'S RED (window 1 — the live return lands at the top): the mechanism (the landing waited for a scroll READING that never comes when a short listing is swapped into an already-sized pane), the fix (land on proxy + the scroll view's own height; the surface said at appear; the hold re-aims until a reading confirms; a teardown-proof liveness guard; the DEBUG `LibraryPlaceTrace`), the ROAD PIN through the real `RootView` (+ its `catalog:` init seam) | DONE (this commit) — `build-for-testing` TEST BUILD SUCCEEDED (`DerivedData/vx828c-bft5.log`, no warning in a touched file); the road pin's RUN, its revert R-C4 and the re-walk are PENDING (the next window) — see "Batch C — THE WALK'S RED" |

#### Batch C — THE TRACE (why the Library forgets — an Improvement, no bug mechanism; read at the code)

1. **The MODEL survives the trip.** The catalog model is `RootView`'s `@State catalog`
   (`RootView.swift:43`, built at `:208`) — one per window — so the question (query, scope, mode,
   sort, the armed day, the facets) and the listed rows ALREADY outlive a note round trip: search
   state and the day filter ride along today.
2. **The VIEW does not.** Any open swaps `paneDetail`'s `.library` arm (`RootView.swift:1393`) for the
   `.post` arm, so `LibraryCatalogView` and its scroll views — the List column
   (`LibraryCatalogView.swift:908`), Cards (`:1135`), the answer sheet (`LibrarySearchSheet.swift:43`)
   — are torn down with their offsets; the return mounts a fresh one at offset 0.
3. **The mount re-asks from the top.** `.task(id: session.wing.currentID) { await model.search() }`
   (`LibraryCatalogView.swift:313`) → `read(startingOver: true)` (`LibraryCatalogModel.swift:641`)
   → the FIRST page only (80 notes), `visibleNoteIndices` reset (`:737`): a row she opened past the
   first page is not even listed on return.
4. **The selection is cleared on the way out.** `openHit` → `model.closeInfo()`
   (`LibraryCatalogView.swift:505–506`; Act 10's "navigation … clears it"). The card tap (`:1242`) and
   the row menu's Open (`:1332`) do not — the roads already disagree.

No single line is wrong; the Library has no place memory. The pins are therefore new-behaviour pins
whose red-on-old is behavioural (the old tree's remount lands at the top / the row unlisted), never a
bug revert.

#### Batch C — DESIGN FORK (C0 — what "the same place" and "selected" mean; proposed for the orchestrator's ruling BEFORE any build)

**The mechanism I propose (architectural, mine — stated so the questions have a frame):**
- **The place is the rows on screen, never a pixel.** The Write/Takes precedent (U0b's
  `ReadingAnchor`, Takes' `ArticlePlace`): the rows the viewport showed, in order, each with how far
  its top sat below the viewport's top (`into`), plus a bounded neighbourhood of ids just above and
  below them in the listed order (the fallback's material). Read from each row's frame in its
  column's CONTENT space (it moves only when layout above it moves — never per scroll frame) and the
  scroll window (`onScrollGeometryChange`, held by reference — the Open list's `SidebarSectionWindow`
  idiom: a scroll re-renders nothing). Computed when her scroll RESTS (one coalesced task per
  burst) and synchronously at a row's open act — never during teardown (whose `onDisappear` order is
  not ours to assume).
- **The landing is UNBOUND:** a one-shot `ScrollViewReader` `scrollTo(id, anchor: UnitPoint(y:
  into / (viewport − rowHeight)))`, unanimated (the Open list's road; Takes measured the proxy
  honouring this arithmetic, negative `into` included), then a short HOLD that re-aims while the lazy
  column settles and ends at her hand (`onScrollPhaseChange` interacting/decelerating — the sidebar's
  measured rule) or a budget. **This is how the 18l-c U8 trap is designed around:** no
  `.scrollPosition` binding exists anywhere in the Library, so nothing re-applies a stale target over
  her hand, and the pins can still stage a scroll through `NSClipView` (the
  `LibraryInfiniteScrollTests` road keeps working — the trap bites only BOUND scroll views).
- **The landing reads nothing; the re-ask stays honest.** The return lands at once on the rows the
  model still holds (no read before the first paint, so no top-then-jump). While a place is
  remembered, the mount's `search()` becomes the existing IN-PLACE re-ask (`read(startingOver:
  false)`) to the place's depth; when it lands, the place re-resolves by id and the hold re-aims. Any
  new question (`search()` — the field, scope, sort, day, a facet, ⌘K's Library road) or a wing
  switch drops the place: today's top-of-list start.

**Q1 — WHAT THE PLACE ANCHORS ON** (product-visible: the brief's letter vs the commonest flow)
- (a) The OPENED row, re-resolved by id in the current sort (the brief's letter). Consequence: under
  the default sort (`edited · newest first`) any keystroke inside the note makes it the newest, so the
  return lands at the TOP of the Library with that row selected — her reported symptom, in the
  commonest flow (open, type, come back).
- (b) **The viewport's own rows** (the reading-anchor precedent), each re-resolved by id in the
  current sort; the opened row is NOT an anchor while any other on-screen row survives (its move is
  her own act's consequence, not a change of where she was). Fallback order: the next surviving
  on-screen row at ITS former `into` → the nearest surviving id of the remembered neighbourhood → the
  top. Never a corpus search.
- (c) (a) while the opened row stays within a screen of its old place, else (b) — two rules for one
  question.

**Proposal: (b)** — still "an id re-resolved into the current sort, never a pixel offset"; the
brief's own fallback ("land where the row would have been — nearest surviving neighbour")
generalised from a row that LEFT the listing to a row that left its PLACE. PROVISIONAL P-828-11.

**Q2 — WHAT "SELECTED" MEANS ON RETURN** (product-visible: the Library has ONE selection today — the
info panel's subject, `infoHit`, drawn as the panel + the row's subject border, which "navigation
clears")
- (a) The panel: the opened row becomes `infoHit` and the panel slides in on every return. Costs: the
  list narrows by the panel's column and, at the 1270-pt default, the controls row wraps to two lines
  (SurfaceContracts "The Library") — the viewport she returns to is not the one she left; reverses
  "navigation clears it" for this road.
- (b) **A return MARK: the opened row wears the existing SUBJECT face (`rowBackground(subject:)` — the
  wash and the fuller border), no panel**, until her next row click, a new question, a mode switch or
  her next open (which replaces it). No layout change; no new face — an existing face at a new
  moment; "navigation clears the panel" untouched.
- (c) Nothing new: whatever selection stood when she left (the panel's subject, the ⌘-pick) is what
  she finds; a title-click open of an unselected row returns unmarked.

**Proposal: (b)**, PROVISIONAL P-828-12.

**Q3 — WHICH LEAVES REMEMBER, WHICH RETURNS RESTORE** (product-visible)
- (a) Only a row's own open records the place, restored on the next return.
- (b) **Every leave of the Library surface records it** (a row's open, the sidebar, ⌘K, ⌥⌘[, the
  quick entry's new note) **and every return this session restores it while the question is
  unchanged** — R-18l-1's in-session shape (the session's first visit starts at the top; a re-visit
  restores), door-agnostic; the ticket's own title is "The Library forgets where you were". A new
  question or a wing switch starts at the top (today's). The MARK (Q2) is made only by a row's open.

**Proposal: (b)**, PROVISIONAL P-828-13.

**Q4 — CARDS' "SELECTED"** (product-visible): Cards draw no selection in any state today (entering
Cards clears it; a card tap opens). (a) **The place only — no mark on a card**; (b) a new card wash.
**Proposal: (a)**, PROVISIONAL P-828-14.

**Q5 — P1's reading** (the orchestrator's constraint): the LANDING reads nothing. The honest re-ask
that replaces the mount's first-page read is the in-place re-ask to the place's depth — the deepest
remembered row's listed position + one page (80) — ∝ how far down her place was, ONE statement off
the main thread, never the corpus and never a page-until-found loop (a row that cannot be found
falls back by Q1's order). That is the class `refresh()` already runs after every row act (∝ what is
listed). A read truly ∝ the viewport needs a WINDOWED listing (rows starting mid-corpus, paging
upward as she scrolls back) — a new paging subsystem with its own scroll-compensation risk, not this
batch. **Proposal: accept "∝ the place's depth"** (stated in the record and the canon draft); if the
orchestrator holds the letter, the windowed listing is its own ticket and this batch restores only
places inside the first page.

**Stated, not asked (scope, mine):** the Timeline is excluded (its own view, its own listing); the
CAPPED books region (All + many books — its own native `List`) keeps its own scroll at its top and
its rows are not anchors; the answer sheet's place is its groups (a note group's id is the note's)
with its open "all N ›" groups re-read in place as today; a split's two Library panes share the
window's one catalog model (one memory per window; two windows, two memories); nothing persisted,
nothing synced.

**Pins planned (to the brief's acceptance line):** pure resolver pins (unchanged listing → the same
row and `into`; the top row deleted / filtered away → the next surviving on-screen row at its own
`into`; every on-screen row gone → the nearest surviving neighbour; nothing → the top; the opened row
moved to the top under the edited sort → the place holds (Q1-b)); model pins (a remembered place
makes the mount's read in place and bounded — the listed count ≤ the place's depth + one page; a new
question / sort / day / wing drops it; the mark's set and clear roads); mounted pins over the whole
catalog (scroll the List / Cards / the answer sheet / a day's answer by `NSClipView`, unmount,
re-mount on the same model → the anchor row's frame back at its `into` within a point — red on the
old tree, whose remount lands at the top).

**P-828-5 — the book Index/Outline courtesy: ASSESSED, NOT CHEAP — recommend a ticket.** (1) A
second surface with its own landing family: the ascent (`ShellRouter.pendingBookAscent` →
`BookViewModel.requestReveal`), VX-630/680's carries, VX-662/663/681's arrivals, VX-624's floor, the
Outline follower's freeze on programmatic landings (VX-562/646) — any change there re-walks four
modes. (2) The cheap road (park the existing ascent at the note last opened from the book on every
plain return) lands that note's card at the page TOP, not where she was, and changes what EVERY
return to a book opens to this session (the Bookcase row, the sidebar, ⌥⌘[) — itself a product
call. (3) The honest version is the book's own place memory (this batch's mechanism over the
Outline's and Index's columns), sized as its own unit. Proposed ticket: *"A book's Outline and Index
remember where you were on return from a note (VX-823's courtesy)"* — Improvement · Books.

#### Batch C — IMPLEMENTER SELF-ASSESSMENT (Opus, 2026-11-05)

**Not done (first line, by the brief):** no app-suite RUN, no revert RUN, no walk, no Debug launch —
all stage-gated, all the orchestrator's (named exactly below). No canon, QUESTIONS or other shared
ledger touched (drafts below). No `Shared/` file (no phone suites owed by this batch), no `Sync/`,
custody, keychain or core file. VX-856 (the book courtesy) not built, as ruled.

**VX-823 — the mechanism as traced (an Improvement, no bug class; C0's TRACE above):** the catalog
MODEL is `RootView`'s `@State` and outlives a note round trip (the question and the listed rows
survive); the catalog VIEW is replaced by the `.post` arm, so its scroll views and their offsets
die; the remount's `.task` asked a NEW question (`search()` → the first page, 80 rows,
`visibleNoteIndices` reset) at offset 0; `openHit` cleared the panel on the way out.

**The fix as built, to the ruling (bae4324aa) — one pointer per piece:**
- `Features/Library/LibraryPlace.swift` (NEW, pure) — the place = the ON-SCREEN rows (id + `into` +
  height) and a 12-each-side neighbourhood over the surface's drawn `Order` (two lookups, never a
  copy); `resolve` = P-828-11's chain (the first surviving on-screen row that is not the opened one,
  else the opened one, else the nearest surviving neighbour — below first at a tie — where the rows
  began, else nil = the top); `anchorY` (Takes' measured proxy arithmetic); `isSettled` (½ pt, or
  as close as the scroll's ends allow); `depth` (Q5: reach + 1 + one page); `Surface` (+ which draw a
  selection, + `isSameKind`).
- `Features/Library/LibraryCatalogPlace.swift` (NEW) — `LibraryPlaceMemory` (per pane: the place, the
  views' window/surface/row frames, the observed marks and the re-ask token; `questionChanged()`
  drops every place and mark) and the model's acts: `placeOrder`, `notePlace` (capture + the note and
  group reach), `rowOpened` (the place with its opened row + the mark where the surface draws a
  selection), `listingAppeared` (a place in this wing → `reread` to its depth, then the token; the
  wing moved → `search()`; else `startOver()` — not a new question, so another pane's place
  survives), `placeLanding`, `owesReturn`.
- `Features/Library/LibraryCatalogModel.swift` — `placeMemory`; `search()` = `questionChanged()` +
  `startOver()` (what `search()` read before, byte-identical); `reread(noteDepth:groupDepth:)` (the
  in-place road with the place's depth); the mark's clear roads: `clickNoteRow`, `selectBook`,
  `modeChanged` (which also drops the places — flag (a)).
- `Features/Library/LibraryPlaceScroll.swift` (NEW, view) — `libraryPlaceRow` (a row's frame in its
  column's CONTENT space — written on appear and on a layout shift above it, never per scroll frame;
  dropped on disappear); `libraryPlaceScroll` (the window by reference, `SidebarSectionWindow`'s
  posture; the rest watch — 150 ms of stillness notes the place; the return: decided once per mount,
  landed on this mount's first measured reading by ONE unanimated `ScrollViewReader.scrollTo(id,
  anchor:)`, then held — re-checked at 40/120/300/650 ms and on any viewport/content change, re-aimed
  only while off its place, ≤ 12 aims; re-resolved when the re-ask's token lands; ended at once by her
  hand phase, else when the checks are done and no re-ask is in flight).
- `Features/Library/LibraryCatalogView.swift` — `placeKey` (default `PaneID.primary.raw`); the
  mount's `.task(id: wing)` → `listingAppeared`; every row-open door → `rowOpened` (`openHit` — the
  title, the double-click, the panel's Open, book rows; the card tap; the row menu's Open; a
  passage; a scraps head and a tag's block line with `marks: false`); `isSubject` (the panel's subject
  OR this pane's mark) on every List-faced row background, the capped books region's included; the
  List column (`.list(includesBooks:)`) and the Cards (`.cards`) named and tracked.
- `Features/Library/LibraryBooksRegion.swift` — `LibraryPagedNotes.placeKey` + the rows' reports.
- `Features/Library/LibrarySearchSheet.swift` — `placeKey`; the groups' (id = the home's) and the
  Books section's reports; the sheet tracked (`.sheet`).
- `RootView.swift` — `placeKey: pane.raw` on the `.library` arm (one line + a comment).

**How the 18l-c U8 trap is designed around (the brief's ask):** the landing is UNBOUND — a one-shot
proxy `scrollTo`, no `.scrollPosition` / `ScrollPosition` binding anywhere in the Library — so (1)
nothing re-applies a stale target over her hand on a relayout (the trap's production face; the hold
is bounded and her hand phase ends it), and (2) a pin may stage "her scroll" through `NSClipView`
(the `LibraryInfiniteScrollTests` / `VX349ListHeaderRestTests` road — the latter's floating-header
guard already proves `onScrollGeometryChange` fires on a clip scroll in the test host). The model
pins stage the scroll through its owning door (`placeMemory.noteWindow` / `noteFrame`) instead.

**Per pane (the ruling's amendment) — REACHED:** every memory value is keyed by `PaneID.raw`, handed
down by `RootView`'s one `.library` arm (trivially reachable, so preferred as ruled). What stays
SHARED is the listing itself (the window's one catalog model): two Library panes share the question
and its rows, so pane 2's restore re-ask also re-reads pane 1's rows in place (harmless — in place),
and a pane mounting with no place reads the first page (`startOver`) without dropping the other's
place (`eachPaneKeepsItsOwnPlace`).

**Pins — and exactly what makes each red (the orchestrator's revert window).** Each revert is an
UNCOMMITTED edit on the committed tree (27bfde19e or later), restored by `git checkout --` (git is the
honest mid-revert state; no prerevert dir needed — nothing uncommitted rides the tree):
| Pin (suite TYPE · tests) | Red on old because | Behavioural revert that shows it |
|---|---|---|
| `LibraryPlaceTests` (11, pure) | new — compile-red on old; strength = exact values | **R-C1:** in `LibraryPlace.resolve` replace `survivors.first(where: { $0.id != place.openedID }) ?? survivors.first` with `survivors.first` → expect `theOpenedRowIsNotTheAnchorWhileAnotherOnScreenRowSurvives` red (n5 at −15 where n6 at 15 is owed); every other pure pin green |
| `LibraryReturnPlaceTests` (9, model) | the pre-fix mount asked a NEW question from the top: 80 rows, no place, no landing | **R-C2:** make `LibraryCatalogModel.listingAppeared`'s body `await search()` alone → expect red: `aReturnReasksInPlaceToThePlacesDepthAndLandsWhereSheWas` (80 ≠ 249; landing nil; token 0), `theOpenedRowsOwnMoveDoesNotMoveThePlace` (landing nil), `aDeletedOnScreenRowFallsToTheNextSurvivor` (nil), `theSearchRidesAlongAndTheSheetComesBackWhereSheWas` (25 groups ≠ 74; nil), `theDayRidesAlongAndItsAnswerComesBackWhereSheWas` (nil), `eachPaneKeepsItsOwnPlace` (the third pane's `search()` drops both places); GREEN: `aNewQuestionDropsThePlaceAndTheMark`, `aWingSwitchDropsThePlace`, `theMarkGoes…` (no return in them). **R-C1 also reds** `theOpenedRowsOwnMoveDoesNotMoveThePlace` (the landing names the moved row) |
| `LibraryReturnPlaceMountTests` (5, mounted) | uses NOTHING the pre-fix tree lacks — runnable as-is on it: the remount lands at offset 0 with the first page alone listed | **R-C3:** in `LibraryPlaceScroll.decide()` set `memory.landingOwed = false` (no return landing; the model's re-ask unchanged) → expect the four return pins red (the List / the Cards / the sheet / the day's answer back at their top: the row off its place or unlisted on screen); GREEN: `aNewQuestionAskedWhileAwayStartsAtTheTop` (a guard, green on both trees) |

**PENDING (the orchestrator's stage window).**
1. Mac suites, by TYPE (a zsh array): the new `LibraryPlaceTests` · `LibraryReturnPlaceTests` ·
   `LibraryReturnPlaceMountTests`; the neighbours the diff reaches (every suite naming the catalog's
   view/model/sheet/paged rows): `LibraryInfiniteScrollTests` · `LibraryPagingModelTests` ·
   `LibraryPanelHostTests` · `LibraryPreviewBrainTests` · `LibraryListFaceTests` ·
   `LibraryListFaceRigTests` · `VX349ListHeaderRestTests` · `LibraryRowClickTests` ·
   `RowClickTimingTests` · `NoteRowRoutingTests` · `NoteRowSelectionRuleTests` ·
   `LibrarySearchWiringTests` · `LibrarySearchLandingTests` · `LibrarySearchStateTests` ·
   `LibrarySearchJoinTests` · `LibrarySearchArchivedTests` · `LibrarySearchCommitsFacetTests` ·
   `LibraryTagListingTests` · `LibraryDayFilterTests` · `LibraryViewScopeSwitchTests` ·
   `LibraryCardStampsTests` · `LibraryCardsWordTests` · `LibraryControlsGeometryTests` ·
   `VX350NarrowLibraryTests` · `VX350SearchToggleMountTests` · `VX384LibraryFollowsMintsTests` ·
   `VX176LibraryTintTests` · `DebugOracleSingletonWindowTests` · `MCPSharedIconClickTests` ·
   `MCPSharedRowsTests` · `BookRowMenuTests` · `NoteDeletionNavigateAwayTests` ·
   `TutorialCurrencyTests` · `CapabilityRegistryTests` · `ShellChromeTests` (RootView touched).
2. Reverts R-C1, R-C2, R-C3 (above), each one suite, then restore.
3. The walk (dev store, both voices; a Library of a few hundred notes — the dev store's sample books
   suffice or mint a scratch run): **List** — scroll deep, open a row by its title, type a word, ⌥⌘[
   back: the same rows where they were, the opened note at the TOP of the edited sort wearing the
   subject face (no panel), the controls row's line count unchanged; open a row by double-click and by
   the row menu's Open — the same; leave by the SIDEBAR (Bookcase) and come back — the place, no mark;
   a body click anywhere ends the mark. **Cards** — the same round trip: the place, no mark. **A search
   live** — scroll the answer sheet, open a passage, come back: the sheet where it was, the words in
   the field, the group's head marked. **The day filter** — armed, the round trip lands the day's
   answer where it was, the day still armed. **A new question** (type in the field, a sort pick, a wing
   switch, a mode switch) — the top. **A row deleted** (delete the opened note from its own note ▾,
   come back) — the next row where it sat. **A split** with the Library in both panes (if cheap) — each
   pane its own place.

**PROVISIONAL (QUESTIONS entries at the merge moment).** P-828-11 (b) · P-828-12 (b) · P-828-13 (b) ·
P-828-14 (a) — built as ruled. Within them, mine (flags (a), (c)–(e) below are the reviewer's):
the 150-ms rest; the 12-each-side neighbourhood; a neighbour above lands with its foot where the rows
began (the lead row's height standing in for its own); the hold's timings and 12-aim budget.

**For the orchestrator's canon pass (DRAFTED — not applied; the two-file rule).**
- SurfaceContracts, "The Library" — ADD a bullet: "**The Library remembers where you were.** Every
  leave of a Library pane notes its place — the rows on screen, each by id with where it sat — and
  every return this session, while the question (the field, scope, sort, the day, the facets) and the
  wing are unchanged, lands those rows where they sat, re-resolved in the current listing: the row she
  opened is not the anchor while another on-screen row survives; a row gone since falls to the next
  on-screen survivor, then its nearest neighbour, then the top. The row she opened from wears the
  subject face with no panel until her next row click, a new question, a mode switch or her next open;
  the Cards keep the place only. The landing reads nothing; the return re-asks in place to the place's
  depth (its deepest remembered row plus one page). A new question, a wing switch or a mode switch
  starts at the top. Per pane, in memory only; the Timeline and the capped books region keep their own
  top (VX-823, P-828-11…14, `notes/plans/fixes/vx-828-editor-shell-qol.md`)."
- AppSpec §12 "The Library" — after "…the controls row that never changes its line count as the author
  types, sorts or searches." ADD: "A return within the session lands where she left it (VX-823)."
- AppSpecRecord: the dated entry + the narrative under §12 (The Library) — her ask verbatim, the fork
  and its ruling, Q5's P1 reading.
- MOBILE PARITY: nothing mobile-visible (no `Shared/` change; the phone's Library is its own) — a VM
  twin is a candidate ticket, the orchestrator's call.

**Self-assessment.** CONFIDENT: the trace (read at the code); the pure brain (exact values on every
fallback shape); the model's state transitions (the re-ask's depth exact, every drop road, the mark's
set/clear roads, per-pane survival); the U8 design (no binding exists to re-apply anything).
LESS CERTAIN, ONLY THE STAGE WINDOW CAN SETTLE IT: the view's geometry — that a row's frame in the
content's NAMED space and `ScrollGeometry.visibleRect` share one origin (no top padding sits between
them on any of the three scroll views, and none sits at a safe-area edge — each is below the
catalog's own masthead — so no scroll inset enters; the mounted pins' 1-pt bars and the walk are the
oracle — a constant offset would red every one of them), and that a one-shot proxy landing plus the bounded hold settles the
List/Cards/sheet within a point (Takes measured the proxy arithmetic on a lazy column; uniform List
rows should settle at the first aim). FLAGS FOR THE COLD REVIEWER: **(a)** a MODE switch drops every
place (`modeChanged` → `questionChanged`), beyond the ruling's named drops (a new question, a wing):
the reasons are the ruling's own "a mode switch is not a return" and Q2's mark clear, and the
surface-kind check in `owesReturn` is the belt (a place lands only on its own kind) — PROVISIONAL;
**(b)** the per-pane memory shares one listing (above); **(c)** a NO-PHASE scroll inside the hold window
(keyboard paging, if it reports no phase) is re-aimed for up to the hold's last check, and her rests
are noted only outside the hold — a place left with no scroll since the return keeps the remembered
one, by construction; **(d)** each row now carries an `onGeometryChange` in Release (content space —
the action fires on appear and on a layout shift above the row, never per scroll frame; the transform
itself is SwiftUI's to evaluate); the DEBUG build already carried a per-frame catalog-space probe on
every note row; **(e)** every `search()` caller now drops the places and marks — all are new-question
doors (the field, scope, mode-with-a-day, sort, direction, the day, the facets, ⌘K's Library road;
listed at C0); **(f)** unchanged and noticed: the row menu's Open and the card tap never closed the
info panel (the title/double-click road does) — a panel open on another row stays open across a menu
Open; not this batch's to change.

#### Batch C — THREE MOUNTED PINS RED ON THE NEW TREE (stage window part 1) — traced: all three FIXTURE, the product unchanged

The window ran 258 tests / 38 suites: 255 green (every pure and model pin, all 35 neighbours), three
of the five mounted pins red. What was actually wrong, each read off the window's log
(`scratchpad/batchC-suites.log` lines 5085/5469/6144/6547):
1. **`theListComesBackWhereSheLeftItDeepInTheLibrary` — the pin read a STALE row.** Its chooser took
   the topmost DEBUG-oracle note frame inside the notes region; the oracle (`OwnedRegistrations`)
   keeps a de-realized row's LAST frame until its catalog leaves, and a clip JUMP de-realizes rows
   without moving their reports. `scrollToTheEnd`'s first jump left rows ~65–79 (the first page's
   end) reported on screen; after the jump to 3,500 pt the chooser picked row 65 (the premise line
   read `deepest → 65`), which was not on screen — so after the return to the real place row 65 was
   never re-realized and its frame was absent (`top(of:) → nil`). The landing is not implicated.
2. **`theCardsComeBackWhereSheLeftThem` — the pin compared raw clip offsets across two mounts of a
   lazy column**, which are not comparable: the rows above are estimated until realized (Takes'
   recorded ~390-pt measurement, `EditorRouter.takesArticlePlaces`' own doc — the very reason the
   product anchors on rows, never pixels). The window measured 4,129 vs 4,000, and in the SAME run the
   pin's own row-identity check (the first realized card ±1) recorded no issue: the same cards came
   back.
3. **`theAnswerSheetComesBackWhereSheLeftIt` — the chooser needed `notesRegionFrame`, which only the
   List column publishes**; in the answer sheet it is nil, so the `#require` BEFORE the trip failed.
   Nothing about the return ran.

**The fix — the pins only (`LibraryReturnPlaceMountTests.swift`, 00569c8ce):** the reading row is
chosen only among rows the listing says are REALIZED (`visibleNoteIndices` — its own appear /
disappear bookkeeping), the one nearest the catalog's vertical middle (inside the listing whatever
sits above it — no region frame needed); `top(of:)` answers only while the row is realized; the List
scrolls to 70 % of its document (well past the first page in any voice) and its premise is a
`#require`; the Cards' oracle is row identity (the first realized card ±1 — the Cards carry no DEBUG
row probe), never the offset; the List's and the sheet's raw-offset bars are gone (the row's place on
screen is the bar); the List's "re-asked short of the corpus" line is gone (at 70 % of 200 notes the
place's depth plus a page reaches the end; the depth is the model pins' exact claim). Still nothing
the pre-fix tree lacks (red-on-old runnable as-is); R-C3 still reds the four return pins.
`build-for-testing` TEST BUILD SUCCEEDED (`DerivedData/vx828c-bft4.log`). The re-run is the
orchestrator's (the window holds).

#### Batch C — THE WALK'S RED (window 1: the live return lands at the top) — the mechanism, the fix, the road pin

**What the walk showed** (the record's "Batch C — ORCHESTRATOR VERIFICATION, WINDOW 1"): in the real
app, ~47 rows, a title click into a note and ⌥⌘[ back — and, with no edit, the same — the Library
came back at its TOP; the return MARK came back. So the place memory survived the trip (the mark
lives beside the place and only `questionChanged` clears both — it never ran), and what failed is the
RETURN mount's landing.

**The mechanism — traced by reading (no Debug launch, no app test run is mine); the road pin below
is the instrument that confirms or refutes it in the next window.** The return landing was owed at
`decide()` but FIRED only from this mount's first scroll READING (`landIfReady`'s predecessor: "the
first measured reading with a proxy in hand" — the `onAppear` arm also required `memory.window`, i.e.
a reading). `onScrollGeometryChange` calls its action when the transformed value CHANGES — Apple's own
words for the `action` parameter ("A closure to run when the transformed data changes"; its initial
call is undocumented — a read-only lookup, 2026-11-05: developer.apple.com's
`onScrollGeometryChange(for:of:action:)` page). A short listing swapped into an ALREADY-SIZED pane
(the shell's `paneDetail` arm swap inside a laid-out `PaneHost`) lays out once and never changes —
no content re-estimate, no resize — so no reading ever arrived, the owed landing never ran, and the
hold's checks (which also needed a reading) never re-aimed: the list rested at offset 0, the rows the
model still held at their natural top. **Why every pin was green:** the mounted pins re-mount the
catalog onto a fresh hosting ROOT (`hosting.rootView = …`), whose first passes resize the scroll view
— a geometry change, a reading, a landing; the model pins never touch the view. **Why the departure
side is not implicated:** the place was noted (the open captures it synchronously; the window's mark
proves the open ran), and a teardown cannot overwrite it now (below).

**The fix (`Features/Library/LibraryPlaceScroll.swift`; `LibraryCatalogPlace.swift` +
`noteSurface`):** the return lands as soon as the pane has its PROXY and a VIEWPORT — the viewport
is the scroll view's OWN height from `onGeometryChange` (which reports its first value at mount:
the catalog's DEBUG frame probes and its `libraryWidth`/`listAreaHeight` already depend on that),
else this mount's reading — from `onAppear`, from the height report, from a reading, or from the
re-ask's token, whichever completes the set (`landIfReady`); the pane's surface is said at `onAppear`
(`noteSurface`), so the landing resolves in the surface it mounted; the hold's checks re-aim while
NO reading has yet confirmed the row's place (an aim made before the scroll view could act moves
nothing and sends no reading) — bounded by the same 12-aim budget. **A guard beside it (not the
fix):** a surface notes a place only while LIVE (between its appear and its disappear — a rest
armed or fired during teardown notes nothing), so no teardown reading can overwrite the place an open
captured. **A DEBUG instrument (stays, off unless a pin installs its sink — the `SidebarSectionTrace`
shape):** `LibraryPlaceTrace` — decide / appear / land / landing / aim / re-ask / rest lines, so a
red pin says which step failed instead of only "at the top".

**The road pin (`VariorumTests/LibraryReturnRoadTests.swift`, 2 arguments):** the REAL `RootView`
(a new internal init seam `catalog:` — production passes nothing; batch D's ruled `model:` seam is
the precedent) in a window; the Library reached through `ShellRouter.adopt(.library)` (the sidebar's
road); 5 books + 47 notes (the walk's shape); her scroll by the clip to 75 % and its rest; then
(a) the catalog's open door's two statements — `rowOpened(row, placeKey:)` then the shell's
`adopt(.post(row))` (`openHit` minus the panel's close) — or (b) the sidebar's leave to the Bookcase;
then `router.goBack()` (⌥⌘[). Claims: the row back within 1 pt of where it sat (the DEBUG oracle,
realized rows only), and on (a) the return mark. Its failure message carries the trace.
**RED-ON-OLD by revert R-C4:** in `LibraryPlaceScroll.landIfReady` add `memory.window.isMeasured`
to the guard (the landing gated on a reading again — the pre-fix rule) → expect both arguments red
(the row not where it sat — the list at its top) with a trace showing `decide owed=true` and no
`landing` line. **If the pin is GREEN under R-C4, the mechanism above is wrong** — the trace then
names the step, and this record says so before anything else lands. (The pin needs the new init
seam, so on the C3 tree it is compile-red; R-C4 is its behavioural red.)

**Files touched (the whole batch):** `App/Variorum/Variorum/Features/Library/LibraryPlace.swift` (new) ·
`App/Variorum/Variorum/Features/Library/LibraryCatalogPlace.swift` (new) ·
`App/Variorum/Variorum/Features/Library/LibraryPlaceScroll.swift` (new) ·
`App/Variorum/Variorum/Features/Library/LibraryCatalogModel.swift` ·
`App/Variorum/Variorum/Features/Library/LibraryCatalogView.swift` ·
`App/Variorum/Variorum/Features/Library/LibraryBooksRegion.swift` ·
`App/Variorum/Variorum/Features/Library/LibrarySearchSheet.swift` · `App/Variorum/Variorum/RootView.swift` ·
`App/Variorum/VariorumTests/LibraryPlaceTests.swift` (new) ·
`App/Variorum/VariorumTests/LibraryReturnPlaceTests.swift` (new) ·
`App/Variorum/VariorumTests/LibraryReturnPlaceMountTests.swift` (new) · this record.

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

#### Batch B — LIVE STATUS (implementer: Opus, fresh session, 2026-11-05)

**Not done by this batch (first line, final):** NO app-suite RUN, NO red-on-old revert RUN (R-B1, R-B2,
R-B2b, R-B3, M-B4), NO walk, NO Debug launch — all stage-gated, all the orchestrator's (named exactly in
the self-assessment). No `App/Variorum/Shared/` file — no phone suites owed. No canon, QUESTIONS or shared ledger
touched. No `Sync/`, custody or keychain anywhere in this batch's reach. Built to the fork's ruling
(0aca117b3, "Batch B — THE FORK'S RULING"); B2 lands before B1 (the chord rides B2's road).

| Piece | What | Status |
|---|---|---|
| B0 | Preflight (the brief's reading list, read in full; her three tickets read on the board) + THE TRACE + THE DESIGN FORK | DONE (ec53930ef) — RULED (0aca117b3) |
| B1 | VX-824: the pure chord rule + the registry declaration (`.goToWing`, the alternate "⌘1–9") + the helper row + the window's key monitor + routing pins | DONE (this commit) — `Workspace/WingNumberKeys.swift` (NEW: the key = exactly ⌘ + one digit; the pure rule over the registry's gate, the keyboard holder per Q-B1 (a) and the switcher's order; the holder classes; the monitor, the `BrowserNavKeyMonitor` shape); `CapabilityID.goToWing` + its declaration (`.surface`, app scope, alternate "⌘1–9", the mode row's mirror, the collision sweep recorded at the declaration); `RootView`: the monitor mounted, `wingNumberKey` (static — what the key runs), `surfaceCapabilities` + `.goToWing`; `WingsModel.answer`; `WingCopy.noWingAtNumber` (P-828-1 (i) words as drafted); the ⌘/ helper's row (`.alternates`) + the ⌘L row's words name the landing. Pins `WingNumberKeysTests` (13, NEW — the key, the rule's table incl. the three contexts and both P-828-1 arms, the words, the holder classes, the declaration + the catalog's contextual pair, and the WHOLE ROAD with real NSEvents in a real window: the capture box holding the keys ⇒ goes; a note detail ⇒ passes; a book's live note ⇒ passes; ⌘7 with two wings ⇒ refusal; ⌘1 = current ⇒ lands silently; ⌘⇧1 never) + `ShellChromeTests`' exact surface list re-pointed (justified, the VX-644 line's class). Mac `build-for-testing` TEST BUILD SUCCEEDED. RUN + revert R-B1 PENDING (stage) |
| B2 | VX-833 (1): the deliberate switch lands in the wing's Bookcase — one road in `WingsModel`, every switcher door through it — + pins | DONE (this commit) — `WingsModel.goTo(_:saying:)` + `landInBookcase` (wired per window by `RootView.wireWingLanding` → `pendingSelection = .shelf`); `switchSaying`/`cycle` ride it; the ▾ list's picker → `goTo(saying: false)`; `WingSwitcherBrain` commits the current row (P-828-1 (ii)(a)); pins `WingDeliberateLandingTests` (6, NEW) + 4 justified re-points in `WingSwitcherChordTests` (`.close` → `.commit(current)`). Mac `build-for-testing` TEST BUILD SUCCEEDED. RUN + revert R-B2 PENDING (stage) |
| B3 | VX-833 (2) + VX-844: the label's space (pure) + right-aligned in the column + the marquee (pure plan + view) + pins | DONE (this commit) — `Core/Views/WingToolbarLabel.swift` (NEW): `WingLabelSpace` (the line − 8 pt air − the item's edge; the 24-pt floor ⇒ not drawn; the hidden sidebar ⇒ the old place and 160-pt cap; VX-736's 169-pt edge until the first read), `WingMarqueePlan` (the ticker: rest 2.5 s, 25 pt/s, 24-pt gap, seamless wrap; still — NO loop — while it fits; Reduce Motion still; the loop key = name, space, plan), `WingMarquee` (the words still or ticking; hard clips; one accessibility label; a cancellable `.task` loop that returns at once for a still plan), `WingLabelPlacementView` (right-aligned in exactly its space), `WingToolbarSlot` (the shell's own `shellSidebarWidth` key, read here so a seam drag re-lays the label alone) and `WindowLeadingEdgeProbe` (the item's edge in WINDOW coordinates — on layout, arrival, resize and full screen; never a hit); `RootView`'s third `.navigation` item rides the slot and the marquee (the old `.frame(maxWidth: 160)` + `.truncationMode(.tail)` gone; the premise strings the three source pins read are kept). Pins `WingToolbarLabelTests` (10, NEW — the space rule + both edges; the plan: fits ⇒ no loop, the ticker's numbers, Reduce Motion, the loop key; HOSTED geometry: a short name flush right in exactly its 63-pt space, a long name keeps the space and its 53-pt window, below the floor nothing; the composition by source). Mac `build-for-testing` TEST BUILD SUCCEEDED. RUN + revert R-B3 + the walk PENDING (stage) |
| B4 | Self-assessment + the end-of-batch headless suite + the app `build-for-testing` | DONE (this commit) — full core `swift test` at 1dd4e3233: `VariorumCoreTests` 3670 tests / 493 suites PASSED (5 known issues — unchanged from batch D: this batch touches no package code); `StringsWorkbookTests` 32/4 PASSED; the 7 known "dependency not used" warnings (14 lines); `VariorumMCPTests` 549/100 with 3 issues, all the MCP socket harness (`MCPHarnessTimeLimitTests`, `MCPReaderAfterCloseTests`, `MCPDiscoverProbeServerTests`) — re-run ALONE (`swift test --skip-build --filter …`): 10 tests / 3 suites PASSED. Mac `build-for-testing` TEST BUILD SUCCEEDED at 1dd4e3233, no warning in a touched file. Self-assessment below |

#### Batch B — THE TRACE (read at the code, this tree)

- **⌘digit today.** The mode row's keys are View-menu items, one per `PostMode` (`EditorCommands.swift:1048-1057`),
  grey wherever `.switchMode` is unavailable — `ctx.mode != nil` (`CapabilityRegistry.swift:1499`), i.e. no
  note detail mounted in the key window's focused pane (an unfocused pane mounts no detail; a book's Outline
  carries no post mode — `CommandRouter.swift:33/103/155`). **A grey menu item swallows its chord in
  silence** (`OneWingChord.swift`'s header, measured at 13n-c W-UX-6): so outside a note ⌘1–⌘9 do NOTHING
  today, not even a refusal. A LOCAL key monitor sees a key before the menu does — the two precedents:
  `BrowserNavKeyMonitor` (per full window, mounted by `RootView.swift:364-368`; VX-560's "outside text"
  gate is `PageTurnKeys.textIsFirstResponder` — `PageTurnKeys.swift:64`: any `NSText`, any field, a web
  view) and `OneWingChord` (app-wide, speaks a grey chord's note).
- **What holds the keyboard where ⌘digit would land.** VX-332: every arrival at the Bookcase puts the caret in
  its QUICK ENTRY (`CaptureNSTextView` — an `NSTextView`, so an `NSText`) when nothing else holds the keyboard.
  The note-prose surfaces are `EditorTextView` (Write; a book's live note; the Pool's and Snippets' editors)
  and `PaneTextView` (the panes' TK2 surface); comments are `CommentNSTextView` / `CommentTwinTextView`.
- **Wing order.** `WingsModel.rows` (`WingsModel.swift:106-108`): Home first, then `Queries.wings` in switcher
  order (`wing.position`) — the order ⌘L's sheet and the ▾ menu list.
- **The switch roads, and that none navigates.** `WingsModel.switchTo` (silent, `:121`), `switchSaying` (the
  "Now in …" receipt; current wing ⇒ nothing, `:137-141`), `cycle` (`:150`). Doors: ⌘L's sheet →
  `WingSwitcherModel.apply` → `switchSaying` (`WingSwitcherSheet.swift:48-56`; the brain answers `.close`
  for the CURRENT wing, `WingSwitcherBrain.swift:119-126`); the masthead ▾ menu's inline picker →
  `switchTo` (`WingSwitcherMenu.swift:175-177`); the masthead word's cycling click → `cycle`
  (`WingSwitcherMenu.swift:94-96`); the toolbar label → `ShellActions.openWingSwitcher` → ⌘L's sheet
  (`RootView.swift:317-331`, `ShellActions.swift:1017`). Every one switches `WingState.currentID` and the
  focused pane keeps whatever it shows (a listing re-scopes; a note stays — editors never close on a
  switch, 17y (f)). That is VX-833's mechanism: the pick changes the room but leaves her standing where she
  was. Not switcher doors: `WingFollow.follow` (`WingFollow.swift:114-129`), `mint` (`WingsModel.swift:157`),
  `delete` (`:204-208`), `WingState.revalidate`, Compare's lineage "go to ‹wing› ›"
  (`CompareBoardView.swift:1727`), `MCPNavigator`'s wing landing (`MCPNavigator.swift:125`).
- **The one navigation request road:** `router.pendingSelection = .shelf`, adopted by the window into its
  focused pane (`RootView.swift:508-512`) — what `goBack`/`openNote` use.
- **The label.** `RootView.swift:317-332`: the toolbar's third `.navigation` item (after the sidebar toggle and
  New Note's glass group), `.frame(maxWidth: 160, alignment: .leading)` + `.truncationMode(.tail)`. The
  toolbar's leading items are laid out by the WINDOW, never by the column (`ShellSplit` is an `HStack`), and
  the column's line sits at x = the clamped `shellSidebarWidth` (`ShellSplit.swift`; fresh 240, 180…360).
  VX-736 measured the label's origin at ≈ 173.8 pt in both voices (`vx-736-hotfix-101.md:370`). **The
  mechanism for VX-833 (2) and VX-844 together:** the label is placed leading with a fixed 160-pt cap that
  knows nothing of the column, so it floats after New Note instead of standing at the column's right edge,
  and any name wider than the ≈ 58 pt left at 240 runs past the line ("in walk wing", Terminal — J5); past
  160 it tail-truncates (the ellipsis she declined).

#### Batch B — DESIGN FORK (B0 — proposed for the orchestrator's ruling BEFORE the unruled arms are built)

**Q-B1 — what "no note holds the keys" means (a READING of the ruled words; it decides VX-824's core).** The
brief composes it as the VX-560 family (who holds the keyboard) PLUS the note-focus condition. Read
literally, the VX-560 half (any text input) collides with VX-332: the Bookcase's resting caret is in its
quick entry, so ⌘digit would be dead ON THE BOOKCASE — including the second press after a ⌘digit landing,
since the landing is a Bookcase arrival and puts the caret back in the box. Options:
- **(a) PROPOSED — the holder must be a NOTE.** The wing arm takes ⌘1–⌘9 unless (1) the focused pane shows a
  note — the mode row's own gate (`ctx.mode != nil`), whatever holds the keyboard there (her "in a note it
  stays the mode row") — or (2) a WRITING surface holds the keyboard anywhere in the window: note or snippet
  prose (`EditorTextView`, `PaneTextView` — a book's live note in Outline/Index, Read's edit face, the Pool,
  Snippets) or a block comment's text. Every other holder — the capture box, the Library's and a book's search
  fields, the tag field — is not a note, and ⌘digit has no meaning in any of them (no editing chord is taken),
  so the chord goes to the wing there.
- (b) The literal VX-560 rule: any text input (`PageTurnKeys.textIsFirstResponder`) blocks the wing arm — the
  Bookcase dead-key cost above.
- (c) The note-focus condition alone (`ctx.mode == nil` ⇒ wing): typing in a book's live note or a snippet,
  ⌘2 would leave the book under her hands for another wing's Bookcase.

Under (a) and (b) a press the wing arm declines PASSES ON exactly as today: inside a note the menu's mode item
takes it; in a book's live note it meets the grey mode item and is swallowed silently (today's behaviour,
untouched). Note-only windows and the quick-note pad carry no monitor (it is the full window's, `RootView`'s,
the `BrowserNavKeyMonitor` shape), so ⌘digit there is untouched. Sheets are their own windows — untouched.

**P-828-1 — a ⌘digit that names no other wing (the brief's PROVISIONAL; P-2's door-that-did-nothing frame).**
- *(i) N beyond the wing count* (⌘5 with three wings; ⌘2 with one). **(a) PROPOSED — a refusal on the status
  seam**, the key consumed (it never reaches the grey mode item): AppSpec §12 "a door that did nothing speaks
  a refusal", with the two chord precedents (`OneWingChord` — ⌘L with one wing; VX-560's ⌘← with nowhere to
  go). Draft words (PROVISIONAL, sentence case): one wing — "There is only one wing so far — New Wing… under
  the wing name at the top of the Bookcase makes another, and then ⌘2 goes to it." (⌘L's ruled note's shape);
  several — "There's no wing 5 — ⌘1–⌘3 go to your 3 wings, Home first." (b) A quiet no-op — consumed or
  passed to the grey item, nothing said (today's silent swallow).
- *(ii) N = the CURRENT wing.* **(a) PROPOSED — it lands in that wing's Bookcase**: the chord means one thing,
  "wing N's Bookcase"; no receipt (the wing did not change); already on that Bookcase ⇒ nothing moves and
  nothing is said (the "re-selecting the shown thing is not an act" precedent). AND the switcher's own pick of
  the current wing lands the same way — today the brain answers `.close` there (a 13n-c reading, not a ruling),
  and her "i want it to be consistent" reads as one meaning for "pick a wing" on every road; the brain gains a
  "land here" outcome for a deliberate commit of the current row (⏎, a click, a held-⌘ release on it) while
  Esc stays a plain close. (b) ⌘digit lands; the switcher's current pick keeps closing (brain untouched).
  (c) Neither moves — a chord naming the current wing does nothing, silently (`switchSaying`'s rule; a silent
  chord, P-2's own question). Consequence of (a), stated: with ONE wing, ⌘1 outside a note is Home's
  Bookcase.

**Q-B2 — which doors are "the switcher's pick" (a READING of VX-833's "one rule for both roads").**
- **(a) PROPOSED — every door whose act is choosing a wing in the switcher:** ⌘L's sheet (⏎, a row click, the
  held-⌘ release — and so the toolbar label, which opens it), the masthead ▾ menu's wing list (Bookcase and
  Library mastheads), and the masthead word's cycling click — plus the chord. Each lands in the chosen wing's
  Bookcase in the focused pane through the one request road (`pendingSelection = .shelf`). Receipts as
  today: the sheet and the cycle say "Now in …", the chord says it too (blind like a cycle), the ▾ list stays
  silent (13i-d — she reads the name she picked).
- (b) As (a) except the cycling word keeps the surface it was clicked on. The reason to weigh it: on the
  LIBRARY masthead a cycle that lands on the Bookcase moves the word under her pointer (the Bookcase draws its
  own elsewhere), so stepping three wings by repeated clicks needs a re-aim after the first; on the Bookcase
  masthead (a) and (b) are the same.
- NOT a deliberate switch under either (untouched, named so the ruling can redirect): the cross-wing FOLLOW
  (the brief's rule), New Wing…'s switch-in ("you're in it now"), Delete Wing's return to Home, a dead wing's
  revalidation, Compare's lineage "go to ‹wing› ›" (a road from inside a note), and the MCP door's
  `show_in_app` wing landing (MCPSpec territory; vx-809 holds the door).

**P-828-2 — the marquee (the brief's PROVISIONAL).** Built whichever cadence is ruled (the ruled half): the
decision to animate is a pure function of (the words' width, the space); when the words fit, the view starts
NO clock of any kind (no TimelineView, timer or repeating animation exists on the common case — P-8); the loop
is a cancellable task keyed on (name, space), so a rename, a resize or a switch that makes the name fit stops
it, and so does the view leaving. The words are clipped hard at the space's two edges (no ellipsis — declined;
no fade — the car radio's own window). Cadence:
- **(a) PROPOSED — the ticker, the car radio's own shape:** the label rests showing the name's START for 2.5 s;
  then the words travel left at a steady 25 pt/s, a 24-pt gap behind them and the name again after it, until
  that next copy stands exactly where the start rested — a seamless return — and it rests again; one
  direction only, never a jump back; for as long as it overflows.
- (b) Ping-pong: rest at the start 2 s, travel left until the END shows, rest 1.5 s, travel back, repeat.
- (c) One pass per arrival: on appear and on each wing switch, travel once to the end and back, then rest at
  the start for good (the hover's help carries the whole name).
- Common to all: **Reduce Motion** (System Settings ▸ Accessibility; the app's `accessibilityReduceMotion`
  precedent in Takes/Read) ⇒ no movement — the start, clipped; the hover gives the whole name. The numbers
  (2.5 s, 25 pt/s, 24 pt) are PROVISIONAL for her eye on the walk.
- Two edges inside P-828-2 (built as proposed unless redirected): **the space's floor** — a column dragged so
  narrow that the space is under 24 pt (the 180-pt minimum leaves ≈ 0) draws NO label (a sliver that cannot
  show a letter is no door, P-2; ⌘L and both mastheads remain) — alternative: draw it at the floor and let it
  cross the line there; **the sidebar hidden** (⌃⌘S) — no column and no line, so the label keeps today's place
  after New Note with today's 160-pt cap as its space, the marquee past it.

**Not a fork — VX-833 (2) as it will be built (ruled):** the label stays the toolbar's third `.navigation`
item (VX-644's switcher door) and takes the column's remaining width as its frame — space = the column's line
(the clamped `shellSidebarWidth`) − 8 pt of air (`FreshSidebarWidthTests.air`) − the item's own leading edge,
READ live in window coordinates by a zero-size AppKit probe (the leading items are the window's, and they move
— full screen drops the traffic lights — so the origin is measured, never assumed); the words stand at the
space's TRAILING edge; the hover wash hugs the words, never the empty run before them.

**Pins planned:** the pure chord rule (in-note ⇒ pass on; a writing surface holding the keys ⇒ pass on; the
capture box / a field / nothing ⇒ wing N; P-828-1's arms) + real-`NSEvent` classification (the
`OneWingChord`/`BrowserNavKeys` pin shape); `CapabilityRegistryTests` + `ShortcutCatalogTests` with the new
declaration; the deliberate road lands `.shelf` from every switcher door (red-on-old by reverting the landing
call) and the follow does NOT land; the label's space (pure) + a hosted geometry pin of the label at a given
origin and line (red-on-old by reverting to the leading 160-pt cap); the marquee plan (fits ⇒ still, no loop
key; overflow ⇒ the ruled cadence; Reduce Motion ⇒ still).

**ASKED OF THE ORCHESTRATOR (one ruling unblocks B1–B3):** Q-B1; P-828-1 (i) and (ii); Q-B2; P-828-2's
cadence and its two edges.

#### Batch B — IMPLEMENTER SELF-ASSESSMENT (Opus, 2026-11-05)

**Not done (first line, by the brief):** no app-suite RUN, no red-on-old revert RUN (R-B1, R-B2,
R-B2b, R-B3, the mutation M-B4), no walk, no Debug launch — all stage-gated, all the orchestrator's
(listed exactly below). No canon, QUESTIONS or shared ledger touched (drafts below). No `Sync/`,
custody, keychain or editor-seam file (`EditorTextView`/`PaneTextView` are only NAMED, as classes the
chord passes on to). **No `App/Variorum/Shared/` file touched — no phone suites owed by this batch.**

**VX-824 — the mechanism (traced at B0).** Outside a note the View menu's mode items are grey
(`.switchMode`: `ctx.mode != nil`) and a grey menu item swallows its chord silently, so ⌘1–⌘9 did
nothing there. **The build** (her shape (a); the fork's Q-B1 (a), P-828-1): one pointer per piece —
- `App/Variorum/Variorum/Workspace/WingNumberKeys.swift` (NEW) — the key (exactly ⌘ + one digit 1–9),
  the pure rule (the registry's gate × the keyboard holder × the switcher's order), the holder classes
  (`EditorTextView`, `PaneTextView`, `CommentNSTextView` = a writing surface; the capture box, fields,
  nothing = not), and `WingNumberKeyMonitor` (the `BrowserNavKeyMonitor` shape — a local monitor sees the
  key before the menu; consumed only when it is the chord's).
- `Registry/Capability.swift` + `Registry/CapabilityRegistry.swift` — `.goToWing` ("Go to Wing",
  `.surface`, app scope, alternate "⌘1–9", availability = the mode row's mirror; the collision sweep is at
  the declaration).
- `RootView.swift` — the monitor mounted beside VX-560's; `wingNumberKey` (static: what the key runs);
  `surfaceCapabilities` gains `.goToWing`.
- `Core/Views/WingsModel.swift` — `answer(_:)`; `WingCopy.noWingAtNumber` (P-828-1 (i), the drafts verbatim).
- `Registry/ShortcutCatalog.swift` — the ⌘/ helper's `.alternates([.goToWing])` row; the ⌘L row's words
  name the landing and the label's new place.

**VX-833 (1) — the mechanism (traced at B0).** Every switcher door switched `WingState.currentID` and
nothing else — the focused pane kept what it showed. **The build:** ONE deliberate road —
`WingsModel.goTo(_:saying:)` (switch when another; "Now in …" where said; then `landInBookcase`), wired
per window by `RootView.wireWingLanding` to the shell's one request road (`pendingSelection = .shelf`).
`switchSaying` (⌘L's sheet), `cycle` (the masthead word) and the ⌘digit chord ride it said; the ▾ list's
picker rides it silent (`WingSwitcherMenu.swift`). `WingSwitcherBrain` commits a deliberate pick of the
CURRENT row (⏎, a click, a held-⌘ release on it — P-828-1 (ii)(a)); Esc stays the sheet monitor's plain
close. Untouched by construction (they never call `goTo`): `WingFollow`, `mint`, `delete`,
`WingState.revalidate`, Compare's go-to, `MCPNavigator`.

**VX-833 (2) + VX-844 — the mechanism (traced at B0).** The label carried `.frame(maxWidth: 160,
alignment: .leading)` + `.truncationMode(.tail)`: a width blind to the column (the toolbar's leading
items are the window's), so it floated after New Note, crossed the line past ≈ 58 pt of words at 240, and
tail-truncated past 160. **The build** — `Core/Views/WingToolbarLabel.swift` (NEW): `WingLabelSpace` (the
line − 8 pt air − the item's edge; < 24 pt ⇒ not drawn; sidebar hidden ⇒ the old place and cap),
`WingMarqueePlan` (the ruled ticker; still — no loop — while it fits; Reduce Motion still),
`WingMarquee` (the view: hard clips, one accessibility label, a cancellable `.task` loop that returns at
once for a still plan), `WingLabelPlacementView` (right-aligned in exactly its space), `WingToolbarSlot`
(its own read of the shell's `shellSidebarWidth`, so a seam drag re-lays the label alone) and
`WindowLeadingEdgeProbe` (the item's edge in window coordinates; re-read on layout, arrival, resize and
full screen; never a hit). `RootView`'s third `.navigation` item rides the slot and the marquee.

**Pins — and exactly what makes each red (the orchestrator's revert window).** Pre-revert copies are
not needed: every revert is an UNCOMMITTED edit on the committed tree at the batch's last commit,
restored by `git checkout -- <file>` (git is the honest mid-revert state — batch A's precedent).
| Pin (suite TYPE · test) | Red on old because | Behavioral revert that shows it |
|---|---|---|
| `WingNumberKeysTests` (13, NEW) | new act — compile-red on old (no `.goToWing`, no `WingNumberKeys`) | **R-B1:** in `Workspace/WingNumberKeys.swift`, make `decide(…)`'s body `return .passOn` (the old silent swallow). Expect RED: `outsideANoteTheKeysGoToTheWingInSwitcherOrder` (3), `aNumberNoWingAnswersIsARefusal` (3), `onTheBookcaseWithTheCaptureBoxHoldingTheKeysTheChordGoes` (4), `aNumberNoWingAnswersSpeaksAndMovesNothing` (3), `theCurrentWingsNumberLandsSilentlyAndShiftIsNotTheChord` (2 — consumed, `.shelf`). GREEN: the key, both in-note tests, the writing-surface test, the words, the holder classes, the declaration, the book-live-note road |
| `WingDeliberateLandingTests` (6, NEW) | no landing exists on old (no `goTo`) | **R-B2:** in `Core/Views/WingsModel.swift`, comment out `landInBookcase()` in `goTo`. Expect RED: the `.shelf` line in `theSaidRoad…`, `theMenuListsPick…`, `theMastheadCycleLands`, `theSheetsCommitLands…` (2 lines); also `WingNumberKeysTests`' two `.shelf` lines. GREEN: `theFollowAndTheOtherSwitchesNeverLand`, `theWindowWiresItsLanding` and every switch/receipt line |
| `WingSwitcherChordTests` (4 RE-POINTED lines: `theFieldsUnchangedWriteBackIsNotTyping`, `heldCommandLCyclesAndReleaseCommits`, `returnOnTheCurrentWingCommitsItAndArrowsNeverArmRelease`, `aRowClickCommitsTheCurrentRowToo`) | the old brain answered `.close` for the current row — each re-pointed line is red on old by construction | **R-B2b:** in `Core/Views/WingSwitcherBrain.swift` restore `pick` → `id == currentID ? .close : .commit(id)` and `commit()` → `highlight == currentID ? .close : .commit(highlight)`. Expect RED: those 4 lines + `WingDeliberateLandingTests.theSheetsCommitLandsTheCurrentWingIncluded`'s ⏎-on-current line |
| `WingToolbarLabelTests` · `aShortNameStandsFlushRightInItsSpace` | the old label was leading at its natural width | **R-B3:** in `Core/Views/WingToolbarLabel.swift`, `WingLabelPlacementView.body`'s `.column(let width)` arm → just `content(words)` (no Spacer, no frame — the old leading shape). Expect RED: the item-width line (≈ 55 ≠ 63) and the flush-trailing line; the premise line green |
| `WingToolbarLabelTests` · `aLongNameKeepsTheSpaceAndClipsInsideIt`, `belowTheFloorNothingIsDrawn`, the pure space/plan pins, the source pin | new seams — compile-red on old; GREEN under R-B3 (the long name's width comes from the marquee's clamp — a guard, stated) | **M-B4 (mutation, the marquee's teeth):** in `WingMarqueePlan.plan`, drop `words > viewport + tolerance` from the guard. Expect RED: `aNameThatFitsHasNoLoop` (the fits/exact/noise lines) — the "no clock while it fits" state |
| `ShellChromeTests` · `theSidebarToggleIsDeclaredOnItsTwoDoors` | its exact surface list (RE-POINTED, the VX-644 line's class) | — |

**PENDING (the orchestrator's stage window).**
1. Mac suites, by TYPE (a zsh array): `WingNumberKeysTests` · `WingDeliberateLandingTests` ·
   `WingToolbarLabelTests` · `WingSwitcherChordTests` · `ShellChromeTests` · `CapabilityRegistryTests` ·
   `ShortcutCatalogTests` · `HelperCurrencyTests` · `FreshSidebarWidthTests` · `QuickEntryWingLabelTests` ·
   `WingChordsAndLabelDoorTests` · `WingSwitcherTests` · `WingFollowTests` · `WingPaletteDoorsTests` ·
   `ChromeLineLimitTests` · `BrowserNavKeysTests` · `OpenStripMenuTests` · and RootView mounts the new
   slot/probe/monitor in every shell pin — at least `ShellLandingTests` · `QuickEntryLaunchFocusTests`
   (VX-332's caret: the slot must never take focus) · `StatusToastPlacementTests` ·
   `DebugOracleTwoWindowTests` · `WindowsTests` · `PaneSplitTests` (and `TourTests` if the window allows).
2. Reverts R-B1, R-B2, R-B2b, R-B3 and M-B4 (above), each one suite (+ the named neighbours), then
   restore.
3. The walk (dev store, BOTH voices; a second and third wing, one named long — e.g. "walk wing" in
   Terminal and a much longer one):
   (a) ⌘digit — on the Bookcase with the caret in quick entry ⌘2 → wing 2's Bookcase + "Now in …"; then
   ⌘3 at once (the chained press); ⌘1 → Home; ⌘9 → the refusal; the Library with its search field
   focused ⌘2 → switches; in a note ⌘2 → Takes, no wing change; a book's Outline with the caret in a live
   note ⌘2 → nothing; a Snippets editor ⌘2 → nothing; ⌘/ shows the row and "cmd 3" finds both.
   (b) VX-833 — from the Library: ⌘L pick → that wing's Bookcase; ⌘L ⏎ on the current wing → its
   Bookcase; the toolbar label → sheet → a row → Bookcase; the Library masthead ▾ list → Bookcase,
   silent; the Library masthead word's cycle → Bookcase + receipt (the re-aim regression, for her eye);
   a cross-wing note from the Open list → the follow switches and the note STAYS (no landing).
   (c) VX-833 (2) / VX-844 — the label right-aligned at the column line with ≈ 8 pt air; drag the seam
   wider / narrower → it follows; narrow below ≈ 201 pt → it disappears; ⌃⌘S → the old place after New
   Note; full screen → still right-aligned; the long name TICKS (2.5-s rest, steady leftward, seamless
   wrap), never crosses the line, no ellipsis; rename it short → still; the first frame after a switch
   shows no left-aligned flash (flag (e)); Reduce Motion on (optional — a global setting) → still.

**PROVISIONAL (QUESTIONS entries at the merge moment).** Q-B1 (a) — her "text input" family read as
"a writing surface" (flagged for her morning); P-828-1 (i) the refusal words, (ii) the identity switch
lands on both roads; Q-B2 (a) every switcher door lands — the cycling word's re-aim regression is the
cheap morning redirect; P-828-2 (a) the ticker's numbers (2.5 s · 25 pt/s · 24 pt), Reduce Motion
still, the 24-pt floor and the hidden-sidebar place.

**For the orchestrator's canon pass (DRAFTED — not applied; the two-file rule).**
- SurfaceContracts "The app", keyboard family — ADD: "⌘1–⌘9 go to wing N in the switcher's order (Home
  first) and land on its Bookcase while no note holds the keys — inside a note they stay its mode row, a
  writing surface holding the keyboard (a book's live note, a snippet, a comment) passes them on, and a
  number no wing answers says so (VX-824, `notes/plans/fixes/vx-828-editor-shell-qol.md`)".
- SurfaceContracts "The app", the wing label sentence — REPLACE "sits beside the window toolbar's New
  Note button" with: "stands right-aligned at the top of the sidebar's column, never past its line
  (not drawn below 24 pt of room; with the sidebar hidden it keeps its place after New Note), and a name
  longer than its room scrolls within it like a car radio's display — never an ellipsis, never moving
  while it fits or under Reduce Motion (VX-833, VX-844, P-828-2)".
- SurfaceContracts "The Bookcase and books", the wing switcher bullet — ADD: "Every deliberate switch —
  ⌘L's sheet (its current wing included), the masthead ▾ list, the masthead word's cycle and ⌘1–⌘9 —
  lands in that wing's Bookcase; the cross-wing follow never does (VX-833)".
- AppSpec §12 "Keyboard family" — ADD "⌘1–⌘9 go to a wing outside a note (VX-824)".
- AppSpecRecord: the dated entry + the narrative under §12 (keyboard family; the wing switcher; the
  toolbar label). MOBILE PARITY: nothing mobile-visible (Mac chrome; the phone has no wing face).

**Self-assessment.** CONFIDENT: the routing rule and its three contexts (pure + the whole road with real
NSEvents in a real window through the exact static the monitor runs); the one deliberate road (every
switcher door through `goTo`; the never-lands list pinned); the space rule and the plan (pure, exact).
LESS CERTAIN, for the walk: the probe's reading inside a toolbar item (window coordinates via
`convert(_:to: nil)` — standard, but the toolbar's hosting is SwiftUI's), and the ticker's look.
FLAGS FOR THE COLD REVIEWER:
(a) the writing-surface test is by CLASS (`EditorTextView`, `PaneTextView`, `CommentNSTextView`) — a
future prose surface class would take the chord while typing until added there;
(b) the digit is read from `charactersIgnoringModifiers` (the menu's own key equivalents are
character-based); a layout whose unshifted digit row yields other characters (AZERTY) does not reach
the chord — untested;
(c) ⏎ straight after ⌘L now LANDS on the current wing's Bookcase (D-W3's "Return closes" became
"Return lands" — ruled, P-828-1 (ii)(a)); `WingSwitcherBrain.Outcome.close` is no longer produced by the
brain (kept; `apply` honours it);
(d) the probe re-reads on layout, arrival, resize and full screen only — a toolbar re-layout with none of
those would leave a stale edge until the next; reports are thresholded at 0.5 pt (no feedback loop: the
item's width never moves its own leading edge);
(e) before the words are measured the marquee's viewport is the max width for one pass — a possible
one-frame left-aligned flash on a switch (the walk looks);
(f) the loop's reset after `duration` may beat the animation's presentation end by milliseconds — a
sub-point jump, invisible by the seamless copy's construction;
(g) two readers of `shellSidebarWidth` (the shell, the slot) must keep one default — both read
`ShellSplit.idealWidth`;
(h) `FreshSidebarWidthTests`' captured-ink oracle now describes the ITEM's leading edge, not the words'
start (the words now end at line − air − inset by construction): still a valid upper bound, its premise
strings kept on purpose; its prose is partly stale (a later doc touch);
(i) with one wing ⌘1 outside a note is a go-to-Bookcase chord (accepted in the ruling);
(j) the ⌘L helper row's words changed ("at the top of the sidebar"; "every switch lands on that wing's
Bookcase") — her copy eye.

**Files touched (the whole batch):** `App/Variorum/Variorum/Workspace/WingNumberKeys.swift` (new) ·
`App/Variorum/Variorum/Core/Views/WingToolbarLabel.swift` (new) ·
`App/Variorum/Variorum/Core/Views/WingsModel.swift` · `App/Variorum/Variorum/Core/Views/WingSwitcherBrain.swift` ·
`App/Variorum/Variorum/Core/Views/WingSwitcherMenu.swift` · `App/Variorum/Variorum/Core/Views/WingSwitcherSheet.swift` ·
`App/Variorum/Variorum/Registry/Capability.swift` · `App/Variorum/Variorum/Registry/CapabilityRegistry.swift` ·
`App/Variorum/Variorum/Registry/ShortcutCatalog.swift` · `App/Variorum/Variorum/RootView.swift` ·
`App/Variorum/VariorumTests/WingNumberKeysTests.swift` (new) · `App/Variorum/VariorumTests/WingDeliberateLandingTests.swift` (new) ·
`App/Variorum/VariorumTests/WingToolbarLabelTests.swift` (new) · `App/Variorum/VariorumTests/WingSwitcherChordTests.swift` ·
`App/Variorum/VariorumTests/ShellChromeTests.swift` · this record. Commits: ec53930ef (B0) · 569f2fcca (B2) ·
76db05116 (B1) · 1dd4e3233 (B3) · this commit (B4).

#### Batch B — THE WINDOW'S THREE REDS (stage "vx-828-batchB" part 1: 201 tests / 36 suites, 33 green, 3 red, zero .ips) — traced, fixed at 8b8a2b31a

1. **`BrowserNavKeysTests.theAlternatesAreDeclaredAndNoMenuKeyEverTakesTheLineKeys` (line 79) — a stale
   closed set, the batch A re-point class.** It pinned the registry's alternates to exactly VX-560's and
   VX-563's four keys; `.goToWing`'s "⌘1–9" is a fifth of the same monitor-door shape. Re-pointed
   (VX-563's own "A JUSTIFIED EDIT" class, named at the line); the helper-shows-them line still binds.
   **Sweep:** no other pin asserts a closed set of alternates (`compactMap(\.alternateShortcutLabel)` has
   one caller); the only exact `RootView.surfaceCapabilities` pin (`ShellChromeTests`) was already
   re-pointed at B1.
2. **`QuickEntryWingLabelTests.theToolbarsNewNoteButtonWearsTheWingLabel` (lines 90/92/93) — NOT a lost
   behaviour.** The pin reads the label through a 2,400-char window after the New Note button
   (`prefix(2_400)`), then 1,200 from the item. B3 added a 5-line comment above the item: the item moved
   from 1,397 to 1,781 chars and its body grew 759 → 885, so `.lineLimit(1)` (2,434), `.help(…)` (2,572)
   and `.sharedBackgroundVisibility(.hidden)` (2,666) fell past 2,400 while every one was still in the
   source — the muted style, the one-line policy (P-8), the hover and the hidden glass all KEPT on the
   new slot's button. Fix: the comment is removed (the slot file's header carries the story; the item's
   code names `WingToolbarSlot` / `WingMarquee`) — the item is back at 1,397…2,318; the pin untouched and
   green by an offline replay of its exact windows. (The 2,400 window is fragile — about 80 chars of
   headroom now; a later touch there should widen it.)
3. **`WingToolbarLabelTests.aShortNameStandsFlushRightInItsSpace` (line 159) — the PIN's arithmetic was
   wrong, the placement right.** Measured in the window: the item exactly 63 (passed), the words
   (12.5, 45.0) — maxX 57.5, so maxX + 5 = 62.5, off by exactly 0.5 against a strict `< 0.5`. Mechanism:
   the words' natural width is fractional ("in Home", SF 11.5: 44.93 pt — VX-736's CoreText measure), the
   Spacer absorbs the fraction, and SwiftUI snaps each frame edge to the backing grid on its own, so two
   independently snapped edges can sit up to a point apart (a quarter point each at 2×, a half at 1×).
   The ruled behaviour (words at the trailing edge) holds within the grid; the line now allows ≤ 1 pt
   with the reason at the pin, and R-B3's old leading shape still misses by ≈ 8 pt (red).

Next: the orchestrator re-runs the three suites (`BrowserNavKeysTests` · `QuickEntryWingLabelTests` ·
`WingToolbarLabelTests`); the reverts and the walk stay PENDING as listed in the self-assessment.

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

#### Batch E — LIVE STATUS (implementer: Opus, fresh session, 2026-11-05)

**Not done by this batch (first line, final):** NO app-suite RUN (15 new app tests across
`SpellingDoorTests` · `SettingsTagsWingFollowTests` · `TagSweepTests`, and their neighbours), NO
red-on-old revert RUN of an app pin (R-E1, R-E2, R-E3 named below), NO Debug launch, NO walk — all
stage-gated, the orchestrator's (the self-assessment's PENDING list names each exactly). No canon,
QUESTIONS or shared ledger touched (drafts in the self-assessment); no `Sync/`, custody or keychain
file; no `App/Variorum/Shared/` file (WingWords is only READ) — so no phone suites owed by this batch.
The vendored `TagUsageQueries.swift` (c1554f958) is vx-809's bytes and is never edited here.

| Piece | What | Status |
|---|---|---|
| E0 | Preflight (the brief's reading list, read in full; the three tickets' bodies read) + THE DESIGN FORK below | DONE — proposed (c9aba7cb1); RULED (4b1d1d47d, "Batch E — THE FORK'S RULING": Q-E1 (a), P-828-4 one combined entry, Q-E3 (i), Q-E4 (a)) |
| E1 | VX-798: Edit ▸ Spelling and Grammar (⌘: Show Spelling and Grammar · ⌘; Check Document Now), registry-declared, the responder-chain act + its refusal; pins | DONE (70b4a315e) — `CapabilityID.showSpellingPanel` / `.checkSpelling` + their registry rows (app scope, `[.menuBar]`, `always`, the collision sweep in the comment); `Registry/SpellingDoor.swift` (the act: `NSApp.sendAction(_:to: nil, from:)` on the menu's road, `tryToPerform` from a given responder for pins — never an explicit `to:` target, which AppKit sends to unconditionally and a non-answering one THROWS, probed; the door speaks `SpellingDoorCopy.nothingToCheck` where nothing took it); `EditorCommands`: `menuRendered` + `keyEquivalent` (`":"`/`";"` + ⌘) + the Spelling and Grammar submenu after Find; two helper rows (`ShortcutCatalog`, writing group, its line + "spelling"). Pins `App/Variorum/VariorumTests/SpellingDoorTests.swift` (5 tests; the act one parameterized over 5 surfaces × 2 levels). Mac `build-for-testing` TEST BUILD SUCCEEDED, no warning in a touched file. RUN + revert R-E1 PENDING (the stage window) |
| E2 | VX-838: Settings ▸ Tags names its wing ("Tags — in ‹wing›") and follows the app's wing live; pins | DONE (a7d6ab3fe) — `AppSettingsView`: the model's task keyed `.task(id: session.wing.currentID)` (the fix — RootView's idiom), the header's title through `AppSettingsView.title(of:tagsWingName:)` (Tags → `TagManagerCopy.title(wingName:)`, every other pane its own title), the internal `tags:` init seam (D's ruling 8 precedent); `TagsViewModel`: `shownWing` (id + name) adopted with the list from ONE read (`Listing` — `allTags` + `Queries.wingName`, Home's name `WingWords.home`), the start-once-per-wing contract stated in its doc; `Features/Settings/TagManagerCopy.swift` (new). Pins `App/Variorum/VariorumTests/SettingsTagsWingFollowTests.swift` (3: the MOUNTED follow — red-on-old by R-E2; the one-read name + live rename; the pure title). Mac `build-for-testing` TEST BUILD SUCCEEDED; one warning in a touched file, PRE-EXISTING (`AppSettingsView.swift` `PromoteTagsSheet.spec` — untouched code; present in batch C's logs vx828c-bft2/-bft5). RUN + revert R-E2 PENDING (the stage window). Not Shared/ (`WingWords` is read only) |
| E3 | VX-840 core: the unused listing (consuming `tagSubtreeIsWorn`) + the bulk act + exact-rows pins | DONE (23f68603c; the vendor commit c1554f958 ahead of it, alone) — `Queries/UnusedTagQueries.swift` (new): `Queries.unusedTags(_:wingID:)` = every live tag of the wing with `!tagSubtreeIsWorn(…, .library(countingTrashRevivable: true))`, path order, asking the brain once per maximal unused subtree (UNUSED is closed downward — WORN is subtree-honest; the subtree matched by stored wing + path prefix, `tagSubtree`'s own rule); `Queries.unusedTagRegions()` — tag, post_tag, block_tag whole; `container` / `block` / `wing` NARROWED to `(id, deleted_at)` so autosave's touch/churn stamps and every take write never wake it (P1); `AppDatabase.observeUnusedTags(wingID:)` (`observe(tracking:)`, re-fetched on a reader — VX-670 / batch D's shape). `Operations+Tag.swift`: `deleteUnusedTags(_:)` — ONE write, ONE stamp: walking the confirmed ids in path order, a tag's subtree goes (through `deleteTag`'s own `tombstoneTagSubtree`) only when it is still live, still unused by the brain INSIDE the write, and every live tag under it NOW was confirmed; the passes join into one `TagDeletionPass` and ONE entry `"Delete Unused Tags"` on VX-247's machinery (`registerTagDeletionEntry` gained only `label:`; `deleteTag` passes `"Delete Tag"`, byte-same behaviour); nothing taken ⇒ nothing written, no entry, `[]`. Pins `Tests/VariorumCoreTests/UnusedTagsTests.swift` (7): the listing's wearers (live note · block in a note · snippet · Trash-held note · Trash-held block → off; never applied · removed · removed-then-trashed → on; Put back keeps it off; removing the last wearer lists it), the subtree (and the brain agrees tag by tag), per-wing twins, the region (complete per table×column over every arm; narrow against keystroke writes; woken by trash/application writes), the act's one stamp + one entry + whole undo/redo + the single delete's label unchanged, confirmed ∩ still-unused subtree-aware (worn since · Trash-held since · an unseen child · a child unconfirmed), nothing-left-writes-nothing (no outbox row, no entry). `swift test --filter UnusedTagsTests` 7/7 GREEN headless. **Mutation probes ANNOUNCED here (this commit), each an UNCOMMITTED edit on the committed tree restored by `git checkout --`:** M-E1 `unusedTags` asks `.library(countingTrashRevivable: false)` → expect `whatIsWornOrRevivableNeverLists` red (in-trash, block-in-trash listed); M-E2 `deleteUnusedTags` loses the `confirmed.isSuperset(of: subtree)` guard → expect `theActTakesOnlyWhatTheSheetShowedThatIsStillUnused` red (b with its unseen child, d with its unconfirmed child taken); M-E3 `deleteUnusedTags` loses the in-write worn guard → expect that pin red (a, f taken) AND `nothingLeftWritesNothing` red (x taken, an entry registered). RESULTS (all three red as predicted, each restored by `git checkout --`, `git status` clean, 7/7 green again): M-E1 → `whatIsWornOrRevivableNeverLists` red, 3 issues (the Trash-held note's and block's tags listed — and still listed after the Put back for the block still in the Trash); M-E2 → `theActTakesOnlyWhatTheSheetShowedThatIsStillUnused` red, 2 issues (b went with its unseen child, d with its unconfirmed child); M-E3 → that pin red (2) AND `nothingLeftWritesNothing` red, 4 issues (the worn x deleted, an outbox row written, an entry registered). The in-write guards are load-bearing |
| E4 | VX-840 app: the door, the sheet, the words; pins | DONE (this commit) — `CapabilityID.deleteUnusedTags` + its registry row (`.surface`, app scope, verb "Delete Unused Tags" = the undo label, note = the race refusal; `.deleteTag`'s home) and `TagManagerPane.surfaceCapabilities` (the surface walk's union carries it); `TagsViewModel`: `unused` held by `startUnused()` (`observeUnusedTags`, keyed per wing like `start()`), `deleteUnusedTags(_:) -> Int?` (the act through the session's runner — so onto the session's ⌥⌘Z stack); `TagManagerPane`: the door "Delete N unused tags…" in the foot beside New Tag…, drawn only while N > 0 (`showsSweepDoor`), its `.task(id: wing)` holding the count only while the pane shows; the sheet `UnusedTagsSheet` over a SNAPSHOT `UnusedTagSelection` (all checked; the LINKED boxes — unchecking a tag unchecks its listed ancestors, checking one checks its listed subtree; "under" = same stored wing + path prefix, `tagSubtree`'s rule), its destructive "Delete N Tags" the one confirm; the outcome in the pane's own line (`sweepLine(taken:)`: receipt muted / refusal alarm; retired on a wing switch, the sheet with it, and when the vocabulary grows — an ⌥⌘Z bringing them back, a new tag); the words in `TagManagerCopy` (P-828-4 drafts verbatim, PROVISIONAL). Pins `App/Variorum/VariorumTests/TagSweepTests.swift` (7: all checked at start; the subtree rule incl. another wing's twin path; no click sequence ever checks a tag without its subtree; the door's visibility + words; the line's three outcomes; the declaration; the model's road — live list, one "Delete Unused Tags" entry on the session's stack, the race's 0 with no entry). Mac `build-for-testing` TEST BUILD SUCCEEDED, no new warning in a touched file. RUN PENDING (the stage window). No Shared/ file |
| E5 | Self-assessment + the end-of-batch headless suite | DONE (this commit) — full core `swift test` at 9a49f7350: `VariorumCoreTests` 3677 tests / 494 suites PASSED (5 known issues; +7 / +1 over batch D's 3670/493 = `UnusedTagsTests`; PinBeltTests rides inside, passed); `StringsWorkbookTests` 32/4 PASSED; the 7 known "dependency not used" warnings (14 lines, build + test); `VariorumMCPTests` 549/100 with 7 issues, ALL the MCP socket harness (`MCPStopRoadsServerTests` ×2, `MCPStopEndsConnectionGrantsServerTests`, `MCPHarnessTimeLimitTests`, `MCPReaderAfterCloseTests`, `MCPDiscoverProbeServerTests`, `MCPCloseReasonTests` — "claude-code got no answer to its initialize" and its kin) — re-run ALONE (`swift test --skip-build --filter` the six): 31 tests / 8 suites PASSED in 12.0 s. This batch touches no MCP code (the vendored brain is read only by Settings) |

**Owed to a stage window for E1/E2 (named at E2; the WHOLE batch's list is the self-assessment's
PENDING section below):**
- Suites (TYPES): `SpellingDoorTests`, `SettingsTagsWingFollowTests`, plus the registry neighbours
  `CapabilityRegistryTests`, `ShellChromeTests`, `ShortcutCatalogTests`, `SettingsShapeTests`,
  `MCPPaneTabsTests` (mounts `AppSettingsView`), `WingSwitcherTests` (constructs `TagsViewModel`).
- **R-E1** (named before running): in `App/Variorum/Variorum/Registry/SpellingDoor.swift`, `case
  .checkDocument: #selector(NSText.checkSpelling(_:))` → `#selector(NSTextView.toggleContinuousSpellChecking(_:))`.
  Expect red: `aCheckStepsToTheNextMisspellingAndTurnsNothingOn` on all five surfaces (the flags move,
  nothing is selected) and `everyWritingSurfaceAnswersBothActs` (the selector); the declaration and
  refusal pins green. Uncommitted edit; `git checkout --` restores.
- **R-E2** (named before running): in `AppSettingsView.swift`, `.task(id: session.wing.currentID) {
  await tags.start() }` → `.task { await tags.start() }` (the pre-fix line). Expect red:
  `thePaneFollowsTheAppsWingLive` (the list stays `["alpha"]` after the switch); the other two green.
- Walk legs (dev store, both voices where a face is voiced): (1) Edit ▸ Spelling and Grammar holds
  exactly Show Spelling and Grammar ⌘: and Check Document Now ⌘;; (2) Write — a note with two
  misspellings, Spellchecking Off in Settings ▸ Editor: ⌘; selects the first, ⌘; again the second, no
  red underlines appear as typing resumes (the level stayed Off); (3) a live Takes pane and the quick
  entry box: ⌘; selects there; (4) ⌘: shows the panel; its Change corrects the word in Write (the
  DEBUG identity oracle stands — an ordinary text edit, autocorrect's road); (5) the keyboard on no
  text (e.g. a Library row) — ⌘; speaks "Spelling checks the text you're writing in — click into a
  note or a box first."; (6) Settings ▸ Tags open in Home reads "Tags — in Home" (Terminal: "tags —
  in home"); ⌘L to another wing — the pane re-lists that wing's tags and reads "Tags — in ‹wing›"
  without reopening; back to Home — Home's again.

#### Batch E — THE DESIGN FORK (E0 — proposed for the orchestrator's ruling BEFORE any of VX-840's act is built)

**Q-E1 — THE SHARED QUERY IS ABSENT FROM THIS TREE (the brief's stop condition, reported).**
`Sources/VariorumCore/Queries/TagUsageQueries.swift` does not exist at e0b15ded0: vx-809 has not
merged. It stands on `origin/vx-809-mcp-door-ergonomics` (tip c02250829), minted by 5279ec16a and
untouched since — read here with `git show` only; its signature is the record's paragraph exactly,
and it depends on nothing this tree lacks (`Queries.tagSubtree` only). The brief's fallback
("compiling blind is acceptable for the app half") would leave this SHARED branch unbuildable for
batch B's remaining window and the merge gate — declined on that ground alone. Three roads:
- **(a) LEAN — import the owner's file byte-identical, as its own commit** (`git show
  5279ec16a:Sources/VariorumCore/Queries/TagUsageQueries.swift`; nothing else of vx-809 — not its
  tests, not its wire change), the message naming the source SHA. Not a twin: one definition, the same
  bytes, minted by its owner; git merges an identical add cleanly whichever run merges first, and if
  vx-809's ladder edits the file later the merge-in takes theirs and re-runs `TagUsageQueriesTests` +
  this batch's pins (the record's "whoever merges second" line already binds that). Buys: the real
  predicate under every pin tonight, a real in-transaction re-check, and a walk in this run's window.
- **(b) a `#if VX809_MERGED` seam:** the production call written against the signature inside an
  inactive branch (parsed, never type-checked — the branch builds today); the act pinned core-side
  against a test-double predicate; the door NOT rendered until the merge-in deletes the flag lines
  (P-2: no predicate, no act). Costs: VX-840's walk PENDING the merge-in; code type-checked only
  then; a forgotten flag is a door that never renders.
- **(c) hold VX-840** until vx-809 merges to main and main is merged into this branch.

**Q-E2 — P-828-4, the bulk act's undo shape.**
- **(b) LEAN — ONE compound entry, "Delete Unused Tags"** ("Undo Delete Unused Tags" on ⌥⌘Z). One
  operation, one write transaction, ONE stamp: each confirmed root's subtree is tombstoned through
  `deleteTag`'s own row body (`tombstoneTagSubtree` — the subtree rule, the per-tag cascade trigger)
  and the passes concatenate into ONE `TagDeletionPass`; the entry is VX-247's machinery unchanged
  (`registerTagDeletionEntry`, gaining only a label argument) — its inverse already walks a pass in
  path order (parents before children, every revived path rebuilt from its live parent), so a
  multi-root pass needs no new undo code, and its redo re-deletes exactly what the undo revived. Why:
  her ask is ONE confirmed act; the house shape is one act = one entry (import, duplicate, diverge,
  the MCP door's one ⌥⌘Z per write); and one transaction means the act is all-or-nothing. Accepted
  consequence, stated: the redo is the single delete's redo — a tag she applied to a note between
  the undo and the redo goes again with its application (VX-247's own redo shape; the next undo
  brings both back on that stamp).
- (a) N entries — `deleteTag` once per root, N transactions, N "Delete Tag" entries: twelve tags
  swept means twelve ⌥⌘Z presses to take the act back, and a failure midway leaves a half-swept wing.

**Q-E3 — the listing and the checkboxes.** "Unused" = `!tagSubtreeIsWorn(db, tagID:, scope:
.library(countingTrashRevivable: true))` for every live tag of the shown wing (`Queries.allTags`'s
wing scope). WORN is subtree-honest, so UNUSED is downward-closed: every listed tag's whole subtree
is listed too. Options:
- **(i) LEAN — list every unused tag** (her "list every tag"), indented as the manager indents, all
  checked; the boxes are COUPLED — unchecking a tag unchecks its listed ancestors (an ancestor's
  delete takes everything under it), checking a tag checks everything listed under it — so a checked
  tag's subtree is always wholly checked and the act deletes exactly the checked set.
- (ii) list only each unused subtree's ROOT, the row naming how many ride under it (a child kept
  only by keeping its whole root).
- (iii) independent boxes; a checked parent over an unchecked child refuses at the confirm.

**The act's race rule (stated with (i), D's ruled "ids ∩ still-qualifying" carried to subtrees):**
inside the ONE write, walking the confirmed ids in path order, a tag's subtree is taken only when the
tag is still live, still unused by the same predicate, and every live tag under it NOW is in the
confirmed set (a child minted since the sheet opened keeps its ancestors — the act never deletes
more than the sheet showed); otherwise the walk descends to its confirmed children. Nothing left ⇒ a
refusal, nothing written, no entry registered.

**Q-E4 — the door.**
- **(a) LEAN — a held count, D's ruled shape:** a named-region observation re-fetched on a reader
  after each commit (VX-670's discipline, `observeEmptyTrashBlocks`' precedent), keyed to the shown
  wing; the door "Delete 3 unused tags…" in the pane's foot row beside New Tag…, NOT rendered at 0
  (P-2; batch D's ruling 6). The region names `tag`, `post_tag`, `block_tag` and only the columns the
  predicate reads on `container` / `block` (`id`, `deleted_at`) — so autosave's `container` stamps and
  `variant` writes never wake it (P1; feasibility checked at build, else whole tables, D's shape).
- (b) the door rendered while the wing holds any tag; the read runs once at the press; zero speaks
  the refusal in the pane's line.

**The words (drafts — PROVISIONAL, hers to tune; sentence case).** Door "Delete 3 unused tags…" /
"Delete 1 unused tag…" (registry verb "Delete Unused Tags"); help "Tags no note, snippet or thing in
the Trash wears — you choose which go". Sheet title "Unused tags in ‹wing›"; its line "No note or
block wears these — nothing in the Trash does either. Uncheck any you want to keep; ⌥⌘Z puts the
rest back." Buttons Cancel · "Delete 3 Tags" (destructive; grey at 0 checked). Receipt — in the
pane's own message line (the Settings window has no status bar; today's single delete speaks nothing
and the list changing is its answer): "Deleted 3 unused tags — ⌥⌘Z puts them back." Race refusal:
"None of those tags are unused any more — nothing was deleted."

**Stated now so the ruling can redirect them — NOT forks (E1, E2 build to these while E0 waits):**
- **VX-798.** Two registry declarations (doors `[.menuBar]`, scope `.app`, no takes
  access), AppKit's own titles — "Show Spelling and Grammar" ⌘: and "Check Document Now" ⌘; —
  rendered in an Edit ▸ Spelling and Grammar submenu right after Find (AppKit's own Edit order), the
  two items ONLY. Availability `always`; the act sends `showGuessPanel(_:)` / `checkSpelling(_:)` down
  the responder chain (`NSApp.sendAction(_:to: nil, from:)` — the Paste Without Line Breaks precedent:
  "a text view holds the keyboard" is a fact `CapabilityContext` cannot see and the chain answers
  exactly), and where nothing takes it the door SPEAKS its declared refusal (P-2). NOT built: AppKit's
  three toggles (Check Spelling While Typing · Check Grammar With Spelling · Correct Spelling
  Automatically) — they write the per-view flags UNDER the A24 setting and would turn continuous
  checking on without turning completion off, the §3 crash pairing; SwiftUI's `TextEditingCommands()`
  is refused for the same reason (and it would add a second Find menu). Probe (throwaway, offscreen
  TK2 `NSTextView` in a window, macOS 27.0.1): `checkSpelling(nil)` selected "brwn" then "jumpd",
  `isContinuousSpellCheckingEnabled` stayed false, `isAutomaticTextCompletionEnabled` stayed true;
  outside a window it did nothing. Pins: the pair declared, keyed and in the helper; the act on each
  live editor kind (selects the first misspelling, the A24 flags untouched); the refusal. Red-on-old:
  an Improvement — the old tree has no door; the behavioral revert R-E1 (the check door's selector →
  `toggleContinuousSpellChecking(_:)`) must turn the flags pin red.
- **VX-838 — the mechanism (traced at the code):** `AppSettingsView.body` starts the pane's model with
  a plain `.task { await tags.start() }` (AppSettingsView.swift:223) — once per window lifetime; `start()`
  reads `session.wing.currentID` at subscription and its `observeTags(wingID:)` stays pinned to that
  wing. A switch changes `session.wing.currentID` and nothing restarts it, so the list keeps the old
  wing's vocabulary — and a root tag minted from that stale list lands in the NEW wing
  (`createTag(…, wingID: session.wing.currentID)`) and never appears in it. RootView's twin model has
  always been `.task(id: session.wing.currentID)` (RootView.swift:629); TagsViewModel's comment
  ("the shell restarts this task when the wing switches") is true there only. **The fix:** the
  task keyed on the wing; the model adopts its list AND its wing's name from ONE read (the header can
  never name a wing other than the one listed, and a wing rename re-titles it live); the header for
  the Tags pane reads "Tags — in ‹wing›" (the toolbar's own "in ‹wing›" words, voiced as chrome).
  Pins: a mounted follow pin (red-on-old by R-E2: `.task(id:)` → `.task`), the model's one-read
  name pin, the pure title pin. Test seam: an internal `tags:` init parameter on `AppSettingsView`
  (production unchanged by default) — batch D's ruled `model:` precedent (ruling 8).

**ASKED OF THE ORCHESTRATOR (one ruling unblocks E3–E4):** Q-E1 (a)/(b)/(c); P-828-4 (Q-E2);
Q-E3's listing; Q-E4's door; the words (or leave them PROVISIONAL).

#### Batch E — IMPLEMENTER SELF-ASSESSMENT (Opus, 2026-11-05)

**Not done (first line, by the brief):** no app-suite RUN, no app red-on-old revert RUN, no walk, no
Debug launch — all stage-gated, the orchestrator's (named exactly below). No canon, QUESTIONS or other
shared ledger touched (drafts below). No `Sync/`, custody, keychain or `Shared/` file. Every piece is
built, the Mac target and its tests compile (build-for-testing green at 9a49f7350), and every headless
half is green.

**VX-798 — what was missing (an Improvement, no bug mechanism).** A SwiftUI-lifecycle menu bar carries
none of AppKit's Spelling and Grammar items, and nothing put them back — so spelling had no menu home
and no chord; only the A24 level (Settings ▸ Editor ▸ Spellchecking) existed, and it is a toggle. Built
(70b4a315e): the macOS pair under AppKit's own titles and keys, registry-declared
(`.showSpellingPanel` ⌘: · `.checkSpelling` ⌘;, app scope, `[.menuBar]`, `always`), in an Edit ▸
Spelling and Grammar submenu after Find; the act (`Registry/SpellingDoor.swift`) walks the responder
chain — `NSApp.sendAction(_:to: nil, from:)` on the menu's road — and the door speaks its declared
refusal where nothing took it. **Which responders answer** (every one an `NSTextView`, `NSText`
implements both acts, none of ours overrides them): Write's editor and the inline book/pool editors
(`EditorTextView`), every pane — live takes, Read's edit face, lenses, Compare, AND read-only panes,
which select the misspelling but cannot be edited by the panel's Change (`PaneTextView`), the quick
entry and quick-note boxes (`CaptureNSTextView`), the comment fields (`CommentNSTextView`), and any
text field's field editor (Settings' search, the find bar) — standard macOS. One-shot by construction:
no selector writes a checking flag, and AppKit's three toggles are deliberately absent (each writes a
per-view flag under the A24 setting; the first would turn continuous checking on with completion still
on — the TEXTKIT2 §3 pairing).

**VX-838 — the mechanism, traced on this tree.** `AppSettingsView.body` started the Tags model with a
plain `.task { await tags.start() }` (AppSettingsView.swift:223 before the fix) — once per window — and
`start()` reads `session.wing.currentID` at subscription, so its `observeTags(wingID:)` stayed pinned to
the wing open at the time. A switch restarted nothing: the list kept the old wing's vocabulary, and a
root tag minted from it landed (`createTag(…, wingID: session.wing.currentID)`) in the NEW wing, unseen.
RootView's twin model was always `.task(id: session.wing.currentID)`. **The fix (a7d6ab3fe):** the task
keyed on the wing; the model adopts its list and its wing's name from ONE read (`TagsViewModel.Listing`
— a rename re-titles live, and the header can never name another wing than the one listed); the header
reads "Tags — in ‹wing›" (`AppSettingsView.title(of:tagsWingName:)` → `TagManagerCopy.title`).

**VX-840 — built to the fork's ruling (4b1d1d47d), one pointer per piece.**
- `Sources/VariorumCore/Queries/TagUsageQueries.swift` — vx-809's brain, VENDORED byte-identical from
  5279ec16a (blob 90472b916, unchanged at their tip 8b32bf03f), its own commit c1554f958, never edited.
- `Sources/VariorumCore/Queries/UnusedTagQueries.swift` (new) — `Queries.unusedTags(_:wingID:)` (the
  brain per tag, `.library(countingTrashRevivable: true)`; once per maximal unused subtree — UNUSED is
  closed downward), `Queries.unusedTagRegions()` (narrowed to `(id, deleted_at)` on
  container/block/wing), `AppDatabase.observeUnusedTags(wingID:)`.
- `Sources/VariorumCore/Operations/Operations+Tag.swift` — `deleteUnusedTags(_:)` (one write, one
  stamp, confirmed ∩ still-unused subtree-aware inside it, ONE "Delete Unused Tags" entry);
  `registerTagDeletionEntry` gains only `label:` (`deleteTag` passes "Delete Tag" — byte-same behaviour).
- `App/Variorum/Variorum/Features/Tags/TagsViewModel.swift` — `unused` / `startUnused()` /
  `deleteUnusedTags(_:) -> Int?`.
- `App/Variorum/Variorum/Features/Settings/TagManagerCopy.swift` — the words (PROVISIONAL) and the pure
  `UnusedTagSelection` (the linked boxes).
- `App/Variorum/Variorum/Features/Settings/AppSettingsView.swift` — `TagManagerPane`'s counted door,
  its keyed `.task`, the sheet (`UnusedTagsSheet`), the line (`sweepLine(taken:)`).
- `App/Variorum/Variorum/Registry/Capability.swift` + `CapabilityRegistry.swift` — `.deleteUnusedTags`.

**Pins — and exactly what makes each red.**
| Pin (suite TYPE · test) | Red on old because | Behavioral revert that shows it |
|---|---|---|
| `SpellingDoorTests` (app, 5; the act parameterized 5 surfaces × 2 levels) | new feature — compile-red on old (no acts, no door) | **R-E1:** `SpellingDoor.swift`, `case .checkDocument: #selector(NSText.checkSpelling(_:))` → `#selector(NSTextView.toggleContinuousSpellChecking(_:))` → expect `aCheckStepsToTheNextMisspellingAndTurnsNothingOn` red on all five surfaces + `everyWritingSurfaceAnswersBothActs` red; the declaration and refusal pins green. `git checkout --` restores |
| `SettingsTagsWingFollowTests` · `thePaneFollowsTheAppsWingLive` (app, mounted) | the plain `.task` pins the list to Home: after the switch it stays `["alpha"]` | **R-E2:** `AppSettingsView.swift`, `.task(id: session.wing.currentID) { await tags.start() }` → `.task { await tags.start() }` → expect it red; the other two green |
| `SettingsTagsWingFollowTests` · the name and title pins | new API (`shownWing`, `title(of:)`) — compile-red on old | — (guards) |
| `UnusedTagsTests` (core, 7) | new feature — compile-red on old; STRENGTH shown by M-E1…M-E3 on the new code, all red as predicted (E3's row) | — (ran green headless) |
| `TagSweepTests` (app, 7) | new feature — compile-red on old | **R-E3 (optional, pure):** `TagManagerCopy.swift`, `UnusedTagSelection.toggle` — delete the `for other in rows where Self.isAncestor(other, of: row) { checked.remove(other.id) }` line → expect `theBoxesCarryTheSubtreeRule` + `noClickSequenceEverChecksATagWithoutItsSubtree` red, the rest green |

**PENDING (the orchestrator's stage window).**
1. Mac suites, by TYPE (a zsh array): `SpellingDoorTests` · `SettingsTagsWingFollowTests` ·
   `TagSweepTests` — and the neighbours the diff reaches: `CapabilityRegistryTests` ·
   `ShellChromeTests` · `ShortcutCatalogTests` · `SettingsShapeTests` · `ChromeLineLimitTests` ·
   `MCPPaneTabsTests` (mounts `AppSettingsView`) · `WingSwitcherTests` (constructs `TagsViewModel`).
2. Reverts R-E1, R-E2 (R-E3 if the window allows), each one suite, then restore.
3. The walk (dev store; both voices where a face is voiced): legs (1)–(6) as named in LIVE STATUS, plus
   (7) THE SWEEP — in a wing holding a tag on a note, a tag whose only note is in the Trash, a tag she
   removed from a note, and a parent with an unused child: Settings ▸ Tags shows "Delete N unused
   tags…" with N = only the removed tag and the parent's subtree (the Trash-held one is NOT counted);
   the sheet lists them checked; unchecking the child unchecks the parent; Cancel changes nothing;
   re-open, Delete — they leave the list, the receipt "Deleted N unused tags — ⌥⌘Z puts them back."
   speaks in the pane, the door disappears at 0; ⌥⌘Z in the main window ("Undo Delete Unused Tags")
   brings every one back at once and the receipt retires; ⇧⌥⌘Z takes them again; (8) the door follows
   a wing switch (the other wing's count, or no door).

**PROVISIONAL (QUESTIONS entries at the merge moment).** P-828-3 (a Trash-held wearer keeps its tag in
use — built through the brain's `countingTrashRevivable: true`); P-828-4 (one combined "Delete Unused
Tags" entry, the redo consequence as ruled); Q-E3 (i) the linked boxes and Q-E4 (a) the counted door
(the ruling's header: PROVISIONAL for her morning sitting); the VX-840 words verbatim as drafted; and
VX-798's refusal words ("Spelling checks the text you're writing in — click into a note or a box
first."), new and mine.

**For the orchestrator's canon pass (DRAFTED — not applied; the two-file rule).**
- SurfaceContracts, "The app" Keyboard family — ADD before "The Shortcuts & Dictionary helper
  exists…": "⌘; is Check Document Now and ⌘: Show Spelling and Grammar (Edit ▸ Spelling and Grammar):
  one-shot acts on whatever text holds the keyboard — never the continuous level, whose one home is
  Settings ▸ Editor ▸ Spellchecking — and where no text holds it the door says so (VX-798)."
- SurfaceContracts, "The app" sidebar bullet — after "is tag management's home", ADD: "Settings ▸ Tags
  names the wing its vocabulary is ("Tags — in ‹wing›") and follows the app's wing live (R-828-2); while
  the wing holds a tag nothing wears — no live note or block, nothing in the Trash — its foot offers
  "Delete N unused tags…", a sheet of every such tag checked, its boxes bound to the subtree rule,
  deleted in one act with one ⌥⌘Z entry, "Delete Unused Tags" (VX-840, PROVISIONAL P-828-3/-4)."
- AppSpec §9 "Tags, comments, presentation, references" — ADD: "**deleteUnusedTags(ids)** deletes, in
  one transaction on one stamp, each confirmed tag's subtree that is still unused
  (`Queries.tagSubtreeIsWorn`, Trash-revivable wearers counting) and wholly confirmed; one "Delete
  Unused Tags" structural-undo entry on deleteTag's inverse and redo; nothing left writes nothing
  (VX-840)." And in "Structural undo and redo"'s list: "deleteTag" → "deleteTag and deleteUnusedTags".
- AppSpec §12 "The app" Keyboard family — ADD "⌘; ⌘: spelling, once (VX-798)".
- AppSpecRecord: the dated entry + the narrative under §9 (tags) and §12 (Settings ▸ Tags; the menu bar).
- MOBILE PARITY: nothing mobile-visible (the phone's tag manager has no wing face and no sweep; iOS's
  own text menus carry spelling). A VM twin of the sweep in the phone's tag manager is a candidate
  ticket — the orchestrator's call.
- Rulings reconciled: R-828-2 — "names its wing … FOLLOWS the app's wing live": both built, the follow
  covering a rename too; R-828-4 — VX-840 built here, consuming vx-809's mint (vendored, Q-E1 (a)).

**Self-assessment.** CONFIDENT: VX-838's mechanism (read in the code; the fix is RootView's idiom); the
sweep's core (exact rows on every wearer shape, the region pinned per column, the act's in-write
guards each proven load-bearing by a mutation probe, undo/redo whole through VX-247's untouched
machinery); VX-798's one-shot property (probed offscreen before the build, pinned on five surfaces at
two levels). FLAGS FOR THE COLD REVIEWER: (a) VX-798 is editor-ADJACENT: no editor-seam file changed,
but the Spelling panel's Change edits through `NSTextView`'s ordinary input path into the editor's
delegate — autocorrect's road at "check and correct" — so walk leg (4) runs it under DEBUG's identity
oracle; (b) the two items are never grey (availability `always`; P-2 is met by the spoken refusal —
Paste Without Line Breaks' precedent), and field editors answer too, so ⌘; in a search field checks
that field; (c) with the Spelling panel itself key, the nil-target chain starts at the panel —
AppKit-standard, unverified in our app (walk); (d) `unusedTags` asks the brain once per maximal
unused subtree — correct only because WORN is subtree-honest; `theSubtreeDecides` checks it tag by
tag; (e) the count's region is COLUMN-narrowed (`container`/`block`/`wing` to `(id, deleted_at)`) —
it rests on GRDB's column-precise UPDATE tracking, pinned both ways; (f) the act is wing-agnostic over
the ids it is handed (the door hands one wing's); (g) the redo re-deletes a tag applied between undo
and redo, with its application (ruled: the single delete's own semantics); (h) the sheet is a
SNAPSHOT — the door's count moves live, the open sheet does not; the act's in-write re-check is what
keeps it honest; (i) the pane's sweep line retires on a wing switch and when the vocabulary grows (an
⌥⌘Z, a new tag), not on a later single delete — a stale "Deleted N…" can sit beside one; (j) RootView's
`TagsViewModel` now also reads the wing's name in its observation (∝ one row; a wing rename wakes it);
(k) `AppSettingsView` gained an internal `tags:` init seam (D's ruling 8 precedent); (l) the vendored
file must stay byte-identical — the merge-in takes theirs.

**Files touched (the whole batch):** `Sources/VariorumCore/Queries/TagUsageQueries.swift` (vendored,
vx-809's) · `Sources/VariorumCore/Queries/UnusedTagQueries.swift` (new) ·
`Sources/VariorumCore/Operations/Operations+Tag.swift` · `Tests/VariorumCoreTests/UnusedTagsTests.swift`
(new) · `App/Variorum/Variorum/Registry/Capability.swift` ·
`App/Variorum/Variorum/Registry/CapabilityRegistry.swift` ·
`App/Variorum/Variorum/Registry/ShortcutCatalog.swift` · `App/Variorum/Variorum/Registry/SpellingDoor.swift`
(new) · `App/Variorum/Variorum/EditorCommands.swift` ·
`App/Variorum/Variorum/Features/Settings/AppSettingsView.swift` ·
`App/Variorum/Variorum/Features/Settings/TagManagerCopy.swift` (new) ·
`App/Variorum/Variorum/Features/Tags/TagsViewModel.swift` ·
`App/Variorum/VariorumTests/SpellingDoorTests.swift` (new) ·
`App/Variorum/VariorumTests/SettingsTagsWingFollowTests.swift` (new) ·
`App/Variorum/VariorumTests/TagSweepTests.swift` (new) · this record.

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

#### Batch D — ORCHESTRATOR VERIFICATION (stage window "vx-828-batchD", 2026-11-05, GO 03:03)

Hand-back verified against git first: worktree clean at 457101726, the seven commits as listed,
`EmptyBlockSweepTests` re-run green headless by the orchestrator (15/15); the op read line-by-line
(in-transaction re-read over every wing, confirm ids ∩ still-qualifying with dedupe, intents only
through `mintPurgeIntents`, empty answer writes nothing); the band read in the diff (the overlay →
a laid-out `VStack` foot). One correction to the hand-back's window list: **"TutorialWalkTests" is
a FILE of eleven suites, not a TYPE** — the two Trash-relevant TYPEs (`TutorialDeletionActsTests`,
`TutorialDoorTests`) ran instead.

**Part 1 (suites):** ONE run, 18 suites / 196 tests, ALL GREEN in 35.9 s —
TrashEmptyBlockSweepTests (7) · TrashMessageBandTests (2) · TrashMultiSelectTests ·
TrashFirstPaintTests · TrashPurgeDoorsTests · TrashConfirmEdgeTests · TrashPurgeSharedLayerTests ·
TrashSurfaceTests · TrashPoolHonestyTests · SnippetGroupTrashTests · IAAndTrashShapeTests ·
RecoveryDoorsTests · CapabilityRegistryTests · ShellChromeTests · ChromeLineLimitTests ·
TutorialDeletionActsTests · TutorialDoorTests · TypedReturnKeyTests (32, the re-show baseline).
2 warnings = the known anonymous `Date.swift:37` harness noise (batch A's same class).

**Part 2 (reverts, each an uncommitted edit restored by `git checkout --`, tree clean after each):**
- **R-D4** (body back to `list.overlay(alignment: .bottom) { messageFoot }`): EXACTLY the two
  geometry `#expect`s red (`foot.minY >= list.maxY - 0.5`, `list.height < idle.height - 0.5`); the
  order guard stayed green. Restored → 2/2 green.
- **Batch A's owed CLEAN red re-show of revert 1** (`if false,` on the wordStart arm): the three
  key pins failed at PLAIN `#expect`s (store-slot comparisons), 12 issues, the RUN COMPLETED —
  zero `_checkSubscript` traps, zero crash markers in the log, ZERO new `.ips` from the red run.
  The 99fd1dd58 hygiene holds: red is clean now. Restored → 32/32 green. Batch A's PENDING (1)
  is CLOSED; only the phone suites at the merge gate remain for batch A.

**The window's `.ips` accounting (baseline 024952, count 8):** TWO new — 030714, 030816 (count 10,
both mid-window, NONE from the walk; the count was re-checked at quit, still 10). Both are the
coordinator-pre-classed **swift-testing ABI.Record JSON-encoder stack overflow** (EXC_BAD_ACCESS at
`___chkstk_darwin` under `Testing ABI.Record.encode(to:)` → `__JSONEncoder.wrapGeneric` recursion,
~130 frames, no Variorum or SQLCipher frames; each ~5 s after its host's launch, AFTER the verdict
printed — teardown event-flush). The coordinator classed both in-window ("that's the encoder class,
not VX-855"); the green re-runs produced none. NOT this run's code; the class rides the harness.

**Part 3 (the walk — dev store Debug `io.lduarte.Variorum.debug`, scratch note "2026-11-05"/
"sweep alpha" in Home; cast minted by the editor's own roads):** three Return-chained empties
backspace-CARVED alone; a worded block Delete-Block'd alone ("worded husk"); an empty block with a
FILED comment ("keeps this husk out of the sweep") Delete-Block'd alone (the carve would refuse a
commented block — the Delete Block door took it); a mid-word Return INSIDE "beta" (batch A's arm,
seen again live: the word rode down whole) making a divide successor that was emptied by hand and
carved — an empty husk whose `derived_from` names the LIVING "sweep" block. Legs, Study voice:
(a) the door drew "Delete 3 empty blocks…" LEFT of Empty Trash — N counted ONLY the three carved
empties; the worded, commented and linked husks all sat visibly in the list, uncounted; (b) the
confirm spoke P-828-10's N>1 draft VERBATIM with the count; CANCEL changed nothing; (c) the kind
filter set to Notes neither hid nor narrowed the door (same label, same count, zero block rows
listed); cleared; (d) Delete for Good: the three empties left the listing at once, the worded /
commented / linked husks STAYED, the door DISAPPEARED (count 0 ⇒ not rendered), and the receipt
spoke IN ITS OWN BAND below a full viewport of rows — "3 empty blocks are gone from the app now —
the app's own cleanup removes the bytes." (the never-synced population, right for this store) —
never over a row (VX-636 seen live). (e) TERMINAL voice (⌘K "Use Terminal Voice"): two fresh
Return-chained empties carved; the Trash drew "Delete 2 empty blocks…" (the door RE-APPEARED from
0); the N=2 confirm verbatim; Delete for Good; the receipt in the band, monospace, below the rows;
the door gone again at 0; the three protected husks untouched throughout. Voice restored to STUDY
(⌘K), ⌘Q, both strict pgreps empty — zero instances, posture unchanged. One machinery note: the
guard tripped once mid-walk on the KNOWN self-inflicted idle-reset (a 1 s gap between injected
acts); idle was watched climbing (11→17 s) before resuming — nobody at the machine; ≥3 s spacing
held thereafter.

**Batch D is VERIFIED** (ledger rows 7–8 flipped). Owed at the merge gate only: the phone suites
(batches A+D: MobileStructuralTests · MobileTakeStructureTests · MobileTrashTests ·
MobileNoteTrayTests · MobileVersionsTests). For closeout: the implementer's VM-twin candidate (a
phone Trash sweep door) rides the MOBILE PARITY line — nothing mobile-visible tonight.

#### Batch C — THE FORK'S RULING (orchestrator, 2026-11-05 — build C1–C4 to this; everything below PROVISIONAL for her morning sitting)

1. **Q1 / P-828-11 the place's anchor: (b) CONFIRMED** — the place is the ON-SCREEN ROWS, each
   re-resolved by id into the current sort; fallback the next surviving on-screen row, then the
   nearest surviving neighbour, then the top; the opened row is NOT an anchor while another
   on-screen row survives. Reason, adopted from the trace: under the default edited-newest-first
   sort any keystroke in the note moves the opened row to the TOP, so (a) re-creates her exact
   complaint in the most common flow — and her sentence is "keeping where you were", which is the
   rows that were before her eyes, not the row that left. (c) adds a threshold with no gain: (b)
   already lands the old neighbourhood whether or not the opened row moved. **The brief's "anchors
   on the row's ID" line is superseded by this ruling** (it was the orchestrator's translation of
   the ticket, and the fork surfaced the trap in it).
2. **Q2 / P-828-12 "selected" on return: (b) CONFIRMED** — the return mark: the opened row wears
   the existing subject face, no panel. (a) is refused STRUCTURALLY, not by taste: the Library's
   contract pins the controls row's line count, and the panel-on-return wraps it at the default
   window. (c) drops her "the row you left from selected" clause. Clear roads as proposed (next
   row click, new question, mode switch, next open). Accepted consequence, stated: when the opened
   row moved to the top under the edited sort, the marked row may sit off-screen from the restored
   place — the place wins, and the mark is findable at the top.
3. **Q3 / P-828-13 which leaves and returns: (b) CONFIRMED** — every leave records, every
   in-session return restores while the question is unchanged (R-18l-1's in-session shape, the
   family precedent); only a row-open makes the Q2 mark (only then does "the row you left from"
   exist).
4. **Q4 / P-828-14 Cards: CONFIRMED as proposed** — the place only, no mark. Cards show no
   selection state today; minting a new card face is a product call that is hers, not tonight's.
5. **Q5 P1's reading: ACCEPTED — "proportional to the place's depth."** The landing reads nothing;
   the model's re-read is bounded by the place's listed position plus one page — a quantity SHE
   created by scrolling there once (paying exactly this cost in pages), bounded by her session,
   never by the corpus. One statement, off the main thread, refresh()'s own cost class. The
   windowed upward-paging listing is a new subsystem — disproportionate tonight; if deep places
   ever feel slow it becomes its own ticket.
6. **Scope limits: CONFIRMED as stated** (Timeline out; the capped books region keeps its own top;
   the answer sheet's place is its groups; nothing persisted or synced). ONE amendment: the
   split's two-Library-panes-share-one-memory shape is accepted PROVISIONAL and FLAGGED for the
   cold reviewer — if a per-pane memory is trivially reachable, prefer it (a two-Library split
   restoring pane 1's place in pane 2 is odd); if not, keep shared and say so in the
   self-assessment.
7. **P-828-5: ruled NOT CHEAP — TICKETED as VX-856** (Improvement · Books · Low, Backlog; the
   assessment's reasons on the ticket). Nothing of it builds in this run.

The pin plan is accepted as proposed (resolver pins pure; model pins; mounted whole-catalog pins
staged through NSClipView, red-on-old = lands at the top). The diff not touching
`App/Variorum/Shared/` is noted — batch C adds no phone suites to the merge gate.

#### Batch C — ORCHESTRATOR VERIFICATION, WINDOW 1 (stage "vx-828-batchC", 2026-11-05, GO 04:15 — suites + reverts GREEN, the walk RED; the window released at the red per the coordinator's call)

**Part 1 (suites):** first run 258 tests / 38 suites — 255 green, THREE of the five new MOUNTED
pins red ON THE NEW TREE. All three were FIXTURE bugs, not product (the implementer's diagnosis,
mechanisms recorded in "Batch C — THREE MOUNTED PINS RED ON THE NEW TREE"; fix 00569c8ce, pins
only). Re-run of `LibraryReturnPlaceMountTests` after the fix: 5/5 GREEN. The 2 warnings are the
known anonymous `Date.swift:37` noise. Zero new `.ips` in the entire window (count 10 before and
after; no Problem Reporter at quit).

**Part 2 (reverts, uncommitted edits on the committed tree, each restored, tree clean after each):**
- **R-C1** (resolve → `survivors.first`): red EXACTLY `theOpenedRowIsNotTheAnchorWhileAnotherOn
  ScreenRowSurvives` + `theOpenedRowsOwnMoveDoesNotMoveThePlace`; the other 18 green. Restored.
- **R-C2** (`listingAppeared` → bare `search()`): 6 of 9 model pins red (depth, opened-row move,
  deleted row, sheet, day, each-pane — 14 issues), the new-question + wing-switch guards GREEN as
  predicted. Restored.
- **R-C3** (`landingOwed = false`): the four return pins red, the new-question guard green.
  Restored.

**Part 3 (the walk) — RED ON THE PRIMARY LEG, live.** Study voice, the Library at ~47 rows:
- Probe 1: scroll deep into the prince's chapters, open XXII by TITLE, one-char edit (typed and
  deleted — bytes unchanged, stamp moved), ⌥⌘[ back → the list landed AT THE TOP (Books header
  visible, offset 0), not at the chapters neighbourhood. **The MARK worked:** XXII sat at the top
  of the edited sort wearing the subject face, no panel.
- Probe 2 (differential — NO edit, same road): open Dedication by title, ⌥⌘[ back → the TOP again.
  So the failure is the live return road itself, independent of the sort move.
- **The clue for the diagnosis:** the mark SURVIVED the round trip, so the per-pane place memory
  persists across the trip — what failed is the RESTORE side (`listingAppeared` → `owesReturn` /
  the landing) in the REAL RootView swap, which the mounted harness does not reproduce (it
  re-mounts onto the same held model by hand). The mounted pins are necessary but not sufficient;
  a pin that reproduces the real teardown road is owed with the fix.

**Status:** rows 1–2 of the batch C build stand (pure + model + neighbours green; reverts shown);
VX-823 is NOT verified — the live return fails. Handed back to the implementer with both probes.
The stage was RELEASED at the red (vx-805's Unit B was waiting); the fixed walk re-runs in a
fresh window.

#### Batch C — WINDOW 2, R-C4 HOLLOW + R-C4b NAMED (orchestrator, live during "vx-828-batchC2")

R-C4 as named (add `memory.window.isMeasured` to `landIfReady`'s guard) ran GREEN on both road
arguments — the revert is HOLLOW, not yet the pin: the per-pane memory persists across the trip
(the same persistence that carries the mark), so `window.isMeasured` remains true from the
pre-trip scrolling and the added guard blocks nothing on any return from a scrolled pane.
**R-C4b, named before running (the honest pre-fix shape):** disable the fix's two new landing
triggers — the `landIfReady("appear")` call in the appear closure and the `landIfReady("height")`
call in the mount-geometry closure — so a landing again requires a fresh scroll READING on the
new mount, which the real arm swap never sends. Expected: both road arguments red at the top with
the decide/appear trace printed and no `landing` line. Uncommitted edit on the committed tree
(3a7dbff78); `git checkout --` restores.

*(Correction beside this section — ladder round 1 FINAL CALLS, `notes/plans/fixes/vx-828-ladder-round1.md`, 0b8fd184b: R-C4's guard reads the scroll's MOUNT-LOCAL window (`LibraryPlaceScrollMemory` is per-mount `@State`), which the hosted mount's own unavoidable scroll reading fed — not a window persisting across the trip (that is the model-held `placeMemory.windows`, which the guard never reads); the road pin's red is now R-C4 under the `LibraryPlaceTrace.withholdsReadingsUntilAim` seam.)*

#### Batch C — ORCHESTRATOR VERIFICATION, WINDOW 2 (stage "vx-828-batchC2", 2026-11-05, GO 04:56, hard 60 — VX-823 VERIFIED)

**Suites:** LibraryReturnRoadTests + LibraryReturnPlaceMountTests + LibraryReturnPlaceTests —
15 tests / 3 suites ALL GREEN on the fix (3a7dbff78).
**Reverts:** R-C4 as named ran GREEN under the revert — HOLLOW (the per-pane memory persists
across the trip, so `window.isMeasured` holds from pre-trip scrolling; the guard blocks nothing).
R-C4b (named above before running — disable the appear/height triggers, the pre-fix reading-only
shape) ALSO GREEN on both road arguments: **the road pin is HOLLOW as red-on-old evidence** — the
hosted RootView mount still produces a scroll reading, so the pin never reproduces the live
no-reading condition even through the real router. Recorded, not fixed (the hallucination guard's
letter). The pin STAYS as a shell-road regression net; it must NOT be cited as this fix's
red-on-old. **The fix's red-on-old is the CROSS-WINDOW BEHAVIORAL PAIR:** window 1's walk red
LIVE on the pre-fix build (two probes, ⌥⌘[ to the top with and without an edit) → window 2's walk
green LIVE on the fix build, same legs, same store, both voices. FLAG FOR THE LADDER: a pin that
genuinely reproduces the no-reading mount (a pre-sized pane swap) is worth a reviewer's look.
**The walk (trimmed at the coordinator's call; the rest DEFERRED to the merge-gate window):**
Study — (a) deep title-open, NO edit, ⌥⌘[ → the exact neighbourhood restored, the opened row
wearing the mark, no panel, controls row one line; (b) same WITH a one-char edit (bytes restored)
→ the neighbourhood held while the opened row left for the top of the edited sort; scrolled up:
the row sits at the top WEARING THE MARK (P-828-12's accepted consequence, seen); (c) the
double-click road → place + mark green; (d) the row-menu Open road → place + mark green (the mark
moved to the newly opened row, the prior cleared — the clear roads seen live). Terminal — the
voice flip itself KEPT the place (appearance is not a question); title-open + edit + ⌥⌘[ → the
place held, the opened row to the top, mirror of Study. Zero new `.ips` across the window (count
10 before and after), no Problem Reporter at quit (checked per the new pre-release rule), both
strict pgreps empty, Study restored, posture unchanged. Walk machinery note: the guard's
idle-reset tripped once on a 1.5 s gap (self-inflicted, idle watched climbing 12→18 before
resuming); a stray pre-leg keystroke landed in QUICK ENTRY and was deleted — no note minted, no
store change (verified in the capture).
**DEFERRED to the merge-gate window (walk-only; the pins for each are GREEN):** sidebar leave,
Cards, the live search sheet, the armed day filter, the new-question / wing / mode resets, the
deleted-row survivor, the two-pane split. **Ledger row 6 flips VERIFIED** with this note.

#### Batch B — THE FORK'S RULING (orchestrator, 2026-11-05 — build B1–B4 to this; everything below PROVISIONAL for her morning sitting)

1. **Q-B1 "no note holds the keys": (a) CONFIRMED** — the mode row takes ⌘digit inside a note
   detail; otherwise the wing chord takes it UNLESS a writing surface holds the keyboard
   (`EditorTextView`, `PaneTextView`, a comment text view). Fields and the capture box pass the
   chord through — ⌘digit has no editing meaning in a text field, and the literal VX-560 reading
   would kill the chord exactly where it matters most (the Bookcase's resting caret sits in quick
   entry — VX-332 — and every ⌘digit landing puts it back there, so the second press would always
   be dead). (c) would jump wings mid-typing in a book's live note — refused. **This interprets
   her "text input" family — flagged plainly for her morning eye.**
2. **P-828-1: (i) a refusal on the one status seam** — the chord fired and did nothing, and a
   door that did nothing speaks a refusal (the seam's own law; OneWingChord/VX-560 precedents).
   Words as drafted, PROVISIONAL, hers to tune. **(ii) (a) CONFIRMED both roads** — ⌘N naming the
   CURRENT wing lands in its Bookcase, and the switcher's deliberate pick of the current row
   commits the same way (the brain's `.close` becomes a commit for a deliberate pick; Esc stays a
   plain close). Her VX-833 word is "consistent": every deliberate switch lands in the Bookcase,
   including the identity switch. Accepted consequence, stated: with one wing, ⌘1 outside a note
   is a go-to-Bookcase chord — harmless and arguably useful.
3. **Q-B2 which doors: (a) CONFIRMED** — ⌘L's sheet, the toolbar label, the ▾ list, the cycling
   word AND the chord all land on `.shelf`; receipts as today (the chord says "Now in …", the ▾
   list stays silent). Her reason was CONSISTENCY, verbatim, so no door is carved out on day one.
   **The cycling-word regression is REAL and recorded for her morning:** landing moves the word
   away from the pointer, so stepping wings by repeated clicks now needs a re-aim per step; if
   that pattern matters to her, flipping that one door is a cheap morning redirect (VX-834
   remains the eventual preference). Untouched, as listed: the follow, New Wing…, Delete Wing,
   revalidation, Compare's "go to ‹wing› ›", MCP show_in_app (vx-809's door).
4. **P-828-2 the marquee: (a) the ticker CONFIRMED** — rest 2.5 s, 25 pt/s leftward, 24-pt gap,
   seamless wrap, repeat; her "car-radio" names the ticker, not the ping-pong. The ruled half
   stands as proposed (width-decided, no clock when it fits, cancellable task keyed on
   (name, space), hard clips). Reduce Motion = no movement (rest at the start). The two edges as
   proposed: under 24 pt the label is not drawn; hidden sidebar keeps the old place and 160-pt
   cap. VX-833(2)'s build shape (live-measured leading edge, trailing-aligned words, 8 pt of
   air) is within the ruled text — build it.

Build B1–B4. The pin plan binds as briefed (routing pins for the chord's three contexts incl.
the quick-entry pass-through; the registry walk; the marquee's no-clock-when-fit state pin; the
switcher-alignment geometry pin where reachable).

#### Batch E — THE FORK'S RULING (orchestrator, 2026-11-05 — build E3–E5 to this; everything PROVISIONAL for her morning sitting)

1. **Q-E1 the absent shared query: (a) CONFIRMED** — add vx-809's
   `Sources/VariorumCore/Queries/TagUsageQueries.swift` BYTE-IDENTICAL as its own commit, the
   source branch and SHA (5279ec16a) named in the message, and NEVER edited in this worktree
   afterward. This is "build against the named signature" in its most faithful form — the one
   mint vendored whole, not a twin (the seam's law is one implementation, and this is vx-809's,
   bytes and all). Git reconciles identical adds; if vx-809's ladder edits the file first, OUR
   merge-in takes THEIRS and the second merger re-runs TagUsageQueriesTests — both already the
   standing rules. (b) would leave VX-840 undrawable and unwalkable tonight; (c) would hold a
   member open past the run. vx-809's own tests are NOT copied (their branch carries them; less
   collision surface). The coordinator is being told, so the seam ledger stays straight.
2. **Q-E2 / P-828-4 the bulk undo: ONE combined entry, "Delete Unused Tags" — CONFIRMED** (the
   lean). One confirmed act = one ⌥⌘Z entry is the house pattern (the cross-block compound,
   importDocument's one compound entry); one transaction on one stamp; VX-247's Delete Tag
   undo/redo reused with only a label. The stated redo consequence (a tag re-applied between
   undo and redo is deleted again, application riding) MATCHES the single delete's own redo
   semantics — consistent, accepted, recorded. PROVISIONAL.
3. **Q-E3 the list: (i) CONFIRMED** — every unused tag listed checked, linked boxes encoding
   deleteTag's own subtree reality (unchecking a tag unchecks its ancestors, since deleting an
   ancestor would take the kept child; checking a tag checks its subtree). The act re-checks
   inside the transaction, subtree-aware confirmed ∩ still-qualifying (batch D's rule applied to
   subtrees). The boxes never promise what the operation wouldn't do.
4. **Q-E4 the door: (a) CONFIRMED** — the live count on a narrow observation, "Delete N unused
   tags…", not drawn at zero (batch D's ruling 6, the P-2 letter). Words stand as drafted,
   PROVISIONAL, hers to tune.

#### Batches B+E — ORCHESTRATOR VERIFICATION, THE WALK (stage "vx-828-batchBE" suites/reverts at 06:59 + "vx-828-batchBE2" walks at 10:37, 2026-11-05; the gap = the session's usage limit, no acts lost — the claim expired idle, the coordinator held the stage and closed one leftover Problem Reporter from the 07:03/07:04 encoder-class .ips)

**Suites (batchBE, 06:59):** ONE run, EXECUTED 120 tests / 13 suites — one red,
`BrowserNavKeysTests.aWebViewHoldingTheKeyboardKeepsCommandArrow`, dependency-injection issues
under a NEW NEIGHBOR ORDER; re-run ALONE 5/5 green — recorded as an ORDER-ISOLATION FLAKE (the
known anonymous Date.swift class, first time attributed), counted green per the alone-run rule.
All B re-points and all E suites green first time. **All EIGHT reverts red exactly on their
asserted lines** (R-B1 five chord pins · R-B2 every landing pin with the follow guard green ·
R-B2b exactly `aRowClickCommitsTheCurrentRowToo` · R-B3 the flush-right pin with the clip guard
green · M-B4 `aNameThatFitsHasNoLoop` · R-E1 the one-shot flags pin on all five surfaces · R-E2
`thePaneFollowsTheAppsWingLive` — VX-838's true red-on-old · R-E3 both linked-box pins), each
restored, tree clean.

**The walk (batchBE2, 10:37–11:15, Study then Terminal):**
- **The third wing** minted by hand ("the long-winded third wing of walking", agents' content,
  KEPT for the merge-gate walk) — the New Wing road itself landed in the new wing's Bookcase with
  its receipt.
- **VX-824 the chord, Study:** ⌘1 from the new wing's Bookcase → Home's Bookcase; ⌘2 IMMEDIATELY
  after (the caret resting in quick entry — VX-332's exact case) → Walk Wing + "Now in …": THE
  CHAINED PRESS WORKS, the literal rule's dead-chord trap is closed. ⌘9 → the P-828-1 (i) refusal
  VERBATIM ("There's no wing 9 — ⌘1–⌘3 go to your 3 wings, Home first."), nothing moved. In a
  NOTE: ⌘2 → the MODE ROW (Takes), wing unchanged. The snippets LIST: ⌘2 fired and switched —
  CORRECT (a list is not a writing surface). **Terminal:** in-note ⌘3 → Read (the mode row);
  from the Bookcase ⌘3 → the long-named wing's Bookcase + receipt, monospace.
- **VX-833:** every witnessed deliberate road landed in the Bookcase (the create, the chord in
  both voices); the FOLLOW did NOT land (opening a Home note from the Open list switched the wing
  and stayed in the note — seen twice).
- **VX-844:** the ticker TICKS — captures 3 s apart read "in the lo" → "ɡ-winde" (Study) and
  mid-tick in Terminal; clipped hard at both edges, never crossing the column line, no ellipsis.
- **VX-798:** typed "brwn" in sweep alpha (Write); ⌘; SELECTED it (one press, no checking flag);
  ⌘: raised the panel; its CHANGE replaced it with "brown" through the normal input path — the
  DEBUG identity oracle stayed silent; the word then removed, bytes restored.
- **VX-838/VX-840 the Settings legs: BLOCKED by words-guard, fail-closed honored** — three runs,
  all "withheld (AXError -25200)" with Settings open (batch A's precedent exactly); the one
  Settings capture was DELETED UNREAD. Their behavior stands on the GREEN pins
  (SettingsTagsWingFollowTests · TagSweepTests · UnusedTagsTests + probes M-E1..3) and the legs
  are DEFERRED to the merge-gate window with a FIXTURE PREPARED: the tag "husk-tag" sits LIVE
  with ZERO applications in Home (applied to sweep alpha by hand, then removed) — the sweep door
  should read "Delete 1 unused tag…" there.
- **Posture:** voice restored to Study, wing Home, ⌘Q clean, both strict pgreps empty, NO Problem
  Reporter, .ips count 16 before and after the walk (zero new; the six 07:03/07:04 ones are the
  suite-phase encoder class, coordinator-classed).

**DEFERRED to the merge-gate walk** (each covered by a green pin today): batch C's seven legs
(sidebar leave, Cards, search sheet, day filter, resets, deleted-row survivor, two-pane); B's
⌘L-sheet pick / ▾-list silent pick / masthead-cycle landings, the Library-search-field chord, the
snippet-EDITOR chord (the list-level firing was witnessed; whether the snippets editor is a
pinned holder class — the walk confirms), the label's seam drag / sub-24-pt floor / full screen /
first-frame flash, the ⌘/ helper rows; E's menu-group glance, the capture-box chord, and the two
Settings legs above. One process note: a `⌘,`+click combined command was DENIED by the session's
action classifier mid-walk — split into two calls it ran; noted for walk briefs (keep acts one
per call).

**Ledger rows 3/4/5/9 flip VERIFIED; rows 10/11 flip VERIFIED-BY-PINS** (the live Settings walk
deferred as above). Batches A–E are ALL CLOSED pending the merge-gate items; the ladder (round 1
spawned 10:37, running headless) is the run's last gate before closeout.

#### THE LADDER — ROUND 1 VERDICT (orchestrator's running note; the findings file is
notes/plans/fixes/vx-828-ladder-round1.md, 4d45798b3 + 51cbb2cb3)

0 BLOCKER · 0 MAJOR · 1 standing MINOR (the road pin's stale red-on-old claim + the missing
mechanism net — with the implementer for agree/dispute, the reviewer holds the final call) ·
4 NIT. Dispositions of the NITs that are the ORCHESTRATOR'S: (a) **P-828-6 addendum, recorded
now:** a caret adjacent to punctuation inside a word's run (e.g. `beta|,`) rides the WHOLE run
down under wordStart's floor where the old settle would have cut at the next word — within
R-828's letter ("the whole word rides down") and the ruling's spirit, now NAMED in the
provisional for her morning eye; (b) the `noEmptyBlocksLeft` refusal's "not in the Trash any
more" over-claim joins P-828-10's wording-pass list (hers); (c) the ▾-list Picker current-row
re-pick (SPECULATIVE) joins the merge-gate walk as a micro-leg beside the ▾-list witness;
(d) the 2,400-char window widening is with the implementer (above). ADDED TO THE MERGE-GATE
WINDOW: the amended road pin's red-show under R-C4 (one revert, one suite) once the MINOR's fix
lands. The reviewer's clean-bill highlights and the full verification-debt restatement live in
the findings file.
