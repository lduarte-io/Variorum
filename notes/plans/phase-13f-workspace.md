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

#### Batch 3 — ACCEPTED (2026-07-30; the orchestrator's adjudication)

**Counts by my own runs:** core `✔ Test run with 906 tests in 102
suites passed` · Mac `✔ Test run with 982 tests in 159 suites passed`
— both match the record's claims exactly. **Load-bearing diffs read:**
the Workspace module is P-9 done right (pure `WorkspaceNavigation`
types + a thin model, 24 pins of arithmetic); the one-line
`onChange(of: selection)` recording point is the P-4 shape (doors
name destinations, the shell decides); the permanent key-table
collision pin is a standing asset beyond this batch; the shell-mount
pin closes exactly the silent-failure pair a pure pin cannot see
(unwired closures; unseeded history). All eight judgment calls
ENDORSED — (2) was rightly flagged rather than decided and went to
her (round 7 below); (5)'s stale-title corner is recorded and
acceptable at strip cadence. The four registry-walk widenings are
each the declaration's own requirement, named in the tests.
**Ledger:** W3+W16 BUILT and adjudicated; the strip's ordering flip
rides batch 4 (round 7).

### Sitting rulings — round 7 (2026-07-30, question batch 4: the batch-3 flags + the split's same-note rule)

1. **The Open strip goes INSERTION-ORDERED, with session-only manual
   drag-reorder, hers verbatim:** *"insertion order, maybe they're
   draggable / reorderable manually like browser tabs as well though?
   session only, not a setting"* → build both (the "maybe" recorded
   as written — the reorder is hers to walk); recency still decides
   MEMBERSHIP; ⌘⇧n reads the stable order. Rides batch 4.
2. **Strip tracks notes only: RATIFIED as built.**
3. **The split NEVER shows the same note twice, hers verbatim:**
   *"opening a note already showing in the other pane could move you
   there or it could just open 'lenses' or 'compare' or something
   instead - that already is a mode, just not going to be this mode.
   definitely not two live side by sides - we already offer that for
   one note"* → the DEFINITE half binds (no same-note split, ever);
   the shipped shape is her first-listed reading — focus the
   existing pane and SPEAK, the copy naming Lenses/Compare as the
   same-note side-by-side surfaces (her "could open lenses instead"
   floated alternative recorded here, one door-swap away if she
   prefers it on the walk).

### Batch 4 brief — the two-pane SPLIT (W1/A25) + the strip's ruled ordering flip (fresh Opus implementer; PROPOSAL GATE inside)

**Read IN FULL before touching code:** `CLAUDE.md` + the canon it
loads (AppSpec §4/§12; §14's deltas); THIS plan file WHOLE — the
constitution (P-3 is this batch's law), THE KICKOFF SITTING, sitting
rulings rounds 1–7 (round 2 item 1 = two panes + the FREE-TILING
RIDER; round 7 = your ordering flip and the same-note rule), batches
1–3's records + acceptances (batch 3's "three seams are already cut"
note is your map: `PaneID` dictionary keys; workspace-per-router; the
three registry closures as the focused-pane landing spot); the 13c
plan's "Environment traps" (binding); the 13d plan's batch 3 record
(the flight-latch trigger sentence and the one-flight door) and the
13f plan's own "Binding constraints" section (the latch note names
A25 as a likely first customer — CHECK BEFORE BUILDING).

**The items:**

0. **The strip's ruled flip (round 7.1):** insertion order (recency
   keeps deciding membership; closing still promotes from the tracked
   list) + session-only manual drag-reorder of the shown rows. Ruled
   flip — the recency-order pins flip DELIBERATELY, named; new pins
   for stable ordinals and the reorder arithmetic (pure, red-on-old).
1. **The split itself:** ONE window shows TWO panes side by side, two
   DIFFERENT notes, each an ordinary detail surface with its own
   per-post mode memory. Doors (registry-declared, P-1): an "Open
   Beside" act on note rows (sidebar/strip/library contexts as the
   registry reaches them) + a View-menu door + a close-split door.
   The divider is draggable; layout state is session/window view
   state (IDs only). **The same-note rule (round 7.3):** opening a
   note already showing in the other pane FOCUSES that pane and
   speaks; the copy names Lenses/Compare for same-note side-by-side.
2. **P-3 across panes — the batch's core:** exactly ONE live editor
   across both panes, the ring migrating on click exactly as the
   Book spread does; the un-focused pane renders read-cheap. The
   liveness extension lands ON `PaneTextAuthority` / the standing
   authority seams — NEVER a second mechanism. The registry's three
   workspace closures gain the focused-pane refinement (batch 3's
   recorded seam); every capability resolves against the FOCUSED
   pane's context.
3. **Per-pane history/chip:** each pane keys its own history (the
   `PaneID` dictionary already holds this — wire the second key);
   ⌘[ / ⌘] act on the FOCUSED pane; each pane carries its own chip.
4. **THE FLIGHT-LATCH CHECK (binding, BEFORE building):** the 13d
   batch-3 latch is model-local; the 13f constraints note names A25
   as its likely first trigger. With the same-note rule the two
   panes hold two different posts — VERIFY whether any composition
   this batch creates can mount structural doors on ONE post from
   two surfaces (including strip/sidebar doors firing at a pane's
   post mid-ceremony). Record the verdict with its trace either way;
   if the latch must move to a post-keyed shared authority, that IS
   this batch's work — do it at the authority, not with a flag.

**THE PROPOSAL GATE (binding — the 13d batch-3/4E pattern):** BEFORE
building items 1–3, investigate and append a short PROPOSAL under
your batch record heading covering: (a) how selection/router state
becomes per-pane (today `ShellRouter` holds ONE selection — what
splits, what stays window-scoped, how the sidebar's click targets
the focused pane); (b) how the one-live-ring extension lands on the
standing authority (name the exact seams); (c) the latch verdict
from item 4; (d) what the second pane's chrome is (chip, mode rail,
inspector — what renders per pane vs per window). Then STOP and
report; the build proceeds on the orchestrator's ruling. Item 0 may
be built before the gate (it needs none of (a)–(d)).

