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

### Sitting 2 (2026-07-17, evening) — reactions to round 1; the two-voices ruling

**Her message VERBATIM (her explicit instruction: "I want you to include this message
verbatim in the plan too so the fable session that implements 13 can see my words itself
along with your interpretations / rulings on it"):**

> ok, so i'll say this much: the mockup at
> file://<home>/dev/variorum/Spikes/Phase11Mockups/mockups.html is still
> probably my overall favorite look, but i also loved the terminal look. the start typing
> part of the terminal was great - maybe it'll have to be moved to the top so that people
> can use it even when they have more books, and hitting enter brings you to your item as
> a whole post. i do think that all the words you talked about should still live on the
> side bar now that i know what canvas is. i do think that we should have a place where
> you can see all your posts - not sure what that is (library?) I really like option 3,
> the book view, and think it needs to be an option for a view. so i guess in short i'd
> say: terminal should be an option for the font / styling / colors. the mockup should
> also be an option, i love the font / colors / styling of that one too, the colors on
> it. the type to start going on the home screen is graet too. the book view is very
> valuable as well. i really do like the terminal look and i like its library better ( i
> can't click on the other things to see hwo they look, i don't think i need that added
> to the mockup though). i like the shelf style of terminal more. i'm not sure what it
> would take for terminal and the other one to be an option because i love the terminal
> like details, like the little > on what's selected, the slashes, etc. but i think that
> we can probably show both options and i think they both matter. movable chapters is
> great in the A/B book view. comment should be a margin. i think B's list shelf is
> better but probably showing tags instead of what it is showing. love the terminal
> view's wordcount prominence and etc. the terminal view is the closest to how i want
> things overall, but i do like having the option for the book view for a clamer editing
> view, and i also like the mockups coloring and font options and it would be nice to be
> able to switch between them. i don't want to compromise on all the special little ways
> in which the terminal one was special though - the slashes, the blinking cursor, the
> ~/shelf, etc. that would also be a cool view for being able to click on chapters and
> journals idk. i think that when you're making the final UI surface, the other thing is:
> things should be simplifiable (our principle that fans can always collapse), but also,
> all the amazing options that we built out for the user should feel accessible. i think
> the terminal view is definitely the closest to what i want overall. i actually really
> like the comment inline with a different color behind it for the terminal view too -
> can that be a setting? i think that in general we shouldn't have all the blocks as
> different colors and should just have separation of blocks via the dotted lines if
> users want to see them - the active block being highlighted is a good choice. does this
> all feel like it is understandable? I want you to include this message verbatim in the
> plan too so the fable session that implements 13 can see my words itself along with
> your interpreations / rulings on it. i also am open to advice on the overall issues and
> feel of the app. another big thing - the text not going to close to the edge. i hate
> how textedit looks with no space between the edge and text for example. also, i
> actually do like the terminal view's "start typing" being at the bottom of the page, it
> does feel more natural, but then the area above it needs to have a max height and be
> scrollable. [screenshot] i also like in the mockup this way that you can see what block
> you're editing with the outline - also better than the text alone having a background
> color. though, i think you should always be able to type on the block with fans open it
> and be able to edit it though - if you see it in the editor, it should be editable,
> just to be clear. i do like that in this view with all the card options open to the
> side all the cards are editable too though.

*(Her screenshot: `Spikes/Phase11Mockups/mockups-v2.html`, section 1 "Fan-out styles" —
the blue OUTLINE ring on the block being edited, the grey wash marking the block whose
takes are open, and the takes as editable cards in a grid to the right of the article.)*

**Interpretations / rulings (Fable's reading of the above — flag any miss):**

- **R1 — TWO first-class VOICES, not one design with palettes.** The **Terminal voice
  LEADS** ("definitely the closest to what i want overall") and the **Study voice**
  (source of truth: `Spikes/Phase11Mockups/mockups.html` — its font/colors/styling, her
  overall favorite look) is the second; both ship, switchable. Critically, a voice
  carries its **idioms**, not just tokens — she named them: the `›` on the selected item,
  the slashes in chapter labels, `~/shelf`, the blinking cursor. "I don't want to
  compromise on all the special little ways in which the terminal one was special." The
  theme system must support idiom slots (markers, label grammar, chrome voice), not just
  color/font swaps. Hold at TWO voices until both are excellent.
- **R2 — The reading-flow book view (direction C) is a VIEW MODE, not a theme** — "an
  option for a view," the calmer reading/editing surface, available regardless of voice.
- **R3 — Quick-entry ("start typing") lives at the BOTTOM of the home surface** (her
  final statement supersedes the earlier move-to-top thought — self-correction resolved
  per her later words), with the shelf list above it **max-height + scrollable**; the
  blinking cursor stays; **Enter opens the typed text as a whole post**.
- **R4 — The shelf is the terminal LIST style (B), with a TAGS column** replacing the
  current metadata columns.
- **R5 — Sidebar keeps ALL the top-level words** now that canvas is understood: Shelf,
  Journal, Library, Pool, Tags, Canvas. **Library = the place you see ALL posts**
  (her "not sure what that is (library?)" answered affirmatively); timeline stays folded
  into Library as a view mode (sitting 1).
- **R6 — Block boundary presentation:** NO per-block background colors, ever ("we
  shouldn't have all the blocks as different colors") — **dotted seams, visible on
  demand** ("if users want to see them"), are THE boundary mechanism; the 9d pastel tint
  mode's look retires (its toggle's face becomes seam visibility). The block being
  EDITED is marked with an **OUTLINE ring** (the mockup's blue ring — "better than the
  text alone having a background color"); the mockup's grey wash marking the
  takes-open block stays available as the changing-block marker (her screenshot's liked
  state). §12's boundaries-invisible-at-rest holds.
- **R7 — Comments: MARGIN placement is the ruling** ("comment should be a margin");
  the terminal-style **inline tinted comment is a SETTING** she wants offered ("can
  that be a setting?").
- **R8 — If you can see it in an editing surface, you can edit it.** Blocks stay
  typeable with their fans open; take cards in the side grid are editable in place;
  the live-editor ring migrates on click (P3's one-live-editor holds mechanically —
  this is a UX guarantee, not an architecture change).
- **R9 — Margins are sacred:** text never runs near the window edge (TextEdit named as
  the anti-pattern); generous gutters on every text surface.
- **R10 — Simplifiable AND accessible:** calm default (fans collapse — the standing
  principle) while "all the amazing options we built should feel accessible" — the
  legibility mandate; concrete mechanisms are design work (Fable's ⌘K command-palette
  suggestion pending her reaction).
- **R11 — Word-count prominence** (the terminal status line) is liked — keep it a
  visible, ambient part of the editing surface.
- Acknowledged, no action: round-1 pages don't need clickable cross-navigation.

## Emerging direction (running synthesis — updated after sitting 2)

- **Two voices, one structure:** the Terminal voice leads (her default); the Study
  voice (= the Phase 11 mockups' look) is the switchable second. Same IA, layout,
  and gestures in both; voices carry tokens AND idioms (R1). Dark = thought-through
  grey in both. Light designed first.
- Home = the **list shelf** (terminal style, tags column) with the **bottom
  quick-entry bar** (blinking cursor; Enter → whole post; list above scrolls under a
  max height). Sidebar: Shelf · Journal · Library · Pool · Tags · Canvas. Library =
  all posts (timeline is one of its view modes).
- Books are real: ordered posts, **reorderable first-class chapters** (model options
  round owed to her), finishable (`reading.locked`'s face), boundable (`max_posts`
  face + a words-based option), smart books on the same shelf; **the reading-flow
  view (C) is a view mode** for calm reading/editing in any voice.
- Editor language: big surface, generous margins always (R9); dotted seams on
  demand, no block background colors (R6 — the 9d tint look retires); OUTLINE ring
  on the editing block; grey wash only as the transient takes-open marker; takes as
  editable cards (side grid per the mockup, or beneath per round 1); margin comments
  (inline-tinted as a setting); prominent word counts; everything visible is
  editable (R8).
- Legibility: calm default + every capability findable; candidate mechanism ⌘K
  command palette (pending her reaction).

## Open questions (running)

1. Does the JOURNAL live on the shelf as a notebook among notebooks, or stay its
   own top-level place (or both — a notebook with a dedicated door)? *(Sidebar door
   confirmed in sitting 2; on-shelf-also still open.)*
2. ~~Timeline folded into Library as a view mode~~ — leaning confirmed sitting 2
   (Library = all posts; timeline one of its views).
3. Canvas: stays a sidebar word (sitting 2). Its v1 design investment level still
   open (functional-as-is vs restyled this phase).
4. The pool's product name/face ("scraps"? "loose notes"?) so its role reads.
5. Chapter-grouping model shape (options round owed — 2–3 schema shapes with
   tradeoffs).
6. ~~Comment placement~~ — RULED sitting 2 (R7): margin default; inline-tinted as a
   setting.
7. ~~Which direction leads~~ — RULED sitting 2 (R1): Terminal leads; Study second;
   C = a view mode, not a theme.
8. How far do terminal idioms extend into navigation (she floated terminal-style
   chapter/journal browsing — "idk")? Per-surface vs global voice switching?
9. The ⌘K command palette as the accessibility-of-power mechanism — her reaction
   owed.
10. Seam-visibility default: invisible at rest (§12) with a toggle — what's the
    toggle's home (menu? per-post? global setting)?
