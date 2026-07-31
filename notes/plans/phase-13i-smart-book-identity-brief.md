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
