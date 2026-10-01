# Phase 13i — THE DESIGN SITTING RECORD (2026-09-30)

**Status: THE BINDING RECORD of the 13i design sitting.** The author attended the whole sitting;
every ruling below is hers, verbatim-faithful where quoted. This record SUPERSEDES the open knots of
`notes/plans/phase-13i-smart-book-identity-brief.md` (the brief stays as raw material and history —
§ "Dispositions" below answers it item by item) and carries the design for all five runs of the 13i
split (a–e). Her framing at the open: *"Nothing that is in the plan right now should be considered
binding — this is the session in which we'll be deciding the best shape for things."* Her closing
instruction: write this record, update the plans (including 13o's inputs), surface everything now in
doubt — then iterate the UI on top of the recorded plan.

**The mockup (part of this record):** `notes/plans/mockups/13i-bookcase-shelves.html` — the
Bookcase/shelves design in four states (State A live), the restyled strip, the Pool tuck, the
overflow panel. The UI iteration pass continues on it AFTER this record, at her word.

---

## 1. THE SHAPE RULED — three nouns, one row underneath

**The ladder (ruled):**

| noun | holds rows? | answers |
|---|---|---|
| **Gathering** | no — it shows | "visible here" |
| **Book** | yes — members | "membership here" |
| **Owned Book** | yes — exclusively | "there is no second place it lives" |

- A **GATHERING** is a saved rule (tags/stars, boolean), assembled at read, always current. It has
  NO membership rows — *"if it's mirrored, it's just showing items that are elsewhere"* (hers; the
  sitting's working terms "mirror/collect" are RETIRED in favor of gathering/book). It evicts when
  the tag/star goes away, by definition. **Her coinage, for the bookbinding term** — a gathering is
  the folded bundle of pages not yet sewn into a book: *"it can be bound into a book and that makes
  sense as a name + action."* ("Smart" declined — *"I just hate when things are called something
  Smart as a general pet peeve"*; "Mirror" declined — *"worrying to me precisely because of the idea
  that it's a mirrored copy — it's not, it's the same [note]"*; "Lens" declined by Fable — hard
  collision with the ratified lens vocabulary and the Lenses mode; "Pointer"/"Auto"/"Window"
  considered and passed over.)
- A **BOOK** is membership rows as truth (the ratified "membership rows are curated truth" line,
  now the whole story): orderable, chapterable, finishable, sealable, ownable.
- The full vocabulary, ruled in her enumeration: *"there's a Gathering, a Book, an Owned Book, a
  Finished Book, a Sealed Book, and a Living book (which could be an owned book as well)."*
  **LIVING BOOK** = any book whose intake is on (the adjective freed up by the gathering noun — her
  observation). **Finished/Sealed/Owned** are §5–6 below. All sensible combinations legal (an owned
  living book is the claiming book; an owned daily Journal is *"a perfectly acceptable choice"*).
- The two strengthenings are DIFFERENT DOORS, visibly: gathering → book gains **membership**
  ("Turn into a book" / binding); book → owned gains **exclusivity** ("Own its notes"). Her
  closing read: *"the shape is finally feeling cohesive… It's also more clear why something can be
  in an Owned book and STILL appear in a gathering — it removes the confusion of 'how is this in an
  owned book but still in a different book'."*

## 2. THE EDIT LAW (ruled — zero exceptions; the tutorial's core lesson)

1. **Editing never forks.** A note is one thing; wherever it appears, an edit shows everywhere.
   Her sentence, near-verbatim for the tutorial: *"editing a note that is within a book is ALWAYS
   editing every book that it is in — owned or not owned. That's exactly why you have to be careful
   about whether a book is owned or not."*
2. **Adding never copies.** Membership in a (non-owned) book is a pointer.
3. **Copies are always ceremonies** — the diverge door, convert-to-Owned's copies, cross-wing copy,
   seal-a-shared-book's listed forks — always explicit, always lineage-edged.
4. **Ownership doesn't change the edit rule; it removes the ambiguity.** Her confirmed meaning:
   *"there is no second place it lives — editing it anywhere is editing the book"* (the round-5
   navigation ruling STANDS: a Library click opens the standalone note; the Book Panel is the
   bridge).

Corollaries reaffirmed: I8 (no post-level variant resolution — a book wanting its own version
forks, visibly); OWNED is I2's discipline promoted one level (blocks were always singly-owned with
reuse as copy+lineage; an owned book applies the block's own rule to notes — the religion stays one
religion). Appearance/membership/ownership is the canonical triad; **ownership constrains
membership, tags drive appearance, machinery never touches a tag.**

