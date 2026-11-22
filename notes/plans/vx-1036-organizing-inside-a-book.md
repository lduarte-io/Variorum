# VX-1036 — Organizing inside a book

**Ticket** VX-1036 (Umbrella, Books) · **Branch** `vx-1036-organizing-inside-a-book` · **Worktree** `~/dev/variorum-vx-1036` (Pro) · **Shape** `/architect-phase` · **Stage coordinator** nov22 · **Mockups** `notes/plans/vx-1036/`

**STATUS — OPEN 2026-11-22: DESIGN SITTINGS. Nothing is built. No implementer has been spawned. Her word at kickoff: "we will finish the design plans together before you do any building."**

---

## FOR A LATER READER

*(Written whole at closeout. Until then, the state in four lines.)*

- The effort is at its first design sitting. §1 holds her words, §2 what the app already does, §3 the two defects she reported as traced by reading (no pin yet), §4 the design forks as proposals, §5 the sitting's questions and her rulings as they land.
- Nothing in §4 is ruled. Nothing is built.
- No schema, `Sync/`, custody or editor-seam line is planned; a stored lane order is an open question for her (F2).
- Preflight for the BUILD is not complete (§8 says what is read and what is owed before the first spawn).

---

## 1. Her words (verbatim — the feature passages only)

Her instruction for this record (2026-11-22): the repo notes carry the feature alone. The passages below are exact; "…" marks where a sentence is entered or left partway. The use the design must serve, in the architect's words: planning tasks across a week, and managing many small notes from inside one book or gathering.

### 1a. The kickoff message, 2026-11-22

> we will finish the design plans together before you do any building. normal /architect-phase discipline, you can mint a ticket for this.

> … basically I need a way to organize notes within a book better, via a view of the tags. I said books but gatherings might be a better tool for this - I also do want the ability to not see the tags while in a book to be preserved, and i want an option for while reading a book to see the name of a note in there. there's also an existing bug / issue i've noticed where when making a new note within a book, it's made at the bottom of a long list sometimes and then you can't actually see the new note ready to be edited. and then i'm not sure that changing the order of the notes (like sort by) is changing the reading order - which seems both confusing and like a bug. so basically a host of imporvements to what looking at a note within a book is like, tag management changing and becoming better (i think having tag "chapters" in gatherings should be allowed, so i could have a weekly gathering that gatehrs all days of the week but tuesday is under tuesday, etc.). i know there are complexities there with what to do when multiple tag based chapters would apply to a note, but i really want better organization. i'm imagining swimlanes in the SDLC - not visually ofc, but I do feel like books / tags are very underbaked for organization …

> I think we can talk about this and then I'll need different mockups for how it could look that I can give feedback on.

### 1b. From a longer note she shared for context

> … I haven't been able to add tags to a note and edit the actual note while i'm in the book view - I think that what I need is a way to open a "note" menu where the block menu is while you're actively typing with the tags that a note has, and maybe a way to see from the book view what tags each note has. Not sure exactly what that should look like, it's a more major feature change, but I think that's what I'd need for everything to work the way I'm imagining and be able to work with a note just from within the book view. In general making the book view a more powerful way of working with multiple notes will be important though …

> … (probably has to be a setting for if you want to see tags on a book or not, because it would be annoying to always see them), will make a book (or gathering) more of a managing ground.

> It would be nice if chapters could auto-collect tags within a book too - if I could have a Tuesday chapter that always had things tagged Tuesday, that would be super helpful, so I could visually build and look at the organization of my week and move it around with just tagging.

> … the UI is more suited to actually writing than it is having basically ten million sticky notes everywhere / project board lanes.

> … I really need to make that Variorum change to when you make a note in a new book. it's so annoying also when things are sorted one way on the left side but then don't follow that order in the reading order …

> … being able to have a chapter that auto-collects / organizes tags is going to be important, but I'm also not sure what the deal with that is going to be because chapters are a book only thing. Maybe I only add this rule to gatherings anyway - that would buff gatherings even more and also avoid some issues with removing tags not automatically moving things …

> … starred being across libraries being a setting and cross library search being an option …

> … what search across the library should look like, if you should be able to exclude wings from appearing in that.

---

## 2. What the app already does (read on main `99db9ee33`, 2026-11-22)

**Tag-grouped display exists, in one mode, as a way of looking.**
- A book's **Index** masthead carries `group ▾`: chapters (where the book has them) · each tag family its notes wear · none. Choosing one writes nothing; it is remembered per book on this Mac only. A family gives one heading per child tag, A–Z by path; each note files under ONE heading — the lexically smallest child it wears; the rest trail under "other". (`Features/BookView/BookIndexGrouping.swift`; QUESTIONS #172, P-13id-U3-4, PROVISIONAL.)
- The Index also carries the in-book filter (`by tag ▾`, with / without, all / any, "N shown") and "save as gathering…". The filter lasts while the Index is open. (`BookFilterBar.swift`; `Queries.assembleReading(…, filter:)`.)
- Outline, Book, Read, the navigator and the Book Panel do not group by tag.

