# VX-1036 — Organizing inside a book

**Ticket** VX-1036 (Umbrella, Books) · **Branch** `vx-1036-organizing-inside-a-book` · **Worktree** `~/dev/variorum-vx-1036` (Pro) · **Shape** `/architect-phase` · **Stage coordinator** nov22 · **Mockups** `notes/plans/vx-1036/`

**STATUS — OPEN 2026-11-22: DESIGN SITTINGS. Sitting 1 answered (R-1036-1…9); the round-1 mockups are being drawn for sitting 2. Nothing is built. Her word at kickoff: "we will finish the design plans together before you do any building."**

---

## FOR A LATER READER

*(Written whole at closeout. Until then, the state in four lines.)*

- Sitting 1 is answered: §5 holds her reply and the rulings R-1036-1…9. §4b is the design as it stands (lanes L-1…L-11, tags T-A…T-D, new notes N-1…N-3, the dial D-1, Read titles RT-1, wings W-1…W-6); §4c is the round-1 mockup brief; §4 is the first read it grew from, kept as written.
- The tickets: VX-1037 lanes · VX-1038 tags inside a book · VX-1039 the new-note defect and landing · VX-1040 the order dial · VX-1041 wings · VX-881 titles in Read — all sub-issues of VX-1036.
- One schema event is accepted in principle (R-1036-5: the lanes column); its mirror deploy runs only at her go. Nothing is built.
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

- **WITHDRAWN by her at sitting 1 (R-1036-1): "I think I'm actually just wrong, and it wasn't in the wrong order, I just didn't expect the new note to be at the bottom." What follows is the reading as it stood; the dial's look-then-save grammar is what she then ruled on (R-1036-2).**
- Not located as a defect. Inside one book window every mode reads the same ordered entries, so the navigator and the page cannot disagree by construction (§2, the order dial).
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

## 4b. The design after sitting 1 (her rulings R-1036-1…9 in §5; everything marked PROPOSED is the architect's and waits on the mockups)

### Lanes — a gathering's own shape

