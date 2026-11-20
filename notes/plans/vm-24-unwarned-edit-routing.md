# VM-24 — An unwarned edit whose report TextKit widens snaps back on the phone (VM-243 riding)

**STATUS: CLOSED 2026-11-20 — merged to main (PR #19, merge commit `fe1493c16`); /architect-phase on the Pro, an away
run overnight (she slept; her words in §1); orchestrator session `vm-24`; stage coordinator `nov18`.** Ticket VM-24
(team VM, project "Mobile — the catch-up & launch") · rider VM-243, at her word · Branch
`vm-24-unwarned-edit-routing` (deleted after the merge) · PR #19.

This file is the run's ONE record: her words, the binding principles, the design as ruled, the batches and their
briefs, the ledger, what is held for her, and each batch's live status and closeout. The kickoff VM-78 wrote is kept
whole at its end.

## FOR A LATER READER

*Written at the closeout from the settled facts. Below it is the night's working record, kept as written.*

**What the run was.** VM-24 as its own run after wave 1 of the mobile catch-up (her ruling, §1), with VM-243 riding
at her word; /architect-phase, an away run on 2026-11-20, Fable orchestrating, a fresh Opus implementer per batch,
one Fable cold review, nov18 on the stage. Two phone-only fixes in the Write editor, no `Shared/`, `Sources/`,
`Sync/`, custody or schema line; the Mac byte-unchanged.

**The mechanisms, as settled.**
- **VM-24** — an edit that reaches the phone editor's `storageDidEdit` with no arming that describes it (an
  unasked-about autocorrection, dictation, a marked-text commit, any programmatic input call, a typed key whose
  arming another report spent) was routed by `fallbackVerdict` from the storage's post-fixing report; attribute
  fixing widens that report through the paragraph's terminator, which at the end of a block with a block after it is
  the separator, so a plain in-block edit refused and `desyncRecovery` re-rendered from the store (§4.1).
- **VM-243** — on iOS a typed character inherits the font and ink of the character before the caret but never the
  markdown face's own mark, and the face clears only marked runs: text typed after a marker kept the marker's faint
  ink (and, after a heading, its font) until a write with the base attributes landed (§4.4; confirmed by its pin
  before any fix, §12).

**The fixes, one pointer each.**
- VM-24: `MobileChangedCharactersCapture` + `MobileStorageObserver`'s `willProcessEditing` and the
  `changedCharacters` argument of `storageDidEdit` / `fallbackVerdict`, all in `MobileEditorViewModel.swift` —
  `a8662b81e`. The edit trace's widened · rescued · no-capture counts (`MobileEditTrace.swift`), the same commit;
  their words shortened at the ladder (`9675f8888`, `8f5323554`).
- VM-243: `MobileTypedFace.reset` (new file) and its one call in `storageDidEdit` before the line's restyle —
  `efc66ee57`.
- Pins: `MobileUnarmedEditRoutingTests` (`ea5a7a635`), `MobileChangedCharactersCaptureTests` /
  `…ObserverTests` and the trace's (`d98d12517`), `MobileTypedTextFaceTests` (`b437305db`, reading (f)
  `03b06f417`), `MobileTypedFaceRuleTests` / `…GateTests` (`151d98a87`). The standing pin
  `MobileMarkdownCaretTests.aReplaceThroughTheInputRoadAtARescuePointKeepsTheSurfaceInStep` is green, three cases of
  three, its file unedited.

**The rulings.** Hers: §1 (the run, the rider, the away night). The architect's: D-24-1…5 (§4.3) and D-243-1
(§4.5), with the half-1 ruling on what VM-243's pin showed (§12). Options not built and why: §4.2, §4.5.

**The evidence** (§12's three "orchestrator's stage results" sections; `notes/plans/vm-24-walk.md`; the ladder
`notes/plans/fixes/vm-24-ladder-round1.md`). Every pin red on the old code by a build over the base files and green
on the fix, alone and in company (371 tests in 52 suites; then 385 in 55). The walk: VM-243's bug on the BEFORE
captures, gone on the AFTER; the simulator's keyboard asked the gate before every edit, so the walk met no unarmed
edit — VM-24's device evidence is her phone's "before" and "after" sessions (§10). The ladder: one round,
0 BLOCKER · 0 MAJOR · 2 MINOR · 1 NIT, all landed and confirmed. The gate (§12, "THE GATE"): the whole phone target 1,226 tests in 215 suites with ZERO red — main's one standing red gone — the gated speed suite's 13 alone, and the Mac's 22 suites that read the phone's source (129 tests), all green.

**Canon.** TEXTKIT2_NOTES §3 (two iOS 26.2 findings and their rules); MobileSoul PL-81. No AppSpec or
SurfaceContracts line moved.

**Open items.** Her phone's two sessions (`notes/handoffs/vm-24-morning-phone-session.md`, then the "after" app);
her five calls and the wording pass (QUESTIONS #282; `notes/handoffs/vm-24-handoff.md`); VX-1031 (the Mac's twin,
not fixed); VX-68 closed with this merge, PROVISIONAL. PR #19, merge commit `fe1493c16`. The gate's call was the stage coordinator's (nov18), provisional in her absence
and hers to confirm. The "after" app for her phone is named in the handoff's first lines; the walk's captures are kept
for her on the Pro in `~/dev/variorum/App/Variorum/DerivedData/vm24-walk-screens/` until she says "delete the
screens".

## The orchestrator's live state (kept current; a resuming session reads this first)

**CLOSED 2026-11-20 07:11 — merged (PR #19, merge commit `fe1493c16`).** The gate passed (§12, "THE GATE"; the
coordinator's call, hers to confirm). What remains is hers: the "before" session on the wave-1 app, the "after" app
and the same session, QUESTIONS #282 (`notes/handoffs/vm-24-handoff.md`). The blocks below are the night's states,
kept as written.

**As of 2026-11-20 06:55.** BOTH BATCHES PROVED, THE WALK DONE, THE LADDER CLOSED AFTER ONE ROUND, MAIN MERGED IN
(`190165014`; main had moved by four notes files only). The code is `8f5323554`'s — nothing under App or Sources
after it — and the gate's phone product `App/Variorum/DerivedData/vm24-gate` is built from it. READY for the gate is
going to nov18: (1) the whole phone target, one launch; (2) `MobileHerPathsPerfTests` alone with
`TEST_RUNNER_VM66_PERF=1`; (3) the Mac's 22 types that read the phone's source, from `vm24-a-mac` (nov18 widened the
seven; the list is in the session scratchpad's `gate.sh` and in the gate's result block when it runs). No whole Mac
target is owed (no `Shared/` or `Sources/` line; nov18 agrees). The Core suites that name phone files ran headless
on the final words: `MCPProviderNeutralityTests` 2 tests, `Phase13icOutflowTests` + `OutflowRetirementTests` 13
tests, all passed. After the gate: the PR `VM-24: …` and the merge at nov18's GO, the shared ledgers on main, the
Release device build for her "after" session in its OWN folder (never `vm47-wave1-device`), the handoff.

- **Batch A, checked by the orchestrator against the implementer's report (never trusted):** tip `cd72732ec`;
  the fix is `a8662b81e` — `MobileEditorViewModel.swift` and `MobileEditTrace.swift` only, read line by line against
  D-24-1 and D-24-4 and matching both; `git diff --stat 4b0eaaacb HEAD -- App/Variorum/Shared Sources
  App/Variorum/Variorum` is empty; the three builds (`DerivedData/vm24-a-red` at `ea5a7a635`, `vm24-a` at
  `d4085103c`, `vm24-a-mac` at `d98d12517`) each succeeded and each matches the tree where it matters; every
  `-only-testing` name is a type with one definition. Its closeout and the window's commands are in §12. The
  window script is the orchestrator's throwaway (the session scratchpad's `window-a.sh`), a copy of §12's commands
  with a verdict poll.
- **nov18 wants in every READY:** the tree's commit and that the builds are of it; each `-only-testing` list one
  argument per TYPE; the new pins' expected reds by test name. No QUIET window is coming (this is the only run on
  the machine). **Main moved by notes only** since the branch (vm-47's last handoff commits, nov18's handoff
  `508a2bae0`): merge main in before the gate, no rebuild.

*The block below is the state before batch A, kept as written.*

**As of 2026-11-20 04:20.** Preflight done; the run is seated; the design is ruled (§4); nothing is built yet.

- **Done:** the reading (the kickoff's order, whole); the in-flight row on main (`8ff1d08af`); VM-24 and VM-243 In
  Progress; the standing pin re-run ALONE on main's code (claim `vm-24` 04:02–04:06, the standing simulator, products
  `App/Variorum/DerivedData/vm24-base` at `8ff1d08af`): "Test run with 4 tests in 1 suite failed … with 2 issues" —
  `aReplaceThroughTheInputRoadAtARescuePointKeepsTheSurfaceInStep` red for "hi" and "hello there" at
  `model.desyncRecoveryCount == 0` (`MobileMarkdownCaretTests.swift:215`), "Hello" green: main's shape, red alone.
- **Settled by reading — the edit trace in the wave-1 build IS enough for the "before"** (§4.6). Her morning script is
  `notes/handoffs/vm-24-morning-phone-session.md` (`51e954692`); nov18 puts its path in its handoff's top lines.