**A stored grouping exists in the schema and has no door.**
- `reading.grouping_tag_id` is a synced column since the first schema. `Queries.assembleReading` resolves it to a `section_path` per note (`Queries/ReadingAssembly.swift:363`, `tagFamilySectionSelect`), and the Outline draws a heading wherever that path changes along the book's order (`BookOutlineRows.rows(flat:)`) — headings over RUNS; it does not reorder notes into groups.
- No operation or face sets the column. The only writers are the mint's parameter, Duplicate and the wing moves.

**Standing rulings this design touches.**
- The 13i sitting, §3 (gatherings): capabilities include "the tag-family grouped DISPLAY (never real chapters)"; no membership, chapters or hand order as truth.
- The same record's future-ideas ledger, §13: "Drag between tag-groups = retag (the kanban upgrade of the grouped display; her "love that idea")" and "A horizontal board view (Canvas-flavored)".
- QUESTIONS #25(a): chapters are a book's only; a gathering refuses `createSection`.
- Intake law (AppSpec §9): un-tagging is a non-event for a book; a tombstone means decided. A gathering holds nothing and "evicts when the tag goes, by definition".

**A note's tags inside a book.** No book face shows or edits a note's tags: not the Outline's rows, the Index, the navigator, the sidebar's note box or the Book Panel. Tags are seen and edited in the note's own masthead (Write) and its menus.

