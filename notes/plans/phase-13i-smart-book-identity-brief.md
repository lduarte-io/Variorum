# Phase 13i — Smart-book identity (BRIEF; the problem's shape, nothing decided)

**Status: BRIEF ONLY — authored 2026-07-30 at the 13f kickoff sitting,
at the author's direction, verbatim:** *"i would make a new phase with
a short brief on what you know about the shape of the problem
(whatever the next unused letter in the 13 series is I suppose), i'll
just handle it fully in another phase. i haven't really thought
through it a lot yet."* Per her standing instruction the uncertainty
is preserved: this brief records what is KNOWN, binds nothing beyond
her quoted words, and expects to partially stale. The phase opens with
an author-attended design sitting; cast at her kickoff, as always.

## Her direction (2026-07-30, verbatim — the phase's seed)

> "I don't know if that's related to the manual order or if we have a
> different phase addressing the chapter and how if you have an
> 'automatic book' that's just based on tags and you change the order,
> how you're actually making a different book 'object' but I think it
> should be at least noted for that phase if we don't handle it now. I
> think it would probably be best if we allow constantly updating
> 'smart books' based on just tags and then if you try to do something
> (post limit, lock it, new chapter name, manual reordering, etc) it's
> now a named book. and it can still have the smart attributes and
> keep auto adding despite being a particular named book, but I do
> think making changes should mean it has to be a particular smart
> book."

## Her second direction (2026-08-02, the 13k-closeout conversation — book-scoped AUTO-TAG rules)

> "i'm also thinking that in the future, i want to be able to make rules
> so that items created within a book have a tag auto applied to them, so
> that i can actually have different journal 'books' in variorum that for
> a period of time, are all created with the same tag so i can have a
> smart book, while they're still in the journal book overall. i think
> that could even go in the phase 13 plans."

Slotted HERE (recorded the same day, at Fable's suggestion with her
message naming "the phase 13 plans") because it is the same
what-is-a-book territory as the hybrid: it is R98's rule (adding a post
to a SMART book applies the tag) generalized into a standing rule ON a
book — including a CURATED one (her use case is the daily Journal book:
entries keep landing in Journal AND carry, say, a period tag feeding a
smart book). Knots it adds to the sitting's agenda: where the rule
lives (a column on `reading` would be a §12 lockstep event); which
doors apply it (mint-inside-the-book only — her word is "created
within" — or also add/move-in, and the four daily doors of
`shelveInDailyJournalBook`); the "for a period of time" half — does a
rule expire, or does she just remove/replace it (and removing a rule
presumably never untags what it already tagged); and composition with
the hybrid's own collection so two rules cannot loop (a book whose rule
feeds the very tag its own smart assembly collects on).

## What ships today (the baseline this phase would change)

- **N38's shape A** (13c batch 2D, ratified at the 13d sitting via
  #46's "ratify all seven"): converting a smart book MATERIALIZES its
  current assembly as real `reading_post` rows in the order being
  viewed, flips `kind` to `curated`, freezes `sort_field` to manual —
  and the converted book **STOPS collecting**. The filter
  (`query_spec`) and `grouping_tag_id` stay on the row as provenance;
  a fresh "(collecting)" smart book is offered at conversion.
- **The doors:** the shelf's convert menu item; "+ new chapter" on a
  smart book (converts, then prompts). Adding a post to a smart book
  tags it instead (R98); order is controllable on any book (A31's
  view-local override + the "Save as This Book's Order" adopt door).
