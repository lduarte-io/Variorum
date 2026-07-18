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

### Sitting 3 (2026-07-17, late evening) — highlighting, v2-as-canon, callouts, the paragraph-floor direction, chapters green-lit

**Her message VERBATIM (same instruction as sitting 2 — her words beside the rulings;
she attached seven screenshots, manifest below):**

> well i think that the block that you're looking at hte different fans of can be shown
> in a few ways. i think that this is nice enough, it's a good separation: [Image #2]
> but i also like this view, where it actually is a different background on the block
> that has a bunch of fans and is being edited. when this was the case, the other block
> being edited got the bar around it. i included an image where a different block is
> being edited and where it's not for it to be clear, but i like this rule for when
> we're doing the marginalia thing. [Image #4] [Image #3]. i'm also not sure if fan out
> all is always goign to work with every mode of seeing your different options -
> thoughts on that? also, in this one, the active editor doesn't even have a highlight
> but it works because the cursor is there blinking: [Image #5]. so talk to me a little
> about my different options and what you think would be good. this view also doesn't
> have the block being edited highlighted and i still think it looks good: [Image #6].
> maybe it should be a setting? idk, i think that having the takes that are being
> debated be a different color is helpful and the box around is also helpful, but i
> think the box around should be optional (or background color is optional) for
> currently editing this block. sometimes people don't even want to see what block
> they're editing, it does make it busier. showing the different takes in a different
> color still helps though, at least it helps you see what full block is being
> replaced. the v2 mockup really is the best place to look for all of this and the v2
> mockup is still the most "active view" look i've seen and liked.
> file://<home>/dev/variorum/Spikes/Phase11Mockups/mockups-v2.html
> also yes, i like the command K palette for the everything being accesible. every
> buried capability shoudl absolutely be typeable and shortcutable. i also want to know
> what command n is right now - new post? i think that's what it should be, but i'm
> open to new block. i'm a little conflicted on it though. one thing i will say that
> notes and notion both have is the ability to make a separated little background color
> block of text within the writing - i defitely want to add that [Image #7]. also, i'm
> starting to realize all the millions of issues having takes for different words
> causes - i think i'd be willing to go back and say that it can only be done at the
> paragraph level. that woudl take a lot of inspo from notion, where the blocks can be
> dragged up or down, and have different colors, and there's a little more natural
> separation between the blocks. this an example on notion of moving a block in motion,
> you can see the bar where it's going to go and that shows up. [Image #8] I don't
> think we need the notion stuff of the photos and the different left and right blocks,
> we're staying text editor, but i do like the spacing and the way the different color
> background on the blocks still has white between them. i think the lack of white
> between the block colors is why i wasn't enjoying it earlier. you can move and save
> these images and this message too for the active chat. and yeah, we can also do the
> chapter grouping model options. journal should appear on the shelf as a notebook, the
> pool area should be called blocks i think (makes it the most sense) and pool can
> still just be posts or something. what are your thoughts on all of these items? i'm
> still a little unclear on how the highlighting should work and i don't know if i made
> it clear enough how much i like mockup v2 - that should be an editor view option,
> also wit hthe book reading option. the terminal view should still have the same
> capabilities but yes, i agree we can hold exactly 2. just those two captures both
> modes i like. i do think being able to choose your font should eventually be on the
> roadmap, but not for now.

**Image manifest.** The attached screenshots lived only in macOS's drag-temp folder and
were purged before they could be copied (checked the same minutes; Desktop copies don't
exist). Six of seven are screenshots OF `Spikes/Phase11Mockups/mockups-v2.html`, which
is in the repo — each is exactly reproducible; the two Notion references are described
precisely (the author may re-attach them for the record; `sitting-refs/README.md`
invites it):

- **#2** — v2 **tab 1 (fan-out styles), the inline STACK**: takes stacked in the flow
  under the paragraph, chosen take with green left-bar + tab chips, dashed "+ new take
  (branch) · + blank take" footer. Her: "nice enough, it's a good separation."
- **#3** — v2 **tab 1, marginalia (side cards) with "Mark the changing block" ON,
  editing INSIDE the changing block**: the changing block wears the grey wash; the live
  editor sits in a take card (ring + "live editor" chip); no other block marked.
- **#4** — same, but **editing a DIFFERENT block than the changing one**: that block
  wears the blue outline ring while the changing block keeps the grey wash. Her: "i
  like this rule for when we're doing the marginalia thing."
- **#5** — v2 **tab 2 (full-text columns), one column**: NO editing indicator at all —
  just the caret. Her: "it works because the cursor is there blinking."
- **#6** — v2 **tab 3 (aligned posts / versions)**: no editing highlight; colored
  lineage rails on block cards. Her: "i still think it looks good."
- **#7** — **Notion callout closeup**: a rounded, soft-blue background block ("💡 goal
  <3 / like this") inside normal prose — the separated-colored-text-block feature she
  wants.
- **#8** — **Notion mid-drag**: dragging a block with the horizontal blue insertion bar
  showing where it will land; also shows Notion's colored blocks separated by white.

**Rulings (hers) and proposals (Fable's, pending her ratify):**

- **R12 — mockups-v2 is CANON for the active/editing view** ("the best place to look
  for all of this… the most 'active view' look i've seen and liked") — it becomes an
  **editor view option**, beside the book-reading view; the Study voice's editing
  surface derives from v2, and the Terminal voice must carry the SAME capabilities.
  **Hold at exactly two voices confirmed** — "just those two captures both modes i
  like."
- **R13 — Takes-open marking:** the tinted/distinct take cards are constant ("still
  helps… see what full block is being replaced"); the **grey wash on the changing
  block stays** (v2's "Mark the changing block," toggleable). The inline stack (#2)
  is an acceptable presentation too.
- **R14 — The EDITING indicator is OPTIONAL** ("sometimes people don't even want to
  see what block they're editing, it does make it busier") — a setting; ring and
  background are the two candidate forms; cursor-only is legitimate (#5/#6).
  **PROPOSED scheme (Fable)**: a three-way setting **off / outline / background**
  with **off** the default in the plain editor (cursor suffices), PLUS the marginalia
  rule from #3/#4 always-on IN MARGINALIA (wash = changing block; ring = the other
  block being edited) because many-editable-surfaces need the ring to find the
  editor. Pending her ratify.
- **R15 — ⌘K ratified** ("every buried capability should absolutely be typeable and
  shortcutable"). Fact recorded: **⌘N is currently unassigned** (no newItem command
  group; "New Post" is a shortcut-less sidebar button; plain ⌘K free, ⌘⇧K = Make
  Block). **PROPOSED: ⌘N = New Post** — her leaning; and "new block" needs no
  command because blocks are born by typing (crystallization) — Enter at the
  paragraph level IS new-block. Pending her confirm.
- **R16 — CALLOUT blocks WANTED** (#7): a separated, background-colored text block
  within the writing (Notes/Notion class). **PROPOSED shape**: block-level
  presentation metadata (e.g. a nullable `presentation` column on `block` — kind /
  color / optional emoji), identity-level like `block.name`, synced as plain CAS
  metadata, riding the SAME §12 lockstep event as comments; takes share the callout
  frame (presentation is the block's, not the take's); export maps to a blockquote
  form. Pending ratify.
- **R17 — The white-gap diagnosis (binding for any colored blocks):** colored block
  backgrounds must keep base-background breathing room between blocks — "the lack of
  white between the block colors is why i wasn't enjoying it earlier" (the 9d tint's
  real defect).
- **R18 — THE PARAGRAPH-FLOOR DIRECTION (uncertainty preserved: "i think i'd be
  willing to go back and say"):** takes/blocks only at the **paragraph level** — no
  sub-paragraph take machinery; Notion-inspired: draggable blocks, natural
  separation. Precision on what this actually changes (Fable): takes were ALWAYS
  block-level (I7); today's everyday granularity is already the paragraph
  (crystallization); sentence-sized blocks arise only from deliberate
  extract/divide-at-sentence gestures. So the change = **raise the SPLIT floor**:
  extract/divide/Make-Block snap to paragraph boundaries only; sentence-level
  BoundarySnapping retires from gestures (stays for TOC first-sentence display);
  cross-fan bracketing and the W get dramatically simpler. **Open halves for her:**
  (a) do MULTI-paragraph blocks survive (the ceiling — merge produces them;
  CoreDescription calls them important)? (b) hard refusal vs. default-with-escape?
  NOT yet ruled — next sitting.
- **R19 — Block drag gets the Notion insertion bar** (#8): drag up/down with the
  horizontal drop-target bar. (Reorder machinery ships; the bar is the design.)
- **R20 — Shelf/naming:** **the Journal appears on the shelf as a notebook** (Q1
  RULED; the sidebar door stays per sitting 2). **The pool area is renamed
  "Blocks"** ("makes it the most sense"). Her trailing clause "and pool can still
  just be posts or something" is AMBIGUOUS — flagged, clarification owed (possibly:
  the Library surface reads "Posts"?). Not guessed.
- **R21 — Font choice: eventually on the roadmap, NOT now.**
- **PROPOSED (Fable) — expand-all-fans adapts per style** (her doubt is right: "not
  sure if fan out all is always going to work with every mode"): literal in the
  inline-stack style; in marginalia = follow-the-scroll (the near-viewport fanned
  block's cards show); absorbed/not-offered in full-text columns and slot-split
  (those styles ARE whole-post fan presentations). Pending ratify.
- **Chapter-grouping options: GREEN-LIT** — the three schema shapes go to her (in
  the sitting-3 reply; decision next sitting).

### Sitting 4 (2026-07-17, night) — ratifications, the paragraph question dissolved, Pool redefined, the edit-home clarification

**Her message VERBATIM (standing instruction; two screenshots re-supplied the lost
Notion refs — saved to `sitting-refs/`; captures removed for publication):**

> [Image #9] this notion picture shows the background color option on a text block
> with the block mover to the left this picture is a little blurry because it's in
> motion but it shows the blue bar showing where the block is moving: [Image #10]
> also: yes, I agree with what you said about the highlighting scheme. i like takes
> being visually distinct. i like the changing block wash and that you can turn it
> off. i liek the editing indicator being a setting. also, with the other options
> like when the other takes are inline just beneath the block, you can't click on
> them to edit them? i thought you could basically always edit everythign that you
> can see? i really like everything that you said about the highlighting scheeme. i
> think that for marginalia, it could show the cards still as marginalia but only
> have them one marginalia block high (even if the block is only a sentence, it
> would just make the post vertically taller), and you can scroll through the
> marginalia horizontally. and on longer blocks, you still have the marginalia in
> the normal way. i think that follow the scroll should be an option for how to see
> takes though - that is an excellent idea!! for all the different modes. i do agree
> that full text columsn and slot split, it shouldn't be offered becasue it already
> is offered. so if takes were always whole block, then what was the deal with a
> sentence sized block? i think there's no point in having a block that actually
> secretly can't have takes - that's super confusing. also, i do think that multi
> paragraph blocks should be possible and they should survive as the ceiling. i feel
> like sub paragraph splits should just create 2 or 3 new paragraphs. if you
> highlight a sentence in a paragraph and do "make this a block", it should suddenly
> be a new paragraph with a different block above it and a different block below it.
> and yeah, i agree the callout frame makes sense to put at a block level. for the
> chapter groupings - i think that a reading section table is fine. we don't need
> nesting readings for now. callign it blocks - good. pool can just be posts or
> something: I mean that pool should be an area for posts that do not belong to any
> book. i think that this will help cut down on the number of floating notes / posts
> that i have - most htings should be addable to some book or anotehr with a tag.
> you can promote a tag (or several tags, AND joining or OR joining) to being a
> "Book". does that make more sense? i feel like you should be able to add things
> manually to a book or have a book that is based on tags - you should be able to
> save them. i'm wondering if you manually add something to a book - should that add
> a tag to the post that says it is book ownership? i think it would be okay if
> posts could be in multiple books but that gets back to the where can it be edited
> ? i think earlier we decided that posts have one place where they can be edited
> and if they try to be edited out of their home, it makes a copy of that post, but
> how do you know where the post's home is? i think if we can nail this down, it
> would help. I guess library would be all books, posts, and blocks. like litearlly
> everything, sortable and searchable.

**Rulings and resolutions:**

- **R22 — The highlighting scheme is RATIFIED in full** (Q11 closed): takes always
  visually distinct; changing-block wash with its off-toggle; editing indicator a
  setting (off / outline / background, off default); the marginalia wash+ring rule
  always on in marginalia.
- **R23 — Editability confirmed everywhere, her check answered YES:** in EVERY
  fan-out style — the inline stack included — every visible take is editable in
  place; clicking in migrates the live editor. (R8 was always style-universal; v2's
  own header says "type in any take or paragraph.")
- **R24 — Marginalia sizing (her design):** for SHORT fanned blocks, the margin
  cards render as a ONE-CARD-HIGH strip that scrolls HORIZONTALLY — the post grows
  vertically to fit the strip even when the block is a single sentence; longer
  blocks keep the normal vertical card column.
- **R25 — Follow-the-scroll is RATIFIED and GENERALIZED:** an OPTION for how takes
  are viewed in ALL modes ("that is an excellent idea!! for all the different
  modes"), not just marginalia's expand-all behavior. Full-text columns and
  slot-split offering no expand-all: agreed.
- **R26 — THE PARAGRAPH QUESTION DISSOLVED (Q12 closed, no machinery change):**
  her clarifying question ("what was the deal with a sentence sized block?")
  exposed that the feared thing never existed — there is NO block that "secretly
  can't have takes": takes were ALWAYS whole-block (I7), a sentence-sized block
  fans fine (it is simply a short paragraph), and there are NO sub-paragraph seams
  — block boundaries render as newlines, so every block IS its own paragraph on
  the surface. Her rulings confirm the existing semantics exactly: **multi-
  paragraph blocks survive as the ceiling**, and **make-block-on-a-sentence
  PROMOTES it to its own paragraph** with the before/after text as separate
  blocks — which is precisely what the shipped compound divide does today.
  Nothing is un-built; a clarifying sentence joins CoreDescription at plan
  ratification (the "floor is a sentence" line gains "…and a block is always its
  own paragraph on the surface").
- **R27 — Callout frame at block level: AGREED** (Q13's shape ratified; the
  `presentation` metadata rides the comments lockstep event).
- **R28 — Chapters: the `reading_section` table RULED** ("fine; we don't need
  nesting readings for now") — Q5 closed.
- **R29 — POOL REDEFINED (the sitting-3 ambiguity resolved):** "pool should be an
  area for posts that do not belong to any book" — the un-shelved-posts surface,
  whose PURPOSE is to drive floating posts down ("most things should be addable
  to some book or another with a tag"). The name stays loose ("posts or
  something"). The scraps area's rename to **"Blocks"** confirmed good.
- **R30 — Tag promotion to Book:** one or SEVERAL tags, **AND-joined or
  OR-joined**, can be promoted to a saved Book (= smart readings on the shelf;
  manual books coexist). Engineering note: the v1 SmartQuerySpec vocabulary is
  ANY-of tags only — the AND-of-tags form is an additive vocabulary extension
  this implies.
- **R31 — The EDIT-HOME question (her "nail this down") — the model already
  answers it, pending her confirmation:** posts have NO home-vs-away and NO
  copy-on-edit rule. Membership is not ownership: books point at posts
  non-exclusively (the deliberate asymmetry that makes on-demand books work);
  editing a post edits THE post, everywhere, in every book that shows it. What
  her memory reaches for is the BLOCK rule (I2 single ownership + pool-drag
  COPIES with lineage) and the VERSION family: wanting a book-local divergent
  copy is a deliberate gesture (`duplicateAsVersion` + `version_of`), never an
  automatic consequence of editing. So "how do you know where the post's home
  is" dissolves: its home is the library; books are saved ways of collecting it.
- **R32 — LIBRARY = EVERYTHING:** "all books, posts, and blocks. like literally
  everything, sortable and searchable" — the total catalog across entity types.
  (Fable's consolidation note, recorded as advice not ruling: the sidebar noun
  pile is growing — Shelf · Journal · Library · Pool · Blocks · Tags · Canvas —
  and Pool-as-bookless-posts is queryable as a Library filter; whether it earns
  a top-level word or lives as a saved filter is worth one deliberate look at
  the IA when the plan is drafted.)
- **Fable recommendation (recorded, her call owed): NO ownership tags on manual
  add** — reifying membership as a tag creates two truths for one fact
  (`reading_post` vs the tag) with all the divergence that brings; the honest
  answer to "which books hold this post" is showing the reverse lookup as a
  metadata chip on the post. Pending her yes/no.

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

1. ~~Journal on the shelf~~ — RULED sitting 3 (R20): yes, a notebook on the shelf;
   the sidebar door stays.
2. ~~Timeline folded into Library as a view mode~~ — leaning confirmed sitting 2
   (Library = all posts; timeline one of its views).
3. Canvas: stays a sidebar word (sitting 2). Its v1 design investment level still
   open (functional-as-is vs restyled this phase).
4. ~~Pool naming~~ — RESOLVED sitting 4 (R29): scraps area = "Blocks"; "Pool" =
   the bookless-posts surface (name loose). Residual: does Pool earn a top-level
   sidebar word or live as a Library filter (the R32 consolidation note)?
5. ~~Chapter-grouping model shape~~ — RULED sitting 4 (R28): the
   `reading_section` table; no nested readings.
6. ~~Comment placement~~ — RULED sitting 2 (R7): margin default; inline-tinted as a
   setting.
7. ~~Which direction leads~~ — RULED sitting 2 (R1) + confirmed sitting 3 (R12):
   Terminal leads; Study second (its editing surface = mockups-v2); hold at two.
8. How far do terminal idioms extend into navigation? Per-surface vs global voice
   switching?
9. ~~⌘K~~ — RATIFIED sitting 3 (R15). Remaining: ⌘N = New Post (proposed,
   her confirm owed — currently unassigned).
10. Seam-visibility default: invisible at rest (§12) with a toggle — the toggle's
    home (menu? per-post? global setting?).
11. ~~The editing-indicator scheme~~ — RATIFIED sitting 4 (R22).
12. ~~THE PARAGRAPH FLOOR~~ — DISSOLVED sitting 4 (R26): the feared sub-paragraph
    take machinery never existed; multi-paragraph ceiling survives; make-block
    promotes to own paragraph (= shipped behavior). Clarifying line joins
    CoreDescription at ratification.
13. ~~Callout shape~~ — RATIFIED at block level sitting 4 (R27); export mapping
    detail remains plan-drafting work.
14. ~~Expand-all-fans per-style~~ — RATIFIED sitting 4 and GENERALIZED (R25):
    follow-the-scroll becomes a takes-viewing OPTION in all modes.
15. Ownership tags on manual book-add — Fable recommends NO (two truths for one
    fact; show membership as a reverse-lookup chip instead) — her yes/no owed.
16. The R31 edit-home clarification (posts have no home; versions are the
    deliberate divergence door) — her confirmation owed.
17. Pool's IA slot: top-level sidebar word vs Library saved-filter (R32's note).
18. ⌘N = New Post — proposed sitting 3, not yet confirmed.