- **Next, in order:** batch A (VM-24's fix) to a fresh `opus-implementer`, headless, then its red/green window ·
  batch B (VM-243: the pin first, as the confirm) · the simulator walk · the ladder (`fable-reviewer`, a fresh one
  per round) · the gate (nov18's two orderings: the walk and every review round close before the gate's
  whole-target legs; the gate's tree is the tree that merges, apart from notes) · the closeout, the device build for
  her "after" session, the handoff.
- **Held for her:** §10.

## 1. Her words and rulings this run stands on

- **The decision that made this run (2026-11-19, a dialog pick in the VM-78 session, no prose):** "Own run after
  wave 1 (Recommended)" — VM-24 becomes its own short run on merged main once all four mobile runs have merged,
  before wave 2; it starts with one session on her phone counting how often unwarned edits and snap-backs occur, so
  the fix has before-and-after numbers.
- **To the stage coordinator the same morning, verbatim:** "I chose the own run after wave 1 option that vm-78
  proposed. i want you to message them about this to lock the plan down, but basically i want you to open a new
  session in tmux once wave 1 is done and merged, and tell it to architect-phase that issue, reporting to you for
  stage details. just kick that off when wave1 is done for me."
- **VM-243 rides at her word, not as an offer.** Asked whether to add it to this run (2026-11-20, 02:17, as relayed
  by the coordinator), verbatim: "yeah go ahead and add that as a rider honestly".
- **VM-243, her report (2026-11-19, the ticket), verbatim:** "after I use a dash, the rest of the text after that is
  also in a faint wash and sometimes it doesn't go away for the rest of the note, sometimes it does. it's a weird
  bug."
- **Away for the night (2026-11-20, about 03:15, as relayed by the coordinator), verbatim:** "ok i'm going to go to
  sleep, so i'll handle everything in the morning. if you finish vm-24 before i'm back, do your own closeout and
  i'll start from handoffs for everythign."
- **Standing rules this run meets:** the ladder runs up to five rounds, a further round only while the last found a
  new BLOCKER or MAJOR (2026-11-19); installing anything on her phone is her hands; the pin stays red and unwrapped
  until the fix turns it green (VM-78's decision, kept).

**No run ticket was minted, and that is said here because the phase skill's "several ticket ids = a RUN" rule says
to mint one.** Her words made VM-24 the run ("architect-phase that issue") and VM-243 a rider on it; the coordinator
named the worktree after VM-24. So VM-24 names the branch, the worktree and the PR; VM-243 keeps its number, its
commits say `Part of VM-243`, and it closes on its own at the merge. VM-243 stays seated under VM-137 (her seating);
nothing was re-parented. Hers to re-cut (§10).

## 2. Binding principles

**The architect shape's constitution, carried verbatim (binding here as in every phase this skill runs):**

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

**This run's own, from canon:**

- **On the phone, what the text wears is a re-derived projection, never an inheritance** (MobileSoul §5 item 2:
  "Text mutates in batches you didn't type … Identity is a re-stamped projection, never attribute inheritance. Any
  new editor behavior must pass the autocorrect/dictation test on device."). Both fixes here are that rule applied:
  the block an edit belongs to is read from what changed, and the face a typed character wears is derived where it
  lands.
- **Clamp to the verdict's range, never the report's** (TEXTKIT2_NOTES §3, the macOS 26 fixing finding). The
  storage's post-fixing report is a hint about extent; it never decides which block changed.
- **The store is never at risk and must stay so:** a refused route returns before the autosave; nothing in this run
  may write a block's text toward the store on a guess.
- **The fence is designed against, not around** (VM-64's `StructuralFlightFence`, as merged): its ten pins ride every
  window and the gate.
- **The orchestrator never implements** (CLAUDE.md's cast rule, verbatim there). Every line of both fixes and their
  pins is an implementer's; the editor seam is never the orchestrator's hands.

## 3. Cast, members, and how the run is cut

**Cast (CLAUDE.md's standing cast; she is away, so no redirect at kickoff — hers to redirect at any time):** the
orchestrator (Fable) · `opus-implementer`, a fresh one per batch, one agent at a time · the cold reviewer is
`fable-reviewer` every round (the diff is the phone's editor seam), a fresh one per round, `notes/REVIEW_PROMPT.md`
verbatim with zero framing. No line of `Sources/VariorumCore/Sync/`, custody, keychain or schema is touched; a batch
that finds it must stops and reports first.

**Members:** VM-24 (the run) · VM-243 (rider). **Riders offered:** none beyond her own; the open Low and Medium
mobile Editor tickets are seated under later umbrellas (VM-137's Writing, wave 3) and stay there.

**Acceptance units and the evidence each closes on** (named before the first spawn; `notes/PhaseSizingGuidance.md`):

| # | Unit | Evidence of its kind | State |
|---|---|---|---|
| 0 | The measurement: one session on her phone, the edit trace on, counting unwarned edits and snap-backs per way of entering text | Her paste of the readout after each step (`notes/handoffs/vm-24-morning-phone-session.md`) on the wave-1 build — the "before". The same session on the fixed build — the "after" | HELD for her hands (§10). The instrument question is settled (§4.6) |
| A | VM-24: an unarmed report is routed from the characters that changed | The standing pin green 3 of 3, untouched; new pins red on the old code by a build over the base files and green on the fix; the fence's ten pins and the phone's editor suites green in one host; the simulator walk (typing, paste and the readout's new lines in a real note); on her phone, the "after" | NOT STARTED |
| B | VM-243: text typed after a dash line is in full ink | The pin FIRST, as the confirm of a mechanism traced only by reading: red confirms and the fix proceeds, green means record-only. Then green on the fix; the walk's capture of a dash line and the paragraph after it; her three yes-or-no answers on the phone | NOT STARTED |

Two units under one theme (the phone editor's landing of typed text), each its own implementer session; unit 0 is
hers. The run is inside the sizing guidance.

**Order: A, then B.** B's fix wants the exact changed characters, which A's capture provides (§4.5).

## 4. The design, as ruled by the architect

*Product behaviour is not invented here: VM-24's fix removes a snap-back and VM-243's makes the phone draw what the
Mac draws. Where a call could be hers it is marked PROVISIONAL and listed in §10.*

### 4.1 VM-24 — the mechanism, re-read on main (`8ff1d08af`, 2026-11-20)

VM-78's trace holds on today's tree; only the line numbers moved. All in
`App/Variorum/VariorumMobile/Features/Write/MobileEditorViewModel.swift`:

1. The gate (`shouldChangeText`, `:1893`) parks an `ArmedEdit` for an edit it approves (`:2014-2019`). Belts above
   it: gone, stood down, sealed (`:1924-1935`), then VM-64's flight belt (`:1946-1951`).
2. `storageDidEdit` (`:2195`) takes the arming and clears it at the FIRST report, whatever that report is
   (`:2222-2223`), and consumes it only if `ArmedEdit.binds` says it still describes the report (`:2224-2229`).
3. An absent or unbound arming routes by `fallbackVerdict` (`:2249`, `:2342-2352`), which rebuilds the old range from
   the REPORTED range: `(editedRange.location, editedRange.length - delta)`.
4. The report is `NSTextStorageDelegate`'s `didProcessEditing` range (`MobileStorageObserver`, `:2789-2799`) — the
   range AFTER attribute fixing, which can run through the paragraph's terminator (TEXTKIT2_NOTES §3).
5. When the edited paragraph is the last of a block that has a block after it, that terminator is the block
   separator: the rebuilt old range crosses it, `BlockRangeIndex.verdict` refuses, and the `.refuse` arm
   (`:2307-2312`) takes `recoverFromUnroutableEdit` (`:2391`) to `desyncRecovery` (`:2396-2412`): counted, asserted in
   DEBUG, the pending autosaves flushed, the note re-read and re-rendered. The edit was never recorded, so it is
   gone from the page.
6. VM-64's storage belt sits INSIDE the `.block(i)` arm (`:2277`), so a widened unarmed edit during a structural
   flight never reaches it: it refuses at step 5 and heals mid-flight instead.

Which edits arrive unarmed (VM-78's reach table, round 3's R3-F5 correction, VM-64's batch 2): autocorrect and
predictions when the keyboard does not ask, dictation's words in progress, marked-text commits, any programmatic
`replace(_:withText:)` / `insertText(_:)` / `deleteBackward()`, and an ordinary typed character whose arming was
spent on a keyboard transaction that landed first (her phone's own trace, E1 #50–#52).

### 4.2 VM-24 — the options, weighed against the fence as it landed

| Option | What it is | Verdict |
|---|---|---|
| 1 — route an unarmed report from the pre-fixing range | The storage observer also hears `willProcessEditing`, whose range is the characters that changed before fixing widens it; `fallbackVerdict` rebuilds the old range from that | **BUILT (D-24-1).** It repairs the routing at its cause for every unarmed road at once, without knowing which system roads skip the gate, and it cannot loosen a refusal: the storage's own pre-fixing range of a change that truly crosses a block still crosses it |
| 2 — a fallback that tolerates the widening | Accept a report that overruns a separator only by the paragraph's terminator when the net change fits the block | **REJECTED.** It judges from a range that does not say where the characters changed; a real cross-block system edit could be written to one block's take. This run may not write toward the store on a guess (§2) |
| 3 — arm the roads the phone can see | Override the public input doors to ask the gate first | **NOT BUILT.** It cannot cover an arming spent before its edit lands (R3-F5), it reaches only roads that pass through those methods, and it adds a place where a system edit is refused. Considered and not pursued; option 1 needs no belt from it |

### 4.3 VM-24 — the rulings

**D-24-1 — the fix.** Phone-only, in `MobileEditorViewModel.swift`:

- `MobileStorageObserver` implements `textStorage(_:willProcessEditing:range:changeInLength:)`. When the mask holds
  `.editedCharacters` it keeps that `(range, delta)` — the characters as the storage accumulated them, before fixing.
- Its `didProcessEditing` takes the kept value and clears it FIRST — before the model is called, and on every
  callback whatever its mask — so a nested attribute-only transaction (the re-stamp, the face restyle) can neither
  read nor leave a stale one. It accepts the kept value only when its delta equals the report's and its range lies
  inside the reported range; anything else is dropped.
- `storageDidEdit(_:changeInLength:)` gains one optional argument, the changed characters, defaulting to nil, so
  every existing caller and pin compiles and reads unchanged.
- `fallbackVerdict` rebuilds the old range from the changed characters when it has them, else from the report
  exactly as today. **No kept value ⇒ today's behaviour, byte for byte** (the fail-safe if a road ever reports
  without the first callback).
- An unbound edit's churn cost (`recordAutosave`, `:2372-2376`) is computed from the changed characters when known —
  the same rule `exactCost` already applies to bound edits. The re-stamp, the face restyle and the chrome keep the
  REPORTED range: each needs the extent and each is extent-safe by its own rule (`restampProjection`'s doc,
  `:2520-2541`).
- Nothing else in the routing moves: the binding, the four arms, the refusal road, the fence's two belts and its
  settle.

**D-24-2 — against the fence.** What an edit gets, before and after:

| The edit | Before | After |
|---|---|---|
| Unarmed, changes characters inside one block, report widened past that block's end, no flight | refused, healed from the store (the snap-back) | routed to its block, recorded for autosave |
| The same during a structural flight | refused, `desyncRecovery` in mid-flight (a flush and a re-read while the act lands) | routed to its block, where VM-64's storage belt withholds it, forces the re-read and the fence says its sentence — the road VM-64 designed for an edit that never asked |
| Unarmed and truly spanning a block boundary | refused, healed | unchanged |
| Armed and bound | routed by the arming | unchanged |
| Asked about during a flight | refused at the gate | unchanged |

So the fix makes the fence's storage belt reachable for widened edits too; it writes nothing toward the store during
a flight that was not written before. The fence's ten pins are in every window of batch A, with one new pin: a
gate-less edit in a NON-LAST block during a held divide is withheld and said, with no desync.

**D-24-3 — the Mac.** Nothing changes on the Mac, and no `Shared/` or `Sources/` file is touched. The Mac's
`fallbackVerdict` (`App/Variorum/Variorum/Features/Editor/EditorViewModel.swift:1465-1475`) reads the post-fixing
range the same way and macOS widens too (TEXTKIT2_NOTES §3, 13l), but no Mac road is shown to arrive unarmed with a
widened report that crosses a block, and no fix lands without a traced mechanism. The Mac twin is filed as a ticket
at the closeout (Exploration, Editor), with this record's facts. If the Mac adopts the same routing later, the
changed-characters value is the piece to hoist into `Shared/EditorBrain`.

**D-24-4 — the instrument.** The edit trace (`MobileEditTrace.swift`) learns the changed characters so the "after"
session can count what the fix did: a report is marked **widened** when the reported range is longer than the
changed characters, and **rescued** when it was unarmed, widened, and the reported range would have refused where
the changed characters route — each rescued edit is one snap-back that did not happen. Two counters and their two
headline lines, plus a count of character reports that arrived with no kept value (if that is ever above zero on
her phone, the first callback does not fire on some road and the capture needs another home). The extra verdict is
computed only while the trace is armed and only for an unarmed, widened report; disarmed, the cost stays one `Bool`
read. Offsets and counts only, as ever. The new words are DRAFT for her wording pass.

**D-24-5 — VX-68** (the gate-less insertion watch row, "the first place to look on any typing-flicker report")
closes with this run's merge: its class is the widened gate-less report's honest re-render, which the fix removes,
with pins. PROVISIONAL (§10).

### 4.4 VM-243 — the mechanism, traced by reading (SPECULATIVE until its pin is red)

1. The markdown face marks every run it styles with a custom attribute, `MarkdownFace.faceAttribute`, and a restyle
   clears only runs that carry the mark (`App/Variorum/Shared/MarkdownFace/MarkdownFaceCore.swift:178-203`).
2. A dash line's lead, `"- "`, is the bullet's marker (`Sources/VariorumCore/Domain/MarkdownSyntax.swift:348-356`),
   written in the marker's muted ink with the mark (`MarkdownFaceCore.swift:298-302`;
   `MobileEditorStyle.swift:214`). The item's words are deliberately never written (`:334-336`, "the item's text
   reads as prose").
3. On iOS a typed character takes UIKit's typing attributes, derived from the character before the caret. The
   standard ones ride — font, ink, paragraph style; a custom key does not (the model's header, `:13-19`; the Stage 0
   spike measured `carryCustomKeyAtMidBlockCaret=NO`). So the first word typed after `"- "` lands in the marker's
   muted ink WITHOUT the mark.
4. Nothing clears it. The restyle's clear walks marked runs only, and a bullet's words are never re-written. Every
   next character inherits from the one before it — along the line, through the Return, into the next paragraph —
   until a write with the base attributes lands there (the full render at re-open; a programmatic replace,
   `:2487-2518`; the tail's normalizing replace) or the caret moves to text in full ink. That is her "sometimes it
   doesn't go away … sometimes it does".
5. The Mac does not have it: AppKit's typing attributes carry the custom mark, so the same clear pass resets the
   inherited ink.

What this predicts beyond her report, and the pin checks each: words typed right after any closing marker are faint
(`*a* b`); text typed on the line after a heading may keep the heading's font; a re-open clears all of it (the
attributes are never stored).

### 4.5 VM-243 — the ruling (built only if the pin is red)

**D-243-1 — the face is derived where the text lands.** Phone-only, in `storageDidEdit`, for every routed arm,
BEFORE the line's `MarkdownFace.restyle`: the changed characters' face attributes are reset to the surface's base —
the base font and ink (`MobileEditorStyle.baseAttributes`), strikethrough and the code chip's background removed —
and the restyle then derives whatever face those lines truly have. Rules:

- **The range is the changed characters and nothing wider:** D-24-1's kept value; with none, a bound arming's
  `(location, replacementLength)`; with neither, no reset (today's behaviour). Never the widened report.
- **Equality-gated:** characters already wearing the base write nothing, so plain prose typed in plain prose costs
  one attribute read and no storage edit.
- **Never the paragraph style** (the reservations own it, `MobileEditorTextView.swift:701-726`), never the block
  identity.
- It sits beside `restampProjection`, the same doctrine as the identity re-stamp and `healReservationResidue`: heal
  the landing.

Weighed and not built: setting `typingAttributes` to the base at each selection change (UIKit re-derives them, and
the unarmed roads may not read them at all); a reset door inside the shared `MarkdownFace` (the leak is iOS's alone,
and a `Shared/` change would owe the Mac a leg for code it never calls).

**Reserved for the architect:** if the pin shows a different mechanism — green where this predicts red, or red in a
shape this does not explain — the implementer stops and reports before any fix.

### 4.6 The instrument question — the edit trace in the wave-1 build IS enough for the "before"

Read in `MobileEditTrace.swift` and its call sites on `226edf626`'s tree (identical to today's):

- It ships in Release, is armed from the phone (Settings ▸ Diagnostics ▸ "Record edit trace"; the arming survives a
  relaunch), and its readout has Copy, Refresh and Clear (`MobileSettingsView.swift:378-406`).
- Its counters are monotonic and outlive the 300-event ring: storage edits, **gate-less** (no consult since the last
  report), **arming rejected** (an arming was parked and did not bind), **desync recoveries**. The first two are the
  unarmed edits; the last is the snap-backs. That is the count the kickoff asks for.
- It does not label the way the text was entered, so the script has her do one way at a time and Copy after each;
  the counters add up and consecutive pastes subtract.
- Its counters live in memory: swiping the app away starts them from zero (the script says so).
- **One limit:** it does not record the pre-fixing range, so "this report was widened" is read from each line's
  length against its delta, not measured. The snap-back count is exact. The "after" build measures widening directly
  (D-24-4).

So one install serves VM-64's timing readout and this run's "before"; no other build is needed on her phone for it.
**The "before" must run on the app VM-47 built from `226edf626`**
(`~/Library/Developer/Xcode/DerivedData/vm47-wave1-device/`): a rebuild of main after this run merges would carry
the fix.

## 5. The batches

### Rules common to every batch

- **Pin before fix, per member.** Every pin is committed first and shown red on the old code by a BUILD of the pins
  over the base production files (commit before you revert; say so in your LIVE STATUS before starting; restore and
  verify by `git diff`), then green on the fix.
- **These pins drive the UNARMED road on purpose** — that is the road under repair — so TEXTKIT2_NOTES §3's rule for
  pins that claim her keyboard's road does not apply to them. What does apply: every pin must be deterministic in
  any company. Say for each pin why its report is widened every time (the construction, not luck), and prove it by
  running the suite alone and after the editor suites in one host.
- **No `Shared/`, `Sources/`, `Sync/`, custody or schema line.** If a fix seems to need one, stop and report.
- **No behaviour beyond the rulings in §4.** A decision they do not make is a question for the orchestrator, asked
  before building that half.
- **Words:** any string the app can show is marked DRAFT in your closeout for her wording pass; no retired
  vocabulary (the Mac's `DeadVocabularyTests` reads the phone's source).
- **Records:** durations and counts only in anything this run logs; never note text, titles or ids. Never a device
  identifier or simulator UDID in a commit or this record (`<simulator-udid>`).

### Batch A — VM-24: an unarmed report is routed from the characters that changed (editor seam)

**Extra reading, in full, before any line:** `notes/TEXTKIT2_NOTES.md`; this record's §1–§4 and §7; in
`notes/plans/fixes/vm-78-fixes-to-whats-there.md`, BATCH C's "WINDOW (3) — RESULTS" and "VM-24 — the mechanism, its
reach, and the options"; in `notes/plans/fixes/vm-64-timing-and-lags.md` §7, batch 2's "Iteration r1 → r2" and
"Iteration r2 — refuse and say"; `App/Variorum/VariorumMobileTests/MobileStructuralFlightFenceTests.swift` whole
(its hold of the store's queue, `systemEdit`, `withDesyncsRecorded`, `host`);
`App/Variorum/VariorumMobile/Features/Write/MobileEditTrace.swift` whole.

**The unit.** D-24-1, D-24-2 and D-24-4 as ruled, with their pins.

**The pins** (a new suite, `MobileUnarmedEditRoutingTests`, `.serialized`, hosted in the key-window posture; the
names are yours):

1. **THE NEW PIN — red on old.** A gate-less edit whose report fixing widens past its block's terminator, made
   inside a block that has a block after it, is routed to its block: no desync, the page holds the text, the store
   holds it in that block's take after a flush, the DEBUG identity audit quiet, the next block untouched. The
   construction to start from is the fence suite's `systemEdit` (a font-only attributed insert through the storage;
   VM-64's r1 window showed it refuse in a non-last block on both of its trees). Cover an insert at the block's end,
   an insert mid-paragraph and a replace.
2. **The control — green on both.** A gate-less replace that truly spans a block separator still refuses and heals
   from the store; nothing is written to either block's take.
3. **The spent arming — red on old.** E1 #50–#52's shape: the gate is asked about a character at offset n, a
   different report lands first and takes the arming, the consulted insert then lands unarmed and widened. It routes.
4. **The fence — red on old.** A gate-less widened edit in a NON-LAST block while a divide is held: withheld (no
   stale write, no conflict take), the page re-read, the sentence said once as the fence drops, no desync.
5. **The capture's belts.** An attribute-only transaction leaves no kept value behind; a kept value whose delta or
   range disagrees with the report is dropped and the report routes as today.
6. **The trace** (`MobileEditTraceTests`): widened and rescued are counted and drawn; a disarmed trace does no extra
   work; the no-kept-value count.
7. **The standing pin** (`MobileMarkdownCaretTests.aReplaceThroughTheInputRoadAtARescuePointKeepsTheSurfaceInStep`)
   is NOT edited. It goes green, three cases of three, by the fix alone — and by doing so it proves the delegate's
   first callback fires on UIKit's own replace road.

**Evidence owed:** the red build (`DerivedData/vm24-a-red`: your pins over the base's production files) and the fix
build (`DerivedData/vm24-a`), both `build-for-testing`; a Mac `build-for-testing` (`DerivedData/vm24-a-mac`) for the
Mac suites that read the phone's source. Then the READY report with the stage commands below filled in.

**The stage window the orchestrator will ask for** (you do not run it unless told): (i) the new suite and the caret
suite on the red build — the new pins red as tabled, the control green, the caret pin red in main's shape; (ii) on
the fix build, ONE invocation: the new suite, then VM-64's 49 editor types (its record's r2 list, which holds the
fence suite and the caret suite) — everything green; (iii) the gated speed suite is the gate's, not this window's;
(iv) the Mac's seven types that read every phone file: `DeadVocabularyTests`, `DataSafetySearchIndexTests`,
`PaneLineMetricsScopeTests`, `OneRefreshAuthorityCompositionTests`, `OneInputPathTests`, `PaletteDerivationTests`,
`GlyphRainTests`.

**Not in this batch:** VM-243; any change to what an armed edit does; any new refusal; the Mac.

### Batch B — VM-243: text typed after a dash line is in full ink (editor seam)

**Extra reading:** as batch A's, plus batch A's closeout in §12; §4.4–§4.5 here; `MarkdownFaceCore.swift` whole;
`MobileMarkdownCaretTests.swift` and `MobileMarkdownTests.swift`; the ticket's two screenshots as described in §4.4
(her phone, Study voice: two dash lines faint through their whole text, a later paragraph faint, later ones in full
ink).

**The unit, in two halves with a stop between them.**

- **Half 1 — the pin, as the confirm.** A hosted pin (the keyboard's road: the delegate consult, then the insert —
  the fence suite's `keyboardType` shape; Study voice, where the inks differ) that reads the ink and font of each
  run after: (a) `- one` typed a character at a time; (b) Return twice, then `two`; (c) on a new line, `*a* b`;
  (d) a heading line, Return, a word; (e) the note re-opened. §4.4 predicts: "one", "two" and " b" in the marker's
  ink on the old code; (d) to be read, not assumed; (e) full ink. **Build it over the base, record what it shows,
  and STOP: report to the orchestrator before any fix.** Red as predicted ⇒ half 2. Anything else ⇒ the architect
  rules.
- **Half 2 — the fix, D-243-1 as ruled,** then the pin green, the caret suite's VX-296 pins green (the reset must
  not cost the caret's honour at a rescue point), and the equality gate pinned (typing plain prose in plain prose
  makes no attribute edit — count storage edits or `processEditing` passes).

**Not in this batch:** the shared face; the Mac; faint ink already on a page (a re-open clears it).

## 6. Kickoff message (handed to every implementer verbatim, with its batch named)

> You are the implementer for ONE batch of the VM-24 run — the phone editor's routing of an edit it was not asked
> about, with VM-243 riding. Work only in the worktree `~/dev/variorum-vm-24` on branch
> `vm-24-unwarned-edit-routing`; never touch `~/dev/variorum` (main) or any other worktree.
>
> **Read first, yourself, in full, before touching code:** `CLAUDE.md` and its loaded canon;
> `notes/TEXTKIT2_NOTES.md`; `notes/MobileSoul.md` §1–§5; `notes/SessionResiliencyProtocol.md` (it binds you); this
> record (`notes/plans/vm-24-unwarned-edit-routing.md`) §1–§7 and your batch's section in §5, then the extra reading
> that section names. Verify every file:line this record cites against today's tree before building on it.
>
> **Her words, the reason this run exists:** a word the keyboard just put in snaps back, with a flicker; and, for
> VM-243, "after I use a dash, the rest of the text after that is also in a faint wash and sometimes it doesn't go
> away for the rest of the note, sometimes it does."
>
> **What every batch owes:** the batch section's unit and nothing beyond it, built to §4's rulings; pin before fix
> (every bug-class change lands with a pin red on the old code, shown by a build over the base files — commit
> before you revert, and say so in the record first); no `Shared/`, `Sources/`, `Sync/`, custody or schema line;
> the Mac must not change; any line the app can show is marked DRAFT for her wording pass; offsets, counts and
> durations only in anything logged.
>
> **The checkpoint protocol binds from your first commit:** write your batch's LIVE STATUS block in §11 at the
> start; commit per coherent piece and push after every commit; flip the status in the same commit as each piece;
> claims not yet verified are marked PENDING; synchronous foreground waits only (poll a log with a
> `grep -q … && break; sleep 5` loop; never end your turn waiting on a background run); never spawn a subagent
> except one Sonnet lookup for an external fact. Commits carry no attribution trailer; messages are public copy and
> say `Part of VM-24` or `Part of VM-243`. The repo is PUBLIC and every push runs a pre-push guard: never a device
> identifier, simulator UDID, email, account id or credential in a commit or the record; a guard refusal is fixed
> in the commits, never bypassed. `notes/QUESTIONS.md`, `notes/TICKETS.md` and the master plan are shared ledgers
> touched only at the merge: write each open question, with its options, under "For QUESTIONS at the merge" in your
> closeout.
>
> **The stage:** headless `swift build` / `swift test` and `xcodebuild build` / `build-for-testing` need no stage.
> EVERY `xcodebuild test` (simulator or Mac), every simulator boot, walk or Debug launch needs a window that only
> the orchestrator can obtain from the coordinator (nov18). So: do all headless work, get `build-for-testing` green
> for what §5 names, then END YOUR TURN with a READY report naming the exact suites and commands, runnable by
> someone else from your built products (`test-without-building` against your DerivedData folder, TYPE names in a
> zsh array, one argument each). Never claim the stage, boot a simulator or run a test host on your own. Use
> run-tagged DerivedData folders under `App/Variorum/DerivedData/` (gitignored) and say their paths. Stop a build
> only by the PID your own script started. If the orchestrator tells you a QUIET window is on, run no cold or full
> build until it ends.
>
> **Report back with:** what shipped (file by file), the pins and how each was shown red on old, design calls with
> the options you weighed, commits (hashes), the exact stage commands, anything that needs the author. Write your
> batch's closeout in §12 detailed enough to be reviewed cold against §4.

## 7. Environment traps (carried into every brief)

- Phone tests run from `App/Variorum/`: `xcodebuild … -project Variorum.xcodeproj -scheme VariorumMobile
  -destination "platform=iOS Simulator,…"`, suite-level `-only-testing:VariorumMobileTests/<Type>`, TYPE names
  never file names. `build-for-testing` signs for `name=iPhone 17 Pro,OS=26.2` without booting. The stage window's
  device is addressed by a UDID the GO message carries; it never enters a commit. Boot fresh inside the claim, let
  it settle 30 s, shut down before release.
- A result line gives the Swift Testing verdict line and executed counts (a zero-executed line is no verdict; the
  count includes skipped tests — read the `skipped` lines), names EVERY failing test, and says: one launch,
  `Restarting after unexpected exit` count, simulator shut down, no Variorum or VariorumMobile instance, no Problem
  Reporter, no new `Variorum*.ips`, the simulator app's container listing (`Variorum-dev` only).
- A failed run's `xcodebuild` can linger after its verdict: wait at most 90 s, then stop only your own PID.
- `MobileHerPathsPerfTests` runs only alone with `TEST_RUNNER_VM66_PERF=1`; in any other run its 13 tests are
  skipped, and a skip is never a pass.
- Main's baselines after wave 1: the whole phone target has ONE red — this run's own pin, two of its three cases;
  the whole Mac target has none, with two known flaky names (VX-701's esc-boundary test, VX-953's spelling write
  arm).
- Never add a build configuration; never a TK1 API (`.layoutManager` downgrades silently); the canary checkpoint
  follows every processed storage edit.
- A debug assertion inside a hosted pin is recorded as a failing issue through `EditorAssertionSeam`'s task-local
  handler (the fence suite's `withDesyncsRecorded`), never left to stop the host, and never muted into a pass.
- Never `git checkout` over uncommitted work; never `git add -A` in this worktree; push after every commit; no
  history rewrites.

## 8. Review foci (written at plan time, before any code)

1. **The kept value's pairing.** Can a pre-fixing value ever be consumed by a report it does not belong to — a
   nested attribute-only transaction from inside `storageDidEdit`, a suppressed programmatic write, an early return,
   two storages? Is it cleared on every path?
2. **No refusal loosened.** Is there any input for which an edit that truly spans a block boundary, or lands outside
   the tiling, now routes to a block?
3. **The fence, row by row.** Re-read VM-64's input table (its record, batch 2 r2) against the changed routing: is
   anything written toward the store during a flight that was not before? Does the fence still drop only when the
   page holds the store?
4. **The store.** Does any new path record a block's text for autosave on a judgement rather than on the storage's
   own account of what changed?
5. **The face reset (VM-243).** Can it touch an attribute that is not the face's (paragraph style, block identity,
   anything a chrome writes into storage)? Is it gated so plain typing makes no attribute edit? Is its cost ∝ the
   changed characters (P1)? Does the caret's honour at a rescue point (VX-296) survive it?
6. **TextKit.** No TK1 API; no layout forced; no attribute write joins a character edit's transaction; the canary
   checkpoint still follows every processed edit.
7. **The trace.** Zero behaviour change; inert while disarmed (the 100k pin
   `theEditTraceIsInertDisarmedAndQuietArmedAt100k`); offsets and counts only.
8. **The Mac.** No `Shared/` or `Sources/` line; the Mac twin ticketed, not fixed.
9. **The pins.** Is each "red on old" shown by a build over the base files and recorded? Is each deterministic in
   company, and does the record say why? Was the standing pin left unedited?
10. **Words and records.** New strings marked DRAFT; no retired vocabulary; no identifier in a commit; every claim
    in a closeout findable in a test or a log.

## 9. The ledger

| # | Item | Owner | Status |
|---|---|---|---|
| L1 | Unit 0, the "before" session on her phone | her hands; the script `notes/handoffs/vm-24-morning-phone-session.md` | HELD for her morning (§10) — the script is on main since the merge |
| L2 | Is the wave-1 build's trace enough for the "before"? | orchestrator | DONE — yes (§4.6) |
| L3 | The standing pin re-run alone on main's code | orchestrator | DONE — red, main's shape (the live state) |
| L4 | The design: VM-24's options against the fence; VM-243's trace | architect | DONE (§4) |
| L5 | Batch A — VM-24's fix and pins | implementer | DONE (`a8662b81e`; §12) |
| L6 | Batch A's red/green window, the Mac's seven source-reading types | orchestrator, nov18's GO | DONE 04:47–04:51 — red as tabled on the old code, 371 tests in 52 suites green on the fix, the standing pin green 3 of 3, the Mac's 46 in 7 green (§12, "the orchestrator's stage results") |
| L7 | Batch B — VM-243: the pin as the confirm, then the fix | implementer | DONE — the pin `b437305db` (+ reading (f) `03b06f417`), the fix `efc66ee57`, the reset's pins `151d98a87` (§12) |
| L8 | Batch B's window | orchestrator, nov18's GO | DONE — the confirm 05:08–05:10 (red as predicted); the red/green 05:27–05:31 (7 issues at the tabled lines on the build without the fix; 385 tests in 55 suites green on the fix; the Mac's 46 in 7 green) |
| L9 | The simulator walk (typing mid-note, paste, the readout's new lines; a dash line and the paragraph after it) | orchestrator | DONE 06:06–06:21 — both passes; rows a, b, c, e, f, g, h PASS, row d PASS for the paste at a paragraph's end and NOT WALKED for the paste over a selection; VM-243's bug on the BEFORE captures and gone on the AFTER; the simulator produced no unarmed or widened edit, so VM-24's device evidence is still her "after" session; one finding, W-1 (`notes/plans/vm-24-walk.md`, "The verdicts") |
| L10 | The ladder (`fable-reviewer`, fresh per round, up to five) | orchestrator | CLOSED after ONE round — `notes/plans/fixes/vm-24-ladder-round1.md`: 0 BLOCKER · 0 MAJOR · 2 MINOR · 1 NIT, every finding agreed and landed (`9675f8888`, `b3fa281f9`), the reviewer's final calls confirming each, plus its final call 2 on the implementer's own observation (`8f5323554`: the new "widened" line fits both voices); no second round earned; the orchestrator's line-by-line check of the final round's four hunks done (strings and comments only) |
| L11 | The gate: the whole phone target, the gated speed suite alone; the Mac's readers of the phone's source | orchestrator, nov18 | DONE 06:52–07:09 — 1,226 tests in 215 suites, ZERO red (main's standing red gone); the speed suite 13 alone; the Mac's 22 source-reading types 129 tests (§12, "THE GATE") |
| L12 | Canon: TEXTKIT2_NOTES §3 (what was measured about the first callback and the fix's rule); SurfaceContracts only if a contract line moved; MobileSoul PL-81 | orchestrator at closeout | DONE — TEXTKIT2_NOTES §3 (two findings) and MobileSoul PL-81 (`b29705c7f`); no SurfaceContracts or AppSpec line moved |
| L13 | VX-68 closed with a comment naming the pin (D-24-5) | orchestrator at the merge | DONE at the merge — VX-68 closed with a comment naming the pins; PROVISIONAL (QUESTIONS #282 item 2) |
| L14 | The Mac twin's ticket (D-24-3) | orchestrator at closeout | DONE — VX-1031 (Exploration · Editor · Low · Backlog) |
| L15 | The device build of the fixed tree for her "after" session, and its block in the handoff | orchestrator after the merge | DONE — the "after" app built from the merge commit `fe1493c16`; its path and facts are the handoff's first lines |
| L16 | Unit 0's "after" session | her hands | HELD for her hands (§10) |
| L17 | Closeout: this record's FOR A LATER READER, the shared ledgers at the merge (QUESTIONS #282, AppSpecRecord, the finals line, the master plan), `Tools/canon-size`, the tickets, the handoff `notes/handoffs/vm-24-handoff.md`, the cleanup | orchestrator | DONE — this record closed; QUESTIONS #282, the AppSpecRecord entry, the finals line and the master plan on main in the ledger commit; `Tools/canon-size` 143606 (headroom 6394); VM-24 and VM-243 Done; the handoff final; the cleanup done at the hard stop |

## 10. Held for her (the sitting bundle; nothing here was improvised around)

1. **The "before" session on your phone** — `notes/handoffs/vm-24-morning-phone-session.md`, about fifteen minutes
   on the wave-1 build, with one minute of yes-or-no checks for the dash bug.
2. **The "after" session** needs the fixed build on your phone, so a second install. PROVISIONAL plan: this run
   prepares that device build from the tree that merges and writes its block; you install it when you choose —
   right after the "before" session, or with the next phone build. Until then the fix's evidence is the pins and
   the simulator walk.
3. **No run ticket was minted** (§1): VM-24 names the run and VM-243 rides. Say if you want a `Run:` ticket over
   both.
4. **VX-68 closes with this merge** (D-24-5) — PROVISIONAL.
5. **The Mac twin** (D-24-3): ticketed, not fixed. Say if you want it looked at sooner.
6. **The edit trace's new lines** (D-24-4) are DRAFT words.
7. **VM-243 is built to "what the Mac draws"**: the dash faint, its words and everything after in full ink (the
   ticket's own "what should happen").

## 11. LIVE STATUS

*(Each implementer writes its batch's block here at its start and flips it per commit.)*

### Batch A · VM-24 — LIVE STATUS (implementer, opus; started 2026-11-20 ~04:40, base `4b0eaaacb`)

**Revert state: NO REVERT IS IN FLIGHT.** The red build is made WITHOUT a revert: the pins land in their own commit
(pins 1–4 use only API that exists on the base tree), and `DerivedData/vm24-a-red` is built from the tree at that
commit, whose production files are byte-identical to the base's (verified by `git diff --stat 4b0eaaacb`). If a pin is
ever edited after the fix lands, the red build is remade by the revert protocol and this line says so first.

| Piece | State |
|---|---|
| Reading (CLAUDE.md + canon, TEXTKIT2_NOTES, MobileSoul §1–5, the protocol, this record §1–§7 + batch A, VM-78 BATCH C's two sections, VM-64 §7 batch 2's r1→r2 and r2, the fence suite whole, `MobileEditTrace.swift` whole); every file:line in §4.1 re-verified on `4b0eaaacb` — all hold | DONE |
| A macOS probe (a scratch script, not a test host): `NSTextStorageDelegate.willProcessEditing` fires for a programmatic `replaceCharacters`, with the exact change; `didProcessEditing` widens a font-only insert through the paragraph's terminator. macOS evidence for UIFoundation's shared storage, NOT an iOS measurement | DONE |
| Pins 1–4 (`MobileUnarmedEditRoutingTests`, base API only) | DONE (`ea5a7a635`) — red/green PENDING the stage window |
| Red build `DerivedData/vm24-a-red` (the tree at `ea5a7a635`: `git diff --stat 4b0eaaacb ea5a7a635` = the new test file + this record, no production file) | DONE — `** TEST BUILD SUCCEEDED **`, log `DerivedData/logs/vm24-a-red-bft.log`; the test binary carries the new suite. FROZEN: never rebuilt into |
| The fix (D-24-1): the capture in `MobileStorageObserver`, `storageDidEdit(_:changeInLength:changedCharacters:)`, `fallbackVerdict`, the unbound churn cost | DONE (`a8662b81e`) — green PENDING the stage window |
| The trace (D-24-4): widened · rescued · no capture | DONE (`a8662b81e`) — DRAFT words; green PENDING |
| Pins 5 (capture belts: `MobileChangedCharactersCaptureTests` + `MobileChangedCharactersObserverTests`) and 6 (trace: five new tests in `MobileEditTraceTests`) | DONE (`d98d12517`, `d4085103c`) — green PENDING the stage window |
| Fix build `DerivedData/vm24-a` (phone) | DONE at the code of `d4085103c` — `** TEST BUILD SUCCEEDED **`, log `DerivedData/logs/vm24-a-bft3.log`; no new warning in a touched file (the one warning in `MobileEditTraceTests.swift`, an unneeded `try` in `theRingIsBoundedWhileTheCountersStayTrue`, is the base's) |
| Mac `DerivedData/vm24-a-mac` | DONE at the code of `d98d12517` (no Mac, `Shared/` or `Sources/` file differs from the base: `git diff --stat 4b0eaaacb HEAD -- App/Variorum/Shared Sources App/Variorum/Variorum` is empty) — `** TEST BUILD SUCCEEDED **`, log `DerivedData/logs/vm24-a-mac-bft.log` |
| Closeout in §12 + the READY report | DONE (the commit after `75606a263`, whose message named it too early) |
| The stage window (§12, "The stage window") | PENDING — the orchestrator's, from these products |

### Batch B · VM-243 — LIVE STATUS (implementer, opus; started 2026-11-20 ~05:00, base `d63c1e2cd`)

**This turn is HALF 1 ONLY** (the pin as the confirm, built over the tree as it stands — no VM-243 fix exists in it —
then a STOP and a READY report). No fix line is written until the orchestrator says how to proceed.

**Revert state: NO REVERT IS IN FLIGHT, and none is needed for half 1.** The tree at `d63c1e2cd` carries no VM-243
fix, so the pin's build over it IS the build over the base files: the pin lands in its own commit, using only API
that exists on this tree, and `DerivedData/vm24-b-pin` is built from the tree at that commit (its production files
byte-identical to `d63c1e2cd`'s, shown by `git diff --stat d63c1e2cd`). If half 2 ever edits the pin after the fix
lands, its red build is remade by the revert protocol and this line says so first.

| Piece | State |
|---|---|
| Reading (CLAUDE.md + canon, TEXTKIT2_NOTES, MobileSoul §1–5, the protocol, this record §1–§7 + batch B + batch A's closeout, VM-78 BATCH C's two sections, VM-64 §7 batch 2's r1→r2 and r2, the fence suite whole, `MobileEditTrace.swift` whole, `MarkdownFaceCore.swift` whole, `MobileMarkdownCaretTests.swift`, `MobileMarkdownTests.swift`); §4.4–§4.5's file:line pointers re-verified on `d63c1e2cd` — all hold but the programmatic replace, which batch A moved (`:2487-2518` → `MobileEditorViewModel.swift:2552-2583`) | DONE |
| The pin (`MobileTypedTextFaceTests`, readings (a)–(e), base API only) | DONE (`b437305db`) — compiles; red/green PENDING the stage window |
| Pin build `DerivedData/vm24-b-pin` (`build-for-testing`) | DONE at the tree of `b437305db` (no production file differs from `d63c1e2cd`) — `** TEST BUILD SUCCEEDED **`, log `DerivedData/logs/vm24-b-pin-bft.log`, no warning in the new file, the test binary carries the suite |
| Half 1's closeout in §12 (expected result per reading, by expectation line) + the READY report | DONE (the commit after `b437305db`) |
| The stage window (the pin alone; the orchestrator's) | DONE by the orchestrator 05:08–05:10 — red as predicted (§12, "Batch B, half 1 — the orchestrator's stage results…"); the architect's ruling: half 2 proceeds, D-243-1 unchanged, plus reading (f) and the reset's range precision |

**HALF 2 (started ~05:20 on the orchestrator's word; the tip at its start `ceca0af3b`).** Revert state: **NO REVERT IS
IN FLIGHT and none is needed** — reading (f) lands in the pin file FIRST, in its own commit, with no production line;
`DerivedData/vm24-b-red` is built from the tree at that commit (production files byte-identical to `d63c1e2cd`'s).
`vm24-b-pin` stays frozen as half 1's product. The fix lands only after that build has succeeded.

| Half 2 piece | State |
|---|---|
| Reading (f), the open tail, added to `MobileTypedTextFaceTests` (base API only) | DONE (`03b06f417`) — compiles; red/green PENDING the window |
| Red build `DerivedData/vm24-b-red` (the pin with (f), no fix) | DONE at the tree of `03b06f417` (no production file differs from `d63c1e2cd`) — `** TEST BUILD SUCCEEDED **`, log `DerivedData/logs/vm24-b-red-bft.log`, the binary carries (f). FROZEN |
| The fix (D-243-1): the changed characters' face reset to the base before the line's restyle, every routed arm, equality-gated | DONE (`efc66ee57`) — `MobileTypedFace.swift` (new, the pure rule) + its one call in `storageDidEdit` + the model's `typedFaceResets` count; green PENDING the window |
| The gate's pins (plain prose typed in plain prose writes nothing; the reset's own pass count) | DONE (`151d98a87`, its pass counter made sendable-clean in the commit after it) — `MobileTypedFaceResetTests.swift` (new): `MobileTypedFaceRuleTests` (6, bare storage, pass-counted) + `MobileTypedFaceGateTests` (2, her road); green PENDING the window |
| Fix build `DerivedData/vm24-b`; the Mac — no Mac-compiled file is to change, so batch A's `vm24-a-mac` serves | DONE at the code of the commit after `151d98a87` — `** TEST BUILD SUCCEEDED **` (log `DerivedData/logs/vm24-b-bft2.log`; the first attempt, `vm24-b-bft.log`, failed on one Swift 6 sending error in the gate file's pass counter, fixed); no warning in a touched file. Mac: `git diff --stat d63c1e2cd HEAD -- App/Variorum/Shared Sources App/Variorum/Variorum` is empty, so no Mac build was made; `vm24-a-mac` serves the seven source-reading types (they read the phone's files from disk at run time) |
| Half 2's closeout in §12 + the READY report | DONE (the commit after `106a0d2a4`) |
| Half 2's stage window | PENDING — the orchestrator's, from these products (§12, "Batch B · VM-243 — half 2: the fix", its last section) |

### Ladder round 1 · the fix pass — LIVE STATUS (implementer, opus; started 2026-11-20, base `6b5dfb41d`)

Three findings from `notes/plans/fixes/vm-24-ladder-round1.md` (F1, F2, F3): words and comments only, no behaviour.
**Revert state: NO REVERT IS IN FLIGHT, and none is planned** — no pin is being added that would need a red build (the
answers say why). Headless only: no `xcodebuild test`, no simulator boot.

| Piece | State |
|---|---|
| Reading (CLAUDE.md + canon, the protocol, the round-1 report whole, this record §1, §4.3, §5's common rules, §6, §7, the walk's verdicts, `MobileEditTrace.swift` whole, the two test files at the cited lines, `fallbackVerdict` and the capture) | DONE |
| The answers to F1, F2, F3 in the round-1 file, committed before any fix | DONE (`f40e9af0c`) — all three AGREE; F1 takes "(snap-backs avoided)", no optional pin; two observations left for the reviewer and her (Terminal wraps its other parenthetical lines; "rescued" during a flight) |
| F1 (the "rescued" line's parenthetical) + F3 (one clause in the trace header), one commit | DONE (`9675f8888`) — `MobileEditTrace.swift` only; CONFIRMED by the reviewer's final calls (`359baa52b`), the missing pin accepted |
| F2 (the routing suite's doc sentence) | DONE (`b3fa281f9`) — `MobileEditRoutingTests.swift` doc comment only; CONFIRMED |
| The phone `build-for-testing` into `DerivedData/vm24-gate` (first build) | DONE — of the tree at `b3fa281f9`: `** TEST BUILD SUCCEEDED **`, log `DerivedData/logs/vm24-gate-bft.log`, 0 errors, no warning in a touched file. SUPERSEDED by the rebuild below (final call 2 changed one string after it) |
| "What was applied" + the first build's result in the round-1 file | DONE (`afc808024`) |
| **Final call 2** (the reviewer's "## Final calls", relayed by the orchestrator): the "widened" headline's DRAFT parenthetical becomes "(past the change)", exactly as specified; measured BEFORE committing with the same CoreText method — Terminal 361.6 pt at a five-digit count against the 362 pt measure, Study 256.9 pt | DONE (this commit) — `MobileEditTrace.swift`'s headline only; no pin asserted the old words (the trace suite checks the prefix `"  widened           1"`, still true); the per-event mark untouched. Observation 2 is record-only, by the call |
| The gate's phone product rebuilt into `DerivedData/vm24-gate` | DONE — of the tree at `8f5323554`: `** TEST BUILD SUCCEEDED **`, log `DerivedData/logs/vm24-gate-bft2.log`, 0 errors, no warning in the touched file; the dylib carries "(past the change)" and "snap-backs avoided", neither old wording. No Mac build owed. **Nothing under App or Sources changes after `8f5323554`** — THE GATE'S PRODUCT |
| Final call 2 in the round file's "What was applied" + the rebuild's result | DONE (this commit) |
| Owed elsewhere, not this pass's | a capture of the fixed readout (recommended by the reviewer, not owed; the orchestrator's) |

## 12. Batch closeouts, findings and dispositions

*(Each implementer's closeout; the orchestrator's stage results; the ladder's dispositions.)*

### Batch A · VM-24 — an unarmed report is routed from the characters that changed (implementer closeout)

**Not done in this batch (first, by the record's rule):** NO test was run — every red and every green below is
PENDING the orchestrator's stage window (the commands are at the end of this section, runnable from my built products).
No simulator walk (L9, the orchestrator's), no device, no Debug launch. Not touched: VM-243 (batch B), the Mac (D-24-3:
its twin is the orchestrator's ticket, L14), TEXTKIT2_NOTES §3 (L12, the orchestrator's at closeout), VX-68 (L13),
`notes/QUESTIONS.md` and every shared ledger. No `Shared/`, `Sources/`, `Sync/`, custody or schema line.

**Base** `4b0eaaacb`. **Commits:** `7fe494aee` (live status) · `ea5a7a635` (pins 1–4, base API only — the red build's
tree) · `44db1a748` (the red build recorded) · `a8662b81e` (the fix and the trace) · `d98d12517` (pins 5 and 6, one
fence-suite comment) · `d4085103c` (a pin reads its own recorder) · `75606a263` (the live status flipped — its message
names a closeout it did not carry: the edit that wrote it had failed, which this commit's text corrects) · the next
commit (this closeout).

#### What shipped, file by file

- `App/Variorum/VariorumMobile/Features/Write/MobileEditorViewModel.swift` — the fix (D-24-1), and nothing else moves:
  - `MobileStorageObserver` implements `textStorage(_:willProcessEditing:range:changeInLength:)` and holds a
    `MobileChangedCharactersCapture`. Its `didProcessEditing` TAKES the kept value first — inside the main-actor hop,
    before the `.editedCharacters` guard, so on every callback whatever its mask — and hands it on as the new
    argument.
  - `MobileChangedCharactersCapture` (new, `nonisolated` like `ArmedEdit`, at the end of the file): the pure pairing
    rule. `willProcess` keeps `(range, delta)` only when the mask holds `.editedCharacters`, and REPLACES whatever was
    kept (an attribute-only pass keeps nothing — design call 2); `take` returns the kept range only when its delta
    equals the report's and its range lies inside the reported range, and leaves nothing kept either way.
  - `storageDidEdit(_:changeInLength:changedCharacters: NSRange? = nil)` — the one optional argument; nothing but the
    observer passes it.
  - `fallbackVerdict(editedRange:delta:changedCharacters:)` — rebuilds the old range from the changed characters when
    given, else from the report: with nil the arithmetic is the old line byte for byte (`changed = changedCharacters ??
    editedRange`).
  - An unbound edit's churn cost: `bound?.exactCost ?? changedCharacters.map { ($0.length - delta) + $0.length }` —
    `exactCost`'s own rule (old + new lengths) over the changed characters; with neither, `recordAutosave`'s report
    arithmetic as before.
  - The E1 `report` call moved below the verdict (a pure append still, before any arm runs) and passes the changed
    characters and a non-escaping `rescued` closure. `refuses(_:)` is a two-line private helper.
  - Kept on the REPORTED range, as ruled: `restampProjection`, `MarkdownFace.restyle`, `refreshChrome(scope:)` — and
    `markdownCaret.noteEdit` at the top (not named by the ruling; left unchanged — design call 4).
  - The header's routing paragraph and the doc comments of `storageDidEdit`, `fallbackVerdict`, `recordAutosave` and
    the observer say the new rule.
- `App/Variorum/VariorumMobile/Features/Write/MobileEditTrace.swift` — the instrument (D-24-4): `Flags` widened to
  `UInt16` (seven bits were used) with `.widened`, `.rescued`, `.noCapture`; `Event` gains `changedLocation` /
  `changedLength` (-1 when unknown); `Summary` gains `widenedReports`, `rescuedReports`, `reportsWithoutCapture`;
  `report(…changedCharacters:rescued:)` marks a report WIDENED when the reported length exceeds the changed length,
  RESCUED when it is unbound and widened and `rescued()` says the report alone refuses where the changed characters
  route, NO CAPTURE when nothing was kept; three headline lines and three per-event marks (DRAFT words, below); the
  os_log line gains the two offsets; the header gains a "VM-24's three additions" section. Disarmed, `report` still
  returns at its first guard, so the closure is never called and nothing is formatted.
- `App/Variorum/VariorumMobileTests/MobileUnarmedEditRoutingTests.swift` (new) — pins 1–4, base API only.
- `App/Variorum/VariorumMobileTests/MobileChangedCharactersCaptureTests.swift` (new) — pin 5, two suite types:
  `MobileChangedCharactersCaptureTests` (pure) and `MobileChangedCharactersObserverTests` (the real observer + model).
- `App/Variorum/VariorumMobileTests/MobileEditTraceTests.swift` — pin 6: five tests; one stale comment corrected (the
  gate-less-insertion parenthetical).
- `App/Variorum/VariorumMobileTests/MobileStructuralFlightFenceTests.swift` — ONE comment (road C's parenthetical now
  says the non-last-block shape is VM-24's pin). No fence pin's code changed.

#### Against §4, ruling by ruling

| Ruling | Built |
|---|---|
| D-24-1 · the observer hears `willProcessEditing`, keeps `(range, delta)` when the mask holds `.editedCharacters` | yes — `MobileStorageObserver.textStorage(_:willProcessEditing:…)` → `capture.willProcess` |
| · `didProcessEditing` takes and clears FIRST, on every callback whatever its mask | yes — `capture.take` is the first statement inside the hop, before the mask guard |
| · accepted only when delta equals and range lies inside; else dropped | yes — `MobileChangedCharactersCapture.accepts` |
| · `storageDidEdit` gains one optional argument defaulting to nil | yes |
| · `fallbackVerdict` from the changed characters, else the report; no kept value ⇒ today's behaviour byte for byte | yes |
| · unbound churn cost from the changed characters when known | yes |
| · re-stamp, restyle, chrome keep the REPORTED range | yes (and the caret claim — design call 4) |
| · nothing else in the routing moves (binding, four arms, refusal road, both fence belts, settle) | yes — the `switch` and everything after it is byte-unchanged; the gate is untouched |
| D-24-2 · the five rows | row 1 is pin 1; row 2 is pin 4; row 3 is pin 2 (and the existing composed-transaction and crash pins, whose changed characters still cross); rows 4–5 — no armed path or gate line changed |
| D-24-3 · the Mac | untouched (the empty diff in the live status); the twin is the orchestrator's ticket |
| D-24-4 · widened · rescued · no capture; the extra verdict only armed and only unbound + widened; offsets and counts only | yes — pinned by `theRescueVerdictIsAskedOnlyArmedAndOnlyForAnUnboundWidenedReport` |

#### The pins (none run yet — every column below is EXPECTED, PENDING the window)

| # | Pin | Kind | Red build `vm24-a-red` | Fix build `vm24-a` |
|---|---|---|---|---|
| 1 | `MobileUnarmedEditRoutingTests.anUnarmedEditWhoseReportIsWidenedPastItsBlockRoutesToItsBlock(_:)` × 3 (insert at the block's end, insert mid-paragraph, replace mid-paragraph) | bug pin | RED, each case: a recorded "the editor's debug assertion fired" issue, `desyncRecoveryCount == 0` false, the index and the store without the edit | green |
| 2 | `…anUnarmedReplaceThatTrulySpansASeparatorStillRefusesAndHeals()` | control | green | green |
| 3 | `…aConsultedInsertWhoseArmingWasSpentRoutesToItsBlock()` (E1 #50–#52) | bug pin | RED: the second report desyncs; the comma never reaches the store | green |
| 4 | `…anUnarmedWidenedEditInANonLastBlockDuringADivideIsWithheldAndSaid()` | bug pin (D-24-2's new fence pin) | RED: a mid-flight desync (recorded), and no sentence (the belt was never reached) | green |
| 5 | `MobileChangedCharactersCaptureTests` (5 tests) · `MobileChangedCharactersObserverTests` (4 tests) | the new machinery's tests | not in the red build (they need the new API) | green |
| 6 | `MobileEditTraceTests`: `aWidenedUnarmedReportIsMarkedAndItsRescueCounted`, `aBoundWidenedReportIsWidenedButNeverRescued`, `theRescueVerdictIsAskedOnlyArmedAndOnlyForAnUnboundWidenedReport`, `aReportWithNoKeptValueIsCountedAndMarked`, `armingTheTraceChangesNothingOnTheRescuedRoad` | the instrument's tests | not in the red build | green |
| 7 | `MobileMarkdownCaretTests.aReplaceThroughTheInputRoadAtARescuePointKeepsTheSurfaceInStep(_:)` — NOT edited | the standing pin | RED in main's shape ("hi", "hello there"; "Hello" green) | green, 3 of 3 — which also proves the delegate's first callback fires on UIKit's own replace road |

**How "red on old" is shown:** by a BUILD of the pins over the base's production files without any revert —
`vm24-a-red` is the tree at `ea5a7a635`, where the only differences from the base are the new test file and this
record. The pins' file has not changed since, so the red build stays current; `vm24-a-red` is frozen. (Remaking it,
should it ever be lost: a `git worktree add` at `ea5a7a635` and the same `build-for-testing`; no checkout over this
worktree.) **Red counts only at the routing expectations:** every pin first asserts its own premise — the edit reached
the report with no gate consult (its own armed trace recorder), the storage's pre-fixing range is exactly the change,
and fixing widened the report through the block's terminator (both read from the storage's own notifications,
`StorageReports`) — and those premises are TextKit's facts, true on both trees. **A red at a premise line ("before
fixing, the storage's range…", "fixing widened the report…", "…with no gate consult", "the first report took the
arming…") is NOT the expected red: stop and report it — it would mean the construction no longer widens.**

**Why each widened report is widened every time (the construction):** every edit in pins 1, 3, 4 is a storage write
whose new run carries a font and NO paragraph style, landing mid-paragraph or at a paragraph's end (never at its
start), in a paragraph whose every character wears the surface's base paragraph style
(`MobileEditorStyle.baseAttributes`, through the materializer). Fixing must write the paragraph's style over the new
run, and iOS reports that write from the edit's location through the paragraph's terminator — TEXTKIT2 §3's iOS fixing
finding, round 2's M12 (`{8, 9}`), VM-2's r1 window (this very write refused in a non-last block on both of its trees,
every run), and `MobileEditTraceTests.theSpecifiedPredicateWouldFireOnEveryOrdinaryKeystroke` (green in the 49, on the
bare storage). No earlier suite can leave the run already wearing the style object — it carries none — which is
exactly the difference from a bare `insertText`, whose typing attributes can (TEXTKIT2 §3, VM-2: the process-state
dependence). Pin 3's first report lands in the LAST block, whose widened report ends at the document's end, so it
routes on any tree. The changed characters are deterministic too: a single `replaceCharacters` outside any open
transaction is processed at once, and its pre-fixing range is the replacement's own range. Determinism is proven, as
§5 asks, by the window running the suite ALONE and then after the editor suites in one host ((ii-a) and (ii-b)).

**A macOS probe, recorded as such (2026-11-20, a scratch script run with `swift`, not a test host, no stage):** on
macOS 27 UIFoundation's `NSTextStorage` sends the DELEGATE's `willProcessEditing` for a programmatic
`replaceCharacters`, exact, before fixing; `didProcessEditing` widens a font-only insert through the terminator —
insert at a paragraph's end `{11,1}` → `{11,2}`; mid-paragraph `{6,1}` → `{6,7}`; a replace `{6,2}` → `{6,4}`; a
deletion `{6,0}` → `{6,0}`; an insert carrying its neighbour's own attributes `{6,1}` → `{6,1}`; an attribute-only edit
reports mask 1 to both callbacks; an attribute write made inside the delegate's `didProcessEditing` triggers no nested
callback there (it joins the pass). Evidence for the shared storage's behaviour on the Mac only — **iOS's own answer is
the window's** (the standing pin going green is the proof that the first callback fires on UIKit's replace road;
VM-78's window saw the `willProcessEditing` NOTIFICATION exact on that road, `{1,2}` against `{1,5}`).

#### Design calls (options weighed; the built one first — none is a product decision)

1. **The red build without a revert.** (a) **built:** pins 1–4 use only base API and land first, so the red build is
   the pins commit's tree; (b) the revert protocol over the fix's production files. (a) cannot leave a half-restored
   production file and needs no restore; (b) stays the road if a pin is ever edited after the fix.
2. **An attribute-only `willProcessEditing` clears the kept value.** (a) **built:** every first callback REPLACES the
   kept value (nil for an attribute-only pass); (b) leave the kept value alone on an attribute-only first callback (the
   ruling's minimum). (a) is strictly safer — a value can only ever pair with the next second callback of the pass it
   was kept in — and costs nothing: no attribute-only pass sits between a character pass's two callbacks.
3. **`rescued` counts UNBOUND reports**, a rejected arming included (pin 3's E1 shape is exactly a rescue); "unarmed"
   in D-24-4 read as "routed by the fallback". Alternative: gate-less only (no consult since the last report) — it
   would not count the spent-arming road the fix also repairs.
4. **The caret claim (`markdownCaret.noteEdit`) keeps the reported range** — D-24-1 names what keeps it and says
   nothing else moves; routing it from the changed characters would change VX-296's ledger arithmetic, which is no
   part of this unit. Recorded for batch B's reader (the face is VM-243's).
5. **Pin 4 lives in the new suite**, with the fence suite's hold copied file-private, rather than as an eleventh pin in
   the fence suite (whose ten pins ride every window unchanged); the fence suite's road-C comment points at it.
6. **The trace's per-event mark shows the changed characters' offsets** ("widened — changed at 24 len 1") — offsets
   only, so "widened" is read from the line, not inferred.

#### Self-assessment against §8's review foci

1. *Pairing:* taken first at every second callback, inside the hop and before the mask guard; nested attribute-only
   passes (the re-stamp, the restyle) can neither read nor leave a value; a suppressed programmatic write's own pass
   keeps and takes its own value and returns at `suppressEditProcessing`; one observer per storage (`attach(storage:)`
   mints one). The residue: a CHARACTER pass whose first callback arrived between another pass's two callbacks would
   meet a value it does not own — that needs a character edit inside fixing, which nothing does; the delta and inside
   checks would still have to pass.
2. *No refusal loosened:* the pre-fixing range is the union of everything the pass changed, so a change crossing a
   separator still crosses it (pin 2); the existing cross-block pins — `aComposedTransactionWiderThanItsApprovalIsNot
   Consumed`, the two coalesced-delete crash pins, E1's crash-shape pins — all keep their crossing changed range.
3. *The fence:* a widened unarmed edit during a flight now reaches the storage belt (withheld, forced re-read, said);
   nothing new is written toward the store during a flight; the gate belt and the settle are untouched.
4. *The store:* routing now reads the storage's own pre-fixing account; no judgement path was added.
6. *TextKit:* no TK1 API, no layout forced, no attribute write added anywhere (the capture writes nothing), the
   canary checkpoint unchanged.
7. *The trace:* disarmed, one guard and a return (the closure never runs — pinned);
   `MobilePerfWalkTests.theEditTraceIsInertDisarmedAndQuietArmedAt100k` compares `Summary` to an empty one, which the
   new zero-defaulted counters keep true (optional window item (v)).
8. *The Mac:* no Mac, `Shared/` or `Sources/` line; the Mac build compiles.

#### Words (DRAFT, for her wording pass — the edit trace's readout, Settings ▸ Diagnostics ▸ Edit trace…)

Three headline lines: `widened … (ran past the characters that changed)` · `rescued … (each one a snap-back that did
not happen)` · `no capture … (expected 0)`. Three per-event marks: `widened — changed at N len M` · `rescued` · `no
capture`. No retired vocabulary.

#### Residuals (traced, not fixed here)

- `MobileEditRoutingTests.aStaleVerdictIsNotAppliedToTheNextEdit`'s doc says a widened gate-less report "can already
  overflow its entry and take the honest recovery road" — true before VM-24, now only when no changed characters were
  kept. A comment in a suite this batch does not otherwise touch; left for the ladder to call.
- TEXTKIT2 §3: the window's results (whether the delegate's first callback fires on UIKit's replace road, measured by
  the standing pin) are the orchestrator's canon line (L12).
- Her phone: the "after" session's three new counts are what say whether some road reports with no first callback
  (`no capture` above 0) — MobileSoul §5.2's device test.

#### For QUESTIONS at the merge

None new from this batch. The trace's new words are §10 item 6's (DRAFT). Design calls 2–6 above are the
implementer's, recorded for the ladder, not hers.

#### The stage window (the orchestrator's; the GO's claim line and UDID fill `<simulator-udid>`; boot fresh, settle 30 s, run, shut down)

Products: `App/Variorum/DerivedData/vm24-a-red` (red, the tree at `ea5a7a635`, frozen), `…/vm24-a` (the fix, the
code of `d4085103c`), `…/vm24-a-mac` (Mac, the code of `d98d12517`). Logs and bundles: `DerivedData/logs/`,
`DerivedData/vm24-bundles/` (a bundle name is never reused). Poll for the Swift Testing verdict line, never the exit.

```zsh
cd ~/dev/variorum-vm-24/App/Variorum
T=(xcodebuild test-without-building -project Variorum.xcodeproj -scheme VariorumMobile
   -destination 'platform=iOS Simulator,id=<simulator-udid>' -collect-test-diagnostics never)

# (i) the red build: the new suite and the caret suite
red=(MobileUnarmedEditRoutingTests MobileMarkdownCaretTests)
"${T[@]}" -derivedDataPath DerivedData/vm24-a-red -resultBundlePath DerivedData/vm24-bundles/a-red.xcresult \
  ${red/#/-only-testing:VariorumMobileTests/} > DerivedData/logs/vm24-a-red-run.log 2>&1

# (ii-a) the fix build: the three new types ALONE
alone=(MobileUnarmedEditRoutingTests MobileChangedCharactersCaptureTests MobileChangedCharactersObserverTests)
"${T[@]}" -derivedDataPath DerivedData/vm24-a -resultBundlePath DerivedData/vm24-bundles/a-alone.xcresult \
  ${alone/#/-only-testing:VariorumMobileTests/} > DerivedData/logs/vm24-a-alone.log 2>&1

# (ii-b) the fix build, ONE invocation: the three new types, then VM-64's 49 editor types
tests=(MobileUnarmedEditRoutingTests MobileChangedCharactersCaptureTests MobileChangedCharactersObserverTests
  MobileStructuralFlightFenceTests MobileStructuralTests MobileSelectionActsTests
  MobileEditorMaterializationTests MobileCanaryTests MobileEditorRoutingTests MobileEditorCrystallizationTests
  MobileEditorProjectionTests MobileTypewriterRoomTests MobileNoteSealTests MobileFindInNoteTests
  MobileEditRoutingBindingTests MobileIdentityAuditSeparatorTests MobileBulkArmingTests MobileCanaryTeardownTests
  MobileEditRoutingCrashTests MobileEditRouteArmsTests MobileWholeBlockDeleteBrainTests MobileWholeBlockDeleteTests
  MobileCrossBlockEditBrainTests MobileCrossBlockEditTests MobileMarkdownRenderTests MobileMarkdownReturnTests
  MobileMarkdownActsTests MobileCheckboxTapTests MobileMarkdownCaretTests MobileTakesTests MobileTakesBrowserTests
  MobileTakesBrowserSurfaceTests MobileTakesChromeTests MobileTakeReorderTests MobileTakeToBlockTests
  MobileTakeLockTests MobileUndoDoorTests MobileBlockMenuTests MobileCommentsTests MobileBlockDecorTests
  MobileWalkTests MobileTrailingNewlinesTests MobileSpaceEaterTests MobileCRLFCaptureTests
  MobileWriteScrollAuthorityTests MobileScrollAuthorityBrainTests MobileLivenessTests
  MobileDeferredProjectionRetryTests MobileTypedOverRescueTests MobileEditTraceTests MobileKeyDoorPostureTests
  MobileSavepointOnLeavingTests)
"${T[@]}" -derivedDataPath DerivedData/vm24-a -resultBundlePath DerivedData/vm24-bundles/a-company.xcresult \
  ${tests/#/-only-testing:VariorumMobileTests/} > DerivedData/logs/vm24-a-company.log 2>&1

# (iv) the Mac's seven types that read every phone file (no simulator)
mac=(DeadVocabularyTests DataSafetySearchIndexTests PaneLineMetricsScopeTests OneRefreshAuthorityCompositionTests
  OneInputPathTests PaletteDerivationTests GlyphRainTests)
xcodebuild test-without-building -project Variorum.xcodeproj -scheme Variorum -destination 'platform=macOS' \
  -derivedDataPath DerivedData/vm24-a-mac -collect-test-diagnostics never \
  -resultBundlePath DerivedData/vm24-bundles/a-mac.xcresult \
  ${mac/#/-only-testing:VariorumTests/} > DerivedData/logs/vm24-a-mac-run.log 2>&1

# (v) OPTIONAL (focus 7): the 100k trace pin alone, from the fix build — the argument quoted whole
"${T[@]}" -derivedDataPath DerivedData/vm24-a -resultBundlePath DerivedData/vm24-bundles/a-perf-trace.xcresult \
  '-only-testing:VariorumMobileTests/MobilePerfWalkTests/theEditTraceIsInertDisarmedAndQuietArmedAt100k()' \
  > DerivedData/logs/vm24-a-perf-trace.log 2>&1
```

Expected (Swift Testing counts test FUNCTIONS, a parameterized one once; read the `skipped` lines):
- **(i)** "Test run with 8 tests in 2 suites failed". Red, by name:
  `anUnarmedEditWhoseReportIsWidenedPastItsBlockRoutesToItsBlock(_:)` (all three cases),
  `aConsultedInsertWhoseArmingWasSpentRoutesToItsBlock()`,
  `anUnarmedWidenedEditInANonLastBlockDuringADivideIsWithheldAndSaid()`,
  `aReplaceThroughTheInputRoadAtARescuePointKeepsTheSurfaceInStep(_:)` for "hi" and "hello there". Green:
  `anUnarmedReplaceThatTrulySpansASeparatorStillRefusesAndHeals()`, the caret suite's other three tests and its
  "Hello" case. No host restart (every desync is recorded, never trapped). A red at a premise line is not the
  expected red (above).
- **(ii-a)** "Test run with 13 tests in 3 suites passed".
- **(ii-b)** "Test run with N tests in 52 suites passed", one host process, `Restarting after unexpected exit` = 0;
  the caret suite 4 of 4 with the standing pin 3 of 3 cases; the fence suite 10 of 10; `MobileEditTraceTests` 13 of
  13. Any red is named and is a finding (main's whole-target baseline after wave 1 had only the standing pin red).
- **(iv)** "Test run with N tests in 7 suites passed".
- **(v)** "Test run with 1 test in 1 suite passed" (heavy: the 100k worlds).

#### Batch A — the orchestrator's stage results (the window; every PENDING above is settled here)

**Claim `vm-24`, 2026-11-20 04:47:46 → released 04:51:34, nov18's GO.** The tree at `2ad0eabce` (code as built: the
red build `vm24-a-red` at `ea5a7a635`, the fix `vm24-a` at `d4085103c`, the Mac `vm24-a-mac` at `d98d12517`; the
later commits are records). The standing iPhone 17 Pro / iOS 26.2 simulator, one fresh boot, a 30 s settle, one
launch per leg, `Restarting after unexpected exit` = 0 in every log, every `xcodebuild` exited by itself. Logs:
`App/Variorum/DerivedData/logs/vm24-a-red-run.log`, `-alone.log`, `-company.log`, `-mac-run.log`, and the summary
`vm24-a-window-summary.txt`. Run by the orchestrator from the implementer's products, with §12's commands.

| Leg | Verdict line | Reds, by name |
|---|---|---|
| (i) the red build: the new suite and the caret suite | "Test run with 8 tests in 2 suites failed after 2.631 seconds with 31 issues." | `anUnarmedEditWhoseReportIsWidenedPastItsBlockRoutesToItsBlock(_:)` — all three cases (an insert at the block's end, an insert mid-paragraph, a replace mid-paragraph): a recorded desync, the index lengths, `autosave.isDirty`, the stored text, the page · `aConsultedInsertWhoseArmingWasSpentRoutesToItsBlock()` · `anUnarmedWidenedEditInANonLastBlockDuringADivideIsWithheldAndSaid()` (a desync; the fence's sentence not said) · `MobileMarkdownCaretTests.aReplaceThroughTheInputRoadAtARescuePointKeepsTheSurfaceInStep(_:)` for "hi" and "hello there" (`:215`). **Green:** `anUnarmedReplaceThatTrulySpansASeparatorStillRefusesAndHeals()` (the control) and the caret suite's other three tests. Every red is an outcome line; no premise line (no consult, the pre-fixing range exact, the report widened) failed |
| (ii-a) the fix build: the three new types alone | "Test run with 13 tests in 3 suites passed after 1.192 seconds." | none |
| (ii-b) the fix build: the three new types, then VM-64's 49, ONE invocation | "Test run with 371 tests in 52 suites passed after 57.135 seconds." — 52 passed-suite lines, 0 failed, 0 skipped | none. **The standing pin is green, three cases of three, its file unedited** ("with 3 test cases passed"); the fence suite passed, its ten pins byte-identical to main's |
| (iv) the Mac's seven types that read every phone file | "Test run with 46 tests in 7 suites passed after 13.770 seconds." | none |

After the window: the simulator shut down (0 booted); its app container lists `Variorum-dev` only; no Variorum or
VariorumMobile instance; no Problem Reporter; no new crash report; the Debug defaults 1,356 keys, unchanged.

**What this settles.** The new pins are red on the old code in the shape the closeout tabled and green on the fix,
alone and in company. The standing pin going green by the fix alone shows the storage delegate's
`willProcessEditing` DOES fire, with the exact range, on UIKit's own `replace(_:withText:)` road on iOS 26.2 (the
simulator) — the measurement L12's TEXTKIT2 line records. Not run: item (v), the 100k trace pin alone; the gate's
whole phone target runs `MobilePerfWalkTests`.

**The fence file** (`MobileStructuralFlightFenceTests.swift`): the batch changed a doc comment above the road-C pin,
four lines; no test was added and no expectation moved.

### Batch B · VM-243 — half 1: the pin as the confirm (implementer closeout of the half; STOPPED for the orchestrator)

**Not done in this half (first, by the record's rule):** NO test was run — every red and green below is EXPECTED,
PENDING the orchestrator's stage window. No fix: D-243-1 is not written, and half 2 waits on the orchestrator's word
after the window ("red as predicted ⇒ half 2; anything else ⇒ the architect rules", batch B). No simulator walk, no
device, no Debug launch. Not touched: any production file (`git diff --stat d63c1e2cd -- App/Variorum/VariorumMobile
App/Variorum/Shared Sources App/Variorum/Variorum` is empty), `Shared/`, `Sources/`, `Sync/`, the Mac, every shared
ledger.

**Base** `d63c1e2cd` (batch A merged into the branch, no VM-243 line). **Commits:** `3a2dab9b9` (live status) ·
`b437305db` (the pin) · the next commit (this closeout and the flipped live status).

#### What shipped

- `App/Variorum/VariorumMobileTests/MobileTypedTextFaceTests.swift` (new) — the suite `MobileTypedTextFaceTests`
  (`.serialized`), five tests, one per reading. File-private copies of the fence suite's `host`, `dismiss`,
  `withDesyncsRecorded` and `keyboardType` (batch A's design call 5: the fence suite's ten pins stay byte-unchanged);
  `betweenKeystrokes` (one `Task.yield` and one 1 ms sleep — a run-loop turn between keys, as between her keystrokes);
  `FaceReading` (reads and names what characters wear; writes nothing); `onAFreshLine` (the world every reading types
  in); `typeKeys`; `expectTypedAndStored`. Base API only: it builds against this tree, which IS the base for VM-243.

#### The construction

- **The road is her keyboard's** (TEXTKIT2 §3's rule for a pin that types): `keyboardType` asks the gate first and
  calls `insertText` only on a yes; a `"\n"` goes on through the editor's ⏎ door (`MobileEditorTextView.insertText` →
  `MobileMarkdownActs.handleReturnKey`: the list's continuation and its K5 exit) exactly as her Return key does. Hosted
  in her posture (the fence suite's `host`). A run-loop turn between keystrokes.
- **The fixture** is a Study note `["Intro.", "After."]`; each reading places the caret at `"Intro.|"`, types one
  Return (content inside block 0) and types on that fresh line — below a line in full ink, inside block 0, with a block
  after it. So no open tail, no crystallization flight and no normalizing programmatic write ever touches the typed
  text (the tail's normalizing replace is one of §4.4's "sometimes it does go away" writes, which would confound the
  reading).
- **Study voice**, set inside the world after `withEditorWorld`'s reset (the caret suite's shape), restored after.
  Premise: the marker's ink and the prose ink draw differently there.
- **Colours are compared RESOLVED** under one fixed light trait collection (`FaceReading.drawSame`, a 0.002 RGBA
  tolerance), never by object identity, so the reading never depends on the host's appearance or on which object a
  copy carries. "Full ink" = draws as `MobileEditorStyle.face.ink`; "the marker's ink" = draws as
  `markdownPalette.marker`; "the base font" = `baseFont`'s PostScript name and size.
- **Why the reading is deterministic in any company:** every edit is ARMED, so it binds however far iOS widens its
  report (`ArmedEdit.describes`; the fence suite's road A) — the routing cannot decide the outcome; the typed runs'
  attribute VALUES come only from this note's own storage (UIKit's typing attributes derive from the character before
  the caret — the face's writes or the materializer's base); the face's writes are pure functions of the line's text
  and marks. The one process-state-dependent iOS fact (the report's width, TEXTKIT2 §3) can move the restyle's scope
  by at most the next line, `After.`, which holds no markdown and no face mark, so it writes nothing there.
- **What every reading prints** (`grep 'VM243|' <log>`): the fixture before typing; one line per key — where it was
  typed, where the caret landed, and what the character before the caret wears; and per reading the coalesced runs
  over the lines that matter: `[start..<end) “chars” ink=<name> #RRGGBB font=<PostScriptName> <size> (base|larger)
  [faced] [struck] [chip]`. Ink names: `ink` (the face's own object), `prose-ink`, `marker`, `link`, `phone-muted`; a
  `≈` prefix means another object that draws the same; `rgba` alone means none of them; `none` means no ink attribute.
  Only the test's own fixture characters are printed; a newline prints as `⏎`. Each OUTCOME expectation's message
  also carries the runs it found, so a red issue reads by itself.

#### The readings and what §4.4 predicts on THIS tree (the tree before VM-243's fix), by expectation line

Every expectation's message starts with its reading's letter and PREMISE or OUTCOME. **A red at a PREMISE line is not
the predicted red** — it means the construction did not reach what it reads (the fixture's bytes, the gate's
approvals, the Return door's continuation and exit, the dash or stars wearing the marker's face, the heading's font,
the voice): stop and send it to the architect.

| Test (reading) | Expectation line | §4.4 predicts |
|---|---|---|
| `aDashLinesWordsAreTypedInFullInk()` (a) — `- one`, a key at a time | `(a) OUTCOME: “one” is typed in full ink` | **RED** — "one" in the marker's ink, no face mark (it inherits the `" "` before it, mark stripped) |
| | `(a) OUTCOME: “one” wears the base font` | green (a marker is written in the base font) |
| | every `(a) PREMISE` line (the dash wears the marker's ink, faced; the page; no desync; the store) | green |
| `theParagraphAfterADashLineIsTypedInFullInk()` (b) — (a), then Return twice, then `two` | `(b) OUTCOME: “two”, on the line after the dash line, is in full ink` | **RED** — the marker's ink (it inherits the Return typed after "one", which inherited "one"'s) |
| | `(b) OUTCOME: “two” wears the base font` | green |
| | every `(b) PREMISE` line (the continuation `- `, the exit, the caret at 13) | green |
| `wordsTypedAfterAClosingMarkerAreInFullInk()` (c) — on a new line, `*a* b` | `(c) OUTCOME: “ b”, typed after the closing star, is in full ink` | **RED** — the marker's ink (it inherits the closing star, mark stripped) |
| | `(c) OUTCOME: “ b” wears the base font` | green |
| | every `(c) PREMISE` line (the stars are markers, faced; "a" italic) | green |
| `theLineTypedAfterAHeadingWearsTheProseFace()` (d) — `# Head`, Return, `word` | `(d) OUTCOME: “word”, on the line after the heading, is in full ink` | **§4.4: TO BE READ, NOT ASSUMED.** The implementer's reading of the same mechanism (not §4.4's text): **RED** — a heading's content is written with its font and NO ink (`MarkdownFaceCore.swift:331-333`), so the last character typed keeps the ink it inherited (the `"# "` marker's) until the next restyle clears it; the Return typed after "Head" inherits that ink and the heading's font, and "word" inherits the Return's |
| | `(d) OUTCOME: “word” wears the base font, not the heading's` | **to be read**; the implementer's reading: **RED** — the heading's font (`IowanOldStyle-Bold 27.0`, "larger") |
| | every `(d) PREMISE` line ("Head" in a larger font; the Return ordinary) | green. The print also shows "Head" itself in full ink after the Return (its restyle cleared the last letter) and the `⏎` after it carrying the heading's font — read, not asserted |
| `aReopenedNoteDrawsWhatWasTypedInFullInk()` (e) — (a) and (b)'s typing, the editor finished, a fresh editor opened | `(e) OUTCOME: after the re-open “one” and “two” are in full ink` | green — **a control, green on both trees** (the face's attributes are never stored) |
| | `(e) OUTCOME: after the re-open “one” and “two” wear the base font` | green |
| | every `(e) PREMISE` line (the dash re-derived as the marker; the store) | green; the "before the re-open" print shows the live page faint as (a) and (b) |

**The predicted verdict:** "Test run with 5 tests in 1 suite failed … with 5 issues" — four tests red ((a) 1, (b) 1,
(c) 1, (d) 2 if it reads as the implementer's extension; 3 or 4 issues if (d) reads otherwise), (e) green. **Red as
predicted** = (a), (b), (c) red at their ink OUTCOME lines only, every PREMISE line green, (e) green; (d) is read from
its print whatever it shows. **Anything else** — any of (a)–(c) green at its ink line, a font OUTCOME red in (a)–(c),
(e) red, any PREMISE red, a host restart — is the architect's to rule before any fix (§4.4's reservation).

#### Design calls (options weighed; the built one first — none is a product decision)

1. **Type inside block 0 of a two-block note, never in the open tail.** (a) built; (b) type at the note's end, as she
   likely does. (b) puts each completed paragraph through crystallization, whose programmatic write lays the base
   attributes over the typed text — one of the very writes §4.4 names as "sometimes it does go away" — so the reading
   would depend on a mint's timing. The face mechanism is the same in a block and in the tail.
2. **A run-loop turn between keystrokes.** (a) built: one `Task.yield` and a 1 ms sleep; (b) back-to-back calls (the
   caret suite's loop). Her keys arrive in separate run-loop turns, so if UIKit re-derives its typing attributes on a
   later turn, (b) could read green over a road her keyboard never takes. Nothing in these worlds runs on a clock.
3. **One test per reading**, each in its own world, every reading starting on a line in full ink — so (c) and (d) are
   never confounded by an earlier reading's faint ink, and the verdict names the reading. (e) re-types (a) and (b)'s
   keys in its own world before the re-open.
4. **The face is read, never driven:** `FaceReading` writes nothing, and the pin never reads `typingAttributes` (a
   getter UIKit may compute lazily — reading it could change what the next key wears). What each character landed
   wearing is read from the storage after the key.
5. **The OUTCOME expectations state the ruled behaviour** (the ticket's "what the Mac draws", §10 item 7): full ink
   and the base font for prose typed after a marker, so the same pin goes green on D-243-1 without an edit.

#### The stage window (the orchestrator's; the GO's claim line and UDID fill `<simulator-udid>`; boot fresh, settle 30 s, run, shut down)

Products: `App/Variorum/DerivedData/vm24-b-pin` — `build-for-testing` of the tree at `b437305db` (the pin over the base:
no production file differs from `d63c1e2cd`), `** TEST BUILD SUCCEEDED **`, log `DerivedData/logs/vm24-b-pin-bft.log`,
no warning in the new file; the test binary carries the suite. Logs and bundles as batch A's (`DerivedData/logs/`,
`DerivedData/vm24-bundles/`, a bundle name never reused). Poll for the Swift Testing verdict line, never the exit.

```zsh
cd ~/dev/variorum-vm-24/App/Variorum
T=(xcodebuild test-without-building -project Variorum.xcodeproj -scheme VariorumMobile
   -destination 'platform=iOS Simulator,id=<simulator-udid>' -collect-test-diagnostics never)

# (B1) THE CONFIRM: the pin alone, on the tree before the fix
pin=(MobileTypedTextFaceTests)
"${T[@]}" -derivedDataPath DerivedData/vm24-b-pin -resultBundlePath DerivedData/vm24-bundles/b-pin.xcresult \
  ${pin/#/-only-testing:VariorumMobileTests/} > DerivedData/logs/vm24-b-pin-run.log 2>&1
grep 'VM243|' DerivedData/logs/vm24-b-pin-run.log > DerivedData/logs/vm24-b-pin-readings.txt

# (B2) OPTIONAL — the same reading in company (the markdown, caret and fence suites in the same host), to show it
# does not move with what ran before it; the readings are compared line for line with (B1)'s
company=(MobileMarkdownRenderTests MobileMarkdownReturnTests MobileMarkdownActsTests MobileMarkdownCaretTests
  MobileStructuralFlightFenceTests MobileTypedTextFaceTests)
"${T[@]}" -derivedDataPath DerivedData/vm24-b-pin -resultBundlePath DerivedData/vm24-bundles/b-pin-company.xcresult \
  ${company/#/-only-testing:VariorumMobileTests/} > DerivedData/logs/vm24-b-pin-company.log 2>&1
grep 'VM243|' DerivedData/logs/vm24-b-pin-company.log > DerivedData/logs/vm24-b-pin-company-readings.txt
```

Expected: **(B1)** the predicted verdict above, one launch, `Restarting after unexpected exit` = 0. **(B2)** the five
pin tests exactly as in (B1), and every other test as on main (the caret suite 4 of 4, its standing pin green 3 of 3
since batch A; the fence suite 10 of 10; the markdown suites green); the `VM243|` lines identical to (B1)'s.

#### For QUESTIONS at the merge

None from this half.

#### Batch B, half 1 — the orchestrator's stage results, and the architect's ruling on what the pin showed

**Claim `vm-24`, 2026-11-20 05:08:45 → released 05:10:19, nov18's GO.** Products `DerivedData/vm24-b-pin` (the tree
at `b437305db`: batch A's fix, no VM-243 fix). The standing simulator, one fresh boot, a 30 s settle, two launches,
`Restarting after unexpected exit` = 0 in both. Logs `DerivedData/logs/vm24-b-pin-run.log` and
`vm24-b-pin-company.log`; the printed readings `vm24-b-pin-readings.txt`.

| Launch | Verdict line | The five readings |
|---|---|---|
| (B1) the pin alone | "Test run with 5 tests in 1 suite failed after 1.673 seconds with 5 issues." | (a) `aDashLinesWordsAreTypedInFullInk()` RED at `:376` (ink; font green) · (b) `theParagraphAfterADashLineIsTypedInFullInk()` RED at `:410` (ink) · (c) `wordsTypedAfterAClosingMarkerAreInFullInk()` RED at `:442` (ink) · (d) `theLineTypedAfterAHeadingWearsTheProseFace()` RED at `:476` (ink) and `:478` (font) · (e) `aReopenedNoteDrawsWhatWasTypedInFullInk()` GREEN. Every PREMISE line green |
| (B2) in company, six types, one invocation | "Test run with 49 tests in 6 suites failed after 4.608 seconds with 5 issues." | the same five issues at the same five lines; the caret suite, the fence suite and the three markdown suites passed |

What the pin printed (Study, light): the lead `"- "` in the marker's ink `#8D8578` WITH the face's mark; `"one"`, and
then `"one⏎two"`, in the same marker ink WITHOUT the mark; `" b"` after a closing star the same; after a heading,
`"⏎word"` in the marker's ink AND the heading's font (`IowanOldStyle-Bold 27.0`), unmarked; after the re-open,
everything typed in full ink `#29241C`. The readings are the same alone and in company (one line differs only by a
system log line the simulator interleaved into it).

**The architect's ruling (2026-11-20 05:12).** §4.4's mechanism is CONFIRMED as traced: red where it predicted
red, green where it predicted green, and the printed runs show the inherited ink without the mark. Reading (d),
which §4.4 left to be read, shows the FONT leaks as well as the ink — text typed on the line after a heading keeps
the heading's font. That is inside D-243-1 as ruled (the reset covers font and ink), so **half 2 proceeds, D-243-1
unchanged**, with two precisions:

1. **One added reading, (f): the open tail.** The pin types inside a settled block; she mostly types at the end of
   a note. A reading types the dash line and the paragraph after it at the note's very end and reads the runs before
   any re-open — so the `.tail` arm's reset is pinned too ("every routed arm"). It is added to the pin FIRST and
   shown on a build without the fix (`DerivedData/vm24-b-red`), whatever it shows there (red is expected; if the
   tail's own writes already lay the base back it is green on both and recorded as such, not forced red).
2. **The reset's range for an ordinary typed key is D-24-1's kept value** — batch A hands the changed characters to
   `storageDidEdit` for every character report, bound or not — so the keyboard's road and the unarmed roads take the
   same reset.

### Batch B · VM-243 — half 2: the fix (implementer closeout)

**Not done in this half (first, by the record's rule):** NO test was run — every red and green below is EXPECTED,
PENDING the orchestrator's stage window. No simulator walk (L9), no device, no Debug launch. No Mac build: no
Mac-compiled file changed (`git diff --stat d63c1e2cd HEAD -- App/Variorum/Shared Sources App/Variorum/Variorum` is
empty), so batch A's `vm24-a-mac` serves the seven source-reading types. Not touched: `Shared/`, `Sources/`, `Sync/`,
custody, schema, the Mac, the caret suite (unedited), every shared ledger. The gated speed suite is the gate's.

**Commits (half 2):** `03b06f417` (reading (f), base API only — the red build's tree) · `efc66ee57` (the fix) ·
`151d98a87` (the reset's own pins) · `106a0d2a4` (the pins' pass counter made Swift-6 clean; the fix build) · the next
commit (this closeout).

#### What shipped, file by file

- `App/Variorum/VariorumMobile/Features/Write/MobileTypedFace.swift` (new, phone-only) — the pure rule
  `MobileTypedFace.reset(_:range:font:ink:baseInks:) -> Bool`: clamps the range to the storage; READS the runs first
  (`enumerateAttributes`, no write while enumerating); a run wears the base when its font is the base font (`===` or
  `isEqual`), its ink is one of `baseInks` (`===` or `isEqual`), and it has no strikethrough and no background; only
  the runs that differ are written, inside ONE `beginEditing`/`endEditing` (one attribute pass): the base font, the
  base ink, `.strikethroughStyle` and `.backgroundColor` removed. Nothing else — never `.paragraphStyle`, never the
  block-ID attribute, never `MarkdownFace.faceAttribute`. Returns whether it wrote.
- `App/Variorum/VariorumMobile/Features/Write/MobileEditorViewModel.swift` — in `storageDidEdit`, inside the existing
  `if let storage` and immediately BEFORE the line's `MarkdownFace.restyle`, i.e. after the routing `switch` (whose
  refusing and recovering arms `return` first) — so every ROUTED arm takes it (`.block`, `.tail`, `.openTail`,
  `.closeTail`) and no refused edit does. The range: `changedCharacters` (D-24-1's kept value), else a bound arming's
  `(range.location, replacementLength)`, else none (the reset is skipped). The values: `MobileEditorStyle.baseFont`
  and `MobileEditorStyle.face.ink` (`baseAttributes`' own); `baseInks` = `[face.ink, markdownPalette.prose]`. A write
  counts `typedFaceResets` (new, `@ObservationIgnored private(set)`, beside `desyncRecoveryCount`). The doc comment of
  `storageDidEdit` says the rule.
- `App/Variorum/VariorumMobileTests/MobileTypedTextFaceTests.swift` — reading (f) added
  (`aDashLineTypedAtTheNotesEndAndTheParagraphAfterItAreInFullInk`), the header updated. Readings (a)–(e) unchanged.
- `App/Variorum/VariorumMobileTests/MobileTypedFaceResetTests.swift` (new) — `MobileTypedFaceRuleTests` (6, the pure
  rule on a bare `NSTextStorage`, counting its own processing passes from `didProcessEditingNotification`) and
  `MobileTypedFaceGateTests` (2, her keyboard's road, hosted, Study).

#### Against §4.5 and the architect's two precisions, ruling by ruling

| Ruling | Built |
|---|---|
| D-243-1 · phone-only, in `storageDidEdit`, for every routed arm, BEFORE the line's restyle | yes — the one call sits right before `MarkdownFace.restyle`, after the arms; refusals and recoveries `return` before it |
| · the changed characters reset to the base font and ink, strikethrough and chip background removed; the restyle then derives the face | yes (`MobileTypedFace.reset`) |
| · the range is the changed characters and nothing wider: the kept value; else a bound arming's `(location, replacementLength)`; else no reset; never the widened report | yes — precision 2 exactly; the reported `editedRange` is never read by the reset |
| · equality-gated: base on base writes nothing | yes — read first, write only differing runs; pinned twice (below) |
| · never the paragraph style, never the block identity | yes — neither key is written; pinned (`aFaintRunIsResetInOnePassAndNothingElseMoves`) |
| · beside `restampProjection`, the same doctrine | the call sits in `storageDidEdit` beside the re-stamp's arms; the rule lives in its own small file so its pins run on a bare storage (design call 1) |
| Precision 1 · reading (f), the open tail, added FIRST and built without the fix (`vm24-b-red`) | yes — `03b06f417`, built before any fix line was written |
| Not in this batch · the shared face; the Mac; faint ink already on a page | none touched; text already faint is NOT healed by this fix (only characters that change are reset — a re-open clears the rest, reading (e)) |

#### The pins — every column EXPECTED, PENDING the window

| Pin | Kind | Red build `vm24-b-red` (no fix) | Fix build `vm24-b` |
|---|---|---|---|
| `MobileTypedTextFaceTests.aDashLinesWordsAreTypedInFullInk()` (a) | the reading pin | RED at `:378` (ink) only — as half 1's window | green |
| `…theParagraphAfterADashLineIsTypedInFullInk()` (b) | reading pin | RED at `:412` (ink) | green |
| `…wordsTypedAfterAClosingMarkerAreInFullInk()` (c) | reading pin | RED at `:444` (ink) | green |
| `…theLineTypedAfterAHeadingWearsTheProseFace()` (d) | reading pin | RED at `:478` (ink) and `:480` (font) | green |
| `…aDashLineTypedAtTheNotesEndAndTheParagraphAfterItAreInFullInk()` (f) — NEW | reading pin, the `.tail` arm | **RED at `:539` ("one" ink) and `:541` ("two" ink), `:543` (font) green — EXPECTED**, by reading: the tail's only text write, `finishMint`'s `replaceTailRegion`, runs only when the reconciled text differs from the tail's (`TailCrystallizer.swift:482`), and a list line's crystallization leaves it unchanged, so nothing lays the base back before the reading. **If (f) is green here, the tail's writes do lay it back: record it as green on both, never forced red** (the architect's ruling) | green |
| `…aReopenedNoteDrawsWhatWasTypedInFullInk()` (e) | control | green | green |
| every PREMISE line of the six | — | green ((f)'s include: the Return at the note's end opens the tail; "two" stands in the open tail, length 3; the store holds `["Intro.", "- one"]`) | green |
| `MobileTypedFaceRuleTests` (6): `baseOnBaseWritesNothingAndTheStorageSeesNoEdit` (zero passes) · `aListedBaseInkCountsAsTheBase` · `aFaintRunIsResetInOnePassAndNothingElseMoves` (ONE attribute-only pass; the lead outside the range keeps its ink and mark; the paragraph-style object and the block ID untouched everywhere) · `aHeadingsFontAStrikethroughAndTheChipAreCleared` · `aRunWithNoInkTakesTheBaseInk` · `anEmptyOrOutOfBoundsRangeWritesOnlyInsideTheStorage` | the rule; the gate counted as the storage's own passes | not in the red build (new API) | green |
| `MobileTypedFaceGateTests.plainProseTypedInPlainProseMakesNoFaceWrite()` | THE EQUALITY GATE on her road (mid-block and a fresh line, Study) — `typedFaceResets == 0` | not in the red build | green |
| `MobileTypedFaceGateTests.proseTypedAfterADashLineIsReset()` | the gate's non-vacuity twin — `typedFaceResets > 0`, "one" in full ink | not in the red build | green |
| The caret suite's VX-296 pins (`MobileMarkdownCaretTests`, 4, file UNEDITED) | the caret's honour at a rescue point survives the reset | — | green 4 of 4, the standing pin 3 of 3 cases (in the 52) |

**Why the gate holds in production, and the one place a harness road differs.** Half 1's printed readings show
every key typed in plain prose landing with the IDENTICAL ink and font objects the base carries ("ink" by identity,
not "≈ink"), so the gate's identity check passes on her road and the reset writes nothing. The house helper
`typeEdit` (`MobileEditorTestSupport.swift:93-106`) inserts runs carrying a font and NO ink — a road no keyboard
takes — and the reset now writes the base ink over each such run (a run with no ink is not the base: design call 3).
So suites that type through `typeEdit` (the gated `MobileHerPathsPerfTests` among them) now pay one attribute pass
per keystroke that her typed keys do not. Recorded for the gate's speed leg; not a production cost.

**Why every pin here is deterministic in any company:** the readings as half 1 says (every edit armed; the attribute
values come only from the note's own storage); the rule's pins use their own fonts and colours on a bare storage; the
gate's pins read a counter the model alone writes.

#### Design calls (options weighed; the built one first — none is a product decision)

1. **The rule in its own file** (`MobileTypedFace.swift`, pure over the values it is handed) rather than a private
   method in the 2,960-line model (P-9) — so its pins count a bare storage's own passes with nothing else writing.
2. **The prose ink counts as the base** (`baseInks = [face.ink, markdownPalette.prose]`): a cleared face run wears
   the face's own `prose` object, which draws exactly as `face.ink`; without it, every key typed after a cleared run
   (the end of a heading, a bold run) would write an ink that changes nothing. Alternative: `face.ink` alone — still
   correct, one wasted write per such key.
3. **A run with NO ink is reset** (it is not the base: the base attributes carry an ink, and an inkless run draws in
   the system's default colour, not the voice's). Alternative: treat nil as base — it would leave inkless text
   inkless, and spare only harness roads (`typeEdit`), which production's keys never take.
4. **The gate pinned two ways** — the storage's own pass count at the rule's level (zero for base on base, exactly
   one for a reset), and the model's own count of the reset's writes on her road (`typedFaceResets`, a counter for
   the pins like `desyncRecoveryCount`). Counting the hosted storage's attribute-only passes would not isolate the
   reset: the re-stamp and the restyle write there too, and whether a write made inside `didProcessEditing` makes a
   pass of its own is a platform behaviour (the macOS probe saw it join the pass), so a raw count could be hollow.
5. **The reset sits after the routing switch** (one call before the restyle) rather than inside each arm — every arm
   that reaches the restyle is a routed arm, and the refusing and recovering arms already `return`.

#### Self-assessment against §8's review foci

5. *The face reset:* writes only font, ink, strikethrough and background — never paragraph style, block identity or
   the face's mark (pinned); gated (pinned twice); ∝ the changed characters (one enumeration over them, P1); the
   caret's honour at a rescue point runs after it, unchanged (the caret suite unedited, in the window).
6. *TextKit:* no TK1 API, no layout forced; the reset is an attribute-only write inside `storageDidEdit` exactly where
   the restyle and the re-stamp already write (the same posture, not a new one); the canary checkpoint still follows.
8. *The Mac:* no `Shared/` or `Sources/` line; the Mac never had the bug (AppKit carries the mark).
9. *The pins:* (f) shown on the red build before the fix existed; (a)–(d) red there as in half 1's window; (e) and the
   gate's pins are controls; nothing is wrapped.

#### Residuals (traced, not fixed here)

- **Marked text (CJK input, the candidate bar):** if UIKit ever draws a composition's highlight through a storage
  `.backgroundColor`, the reset would remove it on a routed composition update. Not observable by these pins on the
  simulator; MobileSoul §5 item 2's device test owns it (her phone, the "after" session).
- Text ALREADY faint on a page (typed before this fix, never re-opened) is not healed until it is re-opened or edited
  — out of this batch by its own "Not in this batch" line.

#### For QUESTIONS at the merge

None new. (The marked-text residual is a device check, not a product question.)

#### The stage window (the orchestrator's; the GO's claim line and UDID fill `<simulator-udid>`; boot fresh, settle 30 s, run, shut down)

Products: `DerivedData/vm24-b-red` (the tree at `03b06f417`: the pin with (f), no fix — FROZEN) · `DerivedData/vm24-b`
(the code of `106a0d2a4`: the fix and every pin) · batch A's `DerivedData/vm24-a-mac` (no Mac-compiled file changed;
the seven types read the phone's files from disk at run time, so they read THIS tree). Poll for the Swift Testing
verdict line, never the exit.

```zsh
cd ~/dev/variorum-vm-24/App/Variorum
T=(xcodebuild test-without-building -project Variorum.xcodeproj -scheme VariorumMobile
   -destination 'platform=iOS Simulator,id=<simulator-udid>' -collect-test-diagnostics never)

# (1) the red build: the reading pin alone, (f) included
red=(MobileTypedTextFaceTests)
"${T[@]}" -derivedDataPath DerivedData/vm24-b-red -resultBundlePath DerivedData/vm24-bundles/b-red.xcresult \
  ${red/#/-only-testing:VariorumMobileTests/} > DerivedData/logs/vm24-b-red-run.log 2>&1
grep 'VM243|' DerivedData/logs/vm24-b-red-run.log > DerivedData/logs/vm24-b-red-readings.txt

# (2a) the fix build: the pin and the reset's two types ALONE
alone=(MobileTypedTextFaceTests MobileTypedFaceRuleTests MobileTypedFaceGateTests)
"${T[@]}" -derivedDataPath DerivedData/vm24-b -resultBundlePath DerivedData/vm24-bundles/b-alone.xcresult \
  ${alone/#/-only-testing:VariorumMobileTests/} > DerivedData/logs/vm24-b-alone.log 2>&1
grep 'VM243|' DerivedData/logs/vm24-b-alone.log > DerivedData/logs/vm24-b-readings.txt

# (2b) the fix build, ONE invocation: the three VM-243 types, then batch A's 52 (the three VM-24 types + VM-64's 49)
tests=(MobileTypedTextFaceTests MobileTypedFaceRuleTests MobileTypedFaceGateTests
  MobileUnarmedEditRoutingTests MobileChangedCharactersCaptureTests MobileChangedCharactersObserverTests
  MobileStructuralFlightFenceTests MobileStructuralTests MobileSelectionActsTests
  MobileEditorMaterializationTests MobileCanaryTests MobileEditorRoutingTests MobileEditorCrystallizationTests
  MobileEditorProjectionTests MobileTypewriterRoomTests MobileNoteSealTests MobileFindInNoteTests
  MobileEditRoutingBindingTests MobileIdentityAuditSeparatorTests MobileBulkArmingTests MobileCanaryTeardownTests
  MobileEditRoutingCrashTests MobileEditRouteArmsTests MobileWholeBlockDeleteBrainTests MobileWholeBlockDeleteTests
  MobileCrossBlockEditBrainTests MobileCrossBlockEditTests MobileMarkdownRenderTests MobileMarkdownReturnTests
  MobileMarkdownActsTests MobileCheckboxTapTests MobileMarkdownCaretTests MobileTakesTests MobileTakesBrowserTests
  MobileTakesBrowserSurfaceTests MobileTakesChromeTests MobileTakeReorderTests MobileTakeToBlockTests
  MobileTakeLockTests MobileUndoDoorTests MobileBlockMenuTests MobileCommentsTests MobileBlockDecorTests
  MobileWalkTests MobileTrailingNewlinesTests MobileSpaceEaterTests MobileCRLFCaptureTests
  MobileWriteScrollAuthorityTests MobileScrollAuthorityBrainTests MobileLivenessTests
  MobileDeferredProjectionRetryTests MobileTypedOverRescueTests MobileEditTraceTests MobileKeyDoorPostureTests
  MobileSavepointOnLeavingTests)
"${T[@]}" -derivedDataPath DerivedData/vm24-b -resultBundlePath DerivedData/vm24-bundles/b-company.xcresult \
  ${tests/#/-only-testing:VariorumMobileTests/} > DerivedData/logs/vm24-b-company.log 2>&1

# (3) the Mac's seven types that read every phone file (no simulator), from batch A's products
mac=(DeadVocabularyTests DataSafetySearchIndexTests PaneLineMetricsScopeTests OneRefreshAuthorityCompositionTests
  OneInputPathTests PaletteDerivationTests GlyphRainTests)
xcodebuild test-without-building -project Variorum.xcodeproj -scheme Variorum -destination 'platform=macOS' \
  -derivedDataPath DerivedData/vm24-a-mac -collect-test-diagnostics never \
  -resultBundlePath DerivedData/vm24-bundles/b-mac.xcresult \
  ${mac/#/-only-testing:VariorumTests/} > DerivedData/logs/vm24-b-mac-run.log 2>&1
```

Expected (Swift Testing counts test functions; read the `skipped` lines):
- **(1)** "Test run with 6 tests in 1 suite failed … with 7 issues": (a) `:378` · (b) `:412` · (c) `:444` · (d) `:478`,
  `:480` · (f) `:539`, `:541`; (e) green; every PREMISE green. If (f) is green: "… 5 issues", recorded as green on
  both (the ruling), not a finding against the fix. Any other red — a premise, a font line in (a)–(c) or (f) — is the
  architect's.
- **(2a)** "Test run with 14 tests in 3 suites passed"; the `VM243|` readings show every typed word `ink=ink` in the
  base font, the leads and stars still `marker … faced`, "Head" in the heading font.
- **(2b)** "Test run with 385 tests in 55 suites passed" (batch A's 371 in 52, plus 14 in 3), one host process,
  `Restarting after unexpected exit` = 0; the caret suite 4 of 4 with the standing pin 3 of 3 cases; the fence suite
  10 of 10. Any red is named and is a finding.
- **(3)** "Test run with 46 tests in 7 suites passed" (as batch A's).

#### Batch B, half 2 — the orchestrator's stage results (the window; every PENDING in the half's closeout is settled here)

**Claim `vm-24`, 2026-11-20 05:27:39 → released 05:31:02, nov18's GO.** The tree at `a43b5fe70` (the red build
`vm24-b-red` at `03b06f417` — the pin with reading (f) and no production change against batch A; the fix `vm24-b` at
the code of `106a0d2a4`; the Mac leg from batch A's `vm24-a-mac`, no Mac-compiled file having changed). The standing
simulator, one fresh boot, a 30 s settle (05:28:15), one launch per leg, `Restarting after unexpected exit` = 0 in
every log, every `xcodebuild` exited by itself. Logs `DerivedData/logs/vm24-b-red-run.log`, `-alone.log`,
`-company.log`, `-mac-run.log`; the summary `vm24-b-window-summary.txt`; the printed readings
`vm24-b-red-readings.txt` and `vm24-b-alone-readings.txt`.

| Leg | Verdict line | By name |
|---|---|---|
| (1) the red build: the pin alone | "Test run with 6 tests in 1 suite failed after 1.868 seconds with 7 issues." | RED: (a) `aDashLinesWordsAreTypedInFullInk()` `:378` · (b) `theParagraphAfterADashLineIsTypedInFullInk()` `:412` · (c) `wordsTypedAfterAClosingMarkerAreInFullInk()` `:444` · (d) `theLineTypedAfterAHeadingWearsTheProseFace()` `:478` (ink) and `:480` (font) · (f) `aDashLineTypedAtTheNotesEndAndTheParagraphAfterItAreInFullInk()` `:539` ("one") and `:541` ("two"). GREEN: (e) `aReopenedNoteDrawsWhatWasTypedInFullInk()`; every PREMISE line. Exactly as tabled — the open tail has the bug too |
| (2a) the fix build: the pin and the reset's two types alone | "Test run with 14 tests in 3 suites passed after 1.753 seconds." | none red |
| (2b) the fix build: those three, then batch A's 52, ONE invocation | "Test run with 385 tests in 55 suites passed after 59.030 seconds." — 55 passed-suite lines, 0 failed, 0 skipped | none red. The standing caret pin "with 3 test cases passed"; the caret suite and the fence suite passed |
| (3) the Mac's seven source-reading types | "Test run with 46 tests in 7 suites passed after 13.449 seconds." | none red |

What the pin printed on the fix (Study, light): the lead `"- "` still in the marker's ink with the face's mark;
`"one"`, `"one⏎two"` (in a block and in the open tail), `" b"` after a closing star and `"⏎word"` after a heading all
in the full ink `#29241C` and the base font; the heading's own words bold 27 pt and an italic's letter italic, both
marked. After the window: the simulator shut down (0 booted); its app container lists `Variorum-dev` only; no
instance; no Problem Reporter; no new crash report; the Debug defaults 1,356 keys, unchanged.

**Both batches' code is now built and proved in windows. The commit the walk's AFTER pass and the ladder read is
`a43b5fe70`'s code** (no App or Sources line after `106a0d2a4`).

#### THE GATE — the orchestrator's stage results

**Claim `vm-24`, 2026-11-20 06:52:08 → released 07:09:50, nov18's GO.** The tree that merges: `cdc1e3b7b` and the
notes commits after it (main `508a2bae0` merged in at `190165014`; nothing under App or Sources after `8f5323554`).
Products: `DerivedData/vm24-gate` (the phone, built from `8f5323554`), `DerivedData/vm24-a-mac` (the Mac; no
Mac-compiled file changed in the run). The standing simulator, one fresh boot, a 30 s settle (06:52:45), legs (1)
and (2) on that boot, then shut down; `Restarting after unexpected exit` = 0 in every log; every `xcodebuild`
exited by itself. Logs `DerivedData/logs/vm24-gate-phone.log`, `-perf.log`, `-mac.log`, the summary
`vm24-gate-summary.txt`.

| Leg | Verdict line | Notes |
|---|---|---|
| (1) the whole phone target, one launch (`-only-testing:VariorumMobileTests`) | "Test run with 1226 tests in 215 suites passed after 761.034 seconds with 6 known issues." | **ZERO red — main's one standing red is gone.** Main's count was 1,194 in 209 with that one red; this tree adds the run's 32 tests and 6 suites. The standing pin: `aReplaceThroughTheInputRoadAtARescuePointKeepsTheSurfaceInStep(_:)` "with 3 test cases passed". Skipped: 13, every one `MobileHerPathsPerfTests`' ("reads the process's one timing recorder"). Known issues, declared, in suites this run does not touch: 4 in "Mobile filter row — width, measured on the real surface", 2 in "Mobile Trash — PR2's recovery surface". Named as run and passed: the fence suite (VM-2), VM-78's guards (the membership sheet's G3 suite, VM-81's three, VM-83's three, VM-21's), VM-64's "VM-68 — the Library's paging and hold rules", VM-47's keyboard and edge pins ("a hidden page never holds the keyboard", "The grounds reach the screen's edges", "Which page colours the strips beyond the band") |
| (2) `MobileHerPathsPerfTests` alone, `TEST_RUNNER_VM66_PERF=1` | "Test run with 13 tests in 1 suite passed after 128.795 seconds." | no skip, no known issue |
| (3) the Mac's 22 types that read the phone's source | "Test run with 129 tests in 22 suites passed after 30.645 seconds with 4 known issues." | the 4 known issues are `IndexTierMetricsTests`' declared ones (TEXTKIT2 §3's short trailing blank line). The types: CrystallizationPlannerTests · CrystallizationReconcilerTests · DataSafetySearchIndexSettingsSearchTests · DataSafetySearchIndexTests · DeadVocabularyTests · ArmedEditTests · MacEditRoutingTests · IndexTierMetricsTests · PaneLineMetricsScopeTests · OneInputPathTests · OneRefreshAuthorityCompositionTests · OneRefreshAuthorityRaceTests · OpsRefusalTableIntegrityTests · PaletteDerivationTests · LobbyWordsDoorPressTargetTests · NotOnYetWordsTests · ProtectionWordsVX307Tests · WordsFieldsConcealTests · SpaceEaterTests · TravellingDotsIndicatorTests · TrayFilterTests · GlyphRainTests |

Headless before the gate, on the final words: the Core suites that name phone files — `MCPProviderNeutralityTests`
"2 tests in 1 suite passed"; `Phase13icOutflowTests` and `OutflowRetirementTests` "13 tests in 2 suites passed".
No whole Mac target was owed or run: the run changes no line under `Shared/`, `Sources/` or the Mac app (nov18's
reading too). After the gate: the simulator shut down (0 booted); its app container lists `Variorum-dev` only; no
instance; no Problem Reporter; no new crash report; the Debug defaults 1,356 keys, unchanged.

---

*The kickoff as VM-78 wrote it on 2026-11-19, kept whole. Its STATUS line and "This file is … NOT a design" are
superseded by the banner above.*

## Kickoff message

> You are starting **VM-24** as its own run, under the architect shape, on `main` as it stands after wave 1 of
> the mobile catch-up has merged.
>
> **Her decision that made this run (2026-11-19).** Asked where VM-24's fix should be built, she chose — a dialog
> pick — "Own run after wave 1 (Recommended)": VM-24 becomes its own short run on merged main as soon as all
> four mobile runs have merged, before wave 2; **it starts with one session on her phone counting how often
> unwarned edits and snap-backs occur, so the fix has before-and-after numbers.** Her words to the stage
> coordinator the same morning, verbatim: "I chose the own run after wave 1 option that vm-78 proposed. i want
> you to message them about this to lock the plan down, but basically i want you to open a new session in tmux
> once wave 1 is done and merged, and tell it to architect-phase that issue, reporting to you for stage details.
> just kick that off when wave1 is done for me."
>
> **The mechanism, traced by VM-78 in a stage window on 2026-11-19 (three lines):**
> 1. An edit can reach the phone editor's `storageDidEdit` UNARMED — without the edit gate having been consulted
>    for it, or with its arming already spent: autocorrect, predictive replacement, dictation and marked-text
>    commits by the code's own account, and sometimes an ordinary typed character that lands behind a keyboard
>    transaction of its own (a device capture shows exactly that).
> 2. An unarmed edit is routed by `fallbackVerdict` from the storage's own report of what changed.
> 3. When TextKit's attribute fixing widens that report inside `processEditing` so that it reaches past the
>    block's terminator, `fallbackVerdict` refuses what was a plain in-block edit, and `desyncRecovery` re-renders
>    the surface from the store: the character or word just entered snaps back, with a flicker. Stored text is
>    never at risk (the refused route returns before the autosave).
>
> **Where it lives:** `App/Variorum/VariorumMobile/Features/Write/MobileEditorViewModel.swift` (`storageDidEdit`,
> `fallbackVerdict`, `desyncRecovery`, the gate and its arming), `App/Variorum/Shared/EditorBrain/EditorEditRouting.swift`
> (`ArmedEdit.describes`, shared with the Mac), `App/Variorum/VariorumMobile/Features/Write/MobileEditorTextView.swift`
> (the input roads). This is the editor seam: a Fable cold review reads every round, and `notes/TEXTKIT2_NOTES.md`
> is read before any line is touched.
>
> **The pin, standing red on main:**
> `MobileMarkdownCaretTests.aReplaceThroughTheInputRoadAtARescuePointKeepsTheSurfaceInStep`
> (`App/Variorum/VariorumMobileTests/MobileMarkdownCaretTests.swift`) — red for two of its three cases, the
> replacements "hi" and "hello there", at the expectation `model.desyncRecoveryCount == 0`; the third case,
> "Hello", is green. It is red alone, red in company, and has been since 2026-10-25 with no product change. It is
> NOT wrapped as a known issue and must not be: it goes green by the fix, and only by the fix. (A test-side wait
> that makes it green by avoiding the condition was considered and refused.)
>
> **Read first, in this order:**
> 1. `CLAUDE.md` and its loaded canon; `notes/TEXTKIT2_NOTES.md` in full; `notes/MobileSoul.md` §1–5.
> 2. `notes/plans/fixes/vm-78-fixes-to-whats-there.md` — its **FOR A LATER READER** section, then, WHOLE (this
>    run is reopening that finding): BATCH C's "WINDOW (3) — RESULTS" and "VM-24 — the mechanism, its reach, and
>    the options" (the reach table, what Apple's documentation does and does not say, the three fix options and
>    what only a device can tell), and "The orchestrator's live state" → the decisions on window (3).
>    `notes/plans/fixes/vm-78-ladder-round3.md`, finding R3-F5 and its final call (the reach correction: a typed
>    character can land unarmed; arming the visible roads cannot cover an arming spent before its edit lands,
>    while routing from the pre-fixing range does not depend on the arming).
> 3. **`notes/plans/fixes/vm-64-timing-and-lags.md` (and `vm-64-midpoint-review.md`) — BEFORE designing
>    anything.** VM-64 merged a flight fence into the same file: it changes how an unwarned edit is handled while
>    a divide, merge or extract is landing (`Domain/StructuralFlightFence.swift`, `MobileStructural.swift`,
>    `MobileEditorViewModel.swift`), and its record says its batch 2 traced the SAME widened-report mechanism for a
>    bare `insertText` (four state-dependent pins in its first fence cycle). Its later batches (the open/close
>    road, the leaving savepoint) also changed `MobileEditorViewModel.swift`.
> 4. `notes/plans/mobile-round-2-crash-trace.md` (the device capture, E1 #50–#52) and VX-68 (the gate-less
>    insertion watch row — it looks like this same mechanism; decide whether this run closes it).
>
> **What this run must NOT assume:**
> - That the code is as VM-78's trace saw it. By the time this run starts, VM-64's fence and its batches 6 and 7,
>   VM-55's message seam (`report(line:)`) and VM-78's date-chip mirror have all merged into
>   `MobileEditorViewModel.swift`. Re-read the routing on `main` and RE-RUN the pin alone before believing any
>   line number in the trace.
> - That the fence and this fix are independent. Both decide what happens to an unwarned edit; the fix is
>   designed against the fence as it landed, and the fence's pins are part of this run's gate.
> - That the simulator can answer the reach question. It cannot produce real autocorrect, predictions or
>   dictation; which system roads arrive unarmed, and how often their reports are widened, is a DEVICE fact.
> - That the trace instruments are in the tree. They were removed before VM-78's gate; commits `a570d3960` and
>   `fec0e478b` on VM-78's branch history carry them (`MobileCaretReplaceTraceTests.swift`, three suite types) and
>   can be restored for this run's own windows — run alone by type, never in a whole-target run.
>
> **The first acceptance unit is the measurement, and it needs her:** one session on her phone, the E1 edit
> trace armed, typing with autocorrect on, accepting predictions, dictating, using the spelling menu and
> pasting — counting gate-less edits and desync recoveries per road. That number is the "before"; the same
> session after the fix is the "after". Installing a build on her phone is her hands (the install runbook:
> `notes/plans/vm-44/plans/vm-45-install-runbook.md`); ask, do not work around it.
>
> **The fix options VM-78's write-up left for the architect (none is chosen):** route an unarmed report from the
> pre-fixing range (`willProcessEditing`), which does not depend on the arming; a fallback that accepts a
> widened report when the character change lies inside one block; arming the programmatic roads (which cannot
> cover a spent arming). The Mac shares `Shared/EditorBrain`; say for each option what the Mac inherits.
>
> **Stage:** report to the stage coordinator of your window for every `xcodebuild test`, simulator boot and
> device install (REQUEST, READY, GO, RELEASE).

## Pointers

- Ticket: VM-24 (re-owned out of VM-78's umbrella on 2026-11-19; Todo; Bug · Confirmed · Editor · High). Its
  comment of 2026-11-19 carries the mechanism and her decision.
- VM-19 (carried by VM-24 until then) is done in VM-78: its teardown pin is proved; the desync it described did
  not reproduce on this toolchain.
- Evidence kept only on the Pro (local, gitignored) until VM-78's worktree is removed: the trace window's logs
  and result bundles. What matters from them is written into the VM-78 record.
