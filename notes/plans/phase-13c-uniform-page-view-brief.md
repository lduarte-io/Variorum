# Phase 13c brief — the UNIFORM-PAGE traditional book view (committed scope)

**Status:** COMMITTED 13c scope — "ruled and wanted, deferred in time only,
not optional" (the author's 13b EOL directive, item 2(1)). Authored at 13b
Stage 4, Batch 4F, as the S4-16 deferral condition's deliverable: *"I do
think that a detailed brief or even plan should be drafted if we aren't
going to do that."* Standalone: a fresh 13c session reads this cold.

**The ask (S4-9(3), her words):** *"a traditional book view with the same
size on every page"* — uniform fixed-size pages, text flowing across them,
beside the existing views (*"love the existing book reading view, I think
we need those other 2 as well"* — the progress bar and the post-per-page
paged view shipped at 13b 4F; this is the third and last).

**Read with this:** AppSpec §4 (the P1 ban + the stored-estimates fallback
door), the Phase 6 decision memo's rulings (`notes/plans/
phase-06-tk2-spike.md` + AppSpec §14's Phase 6 delta — model-driven
book-scrub; live full-document layout banned BY SHAPE; the bounded hybrid
jump precedent), `notes/TEXTKIT2_NOTES.md` §2, and 13b 4F's shipped
machinery (`Features/BookView/` — `BookViewModel`'s page/progress brains,
`PagedBookView`, `ReadingFlowView`).

---

## 1. What it is (and what it is not)

One continuous text — the book's posts in reading order, `renderedText`
semantics (chosen takes; blank takes skip; the conditional join) — flowed
into a sequence of IDENTICAL fixed-size page rectangles, like a printed
book. A long post spans several pages; a page may end mid-post. Contrast
with what already ships:

- the **scroll book view**: one infinite scroll, post cards/bodies, the
  progress bar (post domain);
- the **4F paged view**: page = a POST, vertical scroll inside a page of
  any length (the post list is the page domain — no pagination problem
  exists there at all);
- the **reading flow**: one continuous styled column, no page boundaries.

The uniform-page view is the only one where PAGE BREAKS must be COMPUTED
from text extent — that computation is the entire design problem, because
the banned shape (lay out the whole book to know where pages fall) is
exactly what P1 forbids.

## 2. Settled facts (not open; carried from standing rulings)

- **S1. No live-TK2-geometry pagination.** The Phase 6 memo's model-driven
  ruling binds: the page domain derives from the MODEL, never from asking
  the live editor's layout. Full-document `ensureLayout` measures LINEAR
  in document size (the spike measured 105 ms @ 50k → 408 ms @ 200k) —
  banned by shape, not by tuning.
- **S2. TK2 cannot flow one document into many containers.**
  `NSTextLayoutManager` holds ONE `textContainer` (TK1's multi-container
  page flow was dropped in TK2) — so "traditional pages" cannot be a TK2
  editor trick at all. Pagination must be computed OUTSIDE the editor
  stack. (Verify against the current SDK at build time; this held through
  Tahoe 26.x.)
- **S3. Stored per-block length estimates are the sanctioned door.**
  AppSpec §4's escape hatch, verbatim: drive the scrubber "off stored
  per-block length estimates, not live geometry." An estimate-fed page
  count with honest approximation is canon-compliant; a full-layout page
  count is not.
- **S4. Cost ∝ viewport + edit (P1), virtualized long views + read-cheap
  tiers (P3), overlays never rendering attributes, one live editor.**
- **S5. The view renders the same projection as every other view** —
  `renderPost`/`joinRenderedTexts` semantics; nothing here re-decides
  joins, blank-take skipping, or callout export mappings.

## 3. Proposed pagination architecture (the recommendation; 13c's architect confirms or replaces)

**Two-tier pagination: ESTIMATED globally, MEASURED locally.** The same
shape as the TK2 spike's accepted height story (estimates revise, content
never regresses) and the hybrid jump (estimate → bounded exact
measurement → correction):

1. **The block-extent index (the model tier).** Per block of the book:
   its rendered text length (chars + newline count — both computable at
   read time from `working_text`; see §5 for the stored-vs-derived call).
   From a calibration constant (chars-per-line at the page's font/width ×
   lines-per-page), every block gets an ESTIMATED page-height fraction,
   and the book gets an estimated page count + an estimated page→(block,
   offset) mapping. O(block count) arithmetic, no layout anywhere.
2. **The measured window (the exact tier).** The page actually being
   READ (± one neighbor for page-turn continuity) is paginated EXACTLY by
   bounded text measurement — `CTFramesetter` over the page rect, the
   11b PDF exporter's proven path (pure CoreText, off the editor stack,
   off-main capable): feed it the rendered text of the blocks the
   estimate places near the target page, slice CTFrame ranges until the
   window's pages are filled. Cost ∝ the window (a handful of blocks),
   never the book.
3. **Calibration feedback.** Every measured window updates the
   chars-per-page constant (a running average), so estimates converge
   toward truth as pages are visited. The page COUNT stays labeled as
   approximate until the tail has been measured ("page 37 of ~120") —
   honesty over false precision (the R112 rule applied to numbers).

**Rendering:** each realized page is a read-cheap surface (the standing
read tier — a non-editable TK2 view or a CoreText-drawn page; the
architect picks after a spike, see Q3) inside a fixed page frame with the
book-page chrome (paper, margins, page number). Only the visible spread
realizes (P3); flipping realizes the next window and releases the old.

**Why not the alternatives:**
- *Full-document pagination up front* — banned by shape (S1); a 200k-word
  book would pay seconds at open.
- *TK2 multi-container flow* — impossible in TK2 (S2).
- *Estimate-only pages (no measured tier)* — page seams would visibly lie
  (mid-line cuts, drifting breaks); fine for a scrub DOMAIN, not for
  rendered pages.

## 4. The scrub bar's page domain

The bottom bar is the 4F paged view's grammar (◀ ▶ + slider + "page k of
n"), with the domain now the ESTIMATED PAGE LIST: the slider maps a
fraction to an estimated page index (the one `scrubIndex` brain,
generalized), the landing measures its window exactly, and the label
carries the tilde while the count is approximate. Scrub cost is O(window)
per landing — the hybrid-jump shape. Chapter starts render as page
anchors in the navigator (chapter → its first page, estimated then
corrected).

## 5. The block-extent index: stored or derived? (options for the architect)

- **(a) Derived, in-memory, per open book (RECOMMENDED start):** lengths
  come from the rendered projection at open (one indexed read the book
  view already performs); cached per block, invalidated per-block on
  edit. Zero schema change, zero sync surface. Cost: O(book) chars
  summed once per open — reading lengths, not laying out.
- **(b) A stored `block.length_estimate` column:** AppSpec §4's literal
  "stored" reading — only worth its lockstep event if (a) measurably
  fails at real corpus scale (it should not: length reads are cheap).
  If ever built: additive column, maintained by autosave (it already
  knows the text), plain metadata under sync.
- Record the decision either way; (a) keeps the door honest without
  paying schema cost for an unproven need.

## 6. Composition with the shipped views

- The book-view toggle grows: **Book · Pages · Read · (this view)** — or
  the uniform-page view becomes a SECOND FACE of Read (the reading flow's
  "flow vs pages" sub-toggle), which keeps the segment count at three.
  The architect proposes; the NAME is hers (candidates: "Print", "Book
  pages", "Spread"). (Open — Q1.)
- The 4F machinery reused as-is: `BookViewModel.scrubIndex` (fraction →
  index over any domain), the flip/scrub bar grammar, the navigator's
  page-jump pattern, `seedPageFromFocus`'s enter-where-you-were shape
  (enter at the page containing the focused/last post).
- The progress story is FREE here: on a paged surface, "page k of n" IS
  the progress bar.

## 7. Edge cases (decided on paper before build — the P-5 discipline)

- **A block longer than a page** splits across pages mid-block (CTFrame
  range slicing gives the split for free). The floor case is a page that
  is entirely the middle slice of one block. Estimates must handle
  blocks > 1 page (a block contributes ⌈extent⌉ pages, not 1).
- **Post boundaries:** does a new post start a fresh page (chapter-break
  style) or flow continuously? Traditional books do both (chapters break,
  paragraphs flow). Lean: CHAPTERS break to a new page; posts within a
  chapter flow with the standing inter-post separator. Hers to confirm
  (Q2) — it changes the page count and the feel.
- **Takes/fans:** pages render CHOSEN text only (renderedText semantics).
  Fan badges: lean NO badges on the paged surface (a print page; the R2
  reading-flow precedent renders none) — jumping out is the takes road.
- **Callouts (block.presentation):** render the frame (the white-gap rule
  travels — it is a render-time treatment); a callout splitting across a
  page boundary is the ugly corner — lean: keep callouts whole (push to
  the next page) when they fit on one page, split only when they exceed
  a full page. Costs pagination complexity; flag if it grows.
- **Comments:** none on the page (margins are the page's own — the print
  metaphor; comments live on the editing surfaces). Record so the ladder
  doesn't file it as a gap.
- **The seal / editing:** v1 is READ-ONLY with wake-to-edit — a click
  jumps to the block's post in the scroll/4F-paged editor (the
  reading-flow `onWake` precedent). LIVE editing inside fixed pages is
  deliberately out of v1: an edit reflows every later page (cost ∝ the
  book behind the caret) and the one-live-editor discipline has no page
  shape yet. If she wants in-place editing later, that is its own design
  round (record at kickoff).
- **Resize / font change:** the page is a FIXED logical rectangle
  (chars-per-page constant per font size); window resize SCALES the page
  (paper metaphor) instead of repaginating; a font-size change
  repaginates (estimates first, measured window next — the same two-tier
  path). Lean recorded; Q4 if the architect disagrees.
- **Empty/blank content:** blank takes skip (S5); an empty book renders
  one empty page with the standing empty-state line.

## 8. Open questions for the 13c architect (separated from the settled)

- **Q1.** Fourth toggle segment vs a Read sub-toggle — and the view's
  NAME (hers).
- **Q2.** Post/chapter page-break policy (§7) — hers, with the lean
  stated.
- **Q3.** Page rendering surface: read-tier TK2 view per page vs direct
  CoreText page drawing. A one-day spike decides (TK2 view = selection/
  copy for free but one NSTextView per realized page; CoreText = cheaper
  pages, selection must be built or declined). Lean: TK2 read tier,
  reusing the standing surface — decline only if page-slicing fights it.
- **Q4.** The resize/font repagination posture (§7's lean).
- **Q5.** Whether the estimated page count is good enough for the scrub
  from day one, or the tail should be background-measured to exactness
  after open (bounded, idle-time) — a polish call.

## 9. Verification shape (for the 13c plan to inherit)

- Pure pins on the estimator (extent arithmetic; blocks > 1 page; the
  calibration update; estimate→exact convergence never regresses a
  visited page).
- Hosted pins on realization (a 200-post book realizes only the visible
  spread's pages — the 4F one-page-pin's shape), on flip continuity, and
  on the wake-to-edit road.
- The tutorial's books lesson gains the view's paragraph + a walk act
  (P-6), same batch as the build.
