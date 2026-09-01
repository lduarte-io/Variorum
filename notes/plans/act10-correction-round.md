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
| 5 | Read: "I want the mode where you can scroll horizontally through the pages that the other one has" | Note Read | `ReadModeView` has no paged mode; the book's paged view (13b Stage 4) is the reuse | C | OPEN |
| 6 | Read: "that contents looks kind of weird with how it's cut off" | Note Read's contents column | Mid-word width truncation of first lines | C | OPEN |
| 7 | Book: "clicking on a block automatically navigate[d] you there, and now you have to expand it before editing it" | Book Outline | Regressed click model in the Outline rewrite; expand becomes a separate affordance | B | TRACED |
| 8 | "the left outline looks a bit weird in sherlock holmes with the chapters + the blocks named the same" | Book navigator | Chapter and note share a title; collapse the note line when it equals its chapter (read-time) | B | TRACED |
| 9 | "clicked on an item in the middle of the outline… scrolling went absolutely berserk… landed me at the end" | Book Outline | `BookView.swift:895/932` — `withAnimation { proxy.scrollTo("page-\(id)", anchor: .top) }` over a lazily-realized stack of 9k-word cards: the SwiftUI lazy-stack scrollTo class (estimates, travel, overshoot). NOT TK2. Pin on the Sherlock book | B | TRACED |
| 10 | "the tags are also misaligned from the text" (image 4) | Library rows | Baseline/vertical-center mismatch | A | OPEN |
| 11 | "the word book is misaligned" (image 5) | Library rows | Same class as 10 | A | OPEN |
| 12 | "Scrolling via outline in the book view has completely broken" | Book Outline | Row 9's mechanism | B | TRACED |
| 13 | The gutter "177w… 236w · ⑂ takes on 1 block" is "crowded", low value; "the point was that the note info that used to be below it would be to the right of it" | Book Outline details gutter | Item 18 invented a facts string instead of moving the note details that rendered under the opening paragraphs; move THOSE aside, drop the string (C-6) | B | TRACED |
| 14 | "clicking on the chapters isn't even TRYING to navigate the book at all" | Book Outline | Chapter headers have no scroll target wired | B | TRACED |
| 15 | "showing a tag icon and a + tag at the same time… that's just sloppy"; click → a "tag creator" field slides out, cursor active | Masthead tag cluster | `MastheadTagCluster.swift:54–76` renders cards + "+ tag" + the `#` fold (K12's sticky fold). ONE door with her slide-out field; the fold preference folds into it | A | TRACED |
| 16 | Compare "horribly misaligned" (buttons useful, clarity improved) | Compare | Two left edges/baselines in the flow | D | OPEN |
| 17 | Compare: "'This note' is showing nothing" | Compare anchor column | `CompareBoardView.swift:938` `anchor.title ?? "This note"` — a journal entry's title is nil so the literal shows; and "related blocks only" is emptying the ANCHOR, which it must never filter — peers only | D | TRACED |
| 18 | Blocks: "that line between them should be draggable left / right" | Blocks workbench | Fixed split today; draggable, remembered | C | OPEN |
| 19 | Lenses: "the title is once again weirdly aligned" | Masthead | Row 4's defect | A | TRACED |
| 20 | "the use of lenses is still a bit unclear" | Lenses | A design item, not a fix — needs her words on WHAT is unclear; the orchestrator brings a short list of candidates in the morning bundle | D | OPEN (ruling) |
| 21 | Read: "the outline isn't working great… being able to tap to toggle the outline being on and off is great though. I love that" | Note Read's companion outline | Click/scroll fixed; the toggle stays byte-as-is | C | OPEN |
| 22 | Book Index "looks and feels good, but then you can't actually click into it to edit it" | Book Index | Read-only BY DESIGN (`BookIndexView.swift:23` — double-click hands off to Outline). Her ruling: editable in place — the selected note's block goes live in the right pane (one live editor, P3) | B | TRACED |
| 23 | "the error on clicking on note titles in the outline place in the app was intermittent" (the field guide too) | Book navigator | Trace on the field guide as well as Sherlock; likely row 9's class racing realization | B | OPEN |
| 24 | "the appearance of the 'this note' modes is just as jarring as it has been" | Sidebar rail | R-cor-3: the rail FADES in/out smoothly; nothing added on the left | E | OPEN |
| 25 | "the blocks page is also weird and laggy - it takes a second after selecting it for it to be selected" | Blocks workbench | Trace: the workbench observation (`observeBlockWorkbench`) + selection work on the main actor are the candidates; measure, then fix | C | OPEN |
| 26 | Blocks: "the text is also above the details" | Blocks context panel | Architect's read: the block's full text card sits above the facts; the facts should lead (the text is already in the row) — correctable at her word | C | OPEN |
| 27 | "opening block history doesn't open it correctly" | Block History from Blocks | From Blocks it opens as a THIRD right column beside the workbench's own panel → overflows the window (her "Clos…"/"Restore" cut). One right region at a time | C / F | TRACED |
| 28 | "not sure what the difference between savepoints and lineage is supposed to be, or if they're both in there" | Block History pane | Both are in it (savepoints = each take's saved moments; lineage = the block it came out of); the sections must READ as sections | F | OPEN |
| 29 | "the block history tab stays open as you move to other modes which looks bad and is confusing" | Block History host (`PostDetailView.swift:286`) | The pane is not scoped to the mode that opened it; scope it | C | TRACED |
| 30 | "the index tab is ALSO uneditable in the notes view… it's literally a new writing mode" | Note Index | Built read-right / edit-in-a-small-left-card (`IndexModeView.swift:380–387`). Her ruling: the RIGHT pane is the writing surface (click → that block goes live there); the left column is a navigator | C | TRACED |
| 31 | "the index dropdown on the left is also awkwardly sized, the text is bigger than it" | Note Index left column | The expanded card is the misplaced live editor of row 30; retired with that fix | C | TRACED |
| 32 | "not sure if all of these changes were noted or if you're going to have to look through commit history" | — | Every wave has a record; the 34-commit trail is complete. RECORDED — the gap was use, not record | — | RECORDED |
| 33 | (R-cor-3) "when I click on a book, i just still see the last note i clicked on - obviously bad. a book could show the outline that it has" | Library right panel | A book selection shows the book's outline in the panel | E | OPEN |
| 34 | (R-cor-3) "the line between the 'note info' and the library disappears when you're tabbed out, and it needs significant work" | Library right panel boundary | Inactive-window appearance loses the divider/wash; hold the boundary in both states | E | OPEN |
| 35 | (R-cor-4) "special attention… to the lineage / history / archive / trash" | This Note's Tray · Block History · Archived · Trash | Batch F walks each surface fresh, lists every defect found, fixes them with pins; the rebuilt tray (Act 10 item 1) is walked at every pane width | F | OPEN |
| 36 | (R-cor-4) "word count shouldn't just be thrown in everywhere just because" | All Act 10 chrome | Sweep table: every word-count/metric display in the eight rewritten views (Snippets 10 · Read 6 · Blocks 4 · Index 4 · BookView 4 · LibraryInfoPanel 4 · Compare 2 · BookIndex 1) verdicted KEEP-with-reason or DROP (C-6) | A (table) · each batch (its rows) | OPEN |
| 37 | (R-cor-4) "not sure what the 'reading time' was calculated on… how random is it?" | Note Read | `words ÷ 200` rounded up, a fixed 200-wpm convention — not random, not measured. Stays per her word | — | RECORDED |
| 38 | (2nd msg) 13u item 17 — "if you click somewhere in the read mode, that it doesn't open there in the outline or the writing mode… it might make sense to pull that issue up into this phase, since it seems like there's a lot of 'cross pane interaction'" | Read → Index/Write click-through; the book's Read → editable view | PULLED IN (her word): the ONE scrolled-open door — click a sentence anywhere read-cheap, land in the editing surface at that block with the caret there — built once here and reused by rows 22/30 and the book; 13u2's item 17 is re-homed to this round | B + C (one mechanism) | OPEN |
| 39 | (2nd msg) "I haven't even gotten into blocks and index and how clicking through them is impacting the regular write and takes mode" | Cross-mode position continuity (Write ↔ Takes ↔ Index ↔ Read ↔ Blocks) | W8-1's "index tracks position with take / write / probably block too": the walk exercises every mode switch with a block selected and records whether the position follows; each miss becomes a row | triage → C | OPEN |
| 40 | (2nd msg, image 16) the book Outline's expanded note shows the bottom bar's items stacked VERTICALLY in a floating side card ("block 1/1 · block ▾ · Takes · commit ⌘S · history / note ▾ · comments · Aa / 5w block · 5w in note · ?") — "looks kind of weird… maybe the note menu needs to be collapsible… what's in that menu and how it looks needs to be a bit clearer" | Book Outline's in-place editor chrome | Trace where the side card comes from (the `CommitBar` axis introduced at wave 2c); make it read as one clear, calm control — collapsible if the trace says a stack is the right shape at that width | B | OPEN |
| 41 | (2nd msg) "if compare needs its own phase, give it its own phase!! that's fine" | Compare + Lenses | Authorization recorded: batch D fixes the defects (rows 16/17); if the triage walk finds Lenses/Compare need a DESIGN rather than fixes, the orchestrator writes the brief for a phase of their own instead of half-building it (the S4-16 condition) | D | RECORDED |
| 42 | (2nd msg — RULED R-cor-5: one tab, Read, with the Index's outline) "I also wonder if Index / Read could be condensed into a single tab - making it more similar to book, where it's a selector within a place you're in. and the outline button could hide / show the index, and the index could function as the outline." | The note mode row | A product call — asked at the sitting with the architect's recommendation (see the sitting record) | C | RULED (R-cor-5) |
| 43 | (2nd msg) "If I need to ship the app with just writing and takes, I'd be willing to do so, but ideally that won't be necessary" | — | Recorded as her floor, not the plan; the round's bar is every mode useful, bug-free and beautiful | — | RECORDED |

## 4. The batches (one surface each — C-1; order chosen so "crisp" returns first)

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
- **D · Compare + Lenses** — rows 16, 17, 20. Alignment; the anchor column ALWAYS renders the note
  (derived display name for a nil title; "related blocks only" filters peers only); Lenses per her
  words once she gives them (row 20 stays open for the morning bundle if she has not).
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
- Row 20: what is unclear about Lenses — the candidates the orchestrator brings.
- Row 26: the Blocks context panel's order (facts first) — the architect's reading.
- Any scalpel revert taken under C-5 (none expected; her lean recorded).
- The row-36 KEEP/DROP table for word counts.

## 8. Records (appended per batch; the triage walk first)

*(none yet)*
