# Phase 13c design memo — smart → smart+curated conversion (N38)

**Status:** COMMITTED 13c scope — "ruled and wanted, deferred in time
only, not optional" (the author's 13b EOL directive, item 2(2)). Authored
at 13b Stage 4, Batch 4F, as the S4-28.4 deferral's design memo (the
uniform-page treatment: deferred WITH its design on paper). Standalone: a
fresh 13c session reads this cold. **Register: the T4 memos' — plain
language, tradeoffs enumerated, HER rulings at the 13c kickoff decide;
nothing here is settled beyond what her words already committed.**

**Her direction (S4-28.4, verbatim, uncertainty preserved):** *"adding a
chapter and curating a smart book a little should be allowed, but then
you should be able to make a new 'smart book' off the same tag. so maybe
the book converts from smart to a smart + curated book?"*

**What it grows from (#25(a), answered 2026-07-22):** chapters are
CURATED-only — smart books refuse `createSection` because they have no
`reading_post` rows for a chapter pointer to live on; #25(a) said on the
record: "if a smart book saved to the shelf should someday show chapters,
that is a promote-to-curated design, not a section table change." This
memo IS that design, now wanted.

---

## 1. The model facts a fresh reader needs

- A **smart book** stores a `query_spec` (tags/tagsAll/profile/date
  bounds); its membership is LIVE QUERY RESULTS — no `reading_post` rows
  exist. Tagging a post pulls it in; untagging drops it ("membership
  flaps" — her own confirmed reading, #26(h)). Order comes from
  `sort_field` (manual falls back to created ASC, the ratified rule).
- A **curated book** is real `reading_post` rows: fractional-index
  positions, chapters (`reading_section` + `section_id` pointers), the
  capacity gate (`max_posts`), `restoreReading`'s exact-stamp revival
  (13b 4F).
- The `reading.kind` column is CHECK-constrained to exactly
  `('curated','smart')` — a THIRD kind value means a table rebuild
  migration plus every consumer learning a new case (§4 weighs this).
- Chapters NEED membership rows: `reading_post.section_id` is where a
  chapter assignment lives. There is no way to chapter a derived match
  without materializing something.

## 2. What "conversion" could mean — the three shapes

### Shape A — MATERIALIZE-AND-CONVERT (the recommendation)

At the conversion moment, the smart book's CURRENT results become real
`reading_post` rows (in the order she currently sees — what-you-see-is-
what-you-keep) and `kind` flips to `curated`. The spec string stays on
the row as provenance (harmless; curated assembly ignores it). From that
instant it IS an ordinary curated book: chapters, drag order, caps,
finish, restore — everything already shipped, no new semantics.

The second half of her sentence is its own door offered AT conversion:
**"keep collecting new matches in a fresh smart book?"** — mints a new
smart reading with the SAME spec (name defaulted to "<name> (collecting)"
or her pick), so the tag keeps flowing somewhere while the converted book
freezes into hand-shape.

- **Pros:** zero schema change (`kind` flip is plain metadata CAS;
  materialization is ordinary `addPostToReading`-shaped inserts — tiny
  S1 writes); the whole curated feature set arrives at once; one mental
  model ("a book is smart OR hand-shaped, and you can cross the line
  deliberately"); sync-safe (see §5).
- **Cons:** the converted book STOPS collecting — if she expects "smart +
  curated" to mean "still collects AND holds my chapters," this shape
  says no, the fresh smart book is where collecting continues. This is
  the memo's central product question (§6 Q1).

### Shape B — the TRUE HYBRID (derived ∪ pinned)

`kind` stays `smart`; the book gains an overlay of real `reading_post`
rows beside its live query results. Membership = derived matches PLUS
pinned rows; chaptering a derived post materializes THAT row (a pin) so
`section_id` has a home.

- **Pros:** matches her "smart + curated" words most literally — the
  book keeps collecting AND holds curation.
- **Cons (the knot, named):** every consumer must learn the union — the
  assembly's ordering (where do derived rows sort against hand-ordered
  pinned rows?), the Pool/chip drainage, word counts, the capacity gate,
  lock semantics, `restoreReading`'s sweep. And the flapping question
  turns sharp: a pinned-because-chaptered post whose tag is removed —
  does it stay (a pin) or go (derived)? Either answer surprises in some
  flow; the rule would need her adjudication case by case. No new
  COLUMNS (presence of rows is the overlay), but a large semantic
  surface — the "tortured operation" smell (OverallModel §9) unless her
  use genuinely needs live-collecting chaptered books.

### Shape C — SNAPSHOT-CHILD (no conversion)

Curating never converts: "Save as curated book" mints a NEW curated book
from the current results; the smart book survives untouched and keeps
collecting. Two shelf rows, roles opposite to Shape A's (the ORIGINAL
keeps collecting; the COPY takes the chapters).

- **Pros:** cheapest semantics of all; nothing changes kind; nothing
  stops collecting.
- **Cons:** the book she has been living with (pins, shelf position,
  finish state, the identity she knows) is NOT the one she curates — the
  copy is. Her sentence reads as wanting the EXISTING book to become the
  curated one ("the book converts") — identity matters (pins, the
  daily-journal designation class, sync history). Recorded as the
  fallback if conversion proves confusing in practice.

## 3. The conversion moment (doors, under Shape A)

- **The refusal becomes an offer (the R115/fire-and-DO grammar):**
  today's `wrongReadingKind` refusals on a smart book (create chapter,
  direct add, reorder) upgrade from bare refusals to the conversion
  offer: "This is a smart book — it collects by its tags. Convert it to
  a hand-shaped book to add chapters? (Its current N posts stay; new
  tag matches will stop arriving — optionally keep a fresh smart book
  collecting.)" One confirm; the mint-nothing-on-refuse discipline
  (`assertReadingAcceptsPosts`'s class) applies to the whole compound.
- **A deliberate door too:** the book's settings/shelf menu carries
  "Convert to curated…" for the intentional path.
- **One transaction:** materialize + flip + (optionally) mint the fresh
  smart book — a refusal mid-way leaves no half-converted book.
- **Materialization order:** the CURRENT displayed order (the book's
  sort field evaluated at that instant) becomes the fractional-index
  order; `sort_field` flips to `manual` so nothing visibly moves at the
  moment of conversion. (Alternative: keep the stamp sort live —
  rejected-lean: the point of converting is hand-shape.)
- **Extents/finish carry:** `max_posts`/`word_target`/`locked` ride the
  row untouched (a locked smart book refuses conversion like every
  structural act — un-finish first).

## 4. Sync shape (the brief's "ideally none" — confirmed, with options)

- **Shape A needs NO schema change:** the `kind` flip is metadata CAS on
  an existing CHECK-legal value; materialized memberships are ordinary
  inserts (`uq_reading_post_live` repairs as the standing pure
  duplicate). No lockstep event.
- **Cross-device race, thought through:** device A converts while
  offline device B tags a post into the old spec. Convergence: the book
  is curated (CAS settles kind); B's tag application lands harmlessly
  (the post simply isn't a member — and IS collected by the fresh smart
  book if one was minted, since specs match). A double-convert on two
  devices converges to one curated book with duplicate-membership
  repairs collapsing the overlap (smaller-id keeps). No new repair
  class.
- **Shape B** also adds no columns, but audit every membership consumer
  (§2B's list) before believing "no schema change" equals "no sync
  design" — the overlay's semantics ARE the design.
- **A third `kind` value** (e.g. `'smart_curated'`) would be the ONLY
  variant needing a real migration (CHECK rebuild + mirror + lockstep +
  marker bump). Avoid unless Shape B wins AND the overlay-by-rows
  reading proves too implicit.

## 5. What does NOT change, any shape

The one-journal-post-per-day rule (untouchable); the Pool/chip drainage
rules (#26(h) — a converted book's members are members by rows now, so
drainage keeps working; the fresh smart book keeps draining its tag);
promote-tag(s)-to-book (R30) still mints smart books; `grouping_tag_id`
stays the smart book's sectioning story until conversion.

## 6. Her rulings wanted at the 13c kickoff (plain, one at a time)

1. **The central call:** when you chapter a smart book, should it STOP
   collecting (Shape A — the fresh smart book is where collecting
   continues) or KEEP collecting under the chapters (Shape B — the
   hybrid, §2B's knot)? Your sentence supports either reading.
2. **The fresh-smart-book offer:** always offered at conversion, opt-in
   checkbox, or automatic? And its default name.
3. **The offer-on-refusal door:** should "＋ new chapter" on a smart book
   OPEN the conversion offer (one confirm away), or stay a refusal that
   names the settings door? (Lean: the offer — the R115 grammar.)
4. **Materialization order:** freeze the current displayed order into
   manual (lean), or keep the stamp sort live after conversion?
5. **Reversibility:** is curated→smart ever wanted (it would DELETE
   hand-order/chapters back into derived membership — lean: no; a fresh
   smart book off the same tags is the honest road)?

## 7. Verification shape (for the 13c plan to inherit)

Exact state-transition tests on the conversion op (rows before/after;
order preservation; the one-transaction refusal; extents/finish carry;
locked refuses); a convergence test for the §4 race; walk-test coverage
if the tutorial's books lesson gains the door (P-6); the offer doors
speak (fire-and-DO pins).
