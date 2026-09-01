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
| 2 | "the left edge of the program still has the liquid glass floating edge" | Sidebar container | W8-3 half-delivered: interior flattened (`SidebarView.swift:348`), the floating pane kept | A | TRACED |
| 3 | "the tabs used to be right below the modes, and the tab spacing has gotten less generous… hard to read" | Sidebar mode rail + Open strip | The Open strip rebuilt at the sidebar's bottom (Act 10 item 9); the eight-mode rail compressed (`SidebarView.swift:464–487`). Generous at ordinary heights; compress only under a measured height threshold (the bottom-bar precedent) | A | TRACED |
| 4 | Read: "doesn't have a centered title above the read" | Masthead (all modes) | The title sits in an asymmetric masthead after item 5's tag cluster took the right — same defect as rows 16/19 | A | TRACED |
| 5 | Read: "I want the mode where you can scroll horizontally through the pages that the other one has" | Note Read (`read` half, R-cor-7) | `ReadModeView` has no paged mode; the book's paged view (13b Stage 4 — `scroll · pages`) is the reuse, seen working in the book's Read tab on the walk | C | TRACED |
| 6 | Read: "that contents looks kind of weird with how it's cut off" | Note Read's contents column | Mid-word width truncation of first lines | C | OPEN |
| 7 | Book: "clicking on a block automatically navigate[d] you there, and now you have to expand it before editing it" | Book Outline | Walk-confirmed (captures 49/25): a note-row click selects + toggles expansion but does not reveal (row 47's mechanism); expanding lands focus on the LAST block. Ruled shape: a note-row click REVEALS and lands in the note at its first block (or the clicked block via row 38's door); the ▸ disclosure is the separate expand affordance | B | TRACED |
| 8 | "the left outline looks a bit weird in sherlock holmes with the chapters + the blocks named the same" | Book navigator | Chapter and note share a title; collapse the note line when it equals its chapter (read-time) | B | TRACED |
| 9 | "clicked on an item in the middle of the outline… scrolling went absolutely berserk… landed me at the end" | Book Outline | `BookView.swift:895/932` — `withAnimation { proxy.scrollTo("page-\(id)", anchor: .top) }` over a lazily-realized stack of 9k-word cards: the SwiftUI lazy-stack scrollTo class (estimates, travel, overshoot). NOT TK2. Pin on the Sherlock book | B | TRACED |
| 10 | "the tags are also misaligned from the text" (image 4) | Library rows | Baseline/vertical-center mismatch | A | OPEN |
| 11 | "the word book is misaligned" (image 5) | Library rows | Same class as 10 | A | OPEN |
| 12 | "Scrolling via outline in the book view has completely broken" | Book Outline | Row 9's mechanism | B | TRACED |
| 13 | The gutter "177w… 236w · ⑂ takes on 1 block" is "crowded", low value; "the point was that the note info that used to be below it would be to the right of it" | Book Outline details gutter | Item 18 invented a facts string instead of moving the note details that rendered under the opening paragraphs; move THOSE aside, drop the string (C-6) | B | TRACED |
| 14 | "clicking on the chapters isn't even TRYING to navigate the book at all" | Book Outline | Walk: a navigator CHAPTER click DOES navigate when every card is collapsed (captures 23/50); with a story expanded it livelocks (row 44). The main column's chapter HEADINGS (⠿ name) are not doors at all — her click may have been there. Fix: chapter headings become doors too; the navigator's chapter click survives expansion (row 44's fix) | B | TRACED |
| 15 | "showing a tag icon and a + tag at the same time… that's just sloppy"; click → a "tag creator" field slides out, cursor active | Masthead tag cluster | `MastheadTagCluster.swift:54–76` renders cards + "+ tag" + the `#` fold (K12's sticky fold). ONE door with her slide-out field; the fold preference folds into it | A | TRACED |
| 16 | Compare "horribly misaligned" (buttons useful, clarity improved) | Compare | Two left edges/baselines in the flow | D | OPEN |
| 17 | Compare: "'This note' is showing nothing" | Compare anchor column | `CompareBoardView.swift:938` `anchor.title ?? "This note"` — a journal entry's title is nil so the literal shows; and "related blocks only" is emptying the ANCHOR, which it must never filter — peers only | D | TRACED |
| 18 | Blocks: "that line between them should be draggable left / right" | Blocks workbench | Fixed split today; draggable, remembered | C | OPEN |
| 19 | Lenses: "the title is once again weirdly aligned" | Masthead | Row 4's defect | A | TRACED |
| 20 | "the use of lenses is still a bit unclear" (→ R-cor-6: "absolutely dizzying") | Lenses | Folds into the Lenses + Compare design memo (R-cor-6) | D (memo) | RULED (R-cor-6) |
| 21 | Read: "the outline isn't working great… being able to tap to toggle the outline being on and off is great though. I love that" | Note Read's companion outline | Click/scroll fixed; the toggle stays byte-as-is | C | OPEN |
| 22 | Book Index "looks and feels good, but then you can't actually click into it to edit it" | Book Index | Read-only BY DESIGN (`BookIndexView.swift:23` — double-click hands off to Outline; walk-confirmed, and the handoff lands focus on the LAST block 3/3, not the clicked one). R-cor-7: editable in place — the clicked block goes live in the right pane (one live editor, P3); the book's Read stays read-only | B | TRACED |
| 23 | "the error on clicking on note titles in the outline place in the app was intermittent" (the field guide too) | Book navigator | Trace on the field guide as well as Sherlock; likely row 9's class racing realization | B | OPEN |
| 24 | "the appearance of the 'this note' modes is just as jarring as it has been" | Sidebar rail | R-cor-3: the rail FADES in/out smoothly; nothing added on the left | E | OPEN |
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
| 38 | (2nd msg) 13u item 17 — "if you click somewhere in the read mode, that it doesn't open there in the outline or the writing mode… it might make sense to pull that issue up into this phase, since it seems like there's a lot of 'cross pane interaction'" | Read → Index/Write click-through; the book's Read → editable view | PULLED IN (her word): the ONE scrolled-open door — click a sentence anywhere read-cheap, land in the editing surface at that block with the caret there — built once here and reused by rows 22/30 and the book; 13u2's item 17 is re-homed to this round | B + C (one mechanism) | OPEN |
| 39 | (2nd msg) "I haven't even gotten into blocks and index and how clicking through them is impacting the regular write and takes mode" | Cross-mode position continuity (Write ↔ Takes ↔ Read ↔ Blocks) | Walk: position is PER-MODE MEMORY today, not one position — Index kept block 03 while Takes made block 1 live; Write→Takes carried the caret's block when the caret was in block 1 (capture 39/40); Blocks keeps its own selection. Ruled by W8-1's letter: ONE current block follows you across Write/Takes/Read(edit)/Blocks; batch C builds the one authority and pins it | C | TRACED |
| 40 | (2nd msg, image 16) the book Outline's expanded note shows the bottom bar's items stacked VERTICALLY in a floating side card ("block 1/1 · block ▾ · Takes · commit ⌘S · history / note ▾ · comments · Aa / 5w block · 5w in note · ?") — "looks kind of weird… maybe the note menu needs to be collapsible… what's in that menu and how it looks needs to be a bit clearer" | Book Outline's in-place editor chrome | Trace where the side card comes from (the `CommitBar` axis introduced at wave 2c); make it read as one clear, calm control — collapsible if the trace says a stack is the right shape at that width | B | OPEN |
| 41 | (2nd msg; RULED R-cor-6 — they need a design) "if compare needs its own phase, give it its own phase!! that's fine" | Compare + Lenses | RULED R-cor-6: the design memo is written in-round, the build is its own phase. Earlier note: batch D fixes the defects (rows 16/17); if the triage walk finds Lenses/Compare need a DESIGN rather than fixes, the orchestrator writes the brief for a phase of their own instead of half-building it (the S4-16 condition) | D (memo) | RULED (R-cor-6) |
| 42 | (2nd msg — RULED R-cor-5: one tab, Read, with the Index's outline) "I also wonder if Index / Read could be condensed into a single tab - making it more similar to book, where it's a selector within a place you're in. and the outline button could hide / show the index, and the index could function as the outline." | The note mode row | A product call — asked at the sitting with the architect's recommendation (see the sitting record) | C | RULED (R-cor-5) |
| 43 | (2nd msg) "If I need to ship the app with just writing and takes, I'd be willing to do so, but ideally that won't be necessary" | — | Recorded as her floor, not the plan; the round's bar is every mode useful, bug-free and beautiful | — | RECORDED |
| 44 | **FOUND IN THE TRIAGE WALK — THE BOOK OUTLINE HANGS (BLOCKER): expand a long story, click a chapter in the navigator → 100% CPU, main thread livelocked, window unresponsive (190 s+ observed; killed).** Her "berserk… landed me at the end of the note" is this defect's onset. Reproduced first try on the dev store's Sherlock book (steps: open the book · Outline · click the "The Boscombe Valley Mystery" NOTE row in the navigator, which expands the 9,689-word story in place with focus on **block 215/215** · click any chapter row). Sample: `act10-correction-screens/triage/sample-hang-47298.txt` — every hot frame is SwiftUI (`NSHostingView.beginTransaction → GraphHost.flushTransactions → LazySubviewPlacements.placeSubviews → LazyStack.place → ForEachList.applyNodes → … LayoutEngineBox/UnaryLayout`); our only frames are value copies of `ReadingSection`/`Queries.ReadingEntry`. | Book Outline | **Mechanism (traced at the code, to be confirmed by the implementer's pin):** `BookView.swift:1106–1116` — an EXPANDED note composes the FULL `EditorView` (a TK2 `NSTextView` whose height ESTIMATE moves as its viewport lays out — TEXTKIT2 §2) INSIDE a `LazyVStack` row (`:772`), and the navigator's `withAnimation { proxy.scrollTo(…) }` (`:895`, `:932`) animates toward an anchor whose offset depends on that moving height: place → the editor re-estimates → re-place → the target moves → repeat. Related symptom: expanding lands focus on the LAST block (215/215). Fix shape for batch B: an expanded editor's height must be settled before/while a programmatic scroll runs (measure once — `ensureLayout` over the one expanded note is bounded — and hold it; no animated `scrollTo` at an unsettled anchor), or the expanded body leaves the lazy container; plus the focus-lands-at-end fix. **Red-on-old pin: a mounted book with one 9k-word note expanded receives a navigator scroll request and the run loop returns within a budget (a watchdog), landing at the requested chapter.** | B (FIRST) | TRACED (BLOCKER) |
| 45 | (walk) The book Outline's collapsed card previews only the FIRST block — "A Scandal in Bohemia" previews as "I." (its section numeral); the field guide's cards read fine because their first blocks are prose | Book Outline cards | Preview = the first ~40 words across the note's leading blocks, skipping a lone heading/numeral block (read-time derived, never stored) | B | TRACED |
| 46 | (walk) Compare offers "make outline note" and "+ note" TWICE — as top-right buttons AND as the two centered offer cards | Compare | Two doors for one act (C-6's counterexample class); one placement per act — the memo (R-cor-6) decides which; the mechanical fix here is not to duplicate | D | TRACED |
| 47 | (walk) A navigator NOTE-ROW click in the book Outline selects (›) and toggles expansion but never REVEALS the note when it is off-screen — the field guide's "the take ceremony" got its marker and the page did not move; the Sherlock case only "worked" because a chapter click had already placed the note at the top | Book Outline navigator | `BookView.swift:899–911` — "Reveal is SCROLL-TO and never an auto-expand … the `page-<id>` anchor the expanded header does" — the reveal targets an anchor a collapsed card does not carry, so a collapsed note cannot be revealed; this is row 7's "you have to expand it" and row 23's "intermittent" in one mechanism | B | TRACED |

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
- *(Read's default half was PROVISIONAL for one turn — RULED `edit` by her follow-up; nothing to ratify.)*
- **The Lenses + Compare design memo — `notes/plans/act10-correction-memo-lenses-compare.md` §7, eight rulings** (R-cor-6's deliverable, WRITTEN; the build is its own phase at her slot).
- Row 26: the Blocks context panel's order (facts first) — the architect's reading.
- Any scalpel revert taken under C-5 (none expected; her lean recorded).
- The row-36 KEEP/DROP table for word counts.

## 8. Records (appended per batch; the triage walk first)

### TRIAGE WALK — LIVE (2026-09-01 ~04:30 → ; the orchestrator, dev-store Debug build `io.lduarte.Variorum.debug`, Terminal voice, window zoomed 1728×1084; captures in `act10-correction-screens/triage/`)

- **Driving recipe that works:** System Events for keys/menus/window bounds (`vd.sh` in the session scratchpad); clicks via a compiled CoreGraphics event poster (System Events' `click at` never reached this SwiftUI window; `cliclick` is not installed). The dev app restores TWO windows at launch (state restoration) — close one. Zoom = Window ▸ Zoom (the green button is Full Screen).
- **Confirmed on the dev store, beyond her list:** the masthead title centers in the space LEFT of the right cluster in every mode (rows 4/19 mechanism); Compare offers "make outline note"/"+ note" TWICE (top-right buttons + the centered cards); Compare's anchor column is empty even with a titled note (row 17 — the filter empties the anchor); "position" is per-mode memory, not one position (Index kept block 03 while Takes made block 1 live — row 39); the Library's book-row click leaves the NOTE panel showing (row 33, exact); the "this note" rail vanishes whole on leaving a note (row 24); the library keeps the hairline-separator grammar; the book Outline's card preview shows only the FIRST block ("A Scandal in Bohemia" previews as "I." — the section numeral); the expanded note's vertical side card (row 40) reproduces; expanding a note lands focus on its LAST block.
- **ROW 44 — THE HANG (BLOCKER)** — see the ledger; sample saved beside the captures; the dev build was killed and relaunched to continue.
- **Walk verdicts written into rows 7, 14, 15, 22, 29, 33, 39; new rows 45–47.** Captures 00–51 (the file names say what each is). The field guide was restored into the dev store via Help ▸ Restore Tutorial… (capture 48) so both books exist for the batches. The Trash (47) and Archived (41) rendered fine at the dev store's content level — batch F seeds real content before walking them.
- **What the walk did NOT cover (owed to the batches):** Snippets and the Pool (not in her list); Read's outline toggle (R-cor-5/7 redesigns the mode whole); Canvas; the dark appearance; the Study voice (the walk ran in Terminal — every defect walked is voice-independent; batch A checks the masthead in both voices).
- **Walk CLOSED 2026-09-01 ~05:20.** Batch B spawned next (the hang first).


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