- **L-1 What a lane is.** A gathering may carry LANES: an ordered list; each lane is a rule in the gathering's own grammar (and · or · not over tags and the star) with an optional name — a one-tag lane reads as its tag. Lanes partition what the gathering SHOWS. A note files under the FIRST lane, in lane order, whose rule it matches; a note matching none trails under a last group. Nothing is stored per note; a lane is never a chapter and holds nothing. (R-1036-3/-4/-5/-6.)
- **L-2 Storage (the architect's call inside R-1036-5).** ONE new nullable column on `reading` holding the ordered lanes as canonical JSON — the outflow's shape (R-13ic-1: one JSON column, not a join table). A lane's name is her words, so the column travels ENCRYPTED (the `arrival_provenance` class). It is one SyncSpec §12 event: the mirror column first at her go, then both Macs and the phone in one window — a build behind the marker refuses to sync until refreshed. The phone carries the column from that window; drawing lanes on the phone is a catch-up face. *Considered and not pursued:* a `reading_lane` table (chapters' twin) — it would merge two devices' offline lane edits lane by lane, at the price of `Sync/` registry, purge-family and repair work; with one column the later edit wins whole, the standing metadata class.
- **L-3 Order inside a lane** is the gathering's order (the dial). A gathering holds no hand order; a drag WITHIN a lane is the standing teaching moment (bind into a book to arrange by hand).
- **L-4 Where lanes show.** Everywhere the order renders, from the one order home (`Queries.assembleReading`): the Outline's page (a lane heading where a chapter heading stands), the navigator (lane rows with counts, their notes beneath), Index, Book and Read (a lane opens a section as a chapter does), the ⌘↑/⌘↓ stepper and "note N of M · ‹lane›". PROPOSED: an EMPTY lane keeps its heading in the Outline and the navigator (a week must show its empty Wednesday; it is also a drop target and a "+") and is skipped in Book and Read.
- **L-5 Also matches.** A note that also matches a later lane wears one quiet mark on its row — "also: thursday" — naming the others (R-1036-6). It is never drawn twice.
- **L-6 Moving a note between lanes** — a drag under another lane's heading (navigator or page), or Move to Lane ▸ on the note's menu. ONE act: apply what the destination lane's rule needs (the mint's planner, `GatheringMint.outcome` — the one authority the collect door already reads) and remove what the source lane matched on that the destination does not need; then ask the assembly's own predicate where the note files. If that is not the destination, nothing is written and the door says why. The receipt names the tags: "Moved to Tuesday — added #tuesday, removed #monday." Edges, decided on paper:
  - (a) the destination's rule cannot be met by tagging (a legacy date term; a `not` the note breaks with a tag the gathering itself needs) → refuse in the planner's own sentence;
  - (b) removing the source's tags would take the note out of the GATHERING → those tags stay; if the note then still files ahead of the destination, refuse and name the lane that holds it;
  - (c) a move to the trailing group removes what the source lane matched on; if another lane then catches the note, refuse and name it;
  - (d) the applied tag travels the one application road, so a living book that collects it hears it (seat or bell) — the standing receipts say so;
  - (e) undo — PROPOSED: one ⌥⌘Z entry, "Move to Lane", restoring the exact applications (deleteTag's precedent; plain tag applications stay outside structural undo);
  - (f) several notes at once — not in the first build.
- **L-7 A new note in a lane.** Each lane carries its own "+" (its navigator row and its page heading): the note is born wearing what the gathering's rule needs AND what the lane's rule needs, lands in that lane, and is shown ready to type. Where the two cannot both hold, the door is drawn greyed and says why (the gathering mint door's idiom). The gathering's general "+ new note" makes the note in the lane of the note she is on; with none, as today.
- **L-8 Making and changing lanes.** PROPOSED doors: the gathering's settings sheet gains a Lanes section under Collecting — the ordered list, each row "‹name› — ‹the rule as a sentence›", drag to reorder, Edit… (the rule editor), Remove; "+ add lane" (pick a tag — the quick path — or "a rule…"); and one quick start, "a lane for each tag under ‹family›". The New Gathering sheet offers the same quick path: pick tags in order → the gathering gathers any of them and gets one lane per tag. A lane heading's right-click: Rename Lane… · Edit Rule… · Move Up / Move Down · Remove Lane. Removing a lane never untags (the standing law for rules).
- **L-9 The trailing group** reads "unfiled" (the chapter word — one vocabulary) and shows only while it holds a note.
- **L-10 Bind into a book.** PROPOSED: binding a laned gathering turns each lane into a real chapter holding the notes it showed — nothing moves on screen (the bind's standing rule) — and intake keeps running; later arrivals seat unfiled, because a book's chapters do not collect (R-1036-4).
- **L-11 The wire.** PROPOSED for the first build: reads say lanes (a gathering's listing in lane order, the lane named); no wire road writes lanes. `notes/MCPSpec.md` is read before this is built.

### Tags inside a book — the options the mockups show (R-1036-7; Outline first, Index its twin)

- **T-A** a quiet tag line on each note's card, under its title; a click on it opens the tag editor in place (chips with ✕, a field that suggests existing tags and mints a new one on ⏎).
- **T-B** tags on the navigator's rows only; the page stays as calm as today.
- **T-C** tags in the sidebar's "this note" box for the selected or live note — chips and the add field; nothing on the page.
- **T-D** the note's tags in the bottom bar while she types inside a book — her "note menu where the block menu is".
- **The switch** (all options): per book, "tags" shown or hidden, hidden by default; in a laned gathering a lane's own tag is left off its notes' lines.
- In **Index** the same line rides each note's header row.

### New notes (R-1036-8)

- **N-1** Every mint door ends with the new note on the page, live, the caret in it — the navigator foot's doors included (§3a's defect).
- **N-2** Where it is born: a chapter's own "+" → that chapter, at its end; a lane's "+" → L-7; the general doors (the navigator foot, the page foot, ⌥⌘N) → after the note she is on, in its chapter. PROPOSED: "the note she is on" is the live or selected note, else the note the navigator marks as viewed; with neither, the end. Under a stamp order the place is the order's, and the page goes there.
- **N-3** A note born past the 300-note window widens the window to hold it.

### The order dial (R-1036-2 — her words carry doubt; the mockup shows this reading)

- **D-1** A pick on the dial is the book's order at once on a gathering and on a book whose order is not manual. On a HAND-ORDERED book a pick stays a look, and "Save as This Book's Order" is the visible choice beside "Back to manual order" (the hand order is kept in the rows either way). A finished book looks and cannot save, as today.

### A note's title while reading (VX-881)

- **RT-1** PROPOSED: a per-book switch on Read's own controls, remembered per book on this device (a way of looking). The mockup shows two weights for the title: a quiet muted line, and a small heading.

### Wings — search across wings, Starred across wings, a Wings pane (R-1036-9; its own ticket in this umbrella)

What stands today: the 13i sitting §9 ruled total isolation ("nothing should cross wings"); search scopes to one wing; the star LIST is already store-wide and the sidebar filters it to the standing wing (P-13id-U5-10, PROVISIONAL); the Open list already spans wings, its cross-wing rows wearing the wing indicator; wing management lives in the masthead dropdown.

- **W-1** Isolation stays the default. Each crossing is a named, visible choice of hers — never a silent mix.
- **W-2 Search across wings** (R-1036-10). The Library's search gains a scope word beside the field. It ALWAYS starts as "in ‹wing›"; "in all wings" is a deliberate pick, made per search, and a new search (the field from empty to typed — the standing "fresh hunt") is back in this wing. Nothing remembers the wider scope. Results from another wing wear the wing indicator and sit in their own group under this wing's results; opening one follows the standing rule (the app's wing follows the focused note, "Now in …"). A book's own 🔍 stays the book. The Trash and Archived stay per wing. The sidebar's search field is a door into this same search and starts in this wing too.
- **W-3 Leaving a wing out of search.** A per-wing switch, on by default: "Take part in all-wings search". A wing switched off never appears in an all-wings answer; the answer says one quiet line when a wing is not taking part.
- **W-4 Starred across wings** (R-1036-11, held with her doubt). One choice: Starred shows this wing, or all wings (cross-wing rows wearing the wing indicator). A wing stays out of the all-wings Starred by its OWN per-wing switch — separate from W-3's — on by default: "Show in all-wings Starred".
- **W-5 Settings ▸ Wings** — a pane of its own: the wings in the switcher's order, each row with its name (rename), what it holds, its two switches (W-3, W-4), Move Everything… and Delete (refusing unless empty, as today); New Wing; drag to reorder; and the Starred choice. The masthead dropdown keeps its doors. VX-834 (the view a wing opens on) fits this pane.
- **W-6 What never crosses:** gatherings (they assemble within their wing), tag vocabularies, Arrivals, membership, the Trash, Archived, and the wire's reach.
- **W-7 `#tag` in an all-wings search** (R-1036-13, held with her doubt) matches that tag PATH in every wing taking part — each wing's own tag of that path; tags stay per-wing vocabularies. The alternative, for the record: `#tag` meaning only the standing wing's tag, which would quietly narrow an all-wings search to one wing.
- **W-8 ⌘K** (PROPOSED — her "open to suggestions"): the palette stays in this wing, and its results end with one row, "search all wings for ‹words› ›", that re-asks the same words across the wings taking part, in place; the wider scope lasts until the palette closes. The same rule as W-2: wider only by her press, never remembered.
- **W-9 Storage** (R-1036-12 — the choices sync). PROPOSED as synced `setting` keys holding ids and enums only — the Starred choice, the wings out of search, the wings out of Starred ('' is Home, which is virtual and has no row to carry a column). No schema event: `setting` already syncs, and nothing here is prose.

---

## 4c. The mockup brief (round 1)

**Deliverables** — two self-contained HTML files (inline CSS and JS, no external fonts, scripts or images; they are opened from disk, offline). NEVER published as an Artifact.
- `notes/plans/vx-1036/mockup-1-book-and-lanes.html`
- `notes/plans/vx-1036/mockup-2-wings.html`

**The design language** is the app's own, in the Terminal voice (it leads), with a light / dark switch at the top of each file. Take it from the app, not from taste: `App/Variorum/Variorum/Theme/` (the voice tokens, `VoiceControls.swift`), the book view's faces (`Features/BookView/BookView.swift`, `BookOutlineRows.swift`, `BookNoteBox.swift`, `BookMastheadModeRow.swift`, `BookIndexView.swift`), the tag cluster (`Features/Tags/MastheadTagCluster.swift`), the earlier mockups `notes/plans/mockups/13i-bookcase-shelves.html`, `notes/plans/librarywalkpolish-ui-reference.html`, `notes/plans/vx-808-arrivals-review-mockup.html`, `notes/plans/use-report-2026-09-06-mockups/ceremony-and-note-box.html`, and the screenshot `notes/plans/13o-screens/09-book.png` (an October frame of the book Outline: the sidebar with its "this note" box, the navigator column, the page of note cards — the layout to draw, updated per `notes/SurfaceContracts.md` "The Bookcase and books": the mode row with the order dial at its trailing end, the bottom bar with "note N of M · ‹chapter›"). Sentence case in every rendered word; no word capitalised for emphasis.

**Sample content is invented** — a made-up week of small tasks and a made-up book; never the author's real notes, tags or titles.

**Each frame is labelled** with its option letter and one plain sentence saying what it is and what it costs, so she can answer by letter. A short index at the top of each file links the frames.

**File 1 — frames**
1. *Today, for reference:* a gathering in Outline as it is now (no lanes, no tags).
2. *Lanes in Outline* (L-1, L-4, L-5, L-9): a weekly gathering — lanes monday … friday in her order, one EMPTY lane, an "unfiled" trailing group, one note wearing "also: thursday"; the navigator with lane rows and counts; the bottom bar "note 3 of 11 · tuesday".
3. *Moving a note* (L-6): the drag in flight under another lane's heading with the drop line, then the receipt "Moved to Tuesday — added #tuesday, removed #monday."; beside it the note menu's Move to Lane ▸; and one refusal (edge b) in its words.
4. *A new note in a lane* (L-7, N-1): the lane's "+" on the navigator row and on the page heading; the born note live with the caret in it.
5. *Making lanes* (L-8): the settings sheet's Lanes section; the rule editor on one lane ("#tuesday and not #done"); the New Gathering sheet's quick path.
6. *Tags in the Outline — options T-A, T-B, T-C, T-D,* each its own frame on the same book, plus the tag editor open in place (T-A) and the per-book "tags" switch in both positions. One frame shows T-A + T-C together.
7. *Tags in Index:* the tag line on Index's note header rows.
8. *New note in a book* (N-1, N-2): the general door pressed with a note selected mid-book — the new note born after it, live; and a chapter's own "+".
9. *The order dial* (D-1): the menu on a gathering (a pick saves — the receipt), and on a hand-ordered book (the look, "Save as This Book's Order", "Back to manual order").
10. *Titles while reading* (RT-1): Read ▸ Scroll with titles off, then the two weights on, and the switch on Read's controls.

**File 2 — frames** *(amended the same day for her wings answers, R-1036-10…14; the builder was told by message)*
1. *Search in one wing, today.*
2. *The scope word* (W-2): the field with "in ‹wing› ▾" open; an all-wings answer — this wing's results, then another wing's group, rows wearing the wing indicator; and the next search, back in this wing.
3. *`#tag` across wings* (W-7): an all-wings search on one tag — the matches under each wing that has a tag of that path.
4. *Starred across wings* (W-4): the sidebar's Starred in this-wing mode, in all-wings mode with cross-wing rows marked, and with one wing kept out by its own switch.
5. *Settings ▸ Wings* (W-5, W-3, W-4): the pane — three wings, each with its TWO switches (search, Starred), one wing out of search and a different one out of Starred, the Starred choice, New Wing, reorder.
6. *A wing left out of search* (W-3): the same all-wings search with that wing absent, and the one quiet line that says a wing is not taking part.
7. *⌘K* (W-8): the palette in this wing with its last row "search all wings for ‹words› ›", and the answer after the press.

**Cast.** Drawn by a Fable subagent at her word (2026-11-22: "you can actually stop that opus-implementer and have a fable subagent make the mockups"). The Opus worker spawned first was stopped having written nothing.

**Rules for the builder:** HTML only — no app code, no tests, no build, no stage. Work in `~/dev/variorum-vx-1036`; commit each file as it lands, by pathspec, with a plain message and no trailer; push after each commit. Report the two absolute paths and anything the brief left undecided that you had to choose.

---

## 5. Sittings

### Sitting 1 — 2026-11-22 (answered)

The seven questions, as asked in chat: (1) where she saw the order not follow; (2) lanes on gatherings only, books getting them as a look; (3) a chosen ordered set stored on the gathering, or a family ordered per Mac; (4) one lane per note, or shown in every lane it wears; (5) which faces show tags and where the editing door lives; (6) where a new note is born; (7) starred across wings and cross-wing search — here or their own.

Her reply, verbatim:

> 1 - order: I think I'm actually just wrong, and it wasn't in the wrong order, I just didn't expect the new note to be at the bottom. so you can actually disregard this part of the work - I think it was my own confusion when creating a new note that it wasn't visible to me. 2. i like the idea of using lanes, that makes sense and is different from chapters. i do think that it should maybe automatically save as the book's order - i think that's what was confusing me ? maybe save as this book's order should be a choice when you're changing the manual order, I think I had thought I had changed it before. 2. I agree it can be gathering only. not sure what books getting them as a look means. 3. I think it should be a chosen, ordered set of tags stored on the gathering. a schema change seems right to me here - especially because i do want the rules to be able to support exclusion AND OR NOR like our current gathering rules do. 4 - i agree that it should be filed under the first lane in order and have it pointed out that it could match others. showing it twice is not the solution. 5. i've only been in the default book outline, i haven't been using index very much, but I might like to use it. you can mock up the options that you're imagining. i also do want to be able to add new tags from outline, if that wasn't clear. I was imagining something in the this note sidebar, but i feel like it could also be on the note more directly. i'm not sure what it would look like in index. 6. i agree with this. 7. agreed that cross wing search and starred across wings should be a different ticket than this - it can be in the same umbrella though. we should get that fully planned out now too though (like maybe you should be able to exclude a wing from showing up in the all library search deliberately? a wing setting / management page in settings? not sure what thought this needs but I don't want it to be halfbaked).

The rulings, as read from it (each quoted where her words decide it):

| id | Ruling |
|---|---|
| R-1036-1 | **The order report is withdrawn** — "I think I'm actually just wrong … you can actually disregard this part of the work". Its cause was the new note not being visible (§3a). |
| R-1036-2 | **The order dial saves.** "i do think that it should maybe automatically save as the book's order … maybe save as this book's order should be a choice when you're changing the manual order". Held with her doubt ("maybe", "?"); the reading built into the mockup is D-1, hers to confirm there. |
| R-1036-3 | **The word is "lanes"** — "i like the idea of using lanes, that makes sense and is different from chapters." |
| R-1036-4 | **Lanes are a gathering's only** — "I agree it can be gathering only." Books get nothing new. ("not sure what books getting them as a look means" — answered in chat: it meant the Index's existing `group ▾`, which stays as it is.) |
| R-1036-5 | **A lane set is chosen, ordered and stored on the gathering; a schema change is accepted; lane rules speak the gathering grammar** — "a chosen, ordered set of tags stored on the gathering. a schema change seems right to me here - especially because i do want the rules to be able to support exclusion AND OR NOR like our current gathering rules do." The mirror deploy still runs only at her explicit go. |
| R-1036-6 | **First lane in order; the others pointed out; never twice** — "filed under the first lane in order and have it pointed out that it could match others. showing it twice is not the solution." |
| R-1036-7 | **Tags inside a book: Outline first; mock the options; adding tags from the Outline is required** — "i also do want to be able to add new tags from outline … I was imagining something in the this note sidebar, but i feel like it could also be on the note more directly. i'm not sure what it would look like in index." |
| R-1036-8 | **New notes, as proposed** ("i agree with this"): a lane's or chapter's own "+" makes the note there; the general door makes it after the note she is on; it is always shown ready to type. |
| R-1036-9 | **Search across wings and Starred across wings are their own ticket inside this umbrella, planned fully now** — "like maybe you should be able to exclude a wing from showing up in the all library search deliberately? a wing setting / management page in settings? … I don't want it to be halfbaked". |

### Sitting 1, continued — the wings questions (2026-11-22)

Asked in chat: (1) is the search scope picked per search, or does it stay where she left it; (2) does a wing's "stay out" switch also keep it out of all-wings Starred; (3) do these choices sync, or belong to each device; (4) in an all-wings search, should `#tag` match that tag path in every wing; (5) should ⌘K follow the same scope.

Her reply, verbatim:

> 1. search scope should always default to just being within the wing. i think it should be a deliberate choice to search across all wings. 2. yeah, it should stay out of all wings starred. or maybe it should be a different setting? i think that might be best - a per wing "exclude from general starred".  3. i think they should sync. 4. I think so ? I don't see why not, or what the alternative is. 5. i'm open to suggestions on this one.

| id | Ruling |
|---|---|
| R-1036-10 | **Search always starts in the wing; all wings is a deliberate choice** — "search scope should always default to just being within the wing. i think it should be a deliberate choice to search across all wings." Built as W-2: picked per search, never remembered. |
| R-1036-11 | **A wing stays out of all-wings Starred by its own per-wing setting** — "or maybe it should be a different setting? i think that might be best - a per wing "exclude from general starred"." Held with her doubt; W-4. |
| R-1036-12 | **These choices sync** — "i think they should sync." W-9. |
| R-1036-13 | **`#tag` in an all-wings search matches that path in every wing** — "I think so ? I don't see why not, or what the alternative is." Held with her doubt; the alternative is written at W-7. |
| R-1036-14 | **⌘K: hers to rule on the architect's suggestion** — "i'm open to suggestions on this one." W-8 is the suggestion, drawn on the mockup. |

### Round-1 mockups — delivered 2026-11-22

- `notes/plans/vx-1036/mockup-1-book-and-lanes.html` (`0970134c5`) — frames 1–10, 25 sub-frames.
- `notes/plans/vx-1036/mockup-2-wings.html` (`1c55fd78a`) — frames 1–7, drawn straight to the amended list.
- Each file takes `?theme=dark` and `?only=f6&sub=f6a` (added for off-screen checking).
- **Verified by the orchestrator:** both files committed and pushed; no external resource in either source (no `http`, `<link>`, `<img>`, `<script src>`, `@import`, `url(`); every frame id of §4c present; four frames rendered off-screen and looked at (file 1: frame 2 and frame 6 T-A in light, frame 3 in dark; file 2: frame 5 in light). The builder reports looking at most frames in light and a sample in dark, and names six it did not re-view after a last small edit (frame 1's window height, frame 2's foot crop, 3b and 3c in light, frame 6's "off" window, frame 9 in light, file 2's frame 6 in light).
- The colours are the sea-glass computed by `PaletteDerivation`'s rule (the builder checked them against `PaletteDerivationTests`' pins); the metrics approximate the app's and are not a pixel spec.

**What the builder had to choose** (the brief did not say; each is drawn, none is ruled):
- *Layout:* the navigator drawn dragged to 300 pt — by `BookMastheadModeRow`'s numbers the Terminal mode row needs about 276 pt to keep the dial on its line, and at the shipped 190 pt the dial sits on a second line.
- *Lanes:* the sample gathers `#week` with lanes `#monday`…`#friday`; a lane's "+" is a faint "+" after the navigator row's count and a muted "+ new note" at the end of the page heading; an empty lane is its heading alone with a 0; "also: thursday" rides the page card's title line only; the bottom bar's counts are as today; the note box's where-line names the lane where a chapter would stand; Move to Lane ▸ sits where Move to Chapter ▸ does, lanes in order, then unfiled.
- *The one refusal drawn* (edge b), the builder's words: "Not moved — this note would still file under monday. #monday is what keeps it in this gathering, and monday comes before waiting." — on a variant gathering that collects the day tags themselves.
- *Making lanes:* a "lanes" section with "edit…", "remove", "+ add lane", "a lane for each tag under… ▾"; the picker's last row "a rule…"; the lane editor titled 'Rule — "tuesday"'; the New Gathering quick path as one chip, "a lane for each tag: on".
- *Tags:* the quiet line is leaf names in each tag's own colour, no boxes; a tagless note shows a faint ＃; T-B adds through the row's ＋; T-C is tag cards plus the masthead's ＃ door; T-D sits on the Outline's bottom bar; the switch is a chip, "tags: hidden / tags: shown", beside "expand all · collapse all".
- *New note:* drawn with the card she was on still visible above the new one.
- *The dial:* a gathering's menu leads with "As collected"; the receipt 'Saved the order for "this week" — created ↓.'; on a hand-ordered book, two quiet lines under the mode row and two menu rows.
- *Read titles:* a 13 pt muted line and an 18 pt semibold heading; the switch a chip, "note titles: shown", beside Scroll · Pages.
- *Wings:* the scope word drawn INSIDE the field's trailing end (outside it, the controls row would need about 80 pt more than it has at 1270 pt and break its one-line rule); the band's "in: home" chip retires into it; an all-wings answer is this wing first, then one headed group per other wing, band counts the totals; all-wings Starred lists this wing's rows first; Settings ▸ Wings sits after Tags, one card per wing, Home with no grip, rename, move or delete; the left-out line "Kitchen is not taking part in all-wings search."; ⌘K's row 'Search all wings for "ferry" ›' after "All matches in the Library ›".

**What drawing it exposed, with the architect's disposition** (PROPOSED unless marked hers):
1. *A move into a lane that leaves out a tag the note wears* (a `#done` note into "#tuesday and not #done"): **HERS.** Lean: refuse and say why — a move adds what the destination needs and removes only what the source lane matched on; it never removes a tag for another reason.
2. *What the tag line leaves off:* **HERS.** Either every tag, or everything except the tags that already explain where the note sits (the gathering's own and its lane's).
3. *T-C and T-D are nearly one place:* inside a book the block menu lives in the sidebar's note box, so her "note menu where the block menu is" IS the note box (T-C); the book's only bottom bar is the Outline's position bar (where T-D is drawn). Hers to see.
4. *A lane's name:* a one-tag lane reads as its tag; a lane with a longer rule asks for a name when it is made, the field offering its first tag's name. PROPOSED.
5. *"Unfiled" in a quick-path gathering* never shows (the gathering gathers exactly its lanes' tags) — it appears only where the gathering's rule is wider than its lanes. No decision.
6. *Where the new note lands on the page:* with the note she was on kept in view above it (the minimal-reveal idiom). PROPOSED.
7. *When the wider search scope ends:* when the field is cleared — so "all wings" may be picked on an empty field and holds for the search typed next. PROPOSED, inside R-1036-10.
8. *⌘K's "All matches in the Library ›" pressed after widening* carries the all-wings scope with the words (the sidebar field's precedent). PROPOSED.
9. *All-wings Starred's order:* **HERS.** Drawn as this wing first; the alternative is her one star order as she keeps it, cross-wing rows marked.
10. *A wing with "Show in all-wings Starred" off* still shows its own stars while she stands in it — the switch governs only other wings' view. PROPOSED.

### Sitting 2 — opens on the round-1 mockups

Hers to answer there: the tag option(s) by letter and item 2 · item 1 · D-1 as drawn · the PROPOSED lines of §4b (L-4's empty lane, L-6(e)'s undo, L-8's doors, L-10's bind, RT-1 and its weight) · items 4, 6, 7, 8, 10 on sight · item 9 · W-8's ⌘K row · the wings pane as drawn, and R-1036-11 and -13 confirmed or changed on sight.

---

## 6. Ledger

| # | Item | Ticket | Status |
|---|---|---|---|
| 1 | Tags seen inside a book, with the choice not to see them | VX-1038 | DESIGN — T-A…T-D on the mockup; her pick owed |
| 2 | Tags added and removed from inside a book | VX-1038 | DESIGN — same |
| 3 | Lanes in gatherings | VX-1037 | RULED (R-1036-3…6); L-1…L-11 on the mockup; the PROPOSED lines owed |
| 4 | A note's title while reading a book | VX-881 | DESIGN — RT-1 on the mockup |
| 5 | A new note in a book is shown ready to type, born where its door stands | VX-1039 | RULED (R-1036-8); §3a traced by reading; the pin is the build's first act |
| 6 | The order she picks vs the reading order | — | WITHDRAWN (R-1036-1) |
| 7 | The order dial saves as the book's order | VX-1040 | RULED WITH DOUBT (R-1036-2); D-1 on the mockup |
| 8 | Search across wings · Starred across wings · the Wings pane | VX-1041 | DESIGN — W-1…W-6; sitting 2's questions |
| 9 | The lanes column — the §12 event | VX-1037 | Accepted in principle (R-1036-5); the deploy at her go; `notes/SyncSpec.md` in full before the build |

**Sizing, as it stands:** lanes (with their schema event) and tags-inside-a-book are each a phase-sized unit; the wings ticket is a third; the small ones (rows 4, 5, 7) are a fourth, runnable first. The guidance caps a phase at two units — the split into runs is hers to rule when the design closes.

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
