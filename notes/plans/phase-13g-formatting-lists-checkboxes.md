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
| L1 | WT-1 discoverability: helper "Windows & panes" group + dictionary entries + field-guide workspace lesson + the shortcut drift-guard walk test (found ten missing labels, three pre-13f) | **SHIPPED** (batch 1) |
| L2 | WT-2: context bar defaults COLLAPSED | **SHIPPED** (batch 1) |
| L3 | WT-3: back/context bar flush with the window top — proved ONE change with L4 (the window title's band WAS the gap) | **SHIPPED** (batch 1; her TRY) |
| L4 | WT-4: the "Variorum" whitespace removed — corrected on the record: it was the WINDOW TITLE, not the sidebar label (`.toolbar(removing: .title)` + `.unifiedCompact`) | **SHIPPED** (batch 1; her TRY) |
| L5 | WT-5/F-4: sticky pane modes — mode line SHIPPED; the read-only projections PROPOSED (every non-Write mode is heavy; her word bundled for the morning sitting, orchestrator recommends (b) takes-first) | **PARTIAL** (batch 1) |
| L6 | WT-6: pane body-click focus parity — traced per-CONTENT (2 of 8 branches had the door); the pane-owned `PaneFocusCatcher` | **SHIPPED** (batch 1) |
| L7 | The markdown foundation: pure Domain tokenizer + the dimmed-marker editing face (F-1/F-2) | **SHIPPED** (batch 2) |
| L8 | Insertion faces: ⌘B/⌘I + the Format menu + context submenu + registry declarations (formatting acts are acts) — the visible TOOLBAR is the morning bundle's item (iv), unbuilt | **SHIPPED** (batch 3) |
| L9 | Lists + checkboxes incl. click-to-toggle (ordinary edit; seal refuses honestly) — the RULED half shipped; the checked-box register, indented/nested styling and ⏎-continues-a-list stay held for her word (bundle items ii/iii/v) | **PARTIAL** (batch 3) |
| L10 | Links (F-5): ⌘-click opens in editors (+ the missing Add Link act); fully rendered + plain-click in Read | **SHIPPED** (batch 4) |
| L11 | Read mode full markdown rendering (the F-5 surface rule; pagination measures the transformed text, addresses stay identity) | **SHIPPED** (batch 4 — both faces) |
| L12 | Helper/tutorial coverage for formatting + the re-seed note | **SHIPPED** (batch 4 — ONE Restore-Tutorial click now covers 13f + batches 1 and 4) |
| L13 | The kickoff sweep: the shell-redo flaky pin trace + the windowless-launch/quit-hang characterization (both KnownIssues rows, owner 13g) | **SHIPPED** (batch 5) — flaky pin **RESOLVED** (mechanism traced, fixed at source, 3 latent siblings swept, deterministic pin); windowless **NOT REPRODUCED in 32 launches / 6 arms / 2 trees** — row DEEPENED and re-owned to **13e's kickoff sweep** (L16 must carry it) |
| L14 | W26: the true global quick-note hotkey — SLOTTED to 13e's opening sitting (her round-4 ruling; supersedes round 2's later-in-13g reading) | → 13e |
| L17 | WT-7: the chip popover's wording pass — the diverge RECEIPT ("Open the Copy") must read as a receipt of the past act, the DOOR ("Duplicate as Version") as an act; verify what the "Editing here edits the note everywhere" explainer conditions on (vacuous on a bookless note) | **SHIPPED** (cold review round 1, R1-1 — the "batch 2 / acceptance" route never happened: batch 2 was scoped L7-only and `MembershipChip.swift` carried zero commits all phase; built at the review to the round-4 disposition's letter — the receipt names its book, the explainer conditions on membership) |
| L15 | TEXTKIT2 §5 re-verify after the phase's editor work | closeout |
| L18 | Batch 6 — her morning ruled set: R5-1 takes projection · R5-3 comments LEFT + the "+" retired · R5-4 "block 3/16" · **R5-5 THE CRASH (reproduced, traced to the pane row's geometry-fed-back frame under the hoisted inspector, fixed, verified)** · R5-6 the Notes list · R5-7 inline title · R5-12 the note-window modes switcher | **SHIPPED** (batch 6) |
| L19 | R5-11 the note-only window's clipped top — REPRODUCED and TRACED (layout converges, pixels are the first pass's, any resize repairs it; three candidate fixes measured wrong and reverted) | **NOT FIXED** — KnownIssues row, owner **13e**'s kickoff sweep |
| L20 | Batch 7 — the round-6 nod set: R6-1 tag chips on the top bar (tags leave the bottom bar) · R6-2 the bottom bar's `block ▾` / `note ▾` groups · R6-3 the untitled-date display rule + its export half (the 11b filename shape VERIFIED already compliant) · R6-4 quicknote tag + the self-creating smart book (**consequence, recorded: a quick note is now in Quicknotes and NOT in the Pool** — #52(g)) | **SHIPPED** (batch 7) |
| L16 | 13g's closeout AUTHORS 13e's plan (her standing instruction) — and that plan must NAME, in its kickoff/opening sitting: **W26** (the true global quick-note hotkey, her round-4 slot) and **the windowless-launch/quit-hang row** (re-owned to 13e's kickoff sweep at batch 5, capture-first — see that batch record) | closeout |

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

*(Orchestrator note, 2026-08-01: baselines verified by own runs —
core 926/105, Mac 1068/188, both green; batch 1's fresh Opus
implementer spawned the same night. Mobile's own-run verification
is owed before the first `Sources/`/`Shared/`-touching batch.)*

### Round 4 — 2026-08-01, before bed (W26 slotted; the diverge verdict + a wording finding)

Her message, verbatim:

> ok excellent. just give W26 to a particular phase in the not yet
> run 13 phases - wherever makes sense, so that i'm sure to land on
> it again. i'm going to bed, excited to wake up in the morning!
> the diverge chip works I think but the difference between the
> duplicate as version and open the copy buttons is confusing -
> what is the difference ? i'd update the text on that for clearer
> wording but it seems good

With a screenshot of the membership-chip popover showing, stacked:
"This note is in no book — it lives in the Pool." / [Add to Book ▾]
/ "Editing here edits the note everywhere it appears. To make a
separate note that can diverge:" / [Duplicate as Version] /
"Diverged — \"my book :)\" holds the copy now, in the same place;
the original is untouched elsewhere. ⌥⌘Z undoes it." /
[Open the Copy].

**Dispositions, point by point:**

- **W26 SLOTTED (her ruling): → PHASE 13E's OPENING SITTING** — the
  soonest not-yet-run 13-phase (her 13f round-5 sequencing makes
  13e next after 13g), so she is sure to land on it again. L14
  updated; **L16 now carries the duty**: the 13e plan this phase's
  closeout authors MUST name W26 in its kickoff/opening sitting
  (the true system-wide quick-note hotkey — author-attended; the
  researched one question is whether macOS prompts; the Carbon
  research lives in the 13f plan file). The master plan's 13e row
  gains the item the same turn, so the slot survives any disruption
  to this phase's closeout.
- **Diverge: verdict good** — "the diverge chip works I think."
- **WT-7 (FINDING → RULING, wording): "Duplicate as Version" vs
  "Open the Copy" read as competing alternatives.** They are two
  different MOMENTS, not two options: "Duplicate as Version" is the
  standing divergence DOOR (R31/R35 — it mints a fresh linked copy
  of this note, now); "Open the Copy" is the RECEIPT of the diverge
  she already ran (it navigates to the copy that act placed in
  "my book :)" — it mints nothing). Her ruling: "i'd update the
  text on that for clearer wording but it seems good." ROUTED as
  L17 — a wording pass making the receipt read as a receipt (tied
  to the past act and naming its book, e.g. the button carrying the
  book name) and the door read as an act. RECORDED BESIDE IT, for
  the same pass to VERIFY rather than assume (the hallucination
  guard): in her screenshot the note is in NO book, yet the
  explainer reads "Editing here edits the note everywhere it
  appears" — vacuous for a bookless note (there is no elsewhere);
  the explainer likely wants to be membership-sensitive. Trace what
  the popover actually conditions on before rewording.

### Batch 1 record — the walkthrough batch (2026-08-01, a fresh Opus implementer)

**Counts, from this session's own runs** (the "Test run with N tests" line):
core **926 tests in 105 suites** (unchanged — nothing under `Sources/` or
`Shared/` was touched, by design) · Mac **1075 tests in 190 suites** (from
1068/188: +7 tests, +2 suites — the two discoverability guards, three
pane-focus pins, two pane-line pins). The tutorial spine ran green by TYPE
name throughout (**49 tests in 7 suites**). Zero `Sources/VariorumCore/Sync/`
lines; no schema; mobile untouched.

---

#### L1 (WT-1) — the discoverability surfaces finally carry 13f · SHIPPED

Three faces plus the guard that keeps them honest:

- **`HelperView` (⌘/) gains a "Windows & panes" group** — ⌘⇧1–9 · ⌘[ / ⌘] ·
  ⌘⇧I · ⌘⇧N, plus the four KEYLESS doors by their menu paths (View ▸ Open
  Beside, View ▸ Close Split, File ▸ New Window with the note-row twin, and
  right-click ▸ Toggle Star). Three older omissions of the same class were
  found by the guard and fixed in the same pass: **⇧⌥⌘Z** (structural redo,
  13c), **⌥⌘C** (callout, 13c) and **⌥⌘← / ⌥⌘→** (take pages, 13b).
- **Six dictionary entries** in the app's voice: *pane / the split ·
  window · the Open list · context bar · star · quick note*.
- **The field guide gains a "the workspace" lesson** in the welcome chapter,
  second — right after "getting around", where the sidebar has just been
  introduced. Seven paragraphs: the split and Open Beside; ONE pane writes at
  a time (with the reason, and Lenses/Compare as the same-note answer); both
  window kinds; the Open list, ⌘⇧n, drag-reorder, ✕-closes-a-row, ⌘[ / ⌘];
  the context bar and its fold; stars and the quick note. `plan` and `seed`
  were edited together, so `theSeededBookMatchesTheLessonPlanExactly` holds.
- **A stale key corrected while in that file:** the "shaping blocks" lesson
  still taught **⌥⌘N** for New Block Below, which 13d batch 4 (A14)
  superseded with **⌘⇧⏎**. Exactly the WT-1 class — a discoverability surface
  that drifted out of the registry — so it was fixed here rather than left
  teaching a dead chord.

**THE DRIFT GUARD (the finding's structural half),
`CapabilityRegistryTests.everyDeclaredShortcutIsFindableInTheHelper`:** every
`shortcutLabel` the registry declares must appear in the helper's list.
One-directional on purpose — the helper may hold rows the registry has no
capability for (⌘Z is NSTextView's, ⎋ closes blooms, ⌘, is the system's), and
those are exactly the keys most worth writing down. A sibling pin,
`theKeylessWorkspaceDoorsAreNamedInTheHelper`, covers the doors with no chord.

*Red-on-old, verified by behavioral revert* (helper restored to its pre-13g
rows, `build-for-testing`, suite run, file restored and **checksum matched**):
the guard failed with **exactly ten** missing labels — ⌥⌘← · ⌥⌘→ · ⇧⌥⌘Z ·
⌥⌘C · ⌘1–6 · ⌘⇧1–9 · ⌘[ · ⌘] · ⌘⇧I · ⌘⇧N — and the keyless-door pin failed
beside it.

**The guard caught a bug in itself on its first run**, which is worth
recording: the tokenizer split rows on a bare `"/"`, which turned the
helper's own **⌘/** into `"⌘"` and `""`. The separator is `" / "` now.

---

#### L2 (WT-2) — the context bar is born COLLAPSED · SHIPPED

`WorkspaceModel.contextBarCollapsed` defaults to `true`. Both halves share
one collapse state by design, so this is the one default there was to flip;
collapsed still leaves both halves as doors (the ← arrow and the book glyph),
so the road back is never hidden, and ⌘⇧I or the chevron expands.

*Red-on-old by behavioral revert:* with `= false` restored,
`theChipStateIsSessionStateAndStartsCollapsed` fails on its first assertion.
Two neighbouring pins were re-pointed rather than weakened —
`BookAscentTests.theFoldToggchesTheWholeBar` walks the same one state from
the other end, and `WindowsTests`' per-window claim now proves itself by
EXPANDING one window's bar.

---

#### L3 + L4 (WT-3, WT-4) — ONE change, and the plan's file pointer was wrong · SHIPPED (a TRY)

**These two items are the same thing, and the screenshot is what proved it.**

The plan routed WT-4 at `SidebarView.swift:289`'s
`tokens.chromeLabel("Variorum")`. Captured and zoomed on the running Debug
build: **that `Section` header renders NOTHING on macOS 26** — the sidebar's
rows begin directly under the toolbar. The word she sees is the **WINDOW
TITLE**, drawn with a divider in a band across the top of the DETAIL pane —
and that band is precisely what stands between the window's top edge and the
context bar, i.e. WT-3's gap.

Shipped: **`.toolbar(removing: .title)`** (the word and its divider go, so
the pane's own chrome is the topmost thing in the detail) +
**`.windowToolbarStyle(.unifiedCompact)`** (the strip that remains is not
empty — it carries the traffic lights, New Note and the sidebar toggle — so
it is made as short as it honestly can be). The dead `Section` header was
removed too: a no-op on screen, but it is the string that sent the plan to
the wrong file.

**Two attempts measured and REJECTED on the way** (screenshots in the
scratchpad, listed below):

1. `.ignoresSafeArea(.container, edges: .top)` on the detail, to reach the
   window's literal top edge — the toolbar band is OPAQUE, so the pane's
   first row slid **under** it and became unreadable. Worse than the
   whitespace.
2. `.windowStyle(.hiddenTitleBar)` — **no visible difference** once the title
   itself is removed, so it was dropped rather than carried. It also *looked*
   like it un-floated the sidebar card; the discriminating capture (the
   ORIGINAL binary, photographed **not key**) proved the floating inset card
   is simply the **key-window appearance**. The wrong conclusion was one
   screenshot away, and only the revert-and-compare habit caught it.

**Visual verification owed, one click of hers:** the captures are all of the
SHELF (the pane's first row). The context bar itself renders only inside a
note with an origin, and the automated session could not make the dev window
key to drive one. The geometry claim is the same mount point either way.

Captures: `shelf.png` (before, key) · `flush.png` / `hidden_key.png`
(hiddenTitleBar) · `flush2.png` (the rejected ignoresSafeArea, showing the
buried header) · `orig_nonkey.png` (the discriminating capture) ·
`compact.png` (as shipped).

---

#### L5 (WT-5 / F-4) — sticky pane modes · **PARTIAL, and the other half is PROPOSED**

Built: **the unfocused pane NAMES the mode it is holding.**
`WorkspaceNaming.paneLine` renders `"orbit · takes"`, and `PaneHost` reads
that mode from **`PostDetailView.rememberedMode(postID:)` — the very source
the detail restores from**, so the line cannot disagree with what clicking
gives back. Deliberately NOT a second `modes[PaneID]` field: a mode row that
lies is worse than no mode row, and one source makes "sticky" true by
construction. The help text says it too.

**PROPOSED, not built — the read-only projections.** The brief anticipated
"if ANY mode's read-only projection is genuinely heavy (Canvas is the
candidate)". Traced: **every non-Write mode is that case.** An unfocused pane
may not mount an authority owner or a routed-command handler (`PaneMount`'s
whole rule), and *`TakesBoardView`, `LensesBoardView`, `CompareBoardView`,
`CanvasView` and `BlockTOCView` are each one or both* — while **Write is the
only mode with a shipped read-only twin** (`ReadPostView`). The shipped
precedent agrees and is written down: `SpreadBookView` (13c 2B) renders a
non-live takes-form page as `ReadPostView` for exactly this reason, and its
file header records that mounting a second board would create two
`PaneTextAuthority` owners. Threading a `live: Bool` into those five surfaces
is precisely the alternative the batch-4 gate NAMED AND REJECTED.

So the honest options for her, in the orchestrator's hands:

- **(a)** ship the mode line alone (what is built) and revisit if the pane
  still reads as "reset";
- **(b)** build ONE read-only takes projection (a card list over the fan
  projection, no authority, no handler) — the highest-value single mode, its
  own batch, and the first new surface P-3 has grown since 13b;
- **(c)** all five, which is a phase-sized piece of work and would make the
  mount rule's cost concrete in five places at once.

*Pins:* `aPaneNamesTheModeItIsHolding` (the line) and
`theLineAgreesWithWhatTheDetailWillRestore` (the one-source claim, driven
through the real per-note memory). Red-on-old by behavioral revert
(`paneLine` returning the bare name), checksum restored.

---

#### L6 (WT-6) — pane body-click focus parity · SHIPPED, traced first

**The trace** (her report is the repro; `RootView.paneDetail` is where it
lives). An unfocused pane's body-click focus door existed in exactly two of
its eight branches: **notes and scraps** (`readCheapNote` →
`ReadPostView.onFocusRequest` — the pane she said works) and **books**
(`BookView.onPaneFocusRequest`, and only through `BookViewModel.focus(_:)`,
so a click on the chapter list, header or empty page does nothing). Shelf,
Library, Pool, Snippets, a tag folder and the recovery surface have **no
body-click door at all** — their ROWS focus the pane, but only as a side
effect of navigating it, so the name line was the only way to focus such a
pane without also changing what it shows. **The asymmetry is per-CONTENT, not
per-side:** whichever pane holds a list is the pane whose body does nothing.

**The fix belongs to the PANE** (`PaneFocusCatcher`), not to seven content
surfaces — otherwise the eighth surface rediscovers the bug. It watches via a
**local `.leftMouseDown` monitor** rather than an overlay, because an overlay
that catches clicks also EATS them, and the read tier's click carries a caret
offset while every list row acts on first click; a monitor observes and
returns the event untouched. Installed only while a pane is unfocused inside
a split, so an ordinary one-pane window carries no monitor. The decision is
pure (`PaneFocusClick`) and side-free — no "left", no "right", which is what
made the bug hard to see and what the free-tiling rider needs anyway.

*Pins:* the arithmetic (inside / sibling pane / already-live / another
window), the wire (a real view in a real window: `isWatching` on and off with
liveness, the monitor's real body over real geometry, and the monitor coming
down when the view leaves its window), and `theCatcherNeverIntercepts`.
Red-on-old by behavioral revert of the window check, checksum restored.

**One measured environment fact, recorded rather than papered over:** a
synthesized event pushed through `NSApp.sendEvent` does **not** reach a local
monitor in this test host (the monitor sees events coming off the event
QUEUE). So the pin asserts installation via `isWatching` and drives the
monitor's body directly; the single untested step is AppKit calling a monitor
it already holds. The first draft of this pin claimed the end-to-end dispatch
and went red for that reason — the claim was corrected, not the assertion
weakened.

---

#### INCIDENT — her running app was quit by this session, and relaunched

Recorded plainly because it broke a standing instruction. While restarting
the DEV build I ran `osascript … tell process "Variorum" to click … Quit`.
**Both apps' AppKit process name is "Variorum"** (13f's W25 renamed only the
Dock/display name to "Variorum Dev"), so the Release instance answered and
terminated. It was the **windowless** instance (CGWindowList showed no window
for it before or after — the KnownIssues windowless-launch row), so no editor
was open and no buffer was in flight; all writes are autosaved through the
operations layer and the outbox is durable in SQLite, so there is nothing to
recover.

Repaired immediately: `/Applications/Variorum.app` was relaunched and is
running. **One difference from what was found, stated exactly:** the instance
that was running came from `DerivedData/Build/Products/Release/` (a Release
product left over from the 13f closeout's own build); the one now running is
`/Applications/Variorum.app`, which CLAUDE.md names as the only copy she
launches. Same 13f code, same real store.

**Standing rule this session leaves behind:** never address a Variorum
instance by PROCESS NAME. Use the bundle id (`io.lduarte.Variorum.debug` for
the dev build) or the PID — both were used for every subsequent restart, and
her instance was never touched again.

---

#### Notes for the orchestrator

- **A re-seed is owed** (Help ▸ Restore Tutorial, one click of hers): the
  field guide gained a lesson and had a stale key corrected, so her seeded
  copy is behind. Bundle it with the re-seed already owed from 13f.
- **L3/L4 ship as her TRY** — one modifier each to put back.
- **The L5 proposal above wants her word** before any of (b)/(c) is built.
- Nothing was added to `notes/QUESTIONS.md`: the two open items are a
  proposal to the orchestrator and a visual verification, neither of which is
  a PROVISIONAL product ruling. **#49 remains the next free number.**

### Orchestrator acceptance — batch 1 (2026-08-01)

- **Commit `f0534ad` verified by own inspection:** 15 files, scoped
  exactly as claimed — App target + tests + this plan's record only;
  no `Sources/`, no `Shared/`, no schema, zero `Sync/` lines.
  Load-bearing diffs read: the L3/L4 scene modifiers (measured-not-
  assumed record with two rejected attempts and the discriminating
  not-key capture), the L6 `PaneFocusCatcher` (pane-owned local
  monitor, observe-never-consume, split-only installation), the L1
  drift guard + keyless-door pin.
- **Counts:** implementer's own runs core 926/105 · Mac 1075/190 ·
  spine 49/7. **Orchestrator's own acceptance run of the Mac suite:
  "Test run with 1075 tests in 190 suites passed" — the claim
  matches exactly.** Core is unchanged by construction (no
  `Sources/` diff) — the sitting-open own-run (926/105) stands as
  the acceptance number. Mobile baseline own-run launched at
  acceptance (iPhone 16e), ahead of batch 2's `Sources/` work.
- **The INCIDENT accepted as recorded** — honest, repaired, and
  verified by this session's own `pgrep`: exactly one instance
  running, `/Applications/Variorum.app` (PID at check: 24191).
  **BINDING FOR EVERY LATER BATCH BRIEF (the incident's standing
  rule):** never address a Variorum instance by PROCESS NAME —
  bundle id (`io.lduarte.Variorum.debug` for the dev build) or PID
  only; both builds share the AppKit process name "Variorum".
- **Ledger:** L1 SHIPPED · L2 SHIPPED · L3+L4 SHIPPED as ONE change
  (her TRY — keep/revert on sight; the WT-4 file pointer corrected
  on the record: the whitespace was the WINDOW TITLE, not the
  sidebar label) · L5 PARTIAL (mode line shipped; projections
  PROPOSED — adjudication below) · L6 SHIPPED (traced first).

**L5 adjudication (architect):** the implementer's trace is ACCEPTED
— every non-Write mode is an authority owner and/or routed-command
handler; Write alone has a read-only twin; threading `live:` flags
through five surfaces is the alternative a prior gate named and
rejected. F-4 stands as HER ruling; what changed is its COST, and a
newfound constraint on a settled design goes to her (the skill's
rule), never silently re-scoped. **BUNDLED for the morning sitting
with the orchestrator's recommendation: (b) — build the read-only
TAKES projection as its own batch.** Takes is the mode her complaint
named ("if you were just in takes"), it is the highest-value single
projection, and it walks the P-3 extension road one surface at a
time; (a) stands meanwhile (the pane names its mode); (c) — all
five — is offered honestly at its phase-sized cost.

**THE MORNING BUNDLE (held for her, nothing improvised):** the L5
word ((a) hold / **(b) takes-first, recommended** / (c) all five);
ONE Restore-Tutorial click covering both owed re-seeds (13f's
vocabulary + batch 1's workspace lesson and key correction); the
L3/L4 look on sight (keep, or one modifier each to put back); the
incident relayed plainly; the WT-4 correction FYI.

*Extended at batch 2's acceptance (look/register items, deliberately
not invented overnight):* **(i)** inline code is INVISIBLE in the
terminal voice (terminal prose is already monospaced, so only the
dimmed backticks distinguish it — a tint is the obvious fix; no
tint was ruled); **(ii)** a CHECKED checkbox's text is styled
exactly like an unchecked one (dimming or strike-through is what
most apps do — F-3 ruled the vocabulary, not the register);
**(iii)** indented list items are unstyled (the column-0 rule) —
nested lists need her word on how indentation should read;
**(iv)** an OFFER, not built: a visible formatting toolbar/bar
(her "native-looking tools/buttons") beyond batch 3's Format menu
+ shortcuts + context menu — chrome restraint says menu-first,
her call; **(v)** list ERGONOMICS (does ⏎ at the end of a list
line continue the list with a fresh `- `?) — unruled, and it
changes what typing does, so it waits for her word.

*Extended at batch 3's acceptance:* **(vi)** `notes/QUESTIONS.md`
**#49** — batch 3's nine build-time calls (multi-line wrap
per-line; lead-replaces-lead; the every-piece toggle rule; blank
lines; the `****` caret gesture; ⌘B/⌘I only, five menu-first; the
box's hit-target width; Checklist-mints-unchecked; no palette
rows), each one line to change — the walk reads them in one place;
**(vii)** ONE HAND-CHECK the pins cannot reach: press ⌘B while the
keyboard is in a take pane (AppKit routing a menu key equivalent to
a first responder inside a board is the last unpinnable inch).

## Batch 2 brief — the markdown foundation (a FRESH Opus implementer; self-contained)

**Read first, in full:** `CLAUDE.md`; this plan file TOP TO BOTTOM
(sitting rounds 1–4 are the author's rulings — F-1…F-5 govern this
batch; the P-1…P-9 constitution binds); the "Environment traps"
section of `notes/plans/phase-13c-book-forms-and-conversions.md`
(binding) PLUS batch 1's standing addition: **never address a
Variorum instance by process name — bundle id or PID only**;
`notes/TEXTKIT2_NOTES.md` §1 and §3 — this batch must never touch
`NSTextList`, and §3's per-range rendering-attributes warning
governs mechanism choice below.

**Scope: L7 ONLY** — the tokenizer + the dimmed-marker editing
face. NOT in this batch (they build ON it): insertion faces +
registry acts (L8), checkbox click-toggle & list ergonomics (L9),
link opening (L10), Read-mode full rendering (L11).

- **(i) The tokenizer — a pure Domain function**
  (`Sources/VariorumCore/Domain/`, suggested `MarkdownSyntax.swift`):
  text → spans; each span = kind + marker range(s) + content range,
  **UTF-16 offsets** (the structural API's unit — grapheme-validated,
  the `BoundarySnapping` discipline). The v1 vocabulary EXACTLY
  (F-3): `**bold**` · `*italic*` · `#`/`##`/`###` headings (line
  start) · `- ` bullets (line start) · `- [ ]` / `- [x]` checkboxes
  (line start) · `~~strikethrough~~` · `` `inline code` `` ·
  `[text](url)`. **Line-scoped scanning** — a span never crosses a
  newline. Unclosed markers are plain text. No nesting resolution
  in v1 beyond a documented first-match rule. Exhaustive edge tests
  in the Domain suite: unclosed, adjacent, mid-word `*`, empty
  content, marker-only lines, checkbox with/without trailing text,
  URLs containing parens — DECIDE each and pin the decision.
- **(ii) The editing face:** dimmed markers + styled content on the
  EDITING surfaces (the full-document editor and the pane read
  tier). **Display == stored, BYTE-FOR-BYTE, always** (F-2 and
  F-5's surface rule): attributes only — the string never changes.
  Mechanism: real FONT/COLOR attributes on the text storage /
  attributed string — deliberately NOT TK2 per-range rendering
  attributes (§3's unreliable class). Headings style at line level,
  code monospace, markers dimmed via the muted token color; all
  colors/fonts through the voice tokens (P-8), both voices, light
  and dark. **P1: re-scan scope ∝ the edited paragraph(s) on every
  keystroke path — never the document; measure and state the
  keystroke cost in the record.** Styling is PASSIVE in this batch:
  clicks, caret, selection, and every structural gesture are
  byte-untouched.
- **`renderedText` / export / the bridge: ZERO lines** — the join
  brain is untouched by F-1's letter (syntax is content); do not
  add semantics anywhere near it.
- **Mobile runs at batch end** (`Sources/` is touched): the iPhone
  17-family/16e destination note (13f plan). Full suites + the
  tutorial spine by TYPE name, counts quoted from your own "Test
  run with N tests" lines. Baselines to match-or-beat: core 926/105
  · Mac 1075/190 · mobile 14/4.
- The loop as batch 1 ran it: red-on-old pins by behavioral revert
  with checksums; PROVISIONAL-and-continue for non-gating ambiguity
  (recorded); STOP-and-report for anything gating or exceeding a
  ruling's shape; append the batch record here; commit per
  convention; never push; never `/Applications`; her running
  real-store instance is never touched.

### Batch 2 record — the markdown foundation (2026-08-01, a fresh Opus implementer)

**Counts, from this session's own runs** (the "Test run with N tests" line, on
the final tree): core **946 tests in 106 suites** (from 926/105: +20 tests,
+1 suite — the tokenizer) · Mac **1088 tests in 191 suites** (from 1075/190:
+13 tests, +1 suite — the face) · mobile **14 tests in 4 suites** (unchanged;
run because `Sources/` was touched). The tutorial spine ran green by TYPE name
on the final tree (**49 tests in 7 suites**). Zero `Sources/VariorumCore/Sync/`
lines; no schema; **zero lines anywhere near `renderedText`, the export
projections or the bridge's join brain** — verified by `git diff --name-only`.

Scope was **L7 only**. L8 (insertion faces + registry acts), L9 (checkbox
toggling and list ergonomics), L10 (link opening) and L11 (Read-mode full
rendering) were deliberately not started; the pieces they need — a span's
marker ranges, a checkbox's box range, a link's URL range — are on the
tokenizer's `Span` already, so they compose without re-deriving anything.

---

#### (i) The tokenizer — `Sources/VariorumCore/Domain/MarkdownSyntax.swift`

A pure Domain function, no GRDB and no AppKit: `spans(in:) -> [Span]`, UTF-16
offsets accumulated per grapheme cluster (so every range is grapheme-aligned by
construction, the `BoundarySnapping` discipline), plus `Span.shifted(by:)` — the
rebasing door a line-scoped rescan needs — and a DEBUG `MarkdownScanCount`
thread-local counter placed **on the scanner itself**, for the reason
`BoundaryScanCount` records: a counter on an app-side wrapper would read zero
against the pre-fix code and every P1 pin built on it would be hollow.

The v1 vocabulary is exactly F-3 and nothing more: `**bold**` · `*italic*` ·
`~~strikethrough~~` · `` `code` `` · `[text](url)` · `#`/`##`/`###` ·
`- ` bullets · `- [ ]`/`- [x]` checkboxes.

**Every decision, pinned:**

| Decision | Why | Pin |
|---|---|---|
| **Line-scoped by law** — a span never crosses a newline | Two things ride it: the per-paragraph rescan (P1), and — because the editor joins blocks with a single `"\n"` — **a span can never cross a BLOCK SEAM**, so markdown and block identity can never disagree | `aSpanNeverCrossesANewline` (core) · `aSpanCanNeverCrossABlockSEAM` (Mac, through the real editor) |
| A line-leading construct must start at the line's **first character** (no CommonMark 0–3 space tolerance) | "It starts the line or it is text" is a rule a writer can hold in her head; an indented line silently becoming a heading is not. *Consequence L9 will meet: indented (nested) list items are not styled in v1* | `headingsRunOneToThreeAndNeedTheirSpace` (`"  # indented"`) |
| `####`+ is plain text | F-3 names three sizes; a fourth can never appear by accident | same |
| `#hashtag` (no space) is plain | — | same |
| `"# "` / `"- "` / `"- [ ]"` alone = the construct with EMPTY content | She has typed the marker and is about to type the words; the face should appear when she commits to it, not one word later | same + `bulletsAreTheHyphenAndNothingElse`, `checkboxes…` |
| **`- ` is the only bullet** (`* ` is NOT) | `*` at a line start collides with italic; one unambiguous list marker beats CommonMark parity here. Her words were "hyphens, [], bullets" | `bulletsAreTheHyphenAndNothingElse` |
| `- [X]` reads as checked; `- []`, `- [?]`, `- [x]text` degrade to a **bullet**, never to nothing | The list keeps its shape while she types | `checkboxesReadBothStatesAndFallBackToBulletsWhenMalformed` |
| Checkbox `markers[1]` IS the box | L9's toggle rewrites exactly that range | same |
| **Minimal flanking rule** for `*`, `**`, `~~`: an opener may not be followed by whitespace, a closer may not be preceded by it | Kills `2 * 3 * 4` — the one false positive a prose writer actually hits — for two comparisons per candidate | `theFlankingRuleKeepsArithmeticArithmetic` |
| Code has NO flanking rule | Backticks legitimately wrap spaces and operators; CommonMark agrees | `boldItalicStrikeAndCodeCarry…` |
| **All inline spans require non-empty content** — `****`, `` `` ``, `[](u)`, `[t]()` are literal | ONE rule across the family instead of five; a link to nowhere is not a link | `emptyContentIsAlwaysLiteral` |
| Unclosed openers are plain text, and scanning advances **one grapheme** | `**a*b*` still finds the italic — pinned because the advance-by-one rule is what makes it true | `unclosedMarkersArePlainText`, `aFailedBoldStillLetsTheItalicInsideItMatch` |
| Mid-word emphasis allowed (`a*b*c`) | CommonMark does, and `un*bloody*likely` is a thing writers type | `midWordEmphasisIsAllowed` |
| Link text does **not** nest (first `]` closes it) — `[a[b]](u)` is plain | A nesting parser buys nothing prose uses | `unclosedMarkersArePlainText` + the shape pins |
| Link URL parens are **balanced** — `[a](https://x/Foo_(bar))` links the whole address | Wikipedia-shaped addresses are the everyday case a first-`)` scan gets wrong | `aURLMayCONTAINParentheses` |
| **No nesting: a span's content is not rescanned** (the documented first-match rule) | `` `*a*` `` is one code span; `**a *b* c**` is one bold span | `aSpansContentIsNotRescanned` |
| **The ONE exception: a line-leading span's content IS inline-scanned** | `# **Big**` and `- [ ] **task**` are what a writer means. Spans come back in APPLICATION ORDER (leading first), so a styler composes them | `aLineLeadingSpansContentIS_inlineScanned` |
| Offsets are UTF-16 and never split a grapheme | The structural API's unit; emoji and ZWJ sequences pinned | `offsetsAreUTF16AndNeverSplitAGrapheme` |

Plus structural pins: inline spans are pairwise disjoint and ascending, every
marker/content range sits inside its span's range (`inlineSpansNeverOverlapAndAscend`),
`shifted(by:)` moves every range together, and the scan counter's own arithmetic
is pinned on the scanner (`theScannerCountsExactlyWhatItWasHanded`).

---

#### (ii) The editing face — `App/Variorum/Variorum/Theme/MarkdownStyling.swift`

**Display == stored, BYTE FOR BYTE.** The file writes only ATTRIBUTES; it never
inserts, removes or replaces a character on any surface. That is what leaves
the app's riskiest machinery (AppSpec §15 risk 1) untouched by formatting —
`BlockRangeIndex`, crystallization, the differential structural rewrite,
autosave, find and every gesture read exactly the offsets they always read.

**Mechanism: real text-storage font/colour attributes, never TK2 per-range
RENDERING attributes** (TEXTKIT2 §3's unreliable class), and **`NSTextList` is
never invoked** (§1/§3) — a list is text lines, which is exactly what F-1 buys.

**Where it is wired** — at the small set of places base attributes are written,
so a future surface inherits the face rather than having to ask for it:

1. `EditorDocument.materialize` — the ONE materialization both full-render paths
   go through (the full-document editor and the read tier);
2. `EditorViewModel.storageDidEdit` — the keystroke path, lines-scoped;
3. `EditorViewModel.applySeamEdit` — structural seam edits reset the replaced
   span to base, so the face is re-derived there (pinned: a divide keeps its
   bold);
4. `ReadPostViewModel.applyDifferential` — the read tier's per-slot replace;
5. `NSTextView.applyVoiceChrome` — the voice switch's full-range base refresh;
6. `PaneSurface` — the ink write, both string adopts, the font/gap branch, and
   live typing (a new `shouldChangeTextIn` **recorder**, which observes and
   never gates, so a pane rescans its edited lines rather than the pane);
7. `RootView` — the palette follows the voice AND the appearance.

**The palette** (marker = `tokens.muted`, link = `tokens.accent`) is a global
written on the main thread, exactly mirroring `EditorTypography.current` and for
the same stated reason: threading a palette through `materialize`, both surface
kinds and every pane composer is the divergent-private-copy class this app has
already paid for twice. Before any voice has been applied it falls back to the
system's secondary/link colours — deliberately NOT a copied token literal.

**The clear path is a capture-and-restore, not a guess.** A styled range carries
`faceAttribute`, whose VALUE is the prose foreground colour that was there
(`NSNull` = "there was none", which is the state `materialize` produces). Panes
take their ink per-view from tokens, the editor takes it from its chrome, and
the read tier may carry none — so remembering beats guessing, and un-styling
restores the surface's own ink whatever it is.

**The zero-write fast path.** Text with no markdown and no previously applied
face writes NOTHING — not one attribute call. Prose without syntax therefore
behaves byte-identically to how it did before this batch, which is the honest
default and keeps the A47c full-range-write class away from ordinary typing.

*Honesty note, measured while pinning it:* an empty `beginEditing`/`endEditing`
pair posts no `processEditing`, so what the guard actually saves is the scan and
the enumeration (~16 µs on a 15k-character note), **not** a layout pass. The
first draft of the pin's comment claimed the invalidation; the claim was
corrected rather than the assertion weakened, and the file header says so.

**The measured keystroke cost** (this session's own runs, warm, 500 samples,
median / p95, on the real editor's storage):

| What | Cost |
|---|---|
| A keystroke on a line with NO markdown, in a 15,599-character note (the fast path) | **16.1 µs / 16.5 µs** |
| A keystroke on a line CARRYING five spans (the full write path) | **148 µs / 153 µs** |
| The same, doc 7,859 → 31,259 → 124,859 chars | **149 / 150 / 152 µs — flat** |
| A whole-document `style()` once, 15,599 chars (the full-render door only) | 6.2 ms |

So the worst keystroke is ~1 % of a 16 ms frame, and it is flat in note size on
BOTH halves — the scan (pinned by `MarkdownScanCount`) and the attribute writes
(measured across a 16× document-size sweep).

**P1 is pinned structurally, not by a clock:** `aKeystrokeRescansItsOWNLinesAndNotTheNote`
drives a real keystroke into a 15,600-character note and asserts the scanner
walked **79** UTF-16 units — the edited line plus the one after it (the range
widening pulls the follower in, so a Return inside `**bold**` restyles both
halves) plus the character just typed.

---

#### Red-on-old pins — four behavioural reverts, each verified and checksum-restored

| # | Revert | Result |
|---|---|---|
| A | `restyle`'s `string.lineRange(for:)` expansion → the whole storage | RED, exactly discriminating: `aKeystrokeRescansItsOWNLinesAndNotTheNote` fails with **15,600 scanned vs 79**; the other 12 pins stay green |
| B | skip `restyle`'s clear loop (`for (sub, value) in applied`) | RED: `removingTheSyntaxRESTORESTheProseFaceExactly` fails — the stale bold and stale marker colour survive the syntax's deletion |
| C | delete the `guard !spans.isEmpty \|\| !applied.isEmpty` fast-path guard | RED: `proseWithNoMarkdownIsNEVERWrittenTo` fails on both `== false` expectations |
| D | drop `\|\| chars[index].isNewline` from the tokenizer's line walk | RED on BOTH sides: core `aSpanNeverCrossesANewline` (all three cases match across the newline) and Mac `aSpanCanNeverCrossABlockSEAM` (the face crosses the block seam) |

Each file was restored and its `md5` matched the pre-revert value
(`MarkdownSyntax.swift` → `1e1d0a737c4c858afa53be102ef25316`). The reverts are
recorded as `DISCRIMINATING REVERT` doc comments on the four pins, the house
convention (`TakesCardHeightTests`), so a future reader can re-run them.

---

#### What was LOOKED at (an offscreen render, not her app)

A throwaway harness rendered the vocabulary through the real
`EditorTextView` + `applyVoiceChrome` + the face and wrote PNGs (the test host
is sandboxed, so they went to the Debug container's `tmp` and were copied to
the session scratchpad; the harness itself was removed before the final runs —
it is ~25 lines and trivially re-created). **Her running instance was never
touched**; instances were checked by PATH throughout and only
`/Applications/Variorum.app` (PID 24191) was ever seen.

What the light renders show, and they look right: dimmed `#`/`##`/`###` with the
heading text stepping up in size; `**bold**` bold with faint stars; `*italic*`
oblique; `~~struck out~~` struck through **with the markers not struck**; a
green (terminal) / blue (study) link text with a dimmed `(url)`; dimmed `- `,
`[ ]` and `[x]` leads with the items reading as ordinary prose; and
`2 * 3 * 4` and `hyphen-word` left completely alone.

**Two look items for the orchestrator to bundle (deliberately NOT invented into
code, and NOT `QUESTIONS.md` entries — neither is a shipped PROVISIONAL product
ruling; #49 remains the next free number):**

1. **`` `inline code` `` is invisible in the TERMINAL voice.** The face gives
   code the monospaced system font, and the terminal voice's prose is already
   monospaced — so only the dimmed backticks distinguish it (the render
   confirms it). In the study voice it reads clearly. A tint or a background
   would fix it, but neither was ruled, and inventing a colour would be
   inventing product behaviour. Cheap either way.
2. **A CHECKED checkbox's text is styled exactly like an unchecked one.**
   Dimming it, or striking it through, is the obvious candidate and is what
   most apps do — but F-3 ruled the vocabulary, not the register, and L9 (the
   click-to-toggle batch) is the natural place to ask her.

**One measured environment fact, recorded so a future session does not chase
it:** in the OFFSCREEN dark render the prose reads near-black on black, because
runs carrying no `.foregroundColor` draw with a default that `cacheDisplay`
resolves against the wrong appearance (setting `view.appearance` explicitly did
not change it). This is **unchanged by this batch by construction** —
`materialize` has never written a foreground colour, and the face only ADDS
colours to markers and links — and the on-screen app is unaffected. The light
renders are the honest look samples.

---

#### Notes for the orchestrator

- **Nothing was added to `notes/QUESTIONS.md`** — the two open items above are
  taste questions for her sitting bundle, not shipped PROVISIONAL rulings.
  **#49 remains the next free number.**
- **No proposal is owed** — no design fork emerged that the brief did not
  answer. L8–L11 build on the `Span` shape as it stands.
- **A test-parallelism property, pre-existing and inherited:** the face's pins
  read `EditorTypography.current`, a shared global that `Phase13SurfaceTests`
  also mutates (with save/restore, as these do). Full suites are green and the
  window is small, but if a marker-colour or heading-size pin ever flakes, that
  is the first place to look — no new machinery was invented for it.
- **One inherited limitation worth carrying into L9:** indented list items are
  not styled (line-leading constructs must start at column 0). Nested lists will
  need that rule widened, deliberately and with her word on how indentation
  should read.

### Orchestrator acceptance — batch 2 (2026-08-01)

- **Commit `b46b4a6` verified by own inspection:** 11 files, scoped
  exactly as the brief demanded — the Domain tokenizer + its test
  suite, the styling theme file + face tests, the editor/pane/read
  wiring, this plan's record. No `Sync/` lines, nothing near
  `renderedText`/export/the join brain (file list confirms), no
  schema.
- **Counts by the orchestrator's OWN runs:** core "Test run with
  946 tests in 106 suites passed" · Mac "Test run with 1088 tests
  in 191 suites passed" · mobile "Test run with 14 tests in 4
  suites passed" — every implementer claim (946/106 · 1088/191 ·
  14/4 · spine 49/7) matched exactly. **Batch 2 ACCEPTED.**
- The tokenizer's edge-decision table, the four discriminating
  reverts, the measured flat ~150 µs worst keystroke, and the
  refuted-and-corrected fast-path claim are accepted as recorded.
- The two look items + the L9 limitation are routed to THE MORNING
  BUNDLE (extended above, items i–v); nothing invented overnight.

## Batch 3 brief — the formatting acts (a FRESH Opus implementer; self-contained)

**Read first, in full:** `CLAUDE.md`; this plan file TOP TO BOTTOM
(rounds 1–4 = the rulings F-1…F-5; the P-1…P-9 constitution binds;
batch 2's record defines the tokenizer API you build on); the
"Environment traps" section of
`notes/plans/phase-13c-book-forms-and-conversions.md` (binding) PLUS
the batch-1 standing rule: **never address a Variorum instance by
process name — bundle id or PID only**; `notes/TEXTKIT2_NOTES.md`
§1/§3 (no `NSTextList`, ever; no TK2 per-range rendering
attributes).

**Scope: L8 + L9's ruled half (click-to-toggle) ONLY.** NOT in this
batch — held for her morning word, do not preempt: the checked-box
text register, indented/nested list styling, ⏎-continues-a-list
ergonomics, any visible formatting toolbar (menu/shortcut/context
doors only), links behavior (L10), Read-mode rendering (L11).

- **L8 — the insertion faces.** The edit COMPUTATION is pure Domain
  (`Sources/VariorumCore/Domain/`, e.g. `MarkdownEditing`):
  wrap/unwrap toggles for `**` `*` `~~` `` ` `` over a selection
  (consult `MarkdownSyntax.spans` to decide wrapped-ness — never
  regex guessing; ⌘B on `**sel**` UNWRAPS), empty-selection insert
  with caret-between, and line-level prefix toggles for headings
  (#/##/###), `- ` bullets, and `- [ ]` checkboxes at the caret's
  line(s), the column-0 rule respected. Tests in the Domain suite
  for every shape. The FACE: registry declarations (P-1 — verb,
  scope, doors, availability = a live editing surface, honest
  refusal copy), a **Format menu** + context-menu entries +
  shortcuts. **Collision-sweep every chord before binding it** (the
  13f pattern — sweep `EditorCommands.keyEquivalent`, every
  `.keyboardShortcut(` in `Variorum/` and `Shared/`, `NSMenuItem`
  equivalents; record the sweep's result in the registry comment;
  ⌘B/⌘I are the natural candidates IF free; anything not free ships
  menu-first, recorded). The drift guard will force the helper rows
  — that is it working; add them with the chords. All edits ride
  the ORDINARY editing pipeline (autosave, churn, text undo); seal
  and variant locks refuse through the standing surfaces
  (fire-and-speak, P-2).
- **L9's toggle:** a click exactly on a checkbox's BOX (the
  tokenizer's box range — `markers[1]`, already carried) in a LIVE
  editing surface toggles `- [ ]` ↔ `- [x]` as one ordinary edit
  (caret preserved; text undo works; sealed refuses honestly). The
  read tier's standing click-to-focus is untouched: first click
  focuses (as today), the click on the live surface toggles. State
  the chosen hit-test mechanism in the record; it must not eat
  ordinary caret clicks (the batch-1 `PaneFocusCatcher`
  observe-don't-consume lesson is the reference shape).
- **Suites:** `Sources/` is touched (the Domain functions) ⇒ ALL
  THREE run at batch end, counts quoted from your own "Test run
  with N tests" lines. Baselines to match-or-beat: core 946/106 ·
  Mac 1088/191 · mobile 14/4. Tutorial spine green by TYPE name.
- The loop as batches 1–2 ran it: red-on-old by behavioral revert
  with checksums; PROVISIONAL-and-continue non-gating (recorded;
  product PROVISIONALs to `notes/QUESTIONS.md`, #49 next free);
  STOP-and-report anything gating; batch record appended here;
  commit per convention, explicit paths; never push; never
  `/Applications`; her real-store instance never touched.

### Batch 3 record — the formatting acts (2026-08-01, a fresh Opus implementer)

**Counts, from this session's own runs** (the "Test run with N tests" line, on the
final tree): core **970 tests in 107 suites** (from 946/106: +24 tests, +1 suite —
the edit computations) · Mac **1100 tests in 192 suites** (from 1088/191: +12
tests, +1 suite — the faces) · mobile **14 tests in 4 suites** (unchanged; run
because `Sources/` was touched). The tutorial spine ran green by TYPE name on the
final tree (**49 tests in 7 suites**). Zero `Sources/VariorumCore/Sync/` lines; no
schema; **zero lines anywhere near `renderedText`, the export projections or the
bridge's join brain** — verified by `git status --short` (nothing under
`Queries/`, `Operations/`, `Bridge/` or `Features/Export`).

Scope was **L8 + L9's ruled click-to-toggle half**. Deliberately NOT started, per
the brief: the checked-box text register, indented/nested list styling,
⏎-continues-a-list, any visible formatting toolbar, links behaviour (L10) and
Read-mode full rendering (L11).

---

#### (i) The edit computations — `Sources/VariorumCore/Domain/MarkdownEditing.swift`

A pure Domain function beside the tokenizer, no GRDB and no AppKit. It answers
ONE question — *given this text and this selection, which characters change and
where does the selection land?* — and returns a `Plan` of ascending, disjoint
`Edit`s plus the resulting selection. It never touches a text view, a store or an
operation.

**The caller passes WHOLE LINES, not the document** (`plan(_:inLines:selection:)`).
That is the `MarkdownStyling.restyle` shape, and it buys the two things this batch
rests on:

1. **P1** — ⌘B costs the lines it touches, never the note (measured below);
2. **no formatting act can restructure a note** — every edit sits inside one line,
   and a line sits inside one block (blocks are joined on the surface by a single
   `"\n"`, so a seam always terminates a line). The editor's cross-block arm,
   which MERGES blocks (the ratified 2026-07-09 merge-then-edit, made for a
   deliberate hand-made selection), is therefore **unreachable by construction** —
   where `EditorFind` has to pre-check every range for exactly this, this gets it
   for free. Pinned end-to-end through the real pipeline
   (`aFormattingActAcrossABlockSeamNeverRestructuresTheNote`: two blocks in, two
   blocks out, both bulleted in the STORE).

**Every product-flavoured decision, and its pin** (all nine are also in
`notes/QUESTIONS.md` **#49**, one line each to overturn):

| Decision | Why | Pin |
|---|---|---|
| **Wrapped-ness is READ from `MarkdownSyntax.spans`**, never guessed | ⌘B on `**sel**` unwraps; so does a caret inside the bold word. A regex would have to re-derive the flanking rule, the empty-content rule and the no-nesting rule the tokenizer already owns | `theActUNWRAPSWhatIsAlreadyWrapped` |
| A caret **just OUTSIDE** a span (right after `**bold**`) does NOT unwrap it | Typing on and pressing ⌘B must start the next bold, not silently undo the last word's | `aCaretJUSTOUTSIDEASpanStartsNewEmphasisInsteadOfUndoingTheOld` |
| A multi-line wrap wraps **each line** | The tokenizer is line-scoped by law, so one pair of markers around a multi-line selection would be literal stars on screen — silently wrong output beats no output only if you never look | `aMultiLineSelectionWrapsEACHLineAndSkipsTheBlankOnes` |
| **Toggle = clear only when EVERY affected piece/line already carries the act** — ONE rule for both families | The alternative (flip each independently) never converges to a tidy list | `aMultiLineSelectionUnwrapsOnlyWhenEVERYPieceIsWrapped`, `aMultiLineLeadClearsOnlyWhenEVERYLineCarriesIt` |
| Setting a line lead **REPLACES** whatever lead the line had | The three line kinds are mutually exclusive to the tokenizer; prefixing would make `- # Title`, whose `#` reads as literal text | `settingALeadREPLACESWhateverLeadTheLineHad` |
| A selection's **surrounding whitespace is trimmed** before wrapping | A double-click-drag routinely picks up the trailing space, and wrapping it breaks the flanking rule — the markers would be literal | `aSelectionsSurroundingWhitespaceIsNotWrapped` |
| A **blank line inside** a multi-line selection is skipped; a **lone** blank line is not | Bulleting the gap between paragraphs is nobody's intent; "caret on an empty line, start a list" is the everyday gesture | `aBlankLineInsideAMultiLineSelectionKeepsItsShape` |
| A selection **ending exactly at a line's first character** does not reach that line | Selecting "abc\n" bullets one line, not two | `aSelectionEndingAtALinesFirstCharacterDoesNotReachThatLine` |
| The **caret gesture** inserts `****` with the caret between, and never a silent no-op (a whitespace-only selection falls back to it) | She asked for bold and is about to type it | `aCaretGestureInsertsBothMarkersAndSitsBetweenThem`, `aWhitespaceOnlySelectionFallsBackToTheCaretGesture` |
| Heading levels are **clamped to 1…3** | F-3 names three sizes and `####` is plain text to the tokenizer — a caller must never mint invisible syntax | `headingLevelsAreClampedToTheThreeTheTokenizerReads` |
| A **checkbox is born UNCHECKED**, and a CHECKED line is still a checkbox to the act | Checking is the click (L9), not the insertion | `aLineLeadTogglesOffWhenItIsAlreadyExactlyThatLead` |
| Offsets are UTF-16 and never split a grapheme; an out-of-range selection **clamps** rather than trapping | The structural API's unit, and the same discipline the tokenizer keeps | `offsetsAreUTF16AndSurviveGraphemesWiderThanOne`, `anOutOfRangeSelectionIsClampedRatherThanTrapping` |

---

#### (ii) The faces — `App/Variorum/Variorum/Features/Formatting/MarkdownActs.swift`

**A formatting act is an ordinary edit, applied through the ordinary input path:**
`shouldChangeText` → `replaceCharacters` → `didChangeText`, the exact trio typing
takes and the one `EditorFind` re-drives its replacements through. So the Write
editor's delegate routes the verdict, updates `BlockRangeIndex`, records autosave
and churn, and **refuses under a seal in its own words with no new refusal code**;
a pane's coordinator restyles its edited lines and hands the text to its board's
autosave. Nothing writes a row; no operation was added; no schema. Pinned all the
way into the store (`boldRidesTheOrdinaryPipelineAllTheWayIntoTheStore`,
`theCheckboxActMakesAListLineFromTheCaretsOwnLine`,
`aSealedNoteRefusesFormattingWithoutTouchingAByte`).

Edits are applied **LAST FIRST** (every earlier offset stays valid — the SDK's own
reason for the finder's reverse ordering) under **ONE undo group**, so ⌘Z takes
back the act rather than half of it (`anActIsONEUndoStep`, driven through a real
window because an `NSTextView` finds its undo manager through the responder
chain — a windowless surface has none, which is how the first draft of that pin
went red).

**THE TARGET IS THE FIRST RESPONDER, and it must be OURS.** A menu key acts on the
key window's first responder when it is a `MarkdownFormattable` — the marker
protocol the two surface kinds opt into and nothing else does. This is **not** a
second liveness mechanism (P-3): it decides nothing about which pane is live, it
asks who currently holds the keyboard, which liveness has already decided (a live
pane makes itself first responder; `PaneTextAuthority` stays the only authority).
The narrowness is load-bearing rather than tidy — **a rename field, the ⌘K search
field and the quick-note pad are all editable `NSTextView`s**, and without the
protocol check ⌘B would have typed `****` into them
(`theTargetIsOneOfOurSurfacesAndOnlyOneOfOurs`, revert-verified). Where there is
no such surface the door SPEAKS (`MarkdownActs.noTargetNote`) instead of being a
dead key (P-2).

**THE COLLISION SWEEP** (the 13f pattern, five places): `EditorCommands.keyEquivalent`
(41 chords) · every `.keyboardShortcut(` call site in `Variorum/` and `Shared/`
(67, incl. `.defaultAction`/`.cancelAction` and the two arrow-key pagers) · every
`NSMenuItem` key equivalent (both are `""`) · the one `performKeyEquivalent`
override (⌘S) · the one `keyDown` override (⇧⏎). **Result: ⌘B and ⌘I are FREE.**
No bare-⌘ letter chord binds `b` or `i`; their shifted neighbours ⌘⇧B (block
seams) and ⌘⇧I (context bar) are the right neighbours to have — the same letter,
the heavier gesture. **The final chords: ⌘B Bold · ⌘I Italic, and nothing else.**
Strikethrough, Inline Code, Heading, Bullet List and Checklist ship **menu-first**
and deliberately keyless: no platform chord for them is standard enough to be
obvious, and inventing one would owe a sweep no ruling asked for (13f batch 4's
precedent). The registry comment carries the sweep; QUESTIONS #49(f) offers her
keys for any of them.

**The doors:** a top-level **Format** menu (Bold · Italic · Strikethrough · Inline
Code — divider — Heading ▸ 1/2/3 · Bullet List · Checklist) and the SAME rows as a
**"Format" submenu in the context menu of both text-surface kinds**, built once by
`MarkdownActs.formatMenuItem(for:)` so the two can never drift. The submenu is
rendered **only where the surface can be edited** — a read pane and a sealed
editor simply do not have it (P-2), pinned. Deliberately no ⌘K palette rows (seven
formatting rows would read as clutter beside "New Note"; QUESTIONS #49(i)).

**Availability is `editableText`** — `writeEditorAttached || takesBoardAttached ||
mode != nil`, i.e. every note mode plus the book/spread/pool editors and a board
mounted outside a detail. Broader than the take family, and the breadth is a FACT:
Write's editor, the Takes/Lenses/Compare panes (4C/4D), Canvas's cards (4E) and
the Blocks TOC's expanded row are all live editable surfaces, so greying the door
there would be a lie. `takesAccess: .native` is literally true — the act runs on
whichever surface holds the keyboard, so Write is not privileged (R118).

**Discoverability rode WITH the build, which is WT-1's whole lesson:** the drift
guard forced the helper rows the moment ⌘B was declared, and the helper's
"Formatting" group names all seven doors — the two chords, and the five by their
menu path — plus dictionary entries for **markdown** (why what she sees is what is
saved, and why an export is already markdown) and **checkbox**.

---

#### (iii) L9's click — the hit-test mechanism, and why it cannot eat a caret click

**Mechanism: an early return in `mouseDown`, on both surface kinds, gated on a
pure decision.** The surface asks `MarkdownActs.toggleCheckbox(at:in:)` BEFORE
calling `super.mouseDown` — because `super.mouseDown` runs AppKit's
selection-tracking loop and there is no "after" in which to decline — and the
answer is no unless:

- the surface is **editable** (a read pane and a sealed editor are not, so their
  clicks fall straight through to the standing click-to-focus — her ruling's
  letter, "first click focuses, as today"; pinned);
- the click is a **single click with no modifiers** (a double-click still selects
  a word; ⌘-click stays free for L10's link opening);
- the click's insertion index lands **STRICTLY INSIDE** the box's three
  characters.

That last rule is the one that keeps it honest, and it is why the decision is a
pure Domain function rather than an inline comparison. A click yields a BOUNDARY
index, so `boxStart` and `boxEnd` are also produced by clicks on the half
character *outside* the box; accepting them would let a click aimed at the text
toggle a box instead. The trade, stated: the target is about two characters wide.
Pinned on both sides — the arithmetic in the core suite (indices 2 and 5 return
nil, 3 and 4 toggle) and the WIRE in the Mac suite through a real surface's own
geometry (`aClickONTheBoxTogglesItAndACaretClickIsNeverEaten` finds its click
points by asking the laid-out view what `characterIndexForInsertion` says, so the
pin exercises point → index → hit test rather than re-deriving it from a font
metric).

The toggle itself is **three characters for three** (`[ ]` ↔ `[x]`), so every
offset in the note survives and the caret simply goes back where it was — pinned.
It rides the same ordinary path as everything else, so ⌘Z takes it back and a
sealed note refuses it.

This is the batch-1 `PaneFocusCatcher` lesson in its other form: that one
**observes and never consumes** because it has no target of its own; this one
**consumes exactly when it has one**.

---

#### The measured P1 cost

`theDoorScansTheLinesItTouchesAndNotTheNote` drives ⌘B into a **15,600-character**
note through the real editor and asserts the scanner walked **fewer than 500**
UTF-16 units — the planned line plus the face's own line rescans. Measured on the
shipped code: well inside the bound. With the door handed the whole document
instead (revert A below) the same run scans **15,725**.

---

#### Red-on-old pins — five behavioural reverts, each verified and checksum-restored

| # | Revert | Result |
|---|---|---|
| A | `MarkdownActs.apply` hands `MarkdownEditing.plan` the WHOLE document instead of `lineRange(for:)`'s substring | RED, exactly discriminating: `theDoorScansTheLinesItTouchesAndNotTheNote` fails with **15,725 scanned vs < 500**; the other 11 pins stay green |
| B | `checkboxToggle`'s strict bounds relaxed to `<=` / `<=` | RED: `aClickInsideTheBoxTogglesItAndNowhereElseDoes` fails on BOTH boundary expectations (indices 2 and 5 toggle) |
| C | drop `.reversed()` from `apply`'s edit loop | RED on three pins, with the text it produces: `"say **th**is now"` and `"- on- e\ntwo"` — every edit after the first lands at an offset the first one moved |
| D | drop `view is MarkdownFormattable` from `target(in:)` | RED: `theTargetIsOneOfOurSurfacesAndOnlyOneOfOurs` fails — a plain editable `NSTextView` (what every field editor in the app is) becomes a legitimate ⌘B target |
| E | `wrapPlan`'s `allSatisfy` → `contains` | RED: `aMultiLineSelectionUnwrapsOnlyWhenEVERYPieceIsWrapped` fails — one bold line and one bare one would UNWRAP the bold instead of bolding the bare |

Each file was restored and its `md5` matched the pre-revert value
(`MarkdownActs.swift` → `b1c8f4cec53585ce23820eac37808351`;
`MarkdownEditing.swift` → `0fcbfe75c6d5210e48cdb76b0cf42bf0`). All five are
recorded as `DISCRIMINATING REVERT` doc comments on their pins, the house
convention (`TakesCardHeightTests`), so a future reader can re-run them.

---

#### Notes for the orchestrator

- **`notes/QUESTIONS.md` gains #49** — nine build-time product calls, bundled the
  way #48 was, each one line to change. **#50 is now the next free number.**
- **No proposal is owed**: no design fork emerged that the rulings did not answer.
  The two that came closest are recorded as #49(a) (per-line multi-line wrap vs
  refusing) and #49(g) (the hit target's width) rather than built both ways.
- **The morning bundle's items (ii)/(iii)/(v) are UNTOUCHED and still hers** — the
  checked-box text register, indented/nested list styling, and whether ⏎ at the end
  of a list line continues the list. (iv), the visible toolbar, is likewise
  unbuilt: this batch shipped the menu, the context submenu and the two chords,
  which is what the brief scoped.
- **No visual loop was run.** This batch adds acts, not looks: the only new pixels
  are menu rows and a context submenu, and the face those acts produce is batch
  2's, already looked at. The checkbox click has no appearance of its own.
- **One thing a reviewer should check by hand when the app is next open** (it is
  pinned by geometry, not by a real AppKit click): pressing ⌘B while the keyboard
  is in a take pane. The pins drive `MarkdownActs.apply` on a real `PaneTextView`
  and the registry on real contexts, but the last inch — AppKit routing a menu key
  equivalent to a first responder inside a board — is the one step no headless pin
  reaches.

### Orchestrator acceptance — batch 3 (2026-08-01)

- **Commit `2d69230` verified by own inspection:** 14 files, scoped
  as briefed — `MarkdownEditing` (pure Domain) + its suite, the
  `MarkdownActs` face + registry declarations + Format menu doors,
  the checkbox hit-test on both surface kinds, the helper rows the
  drift guard forced, the #49 QUESTIONS bundle, this plan's record.
  No `Sync/` lines, nothing near the join brain, no schema. The #49
  entry read in full — nine calls, each stated with its
  alternative, properly OPEN for the walk; #50 next free.
- **Counts by the orchestrator's OWN runs:** core "Test run with
  970 tests in 107 suites passed" · Mac "Test run with 1100 tests
  in 192 suites passed" · mobile "Test run with 14 tests in 4
  suites passed" — every implementer claim (970/107 · 1100/192 ·
  14/4 · spine 49/7) matched exactly. **Batch 3 ACCEPTED.**
- The five discriminating reverts, the sweep's ⌘B/⌘I-only outcome,
  and the first-responder targeting (revert D proving ⌘B would have
  typed `****` into the rename field) are accepted as recorded.
- Morning bundle extended: #49's walk (vi) + the take-pane ⌘B
  hand-check (vii).

## Batch 4 brief — links, Read rendering & the formatting lesson (a FRESH Opus implementer; self-contained)

**Read first, in full:** `CLAUDE.md`; this plan file TOP TO BOTTOM
(rounds 1–4 = the rulings; F-5's surface rule GOVERNS this batch;
the constitution binds; batch 2's record defines the tokenizer,
batch 3's the acts); the "Environment traps" section of
`notes/plans/phase-13c-book-forms-and-conversions.md` (binding)
PLUS the batch-1 standing rule (never address a Variorum instance
by process name — bundle id or PID only);
`notes/TEXTKIT2_NOTES.md` §1/§3.

**Scope: L10 + L11 + L12.** Still NOT in this batch — held for her
word, do not preempt: the checked-box register, indented/nested
lists, ⏎-continues-a-list, any visible toolbar, any change to the
#49 calls.

- **L10 — links behave (F-5's letter).** EDITING surfaces: ⌘-click
  on a link span (the tokenizer already carries the `url` range)
  opens the URL — `http`/`https` only in v1 (anything else is
  inert; PROVISIONAL, record it); a plain click stays a caret
  click, byte-untouched. Hover may show the URL as help text where
  cheap — optional, not owed. **Add the missing insertion act:**
  Format ▸ Add Link (registry-declared like batch 3's acts;
  menu-first, no chord unless the sweep gives one freely):
  selection → `[selection]()` with the caret between the parens;
  no selection → `[]()` caret in the brackets. Same pure-Domain
  computation discipline as `MarkdownEditing` (extend it, with
  tests).
- **L11 — Read mode renders markdown FULLY FORMATTED** (the F-5
  surface rule: display ≠ stored is safe exactly where no editing
  gesture maps clicks to offsets — Read is A43's reading surface).
  A PURE presentation transform in Domain: markdown → (display
  text, style runs, link map), tested on its own; markers hidden,
  headings/bold/italic/strike/code/lists/checkboxes styled, links
  plain-click openable. Apply it to the book's Read mode — BOTH
  faces (scroll and pages). **Pagination stays honest:** page
  slicing/extents measure the TRANSFORMED text (the (post,
  page-in-post) IDENTITY address rule from 13c K1 is untouchable —
  addresses never become indexes), and the transform runs lazily
  per rendered block (P1: cost ∝ what renders). Checkboxes in Read
  are DISPLAY ONLY (no toggling — Read edits nothing). If any
  other read-only surface tempts you (reading flow etc.), STATE
  where the transform could apply later — build only Read's two
  faces.
- **L12 — the formatting lesson + helper completeness.** The field
  guide gains a formatting lesson (the markdown vocabulary, ⌘B/⌘I,
  the Format menu, checkbox clicking, links incl. ⌘-click vs
  Read's plain click; `plan` and `seed` edited together so the
  walk test holds). The helper's formatting rows complete (the
  drift guard is the floor, not the ceiling — Add Link joins its
  keyless kin). NOTE in the record: this stales the seeded guide
  again; her ONE owed Restore-Tutorial click covers everything
  (13f + batches 1 and 4).
- **Suites:** `Sources/` is touched ⇒ ALL THREE at batch end,
  counts quoted from your own "Test run with N tests" lines.
  Baselines to match-or-beat: core 970/107 · Mac 1100/192 · mobile
  14/4. Tutorial spine green by TYPE name.
- The loop as batches 1–3 ran it: red-on-old by behavioral revert
  with checksums; PROVISIONAL-and-continue non-gating (recorded;
  product PROVISIONALs to `notes/QUESTIONS.md`, next free **#50**);
  STOP-and-report anything gating; batch record appended here;
  commit per convention, explicit paths; never push; never
  `/Applications`; her real-store instance never touched.

### Batch 4 record — links, Read rendering & the formatting lesson (2026-08-01, a fresh Opus implementer)

**Counts, from this session's own runs** (the "Test run with N tests" line, on the
final tree): core **986 tests in 108 suites** (from 970/107: +16 tests, +1 suite —
the reading transform, plus the link act's pins in the existing editing suite) ·
Mac **1117 tests in 193 suites** (from 1100/192: +17 tests, +1 suite — Read's rendering, the link click, the helper ceiling and the lesson pin) · mobile **14 tests in 4 suites** (unchanged) (run because `Sources/` was touched). The
tutorial spine ran green by TYPE name on the final tree (**50 tests in 7 suites**, from 49/7 — the formatting lesson's own pin). Zero
`Sources/VariorumCore/Sync/` lines; no schema; **zero lines anywhere near
`renderedText`, the export projections or the bridge's join brain** — verified by
`git status --short` (nothing under `Queries/`, `Operations/`, `Bridge/` or
`Features/Export`).

Scope was **L10 + L11 + L12**. Deliberately NOT started, per the brief: the
checked-box register, indented/nested list styling, ⏎-continues-a-list, any
visible toolbar, and every #49 call (untouched — #50 is a new bundle beside it,
never an edit to that one).

---

#### (i) L10 — links behave

**Three surfaces open links and they had to agree**, so there is ONE rule, ONE
guard and ONE door: `App/…/Features/Formatting/MarkdownLink.swift`.

**The scheme rule, v1: `http` and `https` only** (a build-time call — QUESTIONS
#50(a)). A link's target is ordinary text she typed, and a click must not hand an
arbitrary scheme to `NSWorkspace`: `file:` reaches the disk and the custom-scheme
space is every other app on the machine. Anything else is **INERT** — it still
renders as a link (the syntax is what it is) and the click simply does nothing,
so it behaves like the ordinary click it visually was. *(Measured while pinning
it, and recorded because it changes what the allowlist is actually load-bearing
for: `file:`, `mailto:` and `javascript:` are refused by the HOST check alone —
they have no host. What only the allowlist refuses is a well-formed
`ftp://…`/`vscode://…`, so the scheme pin's discriminating cases are those.)*

**⌘-click on the editing surfaces.** `MarkdownActs.openLink(at:in:)` +
`isLinkClick(_:)`, asked before `super.mouseDown` on both surface kinds
(`EditorTextView`, `PaneTextView`) for the same reason the checkbox click is:
`super.mouseDown` runs AppKit's selection-tracking loop and there is no "after"
in which to decline. The gesture is ⌘ alone, one click — so it never competes
with the plain caret click, the checkbox toggle, a double-click's word selection
or a ⇧-click's selection extension.

**Deliberately NOT gated on `isEditable`** (QUESTIONS #50(f)): opening a link is
not an edit, so the read tier and a sealed note follow one exactly like a live
editor does. That is the honest line — what made the modifier necessary was that
a plain click on an editing surface is already spoken for (it places the caret,
and the read tier's click SEEDS that caret's offset), not that the surface can be
written to. The lookup itself is a pure core function (`MarkdownEditing.link(inLines:at:)`),
and the whole SPAN counts — `(url)` included — because the dimmed address is
visibly part of the link and this gesture carries a modifier.

**The missing act.** Links were ruled IN at the sitting and shipped in batch 2
with a FACE but no DOOR: the only way to make one was to type the brackets.
`.formatAddLink` is now a registry capability like batch 3's seven, rendered by
the Format menu and the context submenu from the one `MarkdownActs.rows` table.
The edit computation is `MarkdownEditing`'s, and it joins the WRAP family rather
than becoming a third shape — a link's markers are simply asymmetric (`[` and
`]()`), so everything the family already decided applies unchanged: wrapped-ness
is read from the tokenizer, the toggle clears when the piece already carries it,
the selection's whitespace is trimmed. Three calls it needed of its own, all in
#50: the caret lands in the PARENS after a wrap and in the BRACKETS after the
caret gesture (c); it takes only the line the selection STARTS on (c); and on an
existing link it REMOVES the link with its address (d), which is the family's own
toggle rule and one ⌘Z from undone.

**The chord: none, and the sweep is the reason.** The platform's own add-link
chord is ⌘K, bound to Find Anything since Phase 13 (R15) — the one key a reader
would guess is the one key that is taken, and re-pointing it at a text act would
break the app's most-used door. Menu-first, beside the other five keyless acts
(#50(e) offers her one). The registry comment carries the sweep's reasoning.

---

#### (ii) L11 — Read renders markdown fully formatted

**The transform is PURE and lives in Domain**
(`Sources/VariorumCore/Domain/MarkdownRendering.swift`): text in, a DISPLAY
STRING plus semantic runs and per-line styles out. It never returns a font, a
colour or a point size — those are the app's, from the voice tokens (P-8) — and
it never writes anything. One tokenizer scan, one walk; cost ∝ what it is handed,
which is what lets both faces get P1 by rendering only what they draw.

**The shape, exactly:**

| Out | What it is |
|---|---|
| `text` | the display string — markers removed, list leads SUBSTITUTED |
| `runs` | ascending, disjoint character runs: `Emphasis` (bold/italic/strikethrough/code) + an optional `url` |
| `lines` | every line in order (blank ones included), each with a `LineStyle`: body · heading(1…3) · bullet · checkbox(checked:) |
| `links` | the runs carrying a `url` — a reading surface's hit map |

**Two decisions worth naming.** Line leads are **substituted**, not merely hidden
(`- ` → `• `, `- [ ]` → `☐`, `- [x]` → `☑` — QUESTIONS #50(b)): a bullet list
rendered without bullets reads as loose lines, which is not what "fully
formatted" means. And a checkbox in Read is **display only** — Read has no
editing gesture at all (her A43 ruling), so there is nothing to toggle and
nothing was wired.

**Everything the tokenizer already decided is inherited verbatim** rather than
re-decided: line-scoped by law (so nothing crosses a newline, and on an editor
surface nothing can cross a block seam), column-0 leads (so an indented list item
is still unstyled in v1 — the known limitation nested lists will need her word
to widen), the one nesting exception (`# **Big**` composes: a heading style AND a
bold run), and UTF-16 offsets that never split a grapheme.

**The PAGED face** (`PageComposer.compose`). The walk now builds **TWO strings
from ONE set of decisions**: the stored `body` — the ratified projection, still
pinned byte-equal to `Queries.renderedText`, which is what makes it the drift
guard on the join conditional — and the DISPLAY string the page draws. The join
is read off the STORED text (renderedText's own rule) and applied to both, so
there is still exactly one decision about separators.

**The transform runs PER BLOCK**, and that is the load-bearing choice. It is
equivalent to rendering the joined body (the transform is line-scoped and the
joins are line breaks), and it keeps every block's DISPLAY range known without a
mapping table — which matters because the callout indent rides those ranges, and
the display is now a DIFFERENT LENGTH from the stored text. That is the one real
arithmetic hazard this batch introduced, and its pin is the batch's sharpest
(revert D below).

**Pagination measures the TRANSFORMED text** — the framesetter is built over the
composed attributed string, so a page's visible range is a range of what is
drawn. **The 13c K1 address rule is untouched by construction:** a page is still
named `(post, page-in-post)`, `PageIndex.Position` is unchanged, and nothing here
is an index into a projection. What the transform does move is the ESTIMATE:
`PageEstimator` reads `Queries.blockExtents`' stored character counts, which now
slightly over-count a marker-heavy post. That is what the calibration loop is
for (it corrects from measured posts), and it is exactly the "estimates revise,
content never regresses" contract the domain was built on — recorded rather than
chased.

**The paged leaf's plain click.** A page is a `CTFrame` drawn into a view, so
there is no link handling to inherit: `PageFrameNSView.mouseDown` asks
`characterIndex(at:)`, which undoes the page's scale and asks CoreText itself
(`CTLineGetStringIndexForPosition` on the line the point landed in), then looks
the index up in the post's link map. **A real defect was found here by its own
pin** — see revert E.

**The SCROLL face** (`ReadingFlowView`). `FlowParagraph.paragraphs(of:)` renders
the post's projection once per realized row (inside the `LazyVStack`'s own task,
so the cost stays ∝ what materialized) and builds an `AttributedString` per
display line **by CONCATENATION** rather than by indexing — the runs are
ascending and disjoint, so walking them is exact and no `AttributedString.Index`
arithmetic can drift against UTF-16 offsets that came from elsewhere. Emphasis
rides as `inlinePresentationIntent` (SwiftUI's own markdown path), a heading is a
size, a list line sits in, and a link becomes a real `.link` attribute so
SwiftUI's `Text` opens it on a plain click — through an `OpenURLAction` carrying
the same scheme guard, so an address the app will not follow simply carries no
link attribute at all. The flow keeps its own paragraph rule unchanged: blank
display lines are dropped (the paged reader is the face that keeps stored spacing
byte for byte).

**One inch no headless pin reaches, and it is recorded rather than claimed:**
whether SwiftUI dispatches a link tap ahead of the enclosing "wake this post"
tap gesture on the flow's row. The failure mode if it does not is benign — the
click wakes the post for editing instead of opening the address, which is the
surface's standing behaviour — but it is a hand-check.

---

#### (iii) L12 — the formatting lesson, and the helper's ceiling

**The field guide gains "formatting"**, third in the WRITING chapter — after the
two lessons that teach what a block IS, because the vocabulary is about what a
line of text looks like. `plan` and `seed` were edited together, so
`theSeededBookMatchesTheLessonPlanExactly` holds.

**The lesson is written IN the vocabulary it teaches**, which under F-1 means its
stored text literally IS the syntax the reader is being shown: `**markdown**`
renders bold with dim stars, `## Headings are sizes` is a heading, three `- `
lines are a list, `- [ ]` and `- [x]` are boxes she can click, and
`[like this](https://apple.com)` is a link. Its last paragraph sends her to READ
and tells her what she will see there — and the pin follows her
(`theFormattingLessonIsWrittenInTheVocabularyItTeaches`): the same text, rendered
for reading, carries none of those spans' markers, shows `☐`/`☑` and `•`, and
yields the apple.com link.

**The helper's rows complete:** Format ▸ Add Link joins its keyless kin, and a
row states BOTH click rules — ⌘-click in a writing surface, plain click in Read
— because they differ by surface and cannot be inferred from a menu. A
dictionary entry for **link** says the same thing in prose, including the one
place the app deliberately shows something other than what is stored.

**And the guard above the guard.** The registry drift guard (L1) is the FLOOR: it
can only see acts that declare a chord, and six of these eight deliberately don't
— so a keyless door would be exactly as invisible as the whole 13f workspace was,
which is WT-1's finding. `theHelperNamesEveryFormattingDoorIncludingTheKeylessOnes`
is the ceiling: every formatting capability's verb must be findable in the
helper, case-insensitively (the helper writes in prose, and prose is the point of
a hand-written list).

**A RE-SEED IS OWED — and her ONE Restore-Tutorial click now covers everything:**
13f's vocabulary, batch 1's workspace lesson and stale-key correction, and this
batch's formatting lesson. One press of Help ▸ Restore Tutorial…, whenever she
next opens the app.

---

#### Red-on-old pins — five behavioural reverts, each verified and checksum-restored

| # | Revert | Result |
|---|---|---|
| A | `PageComposer.compose` appends the RAW block text to `display` (the pre-batch behaviour: the page draws the stored text) | RED: `thePageDrawsTheRenderedTextWhileTheBodyStaysTheStoredProjection` fails on its first expectation — the page shows `# A heading` and `**bold**` again. Four more L11 pins fall with it, which is the honest blast radius of the claim |
| B | drop `act.wrapsFirstLineOnly` from `MarkdownEditing.plan`'s line filter | RED: `addLinkTakesOnlyTheLineTheSelectionSTARTSOn` fails — a two-line selection mints `[one]()\n[two]()`, two empty links, only one of which could hold the caret. The other 28 core pins stay green |
| C | drop `openableSchemes.contains(scheme)` from `MarkdownLink.openable` | RED on BOTH sides: `onlyHttpAndHttpsAddressesAreOpenable` (`ftp://x.test/a` and `vscode://open` become openable) and `aFlowLinkIsClickableOnlyWhenItsSchemeIsOne` (an `ftp:` address becomes a live clickable link on a reading surface) |
| D | compute the block ranges from the STORED offsets (`let start = (composed as NSString).length`, as it was before this batch) | RED, exactly discriminating: `aCalloutStaysOnItsOwnBlockAfterAnEarlierBlockShortens` fails (the frame lands nowhere) and `theLinkMapNamesTheWordsItCoversEvenBehindATitle` loses the second link entirely |
| E | use `origins[i]` directly instead of rebasing onto the frame path's bounding box | RED: `aPointOnThePageResolvesToTheCharacterUnderIt` fails — a click on the first word resolves INTO the link |

Each file was restored and its `md5` matched the pre-revert value
(`MarkdownRendering.swift` is new this batch; `PagePaginator.swift` →
`b2e3b8e0139d92d0cd66d21305bc432a`, `MarkdownEditing.swift` →
`7de8fdfb2bf65d60307fcbff680033f8`, `MarkdownLink.swift` →
`765c2d5015a4ee09e5094172fa0b70d3`, `PagedReadView.swift` →
`a8aefa1ccf54e9b7843efd61e4a7ef37`). All five are recorded as
`DISCRIMINATING REVERT` doc comments on their pins, the house convention, so a
future reader can re-run them.

**Revert E was not hypothetical, and this is the batch's one real finding.** The
first draft of `characterIndex(at:)` compared `CTFrameGetLineOrigins`' output
directly against a point in the page's coordinate space. It is wrong:
**CoreText reports line origins relative to the frame PATH's bounding box**, not
to the page — so a click on the first word of a page resolved to the SEVENTH
character, and every link hit would have been off by the page's own margin. The
pin that caught it is the deliberately-discriminating half of the same test ("a
point at the line's left edge lands BEFORE the link"), added because a hit-test
pin that only asserts "some point finds the link" is satisfied by a sweep over a
wrong coordinate space. Fixed by rebasing onto `CTFrameGetPath(...).boundingBoxOfPath`,
which asks the frame rather than assuming the geometry.

**Two hygiene guards added while reverting, and why they are not decoration.**
Revert D's first execution took the TEST HOST DOWN instead of failing a pin: an
out-of-range range reached `addAttribute` (an `NSRangeException`) and, in the
pin, an out-of-range `NSString.substring`. Both write sites now carry the same
bounds guard every other attribute write in the app carries
(`MarkdownStyling.write`'s rule) — they cannot fire while the ranges are computed
on the string they name, and what they prevent is a crash rather than a wrong
look. The revert then failed cleanly, which is what a red-on-old pin is for.

---

#### Notes for the orchestrator

- **`notes/QUESTIONS.md` gains #50** — six build-time calls, bundled the way #49
  was, each one line to change. **#49 was not touched.** **#51 is now the next
  free number.**
- **No proposal is owed**: no design fork emerged that F-5 did not answer. The
  two that came closest are recorded as #50(c) (links act on one line) and
  #50(d) (Add Link removes an existing link) rather than built both ways.
- **The morning bundle's items (ii)/(iii)/(iv)/(v) are still UNTOUCHED and still
  hers** — the checked-box text register, indented/nested list styling, the
  visible toolbar offer, and whether ⏎ continues a list. This batch deliberately
  did not preempt any of them; note that (ii) now has a second surface to answer
  for, since a checked box in Read is a `☑` glyph whose TEXT is styled like any
  other line.
- **One hand-check, for whenever the app is next open:** click a link in a book's
  Read ▸ scroll face. The paged face's click is pinned through real CoreText
  geometry; the flow's rides SwiftUI's own link dispatch, and whether it wins
  against the row's "wake this post" tap gesture is the one inch no headless pin
  reaches. (If it loses, the click wakes the post — benign, and one line to fix
  by moving the wake gesture.)
- **No visual loop was run.** The new pixels are Read's two faces, and the
  honest way to look at them is in her own book with her own voice — a
  screenshot of a synthetic page would tell her less than one press of ⌘5 will.

### Orchestrator acceptance — batch 4 (2026-08-01)

- **Commit `a9ca0d2` verified by own inspection:** 22 files, scoped
  as briefed — `MarkdownRendering` (pure Domain transform) + suite,
  the paginator's two-strings-from-one-decisions shape (App-side;
  NOTHING under `Queries/`/`Bridge/`/export paths — name-list
  confirmed), `MarkdownLink`'s one-place scheme rule, Add Link in
  the wrap family, the formatting lesson + helper ceiling pin, the
  #50 QUESTIONS bundle (read in full — six calls, properly OPEN;
  #51 next free). No `Sync/` lines, no schema.
- **Counts by the orchestrator's OWN runs:** core "Test run with
  986 tests in 108 suites passed" · Mac "Test run with 1117 tests
  in 193 suites passed" · mobile "Test run with 14 tests in 4
  suites passed" — every implementer claim (986/108 · 1117/193 ·
  14/4 · spine 50/7) matched exactly. **Batch 4 ACCEPTED.**
- The CoreText origin-space finding (line origins relative to the
  frame PATH's bounding box — caught by the deliberately-
  discriminating half of its own pin), the five reverts, and the
  house bounds guard on both derived-range write sites are accepted
  as recorded.
- **Morning bundle extended:** **(viii)** #50's walk (links + Read's
  six calls); **(ix)** a second hand-check — click a link in Read's
  SCROLL face (whether SwiftUI's link dispatch wins against the
  row's wake-the-post tap; benign either way, one line to move the
  gesture if not); and the note that item (ii), the checked-box
  register, now has a SECOND surface to answer for (Read's ☑ line).

## Batch 5 brief — the kickoff sweep (a FRESH Opus implementer; self-contained; INVESTIGATION-FIRST)

**Read first, in full:** `CLAUDE.md`; this plan file TOP TO BOTTOM
(the constitution binds; the batch records tell you what this phase
has already touched); the "Environment traps" section of
`notes/plans/phase-13c-book-forms-and-conversions.md` (binding)
PLUS the batch-1 standing rule (bundle id `io.lduarte.Variorum.debug`
or PID only — NEVER process name; the author's real-store instance
is NEVER touched, quit, killed, or sent events); the TWO
`notes/KnownIssuesAndTechDebt.md` rows this batch owns (the
shell-redo flaky pin; the windowless-launch + quit-from-windowless
rows) VERBATIM; and the 13f plan's "THE CLOSEOUT EXECUTED" section
(`notes/plans/phase-13f-workspace.md`) — the windowless
investigation's full prior record, including the AX-reads-the-
current-Space-only vantage trap (use CGWindowList for window
censuses, never AX counts).

**Scope: L13 — two traces. The hallucination guard binds HARD:**
no fix without a self-traced concrete mechanism; a trace that does
not conclude is recorded honestly (what was tried, what was ruled
out, the surviving candidates) and the KnownIssues row is updated
rather than closed. DO NOT patch on suspicion.

- **(i) The shell-redo flaky pin**
  (`theShellRedoActionRunsThroughTheRunnerAndReports`, 13c-era
  shell-redo status machinery): trace the status-delivery TIMING.
  One recorded failure (2026-07-30, "Redid" never reached the
  status text), clean on every run since — so REPRODUCE FIRST if
  you can (a loop of the suite / induced scheduling pressure); if
  the mechanism is found, fix it with a DETERMINISTIC red-on-old
  pin (the flake reproduced reliably under the pin's conditions);
  if not, record the ruled-out space and leave the row updated.
- **(ii) The windowless launch + quit-from-windowless hang** (the
  `openApplication` path presents ZERO windows on any Space;
  REOPEN mints the window — the standing recovery; quit from
  windowless does not complete, clean with a window, verified
  twice at the 13f closeout): trace the mechanism INSIDE the app —
  scene presentation vs. launch-event handling. Work on the DEBUG
  build (dev store, `io.lduarte.Variorum.debug`) launched by the
  `openApplication` path; CGWindowList for censuses; her instance
  untouched. A fix (e.g. an explicit window-ensure on launch, or
  whatever the trace actually supports) lands only WITH the traced
  mechanism and a pin/procedure that discriminates; otherwise the
  characterization is deepened on the row.
- **Suites:** likely App-target only; if `Sources/`/`Shared/` is
  touched, mobile runs too. Full suites at batch end regardless,
  counts quoted. Baselines to match-or-beat: core 986/108 · Mac
  1117/193 · mobile 14/4. Tutorial spine green by TYPE name.
- The loop: red-on-old by behavioral revert where a pin CAN go red
  (lifecycle timing may honestly be procedure-verified — say so
  explicitly, the model-layer honesty rule); batch record appended
  here (the traces in full — a ruled-out candidate is a result);
  KnownIssues rows updated to match reality (resolved, or deepened
  with the new trace); commit per convention, explicit paths;
  never push; never `/Applications`.

### Batch 5 record — the kickoff sweep (2026-08-01, a fresh Opus implementer)

**Counts, from this session's own runs** (the "Test run with N tests" line, on the
final tree): core **986 tests in 108 suites** (unchanged — nothing under
`Sources/` or `Shared/` was touched, by design) · Mac **1121 tests in 194
suites** (from 1117/193: **+4 tests, +1 suite** — one new redo pin and the
three-pin quit-door characterization suite) · mobile **NOT RUN and not owed**
(`Sources/`/`Shared/` untouched; baseline 14/4 stands). The tutorial spine ran
green by TYPE name on the final tree (**50 tests in 7 suites**). Zero
`Sources/VariorumCore/Sync/` lines; no schema; **the whole diff is test code** —
`git status --short` shows four files, all under `VariorumTests/`.

**This was an INVESTIGATION batch and it ends with one trace CLOSED and one
trace OPEN.** Trace (i) found its mechanism, fixed it at the source, and left a
deterministic pin. Trace (ii) did not reproduce in **32 launches across six
arms and two trees**; what it produced is a ruled-out space, two refuted
hypotheses with arithmetic, a characterization suite, and a reproduction
toolkit — the row is DEEPENED and re-owned, not closed. No line of product
code was written on suspicion.

---

#### (i) THE SHELL-REDO FLAKY PIN — mechanism found, fixed, deterministically pinned · **RESOLVED**

**The mechanism, traced by reading the three files it spans** (`ShellActions`
→ `OperationsRunner` → `UndoStack`), then proved by measurement below:

`ShellActions.structuralRedo()` fires a detached `Task { @MainActor }`. Inside
it, the re-apply runs through `session.runner.run { … }` — `OperationsRunner`
is an **actor**, so that is a hop OFF the main thread. `UndoStack.redo(with:)`
runs the re-apply, then moves BOTH stacks under its `NSLock`, then calls
`notifyChange()`, then returns. Only after that return does the door's
continuation resume ON THE MAIN ACTOR and call `status.speak("Redid: …")`.

So the two signals are strictly ordered:

| Signal | Where it becomes true |
|---|---|
| `stack.redoDepth == 0` / `stack.depth == 1` | inside `UndoStack.redo`, on the runner's thread |
| the store shows the re-applied rows | same place, one step earlier |
| `status.current?.text == "Redid: …"` | **later** — after the actor hop back to the main actor |

The pin polled `redoDepth != 0` and asserted the STATUS. `redoDepth` is read
under the same lock the mutation takes, so it flips the instant the runner
mutates — and the poll loop's own 1 ms wake can land in the window between
that flip and the door's main-actor continuation. Under a busy main actor (a
full parallel suite run — exactly where the one recorded failure happened,
2026-07-30) the window widens. **The defect is the PIN's, not the door's:**
the door does the right thing in the right order, and the report is a
transient toast; nothing about the product changed or needed to.

**Organic reproduction: ATTEMPTED AND FAILED, and that is recorded rather than
skipped** — 27 runs of `BlockDeletionAndRedoTests`, all green: 15 idle, then 12
with 16 spinning workers on 12 cores (load average verified above 30). The
window is microseconds wide; a shotgun will not find it.

**Deterministic reproduction — hold the window open.** `notifyChange()` fires
on the mutating thread, INSIDE `redo(with:)`, after both stacks have moved and
before the call returns. So a change observer that sleeps blocks the runner,
which blocks the door's continuation, while `redoDepth` already reads 0. That
is the same window at 150 ms instead of a few microseconds — no product change,
no fake seam, the real ordering. The new pin
`theRedoReportArrivesAfterTheStackHasAlreadyMoved` installs it for exactly one
act and takes it down again.

**RED-ON-OLD, by behavioural revert, verified:** with the new pin's wait
replaced by the OLD polling shape (`for _ in 0..<2000 where stack.redoDepth != 0`)
and everything else untouched, the run is

> `✘ Test theRedoReportArrivesAfterTheStackHasAlreadyMoved() recorded an issue at BlockDeletionAndRedoTests.swift:641:13: Expectation failed: (harness.session.status.current?.text.contains("Redid") → false) == true`
> `✘ Test run with 29 tests in 1 suite failed after 0.289 seconds with 1 issue.`

— exactly discriminating (one test, one expectation, the other 28 green), and
it failed on EVERY execution rather than on one in thirty. File restored and
`shasum -a 256` matched the pre-revert value
(`BlockDeletionAndRedoTests.swift` → `2cb3577f815d0a249244144595ca509c99883ee7ba864fdf16681e3c35e22789`).
The revert is recorded as a `DISCRIMINATING REVERT` doc comment on the pin, the
house convention, so a future reader can re-run it.

**The fix, and the rule it encodes: poll the LAST signal in the chain, never an
earlier one.** `theShellRedoActionRunsThroughTheRunnerAndReports` now waits on
the status it asserts (`settleUntilRedoIsReported`, a bounded async poll — the
standing never-a-sync-RunLoop-pump rule) and then asserts the stack, the store
and the report together.

**THE SWEEP — three latent siblings of the same class, found and fixed.** The
mechanism is "an act whose store/stack effect lands inside `runner.run` and
whose report lands after it", so every pin that waits on the early signal and
asserts the late one is the same bug asleep. Swept all 32 `status.current`
assertions in `VariorumTests/`; four were in the class, three of them latent:

| Pin | Waited on | Asserted | Now waits on |
|---|---|---|---|
| `BlockDeletionAndRedoTests.theShellRedoActionRunsThroughTheRunnerAndReports` | `redoDepth == 0` | "Redid" | the status |
| `DestructiveUndoWarningTests.redoNeverAsks` | `redoDepth == 0` | "Redid" | the status |
| `DestructiveUndoWarningTests.approvingRunsTheOrdinaryUndoWithItsInsuranceIntact` | `depth == 0` | "Undid" | the status |
| `CommandRoutingTests.sealFromAHandlerLessModeActsWithoutAWrongRefusalFlash` | the STORE (`locked == true`, written inside `runner.run`) | "Sealed" | the status |

In each case the stack/store assertion was KEPT, moved after the wait — so the
pins prove strictly more than before, not less.

**Deliberately NOT changed, each checked rather than assumed:**
`StarDoorTests.theSixthStarSpeaksTheOperationsOwnRefusal` (`StarsModel.toggle`
is `async` and speaks INSIDE the awaited call, so the caller's `await` covers
it); `CommandRoutingTests.sealWithNoPostOpenStillSpeaksTheHonestNote`
(`toggleSeal`'s no-post branch speaks synchronously, before any `Task`);
`TutorialWalkTests`' restore pin (`shell.pendingSelection` and `status.speak`
are adjacent main-actor statements with no suspension between them). Three
ruled-out candidates are three pins not churned.

**Stability check after the fix:** 8 consecutive runs of the three touched
suites, all green (36/3 each time).

---

#### (ii) THE WINDOWLESS LAUNCH + THE QUIT-FROM-WINDOWLESS HANG — **NOT REPRODUCED; the row is DEEPENED, not closed**

**32 launches. Zero windowless. Six arms, two trees.** Every launch was
censused with `CGWindowListCopyWindowInfo([.optionAll], …)` filtered by PID —
`.optionAll`, so windows on other Spaces and off-screen windows are counted
(the 13f record's vantage trap is about AX, and it is avoided by construction
here; a throwaway `census` tool built for this batch prints layer, on-screen
flag, alpha and bounds per window). All arms on the **DEBUG** build
(`io.lduarte.Variorum.debug`, dev store); her `/Applications` instance was
never addressed, and every instance was identified by PATH or PID, never by
process name (the batch-1 standing rule).

| Arm | Launches | Windowless |
|---|---|---|
| `open <path>` (current tree) | 7 | 0 |
| `NSWorkspace.openApplication`, `activates = true` | 2 | 0 |
| `NSWorkspace.openApplication`, `activates = false` | 2 | 0 |
| `open` under heavy scheduling pressure (20 spinners on 12 cores, load avg 33) | 8 | 0 |
| a SECOND instance of the same bundle id (`open` then `open -n`) | 2 | 0 |
| **the 13f-CLOSEOUT TREE ITSELF** (worktree at `74ddf48`, Debug, isolated DerivedData) | 6 | 0 |
| latency trials (below) | 5 | 0 |

**The worktree arm is the one that matters most, and it is the batch's
strongest single result.** The tree the 13f closeout tested — commit `74ddf48`,
the phase's sealing commit — built Debug into its own DerivedData and launched
six times, presents a window every time. So the behaviour is **not a property
of the tree**: 13g's batch-1 window changes (`.toolbar(removing: .title)`,
`.windowToolbarStyle(.unifiedCompact)`, the dead sidebar `Section`) did not
"fix" it, and the 13f-closeout Debug arm does not reproduce today either. What
varies is the environment or the state, not the code.

**Two hypotheses REFUTED with measurement, not argument:**

1. **"The census ran too early — the window is merely late."** Measured
   launch-to-first-window on the Debug build over five trials:
   **+0.58, +0.58, +0.60 s** to the first layer-0 window, **+0.54, +0.83 s** to
   the first ON-SCREEN one. A census at three seconds — let alone the seven this
   batch used — cannot miss it.
2. **"A large store blocks the main thread before any window exists."** This one
   was worth taking seriously: `AppBootstrap` opens the store SYNCHRONOUSLY in
   the App struct's `@State` initializer, so nothing can present until it
   returns. But the arithmetic kills it: the dev store this batch measured
   against is **36 MB** and still reaches a window in 0.6 s, while her real
   store — read-only `ls`, never opened — is **4.5 MB**, an order of magnitude
   smaller. Her launch cannot be slower than the one measured.

**Read-side results (a ruled-out candidate is a result):**

- **Nothing in the app closes, hides or orders out a window.** Swept
  `Variorum/` and `Shared/` for `dismissWindow`, `.close()`, `orderOut`,
  `setIsVisible`, `NSApp.hide`, `handlesExternalEvents`, `isRestorable`,
  `restorationBehavior`: every hit is an `openWindow` door or the quick-note
  pad's own model call. There is no code path that could suppress the main
  window.
- **The saved-state directory for the Debug build is EMPTY** even after clean
  quits (`NSQuitAlwaysKeepsWindows` is unset ⇒ close-windows-on-quit), so
  restoration is not in play on this build at all — consistent with 13f's own
  fresh-state arm.
- **THE QUIT DOOR IS RULED OUT for the windowless-LAUNCH state, and this is
  now pinned** (`VariorumTests/QuitDoorTests.swift`, three tests). Reading
  `VariorumAppDelegate.applicationShouldTerminate` against
  `AppSession`: the quit registry gains an entry **per OPENED POST**
  (`AppSession.autosave(forPost:)` registers one), not at session birth — and a
  windowless launch never ran `RootView.onAppear`, so the delegate holds no
  session at all. Both facts land in the same branch: `pendingEditor == nil`
  and `registry?.isEmpty != false` ⇒ **`.terminateNow`, synchronously, with no
  Task and nothing awaited.** The app's own quit door cannot be what leaves
  such a process alive.

**Surviving candidates, stated as candidates:**

- **The `.terminateLater` road has no deadline.** Once ANY post has been opened,
  the door returns `.terminateLater` and replies from a `Task` that awaits the
  focused editor's finalize and every registered flush. A flush that never
  returns wedges ⌘Q forever, with no timeout and no fallback. This does NOT
  explain a windowless *launch* (no post was opened), but it does fit a
  windowless state reached by CLOSING windows in a session that had been used —
  which is a different road to the same look. Pinned by its precondition
  (`openingOnePostPutsTheDoorOnTheAsynchronousRoad`); deliberately NOT driven,
  because driving it would call `NSApp.reply(toApplicationShouldTerminate:)`
  inside the test host and a pin must not be able to quit the runner. **No fix
  was written**: no concrete hanging flush was traced, and a deadline added on
  suspicion is exactly what the hallucination guard forbids.
- **One measured oddity, recorded because it is a real datum and unexplained:**
  `tell application id "io.lduarte.Variorum.debug" to close every window`
  returned **"AppleEvent timed out (-1712)"** and the window stayed open, while
  `quit` on the same instance answered in **0.08 s** and the process died. So
  the app answers the `quit` event promptly and does not answer the standard
  suite's `close`. Whether that is SwiftUI's standard-suite coverage or
  something in this app is unknown; it is the nearest live thread to 13f's
  sibling observation and the first thing a next attempt should pull.
- **Environment/state**, which is where the evidence now points: something about
  the machine's or the instance's state at the 13f closeout, not the code. What
  differed and could not be re-created here: the screen was **locked** for every
  measurement in this batch (the window appeared anyway, so lock is not the
  trigger — but its opposite could not be tested), Spaces arrangement and the
  frontmost app could not be varied, and the **RELEASE configuration is out of
  reach in this session by design**: `StoreLocation.resolve()` gives a release
  build `.real` with no opt-out, so launching one would put a second writer on
  her live store while her instance runs. Not done, and not to be done while
  her app is up.

**THE REPRODUCTION TOOLKIT, so the next session does not rebuild it.** Two
throwaway Swift tools were written for this batch (kept out of the repo — each
is ~20 lines and reproduced by this description): a **census** —
`CGWindowListCopyWindowInfo([.optionAll], kCGNullWindowID)`, filter by PID,
print `layer / onscreen / alpha / bounds / name` per window plus a total; and a
**launcher** — `NSWorkspace.shared.openApplication(at:configuration:)` with
`activates` switchable. Never AX, never `pgrep` by name.

**WHAT THE NEXT ATTEMPT SHOULD DO, and it is the opposite of what this one
did:** stop trying to summon it. A cold reproduction has now failed 32 times
across two trees and six arms. **Capture it the next time it occurs** — the
state is recognizable from outside (a running Variorum with no window on any
Space) and the recovery (a Dock click) is one gesture away, so the sequence is:
`sample <pid> 5` FIRST (a stack of every thread answers "is the main thread
blocked, and in what" in one shot), then the CGWindowList census, then
`lsappinfo info -only StatusLabel,pid <pid>`, then try `quit` and time it, and
only then click the Dock. That capture is worth more than another thirty cold
launches.

---

#### Notes for the orchestrator

- **`notes/QUESTIONS.md` untouched — #51 remains the next free number.** Nothing
  in this batch is a product ruling; the two dispositions are a fixed pin and a
  deepened row.
- **KnownIssues, both rows updated to match reality:** the shell-redo flaky row
  is **REMOVED** (resolved — mechanism traced, fixed at its source, three latent
  siblings fixed with it, a deterministic pin left behind); the windowless row
  is **REWRITTEN** with this batch's ruled-out space and capture-first
  instruction, and **re-owned to 13e's kickoff sweep** (a phase number — never a
  blank owner; the same hand-off shape 13f used to give it to 13g). **L16's
  closeout duty inherits it:** the 13e plan this phase's closeout authors must
  name it beside W26.
- **No product code was touched.** The whole diff is `VariorumTests/`: three
  pins re-pointed, one new pin, one new three-pin characterization suite. If a
  reviewer wants the shortest possible reading, it is
  `BlockDeletionAndRedoTests.swift`'s two redo tests and
  `QuitDoorTests.swift`.
- **No visual loop was run** — this batch adds no pixels.
- **Her instance was never touched:** verified by PID at the start (24191,
  `/Applications/Variorum.app`, one on-screen window) and at the end, unchanged.
  The worktree and its isolated DerivedData were removed; `git worktree list`
  shows only the repo.

### Orchestrator acceptance — batch 5, the kickoff sweep (2026-08-01)

- **Commit `d5546ba` verified by own inspection:** test code and
  records ONLY (four test files + the two notes files) — exactly
  what "the defect is the pin's, not the door's" should look like.
  No product code, no schema, zero `Sync/` lines.
- **Counts by the orchestrator's OWN runs:** Mac "Test run with
  1121 tests in 194 suites passed" — the claim matched exactly.
  Core untouched by construction (nothing under `Sources/` in the
  diff) — the standing own-run 986/108 is the acceptance number;
  mobile not owed.
- **Trace (i) ACCEPTED — the flaky-pin row RESOLVED:** the
  mechanism (the stacks move under the lock strictly before the
  actor-hop continuation speaks the status) traced across three
  files, made deterministic by holding the real window open, red
  on the old polling shape on EVERY run; the 32-assertion sweep's
  three latent siblings fixed the same way. KnownIssues row
  removed — verified gone.
- **Trace (ii) ACCEPTED — deepened, honestly not closed:** 32
  launches / six arms / two trees / zero windowless, every census
  CGWindowList-by-PID; the ruled-out space (incl. the
  13f-closeout tree itself — the behaviour is NOT tree-borne) and
  the three surviving candidates recorded on the row; re-owned to
  **13e's kickoff sweep, capture-first** (sample → census →
  lsappinfo → timed quit → only then the Dock click); L16 carries
  the duty beside W26. The locked-session caveat (every arm ran
  under `CGSSessionScreenIsLocked = 1`; the unlocked opposite
  untested) is on the row where it belongs.
- **Batch 5 ACCEPTED. The overnight autonomous arc is COMPLETE** —
  batches 1–5 shipped and accepted, counts core 986/108 · Mac
  1121/194 · mobile 14/4 · spine 50/7, all orchestrator-own-run.
  Everything further waits on the author: the morning bundle
  (items i–ix + the L5 word), the #49/#50 walks, any
  sitting-driven batches, then the ONE Fable cold review
  (standard ladder), the TEXTKIT2 §5 re-run (L15), and the
  closeout that authors 13e's plan (L16 — W26 + the windowless
  capture-first item both named).

### Round 5 — 2026-08-01, her morning (the L5 word; a new roadmap row; her ergonomics list; one crash)

Her message, verbatim:

> hi, i closed my app so you can refresh it. but i'm kind of curious
> - what do you mean hold with the shipped mode-label? for the stick
> pane modes ruling? I think that having a takes projection first
> would be fine - i honestly don't think that lenses or compare need
> to be a side by side mode option for now or potentially ever.
> takes is more of a main editing space so it's more important to
> see that rpeserved. i'm also ready to hear the questions out. i
> think that i also need you to add something to the plan / roadmap
> for a new phase 13 phase where I handle the deletion of items
> better. I think that some kind of "true delete" should be added
> for posts (going to a Trash for 30 days before really deleting),
> because I already have posts in my library i don't want to have.
> that seems like an obvious pre-ship feature. and also, I think
> that you need to be able to see the archived blocks (or deleted
> blocks) that are associated with a particular post, because just
> going to the library you get a little lost. separately from that
> phase, there are a couple little ergonomic improvements that I
> want: 1. stop showing the comment + to the right completely, it
> conflicts with the take icon. I also think comments should appear
> on the left since there's so much machinery going on on the right
> already. 2: stop showing the actual ID of the block (1R3D9145 as
> an example), and rather than blk, show "block 1/1". there's also
> a bug where clicking on the "show scraps button" just fully
> crashed the application and nothing appears. I have that variorum
> stack trace of the crash if you need it. I also want to make a
> different view in the library that is more similar to the apple
> notes view where you can see the first little bit of text:
> [screenshot — the Apple Notes list: title, date, snippet, folder].
> I also think that if you click on "Untitled" it lets you edit the
> text field there and then rather than bringing up a smaller
> little window to edit. I also want better ergonomics on the tags
> - I'm open to suggestions on how to achieve that, but I like it
> when there are little tag cards that are different colors and
> it's easier to add and remove them and they might belong on the
> top bar. I also feel like the bottom bar is looking a little bit
> overly crowded - i'm open to suggestions on how to handle this
> honestly but i feel like not all of these items are needed? I'm
> thinking something where there could be groupings on the bottom
> of settings and clicking on them brings all the options out in a
> slide - almost like tab groups in a brwoser? so there could be a
> block menu for divide, extract, make block, and merge. (fast
> users will use the hotkeys if they want). I think newlines make
> blocks earns its place, I think the takes button earns its place.
> i think tags should move anyway. i think +below and -block should
> maybe be in a block meny? again, I'm overall open to suggestions
> on this but I feel like it looks just a little bit cluttered.
> I'll have to do the look / feel calls after I have the updated
> app. I also think that we should maybe just make "Untitled" save
> with the actual date as the name - I think it looks nicer and
> then even if someone never titles things, it's more of a log look
> than 500 untitled things. it looks nice in the journal to click
> into it and see the dates but then you click on the journal and
> it's untitled - i do think you sohuld be able to rename it from
> the date, but auto date name is better than just "Untitled" I
> think. i don't want the title to feel too forced - belonging in a
> book should be enough for most small notes, but Untitled looks
> ugly. opening in a new window seems to be working pretty well but
> there is this bug where the top of it i couldn't scroll to (where
> it says Untitled) and it was cut off [screenshot — the note-only
> window, title clipped under the context bar]. I also think there
> should be a small "modes" thing in the upper right of a new
> window, so you can still switch to write / takes / etc. i also
> like the idea of quicknotes automatically adding a quicknote tag
> and there being a smart "quicknotes" book that's just based on
> tag, so if you remove the tag it leaves the book.

**Dispositions, point by point:**

- **The refresh: EXECUTED this round** — zero instances verified,
  fresh WAL-safe backup `variorum-backup-2026-08-01-211545`
  (integrity ok), Release build → `/Applications`.
- **The mode-label question: ANSWERED** (batch 1's interim — the
  un-live pane shows a small line naming the mode it holds while
  still rendering plain read text; "hold" meant keep only that).
- **R5-1 (RULED — the L5 word): (b) TAKES-FIRST.** Her words:
  "having a takes projection first would be fine - i honestly
  don't think that lenses or compare need to be a side by side
  mode option for now or potentially ever. takes is more of a main
  editing space so it's more important to see that rpeserved."
  The read-only TAKES projection builds (batch 6); Lenses/Compare
  (and Canvas/Blocks) projections are DELIBERATELY NOT BUILT — her
  uncertainty preserved ("potentially ever" is not "never"): an
  un-live pane in those modes keeps the mode label + read text.
- **R5-2 (NEW ROADMAP ROW, her instruction): the DELETION phase**
  — added to the master plan as row 13j (her words on the row):
  a "true delete" for posts — a TRASH holding 30 days before
  really deleting ("an obvious pre-ship feature"; she already has
  library posts she doesn't want) — and per-POST visibility of the
  archived/deleted blocks associated with a particular post ("just
  going to the library you get a little lost"). Recorded
  interaction for its kickoff sitting: physical purge is the
  Tombstone-GC KnownIssues row's territory (sync-aware horizon,
  owner 12) — the two must be designed together, not separately.
- **R5-3 (RULED, ergonomics): the comment "+" on the right goes
  ENTIRELY** (conflicts with the take icon) **and comments move to
  the LEFT margin** ("so much machinery going on on the right
  already"). Batch 6.
- **R5-4 (RULED, ergonomics): the block line drops the raw ID and
  "blk" — it reads "block 1/1".** Batch 6.
- **R5-5 (BUG, crash — trace IN HAND):** clicking "show scraps"
  (the Snippets section door) crashes the app. The orchestrator
  pulled both `.ips` reports from her DiagnosticReports directly
  (2026-08-01 14:52:36/37, the /Applications 13f build): an
  NSException thrown from AppKit's
  `_postWindowNeedsUpdateConstraints` DURING `NSHostingView.layout`
  (a SwiftUI `graphDidChange → setNeedsUpdate` re-entry inside the
  layout pass — the update-constraints feedback-loop guard;
  `NSApplication _crashOnException` terminates). The same FAMILY as
  the b6dae25 chrome-layout class. Batch 6 traces the concrete view
  on HEAD (the repro is her click) and fixes with a red-on-old pin.
- **R5-6 (RULED, build): the Apple-Notes-style Library list view**
  — a view mode showing title · date · the first bit of text ·
  book, per her screenshot. Snippet derived READ-TIME and BOUNDED
  (never stored — the no-denormalization rule; cost ∝ listed rows,
  the windowed-observation discipline). Batch 6.
- **R5-7 (RULED, build): inline title editing** — clicking
  "Untitled" (or a title) edits in place; the little rename window
  retires from that path. Batch 6.
- **R5-8 (PROPOSAL WANTED, hers to nod): tag ergonomics** — she
  likes colored tag cards, easier add/remove, "might belong on the
  top bar". Orchestrator proposal offered this round (chips on the
  context bar with stable per-path colors, popover add with
  autocomplete, ✕ removes; tags leave the bottom bar). Held for
  her word.
- **R5-9 (PROPOSAL WANTED, hers to nod): the bottom bar regroup**
  — her direction: grouped slide-outs ("like tab groups in a
  brwoser"); a block menu for divide/extract/make block/merge
  (+below/−block "maybe"); newlines-make-blocks EARNS ITS PLACE;
  the takes button EARNS ITS PLACE; "tags should move anyway."
  Orchestrator proposal offered this round. Held for her word.
- **Look/feel calls (bundle items i–v): DEFERRED by her** until
  the refreshed app is in hand. Carried.
- **R5-10 (PROPOSAL WANTED, hers to nod): untitled notes show
  their DATE** — her want: "auto date name is better than just
  'Untitled'"; renameable from the date; titles never forced.
  Orchestrator recommends the DISPLAY-RULE shape (untitled renders
  its date everywhere; `title` stays NULL — fixes every EXISTING
  untitled note for free, no denormalized copies) over
  stamp-title-at-creation. Held for her word.
- **R5-11 (BUG): the note-only window's top is unreachable** — the
  title area can't be scrolled to, cut off (her screenshot, the
  13f build). Batch 6 traces on HEAD (the L3/L4 title-band change
  may interact — verify, not assume).
- **R5-12 (RULED, build): a small MODES switcher in the note-only
  window's top right** (write/takes/etc. reachable there). Batch 6.
- **R5-13 (RULED in direction, details to nod): quick notes
  auto-tag `quicknote`; a smart "Quicknotes" book keyed on the tag**
  ("if you remove the tag it leaves the book" — exactly smart
  membership's semantics). Self-creation shape offered for her nod
  (the #37(iii) Journal precedent). Batch 7 on her word.

**Routing:** batch 6 (spawning this round) = R5-1's takes
projection + R5-3 + R5-4 + R5-5 crash + R5-6 + R5-7 + R5-11 +
R5-12. Batch 7 (after her nods) = R5-8 tags + R5-9 bottom bar +
R5-10 date display + R5-13 quicknote book. The #49/#50 walk was
delivered in the same reply; defaults stand unless she flags.

## Batch 6 brief — her morning list, the ruled set (a FRESH Opus implementer; self-contained)

**Read first, in full:** `CLAUDE.md`; this plan file TOP TO BOTTOM —
round 5 is the ruling set you build (R5-1, R5-3…R5-7, R5-11,
R5-12); the P-1…P-9 constitution binds; the "Environment traps"
section of `notes/plans/phase-13c-book-forms-and-conversions.md`
(binding) PLUS the batch-1 standing rule (bundle id
`io.lduarte.Variorum.debug` or PID only — NEVER process name; the
author's real-store instance is likely RUNNING and is never
touched); `notes/TEXTKIT2_NOTES.md` §1/§3.

**Scope — eight ruled items; nothing from the batch-7 nod set
(tags, bottom bar, date display, quicknote book):**

- **(1) R5-1 — the read-only TAKES projection** (her L5 word:
  takes-first; Lenses/Compare/Canvas/Blocks projections
  deliberately NOT built). An un-live pane whose remembered mode is
  Takes renders a read-only card list over the fan projection — NO
  authority owner, NO routed-command handler (the `SpreadBookView`
  → `ReadPostView` precedent is the shape; batch 1's L5 record
  names the constraint set). Dimmed/read styling; click behavior
  unchanged (the pane's body click focuses — batch 1's
  `PaneFocusCatcher` already owns that). P3: exactly one live
  surface, ever — the projection extends nothing beside
  `PaneTextAuthority`. P1: cost ∝ visible cards.
- **(2) R5-3 — comments move LEFT; the right-side comment "+"
  goes entirely** (it conflicts with the take icon). The margin
  comment presentation renders on the LEFT margin; the standing
  comment doors (the bottom-bar/menu/shortcut doors, ⌘⇧')
  remain — this is a PLACEMENT change, not a doors change.
- **(3) R5-4 — the block line reads "block 1/16"**, no raw ID, no
  "blk". (The read-time ordinal machinery is 9d's; only the
  rendered string changes.)
- **(4) R5-5 — the show-scraps CRASH.** Trace in hand (round 5's
  record): her click on the Snippets door threw an NSException
  from `_postWindowNeedsUpdateConstraints` DURING
  `NSHostingView.layout` — a SwiftUI update re-entering the layout
  pass (the update-constraints feedback-loop guard;
  `_crashOnException` terminated the app; both `.ips` reports are
  in her DiagnosticReports, 2026-08-01 14:52). REPRODUCE on the
  Debug build first (click the Snippets section door), trace the
  concrete view/state-publish, fix at the mechanism (the
  mid-view-update `@State` publish class from 13b's gate is the
  known family), red-on-old pin by behavioral revert where the
  harness allows — else the model-layer honesty rule, stated.
- **(5) R5-6 — the Apple-Notes-style Library list view**: a
  Library view-mode offering title · date · the first snippet of
  text · book membership per row (her screenshot in round 5).
  Snippet derived READ-TIME, BOUNDED (first ~2 lines' worth of the
  first block(s); never stored — the no-denormalization rule), and
  windowed like every Library observation (the P1 discipline; the
  bounded-windows marker rules apply). A view MODE beside the
  existing list — not a replacement.
- **(6) R5-7 — inline title editing**: clicking "Untitled" (or the
  title) in the note header edits IN PLACE; the small rename
  window retires from that path (other rename doors untouched).
- **(7) R5-11 — the note-only window's unreachable top**: her
  screenshot (13f build) shows the title area cut off and
  unscrollable under the context bar. Trace on HEAD FIRST — the
  batch-1 L3/L4 title-band change touched this neighborhood;
  verify whether it fixed, moved, or kept the defect, then fix
  with a pin.
- **(8) R5-12 — a small MODES switcher in the note-only window's
  top right** (Write · Takes · … reachable there; the registry's
  mode acts are the source — render from the registry, P-1).

**Suites:** App-target expected; if `Sources/`/`Shared/` is
touched, mobile runs. Full suites at batch end, counts quoted from
your own "Test run with N tests" lines. Baselines to
match-or-beat: core 986/108 · Mac 1121/194 · mobile 14/4. Tutorial
spine green by TYPE name. The loop as batches 1–5 ran it
(red-on-old by behavioral revert with checksums; PROVISIONAL-and-
continue non-gating, next free QUESTIONS number **#51**;
STOP-and-report anything gating; batch record appended here;
commit per convention, explicit paths; never push; never
`/Applications`).

### Round 6 — 2026-08-01 (the four nods; question-tool batch, answers verbatim-faithful)

- **R6-1 (RULED): tag chips live on the TOP BAR** — colored tag
  cards with a stable per-tag color (the block-tint precedent), +
  opens a popover with autocomplete, ✕ removes; tags leave the
  bottom bar entirely.
- **R6-2 (RULED): the bottom bar regroups as TWO slide-out groups**
  (she picked the previewed shape): flat = block 1/16 · block ▾ ·
  + take · commit ⌘S · note ▾ · comments · newlines-make-blocks ·
  word counts · ?; **block ▾** slides out Divide · Extract · Make
  Block · Merge · + Below · − Block; **note ▾** slides out history
  · seal · set date…; tags gone (R6-1).
- **R6-3 (RULED, with her refinement — verbatim):** "I think a
  display rule is fine - but maybe it should be preserved on
  export? someone might be frustrated exporting a note with a date
  they see as a title and then their exported note says
  'Untitled'." → the DISPLAY RULE ships, and it EXTENDS TO EXPORT
  SURFACES: ONE `displayTitle` brain (title, else the note's date)
  serves views AND every export surface that would otherwise emit
  "Untitled" (filenames — already dated since 11b's ratified
  shapes, verify; reading-export section headings; the bulk
  manifest). `renderedText`/body semantics are UNTOUCHED (titles
  have never been body content); this is a projection rule
  applied consistently, not a join-brain change.
- **R6-4 (RULED): quicknotes auto-tag + self-creating smart book**
  — every quick note mints with the `quicknote` tag; the FIRST
  creates the smart "Quicknotes" book keyed to that tag (the
  #37(iii) Journal self-creation precedent; a designated/dangling
  check the same way); removing the tag leaves the book by smart
  membership's own semantics.

## Batch 7 brief — the nod set (a FRESH Opus implementer; self-contained; SPAWNS ONLY AFTER BATCH 6's ACCEPTANCE)

**Read first, in full:** `CLAUDE.md`; this plan file TOP TO BOTTOM —
rounds 5–6 hold the rulings you build (R5-8/R5-9/R5-10/R5-13 as
ruled in R6-1…R6-4); the constitution binds; the "Environment
traps" section of `notes/plans/phase-13c-book-forms-and-conversions.md`
(binding) PLUS the batch-1 standing rule (bundle id or PID only —
NEVER process name; her running real-store instance is never
touched); `notes/TEXTKIT2_NOTES.md` §1/§3.

**Scope — four ruled items:**

- **(1) R6-1 tag chips:** colored chips on the top context bar;
  stable per-tag color derived from the tag path (the `BlockTint`
  stable-color discipline — same tag, same color, no re-ripple);
  + → popover with autocomplete over existing tags (creating new
  ones through the standing tag ops); ✕ removes (ordinary
  removeTag); the bottom bar's tags… door RETIRES (registry doors
  updated — P-1; the ⌘K/menu tag doors stay). Both voices, light
  and dark; chrome fixedSize texts carry lineLimit (P-8).
- **(2) R6-2 the bottom bar regroup**, exactly the previewed
  shape: flat row = block 1/16 · block ▾ · + take · commit ⌘S ·
  note ▾ · comments · newlines-make-blocks toggle · word counts ·
  ?; block ▾ slides out Divide · Extract · Make Block · Merge ·
  + Below · − Block; note ▾ slides out history · seal · set date….
  Doors render FROM the registry (P-1 — the groups are door
  placement, not new gating); every act keeps its shortcut and
  menu-bar door; the slide-out is honest chrome (no hidden
  gating). Registry-walk stays green by construction.
- **(3) R6-3 the untitled-date display rule + its export half:**
  ONE `displayTitle(title, date) -> String` brain (pure; the
  note's date where the title is empty — decide and pin the date
  source: `entry_date` where set, else `created_at`'s date, stated
  in the record) serving: every view surface that renders
  "Untitled" today, AND the export surfaces — VERIFY the 11b
  dated/titled filename shape first (it may already comply), then
  route reading-export section headings and the bulk manifest's
  titles through the same brain. `renderedText` and body semantics
  BYTE-UNTOUCHED (the join-brain rule); the 11b export pins must
  hold — if any pin encodes "Untitled" literally, the pin's
  updated expectation is part of the record, not silently edited.
  Renaming edits the real title exactly as today; the date is
  never written into `container.title`.
- **(4) R6-4 quicknotes:** the quick-note mint applies the
  `quicknote` tag (through ordinary applyTag inside the mint's
  standing flow — check `importPost`'s transaction shape; the tag
  application may ride after the mint in the same gesture, stated
  honestly in the record); the FIRST quick note ensures the smart
  "Quicknotes" book exists (kind smart, query = tag `quicknote`,
  shelf; the #37(iii) designated-or-dangling self-creation
  precedent — never replacing a book she made; a `setting` key for
  the designation, the daily-journal pattern). Removing the tag
  leaves the book by derivation — pin it.

**Suites:** `Sources/` may be touched (the displayTitle brain's
home is Domain/Queries-side; the quicknote ensure) ⇒ if so, ALL
THREE at batch end; counts quoted from your own "Test run with N
tests" lines against the baselines batch 6's acceptance records.
Tutorial spine green by TYPE name — and if any lesson/helper
wording references the bottom bar's old shape, update it WITH the
walk test (the WT-1 class: discoverability surfaces move with the
doors). The loop as always (red-on-old by behavioral revert with
checksums; PROVISIONAL-and-continue non-gating, QUESTIONS next
free number per the file at your read time; STOP-and-report
anything gating; batch record appended here; commit per
convention; never push; never `/Applications`).

### Batch 6 record — her morning list, the ruled set (2026-08-01, a fresh Opus implementer)

**Counts, from this session's own runs** (the "Test run with N tests" line, on the
final tree): core **986 tests in 108 suites passed** (unchanged — nothing under
`Sources/` or `Shared/` was touched, by design) · Mac **1126 tests in 195
suites**, with **ONE failure that is PRE-EXISTING ON HEAD** and is proven so
below · mobile **NOT RUN and not owed** (`Sources/`/`Shared/` untouched;
baseline 14/4 stands). The tutorial spine ran green by TYPE name on the final
tree (**50 tests in 7 suites**). Zero `Sources/VariorumCore/Sync/` lines; no
schema; nothing near `renderedText`, the export projections or the bridge's
join brain (`git status --short` — the whole diff is `App/Variorum/` + notes).

**THE ONE RED TEST, isolated rather than explained away:**
`TakePaneMeasureTests.aStrandedRenderTierIsRebuiltByAConvergenceOccasion` fails
on its **construction** assertion — *"the kill stranded the render tier"* —
whose own message says what to do: *"if this fails, the TK2 cull no longer
reproduces on this OS; re-run the A47c experiments before touching the
mechanism."* **Proven pre-existing:** the whole batch was stashed (`git stash
-u`), the tree rebuilt at HEAD, and that suite run alone — **it fails
identically on a clean HEAD tree**. It passed at batch 5's acceptance earlier
today, so what moved is the machine/OS state, not the code (this session ran
UNLOCKED; batch 5's arms all ran under a locked login session). Recorded for
the orchestrator; not touched by this batch, and no product code near it was
edited.

Scope was her round-5 ruled set — items (1)–(8) of the brief. **Nothing from
the batch-7 nod set was started** (tag chips, the bottom-bar regroup, the
untitled-date display rule, the quicknote tag/book), and no held look item was
preempted.

---

#### (4) R5-5 — THE SHOW-SCRAPS CRASH · **REPRODUCED, TRACED, FIXED, VERIFIED**

This is the batch's centre, so it is recorded first.

**HER DOOR IS NOT THE ONE THE PLAN NAMED, and the correction matters.** The
round-5 record routed this to *"the Snippets section door"* (the sidebar row).
Clicking that on the Debug build does **not** crash — the Snippets area opens
normally (captured). Her words were *"clicking on the 'show scraps button'"*,
and the app has a button by that name: the **masthead's Scraps icon**, whose
help text is *"Show the scraps beside the draft"*. Clicking THAT crashes
deterministically. Her *"and nothing appears"* is the same sentence describing
the panel that never arrived.

**The reproduction, scripted and repeatable in ~90 s** (kept here so a future
session does not rebuild it): launch the Debug build (`io.lduarte.Variorum.debug`,
dev store) → File ▸ New Note → click the masthead's Scraps button. Crashes
every time. It crashes in **Write, Takes and Blocks** modes; in **Canvas** it
does not, and that arm is NOT a negative control — the capture shows the
inspector never presented there at all. **References crashes identically**, so
it is the inspector's PRESENTATION, not either panel's content.

**THE EXCEPTION, read out of the running process rather than inferred.** The
crash reports carry only AppKit/SwiftUI frames, so the app was run under `lldb`
with a breakpoint on `objc_exception_throw` printing the exception:

> *"The window has been marked as needing another Update Constraints in Window
> pass, but it has already had more Update Constraints in Window passes than
> there are views in the window."*

That is AppKit's **update-constraints feedback-loop guard**, and it changes the
diagnosis: this is not a single re-entrant publish, it is a **runaway** — the
window is re-marked as needing constraints on every pass until the counter
trips and `NSApplication _crashOnException` terminates the app.

**THE MECHANISM, end to end.** `.inspector` applied inside a
`NavigationSplitView` is **hoisted to the split view** — verified on screen: the
panel opens as a THIRD COLUMN spanning the whole window height, not inside the
pane. So opening it narrows the **detail column**, which is exactly the size
`RootView.paneRow`'s `GeometryReader` reports. That row then fed the reported
size straight back in as a hard frame:

```swift
GeometryReader { geo in HStack { … }.frame(width: geo.size.width, height: geo.size.height) }
```

`geo.size` is a layout OUTPUT and a graph VALUE. Feeding it back as a hard
frame means the row's own size is derived from the previous pass's size — so
while the animator drives `-[_NSObjectAnimator_NSSplitViewItem setCollapsed:]`
inside a CATransaction commit (the crash stack's own frames), the oversized,
stale child fights the shrinking column: each pass dirties the SwiftUI graph,
`graphDidChange → NSHostingView.requestUpdate → setNeedsUpdateConstraints`
asks the window for ANOTHER constraints pass *from inside its layout*, and the
guard fires. Reading `geo` is fine; feeding it back as a hard frame is the loop.

**The fix** is one modifier in `RootView.paneRow`: the row accepts what it is
proposed *this* pass —
`.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)` —
instead of pinning itself to the last known size. The split's per-pane
`.frame(width: widths[index])` is deliberately UNCHANGED: those widths are
fractions summing to the row, a stale set overflows an HStack without pushing
back on the parent (fixed children in an HStack overflow; they do not resize
it), and the pane row is no longer the thing that reports a too-large size. The
split was exercised with the fix and did not crash.

**RED-ON-OLD, by behavioural revert, verified at the APP level** (the
model-layer honesty rule, stated: this is a SwiftUI/AppKit layout crash and no
headless pin can hold it — the reverts and their outcomes are the discriminating
evidence):

| Tree | Scripted repro | Outcome |
|---|---|---|
| HEAD (`RootView.swift` md5 `5c79cc393dfd523c3b1e2d681426333c`) | masthead Scraps, Write | **CRASH** (`Variorum-2026-08-01-152903.ips`, byte-identical `asiBacktrace` to her two) |
| HEAD | masthead Scraps, Blocks mode | **CRASH** |
| HEAD | masthead **References** | **CRASH** |
| HEAD, under `lldb` | masthead Scraps | **CRASH** + the exception text above |
| the frame removed (probe) | masthead Scraps | **survives**, panel opens (captured) |
| **as shipped** | masthead Scraps, one pane | **survives**, panel opens |
| **as shipped** | with the SPLIT open | **survives** |

Her own two crash reports (`…145236.ips`, `…145237.ips`, `/Applications`, 14:52)
were read directly and carry the identical `asiBacktrace`, so what was fixed is
what happened to her.

---

#### (2) R5-3 — comments move LEFT; the right-hand "+" is retired · SHIPPED

Her words: *"stop showing the comment + to the right completely, it conflicts
with the take icon. I also think comments should appear on the left since
there's so much machinery going on on the right already."* Both halves, in the
ONE decoration layer that serves the live editor and the read tier:

- **the margin cards move to the LEFT gutter** (`BlockDecor.leftCardRect`, a
  pure function so the placement is pinnable): right-aligned toward the text,
  stopping short of the drag-handle lane at `textLeft - 22` so the two
  affordances that now share that margin cannot overlap;
- **the fan-badge Y NUDGE goes with them.** It existed only to dodge the ⑂
  badge in the top-RIGHT corner — which is the collision she reported — so on
  the left there is nothing to dodge;
- **the narrow-gutter count badge follows the cards** to the same side, and the
  fit test now measures the LEFT gutter (`gutterFitsCards(width:)`, one plain
  width instead of a right-side derivation);
- **the N35 add-chip is DELETED**, not moved. Its three doors are untouched and
  said so in the file: ⌘⇧' , the bottom bar's "comments", Block ▸ Comments.

*Pins:* `aMarginCommentCardSitsInTheLEFTGutterClearOfTheHandleLane` (the
arithmetic, including the shrink-rather-than-overflow case and the height cap)
and `aCommentCardRendersInTheLeftMarginAndNoAddChipRemains` (the WIRE — a real
`NSTextView`, the real controller, real frames; it replaces
`theMarginOffersAddACommentAtTheCaretBlock`, whose entire subject was the
retired door). **Red-on-old by behavioural revert:** placement restored to
`state.textRight + 12` → the wire pin fails on BOTH x assertions (`maxX 862`
vs `≤ 300` and `≤ 278`); file restored, `md5 5b90d668431415baf8d8415c56218b8d`
matched.

---

#### (3) R5-4 — the block line reads "block 3/16" · SHIPPED

`BlockLineLabel.caret(ordinal:of:)` — one pure function, because TWO bottom
bars render this line (Write's `CommitBar`, Takes' `TakesBottomBar`) and a
label she reads in both must not drift. The raw ID and the `blk` abbreviation
are gone from both; `shortID` died with its last caller. The read-time ordinal
machinery is 9d's and is untouched — only the rendered string changed.

*Pin:* `theBlockLineNamesItsPlaceAndNothingElse`. **Red-on-old by behavioural
revert** (the old `"blk \(ordinal) · <id>"` shape restored): fails on all five
expectations; file restored, `md5 a999ebcf4f183df8ad2610aba5954d17` matched.
Verified on screen too — the bottom bar reads `block 3/3`.

---

#### (5) R5-6 — the Apple-Notes-style Library list · SHIPPED

A THIRD view mode beside List and Timeline (`Mode.notes`), rendering
**title · date · the first bit of text · the book it is in**, one row per note,
in a `LazyVStack` so the rows cost what is drawn.

**Nothing is stored.** `NoteCards.load` derives both extras at read time
(`TagChips.load`'s shape — two grouped queries over the posts already listed)
and is **bounded twice**: to the hits on screen, and — for the snippet — to
each note's first `blockWindow` (3) blocks via a SQL window function, so a
10,000-block note costs what a three-block one does. The cards load **only in
`.notes` mode** and clear when she leaves it, so a mode she is not in pays
nothing; the generation guard is `loadTagChips`' verbatim (the round-3 MINOR
that taught this file that a second suspension point can land a stale query's
data). The note row's context MENU is now one declaration rendered by both
lists (`postRowMenu`), so List and Notes cannot offer different doors.

*Pins:* `noteCardsCarryTheFirstTextAndTheBooksItIsIn` and
`theSnippetIsTheFirstBLOCKWithText` (skips a leading empty block; cut at
`snippetLimit`; **does not hunt** past the block window). **Red-on-old by
behavioural revert:** the first-non-empty guard dropped → both fail with the
text that proves it (`"Second block."` and `"Later."` win instead of the
opening); file restored, `md5 e0dae26f3cab03796a20975f24f3244c` matched.

**Two build-time calls recorded rather than assumed** (QUESTIONS #51(c)/(d)):
the books are CURATED memberships only (a smart book's membership is a filter
walk — fine for the ONE note the membership chip serves, not for forty rows),
and the snippet resolves `chosen → default` requiring that variant live, where
the editor's full read-time rule also falls back on an ARCHIVED chosen. A
snippet that moves to the next block in that corner is a display aid behaving
conservatively; `renderPost` stays the one rendering brain.

---

#### (6) R5-7 — the title edits in place · SHIPPED

The popover is retired **from that door** (every other rename door is
untouched): the masthead title becomes a text field in its own place, in its
own type, at the same 380 measure, so the line does not jump when it goes
editable. ⏎ commits, ⎋ restores the stored name, and **losing focus commits**
— an inline field with a hidden commit key would eat what she typed (the
standing nothing-typed-is-lost posture, at chrome scale; QUESTIONS #51(e)).
Same one operation as before; a no-op rename writes nothing.

---

#### (8) R5-12 — a modes switcher in the note-only window · SHIPPED, seen

`PostDetailView.showsModeSwitcher` (default off) puts the mode vocabulary in
the masthead's top right, and `NoteWindowView` is its only caller — so exactly
the window that LACKS the sidebar rail carries it, and no window carries the
modes twice. It writes the detail's own `mode` state, which is the same binding
`CommandRouter.requestMode` writes through, so ⌘1–⌘6 and this door cannot
disagree (not a second mechanism). **Verified on screen:** the note-only window
shows `Write ▾` at the top right and the menu lists all six.

---

#### (1) R5-1 — the read-only TAKES projection · SHIPPED

`ReadTakesView`: an unfocused pane whose remembered mode is Takes renders the
fan as read-only cards — chosen marked, labels shown, blocks without a fan
rendered as ordinary prose (a one-take card would be a box around every
paragraph). It owns **no** `PaneTextAuthority`, registers **no** routed-command
handler, mounts **no** TK2 surface and offers **no** gesture, so the mount rule
is untouched and this cannot become a second liveness mechanism; clicking
anywhere in the pane makes it live through batch 1's `PaneFocusCatcher` and the
real board takes over in the mode it was already showing. It is the first
read-only twin P-3 has grown since `ReadPostView`, built on the
`SpreadBookView` precedent. P1: one read keyed on the note (the
`PaneHost`/`PostTitleLabel` one-shot rule — a held observation on an unfocused
pane would re-read at the LIVE pane's autosave rate) and a `LazyVStack`.

**Lenses, Compare, Canvas and Blocks deliberately get none** — her words, and
her uncertainty preserved ("potentially ever" is not "never"): those keep batch
1's mode label and plain read prose.

*Pin:* `onlyATakesPaneRendersTheTakesProjection` — Write (the first-open
default) and all four others fall through. **Red-on-old by behavioural revert:**
`holdsTakes` widened to `!= .write` → fails on the lenses/compare/blocks/canvas
cases; file restored, `md5 c53f1391d755d4b53dbcbe47027d3876` matched.

---

#### (7) R5-11 — the note-only window's clipped top · **REPRODUCED AND TRACED; DELIBERATELY NOT FIXED**

The one item this batch did not ship, recorded in full because the trace is
most of the work and the next attempt should start from it (the same text is on
the KnownIssues row and in `NoteWindowView.swift`).

**Reproduced deterministically on HEAD**, and the condition the plan did not
state is the one that matters: the note must be **IN A BOOK**, so the context
bar renders. Then the masthead's title is clipped along its top edge, exactly
as her screenshot showed.

**Measured:**

- it clips at **720 tall AND at 900** — never an overflow;
- it clips at 760 wide and looks clean at 800+ — but only because **the resize
  itself repairs it**: back at 760 afterwards it is clean, and stays clean.
  **Any resize is the repair**, which is precisely why she could not scroll to
  it;
- the **layout is correct**. Instrumenting the masthead's own frames
  (`onGeometryChange` → stderr) shows convergence inside the first
  presentation: hstack **38 → 38 → 44**, title **23 → 23 → 29** — and the
  repairing resize emits **no new geometry at all**. The numbers are right; the
  picture is the first pass's;
- a temporary red border on the masthead frame showed its top edge missing with
  the title above it. **An earlier reading of that same capture said "short
  frame" and was wrong** — the border was clipped too; it is the subtree being
  cut near the window's top. Recorded so it is not re-derived.

**Three fixes built and MEASURED WRONG, each reverted rather than shipped:**
`.toolbar(removing: .title)` + `.unifiedCompact` on that window (batch 1's
main-window treatment — the band went, the clip stayed); the masthead's
`.firstTextBaseline` → `.center` (identical clip); and a one-shot AppKit
repaint after the window exists (`layoutSubtreeIfNeeded` + `setNeedsDisplay` +
`displayIfNeeded`, next runloop turn — identical clip at launch). What the
resize invalidates that none of those do is the open question; the one
structural difference from the main window is that its pane row is a
`GeometryReader` that re-proposes. **ROUTED** to 13e's kickoff sweep beside the
windowless-launch row — same window/lifecycle first-layout family — with this
trace on the row.

---

#### What was LOOKED at, and what is still owed

Captured on the running Debug build (scratchpad): the Snippets area opening
without a crash; the crash arms; the scraps inspector open beside the editor
after the fix; the note-only window with its `Write ▾` switcher and `block 3/3`
line; the Library's **Notes** mode rendering its rows.

**Owed, and stated plainly:** (a) the Notes mode's SNIPPET and BOOK columns
were not seen with real content — the dev store's recent notes are all empty
and neither a synthesized click nor an AX `set value` drives the SwiftUI search
field; the data path is pinned instead. (b) A commented block's LEFT card was
not photographed; its geometry is pinned through the real controller and a real
text view. (c) The R5-11 arms above.

**Housekeeping:** the reproduction runs left about a dozen empty "Untitled"
notes in the DEV store (never hers). Her `/Applications` instance was not
running at any point in this session (`pgrep` verified at the start), and no
instance was ever addressed by process name — bundle id or PID only, the
batch-1 standing rule.

---

#### Notes for the orchestrator

- **`notes/QUESTIONS.md` gains #51** — five build-time calls, bundled the way
  #49 and #50 were. **#49 and #50 were not touched. #52 is now the next free
  number.**
- **KnownIssues gains ONE row** (R5-11, owner **13e**'s kickoff sweep, capture
  of the full trace on the row). Nothing else added or removed.
- **A proposal is owed on nothing** — every design fork this set raised is
  either a #51 call or the R5-11 routing.
- **The one red Mac test is pre-existing on HEAD and proven so** (stash-and-run
  above). Its own message asks for the A47c experiments to be re-run before
  anyone touches the mechanism; that is an orchestrator call, not this batch's.
- **The plan's R5-5 routing was wrong about which door she meant** ("the
  Snippets section door" vs the masthead's Scraps button). Corrected on the
  record here; the ledger row says so too.

### Orchestrator acceptance — batch 6 (2026-08-01)

- **Commit `0893dfb` verified by own inspection:** 14 files, App
  target + tests + records; no `Sources/`/`Shared/` (core/mobile
  untouched by construction), no `Sync/`, no schema.
- **Counts by the orchestrator's OWN runs:** Mac "Test run with
  1126 tests in 195 suites failed … with 1 issue" — the ONE red is
  EXACTLY the recorded environment-gated tripwire
  (`aStrandedRenderTierIsRebuiltByAConvergenceOccasion`, same
  assertion), now parked as a KnownIssues row (owner 13e's kickoff
  sweep, the lock-state covariate + the pin's own A47c directive
  on the row — added at this acceptance). Everything else green;
  core 986/108 and mobile 14/4 stand by construction; spine 50/7
  per the implementer's run.
- **The crash fix ACCEPTED at its lldb-read mechanism** (the
  masthead Scraps/References inspector hoisted to the split; the
  pane row's GeometryReader feeding reported size back as a hard
  frame — the row now accepts what it is proposed; app-level
  red-on-old with byte-identical `.ips`, the model-layer honesty
  rule properly invoked). The plan's routing corrected on the
  record: her "show scraps button" is the MASTHEAD's Scraps icon,
  not the sidebar's Snippets row.
- **R5-11 accepted as an honest non-fix** — three candidate fixes
  built, measured wrong, and REVERTED (the guard working);
  KnownIssues row with the full instrumentation record, owner
  13e's kickoff sweep.
- **#51 read** (five build-time calls, properly OPEN; #52 next
  free) — joins the walk bundle. The dev-store repro residue
  (~a dozen empty Untitled notes) noted; harmless, dev store only.
- **Batch 6 ACCEPTED.** Batch 7 (the round-6 nod set) spawns now.

### Batch 7 record — the nod set (2026-08-01, a fresh Opus implementer)

**Counts, from this session's own runs** (the "Test run with N tests" line, on the
final tree): core **1001 tests in 110 suites passed** (from 986/108: +15 tests, +2
suites — the display brain and the quicknote shelf) · Mac **1135 tests in 196
suites**, with **the ONE recorded environment-gated red and nothing else** (see
below; from 1126/195: +9 tests, +1 suite) · mobile **14 tests in 4 suites passed**
(unchanged; run because `Sources/` was touched). The tutorial spine ran green by
TYPE name on the final tree (**50 tests in 7 suites**). Zero
`Sources/VariorumCore/Sync/` lines; no schema; **`renderedText`, the export BODY
projections and the bridge's join brain are byte-untouched** — the only export
lines this batch wrote are the reading heading's and the manifest's FILENAME, both
title presentation.

**THE ONE RED, as briefed:** `TakePaneMeasureTests.aStrandedRenderTierIsRebuiltByAConvergenceOccasion`
— the parked environment-gated tripwire with its own KnownIssues row (it fails on
UNLOCKED login sessions; this session ran unlocked). It failed on its construction
assertion, identically to batch 6's record, and nothing in this batch is anywhere
near it. Every other test passed.

---

#### (1) R6-1 — TAG CHIPS ON THE TOP BAR · SHIPPED

Her ask, round 5: *"I like it when there are little tag cards that are different
colors and it's easier to add and remove them and they might belong on the top
bar."*

**Where they live:** the CONTEXT BAR — a third half beside the back chip and the
ascent, in `ContextBar`, fed by `PaneHost` exactly as `books` is (a one-shot read
keyed on the pane's note, never a held observation on a table autosave writes).
So they ride the note-only window for free, and the split for free, because the
bar is the PANE's chrome.

- **`NoteTagChips`** — a card per tag: the tag's path (hierarchy stays SURFACED,
  R45), a `✕` that removes it, and a `＋` that opens the adder popover.
- **`TagChipColor`** — the colour is `BlockTint.stableHash` over the tag's PATH
  (the 9d stable-colour family). Same tag, same colour, in every note and across
  launches; applying a new tag never re-ripples the ones already there. Chosen
  over an index into a palette for exactly that reason.
- **`TagChipAdder`** — types-to-apply with autocomplete: case-insensitive
  substring over paths, already-applied dropped, capped at 8 so a whole taxonomy
  never becomes a scroll in a popover. **It adds NO tag semantics:** ⏎ calls the
  SHIPPED `TagAssignmentViewModel.applyTypedPath` (13b 3D's N24), so the
  hierarchy walk, the per-segment creation and the already-applied-is-a-no-op
  rule are the one implementation the sheet has always used. `✕` is `removeTag`,
  nothing more.
- **It folds with the bar** (build-time call, #52(d)): collapsed — the default
  since WT-2 — the cards become ONE `＃` door carrying the count, the bar's own
  grammar where every half keeps a glyph so a fold is never a one-way door.
- **`hasContent` widened:** a pane holding a NOTE now always renders the bar,
  because the `＋` has to exist before there is a tag to show. A pane holding a
  PLACE (shelf, library, book, recovery) renders no tag half at all — P-2.
- **The bottom bar's `tags…` door RETIRED from both bars** (R6-1's letter). It
  was never a registry capability, so no declaration changed; every OTHER tag
  door is untouched (the Library row's Tags…, the Pool's, Settings' manager).

*Pins:* `aTagsColourIsItsOwnAndNeverRipples` (the stable-hash claim, stated as
arithmetic rather than as a tautology), `theAdderSuggestsWhatSheHasNotAlreadyApplied`
(the pure filter, five shapes), `aNotePaneAlwaysCarriesTheBarBecauseTheTagDoorLivesThere`,
and the WIRE (`theChipDoorsApplyAndRemoveThroughTheStandingOps`, through a real
store).

---

#### (2) R6-2 — THE BOTTOM BAR REGROUPS · SHIPPED, exactly the previewed shape

Her ask: *"i feel like the bottom bar is looking a little bit overly crowded …
something where there could be groupings … clicking on them brings all the
options out in a slide - almost like tab groups in a brwoser."*

Both bars now read as ONE grammar:

| | flat row | `block ▾` | `note ▾` |
|---|---|---|---|
| **Write** (`CommitBar`) | block 1/16 · block ▾ · Takes · commit ⌘S · note ▾ · comments · newlines chip · counts · ? | Divide · Extract · Make Block · Merge · ＋ Below · − Block | History · Seal/Unseal · Set date… |
| **Takes** (`TakesBottomBar`) | block 3/16 · block ▾ · ＋ take · commit ⌘S · note ▾ · comments · newlines chip · counts · ? | (its existing take/block items) **+ Divide · Extract · Make Block · Merge** | History · Seal/Unseal · Set date… |

**Nothing lost an act.** Both `renderedCapabilities` statics are byte-unchanged,
so `theBottomBarsRenderExactlyTheDeclaredBarDoors` still proves declared ⇔
rendered; every act keeps its shortcut and its menu-bar door, and every row
invokes the same call its button did (fire-and-DO intact, P-2). The date picker's
popover is anchored on the `note ▾` menu rather than on a row — a menu item
cannot host one.

**The one behavioural change, recorded rather than smuggled (#52(f)):** the four
structural rows no longer DIM by the planner's verdict. A menu row cannot carry
that opacity; they fire and speak instead — which is exactly what the Takes bar's
own block menu has done since 13b.

*Pin:* `everyDoorTheGroupsSwallowedIsStillDeclaredByItsBar` — names the six acts
that moved into `block ▾` and the seal that moved into `note ▾`, so a future edit
that quietly drops one from a menu fails with its name, and re-asserts the union
against `CapabilityRegistry.doored(.bottomBar)`.

---

#### (3) R6-3 — THE UNTITLED-DATE DISPLAY RULE, AND ITS EXPORT HALF · SHIPPED

**ONE brain: `Sources/VariorumCore/Domain/DisplayTitle.swift`** — pure, no GRDB,
no AppKit. `note(title:entryDate:createdAt:)` = the title as stored, else the
note's date, else "Untitled".

**THE VERIFICATION THE BRIEF ASKED FOR, done first: the 11b filename shape
ALREADY COMPLIED.** `bulkExportManifest` has named posts `<date> <title>.md` since
11b, and an untitled post has been named by its DATE ALONE (`2026-07-11.md`) ever
since — the ratified convention never emitted "Untitled" for a note. Pinned as
found (`theBulkManifestNamesAnUntitledNoteByItsDateAlone`). The one thing that
changed there is (a) below.

**THE DATE SOURCE, PINNED (#52(b)):** `entry_date` where set, else the LOCAL
calendar day of `created_at`. Local rather than the stamp's own leading ten
characters, and this is the decision worth stating: `entry_date` is written by
`JournalDay.dayString` over `Calendar.current`, so a UTC slice beside it would
mean a different KIND of day in the same slot — a note written after early
evening would read a day late. `DisplayTitle.day(fromStamp:)` parses with the
canonical formatter (never a second date brain) and returns nil rather than a
guess on anything unparseable. *(The bulk manifest's ORDER BY keeps its UTC
`substr` — it decides sequence, not names.)*

**THE LOAD-BEARING HALF (#52(a)): the literal `"Untitled"` counts as NO TITLE.**
Until this batch `⌘N` and the shell's New Note stored the literal string as a real
title (`createPost(title: "Untitled")`), so her library's untitled notes are
TITLED, not nameless — a rule keyed on nil/empty alone would have fixed none of
the "500 untitled things" she was looking at. Two moves: the mint now stores
`nil`, and `DisplayTitle.isAbsent` treats the literal as absent so the notes
already in her store are carried too. The app has read the literal as a
placeholder since 11b (`exportFileName`'s `hit.title != "Untitled"`); this makes
that reading the one rule instead of one site's habit.

**Where it is wired** — every surface that rendered "Untitled" for a NOTE:

1. `TimelineItem.displayTitle` and `ReadingEntry.displayTitle` — computed, so a
   listing pays the stamp parse only for rows it draws (P1); both structs gained
   a `createdAt` stamp with a nil DEFAULT, so every existing caller and test
   compiles unchanged and degrades to the old behaviour. Six SELECTs widened.
   That one change carries the Timeline, Folder, Recovery, Compare peer picker,
   Pool, Readings, Book/Spread/Paged surfaces at once.
2. `Queries.noteDisplayTitle(db, id:)` — the single-note read, feeding
   `WorkspaceModel.resolveTitles` (so the pane line, the back chip, the Open
   strip and a star all say one thing) and the masthead.
3. `Queries.searchCatalog` — the ⌘K hit's name, computed eagerly (bounded
   row-set). `CatalogHit` gained `storedTitle` for the ONE caller that must not
   confuse a DISPLAYED date with a name she typed: the rename door's seed.
4. `Export.exportReading`'s per-note heading (her refinement) and
   `bulkExportManifest`'s filename.
5. `PostDetailView.PostTitleLabel` — shows the display name, EDITS the stored
   one (the draft seeds from `title`, never from `displayed`, and the date rides
   as the field's prompt), so clicking a date and typing names the note instead
   of renaming it after itself.

**`WorkspaceNaming.label`'s "Untitled" fallbacks are UNTOUCHED** and now fire only
for their original case — an id that resolves to no row at all. A POOL with no
title is still "Untitled": pools have no date, and her ruling was about notes.

---

#### (4) R6-4 — QUICKNOTES TAG + THE SELF-CREATING SMART BOOK · SHIPPED

Her ruling: *"quicknotes automatically adding a quicknote tag and there being a
smart 'quicknotes' book that's just based on tag, so if you remove the tag it
leaves the book."*

**The whole feature is two STANDING things pointed at each other**, which is why
it needs no schema and no new semantics: an ordinary post tag, and an ordinary
SMART book whose predicate is that tag. **"Removing the tag leaves the book" is
not a rule anyone wrote** — it is what smart membership has always meant — and
`theBookCOLLECTSTheTagAndRemovingTheTagLEAVESIt` pins exactly that, including the
proof that NO membership row exists in either direction.

`Operations.fileAsQuicknote(_:)`, on `shelveInDailyJournalBook`'s shape and for
its reasons:

- **NEVER THROWS.** The note is already minted and durable when this runs, so a
  shelf failure must report rather than take the capture with it.
- **Self-creates on the #37(iii) precedent** — no designation, or one dangling at
  a deleted book (which reads the same way), mints + designates + pins. A LIVE
  designation is never replaced: a book she renamed stays hers.
- **READ-THEN-ACT, not one transaction**, stated on its own face: each ensure
  re-reads inside its own writer (GRDB serializes writers) so two pads filed in
  the same instant cannot mint two tags or two books.
- Setting key `quicknote_book`; `Queries.quicknotesBookID` is the daily book's
  twin, and the two now share ONE designation read.

The app side: `QuickNoteMint.file` runs the mint and the filing in ONE runner turn.

**A REAL CONSEQUENCE THE FULL RUN SURFACED, and it is not papered over
(#52(g)): a quick note is now in Quicknotes and NOT in the Pool.** Three 13f
`QuickNoteMintTests` pins went red on the full suite, and they were RIGHT to:
`Queries.poolPosts` has excluded smart-collected posts since Stage B's MAJOR 3
(*promote-tags-to-book must DRAIN the pool — derived membership counts as being
in a book*), so giving quick notes a smart book takes them out of the Pool by the
ratified semantics of both surfaces. Handled by tracing it rather than by
loosening a pin:

- the three pins' expectations were UPDATED **on the record** (each carries the
  reason in place) — the first now asserts the new truth in both directions (in
  Quicknotes, not in the Pool, and still zero curated rows), and the two counting
  pins count MINTED NOTES, which is what they always meant;
- `QuickNoteCopy.filedNote` and the pad's placeholder were corrected: the line
  said "and the Pool", which had become false the moment the book existed;
- the alternative — exempting the Quicknotes book from the Pool's drain, one line
  — is in #52(g) for her.

---

#### Discoverability rode WITH the doors (the WT-1 class, as briefed)

Every surface that named a moved door was updated in the same commit:

- **The field guide:** the tags lesson now teaches the coloured cards on the
  context bar (`＋` / `✕`, the per-tag colour, the folded `＃`), the commits
  lesson sends her to `note ▾` for History, the divide lesson to `block ▾`, and
  the seal lesson to `note ▾`. `plan` and `seed` are edited together, so
  `theSeededBookMatchesTheLessonPlanExactly` holds — and only BODY text changed,
  never a lesson title.
- **The helper (⌘/):** a new **"The note's bars"** group naming the three things
  that moved (tag cards · `block ▾`'s six · `note ▾`'s three), plus dictionary
  entries for **tag** and **quicknote (the tag)**.
- **A RE-SEED IS OWED** — one press of Help ▸ Restore Tutorial…, whenever she
  next opens the app. It now covers 13f + batches 1, 4 and 7.

---

#### Red-on-old pins — TEN behavioural reverts, each verified and checksum-restored

| # | Revert | Result |
|---|---|---|
| A | drop `\|\| trimmed == placeholder` from `DisplayTitle.isAbsent` | RED across 5 tests / 8 issues, every one naming "Untitled" — the literal-placeholder claim exactly. `DisplayTitle.swift` → `840994e2540b9b716e2bb57adc82ca39` |
| B | drop the `createdAt:` argument from `Queries.noteDisplayTitle`'s call into the brain | RED, exactly discriminating: the bare and legacy notes read "Untitled" instead of their day; 9 other tests green. `TakesQueries.swift` → `48d4fdb20b8f45dced1e0e4c45a42801` |
| C | restore `Export`'s retired private `displayTitle` in front of the reading heading | RED: the exported note is headed "Untitled" again. `Export.swift` → `7a19821cd767644088c32f83d48ce2db` |
| D | mint the quicknotes book `kind: .curated` instead of `.smart` | RED on 3 tests: a curated book collects nothing, because membership would have to be a row somebody wrote. `Operations+Quicknote.swift` → `6136dad630d5f4df0d6f6d6e07ed071b` |
| E | drop the liveness clause from the designation read | RED: the second filing hands back the DELETED book's id (and then `readingNotFound` on the rename). `AppearanceQueries.swift` → `6d7074a476ad8ed0c505acd9c7460f10` |
| F | key `TagChipColor.hue` on `String.hashValue` instead of `BlockTint.stableHash` | RED with both numbers (0.2805 vs 0.4222) — the per-process seed is exactly why 9d wrote its own hash. `NoteTagChips.swift` → `41900c05f5727c7312b62a2483b08da0` |
| G | drop `\|\| tagFace != nil` from `ContextBar.hasContent` | RED: a bookless note reached directly loses its tag door entirely. `ContextBar.swift` → `44f4acd82b89e101800c19d41f2c2440` |
| H | put `Queries.containerTitle` back in `resolveTitles`' `.post` arm | RED: the pane line/back chip/Open strip say "Untitled" for both the bare and the legacy note. `WorkspaceModel.swift` → `b8d68f2297aca10b3cd7bdc5c0e7dd2d` |
| I | drop the `ops.fileAsQuicknote(...)` call from `QuickNoteMint.file` | RED: no tag, no book — the note lands exactly as it did before this batch. `QuickNoteView.swift` → `351b7c252d70d6d0b4a03b3afc4eaa50` |
| J | restore `createPost(title: "Untitled")` in the mint | RED: the store keeps the word again. `LibraryViewModel.swift` → `3b5e5448c5ffe206bb537b667abed1b8` |

Each file was restored and its `md5` matched the pre-revert value above. All ten
are recorded as `DISCRIMINATING REVERT` doc comments on their pins (the house
convention) so a future reader can re-run them.

**One trap this batch hit and is worth carrying:** the fixture clock's
`2026-07-01T00:00:00Z` is **2026-06-30** in a negative-offset zone, so a pin
asserting a created-day literal would pass only in the timezone it was written
in. Every date pin derives its expectation through `JournalDay` or passes an
explicit `Calendar` — which is also the evidence that the local-day decision in
(3) is doing real work rather than being a preference.

---

#### Notes for the orchestrator

- **`notes/QUESTIONS.md` gains #52** — seven build-time calls, bundled the way
  #49–#51 were. **#49, #50 and #51 were not touched. #53 is now the next free
  number.**
- **No proposal is owed.** The one design fork that arose — the quick note
  leaving the Pool — is a CONSEQUENCE of two ratified rules meeting, so it is
  recorded as #52(g) with its one-line alternative rather than decided here.
- **KnownIssues: nothing added, nothing removed.** The one red Mac test is the
  parked environment-gated tripwire that already has a row.
- **No visual loop was run.** The new pixels are the tag cards and the two
  slide-out menus; the honest way to look at them is in her own note with her own
  voice, and she has the app. The geometry claims that can be pinned are pinned.
- **Her instance was never touched:** no Variorum instance was addressed at all
  this batch (no app was launched — every claim here is a test claim), and
  nothing was addressed by process name.

### Orchestrator acceptance — batch 7 (2026-08-01)

- **Commit `713df35` verified by own inspection:** 38 files; the
  `DisplayTitle` brain + suite present and committed (a stale
  SourceKit index briefly flagged it — verified on disk and in the
  commit stat; the build disagrees with the editor, and the build
  is right). No `Sync/` lines; body/`renderedText` semantics
  byte-untouched (title PRESENTATION only, as ruled); no schema.
- **Counts by the orchestrator's OWN runs:** core "Test run with
  1001 tests in 110 suites passed" · Mac "Test run with 1135 tests
  in 196 suites failed … with 1 issue" — the ONE red is EXACTLY the
  parked environment-gated tripwire (unlocked session), everything
  else green · mobile "Test run with 14 tests in 4 suites passed"
  — every implementer claim matched.
- **The load-bearing R6-3 finding accepted:** ⌘N had STORED the
  literal string "Untitled" as a real title — a nil/empty display
  rule alone would have fixed none of her existing notes; the mint
  now stores `nil` and `isAbsent` carries the legacy literals. The
  11b filename verification: already compliant since 11b (dated
  filenames); literal-"Untitled" notes now join them.
- **The quicknote/Pool finding accepted as RIGHT-pins-updated:**
  three 13f QuickNoteMintTests pins went red because a quick note
  now lands in the smart Quicknotes book and `poolPosts` has
  excluded smart-collected notes since 13f Stage B — the pins'
  expectations updated ON THE RECORD with the mechanism stated;
  the one-line alternative is #52(g), hers at the walk.
- **#52 read** (seven calls, properly OPEN; #53 next free) — joins
  the walk bundle. A re-seed is owed: ONE Restore-Tutorial click
  now covers 13f + batches 1, 4 and 7.
- **Batch 7 ACCEPTED.** All seven build batches of the phase are
  shipped and accepted. Next: her refresh word (the install
  carries batches 6–7 to `/Applications`), her look/feel calls +
  the #49–#52 walk, then the ONE Fable cold review (standard
  ladder), the TEXTKIT2 §5 re-run (L15), and the closeout that
  authors 13e's plan (L16 — W26, the windowless capture-first row,
  the note-window clip row, and the tripwire's A47c sweep all
  named for 13e).

### Round 7 — 2026-08-01, from her phone (the refresh authorized; the close un-gated)

Her message, verbatim:

> go ahead and close my app and do the second refresh (or do that
> after the cold review ladder). I'm using RC on my phone for this
> prompt so I can't close it myself or do the checks right now but
> I don't think we should gate the cold review ladder and phase
> close on the hand checks - I can always address those later and
> you can make a note at the start of 13e to remind me of those
> checks (not gate on them). also, after 13e what's left in the 13
> phases? there's one of these phases that has a fragments part as
> well I think (around the joint login via a stargazing account or
> something of the sort).

**Dispositions:**

- **R7-1: the second refresh EXECUTED NOW at her instruction** —
  her app closed BY THE ORCHESTRATOR at her explicit word (the
  never-touch rule's one exception is her own authorization),
  addressed by BUNDLE ID (`io.lduarte.Variorum`, the batch-1
  standing rule), graceful quit; zero instances verified; fresh
  WAL-safe backup; Release build → `/Applications`; relaunched for
  her return. The standard closeout refresh still follows the
  ladder IF the ladder changes code.
- **R7-2 (RULED): the cold review ladder and the phase close are
  NOT GATED on her hand-checks** — her words: "I can always
  address those later and you can make a note at the start of 13e
  to remind me of those checks (not gate on them)." The 13e plan
  this closeout authors OPENS with a reminder note (never a gate):
  the two hand-checks (⌘B in a take pane; the Read-scroll link
  click), the look/feel calls (bundle items i–v), and the #49–#52
  walk — all hers at leisure, the 13c/13f precedent (a phase
  closes with its walk riding the next opening).
- **Her roadmap question answered in the reply** (no ruling): the
  Fragments/joint-login work she remembers is Phase 14a (suite
  identity — the neutral stargazing account), not a 13-family row.

### Cold review — round 1 (2026-08-02, Fable; findings committed BEFORE fixes)

**Scope reviewed:** the phase's combined diff `74ddf48..HEAD` (85 files),
this plan file top to bottom, the canon docs, and the code under
`Sources/` and `App/` the phase touched. **Counts by this reviewer's OWN
runs on HEAD before any fix:** core "Test run with 1001 tests in 110
suites passed" · Mac "Test run with 1135 tests in 196 suites failed …
with 1 issue" — the ONE red isolated by a solo suite run and confirmed
to be EXACTLY the parked environment-gated tripwire
(`TakePaneMeasureTests.aStrandedRenderTierIsRebuiltByAConvergenceOccasion`,
its own KnownIssues row; this session ran unlocked) · mobile "Test run
with 14 tests in 4 suites passed". The plan carries no "Review foci"
section; the standing prompt alone governs.

#### Findings, severity-ranked

**R1-1 · MAJOR · notes/plans/phase-13g-formatting-lists-checkboxes.md
(ledger L17) + App/Variorum/Variorum/Features/BookView/MembershipChip.swift
· A RULED item was DROPPED — L17 (her WT-7 wording ruling) was never
built, and the ledger row misstates its route.** The mechanism, traced:
her round-4 ruling ("i'd update the text on that for clearer wording but
it seems good") was ROUTED as L17 with a recorded direction — the
diverge RECEIPT ("Open the Copy") must read as a receipt of the past
act, "tied to the past act and naming its book, e.g. the button carrying
the book name"; the DOOR ("Duplicate as Version") as an act; and the
pass must VERIFY what the "Editing here edits the note everywhere it
appears" explainer conditions on (suspected vacuous on a bookless note).
The ledger's status column says "batch 2 / acceptance" — but batch 2's
brief scoped "L7 ONLY", no batch record or acceptance ever mentions L17,
and `git log 74ddf48..HEAD -- …/MembershipChip.swift` is EMPTY: the file
was not touched once all phase. The explainer verification duty confirms
the suspicion: the sentence renders UNCONDITIONALLY in the popover body
(no membership gate — read at MembershipChip.swift:121), so a bookless
note (including the ORIGINAL right after a diverge moved it out of its
only book — exactly her screenshot's state) reads "everywhere it
appears" with no elsewhere in sight; and the receipt button is the bare
"Open the Copy" for both the diverge and the plain duplicate, naming no
book and no act. Severity rationale: the material impact is wording, but
a ruling of hers shipped with NO disposition — neither built, nor
honestly held for her word — and a ledger row that claims a route that
never happened is the drift class this phase's own WT-1 finding exists
to kill. **Disposition: FIXED by this reviewer** (the fix record below)
— built to the recorded ruling's letter, nothing invented beyond it.

**R1-2 · MINOR · App/Variorum/Variorum/Features/Help/HelperView.swift:350
+ App/Variorum/Variorum/Features/Tutorial/TutorialSeeder.swift:322 · Two
discoverability surfaces teach a landing that batch 7 made FALSE — the
WT-1 drift class, on the phase that named it.** The mechanism: batch 7
(R6-4) files every quick note under the `quicknote` tag into the smart
Quicknotes book, and `Queries.poolPosts` has excluded smart-collected
posts since 13f Stage B — so a quick note is NOT in the Pool (the batch
record and #52(g) say so, and `QuickNoteCopy.filedNote`/the pad's
placeholder were corrected). But the helper's "quick note" DICTIONARY
entry and the field guide's WORKSPACE lesson (batch 1's, seeded verbatim
into her store) both still end "…what you wrote is kept as a note in the
Pool." Batch 7's discoverability pass updated the tags/commits/divide/
seal lessons and added the "quicknote (the tag)" entry, but missed the
two surfaces describing the quick note's own landing — the exact class
her round-1 report opened the phase with. (Two stale comments ride
along: QuickNoteView.swift:37 and :217 still describe the Pool landing.)
**Disposition: FIXED** — both surfaces now name Quicknotes with the
one-untag road back to the Pool; `plan`/`seed` edited together so the
walk test holds; NOTE: this stales the seeded guide again — her ONE owed
Restore-Tutorial click (13f + batches 1, 4, 7) covers it, nothing new
for her to do.

**R1-3 · MINOR · App/Variorum/Variorum/Features/QuickNote/QuickNoteView.swift
(QuickNoteMint.file) · The filing REFUSAL arm speaks the SUCCESS wording
— and contradicts its own comment.** The mechanism: `fileAsQuicknote`
returns `.refused(reason)` when the tag/book ensure or the apply fails
(the note itself is safely minted); the switch then speaks
`"\(QuickNoteCopy.filedNote) (\(reason))"` — i.e. "Filed in Quicknotes —
tagged #quicknote. (the quicknotes shelf could not be reached)". The
claim is false precisely when it is spoken: the note carries NO tag, is
in NO smart book, and IS in the Pool. The comment four lines above says
"a refusal keeps the Pool wording, which stays true either way" — the
code does not do what its comment says (filedNote itself was rewritten
to the Quicknotes wording for every arm). **Disposition: FIXED** — the
refusal arm gets its own wording brain (`QuickNoteCopy.refusedFilingLine`,
pure so it pins): the note is kept, it is in the Pool, and the reason
rides along; the comment now matches the code.

**R1-4 · NIT · App/Variorum/Variorum/Features/BookView/ReadingFlowView.swift
(FlowPostView `.help`) · The one note-naming surface left outside the
R6-3 display brain.** `entry.title?.isEmpty == false ? entry.title! :
(entry.entryDate ?? "")` — an untitled, undated note gets an EMPTY
tooltip where every sibling surface now shows its date. Outside batch
7's letter (this spot rendered "" rather than "Untitled", so the sweep's
grep missed it), but it is the display brain's question asked the old
way. **Disposition: FIXED** (one line, `entry.displayTitle`; the brain
itself is pinned by `DisplayTitleTests` — clarity class, mechanism
stated, no separate pin owed).

**R1-5 · NIT · record-only · The batch-6 record's archived-chosen
characterization of the Notes-mode snippet is imprecise.** The record
(and the #51(d) neighborhood) says the snippet "resolves chosen →
default requiring that variant live … a snippet that moves to the next
block in that corner". Precisely: the SQL joins on
`v.id = COALESCE(chosen, default) AND v.deleted_at IS NULL` — a
TOMBSTONED chosen reads as empty and the snippet moves on (as recorded),
but an ARCHIVED-and-live chosen MATCHES, so the snippet shows the
archived take's text where `renderPost` would fall back to the default
take. A display aid diverging in a corner both records already class as
a simplification; recorded here precisely so the next reader is not
misled. No code change.

**R1-6 · NIT · record-only (a look item for her bundle) ·
`ReadTakesView`'s cards render raw markdown markers unstyled.** The
takes projection shows `**bold**` as plain undimmed text. Display ==
stored holds (no F-5 violation — the surface neither edits nor maps
clicks to offsets), but it is the one text surface wearing NEITHER face.
A look call, hers; routed to the 13e reminder note's look/feel bundle,
not fixed by fiat.

Nothing here routes to `notes/QUESTIONS.md`: R1-1's fix implements a
ruling she already made; R1-6 is a look offer, not a shipped PROVISIONAL.
**#53 remains the next free number.**

#### Clean bill (checked specifically, found solid)

- **F-1/F-2's one invariant:** `MarkdownStyling` writes ATTRIBUTES only —
  no code path inserts/removes a character; pinned byte-for-byte
  (`materializationStylesWITHOUTMovingASingleByte`,
  `aMarkdownHeavySessionLeavesTheStoreAndTheViewIdentical`) and the
  zero-write fast path honestly scoped (its comment claims the scan, not
  a layout pass).
- **The line-scoped law and its two consequences:** a span never crosses
  a newline (core pin) nor a block SEAM (Mac pin through the real
  editor); the edit computations take whole lines, so the cross-block
  merge arm is unreachable by construction — pinned INTO THE STORE (two
  blocks in, two blocks out, both bulleted).
- **TEXTKIT2 discipline:** no `NSTextList` anywhere; the face is real
  text-storage font/color attributes, never TK2 per-range rendering
  attributes; the §5 re-run (L15) is properly still owed at closeout.
- **P1:** keystroke rescan ∝ edited lines, pinned STRUCTURALLY
  (`MarkdownScanCount` lives on the scanner, 79 units on a 15.6k-char
  note; ⌘B < 500); measured costs flat across a 16× document sweep.
- **The join brain and the bridge:** `renderedText`, `exportPost`,
  `joinRenderedTexts` and everything under `Bridge/` are byte-untouched
  by the diff; the paged Read face builds TWO strings from ONE decision
  set with the stored body still pinned equal to `renderedText`
  (`theComposedBodyIsTheRatifiedProjection`); the only export lines are
  title PRESENTATION, which R6-3 explicitly ordered.
- **Zero `Sources/VariorumCore/Sync/` lines; ZERO schema** (no
  Persistence/migration files in the diff; mirror stays at marker 4);
  the quicknote book is settings + standing ops only, its designation
  read sharing ONE implementation with the daily book, liveness clause
  pinned (revert E).
- **The 13c K1 address rule:** Read's pagination measures the
  TRANSFORMED text but a page's name stays `(post, page-in-post)`
  identity; the estimator's marker-heavy over-count is honestly recorded
  as calibration territory.
- **The registry walks:** the eight formatting capabilities declared
  with doors and sweep-verified chords (⌘B/⌘I confirmed free by reading
  `EditorCommands.keyEquivalent`); declared ⇔ rendered still proven for
  both bottom bars after the R6-2 regroup
  (`theBottomBarsRenderExactlyTheDeclaredBarDoors`,
  `everyDoorTheGroupsSwallowedIsStillDeclaredByItsBar`); the helper
  drift guard + keyless-door + formatting-ceiling pins are real and
  honestly one-directional.
- **R6-3's load-bearing halves:** the mint stores `nil`; the literal
  "Untitled" reads as absent (carrying her existing rows); the date is
  the LOCAL calendar day matching `entry_date`'s kind of day, with the
  timezone-honest test discipline (fixture-clock trap recorded); the
  rename door seeds from `storedTitle`, never the displayed date.
- **The R5-5 crash fix:** the traced mechanism (a `GeometryReader`'s
  reported size fed back as a hard frame fighting the hoisted
  inspector's animating split) is coherent and the fix is the minimal
  correct one (accept the proposed size); the app-level red-on-old with
  byte-identical `.ips` is the model-layer honesty rule properly
  invoked.
- **Batch 5's flaky-pin fix:** poll-the-LAST-signal is the right
  mechanism; the window-holding deterministic pin is real (green in this
  reviewer's full run) and the three sibling re-points strengthen the
  pins (store/stack assertions kept, moved after the wait).
- **The mount rule:** `ReadTakesView` owns no authority, registers no
  handler, mounts no TK2 surface; `PaneFocusCatcher` observes and never
  consumes; `MarkdownFormattable` targeting is not a second liveness
  mechanism (it asks who holds the keyboard, which liveness decided).
- **QUESTIONS hygiene:** #49–#52 appended, properly OPEN for her walk,
  each call one line to change; KnownIssues rows all carry named owners
  (13e), per the R2-7 owner rule.

#### Fix records — cold review round 1 (the reviewer's own fixes, per the standing flow)

**R1-1 (MAJOR) — L17 built to her round-4 disposition's letter.** Two
pure wording brains so the promises are pinnable
(`MembershipChip.ascend`'s stated reason — a promise inside a view's
closure is a promise no test can keep):

- `DivergeCopy.openCopyLabel(book:)` — the receipt: with a book,
  `Open the Copy in “<book>”` (the diverge's landing button now carries
  the book that holds the copy — the disposition's own example); nil —
  the bare `Open the Copy` (a plain duplicate's copy has no book to
  name, and its own status line sits beside it). The chip holds
  `copyBookName` beside `duplicatedPostID` — set by `diverge(for:)`,
  nil'd by `duplicate()`.
- `MembershipChip.explainerLine(bookCount:)` — the explainer,
  conditioned on membership: ≥1 book keeps "Editing here edits the note
  everywhere it appears. To make a separate note that can diverge:"
  (R31/R35's truth, said where it IS true); 0 books gets the door's
  plain lead-in ("To make a separate, linked copy of this note:") —
  the vacuous claim gone from exactly the state her screenshot showed
  (the original, bookless right after its diverge).
- The DOOR ("Duplicate as Version") keeps its standing name — what the
  ruling wanted read-as-an-act is delivered by the receipt no longer
  competing with it. The ledger's L17 row corrected on the record.

*Pin:* `DivergeDoorTests.theCopyReceiptNamesItsBookAndTheExplainerNeedsAnElsewhere`.
*Red-on-old by behavioral revert, twice, each exactly discriminating:*
(A) `openCopyLabel` returning the bare receipt regardless → RED on the
book expectation, the other 5 suite tests green; (B) `explainerLine`
made unconditional → RED on the bookless expectation. Each restored,
`MembershipChip.swift` md5 `f61b72a9528dc8387f20893abaf013af` matched
both times. *The one un-pinned inch, stated:* the popover BODY wiring
(the view calling the two brains) is SwiftUI popover content no
headless pin reaches — one call site each, read in review.

**R1-2 (MINOR) — the two discoverability surfaces now teach the real
landing.** The helper's "quick note" dictionary entry and the field
guide's workspace lesson both end at Quicknotes now — the tag, the
smart book, and the one-untag road back to the Pool; `HelperView.entries`
made non-private for the pin (the `groups` precedent); the two stale
`QuickNoteView` header comments corrected with it. `plan`/`seed` moved
together — only BODY text changed, `theSeededBookMatchesTheLessonPlanExactly`
green throughout (verified under the revert too).

*Pins:* `QuickNoteWordTests.theHelperDictionaryTeachesTheQuicknotesLanding`
and `TutorialBookShapeTests.theWorkspaceLessonTeachesTheQuicknotesLanding`.
*Red-on-old by behavioral revert:* (D) the pre-fix helper sentence
restored → RED on both Quicknotes expectations, the refusal pin green
beside it (`HelperView.swift` md5 `654a1bec63d794abc30cbf108acdcde9`
restored-and-matched); (E) the pre-fix lesson sentence restored → RED
on all three lesson expectations with the plan==seed walk GREEN (only
body text moved — `TutorialSeeder.swift` md5
`9e07eb09cc9ccc20070b0c433d295d7a` restored-and-matched).
**A RE-SEED NOTE:** the workspace lesson's body changed again — her ONE
owed Restore-Tutorial click (13f + batches 1, 4, 7) covers this too;
nothing new for her to do.

**R1-3 (MINOR) — the filing refusal speaks its own true line.**
`QuickNoteCopy.refusedFilingLine(_:)`: "Kept as a note in the Pool —
the Quicknotes filing didn't take: <reason>." — true at the moment it
is spoken (the note is minted and durable, wears no tag, and the Pool
lists it); `QuickNoteMint.file`'s refusal arm speaks it, and the
comment that contradicted the code now matches it.

*Pin:* `QuickNoteWordTests.aFilingRefusalNeverClaimsTheQuicknotesLanding`.
*Red-on-old by behavioral revert:* (C) the pre-fix composition
(`"\(filedNote) (\(reason))"`) restored → RED on three expectations,
the helper pin green beside it (`QuickNoteView.swift` md5
`3611bd7389e9e7fa44c59dc531b14f6e` restored-and-matched).

**R1-4 (NIT) — the flow tooltip joins the display brain.**
`FlowPostView`'s `.help` now reads `entry.displayTitle` — the clarity
class (mechanism stated in the finding; the brain itself is pinned by
`DisplayTitleTests`), no separate pin owed.

**R1-5 / R1-6 — record-only, as found:** the snippet's archived-chosen
precision note stands in the finding; ReadTakesView's faceless markers
ride the 13e reminder note's look/feel bundle for her word (nothing
built by fiat).

**Scope of the fix pass:** five files under `App/Variorum/Variorum/`
+ three test files + this plan file. Zero `Sources/` lines (core and
mobile stand by construction at this reviewer's own HEAD runs:
1001/110 · 14/4); zero `Sync/` lines; no schema; `renderedText`/export/
bridge untouched; her `/Applications` instance never addressed.

**Final counts after the fix pass, this reviewer's own runs** (the "Test
run with N tests" line): core **1001 tests in 110 suites passed**
(untouched by the fixes — the HEAD own-run stands) · Mac **1139 tests in
197 suites**, failing ONLY on the parked environment-gated tripwire
(`TakePaneMeasureTests.aStrandedRenderTierIsRebuiltByAConvergenceOccasion`
— its own KnownIssues row; this session ran unlocked; +4 tests +1 suite
over HEAD's 1135/196, exactly the four review pins and their one new
suite) · mobile **14 tests in 4 suites passed** (untouched by the
fixes — the HEAD own-run stands) · the tutorial spine green by TYPE
name, **51 tests in 7 suites** (from 50/7 — the workspace-lesson pin
joined it). **The round is CLOSED at round 1 from this reviewer's side:
every finding fixed with a discriminating revert-verified pin, or
honestly record-only.**

### Orchestrator acceptance — cold review round 1 (2026-08-01)

- **Commits `846c970` (findings, committed before fixes) +
  `7474343` (fixes) verified by own inspection:** 9 files in the
  fix pass, scoped to the findings (the chip, quick-note surfaces,
  the two teaching surfaces, the flow tooltip, pins, records).
- **Counts by the orchestrator's OWN runs:** core "Test run with
  1001 tests in 110 suites passed" · Mac "Test run with 1139 tests
  in 197 suites failed … with 1 issue" — the one red confirmed BY
  IDENTITY via a solo suite run (the parked tripwire, same test,
  same assertion). Mobile untouched by the fix pass (App-only
  diff); 14/4 stands. Every reviewer claim matched.
- **R1-1 accepted with the orchestrator's own accountability on
  the record:** the dropped L17 was an ORCHESTRATION miss — the
  ledger said "batch 2 / acceptance" but no brief ever carried it;
  the ladder caught exactly the class it exists to catch. The fix
  is the round-4 disposition's letter, nothing invented.
- **R1-6 (raw markers in ReadTakesView) routed to the 13e
  reminder-note bundle** beside the look items, per round 7's
  no-gate ruling. R1-2's re-seed note folds into the ONE owed
  Restore-Tutorial click.
- **Process note (the quoted-run-line rule, this time on the
  orchestrator):** the round-1 acceptance Mac run was launched
  from the repo root FOUR times in a row (a repeated-command loop;
  cwd does not persist for backgrounded `cd` compounds) before
  being rewritten with an explicit `-project` path — which is
  cwd-independent and is the shape this orchestrator will use for
  every remaining run. No wrong number was ever recorded (the
  stray runs were killed, exit 144, none produced a counted line).
- **Round 1 ACCEPTED. Round 2 spawns now** — a FRESH cold
  reviewer re-reviewing the fixes and what they touched (the
  ladder's real-pass rule; new BLOCKER/MAJOR ⇒ round 3, cap 3).

### Cold review — round 2 (2026-08-01, Fable; a FRESH reviewer — the ladder's real-pass rule)

**Scope re-reviewed:** the round-1 fix diff (`7474343`, 9 files) as
fresh code, the findings record (`846c970`), every round-1 disposition
against the code and the phase's rulings (the plan file read top to
bottom; the round-4 sitting record is the L17 anchor), and the fixes'
neighborhoods (`MembershipChip`/`DivergeCopy` + `MultiBookEditNote`,
the quick-note word surfaces end to end incl.
`Operations+Quicknote.fileAsQuicknote`, the seeder's plan/seed
mechanism, `ReadingEntry.displayTitle` + `DisplayTitle`). **Counts by
this reviewer's OWN runs on HEAD:** core "Test run with 1001 tests in
110 suites passed" · Mac "Test run with 1139 tests in 197 suites
failed … with 1 issue" — the ONE red confirmed BY IDENTITY as the
parked environment-gated tripwire
(`TakePaneMeasureTests.aStrandedRenderTierIsRebuiltByAConvergenceOccasion`,
its own KnownIssues row; unlocked session) · mobile "Test run with 14
tests in 4 suites passed" · all SEVEN tutorial-spine suites green
inside the full Mac run.

#### Verdicts, per round-1 disposition

- **R1-1 (MAJOR, the dropped L17) — HOLDS.** The finding's premise
  re-verified independently: `git log 74ddf48..846c970 --
  MembershipChip.swift` is EMPTY (zero commits all phase before the
  fix) and batch 2's brief says "Scope: L7 ONLY" — the ledger's old
  "batch 2 / acceptance" route never happened; the row now says so.
  The fix matches the round-4 disposition's letter: the receipt
  (`DivergeCopy.openCopyLabel(book:)`) names the book the diverge
  landed in, driven by `copyBookName` — set by `diverge(for:)`, nil'd
  by `duplicate()`, both arms read coherent (a refusal leaves the
  prior receipt pair untouched together); the explainer
  (`MembershipChip.explainerLine(bookCount:)`) says "everywhere it
  appears" only where an elsewhere exists — and `books` includes
  smart matches (derived membership IS membership), so the claim is
  true wherever it now renders. The pin discriminates by
  construction (pure-string containment against exactly the pre-fix
  behaviors) and is green in this reviewer's run. Neighborhood
  checked: `MultiBookEditNote.sentence` speaks "everywhere" only at
  `bookCount >= 2` (`shouldSpeak`) — never vacuous, consistent; no
  other surface renders an "Open the Copy" receipt (grep-verified).
  **The one judgment call, endorsed on the record:** the DOOR keeps
  its standing "Duplicate as Version" name — the ruling's
  door-read-as-an-act half is delivered by the receipt no longer
  competing with it (the label is already an imperative act phrase,
  and its `.help` states the act); the fix record says exactly this
  rather than claiming more. Any further door wording is hers (the
  look/feel bundle).
- **R1-2 (MINOR, the quicknote-landing drift) — HOLDS.** Both
  surfaces now teach the R6-4 landing with the one-untag road back;
  every OTHER quick-note word surface swept independently and found
  consistent (the pad's placeholder, the hint, the "quicknote (the
  tag)" dictionary entry, the corrected `QuickNoteView` header
  comments; `grep "in the Pool"` across app sources returns only
  true claims). The plan==seed mechanism is sound by construction —
  the plan holds chapter/lesson NAMES, bodies are seeded from the
  one literal — so the walk stayed green while the body moved. Both
  pins discriminate (the pre-fix texts lack "Quicknotes" and carry
  the banned phrase); the workspace-lesson pin properly joined the
  spine (7 suites, all green in the full run).
- **R1-3 (MINOR, the refusal toast) — HOLDS.** `refusedFilingLine`'s
  claims traced TRUE in every refusal arm reachable from its one
  speaker: `QuickNoteMint.file` runs the mint and the filing in ONE
  serialized runner turn, so nothing can interleave, and every
  reachable `.refused` (tag/book ensure or apply failure) leaves the
  note minted, untagged, bookless — exactly "kept, in the Pool", with
  the reason carried. (The `quicknoteResidualReason` "the note is no
  longer there" arm exists for other callers and is unreachable from
  this speaker — noted, not a finding: no pin could go red on an
  unreachable path.) The pin discriminates; the comment now matches
  the code.
- **R1-4 (NIT, the flow tooltip) — HOLDS.** `ReadingEntry.displayTitle`
  routes to the ONE `DisplayTitle.note` brain (pinned by
  `DisplayTitleTests`), and `assembleReading`'s SELECT carries
  `created_at`, so the tooltip degrades date-ward, never to "".
- **R1-5 / R1-6 (record-only) — HOLD as recorded.** No code change;
  R1-6 rides the 13e reminder-note bundle per the acceptance.

#### Revert & scope integrity, verified

The four restore checksums in the round-1 fix record match this
reviewer's own md5s of the committed files EXACTLY
(`MembershipChip.swift f61b72a9…`, `HelperView.swift 654a1bec…`,
`QuickNoteView.swift 3611bd73…`, `TutorialSeeder.swift 9e07eb09…`) —
the revert dance left no residue; the working tree is clean. The fix
pass is App + tests + plan only (stat-verified): zero `Sources/`
lines, zero `Sync/` lines, no schema (no Persistence/ lines in the
whole phase diff; `Bridge/` byte-untouched; the join-brain functions
untouched), her `/Applications` instance never addressed by this
round either. One extra truth check beyond round 1's: the
plain-duplicate status's "in the Pool until you shelve it" stays TRUE
even for a duplicate of a smart-collected quicknote, because
`duplicateAsVersion` deliberately copies no tags (its doc states it;
the copy is untagged and bookless).

**NEW findings: NONE — at any severity.** No round 3 is owed.
`notes/QUESTIONS.md` untouched (#53 remains the next free number).
**THE LADDER CLOSES AT ROUND 2.**

## THE CLOSEOUT (2026-08-01)

- **Final counts (orchestrator's own runs):** core 1001/110 · Mac
  1139/197 (the ONE tripwire red confirmed BY IDENTITY; its
  KnownIssues row, owner 13e) · mobile 14/4 · tutorial spine 51/7.
  NO schema all phase (mirror at marker 4); zero `Sync/` lines;
  `renderedText`/export/the bridge's join brain byte-untouched
  (re-verified by the round-2 reviewer over the whole phase diff).
- **L15 DISCHARGED:** the TEXTKIT2 §5 spike re-run on macOS 26.5.2
  — ZERO canary events whole-run
  (`Spikes/TK2Spike/results-2026-08-01-macos26.5.2.log`, archived
  beside the 26.4.1 and 2026-07-30 logs).
- **Every ledger row dispositioned:** L1–L12 SHIPPED (L5 completed
  by her L5 word + batch 6's takes projection; L9's held halves
  ride the 13e reminder note); L13 the sweep (one row RESOLVED at
  its mechanism, one DEEPENED → 13e capture-first); L14 → 13e (her
  round-4 ruling); L15 discharged; L16 EXECUTED (the 13e plan
  authored — the reminder note at its top, W26 at its opening
  sitting, the four-row kickoff sweep); L17 BUILT at the review
  (R1-1 — the dropped routing owned by the orchestrator on the
  record). Rounds 5–6's rulings all shipped (batches 6–7) or held
  exactly as ruled.
- **The ladder:** closed at ROUND 2 — round 1: 1 MAJOR / 2 MINOR /
  1 NIT fixed + 2 record-only, every fix red-on-old with
  discriminating reverts; round 2 (fresh reviewer): ALL SIX
  dispositions HOLD, ZERO new findings.
- **QUESTIONS:** #49–#52 OPEN for her walk, riding 13e's opening
  reminder note (her round-7 no-gate ruling); #53 next free.
  **KnownIssues:** the shell-redo row RESOLVED and removed; the
  windowless row deepened → 13e; the note-window-clip and A47c
  rows added → 13e; the find&replace takes-half and 11a
  copy-doors rows stay 13e's.
- **Canon:** AppSpec §14's 13g delta (own commit `a285bac`).
  **Handoff:** `notes/handoffs/phase-13g-handoff.md` (her
  checklist at the top). **The 13e plan:**
  `notes/plans/phase-13e-takes-block-management.md`, paste-ready.
- **The final `/Applications` refresh executed at this closeout**
  behind a fresh backup under her standing round-7 authorization
  (review fixes included; relaunched for her).

**THE PHASE IS SEALED.**
