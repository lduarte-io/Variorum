# VM-24 — An unwarned edit whose report TextKit widens snaps back on the phone (VM-243 riding)

**STATUS: OPEN 2026-11-20 — /architect-phase on the Pro, an away run (she is asleep until morning); orchestrator
session `vm-24`; stage coordinator `nov18`.** Ticket VM-24 (team VM, project "Mobile — the catch-up & launch") ·
rider VM-243, at her word · Branch `vm-24-unwarned-edit-routing` · Worktree `~/dev/variorum-vm-24` · PR: PENDING.

This file is the run's ONE record: her words, the binding principles, the design as ruled, the batches and their
briefs, the ledger, what is held for her, and each batch's live status and closeout. The kickoff VM-78 wrote is kept
whole at its end.

## FOR A LATER READER

*Written last, at the closeout. Until then "The orchestrator's live state" below is the current truth.*

## The orchestrator's live state (kept current; a resuming session reads this first)

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
| L1 | Unit 0, the "before" session on her phone | her hands; the script `notes/handoffs/vm-24-morning-phone-session.md` | HELD (§10) |
| L2 | Is the wave-1 build's trace enough for the "before"? | orchestrator | DONE — yes (§4.6) |
| L3 | The standing pin re-run alone on main's code | orchestrator | DONE — red, main's shape (the live state) |
| L4 | The design: VM-24's options against the fence; VM-243's trace | architect | DONE (§4) |
| L5 | Batch A — VM-24's fix and pins | implementer | NOT STARTED |
| L6 | Batch A's red/green window, the Mac's seven source-reading types | orchestrator, nov18's GO | NOT STARTED |
| L7 | Batch B — VM-243: the pin as the confirm, then the fix | implementer | NOT STARTED |
| L8 | Batch B's window | orchestrator, nov18's GO | NOT STARTED |
| L9 | The simulator walk (typing mid-note, paste, the readout's new lines; a dash line and the paragraph after it) | orchestrator | NOT STARTED |
| L10 | The ladder (`fable-reviewer`, fresh per round, up to five) | orchestrator | NOT STARTED |
| L11 | The gate: the whole phone target, the gated speed suite alone; a Mac leg only if a shared file changed | orchestrator, nov18 | NOT STARTED |
| L12 | Canon: TEXTKIT2_NOTES §3 (what was measured about the first callback and the fix's rule); SurfaceContracts only if a contract line moved; MobileSoul PL-81 | orchestrator at closeout | NOT STARTED |
| L13 | VX-68 closed with a comment naming the pin (D-24-5) | orchestrator at the merge | NOT STARTED |
| L14 | The Mac twin's ticket (D-24-3) | orchestrator at closeout | NOT STARTED |
| L15 | The device build of the fixed tree for her "after" session, and its block in the handoff | orchestrator after the merge | NOT STARTED |
| L16 | Unit 0's "after" session | her hands | HELD (§10) |
| L17 | Closeout: this record's FOR A LATER READER, the shared ledgers at the merge (QUESTIONS #282, AppSpecRecord, the finals line, the master plan), `Tools/canon-size`, the tickets, the handoff `notes/handoffs/vm-24-handoff.md`, the cleanup | orchestrator | NOT STARTED |

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

## 12. Batch closeouts, findings and dispositions

*(Each implementer's closeout; the orchestrator's stage results; the ladder's dispositions.)*

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
