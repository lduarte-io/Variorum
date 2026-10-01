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

## 17. HER RULINGS ON §16 — same day, the record's second pass

- **(a) RULED — the starter shelf IS "Welcome."** Her words: *"I thought we decided that the
  starter shelf would be named 'Welcome' earlier in this chat. It will be."* So: ONE shelf at
  birth, named Welcome, holding the seeded content; ordinary and renamable; new books land on it
  until she makes shelves (dangling shelf pointers read as the first shelf, which is Welcome).
  *Design note, recorded honestly: the round-6 rationale (seeing shipped books SEPARATED from
  yours) is fully satisfied the moment any second shelf exists; if birth-time separation is ever
  wanted, a second "Your books" shelf at first mint is a one-line tweak — not ruled, just kept.*
- **(b) RULED IN — the classics lesson ships:** Sherlock owned · Jekyll plain · both `#classics` ·
  the seeded classics gathering on Welcome · the seeded quicknote. Hide-owned global default
  stays show-badged (the dependency).
- **(c) explained, stands as a UI-pass detail:** this is her own "the numbers of each thing should
  be dismissable or at least collapsible into a small icon" about the Bookcase masthead's
  "8 books · 3 gatherings · 4 shelves" line; only the exact collapse gesture is open.
- **(d) explained, stands unless she objects:** intake rules may reference TAGS and the STAR,
  combined with and/or/not ("tagged video-ideas AND starred"). Excluded for v1: date-, length- and
  churn-shaped predicates ("edited this month") — they have no event for event-driven intake to
  fire on, and a gathering of them would be a search wearing a book's clothes.
- **(e) RULED — minimal naming, nothing deeper.** Her words: *"it can say it was in a different
  wing but I don't think we should have much more detailed linking than that, maybe move back to
  that wing for more or something? I don't want to encourage too much cross wing behavior."* The
  lineage door names the wing ("copied from a note in [Imports]") and at most offers a plain
  go-to-that-wing road; no preview, no content pulled across, no deep links.
- **(f) RULED — the Index masthead.** The grouped-by control lives as proposed.

## 18. THE SWEEP ADDENDUM — details recovered on her ordered re-read of the whole sitting

*(Her instruction: "do a thorough sweep where you actually re-read our conversation and make sure
that no details were missed." The re-read found these five absences plus small notes; everything
else checked present — the manuscript/editions idea §5+§13, the kanban drag-retag §13, shelf
reordering §7, the 13o handoff §12 all verified.)*

