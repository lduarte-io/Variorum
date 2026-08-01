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
| L13 | The kickoff sweep: the shell-redo flaky pin trace + the windowless-launch/quit-hang characterization (both KnownIssues rows, owner 13g) | sweep batch |
| L14 | W26: the true global quick-note hotkey — SLOTTED to 13e's opening sitting (her round-4 ruling; supersedes round 2's later-in-13g reading) | → 13e |
| L17 | WT-7: the chip popover's wording pass — the diverge RECEIPT ("Open the Copy") must read as a receipt of the past act, the DOOR ("Duplicate as Version") as an act; verify what the "Editing here edits the note everywhere" explainer conditions on (vacuous on a bookless note) | batch 2 / acceptance |
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
