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
