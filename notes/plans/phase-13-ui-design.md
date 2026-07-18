# Phase 13 — UI design passes (plan-in-progress · design sittings record)

> **STATUS: SITTINGS IN PROGRESS (begun 2026-07-17). NOT an executable plan yet.**
> Per the two-stage process (CLAUDE.md model policy, author 2026-07-17): this file
> accumulates the author-attended design sittings' record — the 11a "kickoff spike
> record" precedent: what's recorded here from her own words is BINDING input — and
> hardens into the phase's execution plan; the author invokes `/run-phase 13` once
> the plan is ratified as final. Companion inputs: `notes/plans/phase-13-brief.md`
> (orientation sketch + the 2026-07-17 author additions), AppSpec §14's 2026-07-17
> author-intake delta (items 1–12), and the deferred-12 pull-forwards (three
> design-prerequisite measurements, dev-store design corpus, restore drill — all
> owed at this phase's kickoff).

---

## Design sittings record

### Sitting 1 (2026-07-17) — orientation: taste anchors, IA, the books reversal

**THE BOOKS REVERSAL (her explicit direction, superseding an early decision).**
Her words: "we actually explicitly decided earlier to not have books and ordered
groupings of posts, but i think that doesn't make sense to me anymore." Precision on
what the early decision actually was: ordered books have ALWAYS existed (curated
readings are ordered post lists); what was decided against was **chapters as
container objects** (CoreDescription pillar 3: "a chapter is effectively a tag
section"; OverallModel §2: "Sections come from grouping rules, not container
objects"). That half she now reverses: she wants **actual books with posts in a
particular order** and **real chapter groupings you can reorder**. She wants BOTH
kinds: curated ordered books AND "on-demand books built by tags and last-edited
order that you can save as a book on your shelf" (= smart readings, which already
exist — saved-to-shelf is exactly a saved smart reading; their order derived, not
hand-moved — she's fine with that). **Canonical-doc consequence, deliberately
deferred:** pillar 3's chapter wording and OverallModel §2's sections line get their
ratified supersession when this plan is ratified — the sitting record carries the
direction until then. Also wanted: **drag posts onto a book** (the membership op
exists; the drag face doesn't).

**Taste anchors (her words, condensed):**
- **The Phase 11 mockup is still the single best anchor** — "closer to what i want
  than apple notes or terminal is." Specifically liked: the **sepia background with
  white posts**, the colors, the font, **takes having a different background color
  than the overall post** ("that's helpful"), **dotted lines between blocks**
  ("honestly nicer than the color backing we have right now, that i think doesn't
  look that good"), the **selected block getting a highlight**.
- **Terminal:** the text and spacing ("like this claude message" — mono, airy), how
  FAST you can start writing, simplicity, "no other things going on" — **"being able
  to sink into the work is really important for me."**
- **Apple Notes:** always quick and easy to add something (she loves how quick a new
  note is); DISLIKES the endless-pile feeling; its tagging "feels bleh." She wants
  things **contained in books for the most part**, standalone posts as an option;
  "my notes tend to group into clusters of what they're about that i could add
  books for."
- **Notion:** liked it, "got too busy."
- **Books/Kindle apps:** infinite scroll is good for whole books; finished books
  show **nothing but the text** — "ibooks if it were an editing surface with takes
  is a good way of thinking about it."

**Feel/theme:** she'd like warm-literary-paper (option A) AND other feels available
as **user-selectable theme options** — A and B as choices, not a single identity.
**Light/dark:** lives in light primarily — design light first — but dark must "feel
thought through": **Gemini-style dark GREY, not black.**

**IA (her reactions):** the current pile **Journal, Library, Pool, Tags is good**
(pool described by her as "where you add standalone items" — note: the pool holds
SCRAPS/blocks; standalone posts live in the library — a naming/legibility item to
resolve, not silently). **Timeline:** her instinct — "a view of all posts and maybe
that's just a view on the library?" (leaning recorded: fold timeline into the
library as a sort/view mode, not a top-level place). **Canvas:** she asked "what is
canvas right now?" — she doesn't know a shipped surface exists; the legibility
finding in miniature. **Books/shelf** joins the top level (the notebook direction,
§14 item 10). **The post view should be BIG.** **Density:** shelf surfaces feel
like a **quiet bookshelf**, with the information surface **accessible somehow**
(progressive disclosure, not ambient).

**Use cases she named to design against (all of them, not one):** quick notes; the
daily journal; standalone blog posts; researched blog posts (references beside);
a SERIES of blog posts (e.g. three); a whole book — editable down to "one sentence
being different," with the whole still making sense.

### Prototype rounds

- **Round 1 (2026-07-17):** `Spikes/Phase13Mockups/` — three deliberately divergent
  direction pages built from sitting 1 (index.html links them): **A "The Study"**
  (the mockup language matured — sepia room, white paper posts, serif prose, dotted
  seams, tinted takes), **B "The Terminal Study"** (mono, near-zero chrome,
  instant-entry, maximal sink-in), **C "The Reading Room"** (iBooks-as-an-editing-
  surface — page-like reading flow, chrome that gets out of the way, finished books
  as pure text). Each includes shelf/book/editor screens + a dark-grey sample.
  Likely outcome per her own framing: one leads as default, others inform the THEME
  system's range. Awaiting her reactions.

## Emerging direction (running synthesis — NOT yet binding)

- Home = a **shelf of books/notebooks** (quiet; info on demand); the Journal keeps
  its own top-level door; Library = the total catalog (timeline likely a view mode
  of it); Pool for scraps; Tags kept.
- Books are real: ordered posts, **chapter groupings as first-class reorderable
  things** (model options to design: e.g. a `reading_section` table vs alternatives
  — 2–3 shapes with tradeoffs owed to her before deciding), finishable
  (`reading.locked`'s face), boundable (`max_posts` face + a words-based option),
  smart books save to the same shelf.
- Editor language: big writing surface, dotted seams (retiring the 9d tint's look;
  the never-adjacent/stable color RULES stay wherever color remains), selected-block
  highlight, takes visually distinct by background, terminal-grade speed to first
  keystroke, iBooks-grade purity at rest.
- Theming: a token layer supporting multiple selectable themes; light designed
  first; dark = thought-through dark grey.

## Open questions (running)

1. Does the JOURNAL live on the shelf as a notebook among notebooks, or stay its
   own top-level place (or both — a notebook with a dedicated door)?
2. Timeline folded into Library as a view mode — confirm or keep separate.
3. Canvas's home once legible (a view of a pool/post, not top-level?) — and does it
   earn its place in v1 of the redesign at all?
4. The pool's product name/face ("scraps"? "loose notes"?) so its role reads.
5. Chapter-grouping model shape (options round owed).
6. Where do comments LIVE visually (margin? panel? hover?) — design round with the
   schema work.
7. Which direction leads as the default theme; what range must the theme system
   span (A-warm ↔ B-mono at minimum?).
