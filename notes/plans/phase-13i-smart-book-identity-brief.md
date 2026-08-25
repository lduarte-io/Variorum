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
  name"*). The collision to resolve at the sitting: the sidebar's
  **Library** item means "all notes," and a LEVEL also called library
  overloads the word. Candidates on the table (Fable's, for the
  sitting): name the default **"Home"**, keep "library" as the
  level's term, and rename the sidebar item "All Notes"; or reserve
  **"Library"** as the default's name and rename the sidebar listing
  instead. Hers.
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
