# Phase 13f — Workspace

**Status: KICKED OFF by the author 2026-07-30 under `/architect-phase`**
(her invocation, with a large kickoff message — recorded verbatim-faithful
in "THE KICKOFF SITTING" below). She picked 13f as the next phase at
the 13d sitting (her K4 "soonest" rank). **Cast: pending her
confirmation at the opening sitting** (the recommended default is the
13d/QoL shape — Fable orchestrator · a fresh Opus implementer per
batch · ONE Fable cold review at phase end).

## Binding principles (the P-1…P-9 constitution — copied VERBATIM at kickoff per the skill's requirement; byte-exact from 13b's plan file via 13c's and 13d's copies)

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

**The skill's "Applying the constitution" precisions bind here as
written there** (P-1's routed-vocabulary scope + `.surface`; P-3's two
surface kinds — the full-document editor is never absorbed; layer
placement + parity-by-forwards; the overlay/sink delivery law), and
the 13d closeout's "Standing notes for successors" + the 13c plan's
"Stage 4 lessons" and "Environment traps" sections bind by reference.

## Kickoff message (paste-ready for the orchestrator/coordinator the author invokes)

> You are running Variorum Phase 13f under the shape the author picks
> at kickoff (`/architect-phase` fits — windows/tabs composition is
> design-heavy and wants sittings; `/run-phase` if she prefers it
> spec-driven after an opening design sitting). Read IN FULL first:
> `CLAUDE.md`, `notes/CoreDescription.md`, `notes/OverallModel.md`,
> `notes/AppSpec.md` (§12, §14's 13c/13d deltas),
> `notes/plans/phase-13d-refusal-ergonomics-floor.md` (the P-1…P-9
> constitution it carries binds 13f identically; its closeout's
> "Standing notes for successors"; its environment sections bind by
> reference to the 13c plan's traps), `notes/TEXTKIT2_NOTES.md`, this
> plan, and the 13c plan's "Author intake, 2026-07-25" ledger rows
> A25–A30 + A32 (her verbatim asks). Verify the baselines with your
> own runs. Copy the constitution into this file verbatim at kickoff
> if running under `/architect-phase`. OPEN WITH A DESIGN SITTING —
> the window/tab/split composition questions below are hers, not
> pre-decided.

## Baselines at open (verify with your own runs)

Core **901/101** · Mac **876/145** · mobile **14/4** — the 13d finals,
verified by the 13d orchestrator's own runs 2026-07-28 at `2c44d9f`+.
No schema change since v1_12; mirror at lockstep marker 4.

## Scope (the K3 roadmap's row; her ledger rows verbatim in the 13c plan's intake table)

| Row | Item (hers) | Notes |
|---|---|---|
| A25 | Two posts side by side in one window | The Compare/side-by-side machinery is takes/lens-axis; this is the WORKSPACE axis — two independent posts, each an ordinary editing surface. P3 binds: ONE live editor migrating (`PaneTextAuthority` — the 13d batch-3 flight-latch trigger sentence fires HERE if both sides carry structural doors: the latch moves to a post-keyed shared authority) |
| A26 | Several windows / a split window | Window architecture: scene composition, per-window state, the one-live-editor rule ACROSS windows — the liveness authority's biggest test yet; never a second mechanism |
| A27 | Tabs of open notes with ⌘⇧1… | Open-note tabs + ordinal shortcuts; registry-declared (P-1); check the ⌘⇧ collision space (13d batch 4's sweep pin is the precedent and the guard) |
| A28 | Starred notes | Star = metadata; the shape (a tag? a column? a pin-like setting?) is a design-sitting question — a new column is a §12 lockstep event and needs her explicit go |
| A29 | The quick-note sticky format | Her sticky-note capture shape; composes with the Pool and quick-entry — sitting question |
| A30 + A32 | The workspace set's remaining rows + the infinite-scroll editor idea | Read her verbatim rows in the 13c intake ledger before scoping; the infinite-scroll idea is exploratory — sitting material, not committed |
| K5 | The `post` → `note` UI-STRING-ONLY sweep | STRINGS ONLY: `container.kind='post'` and the canon docs keep the model term (her K5 ruling verbatim — the ratified vocabulary stays unmuddied). A sweep batch with a registry/copy walk |

## Binding constraints (from the master plan's row + the 13d closeout)

- **P3 holds across windows:** ONE live editor, ONE liveness authority
  (`PaneTextAuthority`) — no second liveness mechanism, ever. Any
  cross-window/cross-post liveness extension lands ON the authority.
- **The 13d flight-latch trigger** (recorded in 13d batch 3): the
  moment any composition mounts Write and a takes/lenses board on ONE
  post with structural doors on both sides, the model-local
  `structuralInFlight` latch MUST move to a post-keyed shared
  authority. A25/A26 are the likely first customers — check before
  building, not after.
- **The P-1…P-9 constitution** binds (copy verbatim at kickoff); the
  registry grows to cover new doors as work touches them.
- **No schema change without her explicit ruling** (A28's star shape
  is the candidate) — a §12 lockstep event, mirror-first, her go-ahead.
- **Environment:** the 13c plan's traps section by reference (the 13d
  additions: the mobile scheme's OS 26.2 destinations are iPhone
  17-family/16e; lock-flag exceptions #2/#3 — keep the probe, not the
  prediction).

## Candidate opening-sitting agenda (bring as question batches)

1. The window model: tabs-in-one-window vs multiple windows vs both;
   what ⌘⇧1… addresses (tabs? windows?).
2. A28's star shape (schema-touching options need her §12 go).
3. A29's sticky format: capture door, where stickies live, their
   relationship to the Pool.
4. The side-by-side composition: what sits beside what (two Write
   editors? Write + board?), and the one-live-ring behavior she wants
   across panes/windows.
5. Carried one-liners from 13d if still unanswered: extract-inherits-
   A11; the ⌥⌘N alias.

## Verification

Per-batch: the standing loop (build → pins → the tutorial spine green
→ full suites, counts confirmed by the "Test run with N tests" line —
never a bare SUCCEEDED; all three suites when `Sources/` or `Shared/`
is touched). Review shape: the author sets it at kickoff. Red-on-old
absolute; the hallucination guard binds; every PROVISIONAL to
`notes/QUESTIONS.md` (append, never renumber — next free number at
authoring time: **#49**).

## THE KICKOFF SITTING — 2026-07-30 (author-attended; her kickoff message recorded verbatim-faithful, uncertainty preserved; triage below is the architect's, her confirmations pending where marked)

She invoked `/architect-phase` with the paste-ready kickoff and a large
intake. Opening mood, hers: *"overall things are looking great"* · *"the
app is looking amazing. couldn't be more excited about it!!"* · *"I
showed my coworkers this app and they were already quite impressed with
it! I think we have something quite special."*

### A. The QoL-round taste walk (the handoff checklist's feel walk — her verdicts)

1. **Typewriter room (A22): works.** *"the whitespace underneath works
   great on write"* — **NEW RULING: "i would also like to have that
   whitespace option on takes."* This EXTENDS A22's ruled Write-only
   scope (the 13d sitting deliberately scoped it to the post editor);
   the Takes board is a pane surface, so the mechanism is its own build
   (the board's scroller, not the full-document editor's frame). Ledger
   W7.
2. **Slot split (QoL item 3): works.** *"the longer slot split look
   works great and I like that it's draggable"* — **NEW RULING: "but
   carousel needs the same treatment."** This SUPERSEDES the QoL
   round's carousel-keeps-the-ruled-110 scoping (S4-31b had already
   been superseded for slot split only; her ruling now extends
   natural-height + shorten-drag to CAROUSEL too). The QoL round's
   carousel-byte-unchanged pins flip deliberately when built. The rail
   strip was not named — ask before touching it. Ledger W8.
3. **The divide ceremony's cut ticks — NEW RULING:** *"I also think we
   don't need all those lines to show where you can cut - I feel like
   it's pretty clear that it only jumps to in between words."* Remove
   the cut-affordance tick marks; the snap behavior itself is
   untouched. Ledger W9.
4. **Margin grid: accepted.** *"the margin grid note style is done
   well, I like how it looks."*
5. **The divide ceremony's unchecked-take door — HER QUESTION, and a
   real findability finding:** *"I tried doing a divide and I see that
   it says 'won't come to either new block' if I don't select it,
   remains whole on the original one, but how do I even see the
   original one? I tried going to the history of one of the post
   divide takes but I don't see it. So I'm a little confused on what
   that door is supposed to be."* ANSWERED at the sitting (see the
   orchestrator's reply): the original block A is preserved whole —
   unchecked takes stay on it — and is RELEASED from the post
   (unplaced, per the W's ratified shape); today's doors are ⌥⌘Z
   (restores A's placement, the whole divide reversed) and the
   Recovery surface's unplaced-blocks list (Library ▸ Recovery),
   which offers "Place in pool". A successor take's HISTORY will never
   show A — commits are per-variant and never copied (I5's letter).
   **The finding:** neither the ceremony copy nor the completion names
   where the original GOES, and the Recovery door is obscure from the
   ceremony's vantage. Candidate fixes for her taste (propose-only
   until she picks): name the destination in the ceremony/completion
   copy; a lineage door on successors ("show the block this came
   from" via the existing derived_from edge). Ledger W10.

### B. Bugs from her daily use (findings — trace first, the hallucination guard binds)

6. **Chapter reordering in a book:** *"It does appear like there's a
   small bug with manual book order - i haven't been able to move the
   chapters in between the posts (which did used to work). I don't
   know if that's related to the manual order or if we have a
   different phase addressing the chapter…"* Untraced; candidate
   neighborhoods (NOT conclusions): the A31 order-override faces
   (13c 2D), the navigator's chapter reorder, 13d batch 1's Book/
   Outline flips. Ledger W11.
7. **Scrap drag-into-post dead:** *"there's a bug right now where
   trying to drag a standalone block into a post is just not
   working."* The sidebar Blocks (scraps) drag — `poolDragCopy`'s
   face, shipped Phase 10. Untraced. Ledger W12.

### C. Design directions recorded (owners marked; nothing built from these without her word)

8. **Smart-book identity — her direction, verbatim (this REOPENS
   N38's shape question toward the hybrid the memo called shape B;
   QUESTIONS #46(1) recorded shape B as "a phase's worth of design,
   not a flag"):** *"I think it would probably be best if we allow
   constantly updating 'smart books' based on just tags and then if
   you try to do something (post limit, lock it, new chapter name,
   manual reordering, etc) it's now a named book. and it can still
   have the smart attributes and keep auto adding despite being a
   particular named book, but I do think making changes should mean
   it has to be a particular smart book."* Also hers: *"I think it
   should be at least noted for that phase if we don't handle it
   now."* Triage: a DESIGN MEMO is owed before any build (P-5; the
   S4-16 condition if deferred out of 13f) — the keeps-collecting +
   hand-curation union is exactly the knot #46(1) named (what does
   the capacity gate count; the chaptered-post-whose-tag-left case).
   Owner: her call at this sitting — 13f sitting-conversation + memo
   now, build at a books-flavored slot. Ledger W13.
9. **Markdown mode — recorded FOR 13G's opening design sitting (its
   plan row already reserves exactly this fork), her words:** *"I know
   a lot of people use markdown religiously, so I'm interested in
   trying to consider if we should have a 'markdown mode' where you
   can write actual markdown and have it format as a particular
   setting to have on, with the default just being like normal rich
   text editor for bolding, italics, etc., but that can still export
   correctly as markdown. again, not sure if that's the right phase
   for this, but worth considering and talking about the tradeoffs
   for."* Carried to the 13g sitting's agenda; nothing decided.
10. **Naming — "notes" wobble, hers verbatim (feeds THIS phase's K5
    sweep):** *"I'm wondering if 'notes' is the best word for it. it
    seems natural. there's 'notes' and then I was previously using
    'posts' which seems too social media-y, but then saying that
    several 'notes' make up a chapter seems a little weird. I like
    blocks for how direct of a word it is."* The K5 sweep is
    UI-strings-only either way (`container.kind='post'` and the canon
    docs keep the model term). Sitting question — the sweep builds to
    her pick. Ledger W14.
11. **"Blocks" sidebar section → "Snippets", hers:** *"I also am
    considering a rename of the 'Blocks' pool to 'Snippets' in the
    UI, to make it clearer that it's more for reusable blocks that
    you can drag into any post."* UI-string rename of the R44 sidebar
    word (the scraps section); rides the K5 sweep batch if she
    confirms. Ledger W15.
12. **Better links / back-navigation, hers:** *"one thing that i
    think should be added to the plan for the 13 phases, maybe not in
    this phase since it's already quite full … I want better links -
    right now when you're in write, there's no easy way to get back
    to the book you were in that you just clicked in from. so I think
    a way to go back to where you just navigated from should be an
    option. i also think in compare that you should be able to click
    on the post you're comparing it with."* Triage: navigation
    between open things is the same fabric as tabs (A27) — the
    architect recommends designing it WITH the tab/window model at
    this phase's sitting, building only if room (her "maybe not this
    phase" honored — the slotting question is hers). Ledger W16.
13. **Compare's full-editor want re-affirmed = A25/A26/A27's core,
    hers:** *"compare is surfacing the issue i already brought up of
    really wanting to be able to edit two unrelated posts side by
    side, full editor. because compare calls for the posts to
    actually have a fully functional write editor *if I wanted that*,
    and I'd like being able to open multiple windows and being able
    to open multiple 'post/note' windows within the app as well,
    without it being a separate window. both are existing wants."*
    Confirms the committed scope; the design sitting's composition
    questions carry it.

### D. Roadmap additions (her instruction: "just toss these items on the roadmap, we don't even need to discuss them right now")

Three unslotted rows added to the master plan's phase table this
sitting, her words quoted there: **whole-library text search** (*"a
phase dealing with searching through text more thoroughly for the
whole library will have to be considered (LOTS of potential technical
implementations there, we'll probably handle that after the existing
13 phases, I think that subdivisions for searching books / posts /
etc. will be valuable)"*) · **grammar & spellchecking** (*"we'll need
a phase for dealing with grammar / spellchecking / etc."*) · **more
export options** (*"and more export options in the future"*).

### The 13f ledger (running; every row owned)

| Row | Item | Status |
|---|---|---|
| W1 (A25) | Two posts side by side in one window | committed scope — design sitting |
| W2 (A26) | Several windows / a split window | committed scope — design sitting |
| W3 (A27) | Tabs of open notes, ⌘⇧1… | committed scope — design sitting |
| W4 (A28) | Starred notes | design sitting (star shape; schema needs her §12 go) |
| W5 (A29) | Quick-note sticky format | design sitting |
| W6 (K5+A30) | `post` → `note` UI-string sweep | word pending her pick (W14); sweep batch |
| W7 | Typewriter-room option on Takes (her 2026-07-30 ruling) | RULED — opening batch candidate |
| W8 | Carousel gets slot split's natural-height + shorten-drag (her ruling; supersedes the QoL carousel scoping) | RULED — opening batch candidate |
| W9 | Remove the ceremony's cut tick marks (her ruling) | RULED — opening batch candidate |
| W10 | Divide-W original-block findability (her confusion; propose-only options) | recorded — her pick at sitting |
| W11 | BUG: chapter reorder between posts broken | trace + fix — opening batch |
| W12 | BUG: scrap drag-into-post dead | trace + fix — opening batch |
| W13 | Smart-book identity direction (N38 shape-B reopening) | design memo owed; owner = her call |
| W14 | The naming question ("notes"?) | sitting question |
| W15 | "Blocks" → "Snippets" | sitting question; rides K5 sweep if confirmed |
| W16 | Back-navigation + Compare click-through | design with A27 at sitting; slotting hers |
| W17 (A32) | Infinite-scroll editor idea | exploratory — sitting material, not committed |
| W18 | QoL-handoff standing items (field-guide re-seed; extract-blank-line one-liner) | hers / carried |
| W19 | Kickoff sweep: the `theShellRedoActionRunsThroughTheRunnerAndReports` flaky pin (KnownIssues row owned by 13f) | trace when in that code — kickoff-sweep item |

### Sitting rulings — round 1 (2026-07-30, question batch 1)

1. **CAST RULED: the 13d/QoL shape** — Fable orchestrator · a fresh
   Opus implementer per batch · ONE Fable cold review at phase end.
2. **OPENING FRICTION BATCH: YES, all five** — W11 + W12 (traced
   first) and the three ruled QoL follow-ons W7/W8/W9 build first,
   while the design sitting continues. (The rail strip stays
   UNTOUCHED in W8 — she named carousel only; offered and not
   contradicted.)
3. **W16 back-navigation: DESIGN + BUILD IN 13F** — her pick of the
   recommended option; back-nav and Compare's click-through are
   designed WITH tabs as one navigation model.
4. **W15 RULED: "Blocks" → "Snippets"** — UI string only, rides the
   K5 sweep batch.

Ledger updates: W7/W8/W9/W11/W12 → batch 1 (opening friction batch);
W15 → RULED, sweep batch; W16 → committed scope, designed with W3.

### Sitting rulings — round 2 (2026-07-30, question batch 2: the window model)

1. **W1/A25 — TWO PANES in v1, with a standing architecture rider,
   hers verbatim:** *"I think two panes is the right choice for v1,
   but I would make a note for the future that free tiling is on my
   desire list. It's not worth it at this exact moment, but make sure
   the architecture isn't going down a road closed to that because it
   would be nice in the future."* → BINDING: the pane/workspace
   architecture must not foreclose free tiling (no two-pane
   assumptions baked into the liveness authority, tab routing, or
   layout state). Free tiling joins the desire list, unslotted.
2. **W3/A27 — per-window tab strip, IN THE SIDEBAR, hers verbatim:**
   *"I'm fine with the per-window tab strip but i don't think it
   should be above the editor - i like the clean look there. i'd use
   the free space that's underneath 'library / shelf / pool /
   blocks' for now"* → open-note tabs render as a sidebar section
   below the four standing sections ("for now" — placement
   revisitable); ⌘⇧1…9 jumps by position; the editor chrome stays
   clean.
3. **W2/A26 — BOTH window kinds** (her pick of the recommendation):
   File ▸ New Window = a full app window; "Open in New Window" on a
   note = a lightweight note-only window. ONE live editor across all
   windows — the liveness authority extends, never a second
   mechanism.
4. **W16 — history + named back chip, WITH a collapse door, hers
   verbatim:** *"I think that you should be able to collapse the
   named back chip if you want - I like how clean the editor looks
   right now."* → per-pane history (⌘[ / ⌘]) + the "← <origin>" chip,
   chip collapsible; Compare's peer post opens through the same
   history.

### Sitting rulings — round 3 (2026-07-30, question batch 3)

1. **W4/A28 — stars = a synced `setting` list + a Starred sidebar
   section** (her pick of the recommendation; the `shelf_pins`
   precedent — ZERO schema, no §12 event): up to 5 notes or books,
   star/unstar via context menu + ⌘K, section at the sidebar's top.
2. **W5/A29 — the quick note is a FLOATING MINI-WINDOW** (her pick):
   global shortcut / menu-bar door; typing mints an ordinary bookless
   note (Pool lists it); the sticky face shows no takes machinery;
   the note persists when the window closes.
3. **W14 — THE WORD IS "NOTE"** (her pick): the K5 sweep proceeds
   post→note, UI strings only, plus the ruled Blocks→"Snippets"
   rename (W15).
4. **W13 — smart-book identity gets ITS OWN NEW PHASE, hers
   verbatim:** *"i would make a new phase with a short brief on what
   you know about the shape of the problem (whatever the next unused
   letter in the 13 series is I suppose), i'll just handle it fully
   in another phase. i haven't really thought through it a lot yet."*
   → **Phase 13i** (the next unused letter — 13b–13h exist) with a
   short problem-shape brief, authored this sitting:
   `notes/plans/phase-13i-smart-book-identity-brief.md`. Nothing
   built; the brief binds nothing beyond her recorded words.

### Batch 1 brief — the opening friction batch: W7 · W8 · W9 · W11 · W12 (fresh Opus implementer; self-contained)

**Read IN FULL before touching code:** `CLAUDE.md` + the canon it
loads; THIS plan file (the constitution, THE KICKOFF SITTING, the
sitting rulings above); the 13c plan's **"Environment traps"** section
(binding — instance discipline, run-line proof, `pipestatus`, no
custom build configurations, checksums before reverts); in
`notes/plans/qol-round-2026-07-29.md`: the batch records for the
**divide-ceremony drawn geometry brain** (W9's target), the
**typewriter room third mechanism** (W7's Write-side precedent), and
**slot split's drag + view-memory storage** (W8's grammar — including
the recorded `TakesViewMemory` decode-compat trap: adding a Codable
field silently resets stored view memory); the 13d plan's batch-5 A22
record. Then the code each item names.

**The items:**

1. **W7 — the typewriter-room option on TAKES (her ruling).** Write's
   room is the QoL round's grow-the-document mechanism on the
   full-document editor; the Takes board needs its OWN room —
   scrollable allowance below the board's content (~one viewport
   page, matching Write's feel), reachable through REAL input paths
   (the pin-gap lesson is standing law: pin via scroller/knob paths,
   not internal APIs). A click in the room should land focus at the
   end of the LAST take pane's text (the A22 "room is space the caret
   can enter" doctrine). P-3 binds: no second liveness mechanism — if
   the click-lands-focus half can't ride the board's existing focus
   path simply, STOP and propose that half. Zero store bytes (pin).
2. **W8 — carousel adopts slot split's natural-height + shorten-drag
   (her ruling; SUPERSEDES the QoL round's carousel-keeps-110
   scoping).** Same grammar as slot split: natural full height by
   default, the grab bar pulls shorter with in-place scroll, drag
   back to natural = full again, double-click resets, heights
   remembered per block in the SAME local view-memory family (respect
   the decode-compat trap — follow the storage shape slot split
   shipped). The QoL round's carousel-byte-unchanged pins flip
   DELIBERATELY — name every pin change in the batch record. **The
   rail strip is UNTOUCHED** (she named carousel only).
3. **W9 — remove the ceremony's cut tick marks (her ruling,
   verbatim: "we don't need all those lines to show where you can
   cut - I feel like it's pretty clear that it only jumps to in
   between words").** Rendering only: the tick affordance goes; the
   snap rule, the ✂ slot, click/drag/arrow behavior, checkbox
   semantics all byte-unchanged (their pins run green unmodified). A
   ruled flip, not a bug fix — update only pins that assert tick
   presence, and name them.
4. **W11 — BUG, TRACE FIRST: chapter reordering between posts.** Her
   report verbatim: *"i haven't been able to move the chapters in
   between the posts (which did used to work)."* Trace the chapter
   reorder path (the book navigator's chapter drag/reorder,
   `reorderSection`, and the surfaces 13d batch 1 / 13c 2A–2D
   touched) to a concrete mechanism BEFORE any fix; red-on-current
   pin; fix; revert-verify. If the trace lands on a DESIGN conflict
   (e.g. an order-override interaction) rather than a defect, STOP
   and report — that is a product question, not a patch.
5. **W12 — BUG, TRACE FIRST: scrap drag-into-post dead.** Her report
   verbatim: *"trying to drag a standalone block into a post is just
   not working."* The sidebar scraps (Blocks/Snippets section) drag
   into an open post — `poolDragCopy`'s face (Phase 10; ⌥-drag
   carries the fan). Same discipline: mechanism → red pin → fix →
   revert-verify. If the drop path died with a newer surface (the
   pane surface, registry routing), trace to the seam and fix at the
   seam's level, not with a bypass.

**Loop (binding):** build → pins (red-on-old verified by behavioral
revert for W11/W12; checksums before every revert) → the tutorial
spine green on its own run (`Tutorial*Tests` by TYPE name) → full
suites: core `swift test` from the repo root, Mac from `App/Variorum/`
— quote the "Test run with N tests" line (the ONLY proof; zsh
`pipestatus`); run mobile ONLY if `Sources/` or `Shared/` is touched
(destination: the iPhone 17-family/16e note). **Baselines to
match-or-beat: core 903/102 · Mac 933/151 · mobile 14/4.** Append
your batch record to THIS file under "Batch records" (changes, files,
every pin change named, counts by your own runs, PENDING marks).
Commit per convention with the standing trailer (one commit per item
is fine if the diffs read cleaner). **Never** refresh `/Applications`
(installs at her word only), never touch `Sources/VariorumCore/Sync/`,
never push, never `git checkout` over uncommitted work. If any item
turns out materially bigger than its ruling's shape, STOP on that
item and return with a proposal.

## Batch records

*(Implementers append here — one record per batch.)*

### Batch 1 — the opening friction batch (W7 · W8 · W9 · W12 BUILT; **W11 STOPPED with a trace**); commits `2f01988` · `e3c09d1` · `8b2ff48`

**Counts, by my own runs at build-complete:** core `✔ Test run with 903
tests in 102 suites passed after 30.194 seconds` (`swift_exit=0`) · Mac
`✔ Test run with 939 tests in 152 suites passed after 136.438 seconds`
(`xcodebuild_exit=0`) · tutorial spine on its own run, by TYPE name
(`TutorialBookShapeTests` + `TutorialDoorTests`): `✔ Test run with 14
tests in 2 suites passed after 4.308 seconds`. From the batch's
baselines (903/102 · 933/151 · 14/4): **+6 Mac tests, +1 suite**; core
byte-unchanged. **Mobile deliberately NOT run** — zero `Sources/` and
zero `Shared/` lines (verified by `git status`), so the loop's own
condition for running it is unmet; the round's 14/4 stands.

**No schema. Zero `Sync/` lines. No Release build, no `/Applications`
refresh.** Her app was not running at any point (`pgrep` checked at
open; the discipline held throughout). Two pre-existing uncommitted
author files (`notes/DetailedPlanForPhases.md`,
*[removed for publication]*
was staged by explicit path.

#### W12 — the scrap drag into a post (BUG; traced, then measured)

**The mechanism, measured on macOS 26.5.2 before anything changed.**
AppKit's destination sequence is `draggingEntered` → `draggingUpdated` →
**`prepareForDragOperation`** → `performDragOperation`, and a `false`
from the THIRD step ENDS it — the fourth is never sent. `EditorTextView`
overrode the first, second and fourth (all correct, all reachable in
isolation) and **never the third**, and `NSTextView`'s own
implementation answers **false** for a pasteboard carrying only
`io.lduarte.variorum.poolblock`. Probe output, both editor variants:
`entered/updated = .copy`, `prepare = false`, and with the gate
overridden the pool branch runs and consumes. So the drag showed the
copy cursor the whole way in and then did nothing — her report exactly,
and nothing to do with `poolDragCopy`, the payload, the pool listing, or
the ScrapsPanel.

Ruled OUT by measurement on the way (recorded so nobody re-walks them):
`isEditable`/`isRichText` writes do NOT drop a custom registered drag
type (`updateDragTypeRegistration` was the first suspect — probed
through a full window lifecycle, the type survives every write), and the
payload/registration halves were already pinned green.

**Fix:** one override — `prepareForDragOperation` answers true for the
pool type, else `super`. At the level the contract lives; no bypass.

**THE PIN-GAP, and it is the transferable part:** every shipped
pool-drag pin drove `performDragOperation` (or `model.poolDrop`)
DIRECTLY, skipping the gate AppKit does not skip — a green suite over a
feature that could not be used. New pin
`theWholeAppKitDropSequenceReachesThePoolBranch` drives all four steps
against the real text views from `makeEditor()` and `makeInlineEditor()`.

**Revert W12-A** (checksummed; `shasum -c` OK after restore): the
override deleted ⇒ the new pin fails at exactly the prepare assertion in
BOTH variants (2 issues) and every other pin in the suite stays green.

Recorded with it: **SwiftUI's hosting drop path calls PRIVATE selectors
on the dragging info** (`_lastDragDestinationOperation` — measured by
crash), so a hand-rolled `NSDraggingInfo` can drive an `NSTextView`
destination and can **never** drive a `.dropDestination`. That asymmetry
is why W11's half below is honestly unpinnable.

#### W11 — chapter reordering: **STOPPED, per the brief's own escape**

Her report: *"there's a small bug with manual book order - i haven't
been able to move the chapters in between the posts (which did used to
work)."* The brief's instruction: trace to a concrete mechanism BEFORE
any fix; if the trace lands on a DESIGN conflict rather than a defect,
STOP and report. **It lands on one, and there is no defect I can prove.**

**What I verified, at every layer I can drive:**

1. **The operations layer is correct.** A throwaway core probe ran
   `reorderSection` through the exact `InsertPosition`s the two doors
   emit — `.after(next)` / `.before(previous)` — and the section order
   round-tripped ["I","II","III"] → ["II","I","III"] → back → ["I","III","II"].
   (Probe deleted; not shipped.)
2. **The model door is pinned green and untouched.**
   `BookStructureTests.chapterDragDropsBeforeTargetOrAtTheEnd` drives
   `moveChapter(_:before:)` incl. the end zone, the no-op edges and a
   foreign payload.
3. **The drag machinery is BYTE-IDENTICAL to the build she confirmed
   worked.** `git show <commit>:BookView.swift | grep draggable|dropDestination`
   across `23b0c12` (13b 3E N21, where she reported the dots "make me
   feel like it should be draggable and it isn't" and they were made
   draggable) → `2492ac0` → `681851e` → `f9cf009` → `8c07717` → HEAD:
   the same two sites in the navigator and the same two in the body, at
   shifting line numbers and nothing else. No regression exists in this
   code.

**What the trace DOES show — the reach and the semantics:**

- A chapter's ONLY drop targets are (a) another chapter's header and
  (b) a 14 pt end zone. Everything between two chapters — every post
  row, every gap — is not a target. Dropping A on B means "A goes
  BEFORE B", so **moving a chapter DOWN one slot has no target at all
  unless a third chapter follows it**; with two chapters the only way
  down is the 14 pt strip at the very end of the book. That alone
  produces "I haven't been able to move the chapters."
- Since 13c 2A the space between two chapter headings in the Outline
  BODY is a whole post's prose (and since 13d batch 1, a card), so the
  targets shrank against everything around them. The body header also
  carries no `.contentShape(Rectangle())`, so its hit area is the
  glyphs, not the row — the navigator's is a `Button` and takes the row.
- **And the literal reading of her words is not expressible in the
  model:** a chapter's `position` orders chapters among chapters, and
  posts belong to chapters by `reading_post.section_id` assignment.
  "A chapter in between the posts" has no meaning to place — deciding
  what dropping a chapter between post 3 and post 4 SHOULD do (re-anchor
  it before that post's chapter? split the chapter? re-assign the posts
  below it?) is inventing product behavior.

**Why I did not fix the reach half anyway:** the hallucination guard.
Every candidate fix here is a drag-geometry change, and the drag route
into SwiftUI cannot be driven in this host (measured above — the private
selector), so nothing I could ship would carry a red-on-old pin. A fix
without a pin, on an item whose diagnosis is a product question, is
exactly the class the guard exists to refuse.

**For the orchestrator / her:** the cheap, invention-free half is an
explicit **"Move Down"/"Move Up" pair that already exists in the chapter
context menu** (`chapterMenu` — verified correct at the ops layer
above); if her drag keeps failing, the honest first answer is that those
menu items work today and the drag's targets are too few. The design
question — should a chapter be droppable anywhere between posts, and
what would that mean — is hers.

#### W9 — the ceremony's cut ticks (a ruled flip, not a bug fix)

Rendering only. The tick at every legal cut position is gone; the hover
highlight went with it (it was one of those lines, thickened, and its
only consumer was the tick — a hover tracker that changes nothing on
screen is state churn per mouse move, 13d judgment call 1's class).

Everything the slots DO is untouched and that is what keeps this a
rendering change: `slotWidth` still puts the gap between two words (so
the wrap arithmetic and every cached geometry are byte-identical),
`nearestSlot` still resolves clicks and drags, `isStrong` still gives
sentence ends and newlines their extra catch, `slotFrame` still places
the ✂.

**PIN CHANGES: none.** No pin asserted a tick's presence (the flow is
drawn in a `Canvas`), so all 15 pins across `DivideCeremonyCostTests` +
`WCutPlacementTests` pass **UNMODIFIED** — the parity proof a ruled flip
wants.

#### W8 — carousel adopts slot split's natural height + shorten-drag

Her ruling extends the QoL round's supersession of S4-31b/N40 to
carousel; that round scoped it to slot split deliberately and pinned
carousel's 110 as CHARACTERIZATION. `carouselBloom` is now byte-for-byte
`slotSplitBloom`'s composition. **The rail strip is UNTOUCHED** (she
named carousel only; its pin passes unmodified).

**Judgment call, recorded:** the height store is SHARED with slot split
(the same `takesSlotHeights.<postID>` key, the same per-block entry). It
is one question, one geometry (both go through `pagedTakesRow` →
`containerRelativeFrame` at the same `beneathCount`) and one natural
height; two stores would give a block two remembered heights with
nothing on screen to say which she set. The `TakesViewMemory`
decode-compat trap is respected by construction — nothing was added to
that struct.

**PIN CHANGES, every one named:**
- `carouselKeepsTheRuledFixedCardHeight` → **`carouselShowsALongTakeAtFullLength`**
  — a DELIBERATE FLIP: inverted, not deleted (same measurement, opposite
  expectation), and its `measuredHeightWrites == 0` half flips with it
  (carousel subscribes to the measurement seam now, because it sizes a
  wrapper).
- **+ `aShortenedCarouselSlotReEntersTheInCardScroll`** (new, red on old).
- **`paneMeasurementIsIndependentOfCapping` REWORKED**: it compared
  carousel (capped) against slot split (uncapped), and this ruling made
  both arms the same state — it would have gone on passing while
  asserting nothing. The capped arm is now made by SHORTENING (the only
  way a card is capped at all now), so T4's "the cap saved DRAW, not
  LAYOUT" is under test again.
- Unchanged and passing: `theRailShortBlockStripKeepsItsOneCardHeight`,
  every slot-split pin, the seam settle + deferral pins.

**Revert W8-A** (checksummed, restored byte-identical): carousel back to
`railCardHeight` ⇒ exactly the two carousel pins red (3 + 1 issues),
slot split and the rail green. **A green revert got a stronger arm
first:** the drag pin originally dragged to the FLOOR — which IS
`railCardHeight`, indistinguishable from the retired fixed height, so it
passed on the reverted code. It drags to 400 now, a height the
pre-ruling code cannot produce.

#### W7 — the typewriter room on the takes board

**It is NOT a fourth A22 mechanism, and that is the design point.**
Write's room is a scroll allowance on an `NSTextView`'s document frame —
three mechanisms to get right, because an allowance is invisible to half
the input paths. The board's article is an ordinary SwiftUI
`ScrollView`, so the room is ordinary **content extent**: a clear box
below the last row, which the wheel, trackpad, knob and paging all reach
by construction. There is no allowance to be blind to. The HEIGHT is the
shared brain (`TypewriterRoom.height` — viewport less one line), so the
two surfaces feel alike and neither can drift.

**The click-lands-focus half rides the board's existing focus path**, so
the brief's STOP condition was not reached: `focusWithCaretAtEnd` →
`focus` → the authority. P-3 holds — exactly one live pane, one liveness
authority. The caret half is a new single-purpose seam on the pane
surface: a monotonic token meaning "put your caret at the end", inert at
zero, **baselined at construction so a remount never acts on its own**,
and applied only to a pane liveness already reached. It cannot become a
second liveness mechanism (it moves a caret INSIDE a pane; it never
decides which pane is live), and the room is its only caller —
`TakesCellView`'s parameter defaults to 0, so Lenses, Compare, the TOC
and the book surfaces read exactly as before.

Target selection: the LAST slot's shown take, in the article column —
except under a slot-split bloom, which replaces the article cell, where
it is the fan namespace (the same branch `articleRow` itself takes).

**New suite `TakesRoomTests` (4):** the room inside the article scroll
view's `documentRect` **and inside the scroller's own maximum travel**
(the knob path A22 was specifically blind to); the landing's ring +
caret; **ZERO STORE BYTES** (blocks and text byte-identical before and
after — A22's "allowance, never content", pinned); the seam inert
without a request.

**Reverts** (checksummed, restored byte-identical): **W7-A** the room
removed ⇒ the extent pin red with the numbers stated (`document 328` =
the rows alone, vs `rows + room = 831`), caret pins green · **W7-B** the
caret request never applied ⇒ exactly the landing pin red (`{0,0}` vs
`{47,0}`).

**Two non-vacuity findings, both found by a pin FAILING** (kept because
either would have made a hollow green pin):
1. **A live pane's caret already sits at its text end** — AppKit puts it
   there when `string` is set. Asserting "end" on a fresh pane proves
   nothing, so the landing pin puts the caret at 0 first and the
   inert-seam pin parks it at 3.
2. **The board lands its own ring at mount**, so "nothing is live
   before the click" was simply false; the pin asserts the ring MOVES to
   the last block instead, which is the stronger claim anyway.

#### Environment traps (new this batch)

1. **`scrollPageDown:` on a hosted SwiftUI `ScrollView`'s document view
   does not return in this test host** — a 7-minute run produced no
   output and had to be killed; bisected to that one call. The
   reachability claim rides `documentRect` + the scroller's maximum
   travel instead, which is the number the knob is computed from. (Note
   the shape: it reads exactly like the batch-1 `timeout`-binary trap —
   a hang that is really a tool.)
2. **`NSDraggingInfo` fakes cannot drive SwiftUI drops** — the hosting
   path sends `_lastDragDestinationOperation` (private) and the process
   terminates on the unrecognized selector. AppKit destinations
   (`NSTextView` and friends) are drivable; `.dropDestination` is not.
3. zsh applies history modifiers inside double quotes, so
   `git show "$c:App/…"` silently becomes `$c:A` + `pp/…`. Assign the
   path to a variable first (`p=App/…; git show "$c:$p"`).

#### For the orchestrator

- **W11 needs her**, not a patch — the trace and the two candidate
  readings are above.
- **PENDING, deliberately:** nothing. No PROVISIONAL was created, so
  `notes/QUESTIONS.md` is untouched (next free number stays **#49**).
- Her walk will notice, beyond the four rulings: a carousel bloom now
  has a grab bar under it exactly as slot split does, and its cards can
  be tall enough to change how a fanned block reads at rest; and the
  takes board can now scroll past its last block, which it never could.

#### Batch 1 — ACCEPTED (2026-07-30; the orchestrator's adjudication)

**Counts by my own runs** (not the implementer's): core `✔ Test run
with 903 tests in 102 suites passed` · Mac `✔ Test run with 939 tests
in 152 suites passed` — both match the record's claims exactly; tree
clean at `7f03d8b` except the author's own two uncommitted files
(hers, untouched by every commit — staged-by-explicit-path verified).

**Load-bearing diffs read:** W12's fix is ONE override at the level
the AppKit contract lives (`prepareForDragOperation` answers true for
the pool type, else super) — no bypass, and the new four-step
full-sequence pin closes the recorded pin-gap (every old pool-drag pin
drove step four directly; the suite was green over a feature that
could not be used — the QoL round's pin-gap lesson recurring in a
second input family, now pinned at the real path). W9's zero-pin-change
parity is the ruled-flip proof done right. W8's flip is named
pin-by-pin, and the strengthened drag arm (to 400, a height the
pre-ruling code cannot produce — after the floor-drag arm passed green
on the reverted code) is the guard working as designed; the SHARED
height store judgment call is ENDORSED (one geometry, one natural
height, one question — two stores would give a block two remembered
heights with nothing on screen to disambiguate) and flagged for the
end-of-phase Fable review. W7's not-a-fourth-mechanism design is
ENDORSED — content extent on a SwiftUI ScrollView is reachable by
construction, exactly the class of simplicity A22's three mechanisms
never had available; the caret-request seam is baselined at
construction and inert at zero, and it moves a caret INSIDE a pane
without ever deciding liveness, so P-3 holds.

**The W11 STOP is ACCEPTED as the brief's escape working:** three
layers verified sound (ops probe round-trip; the pinned model door;
drag machinery byte-identical across every commit since she confirmed
it working), the reach analysis is concrete (two targets only — a
chapter header and a 14 pt end zone; a two-chapter book cannot move a
chapter down by drag at all), and the literal ask ("a chapter in
between the posts") is genuinely inexpressible in the
assignment-based chapter model — deciding what that drop MEANS is
hers. The unpinnable-SwiftUI-drag measurement (private selector,
crash-verified) makes any drag-geometry fix un-red-pinnable; the
guard was applied correctly. → HER RULING via the sitting (question
posed 2026-07-30).

**New environment traps endorsed into the standing record** (the
hosted-ScrollView `scrollPageDown:` hang; NSDraggingInfo fakes never
drive `.dropDestination`; the zsh history-modifier `git show` trap).

**Ledger:** W7 BUILT · W8 BUILT · W9 BUILT · W12 BUILT (all
adjudicated) · W11 → awaiting her ruling.

### Sitting rulings — round 4 (2026-07-30, after batch 1's adjudication)

1. **W11 RULED, hers verbatim:** *"i think we should fix the reach,
   but it should also be possible to pick up a post and move it to
   another chapter."* → TWO halves build in batch 2: (a) the
   chapter-drag REACH fix (chapters keep reordering among chapters;
   generous targets — whole-row hit areas, gap targets so a
   two-chapter book can move a chapter down; a drop between posts
   snaps to the nearest chapter boundary); (b) **post-drag-to-chapter**
   — a post row is draggable onto a chapter (assignment via the
   standing `assignPostToSection` op + ordering via the standing
   position machinery; no new semantics). The DIVIDER reading of
   chapter drag (a heading drop between posts re-binning them) is
   recorded as a knot in the 13i brief for that phase's sitting.
2. **W10 RULED: copy + lineage door** — the ceremony's unchecked-take
   line and the completion/status copy NAME where the original goes
   (Library ▸ Recovery; ⌥⌘Z), AND successors gain a "Show Original
   Block" door riding the existing `derived_from` edge.

### Batch 2 brief — W10 (both halves) + W11 (both halves) (fresh Opus implementer; self-contained)

**Read IN FULL before touching code:** `CLAUDE.md` + the canon it
loads (AppSpec §9's divide/divideW/`assignPostToSection`/
`reorderSection` entries; §12); THIS plan file (constitution, THE
KICKOFF SITTING, sitting rulings 1–4, batch 1's record — its W11
trace IS your starting map, and its environment traps bind: the
hosted-ScrollView `scrollPageDown:` hang, NSDraggingInfo fakes never
driving `.dropDestination`, the zsh `git show` history-modifier trap);
the 13c plan's "Environment traps" section (binding); the QoL round's
ceremony batch record (the copy-on-the-controls grammar W10a extends).

**The items:**

1. **W10a — the ceremony copy names the destination.** The
   unchecked-take semantics line (QoL round: "unchecked = stays whole
   on the original block, in neither successor") gains where the
   original GOES: Library ▸ Recovery, and ⌥⌘Z undoes. The
   divide-completion status line (the 13d "Block divided — ⌥⌘Z undoes
   it." grammar) says it too when a W-divide released an original
   with unchecked takes. Fit the existing copy grammar; no new
   mechanism.
2. **W10b — the "Show Original Block" lineage door.** On a block
   whose `derived_from` edge (divide/divideW/merge origin) points at
   an ancestor with NO live placement: a context-menu door (registry-
   declared, P-1 — the `.surface`/`.contextMenu` conventions) that
   navigates to the Recovery surface and reveals that block
   (scroll-to/highlight per the surface's existing affordances; if
   reveal needs NEW plumbing beyond navigation + selection, keep it
   to navigation and record the gap rather than inventing). P-2:
   fire-and-DO; a block with no such ancestor renders no door.
3. **W11a — the chapter-drag reach fix.** Per her ruling: whole-row
   hit areas on chapter headers (`.contentShape(Rectangle())` — the
   batch-1 trace named the glyph-only body header), drop targets in
   the gaps between chapters (meaning "before the next chapter" /
   "to the end"), so a TWO-chapter book can move a chapter down; a
   drop between posts snaps to the nearest chapter boundary.
   Semantics UNCHANGED — chapters reorder among chapters via the
   pinned `moveChapter`/`reorderSection` path. **The pin honesty
   rule from batch 1 binds:** the SwiftUI drag route is unpinnable in
   this host (measured — private selector), so pin at the MODEL
   layer (any new target-resolution logic as pure functions with
   their own pins) and RECORD what is visual-verification-only for
   her walk / the Design & UI review row. No un-tested claim.
4. **W11b — post-drag-to-chapter.** A post row (Outline body +
   the navigator list — wherever post rows render in a chaptered
   book) is draggable onto a chapter header or between posts of
   another chapter: assignment = `assignPostToSection`, position =
   the standing fractional-index machinery; a drop under a LOCKED
   reading fires the op and delivers its real refusal (P-2 — the
   locked reading freezes assign, #25(b)). Registry-declared.
   Model-layer resolution logic pure + pinned; the drag route's
   visual half recorded as above. If the surface turns out to need
   a second drag payload type colliding with the standing post/block
   payloads, STOP and propose.

**Loop (binding), identical to batch 1's:** trace → build → pins
(red-on-old by behavioral revert where a pin CAN go red; checksums
before every revert; the model-layer honesty rule above) → tutorial
spine green by TYPE name → full suites with quoted "Test run with N
tests" lines (core from the root, Mac from `App/Variorum/`; mobile
only if `Sources/`/`Shared/` is touched). **Baselines to
match-or-beat: core 903/102 · Mac 939/152 · mobile 14/4.** Append
your batch record under "Batch records"; commit per convention with
the standing trailer, staging by EXPLICIT PATH ONLY (two author
files sit uncommitted in the tree — `notes/DetailedPlanForPhases.md`
*[removed for publication]*
`/Applications`, never `Sources/VariorumCore/Sync/`, never push,
never `git checkout` over uncommitted work, no schema. STOP and
propose if any item exceeds its ruling's shape.

### Sitting rulings — round 5 (2026-07-30, the sequencing ruling)

Her words: *"i'll have that session commit it. … so 13g will be next,
you'll author that phase's plan during your closeout, and leave a
note for 13g to author 13e. and then I guess I'll choose what's after
13e."* → RULED: **13f → 13g → 13e**, then her choice. The 13f
closeout authors 13g's plan (from the standing 13g row + her recorded
markdown dual-mode inclination) AND carries an explicit note that
**13g's closeout authors 13e's plan**. What follows 13e is chosen at
that point (the remaining 13-series rows then: 13h, 13i). The
release-strategy files stay uncommitted for HER session to commit —
this phase's commits keep staging by explicit path around them.

### Batch 2 — W10 (both halves) + W11 (both halves), ALL BUILT

**Counts, by my own runs at build-complete:** core `✔ Test run with 906
tests in 102 suites passed after 29.511 seconds` (`swift_exit=0`) · Mac
`✔ Test run with 958 tests in 154 suites passed after 134.031 seconds`
(`xcodebuild_exit=0`) · mobile `✔ Test run with 14 tests in 4 suites
passed after 0.219 seconds` (`mobile_exit=0`) · the tutorial spine on
its OWN run, by TYPE name (`TutorialBookShapeTests` · `TutorialDoorTests`
· `TutorialWritingActsTests` · `TutorialTakesActsTests` ·
`TutorialStructureActsTests` · `TutorialLookingActsTests` ·
`TutorialLibraryActsTests`): `✔ Test run with 49 tests in 7 suites
passed after 12.159 seconds`. From the batch's baselines (903/102 ·
939/152 · 14/4): **+3 core tests · +19 Mac tests, +2 suites**; mobile
byte-unchanged. **Mobile WAS run** — `Sources/` carries two files this
batch, so the loop's condition is met.

**No schema. Zero `Sync/` lines. No Release build, no `/Applications`
refresh.** Her app was not running at any point (`pgrep` by path at open
and at close). HEAD moved under me mid-batch — her own three notes
commits (`f3b5251` · `db1cf12` · `11a8a0e`) landed while I built, so the
two "uncommitted author files" the brief names are now hers and
committed; every commit here still staged by explicit path, and nothing
under `notes/` outside this record was touched.

#### W10a — the ceremony names where the original goes

Her question was a findability finding, and the missing half was one
sentence in three places. All three now say it, and — the part that
makes it a fix rather than a patch — they say it by reading ONE name.

- **`RecoveryPath`** (new, in `RecoveryView.swift`): `menuLabel` ·
  `unplacedSection` · `surface` · `unplacedBlocks`. The **doors that
  render those labels read it too** — the Library ⋯ menu item, the ⌘K
  palette row, and this view's own section header — so the sentence and
  the label cannot drift apart.
- The sheet's two sentences moved OUT of `Text` literals into
  `DivideWCeremony.checklistExplainer` / `.uncheckedRowNote`, for one
  reason: **a promise made in a `Text` literal is a promise no test can
  keep.** They are pinned now.
- The completion speaks: `DivideWCeremony.releasedOriginalNote(
  uncheckedTakes:)`, spoken through the host's own status voice from
  `confirm()` — Write's toast, a board's status line, **no new
  mechanism**. `nil` when every take was checked (the original is still
  released, but nothing she wasn't shown rode away, and a note on every
  divide is noise where the ruling asked for an answer).

**DEVIATION FROM THE BRIEF'S WORDING, deliberate:** the brief says
"Library ▸ Recovery". **No surface in this app has ever shown the word
"Recovery"** — `SidebarSelection.recovery` is an internal case name, and
the door she can actually find reads **"Archived & Deleted"** under
Library's ⋯ menu, with an **"Unplaced blocks"** section inside it. Copy
naming a door that does not exist would defeat the entire item, so the
shipped copy is `Library → Archived & Deleted → Unplaced blocks` — which
is ALSO the grammar the merge ceremony has spelled out for its
stay-behind takes since 13b (arrow character included). The divide's
half of that same sentence was simply missing.

**Judgment call — a small scope-adjacent fold, and why:** the five
PRE-EXISTING sites that already spell this path (the merge ceremony
sheet, `EditorSurfaceController`'s two merge-status pairs, the helper's
lineage paragraph) now read `RecoveryPath` too. Without it the "one
name" claim in the new type's own doc comment would be false the day it
shipped. Zero behaviour change, proven: the two existing pins that
assert this copy (`MergeCeremonySheetTests`'
`confirmingThePrePairedSheetReproducesTheInstantOutcome` and
`BoundaryFluidityTests`' `mergeOnFannedBlocksSpeaksAboutTheFan`, both
asserting `status.contains("Unplaced blocks")`) pass **UNMODIFIED**.

#### W10b — the "Show Original Block" lineage door

The road back from a successor to the block it came from. The edge has
existed since Phase 3 and nothing had ever walked it.

- **Core: `Queries.unplacedOrigins(_:inContainer:)`** — for each live
  block placed in a post, the blocks its OWN `derived_from` edges point
  at (DIRECT edges: the block's own origin, not its ancestry) that are
  live and **have no live placement**. Sorted, so the pick is
  deterministic on every device; several origins are normal (a merge
  releases both sources). Cost is one indexed pass over the post's
  placements — the `renderPost` class, and it rides the same projections.
- **Reach, both editors, one field each:** the takes board reads it off
  `Queries.TakesProjection.unplacedOrigins` (a new field on the
  projection it already re-reads on exactly the writes that change it);
  Write gets `observeUnplacedOrigins`, the third per-block map beside
  presentations and comments, because **a menu builder runs
  synchronously and must never touch the store** (P2).
- **Registry:** `CapabilityID.showOriginBlock` — block scope,
  `[.contextMenu]`, `takesAccess: .native` (R118 — Write is not
  privileged), availability `takeFamily`. Rendered ONLY where an origin
  exists, the `.diffAgainstChosen` precedent exactly: the CONTEXT rule is
  the registry's, the per-TARGET condition is the surface's (P-2).
- **P-4 at the act:** invoking posts `.variorumRevealUnplacedBlock` with
  the block id and speaks; `RootView` decides that means `.recovery`
  (the `.variorumOpenPost` precedent, one level up). The surface never
  navigates itself.

**Judgment call — I built the REVEAL, not just the navigation.** The
brief's escape ("if reveal needs NEW plumbing beyond navigation +
selection, keep it to navigation and record the gap") was aimed at
inventing a highlight subsystem. What shipped is stock SwiftUI and no
new concept: a one-shot reveal id on the shell (the
`router.pendingSelection` consume pattern), a `ScrollViewReader`
`scrollTo`, and a `listRowBackground` mark on the row. Navigating to an
unbounded list of unplaced blocks *without* saying which one would have
left the findability finding exactly where it was.

#### W11a — the chapter-drag REACH fix

Batch 1's trace stands: **no defect exists in the chapter drag**, and
this batch did not invent one. The pinned model door
(`chapterDragDropsBeforeTargetOrAtTheEnd`) passes **UNMODIFIED** — the
parity proof that the semantics are untouched. What changed is reach.

- **The body's chapter header was glyph-only** (batch 1 named it): it now
  carries `.frame(maxWidth: .infinity)` + `.contentShape(Rectangle())`,
  so the target is the full-width row **including its 28 pt of top air**
  — which IS the gap between one chapter's last post and the next
  chapter's heading. That is the "target in the gap" her ruling asked
  for, with no second view to keep in sync. The navigator's rows got the
  same treatment.
- **Post rows are chapter drop targets now**, resolving to the NEAREST
  chapter boundary — and that is what actually answers her report: with
  two chapters, "before" was the only meaning a drop could carry, so
  moving one DOWN had no target at all. Dropping it on a post in the
  second chapter's lower half now resolves to the end.
- The end zones grew (navigator 14 → 28; the Outline body's 14 → 44,
  where it sits after a whole book's prose).

**"Nearest" is measured in ROWS, not pixels** — a post in the top half of
its chapter takes the boundary above, the bottom half the boundary below.
Rows are what the model knows; geometry would put the rule where no test
can reach it.

#### W11b — post-drag-to-chapter

`BookStructureModel.filePost` — assignment through the standing
`assignPostToSection`, order through the standing `reorderReadingPost`,
**no new semantics and no new operation**. A FINISHED book fires the op
and delivers its real refusal (#25(b)), pinned.

**The payload question the brief said to STOP on — resolved WITHOUT a
stop, and here is the reasoning.** A chaptered book now drags two kinds
of thing over the same targets, and the shipped payload was a bare
`section.id`. `BookStructureModel.BookDrag` discriminates by PREFIX
(`book-chapter:` / `book-post:`) — the `LensesBoardView.dragPayload`
(`lens-move:`) precedent, already in the app. It is still ONE `String`
transferable, so **no new payload type meets the standing post/block
drags**, and it is strictly safer than before: a foreign payload (a
scrap, a catalog hit, a lens block) now decodes to nil and is refused,
where the bare-id era let it reach the model and relied on an id lookup
to reject it.

**Position is written only when position is what she is LOOKING at**
(`repositionsOnDrop(viewOrder:)`: the A31 view override, else the
reading's stored `sort_field`, must be `.manual`). Under a stamp sort the
drop still files the post — that is her ruling — but rewriting a stored
manual order she cannot see would be an invisible edit.

**Judgment call — where the drag SOURCE lives.** Navigator post rows drag
whole-row; in the Outline body the expanded post's HEADER and the
collapsed CARD drag, and the prose does not (an expanded post shows a
live editor or a read-cheap surface, and a drag over those would fight
selection). `Button` + `.buttonStyle(.plain)` + `.draggable` is not a
guess: it is the exact construct the navigator's chapter rows have used
since 13b 3E, and her own report confirms those rows' clicks work.

#### THE FINDING WORTH CARRYING FORWARD

**`assembleReading` already orders a chaptered curated book BY CHAPTER**
(`ORDER BY (s.id IS NULL), s.position, s.id, rp.position`). Consequence
for anyone touching book order: a post moving DOWN into a later chapter
lands at that chapter's top **for free**, from assignment alone — so a
pin written on that direction asserts nothing about repositioning. Found
by revert W11b-A running GREEN on exactly that shape; the pin was
rewritten to move a post UPWARD, where the membership position has to be
written or it lands at the chapter's END.

#### Pins — every change named

**New suites (2):**
- **`OriginBlockDoorTests` (9)** — W10 whole: the sheet's two sentences
  name the path · the completion is conditional, singular/plural honest
  and carries ⌥⌘Z · a real three-take ceremony confirm SPEAKS the
  destination · an all-checked confirm keeps the ratified completion
  byte-for-byte · the registry declaration · a real divide-W gives BOTH
  successors the door and it names A · **a plain divide's successor gets
  NO door** (the placement rule, at the surface) · the broadcast + speech
  · the board's projection carries the origins and its door acts.
- **`BookDropTests` (6)** — W11 end to end: **her two-chapter
  down-move** · a post drop files AND lands where it was dropped · a
  header drop lands at the chapter's TOP (moving upward) · a FINISHED
  book speaks the op's own refusal for both drag kinds · the dispatcher
  routes by payload kind and refuses foreigners · repositioning follows
  the rendered order.

**Grown existing suites (2):**
- `BookStructureModelTests` **+4**: the payload codec · the
  nearest-boundary table (her scenario as a table) · a one-row chapter ·
  the post-drop plan table.
- `LineageQueryTests` (core) **+3**: a divide-W's successors name the
  released original · a merged block names BOTH sources, sorted · a
  still-placed origin never offers the door (and a re-placed one retires
  it).

**Pins MODIFIED: none.** `chapterDragDropsBeforeTargetOrAtTheEnd`,
`MergeCeremonySheetTests`, `BoundaryFluidityTests` and every ceremony pin
pass unmodified — the parity proof for a reach fix and a copy fold.

**Reverts (checksummed with `shasum -a 256`; every file restored and
verified OK before the next):**
- **W10a-A** — the sheet's sentence stops at "the original" and the
  completion never speaks ⇒ **3 W10a pins red (9 issues)**, the 5 W10b
  pins green. Exactly discriminating.
- **W10b-A** — the query's `NOT EXISTS (live placement)` clause deleted
  ⇒ core `aStillPlacedOriginNeverOffersTheDoor` red (2 issues) and Mac
  `aPlainDividesSuccessorGetsNoDoorBecauseItsOriginIsStillOnThePage` red
  (2 issues). **A GREEN REVERT GOT A STRONGER ARM FIRST:** on its first
  run the Mac suite passed the revert entirely — the door pins only ever
  exercised blocks with no origin at all — so the plain-divide arm was
  added before the work was trusted.
- **W11a-A** — the nearest-boundary rule loses its bottom half ⇒ the
  boundary table red on exactly the two bottom-half rows, and **her
  two-chapter down-move end-to-end pin red**.
- **W11b-A** — `filePost` files but never repositions ⇒ both order pins
  red. Same story as W10b-A: the header-drop pin passed the revert until
  it was rewritten to move a post upward (the `assembleReading` finding
  above).

#### VISUAL-VERIFICATION-ONLY — for her walk and the Design & UI review row

Batch 1 measured that the SwiftUI drag route cannot be driven in this
host (the hosting path sends the private `_lastDragDestinationOperation`
and the process terminates on the unrecognized selector). Every DECISION
below it is pinned at the model layer; **these halves are not, and no
claim is made that they were tested:**

1. That a chapter header's hit area really covers its row and its 28 pt
   of top air (W11a's core reach change).
2. That the enlarged end zones (28 pt navigator / 44 pt body) are
   comfortably reachable with a chapter in hand.
3. That the post rows' insertion bars appear where expected while
   dragging, in both the navigator and the Outline body.
4. That dragging from a collapsed card / an expanded post header does not
   interfere with that row's click (the construct is the navigator's
   proven one, but this pairing is new).
5. That the Recovery surface really SCROLLS to the revealed block and
   that its row mark reads clearly in both voices, light and dark.
6. That the sheet's longer explainer still fits its `lineLimit(6)` at the
   sheet's 560 pt minimum width without truncation.

#### For the orchestrator

- **PENDING, deliberately: nothing.** No PROVISIONAL was created, so
  `notes/QUESTIONS.md` is untouched (next free number stays **#49**).
- **Nothing exceeded its ruling's shape**, so no item stopped. The one
  place the brief invited a STOP (a colliding drag payload) resolved
  inside the existing prefix precedent — reasoning above, so it can be
  overturned rather than merely trusted.
- Her walk will notice, beyond the four items: the divide ceremony's
  header paragraph is one line longer; the merge ceremony, the merge
  status line and the helper now spell the recovery path identically
  (same words, one source); and a chapter heading in Outline highlights
  across its whole row when something is dragged over it.

#### Batch 2 — ACCEPTED (2026-07-30; the orchestrator's adjudication)

**Counts by my own runs** (not the implementer's): core `✔ Test run
with 906 tests in 102 suites passed` · Mac `✔ Test run with 958 tests
in 154 suites passed` — both match the record's claims exactly; the
implementer's quoted mobile line (14/4, run because `Sources/` was
touched) is accepted, and mobile re-verifies by my own run at phase
end per the standing rule.

**Load-bearing diffs read:** the core query is live-row disciplined
(deleted_at guards on edge, origin and placement; the `NOT EXISTS`
live-placement clause is the door's whole meaning and revert W10b-A
proved both its pins discriminate) with cost bounded to the post's
placements; W11's `BookDrag` prefix payload follows the standing
`lens-move:` precedent and is strictly safer than the bare id it
replaces; the reach fix leaves `chapterDragDropsBeforeTargetOrAtTheEnd`
and every ceremony pin UNMODIFIED — the parity proof.

**The three flagged calls, adjudicated:**
1. **The recovery-path wording deviation ENDORSED** — the brief's
   "Library ▸ Recovery" was MY error (an internal case name, not a
   door the author can find); the implementer corrected to the app's
   real grammar (`Library → Archived & Deleted → Unplaced blocks`),
   which is also the merge ceremony's shipped sentence. The deviation
   discipline working exactly as intended.
2. **The `RecoveryPath` fold ENDORSED** — one name, many readers is
   the anti-drift shape this phase's own kickoff finding (W10) exists
   to buy; the two standing pins over that copy pass unmodified.
3. **Building the reveal ENDORSED** — within the escape's intent
   (stock consume-pattern + `scrollTo` + row mark; no new highlight
   subsystem); navigation without saying WHICH block would have left
   the findability finding standing.

Also endorsed: the two green-reverts-got-stronger-arms events (the
guard applied before trust, twice), and the `assembleReading`
orders-by-chapter finding — carried into the 13i brief as knot 9 the
same sitting. **The six visual-verification-only items** route to her
walk and the standing Design & UI review row (recorded in the batch
record; nothing about them is claimed tested).

**Ledger:** W10 BUILT (both halves) · W11 BUILT (both halves) — all
four adjudicated. Remaining build rows: W1/W2 (split + windows),
W3+W16 (batch 3, briefed), W4 stars, W5 sticky, W6+W15 the sweep,
W17/A32 exploratory.

### Batch 3 brief — the navigation core: the Open-notes strip (W3/A27) + back-navigation (W16) (fresh Opus implementer; self-contained; spawn AFTER batch 2's acceptance)

**Read IN FULL before touching code:** `CLAUDE.md` + the canon it
loads (AppSpec §12; §14's 13c/13d deltas); THIS plan file — the
constitution, THE KICKOFF SITTING, sitting rulings rounds 1–5 (round
2 items 2 and 4 are YOUR two rulings), batch 1's and batch 2's
records (their environment traps bind; batch 2's P-4 broadcast
pattern for reveal/navigation is the precedent you extend); the 13c
plan's "Environment traps" (binding); the 13d batch-4 record's A14
item (the ⌘⇧ collision-sweep precedent and the registry shortcut
grammar).

**The rulings you build to (hers, recorded above):** the per-window
tab strip lives in the SIDEBAR's free space under Shelf · Library ·
Pool · Blocks (*"i'd use the free space that's underneath … for
now"*); ⌘⇧1…9 jumps; back-navigation is per-pane history (⌘[ / ⌘])
plus a named "← <origin>" chip that is COLLAPSIBLE (*"I like how
clean the editor looks right now"*); Compare's peer post becomes
click-through-to-open riding the same history.

**The items:**

1. **The Open section (the tab strip's sidebar form).** A fifth
   sidebar section below the standing four, listing the window's
   OPEN notes: opening a note (from any door — shelf, library, pool,
   ⌘K, a book, Compare's new click-through) adds it / moves it to
   recency; rows close individually (closing never deletes anything
   — pure view state); SESSION-scoped per window (the view-local
   state precedent — nothing persists, nothing syncs). Cap the list
   visibly (a "…" truncation row per the bounded-windows discipline)
   — pick a sane cap and record it. Section header word: "Open"
   (a UI string; the K5 sweep batch may re-touch it — do NOT rename
   anything else, the sweep is not yours).
2. **⌘⇧1…⌘⇧9 jump to the nth open note.** Registry-declared (P-1;
   every shortcut a menu item — the R73/R91/R93 legibility mandate;
   the Shortcuts helper picks them up from the registry). **RUN THE
   COLLISION SWEEP FIRST** (the 13d batch-4 precedent): menu key
   equivalents + registry shortcuts for ⌘⇧ digits; record the
   sweep's result in the batch record; if any digit is taken, STOP
   and report rather than substituting.
3. **Per-pane navigation history + the back chip.** A history stack
   keyed by PANE (today exactly one detail pane exists — build the
   key from day one so batch 4's split inherits it; the free-tiling
   rider binds: no two-pane assumptions). Every open-note navigation
   pushes; ⌘[ / ⌘] walk back/forward (COLLISION SWEEP these too —
   record what ⌘[/⌘] mean anywhere today); the chip renders "←
   <origin title>" when the pane arrived from somewhere, is
   COLLAPSIBLE per her ruling (a chevron collapse; collapsed state
   session-scoped; collapsed = a small glyph, never zero door), and
   P-8's chrome rules bind (`lineLimit(1)` on the title — the
   b6dae25 class). History is view state: it never persists, never
   syncs, and holds IDs only (never copies of text — the standing
   state rule).
4. **Compare's click-through.** The peer post's header becomes an
   open door (fire-and-DO: opens the post in the ordinary editor,
   pushing history so ⌘[ returns to Compare's board). Registry-
   declared where the registry reaches it; the 2E/board records
   name the surfaces.

**Shape constraints:** P-4 — navigation decisions land in the
shell/router by composition (batch 2's `RootView` precedent), never
derived from broadcasts by listeners; P-3 untouched — opening notes
migrates the ONE live editor exactly as today; P-9 — the history
stack is its own small type with its own pure pins, not a view-model
appendage. NO schema, no `Sync/`, and the K5 sweep batch owns every
rename — touch no standing strings beyond the new section's own.

**Pin honesty:** the history stack, recency ordering, cap/truncation,
and chip-state logic are PURE and fully pinned (red-on-old by
behavioral revert; checksums); ⌘⇧n routing pins at the registry/
dispatch layer (the 13d A14 precedent). What only a hand can verify
(the strip's look in the sidebar, chip collapse feel) goes on the
visual-verification-only list for her walk / the Design & UI review
row.

**Loop, records, constraints:** identical to batches 1–2 (tutorial
spine by TYPE name; full suites with quoted "Test run with N tests"
lines; mobile only if `Sources/`/`Shared/` is touched; batch record
appended; commits by explicit path with the standing trailer; never
`/Applications`, never push; STOP-and-propose on anything exceeding
a ruling's shape). Baselines to match-or-beat: **core 906/102 · Mac
958/154 · mobile 14/4.**

### Sitting rulings — round 6 (2026-07-30, the 13h note)

Her words, verbatim: *"yeah i like 13g before 13h. I think make a note
for 13h that I'm going to need to have a longer design conversation
about what this really looks like for a folder of markdown files - I
imagine they stay markdown and i'm only exposing an editor, and then
if they want to become variorum posts that's a deliberate step to
convert the markdown into a variorum post? I do agree that it would be
helpful in luring users away from Obsidian. I think I'll just need to
decide more at that step to be honest"* → RECORDED as
`notes/plans/phase-13h-folder-design-note.md` (her floated
folder-editor shape beside the row's standing bridge shape; the two
poles + the sitting questions; nothing decided — her uncertainty
preserved). The master plan's 13h row points at it and carries the
opens-with-the-conversation flag. 13g-before-13h affirmed.

### Batch 3 — the navigation core: the Open strip (W3/A27) + back-navigation (W16), ALL FOUR BUILT

**Counts, by my own runs at build-complete:** core `✔ Test run with 906
tests in 102 suites passed after 30.138 seconds` (`swift_exit=0`) · Mac
`✔ Test run with 982 tests in 159 suites passed after 133.846 seconds`
(`xcodebuild_exit=0`) · the tutorial spine on its OWN run, by TYPE name
(`TutorialBookShapeTests` · `TutorialDoorTests` · `TutorialWritingActsTests`
· `TutorialTakesActsTests` · `TutorialStructureActsTests` ·
`TutorialLookingActsTests` · `TutorialLibraryActsTests`): `✔ Test run with
49 tests in 7 suites passed after 11.944 seconds`. From the batch's
baselines (906/102 · 958/154 · 14/4): **+24 Mac tests, +5 suites**; core
byte-unchanged. **Mobile deliberately NOT run** — zero `Sources/` and zero
`Shared/` lines (verified by `git status`), so the loop's own condition for
running it is unmet; the phase's 14/4 stands.

**No schema. Zero `Sync/` lines. No Release build, no `/Applications`
refresh.** Her app was not running at any point (`pgrep` by path at open and
at close). Every commit staged by explicit path; nothing under `notes/`
outside this record was touched (sitting round 6 landed in the file while I
built and is untouched above).

#### THE COLLISION SWEEPS — both clean, and one is now permanent

**⌘⇧1…⌘⇧9: FREE.** **⌘[ and ⌘]: FREE.** Swept, per the 13d A14 precedent,
across the whole keyboard family: `EditorCommands.keyEquivalent` (the ONE
table where keys are declared), every `.keyboardShortcut(` call site in
`Variorum/` and `Shared/`, every `NSMenuItem` key equivalent, and the two
`performKeyEquivalent` overrides.

- No digit is bound with ⇧ anywhere. The nearest neighbours are the post
  modes' **⌘1–⌘6** (plain command, `CommandGroup(before: .toolbar)`), which
  is also why the family reads right beside them in the same menu group.
- No bracket character is bound anywhere in the app at all. Every other
  `.keyboardShortcut` outside the key table is `.defaultAction` /
  `.cancelAction` inside a sheet, or the book views' bare arrow keys; the
  one `performKeyEquivalent` override intercepts ⌘S and nothing else.
- Neither item needed its stop-and-report door.

**Made permanent** (`theKeyTableHasNoCollisionsAndTheNavigationKeysAreOurs`):
the pin walks the whole key table asserting **no two capabilities share a
chord** — it is a standing sweep for every key anyone adds next, not just
mine — and then that ⌘[ / ⌘] are ours and that **no ⌘⇧⟨digit⟩ appears in the
table at all** (the family wires per ordinal in the menu, which is where the
row's identity lives). The table was already collision-free; it stays that
way by test now.

#### 1. The Open section — the tab strip's sidebar form

Her ruling was placement as much as feature (*"i don't think it should be
above the editor - i like the clean look there. i'd use the free space
that's underneath 'library / shelf / pool / blocks' for now"*), so the strip
is a fifth `List` Section and the editor chrome is byte-untouched.

- **Rows are ordinary tagged List rows** (`.tag(SidebarSelection.post(id))`),
  which buys three things for free and with no new mechanism: clicking a row
  navigates through the shell's own selection, the `›` selection marker lands
  on the current note by the R1 idiom already there, and the row participates
  in the same keyboard/accessibility behaviour as Shelf · Library · Pool ·
  Blocks. The trailing edge carries the row's own **⌘⇧n**, so the key is
  legible without opening a menu, and a **✕** that closes the ROW.
- **Caps, recorded: 9 shown · 12 tracked · truncation row beyond.** The nine
  is not arbitrary — it is exactly ⌘⇧1…⌘⇧9, chosen so the two numbers cannot
  drift apart (every visible row carries a key; no key reaches a row she
  cannot see; the pin states that equality). The tracked list is deeper so
  closing a row PROMOTES the next most recent into view instead of leaving a
  hole, and the *"…N more open"* row is the bounded-windows discipline's
  visible marker — never a silent cut.
- **Session-scoped per window by construction:** the state hangs off
  `ShellRouter`, which is the shell's own object, so batch 4's second window
  gets its own the moment it gets its own router. Nothing persists, nothing
  syncs, and the strip holds **ids only** — the titles are resolved for
  display and never stored in navigation state.

#### 2. ⌘⇧1…⌘⇧9 — one declaration, a key per row

`CapabilityID.openNote` is ONE registry declaration for the whole family,
which is exactly what `switchMode` is for ⌘1–⌘6 — and the same walk
exemption, widened from a single-id guard to a named `ordinalFamilies` set.
The menu renders a **submenu of the open notes BY NAME**, each row carrying
its ordinal key, so every shortcut is a menu item (R73/R91/R93) and the keys
and the sidebar rows **cannot disagree: both read
`workspace.openNotes.shown`, in the same order.**

With nothing open the submenu is honestly grey (`openNoteCount > 0`) — the
`undoAvailable`/`redoAvailable` shape, a stack gate rather than a mode gate.
A key that could only ever be dead is not a key here.

#### 3. Per-pane history + the collapsible back chip

**The whole recording is ONE line in the shell**, and that is the design:
every door in the app already funnels through `RootView`'s selection — the
shelf, the library, the pool, ⌘K, a book's `.variorumOpenPost` broadcast,
Compare's new click-through, the strip itself — so `onChange(of: selection)`
makes the history and the Open list complete **by construction** rather than
by instrumenting each door and hoping the next one remembers. P-4 exactly:
the doors name a destination, the shell decides what it means.

- **Keyed by `PaneID` from day one** (the free-tiling rider): a dictionary,
  never a pair of stacks, never "left/right". A second pane's history is
  already independent — pinned, today, with two keys.
- **The re-entrancy problem is solved by arithmetic, not a flag.** ⌘[ sets
  `current` itself and the shell then reports that arrival back — so `visit`
  no-ops on an unchanged destination and the forward future survives. A flag
  would have to be cleared on every path SwiftUI might or might not take;
  revert **W16-A** shows precisely what its absence costs (⌘] stops working
  after ⌘[).
- **The chip lives in the SHELL, above the detail** — not in
  `PostDetailView` — because "where did I come from" is the PANE's fact. One
  chip therefore serves a post, a book, a folder and the recovery surface,
  and Write's masthead is untouched. It renders only when the pane arrived
  from somewhere, so a cold launch at the shelf shows nothing at all.
- **Collapse, per her ruling** (*"I like how clean the editor looks right
  now"*): the fold chevron is present in BOTH states, so collapsing is never
  a one-way door — collapsed reads `← ›`, two small glyphs, and the arrow
  still goes back. `lineLimit(1)` + a bounded frame on the name (P-8's
  b6dae25 class). Collapse state is session-scoped, per window.

#### 4. Compare's click-through

Her second W16 half (*"in compare … you should be able to click on the post
you're comparing it with"*). The peer column's header gains an **Open**
button beside Mark as Versions / Diff, declared as
`CapabilityID.openPeerPost` — a `.surface` act (its target is the column you
point at: the `.unarchiveTake` class), with `CompareBoardView` joining the
walk's surface-door union.

It **fires the existing `.variorumOpenPost` channel** rather than navigating
itself (P-4), which is also what makes the ruling's own promise true without
a line of extra code: opening the peer pushes the anchor post onto the
pane's history, and ⌘[ returns to it in Compare **because per-post mode
memory reopens it there.**

#### Judgment calls, recorded so they can be overturned rather than trusted

1. **The strip tracks POSTS only.** Books, folders, the pool and the
   recovery surface are destinations (they get history and the chip) but not
   *notes*. Her row says "tabs of open notes"; W14 ruled the word is "note".
2. **Recency ordering is the brief's letter** — *"adds it / moves it to
   recency"* — and it has a consequence worth her eye: **⌘⇧1 is always the
   note you are already in**, and the ordinals shuffle as she moves (browser
   tabs are insertion-ordered instead). Built as briefed, flagged, not
   deviated from.
3. **The section renders LAST**, below the contextual "this post" rail. With
   no post open that is literally "the free space underneath the four"; with
   one open, the rail keeps the placement she ruled in 13's batch 14 and the
   strip sits under it. The alternative displaced a ruled placement.
4. **`SidebarSelection` became `nonisolated`.** The target defaults to
   MainActor isolation, which isolates even a plain value enum's synthesized
   `Equatable` — and the pure types compare destinations away from any actor
   so they can be pinned as the arithmetic they are. Widening, not narrowing;
   the registry layer's own value types are declared exactly this way.
5. **Titles are one-shot reads keyed on what is shown** (the shipped
   `PostTitleLabel` precedent), not a held observation per row. **The known
   corner:** renaming a note elsewhere does not live-update its strip row
   until the shown set or its order next changes — which any navigation does.
   A held per-row observation is the alternative if she ever notices it.
6. **Closing the row of the note you are looking at** removes the row and
   leaves the note on screen. There is no "close the pane" concept until
   batch 4's windows, and navigating away on a close would be a bigger
   surprise than a missing row.
7. **`.openPeerPost` joins the takes-parity exemption** with the
   `.switchMode` reason: it is a NAVIGATION act, not an editing one — no
   surface is behind another because no surface edits anything.
8. **The registry context reads the workspace through a closure**
   (`openNoteCount` / `canNavigateBack` / `canNavigateForward`, the
   `undoAvailable` idiom), wired by the shell to ITS window's workspace.
   That closure is where batch 4's focused-window refinement lands, and
   nothing else has to change for it.

#### Pins — every change named

**New suite `WorkspaceNavigationTests` (24 tests in 5 suites):**
`NavigationHistoryTests` (4) the trail, the round trip, the forward future,
the bound · `OpenNotesTests` (4) recency without duplication, closing one
row, the ordinals' reach, the bound + the truncation number ·
`WorkspaceNamingTests` (3) every destination kind names itself, unresolved
still reads as what it is, the chip's one sentence · `WorkspaceModelTests`
(7) recording both halves, the back-walk idempotence end to end, the
free-tiling pane keys, chip state, **closing a row never touches the store**
(a real store: the container is still live and titled afterwards), title
resolution for post and book · `NavigationDoorsTests` (6) the permanent
collision sweep, declared ⇔ rendered, grey-where-it-cannot-act, the shell
doors' destinations, a pane with nowhere to go asking for nothing, and the
**shell-mount pin** (below).

**Pins MODIFIED — four, all in the registry walk, each a widening the new
declarations require:**
- `sampledContexts` **+1 context** (the workspace gates — the third family
  of app-scope stack gates beside undo and redo; without it the navigation
  core would read `.unavailable` everywhere the walk looks, exactly as the
  find family did before its own context joined).
- `everyEditingCapabilityDeclaresItsTakesAccess` — exempt set **+
  `.openPeerPost`**, with the reason stated in the test.
- `everyShortcutLabelHasExactlyOneKeyWiring` — the `.switchMode` guard
  becomes a named `ordinalFamilies` set (**+ `.openNote`**).
- `theSurfacesRenderExactlyTheDeclaredSurfaceActs` — union **+
  `CompareBoardView.surfaceCapabilities`**.
- (Mechanical, not a claim change: `PostDetailAndPanelTests`' `SidebarView`
  construction gains the new `workspace:` argument.)

**Everything else passes UNMODIFIED**, including every other registry-walk
assertion — the parity proof that the four new declarations are additions,
not adjustments.

**Reverts (checksummed with `shasum -a 256` before each; every file restored
and verified OK before the next):**
- **W3-A** — `opened` loses its move-to-front dedupe ⇒ **2 pins red** (the
  pure recency pin and the model's return-to-a-note pin). Exactly
  discriminating.
- **W3-B** — `id(atOrdinal:)` reads the tracked list instead of the shown
  rows. **A GREEN REVERT GOT A STRONGER ARM FIRST:** with exactly nine notes
  open the two readings are the same list, so nothing could tell them apart.
  The bound pin now overfills the strip and asserts `id(atOrdinal: 10) ==
  nil` — a state the wrong reading cannot produce — and the revert then ran
  **red** (`→ "p8"`).
- **W16-A** — `visit` loses its no-op guard ⇒ **4 issues across 3 suites**
  (pure, model, and shell door): the shell's report of a back-walk destroys
  the forward future. The whole re-entrancy design, discriminated at three
  layers.
- **W16-B** — a new navigation stops clearing the forward future ⇒ the
  browser-rule pin red.
- **W16-C** — `WorkspaceModel.visit` ignores its `pane:` argument ⇒ **4
  issues**: the free-tiling rider's pin, red.
- **W16-D** — the shell's `wireWorkspace()` call removed ⇒ **3 issues**: no
  seed and no wiring.

**The shell-mount pin, and why it exists.** Two halves live in the VIEW and
no pure pin could ever catch them, and both fail SILENTLY: the registry
context must be wired to this window's workspace (unwired, Back / Forward /
Open Notes are grey forever, because the router's defaults answer "no" to
everything), and the pane's history must be SEEDED with what the window is
already showing (`onChange` never fires for an initial value — unseeded, the
first click out of the shelf pushes nothing, so **the very first back chip
she could want is the one that never appears**). `RootView` is mounted in a
real window and both are asserted; revert W16-D is its red.

#### VISUAL-VERIFICATION-ONLY — for her walk and the Design & UI review row

Everything that DECIDES anything above is pinned. These are look-and-feel
halves, and **no claim is made that they were tested:**

1. That the Open section sits where she meant it, and reads well BELOW the
   contextual "this post" rail when a post is open.
2. That the row's ✕ hit target does not fight the row's own
   click-to-navigate, and that the ⌘⇧n label at the trailing edge reads as
   quiet signage rather than noise.
3. That the *"…N more open"* row reads as signage and not as a dead row.
4. That the collapsed chip (`← ›`) still reads as a door, and that the
   expanded chip does not crowd the masthead beneath it.
5. That the chip's bar height and divider feel "clean" in both voices, light
   and dark (her whole reason for wanting the fold).
6. That Compare's new **Open** button sits comfortably beside Mark as
   Versions / Diff and does not crowd the peer picker.

#### For the orchestrator

- **PENDING, deliberately: nothing.** No PROVISIONAL was created, so
  `notes/QUESTIONS.md` is untouched (next free number stays **#49**).
- **Nothing exceeded its ruling's shape**, so no item stopped. The one place
  a stop was pre-authorised (a taken ⌘⇧ digit or bracket) did not arise —
  both sweeps came back clean.
- **Two things her walk will notice beyond the four items:** the detail pane
  now grows a thin chip bar the moment she navigates anywhere from the shelf
  (and never before), and the sidebar gains a fifth section that appears the
  first time a note is opened and never empties itself again inside a
  session.
- **For batch 4 (windows/split), three seams are already cut:** `PaneID` is
  a dictionary key, not a pair; the workspace hangs off `ShellRouter`, so a
  per-window router is a per-window workspace; and the registry's three
  workspace closures are the single place a focused-window rule has to land.