- **Chapters are curated-only** (#25(a)): smart books refuse
  `createSection`; their sectioning stays tag-derived
  (`grouping_tag_id`).

## The shape of the problem (what her direction reopens)

Her direction is essentially **the hybrid the 4F design memo called
shape B** — a book that is at once hand-curated (chapters, order,
extents, lock) AND still collecting from its tags. QUESTIONS #46(1)
recorded why shape A was built in her absence: B's consumers must all
learn a **union of derived matches and pinned rows**, and the memo
named the knots that need HER rulings, not defaults:

1. **The departed-match knot (the sharpest):** a post you chaptered
   or hand-placed whose tag you then remove — does it stay because
   you curated it, or go because it no longer matches? Either answer
   surprises someone; the memo judged it unanswerable by default.
2. **Order interleaving:** where do NEW auto-arrivals land in a book
   you've hand-reordered? (End? Sorted among the un-touched? A
   "new arrivals" tail section?)
3. **What the capacity gate counts:** `max_posts` against derived +
   pinned union; can auto-adds push a book over its cap, and does a
   full book stop collecting or refuse visibly?
4. **Which acts flip the identity:** her list — *"post limit, lock
   it, new chapter name, manual reordering, etc"* — the "etc" needs
   enumeration (renaming? pinning? word target? a single drag?), and
   what the flip DOES now that collecting continues (her words:
   "it's now a named book… and it can still have the smart
   attributes and keep auto adding").
5. **Storage:** does the hybrid live on the existing columns
   (`kind`/`query_spec` both meaningful at once) or need a schema
   change (a §12 lockstep event — mirror first, her explicit go)?
   Membership rows for derived matches (materialize-on-arrival) vs
   derived-at-read (today's smart assembly) is the load-bearing fork.
6. **What happens to the shipped conversion door and the
   "(collecting)" offer** — superseded, kept as the escape hatch, or
   recast as the identity flip itself?
7. **Her W11 bug report was adjacent, and its trace fed this brief:**
   13f's opening batch traced *"i haven't been able to move the
   chapters in between the posts"* to a REACH problem (too few drop
   targets — fixed in 13f batch 2, chapters still ordering among
   chapters) plus a genuine semantics question, recorded as knot 8.
   Her 13f round-4 ruling also added post-drag-to-chapter (built in
   13f on the standing `assignPostToSection` op).
8. **The DIVIDER reading of chapter drag (from the W11 sitting,
   2026-07-30):** should dropping a chapter HEADING between two posts
   move the BREAK — posts re-binning to the chapters around the new
   position? That reads chapters as dividers over one ordered post
   list, where the model deliberately made them assignment targets
   (R28 — memberships point at chapters; dangling = unsectioned). A
   divider reading would derive assignment from position — a real
   semantics change wanting this phase's sitting, not a drag patch.
9. **A mechanism fact for knot 2, found at 13f batch 2 (revert
   W11b-A running green):** `assembleReading` already orders a
   chaptered curated book BY CHAPTER (`ORDER BY (s.id IS NULL),
   s.position, s.id, rp.position`) — assignment alone lands a post at
   its new chapter's top when moving down; membership position only
   has to be written moving up (else the post lands at the chapter's
   END). Any hybrid's arrival-interleaving rule composes with this
   ordering, not with a flat position list.

10. **BOOK-LOCK — the missing second book state (from the 13f sitting,
    round 10, 2026-07-30):** "finished" (`reading.locked`) freezes
    STRUCTURE only and exists; text-immutability at book level does
    not exist (the per-post seal seals everywhere — her rejected
    "locked everywhere" pole). Her floated shape, recorded: locking a
    book auto-diverges SHARED posts (the 13f W23 diverge-for-this-book
    compound per post — the version copy takes the slot here and is
    SEALED; the original stays live elsewhere) and seals single-book
    members directly (which also stops library-edit drift). Edges for
    the sitting: does lock imply finish; what unlock does (unseal
    members? the forks are permanent); do the forks' takes seal (the
    seal already says yes); and the NAMING of the two states — her own
    finished/locked word-blur in this round is evidence the shelf must
    distinguish them. Her ruling: this knot is 13i's ("13i's sitting",
    2026-07-30).

## What binds

