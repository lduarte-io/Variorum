# The Act 10 Correction Round — every UI change of the pre-13u round weighed, corrected, and walked

**STATUS: OPEN — opened 2026-09-01 at the author's sitting (her `/architect-phase` invocation).
Orchestrator: Fable (the sitting's session). Cast: all Fable — fresh implementer per batch, fresh
cold reviewer per ladder round. Runs NOW, before `pre-13x` (her ruling R-cor-2). Her acceptance is
ONE walk at the end on the refreshed `/Applications` build (R-cor-4). Source document:
`notes/author-reports/2026-09-01-post-act10-ui-report.md` — her words verbatim + the fifteen-image
manifest. This file is the ONE running record; a fresh session reads it in full.**

---

## 0. Why this round exists (the honest paragraph, written by the orchestrator)

The pre-13u round's Act 10 shipped 34 commits / 111 files / +10,235 −1,720 of UI in four waves.
Wave 2c alone built FIVE phase-sized surfaces — Index (635 lines), Read (385), the Blocks workbench
(811), the book Index (574), plus rewrites of BookView, BlockTOCView, Compare and Lenses — across
three chained implementer sessions, one of which died mid-run. The plan carried the escape hatch
("item 18 defers WHOLE to 13u2 if 2c cannot hold it") and the verdict came back "nothing defers":
an architect's call, and the wrong one. Verification was structural, not experiential — item 18 by
"mount smokes", the record's own admission that *"No Compare/Lenses capture exists in the 2c walk
set"*, and a three-round ladder whose every BLOCKER/MAJOR lived in `Sync/`. Two rulings shipped
half-delivered without the residue being flagged: W8-3 (the sidebar column's interior flattened,
`SidebarView.swift:348`; the floating glass pane itself left) and Index (built with the LEFT
column's small card as the live editor and the big right pane read-only by construction,
`IndexModeView.swift:380–387`). The install was refreshed before anyone used the result. She used
it, and reported the app had gone "from feeling pretty crisp, working well, no obvious bugs" to
"feeling like a vibecoded mess." The ideas were hers and she still wants them; the execution and
the verification were the failure. This round corrects the surfaces one at a time, walks every one
of them in use before its record closes, and binds the process rules (§2b) that would have caught
it.

## 1. Her rulings at the opening sitting (2026-09-01 — verbatim-faithful; settled)

- **R-cor-1 — SHAPE: correct in place, surface by surface.** Offered: correct-in-place with scalpel
  reverts · revert only wave 2c · wholesale revert to a branch. She chose the first. Her rider
  (R-cor-4 below): *"i'd honestly RATHER not retire any of the new changes"* — so a per-surface
  revert is the LAST disposition, taken only when a surface cannot be made right inside the round,
  and never silently.
- **R-cor-2 — SEQUENCE: this round NOW; `pre-13x` after.** *(The master plan's pointer amended
  the same turn.)*
- **R-cor-3 — THE LIBRARY PANEL (her words, verbatim):** *"I do think that showing a preview of the
  note on the right is helpful, even though the 'couple words showing of the post' is also coming -
  it makes the library feel like a more useful view, and the library really is quite wide right
  now. I will say that the line between the 'note info' and the library disappears when you're
  tabbed out, and it needs significant work. I think that the 'this note' sidebar should just fade
  in and out more smoothly, it would be too crowded to also have something on the left side. I
  think that the library peek should be quite simple, with an easy way to go into the note and have
  the place where your cursor was saved at any point (no need to render a whole write surface with
  takes, blocks, everything). Or we can make it so that the library just has a view and you have to
  click into it to edit it - that's the safer choice, and the read view + metadata still has value.
  QUALITY is what this phsae most needs to emphasize. also, when I click on a book, i just still see
  the last note i clicked on - obviously bad. a book could show the outline that it has or something
  rather than just showing the text. I'm open to good ideas in this area for usefulness, and what
  i'm saying are more inclinations, but the point is a premium feeling app"* → **Architect's
  reading, PROVISIONAL for her morning walk:** the panel becomes a SIMPLE READ PREVIEW (her "safer
  choice") — the note's rendered text, read-cheap and virtualized, a calm small facts line, and ONE
  generous door into the note that lands where the caret was; a BOOK shows its outline (chapters +
  notes) in the same panel; the panel's boundary holds when the window is inactive; the sidebar's
  "this note" rail FADES in/out instead of snapping; nothing new on the left. The writable upgrade
  (read-cheap → live on click, the one-live-editor rule) is a later door if she wants it, not this
  round's.
- **R-cor-4 — HER WALK, THE INSTALL, AND FOUR RIDERS (verbatim):** *"I'll just look at the app after
  all of the fixes are in place. I'm fine with this not being a quick round - this is honestly the
  kind of work that matters the MOST in a certain way. a user won't care about writing git history
  if the app looks and feels like a mess. I'm fine taking the time to do it right, and i'd honestly
  RATHER not retire any of the new changes, but I had to be honest about how upsetting seeing the
  app suddenly feel like slop was. I also would like applications refreshed at the end - I'll
  likely be asleep when you're finishing this work, and I'd rather wake up to it just being *done*.
  I'm also concerned because the linage page hasn't been looking great either - I reported a bug
  with it to the previous waves that resulted in this mess. So special attention shoudl also be
  paid to the lineage / history / archive / trash. And teh chrome being calm is valuable - word
  count shouldn't just be thrown in everywhere just because. i'm also not sure what the 'reading
  time' was calculated on, i think it's fine to show in read for now but i was kind of side eyeing
  its inclusion - how random is it?"* → (a) ONE acceptance walk, hers, at the end; the orchestrator
  walks every batch hands-on in between. (b) `/Applications` refreshed at the end — at a
  zero-instance window (her app was running at the sitting, pid 41735; she was asked to quit it
  before bed; otherwise the Release build is STAGED and swapped at the first zero-instance window,
  the A1 backup first). (c) **Batch F** — the recovery family (This Note's Tray, Block History,
  Archived, the Trash — her "lineage / history / archive / trash") gets its own batch with special
  attention; her earlier report on it was Act 10's item 1 (the tray's clipped header), whose fix
  began the restyle. (d) **The calm-chrome rule**: every word count / metric in chrome is verdicted
  KEEP (it earns its place) or DROP — ledger row 31. (e) Reading time: `words ÷ 200` rounded up
  (`ReadModeView.swift:302`) — a fixed convention (200 wpm adult silent reading), not measured, not
  random; stays in Read per her word; recorded (row 32), the constant named.

- **R-cor-5 — INDEX + READ BECOME ONE TAB, NAMED READ (her ruling at the sitting, verbatim):** *"I like one
  tab named read, but don't do the minimal outline of the current read tab - do the useful outline of the
  index tab. I actually really like how the index tab looks with its > 01, I think it looks nice. the text
  is a bit too small on the dropdown but it's better with the outline as what the current index has."* →
  The note mode row becomes **Write · Takes · Read · Lenses · Compare · Blocks · Canvas** (⌘1–⌘7, derived
  from the one order). READ = the calm page at rest; a click on a block makes THAT block live in place (the
  one-live-editor upgrade — P-3 through `PaneTextAuthority`, the block-TOC design's own promise); the
  outline toggle she loves shows/hides the INDEX column — the Index tab's numbered `▸ 01` navigator
  (headings → sections, blocks nested, filter, scroll-synced), NOT Read's minimal outline, with its
  dropdown/expanded type a step larger; a small in-place selector picks the page's shape — continuous or
  horizontal pages (the book's paged view reused). The Index tab retires INTO Read (its brains — 
  `NoteIndexOutline`, the column — survive as Read's column); AppSpec §12's mode-row line and the field
  guide's "getting around"/"index · read" lessons change at closeout (the re-seed obligation rides). Her
  second message's reasoning is the record: *"making it more similar to book, where it's a selector within
  a place you're in. and the outline button could hide / show the index, and the index could function as
  the outline."*
- **Her hands-off note (2026-09-01 ~04:45):** *"i was the reason that screenshot wasn't right  i'll stop
  clicking anything on my computer and switch to only messaging you via my phone, so you can use my
  computer better."* → the machine is author-free for the walk from here; her real-store app is closed
  (the zero-instance window for the end-of-run refresh is open).

- **R-cor-6 — LENSES + COMPARE NEED A DESIGN (her ruling from the phone, 2026-09-01 ~04:50, verbatim):**
  *"Lenses/Compare need a design - I'm just going to tell you now that they need a design. The changes
  made them a bit clearer (so they're improvements in one sense, even if they look bad), but it's still
  absolutely dizzying. I need you to consider clearly what the point of each tab is, and make the UX of it
  better. promote into note (takes ride) for example is kinda vague."* → Row 41's authorization becomes a
  ruling under the friction doctrine (P-5): **batch D keeps only the mechanical defects** (rows 16/17 —
  alignment; the anchor column always rendering the note); **the orchestrator writes the LENSES + COMPARE
  DESIGN MEMO in-round** (`notes/plans/act10-correction-memo-lenses-compare.md` — the point of each tab in
  one sentence each, the flows a writer actually runs, every door and its wording — "promote into note
  (takes ride)" first — the edges, the tradeoffs, her rulings to collect), and **the build to the memo is
  its own phase**, kicked off at her word after she rules on the memo (the S4-16 condition: deferral
  carries its design, never vagueness). Row 20 folds into the memo.

- **R-cor-7 — R-cor-5 SHARPENED (her phone message + her answer, 2026-09-01 ~05:05): INDEX IS THE EDITABLE
  SURFACE; READ IS NEVER EDITABLE; ONE RAIL TAB NAMED READ WITH AN IN-PLACE `edit · read` SWITCH.** Her words,
  verbatim: *"index being editable is true for index, but is not true once it moves into being the read mode.
  it's not editable on book either - so let's clarify now what an editable index suggests now that read mode
  is separate - book will also have the same thing for index. what do you think? I incline towards there is
  an editable index surface, then you click read and it isn't anymore."* Offered Index / Read / two tabs as
  the rail name; she chose: *"Read — the tab keeps R-cor-5's name; inside, 'edit · read' switches the
  pane."* → **The note rail: Write · Takes · Read · Lenses · Compare · Blocks · Canvas (⌘1–⌘7).** Inside
  READ, one in-place switch **`edit · read`**: **edit** = the editable index surface — the Index tab's
  `▸ 01` outline column (toggle to hide/show; its expanded/dropdown type a step larger) beside the text pane
  in which a clicked block goes LIVE (P-3, one live editor through `PaneTextAuthority`); **read** = the calm
  read-only page (continuous or horizontal pages — the book's paged view reused), the same outline column
  available, nothing editable, a click on a sentence flips to `edit` at that block (row 38's door). **Default
  on entry: `edit` — RULED** (her follow-up, verbatim: *"I want it called Read because it's more distinct.
  still default open to the index edit though."*; per-note memory of the switch is the natural refinement,
  the architect's call). **The BOOK:
  its Index word-tab becomes EDITABLE the same way** (the selected note's block goes live in the right pane —
  row 22); **the book's Read stays read-only.** R-cor-5's other terms stand (the Index tab retires into Read;
  the `NoteIndexOutline` brains survive as the column; canon + field-guide changes at closeout).

- **R-cor-8 — THE OVERNIGHT AUTHORIZATION (her last message before sleep, 2026-09-01 ~06:45, verbatim):**
  *"I'm going to sleep for now - continue your work and don't stop for questions, just choose, record for me
  what was chosen + continue. What phase is this saved as? finish with a variorum refresh + make a handoff
  walk. I probably won't wake this session if you're done before i'm up - maybe. Continue the excellent
  work."* → Every fork from here is CHOSEN by the orchestrator and RECORDED in §7 (the morning bundle) with
  its reason — no holds, no questions; the run ends with the `/Applications` refresh (C-3's walk first) and
  the author handoff whose top is the WALK (her checklist in walk order). Her question answered: this is
  saved as **the Act 10 correction round** — master plan row `act10-cor`, plan `notes/plans/act10-correction-
  round.md`, handoff `notes/handoffs/act10-correction-handoff.md`. **Cutover rule for the orchestrator:** at
  ~57 % of context with five batches ahead, the orchestrator writes its ROLE handoff
  (`notes/plans/act10-correction-orchestrator-handoff.md`, a paste-ready successor prompt inside) NOW and
  keeps it current at every batch close, walks each later batch by SPOT-CHECK (the implementer's full walk
  + the orchestrator's 3–4 captures at the riskiest rows) to stay inside the budget, and if it must stop,
  the successor adopts from the repo — she starts it in the morning if the run is not done.

**Inherited rulings this round builds to (not re-litigated):** the eighth-wave rulings W8-1…W8-5
(`pre-13u-round.md`), the fifth-wave item-15 flow ruling, the mode-row canon R60–94 as extended by
W8-1 (the eight-mode row is AppSpec §12 canon), her copy doctrine (structure and generous targets
first; a sentence only where truly necessary; she rewrites copy later — keep every capability
present), and the 13j recovery doctrine (the Trash is the recovery door).

## 2. Binding principles

### 2a. The 13b constitution (P-1…P-9 — copied byte-verbatim from the skill, as every architect-phase run does)

- **P-1 — One capability registry.** Every user-facing act is declared exactly once: verb, scope (block/take/post/book), per-mode availability rule, its doors (menu / context / bar / shortcut / palette), and its refusal copy. Surfaces render their doors FROM the registry; gating is data, never per-view if-statements. A registry-walk test asserts every declared door exists and every rendered door is declared. This kills the D3/D4 class structurally — the capability matrix stays green by construction instead of by audit.
- **P-2 — Fire-and-DO (R115).** A rendered door either performs the act — including any mode-switch choreography, done visibly for the user — or delivers the operations layer's real refusal. A door that can never act in its context isn't rendered. Lecture-and-redirect is retired.
- **P-3 — One text surface, one liveness authority.** ONE TK2 surface component (live + read modes; one measurement brain — the width-gated remeasure; the shared canary) that every pane composes; the live editor core's identity machinery (`BlockRangeIndex`, crystallization) becomes its live mode, not a sibling implementation. "What text does this pane show, and is it live" is answered by ONE pure, unit-tested authority (`PaneTextAuthority`); views never re-derive it. Its invariants stated as code: exactly one live pane; the live pane is buffer-authoritative; read panes are projection-authoritative once caught up.
- **P-4 — Broadcasts carry signals, never decisions.** NotificationCenter may announce that something happened (mode changed, post opened); no listener derives business state or availability from a broadcast, and no flow's correctness depends on broadcast ordering. Cross-feature flows route through composition. (Stage 0's survey enumerates today's notification bus; Stage 1 disciplines it.)
- **P-5 — The friction doctrine (R116).** Repeated pushback against a rule marks an under-architected feature. The response is never another patch: write the feature's DESIGN MEMO — intended behavior whole, edge cases enumerated on paper, refusal wordings, undo story — get the author's rulings on the product-flavored edges, then build to the memo. Happy path ships first, but the edges are *decided at design time*, not discovered by the author. First two memos owed: **merge** and **the W ceremony**.
- **P-6 — The tutorial is the executable spec (R113).** The guided tutorial flow is the contract for every happy path. It stays green — automated where the harness allows, screenshot-walked otherwise — and any change that breaks a tutorial step is a regression by definition.
- **P-7 — Find bugs before she does.** Every layer keeps a proactive harness: the ops-layer soaks (exist), the board/view-model invariant soak (Stage 1), the registry walk (P-1), the per-batch scripted screenshot walkthrough. Red-on-old stays absolute: no bug-class fix without a pin that fails on the pre-fix code.
- **P-8 — Standing law, consolidated.** P1–P3 performance invariants bind the rebuilt layer exactly as they bind the substrate (invalidation ∝ realized rows; one live editor; virtualized long views). Overlays, never rendering attributes. Chrome `fixedSize` texts always carry a `lineLimit` (the b6dae25 class). `Theme/VoiceControls.swift` is THE chrome vocabulary. Complexity lives in the store; restraint lives in the UI.
- **P-9 — No god objects in the frontend either.** A view model mixing board layout, text authority, and gesture routing splits by concern (`TakesViewModel` at 890 lines is the standing counterexample). Same hygiene rule as the substrate, applied where it was being waived.

### 2b. This round's own rules (C-1…C-7 — the fix for the CAUSE; binding on every batch)

- **C-1 — ONE SURFACE PER IMPLEMENTER SESSION.** A batch is one surface. A session that finds a second surface in its way hands off with a record; it never "also does" the next one. (Wave 2c's five-in-one is the counterexample this rule exists for.)
- **C-2 — THE ACCEPTANCE GATE IS USE, NOT MOUNT.** A batch record may not close on mount smokes or pins alone. The implementer walks ITS OWN ledger rows on the running dev-store Debug build — clicking the thing each row is about — with a screenshot per row in the round's screens dir; then the orchestrator walks the same rows hands-on before the record is marked closed. A row whose behavior cannot be exercised in the walk says so, with why.
- **C-3 — NO INSTALL REFRESH WITHOUT A WALK.** `/Applications` is refreshed once, at the end, after the orchestrator's full walk of every touched surface (and the ladder's fixes), at a zero-instance window, the A1 backup first.
- **C-4 — A RULING IS DELIVERED WHOLE, OR ITS RESIDUE IS THE RECORD'S FIRST LINE.** Half-delivering a ruling (W8-3's pane, Index's read-right) is never recorded as done.
- **C-5 — SCALPEL, NEVER AXE — AND LAST.** A per-surface revert to the pre-Act-10 form (file-level, from git; the Act 10 version preserved on a branch `act10-<surface>`) is a NAMED disposition, taken only when the surface cannot be made right inside its batch, recorded with the reason, and bundled for her. Her lean is against retiring anything.
- **C-6 — CALM CHROME.** No metric, count, or label appears in chrome without a stated reason a reader needs it there. Word counts especially (row 31). One door per act (the tag cluster's two doors for one act is the counterexample). Squarish-rounded controls, the mockup grammar (W8-2), solid geometric lines (W8-3) — the style guide stands.
- **C-7 — QUALITY IS THE BAR — "a premium feeling app".** Alignment is a defect. A click that does nothing is a defect. A panel that overflows its window is a defect. A view that lags a second on selection is a defect. Each gets a traced mechanism and, for bug-class fixes, a red-on-old pin; taste calls beyond the granted latitude are bundled for her, never improvised.

## 3. THE LEDGER — her items, every one a row (status: OPEN · TRACED · FIXED(pin) · RECORDED · DEFERRED(owner) · REVERTED(branch))

| # | Her words (short) | Surface | Traced mechanism / architect's read | Batch | Status |
|---|---|---|---|---|---|
| 1 | Library note peek "isn't terribly helpful… a preview of the note you can write in, if anything"; was meant to occupy the writing-modes' space | Library right panel (`LibraryInfoPanel`) | Built as a facts panel; R-cor-3 rules the shape: simple READ preview + one door landing at the saved caret; books show their outline | E | OPEN |
| 2 | "the left edge of the program still has the liquid glass floating edge" | Sidebar container | W8-3 half-delivered: interior flattened (`SidebarView.swift:348`), the floating pane kept | A | FIXED (A `b22b6ff`: `ShellSplit` replaces NavigationSplitView — the glass pane gone; walked: orchestrator-a/00) |
| 3 | "the tabs used to be right below the modes, and the tab spacing has gotten less generous… hard to read" | Sidebar mode rail + Open strip | The Open strip rebuilt at the sidebar's bottom (Act 10 item 9); the eight-mode rail compressed (`SidebarView.swift:464–487`). Generous at ordinary heights; compress only under a measured height threshold (the bottom-bar precedent) | A | FIXED (A: flat column, one 30-pt pitch, the Open strip under the rail; `SidebarLayout` compresses only under a measured height; walked: 00) |
| 4 | Read: "doesn't have a centered title above the read" | Masthead (all modes) | The title sits in an asymmetric masthead after item 5's tag cluster took the right — same defect as rows 16/19 | A | FIXED (A `74c72db`: the title centers on the masthead's full width in every mode — pinned across all eight; walked: 00, the crops) |
| 5 | Read: "I want the mode where you can scroll horizontally through the pages that the other one has" | Note Read (`read` half, R-cor-7) | `ReadModeView` has no paged mode; the book's paged view (13b Stage 4 — `scroll · pages`) is the reuse, seen working in the book's Read tab on the walk | C | TRACED |
| 6 | Read: "that contents looks kind of weird with how it's cut off" | Note Read's contents column | Mid-word width truncation of first lines | C | OPEN |
| 7 | Book: "clicking on a block automatically navigate[d] you there, and now you have to expand it before editing it" | Book Outline | Walk-confirmed (captures 49/25): a note-row click selects + toggles expansion but does not reveal (row 47's mechanism); expanding lands focus on the LAST block. Ruled shape: a note-row click REVEALS and lands in the note at its first block (or the clicked block via row 38's door); the ▸ disclosure is the separate expand affordance | B | FIXED (B, walked: 20-fg-far-noterow-reveal) |
| 8 | "the left outline looks a bit weird in sherlock holmes with the chapters + the blocks named the same" | Book navigator | Chapter and note share a title; collapse the note line when it equals its chapter (read-time) | B | FIXED (B, walked: 03-sherlock-outline) |
| 9 | "clicked on an item in the middle of the outline… scrolling went absolutely berserk… landed me at the end" | Book Outline | `BookView.swift:895/932` — `withAnimation { proxy.scrollTo("page-\(id)", anchor: .top) }` over a lazily-realized stack of 9k-word cards: the SwiftUI lazy-stack scrollTo class (estimates, travel, overshoot). NOT TK2. Pin on the Sherlock book | B | FIXED (walked: one expanded story 04/05/07/10/11; ≥2 expanded via row 53's fix, orchestrator-b53/A–C) |
| 10 | "the tags are also misaligned from the text" (image 4) | Library rows | Baseline/vertical-center mismatch | A | FIXED (A: geometry pin; the sheet's rows close-up in both voices) |
| 11 | "the word book is misaligned" (image 5) | Library rows | Same class as 10 | A | FIXED (as row 10) |
| 12 | "Scrolling via outline in the book view has completely broken" | Book Outline | Row 9's mechanism | B | FIXED (as row 9) |
| 13 | The gutter "177w… 236w · ⑂ takes on 1 block" is "crowded", low value; "the point was that the note info that used to be below it would be to the right of it" | Book Outline details gutter | Item 18 invented a facts string instead of moving the note details that rendered under the opening paragraphs; move THOSE aside, drop the string (C-6) | B | FIXED (B, walked: 03) |
| 14 | "clicking on the chapters isn't even TRYING to navigate the book at all" | Book Outline | Walk: a navigator CHAPTER click DOES navigate when every card is collapsed (captures 23/50); with a story expanded it livelocks (row 44). The main column's chapter HEADINGS (⠿ name) are not doors at all — her click may have been there. Fix: chapter headings become doors too; the navigator's chapter click survives expansion (row 44's fix) | B | FIXED (B, walked: 15-body-heading-click, 11-about-this-text) |
| 15 | "showing a tag icon and a + tag at the same time… that's just sloppy"; click → a "tag creator" field slides out, cursor active | Masthead tag cluster | `MastheadTagCluster.swift:54–76` renders cards + "+ tag" + the `#` fold (K12's sticky fold). ONE door with her slide-out field; the fold preference folds into it | A | FIXED (A: the ＃ is THE door — an inline field with the cursor, ⏎ applies; ＋ tag and the masthead fold retired, K12 superseded there; ⌘⇧I → `.tagNote`; walked: 07/09 — open + apply). Nit → row 59 |
| 16 | Compare "horribly misaligned" (buttons useful, clarity improved) | Compare | Two left edges/baselines in the flow | D | OPEN |
| 17 | Compare: "'This note' is showing nothing" | Compare anchor column | `CompareBoardView.swift:938` `anchor.title ?? "This note"` — a journal entry's title is nil so the literal shows; and "related blocks only" is emptying the ANCHOR, which it must never filter — peers only | D | TRACED |
| 18 | Blocks: "that line between them should be draggable left / right" | Blocks workbench | Fixed split today; draggable, remembered | C | OPEN |
| 19 | Lenses: "the title is once again weirdly aligned" | Masthead | Row 4's defect | A | FIXED (as row 4) |
| 20 | "the use of lenses is still a bit unclear" (→ R-cor-6: "absolutely dizzying") | Lenses | Folds into the Lenses + Compare design memo (R-cor-6) | D (memo) | RULED (R-cor-6) |
| 21 | Read: "the outline isn't working great… being able to tap to toggle the outline being on and off is great though. I love that" | Note Read's companion outline | Click/scroll fixed; the toggle stays byte-as-is | C | OPEN |
| 22 | Book Index "looks and feels good, but then you can't actually click into it to edit it" | Book Index | Read-only BY DESIGN (`BookIndexView.swift:23` — double-click hands off to Outline; walk-confirmed, and the handoff lands focus on the LAST block 3/3, not the clicked one). R-cor-7: editable in place — the clicked block goes live in the right pane (one live editor, P3); the book's Read stays read-only | B | FIXED (B, walked: 17-book-index-click-live; caret lands at the block's END — row 49's family, batch C) |
| 23 | "the error on clicking on note titles in the outline place in the app was intermittent" (the field guide too) | Book navigator | Trace on the field guide as well as Sherlock; likely row 9's class racing realization | B | FIXED (B, walked with 47) |
| 24 | "the appearance of the 'this note' modes is just as jarring as it has been" | Sidebar rail | R-cor-3: the rail FADES in/out smoothly; nothing added on the left | E | FIXED — the sidebar half (A: the rail fades, the Open group slides; the sheet's 03-terminal-rail-fade-mid); the panel half is E's |
| 25 | "the blocks page is also weird and laggy - it takes a second after selecting it for it to be selected" | Blocks workbench | Trace: the workbench observation (`observeBlockWorkbench`) + selection work on the main actor are the candidates; measure, then fix | C | OPEN |
| 26 | Blocks: "the text is also above the details" | Blocks context panel | Architect's read: the block's full text card sits above the facts; the facts should lead (the text is already in the row) — correctable at her word | C | OPEN |
| 27 | "opening block history doesn't open it correctly" | Block History from Blocks | From Blocks it opens as a THIRD right column beside the workbench's own panel → overflows the window (her "Clos…"/"Restore" cut). One right region at a time | C / F | TRACED |
| 28 | "not sure what the difference between savepoints and lineage is supposed to be, or if they're both in there" | Block History pane | Both are in it (savepoints = each take's saved moments; lineage = the block it came out of); the sections must READ as sections | F | OPEN |
| 29 | "the block history tab stays open as you move to other modes which looks bad and is confusing" | Block History host (`PostDetailView.swift:286`) | Walk-confirmed (captures 45/46): opened from Write for block 3, it persists into Takes showing block 3's history while block 1 is live — stale AND persistent. Scope it to the mode (and the block) that opened it | C | TRACED |
| 30 | "the index tab is ALSO uneditable in the notes view… it's literally a new writing mode" | Note Index | Built read-right / edit-in-a-small-left-card (`IndexModeView.swift:380–387`). Her ruling: the RIGHT pane is the writing surface (click → that block goes live there); the left column is a navigator | C | TRACED |
| 31 | "the index dropdown on the left is also awkwardly sized, the text is bigger than it" | Note Index left column | The expanded card is the misplaced live editor of row 30; retired with that fix | C | TRACED |
| 32 | "not sure if all of these changes were noted or if you're going to have to look through commit history" | — | Every wave has a record; the 34-commit trail is complete. RECORDED — the gap was use, not record | — | RECORDED |
| 33 | (R-cor-3) "when I click on a book, i just still see the last note i clicked on - obviously bad. a book could show the outline that it has" | Library right panel | Walk-confirmed exactly (capture 20: the book row highlights, the panel keeps the previous note). A book selection shows the book's outline in the panel | E | TRACED |
| 34 | (R-cor-3) "the line between the 'note info' and the library disappears when you're tabbed out, and it needs significant work" | Library right panel boundary | Inactive-window appearance loses the divider/wash; hold the boundary in both states | E | OPEN |
| 35 | (R-cor-4) "special attention… to the lineage / history / archive / trash" | This Note's Tray · Block History · Archived · Trash | Batch F walks each surface fresh, lists every defect found, fixes them with pins; the rebuilt tray (Act 10 item 1) is walked at every pane width | F | OPEN |
| 36 | (R-cor-4) "word count shouldn't just be thrown in everywhere just because" | All Act 10 chrome | Sweep table: every word-count/metric display in the eight rewritten views (Snippets 10 · Read 6 · Blocks 4 · Index 4 · BookView 4 · LibraryInfoPanel 4 · Compare 2 · BookIndex 1) verdicted KEEP-with-reason or DROP (C-6) | A (table) · each batch (its rows) | OPEN |
| 37 | (R-cor-4) "not sure what the 'reading time' was calculated on… how random is it?" | Note Read | `words ÷ 200` rounded up, a fixed 200-wpm convention — not random, not measured. Stays per her word | — | RECORDED |
| 38 | (2nd msg) 13u item 17 — "if you click somewhere in the read mode, that it doesn't open there in the outline or the writing mode… it might make sense to pull that issue up into this phase, since it seems like there's a lot of 'cross pane interaction'" | Read → Index/Write click-through; the book's Read → editable view | PULLED IN (her word): the ONE scrolled-open door — click a sentence anywhere read-cheap, land in the editing surface at that block with the caret there — built once here and reused by rows 22/30 and the book; 13u2's item 17 is re-homed to this round | B + C (one mechanism) | FIXED — book half (B, walked: 24-read-paragraph-click; the note half is batch C's; nit: the landed block sits flush at the pane top, ring clipped — a top inset) |
| 39 | (2nd msg) "I haven't even gotten into blocks and index and how clicking through them is impacting the regular write and takes mode" | Cross-mode position continuity (Write ↔ Takes ↔ Read ↔ Blocks) | Walk: position is PER-MODE MEMORY today, not one position — Index kept block 03 while Takes made block 1 live; Write→Takes carried the caret's block when the caret was in block 1 (capture 39/40); Blocks keeps its own selection. Ruled by W8-1's letter: ONE current block follows you across Write/Takes/Read(edit)/Blocks; batch C builds the one authority and pins it | C | TRACED |
| 40 | (2nd msg, image 16) the book Outline's expanded note shows the bottom bar's items stacked VERTICALLY in a floating side card ("block 1/1 · block ▾ · Takes · commit ⌘S · history / note ▾ · comments · Aa / 5w block · 5w in note · ?") — "looks kind of weird… maybe the note menu needs to be collapsible… what's in that menu and how it looks needs to be a bit clearer" | Book Outline's in-place editor chrome | Trace where the side card comes from (the `CommitBar` axis introduced at wave 2c); make it read as one clear, calm control — collapsible if the trace says a stack is the right shape at that width | B | FIXED (B, walked: 00-state, 04 — one compact grouped card) |
| 41 | (2nd msg; RULED R-cor-6 — they need a design) "if compare needs its own phase, give it its own phase!! that's fine" | Compare + Lenses | RULED R-cor-6: the design memo is written in-round, the build is its own phase. Earlier note: batch D fixes the defects (rows 16/17); if the triage walk finds Lenses/Compare need a DESIGN rather than fixes, the orchestrator writes the brief for a phase of their own instead of half-building it (the S4-16 condition) | D (memo) | RULED (R-cor-6) |
| 42 | (2nd msg — RULED R-cor-5: one tab, Read, with the Index's outline) "I also wonder if Index / Read could be condensed into a single tab - making it more similar to book, where it's a selector within a place you're in. and the outline button could hide / show the index, and the index could function as the outline." | The note mode row | A product call — asked at the sitting with the architect's recommendation (see the sitting record) | C | RULED (R-cor-5) |
| 43 | (2nd msg) "If I need to ship the app with just writing and takes, I'd be willing to do so, but ideally that won't be necessary" | — | Recorded as her floor, not the plan; the round's bar is every mode useful, bug-free and beautiful | — | RECORDED |
| 44 | **FOUND IN THE TRIAGE WALK — THE BOOK OUTLINE HANGS (BLOCKER): expand a long story, click a chapter in the navigator → 100% CPU, main thread livelocked, window unresponsive (190 s+ observed; killed).** Her "berserk… landed me at the end of the note" is this defect's onset. Reproduced first try on the dev store's Sherlock book (steps: open the book · Outline · click the "The Boscombe Valley Mystery" NOTE row in the navigator, which expands the 9,689-word story in place with focus on **block 215/215** · click any chapter row). Sample: `act10-correction-screens/triage/sample-hang-47298.txt` — every hot frame is SwiftUI (`NSHostingView.beginTransaction → GraphHost.flushTransactions → LazySubviewPlacements.placeSubviews → LazyStack.place → ForEachList.applyNodes → … LayoutEngineBox/UnaryLayout`); our only frames are value copies of `ReadingSection`/`Queries.ReadingEntry`. | Book Outline | **Mechanism (traced at the code, to be confirmed by the implementer's pin):** `BookView.swift:1106–1116` — an EXPANDED note composes the FULL `EditorView` (a TK2 `NSTextView` whose height ESTIMATE moves as its viewport lays out — TEXTKIT2 §2) INSIDE a `LazyVStack` row (`:772`), and the navigator's `withAnimation { proxy.scrollTo(…) }` (`:895`, `:932`) animates toward an anchor whose offset depends on that moving height: place → the editor re-estimates → re-place → the target moves → repeat. Related symptom: expanding lands focus on the LAST block (215/215). Fix shape for batch B: an expanded editor's height must be settled before/while a programmatic scroll runs (measure once — `ensureLayout` over the one expanded note is bounded — and hold it; no animated `scrollTo` at an unsettled anchor), or the expanded body leaves the lazy container; plus the focus-lands-at-end fix. **Red-on-old pin: a mounted book with one 9k-word note expanded receives a navigator scroll request and the run loop returns within a budget (a watchdog), landing at the requested chapter.** | B (FIRST) | FIXED — the HANG (walked three ways, CPU 58/19/33 % → 0 within 2 s, window responsive; Boscombe opens at block 1/215); the multi-expanded LANDING residual is row 53 (open) |
| 45 | (walk) The book Outline's collapsed card previews only the FIRST block — "A Scandal in Bohemia" previews as "I." (its section numeral); the field guide's cards read fine because their first blocks are prose | Book Outline cards | Preview = the first ~40 words across the note's leading blocks, skipping a lone heading/numeral block (read-time derived, never stored) | B | FIXED (B, walked: 03) |
| 46 | (walk) Compare offers "make outline note" and "+ note" TWICE — as top-right buttons AND as the two centered offer cards | Compare | Two doors for one act (C-6's counterexample class); one placement per act — the memo (R-cor-6) decides which; the mechanical fix here is not to duplicate | D | TRACED |
| 47 | (walk) A navigator NOTE-ROW click in the book Outline selects (›) and toggles expansion but never REVEALS the note when it is off-screen — the field guide's "the take ceremony" got its marker and the page did not move; the Sherlock case only "worked" because a chapter click had already placed the note at the top | Book Outline navigator | `BookView.swift:899–911` — "Reveal is SCROLL-TO and never an auto-expand … the `page-<id>` anchor the expanded header does" — the reveal targets an anchor a collapsed card does not carry, so a collapsed note cannot be revealed; this is row 7's "you have to expand it" and row 23's "intermittent" in one mechanism | B | FIXED (B, walked: 20) |
| 53 | **ORCHESTRATOR'S WALK OF BATCH B (2026-09-01 ~06:35) — RESIDUAL of rows 44/9/12, MAJOR: with TWO OR MORE expanded stories in the book, opening a COLLAPSED story lands INSIDE THE WRONG STORY (no hang; CPU 0; window responsive).** Repro on the dev store's Sherlock, fresh build 57450: (1) open Boscombe via its row (lands block 1/215 ✓) · (2) open Noble Bachelor far below (lands ✓) · (3) open Five Pips (lands ✓) · (4) click "a scandal in bohemia" (collapsed, far ABOVE) → the page stays at speckled band / engineer's thumb / noble bachelor (capture `orchestrator-b/06-chapter-above.png`); a SECOND click on the now-expanded scandal lands within 1 s (`08-scandal-1s`) · (5) open the LAST story (collapsed, far below, three expanded between) → lands mid-way through NOBLE BACHELOR (`12-last-story-opened`) · (6) click "the red-headed league" (collapsed, above) → lands mid-way through SCANDAL, 4 s later still (`14-redheaded-first-click-4s`). One expanded story: every landing exact (04/05/07/10/11). | Book Outline landing | The batch's "bounded convergence" stops before the expanded-but-unrealized editors between the viewport and the target have reported their heights (each 8–9k words ⇒ thousands of points of estimate error per story); the first click also has to EXPAND the target (a height change of its own). Fix shape: converge on the TARGET's measured frame (iterate until the anchor's top is stable at the viewport's top across two consecutive layout passes, with a generous iteration cap and a watchdog — never a fixed count), and when the click expands the target, land AFTER the expansion has laid out. **Pin: a book with THREE expanded 9k-word notes; open a collapsed note far below and one far above → each lands at its own top (RED on the current tree).** | B (reopened) | FIXED (the fix session `7569af3`…`a2f31cb`: the segmented Outline column + StableSurface + the stability-driven corrector; pin `openingACollapsedStoryLandsAtItsTopWithThreeStoriesExpanded` RED on old; walked by the orchestrator on build 67746: `orchestrator-b53/` A/B/C all land at the top; CPU 0.4, one window) |
| 58 | **ORCHESTRATOR'S WALK OF BATCH A (2026-09-01 ~09:50) — RESIDUAL of rows 4/19/15/55, MAJOR (a visible collision on any note with several tags): the masthead's SECOND row — the centered `~/book` path chip and the trailing tag cluster share it, and they OVERLAP.** On "three ways of working" (5 tags) the path chip `~/the field guide` is drawn UNDER the first two tag cards (`orchestrator-a/00-write-state-masthead.png`); with the `#` field open the chip vanishes under the field + cards entirely (`01-tag-door-open-masthead.png`). | Masthead row 2 (`PostDetailView` masthead + `MastheadTagCluster`) | The title block's centering padding measures the FIRST trailing row (the icons), not the second (the cards + the field), so row 2's centered chip and row 2's trailing cluster are laid out unaware of each other. Fix shape (chosen under R-cor-8): row 2 becomes ONE layout — the path chip leads (left-aligned under the title's leading edge, or centered only when the free width allows it), the cluster trails, a minimum gap between them is honored, and when cards + field exceed the free width the CLUSTER wraps to its own third row (never over the chip); the title's centering padding takes the WIDER of the two trailing rows. Pin: a geometry pin — five tags + the field open → the path chip's frame intersects no card and not the field, in both voices; RED on the current tree. | A (reopened, fix session) | FIXED (the fix session `7dee4c7`…`8330790`: the path chip leads at the article's margin, the cluster wraps right-aligned as `TrailingFlow` reserving the field's width; pins RED on old (10 issues); walked by the orchestrator on build 81367 — `orchestrator-a/02-r58-closed-masthead`, `07-hash-open-masthead`, `09-tag-restored-masthead`: five tags closed/open/applied, no collision) |
| 59 | (orchestrator's walk of A) The masthead `#` door's HIT TARGET is the glyph itself (~10 pt) — a click a few points off lands on the neighbouring card's × (the orchestrator removed a tag by accident that way) or in the editor | Masthead tag door | Give the `#` a generous hit target (≥ 24 pt, the row's height) without moving the glyph; a pin on the button's frame. NIT, quality-class (C-7 "generous targets") | the ladder's fix round (or C if it touches the masthead first) | OPEN (NIT) |
| 55 | **FOUND IN BATCH A's OWN WALK (capture `11-terminal-tag-field-open`, the first cut):** with the inline tag field OPEN the masthead title collapsed to "thr…" — the field was laid out inside the trailing cluster, the cluster's measured width grew by the field, and the title layer's symmetric inset (rows 4/19's centering) squeezed the title to nothing | Masthead (A) | The field must not participate in the masthead's layout: it is an OVERLAY sliding out of the ＃ to the left of the cards (the cluster's width never changes; the title neither moves nor truncates while a tag goes on), and the title's inset gained a FLOOR (the title keeps ≥ 240 pt whatever the cluster holds — many tag cards included). The second cut caught the SAME class one step out (three chips squeezed the title to "worki…" at its floor) — the coupling itself was the defect, so the masthead became TWO ROWS, each a ZStack: the TITLE row centers on the full width inset by the ICON row's width (the only thing that shares its line); the PATH row centers inset by the tag cards' row's width; the path line yields (fades) while the field is out. Pins: `MastheadLayoutTests` + `MastheadTagDoorTests` green after; walked with FIVE chips + the open field in both voices — the title intact and centered (captures 11b / 24b) | A | FIXED (A, in-batch) |
| 54 | **FOUND BY THE ROW-53 TRACE (not the book's surface): every read-cheap TK2 surface measures itself TWICE on realization — a first measure at a provisional width (~half the final height: `10,366` then `20,056` for the same story), then the settled one** — a layout jump every `ReadPostView` makes when it appears; the Outline now hides it behind the remembered surface size, but the surface itself (and every other host of it) still jumps | The read tier (`ReadPostViewModel.remeasure` / `viewWidthChanged`) | Measure at the settled width only (or hold the last known height until the width settles) — the "non-editing pane jumping" family (13u2 item 1); outside the book's files (C-1) | C / 13u2 item 1 | RECORDED |

## 4. The batches (one surface each — C-1). **ORDER AMENDED after the triage walk: B FIRST** — row 44 is a BLOCKER (the book hangs) and the riskiest fix (TK2 geometry inside lazy layout), so it gets the longest soak before the ladder; A (the chrome) follows immediately; then C, F, D, E.

**Triage walk FIRST (the orchestrator, zero code):** the dev-store Debug build, every touched
surface, a screenshot per ledger row, the mechanism traced or the trace plan named — before any
implementer is spawned. The walk may ADD rows (anything found that she did not report) and must
not remove any.

- **A · The chrome** — rows 2, 3, 4, 10, 11, 15, 19, and the row-36 sweep table. The sidebar's glass
  retired for real; the mode rail generous (height-thresholded compression); the Open strip back
  under the modes; the masthead title centered in every mode (one layout, pinned across the eight
  modes + the book); ONE tag door with her slide-out field; library row alignment.
- **B · The Book** — rows 7, 8, 9, 12, 13, 14, 22, 23. Click navigates; the scroll class pinned on
  the Sherlock book (a middle chapter click lands on that chapter, no travel past it); chapter clicks
  wired; the duplicate line; the gutter carrying the old note details; the book Index editable in
  place (P3: one live editor, through `PaneTextAuthority`); the Read title.
- **C · The note modes** — rows 5, 6, 18, 21, 25, 26, 27, 29, 30, 31. Index editable (right pane
  live; the left column a navigator); Read paged + its companion outline; Blocks' draggable split,
  the selection lag traced and fixed, the context panel's order; Block History opening in the ONE
  right region and scoped to the mode that opened it.
- **F · The recovery family** — rows 27, 28, 35 (and whatever the walk finds): This Note's Tray,
  Block History (savepoints vs lineage readable as sections), Archived, the Trash. Special attention
  by her word — walked fresh at every pane width, every door exercised (Put back, Restore, Delete
  Now, the lineage doors), each defect pinned.
- **D · Compare + Lenses — MECHANICAL ONLY (R-cor-6)** — rows 16, 17. Alignment; the anchor column
  ALWAYS renders the note (derived display name for a nil title; "related blocks only" filters peers
  only). **The design is the memo** (`act10-correction-memo-lenses-compare.md`, written by the
  orchestrator in-round; rows 20/41); the build to it is its own phase at her word.
- **E · The Library panel + the sidebar rail** — rows 1, 24, 33, 34 under R-cor-3's PROVISIONAL
  reading: the simple read preview (virtualized, read-cheap), a calm facts line, one door landing at
  the saved caret, a book showing its outline, the boundary holding when inactive, the rail fading.

**Then:** one cold-review ladder over the combined diff (`notes/REVIEW_PROMPT.md` verbatim; fresh
reviewer per round; cap three) → the orchestrator's FULL acceptance walk of every touched surface
(C-2, at round scale) → the Release build + `/Applications` refresh at a zero-instance window behind
the A1 backup (C-3) → the field-guide re-seed if any lesson text changed → the morning bundle.

## 5. Process (binding)

- **The batch loop (the skill's, with C-2 hard):** build → pins (red-on-old by behavioral revert
  for bug-class rows) → `TutorialWalkTests` green → the implementer's walk of its rows with
  screenshots → point-by-point ledger update in THIS file → commit(s) + push → the orchestrator's
  walk → the record marked closed.
- **Briefs are this file's named sections only** — never a session's chat. Each brief carries §2, §5,
  §6, its batch's rows, and the source report's relevant image descriptions.
- **Away-run rule (she is asleep for most of this):** PROVISIONAL-and-continue on everything short
  of an author-only hard stop; taste calls beyond the granted latitude are HELD and bundled (§7),
  never improvised, never dropped.
- **Resiliency:** `notes/SessionResiliencyProtocol.md` binds — commit per piece, a LIVE STATUS line
  per batch record from its first commit, push after each, synchronous foreground waits only.

## 6. Environment traps (carried into every brief verbatim)

- **Instances:** `pgrep -fl 'Variorum.app/Contents/MacOS'` and discriminate by PATH. Her real-store
  app (`/Applications/Variorum.app`, pid 41735 at the sitting) is NEVER quit or killed; no Release
  build and no `/Applications` refresh while it lives. The dev-store Debug build (DerivedData) is a
  separate process on the fenced dev store and may run beside hers — prior walks did exactly this.
- **Builds/tests:** from `App/Variorum/`; `xcodebuild -scheme Variorum -configuration Debug
  -destination 'platform=macOS' build` for the walk build; `build-for-testing` compiles without the
  runner; suite-level `-only-testing` only; confirm the "Test run with N tests" line; zsh
  `pipestatus`; NEVER add a custom build configuration (SPM deps build RELEASE under any name but
  "Debug" and strip the DEBUG-gated oracles).
- **Walks:** the dev store is account-owned and seeds the field guide + the Sherlock library on first
  write; the machine must be unlocked and author-free for a screenshot walk; own `caffeinate -d`;
  screenshots land in the gitignored `notes/plans/act10-correction-screens/` (subdir per batch).
  The test host and the dev build both carry the "Variorum" identity — pick windows by PID.
- **Known reds that are not yours:** the latency pin (`rewriteStrategyLatencies`) reds under load;
  `CanvasDragTrackingTests` is load-flaky; both have KnownIssues rows — re-run isolated before
  concluding anything, never loosen them.
- **Git:** never `git checkout` over uncommitted work; push after each commit (the standing rule);
  no history rewrites.

## 7. The morning bundle (HELD for her — grows through the run)

- R-cor-3's PROVISIONAL reading of the Library panel (read preview, not writable) — ratify or redirect.
- iOS target build owed before the ladder (A touched `Shared/VoiceTokens.navigation`; C/E may touch `Shared/` too) — run once at the ladder, record the result.
- Row 57 (A): the sidebar's arrow-key row navigation went with the List → flat column; recorded for 13u2 unless you want it back sooner.
- *(Read's default half was PROVISIONAL for one turn — RULED `edit` by her follow-up; nothing to ratify.)*
- **The Lenses + Compare design memo — `notes/plans/act10-correction-memo-lenses-compare.md` §7, eight rulings** (R-cor-6's deliverable, WRITTEN; the build is its own phase at her slot).
- Row 26: the Blocks context panel's order (facts first) — the architect's reading.
- Any scalpel revert taken under C-5 (none expected; her lean recorded).
- The row-36 KEEP/DROP table for word counts. *(Batch B's verdicts for the book are in its record: the card `Nw` DROP · the gutter takes fact KEEP · the book meta line KEEP · the side rail's `Nw block`/`Nw selected` DROP, its `Nw in note` word-target door KEEP.)*
- Batch B, row 13: the Outline's prose stays left-anchored at Write's measure (batch 12's ruling) with a flexible, mostly-empty gutter — if she wants the column CENTRED like Write's page, that is a one-line ruling.
- Batch B, row 52: whether `_word_` (underscore emphasis — the Sherlock text uses it) joins the markdown vocabulary; today it renders raw everywhere.

## 7b. CLOSEOUT OBLIGATIONS (written 2026-09-01 ~06:00 so the run's end is a checklist; the standing CLAUDE.md ritual, unabridged, plus this round's own)

1. **Every ledger row dispositioned** — FIXED (pin) / RECORDED / DEFERRED (owner) / REVERTED (branch); no orphans; rows 44 (the hang) and 47 must be FIXED, never deferred.
2. **The review ladder** over the combined diff (`notes/REVIEW_PROMPT.md` VERBATIM, a fresh cold reviewer per round, findings recorded here before any fix session sees them, fixes in a fresh session with revert-verified pins, cap three rounds; every finding with a written disposition).
3. **The orchestrator's FULL acceptance walk** (C-2 at round scale): every touched surface on the dev build, both voices, the batches' capture lists re-shot on the final tree; the row-44 scenario re-run by hand on Sherlock; the tutorial spine green.
4. **Canon deltas, exactly as ruled, never beyond:** AppSpec §12's note mode row → **Write · Takes · Read · Lenses · Compare · Blocks · Canvas** (⌘1–⌘7) with Read's `edit · read` (R-cor-5/7) and the Index mode's retirement into it; the book's Index editable / Read read-only; the K12 masthead-fold supersession (row 15); AppSpec §14's dated delta paragraph for this round (the pre-13u delta rolls to the archive per the lean-docs rule); the Lenses + Compare memo anchored as the design record for its future phase; QUESTIONS.md gains the morning bundle (§7) as a numbered entry.
5. **Master plan:** the table row → done; the pointer → `pre-13x` NEXT at her word; the closeout paragraph (the pre-13u paragraph rolls to `PhaseCloseoutArchive.md`); the running order's note; `FuturePhases.md`/the table gain the **Lenses + Compare build phase** row (the memo's §8) — unslotted, at her word.
6. **KnownIssues:** nothing new expected; if a batch defers, the row carries its owner; the 13u2 item 17 line in the 13u plan is marked re-homed here.
7. **MOBILE PARITY LINE** (`notes/MobileSoul.md`): the phone owes — the seven-mode grammar with Read's `edit · read`, the one current block, the scrolled-open door, the book's editable Index, the tag door's shape; "nothing mobile-visible" is not available.
8. **The tutorial re-seed of HER REAL STORE** — batch C changes lesson text (the "index · read" lesson, "getting around"); the closeout re-seeds via the product door (Help ▸ Restore Tutorial…) on the refreshed install, behind the A1 backup, at the zero-instance window — or, if her store is not reachable without her unlock (a demanded mode), the handoff's checklist carries the one in-app act for her morning.
9. **The install refresh (C-3, R-cor-4(b)):** zero-instance check (`pgrep -fl 'Variorum.app/Contents/MacOS'`), the A1 WAL-safe backup with a UTC name FIRST, `xcodebuild -scheme Variorum -configuration Release build` from `App/Variorum/`, copy the product to `/Applications/Variorum.app`, `codesign -dv` + the build hash recorded here and in the handoff. If her app is somehow running, STAGE the build and swap at the first zero-instance window — never kill it.
10. **The author handoff** `notes/handoffs/act10-correction-handoff.md` — her checklist at the top (the morning walk in order: the chrome · the book incl. the hang scenario · Read's edit·read · Blocks · the recovery family · Compare/Lenses mechanical · the library panel), the PROVISIONALs (R-cor-3's reading; row 26's order; Read's switch memory), the memo's eight rulings, the counts, the commits, what was deferred and where; self-contained.
11. **Memory** (`variorum-phase-9-run-state`) → round CLOSED; NEXT `pre-13x`.
12. **Push** after every commit; the closeout commit last; then STOP — she kicks off what follows.


## 7c. CANON DELTAS — DRAFTED for the closeout (applied exactly as ruled, never beyond; the closeout pastes, it does not compose)

**AppSpec §12 (the note mode row — supersession sentence to append after the pre-13u supersession):** *Ratified
supersession (the Act 10 correction round, 2026-09-01 — her rulings R-cor-5/7, the binding record
`notes/plans/act10-correction-round.md`): the NOTE mode row is **Write · Takes · Read · Lenses · Compare ·
Blocks · Canvas** (⌘1–⌘7, derived from the one order). The Index mode RETIRES INTO Read: READ carries an
in-place `edit · read` switch, opening on `edit` — the editable index surface (the `▸ 01` outline column,
toggleable, beside a text pane in which a clicked block goes live; P3's one live editor through the one
authority) — and `read` is the calm page, never editable (continuous or horizontal pages), a click on a
sentence flipping to `edit` at that block through the ONE scrolled-open door (`LandingTarget`) the book's
Read → Index click-through shares. The BOOK's Index word-tab is EDITABLE in place; the book's Read stays
read-only. The 13k K12 masthead tag-fold is superseded: the masthead's `#` glyph is the ONE tag door (an
inline field with the cursor active), the fold retired there.*

**AppSpec §14 (the dated delta paragraph — replaces the pre-13u paragraph, which rolls verbatim to
`notes/AppSpecDeltaArchive.md`):** *Author-decision + shipped-semantics delta (2026-09-01, THE ACT 10
CORRECTION ROUND — the BINDING record is `notes/plans/act10-correction-round.md`: her rulings R-cor-1…8, the
54-row ledger, the batch records; the source is her verbatim report
`notes/author-reports/2026-09-01-post-act10-ui-report.md`):* **(1) HER RULINGS:** correct the pre-13u round's
UI IN PLACE, surface by surface, retiring nothing that could be made right (R-cor-1/4); this round before
`pre-13x` (R-cor-2); the Library's right panel a simple read preview with one door landing at the saved
block, books showing their outline, the "this note" rail fading (R-cor-3, her inclinations); Index + Read
ONE tab named Read with `edit · read`, `edit` the default and editable, `read` never (R-cor-5/7); Lenses +
Compare NEED A DESIGN — `notes/plans/act10-correction-memo-lenses-compare.md` is the design record, its
build a phase of its own (R-cor-6); the overnight authorization (R-cor-8). **(2) SHIPPED:** `PENDING — one
sentence per batch at the closeout; zero schema; zero `Sync/`; the marker STAYS 7.` **(3) HANDED FORWARD:**
the Lenses + Compare build phase (unslotted, at her word); 13u2's item 17 re-homed here (the door); rows
deferred with owners `PENDING`. Her ratify list: QUESTIONS `#PENDING` (the §7 bundle).

**OverallModel / CoreDescription:** no change (no model semantics moved). **SyncSpec:** no change.
**CLAUDE.md:** no change (the round's rules C-1…C-7 live in the plan; a future ruling may promote C-2/C-3 —
the use-gate and no-install-without-a-walk — to the architect-phase skill; recorded as a candidate for her,
not applied).

## 7d. THE LADDER — spawn text (so the review runs by copy; the skill's rules)

After E closes and before the orchestrator's full walk: spawn a fresh `general-purpose` Agent (cold reviewer,
ZERO framing of the work) with exactly this: *"You are a cold reviewer. Read `notes/REVIEW_PROMPT.md` and
follow it VERBATIM against the diff `git diff 962e7b8..HEAD -- App/ Sources/ Tests/` (the Act 10 correction
round's combined diff; `962e7b8` is the last commit before batch B's first code commit — verify with
`git log --oneline 962e7b8..HEAD`). Your anchor for prior dispositions is `notes/plans/act10-correction-
round.md` §8 (the batch records). Write your findings — BLOCKER/MAJOR/MINOR/NIT, each with a traced
mechanism — as a `LADDER ROUND 1` section appended to that plan file, commit with the standing trailer,
push, and stop. Do not fix anything."* Then: the orchestrator records dispositions in the same section
(repo-first); a FRESH fix session lands accepted findings with revert-verified pins; round 2 = a fresh
reviewer re-reviews the fixes + what they touched; any NEW BLOCKER/MAJOR ⇒ round 3; cap three; anything
open after round 3 is recorded for her. The spec outranks both agents; every finding gets a written
disposition. The trailer for every commit: `Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>` +
`Claude-Session: https://claude.ai/code/session_01UBSTZCXPHewx5nd3VB5fvb`.

## 8. Records (appended per batch; the triage walk first)

### TRIAGE WALK — LIVE (2026-09-01 ~04:30 → ; the orchestrator, dev-store Debug build `io.lduarte.Variorum.debug`, Terminal voice, window zoomed 1728×1084; captures in `act10-correction-screens/triage/`)

- **Driving recipe that works:** System Events for keys/menus/window bounds (`vd.sh` in the session scratchpad); clicks via a compiled CoreGraphics event poster (System Events' `click at` never reached this SwiftUI window; `cliclick` is not installed). The dev app restores TWO windows at launch (state restoration) — close one. Zoom = Window ▸ Zoom (the green button is Full Screen).
- **Confirmed on the dev store, beyond her list:** the masthead title centers in the space LEFT of the right cluster in every mode (rows 4/19 mechanism); Compare offers "make outline note"/"+ note" TWICE (top-right buttons + the centered cards); Compare's anchor column is empty even with a titled note (row 17 — the filter empties the anchor); "position" is per-mode memory, not one position (Index kept block 03 while Takes made block 1 live — row 39); the Library's book-row click leaves the NOTE panel showing (row 33, exact); the "this note" rail vanishes whole on leaving a note (row 24); the library keeps the hairline-separator grammar; the book Outline's card preview shows only the FIRST block ("A Scandal in Bohemia" previews as "I." — the section numeral); the expanded note's vertical side card (row 40) reproduces; expanding a note lands focus on its LAST block.
- **ROW 44 — THE HANG (BLOCKER)** — see the ledger; sample saved beside the captures; the dev build was killed and relaunched to continue.
- **Walk verdicts written into rows 7, 14, 15, 22, 29, 33, 39; new rows 45–47.** Captures 00–51 (the file names say what each is). The field guide was restored into the dev store via Help ▸ Restore Tutorial… (capture 48) so both books exist for the batches. The Trash (47) and Archived (41) rendered fine at the dev store's content level — batch F seeds real content before walking them.
- **What the walk did NOT cover (owed to the batches):** Snippets and the Pool (not in her list); Read's outline toggle (R-cor-5/7 redesigns the mode whole); Canvas; the dark appearance; the Study voice (the walk ran in Terminal — every defect walked is voice-independent; batch A checks the masthead in both voices).
- **Walk CLOSED 2026-09-01 ~05:20.** Batch B spawned next (the hang first).

### ORCHESTRATOR'S WALK OF BATCH B (2026-09-01 ~06:25 →; captures in `orchestrator-b/`)

- **No hang, three ways** (CPU peaks 58 / 19 / 33 % then 0 within 2 s; window responsive throughout). Rows 8 (one row per story), 13 (no gutter counts), 45 ("A Scandal" previews prose) and the row-40 rail (one compact grouped card) read right on the fresh build. Boscombe opens at **block 1/215** (row 44's second symptom fixed).
- **RESIDUAL — row 53 (MAJOR):** landings with two or more expanded stories in play mis-land (details in the row). Batch B is REOPENED for it (a fresh fix session, spawned ~06:45 — B's own session could not be resumed; the repo was its brief); its record stays un-closed until the fix is walked again.
- **The rest of B's rows, walked on the same fresh build (captures 15–24):** the body chapter heading is a door (15) · the book Index edits in place — the clicked block goes live, ring + caret (17; caret at the block's END, row 49's family → C) · the Read tab opens on the book's title page and a click on a PARAGRAPH flips to Index with that block live (24; clicks on a heading or the margin are not doors, by design) · the field guide's far-below "the seal" reveals and opens at block 1/3 (20) · the rail is one compact grouped card (00/04). **Nit for the fix session or C:** the landed block sits flush at the pane's top with its ring clipped — give the landing a top inset.


---

### BATCH B — THE BOOK (brief for a FRESH Fable implementer session; written 2026-09-01 ~05:25 by the orchestrator)

**You are the batch B implementer. Read, in this order, IN FULL: this file (§0–§8 — the constitution, the
round's rules C-1…C-7, the ledger, the triage record); `notes/author-reports/2026-09-01-post-act10-ui-report.md`
(§1 verbatim; the image rows 2, 6, 11, 16); `notes/TEXTKIT2_NOTES.md` §2; then the code: `App/Variorum/
Variorum/Features/BookView/BookView.swift` (1,439 lines — the Outline, the navigator, the lazy stack, the
reveal), `Features/BookView/BookIndexView.swift`, `Features/TOC/BlockTOCView.swift` (the shared outline
brain), `Features/Editor/CommitBar.swift` (the `.vertical` axis — row 40), `Shared/NoteIndexOutline.swift`,
and the existing pins `VariorumTests/BookViewTests.swift`, `BookRedesignMountTests.swift`,
`BookIndexColumnTests.swift`, `BookAscentTests.swift`, `TutorialWalkTests.swift`. Read the hang sample
`notes/plans/act10-correction-screens/triage/sample-hang-47298.txt` (Call graph section). Do not brief
yourself from anything else.**

**Your surface is the BOOK, and only the book (C-1).** Rows, in the order to take them:

1. **Row 44 — THE HANG (BLOCKER) — FIRST.** Reproduce it on the dev-store Debug build before touching code
   (steps in the row; both books are seeded there). Trace the loop yourself; the orchestrator's hypothesis
   (an expanded note's full `EditorView` inside the `LazyVStack` + an animated `scrollTo` at a moving anchor)
   is a hypothesis until your pin says so. **Pin:** a mounted `BookView` with one ~9k-word note expanded
   receives a navigator reveal for another chapter; the pin asserts the main run loop returns within a
   budget (a watchdog on a background thread that fails the test if the main thread does not yield within,
   say, 5 s) AND that the requested chapter is at the top. It must be RED on the current tree (the hang)
   and green after. Fix shape is yours; constraints: P-3 (the expanded editor stays THE one live editor
   through `PaneTextAuthority`), P1 (no whole-book layout), TEXTKIT2 §2 (never `ensureLayout` the whole
   book; one expanded note is bounded). Candidates: settle the expanded editor's height before/while a
   programmatic scroll runs and hold it; no `withAnimation` around a `scrollTo` whose anchor is unsettled;
   or take the expanded body out of the lazy container. Also fix the related symptom: **expanding a note
   lands focus on its LAST block** — it lands on the FIRST (or the requested block); pin it.
2. **Rows 47 + 7 + 23 — the navigator's note-row click.** A note-row click REVEALS the note (scrolls it to the
   top of the page) and lands focus in it at its first block; the ▸ disclosure is the separate expand
   affordance; a collapsed off-screen note must be revealable (the `page-<id>` anchor must exist on the
   collapsed card too, or the reveal must expand-then-scroll — your call, stated). Pin: a collapsed,
   off-screen note is revealed by a navigator click (RED on old: the page does not move). Row 23's
   "intermittent" is this row; say so in the disposition if your trace agrees.
3. **Row 14 — chapters.** The navigator's chapter click already navigates when collapsed (walk capture 23/50)
   — keep it, and make it survive expansion (that is row 44). The main column's chapter HEADINGS (the ⠿
   name rows) become doors too (click → that chapter at the top; the drag handle stays a handle).
4. **Rows 9 + 12 — the scroll class.** After 1–2, walk it on Sherlock: expanded story + middle chapter; note
   row far below; chapter far above. Any residual travel/overshoot gets its own pin.
5. **Row 8 — the duplicate line.** In the navigator, when a chapter has exactly one note whose display name
   equals the chapter's name (case/whitespace-insensitive — `BookNaming.key` is the existing key), the note
   line collapses into the chapter row (the row still opens the note). Pin on a Sherlock-shaped fixture;
   the field guide (different names) must be untouched.
6. **Row 13 — the details gutter.** Drop the invented "236w · ⑂ takes on 1 block" string. The gutter carries
   what used to render BELOW an expanded note's opening paragraphs before Act 10 — find it in git
   (`git show 0e6a09e^:App/Variorum/Variorum/Features/BookView/BookView.swift`) and move THOSE details to
   the side, calm (C-6: no metric without a reason; a word count may stay ONLY where the pre-Act-10 details
   had one). The right edge stops being "bizarrely open": the card column + gutter share the width honestly.
7. **Row 22 — the book's Index becomes EDITABLE in place (R-cor-7).** A click in the right pane makes THAT
   block live right there (the TOC's read-cheap→live upgrade through `PaneTextAuthority` — one live editor);
   the double-click handoff to Outline retires; the book's READ word-tab stays read-only. Pin: after a click
   in the book Index, exactly one live pane exists and it is the clicked block (PaneTextAuthority's
   invariant); the caret is at/near the click.
8. **Row 38 (book half) — the scrolled-open door.** A click on a sentence in the book's READ tab lands in the
   editable view (Index, per R-cor-7) at THAT block with the caret there — not at the top, not at the last
   block. Build the landing target as ONE small brain (`(postID, blockID, characterOffset?)` → the mode
   switch + reveal + focus) that batch C will reuse for the note; name it and its file in your record. Pin:
   a Read click on the third block of the second note lands in Index with that block live.
9. **Row 40 — the expanded note's vertical side card** (`CommitBar` `.vertical`). Make it read as ONE calm,
   clear control: group what belongs together, drop what the book already shows, collapse the stack when
   the width says so, and never a floating box of unrelated items. Her words: "collapsible… what's in that
   menu and how it looks needs to be a bit clearer." Screenshot pair in your record (before/after) —
   this is the batch's one taste-shaped item; keep every capability present (she rewrites copy later).
10. **Row 45 — card previews.** The collapsed card previews the first ~40 words across the note's leading
    blocks, skipping a lone heading/numeral block; derived at read time. Pin on a numeral-first fixture.

**Rules that bind you (from §2b):** one surface — if you find yourself in `PostDetailView`/`SidebarView`/
masthead code, stop and record it for A/C instead. Every bug-class row lands with a red-on-old pin verified
by BEHAVIORAL REVERT (switch the mechanism off in place, run the pin, restore, `git diff --stat` empty).
`TutorialWalkTests` green at the end. **The acceptance gate is USE (C-2):** after the code, walk EVERY row
above on the dev-store Debug build with a capture per row into
`notes/plans/act10-correction-screens/batch-b/` (gitignored) — chapter click with a story expanded (no
hang, lands there) · off-screen note-row reveal · heading click · Sherlock duplicate line · the gutter ·
book Index click-to-edit · Read click → Index at that block · the side card before/after · a numeral-first
preview. Name each capture in your record. **Do NOT touch `/Applications` or her real-store app.**

**Environment (§6 verbatim applies) + the driving recipe:** build the walk build with `cd App/Variorum &&
xcodebuild -scheme Variorum -configuration Debug -destination 'platform=macOS' build`; the product is
`~/Library/Developer/Xcode/DerivedData/Variorum-*/Build/Products/Debug/Variorum.app` (bundle
`io.lduarte.Variorum.debug`, the fenced dev store — both books seeded; if it opens TWO windows, close one).
Drive it with `notes/plans/act10-correction-screens/tools/vd.sh` (`shot <name>` · `click <x> <y>` in
window-relative POINTS · `dbl` · `key <code> ["command down"]` · `menu <Menu> <Item>` · `zoom`); set
`VD_DIR` to your batch's capture dir. Clicks go through the compiled CoreGraphics poster beside it
(System Events' `click at` does not reach this window). Read a capture with the Read tool; captures are 2×
— window point = displayed pixel × (window width ÷ displayed width). The machine must stay unlocked and
untouched by you outside the dev window. Mac tests: from `App/Variorum/`, suite-level `-only-testing:`
(e.g. `-only-testing:VariorumTests/BookViewTests`), confirm the "Test run with N tests" line, zsh
`pipestatus`; the full Mac suite once at the END (baseline: pre-13u finals Mac 1985/343 + whatever the two
13u2 commits since added — state the arithmetic); the known load-flaky reds (`rewriteStrategyLatencies`,
`CanvasDragTrackingTests`) are re-run isolated, never loosened. Never a custom build configuration.

**Resiliency (binding):** commit per row/piece with the standing trailer and PUSH after each; write a
`LIVE STATUS — BATCH B` list at the top of your record from your FIRST commit and update it every commit
(what is done, what is next, what is uncertain); **synchronous foreground waits only — never background a
build or a suite and end your turn waiting on it** (that is how sessions die); if you approach your context
limit, finish the piece in hand, write the record, commit, push, and stop with a one-paragraph handoff at
the end of your record — a successor adopts from the repo, never from you.

**Your deliverable:** the code + pins, and a **BATCH B RECORD** appended to this file directly under this
brief: per row → FIXED (pin name, red-on-old evidence as the issue count under revert) / RECORDED / DEFERRED
(owner + why); the door brain's name; the capture list; the counts; the commits in order; anything you
found that she did not report (as new ledger rows, numbered from 48). Then stop. The orchestrator walks
your rows before the record is marked closed.

### BATCH B RECORD — THE BOOK (a fresh Fable implementer session, 2026-09-01 ~05:30 →)

#### LIVE STATUS — BATCH B (flipped in the same commit as each piece; a fresh session finishes from this list alone)

- **Row 44 (the hang) + rows 9/12 (the scroll class) + row 47/7/23 (the note-row reveal) + row 14 (chapters):** DONE (`be32fa7`) — ONE mechanism: Outline's landing rebuilt (no animation; bounded convergence; the flat `BookOutlineRows` ForEach whose identities ARE the anchors; the model's `pendingChapterReveal` slot beside W21's note slot; chapter HEADINGS are doors; Read ▸ Scroll's chapter click lands the flow). Pins green on the new tree (`BookOutlineLandingTests` ×3, `BookOutlineRowsTests` ×2). **Red-on-old VERIFIED by behavioral revert** (animated `scrollTo` + no hops + the anchor as an explicit `.id` inside a positionally-identified lazy row + no caret seed): 4 issues in 3 tests — the chapter landing 937 pt off with the scroll offset still 0 (the page never moved), the off-screen card never realized (`anchorTop == nil` — row 47's "the page did not move"), the caret at 56,004 (the document's end = block 215/215) and `caretSeed == nil`. Restored; `git diff --stat` empty.
- **Row 44's second symptom (focus lands on the LAST block):** DONE (`be32fa7`) — a bare `BookViewModel.focus` seeds caret 0; pin `aBareFocusLandsAtTheFirstBlock` green; red under revert (2 issues, above).
- **Row 8 (the duplicate line):** DONE (this commit) — `BookOutlineRows.noteLineCollapsesIntoChapter` (one note, `BookNaming.sameName(displayTitle, chapter)`); the navigator draws ONE row, which OPENS the note (`openFromNavigator`), wears the › marker, and carries both menus; the field guide untouched (different names). Pins `BookOutlineFacesTests` ×2 (door class — red-on-old by construction: the rule did not exist).
- **Row 13 (the gutter):** DONE (this commit) — `BookOutlineRows.gutterLine(fannedBlocks:)`: the per-card word count DROPPED (C-6 / R-cor-4(d)); the takes fact KEPT (a card cannot show it otherwise); the gutter beside an expanded read-cheap note is empty (its takes wear badges on the prose); the gutter is FLEXIBLE (`layoutPriority(1)` on the prose column so the measure holds — the `outlineProseSitsOnWritesOwnMeasure` pin caught the first cut splitting the width evenly); the FOCUSED row stays capped at `outlineFocusedRowWidth` so the live editor never exceeds Write's measure. Pin `theGutterCarriesTheTakesFactAndNoWordCount`; red-on-old verified with row 45's revert (7 issues). **Row-36 verdicts for BookView's four metrics:** the card `Nw` → DROP · the gutter `⑂ takes on N blocks` → KEEP · `bookMetaLine` ("book · 13 chapters · 13 notes") → KEEP (the book's shape under its title; not a word count) · the side card's `Nw block` / `Nw in note` → row 40. **Taste note for her (HELD):** the open right of the pane is unchanged in kind — prose and cards still end at Write's measure, left-anchored per batch 12's ruling; the gutter now holds only the takes fact. If she wants the column centred like Write's, that is a one-line ruling.
- **Row 22 (the book Index editable in place):** DONE (this commit) — `BookIndexEditModel` (`Features/BookView/BookIndexEditModel.swift`): ONE `PaneTextAuthority` for the whole pane, each key's `context` = the post (13b 4C's shape), per-post autosave coordinators, the leaving post flushed on migration; `BookIndexPaneNote` OBSERVES its rows (`observeBlockTOC`), renders each block as `Text` and upgrades the clicked block to a `PaneSurfaceView` (role `book-index`); locked takes stay read; the double-click handoff to Outline retired ("Show in Outline" stays a navigation in the row menu); the pane's rows flattened so a note-target scroll reaches an unrealized note (the Outline lesson). Read stays read-only (untouched). Pins `BookIndexEditingTests` ×3; `BookRedesignMountTests` keeps the at-rest half (zero live until a click). Red-on-old by construction: the pre-round index mounted no editable pane at all.
- **Row 38 (book half — the scrolled-open door):** DONE (this commit) — **the door brain is `LandingTarget`** (`App/Variorum/Shared/LandingTarget.swift` — `postID · blockID? · utf16Offset?`, pure, cross-platform home) + `BookViewModel.requestLanding(_:)` / `pendingLanding` (rides beside W21's `pendingReveal`; consumed together). `ReadingFlowView` renders per BLOCK so a click knows its block (`onWake(postID, blockID?)`); `BookView`'s flow wake = `model.requestLanding(target); structure.mode = .index`; the index selects the note, scrolls the pane to the note, then to the block, and makes it live when the note's rows are in hand (`BookIndexEditModel.requestLiveBlock/takePendingLiveBlock` — taken on the observation's first delivery, or at once when the note is already realized). The caret lands at the block's START (a SwiftUI `Text` cannot say where inside itself the click fell — recorded; the TK2 read tier will carry `utf16Offset`). Pin `theReadClickLandsInIndexAtThatBlock` (+ a block-less landing → the first block). Batch C reuses `LandingTarget` for the note.
- **Row 40 (the side card):** DONE (this commit; captures PENDING the walk) — `CommitBar.verticalBody` re-shaped as ONE grouped control: the where-you-are line with a fold chevron (`bookSideRailCollapsed`, a preference — the bar is re-created per focused note) · `block ▾ · Takes` · `commit ⌘S · history` · `note ▾ · comments · Aa` · one count line = the word-target door + `?`. Pairs are `ViewThatFits` (side by side where the rail allows, stacked otherwise — no mid-word wraps, P-8). The rail's `Nw block` / `Nw selected` lines DROPPED (C-6; the flat bar keeps R11's idiom) — row-36 verdicts for the side card. Every door survives (the registry walk's `renderedCapabilities` unchanged). Taste-shaped: before = `03-boscombe-expanded-before.png`; after = `12-boscombe-opened-from-navigator.png` (block 1/215 · the grouped rail) and `31-…` (block 1/8).
- **Row 45 (previews):** DONE (`83a25de`) — `BookOutlineRows.cardPreview(blocks:words:)`: the first ~40 words ACROSS the leading blocks, a lone heading/numeral stub skipped (`isLoneHeadingOrNumeral`: a markdown heading, or ≤ 2 words in ≤ 12 characters — `I.`, `Chapter 3`), an ellipsis where the note goes on, never an empty card. Pins ×3. **Red-on-old VERIFIED by behavioral revert of the two brains to the old rules** (`cardPreview` → the first block's `prefix(280)`; `gutterLine` → `0w · …`): 16 issues across the 45/13 pins (the preview "I.", the gutter "0w"); restored, diff empty. *(Machinery honesty: this revert ran without the "revert starting" line being written first — a slip against the protocol's addendum 2; the tree was restored in the same command and verified clean.)*
- **The USE gate:** DONE — every row walked on the relaunched dev-store Debug build (pid 56593, then 57450 after the navigator fix); the capture list is below. **One defect found in the walk and fixed in-batch (row 48):** the navigator's row target was the TEXT, not the row.
- **Full Mac suite + TutorialWalkTests:** DONE — **Mac 1999 tests / 347 suites, all green** (`** TEST SUCCEEDED **`; `TutorialWalkTests` inside it; the load-flaky `rewriteStrategyLatencies` passed this run, `CanvasDragTrackingTests` green — neither loosened). **Arithmetic against the pre-13u baseline 1985/343:** the two 13u2 commits since (`bdc4d71`, `72d1c68`) touched no test files (+0); this batch added **+14 tests / +4 suites** — `BookOutlineLandingTests` 3 · `BookOutlineRowsTests` 2 · `BookOutlineFacesTests` 6 · `BookIndexEditingTests` 3 — so 1985 + 14 = **1999** and 343 + 4 = **347**, exact. **Core 1524 / 165, green and exact** (zero `Sources/VariorumCore` lines in this batch).
- **STATUS: BATCH B's build is COMPLETE — the record awaits the orchestrator's hands-on walk (C-2) before it is marked closed.** The dev-store Debug build (pid 57450, the fresh product with every batch-B commit) is left RUNNING for that walk, window zoomed; `/Applications` untouched; her real-store app untouched.
- **No revert in flight** (the red-on-old revert ran and was restored — `git diff --stat` empty against `be32fa7`; evidence in the table below).

#### The hang — what reproduced, what did not (recorded before any code moved)

- The dev-store Debug build (pid 49566, the walk's relaunch) reproduced the walk's PRE-conditions exactly: navigator note-row click on "The Boscombe Valley Mystery" → the story expands, focused, the side card reads **block 215/215** (capture `03-boscombe-expanded-before.png`).
- **The scroll class reproduced twice, deterministically:** a navigator click on the chapter AFTER the expanded story ("the five orange pips") landed mid-story at the same paragraph both times (captures `05-after-five-pips.png`, `09-after-five-pips-2.png`) — her "didn't scroll to the correct item… landed me at the end of the note". A chapter ABOVE the story landed correctly (`04-…`); the last chapter's click landed inside the story too (`06-…`).
- **The livelock did NOT recur** in six attempts on the same build and sequence (CPU peaked 32–43% for < 2 s per click, then 0%). The triage sample's hot frames are lazy placement under an animated transaction stream; the mis-landing and the livelock are the same mechanism at two phases (an animation travelling toward an ESTIMATED offset while rows realize and the target moves — converging short, or retargeting forever). The fix removes the animation and bounds the convergence, so the class is closed by construction; the pin's watchdog stands as insurance. Recorded honestly: the hang itself was not re-observed.
- **Harness facts measured this batch (they shaped the fix):** `ScrollViewProxy.scrollTo` reaches an UNREALIZED `LazyVStack` row ONLY through the row's ForEach identity — an explicit `.id` on an unbuilt row is unknown to the reader (a reveal of an off-screen card moved nothing; the same reveal by the ForEach identity landed at top=0.0). Geometry reports (`onGeometryChange` in the scroll's named space) do NOT follow an AppKit-driven `NSClipView.scroll(to:)`, so the landing stays SwiftUI-driven. The last row of a page can never sit at the top (SwiftUI clamps) — the pins target rows with a viewport of content below them.

#### Per-row dispositions (filled as rows close)

| Row | Disposition | Pin | Red-on-old |
|---|---|---|---|
| 44 | FIXED — Outline's landing rebuilt; bare focus seeds caret 0 | `BookOutlineLandingTests.aChapterRevealLandsAtTheChapterWithAStoryExpandedAndLive` · `.aBareFocusLandsAtTheFirstBlock` | 1 issue (937 pt off, offset 0) · 2 issues (caret 56,004; seed nil) |
| 9 · 12 | FIXED (row 44's mechanism) | the chapter pin above | the same 1 issue |
| 47 · 7 · 23 | FIXED — a note-row click focuses + reveals through the model slot; the anchor is the row's ForEach identity. Row 23's "intermittent" IS this: the old reveal worked only for a card that happened to be realized | `.anOffScreenCollapsedNoteIsRevealedAtTheTop` | 1 issue (the card never realized — the page did not move) |
| 14 | FIXED — the body's chapter headings are doors (`navigateToChapter`); the navigator's chapter click survives an expanded story (the chapter pin) | the chapter pin | — (door class) |
| 8 | FIXED — the one-note chapter's duplicate line collapses into the chapter row, which opens the note | `BookOutlineFacesTests.aOneNoteChapterThatSaysTheNotesNameCollapsesTheNoteLine` · `.differentNamesOrSeveralNotesKeepEveryLine` | door class (the rule did not exist) |
| 13 | FIXED — the word count dropped from the gutter (C-6); takes fact kept; flexible gutter; the focused row capped | `.theGutterCarriesTheTakesFactAndNoWordCount` | 7 issues under the old line (`0w · ⑂ takes…`) |
| 22 | FIXED — the book Index edits in place through ONE authority; Read stays read-only | `BookIndexEditingTests.aLandingMakesTheNamedBlockTheOneLivePaneAndASecondMigratesIt` · `.theEditModelHoldsOneRingAcrossPostsAndOverlaysTheBuffer` | by construction (no editable pane existed) |
| 38 (book half) | FIXED — `LandingTarget` (the door brain, `Shared/LandingTarget.swift`); the Read click lands in Index at that block | `.theReadClickLandsInIndexAtThatBlock` | by construction |
| 40 | FIXED (taste-shaped) — the rail is one grouped, foldable control; counts reduced to the word-target door | — (no pin; before/after captures) | — |
| **48** (new — the walk) | FIXED — the navigator's chapter and note rows act on the WHOLE row (`frame` + `contentShape` moved INSIDE the `Button` labels; a plain button acts on its label's shape, so W11a's "the whole row is the target" was unmet — capture 23 before, 31 after) | — (a hit-test the harness cannot drive; the walk is the evidence) | — |
| **49** (new — the walk, NOT the book's surface) | RECORDED for **batch C** — the DETAIL Write editor's bare arrival lands the caret at the LAST block (capture 15: "block 262/262" on opening a story from a card) — `EditorViewModel.applyFocusSeeds`' N12 comment says "the caret lands at the document start" but the claim only resets when `location > documentLength`, which never holds; the projection fill carries the insertion point to the end exactly as the inline case did (row 44's second symptom, note-side) | — | — |
| **50** (new — traced at the code) | FIXED (rode row 14) — Read ▸ Scroll's navigator chapter click wrote Outline's private `scrollTarget`, which nothing consumed outside Outline; `navigateToChapter` now lands the flow on the chapter's first note. Not walked (Read ▸ Scroll's landing is the flow's own W21 reveal) | — | — |
| **51** (new — traced at the code) | FIXED (rode row 22) — the book Index pane's note-target scroll used an explicit `.id` on a lazy item, inert for an unrealized note (row 47's class); the pane's rows are one flat `ForEach` whose identities are the anchors | — | — |
| **52** (new — observed, not a defect of this batch) | RECORDED for her (§7) — the sample library's `_the_` (Gutenberg's underscore emphasis) renders RAW on the card, the Index pane and Read: the 13g markdown vocabulary has no underscore italics. A vocabulary call, not a rendering bug | — | — |
| 45 | FIXED — the preview reads across leading blocks and skips a lone numeral/heading | `.aLeadingNumeralBlockIsSkippedAndTheProseBeginsThePreview` · `.aProseFirstNoteKeepsItsOpeningAndAStubOnlyNotePreviewsTheStub` · `.thePreviewReadsAcrossLeadingBlocksToTheWordCapWithAnEllipsis` | 9 issues under the old rule (the first block's `prefix(280)` — "I.") |

#### The USE gate — the walk (the relaunched dev-store Debug build, Terminal voice, window zoomed; every capture in `act10-correction-screens/batch-b/`)

| Row | What was done | Capture(s) |
|---|---|---|
| 44 · 9 · 12 (before) | Boscombe opened from the navigator (block 215/215, the old side card); the chapter after it clicked twice → landed MID-STORY both times; the livelock not re-observed in six attempts | `03-boscombe-expanded-before` · `05-after-five-pips` · `09-after-five-pips-2` |
| 44 (after) | Boscombe opened from the navigator: **block 1/215**, the caret at the first block, the new rail | `12-boscombe-opened-from-navigator` |
| 9 · 12 (after) | With Boscombe expanded, the next chapter/story clicked → **lands exactly at its top**, no hang (CPU 1.6 % peak), block 1/178 | `13-five-pips-opened-after-story` |
| 14 | A pure chapter row ("about this text") lands at the top past two expanded stories; the BODY heading "a scandal in bohemia" clicked → that chapter at the top | `14-chapter-row-about-lands-top` · `17-heading-click-scandal` |
| 47 · 7 · 23 | The field guide's far-below note row ("the seal") → the note opens focused (block 1/3) and the page scrolls to it (as far as the page allows — the second-to-last note cannot sit at the very top; SwiftUI clamps) | `22-offscreen-noterow-the-seal-2` |
| 8 | The Sherlock navigator: ONE row per story chapter; "about this text" keeps its differently-named note line; the field guide untouched | `11-sherlock-outline-after` · `20-field-guide-outline` |
| 13 | No gutter word counts; the takes fact alone beside "three ways of working" | `11-sherlock-outline-after` · `22-offscreen-noterow-the-seal-2` |
| 45 | "A Scandal in Bohemia" previews prose, not "I."; Boscombe's card reads across two blocks | `11-sherlock-outline-after` |
| 22 | The book Index: a click on a block in the pane → THAT block live (ring, caret), the column selects the note | `24-sherlock-index` · `25-index-block-click-live` |
| 38 | Read ▸ Scroll → a click on the third block's sentence → Index at THAT block, live, scrolled to it | `26-sherlock-read-flow` · `27-read-click-lands-index-at-block` |
| 40 | The rail after: `block 1/215 ▾ · block ▾ takes · commit ⌘s history · note ▾ comments aa · 9,689w in note ?` | `12-…` · `13-…` · `31-…` |
| 48 | A click RIGHT of a note row's text: nothing (before) → opens the note at block 1/8 (after the fix) | `23-noterow-hit-right-of-text` · `31-noterow-hit-right-of-text-after` |
| (aside) | The card body's click opens the note in the full editor — as designed (N22); it showed row 49 | `15-heading-click-scandal-lands-top` (misnamed: the click hit the card, not the heading) |

Honesty notes: the card and pane show `_the_` raw (row 52); the row-38 caret lands at the block's END in use (the pane's default on becoming first responder), not its start as the record first said — the click's offset is not carried by a SwiftUI `Text` either way; the TK2 read tier's `utf16Offset` is the road.

#### Commits (in order)

1. `be32fa7` — rows 44/9/12/47/7/23/14: the landing rebuilt + pins + this record's skeleton.
2. `ca479eb` — the red-on-old evidence for the landing pins recorded.
3. `83a25de` — rows 45/13/8: the card preview brain, the gutter's line + flexible gutter, the navigator's collapsed duplicate line.
4. `c768c08` — rows 22/38: the book Index editable in place (`BookIndexEditModel`), the scrolled-open door (`LandingTarget`), the flow's per-block click.
5. `45608b1` — row 40: the side rail as one grouped, foldable control.
6. `e4e9dcb` — row 48 (found in the walk): the navigator's rows take the whole row; the walk's captures + this record.
7. `b28128f` — the counts, the door brain's naming, the handoff paragraph. 8. (this commit) the hash filled.

#### The door brain, named (for batch C's reuse)

**`LandingTarget`** — `App/Variorum/Shared/LandingTarget.swift` — `postID · blockID? · utf16Offset?`, pure, `Equatable`/`Sendable`, cross-platform home. The book's consumers: `BookViewModel.requestLanding(_:)` / `pendingLanding` (rides beside W21's `pendingReveal`; both consumed by `consumeReveal()`), `BookIndexView.landOrSeed` (selects + scrolls the note, hands the block to the pane), `BookIndexEditModel.requestLiveBlock/takePendingLiveBlock` (makes the block live when its rows are in hand). The note's version (batch C): the same value, consumed by the note's Read→edit switch (mode change + `CommandRouter.focusedBlock` seed + the pane's live upgrade); a TK2 read tier can fill `utf16Offset`, a SwiftUI `Text` cannot — the consumer then lands at the block. Sibling brains this batch left for reuse: `BookOutlineRows` (the flat lazy rows keyed by anchor — the pattern any lazy landing needs), `BookOutlineGeometry` (the DEBUG landing oracle), `BookIndexEditModel` (one `PaneTextAuthority` over several posts, the compare board's shape).

#### What the orchestrator should know before walking (the handoff paragraph)

Everything is committed and pushed through `e4e9dcb` (+ this record's commit); no revert is in flight; the tree is clean. The rows are all FIXED or RECORDED — none DEFERRED, none REVERTED (C-5 not exercised). Two dispositions are honest limits rather than fixes: the livelock itself was never re-observed on this build (six attempts; the deterministic mis-landing of the same mechanism was, twice, and is pinned + fixed), and the row-38 caret lands at the block, not at the click (a `Text` cannot say where inside itself it was clicked). Three items are HELD for her in §7 (the gutter's centring question, the underscore-emphasis vocabulary, the row-36 verdicts). Row 49 is batch C's (the detail editor's caret-at-end arrival). Walk suggestions: Sherlock ▸ Outline — click "the boscombe valley…" then "the five orange pips" (no hang, lands at top, block 1/N); click a body heading; the field guide's far rows; Index — click any block, then another (one ring); Read — click a sentence mid-story. Known non-book residue seen in passing: the sidebar's Open strip and the masthead are batch A's; nothing in `PostDetailView`/`SidebarView`/masthead/Compare was touched.


#### ROW 53 FIX — the landing with two or more expanded stories (a fresh Fable fix session, 2026-09-01 ~06:40 → ~08:00)

**LIVE STATUS — ROW 53: FIXED (pin + walk) — commits `7569af3` · `763d70d` · `5fb9a8e` · `82ade54` (+ this hash fill). All six steps of the orchestrator's repro land at the top on the final dev build (captures 123–132; the app's own landing log: every landing `settled` in ~1 s, 0–1 hops). The book's eight pin suites + the ten tutorial suites green (101 tests / 17 suites); **the full Mac suite 2001 / 347 green (1999 + 2, exact)**. No revert in flight. The dev build (the final tree) is left RUNNING for the orchestrator's walk. NEXT (the orchestrator): walk row 53's six steps + the rows the walk deferred (47/7/23 on the field guide, 14's body headings, 22, 38, 40); mark the batch record closed.**

- **Reproduced first on the running dev build** (pid 57450 — the current tree: the three commits since its build, `b28128f` `1a6ceaf` `fc925bd`, are docs-only), from "collapse all": step 1 Boscombe ✓ (`37-r53-step1-boscombe`) · **step 2 Noble Bachelor landed ~680 pt SHORT** (`38-r53-step2-noble`; the orchestrator's step 2 landed, mine did not — the class is timing-shaped, not step-shaped) · step 3 ✓ (`39-…`) · step 4 Scandal ✓ in my run (`40/41-…`; the orchestrator's mis-landed) · **step 5 the last story → mid-NOBLE BACHELOR, the same "Lord St. Simon" paragraph as the orchestrator's capture 12** (`42/43-r53-step5-…`) · **step 6 Red-Headed → the page did not move at all, still inside Noble Bachelor 4.5 s later** (`44/45-r53-step6-…`). CPU 0.3–0.4 %; no hang.

- **THE TRACED MECHANISM — five layers, each found by its own trace, in the order found (the first fix was wrong twice, and the record says so):**
  1. **The harness (the pin's DEBUG trace on the pre-fix tree):** the first cut's convergence was COUNT-driven (four hops, each fired the turn after a report). Far-below: `8517 → 470 → −80 → 269 → 200` — the budget spent mid-oscillation while the neighbouring expanded rows were still loading, then a drift to **361 pt**. Far-above: `399 → 419 → 416 → 417 → 414` — four immediate hops re-landing the same wrong offset; left alone one quiet interval the same landing settles to 0.08 pt with ZERO hops (the old loop was fighting SwiftUI's own settle). → `7569af3`: a STABILITY-driven convergence (quiet interval, hop cap 40, 4 s watchdog). Green in the harness — **and still wrong in the app** (steps 5/6, captures 54/56).
  2. **The app, first look:** the quiet interval (150 ms) raced the dev store's async loads (a 9k-word note's DB read + projection fill takes hundreds of ms on the encrypted on-disk store; the in-memory harness takes tens). A hold (1 s) and a re-arm on any content-height change were added — and the app then never finished a landing at all (nothing in the log): the re-arm was STARVED by a content height that changed every ~140 ms. A ceiling (a check no later than 0.6 s after the last decision) restored the decisions — and the app's log (a DEBUG `NSLog` of each landing's story, readable from the launched binary's stderr) showed the real thing: **fourteen `scrollTo` hops in a row moving nothing** while the column's content height crept `+185 pt / 140 ms` for eight seconds, the target de-realized (`top was 665.6` stale, then `unreported`).
  3. **`scrollPosition(id:anchor:)` over `scrollTargetLayout()`** — the declarative position, re-declared twelve times — moved nothing either: whatever the container BELIEVES about a far row's position is what every scroll API consults, and the belief was wrong.
  4. **The per-row height trace named the churn:** every expanded story the lazy column re-realizes steps **40 → ~10,000 → ~20,000 pt** (its placeholder, a first measure at a provisional width, the final — `page-67DB6BCA h=10366` then `20056`; Scandal back at `12622` before `21054`), several rows at once for hundreds of ms. → **remembered surface sizes** (`BookViewModel.rememberedSurfaceSize`, the row's `StableSurface` reserving the height from the first frame): step 5 landed. **Step 6 still did not, and its content trace is the whole story:** `62,817 → 126,417` in steps decaying by a constant fraction, with **no realized row changing height** — a `LazyVStack` estimates every unrealized row at the AVERAGE of the rows it has measured; with five ~20,000 pt stories measured, a collapsed card is estimated at ~4,800 pt and the container's estimate converges toward 26 × 4,800 ≈ **126,000 pt** against ~50,000 real. A far target's position is off by tens of thousands of points; no request can realize it. This is the row-44 livelock's slow form (the same lazy placement, without the animation).
  5. → **THE SEGMENTED COLUMN** (`BookOutlineRows.segments`, pure): the flat rows split at every expanded note — each RUN of small rows (headings 51 pt, cards 46–103 pt) in its own `LazyVStack` (uniform rows, honest estimates); each expanded note a DIRECT child of the outer `VStack`, **virtualized by the book itself** — a placeholder of its remembered surface height when far from the viewport, the real surface when near (`NearViewportObserver`: near within 2,500 pt, far beyond 7,500 — hysteresis, because the first cut without it oscillated `861 ↔ 221` / `21054 ↔ 94` as a row's own swap moved its neighbours). The memory ignores width and keeps the MAX for read-cheap surfaces (the provisional-width first measure) while FOLLOWING a live editor (typing both ways). The one-live-editor mount pin then caught a doubled `EditorTextView` from state writes inside geometry actions ("modifying state during view update") → the near/loaded flips run on the next turn. **All six steps land** (v8 captures 113–122; the final build 123–132).

- **THE FIX AS SHIPPED (the book's files only — C-1):** `BookView.swift` — Outline's landing: the stability-driven convergence (`landingSettleInterval` 0.25 s · `landingMinimumHold` 1 s · `landingMaxWait` 0.6 s · `landingHopBudget` 40 · `landingTimeBudget` 4 s), re-armed by anchor reports AND content-height changes (`onScrollGeometryChange`), ended by a user scroll (`onScrollPhaseChange` → `.interacting`), its bookkeeping in a reference box (no `@State` write per report — the second cut's own loop), a DEBUG trace (`LAND` · `HOP n` · `DONE: settled/gave up` · `content=` · per-row `h=`) and a DEBUG `NSLog` of each landing's story; the SEGMENTED column; `StableSurface`; `NearViewportObserver`; the P3 materialization count moved from the row's init to its REALIZED content (a card, a surface — never a placeholder; expanded rows are constructed for every segment now, so the init no longer measures what the pin guards). `BookViewModel.swift` — `rememberedSurfaceSize/rememberSurfaceSize` (`@ObservationIgnored`, session state). `BookOutlineRows.swift` — `Segment` + `segments(rows:isExpanded:)`.

- **What this changes beyond the landing (stated, so the orchestrator's walk knows what to look at):** an expanded story now stays at its full height while collapsed neighbours realize around it, and scrolling BACK to a story the column has measured no longer steps 40 → 10k → 20k (the "book page jumping" class — her item 1 of 13u2 has this family; the book's half is better for it). Far expanded rows are placeholders (the column's geometry is exact); a story expanded FAR AWAY that the column has never measured ("expand all") stands at an 800 pt placeholder until the viewport nears it, then grows — scrolling DOWN into it is seamless (growth below the page), scrolling UP into one jumps once (growth above) — recorded, rare by construction. A user scroll inside a landing's first second ends the landing where she put the page (never fights her). The 2,500/7,500 near/far band means at most two or three text surfaces exist at once.

- **Pins:** `BookOutlineLandingTests.openingACollapsedStoryLandsAtItsTopWithThreeStoriesExpanded` — five 215-block stories; 3, 7, 11 opened in turn (the walk's state); a collapsed story far below (15) then one far above (1) opened from the navigator's door; each must sit at the top AND STILL be there a second later. **RED on the pre-fix tree: 1 issue** (far below 360.7 pt off; far above 413.8 pt inside the same run — log `r53-pin-red.log`; the trace is quoted in layer 1 above), run BEFORE the mechanism changed — the behavioral-revert evidence in its cleanest form. `BookOutlineRowsTests.segmentsSplitAtEveryExpandedNoteAndKeepRunsWhole` (pure, door class — the brain did not exist). Green after, with every existing book pin: `BookOutlineLandingTests` ×4 · `BookOutlineRowsTests` ×3 · `BookViewTests` (incl. the P3 materialization pin — 150 posts expanded whole, < 75 surfaces) · `BookRedesignMountTests` (the one-live-editor pin) · `BookOutlineFacesTests` · `BookIndexEditingTests` · `BookIndexColumnTests` · `BookAscentTests` — 30 tests / 8 suites; + the ten `TutorialWalkTests.swift` suites (71 tests) in the same run: **101 / 17 green**.

- **Captures (all in `batch-b/`):** the pre-fix repro `37–45` · first cut `48–56` (steps 5/6 still wrong) · `57–66` v2 · `67–75` v3 (the log's first read) · `76–84` v4 · `85–93` v5 (scrollPosition) · `94–102` v6 (remembered sizes — step 5 lands) · `103–112` v7 (segments — step 6 reaches its story, oscillation) · `113–122` v8 (all six land) · **the FINAL build `123-r53-final-sherlock` · `124-…-step1-boscombe` (block 1/215) · `125-…-step2-noble` (1/226) · `126-…-step3-fivepips` (1/178) · `127/128-…-step4-scandal-1.5s/4.5s` (1/262) · `129/130-…-step5-last-1.5s/4.5s` (1/212) · `131/132-…-step6-redheaded-1.5s/4.5s` (1/215)**. The tool dir gained `scroll.swift`/`scroll` (a wheel poster) beside `click`.

- **Counts:** book + tutorial suites 101 / 17 green (above). **Full Mac suite: 2001 tests / 347 suites, all green (`** TEST SUCCEEDED **`, 292.6 s; log `r53-full-mac.log` in the session scratchpad)** — the arithmetic against batch B's recorded 1999 / 347: +2 tests (the row-53 landing pin, the segments pin), +0 suites ⇒ 1999 + 2 = **2001**, 347 = **347**, exact. The load-flaky pins (`rewriteStrategyLatencies` — 2 cases — and `CanvasDragTrackingTests`) passed in-run, zero issues recorded — nothing re-run, nothing loosened. Core untouched (zero `Sources/VariorumCore` lines).

- **Honesty notes / residuals:** (a) the `[SwiftUI] Modifying state during view update` warnings in the test logs PRE-EXIST (32 in the landing suite's run on the pre-fix tree; the PanePublisher's header names the class) — not introduced here, not chased here. (b) **The read tier's first measure runs at a provisional width** (`ReadPostViewModel.remeasure` before the surface's width settles — 10,366 then 20,056 for the same text): a jump every read-cheap surface makes on realization, OUTSIDE the book's files (C-1) — recorded as **row 54** for the read tier's owner; the book now hides it behind the remembered size. (c) The DEBUG `NSLog` landing story stays in (DEBUG only; the way the dev build was made readable — `<DerivedData>/…/Variorum > log 2>&1`). (d) The convergence's constants are stated in the code with their reasons; the one that is a guess is the 800 pt never-measured placeholder. (e) `scrollTargetLayout`/`scrollPosition` were tried and REMOVED (nested lazy ids are not scroll targets; the proxy's `scrollTo` reaches a lazy ForEach identity, measured by the previous session, and now lands exactly against the segmented column's honest geometry).

- **Commits:** `7569af3` (the first cut + the pin, red-on-old recorded) · `763d70d` (the traced fix: segments, remembered sizes, the box, next-turn flips — WIP checkpoint) · `5fb9a8e` (the segments pin, the final captures, this record, row 54) · `82ade54` (the full-suite counts) · this commit (the hashes).

---

#### BATCH B RECORD — CLOSED by the orchestrator (2026-09-01 ~07:50)

Walked twice: the whole batch on build 57450 (`orchestrator-b/`, 25 captures — the hang gone three ways; rows
7/8/13/14/22/23/38-book/40/45/47 right) and row 53's fix on build 67746 (`orchestrator-b53/` — the six
steps by hand, the three risky landings captured, each at its story's top; the fix session's own ten
captures `batch-b/123–132` read as one contact sheet). Counts at close: **Mac 2001 / 347 green** (1985 +
16 tests, 343 + 4 suites); core 1524/165 untouched; tutorial spine green inside the run. Residuals carried
forward, all owned: row 49 (the detail editor's caret-at-end arrival) → C; row 54 (the read tier's
provisional-width first measure) → C; the never-measured "expand all" placeholder at 800 pt and the
pre-existing state-during-update warnings → recorded in the record, the ladder's to weigh; row 52
(underscore emphasis) → her (§7); the nit (a landed block flush at the pane top, ring clipped) → C with
the door. Nothing deferred, nothing reverted (C-5 unexercised). **Batch A spawned next.**

---

### BATCH A — THE CHROME (brief for a FRESH Fable implementer session; DRAFTED 2026-09-01 ~05:40 by the orchestrator — spawn ONLY after batch B's record is closed; one code agent at a time)

**You are the batch A implementer. Read, in this order, IN FULL: this file (§0–§8 — the constitution, the
round's rules C-1…C-7, her rulings R-cor-1…7, the ledger, the triage record, batch B's record);
`notes/author-reports/2026-09-01-post-act10-ui-report.md` (§1 verbatim; image rows 1, 4, 5, 7, 9);
`notes/plans/pre-13u-round.md` §"THE MOCKUP FEEDBACK" (W8-2/W8-3 — the style guide and the glass ruling)
and the mockup itself `notes/plans/pre-13u-mockups/blocks-and-snippets.html` (open it in a browser and
LOOK — it is the reference grammar); then the code: `App/Variorum/Variorum/RootView.swift` (the
`NavigationSplitView` at :138 and the panels it hosts, :450), `Features/Library/SidebarView.swift` (the
rail :464–487, the Open strip :245 and its placement :346–351, the W8-3 comment :348),
`Features/Takes/PostDetailView.swift` (the masthead — find the title's HStack), `Features/Tags/
MastheadTagCluster.swift`, `Workspace/ContextBar.swift`, `Features/Library/LibraryCatalogView.swift` (the
rows at :599/:796/:853 — already `.firstTextBaseline`), `Theme/CalmGrammar.swift`, `Theme/VoiceControls.swift`
(THE chrome vocabulary, P-8), and the pins `VariorumTests/WorkspaceNavigationTests.swift`,
`NoteRowSelectionTests.swift`, `ContextBarShapeTests.swift`, `CommitBarLayoutTests.swift`,
`TutorialWalkTests.swift`. Do not brief yourself from anything else.**

**Your surface is the CHROME — the sidebar, the masthead, the library rows — and only that (C-1).** Rows:

1. **Row 2 — the liquid-glass sidebar retires for real (W8-3, half-delivered).** The floating glass pane is
   the `NavigationSplitView` sidebar's Tahoe default. Deliver W8-3 whole: solid, geometric — a flat column
   with one honest divider, no floating inset, no glass; the interior W8-3 already painted stays. Decide
   the container (a flat style on the split view if macOS 26 offers one that truly removes the floating
   pane; otherwise an `HSplitView`/custom split that keeps the sidebar's collapse, the width memory, and
   every panel RootView hosts beside it — Scraps, References, the tray, the info panel). State the
   decision and its reason in the record. Both voices, light and dark. Pin: a mount smoke that the sidebar
   renders without the split view's glass material (or, if the container changes, that every hosted panel
   still mounts — `BookRedesignMountTests` is the shape).
2. **Row 3 — the rail's spacing and the Open strip.** Compare the rail's row spacing/padding against the
   pre-Act-10 file (`git show 0e6a09e^:App/Variorum/Variorum/Features/Library/SidebarView.swift`) and
   restore generous spacing at ordinary heights; compress ONLY under a measured height threshold (the
   bottom-bar precedent: a pure decision function, pinned red-on-old at the threshold). Move the Open
   strip back to directly UNDER the rail ("the tabs used to be right below the modes") — it keeps its
   Act 10 mechanics (scroll past ~7, newcomer never hidden, ⌘⇧1–9, drag reorder, the 20-tab auto-close);
   the sidebar's bottom keeps the protection/sync/bridge lines. Pins: the existing Open-strip pins ride
   unmodified; one new pin on the threshold function.
3. **Rows 4 + 19 — the masthead title centered in EVERY mode.** Mechanism (walk-confirmed in both voices):
   the title sits in an HStack where the trailing cluster (tray/scraps/references icons + the tag row)
   takes its natural width and the title centers in the REMAINDER — so it lands ~⅓ across. Fix: the title
   block centers on the full content width (overlay/ZStack), the clusters lead/trail; the subtitle path
   (`~/book`) rides with it. One layout for all seven/eight modes and the book. Pin: the title's midX equals
   the content's midX within 1 pt, parameterized over every mode (mount + geometry read).
4. **Row 15 — ONE tag door.** Today: `+ tag` (opens a popover field — good) AND `#` (folds the chips to
   `# N`, K12's sticky fold) side by side. Deliver hers: the `#` glyph is THE door — click → the tag field
   slides out inline beside the chips with the cursor active (reuse the popover's field brain: ⏎ applies,
   `/` nests, suggestions); `+ tag` retires; the masthead FOLD retires (K12's fold served the crowded nav
   bar — record the supersession in the record and at the K12 site's comment). Chips stay visible. ⌘⇧I
   (the fold's key) is re-pointed to open the field, or retired — say which. Pin: exactly one tag door
   renders in the masthead; the field receives focus on open.
5. **Rows 10 + 11 — library row alignment.** The chips and the `book` kind label sit low against the title
   although the HStacks already align on `.firstTextBaseline` — trace the actual cause (chip vertical
   padding vs. its baseline, the smaller label's baseline offset, an `Image` in the HStack) and fix it so
   title, chips, `+`, and kind label sit on one visual line. Pin: a geometry read of the row (title
   baseline vs chip baseline within 1 pt).
6. **Row 36 — the word-count sweep table (C-6).** Enumerate EVERY word-count/metric display in the eight
   Act 10 views (Snippets 10 · Read 6 · Blocks 4 · Index 4 · BookView 4 · LibraryInfoPanel 4 · Compare 2 ·
   BookIndex 1 — `grep -n -i 'words\|[0-9]w\b'`) into a table in your record: file:line · what it says ·
   KEEP (with the reader's reason) or DROP. **Fix the ones on YOUR surface** (the masthead/sidebar/library
   rows if any); the rest are dispositions for their batches (C/D/E/F read your table). Bias: a count
   stays where the pre-Act-10 surface had one or where the mockup grammar shows one; "thrown in" goes.
7. **Row 24 (the sidebar half only) — the "this note" rail fades.** The rail appears/disappears whole on
   note↔library today. Make its arrival/departure a short fade/height animation (nothing added on the
   left — R-cor-3); the library-panel half of row 24 is batch E's.

**Rules that bind you (from §2b):** one surface — if a fix pulls you into the book, the note modes,
Compare, or the library PANEL, stop and record it for B/C/D/E. Bug-class rows land with red-on-old pins
verified by BEHAVIORAL REVERT; geometry pins are pins. `TutorialWalkTests` green at the end (the field
guide's "getting around" lesson names the sidebar — if your change alters what the lesson describes, say so;
copy changes are the closeout's). **The acceptance gate is USE (C-2):** walk every row on the dev-store
Debug build in BOTH voices (Settings ▸ Appearance switches the voice) with a capture per row into
`notes/plans/act10-correction-screens/batch-a/` — the flat sidebar · the rail spacing at a tall window and
at a short one · the Open strip under the rail · the title centered in Write, Takes, Read, Lenses, Compare,
Blocks, Canvas and the book · the one tag door open with the cursor in it · a library row's alignment
close-up · the rail fading. Name each capture in your record.

**Environment + driving recipe + resiliency: exactly batch B's brief's last three paragraphs (read them
there; they bind identically).** Baseline counts: batch B's record states the tree's counts at its close —
yours are those + your pins; state the arithmetic.

**Your deliverable:** the code + pins, and a **BATCH A RECORD** appended under this brief: per row →
FIXED (pin, red-on-old evidence) / RECORDED / DEFERRED (owner + why); the container decision; the row-36
table; the capture list; counts; commits in order; new findings as ledger rows numbered after batch B's
last. Then stop.

---

### BATCH A RECORD — THE CHROME (a fresh Fable implementer session, 2026-09-01 ~08:10 →)

#### LIVE STATUS — BATCH A (flipped in the same commit as each piece; a fresh session finishes from this list alone)

- **Orientation:** DONE — the brief's files read in the brief's order; the mockup's sidebar/masthead CSS read
  (the browser render was blocked: the Chrome extension is not connected and `file://` is refused — the
  grammar was read from the source instead: `.sidebar` = flat `room` column, `1px line` right border,
  `14px 0 12px` padding; `.sb-group` 12 px side padding, 20 px between groups; `.sb-row` 5×8 px padding,
  radius 6, gap 6; `.sb-head` 10.5 px faint; `.sb-sep` a 1 px line with 20 px side margins).
  **Measured on the running dev build (AX tree, text-before-pixels):** the sidebar column sits at
  x = 8 (the floating pane's inset), its rows are 32 pt List rows — BOTH the five areas AND the eight-mode
  rail (identical pitch; the rail's code is byte-identical to the pre-Act-10 file) — while the Open strip's
  rows are ~21 pt (`openRow`: 4 pt padding, min 19, spacing 1). So "the tab spacing has gotten less
  generous… more compressed" is the OPEN STRIP (her "tabs" = the open notes, her own browser-tabs word),
  whose rows left the List's 32 pt pitch for the bottom rail's 21 — not the rail's rows. Recorded here
  before any code moved.
- **Row 2 (the container):** DONE (`b22b6ff`) — `ShellSplit`
  (`Workspace/ShellSplit.swift`: an HStack, ONE 1 pt `line` divider with the pane row's drag grammar,
  `@AppStorage` width 180–360, a collapse that animates) replaces `NavigationSplitView` in `RootView`;
  the sidebar toggle is a DECLARED act (`.toggleSidebar` — the leading toolbar button + View ▸ Toggle
  Sidebar on the platform's own ⌃⌘S, per-window state `ShellRouter.sidebarShown`, grey while a note-only
  window is key; the ⌘/ helper lists it); the status rows moved from the split view's `safeAreaInset` to the
  column's own bottom. **Verified in use on the relaunched dev build (probe captures):** the column is flush
  at x = 0 with one divider; the tray inspector opens as a column INSIDE the detail; ⌃⌘S collapses and
  restores. Pin `ShellChromeTests.theShellMountsFlatAndTheStripRowsAreGenerous` (zero `NSSplitView` under
  the hosting view at rest — the split view's AppKit backing) GREEN. **Red-on-old VERIFIED by behavioral revert** (`ShellSplit.body`
  wrapped back in a `NavigationSplitView`, the column's rows forced to the old 21 pt; run from the committed
  state `b22b6ff`): **2 issues in 1 test** — `countSplitViews → 1` and `drawn → 21.0 == 30.0`; restored by
  `git checkout --`, `git diff --stat` empty.
- **Row 3 (the rail + the Open strip):** DONE (`b22b6ff`) — the sidebar's `List` retired for the
  mockup's flat column (`SidebarView`: groups · `.sb-head` headers · `.sb-row` rows at ONE pitch · `.sb-sep`
  separators); the Open strip sits DIRECTLY UNDER the rail again with every Act 10 mechanic (all open notes
  shown, the section scrolls in place past 7 with the newcomer revealed, ⌘⇧1–9 badges, ✕, drag reorder, the
  model's 20 cap); `SidebarLayout` (pure) decides the pitch — generous 30 pt at ordinary heights, compact 24
  ONLY when the generous layout would not fit the measured column (never at height 0); one navigation
  register `VoiceTokens.navigation` (13 pt mono in Terminal, 13 pt system in Study) for every row.
  **Measured after (AX tree):** areas · rail · strip rows all 30 pt; the strip's row directly under the rail.
  Pins `SidebarLayoutTests` ×5 (the threshold both ways, few rows never compress, unmeasured never
  compresses, the 7½-row window) + the oracle half of the shell pin (the strip's DRAWN row = 30) — red-on-old
  the second issue above (21.0). Recorded honestly: the List's arrow-key row navigation is gone with it.
- **Row 24 (the rail's fade — the sidebar half):** DONE (`b22b6ff`) — the rail group carries
  `.transition(.opacity)` under `.animation(.easeInOut(0.22), value: railPostID)`, so it fades in/out and the
  Open group slides rather than snaps; nothing added on the left (R-cor-3). Walk capture PENDING.
- **Rows 4 + 19 (the masthead):** DONE (`74c72db`) — `PostDetailView`'s masthead is a ZStack:
  the title block (title + the `~/book` chip) CENTERS on the masthead's full width, padded on both sides by
  the trailing cluster's MEASURED width so it can never run under the icons; the cluster (mode menu ·
  tray/scraps/references · the tag cluster) trails on its own layer; `PostTitleLabel` centers in its measure
  (the rename field too). One layout for every mode. Pin `MastheadLayoutTests.theTitleBlockCentersOnTheMastheadInEveryMode`
  — the real detail mounted, switched through all eight modes by the router, the DEBUG oracle
  (`MastheadGeometry`: the title TEXT's own midX vs the masthead's midX, in the masthead's coordinate space)
  within 1 pt in each — GREEN. **Red-on-old VERIFIED by behavioral revert** (the title layer put back to
  the old leading shape, run from `74c72db`): **8 issues in 1 test — 246.0 pt off in every one of the eight
  modes**; restored by `git checkout --`, diff empty.
  **The book's masthead is NOT touched:** its title lives in the navigator COLUMN's header (`BookView.
  bookMasthead`), a left column by design — the book's surface is batch B's (C-1); recorded for the
  orchestrator.
- **Row 15 (one tag door):** DONE (this commit; hash next) — `MastheadTagCluster` rebuilt: the ＃ is THE
  door; click → `TagInlineField` slides out INLINE beside the cards with the cursor in it (⏎ applies through
  the standing `applyTypedPath`, `/` nests, the live taxonomy's matches hang under it, ⎋ or a second ＃ puts it
  away; the field stays out after an apply so several tags go on in one breath); "＋ tag" RETIRED; **the
  masthead FOLD RETIRED — K12 SUPERSEDED for the masthead** (recorded at the site, `ContextBarDoors.swift`,
  and here: the fold served the crowded context bar; the cards stay visible). **⌘⇧I RE-POINTED, not
  retired:** `.tagNote` carries the chord + View-menu + ⌘K doors (note-scoped — honestly grey with no note),
  routed to the mounted masthead through a new `CommandRouter.registerDetail(openTagField:)` /
  `requestTagField()` seam (the tray's pattern, P-4); `.toggleTagChips`, `TagChipsFold`, `tagsDoorCount`,
  `tagsFoldHelp`, `tagChipsVerb`, `ShellRouter.toggleTagChips` all gone; the ⌘/ helper's two sentences
  updated. Pins `MastheadTagDoorTests` ×2 (one declared act, no ＋ on the cards — `chipsShowAddDoor`; the field
  absent at rest, present AND first responder when opened); `BookAscentTests.theFoldIsOneDeclaredActWithOneKey`
  re-pointed at `.tagNote` (a JUSTIFIED PIN EDIT); the fold's two pins in `ContextBarShapeTests` RETIRED with a
  note. Red-on-old by construction (the pre-round cluster had no inline field and declared two acts; the
  fold's own pins were green on the old tree and are gone). **Tutorial text now behind the door:** the seeder's
  "the workspace" lesson still says "＃ folds the note's tag cards away and back (⌘⇧I too…)" — the closeout's
  copy change + re-seed (obligation 8); untouched here by the brief's rule.
- **Rows 10 + 11 (library rows):** DONE (`5a0249c`) — TWO mechanisms, both baseline: **(11)**
  the book row's HStack had NO alignment (default `.center`), so the small "book" label centered against the
  body-size title and its baseline sat below the title's; **(10)** the note row DID align on
  `.firstTextBaseline`, but the chips handed the stack a SYMBOL IMAGE's bottom edge as their baseline — each
  chip was a `.center` HStack of a Text and a bare `Image(xmark)`, and the first-baseline guide of that stack
  resolved to the image — so the chip text landed ~2 pt under the title's line, and the ＋ rode with it. Fix:
  the two List-mode row LINES extracted as views (`CatalogBookLine` · `CatalogNoteLine`, in
  `LibraryCatalogView.swift`) aligned on `.firstTextBaseline` end to end; the book icon and the chip's ✕ are
  `Text(Image(systemName:))` (a Text carries a real baseline); `NoteTagChips`' stacks align on the baseline
  too (every renderer of the chips inherits it — the note cards, the Pool, the masthead). Pins
  `LibraryRowAlignmentTests` ×2 — the lines mounted in a window, the DEBUG `BaselineProbe` oracle
  (`Core/Views/BaselineProbe.swift`: `alignmentGuide` offset + the top in the line's named space) read for the
  title vs the first chip's text vs the ＋, and the title vs the kind label, within 1 pt, in BOTH voices —
  GREEN. **Red-on-old VERIFIED by behavioral revert** (the old shapes put back in place — the book line's
  bare HStack + `Image`, the chips' `.center` stacks + bare `Image` ✕ — run from `5a0249c`): **5 issues in 2
  tests** — the chip text and the ＋ each **1.5 pt** off the title in BOTH voices (4), and the book row's title
  never reported a baseline at all (the unaligned HStack never asked for one — 1); restored by
  `git checkout --`, diff empty.
- **Row 36 (the sweep table):** DONE (this commit) — the table is in the "Row 36" section of this record
  below; NOTHING on the chrome surface carried a count to drop (the masthead, the sidebar and the library rows
  show no word count — the rows' `detail` is a date or the kind word); the rest are dispositions for C / E.
- **The USE gate:** DONE (this commit — the sheet's read is the next line's) — both voices walked on the
  dev-store Debug build (window zoomed 1728×1084): 28 captures in `act10-correction-screens/batch-a/`, the
  contact sheet `batch-a/contact-sheet.png` (28 tiles). The walk caught row 55 twice (the first cut's field
  squeezed the title; the second cut's floor still truncated at three chips) — the masthead is two rows now;
  the final captures show five chips + the open field with the title intact in both voices. The short window
  MEASURED compact (AX: every row 24 pt at a 454 pt column with the rail open; 30 pt generous otherwise).
- **Full Mac suite + TutorialWalkTests:** DONE — **Mac 2010 tests / 351 suites, all green** on the final tree
  (`** TEST SUCCEEDED **`, 303 s; log `test-a-full2.log` in the session scratchpad; the ten tutorial suites
  inside it green; the load-flaky `rewriteStrategyLatencies` (2 cases) and `CanvasDragTrackingTests` passed
  in-run — nothing re-run, nothing loosened). **Arithmetic against batch B's close 2001 / 347:** +13 tests
  (`ShellChromeTests` 3 · `SidebarLayoutTests` 5 · `MastheadLayoutTests` 1 · `MastheadTagDoorTests` 2 ·
  `LibraryRowAlignmentTests` 2) − 4 retired with the fold (`theTagsDoorCarriesTheCountOnlyWhenFolded` +
  `TagChipsFoldTests` ×3) = **+9 ⇒ 2010**, exact; suites +5 new − 1 retired (`TagChipsFoldTests`) = **+4 ⇒
  351**, exact. The first full run on the pre-final tree read 2010/351 with 4 issues in TWO pins whose
  expectations described what this batch changed — `NoteTagDeclarationTests` (`.tagNote`'s surface-only
  declaration) and `NoteVersionsPaneTests`' `s`-chord count (⌃⌘S is a third) — both JUSTIFIED PIN EDITS,
  line by line at the pins; the full suite was then run AGAIN on the final tree: the count above. **Core
  1524 / 165 untouched** (zero `Sources/VariorumCore` lines in the batch). **`Shared/` touched once:**
  `VoiceTokens.navigation` (a new font slot, all four voices filled) — the mobile target compiles the same
  file; its suite was not run here (not this batch's), flagged for the orchestrator.
- **STATUS: BATCH A's build is COMPLETE — the record awaits the orchestrator's hands-on walk (C-2) before it
  is marked closed.** The dev-store Debug build (the final tree's product, `Variorum-dnpxwqhpxdqrdjbunktnzoahckpd`)
  is left RUNNING for that walk — Terminal voice, "three ways of working" open, window zoomed; `/Applications`
  untouched; her real-store app untouched. Tree clean; every commit pushed.
- **No revert in flight** (the row-2/3 revert ran and was restored — evidence above; tree clean against
  `b22b6ff`).

#### The container decision (row 2) — stated, with its reason

`NavigationSplitView` → **a custom split, `ShellSplit`** (`App/Variorum/Variorum/Workspace/ShellSplit.swift`).
Reason: Tahoe's floating glass sidebar IS the split view's rendering of its sidebar column in a key window,
and NO public opt-out exists — searched at the SDK, not assumed: the macOS 26 SwiftUI interface declares
`NavigationSplitViewStyle` in three forms only (`automatic` · `balanced` · `prominentDetail`), none flat;
AppKit's `NSSplitViewItem` gained only `automaticallyAdjustsSafeAreaInsets` and the accessory view
controllers at 26.0 (`NSSplitViewController` nothing); and the 13g measurement already recorded in
`VariorumApp.swift` had shown the floating card is the KEY-window appearance, not a window style. So the
container is ours: an `HStack` — the flat sidebar column, ONE 1 pt divider in the voice's `line` carrying the
pane row's own drag grammar (`RootView.paneDivider`), the detail — with `@AppStorage` width memory
(180–360, ideal 210) and an animated collapse. What it keeps: every panel `RootView` hosts beside the sidebar
(the pane row + its inspectors — scraps, references, the tray, Block History, Versions, the Library's info
panel — all live INSIDE the detail; the tray was opened in the walk and rendered as a column inside the
detail, within the window); the sidebar's collapse (now a DECLARED act, `.toggleSidebar`: the leading toolbar
button + View ▸ Toggle Sidebar on ⌃⌘S — the platform's chord, swept free — per-window state
`ShellRouter.sidebarShown`, grey while a note-only window is key, a row in the ⌘/ helper); the bottom
status rows (the column's own last region). What it costs, stated: the sidebar List's arrow-key row
navigation (row 57).

#### Per-row dispositions

| Row | Disposition | Pin | Red-on-old |
|---|---|---|---|
| 2 | FIXED — `ShellSplit`; the glass pane gone (flush column, one divider) | `ShellChromeTests.theShellMountsFlatAndTheStripRowsAreGenerous` (zero `NSSplitView` at rest) · `.theSidebarWidthIsClampedToAUsableColumn` · `.theSidebarToggleIsDeclaredOnItsTwoDoors` | 1 issue (`countSplitViews → 1`) under the `NavigationSplitView` revert |
| 3 | FIXED — the flat column (the mockup's grammar), the Open strip DIRECTLY under the rail, ONE generous 30 pt pitch, compact 24 only when the measured column cannot hold the generous layout | `SidebarLayoutTests` ×5 · the shell pin's oracle half (the DRAWN strip row = 30) | 1 issue (`drawn → 21.0`) under the 21 pt revert; the threshold pins by construction (the function did not exist) |
| 4 · 19 | FIXED — the title centered on the masthead's full width, every mode; two rows (title ⟂ icon row, path ⟂ tag cards) | `MastheadLayoutTests.theTitleBlockCentersOnTheMastheadInEveryMode` (eight modes via the router; the DEBUG oracle on the title TEXT) | 8 issues (246 pt off in every mode) under the leading-title revert |
| 15 | FIXED — ONE door (＃) → the inline field with the cursor in it; "＋ tag" and the K12 fold retired (K12 superseded for the masthead); ⌘⇧I RE-POINTED at `.tagNote` | `MastheadTagDoorTests` ×2 · `BookAscentTests.theFoldIsOneDeclaredActWithOneKey` (re-pointed) | by construction (no inline field existed; two acts were declared; the fold's own pins retired with a note) |
| 10 · 11 | FIXED — the Library rows on ONE text baseline (`CatalogBookLine` · `CatalogNoteLine`; symbols as `Text(Image)`; the chips' stacks on the baseline) | `LibraryRowAlignmentTests` ×2 (both voices, the DEBUG `BaselineProbe`) | 5 issues (1.5 pt off ×4; the book title never reported) under the old-shapes revert |
| 36 | DONE — the sweep table (this record); nothing on the chrome surface carried a count | — | — |
| 24 (sidebar half) | FIXED — the rail fades in/out (`.transition(.opacity)` under a 0.22 s animation; the Open group slides) | — (no pin: an animation; capture `03-terminal-rail-fade-mid`) | — |
| **55** (new — the walk) | FIXED in-batch — the open field squeezed the title; the field is an overlay, the masthead two rows | the masthead + tag-door pins green after | (the walk's own capture, twice) |
| **56** (new — seen in the walk's probe capture, NOT the chrome) | RECORDED for **batch E** — the Library's List-mode row selection is the SYSTEM blue highlight band (a row clicked once wears a full-width blue selection), against the calm grammar (W8-2: selection is the wash + a tinted border, never a system highlight); the row click model is E's (R-cor-3) | — | — |
| **57** (new — a cost of row 2, stated) | RECORDED for the orchestrator (owner: **13u2**, the feel-and-faces half, if she wants it back) — the sidebar List's arrow-key row navigation is gone with the List; the flat column's rows are buttons/taps. A `focusable` column with ↑/↓ handling restores it as a small batch; not built here (no ruling asked for it, and the List's keyboard focus was never a door she named) | — | — |

#### The USE gate — the walk (the dev-store Debug build, window zoomed 1728×1084, BOTH voices; `act10-correction-screens/batch-a/`, contact sheet **`batch-a/contact-sheet.png`** — 28 tiles)

| Row | What was done | Capture(s) |
|---|---|---|
| 2 | The shelf at launch: the column flush at x = 0, one divider, no glass — Terminal and Study | `01-terminal-shelf-flat-sidebar` · `26-study-shelf-flat-sidebar` |
| 2 | ⌃⌘S collapses the column (the detail takes the width) and restores it | `15-terminal-sidebar-collapsed` · `15b-terminal-sidebar-restored` |
| 3 | A note open: areas · "this note" rail · the Open strip DIRECTLY under it, every row 30 pt (AX-measured) | `02-terminal-note-write-masthead-rail-strip` · `21-study-note-write-masthead-rail-strip` |
| 3 | The SHORT window (600 pt; a 454 pt column, the rail open): every row 24 pt (AX-measured `186x24`), the strip still under the rail | `14-terminal-short-window-compact-rail` · `27-study-short-window-compact-rail` |
| 24 | Leaving the note for the Library: the rail mid-fade, then gone with the Open group slid up | `03-terminal-rail-fade-mid` · `03b-terminal-library-after-fade` |
| 4 · 19 | The title centered in Write · Takes · Index · Read · Lenses · Compare · Blocks · Canvas (Terminal) and Write · Read · Lenses (Study) | `02` · `04-…-takes` · `05-…-index` · `06-…-read` · `07-…-lenses` · `08-…-compare` · `09-…-blocks` · `10-…-canvas` · `21` · `22-study-masthead-read` · `23-study-masthead-lenses` |
| 15 | The ＃ clicked → the field out with the cursor in it; typed; ⏎ applies (the chip lands, the field stays); ⎋ closes — with five cards, the title intact | `11-terminal-tag-field-open` · `11b-…-typed` · `12-…-applied-field-stays` · `12b-…-closed` · `24-study-tag-field-open` · `24b-…-typed` |
| 10 · 11 | The Library rows' close-up (2× crop): "book" on the title's baseline; the chips and ＋ on the note's | `13-terminal-library-rows-closeup` · `25b-study-library-rows-closeup` |
| (the book) | Sherlock's Outline on the new shell — the book's masthead is its navigator column's header (B's surface; unchanged) | `16-terminal-book-outline` |

Honesty notes: the dev store now carries the walk's test tags on "three ways of working" (`walked · again · once · final · study` — applied through the real door, left as evidence of the many-chips case); the rail's fade is judged from one mid-frame capture (a 0.22 s animation cannot be pinned); the tray inspector was exercised in the probe pass (scratchpad captures, not in the sheet) — it renders as a column inside the detail.

#### Commits (in order)

1. `f82ff80` — the record skeleton + LIVE STATUS (the sidebar's pitch measured; the container decision).
2. `b22b6ff` — rows 2 + 3 + 24: `ShellSplit`, the flat column, the strip under the rail, `SidebarLayout`, `VoiceTokens.navigation`, the rail's fade; pins.
3. `70b6023` — rows 2/3 red-on-old evidence.
4. `74c72db` — rows 4 + 19: the centered masthead; `MastheadLayoutTests`.
5. `310c522` — rows 4/19 red-on-old evidence.
6. `3bc142f` — row 15: one tag door, the inline field, the fold retired, ⌘⇧I re-pointed; pins.
7. `5a0249c` — rows 10 + 11: the baseline-aligned Library rows; `BaselineProbe`; `LibraryRowAlignmentTests`.
8. `418b8b4` — rows 10/11 red-on-old evidence + the row-36 table.
9. `7ffa80d` — row 55 (the walk): the field as an overlay, the title floor.
10. `512822c` — row 55's second cut: the two-row masthead; the walk's captures + sheet; the record.
11. `45b8545` — the two justified pin edits (`NoteTagDeclarationTests`, `NoteVersionsPaneTests`), the full suite re-run on the final tree (2010 / 351), the record's dispositions, the container decision, the walk table, rows 56/57, the LIVE STATUS final.
12. (this commit) — this list's hash filled.

#### Row 36 — the word-count / metric sweep (C-6; R-cor-4(d)) — every display in the eight Act 10 views, grep-enumerated (`words\|[0-9]w\b\|wordCount`), verdicted against the brief's bias (a count stays where the pre-Act-10 surface had one or where the mockup grammar shows one; "thrown in" goes)

| file:line | what it says | verdict | reason | who applies |
|---|---|---|---|---|
| `SnippetsSurface.swift:173` (via `SnippetsCopy.words` :76) | a snippet row's facts: `⑂ N takes · N words · edited …` | KEEP | the mockup's snippet `.met` line shows exactly this (`⑂ 3 takes · 18 words`, mockup :992) — W8-4's ruled row | — (as is) |
| `SnippetsSurface.swift:147` | sort by word count | KEEP (not a display) | a sort key, not chrome | — |
| `ReadModeView.swift:302` (via :216) | the page header: `N words · about M minute(s)` | KEEP | her word (R-cor-4(e): stays in Read); the Read mockup's kicker shows it (:859) | C (the `read` half) |
| `ReadModeView.swift:254–255` | the FOOTER: `N blocks · N words · about M min` | DROP | the same facts twice on one page — the header already says them; the mockup's Read shows one line, not a footer duplicate | C |
| `BlocksWorkbenchView.swift:258` | the workbench toolrow: `N blocks · N words` | KEEP | the mockup's Blocks toolrow shows it verbatim (:969); the poweruser center's one anchor | — |
| `BlocksWorkbenchView.swift:419` | per-row `Nw` | KEEP | the mockup's every `.met` row carries `N words` (:1002–:1052); the words SORT (:135) needs its evidence on the row | — |
| `BlocksWorkbenchView.swift:652` | the context panel's `words` fact row | KEEP | the block's facts sheet; a full fact beside the row's abbreviation (C-6's stated reason: the panel is where the whole fact is read) | C may fold it if the panel's order pass (row 26) finds it redundant |
| `IndexModeView.swift:484` | the footer: `N blocks · N words` | KEEP-ONE | the Index mockup shows it (:762); but the Index tab RETIRES into Read's `edit` half (R-cor-7) — the merged tab keeps exactly ONE count line (the mockup's), never the `read` header plus this footer | C |
| `BookView` (batch B's four — verdicted in B's record) | card `Nw` · gutter `⑂ takes on N blocks` · `bookMetaLine` · the side card's counts | DROP · KEEP · KEEP · DROP/KEEP | B's record; unchanged here | done (B) |
| `CommitBar.swift:228–232` (the side card) / `:549–556` (the flat bar) | `Nw in note` word-target door · `Nw block · Nw selected` | KEEP | pre-Act-10 (R11's bottom-bar idiom, the word-target door's face) — not Act 10's | — |
| `LibraryInfoPanel.swift:189` | the facts card's `words` row | KEEP | R-cor-3 asks for "a calm facts line (words · blocks · last edited)" — E rebuilds the panel WITH it | E |
| `CompareBoardView.swift` | — | none found | the brief's "Compare 2" are the takes bottom bar's `Nw note` (`TakesBottomBar.swift:442–466`, pre-Act-10 R11) | — |
| `BookIndexView.swift:352` | per-chapter NOTE counts (`welcome 3`) | KEEP | a structural count (how many notes a chapter holds — the navigator's shape), not a word count | — |
| the chrome (masthead · sidebar · library rows) | — | none | no count to drop; the mockup's `pool 59` sidebar badge is NOT built and is not added (C-6) | A ✓ |

---


#### ORCHESTRATOR'S WALK OF BATCH A (2026-09-01 ~09:45; token-disciplined: A's contact sheet + two live captures with masthead crops, `orchestrator-a/`)

- **Right on the fresh build (pid 77509):** the sidebar is a flat column flush at x = 0 with one divider (the glass pane gone — W8-3 delivered whole); the rail generous; the Open strip directly under the rail; the title centered over the content in Write; the bottom bar one row; the `#` door slides out an inline field with the cursor (row 15). The sheet's 28 tiles show the title centered in all eight modes in both voices, the library rows aligned, the compact rail in a short window, the fade mid-frame.
- **RESIDUAL — row 58 (MAJOR):** the masthead's second row collides (the path chip under the tag cards; hidden under the open field). A is REOPENED for it (a fresh fix session); its record stays un-closed until the fix is walked.
- Row 57 (the sidebar List's arrow-key navigation gone with the flat column): left RECORDED with owner 13u2 as A dispositioned it — she did not ask for it and the flat column is her W8-3 ruling; the ladder may weigh it; noted in §7 for her.

#### ROW 58 FIX — the masthead's second row (a fresh Fable fix session, 2026-09-01 ~09:30 →)

**LIVE STATUS — ROW 58: FIXED — pins green, red-on-old verified (10 issues), walked in BOTH voices on the dev-store Debug build, full Mac suite 2014 / 352 green (exact). No revert in flight; tree clean; every commit pushed. The dev-store Debug build (pid 81367, the shipped tree's product) is left RUNNING for the orchestrator's walk — Terminal voice, "three ways of working" open, window zoomed; `/Applications` untouched; her real-store app untouched (not running). NEXT (the orchestrator): walk row 58 on that build (the five-tag note closed/open in both voices; the ⌘N note; the sheet `batch-a/contact-sheet-r58.png`) and close batch A's record — this session does not close it.**

- **The traced mechanism (verified at the code and by arithmetic against the crop):** the orchestrator's stated cause — "the centering padding measures the FIRST trailing row" — describes `74c72db`'s shape. On the current tree (`512822c`, the two-row masthead) the path row DOES inset by the cards' row's measured width — but `mastheadInset(for:)` caps that inset at `(mastheadWidth − 240) / 2 = 220` pt: the 240-pt floor row 55 added so the TITLE never shrinks, applied to the path row too. Past ~208 pt of cards the inset stops growing, the chip stays centered on the full width (midX 340; `~/the field guide` ≈ 125 pt wide → `[278, 403]`) while five cards + the ＃ occupy `[321, 680]` → the chip is under the first two cards (the crop's exact picture: masthead block at x 630–1310 in the 1728-pt window, chip centered at ~965, cards from ~951). With the field open the overlay extends the cluster 196 pt further left (`[125, 315]`) and row 55 faded the chip to opacity 0 instead of moving it — hidden, its frame still colliding. So row 2's two layers were laid out unaware of each other, exactly as the row says; the cap was the mechanism.
- **Red-on-old VERIFIED by behavioral revert** (the row-2 layout put back IN PLACE to `512822c`'s ZStack — the chip centered behind the capped inset, the cluster trailing on its own layer, the opacity yield — with the oracle wiring kept; run from the committed state `7dee4c7`, log `r58-pin-red.log` in the session scratchpad): **10 issues in the 2 new pins** — Terminal (6): the chip `(489.5, 37.0, 121×14)` intersects the cards at `x 525` and `x 590` (the gap reads −85.5 and −20.5 against the required 16) and the open field `(335, 36, 190×19)` covers it (gap −275.5); Study (4): the chip `(504.25, 43.0, 91.5×14)` intersects the card at `x 568.5` (−27.25) and the field `(378.5, 42, 190×19)` (−217.25). The rows-4/19 centering pin stayed green under the revert (the title row was not reverted). Restored by `git checkout -- App/Variorum/Variorum/Features/Takes/PostDetailView.swift`; `git diff --stat` empty. Green on the fix: `MastheadLayoutTests` ×3 · `MastheadTagDoorTests` ×2 · `LibraryRowAlignmentTests` ×2 — 7 / 3 (log `r58-pins-1.log`).
- **THE FIX AS SHIPPED (the masthead's files only — C-1; plus one new shared-home component):** row 2 of the masthead is ONE `HStack(alignment: .firstTextBaseline, spacing: 16)`: the **path chip LEADS** at the masthead's leading edge — the article's left margin, where the mockup's `.where` line sits under its `h1` — at its own width (`fixedSize` + `layoutPriority(1)`; never compressed); the **tag cluster TRAILS** as `TrailingFlow` (`Core/Views/TrailingFlow.swift`, new — a right-aligned wrapping `Layout`): the cards then the ＃ fill from the right edge and wrap onto further lines when the width that remains says so, items on a line aligned on their first text baseline, the flow reporting its first line's baseline upward so the chip sits on the cards' line. **Every line keeps `TagInlineField.width + 6 = 196` pt free at its LEFT** — the room the field slides out into, whichever line holds the ＃, reserved open or closed so opening the field never moves a card, the chip, or the title (row 55's promise kept a different way); the field hangs off a zero-width anchor item the flow parks at the last line's leading edge. **The ＃ never starts a line alone** (`keepsWithPrevious` — the first walk on the fixed row showed five cards filling a line exactly and the door orphaned below; the last card now comes down with it). Row 55's opacity-yield of the chip is RETIRED with the collision it hid: the chip stays in view while a tag goes on. `MastheadTagCluster` renders `TagChipCard`s directly (the one card extracted from `NoteTagChips`, which now renders the same view — every renderer still inherits rows 10/11's baseline stack; `LibraryRowAlignmentTests` green unmodified); its new `geometryProbeSpace` is the DEBUG oracle's space (nil for the door pin's standalone host — the door pin rides unmodified). `mastheadChipRowWidth` and the path row's inset are gone; the title row is byte-unchanged (inset by the icon row only).
  - **Why the chip LEADS rather than centers-when-room (the brief offered both):** a chip centered on a bare note and shoved left by its third tag is a jump triggered by tagging and an inconsistency across notes; the leading chip is the same on every note, gives the cluster ~540 pt, and reads as the classic masthead — headline centered, dateline left, tags right — in both voices.
  - **The brief's "the title's centering padding takes the WIDER of the trailing rows" — honored in intent, not in letter, and here is why:** under this design nothing on row 2 centers, so only the title needs a centering inset, and the only thing that shares the TITLE's line is the icon row. Insetting the title by the cards' row (the wider one) is exactly what row 55's second cut found truncating the title to "worki…" at the 240-pt floor — so the title row keeps insetting by the icon row alone, and the pin holds the title centered within 1 pt WITH five tags, field closed and open, in both voices. The cards can never reach the title's line: they are a different row.
  - **Twin recorded (the forked-brains class, for the orchestrator):** `TrailingFlow.rows(widths:available:spacing:)` is byte-compatible with the phone's `MobileChipFlow.rows` (leading-aligned there, trailing here; the phone's file is the mobile target's and outside this batch's fence). The Shared/ hoist is a MOVE at the next touch of either — a candidate line for the KnownIssues forked-brains row's "remaining" list, the orchestrator's call. `BlocksWorkbenchView`'s private `FlowLayoutLite` (leading, no baseline alignment) is the same class one surface over — batch C's file (C-1), noted for C to adopt `TrailingFlow` or hoist at its touch.
  - **Widths, stated:** at the 680-pt measure with `~/the field guide` (≈125 pt) the flow's first line holds ≈343 pt of cards (four in Terminal's mono, five in Study's proportional face); a line per ~4 cards thereafter. In a detail narrower than chip + gap + field (≈340 pt) the reserve cannot be honored and the open field would cross the chip — below any width the split allows; recorded, not pinned.

- **Pins (green on the fix — 9 / 4 with the two masthead suites and the row-alignment pin, log `r58-pins-2.log`):** `MastheadLayoutTests.thePathChipAndTheTagClusterNeverIntersectInTerminal` · `…InStudy` — the real detail mounted with a titled note in a book and FIVE tags; the DEBUG `MastheadGeometry` oracle (extended: `pathChipFrame` · `cardFrames` by tag id · `fieldFrame`, all in the masthead's own space; `resetRowTwo()` before the mount) read for: no card intersects the chip · every card sits right of the chip by ≥ 16 · every card inside the masthead · the title centered within 1 pt; then ⌘⇧I's road (`commandRouter.requestTagField()`) opens the field: the field intersects neither the chip nor a card, sits right of the chip by ≥ 16, the chip did not move, the title still centered. `TrailingFlowRowsTests` ×2 — the pure row rule (greedy fill, over-wide item on its own line, nothing dropped) and the orphan rule (the door pulls the last card down; a line is never emptied; no-op without a marked item) — door class (the rules did not exist). **Red-on-old:** the 10 issues above.

- **The USE gate — the walk** (the dev-store Debug build relaunched on the fixed tree twice — pid 80927 the first cut, 81367 the shipped one; window zoomed 1728×1084; BOTH voices; every capture in `act10-correction-screens/batch-a/` as `r58-…`; **contact sheet `batch-a/contact-sheet-r58.png`** (the r58 captures alone — read this one) and `batch-a/contact-sheet.png` refreshed with them):

  | What | Capture(s) |
  |---|---|
  | Terminal · five tags · field closed: the chip leads at the left, four cards on line 1, `walked × #` on line 2, the title centered — nothing touches | `r58-01-terminal-5tags-closed` (the first cut's orphaned ＃ was seen on this same name before the refinement and re-shot) |
  | Terminal · the ＃ clicked → the field out on the ＃'s line, left of `walked`, clear of the chip; typed; ⏎ applies (the card lands, the field stays, nothing else moves) | `r58-02-terminal-5tags-field-open` · `r58-02b-terminal-field-typed` · `r58-03-terminal-6tags-applied-field-stays` |
  | Terminal · SEVEN tags with the field open, then closed: two lines, the door beside a card, the field beside the second line | `r58-03b-terminal-7tags-field-open` · `r58-04-terminal-7tags-closed` |
  | Terminal · the cards' × door: the two walk tags taken off one at a time, the flow re-laid each time, back to five | `r58-05-terminal-x-removed-one` · `r58-06-terminal-back-to-5tags` |
  | Terminal · a one-tag note (`the seal` — the seeder tags every field-guide note `tutorial`) | `r58-07-terminal-0tags` (misnamed — it is the ONE-tag case) |
  | Study · five tags closed (all five + ＃ fit one line in the proportional face) · the field open beside them, clear of `in the field guide` | `r58-10-study-5tags-closed` · `r58-11-study-5tags-field-open` |
  | A ZERO-tag, no-book note (⌘N) in both voices: `in no book` leading, the lone ＃ trailing | `r58-12-study-0tags-new-note` · `r58-13-terminal-0tags-new-note` |
  | (aside) the Settings window's Appearance tab — how the voice was switched | `r58-08-settings-window` · `r58-08b-settings-appearance` |

  Honesty notes: the two walk tags (`row58a`, `row58b`) were applied through the field and removed through the × — the dev store carries the batch's five as before, plus the empty ⌘N note of 2026-09-01 (left; a dev-store artifact). `r58-07` is a one-tag case, not zero; the zero-tag case is `r58-12/13`. The suggestion list under the open field is below the crops' edge and was not inspected (unchanged code).

- **Counts:** the masthead/door/row-alignment/flow pins 9 / 4 green (`r58-pins-2.log`). **Full Mac suite on the final tree: 2014 tests / 352 suites, all green** (`** TEST SUCCEEDED **`, 301.9 s; log `r58-full-mac.log` in the session scratchpad; the ten `TutorialWalkTests` suites inside it green; **the load-flaky `rewriteStrategyLatencies` (2 cases) and `CanvasDragTrackingTests` PASSED in-run — nothing re-run, nothing loosened**). **Arithmetic against batch A's recorded 2010 / 351:** +2 tests (`MastheadLayoutTests`' two geometry pins) +2 tests (`TrailingFlowRowsTests`) = **+4 ⇒ 2014**, exact; +1 suite (`TrailingFlowRowsTests`) ⇒ **352**, exact. Core 1524 / 165 untouched (zero `Sources/VariorumCore` lines); `Shared/` untouched (the mobile target sees no change).

- **Commits:** `7dee4c7` (the fix + the geometry pins + the record opened) · `b667932` (the red-on-old evidence) · `a3dfe16` (the orphan rule + its pins + the warning fix) · `1409d52` (the walk's captures + sheets, the counts, this record's close) · the hash fill.

#### BATCH A RECORD — CLOSED by the orchestrator (2026-09-01 ~10:40)

Walked twice: the batch on build 77509 (`orchestrator-a/00`, `01` + the 28-tile sheet) and row 58's fix on build 81367 (`02`–`09`: the path chip leads, the cluster wraps, the `#` field opens beside the cards and applies — the dev store's "tutorial" tag, removed by a mis-aimed click during the walk, was restored through the door; the stray typed word was removed by hand). Counts at close: **Mac 2014 / 352 green** (2001 + 13 tests, 347 + 5 suites over B's close); core 1524/165 untouched; `Shared/` touched once (`VoiceTokens.navigation`) — the iOS target build is owed before the ladder (the R3-2 lesson; recorded in §7b's checklist). Residuals, all owned: row 56 (the Library's system-blue row selection) → E; row 57 (the sidebar's arrow-key navigation gone with the flat column) → 13u2, her call in §7; row 59 (the `#` hit target) → the ladder's fix round; the tutorial's "the workspace" lesson still describes the retired fold → the closeout's copy change + re-seed (§7b item 8); `TrailingFlow.rows` ≡ the phone's `MobileChipFlow.rows` → a line for the forked-brains KnownIssues row at closeout. Nothing deferred, nothing reverted. **Batch C spawned next.**

---

### BATCH C — THE NOTE MODES (brief; DRAFTED 2026-09-01 ~05:55 — spawn after A closes)

**Token discipline (binding, from the orchestrator handoff §2c):** build ONE contact sheet of your capture directory with `python3 notes/plans/act10-correction-screens/tools/sheet.py <dir>` and name it in your record; the orchestrator reads the sheet first and opens full captures only where a tile earns it.

**Read IN FULL, in order:** this file (all of it — the constitution, C-1…C-7, R-cor-1…7 with R-cor-5/7 as
your governing rulings, the ledger, the triage record, batch B's and A's records — B names the scrolled-open
DOOR brain you reuse); the source report (§1; image rows 1, 10–15); then the code: `Features/Takes/
PostDetailView.swift` (the `Mode` enum + `allCases` rail/menu/keys ~:190, the `InspectorPanel` host
:125–140 / :281–301 / :356, the per-note mode memory :389), `Features/TOC/IndexModeView.swift`,
`Features/ReadMode/ReadModeView.swift` (`outlineShown`, the minimal outline :131+, the page), `Features/TOC/
BlocksWorkbenchView.swift` (the split :147–161 — the context panel is `.frame(width: 320)`; the five `.task`s
:167–171), `Shared/NoteIndexOutline.swift`, `Core/Views/FlowParagraph.swift`, `Features/Tray/
BlockHistoryPane.swift`, `Registry/CapabilityRegistry.swift` (:144 the read-mode gate; :1173 `switchMode`
"⌘1–⌘8"), `Registry/Capability.swift` (:576), the book's paged engine (the Book tab's `scroll · pages`
selector — find it in `Features/BookView/`), the tutorial seeder `Features/Tutorial/TutorialSeeder.swift`
(:332 the mode enumeration; :1332–1348 the "index · read" lesson — its TEXT states ⌘3/⌘4 and the click-lands-
in-Index promise; it changes under R-cor-7), and the pins `NewModesTests`, `NoteIndexOutlineTests`,
`BlocksWorkbenchTests`, `ModesSherlockMeasureTests`, `BlockHistoryPaneTests`, `WorkspaceNavigationTests` (the
eight-mode rail pin re-anchored at `15c7463` — it becomes seven), `TutorialWalkTests`.

**Your surface is the NOTE's mode row and the modes Read (edit·read), Blocks, and the Block History HOST —
and only that (C-1).** Rows:

1. **Rows 30/31 + 5/6/21 + 42 — R-cor-5/7, whole.** The rail becomes **Write · Takes · Read · Lenses ·
   Compare · Blocks · Canvas (⌘1–⌘7, derived from the one order — rail, menu and keys can never disagree;
   the registry verb follows)**. READ carries an in-place **`edit · read`** switch, **default `edit`**
   (RULED), remembered per note (your call, stated). **`edit`** = the Index tab's `▸ 01` outline column
   (toggle to hide/show with the existing outline button; the expanded/dropdown rows' type a step larger;
   **the small expanded editing card RETIRES**) beside a text pane in which **a clicked block goes LIVE in
   place** (the read-cheap→live upgrade through `PaneTextAuthority`; ONE live editor — P-3; the Write
   editor's identity machinery is never duplicated). **`read`** = `ReadModeView`'s calm page, **never
   editable**, with a `continuous · pages` selector (the book's paged engine reused — no second pager) and
   the SAME `▸ 01` column available (the minimal outline retires); the row-6 contents truncation goes with
   it. A click on a sentence in `read` flips to `edit` **at that block with the caret there** — batch B's
   door brain, reused, never re-implemented (row 38's note half). The Index TAB retires; `IndexModeView`'s
   brains become Read's `edit` half (keep the names as forwards where pins ride them — the 3C parity shape).
   Update the registry, the eight-mode pins → seven, and the **seeder's lesson text** to the new truth
   (⌘3 = Read; "click this paragraph — the page turns to edit with it live"), recording that the LIVE
   re-seed is the closeout's act. Pins: seven modes + key derivation; `edit` default; a click in `edit`
   makes exactly that block live (authority invariant); `read` has no live pane; a `read` click lands in
   `edit` at the clicked block; the pages selector renders the paged engine.
2. **Row 39 — ONE current block follows you.** Today position is per-mode memory. Define ONE per-note
   "current block" (the live/caret block in Write and Takes; the selected block in Read's `edit` and in
   Blocks) that every mode ENTERS on and LEAVES to. Pin the round trip: Write caret in block 2 → Takes live
   block 2 → Read(edit) block 2 selected/live → Blocks block 2 selected → Write caret in block 2.
3. **Rows 27 + 29 — Block History's host.** (a) ONE right region at a time: opened from Blocks, the history
   pane must not stand beside the workbench's own context panel past the window's edge — either the context
   panel yields or the history renders inside it; a geometry pin: the window's content never exceeds its
   width. (b) The pane is scoped to the mode that opened it: a mode switch closes it (or re-targets it to
   the current block — say which); it never shows block 3's history while block 1 is live. Pin: open in
   Write, ⌘2 → gone/re-targeted (RED on old: it persists stale).
4. **Row 18 — Blocks' draggable divider** between the list and the context panel (min widths both sides,
   the width remembered, the resize cursor on hover). Pin: a drag changes the split and it persists.
5. **Row 25 — the Blocks selection lag.** Measure first (click → rendered) on the Sherlock 215-block note; the
   candidates are the five `.task`s on appear and `observeBlockWorkbench` re-reading the note's facts on the
   main actor; render the list first and let facts arrive. Pin: a measure pin (the `ModesSherlockMeasureTests`
   shape) with a budget you state; RED on old if the budget is honest.
6. **Row 26 — the context panel's order:** facts first, the text card after (the architect's reading of "the
   text is also above the details"; note it PROVISIONAL in the record — her morning walk can flip it).
7. **Row 36 — apply batch A's KEEP/DROP table** to the displays on your surfaces (Read's page line stays per
   her word; the workbench footer and the Index column's counts per the table).

**Rules (§2b) bind; the acceptance gate is USE:** captures in `act10-correction-screens/batch-c/` — the
seven-mode rail; Read opening on `edit` with the column; a click making a block live in the pane; `read`
continuous and pages; the outline toggle; a `read` click landing in `edit` at that block; the five-step
continuity round trip; Blocks with the divider dragged; the selection timing; history from Blocks inside the
window; history gone after a mode switch. Environment + driving recipe + resiliency: batch B's brief's last
three paragraphs bind identically. Baselines: batch A's record's counts + your pins. **Deliverable:** code +
pins + a BATCH C RECORD under this brief (dispositions, the "current block" authority's name and file, the
captures, counts, commits, new rows numbered after A's last).

---

### BATCH C RECORD — THE NOTE MODES (a fresh Fable implementer session, 2026-09-01 ~10:45 →)

#### LIVE STATUS — BATCH C (flipped in the same commit as each piece; a fresh session finishes from this list alone)

- **Orientation:** DONE — the plan read in full (§0–§8, B's and A's records, this brief), CLAUDE.md, the resiliency protocol, the handoff's §2c, her report (§1 + image rows 1, 10–15), then the brief's files in its order (`PostDetailView` · `IndexModeView` · `ReadModeView` · `BlocksWorkbenchView` · `NoteIndexOutline` · `FlowParagraph` · `BlockHistoryPane` · the registry's two sites · `PostMode` · the book's paged engine `PagedReadModel`/`PagedReadView`/`BookView`'s `scroll · pages` · the seeder's two sites · the pins). Tree clean at `11b6f2a`; the dev-store Debug build pid 81367 running (batch A's product).
- **The settled design (before any code moved):**
  - **Row 1 (R-cor-5/7 whole):** `PostMode` drops `.index` → seven (`fromStored("Index")` → `.read`, the Outline→Compare precedent); `ReadModeView` becomes the READ HOST: an in-place `edit · read` switch (default `edit`, remembered per note under `readFace.<postID>`), the `▸ 01` column shared by both faces (`NoteIndexColumn`, the Index tab's column with its expanded editing card RETIRED and the block rows' handles a step larger), `edit` = `ReadEditPane` (the projection tier; a clicked block goes LIVE in place through the one `BlockTOCViewModel` authority — `PaneSurfaceView`, one ring), `read` = the calm page (continuous) or `NotePagesView` (the book's `PagedReadModel` over the one note — no second pager; the leaf views hoisted to `Core/Views/` under the hoist-at-next-touch rule), never editable; a `read` click → `LandingTarget` → `edit` at that block (B's brain, reused). `IndexModeView` survives as a typealias forward for the pins. The registry gains `readEditAttached` (the takes-board pattern) so the format family is honestly available in `edit` and grey in `read`.
  - **Row 39:** the authority is `CurrentBlockMemory` (per-note, persisted like the mode memory) fed by `CommandRouter.noteFocusedBlock` — every existing reporter feeds it; `registerDetail` restores the fact from it, and every mode ENTERS on the fact: Write's bare arrival lands the caret at the fact's block (fixing row 49's caret-at-end), Takes' N9 landing focuses the fact's block instead of the first, Read's `edit` and Blocks already seed from it.
  - **Rows 27/29:** a mode switch CLOSES the Block History pane (chosen over re-targeting: the question was asked in that mode); in Blocks the context panel YIELDS while any inspector column is open (one right region at a time).
  - **Row 18:** a draggable divider (the `ShellSplit` grammar) with a remembered width. **Row 25:** measure first on the dev build (the count-2 + plain tap idiom is the prime suspect — a single click waits the double-click interval), then fix + a measure pin. **Row 26:** facts first, text after (PROVISIONAL). **Row 36:** Read's footer duplicate DROPS; the column's count line shows in `edit` only; Blocks keeps its three per A's table.
- **Row 1 (R-cor-5/7):** NOT-STARTED — next.
- **Row 39 / 49:** NOT-STARTED.
- **Rows 27 / 29:** NOT-STARTED.
- **Row 18:** NOT-STARTED. **Row 25:** NOT-STARTED (measure first). **Row 26:** NOT-STARTED. **Row 36:** NOT-STARTED.
- **Row 54:** not on this surface — see the dispositions (the read tier is hosted by the library panel, the note-only window and the book; none of Read/Blocks/the history host composes `ReadPostView`).
- **The USE gate / counts:** PENDING.
- **No revert in flight.**

### BATCH F — THE RECOVERY FAMILY (brief; DRAFTED 2026-09-01 ~05:55 — spawn after C closes; her "special attention")

**Token discipline (binding, from the orchestrator handoff §2c):** build ONE contact sheet of your capture directory with `python3 notes/plans/act10-correction-screens/tools/sheet.py <dir>` and name it in your record; the orchestrator reads the sheet first and opens full captures only where a tile earns it.

**Read IN FULL:** this file; the source report (§1 — her words on lineage/history/archive/trash; image
row 12); `notes/plans/phase-13j-purge-memo.md` §4 (the doors' doctrine) and the 13j plan's utility
enumeration for what each surface OWES; then the code: `Features/Tray/TrayPanel.swift`, `Features/Tray/
BlockHistoryPane.swift`, `Shared/BlockHistoryFace.swift` (the four sections: Savepoints · Archived takes ·
Deleted takes · **Came from** — the lineage row), `Shared/RecoveryCopy.swift`, `Shared/RecoveryActs.swift`,
`Features/Library/ArchivedView.swift`, `Features/Library/RecoveryView.swift` (the Trash), `Theme/CalmGrammar.swift`;
the pins `TrayPanelShapeTests`, `TrayPanelMoveTests`, `NoteTrayTests`, `BlockHistoryPaneTests`,
`RecoveryDoorsTests`, `TrashSurfaceTests`, `TrashPurgeDoorsTests`, `IAAndTrashShapeTests`,
`SnippetGroupTrashTests`.

**Your surfaces: This Note's Tray · Block History (the pane's CONTENT; its host is C's) · Archived · the Trash
· the lineage doors ("Came from", the successors' doors) — and only those (C-1).** This batch is different in
shape: **it is a WALK FIRST, then fixes.** The dev store has no recovery content, so:

1. **Seed real content on the dev store through the product doors** (never SQL): in a scratch note — archive
   a block, delete a single block, multi-delete three, divide a block (lineage), merge two, delete a take,
   archive a take, make two savepoints on one take (⌘S twice with an edit between), save a note version
   (⌘⇧S), archive a whole note, delete a note that has a version, delete a snippet group. Record the seeding
   steps so the orchestrator can repeat them.
2. **Walk every surface at three widths** (a narrow pane, her ~1728-pt window, a short window) **in both
   voices**, every door exercised — Put back · Restore · Delete Now · Open note · the lineage row's door · the
   tray's Leaving/Archived sections · Empty Trash's confirm (cancel it) · Archived's un-archive. **Every defect
   becomes a ledger row** (numbered after C's last) with a capture and a traced mechanism, then FIXED with a
   red-on-old pin. Her Act 10 item 1 (the clipped tray header) is verified fixed at every width.
3. **Row 28 — savepoints vs lineage read as sections.** The pane's four sections get real section structure
   (the calm-card grammar: a header with air, one sentence of meaning under each — "Savepoints: this take's
   saved moments" · "Came from: the block this one was divided/merged/extracted out of"); "Came from" is the
   lineage — the word appears once, where it helps. Keep every string's substance (she rewrites copy later).
4. **Row 35 — the calm-chrome rule (C-6) on these surfaces:** no metric without a reason; the Trash's row
   facts ("from · deleted · N days left") stay — they ARE the reason a Trash exists.

**The acceptance gate is USE:** captures in `act10-correction-screens/batch-f/`, one per surface × width ×
voice at minimum, plus one per fixed row. Environment + recipe + resiliency: batch B's brief's last three
paragraphs bind. **Deliverable:** the seeding steps, the walk's row list, the fixes with pins, the BATCH F
RECORD under this brief.

---

### BATCH D — COMPARE + LENSES, MECHANICAL ONLY (brief; DRAFTED — spawn after F closes; the DESIGN is the memo, not this batch)

**Token discipline (binding, from the orchestrator handoff §2c):** build ONE contact sheet of your capture directory with `python3 notes/plans/act10-correction-screens/tools/sheet.py <dir>` and name it in your record; the orchestrator reads the sheet first and opens full captures only where a tile earns it.

**Read IN FULL:** this file; `notes/plans/act10-correction-memo-lenses-compare.md` (so your mechanical fixes
point the same way the design will go — but you build NONE of §3/§4's redesign); the source report's image
rows 8/9/10/13; `Features/Takes/CompareBoardView.swift` (:938 the `anchor.title ?? "This note"` fallback; the
"related blocks only" filter's application), `Features/Takes/LensesBoardView.swift`, `Core/Views/
NotePicker.swift`; the pins on `CompareComposition`/`CompareViewModel`/Takes (they stay green UNMODIFIED —
that is the semantics proof).

**Rows 16, 17, 46 — and only those (C-1):** (17) the anchor column ALWAYS renders the note whole — "related
blocks only" filters PEER columns, never the anchor; the header uses the derived display name (a journal
entry shows its day), never the literal "This note". Pin: related-only on + no peer → every anchor block
renders (RED on old: none). (46) ONE placement per act: the top-right "make outline note"/"+ note" buttons
retire; the offer cards stay (the memo will move them into the slot later). Pin: a registry/mount walk finds
exactly one door per act on the board. (16) the alignment: the toolbar row, the header cards and the offer
cards share ONE left edge and ONE baseline; the `＋ column`/`+ note` ghost stops floating mid-right — it
sits at the column strip's end at the header's height (both boards). Geometry pins. Nothing else — no
renames, no door moves beyond 46. Acceptance: captures of Compare's first open (anchor whole), a two-column
compare, Lenses with two columns. **Deliverable:** the BATCH D RECORD under this brief.

---

### BATCH E — THE LIBRARY PANEL (brief; DRAFTED — spawn after D closes; R-cor-3's PROVISIONAL reading)

**Token discipline (binding, from the orchestrator handoff §2c):** build ONE contact sheet of your capture directory with `python3 notes/plans/act10-correction-screens/tools/sheet.py <dir>` and name it in your record; the orchestrator reads the sheet first and opens full captures only where a tile earns it.

**Read IN FULL:** this file (R-cor-3 verbatim is your governing text — her INCLINATIONS, the safer choice);
the source report's image row 3; `Features/Library/LibraryInfoPanel.swift`, `Features/Library/
LibraryCatalogView.swift` (the row click model — body selects, title opens, double-click opens: #79's
ratified gestures, untouched), `Core/Views/FlowParagraph.swift`, `Features/BookView/` (the navigator's
outline rows, for the book panel), `RootView.swift` (the panel's host and the inactive-window appearance),
the pins `NoteRowSelectionTests`, `WorkspaceNavigationTests`.

**Rows 1, 33, 34, and the PANEL half of 24 — and only those (C-1):**
(1) The panel becomes a **simple READ preview** of the selected note: its rendered text (read-cheap,
`FlowParagraph`, virtualized — P1 holds on a 10k-word note), a calm facts line (words · blocks · last
edited — the facts she asked for at Act 10 item 10 — nothing more), and ONE generous door **Open** that
lands in the note **where the caret last was** (find the per-note caret/current-block memory batch C
built — row 39's authority — and land there; if none is stored, the first block). No takes, no blocks, no
write surface. (33) Selecting a **book** shows the BOOK's outline in the panel — chapters and notes, the
navigator's own grammar; a note row there opens the book at that note (batch B's reveal). (34) The
boundary between the panel and the library holds when the window is INACTIVE (`controlActiveState`) —
the divider and the panel's wash must not vanish; capture active vs inactive. (24, panel half) the panel's
appearance/disappearance animates with the row selection (no teleport); the sidebar rail's fade is A's.
Pins: a note selection renders the note's first block's text; a book selection renders its chapters; Open
lands at the remembered block; the inactive state keeps the divider (a render pin over
`controlActiveState`). Acceptance captures: a note selected (long note), a book selected, Open landing,
inactive window. **Deliverable:** the BATCH E RECORD under this brief. R-cor-3's reading stays PROVISIONAL in
the morning bundle — her walk ratifies or redirects.