**The order dial** (the mode row's trailing end — "Manual order ▾"): picking an order is a LOOK — view-local to that book window, nothing written; "Save as This Book's Order" appears in the menu only after a look is picked (`BookMastheadModeRow.swift`, `BookViewModel.viewOrder`; her A31 intake item, built at 13c). Every mode of that window reads the one observation, so they follow the look together. Readers outside the window keep the stored order: the Book Panel beside a note, the Library's info panel, export, the phone, the wire (VX-1026), and the same book the next time it opens.

**Tickets already on the board that this touches** (none seated as a member yet — her word seats them): VX-881 (a setting to show each note's title in Read ▸ Scroll) · VX-1032 (hide tags in the Library view: one setting and a per-book choice) · VX-576 (tag pickers list most-used first) · VX-571 (a tag's colour) · VX-578 (convert one tag into another) · VX-588 (a "reconsider" door) · VX-128 (block tags, her open question) · VX-300 (book-view editing equal to the note's editor) · VX-312 (⌘1–⌘6 from a book) · VX-856 (Outline and Index remember the place) · VX-1026 (the wire lists hand order) · VX-15 (book hand-reorder returns, parked) · VX-216 (book and gathering menus clarity pass, hers). Phone: VM-120 (Inside a book), VM-126 (the order a book reads in), VM-156, VM-166.

---

## 3. The two reports, traced by reading (no pin yet — a pin confirms before any fix)

### 3a. "when making a new note within a book, it's made at the bottom of a long list sometimes and then you can't actually see the new note ready to be edited"

- Every mint door calls `BookView.mint(_:reveal:)` (`BookView.swift:1542`): the operation, then `model.focus(id)`, then a reveal only `if reveal`.
- **The navigator foot's doors pass `reveal: false`** — "+ new note", "+ new entry", and a gathering's "+ new note" (`BookView.swift:1494`, `:1503`, `:1162`). The note is minted and focused; the page is never asked to go to it.
- The note is seated at the END of the book, in no chapter (`BookStructureModel.newPost` passes no section; `Operations.newPostInReading`). In a chaptered book that is the trailing unfiled group, after every chapter. Under a stamp order it sits wherever the order puts it.
- The doors that do ask (`reveal: true` — the page-foot "+ new note in this book" and ⌥⌘N) may lose the ask: `landOutlineReveal` runs on the reveal's change and, when the new note is not yet among the delivered entries while the book has others, consumes the reveal and returns (`BookView.swift:2714–2717`); the entries' later arrival finds nothing parked. Row 73's parking covers only an EMPTY book. SUSPECTED — whether the observation loses that race is for the pin to say.
- A book past the 300-note window (`BookViewModel.entryWindow`) does not draw a note seated beyond it until "show more ›".

### 3b. "i'm not sure that changing the order of the notes (like sort by) is changing the reading order"

- Not located as a defect yet. Inside one book window every mode reads the same ordered entries, so the navigator and the page cannot disagree by construction (§2, the order dial).
- What reading does show: the dial's pick is a look until saved, so the Book Panel beside an open note, the Library's info panel, the phone, export and the book's next opening all keep the stored order. That alone could read as "sorted one way … but then don't follow that order".
- Owed from her: where she saw it (which book or gathering, which mode, what she changed and with which control, and what did not follow).

---

## 4. The design space — the architect's first read (PROPOSALS; nothing here is ruled)

**F1 — Where lanes live.** Her lean: gatherings only. The architect agrees: a gathering is derived at read, so a retag moves a note at once and an untag removes it, with no eventing. An auto-collecting CHAPTER in a book would need the intake machinery to re-file on every tag change and to act on un-tagging, which today is a non-event by law. Proposal: lanes are a gathering's shape, stored on the gathering; a book keeps real chapters and gets tag lanes only as a look.

**F2 — What a lane is, and its order.** Tags carry no order, so a family's children list A–Z: friday · monday · saturday… Options: (a) lanes are a CHOSEN, ORDERED SET of tags stored on the gathering (the `auto_tag_ids` shape: a JSON array of ids) — any tags, in her order; a new synced column, so a SyncSpec §12 lockstep event with a mirror deploy at her go and a phone leg; (b) lanes are a family's children (the existing `grouping_tag_id`, no schema), ordered by a per-Mac local preference; (c) a sibling order on the tag itself (a `position` column on `tag`) — general tag management, also a schema event. The architect leans (a).

**F3 — A note wearing two lane tags.** Options: (a) it files under the FIRST lane in lane order and its row quietly names the others; (b) it shows in every lane it wears — the same note twice on one page, which the one-live-editor rule, the stepper and "note N of M" all have to answer; (c) lanes are exclusive at the gesture — moving a note to a lane swaps the lane tag — while a second lane tag applied by hand falls to (a). The architect leans (a) + (c).

**F4 — Moving between lanes.** Drag a note under another lane's heading, or "Move to Lane ▸" on the note's menu: one act that removes the old lane's tag and applies the new one through the one application road (so living books hear it). Its undo story is to decide — tag applications are outside structural undo today. Order WITHIN a lane is the gathering's sort; a gathering has no hand order.

**F5 — The unlaned.** Notes the gathering shows that wear no lane tag trail under a last heading ("other" today; chapters say "unfiled").

**F6 — Tags on the page.** Seeing: a quiet tag line per note in the book's rows (Outline, Index, navigator — which of them is a mockup question), on a per-book switch, off by default. Editing: the note's tags reachable while she types inside the book — her "note menu where the block menu is" — or in the sidebar's note box. VX-1032 is the Library's twin.

**F7 — New notes.** The defect is §3a. The design half: where a new note is born — the end (today), after the note she is on (same chapter or lane), or the lane or chapter whose door she pressed (a "+" per lane, born wearing that lane's tag).

**F8 — The order dial.** Keep look-then-save, or make a pick the book's order at once (hand positions are kept in the rows either way; a finished book's pick stays a look). Waits on §3b's answer.

**F9 — Titles while reading.** VX-881 as written: an option to show each note's title in the book's Read. Per book, or one setting.

**Sizing (the guidance, said to her at the sitting):** tags on the page (F6) and lanes (F1–F5) are each a phase-sized unit; the three small items (F7's defect, F8, F9) are a third. The guidance caps a phase at two — a split into two runs sharing this sitting is the likely shape, her call.

---

## 5. Sittings

### Sitting 1 — 2026-11-22 (open)

Asked in chat (her answers recorded here verbatim as they land):

1. §3b — where she saw the order not follow.
2. F1 — lanes on gatherings only, with books getting them as a look.
3. F2 — a chosen ordered set (a schema event) or a family with local order.
4. F3 — one lane per note (first in order), or shown in every lane it wears.
5. F6 — which faces show tags, and where the editing door lives.
6. F7 — where a new note is born.
7. The wave's edges: starred across wings and cross-wing search — this umbrella, or their own.

---

## 6. Ledger

| # | Item | Status |
|---|---|---|
| 1 | Tags seen inside a book, with the choice not to see them | DESIGN — F6 |
| 2 | Tags edited while working inside a book ("note menu") | DESIGN — F6 |
| 3 | Tag lanes in gatherings | DESIGN — F1–F5 |
| 4 | A note's name while reading a book (VX-881) | DESIGN — F9 |
| 5 | A new note in a book is shown ready to edit | TRACED BY READING (§3a); pin owed; ticket owed at her word |
| 6 | The order she picks vs the reading order | NOT LOCATED (§3b); her answer owed |
| 7 | Starred across wings · cross-wing search | SCOPE QUESTION — sitting 1, Q7 |

---

## 7. Mobile parity

To be written when the design closes: a `notes/MobileSoul.md` ledger row per ruled face. Core changes owe a phone leg (the VX-980 lesson).

---

## 8. Preflight state

Read for this sitting: CLAUDE.md and the loaded canon · the master plan's in-flight table and latest closeout · `notes/SurfaceContracts.md` (The app, The Library, The Bookcase and books, The note) · the board snapshot's Books, Library and tag rows · QUESTIONS #25, #171–#173 · the 13i sitting record §3 and §13 · the code named in §2–§3.

Owed before the first implementer spawn: `notes/QUESTIONS.md` and the board snapshot in full · `notes/SessionResiliencyProtocol.md` · `notes/plans/workflow-transition-2026-10-06.md` · `notes/PhaseSizingGuidance.md` · `notes/MobileSoul.md` · `notes/SyncSpec.md` if F2 rules a column in · `notes/MCPSpec.md` if a wire-called operation changes · the 13i-b and 13i-d plan files' sections on the grouped display and the filter bar.

---

## 9. Binding principles — the 13b constitution, P-1…P-9 (copied verbatim, binding in this effort)

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