- Nothing is built from this brief; the design sitting rules first
  (the friction doctrine — the knots above are the sitting's agenda).
- The ratified vocabulary stands meanwhile: *"a lens is a saved way
  of looking"*; a smart book's assembly is derived, membership rows
  are curated truth. Whatever the hybrid becomes, exports/bridge/
  other readers keep reading ONE honest order (the A31 discipline).
- Any schema need is a SyncSpec §12 lockstep event — mirror deploy at
  her explicit go-ahead, never a batch's call.

## References

`notes/plans/phase-13c-book-forms-and-conversions.md` (batch 2D + the
4F conversion memo's record) · `notes/QUESTIONS.md` #46 (the five
conversion rulings + A31's two, all ratified 2026-07-28) ·
`notes/plans/phase-13f-workspace.md` THE KICKOFF SITTING (W13's
verbatim record + the round-3 ruling creating this phase) · AppSpec §9
`convertSmartReadingToCurated`.

## Author addition (2026-08-19, at the 13j close — her words)

> "maybe the tutorial should also have a section where users are
> encouraged to create a book, chapter, and note within something
> (though that tutorial could be added in 13i)"

Routed here at her own suggestion: 13i's scope gains a **books
chapter for the tutorial** — the reader CREATES a book, adds a
chapter, mints a note inside it (the walk asserts the flow, P-6),
and meets membership-not-ownership by doing (add the same note to a
second book; delete one book; watch the note survive — the 13j
books-lesson sentence taught as an act). Sized at this phase's
kickoff alongside its identity work.

## Author additions (2026-08-25, the launch-strategy conversation — her words)

Her message named this phase directly: *"I want to add custom shelf
order and I want the book and schema phase change to make books a bit
more of a robust object - with examples like autoadding tags,
potentially adding extensibility for templates within a book or a book
of templates (not sure how templates fit into the overall plan, but
it's something on my mind), letting books have a distinct order and
also auto add, custom shelf order."*

- **CUSTOM SHELF ORDER — ruled IN, must-have.** Her schedule note:
  *"13i - book & schema change (CUSTOM SHELF ORDER MUST BE ADDED)"*;
  her journal-content note, independently: *"option on shelf to have
  custom order is a need during 13i."* The shelf today pins but has no
  hand-order; a manual order that syncs wants a position on `reading`
  (the §6 fractional-index convention) — a natural passenger on
  whatever §12 lockstep event this phase already carries.
- **Templates** — *"templates within a book or a book of templates"*;
  her uncertainty preserved: *"not sure how templates fit into the
  overall plan, but it's something on my mind."* A sitting CANDIDATE,
  not a ruling. (Framing note for the sitting: the copy-with-lineage
  machinery — `poolDragCopy` / `duplicateAsVersion` — is most of a
  "new from template" door already; the design questions are what
  MARKS a note or book as a template, what a copy strips — dates,
  tags? — and where the door lives.)
- **Distinct order AND auto-add** — her phrasing re-confirms the
  hybrid this brief exists for (knots 1–6 above).
- **Auto-adding tags** — already this brief's second direction
  (2026-08-02, above); re-named in the same breath.
- **SCHEMA-BUNDLING NOTE (the planning-ahead point of her 2026-08-25
  message — she asked what breaks sync once users exist):** bundle
  EVERY schema need this sitting rules in — the shelf position, any
  hybrid/auto-tag columns, and the LIBRARIES dimension (home confirmed
  below) — into ONE §12 lockstep event, landed BEFORE strangers, while
  the lockstep choreography is still a two-device family affair.

## Author rulings — the libraries design (2026-08-25, the launch-strategy sitting's SECOND round; home CONFIRMED here)

She confirmed this sitting as the multiple-libraries question's home
("confirm ... library questions home"). Her rulings and directions so
far, verbatim-faithful — the sitting designs ON these, it does not
re-open them:

- **In-store, one schema:** *"I agree that different libraries can be
  within the same store"* — and the motivation, hers: *"it's more for
  a feeling of cleanliness and a search that isn't contaminated by
  past notes."*
- **Cross-library MOVE is possible, and COPY is also offered:**
  *"cross library move should be possible, but make a copy and put it
  in the other library should also be an option."* (Copy naturally
  rides the copy-with-lineage machinery; whether the lineage edge
  crosses libraries is a sitting detail — coarse edges tolerate it.)
- **Per-library Archived and per-library Trash — both yes** (*"will
  each library have an archived? that makes sense to me. And will
  trash be per library? I also think that makes sense."*). Shape note
  for the sitting: archived/deleted stay STATES on the note; the
  SURFACES scope by the note's library — the state machinery (clocks,
  purge, restore) stays global and single.
- **Books never span libraries:** *"the whole point is that it's in a
  separate library to have separation."*
- **Merge-libraries as a rescue door — sitting candidate:** *"Maybe
  the ability to merge libraries will be important to save users if
  they realized it's a problem?"* (Cheap under the in-store shape: a
  bulk re-stamp plus name-collision handling for books/tags.)
- **The default library:** standard and UNDELETABLE, the home of
  quick notes, the designated daily Journal book, and the tutorial
  (*"I do think there should be a standard one that quicknotes,
  journal, and the tutorial all live in that you can't delete"*).
  **Its NAME is open** — her conflict recorded verbatim: *"since
  library is a place you can be, should we name the default library
  something more distinct? i'm a bit conflicted on what to name it"* —
  and she floated reserving a name (*"I feel like we can reserve that
  name"*). **RULED FURTHER, 2026-08-25 round 3: the sidebar KEEPS
  "Library"** (*"I need the sidebar to keep library"* — "All Notes"
  declined) **and the default instance IS named "Home"** (*"I do like
  it being called Home"*). **What stays OPEN is the LEVEL's name** —
  what each variorum instance/grouping is called (*"i'm conflicted on
  what each variorum instance should be called"*; Obsidian's "vault"
  noted, more suggestions asked). Candidates for the sitting
  (Fable's): **Wing** (a library's wings — the Home wing, the Imports
  wing; on-theme, zero collisions, "New Wing…"/"Move to Wing…" read
  naturally), **Branch** (real library-system vocabulary — separate
  locations, one system; slight git flavor), **Stacks** (library
  stacks), **Vault** (Obsidian's word; collides with the suite's
  internal key vault), **Space** (the safe generic), **Room**. Note
  recorded with them: the choice is lower-stakes than it feels — with
  the sidebar keeping Library and the switcher showing just "Home ▾",
  the level's word surfaces mainly in Settings and menu verbs.
  **RULED, 2026-08-26 (round 4): WING.** Her words: *"let's go with
  Wing. It's architectural and a bit delightful - I also think that
  it evokes more of a different room in the same house rather than
  the true separation of a git branch."* So: the level is a **wing**;
  the default wing is **Home**; the sidebar keeps **Library**. The
  sitting's residue is only the vocabulary sweep (menu verbs,
  settings copy, the tutorial's sentence).
- **Mac UI sketch, hers:** *"the mac os UI would probably have what
  library you're in (if you have multiple) right above the shelf,
  with a drop down selector, for looking at your shelf."* (And her
  earlier floated mobile twin: a selection at the top for whether
  you're in library, archived, or a different library — the archived
  half of that sketch is answered by the per-library-Archived ruling
  above.)

## Her books-communication mandate (same sitting — the tutorial must explain membership)

Her words: *"I feel like the tutorial needs better communication
about what being in a book means, what's going to happen when you
edit a note in multiple books via tag (is it always make a copy? how
would that even work? I feel like the book idea based on tags needs a
bit more fleshing out and better descriptions in the tutorial."* And
the lens over the whole sitting: *"I want some users to use my app to
write their whole actual book - is there something missing there?"*

The factual answer, recorded so the tutorial can teach it (nothing
here changes behavior): editing a note that lives in several books
edits THE note — every book shows the edit, because membership points
and never copies; the deliberate fork is 13f's diverge door
(duplicate-as-version + swap THIS book's slot, the original untouched
in its other books). A tag-based smart book contains the note because
the note CARRIES the tag; the tag rides the note, not the book, so
there is no per-book copy anywhere in the story. The 2026-08-19
tutorial-chapter addition above gains this as its core lesson:
membership-not-ownership taught by doing, PLUS the multi-book edit
story and the smart-book/tag story in plain words. The
whole-actual-book lens joins the sitting's agenda.

## The ownership feel (her round 3, 2026-08-25): a book that really OWNS its notes

Her words, verbatim-faithful: *"I think having a book where it's
clear that book really owns every note in the book is what books are
missing in FEEL to me - it should be a setting that you can do
besides just locking it. Because if you're just seeing a bunch of
notes in a row, and editing in the book view, where you see notes on
top of each other, the idea that those notes have other membership is
super unclear."* And: *"making books be able to fully own their notes
I feel like is an important step somehow ... and equally knowing that
it won't get edited outside of it. I feel like maybe I need an
EXCLUSIVE type of book / note relationship? maybe that's what I
want? help me think through the pros and cons here."* Plus the badge
idea: *"maybe a small book icon per note when you're in the book
view, only when they're in other books as well? or all the time?"*

Her direct question, answered at the sitting (a fact, not a change):
locking a book TODAY copies nothing and seals nothing — `reading.locked`
freezes STRUCTURE only; text-immutability at book level is knot 10's
floated shape (auto-diverge shared posts + seal sole members),
unbuilt, this sitting's to rule.

**The candidate shape sketched at the sitting (Fable — for the
sitting to rule, refine, or reject): the per-book OWNED setting**,
opt-in per book and never the default (pillar 3's many-books power
stays the norm):

1. Notes minted inside an owned book are born its own.
2. Adding an outside note offers MOVE-in (if bookless) or COPY-in
   (if shared elsewhere) — never a shared pointer.
3. An owned book's notes refuse other memberships while owned.
4. Opening one of its notes ANYWHERE opens it in the book's context —
   the honest answer to "knowing that it won't get edited outside of
   it": edits are always *in the book*, without hiding the note from
   the Library (Library = everything, R32, survives).
5. Un-owning / removing releases the note bookless (the Pool lists
   it) — nothing destroyed; the pointer religion intact underneath.
   OWNED is an operations-layer constraint plus a surface rule, never
   containment in the schema.
6. Knot: smart-book assembly vs ownership — does a smart book's
   derived assembly SHOW an owned note (with a badge) or EXCLUDE it
   (strong ownership)? Sitting call.
7. Composition prize: locking an OWNED book needs no diverge ceremony
   at all — sole-owned members just seal, so knot 10 simplifies.

**Pros:** the whole-book author's mental model ("these notes ARE my
book"); an honest editing home; simpler book-lock; exactly the FEEL
she names. **Cons/costs:** it bends the deliberate
posts-are-non-exclusive asymmetry (opt-in keeps the model whole, but
the promise must be defended at every door); enforcement is op-level
with an apply-time sync-repair rule (a cross-table constraint no
partial index can carry — two devices racing an exclusive add need a
deterministic repair, the SyncSpec §7 pattern); and the
smart-assembly knot above.

**The badge (separable — rides this phase either way):** a small book
icon on a note in book view when it has OTHER memberships.
Recommendation recorded: only-when-shared (the badge then MEANS
something; all-the-time is noise), count/names on hover; the editor's
membership chip is the existing sibling surface. **RULED IN,
2026-08-26 round 7: *"I think the in book view badge still earns its
place"*** — the badge ships beside the panel (different surfaces:
the badge marks shared membership IN the book view; the panel is the
note view's bridge).

### Round 4 (2026-08-26) — her rulings on the sketch

- **Book-level text immutability is REQUIRED scope, no longer a
  floated knot** — her words: *"eek - we definitely need book level
  text immutability."* Knot 10 graduates from agenda to deliverable:
  this phase SHIPS the book-level lock (the sitting still rules its
  exact shape — and the composition prize above stands: on an OWNED
  book it needs no diverge ceremony at all).
- **Opt-in confirmed, and the ASYMMETRY BEND ACCEPTED, verbatim:**
  *"I think it's fine for it to bend the deliberate posts are non
  exclusive asymmetry - right now the 'Book' concept is just a bit
  too weak for it to feel useable, so notes will have to lose a
  little ground to let books be stronger."*
- **The conversion door is RULED IN:** *"you should be able to
  convert a book to it and have it make copies of its [notes]"* —
  converting an existing book to Owned COPIES its SHARED members
  (mechanism note: per note this is exactly 13f's
  `divergePostForReading` composite — the copy takes this book's
  slot, the original keeps its other books); sole members become
  owned in place, no copy needed.
- **Un-owning, clarified at the sitting — BOTH doors exist:** (a)
  removing ONE note from an owned book releases it bookless (what
  sketch point 5 meant); (b) turning the whole book's Owned setting
  OFF is the symmetric door — members stay members, the exclusivity
  just lifts. Conversion-time copies persist as the independent
  notes they are; nothing is destroyed by either door.
- **The smart-book knot, walked at the sitting** (her question:
  *"I don't see why a smart book couldn't be an owned book, but tell
  me what you were thinking of"*): the dissolution is that ASSEMBLY
  IS A VIEW and MEMBERSHIP IS ROWS. Smart assembly may SHOW anything
  — an owned note appearing in a smart book is display, not
  membership, and the badge marks it — while ownership constrains
  membership rows. A FULLY-owned smart book (exclusive collection)
  would break her own daily pattern: Journal-membered entries
  carrying a period tag could not be collected by the period book.
  What CAN exist as a designed option: **the CLAIMING smart book** —
  an owned smart book that claims BOOKLESS tagged notes into real
  owned membership on arrival (materialize-and-claim), leaving
  already-membered notes alone (shown-with-badge or skipped —
  sitting call). Recorded beside the plain rule for the sitting.
- **Sketch point 4 (opens in the book's context) was EXPLAINED at
  the sitting** — any door (Library, search, a tag listing) lands
  you INSIDE the book at that note, the book's chrome present, so no
  out-of-book editing surface exists for an owned note; the weaker
  alternative (open standalone under a loud "part of [Book]" banner)
  recorded beside it. **ANSWERED at round 5 (2026-08-26) — see THE
  BOOK PANEL below: the strong shape is DECLINED as default
  navigation** (*"clicking on a note from the library still brings
  you into that note"* — the standalone view keeps canvas, takes,
  and the fuller toolset, *"more strictly useful"*); **the panel is
  the bridge**, and its click-through gives the
  scrolled-into-the-book road on demand.

### Round 5 (2026-08-26) — THE BOOK PANEL (her design: the step up from notes into books)

Her words, verbatim-faithful: *"maybe the answer is rather than a
banner or a simple chip, there's a book table of contents kind of
view with chapters + notes that becomes available in the right side
pane and you can reorder the notes / chapters and drag them within
that view or click on it open the book view already scrolled into
the note from there? I think that would make it feel more like it
was within the book and should actually be available on all notes -
but for notes that are shared between books, you switch out what
book you're look at at the top of it."* And the crucial insight,
hers: *"in a side panel it's collapsible, but that right now notes
feel disconnected from books because the chip is the only insight -
we need a better step up from notes into books that bridges the gap,
while still being close able so the chrome stays clean for focused
writing."*

The shape, recorded as her DIRECTION (details the sitting's):

- A **collapsible right-side-panel Book TOC** on EVERY membered note
  (joining scraps / reference / tray as a panel icon): the current
  book's chapters + notes, the open note marked.
- **Reorder and drag INSIDE the panel** — notes and chapters alike;
  pure composition over the existing ops (`reorder`,
  `reorderSection`, `assignPostToSection` — the 13f drag machinery's
  targets; no new semantics anywhere).
- **Click-through**: a note row opens the BOOK VIEW already scrolled
  to that note — the on-demand form of the declined always-navigate
  shape.
- **The book switcher at the panel's top** when the note is shared
  between books.
- **Closable** — the chrome stays clean for focused writing; the
  membership chip remains the zero-space insight and the panel is
  its step-up.
- **Navigation unchanged**: the Library click opens the standalone
  note, always.
- Sitting notes: the in-book-view badge above composes with or falls
  away beside the panel (different surfaces — both or one, her
  call); the P3/pane discipline binds (bounded query, lightweight
  rows — and the KnownIssues tray/Block-History refresh-frequency
  row gains a sibling if the panel observes at autosave rate);
  OWNED books keep their membership semantics underneath — **the
  panel answers the FEEL half for ALL notes; ownership answers the
  exclusivity half for owned ones.**

### Round 7 (2026-08-26) — owned SMART books: her further thinking (OPEN — now the sitting's sharpest knot)

Her words, verbatim-faithful: *"I think there's honestly more ways
than just what you described for smart books being owned. Another way
would be for it to yank anything matching its tag out of wherever
else it was, deleting other tags on it if necessary, or offering to
delete its own tag from those items. I probably wouldn't make journal
an owned book if I didn't want conflict like that - and tags are book
ownership given the smart book system. I don't even think what I just
said is the best way to do it because destroying tags would be
necessary if two owned smart books fought, and that seems messy. I do
think when you make a book with smart tags owned, that it could be
kinda like flipping a regular book to owned - any item it had that
was shared, an exclusive copy is made right then and there for it,
and to add something to the book you have to remove its other tags.
I'm a little conflicted on how to handle owned smart books still - I
don't know if I love anything suggested yet."*

The option space as it stands (for the sitting; NOTHING ruled):

1. **Yank-on-match** (hers, self-critiqued in the same breath):
   claim everything tagged, ripping other memberships/tags —
   deterministic but destructive; two owned smart books on
   overlapping tags WAR, and the resolution destroys tags. She
   already named the mess.
2. **Copy-on-arrival**: a tagged-but-membered note gets an exclusive
   copy minted automatically — silent, unbounded duplication (the
   fanned-extract class made ambient). Recorded to decline.
3. **Claim-free-only** (round 4's "claiming" shape): auto-claim
   bookless tagged notes, leave membered ones alone — non-destructive,
   but the book's rule silently becomes "tagged AND unclaimed."
4. **Her conversion shape — which stands under EVERY option**:
   flipping to owned materializes the current assembly and
   exclusive-copies the shared items right then (her ruling's
   letter). The open question is only the ONGOING-arrivals rule —
   and her "remove its other tags to add" rider is where tags stop
   being labels and start being slots.
5. **The DOORBELL reframe (Fable candidate, this round): for an
   OWNED book, the tag is the FEED, never the MEMBERSHIP.** The book
   is curated-owned at its core with an INTAKE RULE watching the
   tag. A newly-tagged FREE note auto-claims (a dial); a tagged note
   that lives elsewhere lands in the book's visible ARRIVALS section
   — "matches, but lives elsewhere" — with per-note choices: claim
   (move), copy in, or leave. Nothing is destroyed and no tag is
   ever deleted by machinery; two owned books watching one tag both
   see the doorbell (first claim wins; the other's arrival row says
   "claimed by X"). Her "tags are book ownership" distortion
   dissolves — for owned books, tags return to plural,
   meaning-neutral labels; membership is always a CLAIMED row.
   Composes with knot 5's materialize-on-arrival fork and the
   friction doctrine (conflicts become visible choices, never
   guesses).

Status: OPEN — her words: *"I don't know if I love anything
suggested yet."* The sitting owns it. The plain (un-owned) smart
book and the ruled conversion shape are unaffected meanwhile.