**Pin honesty:** pane/selection/focus arithmetic pure and pinned
(red-on-old by behavioral revert; checksums); the one-live-ring
invariant pinned at the authority layer (the standing exactly-one-
live pins extend); what only a hand can verify (divider feel, the
split's look, focus clicks) goes on the visual-verification-only
list. The hosted-ScrollView and SwiftUI-drop traps from batches 1–3
stand.

**Loop, records, constraints:** identical to batches 1–3 (tutorial
spine by TYPE name; full suites with quoted "Test run with N tests"
lines; mobile only if `Sources/`/`Shared/` is touched; batch record
appended; commits by explicit path — the author's parallel session
works in `notes/`, touch nothing of hers; never `/Applications`,
never `Sources/VariorumCore/Sync/`, never push; no schema;
STOP-and-propose beyond a ruling's shape). **Baselines to
match-or-beat: core 906/102 · Mac 982/159 · mobile 14/4.**

### Batch 4 — the two-pane SPLIT (W1/A25) + the strip's ordering flip

#### Item 0 — BUILT and committed (`34ad7f7`), ahead of the gate as the brief allows

Her round-7.1 ruling, both halves. **ORDER and MEMBERSHIP became two
questions:** order is INSERTION order (a new note joins the END like a
browser tab; re-opening one already in the strip leaves it exactly where
it sits), membership stays RECENCY's (at the tracked bound the
least-recently-*opened* note leaves, never the oldest row — a note she
keeps returning to must not be evicted for having been opened first), and
the manual reorder is the `onMove` convention's arithmetic guarded to the
shown rows, leaving recency untouched because rearranging the strip is not
using a note.

**What the flip BUYS, pinned as the property it is:** ⌘⇧n is a stable
address. Batch 3's judgment call 2 flagged the shuffle to her rather than
deciding it ("⌘⇧1 is always the note you are already in"); the new pin
`theOrdinalsDoNotShuffleAsSheMovesBetweenNotes` wanders between three
notes and asserts every key still addresses what it addressed.

**RULED PIN FLIPS, each named on its own face:**
`openingMovesANoteToTheFrontWithoutDuplicating` →
`openingAppendsInInsertionOrderAndNeverMovesAnOpenNote` ·
`returningToANoteMovesItToTheFrontOfTheStrip` →
`returningToANoteLeavesTheStripsOrderExactlyWhereItWas` (which keeps the
"arriving IS opening" claim, moved onto `recency`, where it is now true) ·
`theOrdinalsCoverExactlyTheShownRows`' first/last arms ·
`closingARowRemovesOnlyThatRowAndNothingElse`' reopen arm ·
`arrivingRecordsBothTheTrailAndTheStrip` ·
`theShellDoorsRouteTheRightDestination` (flipped AND grown a
⌘⇧1-still-addresses-p1 arm). **NEW pins (5):** the stable ordinals · the
bound paid by recency not row age · the reorder arithmetic (multi-row +
out-of-range inert) · the reorder's reach stopping at the strip · the
model's pass-through.

**Reverts, `shasum -a 256` before each, all restored OK:** **I0-A**
(move-to-front) ⇒ red across **all three** suites — the whole flip
discriminated · **I0-B** (the destination's pre-move shift dropped — the
classic `onMove` mistake) ⇒ red on exactly the arithmetic's downward arms ·
**I0-C** (the bound paid by the oldest row) ⇒ red on exactly the membership
pin, 3 issues, everything else green. **A GREEN REVERT GOT A STRONGER ARM
FIRST:** `theReorderStaysInsideTheShownRows` only checked the first row,
which I0-B leaves alone; it now asserts where the dragged row LANDS
(`shown.last`), and the revert then discriminates.

**Counts by my own runs at item 0:** Mac `✔ Test run with 987 tests in 159
suites passed after 134.494 seconds` (`mac_exit=0`; from 982/159 — **+5**,
exactly the new pins) · core `✔ Test run with 906 tests in 102 suites
passed after 29.497 seconds` (`swift_exit=0`; byte-unchanged) · tutorial
spine on its OWN run by TYPE name `✔ Test run with 49 tests in 7 suites
passed after 12.191 seconds`. Mobile deliberately NOT run — zero
`Sources/` and zero `Shared/` lines.

**Visual-verification-only from item 0:** that a sidebar row really drags
to reorder inside the `List` (the batch-1 measurement stands — SwiftUI's
drop route cannot be driven in this host), and that held-still ordinals
read better under her hand than shuffling ones did.

---

#### THE PROPOSAL (the gate) — traced before building items 1–3

Everything below is measured from the code, not assumed. The load-bearing
discovery is that **this exact problem was already solved once, in this
app, with its reasons written down** — `SpreadBookView`'s header comment
(13c 2B) records why the Book spread mounts a live surface on ONE page and
renders its sibling read-cheap, and the brief's own item 2 points at it
("the ring migrating on click exactly as the Book spread does"). The
proposal is that shape, generalized to panes.

##### The four app-scoped singletons a second pane meets

| What | Shape today | Consequence for a split |
|---|---|---|
| `CommandRouter.detailToken` / `activePostID` / `activeMode` / `applyMode` | **ONE** detail registration (`PostDetailView.onAppear`) | Two mounted details ⇒ the second overwrites the first; ⌘1–⌘6 and the sidebar rail address whichever mounted LAST, not the focused one |
| `CommandRouter.handlers` | a **LIFO** stack; `dispatch` walks it reversed | Two mounted surfaces ⇒ every routed act (⌘S, every structural and take door) reaches the last-mounted surface — the N5/D3 class `SpreadBookView` names |
| `EditorRouter.active` | a **single** `weak var` | Two Write editors ⇒ `writeEditorAttached` / `writeEditorOwnsScrollView` describe the wrong one |
| `AppSession.autosave(forPost:)` | already a **per-post registry** | Correct as-is for two panes on two posts — nothing to change |

Two panes are only safe if **at most one of them mounts a live surface at
a time.** That is not a rule I am adding on top; it is the condition under
which the machinery that already exists keeps being correct.

##### (a) How selection/router state becomes per-pane

**Recommended — a pane COLLECTION on `WorkspaceModel`, with the focused
pane's selection projected into the shell's existing binding:**

```
panes:          [PaneID]                     // ordered; 1 today, 2 with a split, N later
selections:     [PaneID: SidebarSelection]
focusedPane:    PaneID
splitFractions: [Double]                     // count == panes.count - 1
```

Nothing is a pair and nothing is named left/right — **the free-tiling
rider, honored in the state shape** exactly as batch 3 honored it for
history. `histories` is already `[PaneID: NavigationHistory]`, so item 3
is a second key and nothing else.

`RootView.selection` stops being `@State` and becomes a **computed
`Binding` over `workspace.selections[workspace.focusedPane]`**. That single
change buys three things with no new routing: the sidebar's
`List(selection:)` keeps working unchanged; **a sidebar click targets the
focused pane by construction** (it writes through the binding); and the
one `onChange(of: selection)` recording point batch 3 built keeps being
complete — it just records into the focused pane's history.

What stays WINDOW-scoped: the Open strip (already ratified as the
window's — batch 3's pane-keys pin asserts both panes' notes are open
notes), `ShellRouter.pendingSelection` (a request; it lands in the focused
pane), the palette, the status toast.

*The alternative, named:* leave `RootView.selection` as the primary pane's
and give secondary panes a note id each. Smaller, but asymmetric — pane 0
could hold anything and pane 1 only notes — which is precisely the shape
the free-tiling rider asks me not to bake in. I do not recommend it.

##### (b) Where the one-live-ring extension lands — the exact seams

**It lands as a MOUNT rule, and therefore on NO new seam at all.** This is
the part I want ruled explicitly, because "no new mechanism" here means
*literally none*:

- `PaneTextAuthority.livePane` is a single optional and the one-ring
  invariant is enforced INSIDE one authority. Authority owners today:
  `TakesViewModel`, `CompareBoardView`'s model, `CanvasViewModel`,
  `BlockTOCView` — **all four are mounted only by `PostDetailView` /
  `PoolDetailView`** (verified by grep).
- Command handlers are registered by exactly five views — `EditorView`,
  `TakesBoardView`, `LensesBoardView`, `CompareBoardView`, `CanvasView` —
  **all inside those same detail hosts, or inside `BookView`'s pages**.
- **Every list surface** (Shelf, Library, Pool, Blocks area, Folder,
  Recovery) registers no handler and owns no authority. They are already
  read-cheap in P-3's sense; nothing needs doing to them.

So: **only the focused pane mounts its full surface. Unfocused panes
render read-cheap**, per destination kind:

- a note (`.post` / `.pool`) → **`ReadPostView`**, whose
  `onFocusRequest(offset)` already focuses-and-seeds-the-caret. This is
  byte-for-byte the Book spread's sibling page.
- a **book** → `BookView` with `paneIsFocused: false`, which calls its own
  **`BookViewModel.focus(nil)`** — the book surface's existing single focus
  authority (13b 3E's fold), so no page mounts an editor. One threaded
  boolean, zero new concepts.
- everything else → unchanged (harmless by the audit above).

Consequence, and it is the evidence the shape is right: **the four
singletons in the table need no changes whatsoever.** One detail
registers, one handler stack entry exists, one editor is active. The
`registerDetail` token guard already survives SwiftUI running the
arriving `onAppear` before the departing `onDisappear`, which is exactly
the ordering a focus migration produces.

The registry's three workspace closures gain the focused-pane refinement
batch 3 predicted — `canNavigateBack/Forward` read
`workspace.history(workspace.focusedPane)`, `openNoteCount` stays
window-scoped. Two lines, in the one place batch 3 cut for it.

*The alternative, named and NOT recommended:* mount full details in both
panes and suppress liveness in the unfocused one via a third disjunct
beside `sealed || structuralInFlight`. It needs the flag threaded into
five surfaces, AND a pane-keyed rewrite of the single-detail registration,
the LIFO stack and `EditorRouter.active` — it multiplies exactly the
mechanisms P-3 exists to prevent, to buy a mode rail on a pane she is not
using.

**The cost I am NOT hiding:** an unfocused note pane shows read-cheap
prose even when its remembered mode is Takes, and snaps to its board on
click; focusing re-mounts the detail (its `.task`s re-run — the ordinary
open cost she already pays on every navigation). The Book spread has
shipped with precisely this since 13c.

##### (c) THE FLIGHT-LATCH VERDICT — **it does NOT need to move**, on this shape, and here is the trace

The 13d trigger sentence fires when "any composition mounts Write and a
takes/lenses board on ONE post with structural doors on both sides." The
hazard's mechanism (13d batch 3, traced there): a keystroke between the
flush and the op records the PRE-op text into the post's autosave
coordinator, and the debounce writes the old text back over rows the
operation just wrote — the forbidden text-duplication class. The
coordinator is **per post**, so the hazard needs **two door-bearing
surfaces on ONE post**.

1. **Every structural act is a `RoutedCommand.structural(_)`** dispatched
   through `ShellActions.dispatch` → `CommandRouter.dispatch` → the LIFO
   handler stack. The menu, the palette, the bars, the sidebar and the
   strip do not act — they dispatch. **So a "strip/sidebar door firing at
   a pane's post mid-ceremony" cannot bypass the mounted surface's own
   latch**; it can only reach a mounted handler, and each of the five
   handler-registering surfaces guards its entry (`EditorSurfaceController
   .runStructural`'s one-flight door; `TakesViewModel.runStructuralDoor`'s
   `guard !structuralInFlight`).
2. **Under the one-live-mount rule, exactly one door-bearing surface is
   mounted per window at any moment.** Two structural doors on one post is
   therefore unrepresentable — not guarded against, *unrepresentable*.
3. **Her same-note rule (round 7.3) removes the case independently**: the
   two panes never hold the same note.

**The one edge I want on the record either way**, because rule 3 alone
does not cover it: pane A showing a BOOK whose focused post is P, pane B
showing note P. That is one post from two surfaces, and the same-note rule
as worded speaks about opening a note "already showing in the other pane"
— a post inside a book is arguably showing. Under the one-live-mount rule
this is dead (the book blurs when unfocused). **If the orchestrator rules
the alternative in (b) instead, this pair becomes reachable and the latch
MUST move to a post-keyed shared authority** — the `AppSession
.mergeJoinMemory` / `tutorialDoorInFlight` precedent 13d already named as
the stricter option. I would then do it at the authority, not with a flag,
and it would be this batch's work.

**A related hazard that is NOT new but gains a new trigger:** clicking the
other pane unmounts the focused pane's detail, and a detail can unmount
mid-flight. That path exists today (a sidebar click during a ceremony does
it), and the backstops exist too (`EditorView.onDisappear →
model.teardown()`, the per-post coordinator's flush). The split adds a
*trigger*, not a *path*. I propose pinning it rather than assuming it, and
I will report if the pin finds anything.

##### (d) The second pane's chrome

**Per pane:** the back chip (her ruling; batch 3 built it "in the SHELL,
above the detail" precisely because "where did I come from" is the PANE's
fact — it moves inside the pane container unchanged, one per pane, each
reading its own `PaneID`); the detail content, which for a focused note
brings its own masthead (title · membership chip · Scraps · References)
for free; and for an UNFOCUSED note pane a quiet one-line name header
reading `workspace.label(for:)`, so a pane is never anonymous. The
difference between a full masthead and a thin name line then *is* the
focus signal, which I would rather have than a border.

**Per window:** the sidebar — including the **mode rail**, which reads
`commandRouter.activeMode` and is therefore the focused pane's *by
construction* under the mount rule, with no new wiring; the status toast
(one presentation, AD-14); the ⌘K palette; the account sheet.

**The one risk I cannot settle from here:** the References/Scraps
**inspector** lives inside `PostDetailView` and is therefore per-pane, but
`.inspector` is designed for a `NavigationSplitView` column and nesting one
inside an `HStack` pane is unverified. I propose keeping it per-pane in v1
and putting it on the visual-verification list; if it misbehaves the
fallback is to hoist it to the window and point it at the focused pane.

##### Two findings for the record, neither blocking this batch

1. **`ShellRouter` is App-level `@State` on `VariorumApp`, so it is shared
   by every `WindowGroup` window.** Batch 3's "per-window router =
   per-window workspace" holds for the SPLIT (one window) but is **not yet
   true for W2/A26's several windows** — a second window would today share
   one workspace, one Open strip and one history. W2's batch must give the
   scene its own router; the state shapes proposed here are already ready
   for it (they are per-workspace, and a workspace is per-router).
2. **`splitFractions` as pure arithmetic rather than `HSplitView`.** A
   hand-drawn divider over `GeometryReader` keeps the fraction in workspace
   state, which makes it pinnable and generalizes to N panes; `HSplitView`
   owns its geometry privately and is two-pane-shaped in practice.

##### What I would build on a ruling, in order

1. `WorkspaceModel`'s pane collection + `focusedPane` + `splitFractions`
   (pure, pinned: open-beside, the same-note refusal, close-split, focus
   migration, fraction clamping).
2. `RootView`'s detail column becomes `ForEach(workspace.panes)` with a
   `PaneHost` (chip + content + the focused/read-cheap fork) and a
   draggable divider.
3. The doors: `CapabilityID.openBeside` + `closeSplit` (registry-declared,
   `.contextMenu` on note rows where the registry reaches them + a View
   menu door), with the same-note refusal copy naming **Lenses** and
   **Compare** as the same-note side-by-side surfaces (her round-7.3
   wording).
4. `BookView`'s `paneIsFocused` thread → `focus(nil)`.
5. The three registry closures' focused-pane refinement.
6. The unmount-mid-flight pin from (c).

**STOPPING HERE per the gate.** Item 0 is built, committed and green;
items 1–3 proceed on the orchestrator's ruling of (a)–(d).

### Sitting rulings — round 8 (2026-07-30, the post→book ascent + the model re-explained)

Her opening, verbatim (recorded whole — it names the phase's real
finding): *"even if you navigated there some other way, there's gotta
be a way from a post/note to see what books it is present in and see
it in the full context of any of those books. I think the reason that
it's been hard to use post / notes is because there isn't a natural
way to step back up into the book. … if you try to edit a post that's
in multiple different books, it gets mutated into it's own copy? …
I'm conflicted - I love the book as a looser collection of posts and
the pointers, but how do I keep a door open from post -> book despite
that?"*

**Answered on the record:** editing NEVER copies (R31/R35 — membership
is not ownership; `duplicateAsVersion` is the one deliberate
divergence door; re-explained to her and landed). **THE TRACE
FINDING (W20):** `MembershipChip` lists the post's books as clickable
links wired to an `onOpenBook` closure — which is **passed nowhere at
the chip's one mount** (`PostDetailView:86`): clicking a book name
has done NOTHING since Phase 13 shipped. The designed ascent door is
a dead affordance — the fire-and-DO class, and precisely her "no
natural way to step back up."

**Her rulings:**
1. **The ascent = chip + visible in-line, HIDEABLE**, hers verbatim:
   *"i think that chip + visible in line is good, but I think that
   you should be able to hide it somehow (even if just with a
   keyboard command). i love our uncluttered interface"* → shaped as
   ONE context bar: the batch-3 back chip and the "in <book(s)>"
   line share the bar and FOLD TOGETHER (one collapse, one
   keyboard/menu toggle — never two hiding mechanisms); the popover's
   links get wired (fire-and-DO: open the book REVEALED at this
   post, the batch-2 reveal grammar; history pushed so ⌘[ returns).
   No dedicated go-to-book shortcut (her middle pick); ⌘K reaches
   the act by name.
2. **Lands into the book's REMEMBERED mode, revealed — CONDITIONED
   on cross-mode continuity**, hers verbatim: *"the remembered mode
   is fine as long as there's a quick way to get from wherever you
   are in read to that same point in book or outline - which I think
   there is? if you click over does it move where you are? or offer
   that as an option?"* → CHECKED: it does NOT exist today — the
   mode picker sets `structure.mode` with no position carry; each
   mode keeps its own place. **W21 (new row): switching Outline ·
   Book · Read carries the CURRENT POST across** (Read's current
   post → the spread anchored on it → Outline revealed at it) — the
   "quick way" her condition names, built as the default behavior of
   the click-over.

**Ledger adds:** W20 — the ascent door (wire the chip links + the
in-books half of the foldable context bar + reveal-at-post) · W21 —
cross-mode position carry inside books. Both: batch 5.

### THE ARCHITECT'S RULING on the Batch 4 proposal (2026-07-30 — the gate closes; BUILD items 1–3)

**(a) APPROVED as proposed** — the pane COLLECTION on
`WorkspaceModel` (`panes`/`selections`/`focusedPane`/`splitFractions`,
nothing paired or left/right-named — the free-tiling rider in the
state shape) with `RootView.selection` becoming a computed Binding
over the focused pane's entry, keeping batch 3's ONE recording point
complete by construction.
**(b) APPROVED — the MOUNT rule** (the focused pane mounts the live
surface; an unfocused note pane renders `ReadPostView` with its
standing click-to-focus door; an unfocused book blurs via its OWN
focus authority). The four-singletons-need-no-change audit is the
evidence the shape is right; the named alternative (both live, a
third liveness disjunct) is REJECTED for the reason proposed — it
multiplies exactly what P-3 exists to prevent. The recorded cost (an
unfocused pane whose remembered mode is Takes shows read prose until
focused) goes to her walk's visual list.
**(c) VERDICT ACCEPTED — the flight latch stays model-local — on TWO
CONDITIONS, both to be pinned, not assumed:** (1) the
unrepresentability itself (under the mount rule, two door-bearing
surfaces on ONE post cannot co-mount — a pin that fails if the mount
rule is ever loosened); (2) the unmount-mid-flight path (the
pre-existing path gaining a new trigger — pinned as proposed). The
recorded edge (a book pane on P beside a note pane on P) is dead
under (b) and the record says so; if any future batch adopts (b)'s
alternative, the latch moves to a post-keyed shared authority FIRST.
**(d) APPROVED** — per-pane: chip, masthead-when-focused, quiet name
line when not (the difference IS the focus signal); per-window:
sidebar, toast, palette; the References/Scraps inspector stays
per-pane in v1 on the visual list, hoisting-to-the-window the
recorded fallback.
**The two findings:** `ShellRouter` shared across `WindowGroup`
windows → **batch 5's FIRST item** (per-window router/workspace
before any second window ships; nothing in batch 4 depends on it).
`splitFractions` in workspace state (pinnable, N-pane-shaped):
approved.

Item 0 (insertion order + drag-reorder) is ACCEPTED pending my own
runs at the batch's end — its pin flips are named and the
ordinals-do-not-shuffle pin is the property her ruling bought.

### Sitting round 9 — OPEN (2026-07-30): her copy-on-edit memory vs R31/R35

Her message, verbatim: *"honestly, wait. I thought that earlier we
decided that editing a post SHOULD always mutate it into a copy? i
thought that's how the app is working right now?"* — The record was
pulled and shown to her (R31 sitting 4 + her own sitting-5 verbatim
confirmation; the R31 record itself diagnosed this exact memory reach
in 2026-07-17: what the memory reaches for is the BLOCK rule —
pool-drag copies + lineage — and the version family). The app today
edits THE post everywhere (no copy-on-edit exists anywhere in the
ops layer). Her ruling on whether R31/R35 stand or reopen: PENDING —
recorded when she answers. NOTED as a P-5 signal regardless: this
confusion has now surfaced three times (sitting 4, today's round 8,
now) — the rule's UI legibility is the under-served half; W20's
visible in-line is part of the answer.

**Round 9 CLOSED — her ruling: "Stands + first-edit note."** R31/R35
stand exactly as decided 2026-07-17 (editing a post edits THE post in
every book; `duplicateAsVersion` the one deliberate divergence door)
— AND the first time she edits a post that appears in 2+ books, a
one-time quiet note says so and names the door ("editing here edits
it everywhere — Duplicate as Version to diverge"). **W22 (new row):**
the first-edit note — one-time via an app-local seen flag (the local
view-memory family; never synced, never schema), spoken in the host's
standing status/toast voice. Batch 5. The P-5 legibility signal is
thereby answered at all three layers: the in-line (W20), the wired
ascent (W20), and the moment-of-edit note (W22).

### Sitting rulings — round 10 (2026-07-30, the ascent's details + the diverge compound + the finish question)

Her message recorded verbatim-faithful in four parts; parses stated so
they can be corrected rather than trusted:

1. **The chip chooser's ordering, hers:** *"prioritizing manually
   adjusted books over smartbooks where it was auto added in the chip
   selector maybe, or what book you were most recently in or
   something"* (both floated, neither firm). **Shaping (architect,
   overturnable):** curated books before smart in the chooser; within
   each group the session's most-recently-visited floats to the top;
   the visible in-line names the TOP pick (+"& N more"). Rides W20.
2. **"the books it is in = the places you can navigate to" —
   RATIFIED** (smart matches included; derived membership IS
   membership, #26(h)).
3. **W21 confirmed as understood:** *"does that mean we are added
   something where clicking between outline/book/read carries your
   place?"* — YES; that is exactly W21.
4. **W23 (new row) — the DIVERGE-FOR-THIS-BOOK compound, hers:**
   *"'duplicate as version' should be a button you can click, not
   just an FYI (it seems a bit annoying to get the FYI but not have a
   button that nicely duplicates it as version and deletes the
   original for you all in one go - accessible from a menu maybe…)"*
   **Parse (stated):** "deletes the original" = removes the original
   from THIS book only — the copy takes the original's exact slot
   here; the original lives on in its other books and the library
   (deleting it globally would gut them; the standing chip "remove"
   wording's own rule). Composition: `duplicateAsVersion` +
   membership swap at position — standing ops, no new operation. The
   W22 first-edit note CARRIES the button; a menu door serves later
   times. Under a FINISHED book it refuses honestly (membership
   frozen — #25's letter). Batch 5.
5. **The finish/content question, hers verbatim:** *"what happens
   when a book is locked with a post in multiple places inside of it?
   i think it auto makes a version of it and deletes the original,
   right? because you can't lock it and have it be in other places
   unless you want to be annoyed. i guess we could support 'this post
   is locked everywhere' but that seems kinda frustrating and
   weird."* **The model fact, verified at the ops layer and told to
   her:** NOTHING auto-forks today — `lockReading` freezes
   STRUCTURE only (membership/order/chapters/extents); member posts'
   CONTENT stays live, and an edit made anywhere (another book, the
   library — single-book posts included) shows inside the finished
   book. Her instinct is a real finding about what "finished" MEANS
   for content; her floated mechanism (auto-fork at lock) and her
   rejected pole ("locked everywhere… frustrating and weird") are
   recorded. The edges need enumeration before any build
   (single-book posts are library-editable too; unlock semantics; do
   forks arrive sealed) — slotting question posed to her.

**Round 10 addendum — her clarification + the slotting ruling:** her
words: *"I guess I said 'finished' but I really meant 'locked', where
it can't be edited anymore. how does that change the question? or
does it not?"* — Answered on the record: it sharpens it. TWO book
states, only one existing: FINISHED (`reading.locked` — structure
frozen, text alive) exists; BOOK-LOCK (text immutability at book
level) does NOT exist — the only can't-edit machinery is the per-post
seal, which seals everywhere (her rejected pole). Her floated shape
IS the missing state's design: lock-the-book = auto-diverge shared
posts (W23's compound per post; the copy sealed here, the original
live elsewhere) + seal single-book members directly. **RULED: the
book-lock design goes to 13i's sitting** (knot 10 in its brief —
edges: lock-implies-finish?, unlock semantics, fork permanence,
naming the two states so "finished"/"locked" stop blurring — the
word-blur that produced this very round is part of the design).

### Batch 4 (cont.) — items 1–3 BUILT: THE SPLIT (W1/A25) + P-3 across panes + per-pane history

**Counts, by my own runs at build-complete:** Mac `✔ Test run with 1003
tests in 165 suites passed after 133.692 seconds` (`mac_exit=0`) · core
`✔ Test run with 906 tests in 102 suites passed after 29.172 seconds`
(`swift_exit=0`) · the tutorial spine on its OWN run, by TYPE name
(`TutorialBookShapeTests` · `TutorialDoorTests` ·
`TutorialWritingActsTests` · `TutorialTakesActsTests` ·
`TutorialStructureActsTests` · `TutorialLookingActsTests` ·
`TutorialLibraryActsTests`): `✔ Test run with 49 tests in 7 suites passed
after 12.069 seconds`. From the batch's baselines (906/102 · 987/159 —
987 being item 0's own result): **+16 Mac tests, +6 suites**; core
byte-unchanged. **Mobile deliberately NOT run** — zero `Sources/` and
zero `Shared/` lines (verified by `git status`), so the loop's own
condition is unmet; the phase's 14/4 stands.

**No schema. Zero `Sync/` lines. No Release build, no `/Applications`
refresh.** Her app was not running at any point (`pgrep` by path at open
and at close). Every commit staged by explicit path; nothing under
`notes/` outside this record was touched (sitting round 8 landed in the
file while I built and is untouched above). Commits: `34ad7f7` (item 0)
· `0fe1bb3` (the proposal) · `07d9f58` (items 1–3).

#### The shape, and why it is this one

The gate approved the MOUNT RULE, and the thing worth carrying forward is
that **it is not a new mechanism — it is the condition under which the
old ones stay correct.**

`PaneTextAuthority` enforces exactly-one-live-ring, and it enforces it
INSIDE one authority. Every authority owner (`TakesViewModel`, Compare's
model, `CanvasViewModel`, `BlockTOCView`) and every routed-command
handler (`EditorView`, `TakesBoardView`, `LensesBoardView`,
`CompareBoardView`, `CanvasView`) is mounted by a detail host. So the
whole extension is: **exactly the focused pane mounts a live surface.**
The unfocused panes render read-cheap —

- a **note** as `ReadPostView`, whose standing `onFocusRequest` migrates
  the ring and seeds the caret (byte-for-byte the Book spread's sibling
  page, and it keeps the ratified read-tier select+copy);
- a **book** through `BookViewModel.liveFocusedPostID` — its OWN single
  focus authority (13b 3E's fold) answering nil for a second REASON,
  never a second mechanism. `focusedPostID` itself is untouched, so a
  pane regaining focus restores exactly what she was editing;
- **every list surface** unchanged, because a list owns no authority and
  registers no handler (audited, not assumed).

**The evidence the shape is right:** `CommandRouter`'s single detail
registration, its LIFO handler stack and `EditorRouter.active` needed
**no change at all**. The rejected alternative (both panes live, a third
disjunct beside `sealed || structuralInFlight`) would have needed the
flag threaded into five surfaces AND a pane-keyed rewrite of all three.

#### State — the free-tiling rider in the shape, not in a comment

`panes: [PaneID]` · `selections: [PaneID: SidebarSelection]` ·
`focusedPane` · `splitFractions: [Double]` (DIVIDER positions, so a drag
edits one number and three panes need no new shape). Nothing is a pair;
nothing is named left or right. `WorkspaceModel.maximumPanes` is a **CAP
on a collection** — her two-panes-in-v1 ruling — so raising it is all
free tiling needs here.

`RootView.selection` became a computed **Binding over the focused pane's
entry**. That one change is what makes a sidebar click target the focused
pane *by construction*, with no new routing; and a row click inside an
UNFOCUSED list pane focuses and navigates in ONE click, because each
pane's sub-views get their own pane-aware `onOpen`.

#### Her round-7.3 rule, at ONE door

*"definitely not two live side by sides - we already offer that for one
note."* `select()` refuses a note another pane shows, focuses that pane,
and the shell speaks a sentence naming **Lenses** and **Compare**. Three
asks reach it — Open Beside on a shown note, ordinary navigation (sidebar
/ ⌘K / ⌘⇧n), and "beside itself" — so **no new door can bypass it**. A
scraps container counts as a note (it opens a detail host too); the
shelf, the library and a book do not, because two panes on the shelf is
nobody's confusion.

#### A FINDING, fixed at the door rather than at the caller

**Adopting and recording had come apart.** Batch 3 put the one recording
point in the shell's `onChange(of: selection)`, which was complete while
there was one pane and one selection. With panes, `openBeside` set a
selection *without* seeding the new pane's history — so a fresh pane
showed no chip, silently. That is batch 3's own shell-mount finding
recurring one level down (a wiring that fails by showing nothing).

`select()` now records the arrival itself, so the claim upgrades from
"the shell's onChange records" to "**the one adoption door records**" —
which cannot be bypassed by a door that writes a selection directly. The
shell's `onChange` stays as a harmless net (re-visiting the current
destination is a no-op by construction). *Found by my own model pins
failing, before any of this reached a window.*

#### Doors (P-1)

`CapabilityID.openBeside` — `[.menuBar, .contextMenu]` — and
`.closeSplit` — `[.menuBar]`; both **app-scope stack gates**, the
`undoAvailable` shape rather than a mode gate, so each is honestly grey
exactly when it could only refuse. The note-row menu is ONE grammar
rendered by three surfaces (the Open strip, the Library catalog, the
Pool), so `SidebarView.contextMenuCapabilities` declares it once for the
family. The **menu's** Open Beside picks the most recently opened note no
pane is showing — item 0's `recency` at its second job, which is the
whole reason order and membership were separated.

Deliberately **no new key equivalents**: the mandate is that every
shortcut is a menu item, not that every menu item is a shortcut, and a
new ⌘-chord here would have wanted its own collision sweep for no ruling
that asked for it. Recorded so it can be added at her word.

#### Item 3 — per-pane history, landed at the model

`WorkspaceModel.history()` now defaults to the **focused** pane. That one
default is where the gate's "focused-pane refinement" landed: ⌘[ / ⌘] and
the registry's `canNavigateBack` / `canNavigateForward` closures became
focus-aware **without a line changing at either end**. Each pane carries
its own chip (`PaneHost`), and closing a pane takes its trail with it.

#### THE GATE'S CONDITION (c) — both halves PINNED, not assumed

**(1) The unrepresentability, asserted where it BITES.**
`aSplitWindowMountsExactlyOneDetailAndOneCommandHandler` mounts a real
split in a real window (two real posts, the batch-3 hosting precedent)
and asserts the three app-scoped singletons still see ONE: `handlerCount
== 1` with two panes on screen, and `activePostID` following the FOCUSED
pane rather than the last-mounted one, across a focus migration in both
directions. The pure half (`PaneMount.liveCount == 1` for every
collection 1…5 and every focus) sits beside it, plus the corner that
makes it mean anything about the running app — `WorkspaceModel.focus`
refuses a non-member, so `focusedPane` is always in `panes`.

**Revert R4-A (the mount rule loosened to always `.live`) turns it red
with `handlerCount → 2` and `activePostID → the wrong post` — which IS
the LIFO misrouting hazard `SpreadBookView` names, reproduced live.**
That is the pin the gate asked for: loosen the rule and it fails.

**(2) The unmount-mid-flight path.**
`aDetailUnmountingUnderAFocusMigrationStillLandsItsText`: clicking the
other pane makes this one read-cheap, which unmounts its detail — a path
that already existed (a sidebar click during a ceremony does it) but that
the split gives a NEW trigger. The backstop is `teardown()`'s
`finalizeWork`, which flushes through the post's own autosave coordinator
while holding the model alive. Premise-asserted first (the buffer is
dirty and NOT yet in the store), so the pin cannot pass vacuously.

**The latch verdict therefore STANDS as ruled: it stays model-local.**
The recorded edge (a book pane focused on post P beside a note pane on P)
is dead under the mount rule and the pins say why.

#### Pins — every change named

**New suite `PaneSplitTests` (16 tests in 6 suites):** `PaneMountTests`
(2) the unrepresentability as arithmetic + the model's focus invariant ·
`PaneLayoutTests` (2) even fractions/widths incl. three panes, and the
drag that can never swallow a pane · `PaneSplitModelTests` (6) open
beside · **the same-note rule at all three doors** · close-split deleting
nothing · per-pane trails with the keys following focus · the Open Beside
candidate · the cap re-using the other pane · `PaneBookBlurTests` (1) the
book's half, including its one-click pane claim · `PaneSplitDoorTests` (3)
the declarations and their grey, the shell's one refusal voice, **and the
hosted unrepresentability pin** · `PaneUnmountTests` (1) condition (c)(2).

**Pins MODIFIED — two, both in the registry walk, each the new
declarations' own requirement:** `sampledContexts` **+1 context** (the
split's two gates — the same app-scope stack-gate family as undo, redo
and the workspace) and `theContextMenusRenderExactlyTheDeclaredContextDoors`
**+ `SidebarView.contextMenuCapabilities`**. Everything else passes
UNMODIFIED, including every other registry-walk assertion — the parity
proof that the two new declarations are additions, not adjustments.

**The registry walk earned its existence again:** it caught both new
doors as declared-but-not-rendered before any behavioural suite did.

**Reverts (`shasum -a 256` before each; all three files restored and
verified OK before the next):**
- **R4-A** the mount rule loosened ⇒ the pure pin red across every pane
  count AND the hosted pin red with `handlerCount → 2`, `activePostID →
  the wrong post`.
- **R4-B** the same-note guard dropped at the adoption door ⇒ exactly its
  arms red (the note lands in BOTH panes). Discriminating: `openBeside`'s
  own guard is separate and its arm stayed green, which is the right
  shape — two doors, two guards, two arms.
- **R4-C** the divider clamp dropped ⇒ the swallow pin red on all three
  arms (both edges and the neighbour-clamped middle).
- **R4-D** the book's blur ignored ⇒ the book pin red.

#### Judgment calls, recorded so they can be overturned rather than trusted

1. **A `.pool` counts as a note for the same-note rule** but NOT for the
   Open strip. The rule is about two detail hosts on one container, which
   `PoolDetailView` is; the strip's notes-only scope (round 7.2) is a
   different question and is untouched.
2. **Unfocused panes have no click-catcher overlay.** A note pane uses
   `ReadPostView`'s own focus door (which preserves the ratified read-tier
   select+copy); list panes focus through their row clicks; a book through
   `onPaneFocusRequest`. An overlay would have cost either the selection
   or a second click. The residue: a click on genuinely empty chrome in an
   unfocused pane does not focus it — visual-verification item 4.
3. **`BookViewModel.onPaneFocusRequest` rides the MODEL, not the views.**
   `model.focus(...)` has twelve call sites; one line at the model covers
   all of them, and no view had to learn that panes exist.
4. **The quiet name line IS the focus signal** (the gate's (d)), so an
   unfocused pane reads as a pane rather than needing a border or a tint.
5. **`closeSplit` closes the FOCUSED pane**, not "the second one" — which
   is what generalizes to N panes, and with two panes is exactly "close
   the split".
6. **No new key equivalents** (above), so no collision sweep was owed and
   none was run.

#### VISUAL-VERIFICATION-ONLY — for her walk and the Design & UI review row

Everything that DECIDES anything above is pinned. These are look-and-feel
halves and **no claim is made that they were tested:**

1. That the divider drags comfortably and its 9 pt grab strip is findable
   (and that the resize cursor appears over it).
2. That the split's two panes read as two panes — the quiet name line on
   the unfocused one against the masthead on the focused one.
3. **The gate's recorded cost:** an unfocused pane whose remembered mode
   is Takes shows read-cheap PROSE until clicked, then snaps to its board.
   (The Book spread has shipped with exactly this since 13c.)
4. That clicking anywhere sensible in an unfocused pane focuses it — the
   real doors are wired (read-tier click, row clicks, book post clicks),
   but empty chrome is not.
5. **The inspector** (References / Scraps) stays per-pane in v1 per the
   ruling; `.inspector` is designed for a `NavigationSplitView` column and
   nesting one inside an `HStack` pane is UNVERIFIED. Fallback recorded:
   hoist it to the window, pointed at the focused pane.
6. That "Open Beside" reads right in all three row menus, and that the
   same-note refusal is legible when it fires.
7. That a book in an unfocused pane still reads well with nothing live in
   it, and that regaining focus restores the page she was editing.
8. That the strip's rows really drag to reorder (item 0's half, carried).

#### For the orchestrator

- **PENDING, deliberately: nothing.** No PROVISIONAL was created, so
  `notes/QUESTIONS.md` is untouched (next free number stays **#49**).
- **Nothing exceeded its ruling's shape**, so no item stopped.
- **Batch 5's first item stands as ruled** and nothing here depends on
  it: `ShellRouter` is App-level `@State`, so a second `WindowGroup`
  window would share this workspace. The state shapes are ready for it
  (they are per-workspace, and a workspace is per-router).
- Her walk will notice, beyond the split itself: the detail pane's
  chrome is unchanged with one pane open (the name line only appears
  when a split exists), and a book or a list beside her is fully
  browsable while nothing in it is live.

### Sitting round 11 (2026-07-30) — the tag-surface ask

Her words, verbatim: *"do we have an easy way to add a new tag on a
post right now? a quick and intuitive area where you can see the
posts at a high level and remove / add them? i don't know which phase
it should go in if not but i do want that. not this one though"* —
**Answered: it EXISTS** — the Library catalog IS the R46 addable
batch-tagging surface (tags column, per-row "+" adding inline, one
tag to many posts; Pool likewise; taxonomy management in Settings per
R52). She was pointed at it for her walk. **If it fails her hands:**
the ask is recorded as a **13e kickoff candidate** (the
management-hands family; her "not this one" honored). **Pattern
noted on the record:** the third built-but-unfound door surfaced
today (the ascent chip W20, the divide original W10, now this) — the
standing Design & UI review row is the owner of that class, and its
first run after 13f is the recommended slot.

#### Batch 4 — ACCEPTED (2026-07-30; the orchestrator's adjudication — the session's cutover seam)

**Counts by my own runs:** core `✔ Test run with 906 tests in 102
suites passed` · Mac `✔ Test run with 1003 tests in 165 suites
passed` — both match the record's claims exactly (987/159 → 1003/165:
+16, +6 suites over item 0's state). **Load-bearing evidence read:**
the mount rule ships as the CONDITION under which the standing
mechanisms stay correct, not a new mechanism — and the proof
endorsed: `CommandRouter`'s single detail registration, its LIFO
stack, and `EditorRouter.active` needed ZERO change. **The gate's
condition (c) pins verified in the record:** the hosted
singleton-unrepresentability pin goes red under revert R4-A with
`handlerCount → 2` and the wrong `activePostID` — the LIFO
misrouting hazard reproduced live, exactly what the condition
demanded; the unmount pin is premise-asserted. **The adoption-door
finding endorsed as the batch's best catch:** `openBeside` seeding
the new pane's history at the ONE adoption door (`select()` records
the arrival itself) upgrades batch 3's shell-recording claim to
unbypassable — found by the implementer's own pins before any window
showed the silent no-chip state. The free-tiling rider held in the
state shape (pane collection; a Binding over the focused entry).
The acknowledged costs stand recorded for her walk (unfocused
Takes-mode pane reads as prose until clicked; the nested `.inspector`
unverified with hoisting as fallback — both on the visual list).
**Ledger: W1 BUILT** (the split, adjudicated) · item 0's strip flip
BUILT · W2 (windows) heads batch 5 behind the per-window router fix.

**CUTOVER:** this orchestrator session ends at this seam (~500k —
the standing context rule). The successor's role file:
`notes/plans/phase-13f-orchestrator-handoff.md` (paste-ready kickoff
at its top; batch 5's queue and every ruling live in THIS file's
rounds 1–11). Nothing is in flight; the tree is clean at this commit.

**Round 11 addendum (her follow-up: "does it exist within the post?")
— checked in code: NO.** `applyTag`'s reachable surfaces are exactly
Library, Pool, and the Folder/tags views; `PostDetailView` carries no
tags face — inside a note her tags are invisible and untouchable.
Recorded as the SECOND HALF of the 13e kickoff candidate (an in-post
tags face — see/add/remove from the note itself), with the note that
the W20 context bar ("in <book>") is its natural home when built:
books and tags are the two halves of "where does this live." Her
"not this one though" continues to govern the slotting.

### ORCHESTRATOR RESUMED — the successor session (2026-07-30); cutover state VERIFIED

Per the role handoff (`notes/plans/phase-13f-orchestrator-handoff.md`):
preflight reading complete (this file WHOLE; the handoff; the 13c
plan's "Environment traps"; the 13d closeout's "Standing notes for
successors"; `notes/QUESTIONS.md` — #32 the only open entry, next
free number **#49**). **Cutover state verified by my OWN runs, not
trusted:** tree clean at `0e2eb2d`, nothing in flight, no running
instances (`pgrep` by path), session unlocked; core `✔ Test run with
906 tests in 102 suites passed` (`swift_exit=0`) · Mac `✔ Test run
with 1003 tests in 165 suites passed` (`xcodebuild_exit=0`) — both
match batch 4's acceptance exactly. Mobile's re-verify stays owed at
phase end (the standing 14/4). Batch 5 proceeds on the queue the
cutover recorded.

### Batch 5 brief — windows (the per-window router + W2/A26, PROPOSAL GATE inside) + the books-ascent family (W21 · W20 · W22 · W23) (fresh Opus implementer; self-contained)

**Read IN FULL before touching code:** `CLAUDE.md` + the canon it
loads (AppSpec §4/§12; §14's 13c/13d deltas; §9's
`duplicateAsVersion`/`addPostToReading`/`removePostFromReading`/
`assignPostToSection` entries); THIS plan file WHOLE — the
constitution (P-3 and P-4 are this batch's law), THE KICKOFF SITTING,
sitting rulings rounds 1–11 (round 2 item 3 = both window kinds;
rounds 8–10 = the ascent family's rulings, HER VERBATIM WORDS —
build to them, not to my compressions below), batches 1–4's records +
acceptances (batch 2's P-4 reveal grammar and batch 4's proposal +
the architect's gate ruling are your precedents; batch 4's "For the
orchestrator" note names the ShellRouter finding you fix first); the
13c plan's "Environment traps" (binding); the batch 1–4 environment
traps (the hosted-ScrollView `scrollPageDown:` hang; `NSDraggingInfo`
fakes never drive `.dropDestination`; the zsh `git show`
history-modifier trap).

**Build order:** items 1–4 (the books family) FIRST, in the order
given (W21 before W20 — W20's landing consumes W21's anchoring
brain); then append THE PROPOSAL (item 5's gate) and STOP — the
windows build proceeds only on the architect's ruling. If your
context is running long when the gate closes, SAY SO in your report:
the windows build can go to a fresh session on the ruled proposal
(the standing cutover discipline) rather than to a degraded one.

**The items:**

1. **W21 — cross-mode position carry in books (round 8 ruling 2;
   round 10 item 3 confirms).** Switching `Outline · Book · Read`
   carries the CURRENT POST across — verified ABSENT today (the
   picker just sets `structure.mode`). Build ONE anchoring brain —
   "land mode M revealed at post P" — with per-mode landings:
   Outline scrolls to the post's row/card (posts open COLLAPSED per
   the #43(a) ruling — reveal means scroll-to, never a silent
   auto-expand; record if auto-expand feels wanted, for her walk);
   Book anchors the spread so P's page is showing (the standing
   leaf/nudge machinery); Read's scroll face scrolls to P, its Pages
   face opens P's first page (the (post, page-in-post) identity
   address). "Current post" per mode = what the mode already knows
   (the live/focused page, else the reading address, else the
   topmost visible post) — trace what each mode tracks before
   inventing state. The carry is the DEFAULT behavior of the mode
   click-over ("if you click over does it move where you are?" —
   her condition, answered YES). Arithmetic pure and pinned;
   red-on-old by behavioral revert.
2. **W20 — the ascent door (round 8 ruling 1; round 10 items 1–2).**
   Three halves, ONE bar: **(a)** wire `MembershipChip.onOpenBook` —
   VERIFY the round-8 trace yourself first (the closure is passed
   nowhere at its one `PostDetailView` mount; clicking a book name
   has done nothing since Phase 13) — fire-and-DO: open that book
   REVEALED at this post via item 1's brain, landing in the book's
   REMEMBERED mode (round 8's condition, satisfied by W21); history
   pushed through the ONE adoption door (batch 4's `select()`
   records) so ⌘[ returns. P-4: the chip posts a notification with
   (book, post) — the batch-2 `.variorumRevealUnplacedBlock`
   precedent — and `RootView` decides; the surface never navigates
   itself. **(b)** the "in <book>" IN-LINE joins the batch-3 back
   chip as ONE foldable context bar: one collapse state, one fold —
   never two hiding mechanisms (her ruling verbatim: chip + visible
   in-line, hideable "even if just with a keyboard command") — with
   ONE registry-declared toggle act (menu item + a key: sweep the
   chord FIRST per the standing key-table pin; pick a defensible
   free chord and record it). The in-line names the TOP pick +
   "& N more". **(c)** the chooser (the chip popover's list) orders
   CURATED BEFORE SMART, session's most-recently-visited floating
   within each group (round 10 item 1 — architect shaping, hers to
   overturn on the walk); smart matches ARE listed (round 10 item 2:
   derived membership IS membership, #26(h)). NO dedicated
   go-to-book shortcut (her middle pick); ⌘K reaches the act by
   name. P-8 binds on the bar (`lineLimit(1)`, bounded frames).
3. **W22 — the first-edit note (round 9's ruling).** ONE-TIME EVER
   (an app-local seen flag — the local view-memory family, never
   synced, never schema): the first time she edits a post that
   appears in 2+ books, the host's standing status/toast voice says
   editing here edits it everywhere and names the door (the ruled
   copy grammar: "editing here edits it everywhere — Duplicate as
   Version to diverge"), and CARRIES the W23 button (round 10 item
   4). Trigger mechanics: on a live pane's FIRST dirty change for a
   post, flag unset → one indexed membership-count read (off-main,
   P2; never per-keystroke) → speak if ≥2 and set the flag. Zero
   store bytes (pin).
4. **W23 — diverge-for-this-book (round 10 item 4; the parse is
   stated there so it can be corrected, not trusted).** The
   compound: `duplicateAsVersion` + membership swap at position —
   the copy takes the original's EXACT slot in THIS book (position
   AND chapter assignment `section_id` — the exact-slot letter,
   pinned); the original lives on in its other books and the
   library. CURATED books only — a smart-book target refuses
   honestly (derived membership has no row to swap; the refusal
   names the tag road; 13i owns that design). Under a FINISHED book
   the op fires and delivers its real refusal (#25's letter — P-2).
   Doors: the W22 note carries the button; a registry-declared menu
   door serves later times (post scope; renders when the post has
   ≥2 book memberships — the note's own condition; the ≥1 widening
   recorded for her walk). Target-book binding: the pane's
   arrived-from book when history shows one, else the W20 chooser
   grammar with nothing new invented — if that composition does not
   fall out cleanly, STOP and propose that half. UNDO: trace what
   each leg registers today; prefer ONE compound entry via the
   standing machinery if the legs carry exact-row inverses; if they
   do not, STOP and propose the honest shape (nothing here is
   unrecoverable either way — the re-add door and the tray both
   exist — but the story must be recorded, never implied).
5. **THE WINDOWS HALF — PROPOSAL GATE (binding; the batch-4
   pattern). Investigate and append a PROPOSAL under your batch
   record; then STOP.** Nothing of items 5a–5b builds before the
   architect's ruling. The proposal must cover, traced from code and
   not assumed: **(a)** the per-window router/workspace shape —
   `ShellRouter` is App-level `@State` on `VariorumApp`, shared by
   every `WindowGroup` window (batch 4's recorded finding; NOTHING
   ships a second window before this is fixed): what moves to
   per-scene state, what stays app-global (`AppSession`, theme,
   registry), and what window restoration does to session-scoped
   workspace state (record the behavior, don't guess); **(b)** the
   cross-WINDOW liveness extension — today's mount rule gives ONE
   live surface per window; two windows would give the app two.
   Trace `CommandRouter` (single detail registration, LIFO
   handlers), `EditorRouter.active`, and menu/⌘-key routing under
   TWO windows, and propose what "ONE live editor across all
   windows" (her round-2 ruling) means mechanically — the landing
   spot must be ON the standing authority seams, never a second
   mechanism (P-3; key-window-gated mounting is the obvious
   candidate — verify it against the singletons, don't assume it);
   **(c)** the same-note rule ACROSS windows (round 7.3 ruled panes;
   a note-only window on P while the main window navigates to P is
   the same class one level up) — propose the extension, and FLAG
   IT if your trace makes it product-flavored rather than
   structural; **(d)** the note-only window's chrome ("Open in New
   Window" = a lightweight note-only window, her round-2 pick):
   what it carries (chip? masthead? inspector?), what it
   deliberately lacks (sidebar, strip), how ⌘⇧n/⌘[/registry
   contexts resolve there; **(e)** the scene architecture (how the
   note-only `WindowGroup` is parameterized; the doors — File ▸
   New Window is the full-app kind, "Open in New Window" is a
   registry-declared act on note rows). **On the ruling, build:**
   the per-window router/workspace FIRST, then both window kinds.
   **W19 rider:** if the router refactor's diff touches the
   shell-redo status-delivery path
   (`theShellRedoActionRunsThroughTheRunnerAndReports`'s flaky
   machinery — the KnownIssues row this phase owns), trace its
   timing THEN (the hallucination guard binds — trace, never an
   untraced patch); if untouched, say so and leave it.

**Loop, records, constraints — identical to batches 1–4:** trace →
build → pins (red-on-old by behavioral revert where a pin CAN go
red; checksums before every revert; the model-layer honesty rule for
anything the SwiftUI drag/window route makes unpinnable — list the
visual halves honestly) → the tutorial spine green on its OWN run by
TYPE name → full suites with quoted "Test run with N tests" lines
(core from the repo root, Mac from `App/Variorum/`; mobile ONLY if
`Sources/` or `Shared/` is touched — the iPhone 17-family/16e
destination note). **Baselines to match-or-beat: core 906/102 · Mac
1003/165 · mobile 14/4.** Append your batch record under "Batch
records"; commit per convention with the standing trailer, staging
by EXPLICIT PATH ONLY (the author's parallel session works in
`notes/` — touch nothing of hers). Never `/Applications`, never
`Sources/VariorumCore/Sync/`, never push, never `git checkout` over
uncommitted work, NO schema. STOP-and-propose on anything exceeding
a ruling's shape. Every PROVISIONAL to `notes/QUESTIONS.md` (append,
never renumber; next free number **#49**).

### Sitting round 12 (2026-07-30, the successor orchestrator's first round) — the walk deferral · the extract one-liner RULED (W24) · the process-name overlap answered

Her message, verbatim: *"I'll just wait until this phase is done and
then I'll do a walkthrough of all the items together after my app is
refreshed. what's the extract one-liner? I typically can't open the
app and do quality gradings while phases are building because the
processes are named the same thing too."*

1. **The walk: DEFERRED TO PHASE END — her ruling.** All standing
   walk material — the batches' visual-verification-only lists (1–4
   so far, plus what later batches add), the QoL-handoff standing
   items, W10's copy in the field — bundles into the phase-end
   handoff and is walked ONCE, on the refreshed `/Applications`
   build (the closeout refresh precedes her walk, behind the A1 rail
   at a verified zero-instance window at her word).
2. **The extract one-liner ANSWERED, then RULED — W24 (new ledger
   row): WIDEN A11 TO EXTRACT** (her pick of the recommendation,
   posed via the question tool at this round). The 13d closeout's
   recorded "extract's identical drop … deliberately not widened —
   her call pending" is now called: the ONE seam-trim brain treats
   extract's seam like divide's — a blank line at the boundary
   survives on the piece before the seam, byte-for-byte, instead of
   extract's silent drop. Builds THIS phase: a Domain-level change +
   a red-on-old pin; slotted as a rider on batch 5's windows
   continuation (or the next batch if that session's context runs
   long); `Sources/` is touched, so the mobile suite runs with it.
   The 13d/QoL-handoff standing one-liner closes when it ships.
3. **The process-name overlap — her concern, verbatim:** *"i talked
   to claude about this earlier and i had the impression that the
   issue was greater than just the test host? like the bundle that
   it is with? i feel like there might be a greater overlap issue
   than just the name, it didn't seem so trivial previously"* —
   **VERIFIED against the 13b 4G record and the live project file:
   her memory is of the PRE-4G world, and it was accurate THEN.**
   Until 13b batch 4G (2026-07-22) the Debug test host shared her
   app's bundle id, and RunningBoard keys one-instance-per-login-
   session on bundle identity — the test host and her live app were
   structurally ONE app to macOS (the 9d-era Runningboard-error-5
   trap; test writes to `.standard` landed in HER defaults domain).
   4G split it with one line (pbxproj:627 — Debug-only
   `io.lduarte.Variorum.debug`; Release byte-untouched at :661,
   verified today): its own sandbox container (it cannot even read
   hers), its own defaults domain, the dev-store fence structurally
   stronger, and the proof runs included a full suite green BESIDE
   her live real-store instance. **What remains shared today is
   exactly the NAME** (two "Variorum"s in the Dock/app switcher)
   plus the flashing test-host windows during runs. Told to her with
   the facts: her real app is safe to use while batches run (the 4G
   unlock is the standing design; installs happen only at verified
   zero-instance windows at her word) — what mid-phase use cannot do
   is grade the NEW items, which reach her installed build only at
   the closeout refresh, so her defer-to-one-walk plan is exactly
   the designed flow. **The Debug-only display-name rename
   ("Variorum Dev") stands OFFERED, not taken** — her word rules it;
   if taken it lands at a clean seam (it touches the project file,
   never mid-batch), with the instance-discipline greps re-checked.

**Ledger add:** W24 — extract widens A11 (RULED; rider on batch 5's
continuation). **Rename offer:** OPEN with her.

**Round 12 addendum — the rename RULED, and the safe-to-run fact
confirmed to her.** Her words, verbatim: *"oh so that's not even an
issue right now? i can run my app at the same time? i'd say yes,
please give them the variorum dev display name, that would be
helpful."* → **(1)** Confirmed to her: yes — running her app beside
building phases has been safe by construction since 13b 4G
(2026-07-22); the one residue is the flashing test-host windows
during suite runs, harmless and now about to be labeled. **(2) W25
(new ledger row) — RULED: the Mac app target's DEBUG configuration
gains a "Variorum Dev" display name** (display string only —
`PRODUCT_NAME`/paths/bundle ids untouched, so the 4G identity split
and the path-based instance discipline are unmoved; Release
byte-untouched; the mobile target out of scope — her pain is the Mac
Dock). **Execution: an orchestrator environment act at batch 5's
acceptance seam** (the round-12 clean-seam rule — it touches the
project file, never mid-batch). Verification owed at execution: the
built Debug host's Info.plist carries the name; the Release config
block is byte-identical; one full Mac suite green after the change;
the instance-discipline greps re-checked (path unchanged by
construction).

### Batch 5 — the books-ascent family: W21 · W20 · W22 BUILT; **W23 STOPPED with a proposal**; the windows PROPOSAL appended (items 1–4 + item 5's gate)

**Counts, by my own runs at build-complete:** core `✔ Test run with 906
tests in 102 suites passed after 29.166 seconds` (`swift_exit=0`) · Mac
`✔ Test run with 1026 tests in 174 suites passed after 135.317 seconds`
(`mac_exit=0`) · mobile `✔ Test run with 14 tests in 4 suites passed
after 0.318 seconds` (`mobile_exit=0`) · the tutorial spine on its OWN
run, by TYPE name (`TutorialBookShapeTests` · `TutorialDoorTests` ·
`TutorialWritingActsTests` · `TutorialTakesActsTests` ·
`TutorialStructureActsTests` · `TutorialLookingActsTests` ·
`TutorialLibraryActsTests`): `✔ Test run with 49 tests in 7 suites
passed after 12.025 seconds`. From the batch's baselines (906/102 ·
1003/165 · 14/4): **+23 Mac tests, +9 suites**; core byte-unchanged.
**Mobile WAS run** — `Shared/` carries two files this batch
(`AppSession.swift`, `AutosaveCoordinator.swift`), so the loop's own
condition is met.

**No schema. Zero `Sync/` lines. No Release build, no `/Applications`
refresh.** Her app was not running at any point (`pgrep` by path at open
and at close; login session unlocked, probed not predicted). Every commit
staged by explicit path; nothing under `notes/` outside this record was
touched. Commits: `67ee0ff` (W21) · `96ee7f1` (W20) · `1532112` (W22).

#### W21 — the mode click-over carries your place

Her round-8 condition, verbatim: *"the remembered mode is fine as long as
there's a quick way to get from wherever you are in read to that same
point in book or outline - which I think there is? if you click over does
it move where you are?"* **Verified absent myself before building:** the
picker's setter was `structure.mode = $0` and nothing else; each of
Outline · Book · Read kept its own place.

**The brain is PURE and invents no state**, which is the design point.
`BookAnchor.currentPost` is ONE rule over facts the surfaces already
hold: Outline's place is the book's focused post; Book's is its spread's
LEFT page, unless the focused post is ON the spread (the page under her
hands keeps its claim — the `adopt` anchor rule restated); Read ▸ Pages'
is the reader's own (post, page-in-post) address. Every arm falls back to
a STANDING anchor rather than to nil, because a carry that lands nowhere
is indistinguishable from a carry that never happened.

**THE ONE FACT NO SURFACE HOLDS, stated rather than invented.** Read ▸
Scroll (`ReadingFlowView`) tracks no scroll position, and per-row
visibility reporting is exactly the machinery 13c 2A deleted on her A6
ruling (*"it seems a bit buggy… remove it fully for now"*). So **leaving
the scroll carries where she ARRIVED**, not where she scrolled to. It is
pinned as behaviour so it can never become a silent surprise, and it is
on the visual list for her walk — if she wants the scroll's own position,
that is a ruling about re-adding a subsystem she asked to have removed.

Landings, one parked request consumed by whichever surface mounts:
Outline scrolls to `page-<id>` (**reveal is scroll-to, NEVER an
auto-expand** — her #43(a) ruling; the collapsed CARD carries the same
anchor, so a collapsed post is revealed as well as an open one); Book
calls the standing `showPost`; Read ▸ Pages seeds/jumps its address **and
reports it back**, which is what makes leaving it carry at all; Read ▸
Scroll gains a `ScrollViewReader` and per-post anchors. Scroll ↔ Pages
carries too — Read's two faces are a mode switch by another name.

#### W20 — the ascent

**(a) THE TRACE, verified myself first (the brief required it).**
`MembershipChip` renders a post's books as clickable links wired to
`onOpenBook` — an **optional** closure — and `PostDetailView:86` (its ONE
mount, grep-confirmed across the whole app) passed nothing. **Clicking a
book name has done nothing since Phase 13 shipped.** The optional is
DELETED rather than filled in: a door whose reach depends on a caller
remembering to hand it one is the fire-and-DO class that produced the
bug. The act is a NAMED call (`MembershipChip.ascend`) that broadcasts —
the batch-2 lesson applied to a closure: *a promise made inside a view's
closure is a promise no test can keep.* P-4 holds: the door names (book,
post), `RootView` decides that means "navigate to the book and hand it
the post to land on", through the ONE adoption door — so history is
pushed and ⌘[ returns to the note, pinned end to end in a real window.
The landing is W21's slot; no second mechanism exists.

**RECORDED DISCREPANCY, deliberately not papered over.** Her round-8
ruling says the ascent lands in the book's *remembered* mode. **Books
have no per-book mode memory:** `BookStructureModel.mode` is seeded once
per open from `defaultMode(for:)` (finished ⇒ Read, else Outline). So it
lands in the mode the book OPENS in, revealed. Adding per-book memory
would supersede R2's ratified *"a finished book opens into the reading
flow"* — a product call, and hers.

**(b) ONE bar, ONE fold.** Her ruling: *"i think that chip + visible in
line is good, but I think that you should be able to hide it somehow
(even if just with a keyboard command). i love our uncluttered
interface."* Batch 3's `BackChip` becomes `ContextBar` carrying both
halves under ONE collapse state and ONE chevron — **never two hiding
mechanisms**. Collapsed, BOTH halves stay doors as glyphs (a fold that
removes the road back is a one-way door). It renders only when it has
something to say, so a cold launch at the shelf is byte-unchanged. The
bar lives per PANE, for batch 3's own reason: "where did I come from" and
"what is this inside of" are both the PANE's facts, so one bar serves a
post, a book, a folder and the recovery surface alike and Write's
masthead stays untouched.

**THE COLLISION SWEEP — result: ⌘⇧I is FREE.** Swept per the 13d A14 /
batch-3 precedent across `EditorCommands.keyEquivalent`, every
`.keyboardShortcut(` call site in `Variorum/` and `Shared/`, every
`NSMenuItem` key equivalent (all empty strings) and the one
`performKeyEquivalent` override (⌘S only): **no `i` chord of any modifier
combination is bound anywhere in the app.** The act is declared `always`
— a door whose whole job is to bring back a bar that is not on screen
must never be grey in the one state it exists for.

**(c) The chooser** (her round-10 shaping, architect-shaped and hers to
overturn): curated before smart, the session's most-recently-visited
floating INSIDE each group, name+id breaking ties so the order is total
and device-independent. **Smart matches are LISTED** — derived membership
IS membership (round 10 ruling 2, #26(h)); `readingsContaining` has
always returned them, verified in the query. ONE pure rule with TWO
readers (the popover and the in-line), so the sentence under the title
and the list it opens cannot disagree about which book comes first. Book
recency rides the ONE recording point (`visit`), bounded at 20.

#### W22 — the first-edit note

Wired at `AppSession.autosave(forPost:)` because that registry is the one
place that knows BOTH halves — which post an edit belongs to, and that
every editing surface on that post shares one coordinator (the N3
boundary). A per-surface hook would have been four hooks and a fifth to
forget, which is the class W20 had just finished finding. The coordinator
gains one `onFirstEdit`, fired once per instance.

The three ruled properties, all pinned: **ONE TIME EVER** (an app-local
seen flag — never synced, never schema); **NEVER PER-KEYSTROKE** (flag
first, so the common case is a `UserDefaults` read; the membership count
is read at most once per opened post, off-main, and never again once the
note has been said); **ZERO STORE BYTES** (variant / commit_point /
sync_outbox counts equal before and after). The count is
`readingsContaining`'s deliberately — the same "books it is in" the chip
and the bar use, so the sentence cannot claim a number the chip
contradicts.

**PENDING, deliberately:** her round-10 item 4 asked this note to CARRY
the W23 button. W23 is stopped (below), so the note ships naming the door
that exists and works today — the chip's own **Duplicate as Version** —
and gains the button when W23 is ruled. `StatusCenter.Item` carries text
only; adding an optional action to it is the small chrome addition W23's
build would make.

#### W23 — **STOPPED**, per the brief's own escape, with the honest shapes

The brief's instruction, verbatim: *"UNDO: trace what each leg registers
today; prefer ONE compound entry via the standing machinery if the legs
carry exact-row inverses; if they do not, STOP and propose the honest
shape."* **They do not, and the gap cannot be closed with standing
machinery.** The trace:

| Leg | Registers today |
|---|---|
| `duplicateAsVersion` | **YES** — `revertMintedContainer` + its redo |
| `addPostToReading` | **no entry** |
| `assignPostToSection` | **no entry** |
| `removePostFromReading` | **no entry** |

(Verified by grepping every `undoStack?.register` site in
`Sources/VariorumCore/Operations/`: not one reading-membership op
registers. `Operations+ReadingConversion` does, which is why the
smart→curated conversion round-trips.)

**The consequence, concretely.** Wrapped in `withCompound`, the entry's
inverse would be the mint's alone: ⌥⌘Z un-mints the copy — whose
membership cascades away with its container — and **leaves the ORIGINAL
still removed from the book**. The book ends up missing that post
entirely, with a menu item that says "Undo Diverge" having apparently
done it. That is a half-undo presented as a whole one, which is exactly
what the instruction refuses. Everything is recoverable by hand (the
chip's Add to Book), but the SLOT and the chapter assignment are not.

**Why I cannot simply give the membership legs an inverse:**
`UndoStack.register` is **internal** to `VariorumCore` (only
`@testable` callers reach it), so the app layer cannot register a
composed inverse; and letting a view register arbitrary inverses would
put a business rule in the frontend, which CLAUDE.md forbids for the same
reason the operations layer exists.

**Three honest shapes, with a recommendation:**

1. **(RECOMMENDED) A thin composite in the operations layer** —
   `divergePostForReading(post:in:)`: ONE transaction-composed act
   calling exactly the standing paths, registering ONE entry whose
   inverse and redo are built from do-time pre-images (the original's
   membership `position` and `section_id`; the copy's id). Undo becomes
   complete and redoable; the act reads as one thing because it is one
   thing. **The cost, stated plainly: it is a NEW OPERATION, and the
   round-10 shaping said "standing ops, no new operation."** That
   sentence was about not needing new *semantics* — this adds none — but
   it is the architect's to re-read, which is why I stopped rather than
   deciding it myself. Touches `Sources/`, so mobile runs; no schema.
2. **The mixed compound** — build as briefed, `withCompound`, and record
   in the plan and in the door's help that ⌥⌘Z reverses the copy only.
   Cheapest; ships today; leaves the half-undo real. I do not recommend
   it: the state it leaves (a book silently short one post) is worse than
   the thing the button saves her.
3. **No undo entry at all** — not reachable: `duplicateAsVersion` always
   registers its own, and a collected entry cannot be dropped.

Everything else about W23 is unblocked and unambiguous — the exact-slot
swap (position AND `section_id`), curated-only with an honest refusal
naming the tag road for a smart target, the finished-book refusal firing
the op and delivering `lockedReading` (#25's letter, P-2), and the two
doors (the W22 note's button; a registry-declared menu door rendered at
≥2 memberships). **On a ruling of shape 1 or 2, W23 is a short build.**

#### Pins — every change named

**New suite `BookAscentTests` (23 tests in 9 suites):**
`BookAnchorTests` (1) the whole mode/form table incl. every fallback and
the honest nil · `BookCarryTests` (7) the carry from each mode at the
model, the empty carry that keeps the last place, consume-exactly-once,
and the spread's real landing · `PagedAnchorReportTests` (1) the reader's
report following its address · `BookChooserOrderTests` (3) her order,
its totality, the in-line's three shapes · `ContextBarTests` (1) the
bar's presence in all four combinations, collapsed included ·
`AscentDoorTests` (4) the broadcast, the fold's declaration/key/doors/
always-availability, the toggle, book recency + its bound ·
`AscentRoutingTests` (1) the shell's whole decision in a real window ·
`MultiBookEditNoteRuleTests` (2) both trigger conditions + the ruled copy
· `MultiBookEditNoteTriggerTests` (3) once-only across two variants, the
end-to-end speech with ZERO STORE BYTES, and the one-book note that says
nothing while KEEPING the note owed.

**Pins MODIFIED — one, mechanical:**
`WorkspaceNavigationTests.theChipStateIsSessionStateAndStartsShowing`
reads `contextBarCollapsed` (the rename that made the two halves fold
together). The claim is unchanged. **Everything else passes UNMODIFIED**,
including every registry-walk assertion — the parity proof that
`.toggleContextBar` is an addition, not an adjustment (it needed no new
sampled context, being `always`).

**Reverts (`shasum -a 256` before each; all four files restored and
verified byte-identical afterwards):**
- **W21-A** the carry ignores the mode and reads focus ⇒ exactly the
  spread and paged arms red (`nil` vs `"p2"`; `"p0"` vs `"p1"`);
  outline, flow and consume stay green. Discriminating.
- **W21-B** `consumeReveal` never clears ⇒ the once-only pin red, twice.
- **W20-A** `ascend` reaches nobody (the pre-batch state) ⇒ the broadcast
  pin red AND the hosted routing pin red **with the pane still on the
  post** — the dead link reproduced live.
- **W20-B** the curated-before-smart clause deleted ⇒ both order arms
  red.
- **W22-A** `record` announces nothing ⇒ the coordinator pin red (0 vs 1)
  and the end-to-end pin red (nothing spoken).

#### Environment traps (new this batch)

1. **`xcodebuild test-without-building` after an edit runs the STALE
   product** — my first revert (W21-A) came back GREEN and looked like a
   hollow pin; it was a stale binary. Every revert since is
   `build-for-testing` → `test-without-building`. Worth stating because
   the failure mode is the dangerous direction: a revert that silently
   passes reads as "the pin proves nothing" and invites weakening a good
   pin.
2. `WorkspaceNavigation` is deliberately free of `VariorumCore` types
   (its `label` takes a title map, not containers) — a helper there that
   takes `[Reading]` fails to compile rather than importing the core into
   the navigation vocabulary. Take a name and a count instead.

#### VISUAL-VERIFICATION-ONLY — for her walk and the Design & UI review row

Everything that DECIDES anything above is pinned. These are look-and-feel
halves and **no claim is made that they were tested** (batch 1's
measurement stands: this host cannot drive SwiftUI's hosted scroll/drag
paths):

1. That Outline really SCROLLS to the carried post — and whether landing
   on a **collapsed card** reads right, or whether she wants the arrival
   unfolded (a ruling, not a fix).
2. That Read ▸ Scroll really scrolls to the carried post on arrival.
3. **The recorded gap:** leaving Read ▸ Scroll carries where she
   ARRIVED, not where she scrolled to — the flow tracks no position.
4. That the context bar reads as ONE bar rather than two chips, in both
   voices, light and dark, and that its collapsed form (`←` + a book
   glyph + the chevron) still reads as two doors.
5. That the "in <book> & N more" line does not crowd the back chip on a
   narrow pane, and truncates gracefully when a book has a long name.
6. That ⌘⇧I feels right for the fold (and that it collides with nothing
   in her muscle memory — the sweep proves only that the app binds it
   nowhere).
7. That the chip's book link now visibly ascends, landing on the right
   post, and that the book it opens is the mode she expects (the
   remembered-mode discrepancy above).
8. That the first-edit note reads as help rather than as a warning, and
   fires at a moment that feels like the right one.

#### For the orchestrator

- **W23 needs a ruling**, not a patch — the three shapes and the
  recommendation are above. It is the only item that stopped.
- **PENDING, deliberately: nothing else.** No PROVISIONAL was created, so
  `notes/QUESTIONS.md` is untouched (next free number stays **#49**).
- **W19 rider: the shell-redo flaky pin's machinery was NOT touched**
  (`ShellActions.structuralRedo` and its status delivery are outside this
  batch's diff, verified). Left alone as the brief instructs. The rider
  fires again if the windows refactor lands on the router.
- Her walk will notice, beyond the four items: a thin bar above the
  editor now says what book the note is in (and folds with ⌘⇧I); the
  book's mode picker keeps her place; and the very first time she edits a
  note that lives in two books, the app says so once.

---

#### THE PROPOSAL (item 5's gate) — the WINDOWS half, traced before building

Everything below is measured from the code. **The headline: the split's
mount rule generalizes to windows almost unchanged, but ONE thing must
move first — `ShellRouter` is App-level `@State` and therefore SHARED by
every `WindowGroup` window.** Batch 4 recorded this; I confirmed it at
`VariorumApp.swift:25`, where `@State private var router = ShellRouter()`
is created once on the `App` and handed to every `RootView` the group
mints.

##### (a) The per-window router/workspace shape

**Recommended: the router moves INTO the window's root view, and the app
keeps only what is genuinely app-global.**

```
per WINDOW  (moves):  ShellRouter — pendingSelection · paletteRequested ·
                      workspace (panes, selections, focusedPane,
                      splitFractions, histories, openNotes,
                      contextBarCollapsed, recentBookIDs, titles)
app-GLOBAL  (stays):  AppBootstrap · AppSession (store, operations,
                      runner, undoStack, commandRouter, status,
                      editorRouter, per-post autosave registry,
                      quitFinalize) · AppServices (sync/bridge/backup) ·
                      ThemeStore
```

The mechanism: `RootView` already takes `router:` with a defaulted
`ShellRouter()`, and already owns eight `@State` view models. Making the
router one more `@State` **created inside `RootView`** is a two-line
change at the type level. The obstacle is exactly one: **`EditorCommands`
holds `let router: ShellRouter`** and is attached to the scene, not to a
window — the menu bar needs *the key window's* router. Two candidate
resolutions, and I recommend the first:

1. **A tiny app-level `WindowRegistry`** (`[UUID: ShellRouter]` plus
   `keyWindowID`), written by each `RootView` on appear / on becoming
   key, read by `EditorCommands` through one computed `activeRouter`.
   This is the `CommandRouter`/`EditorRouter` pattern one level up — a
   session-scoped object holding registrations, with the same token
   discipline that already survives SwiftUI's arriving-before-departing
   ordering.
2. Keep the router app-level and key it internally by window id. Fewer
   moving parts, but every workspace read becomes "which window?" at the
   call site — the asymmetry the free-tiling rider asks me not to bake
   in, one level up.

**Window restoration, recorded rather than guessed:** SwiftUI restores
`WindowGroup` windows on relaunch, and **every piece of workspace state
is session-scoped by ruling** (batch 3: nothing persists, nothing syncs).
So a restored window comes back showing its `.shelf` default with an
empty strip and no history. That is consistent with the rulings but it is
a *behaviour* — if she expects a restored window to reopen its notes,
that is a new ruling about persistence, not a bug. I propose recording it
and NOT persisting anything in v1.

##### (b) Cross-window liveness — the mount rule, one level up

The four app-scoped singletons the split had to respect are unchanged and
are exactly the ones two windows would break (audited by grep, not
assumed):

| What | Shape | Writers |
|---|---|---|
| `CommandRouter.detailToken` / `activePostID` / `activeMode` / `applyMode` | ONE registration | `PostDetailView.onAppear` (the only site) |
| `CommandRouter.handlers` | a LIFO stack | `EditorView`, `TakesBoardView`, `LensesBoardView`, `CompareBoardView`, `CanvasView` |
| `EditorRouter.active` | a single `weak var` | `EditorViewModel` (set on attach, nil'd on teardown) |
| `AppSession.autosave(forPost:)` | already per-post | correct as-is |

Two windows each mounting a live detail ⇒ the second overwrites the
first's registration, the handler stack holds two entries and **every
routed act (⌘S, every structural and take door) reaches the
last-mounted surface rather than the key window's** — the LIFO
misrouting hazard `SpreadBookView` names, which revert R4-A already
reproduces live inside one window.

**Recommendation: extend the mount rule with a KEY-WINDOW gate, on the
same seam and with no new mechanism.** `PaneMount.kind(of:focused:)` is
already the one fork the shell consults; it gains the window's key-ness
as a second input, so the rule reads: **exactly one pane, in exactly one
window, mounts a live surface.** Concretely, `RootView` observes
`NSWindow.didBecomeKeyNotification` / `didResignKey` for its own window
and passes `windowIsKey` into the same fork it already calls. Every
consequence the split's audit relied on then holds unchanged at app
scope: ONE detail registration, ONE handler stack entry, ONE
`EditorRouter.active`.

**The cost, stated:** clicking from window A into window B unmounts A's
detail and mounts B's — the same re-mount cost a pane focus migration
already pays, and the same teardown/flush backstop
(`EditorView.onDisappear → model.teardown() → finalizeWork`) that batch
4's condition-(c)(2) pin covers. **I propose pinning it at window scale
too** rather than assuming the pane-scale pin transfers.

**The alternative I do NOT recommend** is the one batch 4 already
rejected one level down: let both windows mount live surfaces and make
the three singletons window-keyed. It multiplies exactly what P-3 exists
to prevent, and it would additionally require the flight latch to move to
a post-keyed shared authority (13d's trigger sentence), because two
windows CAN hold one post.

##### (c) The same-note rule across windows — **FLAGGED as product-flavoured**

Round 7.3 ruled panes: *"opening a note already showing in the other pane
could move you there … definitely not two live side by sides - we already
offer that for one note."* The structural half transfers exactly (under
(b) only one window is live, so "two live side by sides" is
unrepresentable across windows too, for free). **What does NOT transfer
is the refusal**: `WorkspaceModel.paneShowing` is per-workspace, so a
second window has no idea the first is showing that note, and answering
"is this note open in another window" needs the `WindowRegistry` from
(a).

And the question underneath is hers, not structural: **a second WINDOW on
the same note is a thing people deliberately want** (two views of one
document is the oldest Mac idiom there is), where a second PANE on it was
the thing she ruled out. Her wording — "the other pane" — does not reach
windows. **I recommend asking her**, and propose as the default until she
rules: **windows are NOT subject to the same-note rule** (the structural
danger is already dead under (b); the refusal would forbid something the
platform makes natural). Flagged, not decided.

##### (d) The note-only window's chrome

Her round-2 pick: *File ▸ New Window* = a full app window; *"Open in New
Window"* on a note = a lightweight note-only window.

**Carries:** the note's own detail (`PostDetailView` — masthead, mode
row, inspector), and the **context bar** (its back half is honestly empty
in a fresh note-only window; its "in <book>" half is exactly as useful
there as anywhere, and W20 already renders the bar only when it has
something to say — so this needs no special case).
**Deliberately lacks:** the sidebar (and therefore the Open strip), the
split, the shelf/library/pool destinations. A note-only window shows ONE
note, which is what makes it lightweight.

**How the app-scope acts resolve there** — this is the part worth ruling
explicitly, because "grey" and "absent" are different answers:
- **⌘⇧1…9 (Open Notes):** the strip is the full window's. In a note-only
  window `openNoteCount` reads 0, so the family is **honestly grey** by
  the registry's existing gate. No new rule.
- **⌘[ / ⌘] (back/forward):** a note-only window has one destination and
  no history, so both are **honestly grey** by the existing gate. If she
  wants a note-only window to accumulate history it would need its own
  workspace, which (a)'s shape gives it for free — one line, if ruled.
- **Open Beside / Close Split:** `paneCount` is 1 and `canOpenBeside` is
  false ⇒ grey. Correct as-is.
- **Everything editing-scoped** (⌘S, the structural and take families,
  find) works exactly as in the main window, because it routes through
  `CommandRouter` and this window mounts the live detail when it is key.

So the note-only window needs **no new capability declarations and no new
availability rules** — every app-scope act is already gated on a stack
whose count is honestly zero there. That is the registry earning its
existence again.

##### (e) The scene architecture

```swift
WindowGroup { … }                                   // the full app window (today's)
WindowGroup(id: "variorum-note", for: String.self) { $postID in … }   // note-only
```

The parameterized group is the standard shape and the app already uses
its unparameterized sibling twice (`variorum-helper`, `Settings`), so the
`openWindow(id:value:)` idiom is in place (`@Environment(\.openWindow)`
is already used in three files). Doors:

- **File ▸ New Window** — the full-app kind. `WindowGroup`'s own default
  New Window item does this for free once the router is per-window; I
  propose relying on it rather than declaring a capability for a
  system-standard menu item (nothing else in the registry duplicates a
  standard File-menu item).
- **"Open in New Window"** — a **registry-declared** act on note rows
  (`.contextMenu`, joining `SidebarView.contextMenuCapabilities` beside
  `.openBeside`, so the Open strip, the Library catalog and the Pool all
  render it from ONE declaration), app scope, gated on there being a note
  to open. It calls `openWindow(id: "variorum-note", value: postID)`.

**Two things I would build in this order on a ruling:** (1) the
per-window router/workspace + `WindowRegistry` + the key-window mount
gate, with its pins (the singleton-unrepresentability pin extended to two
hosted windows — the R4-A shape at window scale); then (2) the two window
kinds and their doors. **Nothing of (2) is safe before (1).**

##### The W19 rider

The router refactor in (a) **would** touch `ShellRouter` and the shell's
wiring, but not `ShellActions.structuralRedo` or its status delivery —
which is where `theShellRedoActionRunsThroughTheRunnerAndReports`'s
flakiness lives. This batch touched neither. If the ruled refactor's diff
reaches that path, its timing gets traced then (the hallucination guard);
otherwise it stays where it is.

**STOPPING HERE per the gate.** Items 1–3 are built, committed and green;
W23 awaits a ruling on its undo shape; items 5a–5b proceed on the
architect's ruling of (a)–(e).

**Context note (the brief asked):** my context is comfortable but no
longer short — roughly two thirds through the window I would want for a
build of the windows half plus its pins. **My recommendation: give the
ruled windows build to a FRESH session** (the standing cutover
discipline), and give W23's short build to whichever session runs next —
it is small enough either way.

#### Batch 5 (items 1–4) — ACCEPTED (2026-07-31; the orchestrator's adjudication)

**Counts by my own runs** (not the implementer's): core `✔ Test run
with 906 tests in 102 suites passed` (`swift_exit=0`) · Mac `✔ Test
run with 1026 tests in 174 suites passed` (`xcodebuild_exit=0`) —
both match the record's claims exactly; the quoted mobile line (14/4,
run because `Shared/` was touched) is accepted, with mobile's
re-verify by my own run owed at phase end per the standing rule.

**Load-bearing diffs read:** W20's fix deletes the optional closure
rather than filling it in — `MembershipChip.ascend` is a NAMED
broadcast and `RootView` decides (P-4; the batch-2 lesson applied to
a closure), which is the right level for the fire-and-DO class that
produced the bug; W22's hook lands at `AutosaveCoordinator.record`
(`firstEditFired` once per instance) wired at
`AppSession.autosave(forPost:)` — the ONE place knowing both halves,
flag-first so the common case is a defaults read; W21's
`BookAnchor.currentPost` is pure over facts the surfaces already
hold, every arm falling back to a standing anchor rather than nil.
The five reverts' discrimination is endorsed from the record
(W20-A reproducing the dead link live is the batch's proof done
right). **The stale-product trap is endorsed into the standing
record** (every revert = `build-for-testing` →
`test-without-building`; a green revert on a stale binary reads as a
hollow pin and invites weakening a good one — the dangerous
direction, now named).

**Judgment calls adjudicated:** the remembered-mode discrepancy was
rightly FLAGGED, not decided — it went to her (round 13 below); the
Read ▸ Scroll gap is ENDORSED as recorded behavior (the consequence
of her own A6 removal ruling; pinned; on her walk list); ⌘⇧I ENDORSED
(sweep-verified free; the muscle-memory half is her walk's); W22
shipping without the button ENDORSED as the honest interim (the
button lands with W23's build, below); the chooser's
curated-before-smart shaping was mine (round 10) and stays hers to
overturn at the walk. **Ledger: W21 BUILT · W20 BUILT · W22 BUILT**
(all adjudicated) · W23 ruled below · W19 rider correctly not fired.

### Sitting round 13 (2026-07-31, question batch — the two flagged product calls)

1. **Same-note ACROSS WINDOWS: ALLOW** (her pick of the
   recommendation). A note may show in two windows — two views of one
   document, the standing Mac idiom; only ONE is ever live (the mount
   rule guarantees it everywhere). The round-7.3 pane rule stands
   untouched WITHIN each window; no cross-window refusal machinery is
   built. This closes the proposal's flagged item (c).
2. **Book mode memory: LANDING + CARRY IS ENOUGH** (her pick). The
   ascent lands at the book's opening mode revealed at her post; any
   other mode is one carried click away (W21). R2's ratified "a
   finished book opens into the reading flow" stands whole; no
   per-book mode memory is built. The round-8 "remembered mode"
   wording is satisfied at this shape; the walk re-opens it only if
   her hands disagree.

### THE ARCHITECT'S RULINGS — W23's undo shape + the windows gate (2026-07-31; the gate closes)

**W23 RULED: shape 1 — the thin operations-layer composite**
(`divergePostForReading`-shaped: ONE transaction composing exactly
the standing paths; ONE undo entry whose inverse AND redo are built
from do-time pre-images — the original membership's `position` and
`section_id`, the copy's id). The round-10 "standing ops, no new
operation" sentence was MY compression and it meant no new
SEMANTICS — this adds none; what it buys is the honest undo entry,
and a half-undo presented as a whole one is the forbidden class the
implementer was right to stop on. CLAUDE.md's own rule cuts the same
way: every mutation flows through the transactional operations API,
so the composite belongs in Operations, not in a view. Shape 2
(the mixed compound) REJECTED for the implementer's own reason; §9's
entry lands at the closeout ritual per convention. Everything else
about W23 builds exactly as the batch record states (exact-slot swap
incl. `section_id`; curated-only with the honest smart refusal
naming the tag road; the finished-book refusal; the W22 note gains
its button — `StatusCenter.Item`'s optional action).

**The windows proposal, ruled (a)–(e):**
- **(a) APPROVED as proposed** — the router moves INTO `RootView`;
  a tiny app-level `WindowRegistry` (`[UUID: ShellRouter]` +
  `keyWindowID`) read by `EditorCommands` through one computed
  `activeRouter` (the CommandRouter pattern one level up); the
  keyed-app-level alternative REJECTED for the free-tiling-rider
  reason as proposed. Restoration behavior APPROVED as recorded:
  nothing persists in v1 — a restored window returns to the shelf;
  goes on her walk list as a named behavior, not a bug.
- **(b) APPROVED — the key-window mount gate on the SAME fork**
  (`PaneMount.kind` gains the window's key-ness): exactly one pane,
  in exactly one window, mounts a live surface; the both-live
  alternative REJECTED (batch 4's reason at window scale). **THREE
  CONDITIONS, all pinned, not assumed:** (1) the window-scale
  singleton-unrepresentability pin — the R4-A shape with TWO hosted
  windows (`handlerCount` stays 1; `activePostID` follows the KEY
  window across a key migration in both directions); (2) the
  window-switch unmount-mid-flight pin (the teardown/flush backstop
  at window scale, premise-asserted like batch 4's); (3) **the
  deactivation edge — the key-ness input must be STICKY
  (last-known-key), never literal keyWindow-now:** ⌘-tabbing to
  another APP resigns key with no successor window, and a literal
  reading would unmount the live surface on every app switch — a
  teardown/flush storm the split never had. Pin: app deactivation
  (resign with no new key window) unmounts and remounts NOTHING.
- **(c) RULED BY HER** (round 13): windows are NOT subject to the
  same-note rule. Nothing cross-window is built for it.
- **(d) APPROVED as proposed** — the note-only window carries the
  detail + the context bar and lacks sidebar/strip/split; the
  honest-grey resolution table endorsed (the registry earning its
  existence). Note-only history NOT in v1 (back/forward honestly
  grey there); the one-line widening recorded for her word.
- **(e) APPROVED** — the parameterized
  `WindowGroup(id:"variorum-note", for: String.self)`; File ▸ New
  Window rides the system-standard item undeclared (nothing else in
  the registry duplicates a standard File item — endorsed with the
  reason); "Open in New Window" is ONE registry declaration on the
  note-row family. **Build order BINDING: (1) the per-window
  router/workspace + `WindowRegistry` + the key-window gate with its
  three condition pins; then (2) the two window kinds and their
  doors. Nothing of (2) before (1).** The W19 rider carries: if the
  refactor's diff reaches the shell-redo status path, its timing is
  traced then.

**Continuation plan:** the CURRENT implementer session takes **W23
(ruled shape 1) + W24 (the extract rider, round 12) + the W22
button completion** — small, and its context serves them — then
stops for acceptance. **The WINDOWS build goes to a FRESH session
(batch 5b)** on the ruled proposal, per its own recommendation and
the standing cutover discipline; 5b's brief is THE PROPOSAL plus the
rulings above plus the standing loop — spawned after the
continuation's acceptance, never concurrently.

### W25 EXECUTED (2026-07-31, the orchestrator's environment act at the batch-5 acceptance seam — as ruled at round 12's addendum)

ONE line in the Mac app target's **Debug** config block only
(`INFOPLIST_KEY_CFBundleDisplayName = "Variorum Dev";` — anchored
inside the block carrying `io.lduarte.Variorum.debug`). **Every
recorded verification ran:** the diff is exactly that one insertion
(zero Release-block lines — checked); the built Debug host's
Info.plist reads `CFBundleDisplayName = Variorum Dev` under
`io.lduarte.Variorum.debug` (PlistBuddy on the DerivedData product);
her installed `/Applications` app is untouched (NO display-name key,
identifier `io.lduarte.Variorum` — read directly); the full Mac
suite on the renamed build: `✔ Test run with 1026 tests in 174
suites passed` (`exit=0`); the instance-discipline greps are
unmoved BY CONSTRUCTION (`PRODUCT_NAME` untouched, so the process
path is byte-identical — only the Dock/app-switcher label changes).
The Dock now tells her which "Variorum" is hers. **Ledger: W25
DONE.**

#### Batch 5 (continuation) — W23 (ruled shape 1) + the W22 button + W24; the windows half NOT taken (5b's, as ruled)

**Counts, by my own runs at build-complete:** core `✔ Test run with 916
tests in 104 suites passed after 28.558 seconds` (`swift_exit=0`) · Mac
`✔ Test run with 1030 tests in 175 suites passed after 134.044 seconds`
(`mac_exit=0`) · mobile `✔ Test run with 14 tests in 4 suites passed
after 0.262 seconds` (`mobile_exit=0`) · the tutorial spine on its OWN
run by TYPE name: `✔ Test run with 49 tests in 7 suites passed after
12.000 seconds`. From the continuation's baselines (906/102 · 1026/174 ·
14/4): **+10 core tests, +2 suites · +4 Mac tests, +1 suite**; mobile
byte-unchanged. **Mobile WAS run** — `Sources/` carries three files.

**No schema. Zero `Sync/` lines. No Release build, no `/Applications`
refresh.** Her app was not running at any point. Every commit staged by
explicit path; nothing under `notes/` outside this record was touched
(rounds 12–13, the acceptance, the rulings and W25 all landed while I
built and are untouched above). Commits: `5c8e9cf` (W23 + the W22
button) · `b9a93ec` (W24). Built on the tree as W25 left it.

##### W23 — the composite, as ruled

`divergePostForReading(_:in:)` in a new `Operations+Diverge.swift`. ONE
write composing the standing paths: `copyPost`'s body (the
`duplicateAsVersion` copy exactly), a membership row for the copy at the
ORIGINAL'S OWN `position` and `section_id`, and the original's row
tombstoned. The public membership ops each open their own
`database.write`, so a composite cannot call them without nesting
transactions — it inlines their guards and their writes instead, which is
`newPostInReading`'s standing pattern. **No new semantics: exactly the
rows the standing paths write.** `copyPost` widened private → internal
for its one new caller, with the reason in its doc.

**The undo entry is the whole reason this is an operation**, and the file
says so where a future session will read it: inverse = the original's row
out of its tombstone (its position and chapter were never rewritten, so
this is a tombstone flip, not a re-computation) + the copy's membership
tombstoned + the copy tombstoned; redo = the same three rows the other
way. Exact-row on do-time ids, so undo↔redo ping-pongs (13c 1B's
contract). Refusal buckets are the standing ones (a book deleted
meanwhile ⇒ quiet; FINISHED meanwhile ⇒ throws, entry stays for retry).

**Two calls recorded so they can be overturned rather than trusted:**

1. **CAPACITY IS NOT GATED, deliberately** — the swap is net-zero (one
   membership in, one out), so `addPostToReading`'s at-capacity refusal
   would refuse an act that does not grow the book. Stated in the op's
   doc and PINNED (`aBookAtItsPostCapCanStillDiverge`), rather than left
   silently true.
2. **THE DOOR IS THE CHIP'S BOOK ROW, not a menu item — a deviation from
   the brief's wording, stated.** A menu door needs a target and a
   context fact neither the shell nor the `CommandRouter` has (the pane's
   books are per-pane view state, resolved in `PaneHost`'s own `.task`),
   and its target would still have had to guess which book she meant. The
   chip's rows are where per-book acts already live — it has carried a
   per-book "remove" since Phase 13 — so the target is the row she points
   at. Declared `.surface`, the `.openPeerPost` class. **R118 parity is
   `.native` and LITERALLY true rather than an exemption:** the chip is
   in the post detail's MASTHEAD, which renders above every mode, so
   Takes reaches the door without a mode switch exactly as Write does.
   (The menu door remains one declaration away if she wants it; the
   ambiguity, not the effort, is why it is not there.)

The smart-book refusal has its own sentence because the generic one would
have been a dead end: *"'<book>' collects by its tags, so there is no
membership to move — a copy would only appear there if it carried the
same tags. Duplicate as Version, then tag the copy."* Everything else
falls through to the standing `ChipRefusals` wording, pinned as equal to
it.

##### The W22 button — completed

`StatusCenter.Item` gains an optional `Action` (label + closure); the
toast renders it and **dismisses as it acts** — an offer that survives
being taken reads as a question nobody answered. Every existing `speak`
call and every pin over them is unchanged (the parameter is defaulted).

**The target rule, extracted so it is pinnable:**
`MultiBookEditNote.divergeTarget` = the first CURATED book in the
chooser's own order. That is ONE rule which reduces to *"the book you
came from"* whenever there is one, because arriving at a book floats it
to the top of that order (W20's recency) — and it answers nil when every
membership is derived, so the note speaks WITHOUT a button rather than
offering an act that could only refuse (P-2, at a status offer). It sits
on the type rather than inside the trigger's closure for the reason
`MembershipChip.ascend` does. The window's recency reaches the app-global
session through one closure (`AppSession.recentBookIDs`, the
`openNoteCount` idiom), wired in `wireWorkspace`.

##### W24 — extract joins A11

**The change is that extract stops having its own rule.** Its span has an
inner edge, and that edge IS a cut — so `seamTrimmedHalves` expresses
extract with no second implementation: a PREFIX span is the first half
and owns the k−1 newlines; a SUFFIX span is the second half, so the
SOURCE owns them. "The piece before the seam owns the blank" holds in
both directions, which is A11 verbatim rather than a parallel to it. The
guards were already satisfied at that call site and the code now says why
(`extractableSpan` proves content on the far side, so the cut is
interior; `graphemeRange` proves alignment — kept as a CHECK now that the
halves are taken by offset). **The outer edges are untouched**: the span
still trims both of its own ends and the source's far edge is still left
alone, so exactly one byte class moved.

##### Pins — every change named

**New core suites (2):** `DivergeForBookTests` (6) — the exact slot + the
original keeping its other books and its own life · the copy being a full
version copy · **the undo↔redo round trip** (same membership row id, same
position, same chapter) · the three refusals · the at-capacity swap · the
assembly rendering the copy where the original stood. `ExtractSeamTests`
(4) — her ruling in BOTH directions on one text · the ordinary seams
byte-unchanged (the parity half) · **extract and divide agreeing on the
same three-newline seam** (the one-rule claim made testable rather than
asserted) · the outer edges unmoved.

**Grown Mac suite:** `BookAscentTests` **+ `DivergeDoorTests` (4)** — the
declaration and its honest grey · the copy (button label, ⌥⌘Z, the tag
road, and the fall-through equal to `ChipRefusals`) · the target rule
incl. the all-derived nil · a status note carrying one door.

**Pins MODIFIED — one:** the registry walk's surface union gains
`MembershipChip.surfaceCapabilities` (the new declaration's own
requirement). Everything else passes UNMODIFIED.

**Reverts (`shasum -a 256` before each; both files restored and verified
byte-identical):**
- **W23-A** the copy lands at the END with no chapter ⇒ **6 issues across
  three pins** — slot, chapter, redo's exactness, and the assembly's
  position.
- **W23-B** the inverse never revives the original ⇒ exactly the
  round-trip pin red: **the half-undo this operation exists to prevent,
  reproduced.**
- **W24-A** the pre-ruling extract (both sides trimmed away) ⇒ **5 issues
  across 3 pins**, including the extract-vs-divide agreement pin — the
  one that would catch a second implementation drifting apart later.

##### VISUAL-VERIFICATION-ONLY — for her walk

1. That the chip's book row reads well with THREE controls now (the book
   name, "diverge", "remove") and does not crowd at a long book name.
2. That "diverge" is legible as an act rather than as a label — and that
   its outcome sentence lands where she is looking.
3. That the first-edit note's button reads as an offer rather than as a
   warning's consequence, and that dismissing-as-it-acts feels right.
4. That the smart-book refusal reads as a road rather than as a wall.

##### For the orchestrator

- **PENDING, deliberately: nothing.** No PROVISIONAL was created, so
  `notes/QUESTIONS.md` is untouched (next free number stays **#49**).
- **One deviation flagged above** (the chip row instead of a menu item),
  with its reasoning, so it can be overturned rather than merely trusted.
- **The windows half was NOT taken** — it is 5b's, per the ruling and my
  own recommendation. Nothing here touches the router, the shell's
  wiring, or `PaneMount`, so 5b begins on a clean seam.
- **W19 rider: still not fired.** This continuation touched no part of
  the shell-redo status path; it fires for 5b's router refactor.
- Her walk will notice, beyond the two items: every book row in the chip
  now offers a one-click diverge, and the first-edit note carries a
  button naming the book it would act on.

#### Batch 5 (continuation) — ACCEPTED (2026-07-31; the orchestrator's adjudication — batch 5 CLOSES)

**Counts by my own runs:** core `✔ Test run with 916 tests in 104
suites passed` (`swift_exit=0`) · Mac `✔ Test run with 1030 tests in
175 suites passed` (`xcodebuild_exit=0`) — both match the record's
claims exactly; the quoted mobile line accepted per the standing
rule (phase-end re-verify owed).

**Load-bearing diff read:** `Operations+Diverge.swift` is the ruled
shape done right — ONE `database.write` with the membership guards
inlined (the `newPostInReading` pattern, stated with its
nested-transaction reason), the undo entry registered with BOTH
halves on do-time ids, and `revertDiverge`/`reapplyDiverge` as
guarded exact-row tombstone flips (a FINISHED-meanwhile refusal
keeps the entry for retry). Revert W23-B reproducing the half-undo
this operation exists to prevent is the discrimination the ruling
demanded.

**The four flagged calls, adjudicated:** **(1) the chip-row deviation
ENDORSED** — her round-10 "accessible from a menu maybe…" was hedged
by her own word, the trace is sound (a menu door has neither target
nor context; the chip's rows have carried per-book acts since Phase
13), and R118 parity is literally true via the masthead. **Routed to
her walk:** the door lives on the chip's book rows; the menu door is
one declaration away at her word. **(2) capacity un-gated ENDORSED**
— the swap is net-zero and the ratified extent gate refuses ADDS;
pinned rather than silently true. **(3) the button's target rule
ENDORSED** — one rule reducing to "the book you came from", nil when
every membership is derived so the note never offers an act that
could only refuse (P-2 at a status offer). **(4) the smart-book
refusal's own sentence ENDORSED** — a road, not a wall, pinned equal
to `ChipRefusals` elsewhere.

**Ledger: W23 BUILT · W22 COMPLETE · W24 BUILT — batch 5 closes
whole.** Remaining build rows: W2/A26 (batch 5b, next) · W4 stars ·
W5 sticky · W6+W15 the sweep · W17 exploratory (sitting material) ·
W18 hers · W19 rider (rides 5b). The four visual items join her walk
list.

### Batch 5b brief — the WINDOWS build (W2/A26 + the per-window router; fresh Opus implementer; self-contained; builds THE RULED PROPOSAL)

**Read IN FULL before touching code:** `CLAUDE.md` + the canon it
loads (AppSpec §4/§12; §14's deltas); THIS plan file WHOLE — the
constitution (P-3/P-4 are this batch's law), THE KICKOFF SITTING,
sitting rounds 1–13 (round 2 item 3 = both window kinds; round 13
item 1 = same-note ACROSS WINDOWS ALLOWED — her ruling), batch 4's
record (the split's shape you extend), batch 5's records (the seams
it left clean), **"THE PROPOSAL (item 5's gate)" — your design, and
"THE ARCHITECT'S RULINGS" — your contract: (a)–(e) as ruled, nothing
re-litigated**; the 13c plan's "Environment traps" (binding); the
batch 1–5 environment traps (chief: `build-for-testing` before every
`test-without-building` revert run; the hosted-ScrollView hang; the
zsh `git show` trap).

**Build order (BINDING, the ruling's letter):**

1. **The per-window router/workspace + `WindowRegistry` + the
   key-window mount gate**, with the ruling's THREE condition pins,
   none assumed: (i) the window-scale singleton-unrepresentability
   pin — the R4-A shape with TWO hosted windows (`handlerCount`
   stays 1; `activePostID` follows the KEY window across a key
   migration in both directions); (ii) the window-switch
   unmount-mid-flight pin (the teardown/flush backstop at window
   scale, premise-asserted like batch 4's); (iii) **the sticky-key
   deactivation pin** — the key-ness input is LAST-KNOWN-KEY, never
   literal keyWindow-now: app deactivation (resign with no successor
   window) unmounts and remounts NOTHING. Also pin what batch 3
   promised: two windows hold INDEPENDENT workspaces (own Open
   strip, own histories, own context-bar state). Restoration
   behavior recorded as ruled: nothing persists; a restored window
   returns to the shelf (a named behavior for her walk, never a
   silent surprise).
2. **The two window kinds and their doors:** File ▸ New Window rides
   `WindowGroup`'s standard item, undeclared (the ruled reason on
   the record); "Open in New Window" is ONE registry declaration on
   the note-row family (`.contextMenu`, joining
   `SidebarView.contextMenuCapabilities` beside `.openBeside`),
   calling `openWindow(id: "variorum-note", value: postID)`. The
   note-only window carries the detail + the context bar and LACKS
   sidebar/strip/split; every app-scope act resolves honestly grey
   there through the EXISTING gates (your own (d) table — if any
   act turns out NOT to resolve honestly through an existing gate,
   that is a STOP-and-propose, not a new rule). **Same-note across
   windows is ALLOWED (her round-13 ruling)** — build no
   cross-window refusal; the WITHIN-window pane rule stays
   byte-unchanged, its pins passing unmodified.

**The W19 rider (binding):** if your router refactor's diff reaches
the shell-redo status-delivery path
(`theShellRedoActionRunsThroughTheRunnerAndReports`'s machinery),
trace its timing THEN — the hallucination guard binds, never an
untraced patch; if untouched, say so and leave it.

**Pin honesty:** pane/window/key arithmetic pure and pinned
(red-on-old by behavioral revert; checksums; `build-for-testing`
first); the hosted pins as far as the host can drive real windows
(batch 4 hosted a real split — extend that precedent; where key-ness
or scene plumbing is genuinely undrivable, record the visual halves
honestly for her walk). What only a hand can verify (window feel,
restoration, the note-only chrome) goes on the
visual-verification-only list.

**Loop, records, constraints — identical to batch 5's:** tutorial
spine by TYPE name; full suites with quoted "Test run with N tests"
lines (core from the root, Mac from `App/Variorum/`; mobile only if
`Sources/` or `Shared/` is touched). **Baselines to match-or-beat:
core 916/104 · Mac 1030/175 · mobile 14/4.** Append your batch
record under "Batch records"; commit by explicit path with the
standing trailer (the author's parallel session works in `notes/` —
touch nothing of hers); never `/Applications`, never
`Sources/VariorumCore/Sync/`, never push, never `git checkout` over
uncommitted work, NO schema. STOP-and-propose on anything exceeding
the ruling's shape. Every PROVISIONAL to `notes/QUESTIONS.md`
(append, never renumber; next free number **#49**).

### Batch 5b — SEVERAL WINDOWS (W2/A26): the per-window router + `WindowRegistry` + the key-window gate, then both window kinds; commit `246065c`

**Counts, by my own runs at build-complete:** core `✔ Test run with 916
tests in 104 suites passed after 28.991 seconds` (`swift_exit=0`) · Mac
`✔ Test run with 1041 tests in 181 suites passed after 137.593 seconds`
(`mac_exit=0`) · the tutorial spine on its OWN run, by TYPE name
(`TutorialBookShapeTests` · `TutorialDoorTests` ·
`TutorialWritingActsTests` · `TutorialTakesActsTests` ·
`TutorialStructureActsTests` · `TutorialLookingActsTests` ·
`TutorialLibraryActsTests`): `✔ Test run with 49 tests in 7 suites passed
after 11.836 seconds`. From the batch's baselines (916/104 · 1030/175 ·
14/4): **+11 Mac tests, +6 suites**; core byte-unchanged. **Mobile
deliberately NOT run** — zero `Sources/` and zero `Shared/` lines
(verified by `git status`: every change sits under
`App/Variorum/Variorum{,Tests}/`), so the loop's own condition is unmet;
the phase's 14/4 stands.

**No schema. Zero `Sync/` lines. No Release build, no `/Applications`
refresh.** Her app was not running at any point (`pgrep` by path at open
and at close; login session unlocked, probed not predicted). ONE commit,
staged by explicit path; nothing under `notes/` outside this record was
touched. **Why one commit and not two:** `VariorumApp` mounts
`NoteWindowView` and `RootView` carries lines from both halves, so any
file-level split would have left a commit that does not build — worse
than a single honest one.

#### Two MEASUREMENTS made before anything was written

Both changed what got built, so they lead.

1. **This test host cannot make a window key.** `NSApp.isActive` is
   false in the XCTest host, `makeKeyAndOrderFront(_:)` leaves
   `isKeyWindow` false for every window, and **no `didBecomeKey` fires at
   all** (probed with two real `NSWindow`s before any design was fixed).
   Consequences, both load-bearing: the registry needed a FALLBACK for
   "nothing has been key yet" — which is a real state in the app too, and
   without which every batch-4 hosted pin would have gone red — and the
   hosted pins drive the chain by **posting AppKit's own
   `didBecomeKey`/`didResignKey` for a real hosted window**, which is the
   exact notification a click posts. What no pin here covers is AppKit's
   own posting of it under a real hand; that is on the visual list,
   stated rather than claimed.
2. **File ▸ New Window does not exist today.** Measured, not reasoned:
   the Debug app was launched and its File menu enumerated through System
   Events — `New Post · Today's Entry · — · — · Close · Close All ·
   Commit Take · — · Import Files… · — · Export Library… · Export Block
   as Markdown…`. No New Window item. The cause is this app's own
   `CommandGroup(replacing: .newItem)`: that is the group SwiftUI places
   its automatic New Window item in, and ⌘N was taken for New Post at
   R41. (The dev-store instance was quit afterwards; her real-store app
   was never running.)

#### Item 1 — the per-window router, the registry, the key gate

**What moved, and what deliberately did not.** `ShellRouter` is
`RootView`'s own `@State` now; `AppSession`, `AppServices`, `ThemeStore`'s
owner and the capability registry stay exactly where they were. The app
keeps ONE new object, `WindowRegistry`, because two things are genuinely
app-wide and must still find the right window: the SCENE-attached menu
bar (`EditorCommands` reads `activeRouter`), and the mount gate.

**The gate is one input on the fork that already existed.**
`PaneMount.kind(of:focused:windowIsKey:)` — the ruling's (b), literally:
*exactly one pane, in exactly one window, mounts a live surface.*
`windowIsKey` is **defaulted true**, which is deliberate: it keeps this
ONE fork rather than two, and every batch-4 pane pin reads UNMODIFIED —
the parity proof that the window gate is an addition, not an adjustment.
`PaneMount.WindowState` + `liveCount(across:)` state the app-scale
invariant as arithmetic.

**The key is STICKY, with no resign door at all** (the ruling's condition
3). The registry's `keyOrder` moves only when a window becomes key or
when the key window unregisters. The header says why in the file, and
revert R5b-B shows what a resign door costs.

**TWO problems the second window creates, fixed at the level they live
at — neither was in the proposal, and both would have shipped as
defects:**

1. **The menu's gates answered for the wrong window.** `CommandRouter` is
   the APP's, and batch 3 wired its workspace closures (`openNoteCount`,
   `canNavigateBack/Forward`, `paneCount`, `canOpenBeside`, plus
   `session.recentBookIDs`) to *a* window's workspace in `onAppear` —
   with two windows, last-appear wins, so Back / Forward / ⌘⇧n would
   answer for a window she is not in. They read `windows.activeRouter`
   now, which additionally makes `wireWorkspace` **idempotent across
   windows**: whoever runs it last installs the same closures.
2. **One broadcast navigated BOTH windows.** `.variorumOpenPost`,
   `.variorumRevealUnplacedBlock` and `.variorumOpenBookAtPost` are
   posted to the whole app and every full window listens — P-4's own
   class, arriving the moment windows do. `RootView.claimBroadcast()`
   admits exactly one, and the rule is **not** `isKey`: it is
   `WindowRegistry.navigationTargetID` — the key window when it can
   navigate, else the most recently key FULL window. That second clause
   is what keeps a book link clicked in a NOTE-ONLY window from being a
   dead door, which is precisely the class W20 was built to kill; a
   window that acts while it is not the one she is looking at raises
   itself (`bringForward`), so what she asked for arrives in front of
   her.

#### Item 2 — both window kinds

**File ▸ New Window** — a plain, UNDECLARED `Button` in the `.newItem`
group calling `openWindow(id: "variorum-main")` (the main group gained an
id). **This is a deviation from the ruling's wording** ("rides
`WindowGroup`'s standard item") and it is flagged as one — but the
measurement above shows the standard item is not there to ride, and the
ruled REASON (nothing in the registry duplicates a standard File item) is
honored exactly: it is still undeclared, still in the standard place.
**No key equivalent**: ⌘N is New Post's, and inventing a chord would owe
a collision sweep no ruling asked for (batch 4's precedent). One
declaration away at her word.

**"Open in New Window"** — `CapabilityID.openInNewWindow`, app scope,
`[.contextMenu]`, rendered by the note-row family through
`SidebarView.contextMenuCapabilities` (the Open strip, the Library
catalog, the Pool — ONE declaration, three renderers, exactly as
`.openBeside`). Its availability is `always`, and the file says why so
nobody later reads it as a missing gate: the door is rendered only on a
note ROW, so its target always exists — the `.diffAgainstChosen` /
`.showOriginBlock` split (P-2).

**The note-only window** carries the detail + the context bar and lacks
sidebar, strip and split. Its workspace is set with **`showOnly`, which
records NOTHING** — no history, no Open strip, no book recency — and that
silence IS the mechanism behind the ruling's promise: `openNoteCount` 0,
`canNavigateBack/Forward` false, `openBesideCandidate` nil, `panes.count`
1 give four honest greys through the gates that already exist, and **not
one new availability rule was written for this window.** Everything
editing-scoped (⌘S, the structural and take families, find) works there
exactly as in the main window, because it routes through the app's
`CommandRouter` and this window mounts the live detail whenever it is
key. Note-only HISTORY is not in v1 as ruled; the workspace is there and
one line would give it one.

**Same-note across windows is ALLOWED** (her round-13 ruling): no
cross-window refusal machinery exists, and the WITHIN-window pane rule is
byte-unchanged — every batch-4 same-note pin passes unmodified.

#### Pins — every change named

**New suite `WindowsTests` (11 tests in 6 suites):** `WindowRegistryTests`
(2) the sticky key + the fallback + the key leaving with its window · the
navigation target across full/note-only windows · `PaneMountWindowTests`
(2) the app-scale invariant for 1–3 windows and every key, the no-key
state counting ZERO, and a focused pane in a non-key window being
read-cheap (the gate is AND, not OR) · `NoteOnlyWindowTests` (2) the four
honest greys read through the SAME registry gates, with two editing acts
still enabled beside them · the door's declaration ⇔ rendering ·
`IndependentWorkspaceTests` (1) two strips, two trails, two folds — the
claim batch 3 made and batch 4 found false for windows ·
`TwoWindowMountTests` (3) **the ruling's conditions (1) and (3)** plus the
menu-gates/broadcast pin · `WindowUnmountTests` (1) **condition (2)**.

**Pins MODIFIED: NONE.** Every registry-walk assertion passes unmodified
— `.openInNewWindow` grows BOTH sides of
`theContextMenusRenderExactlyTheDeclaredContextDoors` by construction,
declares no menu-bar door, no shortcut label and no `takesAccess` (app
scope), and is reachable in every sampled context. That is the parity
proof for a batch that added a capability, a scene and a mount input.

**Reverts (`shasum -a 256` before each; all four files restored and
verified OK before the next; `build-for-testing` → `test-without-building`
every time, per the standing stale-product trap):**

- **R5b-A** the key gate removed from `PaneMount.kind` ⇒ **13 issues**:
  `handlerCount → 2` with two windows on screen and `activePostID → the
  wrong post` — **the LIFO misrouting hazard reproduced live at window
  scale**, the R4-A shape one level up, which is exactly what condition
  (1) asked for. Batch 4's own `PaneMountTests` stayed GREEN (the pane
  rule is untouched by the revert) — discriminating in both directions.
- **R5b-B** a resign door added to the registry and wired to
  `didResignKey` (the literal keyWindow-now reading, in mechanism form)
  ⇒ **3 issues**: after an app deactivation `activePostID → nil` and
  `handlerCount → 0` — the live surface torn down and nothing remounted,
  **the teardown/flush storm condition (3) exists to prevent**. The other
  two hosted pins stayed green.
- **R5b-C** `wireWorkspace` bound to its own window's workspace again ⇒
  the menu answers `openNoteCount → 0` while the key window has a note
  open. (Discriminating under EITHER window's appear order: whichever
  window wins, one of the pin's two arms is wrong.)
- **R5b-D** `claimBroadcast` always true ⇒ one broadcast navigates BOTH
  windows — window A jumped to the other window's post.
- **R5b-E** `showOnly` replaced by an ordinary `select` ⇒ the note-only
  window's strip fills and ⌘⇧1–9 lights up: the honest greys become
  dishonest.

#### Judgment calls, recorded so they can be overturned rather than trusted

1. **File ▸ New Window is an explicit undeclared button**, not the
   standard item — because the standard item is measurably absent (above).
   The alternative (`CommandGroup(after: .newItem)`, letting SwiftUI's own
   item back) would put a second ⌘N in the File menu.
2. **The broadcast target is `navigationTargetID`, not `isKey`.** The
   `isKey` reading is simpler and I rejected it for one concrete reason: a
   book link in a note-only window would then reach nobody. The cost of my
   choice is that the book opens in the main window, which raises itself —
   visual item 5.
3. **`bringForward` raises the acting window.** One line, and without it
   the act above happens somewhere she cannot see. Uses the `NSWindow` the
   key reporter already hands over.
4. **Each window builds its own view models** (`LibraryViewModel`, the
   catalog, the pool, `ThemeStore` …), since they are `RootView` `@State`.
   That is the honest meaning of per-window state and it is bounded by the
   window count; the alternative (hoisting eight observations to the app)
   is a bigger change than this ruling asked for.
5. **The status toast renders in every window**, because `StatusCenter` is
   app-global and each window overlays it. A refusal fired in one window is
   therefore visible in both. Left as-is deliberately: the alternative is
   per-window status, which is a real design question and hers.
6. **Note-only windows never listen to navigation broadcasts** — they
   navigate nowhere, so listening could only produce a request they cannot
   honor.

#### VISUAL-VERIFICATION-ONLY — for her walk and the Design & UI review row

Everything that DECIDES anything above is pinned. These are the halves
this host cannot drive, and **no claim is made that they were tested:**

1. That AppKit's real become-key (a click on a window) actually reaches
   the reporter — the pins post the notification AppKit posts; nobody has
   watched a click do it. **The whole windows feature rests on this one
   wire**, so it is the first thing to try: click between two windows and
   watch the live editor follow.
2. That ⌘-tabbing to another app and back leaves the live surface exactly
   as it was (the sticky key, in her hands).
3. That File ▸ New Window appears where a Mac user expects it, and that
   the second window opens at the shelf (RESTORATION, as ruled: nothing
   persists — a relaunched window returns to the shelf; a named behavior,
   not a bug).
4. That "Open in New Window" reads right in all three row menus, and that
   the note-only window's chrome (context bar over the detail, no sidebar)
   feels lightweight rather than truncated.
5. That clicking a book link in a NOTE-ONLY window — which opens the book
   in the main window and raises it — reads as helpful rather than as a
   surprise.
6. That the status toast appearing in both windows is tolerable (judgment
   call 5).
7. That two windows on the SAME note read well (her round-13 ruling
   allows it) — one live, one showing read-cheap prose.

#### For the orchestrator

- **PENDING, deliberately: nothing.** No PROVISIONAL was created, so
  `notes/QUESTIONS.md` is untouched (next free number stays **#49**).
- **Nothing exceeded the ruling's shape**, so nothing stopped. The two
  places the build went beyond the proposal's letter (the broadcast
  target; the explicit New Window button) are both flagged above with
  their measurements and reasoning.
- **W19 rider: NOT FIRED.** The refactor moved WHO HOLDS the router, never
  the redo status-delivery path — `ShellActions.swift`, `ShellRouter.swift`,
  `StatusCenter.swift` and `OperationsRunner.swift` are all UNTOUCHED
  (verified by `git status`). `theShellRedoActionRunsThroughTheRunnerAndReports`
  passed in both full Mac runs today. Left where it is, as the brief
  instructs; its KnownIssues row stands.
- Her walk will notice, beyond the windows themselves: the File menu has a
  New Window item for the first time; note rows carry a second window door
  beside Open Beside; and with two windows open the menu bar's Back /
  Forward / Open Notes answer for the window she is actually in.

#### Batch 5b — ACCEPTED (2026-07-31; the orchestrator's adjudication)

**Counts by my own runs:** core `✔ Test run with 916 tests in 104
suites passed` (`swift_exit=0`) · Mac `✔ Test run with 1041 tests in
181 suites passed` (`xcodebuild_exit=0`) — both match the record's
claims exactly; the mobile-not-run condition verified in the diff
stat (zero `Sources/`, zero `Shared/` lines).

**Load-bearing diff read:** `WindowRegistry` is the ruled shape with
its reasons IN the file (the sticky key has NO resign path — the
condition-3 header; the never-key fallback carries its measurement);
the mount gate is ONE input on the EXISTING fork with `windowIsKey`
defaulted true, which is why every batch-4 pane pin reads unmodified
— the parity proof done the same way twice. All three ruling
conditions are pinned and their reverts discriminate (R5b-A = the
LIFO hazard live at window scale; R5b-B = the deactivation teardown
storm, reproduced by building the literal-key reading as a
mechanism).

**The flagged calls, adjudicated:** **(1) the explicit New Window
button ENDORSED** — the deviation is from the ruling's WORDING and
the measurement is decisive (the standard item does not exist;
`CommandGroup(replacing: .newItem)` — R41's ⌘N — replaced the group
SwiftUI puts it in); the ruled REASON holds (undeclared, standard
place); the two-⌘N alternative rightly rejected. **(2) the
`navigationTargetID` broadcast rule ENDORSED** — the `isKey` reading
would make a book link in a note-only window a dead door (the exact
class W20 killed), and the two defects it fixed (menu gates
answering for the last-appeared window; one broadcast navigating
both) are the P-4 class arriving WITH windows, caught before any
window shipped. **(3) `bringForward` ENDORSED** (an act she cannot
see is worse than a raised window; visual item 5 carries the taste
half). **(4) per-window view models ENDORSED** (the honest meaning
of per-window state, bounded by the window count; the standing
observation bounds ride each copy). **(5) the app-global status
toast LEFT AS-IS, routed to her walk** (visual item 6) — per-window
status is a real design question and hers. **(6) note-only windows
never listening ENDORSED** (a listener that could only mint
unhonorable requests). The one-commit call endorsed (a file-level
split would not build).

**Ledger: W2/A26 BUILT** (both window kinds on the per-window
architecture) — adjudicated. **W19 rider correctly not fired** (the
status path untouched, verified in the diff; the KnownIssues row
stands). The seven visual items — chief among them the one wire no
pin can watch (a real click's become-key reaching the reporter) —
join her walk list. Remaining build rows: **W4 stars + W5 quick-note
(batch 6, briefed below) · W6+W15 the K5 sweep (batch 7, LAST)**;
W17 stays exploratory sitting material; then the phase-end cold
review and the closeout.

### Batch 6 brief — W4 STARS + W5 the QUICK NOTE (fresh Opus implementer; self-contained; PROPOSAL GATE on W5's window/door mechanism)

**Read IN FULL before touching code:** `CLAUDE.md` + the canon it
loads (AppSpec §7's `setting` table + §9; §12; §14's deltas); THIS
plan file WHOLE — the constitution, THE KICKOFF SITTING, sitting
rulings rounds 1–13 (round 3 items 1–2 are YOUR two rulings — build
to her words), batches 1–5b's records + acceptances (5b's
`WindowRegistry`/mount-gate machinery is what W5's window composes
with; the batch-2 P-4 broadcast grammar; the standing environment
traps, chief: `build-for-testing` before every revert run); the 13c
plan's "Environment traps" (binding).

**The items:**

1. **W4 — STARS (her round-3 ruling, verbatim shape):** a synced
   `setting` list — the `shelf_pins` precedent, ZERO schema, no §12
   event — holding up to **5** starred things, notes or books.
   Star/unstar via context menu on note rows AND book rows
   (registry-declared; the note-row family via
   `SidebarView.contextMenuCapabilities`, the shelf's book rows via
   their own surface's declaration) + ⌘K by name. A **Starred
   section at the sidebar's TOP**; rows navigate through the shell's
   ordinary selection exactly as the Open strip's do (books to the
   book, notes to the note). The CAP refuses honestly at the 6th —
   fire-and-DO: the refusal names un-star as the road (P-2; never a
   silently missing door). Star order = star time (insertion);
   un-star anywhere (the section's rows carry it too). The `setting`
   value syncs (upsert-only, the shelf_pins class) — tombstoned/
   deleted targets render nothing and self-heal on next write (state
   the read rule; pin it). Pure list arithmetic pinned red-on-old.
2. **W5 — the QUICK NOTE (her round-3 ruling: a FLOATING
   MINI-WINDOW; global shortcut / menu-bar door; typing mints an
   ordinary bookless note — the Pool lists it; the sticky face shows
   NO takes machinery; the note persists when the window closes).**
   **PROPOSAL GATE FIRST on the mechanism half — investigate and
   append a short proposal, then STOP for the architect's ruling,
   covering:** (a) the WINDOW: what "floating" rides (a third
   `WindowGroup` vs an `NSPanel`-class window; its level, its
   key-ness under 5b's mount rule — the mini editor takes the live
   ring while key, P-3 on the standing authority, never a second
   mechanism; what `WindowRegistry.Kind` it registers as); (b) the
   DOORS: what "global shortcut" can honestly mean (an app-global
   chord — sweep it — vs a system-wide hotkey and what that
   requires; whether a menu-bar STATUS ITEM is in scope or the
   File-menu door suffices for v1), with a recommendation and costs
   stated; (c) the MINT path: the sticky face mints through the
   standing quick-entry grammar (#26(e) — untitled, typed text
   segments as content, bookless so the Pool lists it, R29) — name
   the exact path it rides. **The face half (a mini editing surface,
   no takes machinery, note persists on close) builds after the
   ruling with the window half.** If the system-wide hotkey needs
   anything permission-shaped, that is an author-machine act — STOP
   on that half and record it; never work around it.

**Loop, records, constraints — identical to batch 5b's:** tutorial
spine by TYPE name; full suites with quoted "Test run with N tests"
lines; mobile only if `Sources/` or `Shared/` is touched.
**Baselines to match-or-beat: core 916/104 · Mac 1041/181 · mobile
14/4.** Append your batch record under "Batch records"; commit by
explicit path with the standing trailer (the author's parallel
session works in `notes/` — touch nothing of hers); never
`/Applications`, never `Sources/VariorumCore/Sync/`, never push,
never `git checkout` over uncommitted work, NO schema.
STOP-and-propose on anything exceeding a ruling's shape. Every
PROVISIONAL to `notes/QUESTIONS.md` (append, never renumber; next
free number **#49**).

### Batch 6 — W4 STARS **BUILT**; W5's PROPOSAL appended (the gate); commit `c70c762`

**Counts, by my own runs at build-complete:** core `✔ Test run with 925
tests in 105 suites passed after 28.982 seconds` (`swift_exit=0`) · Mac
`✔ Test run with 1052 tests in 184 suites passed after 137.940 seconds`
(`mac_exit=0`) · mobile `✔ Test run with 14 tests in 4 suites passed after
0.242 seconds` (`mobile_exit=0`) · the tutorial spine on its OWN run, by
TYPE name (`TutorialBookShapeTests` · `TutorialDoorTests` ·
`TutorialWritingActsTests` · `TutorialTakesActsTests` ·
`TutorialStructureActsTests` · `TutorialLookingActsTests` ·
`TutorialLibraryActsTests`): `✔ Test run with 49 tests in 7 suites passed
after 12.015 seconds`. From the batch's baselines (916/104 · 1041/181 ·
14/4): **+9 core tests, +1 suite · +11 Mac tests, +3 suites**; mobile
byte-unchanged. **Mobile WAS run** — `Sources/` carries four files this
batch, so the loop's own condition is met.

**No schema. Zero `Sync/` lines. No Release build, no `/Applications`
refresh.** Her app was not running at any point (`pgrep` by path at open
and at close). ONE commit, staged by explicit path; nothing under `notes/`
outside this record was touched.

#### W4 — stars, on the `shelf_pins` precedent

Her round-3 ruling, and the shape it picked is the whole reason it is
small: **ZERO schema, no §12 lockstep event.** One `setting` row named
`'starred'` holds a canonical JSON array of keys in star order — plain
metadata CAS, so a two-device star race converges to either list and never
to corruption, exactly as pins have since R38.

**The core owns every decision, and three rules sit visibly in
`setStarred`'s body:**

1. **Star time is the order** — a new star is APPENDED.
2. **THE CAP REFUSES** (`starLimitReached(limit:)`) rather than silently
   evicting her oldest star, and the refusal NAMES un-starring as the road
   (P-2 — the door fires and says what to do instead).
3. **EVERY WRITE SELF-HEALS**: it persists exactly what `Queries.starred`
   returns — live targets only.

**Rule 3 is the load-bearing one, and it is what makes rule 2 honest.** The
READ RULE is that a star whose note or book is dead renders NOTHING (the
`dailyJournalBookID` fallback class). Without the self-heal a ghost star
would go on spending one of her five slots — and the refusal's only road
(un-star) has NO DOOR for a row that renders nothing, so she would be
stuck at four stars with no way to see why. **Revert W4-B reproduces
exactly that**: `theCapCountsOnlyWhatSheCanSee` fails with
`starLimitReached`, live.

**The app adds no second rule.** `StarTargeting` is the pure target rule (a
note or a book; the shelf, the library, the pool, a scraps container and a
tag folder are PLACES); ONE `StarDoor` value reaches all four row surfaces
so the menu's word is derived once; names come from
`WorkspaceNaming.label`, so a starred untitled note reads "Untitled"
exactly as it does in the Open strip and the back chip rather than growing
a second fallback.

**The doors (P-1):** `CapabilityID.toggleStar`, app scope,
`[.contextMenu, .palette]` — the note-row family (`SidebarView
.contextMenuCapabilities`: the Open strip, the Library catalog, the Pool)
plus the shelf's BOOK rows from their own new
`ShelfView.contextMenuCapabilities`, plus ⌘K by name. **No key
equivalent** and therefore no collision sweep owed: her ruling named a menu
and the palette, and inventing a chord would owe a sweep no ruling asked
for (batch 4's precedent). The ⌘K gate (`canStarCurrent`) governs the
PALETTE door only — a row carries its own target, which is the standing
`.diffAgainstChosen` / `.showOriginBlock` split, stated in the
declaration so nobody later reads the ungated rows as an oversight.

**The Starred section** sits at the sidebar's TOP (her placement), renders
only when something is starred, and its rows are ordinary tagged `List`
rows — so a click navigates through the shell's own selection, the `›`
marker lands on the current one for free, and a book row goes to the book
while a note row goes to the note, with no new routing at all. Each row
carries the un-star door twice (a trailing ★ button and the context menu),
the Open strip's ✕ shape.

#### Judgment calls, recorded so they can be overturned rather than trusted

1. **The stored key uses the MODEL's word** (`post:` / `reading:`), never
   the UI's. K5's sweep is UI-STRINGS-ONLY and can never reach a stored
   value, so this keeps the ratified vocabulary unmuddied on both sides;
   the grammar is also the app's own (`WorkspaceModel`'s title keys, the
   `book-chapter:` / `lens-move:` payloads). Pinned, so a later rename
   cannot quietly reach it.
2. **ONE list across both kinds, capped at 5 TOTAL** — her ruling says "5
   notes or books", and one list is what makes "star time is the order"
   expressible at all. Two lists would need two caps and an interleaving
   rule she never asked for.
3. **Success is QUIET; only refusals speak.** Every other toggle in this
   registry is quiet (seams, the context bar, shelf pins), and the Starred
   section gaining or losing the row IS the feedback. The one place this is
   arguable is ⌘K, where the palette has just closed and her eye is in the
   editor — flagged rather than decided.
4. **The ⌘K door reads the store rather than the observed model.**
   `ShellActions` holds `session` + `shell` by design and threading a view
   model into it would widen the shell's testable executor for one row. The
   DECISION is still the operation's in both paths (`setStarred`); only the
   source of "is it starred right now" differs, and a racing star from
   another device makes it a redundant no-op at worst.
5. **A star is not archived-aware.** An ARCHIVED note keeps its star and
   its row (archive is kept-but-out-of-ambient-view, and a star is exactly
   an explicit non-ambient pointer). Only a tombstone removes it. Stated
   because the Phase 4 ambient ratification could be read either way.
6. **The sync-straggler corner, named not hidden:** the self-heal drops any
   entry whose target is not live *locally*, which includes a row that has
   not ARRIVED yet — so a star made on another device, whose note is still
   in flight, would be dropped if she stars something else in that window.
   One rule beats two here (stars are presentation, never truth — the
   `shelfPins` fail-open class), the loss is one presentation row, and the
   road back is one click. Distinguishing "tombstoned" from "not yet
   arrived" is one extra query if the architect prefers it.

#### Pins — every change named

**New core suite `StarsTests` (9):** star time + idempotence + the outbox
ride · the cap's refusal and the un-star road out · **the read rule AND
the self-heal** (the stored list still carries the dead entries until the
next write, which is what makes the healing observable) · the cap counting
only what she can see · un-star + a no-op writing NOTHING · malformed JSON
and unreadable entries reading as none, with the readable ones around them
surviving · starring something dead, absent, or a scraps container ·
an untitled note carrying no name so the app's one brain names it · the
stored key's model word round-tripping.

**New Mac suites (3, 11 tests):** `StarTargetingTests` (4) the target rule
over every destination kind, the row's navigation round trip, the row word,
and the cap refusal reaching her in words · `StarDeclarationTests` (3) the
declaration, its honest grey, and all four renderers · `StarActingTests`
(4) both doors acting end to end against a real store, the sixth star
SPEAKING with nothing evicted, and a deleted note leaving the section by
itself.

**Pins MODIFIED — two, both in the registry walk, each the new
declaration's own requirement:** `sampledContexts` **+1 context** (the star
gate gets its OWN context rather than a field on one of the three
workspace lines, because it is not a stack gate — it asks what the pane is
SHOWING; without it `.toggleStar` would read `.unavailable` everywhere the
walk looks, the same hole the find family and the navigation core each
opened) and `theContextMenusRenderExactlyTheDeclaredContextDoors` **+
`ShelfView.contextMenuCapabilities`**. (Mechanical, not a claim change:
`PostDetailAndPanelTests`' `SidebarView` construction gains the new
`stars:` argument.) **Everything else passes UNMODIFIED**, including every
other registry-walk assertion — the parity proof that `.toggleStar` is an
addition, not an adjustment.

**The registry walk earned its existence again:** it caught the missing
sampled context before any behavioural suite did, exactly as it caught
batch 4's two declared-but-not-rendered doors.

**Reverts (`shasum -a 256` before each; both files restored and verified
OK before the next; `build-for-testing` → `test-without-building` every
time, per the standing stale-product trap):**

- **W4-A** the cap guard deleted ⇒ **2 issues on exactly the cap pin** (no
  error thrown; the sixth star lands), every other pin green.
- **W4-B** the self-heal deleted (the write persists the STORED list) ⇒
  **2 issues**: the heal pin, and `theCapCountsOnlyWhatSheCanSee` failing
  with `starLimitReached` — **the ghost-star bug this rule exists to
  prevent, reproduced.**
- **W4-C** the read rule's liveness filter deleted ⇒ **3 core issues** AND,
  after a rebuild, the Mac section pin red (`isStarred` still true for a
  deleted note) — the rule discriminated at both layers.
- **W4-D** stars prepended instead of appended ⇒ **6 issues across 4
  pins**: star time is not a comment.

#### VISUAL-VERIFICATION-ONLY — for her walk and the Design & UI review row

Everything that DECIDES anything above is pinned. These are look-and-feel
halves and **no claim is made that they were tested:**

1. That the Starred section reads right at the sidebar's TOP, above
   Shelf · Library · Pool · Blocks, and that appearing only when something
   is starred feels like discovery rather than a jump.
2. That the trailing ★ button reads as "un-star" and does not fight the
   row's own click-to-navigate (the Open strip's ✕ pairing, one row down).
3. That the cap's refusal is legible when it fires, and that five feels
   like the right number under her hand.
4. That "Star"/"Unstar" reads better on the rows than the registry's own
   "Toggle Star" does in ⌘K (judgment call 3's other half).
5. That a starred BOOK row and a starred NOTE row are distinguishable at a
   glance in the one list (today only the name distinguishes them).

---

#### THE PROPOSAL (W5's gate) — the QUICK NOTE, traced and MEASURED before building

Her round-3 ruling: *a FLOATING MINI-WINDOW; global shortcut / menu-bar
door; typing mints an ordinary bookless note (the Pool lists it); the
sticky face shows NO takes machinery; the note persists when the window
closes.*

**Four measurements led this, and two of them changed what I would build.**
They lead because one of them contradicts an assumption in the brief.

| # | Measured | How |
|---|---|---|
| 1 | **SwiftUI's own floating window level exists at our target** — `Window(id:) { }.windowLevel(.floating).windowResizability(.contentSize).defaultWindowPlacement { }` type-checks clean at `arm64-apple-macos26.0`, zero warnings | `swiftc -typecheck` probe against BOTH the CLT SDK and Xcode's MacOSX26.2 SDK |
| 2 | **`MenuBarExtra` is available** at the same target, same probe, zero warnings | as above |
| 3 | **Carbon `RegisterEventHotKey` is present and NOT deprecated** in the macOS 26.2 SDK — annotated `AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER`, no `DEPRECATED` macro; its own header Discussion says "Registers a **global hot key**" | read from `…/MacOSX26.2.sdk/…/HIToolbox.framework/…/CarbonEvents.h:15484`; the probe links its whole call shape with zero warnings |
| 4 | **⌘⇧N is FREE** | the standing sweep: `EditorCommands.keyEquivalent` (36 chords), every `.keyboardShortcut(` call site in `Variorum/` + `Shared/`, every `NSMenuItem` key equivalent (all empty strings), the one `performKeyEquivalent` override (⌘S). No `n` chord carries shift; the nearest neighbour is ⌘N New Post, which is exactly the right neighbour |

##### (a) THE WINDOW — and the one place I would deviate from the brief

**The floating half is settled by measurement 1: a third SCENE, no NSPanel
bridge.** `Window("Quick Note", id: …)` — singleton, like the helper
window, because there is one sticky pad — with `.windowLevel(.floating)`
and `.windowResizability(.contentSize)`. The `NSPanel`/`NSHostingView`
bridge that this used to require pre-macOS-15 buys nothing at our
deployment target and would be a second window mechanism beside the two
`WindowGroup`s batch 5b just landed.

**What I would deviate on is the FACE, and it is the gate's real
question.** The brief says *"the mini editor takes the live ring while
key, P-3 on the standing authority"*. I propose the opposite, and it is
simpler rather than weaker:

- **RECOMMENDED — shape 1, CAPTURE-THEN-MINT.** The sticky holds a plain
  SwiftUI text field (the `QuickEntryBar` face), **no TK2 surface, no
  block identity, no live ring at all**, and the text becomes a note
  through the standing mint below. **P-3 then holds trivially rather than
  carefully**: the quick note never mounts a text surface, so there is
  nothing for it to be live *with* — no authority, no handler, no
  `EditorRouter.active`. It also answers "the sticky face shows NO takes
  machinery" by construction instead of by stripping a face down.
  *The cost, stated:* it is a CAPTURE surface, not an editor — no blocks
  or takes while typing, and re-summoning gives a fresh sticky rather than
  the last note. That is what a sticky note IS, and the minted note opens
  in the full editor the moment she wants more.
- **The alternative — shape 2, a real mini editor** mounting the standing
  pane surface on a minted post and taking the ring while key. Costs: the
  post must be MINTED BEFORE the surface exists, so every summon she
  abandons leaves a blank note in the Pool (R29's surface fills with
  ghosts — the exact opposite of what the Pool is for); and "no takes
  machinery" becomes a stripped-down face to build and keep stripped. I do
  not recommend it, but the brief's sentence points at it, so it is the
  architect's to re-read.

**Key-ness under 5b's mount rule — I recommend it REGISTERS**, as
`WindowRegistry.Kind.quickNote` (a third case; `Kind` is read only by
`navigationTargetID`'s three `== .full` comparisons, so a new case is
additive and broadcasts skip it by construction — verified by grep).
Registering means that while the sticky is key the app has **zero** live
surfaces, and every app-scope act goes honestly grey **through the gates
that already exist** — `handlerCount` 0 greys ⌘S and the editing family,
`openNoteCount` 0 greys ⌘⇧1–9, and so on: the note-only window's story
exactly, not one new availability rule.
*The cost, stated plainly:* each summon unmounts and re-mounts her main
window's detail (its `.task`s re-run; her pending text flushes through the
per-post coordinator — the safe direction, and the same backstop batch 4's
condition-(c)(2) pin covers). **The alternative — not registering — is
worse and I want the reason on the record:** her main editor would stay
live in a non-key window, so ⌘S pressed while she is looking at the sticky
would commit a take in a note she is not looking at. That is precisely the
"menu gates answering for the wrong window" defect batch 5b found and
fixed; I will not re-open it for a summon cost.

##### (b) THE DOORS — one is free, the other is permission-shaped, and I am STOPPING on it

**RECOMMENDED for v1: a MENU-BAR EXTRA + the app-global chord ⌘⇧N.** Her
ruling names both a global shortcut and a menu-bar door, and the menu-bar
door is a genuine reach-it-from-anywhere door: `MenuBarExtra` sits in the
menu bar whatever app is frontmost, needs **no entitlement and no TCC
permission**, and adds no dependency. ⌘⇧N (measurement 4) reaches it
instantly whenever Variorum is frontmost, and reads right beside ⌘N — ⌘N
makes a note, ⌘⇧N pops the sticky. Both are registry-declared; the chord
joins the key table under the standing pin.
*The one taste consequence for her:* a permanent Variorum glyph appears in
her menu bar. It is a visible product change, so it goes to her, not to me.

**A TRUE SYSTEM-WIDE HOTKEY — one that fires while another app is
frontmost — is a SEPARATE, LATER step, and here is exactly why.** There
are three mechanisms and only one is viable:

| Mechanism | Verdict |
|---|---|
| `NSEvent.addGlobalMonitorForEvents` for `.keyDown` | **Requires Accessibility (TCC)** — Apple's own guide: *"it may only monitor key events if accessibility is enabled or if the application is trusted for accessibility."* Permission-shaped |
| `CGEventTap` | Requires the **Input Monitoring** TCC permission. Permission-shaped |
| Carbon `RegisterEventHotKey` | Present and NOT deprecated in our SDK (measurement 3); reported to need **no** TCC permission and to be sandbox- and App-Store-compatible. **But that no-permission claim is UNCONFIRMED against any primary Apple source** — the lookup could not find it stated in Apple documentation, and there is a reported macOS 15 sandbox regression (FB15168205) for Option-only/Option+Shift chords |

**So: STOPPING on this half, per the brief's own instruction.** Whether a
Carbon hotkey registration produces a permission prompt on HER machine can
only be settled by running it there, and a TCC prompt is an author-machine
act — never something I work around or assume away. I also cannot reach
for `KeyboardShortcuts`/`MASShortcut`: **a new third-party dependency is
an author-only call** (CLAUDE.md), and neither is needed anyway, since
their underlying API is the Carbon one above.
**My recommendation: ship v1 on the menu-bar extra + ⌘⇧N** — which is her
ruling's own second-listed door, costs nothing and risks nothing — and put
the system-wide hotkey to her as a small, separable follow-on with the
measurement above in hand.

##### (c) THE MINT PATH — the standing quick-entry grammar, unchanged

The face mints through **exactly `QuickEntryBar.submit()`'s body**:
`session.runner.run { ops in try ops.importPost(title: nil, text:) }`.
Traced, and every property her ruling names falls out of it:

- **Untitled** — `title: nil`, so the app's one naming brain reads it
  "Untitled" everywhere.
- **Typed text segments as CONTENT** — `importPost` runs
  `SegmentationRules.bulkSegments` under the document-global setting, so
  the 2026-07-12 spacing ruling and the `one_block` face ride free and
  the sticky needs no segmentation rule of its own.
- **Bookless, so the POOL lists it** — it takes no `addPostToReading`, and
  `Queries.poolPosts` is exactly the bookless live posts (R29; pinned by
  `poolPostsAreExactlyTheBooklessLivePosts`).
- **An empty sticky mints NOTHING** — `importPost` throws `emptyImport`
  on whitespace-only text, so an abandoned summon cannot litter the Pool.
- **"The note persists when the window closes"** — ⏎ mints (the R3
  grammar), AND a non-empty sticky mints on close, so nothing typed is
  lost. **Two small questions I would rather have ruled than guess:**
  does ⏎ CLOSE the sticky or clear it and stay (a pad you keep writing
  on)? And should the minted note OPEN in the main window, as
  `QuickEntryBar` does, or stay quietly in the Pool — a sticky that yanks
  her out of what she was doing is the opposite of a quick note, so my
  leaning is: stay quiet, and speak one line naming the Pool.
- **One recorded wrinkle, not a blocker:** `importPost` registers its undo
  entry with the label **"Import"**, so the menu would read "Undo Import"
  after a sticky. Widening that label to a parameter is a one-line core
  change if the architect wants the menu to say what she did.

##### What I would build on a ruling, in order

1. The scene: `Window(id:)` + `.windowLevel(.floating)` +
   `.windowResizability(.contentSize)`, registering as
   `WindowRegistry.Kind.quickNote`.
2. The face: the `QuickEntryBar` grammar, mint on ⏎ and on close.
3. The doors: `CapabilityID.quickNote` — `MenuBarExtra` + ⌘⇧N (the chord
   into the key table under the standing collision pin) + a File-menu
   item, all from ONE declaration.
4. Pins: the mint's properties (bookless ⇒ Pool; empty mints nothing;
   segmentation rides the standing rule) end to end against a real store;
   the registry declaration and its doors; the key-table collision pin
   re-run with ⌘⇧N in it; and the app-scale mount invariant extended to a
   registered `.quickNote` window (the R5b-A shape).

**STOPPING HERE per the gate.** W4 is built, committed and green; W5
proceeds on the architect's ruling of (a)–(c) — and the system-wide-hotkey
half stays stopped on her machine act regardless of how (a) and (c) are
ruled.

#### For the orchestrator

- **PENDING, deliberately: nothing.** No PROVISIONAL was created, so
  `notes/QUESTIONS.md` is untouched (next free number stays **#49**).
- **W4 is BUILT and adjudicable**; **W5 is STOPPED at its gate**, with one
  half (the true system-wide hotkey) stopped on an AUTHOR-MACHINE act
  rather than on a ruling — that half stays stopped whatever is ruled
  about the window and the face.
- **The one deviation I am asking to be ruled on, stated plainly:** the
  brief presumes the sticky is a mini EDITOR taking the live ring; I
  propose it is a CAPTURE surface with no text surface at all, and the
  reasoning is in (a) so it can be overturned rather than merely trusted.
- **W19 rider: NOT FIRED.** This batch touched no part of the shell-redo
  status-delivery path (`ShellActions.structuralRedo`, `ShellRouter`,
  `StatusCenter`, `OperationsRunner` — verified in the diff; the one
  `ShellActions` addition is the star's palette body).
  `theShellRedoActionRunsThroughTheRunnerAndReports` passed in the full Mac
  run. Left where it is; its KnownIssues row stands.
- Her walk will notice, beyond the Starred section itself: every note row
  in the app (the Open strip, the Library catalog, the Pool) and every
  book row on the shelf carries a new star door, and ⌘K types "Toggle
  Star".
