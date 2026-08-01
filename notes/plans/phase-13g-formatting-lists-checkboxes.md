# Phase 13g — Formatting, lists & checkboxes

**Status: PASTE-READY (authored at the 13f closeout, 2026-07-31, per
the front-loaded-planning rule). The author kicks it off at her
word.** Sequencing is HER round-5 ruling at 13f: 13f → **13g** → 13e,
then her choice. **13g's closeout AUTHORS 13e's plan** (her explicit
instruction: "leave a note for 13g to author 13e" — this is that
note; do not close 13g without it).

## Kickoff message (paste-ready for the orchestrator/coordinator the author invokes)

> You are running Variorum Phase 13g under the shape the author
> picks at kickoff (`/architect-phase` fits — the storage-format
> fork is design-heavy and wants sittings). Read IN FULL first:
> `CLAUDE.md` + the canon it loads (AppSpec §14's 13f delta is the
> latest state), this plan, `notes/handoffs/phase-13f-handoff.md`,
*[removed for publication]*
> inclination), `notes/TEXTKIT2_NOTES.md` (§1's
> `includesTextListMarkers` note and §3's broken-`NSTextList`
> warning are this phase's terrain), and the 13c plan's
> "Environment traps" (binding, as every phase). Verify the
> baselines with your own runs. Copy the P-1…P-9 constitution into
> this file verbatim if running under `/architect-phase`. **OPEN
> WITH THE AUTHOR-ATTENDED SITTING, in this order:** (1) **her 13f
> WALKTHROUGH** — walk `notes/handoffs/phase-13f-handoff.md`'s
> checklist with her item by item, recording her verdicts as
> sitting rounds (her round-15 directive at 13f moved the
> walkthrough here so that phase could close; her reports are
> findings — verbatim, routed, answered point-by-point); (2) the
> **MARKDOWN FORK** (below) — hers to rule; (3) the kickoff-sweep
> item (the shell-redo flaky pin's trace — the KnownIssues row this
> phase now owns); (4) cast confirmation.

## Goal

Text can look like text (her A33/A34, verbatim in the 13c intake
ledger): bold, italics, sizes, some markdown — **and the
list/checkbox maker she added live** ("a simple list maker and
checkbox maker (like hyphens, [], bullets)").

## The opening design fork (hers to rule; nothing pre-decided)

**Markdown-as-content** (zero schema; the stored text IS markdown;
export free; sidesteps the broken `NSTextList`; rendering is a
presentation transform) **vs. real attributed runs** (schema for
runs — a SyncSpec §12 lockstep event — plus editor-core work in
TK2's least reliable neighborhoods). This is an architectural fork
and hers.

**Her recorded inclination (2026-07-30, ahead of the sitting —
*[removed for publication]*
pre-decision):** markdown **DUAL-MODE** — one storage format
(markdown-as-content), two input faces (raw syntax, or
native-looking tools/buttons that insert it), export emitting proper
markdown either way. **Her 13f-kickoff words for this sitting's
agenda** (recorded at that plan's kickoff sitting, item 9): *"I'm
interested in trying to consider if we should have a 'markdown
mode' where you can write actual markdown and have it format as a
particular setting to have on, with the default just being like
normal rich text editor for bolding, italics, etc., but that can
still export correctly as markdown… worth considering and talking
about the tradeoffs for."* The sitting rules; the phase builds to
the ruling.

## Binding constraints (whichever fork she rules)

- `renderedText` / export / the Fragments bridge's join brain:
  semantics PINNED UNCHANGED (the one-join-brain rule; the bridge
  pushes what export emits). Any storage-format decision must state
  its export story before building.
- The seal, variant locks, and I4 (newlines are content) bind as
  everywhere; formatting must never become structure by accident.
- TEXTKIT2 §3/§1: `NSTextList` is broken since macOS 14 and the
  Tahoe `includesTextListMarkers` delta makes lists a known-rough
  area — treat any native-list temptation as the trap the notes
  say it is; §5 re-verifies after the phase's editor work.
- A schema-touching ruling is a SyncSpec §12 lockstep event —
  mirror-first, her explicit go (the R53 precedent).
- The P-1…P-9 constitution binds; the registry grows to cover new
  doors (formatting acts are acts: declared, walked, honest).
- No `Sources/VariorumCore/Sync/` lines without the standing rider.

## Carried into this phase

- **The 13f walkthrough** (the opening sitting's first act — the
  handoff doc's checklist; her verdicts become this plan's first
  sitting rounds; anything she overturns is this phase's early
  batch material).
- **The kickoff-sweep item:** the shell-redo flaky pin
  (`theShellRedoActionRunsThroughTheRunnerAndReports`) — the
  KnownIssues row now names 13g; trace the status-delivery timing
  when in that code (the hallucination guard binds: trace, never an
  untraced patch).
- **W17 (her infinite-scroll jot)** — exploratory, uncommitted;
  offer it at the sitting only if she raises it (the narrow
  jump-and-return reading is cheap atop 13f's carry/history
  machinery; the broad reading is a design conversation).
- **13i's brief** (`notes/plans/phase-13i-smart-book-identity-brief.md`)
  and **13h's design note** exist; neither is this phase's scope.

## Baselines at open (verify with your own runs)

Core **926/105** · Mac **1068/188** · mobile **14/4** — the 13f
finals, verified by that orchestrator's own runs 2026-07-31. No
schema since v1_12; mirror at lockstep marker 4. The tutorial spine
(49/7 by TYPE name) green.

## Verification

Per-batch: the standing loop (build → red-on-old pins by behavioral
revert with checksums and `build-for-testing` first → the tutorial
spine green by TYPE name → full suites, counts by the "Test run
with N tests" line; mobile when `Sources/`/`Shared/` is touched).
Review shape: the author sets it at kickoff. Every PROVISIONAL to
`notes/QUESTIONS.md` (append, never renumber — next free number at
authoring time: **#49**). **The closeout authors 13e's plan** (her
round-5 ruling — the takes & block management row, plus the
13e-owned KnownIssues rows: the takes-aware find&replace half, the
11a copy-doors flush alignment, and the 13e kickoff candidates
recorded at 13f round 11: the tag-surface ask + the in-post tags
face).

---

## THE OPENING SITTING — 2026-08-01 (author-attended; the 13f walkthrough is act 1)

**Baseline verification (kickoff duty):** core verified by this
orchestrator's own run at the sitting's open — `swift test` → "Test
run with 926 tests in 105 suites passed" (matches the 13f finals).
Mac and mobile runs deliberately deferred to just before batch 1:
Mac test windows flash beside a live session (13c environment
traps), and she is walking the installed app right now. Cast
unconfirmed as of round 1 (sitting item 4); the P-1…P-9
constitution copies in verbatim when she rules the shape.

### Round 1 — her first walkthrough pass (arrived with the kickoff message; verbatim)

> I'm kind of confused on how I'm supposed to open windows side by
> side - i didn't see it in the tutorial or in the shortcuts. things
> overall look pretty good. as a minor note, i think that the
> navigation back and book icon should default to being collapsed,
> not expanded, and you click to expand them. I like that just
> clicking on the book brings you back to the book where it's from
> if there's just one. in the futrue maybe we add some clicking like
> a command click on books for a mini menu of the books it's in, but
> i think just expanding it or not is good for now. so yeah, not
> really sure how to access what shipped but overall i like it. i
> also think the back bar should be flush with the top to match the
> bar at the bottom, which sits underneath the floating left pane.
> and i don't even konw if we need that empty whitespace that says
> Variorum at the top - let's try getting rid of it. how do i access
> the quick floating pad too? idk how to get to any of the things
> that built last phase

**Dispositions, point by point:**

- **WT-1 (FINDING — the round's load-bearing one): the 13f surface
  is invisible to BOTH discoverability surfaces.** Her report is
  literally accurate, traced at the sitting: the Shortcuts &
  Dictionary helper (⌘/) is a HAND-MAINTAINED static list
  (`HelperView.swift` — `groups` + `entries`), last extended at the
  QoL round's find family, and carries ZERO 13f entries — no
  ⌘⇧1–9, no ⌘[/⌘], no ⌘⇧I, no ⌘⇧N, no Open Beside / New Window /
  stars rows, and no dictionary words for any of it; and the field
  guide's lesson plan (`TutorialSeeder.plan`) has NO workspace
  chapter — the 13f re-seed taught the "note" vocabulary but no
  lesson teaches windows, the split, the Open strip, history,
  stars, or the quick note. The registry declared every act (P-1
  held); the discoverability surfaces were never extended — the
  legibility mandate (R73/R91/R93) did not ride the phase. ROUTED:
  13g's opening walkthrough batch — a helper "workspace" group +
  dictionary entries + a field-guide workspace lesson (⇒ one more
  Restore-Tutorial re-seed for her afterwards), PLUS a drift-guard
  proposal: the helper's hand list beside the registry's
  `shortcutLabel`s is a drift class — a walk test asserting every
  registry `shortcutLabel` appears in the helper, so no future
  phase can ship an invisible shortcut again.
- **Her access questions ANSWERED at the sitting** (from the
  shipped declarations, `CapabilityRegistry.swift`): the split =
  right-click a note row → "Open Beside", or View ▸ Open Beside
  (needs a second open note; the row door puts THAT note beside,
  the menu door the most recently opened other; no keyboard
  shortcut was declared — offered to her as a question). Windows =
  File ▸ New Window (full app window) / right-click a note row →
  "Open in New Window" (note-only). The quick pad = ⌘⇧N, File
  menu, the menu-bar extra glyph in the system menu bar
  (summonable from any app), and ⌘K.
- **"things overall look pretty good … overall i like it"** —
  verdict recorded.
- **WT-2 (RULING): the context bar defaults COLLAPSED** — "the
  navigation back and book icon should default to being collapsed,
  not expanded, and you click to expand them." The two halves
  share ONE collapse state by design, so this is the one default:
  today `WorkspaceModel.contextBarCollapsed = false`; flip it —
  collapsed at birth, click (or ⌘⇧I) expands. ROUTED: the
  walkthrough batch.
- **Verdict (keep): the one-book click-through** — "I like that
  just clicking on the book brings you back to the book where it's
  from if there's just one."
- **FUTURE, recorded not built: ⌘-click the book fold for a mini
  menu of its books** — her words: "in the futrue maybe … but i
  think just expanding it or not is good for now." Candidate for
  13e's kickoff list (the chip's next hands).
- **WT-3 (RULING): the back bar sits FLUSH with the top** — "to
  match the bar at the bottom, which sits underneath the floating
  left pane." Geometry at the ContextBar's `PaneHost` mount; the
  bottom status bar's flush placement is the model. ROUTED: the
  walkthrough batch.
- **WT-4 (RULING, try-it): remove the "Variorum" chrome label at
  the sidebar's top** — "i don't even konw if we need that empty
  whitespace … let's try getting rid of it."
  `SidebarView.swift:289` (`tokens.chromeLabel("Variorum")`).
  Shipped as a TRY — she sees it without and keeps or reverts at a
  later round; if the space proves load-bearing (window-drag area /
  traffic-light clearance), the batch proposes the smallest honest
  alternative instead of silently keeping it. ROUTED: the
  walkthrough batch.

**Still open on the walkthrough** (handoff checklist items she has
not yet been able to reach — continue next round now that the
doors are in her hands): item 0's ONE CLICK (Help ▸ Restore
Tutorial — still pending), item 1's feel checks (become-key
between windows, two-windows-on-one-note, the per-window status
toast TASTE FLAG), item 3's diverge try + the one-time first-edit
note, item 4's menu-bar-glyph-from-another-app + the W26 standing
offer, item 5's naming reads, item 6's smaller looks. Then sitting
acts 2–4: the markdown fork, the flaky-pin sweep note, cast
confirmation.

### Round 2 — 2026-08-01 (the split walked; cast RULED; the walkthrough substantially closed)

Her message, verbatim:

> ok I see how to open it on the side now. it looks pretty good, one
> of my only comments is that it's a bit confusing to see it return
> to read ? or write ? mode when you click away from it, if you were
> just in takes. idk if there should be a "by tab" way of choosing
> the mode, I'm open to suggestions there. also, clicking into the
> read body of the pane on the right makes that the editable pane
> (which I like) but on the left pane you have to click the narrow
> bar that says "click on this pane to edit". i also do want to
> figure out how to do the global hot key for the quicknote but that
> can come a little bit later i suppose. the status toast in every
> window is fine i think. the menu bar glyph is working well, seems
> good. i think the note wording is fine for now, i'll try diverge
> from a book chip later. and cast - yeah, fable orchestrator, opus
> implementer, fable cold review at the end (with the standard
> ladder). I'm ready for the markdown fork design conversation so I
> can get this kicked off and go to bed - I think the walkthrough
> seems pretty solid thus far and I'm happy with how it's looking

**Dispositions, point by point:**

- **The split: found and liked** ("it looks pretty good").
- **WT-5 (FINDING + design question — she is open to suggestions):
  click-away mode flip.** Verbatim above: a pane she left in Takes
  visibly "returns to read? or write? mode" when the other pane
  takes liveness, and she floats a "by tab" way of choosing the
  mode. ORCHESTRATOR'S PROPOSAL (offered at this sitting, built on
  her nod): a pane's MODE is pane-local and STICKY — clicking away
  never changes what a pane SHOWS; the un-live pane keeps its mode
  row and renders a read-only projection of that same mode (a
  dimmed takes board if she was in Takes), with liveness governing
  only the ring and who types. P3-clean (a read-only projection
  costs ∝ visible cards); the mount rule untouched (still exactly
  one live surface). ROUTED: the walkthrough batch, gated on her
  answer this sitting.
- **WT-6 (FINDING → RULING): body-click focus parity across
  panes.** Verbatim above — the right pane's read body takes
  liveness on click ("which I like"); the left pane only via the
  narrow "click on this pane to edit" bar. The ruling is implicit
  in her parenthetical: clicking the read BODY of EITHER pane
  makes it the live pane; the left pane's bar-only door is the
  defect. TRACE the asymmetry first (why the left body click
  doesn't become-key — the hallucination guard binds). ROUTED: the
  walkthrough batch.
- **W26 UPGRADED: wanted, scheduled later** — "i also do want to
  figure out how to do the global hot key for the quicknote but
  that can come a little bit later i suppose." Held as an
  author-attended item later in 13g (the researched one question:
  whether macOS prompts); never run without her at the machine.
- **Taste flag RESOLVED: the app-global status toast STAYS** —
  "the status toast in every window is fine i think."
- **Menu-bar glyph: verdict good** ("working well, seems good").
- **The naming sweep: verdict fine** ("i think the note wording is
  fine for now").
- **Carried, hers:** the diverge-from-a-book-chip try; item 0's
  Restore Tutorial click (still pending).
- **CAST RULED (sitting item 4), her words:** "fable orchestrator,
  opus implementer, fable cold review at the end (with the
  standard ladder)" — the 13d/13f shape: Fable orchestrator ·
  a FRESH Opus implementer per batch · ONE Fable cold review at
  phase end running the standard ladder. `/architect-phase`
  invoked; the constitution below copies in with the ruling.
- **Walkthrough verdict:** "the walkthrough seems pretty solid
  thus far and I'm happy with how it's looking" — the walkthrough
  is substantially CLOSED as a sitting act; the remaining items
  (Restore Tutorial, diverge try, W26) ride her checklist and any
  later report enters as a new round.

## The binding principles (the P-1…P-9 constitution — copied verbatim per the architect-phase shape; provenance `notes/plans/phase-13b-make-it-work.md`)

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

*(The skill's application precisions — P-1's routed-vocabulary scope,
P-3's two deliberate surface kinds, layer placement, the overlay/sink
delivery law — bind as application notes exactly as written there.)*

### Round 3 — 2026-08-01: THE MARKDOWN FORK RULED (question-tool batch; answers verbatim-faithful)

The tradeoffs were walked at the sitting (fork B's cost stated
plainly: attributed runs break the one-mutable-field bet the sync
design rides on — a lockstep event, a conflict class outside S5,
parallel runs stories for commits/exports, and still no native list
story; fork A satisfies the pinned export/bridge constraint by
construction). Her rulings:

- **F-1 (RULED): storage = MARKDOWN-AS-CONTENT.** The stored text IS
  the markdown. Zero schema; sync/bridge/export/search carry it as
  ordinary content (the one-join-brain rule untouched); lists and
  checkboxes are text lines — `NSTextList` is never invoked.
- **F-2 (RULED): the v1 editing face = STYLED WITH DIMMED MARKERS**
  (the iA Writer model): `**bold**` renders bold with faint markers.
  Display text == stored text BYTE-FOR-BYTE on every editing
  surface — the identity machinery (AppSpec §15 risk 1) untouched.
  ⌘B/toolbar insert syntax (dual-mode's second input face). FULL
  HIDING is recorded as a possible LATER RATCHET, deliberately not
  v1 (display ≠ stored means an offset-translation layer through
  the app's riskiest machinery).
- **F-3 (RULED): the v1 vocabulary** = the committed set — bold,
  italic, headings-as-sizes (#/##/###; finally RENDERS the headings
  that already live in text per §14.8), hyphen/bullet lists,
  clickable checkboxes (`- [ ]` ↔ `- [x]` as an ORDINARY edit:
  autosave, churn, text undo; refuses under seal like any edit) —
  PLUS her selections **strikethrough** and **inline code**, PLUS
  **links** (F-5). Arbitrary per-span font sizes are recorded as
  NOT markdown-expressible — sizes = headings; anything beyond is a
  future conversation.
- **F-4 (RULED): WT-5 sticky pane modes = YES**, as proposed: mode
  is pane-local and sticky; clicking away never changes what a pane
  shows; the un-live pane renders a dimmed READ-ONLY projection of
  its own mode; only the ring and who-types move.
- **F-5 (RULED, after her clarifying question — verbatim):** *"if
  we added [text](url) is that going to show up as [text](url)
  though? how is that more face work for click handling if we're
  showing the markdown? or do you mean click handling in the read
  mode, where presumably the markdown will just be displayed
  formatted?"* Answered at the sitting: editing surfaces show the
  styled syntax (text link-colored, the `(url)` dimmed) and open
  via **⌘-click** (a live editor's plain click places the caret —
  that wiring is the "face work"); **READ MODE — a true reading
  surface (her A43 ruling) — renders markdown FULLY FORMATTED,
  markers hidden, plain click opens.** She ruled links IN.
- **The surface rule her question pinned (record it as design
  law):** EDITING surfaces (and the read-cheap tier, whose click
  seeds a caret offset) render the dimmed-marker styled face —
  display == stored, always. READ-ONLY surfaces with NO editing
  gestures (Read mode; exports are markdown by definition) may
  render fully formatted — display ≠ stored is safe exactly where
  no gesture maps clicks to text offsets.

Honesty notes she took with the ruling: the bridge pushes literal
syntax to Fragments (it IS the text); word counts count marker
characters at first (cheap refinement, recorded); no "markdown
mode" setting exists under dual-mode — the only knob is marker
visibility, a display setting if ever wanted.

## THE LEDGER

| # | Item | Status |
|---|------|--------|
| L1 | WT-1 discoverability: helper "workspace" group + dictionary entries + field-guide workspace lesson + the shortcut drift-guard walk test | batch 1 |
| L2 | WT-2: context bar defaults COLLAPSED | batch 1 |
| L3 | WT-3: back/context bar flush with the window top (the bottom bar's model) | batch 1 |
| L4 | WT-4: the sidebar "Variorum" chrome label removed (a TRY — she keeps/reverts on sight) | batch 1 |
| L5 | WT-5/F-4: sticky pane modes | batch 1 |
| L6 | WT-6: pane body-click focus parity (TRACE the left-pane asymmetry first) | batch 1 |
| L7 | The markdown foundation: pure Domain tokenizer + the dimmed-marker editing face (F-1/F-2) | batch 2 |
| L8 | Insertion faces: ⌘B/⌘I/toolbar + registry declarations (formatting acts are acts) | batch 2/3 |
| L9 | Lists + checkboxes incl. click-to-toggle (ordinary edit; seal refuses honestly) | batch 2/3 |
| L10 | Links (F-5): styled + ⌘-click in editors; fully rendered + plain-click in Read | batch 3 |
| L11 | Read mode full markdown rendering (the F-5 surface rule) | batch 3 |
| L12 | Helper/tutorial coverage for formatting + the re-seed note | late batch |
| L13 | The kickoff sweep: the shell-redo flaky pin trace + the windowless-launch/quit-hang characterization (both KnownIssues rows, owner 13g) | sweep batch |
| L14 | W26: the true global quick-note hotkey — author-attended, later in phase (her round-2 word) | HELD for her |
| L15 | TEXTKIT2 §5 re-verify after the phase's editor work | closeout |
| L16 | 13g's closeout AUTHORS 13e's plan (her standing instruction) | closeout |

## Batch 1 brief — the walkthrough batch (a FRESH Opus implementer; self-contained)

**Read first, in full:** `CLAUDE.md`; this plan file top to bottom
(the sitting rounds are the rulings you build; the P-1…P-9
constitution binds); the environment-traps section of
`notes/plans/phase-13c-book-forms-and-conversions.md` (binding,
verbatim). Baselines: core 926/105 · Mac 1068/188 · mobile 14/4.
Do NOT touch `Sources/VariorumCore/Sync/`. No schema.

**The items (L1–L6):**

- **L1 (WT-1):** `HelperView.swift`'s hand-maintained `groups` gains
  a "workspace" group — ⌘⇧1–9 (Open-strip jumps), ⌘[ / ⌘]
  (back/forward per pane), ⌘⇧I (context bar), ⌘⇧N (quick note) —
  plus rows for the shortcut-less doors (Open Beside · New Window ·
  Open in New Window · stars) shown by their MENU PATHS (the
  helper's own framing line "every shortcut is also a menu item"
  holds). The `entries` dictionary gains: window/split/pane, star,
  quick note, the Open strip — one or two plain sentences each, in
  the app's voice. `TutorialSeeder.plan` gains a workspace
  chapter (windows & the split, the Open strip + history + context
  bar, stars, the quick note) — the seeder's walk test asserts
  plan == seed, update both together; NOTE in the batch record that
  lesson edits STALE the real store's seeded guide (her
  Restore-Tutorial click bundles to the next sitting). **The drift
  guard:** a walk test asserting every registry `shortcutLabel`
  appears in the helper's groups — red on today's code by
  construction (the four missing 13f chords), green after; that IS
  its red-on-old.
- **L2 (WT-2):** `WorkspaceModel.contextBarCollapsed` default flips
  to COLLAPSED at birth; click (or ⌘⇧I) expands. Pin the default.
- **L3 (WT-3):** the ContextBar sits FLUSH with the window top at
  its `PaneHost` mount — the bottom status bar (flush, under the
  floating left pane) is the geometry model. Screenshot-verify.
- **L4 (WT-4):** remove `SidebarView.swift`'s
  `tokens.chromeLabel("Variorum")` header. A TRY — she reverts on
  sight if she misses it. If the strip proves load-bearing
  (window-drag area / traffic-light clearance), STOP and propose
  the smallest honest alternative to the orchestrator before
  building (the in-batch fork rule).
- **L5 (F-4):** sticky pane modes — a pane's mode is pane-local and
  sticky; clicking away NEVER changes what a pane shows; the
  un-live pane keeps its mode row and renders a dimmed READ-ONLY
  projection of its own mode; liveness moves only the ring and
  who-types. The mount rule is UNTOUCHED (exactly one live surface,
  ever — extend nothing beside `PaneTextAuthority`). P3: a
  projection costs ∝ visible content. If any mode's read-only
  projection is genuinely heavy (Canvas is the candidate), PROPOSE
  that half before building it.
- **L6 (WT-6):** TRACE why the LEFT pane's read body click does not
  take liveness while the right pane's does (her report is the
  repro), then fix to parity: clicking the read BODY of EITHER pane
  makes it live. Red-on-old pin from the traced mechanism.

**The loop (binding):** red-on-old pins verified by BEHAVIORAL
REVERT; the tutorial spine (`TutorialWalkTests`) green by TYPE name;
full suites at batch end, counts by the "Test run with N tests"
line (Mac from `App/Variorum/`; mobile only if `Sources/`/`Shared/`
is touched — L1–L6 should not); zsh `pipestatus`; never
`git checkout` over uncommitted work; never push; commit per
convention with the batch record appended to this plan file
(point-by-point, PENDING-marked if verification is still owed).