## 3. GATHERINGS (ruled)

- **Rule grammar:** full boolean — AND / OR / NOT with grouping (her: *"AND, OR, NOR, etc."* — NOR
  composes); terms are tag and star predicates. v1 scope: tag/star terms only; time/churn-shaped
  predicates stay views, not gatherings (PROVISIONAL — QUESTIONS #166(d)).
- **Capabilities:** name · shelf spot · star · sort options · view-local order · the tag-family
  grouped DISPLAY (never real chapters) · the hide-owned toggle. **No** membership, chapters,
  hand-order-as-truth, arrivals (matches simply SHOW), finish, seal, own, word targets, capacity.
  A hand-drag inside one is the teaching moment: "Turn into a book to arrange by hand?"
- **Two doors:** **Bind into a book** (in place — materializes the assembly as membership rows;
  INTAKE KEEPS RUNNING; owned notes in the assembly can't materialize, so the confirm lists them:
  copy in / leave out — leave-out means gone from this book, since a book shows members only; no
  ghost/guest display, deliberately — the 4F memo's union-view warning honored). **Make a book from
  this gathering** (spawn — seeds a sibling, copies the rule, the gathering survives).
- **NO duplicate-gathering operation** (her challenge, ruled out: *"why would we be able to
  duplicate a gathering? what would that even accomplish?"* — making a new gathering is already one
  gesture).
- **Wing-scoped:** a gathering assembles WITHIN ITS WING ONLY (§9).
- The starred-notes item: the master plan's "smart book of starred notes" becomes **a gathering of
  starred notes** — same build-at-13i instruction, new noun. Quicknotes (today a smart book)
  migrates to a gathering.
- P1 note: gathering counts on the Bookcase must never be per-render corpus scans — indexed tag
  counts / cached rollups (her: the bookcase *"shouldn't be slow to gather counts"*).

## 4. BOOKS — membership, intake, auto-tag, Arrivals (ruled)

- **Membership rows are truth. Intake is EVENT-DRIVEN:** it fires on the tagging/starring ACT,
  never on tag state. Her ruling closing the brief's sharpest knot: *"I agree with the
  departed-match knot being resolved by event driven intake"* — untagging never evicts a member;
  removing a member never deletes the tag.
- **Tombstone-means-decided:** a live OR tombstoned membership row means the pair is decided;
  intake only ever inserts fresh pairs (the `shelveInDailyJournalBook` precedent generalized).
  **Dismissing an arrival writes a BORN-TOMBSTONED membership row** (created and deleted on one
  stamp) — the decision record with zero new tables, deduped by `uq_reading_post_live`, synced as
  an ordinary row (ruled).
- **ARRIVALS** (her name choice over inbox/doorbell: *"a good way of indicating that something has
  recently happened and now has to be judged"*): intake's answer whenever auto-seating is
  impossible or presumptuous. A plain book's intake auto-seats ordinary notes (multi-membership is
  legal) and BELLS an owned-elsewhere note (copy in / dismiss). An owned book's intake auto-claims
  FREE notes and bells membered ones (claim-move / copy in / leave). At capacity (`max_posts`),
  intake waits at Arrivals. **Placement (ruled, her clutter mandate —** *"it's important to me that
  the UI of a book not start to feel excessively cluttered"***):** invisible when empty (the common
  case); when occupied, ONE muted line atop the book's Index/Book surface expanding inline, plus a
  small accent count on the Bookcase row; never a persistent panel. Arrivals ordering: new members
  land at the END, unsectioned (the unsectioned bin already renders last).
- **The join dial (ruled):** per-book, "new matches: **join quietly** at the end · or **wait at
  Arrivals**" — a living book whose order is guarded routes everything through judgment.
- **Backfill vs catch-up (ruled):** CREATION-time backfill (making a living book from an existing
  tag) seats current matches directly — birth = intent. RESUME catch-up (restore from Trash,
  un-finish, rule edit) routes the gap's matches through Arrivals — gap = judgment. A dead or
  paused book's intake runs nothing (ruled).
- **AUTO-TAG (the outflow; her 2026-08-02 direction built):** notes minted inside the book get the
  tag. Setting the rule offers *"also tag the N current members now"* (ruled). A book born from a
  tag gets intake=T and auto-tag=T by default. Removing a rule never untags what it tagged.
- **First hand-reorder adopts manual order** (A31's adopt door promoted to THE transition);
  until then a living book's order may stay derived.
- **The COLLECTING pane (ruled good):** one section of the book's settings sheet, written as
  sentences — "Gathers from: …" · "New matches: …" · "Notes written here are tagged: … [also tag
  the N current members]" — reachable from the book's ⋯ menu and the Bookcase row's context menu.
  **A gathering's settings sheet is the SAME pane** (its rule IS the object), so binding keeps the
  user's mental map. The journal-trait row joins it (§10).
- **Bulk door shipping in 13i:** "apply a tag to every member" (applyTag in a loop, one receipt).
  The general filter+bulk-bar idiom for members is FUTURE (§13), her words: eventual, *"AI could
  probably do that once I add in AI"* — not needed now.

## 5. FINISHED AND SEALED (ruled — two named states; her: "it is worth having the distinction")

- **Finished** freezes the ASSEMBLY: no adds/removes/reorders/chapter-structure (rename free, per
  the standing rule); intake pauses. Text inside members stays editable — "done collecting, still
  polishing" (the poetry collection; the ended period journal).
- **Sealed** = Finished + text immutability (the required scope from her 2026-08-26 "eek" ruling).
  One line: **Finished = the table of contents is done; Sealed = the book is done.**
- **Sealing an OWNED book needs no forks** (the composition prize — sole members just seal).
  **Sealing a SHARED non-owned book** auto-diverges shared members via the diverge composite — with
  the confirm LISTING the notes that will fork (ruled: the one copy-as-consequence in the design is
  never silent). Unseal: the EXACT-STAMP pattern — members whose seal stamp matches the book's
  unseal together; an independently-sealed note stays sealed. Forks are permanent (they're real
  notes).
- **Seal is designed as EDITION ZERO** (ruled: *"seal as edition zero is perfect"*): nothing in its
  semantics may fight the future manuscript-versions feature (§13) — "cut an edition and keep
  writing" must remain a natural extension.

## 6. OWNED BOOKS (the 2026-08-25/26 rulings STAND; this sitting's additions)

- **Owned requires a book** — a gathering cannot be owned; not a restriction, a category error
  (ruled). The brief's round-7 owned-smart option space DISSOLVES: the "owned smart book" is an
  owned living book with Arrivals.
- **Convert door** (her round-4 ruling stands): sole/bookless members become owned in place;
  shared members get exclusive copies right then (diverge-shaped, this book's slot, lineage edge),
  LISTED in the confirm. Un-owning: both doors stand (release one note bookless; flip the book's
  setting off — members stay, exclusivity lifts).
- **Add doors into an owned book:** bookless → move in clean; membered elsewhere → explicit choice,
  **copy in** (original keeps its lives) or **move in** (other memberships severed, listed).
- **Tags ride copies** (default, ruled) — stripping would vandalize the status/type taxonomy;
  the visible-duplicate-in-a-gathering consequence is hers to resolve by hand (untag either), and
  the HIDE-OWNED toggle is the release valve: per-gathering + a global default, scope = gathering
  assemblies, tag listings, search; **Library EXEMPT from the global setting** (R32; 13o's own
  filters compose). Global default = SHOW, badged (the Welcome lesson depends on it).
- **Deleting an owned book — the two-choice confirm (ruled):** *Delete book only* (its N notes
  released to the Pool — nothing of hers destroyed) · *Delete book and its N notes* (both to the
  Trash on ONE stamp). A NON-owned book's delete is book-only and never offers note deletion
  (they were never "its" notes). The asymmetry is the ownership concept, visible at the door.
- **Duplicate:** non-owned → SHALLOW (a sibling pointing at the same notes; "Duplicate with
  copies" optional for a divergent fork); owned → DEEP ONLY (family copies with lineage; the
  duplicate born non-owned). A gathering: no duplicate op (§3). All cheap — rows, never blobs.
- **The badge family (direction ruled; toggleable as a set; silence the common case):** in a book
  view, the ruled shared-membership badge; in gatherings/listings/search, an *owned-by* badge
  (click-through via the panel bridge). Ordinary free notes: nothing, ever.
- **The DOOR ENUMERATION (13i-c work item — "will be important", hers):** every
  membership-creating door consults ownership — addPostToReading, every drag road, ⌘K, the Book
  Panel's drag powers, `shelveInDailyJournalBook` (an owned-elsewhere note bells, never throws),
  intake, bind-a-gathering, restoreReading's membership revival, divergePostForReading (allowed —
  it copies). The record's list is the checklist; missing one is a ladder finding.

## 7. THE BOOKCASE, SHELVES, WELCOME (ruled; the mockup is the visual record)

- **Names:** the sidebar section becomes **Bookcase**; groupings are **SHELVES** (hers: *"lets call
  that section bookcase and a shelf can stay shelves"*). Mechanically a shelf is `reading_section`
  one level up: an ordered named metadata row a pointer names (`reading.shelf_id`; dangling ⇒ the
  first shelf); never a container, never nested. Books live on exactly one shelf.
- **The verb stays visible** (her ruling overriding Fable's flat-until-second-shelf): a fresh
  bookcase shows the strip and the one starter shelf's header from birth. Starter shelf's name:
  OPEN (QUESTIONS #166(a); "First Shelf" is the mockup's placeholder).
- **The strip (State A):** shelf names set like a MODE ROW — quiet sans, generous spacing, no
  pills/fills/borders (her concern ruled: chips read *"overly AI"* against the app's *"very mature
  appearance"*), active = accent + thin rule beneath, counts whispered on hover. The Bookcase opens
  SOLO on the DEFAULT SHELF (choosable — right-click: Rename · Set Glyph · Make Default · Delete);
  **All** stacks every shelf with collapsible headers; past ~ten, trailing shelves fold into a
  "⋯ more" panel with type-to-filter search. Shelf names are DROP TARGETS (drag a book onto one to
  re-shelve; the only rectangle the strip draws is the hairline drag-over outline). Reorder by
  dragging the names or the panel's rows (ruled). Deleting a shelf returns its books to the first
  shelf — never touches a book.
- **Shelf GLYPHS (ruled):** optional, ONE GRAPHEME, monochrome, inheriting the text's ink — the
  callout frame's ruled precedent reused. The curated case: FEW and visually distinct at strip
  size, NO cross (hers), hieroglyphs and the moon IN (☾ · ❧ · ✶ · ◆ · 𓂀 · 𓅓 · 𓆣 as the working
  set), free Unicode entry beyond it. No emoji, no color. Final set gets a legibility pass at
  build.
- **Masthead counts collapsible (ruled):** *"the numbers of each thing should be dismissable or at
  least collapsible into a small icon"* — exact shape at the UI pass (QUESTIONS #166(c)).
- **STARRED ABSORBS PINS (ruled):** one mechanism — the star (notes' vocabulary), floating a book
  to its shelf's top; **a starred book joins the upper-left Starred section** (hers). Migration:
  pinned books become starred. (This closes the master-plan row's "starred books" question.)
- **The WELCOME shelf (her name ruling:** *"it's literally a welcome to the app, designed to make
  you feel comfortable"***):** holds the seeded books in Home. **The sample-library-as-wing agenda
  item (2026-08-31) is CLOSED — superseded**, her reasoning recorded: wings are a power concept to
  discover (*"realistically if we put them in a different wing everyone would use that wing for the
  most part or just not find it"*); the back-dated stamps keep carrying the recency protection;
  cross-wing move exists for anyone who wants Conan Doyle out later.
- **The seeded TRIAD LESSON (recommended-PROVISIONAL, #166(b)):** Sherlock OWNED, Jekyll & Hyde
  plain, both tagged `#classics`, a seeded **classics gathering** on Welcome (one bookcase row,
  zero new notes — the whole ladder visible at first launch, the owned badge teaching itself);
  plus ONE seeded quicknote (ruled) so the Quicknotes gathering is a live example. The field
  guide's books chapter walks it (her books-communication mandate fulfilled by the three rungs +
  the edit law sentence + the classics walk).

## 8. THE POOL (ruled)

Definition stays honest — bookless notes (a gathering showing a note gives it no home). The VIEW
tucks gathering-shown notes behind the MASTHEAD count — "Pool · 2 notes · 14 in gatherings · show"
(moved from a bottom line at her catch: it would drown under a long Pool); an empty-but-gathered
Pool says it in the empty state. Her lean honored: the Pool stops double-listing Quicknotes while
one click and one honest sentence keep it legible. (Her 2026-08-30 Library-filter agenda line is
answered by the same principle: filters are view-time everywhere; a filter worth keeping is a
gathering; Pool stays its own tab.)

## 9. WINGS (ruled this sitting)

**"Honestly, nothing should cross wings — the entire point is that it's basically a whole separate
library, and the language around it should be clear that it's a separate library."** Gatherings
assemble within their wing; search/tag listings/Arrivals all scope by wing; the ONLY crossings are
the explicit move/copy doors (her 2026-08-25 ruling, standing). Wings stay BIG and FEW (her
imagining, recorded) — shelves now carry the everyday grouping load, so "the Work" is a SHELF, a
wing only when true separation is wanted. Language sweep joins 13i-a/d: a wing presents as a
separate library. Design note (the one data-level exception): the lineage edge under a cross-wing
copy exists as a row; surfaces stay wing-scoped and the lineage door merely NAMES the other wing —
confirm at #166(e).

## 10. THE DAILY JOURNAL — 13i-e RULED COMPLETE

- **The daily Journal is an ACTUAL BOOK** (ruled — membership rows; so a note claimed into an owned
  book LEAVES the Journal via the move confirm, or stays via copy-in). Making the daily Journal
  itself OWNED is legal (ruled).
- `profile='journal'` = the trait "entries date-stamped at creation, named by their day, sorted by
  entry date" — **exposed as a per-book settings row** (ruled: "let's do create journal book for
  daily notebooks as a setting"), one sentence in the Collecting pane's sheet: *"Entries:
  date-stamped, named by their day, sorted by date — on/off."* Flipping it off never rewrites
  existing entries. Template kinship recorded (§13): day-named entries are a built-in special case
  of "new notes here start from a pattern."
- `profile='daily'` = THE daily book, per the memo's design — **destination is the designation's
  ONLY meaning** (her 2026-09-04 ruling re-confirmed: where ⌘J and Today's Entry file; nothing else
  special; door discouragement already gone; nothing against two entries on a day).
- **The keeper repair STAYS** (ruled — the alternative was retiring it with the dead concept; two
  fresh devices offline-minting the daily book still converge to one).
- **Never-hard-delete survives on the ⌘J ground** (ruled), wording: *the daily Journal can be
  archived, never deleted; it returns when a day arrives.*
- The memo's remaining letters: (c) ratified as her leans (⌘J stays; Today's Entry the mobile
  button); (f) faces follow (a)–(e).

## 11. SCHEMA & SYNC — THE 13i-a LOCKSTEP BUNDLE (design-level; mirror first, HER explicit go)

One §12 lockstep event, landed before strangers (the 2026-08-25 bundling note executed):
- **wings** (the libraries design as ruled 2026-08-25/26 + §9's total isolation) · **shelf** table
  + `reading.shelf_id` + positions (custom shelf order = shelf order + within-shelf order — the
  must-have lands here) · **intake rule + auto-tag storage** on `reading` (boolean predicate tree;
  `query_spec` recast) · the **gathering/book recast of `kind`** (migration: smart → gathering,
  curated → book; the shipped conversion door recast as BIND; her migration freedom recorded:
  *"there will never be a better time to do it than now, when i'm still the only user"*) ·
  **starred on reading** (absorbing pin) · `profile='daily'` + the journal-trait setter.
- **SyncSpec §7 additions to write:** intake-materialization convergence (two devices reacting to
  one tagging event — `uq_reading_post_live` dedupes; the repair paragraph) · the OWNED-exclusivity
  repair (two devices racing exclusive adds — deterministic, the brief's flag) · born-tombstoned
  dismissal rows ride ordinary row sync · the daily keeper repair retained (keyed on `'daily'`).
- P1: bookcase/gathering counts indexed or cached (§3).

## 12. 13o HANDOFF (written into its row)

1. **The tag-association search join:** a tag's results surface the books/gatherings ASSOCIATED
   with it (intake/auto-tag), top-ranked — her ruling: *"a book can have a tag association already
   so it does not need its own tag — the tags that it gives its writing is enough."* (Book tags
   DEFERRED — no `reading_tag`; nothing precludes it if use demands.)
2. **Mode facets:** gathering / living / owned / finished / sealed as search filters (never tags).
3. The hide-owned global default composes with 13o's Library/search filters; Library exempt.
4. The index is born knowing WINGS with §9's total isolation (the existing "born knowing libraries"
   line, now with the ruled answer).

## 13. THE FUTURE-IDEAS LEDGER (recorded, deliberately NOT 13i)

- **Templates** — a template is a ROLE pointer, not a place (book→note references outside
  membership — the door 13i keeps open AS A BOUND CONSTRAINT: ownership and the Book Panel bind
  membership only; book→note pointers beyond membership are legal). Spawn = the family-copy
  machinery minus dates; tag handling TBD. The journal trait is its built-in sibling.
- **Editions / manuscript versions** — a frozen membership list over frozen note-versions
  (`saveNoteVersion` machinery); Seal designed as edition zero (§5); "Duplicate with copies" is
  the manual fork meanwhile. NOTHING in 13i forecloses it (her check, answered).
- **Drag between tag-groups = retag** (the kanban upgrade of the grouped display; her "love that
  idea").
- **The groom door** — "remove all members without tag X" = the filter+bulk idiom; general bulk
  member actions (her AI note recorded).
- A horizontal board view (Canvas-flavored) · `reading_tag` if use demands · the merge-wings
  rescue door (standing, 2026-08-25).

## 14. DISPOSITIONS — the brief's knots and the standing rulings, answered

1. **Departed-match (knot 1):** RESOLVED — event-driven intake; rows are truth; tombstone-means-
   decided (§4).
2. **Order interleaving (knot 2):** arrivals/new members land at the END, unsectioned; composes
   with `assembleReading`'s chapter ordering (the brief's mechanism fact 9).
3. **Capacity (knot 3):** membership rows counted; intake waits visibly at Arrivals.
4. **Which acts flip identity (knot 4):** THE FLIP DISSOLVES — one species of book; the only
   transition inside a book is first-hand-reorder adopting manual order (A31's door). The
   gathering→book rung replaces the identity question entirely.
5. **Storage (knot 5):** membership rows for every book (materialize-on-event); derived-at-read
   only for gatherings. The load-bearing fork, chosen.
6. **The conversion door (knot 6):** RECAST as Bind into a book — and it KEEPS COLLECTING (her
   2026-07-30 words honored over N38 shape A's stops-collecting; the "(collecting)" offer dies).
   **N38 shape A superseded**; the A31 view-local override survives for gatherings; the adopt door
   becomes the order-adoption moment. **R98 recast:** adding a note to a GATHERING applies the tag
   (survives there — no rows exist); adding to a book is real membership, with auto-tag covering
   the tagging.
7–8. **W11/divider (knots 7–8):** untouched by this sitting — chapters remain assignment targets
   (R28); the divider reading stays declined unless she reopens.
9. **Mechanism fact:** honored in disposition 2.
10. **Book-lock (knot 10):** SHIPPED SHAPE RULED — Finished/Sealed (§5), the listed-forks confirm,
   exact-stamp unseal, owned-book seal fork-free.
- **Round 7's owned-smart option space:** dissolved (§6). **The 2026-08-31 sample-wing item:**
  closed-superseded (§7). **The 2026-08-30 Library-filter line:** answered (§8). **The tutorial
  mandate:** the three rungs + the edit law + the classics walk (§7). **The pre-13u memo (13i-e):**
  ruled complete (§10). **Smart-book vocabulary:** retired app-wide at 13i-d (the row meta's
  "smart" becomes gathering/living).

## 15. THE FIVE RUNS — scope distribution (sizing re-checked at each plan's writing)

- **13i-a** — THE SCHEMA EVENT: §11 whole (wings, shelves, intake/auto-tag storage, the recast +
  migration, starred, daily marker, the §7 repair paragraphs). Fable work (Sync/ rider).
- **13i-b** — gatherings + intake/auto-tag/Arrivals mechanics + the rule grammar + the starred-
  notes gathering + the Pool tuck.
- **13i-c** — Owned + Finished/Sealed + the convert/delete/duplicate doors + the DOOR ENUMERATION
  + the edit-law refusals.
- **13i-d** — the Bookcase (strip, shelves, glyphs, Welcome + the seeded lesson, starred-absorbs-
  pins, masthead collapse) + the Book Panel (+ its "appears in N gatherings" line, names on click
  — ruled) + the Collecting pane + the grouped-by control + the vocabulary sweep (Shelf→Bookcase,
  smart→gathering, wing-as-separate-library language).
- **13i-e** — the daily Journal as ruled (§10; small now).

Her sizing word: *"if you distribute everything we've decided through the 5 phases it'll likely be
fine."* Each run's plan still states its own sizing honestly per `notes/PhaseSizingGuidance.md`.

## 16. OPEN — QUESTIONS #166 (the sitting's PROVISIONALs)

(a) the starter shelf's name · (b) the classics seeded lesson (recommended; her "open to that"
with the crowding caveat — one row, zero new notes) · (c) the masthead-collapse shape (UI pass) ·
(d) intake grammar v1 = tag/star terms only · (e) cross-wing lineage edges (data-level exception,
surfaces scoped) · (f) the grouped-by control's home on the Index masthead (proposed, standing).

**NEXT:** her UI iteration pass on the mockup; then `/architect-phase 13i-a` per the split addendum
(the sitting that R-cor-13 required has now RUN — this record is it).