1. **THE IN-BOOK FILTER BAR — her ORIGINAL sitting ask, and the record's one significant miss.**
   Her opening message: *"being able to either filter a book within itself for a subset of the
   tags, or make a new book to look at just the tags, is important."* RULED capability: a
   view-local filter bar on a book's (and a gathering's) Index — filter the view by tags/star,
   NEVER mutating membership — plus the **"Save this filter as a gathering"** door (rule = the
   book's tag association ∧ the filter; this is where the boolean grammar earns its keep).
   Slot: mechanics 13i-b, face 13i-d. The future groom door (§13) composes on it (filter + bulk).
2. **THE SHARING/PUBLISHING BOUNDARY** (ratified at the round-3 ratify list: *"excellent point on
   the sharing / publishing boundary — owned should stay a crisp per book fact"*): an owned,
   sealed book is the natural future unit to share read-only or export (commercial someday);
   one standing reason Owned is a crisp per-book fact on the row. Future-ledger line.
3. **THE TRASH LIFECYCLE** (decided at the lifecycle-sweep round, missing from §6): books list in
   the Trash beside notes, kind-labeled. Restore follows the exact-stamp rule — the
   delete-book-and-notes road (one stamp) returns WHOLE; book-only deletes tombstoned the
   memberships on the book's stamp, so restore re-points the released notes home; a member
   independently deleted after the book stays dead (the standing documented corner). SHELVES are
   not Trash objects — deleting one returns its books to the first shelf, cheap metadata, no
   tombstone ceremony.
4. **COMPETING OWNED BOOKS on one tag** (the doorbell sketch's clause, carried into the ruled
   design): both see the arrival; first claim wins; the other book's arrival row reads
   "claimed by [Book]." Nothing destroyed, nothing silent.
5. **MOBILE PARITY** (the standing mandate, unstated in the record): every ruling here is
   phone-expressible by design — the Bookcase/shelf strip as a list, Arrivals, the Collecting
   sentences, the confirms; each 13i run's closeout owes its `notes/MobileSoul.md` ledger row.
6. **Small notes:** ⌘K learns shelves and gatherings (go-to rows; "go to shelf" is nearly free) ·
   books serve READING too — imported/seeded material; nothing in 13i may assume a book's notes
   are self-authored · the tutorial's Work story teaches "the Work is a SHELF; a wing when you
   want true separation" (her wings-stay-big imagining, taught).

## 19. THIRD PASS — her final rulings + the last anything-else harvest (2026-09-30)

**Her rulings:**
- **NEW BOOKS LAND UNSHELVED, not on Welcome** (her words: *"new books shouldn't land on the
  welcome shelf — they should land in 'All' until you move them to a distinct shelf"*). This
  SUPERSEDES §17(a)'s landing clause and §7's dangling-reads-as-first-shelf line: a dangling/NULL
  shelf pointer means UNSHELVED; unshelved books show in All (their own run) and in no shelf's
  solo view; **Welcome holds the SEEDED content only**. Deleting a shelf now returns its books to
  UNSHELVED (no longer "the first shelf"). §17(a)'s "Your books second shelf" design note
  DISSOLVES — her ruling achieves the round-6 separation outright.
- **The masthead collapse — (c) RULED CLOSED:** click to collapse, click to expand, hover to
  reveal while collapsed; the state REMEMBERED (a small local memory, never a Settings-pane row).
- **(d) RATIFIED:** tags + star, with and/or/not; no churn-shaped rules inside books — her words:
  *"we'll make sure that search is good and maybe add a very capable search within a book if
  needed"* (13o's within-a-book scope already carries this; her sentence added to its row).

**Completing (d) — three mechanism details (PROPOSED defaults; standing unless she objects):**
- **Subtree matching:** a tag term matches the tag AND its descendants (`video/` matches
  `video/ideas`) — the app's standing tag-subtree convention; wanting only the exact tag means
  naming the leaf.
- **Rules reference TAG IDs, never paths** — `renameTag` can never break a rule; the rule's
  display derives from the live path. A term whose tag is deleted matches nothing and reads
  "(deleted tag)"; machinery never rewrites a rule.
- **Unstar/untag are NON-EVENTS for intake** (rows are truth; eviction never) — only the applying
  act fires. (A gathering, being derived, reflects unstar/untag instantly as always.)

**The final harvest (PROPOSED, each cheap now; standing unless she objects):**
1. **Context mint:** + New Book while a shelf is solo'd lands ON that shelf (you're looking at
   where you're filing); from All, unshelved. Without this, a book minted in solo view lands
   invisibly outside the current view.
2. **The unshelved run renders LAST in All** (the unsectioned-renders-last convention); the
   new-book flash/scroll covers discovery (the 18l arrival idiom).
3. **Journal and Quicknotes start UNSHELVED** — they are her working objects, not samples;
   Welcome = the field guide + the classics trio, nothing else.
4. **Starred GATHERINGS join the upper-left Starred section** exactly as starred books do (one
   star, every shelf citizen).
5. **Arrivals under Finished are inert, kept:** finishing pauses intake AND judgment — pending
   arrivals stay, untouched, visible if looked at; un-finishing finds them plus the gap's
   catch-up (§4).
6. **Binding preserves identity:** the gathering's row IS the book's row (same id; the mode
   flips) — name, star, shelf spot, glyphless chip, everything survives the bind.
7. **The 13h question stays DELIBERATELY OPEN:** this sitting built the wings machinery but did
   NOT rule an Imports wing into existence — 13h's own kickoff decides it on the machinery
   (its row's "if 13i rules it" resolves to: the machinery yes, the Imports wing itself is 13h's).
8. **EDITIONS and TEMPLATES now have DURABLE FUTURE ROWS** in `notes/FuturePhases.md` (her
   instruction: *"the future manuscript capability / potential should be saved too"*) — each a
   valid KnownIssues owner from today, each pointing back at this record (§5/§6/§10/§13).

## 20. FOURTH PASS — the last items (2026-09-30)

- **WITHIN-SHELF REORDER — RULED IN** (her ask: get it done ahead of time): drag books within a
  shelf, plus context-menu **Send to Top / Send to Bottom** — and her rider honored by the
  mechanism itself: ONE position sequence per shelf, display sorted (starred first, then
  position), so Send to Top writes the smallest position and an unstarred book tops the unstarred
  run — *"send to top would still be underneath starred"* — while a starred book sent to top tops
  the starred run. No special cases. Doors: drag + the context menu; slot 13i-d (positions are
  13i-a's columns either way).
- **QUICKNOTES — RECOMMENDED SHAPE (proposed, standing unless she objects; her conflict
  recorded):** Quicknotes stays an ORDINARY seeded gathering on `#quicknote` — no special
  identity, no delete guard. The reasoning: the quick-entry door's contract is that it TAGS what
  it mints `#quicknote` (a fact of the door, like an auto-tag); the gathering merely shows the
  tag. Unlike the daily Journal (whose guard earned its place because ⌘J FILES INTO it — a
  destination), Quicknotes is not a destination: nothing files into it, so deleting the gathering
  breaks nothing — quick notes still land, still tagged, still findable in the tag's own listing,
  and the gathering is re-makeable in one gesture. Two special books is one more than the design
  needs. **Her removal question CONFIRMED yes:** removing the `#quicknote` tag from a note removes
  it from Quicknotes instantly — a gathering is derived, and evict-on-untag is its definition.
- **REMOVING A NOTE FROM A BOOK — the doors, enumerated** (her question; the OP exists —
  `removePostFromReading`, a membership tombstone; the note lives on in its other books or the
  Pool, tags untouched, and tombstone-means-decided keeps intake from re-adding):
  **"Remove from this book"** on the note row's context menu in the book's Index/Outline, on the
  Book Panel's row menu, and in the sidebar note box's book context. On an OWNED book the same
  door reads **"Release from this book"** (the note goes bookless, to the Pool) — the vocabulary
  carries the ownership distinction. On a GATHERING there is no remove door, because there is no
  membership — the honest door is offered instead: *"Remove the #video-ideas tag."* All three
  speak receipts; slot 13i-c (refusals/ops) + 13i-d (faces).
- **Binding preserves identity — RATIFIED** (§19.6 stands as ruled).
- **The IMPORTS WING — her lean recorded for 13h's kickoff:** *"I think it should exist as the
  default option when importing, but not something for 13i to solve either way."* 13h's rows
  updated to carry the lean; this sitting hands over the machinery and nothing more.

## 21. THE UI ROUND OPENS (2026-09-30) — the design-language ruling and mockup v2

- **Her critique of mockup v1, recorded as the round's brief:** the app's standing look is
  *"stately, chill, performant and uncluttered… the takes area is also calm even when lots is
  going on"*; the flat underline under a selected tab is *"a bit of an AI hallmark"*; v1
  *"doesn't really match the feel of the whole app."*
- **THE DESIGN-LANGUAGE ANCHOR (the round's rule):** the Bookcase borrows ONLY from the app's own
  shipped idioms — the book view's MODE ROW (selection = ink + weight, no underline, no pill: the
  `Outline Index Book Read` idiom she called clean) and the Library's gray SECTION LABELS over
  hairlines (`Books` / `Notes`). External touchstones for taste, not copying: iA Writer ·
  Things 3 · Ulysses · a well-set book's front matter. **Mockup v2 rebuilt on this**
  (`notes/plans/mockups/13i-bookcase-shelves.html`): Direction A (the recommendation — the
  contents-page shape), Direction B (shelves as sidebar children, Apple-Notes-folders style; most
  native, but moves the verb off the page), Direction C (masthead dropdown — DECLINED for shelves
  by her own verb-visibility ruling; noted as the right shape for the WING switcher, her sketch).
  v2 removes: the underline, inline counts (hover + the overflow panel carry them), the
  "3 · default" annotations, glyphs-by-default, pills of any kind.
- **THE DETAILS TOGGLE — RULED** (her ask: the right-hand numbers were *"already trending towards
  crowded"*): a per-surface setting hiding the row meta (counts, words, status words), remembered;
  a quiet "details" word at the shelf line's end. **Arrivals stay visible with details off**
  (proposed: arrivals ask for judgment, numbers don't).
- **Two shipped-app face fixes routed to 13i-d's vocabulary/polish sweep** (pull earlier as a 17
  entry at her word): the Library's segmented control says **"Posts" → must say "Notes"**; the
  "edited · newest first" dropdown is slightly misaligned, and "on day…" wants clearer wording
  (its RANGE capability is 13o's, below).
- **Reference surfaces she named as RIGHT, recorded as anchors:** the current book view
  (navigator + cards) — *"clean, and I like it"* — and the Library's "Books" header with its icon.

**13o items filed this round (written onto its row):** the Library's 40-result cap with
"narrow the search" and no road to more is *"definitely not acceptable"* (her words — full
browsing: infinite scroll or an old-timey pager; "Library should show anything"; her stranded-notes
report after the tutorial re-seed is the proof case); the day filter gains a RANGE; the
many-books case (a bounded books section with its own scroll — her lean — or count + click-through).

## 22. THE CENSUS ROUND (2026-09-30) — Direction A ruled; the place/finder boundary

- **DIRECTION A — RULED** (*"I still prefer option A — I don't want the sidebar to become more
  full"*; and on v2 overall: *"the shape of it is right… you're right that the web ui elements
  are what was throwing it off."*)
- **THE PLACE/FINDER BOUNDARY (proposed, standing — the answer to her observation** *"Shelf is
  starting to look a lot more like Library, but for books… we haven't perhaps made the necessary
  adjustments and decisions to support it being that way yet"***):** the Library is the FINDER
  (derived order, search, time filters); the Bookcase is a PLACE (hand-arranged, stable). The
  dividing rule: **search boxes and time filters never come to the Bookcase; facet-soloing and a
  view-local sort overlay may.** The full finding experience over books is Library's Books
  section + 13o's facets — already handed over. This rule is what stops the two surfaces
  converging.
- **THE CENSUS LINE (her idea, shaped; built into mockup v3):** the masthead counts move to
  their own quiet second line where **each term is a filter** — click "3 gatherings" to solo
  gatherings, click again to clear (ink + weight, the same idiom; a shelf with no matches folds
  away). The **⋯** opens the full census as a dropdown with counts — owned · living · sealed —
  her "prune those in particular" want, kept off the line so the line stays three terms. The
  RULED COLLAPSE GESTURE now applies to this line (fold to ··, remembered). Of her two floated
  shapes (visible selectable line vs glyph-dropdown-only), the built shape is the line + the ⋯
  tail — the dropdown-only alternative stands recorded.
- **THE BOOKCASE SORT (her want, shaped):** `order · shelf order ▾` at the census line's right —
  view-local: **shelf order (default) · last edited** — an overlay that never rewrites the
  arrangement (A31's view-local precedent, one level up). **Mechanism note:** a book's "last
  edited" is DERIVED (max over its members' touch stamps), computed or cached LOCALLY — never a
  synced column on `reading` (a per-keystroke book-row write would storm the outbox).
- **THE SPEC CAUTION — hers, binding on every 13i-d brief:** *"I would caution the spec to not
  build EXACTLY to these details because there's still rounded edges, for example, that the
  regular app doesn't have. the shape of it is right."* The mockup fixes the SHAPE and idiom;
  the build uses the app's own tokens, spacing, type and corner conventions throughout.

## 23. THE № ROUND (2026-09-30) — the census line killed; her rulings

- **Quicknotes shape (§20) — RATIFIED** (*"quicknotes shape is fine"*).
- **The place/finder BOUNDARY RULE — RULED** in her restatement: *"not letting the bookshelf get
  too much more machinery and keeping that to the library."*
- **DETAILS OFF HIDES ARRIVALS TOO — her overrule of §21's exception, RULED:** *"the point is
  that the chrome can be clean if desired."* Her floated future — a filter showing only books
  with arrivals — is folded into the census panel below, built for free.
- **THE CENSUS LINE IS KILLED — her diagnosis, verbatim-faithful:** *"the shelf options
  themselves can't have anything above them — they're a STRONG subheading, not this weird third
  tier."* Her two alternatives (no numbers at all · a collapsed-by-default glyph beside the
  order control) MERGE into the built shape, **the № census** (mockup v4): the shelf row sits
  directly under the masthead; its right end carries the one quiet utility run —
  **№ · order ▾ · details**. The № mark, default collapsed to just itself (numbers effectively
  hidden — her "don't show at all" lean honored), opens the census panel: every count, each row
  a SOLO filter — books · gatherings · finished · owned · living · with arrivals. ONE line
  between masthead and content, ever.

## 24. THE CLOSING ROUND (2026-09-30) — the defaults ratified, two overruled, the sort ruled; READY TO BUILD

- **§19 RATIFIED by her, item by item:** subtree matching (1) · rules remember tags by ID (2) ·
  un-tag/un-star are non-events (3) · context mint (4) · Journal and Quicknotes start unshelved
  (6) · starred gatherings in the Starred section (7). Bind-preserves-identity was already hers.
- **§19.5 OVERRULED — unshelved renders at the TOP of All**, under its own collapsible
  "unshelved" header: *"they're the least convenient to find elsewhere… the Unshelved can just
  be collapsed if needed."* Its books remain manually orderable like any shelf's.
- **§19.8 OVERRULED — FINISHING A BOOK DISMISSES ITS PENDING ARRIVALS** (born-tombstoned decided
  rows): *"you're finishing the book… it would be cluttered for arrivals to hang out on a
  finished book."* The finish confirm carries one line ("N waiting at the door will be
  dismissed"). Consequence recorded: a dismissed arrival returns only on a FRESH tagging act
  (tombstone-means-decided); the un-finish catch-up covers the gap only.
- **THE BOOKCASE SORT — RULED (supersedes §22's two-option sketch):** `order ▾` = **A–Z (the
  DEFAULT** — her words: *"the cleanest rule for all and makes it seem more neat and serious"*)
  **· last edited · my order**. "My order" is the PLACING MODE — drag and Send to Top / Bottom
  live there; it **remembers every placement and appends never-placed books at the end**
  (mechanically free: fractional positions persist across mode switches; new books mint
  end-positions). The chosen order applies WITHIN EVERY SHELF and the unshelved run; starred
  books float first under any order. View-local, remembered. ("my order" as the label is a copy
  candidate — 13s may re-word.)
- **SHELVES STACK IN STRIP ORDER — RULED:** All's top-to-bottom is the strip's left-to-right,
  *"that will make it clearer for people how the reordering works."*
- **MANY SHELVES — CONFIRMED (her check; the earlier design stands, now precise):** the strip is
  ONE line that never wraps, scrolling horizontally with an edge fade; when overflowed, a pinned
  **⋯** opens the type-to-filter shelf panel (the v1 overflow design, kept); the shelf
  right-click gains **Move to Start / Move to End** (her send-to-start); drag-to-reorder stands.
- **Build note from her:** clear air between the shelf names and the utility run (№ · order ▾ ·
  details) — in the mockup; the build spaces by the app's own tokens (§22's caution binds).
- **HER CLOSING WORD — THE UI ROUND CLOSES:** *"I do think that this UI shape looks correct and
  I'm ready for it to be built."* Mockup v5 is the visual record; the shape binds, the
  incidentals don't (§22).

## 25. THE TUTORIAL CURRICULUM — the books chapters (written at her instruction as SECONDARY ACCEPTANCE CRITERIA)

*(Her ask at the close: the tutorial's teaching list, written now, "so it can function as a
secondary sort of acceptance criteria / sanity check." The rule of this section: every lesson is
a sentence the field guide must be able to say TRUTHFULLY of the shipped build — if the build
makes any sentence false, the build is wrong, not the sentence. The WORDS are hers (the 13s copy
landing re-voices everything); this section fixes WHAT is taught. The chapter itself is built at
13i-d, sized at that kickoff per the brief's 2026-08-19 addition; the walk asserts the rituals.)*

**The lessons — each sentence a pin:**

1. **The three kinds.** "A gathering shows you every note matching its rule — it holds nothing.
   A book holds its notes as members. An owned book is the only place its notes live." *(§1)*
2. **The edit law, her sentence nearly verbatim.** "Editing a note that is in a book is always
   editing every book it appears in — owned or not. Adding a note to a book never copies it.
   A copy only ever happens because you asked for one, and it always remembers where it came
   from." *(§2)*
3. **Gatherings.** "A gathering is made from a tag. Remove the tag and the note leaves on its
   own. You can't rearrange a gathering — bind it into a book to take it in hand, and it keeps
   collecting after you do." *(§3, the bind door)*
4. **Arrivals.** "A collecting book auto-adds freely; anything it can't seat on its own waits at
   Arrivals for you to judge — add it, copy it in, or dismiss it. Finishing a book dismisses
   whatever is still waiting." *(§4, §24)*
5. **Owned.** "Put a note in an owned book and that book is its home. Want it elsewhere too?
   You'll get a copy, and you'll know. Remove it and it goes back to the Pool, whole." *(§6, §20)*
6. **Finished and Sealed.** "Finished means the table of contents is done — the writing inside
   can still change. Sealed means the book is done." *(§5)*
7. **The Bookcase.** "Your books live on shelves, alphabetical until you choose otherwise —
   switch to your own order to place them by hand. The shelves run left to right exactly as All
   stacks them top to bottom. Unshelved books wait at the top until you file them." *(§7, §24)*
8. **Deleting.** "Deleting a plain book never touches a note. Deleting an owned book asks: keep
   the notes (they go to the Pool) or take them too. The Trash gives back whatever went in
   together, together." *(§20, §18.3)*
9. **The daily Journal.** "The daily Journal is an ordinary book that is special in one way:
   it's where ⌘J and Today's Entry file. You can archive it; you can't delete it; it comes back
   when a day arrives." *(§10)*
10. **The Pool.** "The Pool is every note with no book. Notes that show in gatherings tuck
    behind the count in its masthead — one click shows them." *(§8)*
11. **Wings.** "A wing is a separate library in the same app — a different room in the same
    house. Nothing crosses between wings except what you move or copy yourself." *(§9)*

**The rituals (taught by DOING — the walk asserts each; the 2026-08-19 ruled ritual extended):**

- **R1 — the classics walk (the seeded lesson, §7/§17):** open the *classics* gathering on the
  Welcome shelf; see Jekyll's and Sherlock's notes side by side; notice Sherlock's wear the
  owned mark; open one through it and land in its book.
- **R2 — membership, by hand (the 2026-08-19 ritual, kept):** make a book, a chapter, a note
  inside it; add the same note to a second book; edit it and see both books change; delete one
  book and watch the note survive.
- **R3 — the gathering's life:** tag two notes; make a gathering from the tag; untag one and
  watch it leave; bind the gathering into a book; reorder it; untag the other and watch it STAY.
- **R4 — ownership's boundary:** flip a book to Owned; try adding one of its notes to another
  book and meet the copy choice; remove a note and find it in the Pool.
- **R5 — the shelf gesture:** drag a book onto a shelf name; switch order to "my order" and
  place one by hand; star one and see it float.

**The sanity check, verdict:** every ruling compressed to a plain sentence on the first attempt —
no lesson needed a second clause of exceptions, which is the design telling us the shape is
right. The two subtlest facts stay OUT of the tutorial deliberately and live in the record
instead: a dismissed arrival returns only on a fresh tagging act (§24 — behavior, discoverable,
not curriculum), and the census/№ needs no lesson at all (it explains itself on click — if a
tester ever asks what № does, THAT is the finding).

**NEXT: awaiting her kickoff of `/architect-phase 13i-a`.** Nothing in this record remains
proposed — every section through §25 is ruled or ratified.
