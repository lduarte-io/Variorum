# Phase 13 — UI design passes (plan-in-progress · design sittings record)

> **STATUS: RATIFIED (sitting 7, 2026-07-18) — EXECUTION UNDERWAY: `/run-phase 13`
> invoked 2026-07-18, all-Fable cast per R54 (her direct-edit amendment: coordinator
> Fable too).** Seven sittings recorded below; every open question is closed; the
> execution plan is at the bottom of this file.
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
- **The Phase 11 mockup (v2) is still the single best anchor** — "closer to what i want
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
thought through". 

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

### Sitting 5 (2026-07-17, late night) — the closing round: IA collapses inward, canvas demoted, the last confirms

**Her message VERBATIM (standing instruction):**

> so - the smallest block size is still a sentence and that's still fine. or a single
> word, which is also fine, it's just on its own paragraph, right? also - good to know,
> the blocks have one home but you can edit it only where it actually lives. and yeah,
> that resolves it, i think it should be clear that duplicate as version is how you
> separate the post you're seeing in your current book from the post that shows
> elsewhere. i think we need clear UI on that when you edit it (this post also appears
> in 4 different books, or something of the sort). i do think knowing which books hold
> it is important btu one source of truth is fine. and yes, i do think promoting a tag
> to a book is a good gesture to have and it should still leave the tag on those items.
> i think that journal can just be within shelf - we can maybe just pin it within
> shelf. i think having a pinned shelf in general would be useful. and then when you're
> in the journal area, you should be able to see your books (i do think that we should
> be able to see what book each journal belongs to, i want mutliple books within
> journal). and i also think that maybe we don't need tags on the sidebar? not even
> really sure what that would show, our tags don't have hierarchy as far as i'm aware
> and i want to keep them that way. what does tags even offer as a tab? i also don't
> know if canvas needs to be an item on the side bar. it seems like the point of canvas
> is to arrange ool scraps or post blocks - that seems more like it should be a view
> that you can open of a post (or a particular view of a post with all its selected
> takes) (let's say no takes in canvas or only the minimum view of takes that mobile
> might inherit where when you click on a block and can switch that block to another
> one of its own takes, one at a time, via a "see takes" button and small selection,
> very minimal). I don't think it makes sense to have canvas on the left right now?
> what would it even show? and yeah, command N should be new post. i couldn't find
> canvas in the existing app so it was hard to judge. the seam visibility toggle home:
> i think that this should be a global setting for now. i think that the terminal idiom
> should bring you to the overall book view (chapters - with their names), a top level
> outline, settings. and then if you click on the post, that shouldn't really move you
> from your current editor. so i guess terminal idioms could bring you to the book. i
> don't know if it makes sense to have a "chapter" view, unless that's where you
> reorder posts in a chapter? i don't think we need a chapter view though tbh.

**Rulings:**

- **R33 — Block floor confirmed as-is:** smallest block = a sentence, or even a single
  word — fine, "it's just on its own paragraph" (correct: every block is its own
  surface paragraph).
- **R34 — Block one-home confirmed:** a block renders and edits only in the one
  container it lives in.
- **R35 — Edit-home CONFIRMED RESOLVED (Q16 closed) + a UI REQUIREMENT:** when
  editing a post that appears in multiple books, the editor must SAY so ("this post
  also appears in 4 books" or similar), with **duplicate-as-version presented as THE
  way to separate this book's copy from what shows elsewhere** — the divergence door
  made discoverable at the moment it matters.
- **R36 — Ownership tags: NO** (Q15 closed) — "one source of truth is fine"; book
  membership shown via the reverse-lookup chip (R35's requirement is its natural
  home).
- **R37 — Promote-tag-to-book RULED**, and the promotion **leaves the tag on the
  items** (the tag keeps existing; the book is a saved way of collecting it).
- **R38 — The Journal folds INTO the Shelf as a PINNED notebook** (supersedes the
  sitting-2 sidebar list half): **pinning is a general shelf mechanism**; the journal
  area shows **which book each journal entry belongs to**, and she wants **multiple
  journal books** (the dream-journal thread realized: journal notebooks are books).
  Model detail (which reading/membership shape binds an entry to its journal book;
  how the one-entry-per-day rule scopes per book) = early-phase ask-her design item.
- **R39 — The Tags tab is DROPPED from the sidebar** ("what does tags even offer as
  a tab?"); tag browsing folds into Library filters; tag management lives where tags
  are used. **FABLE FLAG (surfaced, not silently resolved):** she said "our tags
  don't have hierarchy as far as i'm aware and i want to keep them that way" — the
  MODEL has shipped hierarchical path tags (subtree semantics, the Phase 10
  taxonomy UI) since v1; she has evidently never needed the hierarchy. Ruling
  honored as: **tags present FLAT at the surface** (hierarchy machinery goes
  dormant, is NOT removed — removal would be a model change nothing requires);
  chapters no longer need tag-grouping (reading_section supersedes it, R28).
- **R40 — Canvas leaves the sidebar** (Q3 closed): it is a VIEW you open on a post
  (or the scraps area) to arrange blocks spatially. **In canvas, no fan machinery**
  beyond at most the MINIMAL takes switcher — click a block → "see takes" → a small
  selector switches that block's displayed take one at a time — explicitly the
  minimal shape "mobile might inherit" (the phone-takes rethink and canvas share
  one pattern). ("i couldn't find canvas in the existing app" — the legibility
  finding, again.)
- **R41 — ⌘N = New Post RULED** (Q18 closed).
- **R42 — Seam-visibility toggle = a GLOBAL setting for now** (Q10 closed).
- **R43 — Terminal idioms' reach (Q8 closed at direction level):** the terminal
  navigator serves the BOOK — the overall book view (chapters with their names), a
  top-level outline, settings; **clicking a post opens it in your current editor**
  (no context jump). **NO separate chapter view** — reordering posts within a
  chapter happens in the book view itself.

### Sitting 6 (2026-07-18, small hours) — Pool restored, hierarchy given its chance, the end-taste-checkpoint, black dark

**Her message VERBATIM (standing instruction; she ALSO edited this file directly —
recorded in R51):**

> wait, where did pool go? also, it actually is kinda nice to have tags with
> hierarchy. i haven't used the app really at all so that's not really evidence. keep
> the hierarchy surfaced so that i can see if it does actually become useful to me
> and so that i get the chance to actually use it. i think tags could still be edited
> elsewhere. also, where did Pool go? or is pool just supposed to be surfaced via the
> library? I think pool is still nicer to have at the top level because when you make
> a random post, that's where it goes, and it's still easier to find and see. and
> it's an easier place to add tags to a bunch of posts at once (in the terminal style
> view, remember how i said there should be tags, well that should be an addable
> surface within pool and library). also, just make a note that I'll do the phone
> install and check after phase 13. i just want to get this UI portion done for now.
> also, i don't think every milestone should gate on a tasate checkpoint. i want to
> do a taste checkpoint once the whole thing is done, it'll be easier for me to
> consider it all once it's done. i won't be able to tell if i like the structure if
> it all still looks bad with ugly sapcing, no background colors, no fonts, etc.
> also, are you going to be able to pull in the fonts that we decided on / need? i
> think that it should be possible for you to do so but just checking on that. in
> terms of item 20 - i think that an entry should know its journal book the same way
> posts are going to know what book they're a part of - but is that the new table
> showing what chapter they are in? or i can just make the journals be tagged that
> and promote that tag into being a book - which is basically "book membership is a
> tag" without making it a whole separate tag. one journal post per day is a
> fragments rule that shouldn't be changed. i added to the notes plan specifying that
> v2 is the best anchor, not just the mockup. also, i removed the gemini style dark
> grey instead of black, because i realized that i actually like a fully black
> background more.

**Rulings:**

- **R44 — POOL STAYS TOP-LEVEL** (Q17 — the pinned-filter proposal OVERRULED):
  "when you make a random post, that's where it goes, and it's still easier to find
  and see." **The sidebar, final: Shelf · Library · Pool · Blocks.**
- **R45 — Tag HIERARCHY stays SURFACED** (supersedes R39's dormant-at-the-surface
  half; the dropped dedicated tab stands): "i haven't used the app really at all so
  that's not really evidence — keep the hierarchy surfaced so that i can see if it
  does actually become useful to me." Tags are edited in context, wherever they
  appear.
- **R46 — The list views' TAGS column is an ADDABLE surface in Pool AND Library** —
  batch-tagging a bunch of posts inline, terminal-style.
- **R47 — Phone install + check AFTER Phase 13** (her note; "i just want to get this
  UI portion done"). Consequence spelled for the plan: the A1 lockstep DEPLOY
  executes at the phase END as one choreography — mirror → Mac → phone — before any
  new-schema use on the real store; build work rides the dev store meanwhile; the
  standing no-lens/canvas/name-writes interim constraint simply continues (moot
  while she isn't using the app).
- **R48 — ONE taste checkpoint, AT THE END** (supersedes the per-milestone taste
  gate): "i won't be able to tell if i like the structure if it all still looks bad
  with ugly spacing, no background colors, no fonts." Milestones keep their
  TECHNICAL gates (suites, perf numbers, cold reviews); she judges the whole
  assembled thing once, on the running app, and the fix round follows.
- **R49 — Fonts: confirmed feasible, no dependency needed.** Everything the anchors
  use ships with macOS as system fonts (Charter, Georgia, Iowan Old Style, New
  York, SF Mono, Menlo — the v2 mockup's stack included); nothing to license or
  bundle. A non-system font later = her licensing call (R21's roadmap item).
- **R50 — Journal-book binding RESOLVED (Q20):** an entry knows its journal book
  **the same way any post knows its books — ordinary membership** (curated add, or
  tag + promote-that-tag-to-a-book — her "book membership is a tag without making
  it a whole separate tag"). Her chapter question answered: `reading_post` = which
  book; `reading_post.section_id` = which CHAPTER within it (chapters optional for
  journals). **The ONE-JOURNAL-POST-PER-DAY rule is a Fragments-bridge rule and is
  UNTOUCHABLE** — the daily journal keeps it exactly; how other journal-like books
  coexist with it on a given day is B3's design detail INSIDE that constraint.
- **R51 — Her direct in-file edits recorded (kept, reconciled):** sitting 1's
  anchor line now names **v2** as the best anchor; the grey-dark clause is removed
  because **dark mode = a FULLY BLACK background** (her re-ruling — supersedes the
  sittings-1/2 grey statements; every downstream carrier in this file updated to
  match).

### Sitting 7 (2026-07-18) — the kickoff round: tags' home, the deploy un-gated, Fable staffing, full autonomy

**Her message VERBATIM (standing instruction):**

> am i going to be able to add new tags and adjust tag hierachy in a place in
> settings then? if it'sn ot in the sidebar it still needs o be somewhere. also, just
> do the schema deploy. i removed the app from my phone and don't have it on my phone
> right now and i have no real content in it, so i just want to do the schema deploy.
> the phone consideration is still majorly secondary at this point - i want the real
> thing on my mac, not the dev store, more than i want to verify the phone before
> that happens. also, it'll be fable staffing. and i think that everything is fine to
> get going. can phase 13 get to completion without me at this point? unless a new
> question appears? even then, maybe questions should jsut be noted and the execution
> should continue because honestly, we've spent so long ironing all of this out that
> i'm hoping to get a phase 13 that can just build so i can assess the app in a state
> that is supposed to be completely useable and interpretable, so i can see what is
> still confusing. i also want to note that i LOVED the terminal view of the mockup
> too, and I also did love the book view. so options 2 & 3 of the mockup you built
> me, with the original v2 mockup being more of the editing surface of the book view
> that was option 3 of the mockup that you built me. just make sure that the session
> does know about that mockup / terminal thing too because it was useful.

**Rulings:**

- **R52 — Tag management gets a real home: SETTINGS** ("if it's not in the sidebar
  it still needs to be somewhere") — create tags, adjust hierarchy, rename; also
  ⌘K-reachable; in-context tag editing everywhere (R45/R46) stands beside it.
- **R53 — The schema deploy is AUTHORIZED and UN-GATED (supersedes R47's
  end-of-phase choreography):** she REMOVED the app from her phone (no content, no
  un-updated client exists) — the 11a no-lens/canvas/name-writes interim constraint
  DISSOLVES, and the lockstep is **mirror → Mac only**. Deploy when A1's artifacts
  land, via the stored PAT arrangement (the 9c precedent; her words: "just do the
  schema deploy"). Accepted consequence: once the marker bumps, the pre-13
  installed Mac app visibly refuses to sync until the phase's build replaces it —
  fine, she isn't using it. The phone is "majorly secondary": it reinstalls onto
  current schema whenever she next wants it. Her priority: **the real thing on her
  Mac** — the phase ends with the finished app on `/Applications` against the real
  store.
- **R54 — Staffing: FABLE** — coordinator Fable · implementer Fable · cold reviewer
  Fable (all-Fable — her amendment by direct edit, 2026-07-18, supersedes the
  recorded Opus-coordinator half), the Phase 10/11 same-model review shape; the
  Sync/ rider stands.
- **R55 — FULLY AUTONOMOUS execution:** the phase runs to completion WITHOUT her.
  New questions do NOT stop the build — "questions should just be noted and the
  execution should continue": every ambiguity gets the PROVISIONAL treatment
  (implement the most spec/sitting-defensible reading, record it here + QUESTIONS,
  keep going), INCLUDING product-flavored ones this phase (her explicit widening of
  the standing PROVISIONAL rule, for this phase only). Her one planned touchpoint
  is the END taste checkpoint (R48) — she wants to assess "an app that is supposed
  to be completely useable and interpretable, so i can see what is still
  confusing." CLAUDE.md's author-only calls (invariant violations, new
  dependencies, destroying her data) remain hard stops — none should arise.
- **R56 — The anchor set, final:** she LOVED round-1 **direction B (the Terminal
  Study)** and **direction C (the Reading Room)** — "options 2 & 3 of the mockup
  you built me" — with **mockups-v2 as the EDITING surface of C's book view**. The
  implementing session must treat `Spikes/Phase13Mockups/` (rounds 1–2) as canon
  anchors BESIDE `Spikes/Phase11Mockups/mockups-v2.html`: B for the terminal
  voice, C for the reading/book view, v2 for the active editing surface, round 2
  for the merged rules.

## Emerging direction (running synthesis — updated after sitting 2)

- **Two voices, one structure:** the Terminal voice leads (her default); the Study
  voice (= the Phase 11 mockups' look) is the switchable second. Same IA, layout,
  and gestures in both; voices carry tokens AND idioms (R1). Dark = a FULLY BLACK
  background in both (sitting-6 re-ruling). Light designed first.
- Home = the **list shelf** (terminal style, tags column) with the **bottom
  quick-entry bar** (blinking cursor; Enter → whole post; list above scrolls under a
  max height). Sidebar, FINAL (sitting 6): **Shelf · Library · Pool · Blocks** —
  Journal pinned on the shelf; tags hierarchical, surfaced, edited in context (no
  dedicated tab); canvas a post view. Library = everything (timeline one of its
  view modes); the tags column is an addable batch-tagging surface in Pool and
  Library.
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
3. ~~Canvas~~ — RULED sitting 5 (R40): off the sidebar; a view opened on a
   post/scraps; minimal takes switcher only (the mobile-inheritable shape).
4. ~~Pool naming~~ — RESOLVED sitting 4 (R29): scraps area = "Blocks"; "Pool" =
   the bookless-posts surface (name loose). Residual: does Pool earn a top-level
   sidebar word or live as a Library filter (the R32 consolidation note)?
5. ~~Chapter-grouping model shape~~ — RULED sitting 4 (R28): the
   `reading_section` table; no nested readings.
6. ~~Comment placement~~ — RULED sitting 2 (R7): margin default; inline-tinted as a
   setting.
7. ~~Which direction leads~~ — RULED sitting 2 (R1) + confirmed sitting 3 (R12):
   Terminal leads; Study second (its editing surface = mockups-v2); hold at two.
8. ~~Terminal idiom reach~~ — RULED sitting 5 (R43): the book navigator
   (chapters/outline/settings; post-click opens in the current editor; no chapter
   view).
9. ~~⌘K~~ — RATIFIED sitting 3 (R15). Remaining: ⌘N = New Post (proposed,
   her confirm owed — currently unassigned).
10. ~~Seam-visibility toggle~~ — RULED sitting 5 (R42): a global setting for now.
11. ~~The editing-indicator scheme~~ — RATIFIED sitting 4 (R22).
12. ~~THE PARAGRAPH FLOOR~~ — DISSOLVED sitting 4 (R26): the feared sub-paragraph
    take machinery never existed; multi-paragraph ceiling survives; make-block
    promotes to own paragraph (= shipped behavior). Clarifying line joins
    CoreDescription at ratification.
13. ~~Callout shape~~ — RATIFIED at block level sitting 4 (R27); export mapping
    detail remains plan-drafting work.
14. ~~Expand-all-fans per-style~~ — RATIFIED sitting 4 and GENERALIZED (R25):
    follow-the-scroll becomes a takes-viewing OPTION in all modes.
15. ~~Ownership tags~~ — RULED NO sitting 5 (R36); membership chip instead.
16. ~~Edit-home~~ — CONFIRMED sitting 5 (R35) + the multi-book indicator UI
    requirement.
17. ~~Pool's IA slot~~ — RULED sitting 6 (R44): TOP-LEVEL (the filter proposal
    overruled). Sidebar final: Shelf · Library · Pool · Blocks.
18. ~~⌘N~~ — RULED sitting 5 (R41): New Post.
19. ~~Tags surface~~ — RE-RULED sitting 6 (R45): hierarchy stays SURFACED (given
    its chance); no dedicated tab; edited in context.
20. ~~Journal-books binding~~ — RESOLVED sitting 6 (R50): ordinary membership
    (curated or tag→promoted book); the one-entry-per-day rule untouchable
    (Fragments); daily-vs-other-books day interplay = B3 detail inside that
    constraint.
21. ~~Tag management's home~~ — RULED sitting 7 (R52): Settings (+ ⌘K), with
    in-context editing everywhere.

---

### Sitting 8 (2026-07-18, mid-execution — via the coordinator; the author intervened during the Stage B review round 2 fixes)

**Her message VERBATIM (standing instruction; typos hers):**

> the dream "journal is more the shaep of just being a notebook you can add
> to. i think i will include takes on mobile, so it's not even the same
> fragments ssue of not having takes in general or ahving a surface that
> can't add takes. so it's just a nromal notebook basically.

**Rulings:**

- **R57 — Non-daily journal-like books are NORMAL NOTEBOOKS** (confirms
  the round-2 BLOCKER fix direction, shipped before the ruling arrived):
  entries are ORDINARY posts — no container `profile='journal'`, full
  takes machinery, nothing bridge-coupled; only the daily journal wears
  the journal-profile/bridge shape. **Shipped disposition:** a non-daily
  journal book's "+ new entry" mints `.generic` + `entry_date` (a generic
  post column with no bridge/daily coupling — kept for the dated-notebook
  feel) + one-block segmentation set explicitly; the one-entry-per-day
  rule stays scoped to the daily journal exactly as R50 said (the rule's
  real scope is the journal SHAPE, which these entries no longer wear).
- **R58 — Mobile takes: she now LEANS include** ("i think i will include
  takes on mobile") — recorded with her uncertainty preserved; Phase 15's
  orbit; NOTHING built this phase. Refines AppSpec §14's 2026-07-17 item
  4 (the "rethinking" note) — flag for the closeout ritual's
  canonical-doc batch.

### Author directive (2026-07-18, mid-Stage-C, via the coordinator) — R59: handoff + checkpoint mechanics

**Her words VERBATIM (standing instruction; typos hers):**

> make sure that you write your thorough handoff after this phase is complete - i
> expect that the you as the orchestrator will have a very full context and i
> expect to have to manage / ratfy / assess / judge / whatever handoff items and
> give tweaks and go through my UI / UX review with a new session.

**Ruling:**

- **R59 — The phase handoff must be exceptionally thorough, because the R48
  taste checkpoint runs in a NEW session anchored on it** (a refinement of
  R48's mechanics: her reactions and tweak requests will be managed from a
  fresh session — nothing may depend on any live session's context; the
  CLAUDE.md completeness bar applied hard). `notes/handoffs/phase-13-handoff.md`
  (the phase's LAST act, written at the closeout ritual) must carry: the
  complete ratify list (QUESTIONS #23–#26 + Stage C's additions — each
  PROVISIONAL with its options and what shipped); a **guided UI/UX walk** for
  her review (per surface, both voices, how to reach everything — the
  legibility mandate applied to the handoff itself: what to look at, what to
  try, what's a setting); the checkpoint mechanics (her reactions → further
  sitting entries here → the fix round follows); and the standard content at
  full depth (what shipped and why it's shaped that way, counts, findings +
  dispositions in brief, exactly what she must do next as a checklist at the
  top). Changes nothing about Stage C's scope or the boundary protocol; the
  stage closeouts are written knowing they feed that handoff.

### Sitting 9 (2026-07-18 evening — the R48 taste checkpoint begins; fresh session anchored on the handoff per R59; reactions batch 1, with screenshots)

**Her message VERBATIM (standing instruction; typos hers; [Image #N] markers hers — screenshots from her Desktop/temp, described after the quote):**

> hi fable! I'm ready to get into the walkthrough from phase 13 and ready to
> address some issues that i've noticed. notes/handoffs/phase-13-handoff.md.
> I've already noticed some more serious useability and clarity issues. I
> might need some vocab mroe defined for me or we just need some changes
> overall. here's one example: [Image #2] i don't know what the scratch
> option even is. also, i don't know what duplicate as version would mean
> for the scratch. i also couldn't see takes while the scratch column was
> open, even though i'm in the takes tab. [Image #3] also the marginalia was
> too hard to see - it's not really clear how you close the takes of items
> that you have open, the marginalia was weirdly cut off, and it didn't push
> things up and down like in the demo so that the marginalia could have more
> regular room. i also don't get how these multiple scratch columsn are
> supposed to work and as you can see in the previous image it's not
> resizing cleanly. and in canvas mode you couldn't move things freely, it
> had a verticle limit and i couldn't move the block that is more up and
> more up than it is here for some reason. [Image #5] [Image #4] you Can't
> unmark things as versions too which is another serious issue. i also think
> that being able to choose any post as outline is a little bit confusing.
> also it needs to be easy to make a post inside of a book. overall i jsut
> have some serious useabiltiy questions. [Image #6] clicking on "in no
> book" also doesn't let you easily add it to a book, which it should. the
> meaning of duplicate as version versus mark as verison is unclear. i don't
> know why i can't make this one sentence a block and i don't see where the
> setting to see where different blocks are is, and the error message is cut
> off here [Image #7] i can see in the lower corner that i'm in block 2/2 so
> that's why i can't make a new one but it's still kind of unclear. the take
> editor is clear for when you already have takes but you can't make a new
> take in it, which is really confsuign. the options at the bottom of the
> write editor should absolutely still be there in the take editor -
> arguably, people will often live in the take editor and the main writing
> editor should stay an option but i feel like the take editor should be teh
> primary default view and it should be very clear what branching does. also
> what does branch all fans into a new thread do? i feel like this is all
> pretty confusing

**The screenshots (described for the record):** (1) Takes mode, Margin grid, Chosen + ONE Scratch column — both showing identical text, no take cards anywhere, no visible per-block pick affordance; the scratch column's editor frame sized oddly against the window. (2) Takes mode single-column margin grid — take cards ("takes · 2") clipped mid-card at the RIGHT WINDOW EDGE; the second block's card group crowded directly under the first's. (3) Takes mode with THREE columns (Chosen + Scratch + Scratch), all identical text. (4) Canvas mode on a post — the ‹ take 1 of 2 › switcher open on one card; her complaint: a card near the top could not be dragged further UP (the shipped `max(0, …)` origin clamp in `CanvasView.swift:115-116`). (5) The membership chip popover ("This post is in no book — it lives in the Pool.") with its second line TRUNCATED ("Editing here edits the post everywhere it appears. T…") and Duplicate as Version the only action. (6) Write mode with a cross-block selection; the status-line refusal TRUNCATED ("That span is t…"); sidebar footer shows **"Bridge error — Retry"** (unraised by her; logged for investigation).

**Rulings (R60+; her uncertainty preserved where she has it):**

- **R60 — Versions must be UN-markable in the UI** ("you Can't unmark things as versions too which is another serious issue"). `Operations.removeVersionOf` has existed in core since 11a (round 1) with NO face — the exact 9d class (shipped op, no door). The fix round builds the door(s) wherever version links are shown.
- **R61 — The membership chip must offer ADD-to-book directly** ("clicking on 'in no book' also doesn't let you easily add it to a book, which it should") — the popover currently offers only the divergence door (Duplicate as Version); it gains an add-to-book path.
- **R62 — Making a post INSIDE a book must be easy** — a direct new-post-in-this-book door (journal books have "+ new entry"; non-journal books have no equivalent — New Post lands in the Pool and needs a membership drag).
- **R63 — The Write editor's bottom gesture bar belongs in the Takes editor too** ("should absolutely still be there in the take editor") — firm.
- **R64 (direction, uncertainty preserved) — she leans toward the Takes editor as the PRIMARY default view** ("arguably, people will often live in the take editor and the main writing editor should stay an option but i feel like the take editor should be teh primary default view") — a lean, not a settled flip; the fix round designs what "default" means (per-post memory vs global) and asks live. Rides with: "it should be very clear what branching does."

**Reactions recorded for the fix round (defects vs legibility vs design questions — triaged by the session):**

*Defect-class (mechanism traced or visible in the screenshots):*
1. Margin-grid take cards CLIP at the right window edge (the #28f fixed rail overruns the viewport instead of fitting inside it).
2. The membership-chip popover truncates its explainer text.
3. The status-line refusal truncates ("That span is t…") — refusal copy exists (9d fire-and-speak) but the surface cuts it off; the whole message must be readable.
4. The 2-column takes layout mis-sizes ("it's not resizing cleanly") — the scratch column's frame vs window width.
5. Canvas drag clamps at the top-left origin (`max(0, …)` both axes) — free spatial arrangement can't move a card up/left past 0. Designed clamp, reads as a defect; the fix round frees it (expanding origin / negative-coordinate scroll).
6. "Bridge error — Retry" visible in the sidebar footer (her screenshot; unraised) — investigate.

*Legibility-class (shipped behavior is defensible but failed her cold — the R48 walk's whole point; the 11a ratified shapes are NOT self-explaining on the restyled surface):*
7. "Scratch" is opaque — the pick-a-different-take-per-block affordance inside a scratch column never surfaced for her, so the column read as a pointless duplicate of Chosen.
8. Columns HIDE per-block blooms (the 11a "columns are whole-post fan presentations" ruling, #28d) — in the Takes tab this read as "takes disappeared." Revisit the presentation or make the relationship visible.
9. How to CLOSE an open bloom (the ⑂ toggle / Close All) never surfaced.
10. Duplicate as Version vs Mark as Versions — the shared word "version" with two different gestures (copy-then-link vs link-only) is failing; naming/explainer work.
11. The toolbar Duplicate as Version sits ambiguously ABOVE column context ("what would it mean for the scratch") — it's post-level (copies chosen), never column-level; the column-level door is 💾 save-as-lens → ⧉ promote. Placement/labeling work.
12. "Branch all fans into a new thread" is unglossed jargon.
13. Make Block's refusal on a whole-block selection is correct but unclear even un-truncated ("i can see in the lower corner that i'm in block 2/2 … but it's still kind of unclear").
14. The seam toggle (Settings → Appearance → "Show block seams"; ⌘⇧B) was undiscoverable when she wanted "the setting to see where different blocks are."
15. Overall: "i feel like this is all pretty confusing" — the legibility mandate (§14 item 11) is NOT yet met on the takes/versions surface.

*Design-gap-class:*
16. NO first-take door in Takes mode — the "＋ new take (branch) / ＋ blank take" doors render only inside an OPEN bloom, so an unfanned block cannot grow its first take there (the 9d first-branch chicken-and-egg reborn on the new surface).
17. Margin cards don't get vertical room — "it didn't push things up and down like in the demo" (the v2 mockups pushed content; shipped overlays reserve no vertical space — #27a's recorded TK2 reasoning vs the R24 strip's existing post-grows-to-fit precedent; mechanism is the fix round's design question).
18. Multiple scratch columns' purpose unclear (what a second/third thread is FOR needs to be visible: compare full alternate readings side by side).
19. "Being able to choose any post as outline is a little bit confusing" — the Outline mode's free source-picker; design question, not ruled.

**Status:** #23–#28 remain OPEN (nothing ratified this batch — the walk continues). The fix round follows the accumulated list; its cast is her call (R48/R59). No canonical-doc deltas yet — R60–R63 become §14 deltas when the fix round ships them.

### Sitting 9, continued (2026-07-18 evening — reactions batch 2; THE FIX ROUND CALLED: author-attended, this session)

**Her message VERBATIM (standing instruction; typos hers):**

> ok i think the scratch columns / lenses need to be their own tab at an
> absolute minimum so that it's clear that there is one tab alone where you
> aren't supposed to be able to edit, you're just choosing views of the same
> thing. i kind of had thought that we would promote views from the column
> look at different takes but i think that this is fine too and it is
> defensible. i think we should be clear about what the deal with a named
> lens is though-is this something where you choose your lens on the main
> writer page? I just dont think it should share with lens. or you should be
> able to edit within the scratch columns - i think that would also be fine.
> i think that we need more prominent post names or something so that it's
> much more clear when something is a brand new post. and i think mark as
> versions should still be deleatble and at least unmarkable as the
> versions. duplicate as version meaning nothing for the scratch - i think
> that we duplicate as version from scratch would be save as lens into
> promote, otherwise it just wouldn't be chosen. maybe duplicate for a
> scratch column should be - promote this, but does it have to be saved as a
> lens? I guess it makes sense to save it as a lense if you didnt' really
> want that post. i think the langauge just needs to be clearer somehow.
> branch all fans into new thread is too confusing as jargon but i guess
> what it's going makes sense. also, yeah, the sync isn't working. i think
> we need to add removeVersionOf. we need an easier take and as mentioned i
> think the take view should be the main view. i also think we desperately
> need keyboard shortcuts for opening and closing fans. and maybe a little
> keyboard shortcut helper that can appear on hover and has a dictionary tab
> or something. i think shipped cards should reserve at least two cards of
> verticle room with the marginalia option, or you should be able to choose
> what grid you want up to like 3 high and 2 wide or something - it's too
> hard to only be able to see two takes and it should be an option i think.
> i want to pause here and fix these issues because it's still a little too
> confusing. we also really need a way to add a post into a book already -
> not sure if i mentioend that, butwe should add it. these useability gaps
> are too much, right now it's very confusing. you can also ask me questions
> if any of this wasn't clear enough

**Rulings (R65+; her uncertainty preserved where she has it):**

- **R65 — Scratch columns / lenses become their OWN TAB** ("at an absolute
  minimum"): one mode alone whose deal is choosing views of the same thing;
  the Takes tab keeps the per-block fan cards. Pane editability inside the
  new tab: she offered BOTH shapes as fine ("you aren't supposed to be able
  to edit" first; "or you should be able to edit within the scratch columns
  - i think that would also be fine") — settled by the in-session question
  round. Recorded with it: she had half-expected promote-a-view-from-columns
  to be the shape, and judges the shipped lens design "fine too and it is
  defensible."
- **R66 — Named-lens legibility.** Her question ("is this something where
  you choose your lens on the main writer page?") answered in-session: NO —
  a lens NEVER renders on Write (a lens is never rendering truth, the 11a
  pin); it appears only as a column in the columns surface. The fix makes
  that self-evident (tab separation + the dictionary). Her "I just dont
  think it should share with lens" read by the session as: the takes surface
  shouldn't share its tab with the lens machinery (consistent with R65) —
  flagged for her correction if misread.
- **R67 — Post identity must be prominent** ("more prominent post names or
  something so that it's much more clear when something is a brand new
  post") — the Duplicate-as-Version / promote disorientation: landing in a
  minted post must be unmistakable.
- **R68 — Version links are deletable/unmarkable** (firms R60; "i think we
  need to add removeVersionOf" — the face ships this round).
- **R69 — The scratch column's promote door captures the COLUMN's picks**
  ("duplicate as version from scratch would be save as lens into promote,
  otherwise it just wouldn't be chosen"); whether the named-lens save stays
  a mandatory step is her open question ("does it have to be saved as a
  lens? I guess it makes sense to save it as a lense if you didnt' really
  want that post") — settled by the in-session question round; either way
  "the langauge just needs to be clearer somehow."
- **R70 — "Branch all fans into a new thread" is too-confusing jargon** —
  rename + gloss; the capability itself "makes sense."
- **R71 — The bridge failure is real and joins the fix round** ("also,
  yeah, the sync isn't working" — the screenshot's "Bridge error"). The
  status row hides the error detail behind a hover tooltip
  (`BridgeStatusViews.swift`) — itself the truncated-refusal class; surface
  it, then diagnose the underlying failure.
- **R72 — Takes becomes the MAIN view** (firmer than R64's lean: "as
  mentioned i think the take view should be the main view"), and "we need
  an easier take" — first-take creation must be easy (batch 1's item 16
  confirmed as a build item). Default-view semantics pinned by the
  in-session question round.
- **R73 — Fan open/close KEYBOARD SHORTCUTS** ("we desperately need") +
  a hover shortcut helper with a dictionary/glossary tab ("a little
  keyboard shortcut helper that can appear on hover and has a dictionary
  tab or something") — the legibility mandate's concrete face: the app
  carries its own vocabulary.
- **R74 — The margin grid gets vertical room and a density option**:
  reserve at least TWO cards of vertical room in the marginalia
  presentation, and/or a user-choosable grid up to ~3 high × 2 wide —
  "it's too hard to only be able to see two takes and it should be an
  option i think."
- **R75 — Add-post-into-book re-confirmed** (firms R62 — "we also really
  need a way to add a post into a book already").
- **R76 — THE FIX ROUND RUNS NOW, AUTHOR-ATTENDED, THIS SESSION** ("i want
  to pause here and fix these issues because it's still a little too
  confusing") — the R48/R59 cast call is made: a direct Fable session with
  her, not a `/run-phase` cast. The guided walk resumes after the fixes.

**Question round 1 (in-session, same sitting — four structural calls put to
her with options; three settled, one opened a design conversation):**

- **R77 — The new tab is named "Lenses"** (her pick from Lenses / Views /
  fold-into-Compare): the dictionary defines the word; scratch columns
  become "unsaved lenses," collapsing two words into one idea.
- **R78 — Promote from a scratch column is DIRECT** ("Make this a post" —
  captures the column's picks straight into a new linked post; an optional
  "also keep as a lens" checkbox; the mandatory save-as-lens-first step is
  retired). Matches her own reasoning: a lens is for when you didn't really
  want a post.
- **R79 — "Takes is the main view" means: a post opens in Takes the FIRST
  time; thereafter each post reopens in the mode you last used there**
  (remember-per-post; Write stays one click away in the picker).
- **The pane-editability question opened the real design conversation
  (OPEN — "let's chat more about this"). Her answer VERBATIM (standing
  instruction; typos hers):**

  > I think that choosing only is okay, but only if you have a button that
  > says "open this lens in editor" or something like that. the most
  > anoying thing would be to build a lens, go back to the editor, and have
  > to select your lens. we also have to decide something - does "takes"
  > show you only one lens at a time? because seeing the different lenses
  > is basically a way of having the column editor with different takes
  > open, if you chose manually what you want for block 2, 5, 6, 7, and 10
  > or whatever. so i think it should be possible to open lenses in the
  > multi column take editor - which brings me back to feeling like the
  > column / lenses tab shoudl be editable, because it would basically be
  > like the multi column take editor. especially because i feel like the
  > multi column take editor should have a button to elevate it to a lens.
  > so maybe multi column editor + lens editor is the same tab? and multi
  > column as a view moves out of the normal takes view? it's a pretty
  > different approach from the other approaches so i think that would be
  > fair. i also think you should always when you've chosen takes even on
  > the normal take screen be able to elevate what you have to being a
  > lens. i think we just need a clearer way of seeing lens name, lens
  > choosing, and lens machinery and maybe lenses shoudl be the multi
  > column editor. and at that point, new scratch column would basically be
  > the same as "branch all fans into a new take". but scratch column just
  > for flipping options also makes sense... so i don't know. clearly
  > lenses are diffferent from takes but the blend between them is close
  > enough limitations might read as annoying. let's chat more about this.

  The session's read of where she's converging (proposal put to her in the
  chat, ruling pending): **the Lenses tab IS the editable multi-column
  editor** — the columns composition moves out of Takes wholesale; Takes
  stays single-column per-block fan work; the scratch-vs-branch-all
  distinction surfaces as two differently-named new-column doors (flip
  EXISTING takes vs mint NEW takes everywhere); a "save current choices as
  a lens" door joins the normal Takes screen (her elevate ask); "open this
  lens in editor" dissolves because a lens column IS an editor.

### Sitting 9, continued (2026-07-18 late evening — reactions batch 3: the Lenses model green-lit with amendments; the entanglement diagnosed; three more screenshots)

**Her message VERBATIM (standing instruction; typos hers; [Image #N] markers hers):**

> i think taht the + column makes sense - you can have more views than you
> have takes afterall. i think recombine existing takes still is a bit too
> much jargon to parse - maybe like "new lens without new takes" or
> something like that (but i don't think what i said just now is too clear
> either - maybe it needs a help text hover or something). and i think new
> takes on every block is helpful. i also think new takes on every block
> should still be an option in the traditional takes editor. arranging
> versus writing might be a clearer lable. also, i think we need ways of
> changing the columns between being lenses, new columns (that haven't been
> named yet), etc. i think names should be more prominent for lenses
> because of that - the unnamed ones should still get something like "Lens
> 1" or something so that when you're selecting which columns you want in
> your multi view (which i guess is a minimum of 1 column when there's no
> other takes or views of what's selected to see), you can replace any
> column with a different named lens or replace with a new column, for
> however many you chose to see visible. also, we can't see takes right now
> in the journal which is so confusing because the takes can still EXIST
> (especially due to sync rules) but you can't actually edit them. i'd fix
> that and include a note like - only the chosen view shows on fragments
> (only if the user has a fragments account linked, and even then that
> might not always be true for variorum mobile) - or something like that.
> this view when you click on the takes is also too frustrating because if
> you make a new blank take, it doesn't select that one, and it just feels
> a little bit clunky. you should have new blank take and choose it, and
> you can also see all the takes without being able to immediately edit
> them without choosing. i do think we still need some take machinery in
> the main writer view, i'm just wondering what UI would be better. i also
> am not even seeing the column comparison mode? but i did see it earlier?
> am i missing something? picture for that: [Image #10] and then picture
> for clunky write machinery: [Image #11] i also have a scratch column but
> it is so confusing how i can even select different takes: [Image #13]
> and when i have slot split on 4 i still see nothing with the scratch
> block next to it? the scratch view being in the same view as takes is
> breaking it and now i can't even get to the multi column editor that i
> could earlier. give me your thoughts on this and help me work out the
> resolution to it but i like the build list thus far.

**The screenshots:** (#10) Takes tab, Fan style dropdown open (Stack /
Carousel / Margin grid / ✓ Slot split ×4) with Chosen + Scratch columns
behind it — slot split showing NOTHING beside the scratch column. (#11)
**the pre-13 Phase 7 FanPanel sheet** ("Fan — block EFCC1AAB": rows of
Branch/Choose/Archive/Lock/Delete + New Blank Take/Close) — the Write-side
takes door still opens this unstyled view-only panel; non-chosen takes
cannot be edited there. (#13) Chosen + Scratch columns, ring focused in the
scratch pane, NO visible per-block take-pick affordance.

**Rulings (R80+; her uncertainty preserved):**

- **R80 — The + Column / column-slots model is green-lit** ("+ column makes
  sense - you can have more views than you have takes afterall"): the
  Lenses tab is N swappable column slots, minimum ONE (just Chosen when
  there's nothing else to see), user-chosen count.
- **R81 — Door language: ARRANGING vs WRITING** ("arranging versus writing
  might be a clearer lable"); "recombine existing takes" still too much
  jargon; her own sketch ("new lens without new takes") self-flagged
  unclear; **help-text hovers required** on these doors.
- **R82 — "New takes on every block" is helpful AND must also be offered in
  the traditional Takes editor** (branch-all lives in both tabs; in Lenses
  it opens as a column).
- **R83 — Columns are mutable slots with PROMINENT lens names**: any column
  replaceable via its header (Chosen / any named lens / a new unnamed
  lens); unnamed lenses auto-name "Lens 1", "Lens 2"… — a scratch column IS
  an unnamed lens, now visibly.
- **R84 — Journal takes visibility is broken in practice** ("the takes can
  still EXIST (especially due to sync rules) but you can't actually edit
  them"): fix it, and add a projection note — her wording preserved: "only
  the chosen view shows on fragments (only if the user has a fragments
  account linked, and even then that might not always be true for variorum
  mobile)"; final copy the session's. Session hypothesis (to verify at
  build): the journal book's entries surface takes only through the
  read-tier ⑂ → the OLD FanPanel, which cannot edit non-chosen takes.
- **R85 — The Write-side fan panel (the Phase 7 FanPanel, screenshot #11)
  is the clunk**: "new blank take" must select the new take ("you should
  have new blank take and choose it"); seeing takes without being able to
  edit-without-choosing is the frustration; Write DOES keep take machinery
  ("i do think we still need some take machinery in the main writer view,
  i'm just wondering what UI would be better" — the shape is the session's
  to propose).
- **R86 — The fan-style × columns entanglement is confirmed broken in
  practice** (slot split ×4 beside a scratch column renders nothing; the
  multi-column editor became unreachable "and i can't even get to the
  multi column editor that i could earlier"; scratch take-picking
  undiscoverable — "the scratch view being in the same view as takes is
  breaking it"): the Takes/Lenses split resolves it STRUCTURALLY — fan
  styles belong to Takes (one column, the post); columns belong to Lenses;
  the two never co-occupy a surface again.

### Sitting 9, continued (2026-07-18 late evening — reactions batch 4: FanPanel retirement confirmed; the canvas switcher OVERRULED to view-local; adopt-swap; the keyboard vocabulary)

**Her message VERBATIM (standing instruction; typos hers):**

> i agree that the fan panel should be retired and the take machinery
> should be pulled into just that item in writing. and that's where close
> all takes really matters - it restores the writing pane to being a plain
> writing pain with no buttons at all. in canvas I feel like the switcher
> should only change the post if you explicitly select it - like not just
> viewing it in the post it notes (which the post it notes should also be
> savable as a lens, right?), but if you choose something it's only chosen
> if chosen very carefully. in the lens column i think it's fair to change
> just that lens pick but then i think any lens column should have a very
> obvious "promote lens to chosen" button - which should also rename the
> "chosen one" into a named lens view. and on the takes board, i agree
> with minting a new take on each block without it being chosen. as you go
> through and fill items in, it can be selected. or maybe an option in
> takes where you expliccitly have to say "open new blank take as chosen"
> rather than the deafult - maybe a power user keyboard shortcut. also,
> did yo usee my keyboard shortcut about a new take, archive take, etc.
> keyboard shortcut and a keyboard shortcut help pane? what else should be
> on there to make this really useable? respond to this, we'll confirm
> everything, and you'll start building.

**Rulings (R87+):**

- **R87 — The FanPanel is RETIRED everywhere; Write's take machinery is the
  inline v2 bloom** at the ⑂/caret block ("the take machinery should be
  pulled into just that item in writing"); **Close All restores the plain
  writing pane — "no buttons at all"** in the prose surface (the calm
  default, now a stated rule; the bottom gesture bar is chrome, not
  prose-surface buttons).
- **R88 — The canvas switcher is OVERRULED to VIEW-LOCAL (#28e answered
  the other way):** ‹ › on a canvas card only changes what that card
  SHOWS; chosen moves only through an explicit, careful choose gesture
  ("it's only chosen if chosen very carefully"). The canvas card-picks are
  SAVABLE AS A LENS (her "the post it notes should also be savable as a
  lens, right?" — yes; built). Requires per-canvas view state + a
  differs-from-chosen marker (the #28e alternative's recorded cost,
  accepted).
- **R89 — Lens columns: ‹ › changes that lens's pick only (fair, her
  word); every lens column carries a VERY OBVIOUS "promote lens to
  chosen" door; adopting PRESERVES the outgoing chosen as a named lens**
  ("which should also rename the 'chosen one' into a named lens view" —
  session reading, confirmed in-chat: a nothing-is-lost swap; the old
  chosen arrangement auto-names as a lens, renameable).
- **R90 — Takes-board minting never chooses (ratified: "i agree with
  minting a new take on each block without it being chosen"); an explicit
  "open new blank take as chosen" power variant exists via keyboard
  shortcut** ("maybe a power user keyboard shortcut").
- **R91 — The keyboard vocabulary extends to the take lifecycle** (new
  take, archive take, etc.) **+ the shortcut help pane** (hover cheat
  sheet + a helper with Shortcuts and Dictionary tabs); the session
  proposes the full map (in-chat table) and additions for real
  usability; her confirmation gates the build start.

**Batch 5 (2026-07-18 ~11:30 PM — the confirmation; build START). Her
message VERBATIM (standing instruction; typos hers):**

> yes, adopting swaps, never destroys - it should auto save as a lens and
> we should handle name collisions (by adding like a (1) to the name or
> something, with an increasing integer. I like the chosen until xyz date
> name being the auto though. and yes i agree, every shortcut should be a
> menu item and refusal messages should be larger for people to be able
> tos ee them. also, i think the fragments bridge now issue was due to
> changes fragments made to sync - it went away after logout and log back
> in. i do think it's bad that there wasn't a more helpful message though
> [Image #14]

(#14: the sidebar healthy again — "Synced 11:27 PM · Bridged 11:27 PM".)

- **R92 — Adopt-swap ratified precisely:** adopting a lens auto-saves the
  outgoing chosen as a lens named "chosen until <date>"; name collisions
  resolve with an increasing-integer suffix ("(1)", "(2)", …).
- **R93 — Every shortcut is also a menu item; refusal messages must be
  large enough to read** (the in-chat map + helper design confirmed).
- **R94 — The bridge outage resolved by sign-out/sign-in** (her read:
  Fragments-side sync changes; consistent with a wedged token-refresh
  path). The standing defect is the UNHELPFUL message: bridge/sync
  failures must CLASSIFY and speak — an auth-shaped failure says
  re-authenticate and offers the door; error text renders inline, never
  hover-only. Diagnosis folded into the build item.
- **The confirmation gate is passed — the fix-round build begins** (this
  session, author-attended, per R76). The one shipped-PROVISIONAL this
  sitting reverses is #28e (canvas switcher → view-local; R88) — QUESTIONS
  updated with the sitting as the record.

### Sitting 9 — THE FIX ROUND'S BUILD RECORD (2026-07-18/19, author-attended Fable session per R76; commits 06e6068…5d6b55d)

**Everything her batches ruled is BUILT, tested, and green.** Gates:
**core 738/88 · Mac 423/78 · mobile 11/4** (up from 731/421/11 — the new
machinery's tests). Per ruling:

- **The Takes/Lenses split (R65/R80–R83/R86):** the LENSES tab is the
  editable multi-column editor and all lens machinery's one home — column
  slots (min 1, the NAME is the slot picker), auto-named unnamed lenses
  ("Lens 1"…), the arranging-vs-writing + Column doors with hover glosses,
  the per-block ‹ take k of n › switcher moving that column's pick only,
  visible per-column doors (✓ Make this the post · ⧉ Make this a post ·
  💾), the one-rule footer. TAKES is single-column always — fan styles and
  columns can never co-occupy again (her slot-split-beside-scratch
  showed-nothing state is structurally impossible now).
- **Adopt-swap (R89/R92):** core `adoptLensPreservingChosen` +
  `adoptPicksPreservingChosen` — outgoing chosen auto-preserved as
  "chosen until <date>" (+" (n)" on collision) in the SAME transaction;
  toast names the way back; swap-back round-trip pinned.
- **Direct promote (R78):** core `promotePicks` — scratch columns promote
  without a lens; "keep as a lens too" offered; the forced 💾 step retired.
- **Takes default (R79):** posts open in Takes first; per-post last-mode
  memory after.
- **FanPanel RETIRED (R87/R84/R85):** WriteTakesPanel = the same v2 card
  grammar scoped to one block (editable, ✓, lifecycle, archived takes with
  their way back, growth doors — minting never chooses, R90, the new card
  takes the ring; "＋ blank & choose" beside them); ⎋/Close All restores
  the plain page; the R84 Fragments note on journal-shaped posts
  (TakesProjection gained profile/entry_date); the Takes bottom bar (R63)
  rides both boards — Commit ⌘S/History/Seal/Set Date + structural buttons
  present and SPEAKING.
- **The keyboard family + helper (R73/R91/R93):** the full map (⌘⇧T · ⎋ ·
  ⌘T · ⌥⌘T · ⇧⌥⌘T · ⌘⏎ · ⌃⌘←/→ · ⌘⇧A · ⌘⇧L · ⌃⌘↑/↓ · ⌘1–7 · ⌘/), every
  shortcut a menu item, one command channel to the visible surface,
  nothing a dead key; the Shortcuts & Dictionary window (her ratified
  vocabulary sentence at the top; every app word defined) with hover
  cheat-sheet "?" buttons on both bars.
- **Versions (R60/R68):** core `unmarkPostsAsVersions` (every cross-post
  edge; mark↔unmark round-trip pinned) + faces in Compare ("Unmark") and
  the Library ("Unmark Versions with" — unlinked picks SPEAK).
- **Books & identity (R61/R62/R67/R75):** the membership chip is the ADD
  door (add to any open curated book, per-book remove, readable refusals,
  untruncated text) and the divergence door now ends in "Open the Copy";
  "+ new post" joins non-journal curated books' navigators (atomic
  `newPostInReading` — refusals mint no stray); the post's NAME sits
  prominent in the detail header, click-to-rename.
- **Canvas (R88 — #28e ANSWERED, the alternative):** free movement
  (origin-shifted board, negative coords legal); ‹ › view-local with the
  differs-from-chosen marker; "✓ choose this take" the one careful
  gesture (viewing legal under seal; choosing refuses speaking); picks
  savable as a lens; old writes-chosen pins rewritten to the new
  semantics.
- **Errors speak (R71/R93/R94):** bridge/sync causes inline + classified
  (auth-shaped → "sign in again" guidance + the Account door), status-line
  refusals wrap readable, the whole-block Make Block refusal explains
  itself. Her outage's class (a wedged session after Fragments-side auth
  changes) now names itself instead of hiding in a tooltip.
- **Also probed:** the promoteLens sparse fall-through suspicion — traced,
  CORRECT as shipped (optional chaining flattens); finding dismissed
  hollow per the hallucination guard, sharp pin kept.

**Deliberately NOT in this round:** the typographic PDF (still her
explicit checkpoint call), margin-card push-down beyond the R74 reserved
room (the grid now reserves its height — if the demo-style full reflow is
still wanted after she tries it, that's a next-batch item), and the walk's
remaining surfaces (#23–#27 untouched — the ratify walk continues).

### Sitting 9, continued (2026-07-19 ~12:45 AM — batch 6: first reactions to fix round 1; two bugs, fixed same session)

**Her messages VERBATIM (standing instruction; typos hers):**

> ok so early bugs are no "add post" button exists in the book view. also,
> i did command n for a new post and i can't even edit it when i open it
> straight into the takes view? it's not even editable to start with,
> theres no default block or ability to make and type new blocks. i need
> to explore everything else you just built and told me about for columns,
> taes, and edits, and canvas but first i have to look like that. i also
> think we need version links versus the make new version to be clarified
> in the dictionary if it isn't yet, i didn't check but i do think that
> what we have with version linking still feels a little bit confusing in
> terms of what's a copy, what's just a connection, etc. also, waht is the
> typographic pdf? and what are 23-27? i couldn't try the margin cards due
> to the take typing issue. [Image #15]

> [Image #16] this is what books looks like

(#15: ⌘N's Untitled post open in Takes — a BLANK board, nothing typable.
#16: "~/my book :)" — the navigator with book/read + ⚙ but NO bottom
doors at all, body "This book has no posts yet.")

**Dispositions (same session):**

- **R95 — A BLOCKLESS post never opens into Takes** (the R79 default's
  missing guard — a fresh ⌘N post was a dead end: Takes/Lenses have no
  typing surface; blocks are born in Write's crystallization). Fixed:
  blockless posts force-open in WRITE regardless of mode memory; the
  Takes and Lenses boards gain an empty state ("Nothing here yet — blocks
  are born by typing" + a Start-writing door) so an emptied post is never
  a blank void either.
- **R96 — The add-post door joins the BOOK BODY** (her "no 'add post'
  button exists in the book view"): "+ new post in this book" (or "+ new
  entry" on journal books) now renders at the end of the book's flow —
  the navigator rail's twin, where writing ends. The navigator doors'
  live load path was PROBED (a new live-start test drives the real
  observation: the reading arrives, curated kind intact — green), so the
  screenshot's doorless rail is most consistent with the book being
  SMART ("Create Smart Book"), where chapters/adds are designed-absent
  (#25a) but were absent-and-SILENT — the navigator now explains a smart
  book's collection model in place. Open question to her: which button
  minted "my book :)" — if it was "Create Book" and the doors are still
  missing after relaunch, that's a live repro to chase.
- **R97 — The dictionary's version entry sharpened** (her "what's a copy,
  what's just a connection"): mark = CONNECT only (nothing copied,
  nothing changed); duplicate = COPY + connect in one gesture; unmark
  deletes only the connection. Her instinct that the naming itself may
  still confuse is noted — if the sharpened words don't land on her next
  pass, renaming the gestures is the next lever.
- Her questions answered in-chat: the typographic PDF (the KnownIssues
  row awaiting HER disposition at this checkpoint) and QUESTIONS #23–#27
  (the ratify-walk bundles, summarized).

Counts after batch 6: **core 738/88 · Mac 424/78 · mobile 11/4**;
`/Applications` re-refreshed.

### Sitting 9, continued (2026-07-19 ~2 AM — batches 7 + 8: the window discovery, usability rulings, the Terminal-idiom audit)

**Her messages VERBATIM (standing instruction; typos hers; screenshots
#17–#21 described below):**

> i need a way of going into the editor view from books. also, what is 1w
> post? I'm going to have to deal with the other ratify issues after we
> fix this. also, i think that smart books should still let you add, and
> should just tell you that tags are going to be added. if a smart book is
> based on a view like "before June", then it should give you a
> descriptive error message when you can't add something. also, there's a
> weird bug: I can't see the bottom of the screen and i can't drag the top
> of the window down for resizing it at all without it snapping back to
> being at the top. [Image #17] also, the caroseul seems bugged in a new
> way too [Image #18]. i can't see as many options for it as i see listed,
> and even though you can see there's three takes there's no way to move
> between them. i also can't see the blocks details at the botto mlike
> block 1/5 or anything since i can't see the bottom of the editor, as
> mentioned. also, even when margin says 2 high, it is not actually 2
> high. [Image #19]. also, i feel like hover on mark as versions should
> expalin what the point of marking as versions is - i'm lowkey still
> unclear on the poitn of that if they have no relation to each other.
> what does that even really mean? you can't even see them side by side
> because the blocks don't match up. i also think the outline tab should
> have a button to make it more useful that says like make outline for
> post where you can get a new copy of the post (or whatever the outline
> is - actual copy?) with a side that says outline, automatically named
> "outline of xyz", or something like that. and maybe choose what lens
> you're comparing the outline to on that page too? for what it works
> for?also, what's the point of the blocks page? and the text on it is
> all super mini. [Image #20] also, i crated book, not a smart book.
> there's also this layout bug with the white bar in the middle [Image #21]

> also, terminal has slowly but steadily lost all the personality details
> that i liked so much from the original terminal view. there's no
> blinking line with "new post" that lets me type it on the main shelf
> screen, as we had specified. there's no little > to show the way. I
> haven't seen a ~/path in a while. can you look at what the plan for
> phase 13 had? I feel like what we have is actually wildly incomplete
> given what i had specified and given teh mockup of the terminal that i
> specifically said i liked.

(#17: the book view — curated confirmed; the BODY's "+ new post in this
book" door present and used; the navigator rail's bottom doors NOT
visible. #18: carousel ⑂3 showing two cards, no pager. #19: margin grid
"2 high" showing tall clipped cards. #20: the Blocks TOC, tiny rows.
#21: Write mode with a white band mid-window and dead space below.)

**THE UNIFYING DIAGNOSIS (session): the WINDOW is taller than the screen
and refuses to shrink** — her book is CURATED (her correction + the
body door working proves `reading.kind == .curated` holds), so the
navigator doors DO render — at the rail's bottom, BELOW THE SCREEN. The
same oversize hides the editor's bottom bar (blk n/n, word counts), the
shelf's quick-entry + hint bars (the "no blinking line" half of her
Terminal complaint), and plausibly renders the #21 white band (offscreen
backing-store staleness). Unstick steps given in-chat (drag the window
down by its title bar, then resize; option-green zoom-to-fit); a sane
`defaultSize` (1240×840) added for fresh windows; if it persists after
re-positioning, the next datum is whether the bottom-right corner drag
also refuses.

**The Terminal-idiom AUDIT (her batch-8 charge, checked against R1/R3/R4):**
- The quick-entry bar (blinking cursor), the `~/shelf` ls-line, and the
  hint bar SHIPPED and are in `ShelfView` (entryBar/hintBar at the
  view's bottom; the ls-line its header) — hidden by the window bug, not
  gone. `~/` paths live in the book navigator (her own #16 shows
  "~/my book :)").
- **The `›` selection marker was defined as a token and consumed
  NOWHERE** — a REAL erosion (Stage B built the slot, no surface used
  it). First consumer wired this batch (the sidebar's selected row);
  a FULL idiom pass is queued (R100).

**Rulings (R98+; her uncertainty preserved):**

- **R98 — Smart books accept adds BY TAGGING** ("i think that smart books
  should still let you add, and should just tell you that tags are going
  to be added"): adding a post to a smart book applies the tags its
  filter needs and SAYS so; a filter the post can't satisfy by tagging
  (e.g. entry-date bounds — her "before June" example — or a profile
  mismatch) refuses with a DESCRIPTIVE message naming the filter.
  QUEUED — the next build stretch (a core op over SmartQuerySpec with
  state-transition tests; the chip's Add-to-Book list will include smart
  books once it lands).
- **R99 — The Outline tab gains "Make outline post"** (her shape: a new
  linked copy auto-named "outline of xyz", selected as the outline side;
  her uncertainty preserved — "or whatever the outline is - actual
  copy?"). Session note: `duplicateAsVersion` already mints exactly the
  structure the outline view maps (per-block lineage edges), so the mint
  is cheap; the OPEN QUESTION put to her: does the outline copy start as
  FULL TEXT (she condenses each block down) or as an empty skeleton?
  Her lens-on-the-outline-page follow-up recorded as part of the same
  item. QUEUED behind her answer.
- **R100 — The Terminal idiom pass** ("terminal has slowly but steadily
  lost all the personality details"): the `›` marker everywhere selection
  lives (sidebar done this batch; shelf rows, palette, book navigator
  next), `~/` path grammar re-checked per surface, the quick-entry bar
  confirmed visible once the window fits. Her charge to re-read the
  phase plan's Terminal specification against the shipped app is
  accepted — the audit continues next stretch with the R1/R3/R4/R12
  sittings as the checklist.

**Fixed this batch (no new rulings — defect/legibility dispositions):**
carousel blooms now show the WHOLE fan, chosen included and marked (the
⑂3-vs-2-cards mismatch dead); margin-grid cards are UNIFORM one-card
height clipped exactly like the strip ("2 high" is literally two cards);
every book post header gains **"open ↗"** into the full editor (her "way
of going into the editor view from books"); word counts labeled
readably ("12w block · 1,204w in post") with a hover explainer (her
"what is 1w post?"); Mark-as-Versions' hover now explains the POINT
(connection-not-copy; pairing in Compare/diff; the honest alignment
caveat — lineage-linked copies align block-by-block, hand-linked posts
pair loosely); the Blocks TOC rows read at body size (her "super mini");
the `›` sidebar marker (above). Blocks-page purpose explained in-chat
(the block-level table of contents — jump/reorder/name/move blocks
without scrolling prose).

### Sitting 9, continued (2026-07-19 ~3 AM — batch 8 resolution: the window ROOT-CAUSED and sanitized; the Library quick-entry directive)

**Her messages VERBATIM (standing instruction; typos hers):**

> ok, there's definitely just a bug with the view. i can't move it down
> from being stuck to the absolute top of the screen, even after
> restarting the app. I can't drag it down from the title bar, it snaps
> back into place/ zoom fit makes it wider but can't bring the bottom
> into view - it just stays still stuck as too big for teh scren and
> absolutely unmovable. it can't be shrinked and the layout is cooked.
> also, where is the quick entry bar? i don't see it at all. it should be
> a quick entry bar into a new ost straight from shelf. also, the > is
> only on one item, rather than it being a color > on the one i chos eand
> the other ones not having it. there were also inline comments like
> this: // which I liked. i don't see hwo the quick entry bar passed. and
> the resize is still broken

> make sure that the auto create new post with typing immediately on the
> library page is created the way it was in the most recent round of the
> mockups before the app is next rebuilt for me

**The diagnosis, EMPIRICAL this time** (a temporary debug window-probe run
against the dev store AND against a live backup copy of her real store —
the store copy set aside and restored): the layout demands are HEALTHY
(window content minimum ≈148pt on every probed surface; the sidebar
List's tall frame is normal scroll-under-inset geometry) — so the wedge
is a PERSISTED OVERSIZED FRAME that macOS's window constrainment keeps
re-pinning to the screen top: moves snap back, and the bottom edge with
its resize corners sits unreachable below the screen. **The fix makes
the state unsurvivable rather than chasing the original writer:**
`VariorumAppDelegate` gains a window SANITIZER — at launch and on every
app activation, any non-fullscreen window larger than its screen's
visible frame is clamped back inside it. Relaunching self-heals; nothing
she does can wedge it again. (The probe code was removed after serving.)

**Batch 8 dispositions:**
- **The quick-entry bar was never missing** — it shipped on the shelf
  (mockup-exact: hint line, field, blinking block cursor, ⏎ opens the
  post) and sat below the wedged window's fold. Her "i don't see how the
  quick entry bar passed" is answered honestly: ops and views are
  tested; nothing tests whether WINDOW GEOMETRY hides chrome — the
  sanitizer closes that class.
- **Her directive executed:** the bar is now ONE shared component
  (`QuickEntryBar`, the round-2 mockup's shape as the contract) and the
  **LIBRARY page carries it too** — type, ⏎, the typed text is a post,
  opened.
- **The › marker is now a COLOR ›** (accent, bold) on the selected
  sidebar row only — her batch-8 correction of the batch-7 wiring.
- **The `//` comments memory checked against canon:** the ratified
  round-2 mockup uses "# comment" (its idiom line reads "› selection ·
  path slashes · ~/shelf · blinking cursor · # comments · status line"),
  and "#" is what shipped on the margin comment cards. The "//" she
  remembers is the earlier direction-B draft. HER CALL whether to switch
  the token to "//" — one string in the voice layer.

Counts: core 738/88 · Mac 424/78 · mobile 11/4. Still queued: R98
(smart-book adds by tagging), R99 (outline mint — awaiting her
full-text-vs-skeleton answer), R100's remaining idiom pass.

### Sitting 9, continued (2026-07-19 afternoon — the wedged window ACTUALLY root-caused; the batch-8 diagnosis CORRECTED on the record)

**Her messages VERBATIM (standing instruction; typos hers):**

> hi claude, so we've been working on things in variorum but i've been
> experiencing a bug where the window is stuck to the absolute top of the
> mac and can't be dragged down, the top snaps to the top of the computer
> again. not sure what the deal with that is, a session tried to fix it
> but it didn't work. i coudl restart my computer but it's just an issue
> with this app. is till can't see the bottom

> it looks like you've fixed it, but the sync area needs to ahve a little
> protection from blocks because it's being written over. this loks very
> encouraging thus far though.

*(The second message reacted to a DEV-STORE debug run mid-diagnosis — the
dev store never wedged; the encouragement was premature but the overlap
report it carried was real and is fixed below.)*

**THE BATCH-8 DIAGNOSIS WAS WRONG, and this entry corrects the record.**
Batch 8 ruled the wedge "a persisted oversized frame that macOS
constrainment keeps re-imposing" and shipped a frame-clamping sanitizer.
Empirical refutation, live on her machine: with the persisted frame
RESET to 1240×840 and the Release app relaunched, the window came up
sane and then **regrew itself to 1240×1723–1731 ~5 s after launch** —
the moment the first bridge error landed. The persisted frame was the
bug's SYMPTOM (the autosave recording an inflated minimum), and the
sanitizer never fired usefully because no clamp can beat a live layout
minimum: macOS re-imposes `contentMinSize` immediately.

**The true mechanism, traced and arithmetic-verified:** the R94
inline-cause block renders in NON-SCROLLING window chrome (the sidebar's
status footer), and the window's minimum-size computation probes content
at near-zero width. `Text(authGuidance).fixedSize(horizontal: false,
vertical: true)` with NO line limit measures **one character per line**
under that probe — the ~140-char guidance ≈ 140 lines ≈ **1693 pt** —
and that becomes the WINDOW's minimum height. (The error text below it
was innocent: its `lineLimit(4)` caps the probe — which is also the
proof lineLimit bounds it.) Reproduced in the dev store by env-injecting
her exact bridge error into the footer (window min snapped to 1693,
width-independent); killed by the fix below. Why every earlier probe was
clean: the A4 fence keeps dev-store sync/bridge OFF, so the error branch
— the only tall path — never rendered in any dev probe, and the batch-8
per-surface minimums (~148 pt) were measured without an error present.

**The fix (minimal, provably bounded):** the cause block extracted into
ONE shared component (`ErrorCauseNote`, in `Shared/ErrorPresentation.swift`
— both status rows now render it) with **load-bearing line limits**:
guidance `.lineLimit(6)`, error `.lineLimit(4)` (unchanged), beside the
kept `fixedSize`. Rendering at real widths is IDENTICAL (3–4 wrapped
lines, verified by AX measurement in the reproduction). Same limit added
to `QuickEntryBar`'s error line (same hazard class, shelf/library bottom
chrome). The remaining `fixedSize(h:false,v:true)` instances live in
bounded contexts (sheets with minWidth, scroll content, the helper
window) — swept, judged safe, left alone; the class rule for future
chrome: **an unlimited fixedSize text may never sit in non-scrolling
window chrome.** **RED-ON-OLD PIN:** `ChromeMinHeightTests` measures the
real component under the same near-zero-width probe — reverting the line
limits reds it at **3395 pt measured**; shipped code greens at a few
caption lines (a second test pins that footer-width rendering stays a
real multi-line wrap, never a truncation).

**Also this entry:** her overlap report fixed — the footer VStack gains
an opaque voiced background (`tokens.room`) + top divider, so scrap rows
scrolling under the inset can never write over the sync/bridge lines.
The batch-8 sanitizer stays as belt-and-suspenders (macOS itself clamps
oversized frames at restore/resize once no min-height demand exists —
observed live; the sanitizer's activation hooks provably never fired
during the wedge, so it gets no credit and no further investment).

**Operational side-findings, recorded:** (1) her Fragments-side session
is STRANDED — the bridge fails every round with `endpointFailure(status:
400, refresh_token_not_found)`; the R94 guidance and the only Account…
doors sat below the screen edge the whole time. Sign-out/sign-in via the
now-visible footer clears it (her own outage's known remedy). (2) Her
disk hit 100% full (134 MB free) mid-session — Docker fully removed at
her direction (~17 GB back; she'll clear Claude scratch + DerivedData
after her Fragments agent settles its docs); near-full disks were
starting to fail app writes machine-wide.

Counts: core 738/88 · **Mac 426/79** · mobile 11/4. Still queued: R98,
R99 (awaiting her full-text-vs-skeleton answer), R100's remaining pass.

### Sitting 9, continued (2026-07-19 evening — batch 9: "these buttons are not the best you and I can do" — the chrome joins the voice; R101–R103)

**Her message VERBATIM (standing instruction; typos hers; screenshot #22
described below):**

> hi claude, we have been working on phase 13 and I think that we are good
> to just keep going and keep making changes. the first thing i would say
> is that the text is a little bit awkward - the buttons look very spready
> out, it's not super clear where the editor is, I think it just needs
> some more redesigning. I think the website of mockup v2 was better
> looking and the terminal one was also better looking - the start new
> post typing isn't high up and doens't look as appealing to use. [Image]
> also, we need to fix what happens in a block when one take is deleted
> entirely but others exist - does it keep its own line? I think that's
> fair. I want you to overall take a pass through and focus on useability,
> design, and joy for this project! I gave a lot of thoughts before the
> pass 13, so you can look through my original comments, the mockups, see
> what you think is carried out well and what isn't, and try to do another
> redesign pass on it. i think that there's still elements that are a
> little bit unclear, I want you to step up and think about this like a
> senior product designer and a design architect and someone who can see
> the painpoints of using this daily and work to make them better. these
> buttons are not the best you and I can do, I'm sure of it

(#22: the Takes view on a one-block post — the stock segmented mode
picker spread across the top, a full-width Aqua toolbar row beneath it
(Fan-style popup, two steppers, a checkbox, five bezel buttons), the
lone block floating in white, and a bezel-button bottom bar.)

**THE DIAGNOSIS (this pass's finding):** the voiced surfaces Stage B/C
built are canon-faithful, but the CHROME around them never joined the
voice — the mode row, the takes toolbar, and both bottom bars remained
stock Aqua controls at default spacing, bolted above and below voiced
pages. The round-2 canon's chrome grammar is the opposite: chrome is
quiet TEXT — words you can click, a chip for a toggled state, a muted
status line — and the page is the hero. "The buttons look very spready
out" and "not super clear where the editor is" are both this one gap;
her charge to re-read the mockups confirmed it (round-2 §1–3: the kbar,
the et/es masthead, "+ new take" as a CARD, no bezel anywhere).

**Rulings (R101+):**

- **R101 — The chrome joins the voice** (executes and extends R100): ONE
  voiced control vocabulary (`Theme/VoiceControls.swift` — text-word
  buttons with a hover wash + role inks, the round-2 chip, word-menus
  with their own ▾, the faint status dot) replaces stock Aqua in page
  chrome. Applied this batch: the post header becomes the round-2
  MASTHEAD (the title over its path line — the membership chip now reads
  the voice's path grammar, `~/orbit`, when the post lives in exactly
  one book; the mode row is quiet voiced words with the current mode
  wearing the color › + accent — the segmented picker retired); the
  takes toolbar collapses to ONE quiet line (style/density as word-menus,
  the R13 wash as a `wash: on` chip, expand/close as words) with the
  three rare whole-post acts folded into a `post actions ▾` menu; both
  bottom bars (Write's CommitBar, the Takes/Lenses bar) restyle as
  round-2 STATUS LINES on the room — every R63 door kept, voiced, with
  faint-dot separators; seal banners wash-tinted. Nothing lost a door;
  the rows stop shouting over the page.
- **R102 — The quick-entry bar rides RIGHT BELOW the shelf's rows** (her
  "the start new post typing isn't high up and doens't look as appealing
  to use"): the shelf's list region now HUGS its content, so the entry
  bar (+ the ⌘K hint line) sits directly under the last book — the
  round-2 mockup's geometry at every window size — while a shelf taller
  than the window still pins the bar above the fold exactly as R3 ruled.
  The shelf also opens with the cursor already IN the bar ("start
  typing" is literal now); the Library's bar keeps its pinned-bottom
  placement under the full catalog.
- **R103 — An emptied take KEEPS the block's own line** (her "does it
  keep its own line? I think that's fair" — ruled YES): on EDITING
  surfaces the block's line survives a take being deleted down to
  nothing. Write already renders it by construction (the empty slot
  between separators — pinned since Phase 7 by
  `EditorDocumentTests.emptyTakesRenderAsEmptySlots`, "one\n\nthree");
  the takes article now marks the kept line with a faint "empty take —
  line kept" note instead of an invisible void (boundaries are invisible
  at rest, so a silent empty block was undiscoverable — also the R90
  blank-and-choose gesture's visibility). Export/renderedText continue
  to SKIP blank takes (the Phase 4 ratification — output, not editing).

**Also this batch (R100's continuation):** the ⌘K palette's first row —
the one ⏎ runs — wears the color ›; the book navigator's focused post
wears it too (sidebar shipped batch 8; shelf rows have no persistent
selection to mark).

**Build record:** `VoiceControls.swift` (new — VoicedButtonStyle /
VoicedChip / VoicedMenu / StatusDot); PostDetailView (masthead + ModeTabs
+ voiced title label); MembershipChip (path-grammar label); TakesBoardView
(one-line header, voiced seal banner); TakesBottomBar + CommitBar (status
lines); EditorView (voiced seal banner); ShelfView (content-hugging list
region, autofocused entry); QuickEntryBar (autofocus parameter, presence
padding); TakesShared (the R103 marker); CommandPalette + BookView (the ›
continuations). New chrome text all carries line limits or single-line
labels (the wedged-window class rule holds — and a dev-store launch
probe confirmed the new chrome demands no inflated window minimum:
fresh window 1422×985, layer-0, sane position; screen-capture TCC was
denied so the probe is geometric, not pixel). Verification: **Mac suite
426/426 green in 79 suites** on the final code (core/mobile untouched
this batch — no VariorumCore changes). Still queued: R98 (smart-book
adds by tagging), R99 (awaiting her full-text-vs-skeleton answer),
R100's remaining per-surface audit.

### Sitting 9, continued (2026-07-19 night — batches 10–13: the question round (R98/R99/R100 answered), the block menu, Blocks as a 4th area, collapsed book pages, the bottom mode line, and TWO pinned defects; R104–R107)

**Her messages VERBATIM (standing instruction; typos hers; five messages
across one working stretch — screenshots #23–#28 described inline):**

> how do I fix the TCC blocked part? I don't want to allow audio but i
> can allow screen recording by the terminal. also, can you ask me R98,
> R99, and R100 in question format? also, I tried clicking on the + take
> button but it just opens up takes +1 and i don't see an option in the
> bottom bar where i can add a new take or anything, how do I do that at
> this poitn in time? [#23: margin grid, ⑂+ bloomed, "takes · 1", ONE
> chosen card, NO growth doors visible]

> ok so there was a different session i had that was supposed to fix
> this fixed height issue, which it mostly did, but now on lenses the
> same issue appears. […the b6dae25 report pasted…] also, I feel like we
> need a block menu. the same issue has appeared where i can see the
> takes but i can't make a new take. [#24: same rail, same missing doors]

> also, I don't like seeing the blocks on the side, i think it's way too
> crowded. i think blocks should just be a 4th area and you should be
> able to make blocks as stand alone entries, not just appended to one
> entry. it's so unlear how you're supposed to add tags right now. I
> also don't think yoiu should see the content within a post when you're
> on the book screen unless you click something to toggle that post to
> expand. or hit something to expand or collapse all books. also, the
> title of the book should be aligned to the text of the post and there
> shouldn't be so much open space to the left - refer to this image.
> [#25: the round-1 book mockup — narrow rail, title over post CARDS
> (title + excerpt + meta), everything on one leading edge]. I also feel
> like the location of where all of the write takes lenses compare
> outline blocks canvas buttons are is not very ergonomic - i would
> accept suggestions on where that should go

> [#26/#27] there's another severe issue / bug, beyond not being able to
> even make new takes. in the first image you see that i can't even see
> the full text of the take, in the second you see it expanded, but the
> text that's underneath several newlines never even shows. it just
> feels so broken and like the editor is a long way off from being
> useable still. i asked about the terminal permission controls, but
> maybe we need some testing setup where you can take screenshots /
> pictures for yourself and assess progress? it's just not feeling like
> we're moving forward. also, did you add the items from all of my
> prompts? i'm concerned by the terminal thing never having been brought
> up again.

> [#28] i don't know if my temp screenshots earlier showing the issue
> will be processed soon enoguh to make a difference, so here's the
> picture with the take expanded showing more text and showing that not
> expanded (even though the text is in the chosen take), it didn't
> appear. still not sure what the deal with the terminal permissions are

**THE QUESTION ROUND (AskUserQuestion, her answers verbatim in the
session record):** R98 → **"apply and report (the user already
deliberately tried to add it), but make sure that the filter that can't
be satisfied message still appears"**; R99 → **"First sentence per
block"**; R100's comment glyph → **"i can't see comments right now - not
sure hwo they're supposed to be made. i can only choose once i do see
them, but probably switch to //"**; the mode-row location (her
"suggestions" invitation, three previewed options) → **"Bottom mode line
(Recommended)"**.

**THE TWO PINNED DEFECTS (both hers, both mechanism-traced):**

- **The clipped take (#26–#28, "the text that's underneath several
  newlines never even shows"):** every READ take pane (cards AND the
  takes article's cells) measured its height ONCE at install — BEFORE
  SwiftUI hands it real width. A zero-width container lays out ~nothing,
  reports ~one line, and NO later event re-measures a read pane (the
  LIVE pane re-measures per keystroke — which is exactly why the
  expanded/focused take looked right while every read rendering clipped
  to one line). FIX: `TakeTextView` gains a width-gated `layout()` hook —
  the first real layout re-measures; RED-ON-OLD PIN
  (`TakePaneMeasureTests`): the hosted read pane with
  "hello\n\n\n\nhi there" measures **exactly the 24-pt floor** with the
  hook reverted (verified by behavioral revert) and grows to hold every
  paragraph shipped.
- **The Lenses window-min recurrence ("now on lenses the same issue
  appears"):** the boards' status/journal-note/footer-rule texts were
  unlimited `fixedSize` in NON-SCROLLING chrome — the exact b6dae25
  class, missed by that fix's sweep. FIX: ONE `ChromeNotice` component
  (voiced text + LOAD-BEARING lineLimit) now renders every board notice
  (Takes status + R84 note, Lenses status + footer rule, the book
  navigator's smart-book note); `ChromeMinHeightTests` gains the
  ChromeNotice near-zero-width probe pin.

**Rulings (R104+):**

- **R104 — The BLOCK MENU** (her ask verbatim): a `block ▾` word-menu in
  the takes/lenses status line — new take (branch), blank take, blank-
  as-chosen, Comments…, Open in Write — acting on the pane you're in (a
  one-block post needs no click; fire-and-speak otherwise), beside a
  one-click `+ take` twin. The same family lands on the take cell's
  RIGHT-CLICK menu (＋ new take / ＋ blank take), and Write's status
  line gains `comments`. ALSO the defect half: the margin rail's growth
  doors sat at the END of the horizontal card scroll — clipped past the
  rail width, invisible (her #23/#24) — they render BELOW the cards now,
  always on screen.
- **R105 — Blocks is a FOURTH AREA; standalone blocks are born there**
  (supersedes the rows-in-sidebar build-time call — her "way too
  crowded"): the sidebar is four flat areas (Shelf · Library · Pool ·
  Blocks); `BlocksAreaView` lists every scrap with tags, drag-out, and
  drop-in import, plus a block-flavored quick-entry bar — ⏎ mints ONE
  standalone block (never appended to a post). Recorded consequence:
  sidebar-to-editor scrap dragging retires with the rows (the pool
  editor and canvas remain the side-by-side scrap surfaces).
- **R106 — Book pages collapse to CARDS by default** (her ruling + the
  #25 mockup): a book shows title-excerpt-meta cards ("2,140w · ⑂ takes
  on 2 blocks" class), click to expand in place (the focused/live post
  is always expanded), `expand all · collapse all` beside the book's
  meta line; the book TITLE now heads the CONTENT COLUMN, and the column
  is LEFT-ANCHORED beside the navigator (the centering gulf is gone).
- **R107 — The mode row is the BOTTOM MODE LINE** (her pick): write ·
  takes · lenses · compare · outline · blocks · canvas as voiced words
  at the window's bottom edge (the terminal modeline idiom), the current
  mode wearing the color › + accent; the masthead is pure title + path.
  Honest note: the mode line renders BELOW each view's status line (her
  preview drew it above; hoisting the status bars out of all seven mode
  views is the flip if she wants it — one structural pass).
- **Tags discoverability** (her "so unclear how you're supposed to add
  tags"): a `tags…` door in BOTH status lines (Write + Takes/Lenses)
  opening the post's tag sheet in place. (The Settings manager and
  Library batch-tagging stand unchanged.)

**R98/R99/R100 executions:** R98 BUILT per her refinement —
`Operations.collectPostIntoSmartReading` (apply-and-report; the add IS
the tagging, no membership row; every unsatisfiable filter refuses
DESCRIPTIVELY: malformed spec, profile, date bounds naming the bound,
archived post, a filter tag that no longer exists — build-time call: the
op never mints taxonomy), 6 state-transition tests; the chip's Add menu
gains smart books "(by tagging)" and the shelf drop routes smart books
through it with a muted REPORT line (never red). R99 BUILT —
`Operations.mintOutlinePost` ("outline of <title>"; first sentence per
block via the tocHandle rule, names ignored; empty blocks seed EMPTY —
the mint never invents prose; honest-direction `derived_from` per block
+ the first-pair `version_of` anchor; refuses blockless; undo =
revertMintedContainer), 3 tests; the Outline tab gains the `make outline
post` door (header + empty state) and the kin mapping unions BOTH
derivation directions (a hand-written outline's draft descends from it;
a minted outline descends from the draft — both pair now). R100's
glyph: terminal `commentPrefix` → **"// " (PROVISIONAL — her "probably";
she ratifies once comments are visible, which R104's doors now make
reachable)**; ThemeTests pin updated with the provisionality noted.

**Verification:** core `swift test` **747 green in 90 suites** (was
738/88 — the two new suites); Mac suite **428 green in 80 suites** (was
426/79 — the TakePaneMeasure pin suite + the ChromeNotice pin; the two
BookViewTests hosting tests adapted to R106 via the `initiallyExpanded`
seam — all-expanded must STILL virtualize, the stronger P3 claim); both
defect pins verified red-on-old by behavioral revert (the pane pin read
exactly the 24-pt floor with the hook reverted). **Operational note for HER (the terminal question,
answered in-session):** System Settings → Privacy & Security → Screen &
System Audio Recording → add Terminal
(/System/Applications/Utilities/Terminal.app) — screenshots are silent
stills, no audio is granted; macOS asks to relaunch Terminal, which ends
the running Claude session, so grant between sessions. Once granted,
sessions can screenshot the dev-store app and self-review (the
launch/window-probe machinery already ships in-session).

### Sitting 9, continued (2026-07-20 ~midnight — batch 14: THE VISUAL LOOP ARRIVES; the frozen-article root cause; the sidebar mode rail; the dashed-box entry; R108–R110)

**Her message VERBATIM (standing instruction; typos hers; screenshots
#29–#35 — incl. the round-1 shelf mockup and book mockup as references):**

> ok, i turned the terminal capability on. let me know if you can do it
> and if you can't do it, i may have to quit and restart. also, i like
> this box cutout separation more and think it looks more like the
> terminal. can we get the advice bar with commands moved to the bottom?
> also, there seems to be a bug in that when something is chosen, it
> still doesn't appear as chosen in the space above. also, lines multiple
> paragraph breaks below the start of a take still aren't appearing when
> the take isn't expanded, so our fix wasn't thorough enough. also, the
> bottom looks too crowded with the two blocks. I think the different
> modes should be on the left, in the same verticle pane as shelf /
> library / pools, but with a separator so it's clear that it's only for
> when you're within a post. expanded view: [image] non expanded:
> [image] just straight up missing the rest of the blocks. in margin
> grid it appears, but also the margin grid is not showing the blocks 2
> high even when that setting is made. we just need a lot more work.
> even when there is a comment, i can't really see the comment anywhere
> (I suppose it oculd go on the left in the blank area). I also said in
> my earlier message that I wanted the title aligned with the text, like
> how the mockup looks, for a neater view. can you go back and read
> through all my messages more thoroughly? I feel like communication is
> breaking down under how many issues there are and you aren't seeing
> everything i've said.

**THE VISUAL LOOP IS LIVE:** her Screen-Recording grant works with NO
Terminal restart — sessions now `screencapture` the real screen, launch
the dev-store Debug app, find its window (CGWindowList), and SEE their
work. This batch's shelf changes were verified by screenshot against the
round-1 mockup open in her own browser. Standing practice from here: any
visual change gets a dev-store screenshot before shipping.

**THE FROZEN ARTICLE, actually root-caused (both her reopened reports —
one mechanism, two hazards, pinned):** `TakesViewModel.liveBuffers` was
`@ObservationIgnored` — a keystroke in the live pane updated the buffer,
but SwiftUI NEVER re-evaluated the read rows that mirror it through
`resolvedTake`, so the article cell froze on stale text AND stale
height until the projection eventually caught up ("doesn't appear as
chosen in the space above"; "multiple paragraph breaks below the start
still aren't appearing"). Second hazard, visible in her screenshot as
TWO live rings: the fan cards shared the article cell's pane key
(`takes-main` + block + variant) — focusing the CHOSEN take's card made
the article cell "live" too, and a live pane never adopts text. FIXES:
liveBuffers is OBSERVED (invalidation ∝ realized rows — P3-bounded; the
live pane stays buffer-authoritative behind the `!isLive` adopt guard),
and the fan cards pane in their own `takes-fan` namespace (exactly ONE
live ring again — R22). PIN: `TakesArticleRenderTests` (3 tests over
the REAL mounted board — closed-fan full-text/full-height, the
edit-follow, and `focusedChosenCardNeverFreezesTheArticleCell`, which
REDS with either half reverted — verified by behavioral revert).

**Rulings (R108+):**

- **R108 — The post modes live in the SIDEBAR** (supersedes R107's
  bottom line — "the bottom looks too crowded with the two blocks"): a
  separated `this post` section under Shelf/Library/Pool/Blocks, shown
  only while a post is open, the current mode wearing the color ›
  (PostDetailView broadcasts `variorumModeDidChange`; the rail switches
  via the standing `variorumSwitchMode` door; ⌘1–⌘7 unchanged). The
  bottom holds ONE status line again.
- **R109 — The quick entry is the DASHED-BOX cutout** (her call, mockup
  attached): hint INSIDE the box as the placeholder, blinking block
  cursor, no divider — floating under the last shelf row; the ⌘k advice
  bar moves to the WINDOW BOTTOM with the void between (screenshot-
  verified against the mockup).
- **R110 — Density outranks the strip**: R24's one-card-high horizontal
  strip is the 1-HIGH look; an explicit "2/3 high" margin-grid setting
  stacks cards even for short blocks ("not showing the blocks 2 high
  even when that setting is made").
- **Comments in the takes margin** (her placement suggestion): a block
  with comments shows its first one LEFT of the article cell —
  glyph-prefixed ("//" now visible for her R100 call), rule-edged,
  "+N more", click for the full panel; fetched per realized row.
- **Alignment, this time as she meant it**: the post MASTHEAD and the
  takes control line share the ARTICLE's measure and left edge (title
  directly over the text, one column — margin-grid widens both
  together). Batch 12's book-title half stands.

**Verification:** Mac suite **431 green in 81 suites** (was 428/80 — the
three article pins); core untouched at 747/90; the frozen-article pin
red-verified by behavioral revert of each half; shelf verified BY
SCREENSHOT against the mockup. Open questions left with her: none new —
#23–#27, typographic-PDF, and the "//" ratification (now seeable) stand.

# THE EXECUTION PLAN (DRAFT — for the author's review, then `/run-phase 13`)

## Kickoff message (for the coordinator session)

> You are starting **Phase 13 of Variorum** — the UI design build: two voices over
> one structure, the books/shelf IA, and the small model additions the design
> sittings ruled (comments, callouts, chapters, word targets). **The five design
> sittings above are BINDING INPUT** — the author's verbatim words and rulings
> R1–R43 outrank taste; where this plan says PROPOSED, ask her at the checkpoint,
> never decide. Read, in order: `CLAUDE.md`; this file IN FULL (sittings first);
> `notes/plans/phase-13-brief.md`; `notes/OverallModel.md`; `notes/AppSpec.md`
> (§12, §14's 2026-07-17 delta); `notes/SyncSpec.md` §12; `notes/TEXTKIT2_NOTES.md`
> (§3 rendering-attribute fragility governs every editor decoration);
> `Spikes/Phase11Mockups/mockups.html` + `mockups-v2.html` (the Study voice's
> CANON — R12) and `Spikes/Phase13Mockups/` round 1 + 2 (the Terminal voice + the
> merged shape). **Baselines — do not re-run at session start: core 651/77 · Mac
> 380/68 · mobile 11/4.** Staffing: decided at this kickoff by the author
> (CLAUDE.md model policy — the sittings were author-attended Fable; execution is
> an ordinary cast; the Sync/ rider stands regardless). Environment traps: piped
> xcodebuild masks exit codes; a live app instance blocks the Mac test runner
> (NEVER kill her running Variorum.app); wrong `-only-testing:` names report
> vacuous success; SwiftUI `.task` doesn't fire under the test host.
> **Staffing (author, 2026-07-18 — R54): coordinator Fable · implementer FABLE ·
> cold reviewer FABLE, the 10/11 same-model shape; the Sync/ rider stands.**
> **Execution is FULLY AUTONOMOUS (R55): no mid-phase author questions — every
> ambiguity, product-flavored included, gets PROVISIONAL-and-continue (implement
> the most defensible reading, record it, keep building); her one planned
> touchpoint is the END taste checkpoint (R48). The lockstep deploy is
> pre-authorized (R53) via the stored PAT arrangement.** The anchor set (R56):
> `Phase13Mockups` direction B = the terminal voice, direction C = the
> reading/book view, `mockups-v2.html` = the active editing surface, round 2 =
> the merged rules.

## Ground rules (binding)

- **P1–P3 re-verified after every milestone** — a beautiful editor that regressed
  keystroke cost failed the phase (the brief's binding list).
- **Decorations stay off the live editor** (TEXTKIT2 §3): seams, rings, washes,
  handles, comment margins render as overlay views / read-tier styling — the
  Phase 7 badge pattern — never TK2 rendering attributes on the live NSTextView.
- **Calm default, one block blooms** is architecture; the design expresses it.
  Boundaries invisible at rest (seam toggle = global setting, R42); the white-gap
  rule (R17) governs every colored block.
- **A voice = tokens + idioms** (R1): the Terminal voice's `›`/slashes/`~/`/cursor
  and the Study voice's sepia/paper/serif are load-bearing; no flattening into a
  palette swap. Hold at exactly two voices (R12). Light designed first; dark = a
  FULLY BLACK background (author re-ruling, sitting 6 — supersedes the earlier
  grey note).
- **Margins are sacred** (R9). **Everything visible in an editing surface is
  editable** (R8/R23). **No per-block background colors except callouts** (R6).
- No new third-party dependencies (design systems included) without the author.
- Tests per the standing expectations: schema/ops changes land with exact tests;
  view models get focused coverage; pure-visual SwiftUI faces may be untested but
  every behavioral seam (settings, toggles, membership chips, travel rules) is
  pinned.

## Stage A — substrate (the one lockstep event + the pulled-forward Phase-12 items)

**A0 — kickoff measurements + design corpus + restore drill** (the deferred-12
pull-forwards): (i) the three prerequisite numbers — rendering/decoration budget
on the live editor, read-tier per-view cost at scale, keystroke headroom under
decorations — measured against (ii) a seeded DESIGN CORPUS in the dev store
(A4-fenced; realistic shelf: several books incl. journals, hundreds of posts,
fans, scraps) that also serves every design checkpoint; (iii) the backup restore
drill executed and its runbook recorded (KnownIssues row closes). *Tests: the
measurement harness records numbers in this plan's closeout; the drill's
automated half per the 12 plan's Step 5 wording.*

**A1 — schema, own commits, ONE SyncSpec §12 lockstep event** (all additive):
- `block_comment` (id, block_id, text, created_at, updated_at, deleted_at,
  sync_version, owner_id) — multiple per block; NO uniqueness; cascade: block
  tombstone → comments (exact-stamp, restoreBlock-compatible); outbox triggers;
  registry + serializer walks.
- `block.presentation` (nullable TEXT/JSON: kind/color/emoji) — the callout
  frame (R16/R27), identity-level like `block.name`, CAS metadata.
- `reading_section` (id, reading_id, name, position, created_at, updated_at,
  deleted_at, sync_version) + `reading_post.section_id` (nullable) — chapters
  (R28); dangling section_id reads as unsectioned (the chosen-variant fallback
  class); reading cascade extends to sections.
- `reading.word_target` (nullable INTEGER) — bounded-length notebooks (R38's
  bounded thread; extendable at the boundary).
- SmartQuerySpec gains `tagsAll` (AND-of-tags, R30) — JSON vocabulary only, no
  migration; old clients ignore unknown keys by the ratified v1 rule.
- `06_phase13_lockstep.sql` (mirror tables + lockstep marker bump); **deploy
  AUTHORIZED and UN-GATED (R53, supersedes R47):** the phone app is REMOVED (no
  un-updated client exists; the 11a interim constraint dissolves) — the lockstep
  is **mirror → Mac only**; deploy when these artifacts land, via the stored PAT
  arrangement (the 9c precedent; her sitting-7 authorization on record).
  Accepted consequence: the pre-13 installed Mac app visibly refuses to sync
  from the marker bump until the phase's build replaces it. The phone reinstalls
  onto current schema whenever she next wants it (Phase 15's orbit).
*Tests: migration walks, cascade/tombstone pins, serializer completeness, the
lockstep-refusal pin — the full Phase 11a A1 discipline.*

**A2 — comment/callout/section operations + travel rules:** comment CRUD with
tombstoned-comments recovery (visible, resurrectable — R: never skimpy);
**comments DUPLICATE onto structural successors** (extract/divide keep A's and
copy to the minted half; divide-W copies to B and C; merge carries both onto A′;
pool-copy/promote/duplicate carry them) — each with a state-transition test;
`setBlockPresentation`; section CRUD + reorder + membership-assignment ops;
`word_target` setter. *Tests: per-op transitions incl. every travel rule; undo
inverses where structural.*

## Stage B — the structure (IA + shelf + books), Terminal voice first

**B1 — the token/voice layer as its own module:** tokens (type, color, surface,
spacing) + IDIOM SLOTS (selection marker, path grammar, label voice, cursor,
comment presentation); the two voices; the global settings (voice, seam
visibility, editing indicator off/outline/background, inline-comments,
follow-the-scroll). Light first; the fully-black dark for both voices (R51).

**B2 — the sidebar + Shelf + Library:** sidebar = **Shelf · Library · Pool ·
Blocks** (R44 final: Pool top-level — random posts land there; Journal pinned
INTO the shelf (R38); no Tags tab but tag HIERARCHY stays SURFACED and tags are
edited in context (R45); Canvas a post view (R40)). The shelf: terminal LIST
style with TAGS column (R4), pinning (R38), finish + word-target faces
(`reading.locked` / `max_posts` / `word_target` finally visible), the **bottom
quick-entry bar** (blinking cursor; Enter → whole post; list scrolls under a max
height — R3); ⌘N = New Post (R41); **⌘K palette** (posts, books, commands —
every buried capability typeable, R15). Library = EVERYTHING (books, posts,
blocks; sortable, searchable; timeline as a view mode). **The tags column is an
ADDABLE batch-tagging surface in Pool and Library (R46).** **Tag management gets
its real home in SETTINGS (R52): create tags, adjust hierarchy, rename —
⌘K-reachable; in-context editing everywhere stands.**

**B3 — books:** the book view with **real chapters** (reading_section rows,
movable with drag handles + the Notion insertion bar — R19), drag-posts-in,
promote-tag(s)-to-book with AND/OR (R30/R37 — the tag stays), the **multi-book
membership indicator + duplicate-as-version door** (R35 — the editor states
"also appears in N books"), the terminal **book navigator** (chapters/outline/settings; post-click opens in
the current editor; no chapter view — R43), **journal books per R50** (binding =
ordinary membership, curated or tag→promoted; the one-entry-per-day rule
UNTOUCHABLE — the daily-vs-other-journal-books day interplay is this step's one
design detail, resolved inside that constraint), and the reading-flow view mode
(direction C) with finished books opening into it.

## Stage C — the editor surfaces

**C1 — the writing surface:** margins (R9), dotted seams on the global toggle
(R42) with the 9d tint mode's look RETIRED, the editing-indicator setting
(off/outline/background, off default; the always-on marginalia wash+ring rule —
R22), word-count prominence (R11), block drag handles + insertion bar (R19),
callout rendering with white gaps (R17; export maps to blockquote), **comments:
margin default, inline-tinted setting (R7), deleted-comments surface**.

**C2 — takes presentations:** the v2-canon active view as an editor view option
(R12); marginalia incl. the short-block one-card-high HORIZONTAL strip (R24);
the inline stack; **follow-the-scroll as a takes-viewing option in all modes**
(R25); expand-all only where meaningful (not offered in columns/slot-split);
every take editable in place, live editor migrating (R23; P3 holds).

**C3 — canvas as a post view** (R40): reachable from a post/scraps, spatial
arrange, the MINIMAL takes switcher only ("see takes" → one-at-a-time) — built
as the mobile-inheritable pattern.

## Milestone gates (every stage boundary)

Full suites green at baseline+; the A0 numbers re-checked (no decoration
regression); TEXTKIT2 §5 on the current point release; canary silent; a cold
review over the accumulated diff per the ladder rules. **The TASTE CHECKPOINT is
ONE, AT THE END (R48 — author re-ruling, supersedes per-milestone taste gates):**
she judges the WHOLE assembled thing on the running app over the design corpus —
"i won't be able to tell if i like the structure if it all still looks bad" —
her reactions become further sitting entries here, and a fix round follows
before the phase closes. `/Applications` refresh after each Mac-app milestone.

## Closeout ritual (adapted)

Results + dispositions here; the canonical-doc ratification batch (CoreDescription
pillar 3's chapter line → reading_section; the tags-flat surface note; the
block-is-its-own-paragraph clarifying line; §12's view-list updates incl.
canvas-as-view; §14 delta pointing at this file's sittings; SyncSpec §12 event
record; **AppSpec §7 DDL** — `block_comment`, `reading_section`,
`block.presentation`, `reading_post.section_id`, `reading.word_target` (the
canonical schema must not lag the four shipped migrations — round 3 MINOR);
**AppSpec §9 operations** — comment CRUD/travel + `restoreBlockComment`,
section CRUD + `restoreSection`, `setBlockPresentation`/
`updateBlockPresentation`, `setReadingWordTarget`/`setReadingMaxPosts`,
`assertReadingAcceptsPosts`; **the ratified SmartQuerySpec vocabulary gains
`tagsAll`** in §14's Phase 4 record); master plan row 13 → done, pointer → **Phase 12** (now with real-use
evidence accumulating); KnownIssues reconciliation (restore-drill row closes;
typographic PDF row disposition); the author handoff LAST, checklist at top (the
deferred 11b walk items fold into her first real session with the new UI).

---

# STAGE A CLOSEOUT (2026-07-18, single Fable implementer session — the review ladder's anchor)

**Run shape:** A1 schema commits 1–4 → the sync-shaping commit → THE DEPLOY
(pre-authorized, R53) → A2 → A0, one commit per step, each commit's own suite
green, the FULL three suites green at the stage gate. Commits: `1dc8656`
(v1_8 block_comment) · `f19b519` (v1_9 block.presentation) · `bd5e322`
(v1_10 reading_section + section_id) · `db614d4` (v1_11 word_target) ·
`72dc3cb` (sync shaping, lockstep 3) · `498eab5` (A2 travel + tagsAll) ·
`e109480` (A0). **Stage gate counts: core `swift test` 703 green in 85
suites (baseline 651/77) · Mac app 380 green in 68 suites (baseline,
non-vacuous — 381 ✔ lines in the log) · mobile 11 green in 4 suites.**
Canary status, stated precisely (round-1 NIT 2's correction): the Mac
suite's standing `willSwitchToNSLayoutManager` canary tests are green; the
decoration spike installs NO in-run observer — its whole canary is the
explicit TK2 opt-in precondition at construction plus (post-review) the
reposition-path precondition, which CRASHES the run on a mid-measurement
fallback rather than silently measuring bare inserts. No macOS point
update since the Phase 6 spike's 26.4.1 (25E253) — the TEXTKIT2 §5 matrix
stands on the same build the A0 spike just re-exercised.

## A1 — the schema, the ONE SyncSpec §12 lockstep event (v1_8–v1_11)

- **v1_8 `block_comment`** — id/owner_id/block_id/text/created_at/updated_at/
  deleted_at/sync_version; NO uniqueness (no natural key → no repair class);
  `idx_block_comment_block`; cascade block→comments with the block's EXACT
  stamp (own trigger); outbox capture via the shared helper; joins
  `flipBlockCascadeTombstones` so `restoreBlock`/`restoreContainer` revive
  cascade victims while independently-deleted comments stay dead (pinned).
  Ops: `addBlockComment` / `editBlockComment` / `deleteBlockComment` /
  `restoreBlockComment` (the resurrection door — deleted comments visible
  via `Queries.deletedBlockComments`, "never skimpy"); `Queries.blockComments`
  + `commentCounts` (the C1 margin feed). Comment text is METADATA under the
  merge matrix (server-version-wins CAS) — S5 stays scoped to
  `variant.working_text` by design (QUESTIONS #23).
- **v1_9 `block.presentation`** — nullable TEXT, canonical sorted-keys JSON
  (`BlockPresentation`: kind/color/emoji; kind "callout" ships; `color` is a
  THEME-TOKEN name — the R1 two-voices rule forbids storing palette values);
  identity-level like `block.name`; takes SHARE the frame (R16). `setBlock
  Presentation` mirrors `setBlockName` (no-op guard, no touch/churn, seal-
  refused PROVISIONAL). Malformed stored JSON reads as a PLAIN block (fail-
  open — losing a frame renders prose; fail-closed stays the query doctrine).
- **v1_10 `reading_section` + `reading_post.section_id`** — chapters (R28/
  R50): ordered rows (fractional positions; duplicate names legal), no
  nesting; membership's `section_id` = which chapter; A DANGLING pointer
  reads as UNSECTIONED (the chosen-variant fallback class — deleting a
  chapter never rewrites memberships; pinned at stored-pointer and
  resolved-read levels; NO repair rides the pointer). Cascade reading→
  sections (exact stamp). Ops: `createSection`/`renameSection`/
  `deleteSection`/`reorderSection`/`assignPostToSection`; locked reading
  freezes chapter STRUCTURE while rename stays free (the `renameReading`
  parallel); smart readings refuse chapters (QUESTIONS #25). Registry entry
  placed BEFORE `reading_post` — the standing FK-order walk caught the
  original placement (apply order stays FK-friendly).
- **v1_11 `reading.word_target`** — the words-based extent TARGET (§14 item
  10): display/progress semantics, deliberately NEVER an add-time refusal
  (pinned); `setReadingWordTarget` + `setReadingMaxPosts` (the v1 column's
  FIRST setter); both refuse non-positive and refuse under a locked reading;
  lowering `max_posts` below membership is legal (adds refuse at the
  standing capacity gate).
- **Sync shaping:** `lockstepVersion` 2→3; repairs' `deadParentStamp` +
  direction-1 enumeration cover both new children; `AuthRLSDDLTests`
  reworked to the THREE-file deployed composition (04+05+06, last-body-wins)
  with a NEW marker-monotonicity pin; `SupabaseTransportTests` composes
  01+05+06; `Phase13SyncConvergenceTests` (5): metadata across the wire,
  the comment CAS race (ONE row, no conflict variant), cross-device exact-
  stamp cascades, the section-delete-races-assignment dangle (NO repair —
  read-time fallback on both devices), restoreBlock revival propagation.

### THE DEPLOY — EXECUTED (2026-07-18, R53's pre-authorization; the 9c/11a PAT arrangement)

`Server/supabase/06_phase13_lockstep.sql` executed VERBATIM on the
production mirror via the Management API (HTTP 201). Verified in the same
sitting: `sync_schema_version()` = **3**; `block_comment` and
`reading_section` present with ZERO rows; RLS enabled on both; all three
new columns live (`block.presentation`, `reading.word_target`,
`reading_post.section_id`); both RPCs + the version RPC in place. **The
lockstep is mirror → Mac only (the phone app is removed — R53); the
accepted consequence is NOW LIVE: the pre-13 installed Mac build visibly
refuses to sync (outbox intact, cursor unmoved) until this phase's build
replaces it at `/Applications`.** Build work rides the dev store meanwhile.

## A2 — travel rules + the tagsAll vocabulary

- **Comment travel (duplicate-onto-successors, her ratified instinct):**
  extract/divide keep A's and copy to the minted half; divide-W copies to B
  AND C (A, preserved whole, keeps originals); merge carries BOTH sides onto
  A′; poolDragCopy/duplicateAsVersion/promoteLens carry per-block copies.
  Copies are fresh owner-stamped rows with the source's `created_at`
  PRESERVED (a note's date is part of the note; keeps order stable —
  PROVISIONAL, QUESTIONS #23); DELETED comments never travel. Undo needed
  ZERO new machinery (pinned): reverting a mint cascades the copies away;
  originals untouched.
- **Presentation travel:** structural successors INHERIT the source's frame
  (the span was the callout's content); merge keeps the frame only when
  BOTH sources agree, else mints PLAIN (QUESTIONS #24). The copy family:
  `duplicateAsVersion`/`promoteLens` copy presentation AND `block.name`
  together; **`poolDragCopy` copies presentation (and comments) but has
  NEVER copied `block.name`** — a pre-existing asymmetry this phase's
  additions made visible (round-1 finding 3; the original "copies it like
  block.name" wording here was wrong for that one op). Behavior left AS
  SHIPPED — aligning it either way is the author's call, recorded as
  QUESTIONS #24(e). `mintBlock`/`mintFanBlock` gained the parameter
  (default nil — `newBlock` unchanged).
- **`SmartQuerySpec.tagsAll` (R30):** one conjunct per path, subtree
  semantics each, AND-composing with the v1 fields; JSON vocabulary only —
  nil encodes ABSENT, so pre-13 specs round-trip byte-identically (pinned).
  The promote-tag(s)-to-book GESTURE is B2/B3's face over this vocabulary.

## A0 — measurements + design corpus + restore drill (the deferred-12 pull-forwards)

### (i) The three design-prerequisite numbers (Spikes/Phase13DecorationSpike; RELEASE build, macOS 26.4.1/25E253; 220-block ≈ 10k-word document, editor 700×900)

| measurement | median | p95 | max |
|---|---|---|---|
| (a) keystroke edit path, BARE (insert + viewport ensureLayout) | 0.57 ms | 0.75 ms | 1.00 ms |
| (a) + paragraph GAP (paragraphSpacing 12 — the Phase 10 presentation gap) | 0.58 ms | 0.75 ms | 0.83 ms |
| (a) + GAP + OVERLAYS (18 seams + 18 badges + ring, fragment-geometry repositioned per keystroke) | 0.61 ms | 0.79 ms | 1.01 ms |
| (a) overlay reposition alone (the scroll-tick cost) | 0.02 ms | 0.02 ms | 0.02 ms |
| (a) FOR THE RECORD: rendering-attribute add/remove over the viewport (§3 caveat STANDS — the rule is overlays) | 0.68 ms | 0.92 ms | 0.99 ms |
| (b) read-tier per-view setup+fullLayout, 200 views (180×5-block + 20×50-block) | 0.44 ms | 3.69 ms | 3.88 ms |

- **(b)** re-verifies Phase 10's 0.35 ms-median construction at design-
  corpus scale (the p95 tail is the 50-block posts); memory Δ1.4 MB at a
  dozen live views, Δ25.8 MB at 200 — the real tier virtualizes and never
  holds 200.
- **(c) keystroke headroom vs the 8 ms bar: 7.21 ms decorated** (bare
  7.25 ms). The ENTIRE Stage C decoration language — seams, ring, badges,
  gap — costs ~0.04 ms at p95 as overlays. **Design verdict for Stages
  B/C: the decoration budget is a rounding error when the ground rule
  (overlays, never rendering attributes) is followed; no styling decision
  in this phase is perf-constrained at these scales.** These are the
  baseline numbers every milestone gate re-checks.

### (ii) The design corpus (Spikes/DesignCorpusSeeder — the DEV store, A4-fenced by construction)

Seeded 2026-07-18 into `Variorum-dev/variorum.sqlite` (existing store moved
aside timestamped — never deleted; every row through the operations layer;
rows born unowned; the dev store never pairs with the mirror): **193 posts
+ 1 pool · 625 blocks · 710 variants · ~44k words · 35 comments · 4
chapters · 5 books · 9 hierarchical tags · 8 canvas positions · 1 lens.**
The shelf it draws: the daily journal (~96 dated entries, IN a curated
"Journal 2026" book — R50's ordinary-membership shape), the bounded
**Dream Journal** (word_target 10,000 — the shelf's "62% of 10,000w"
material), **Orbit** (18 posts across 4 real chapters with fans, comments,
callouts), the finished **Letters, 2025** (28 posts, locked),
the **attention** series (URL references), **star-notes** (a smart book
from a tag, locked), a ~10k-word long draft (scroll-feel material), 25
bookless quick posts (the Pool population), 30 scraps (fans, block tags,
canvas positions), and recovery material (an archived post, a deleted
post, a deleted block, a deleted comment). Re-seed anytime:
`cd Spikes/DesignCorpusSeeder && swift run DesignCorpusSeeder --replace`.

### (iii) The restore drill — EXECUTED (the KnownIssues row closes)

**Automated half:** `StoreRestoreDrillTests` (2 green) — a cold copy taken
MID-ACTIVITY via the A1 backup API opens through the recoverable-open path:
`integrity_check` ok; content renders whole (post, fan, comment, chapter);
the post-backup edit is absent (the copy is the snapshot); the restored
copy is a fully LIVE store (post-restore writes work); the rotation
filename round-trips; self-contained (no sidecar files required).
**On-disk rehearsal:** executed against the freshly seeded dev store —
backup → `Variorum-dev/Backups/variorum-backup-seed-drill-*.sqlite` →
`openStore` → integrity ok, container counts match (seeder output is the
record). The REAL-store drill differs by exactly one path substitution
(runbook step 1); it was deliberately NOT run against her store (autonomy
posture: real-store access stays author-assisted — Phase 12 Step 0's rule).

**THE RESTORE RUNBOOK (kept current by deferred-12's Step 5):**
1. Pick the newest copy in `<store dir>/Backups/` (real store:
   `~/Library/Containers/io.lduarte.Variorum/Data/Library/Application
   Support/Variorum/Backups/`; names sort chronologically).
2. COPY it aside (never operate on the only backup):
   `cp variorum-backup-<stamp>.sqlite ~/Desktop/restore-candidate.sqlite`.
3. Verify: `sqlite3 restore-candidate.sqlite "PRAGMA integrity_check;"` →
   `ok`.
4. Inspect content headlessly if wanted (it is a plain SQLite store), or
   open it as a store: quit Variorum, move the damaged
   `variorum.sqlite`(+`-wal`/`-shm`) aside — NEVER delete — and put the
   candidate in its place as `variorum.sqlite`; relaunch. The recoverable-
   open path (`openStore`) migrates it forward if it predates the current
   schema.
5. The restored store renders the library/posts/fans/journal as of the
   backup instant; work written after the backup lives only in the moved-
   aside damaged store and the mirror.
6. **THE SYNC RULE (the A4-fence posture):** the copy carries the
   original's `sync_state` cursor, outbox, and `sync_row_seq` VERBATIM. A
   restored REAL store may sync again — the engine's CAS/merge machinery
   reconciles it against the mirror (stale rows re-pull; S5 rescues any
   text race as conflict takes) — but do it DELIBERATELY: relaunch, let one
   full pull→push round converge, then dump-compare against the mirror
   before trusting the reunion. A restored DEV/drill copy must never be
   pointed at the production mirror at all.

## PROVISIONAL dispositions (R55: noted-and-continued; the end-checkpoint walk)

Logged as QUESTIONS #23 (comments: seal posture · created_at preservation ·
metadata-CAS-not-S5 · deleted-comments-don't-travel), #24 (presentation:
seal posture · inherit-on-split · merge-agree-else-plain · token-name
colors · (e) the poolDragCopy name asymmetry), #25 (sections/extents:
curated-only · locked-reading postures · word_target-never-enforces · the
added `setReadingMaxPosts` · (e) the chapter delete/restore shape). Zero
stop-and-ask items arose; nothing gated the core.

# STAGE C HANDOFF (2026-07-18 — for a FRESH implementer session; this section is self-contained by contract)

**State: Stages A and B are COMPLETE, including review rounds 1 (Stage A,
all five findings fixed) and 2 (Stage B, all thirteen findings fixed) —
dispositions in the two round sections below. STAGE C HAS NOT STARTED.**
The author directed a fresh session for Stage C (context management);
round 3 — the FINAL reviewer session under the ladder cap — runs at the
Stage C boundary over Stage C plus the round-2 fixes.

**A fresh Stage C session reads, in order:** `CLAUDE.md`; this file IN
FULL (sittings 1–8 first — R1–R58 are BINDING; the execution plan's Stage
C section and ground rules; both review-round disposition sections);
`notes/plans/phase-13-brief.md`; `notes/AppSpec.md` §12 + §14's 2026-07-17
delta; `notes/TEXTKIT2_NOTES.md` §3 (rendering-attribute fragility governs
EVERY editor decoration — overlays only, the Phase 7 badge pattern);
the R56 anchor set: `Spikes/Phase11Mockups/mockups-v2.html` (the active
editing surface's CANON — R12), `Spikes/Phase13Mockups/direction-b` (the
terminal voice), `direction-c` (the reading/book view),
`round-2-terminal-first.html` (the merged rules).

**Stage C's scope (the execution plan's letter):**
- **C1 — the writing surface:** margins (R9), dotted seams on the global
  toggle (R42 — the setting + queries exist: `Queries.themeSettings.
  seamsVisible`; the 9d tint mode's LOOK retires), the editing-indicator
  setting faces (off/outline/background — `EditingIndicatorStyle` ships;
  marginalia's always-on wash+ring rule per R22), word-count prominence
  (R11 — `Queries.wordCount` is the one counting rule), block drag
  handles + the Notion insertion bar (R19), CALLOUT rendering with white
  gaps (R17; `block.presentation` + `BlockPresentation` ship; export
  maps to blockquote — the export half is C1's), COMMENTS UI (margin
  default, inline-tinted setting — R7; `Queries.blockComments`/
  `deletedBlockComments`/`commentCounts` + the CRUD/travel ops ship; the
  deleted-comments recovery surface is C1's face).
- **C2 — takes presentations:** the v2-canon active view as an editor
  view option (R12); marginalia incl. the short-block ONE-CARD-HIGH
  HORIZONTAL strip (R24); the inline stack; follow-the-scroll as a
  takes-viewing option in ALL modes (R25 — the setting ships);
  expand-all only where meaningful (not in columns/slot-split); every
  visible take editable in place, ONE live editor migrating (R23/R8; P3
  holds mechanically).
- **C3 — canvas as a post view** (R40): reachable from a post/scraps
  (NOT the sidebar — already removed), spatial arrange (`canvas_layout`
  + ops ship), the MINIMAL takes switcher only ("see takes" → one-at-a-
  time) — built as the mobile-inheritable pattern (R58: she now leans
  takes-on-mobile; the minimal switcher is that surface's seed).
- Stage C also owes: palette block hits' CARET-PRECISE landing (round-2
  finding 6 recorded it as C's), and the R19 polished drag bar for
  chapters (Move Up/Down shipped functional in B3).

**Binding constraints a fresh session must not re-derive:** the ground
rules section above (decorations OFF the live editor — overlay views
only; white-gap rule R17; margins sacred R9; voice = tokens + idioms —
use `Theme/VoiceTokens.swift`, never literal colors; fully-black dark
R51); the A0 measurement baselines (Stage A closeout — re-check at the
gate: decorated keystroke p95 ≈0.79 ms, overlay reposition 0.02 ms,
read-tier 0.44 ms median); **R57** (sitting 8): non-daily journal-like
books are NORMAL notebooks — entries are `.generic`+`entry_date`+
one-block segmentation, never container `profile='journal'`; R55's
PROVISIONAL-and-continue discipline (QUESTIONS #23–#26 hold the open
walks); environment traps (piped xcodebuild masks exit codes; a live
Variorum.app blocks the test runner — NEVER kill hers; wrong
`-only-testing:` names report VACUOUS success — verify "Test run with N
tests", N > 0; SwiftUI `.task` doesn't fire under the test host — models
expose `adopt()` for tests; the app target's default actor isolation is
MainActor — mark cross-actor snapshot types `nonisolated`).

**Gate counts a fresh session starts from (do NOT re-run at session
start):** core 720/87 · Mac 400/73 · mobile 11/4. Stage-end protocol:
full suites at these counts+, A0 numbers re-checked, TEXTKIT2 §5 posture,
canary silent, closeout + dispositions HERE, commit per convention,
`/Applications` refresh, then the stage report — round 3 reviews Stage C
PLUS the round-2 fixes (dispositions above are its anchor).

# STAGE C CONTINUATION (2026-07-18 — the C1 session stopped at the author's ~500k context line; this section is the FRESH continuation session's self-contained anchor)

**State: C1 is COMPLETE and committed (the chosen seam — C2 had not
meaningfully started; a 12-line fragment was deliberately reverted so the
tree sits exactly at the C1 commits). C2 and C3 REMAIN, plus the stage
gate.** Commits this stage: `bd0b866` (C1: typography/margins/decoration
layer/comments UI/callouts/export mapping) · `5cfbfbe` (C1 part 2: word
counts R11, caret-precise landings, chapter drag bar R19) · this docs
commit. **Counts at the seam (full suites, green, re-verified): core 728
in 88 suites (was 720/87) · Mac 411 in 76 suites (was 400/73) · mobile
11/4 (untouched).** The continuation reads: everything the STAGE C
HANDOFF above lists, PLUS this section.

## C1 — DONE (where everything lives)

- **`Theme/EditorTypography.swift`** — `EditorTypography` (the ONE global
  voice typography every TK2 surface write reads through
  `EditorDocument.baseAttributes`: terminal = SF Mono 14, study = Iowan
  Old Style 16; `inlineCommentSpacing` = 22 widens the uniform paragraph
  gap when inline comments are ON; `gutterInset` = the R9 margin math,
  maxColumn 680 / floor 28) + `EditorSurfaceChrome` (voice+dark+inline →
  tokens/typography/NSColors) + `NSTextView.applyVoiceChrome` (colors,
  caret, font, full-range base-attribute refresh PRESERVING blockID —
  an ordinary storage write on voice switch, never §3 rendering
  attributes). `RootView.onChange(of: theme.settings)` keeps the global
  current; each surface coordinator also applies idempotently
  (`appliedChrome` guard) in makeNSView/updateNSView.
- **`Features/Editor/BlockDecor.swift`** — `EditorAppearance` (voice,
  dark, seamsVisible, indicator, inlineComments — pushed by Views via
  `model.appearance`, models never read environments); `BlockDecor` pure
  geometry (Frame/State, `seamYs` mid-gap between CONSECUTIVE visible
  frames, `verticalPad`+`calloutRect` = the R17 white-gap cap (ideal 5,
  minWhiteGap 6), `indicatorRect` (+8/-3 outline offset), `dropBoundary`
  (visible frames → before-entry index, `entryCount` = end),
  `gutterFitsCards` ≥150); `CalloutPalette` (names
  blue/green/sand/violet/rose — token NAMES stored, colors resolved per
  scheme, unknown → blue fail-open); `BlockDecorOverlayController` —
  REUSABLE (editor: comment doors + drag handles wired via convenience
  init; read tier: `init(textView:onOpenComments:nil, onMoveBlock:nil)` =
  quiet cards, no handles). Handles render only when seamsVisible AND a
  drop door exists; drop = ONE `reorder` op. View classes: DecorRectView
  / SeamLineView (dotted 1.5 on [1.5,4] dash) / CommentCardView
  (marginCard-with-rule / strip / badge styles; hitTest passthrough when
  onClick nil) / DragHandleView (⠿, superview-space drag reporting).
- **`EditorViewModel`** — `appearance` (didSet → refreshDecorations);
  `decorSink`; `refreshDecorations()` (the old refreshTint walk emitting
  `BlockDecor.State`; SKIPS ENTIRELY when nothing is decorated — the calm
  default costs nothing, pinned); observations `observePresentations` /
  `observeComments` (+ `adoptPresentations`/`adoptComments` test seams);
  `commentsPanel: CommentsPanelState?` + `openComments`/
  `openCaretComments`; `setCaretCallout(color:)` / `setCaretCalloutEmoji`
  (ASYNC, through `Operations.updateBlockPresentation` — see traps);
  `moveBlock(fromEntry:toBoundary:)` (ASYNC → `.before(slots[b].blockID)`
  / `.start`/`.end`); `postWordCount` (INCREMENTAL per-variant cache in
  `adoptSurfaceTextMap` — only CHANGED texts re-enumerate; caret-block
  live adjustment in `updateCaretContext`); caret-block change refreshes
  decorations only when indicator ≠ off.
- **`ReadPostViewModel`/`ReadPostView`** — the same decoration language
  read-only: `appearance` + `decorSink` + `startDecorContext()` (its own
  observation) + `refreshDecor()` (whole-post frames; indicator forced
  .off); chrome applied via coordinator `applyChrome`; badges anchored at
  the COLUMN edge (both tiers: `min(width - w - 8, columnRight + 6)`).
- **`CommentsPanel.swift`** — `CommentsPanelModel` (observed live+deleted
  snapshot; CRUD through the Stage A ops; refusals speak) +
  `CommentsPanel` sheet (deleted section collapsible, Restore per row) —
  presented from `EditorView.sheet(item: $model.commentsPanel)`.
- **`EditorCommands`** — Block ▸ Comments… (⌘⇧'), Block ▸ Callout (5
  colors / Emoji… NSAlert prompt / Remove), "Toggle Block Seams" ⌘⇧B (a
  BUTTON that reads the setting then flips via the runner — the 9d
  "Show Blocks" Toggle + its AppStorage are GONE; `EditorView` drives
  `model.appearance` from the ThemeStore environment instead).
- **`BlockTint.swift`** — REDUCED to `stableHash` (lineage stripes) +
  `viewRect` (the container→view mapping the decor walks use);
  indices/tintIndex/paletteCount + their pins removed with the look (R6).
  `BlockTintOverlayController`/`PassthroughTintView` deleted from
  EditorView.swift.
- **Core** — `Queries.containerComments` + `Queries.blockPresentations`
  (per-container feeds, cost ∝ post); `Operations.updateBlockPresentation`
  (read-modify-write in ONE transaction; `setBlockPresentation` routes
  through it); the callout→blockquote EXPORT mapping
  (`Queries.exportMapped`) in exportPost/exportBlock/exportReading/bulk —
  bodies now route through `exportPost` — with THE LOAD-BEARING NEGATIVE
  PIN `renderedTextNeverMapsCallouts` (the bridge's join brain never
  maps) and the frame-free export==renderedText byte pin kept.
- **Landings** — `PaletteModel.execute(onOpen: (SidebarSelection,
  String?) -> Void)` (block hits carry their ID); RootView `BlockTarget`
  state → `PostDetailView.initialBlockID` / `PoolDetailView.
  initialBlockID` → existing jump/caretSeed machinery; LibraryCatalogView
  `onOpenBlock` optional door. **Chapters** — navigator rows
  `.draggable(section.id)` + `.dropDestination` with the accent insertion
  bar + end zone; `BookStructureModel.moveChapter(_:before:)` (foreign
  payloads/no-op drops touch nothing).
- **Tests added** — core `Phase13SurfaceQueryTests` (8); Mac
  `Phase13SurfaceTests` (EditorTypographyTests 4 / BlockDecorGeometryTests
  6 / CommentsAndReorderTests 3), `TintRegistrationTests` reworked to the
  decor feed (DecorRegistration…), `BlockTintAndMetricsTests` pruned to
  the survivors, `BookStructureTests` + chapter-drag pin,
  `ShelfAndPaletteTests` palette pin extended (block IDs ride).

## C2 + C3 — REMAINING (the design decisions already made; extend, don't reinvent)

**C2 — takes presentations (the v2-canon restyle + R24/R25):**
- **Restyle `TakesBoardView` + `TakePaneView` + `CollapsibleTakeCard` on
  VoiceTokens** (via `@Environment(ThemeStore.self) private var
  themeStore: ThemeStore?` + `.fallback(for:)` — the established
  pattern): take cards = tokens.card bg + takeLine border; CHOSEN = a
  3pt tokens.chosen leading bar + "✓ chosen" mark (v2's grammar); LIVE =
  tokens.ring stroke 1.5 (TakePaneView already strokes the live pane —
  swap accentColor→tokens.ring; give TakePaneView an optional tokens
  param, default nil = current look, so AlignedPostsView compiles
  unchanged); the bloomed block's in-article cell wears tokens.wash (the
  changing-block marker) behind a **"Mark changing block" toggle,
  default ON** (R13/R22 — @AppStorage("markChangingBlock"); the existing
  `seamlessReading` state is the marginGrid-specific ancestor — fold or
  keep beside it, continuation's call, record it); article column
  `.frame(maxWidth: 680)` centered + padding ≥24 (R9).
- **R24 short-block strip in `marginGridBloom`**: SHORT fanned block →
  the margin cards render as a ONE-CARD-HIGH horizontally-scrolling
  strip (single-row HStack in ScrollView(.horizontal), cards ~220w,
  ~110h; the HStack row's height = the card, so the post grows
  vertically — her letter); LONGER blocks keep the existing 3-tall
  grid. The short/long rule: a pure static (e.g.
  `TakesViewModel.usesHorizontalStrip(text:)`) on a character threshold
  (~200 chars ≈ under ~3 lines at 68ch) — a BUILD-TIME CALL, record it
  in the closeout + QUESTIONS.
- **R25 follow-the-scroll**: TakesBoardView pushes
  `theme.settings.followTheScroll` into the model (plain var, like
  `EditorView`'s appearance pattern); rows in ALL compositions get
  `.onAppear/.onDisappear` → `model.rowAppeared/rowDisappeared(blockID:)`
  maintaining `visibleFannedBlocks`; blooming reads ONE helper
  `model.isBloomed(slot)` = `expandedBlocks.contains || (followTheScroll
  && slot.hasFan && visibleFannedBlocks.contains)` — replace the direct
  `expandedBlocks.contains` reads in articleRow/lockedColumns. (The
  reverted 12-line fragment was exactly the two properties +
  doc-comment for this — re-add them.)
- **Expand-all gating**: the Expand All/Close All buttons render only
  when `columns.count == 1 && fanStyle != .slotSplit` (R25's letter:
  not offered in full-text columns or slot-split — they're already
  whole-post presentations).
- **The + new take doors**: ghost buttons ("+ new take (branch)" ·
  "+ blank take") at the end of stackBloom, pagedTakesRow, and the
  marginGrid strip/grid — v2's dashed footer. Model methods to add:
  `branchTake(blockID:from:)` = `ops.branchVariant(blockID, from:
  renderedVariantID)` and `newBlankTake(blockID:)` =
  `ops.newBlankVariant(blockID)` — both ASYNC AWAITED (the trap below),
  via the existing `run` helper.
- **Tests** (extend `TakesBoardTests`): the strip rule (pure threshold);
  follow-the-scroll effective blooming (set followTheScroll, drive
  rowAppeared, assert isBloomed without expandedBlocks); gating (style/
  column combinations); the branch/blank doors (fan grows through ops).

**C3 — canvas as a post view (R40):**
- **`PostDetailView.Mode` gains `.canvas`** ("Canvas") →
  `CanvasView(session:, containerID: postID).id("canvas-\(postID)")` —
  `canvasProjection`/`poolListing` already work over ANY container
  (renderPost-based; verified). PoolDetailView keeps its existing canvas
  face.
- **The MINIMAL takes switcher** (the mobile-inheritable pattern, R58's
  seed): `CanvasProjection` gains `fans: [String: [Variant]]` (additive
  core change — fetch live ACTIVE takes for the container's fanned
  blocks, fan order, cost ∝ container; own core test). Card face: a
  "see takes" mini button on fanned cards → a small ‹ [take k of n ·
  label] › selector; ‹›  = **`chooseVariant` to the prev/next active
  take** — the PROVISIONAL reading of R40's "switch that block to
  another one of its own takes" (it IS an explicit per-block gesture, so
  I3's deliberate-choice doctrine holds; the alternative — a view-local
  display pick — is the recorded option; QUESTIONS it). Sealed posts
  refuse through the existing message path.
- **Styling**: canvas cards move off the yellow onto tokens.card +
  takeLine border (tokens via the optional-environment pattern).
- **Tests**: core — the fans field (fan order, active-only, per
  container); Mac — the switcher calls chooseVariant (model-level:
  switch → chosen moves; CanvasAndPoolTests is the home).

**The STAGE GATE (after C3, per the boundary protocol):** full three
suites at counts ≥ the seam's; A0 re-check (`Spikes/Phase13DecorationSpike`
re-run — baselines: decorated keystroke p95 ≈0.79 ms, overlay reposition
0.02 ms, read-tier 0.44 ms median; NOTE the spike is self-contained and
does NOT read EditorTypography, so the voice change doesn't skew it —
but the REAL surfaces now default to SF Mono 14 instead of
.preferredFont 13, worth one sentence in the closeout); TEXTKIT2 §5
posture (no macOS update → unchanged); canary silent; the Stage C
closeout INTO THIS FILE (self-contained for the round-3 cold reviewer —
anchor: both prior round sections + this continuation section); commit;
`/Applications` refresh from Release; the stage report. Round 3 reviews
Stage C PLUS the Stage B round-2 fixes. **The closeout ritual (canonical
docs, master plan, THE R59 HANDOFF) is NOT the stage's — the coordinator
instructs it after round 3.**

## Traps this session hit (the continuation inherits these for free)

1. **The app target's default actor isolation is MainActor**: every
   cross-actor snapshot type (observation closure results) needs
   `nonisolated struct` (hit on CommentsPanelModel.Snapshot,
   ReadPostViewModel.DecorContext, EditorAppearance); nested test funcs
   need explicit `@MainActor`; `NSColor(Color)` needs `import SwiftUI`
   in AppKit-ish files; a nonisolated type's member calling a
   MainActor-isolated API needs `@MainActor` on that member
   (EditorAppearance.tokens).
2. **Model gestures must be ASYNC-AWAITED, never `Task { runner.run }`
   fire-and-forget** — unstructured tasks race tests AND each other
   (hit on moveBlock + the callout doors: two gestures landed out of
   order). Partial-edit doors must read stored state INSIDE the
   transaction — `Operations.updateBlockPresentation` is the RMW
   pattern (the Stage B designation-read precedent).
3. **The `withEditor` harness drives projections BY HAND**: after any
   op, `try h.reload()` — model caches (slots, presentationsByBlock)
   never self-update under the test host; `h.settle()` alone is not a
   projection delivery.
4. **`EditorTypography.current` is process-global**: any test that sets
   it must `defer { restore }` (the Mac suite shares the process).
5. Suite-level `-only-testing:` names only (the standing vacuous-success
   trap); piped xcodebuild masks exit codes; never kill her running
   Variorum.app.

## C1 PROVISIONALs (recorded as QUESTIONS #27; the end-checkpoint walk)

See `notes/QUESTIONS.md` #27 (a)–(h) — inline-comment mechanism (the
uniformly widened gap), handles-ride-seams, the narrow-gutter badge
degradation, gutter emoji placement, the ⌘⇧B button-not-toggle face, the
spaced-callout export byte-shift, visible-frames-only drop targets, the
status line's "commits N" not built.

# STAGE C CLOSEOUT (2026-07-18 — C1 by the prior session, C2+C3 by the continuation session; THE ROUND-3 COLD REVIEWER'S ANCHOR, with the two prior round sections and the continuation section above)

**Run shape:** C1 shipped in the prior session at the author's context
seam (commits `bd0b866` + `5cfbfbe`; its complete where-everything-lives
map is the STAGE C CONTINUATION section's "C1 — DONE" — folded into this
closeout by that pointer, not duplicated); the continuation session built
C2 (`8d777ed`) and C3 (`6d993e5`) to the continuation section's recorded
design decisions, then ran the stage gate. **Gate counts (full suites,
green): core `swift test` 729 in 88 suites (seam baseline 728/88 — +1,
the C3 fans-feed pin) · Mac app 417 in 78 suites (seam 411/76 — +6: four
C2 pins, two C3 pins) · mobile 11 in 4 suites (untouched).** Round 3
reviews Stage C PLUS the Stage B round-2 fixes.

**The gate's other checks:**
- **A0 re-check (Spikes/Phase13DecorationSpike, RELEASE, macOS 26.4.1/
  25E253 — `sw_vers` confirmed, same build as Phase 6 and Stage A, so the
  TEXTKIT2 §5 matrix stands unchanged):** decorated keystroke p95 0.89 ms
  vs bare p95 0.89 ms — **decoration cost at p95 −0.00 ms** (the recorded
  baseline pair was 0.79/0.75; this run sits ~0.1 ms warmer across ALL
  conditions uniformly, the load-bearing delta is unchanged: decorations
  as overlays cost nothing); overlay reposition 0.02 ms (exact match);
  read-tier 0.51 ms median / 4.31 ms p95 at 200 views (recorded
  0.44/3.69 — within noise), memory Δ1.4 MB at a dozen / 26.2 MB at 200
  (recorded 1.4/25.8). **No decoration regression.** One recorded
  sentence per the continuation's note: the spike is self-contained and
  never reads `EditorTypography`, so these numbers measure the decoration
  MECHANISM — the real surfaces now run SF Mono 14 (terminal default)
  rather than the spike's system font; the mechanism cost, not the font,
  is what the gate re-checks.
- **Canary:** silent — the Mac suite's standing `willSwitchToNSLayout
  Manager` tests are green in the full run; the spike's TK2-opt-in
  preconditions ran without a crash.
- **`/Applications/Variorum.app` refreshed from the Release build** at
  the gate (the stage owed C1's refresh too — this covers C1+C2+C3).

## C2 — takes presentations (what shipped, where)

- **The v2-canon restyle (R12; anchors: mockups-v2 tab 1 + round-2 §3).**
  `TakesBoardView` gains the optional ThemeStore environment (terminal
  fallback — the established pattern) and renders on VoiceTokens
  throughout: the board on `tokens.surface`; take cards in the new
  **`TakeCardFrame`** (card paper + `takeLine` 1px border + the **3pt
  `tokens.chosen` leading bar** + **"✓ chosen"** mark — v2's grammar) used
  by `takeMiniPane` AND the stack's `CollapsibleTakeCard` (tokens param);
  sameness divergence tints moved off the unstyled yellow onto
  `tokens.accent.opacity(0.12)`; gap dots and secondary text on
  muted/faint tokens. **`TakePaneView` gains an optional `tokens` param
  (default nil = the pre-13 look — BlockTOC/tutorial call sites compile
  unchanged):** with tokens, the pane is TRANSPARENT (the card or article
  behind provides the paper), inked from the voice, and strokes ONLY the
  live ring (`tokens.ring`, 1.5) — R22's rule: among many editable
  surfaces the ring finds the one live editor. `updateNSView` also
  live-adopts a voice switch's `EditorDocument.baseFont` (full-range
  base-attribute refresh, the C1 applyVoiceChrome pattern — an ordinary
  storage write, never §3 rendering attributes).
- **The changing-block WASH (R13/R22):** the bloomed block's in-flow cell
  wears `tokens.wash` behind **"Mark changing block", default ON**
  (`@AppStorage("markChangingBlock")`), in every in-flow style (stack,
  carousel, margin grid; slot-split replaces the flow cell so there is
  nothing to wash). **The old marginGrid-only "Seamless" toggle is
  FOLDED into it** (build-time call, recorded at QUESTIONS #28a): v2's
  letter has the toggle remove the wash ONLY — the cards stay; the old
  Seamless hid the grid too, which would have fought follow-the-scroll.
- **R9's measure:** the single-column article caps at 680pt, centered,
  horizontal padding 24. **The margin grid reserves a FIXED 340pt rail
  on every row** (empty until the row blooms) so the article column
  stays a straight measure whether or not takes are open (v2's rail-row;
  a presentation build-time call, QUESTIONS #28f).
- **R24 — the short-block strip (her design, sitting 4):** in the margin
  grid, a SHORT fanned block's cards render as a **ONE-CARD-HIGH
  horizontally-scrolling strip** (cards 220×110, clipped; the row grows
  vertically to the card even when the block is one sentence); LONGER
  blocks keep the ~3-tall grid growing rightward. The short/long rule is
  the pure static `TakesViewModel.usesHorizontalStrip(text:)` on a
  **200-character threshold** (~under three lines at the 68ch measure —
  build-time call, QUESTIONS #28b). Recorded cost: a long take ON a short
  block clips at the card height in strip form (the one-card-high rule's
  letter); the take is whole in every other presentation and opens fully
  the moment it is edited elsewhere.
- **R25 — follow-the-scroll, generalized:** `TakesViewModel` gains
  `followTheScroll` (pushed by the View from the theme settings — models
  never read environments), **REF-COUNTED row visibility** (`rowAppeared/
  rowDisappeared` from `.onAppear/.onDisappear` in ALL compositions —
  multi-column repeats of one block's row can't blind each other), and
  the ONE bloom rule **`isBloomed(slot)`** = explicitly expanded OR
  (option on ∧ fanned ∧ near-viewport). The visibility dictionary is
  deliberately observation-tracked ONLY while the option is on (the `&&`
  short-circuit means `isBloomed` never reads it when off — the calm
  default costs nothing). Blooming applies wherever blooming exists:
  the single-column article in all four styles and the locked columns'
  in-cell blooms; **unlocked columns have no bloom surface (the pre-13
  shape, unchanged)** — recorded at QUESTIONS #28d with the
  ⑂-can't-close-a-mode-bloom consequence (#28c).
- **Expand-all gating (R25's agreed half):** the Expand All/Close All
  buttons render only when `model.offersExpandAll` — single column and
  not slot-split (columns/slot-split ARE whole-post fan presentations).
- **The fan-growth doors (v2's dashed footer):** "＋ new take (branch)"
  (= `branchVariant` from the slot's rendered take) and "＋ blank take"
  (= `newBlankVariant`) close every bloom — the stack, the paged row
  (carousel/slot-split/in-cell), and both margin-rail forms — model
  methods awaited through the runner (trap 2), refusals speaking under a
  seal (the 9d fire-and-speak posture).
- **Tests (`TakesPresentationTests`, 4):** the strip threshold's edges;
  follow-the-scroll blooming (visibility alone blooms a fanned row with
  `expandedBlocks` empty; single-take rows never; refcount across
  columns; option-off means visibility means nothing; explicit expansion
  regardless); the expand-all gate across style × column count; the
  doors growing the fan through ops with chosen UNMOVED (I3 rides).

## C3 — canvas as a post view (what shipped, where)

- **`PostDetailView.Mode` gains `.canvas`** → the existing `CanvasView`
  over the POST's container (canvasProjection works over any container —
  one traversal, never a bespoke subsystem); `PoolDetailView`'s canvas
  face stands. The sidebar door stayed gone (R40 — removed in B2).
- **Core (additive):** `Queries.CanvasProjection` gains **`fans`** —
  blockID → live ACTIVE takes in fan order, **fanned blocks only**,
  fetched through the tested `activeFans` home (cost ∝ container, P1) —
  so the switcher needs no second fetch. Default `[:]`; every existing
  init/call site compiles unchanged.
- **The MINIMAL takes switcher (R40's letter; R58's mobile-inheritable
  seed):** fanned cards show "⑂ see takes (n)" → a one-line **‹ take k
  of n · label ›** selector; ONE switcher open at a time (view state);
  **‹ › = `chooseVariant` to the prev/next active take** — the
  PROVISIONAL reading of R40's "switch that block to another one of its
  own takes" (an explicit, deliberate per-block gesture — I3's doctrine;
  the alternative, a view-local display pick that never touches chosen,
  is the recorded option — QUESTIONS #28e). Ends CLAMP; a rendered take
  that fell out of the active fan (fallback display) enters the fan at
  its front on ›; a sealed post refuses through the existing speaking
  message path. No other fan machinery reaches the canvas.
- **Styling:** cards move off the unstyled yellow onto `tokens.card` +
  `takeLine` border over the voice's `room`; ink/muted/small from tokens
  (the optional-environment pattern).
- **Tests:** core — `canvasProjectionCarriesActiveFansForFannedBlocksOnly`
  (fanned-only, fan order, active-only, no cross-container leak); Mac —
  `CanvasTakesSwitcherTests` (2): the switcher steps chosen EXACTLY one
  take with clamped ends and offers nothing on single-take blocks (run
  over a POST's canvas — the C3 door itself), and the sealed refusal
  speaks with chosen unmoved.

## Stage C PROVISIONAL dispositions (R55: noted-and-continued)

C1's bundle is QUESTIONS #27 (a)–(h) (unchanged). The continuation adds
**QUESTIONS #28 (a)–(f)**: (a) the Seamless→"Mark changing block" fold;
(b) the 200-char strip threshold + the strip's clip-at-card-height cost;
(c) the ⑂ toggle can't close a follow-the-scroll bloom (no third state
invented); (d) follow-the-scroll's reach = wherever blooming exists
(unlocked columns keep their no-bloom pre-13 shape); (e) the canvas
switcher writes CHOSEN via `chooseVariant` (the explicit-gesture reading
of R40; view-local display pick recorded as the alternative); (f) the
margin grid's fixed reserved rail. Zero stop-and-ask items arose; nothing
gated the core.

**NOT this session's:** the phase closeout ritual (canonical docs, master
plan row, the R59 handoff) — the coordinator instructs it after round 3
adjudicates.

## Stage C cold review, round 3 (2026-07-18 — the ladder's cap) — findings + dispositions

**1 MAJOR / 5 MINOR / 3 NIT, ZERO BLOCKER, plus a clean bill on both
suites and every round-2 fix. ALL NINE AGREED — zero disputes; every
mechanism traced in code by the fixer before fixing. Per the ladder's
rule these fixes land POST-CAP (the Phase 9/11a precedent): no further
review round; this record + the pins are the confirmation. Post-fix
gates: core 731 green in 88 suites · Mac 421 in 78 · mobile 11/4 (+2
core, +4 Mac — the round's pins); `/Applications` refreshed from
Release.**

1. **MAJOR — the reading flow was NOT virtualized** (ReadingFlowView:
   plain `VStack` at both levels while its own header and the B3 closeout
   claimed "`.task` per row inside the LazyVStack — viewport-shaped, P3");
   opening Read mode fired one `renderPost` per member entry and laid out
   the whole book up front — cost ∝ book size, P3's banned shape, hit by
   Journal 2026 (~96 entries) on one click and by every finished book's
   auto-open. AGREED — traced exactly as found (the closeout claim was
   false in code; this section is the correction of record). FIXED: the
   page column is a `LazyVStack` (the paper/shadow wrap the column, so
   the styling is untouched) + a DEBUG `ReadingFlowMaterialization`
   counter in `FlowPostView.init`. Pin:
   `theReadingFlowVirtualizesItsRows` (150 fabricated entries in a
   700×500 hosted window → materializations < 75). **RED VERIFIED BY
   BEHAVIORAL REVERT at suite level** (VStack restored → **300**
   materializations, the whole extent twice — the exact pre-fix shape).
2. **MINOR — the book navigator's "+ new entry" door on a LOCKED journal
   book kept the pre-fix wedge shape round 2's MAJOR 2 fixed at ⌘J**
   (only `alreadyInReading` caught; per-op transactions mean the mints
   COMMIT before the add throws): a locked daily book's entry existed but
   never opened (raw `String(describing:)` error); a locked non-daily
   book minted a stray `.generic` dated post into the Pool per click.
   AGREED. FIXED per the coordinator's instruction — the Outcome doctrine
   applied consistently: the DAILY branch catches locked/at-capacity and
   returns the entry WITH a speaking note (the entry always opens); the
   NON-DAILY branch REFUSES BEFORE MINTING via the new core read
   **`Operations.assertReadingAcceptsPosts`** (the addPostToReading gate
   without a post, run INSIDE the serialized closure — the
   `dailyJournalBookID` precedent, so a concurrent lock can't strand a
   stray; own core pin `assertReadingAcceptsPostsMirrorsTheAddGateExactly`
   covering missing/wrong-kind/locked/at-capacity/willing); refusals speak
   through `ReadingsViewModel.message`; PLUS the door hides on
   `reading.locked` (additive — the gate covers the race the hidden
   button can't). Pin: `aLockedBooksEntryDoorFollowsTheOutcomeDoctrine`
   (daily: opens + "finished" note; non-daily: nil + speaking "locked" +
   container count UNCHANGED; capacity: refuses speaking "limit"). **RED
   VERIFIED BY BEHAVIORAL REVERT** (catches + gate removed → all three
   predicted failures: openedID nil, no note, after 3 ≠ before 2 — the
   stray minted).
3. **MINOR — `CommentCardView` lacked the hit-test passthrough the C1
   record claimed** (`mouseDown` overridden, `hitTest` not — the read
   tier's quiet cards, built with `onOpenComments: nil`, were dead click
   zones over the text). AGREED. FIXED: `hitTest` returns nil when
   `onClick == nil` (the DecorRectView/SeamLineView rule, conditional).
   Pin: `aQuietCommentCardIsClickThrough` (nil door → hitTest nil; door →
   non-nil). **RED VERIFIED BY BEHAVIORAL REVERT** (override removed →
   the card returned itself).
4. **MINOR — the closeout ritual's canonical-doc batch omitted AppSpec §7
   DDL, §9 operations, and the SmartQuerySpec `tagsAll` vocabulary** —
   the shipped schema/ops would have survived the ritual undocumented
   (permanent drift; CLAUDE.md's align rule). AGREED. FIXED: the ritual
   list now names §7's five DDL additions, §9's operation set (incl.
   `restoreSection`, `updateBlockPresentation`, both extent setters, and
   this round's `assertReadingAcceptsPosts`), and the `tagsAll`
   vocabulary line. Doc-only; no pin owed.
5. **MINOR — `loadTagChips` was not generation-guarded** (round 2's
   finding-9 fix covered `hits` but not `postTags`: the chips read is a
   SECOND suspension point, so a superseded generation's chips could land
   last and describe the previous query's rows). AGREED — exactly the
   class finding 9 named. FIXED: the generation rides into `loadTagChips`
   and is re-checked after the chips read (error half too); internal for
   the pin. Pin: `staleTagChipReadsNeverLand` (a stale-generation call
   after a completed search never overwrites the current chips). **RED
   VERIFIED BY BEHAVIORAL REVERT** (guard removed → the stale read wiped
   the current chips to nil).
6. **MINOR — the typographic-PDF KnownIssues row was owned by "13 (UI
   design)" but built/scoped by no stage.** AGREED. FIXED as directed:
   the row's owner now reads "13 → disposition owed at the Phase 13 taste
   checkpoint (build in the fix round, or re-own with a named phase —
   author call; carried on the R59 handoff checklist)" with a round-3
   flag in the row body — a deliberate author call at the checkpoint,
   never a silent carry.
7. **NIT — ThemeStore's fire-and-forget setters** (the trap-2 shape:
   parallel unstructured `Task { runner.run }` can enter the runner out
   of click order and settle on the older value). AGREED — consistency
   debt, honestly non-deterministic to pin (the reviewer's own label; no
   pin per the hallucination guard's architectural-class rule — the
   mechanism is traced: unstructured task scheduling order is
   unspecified). TAKEN: setters now CHAIN (`pendingWrite` awaits its
   predecessor) — FIFO in click order by construction.
8. **NIT — `EditorTypography.current` is a global mutable singleton.**
   AGREED — recorded as DELIBERATE, unchanged: main-thread-confined by
   convention (the file's concurrency note + trap 4's defer-restore rule),
   accepted against `EditorDocument.baseAttributes`' pre-existing static
   shape; the deviation stays a choice on this record, not drift.
9. **NIT — smart-book word counts ignored `max_posts`.** AGREED — and the
   trace widened it honestly: a CURATED book whose cap was LOWERED below
   its membership (#25(d) legal) had the same skew. TAKEN (the
   LIMIT-alignment shape): `bookWordCounts` now counts a capped book
   (either kind) over `assembleReading`'s OWN capped, ordered set — one
   brain, no duplicated ordering; capped books are rare and the load
   stays one-shot (#26(g)). Pin:
   `cappedBooksCountExactlyTheAssemblysCappedSet` (smart capped at 2 of 3
   matches → 5 words not 9; curated lowered to 1 of 2 → 3 not 5). **RED
   VERIFIED BY BEHAVIORAL REVERT** (capped pass removed → 9 and 5, the
   exact pre-fix sums).

# STAGE B CLOSEOUT (2026-07-18, same Fable implementer session — the review ladder's anchor)

**Run shape:** B1 → B2 → B3, one commit per step (`3b4ef50` · `300aac0` ·
`4099ae6`), Mac build green per step, the FULL three suites at the gate.
**Gate counts: core 717 green in 87 suites · Mac app 396 green in 73
suites · mobile 11 green in 4 suites.** A0 baseline re-check: the hardened
spike re-ran during the review round and matched the recorded numbers
within noise (decorated keystroke p95 0.76 vs the recorded 0.79 ms); no
macOS update landed — the TEXTKIT2 §5 posture is unchanged; canary silent
(Mac suite's standing tests green). **`/Applications/Variorum.app`
REFRESHED from the Release build — the R53 lockstep is COMPLETE end to
end: mirror at marker 3 + the updated Mac client installed; her real-store
app syncs again on next launch.**

## B1 — the token/voice layer (its own module)

`App/Variorum/Variorum/Theme/`: **VoiceTokens** — four resolved sets
(terminal light/dark, study light/dark) carrying tokens AND IDIOM SLOTS
(`› ` selection marker, `~/` path grammar with slashes, `# ` comment
prefix, the blinking block cursor, lowercased chrome — R1's "special
little ways" as first-class slots; the Study voice's sepia/paper/serif
from the mockups' canon); **dark = FULLY BLACK room in BOTH voices**
(R51, pinned); every font macOS-shipped (R49 — SF Mono, Iowan Old Style,
New York; zero dependencies); **ReadingPageTokens** = direction C's
paper/serif page (a VIEW MODE's identity, voice-independent — R2).
**ThemeStore** (@Observable, bounded observation over the tiny setting
table; setters through the runner) is environment-fed; the new views take
it OPTIONALLY with a terminal-light fallback (test hosts lack the
environment — BookViewTests hosts BookView). Core: `ThemeVoice` +
`EditingIndicatorStyle` enums; `Operations+Appearance` (voice, seams R42,
editing indicator R14/R22, inline comments R7, follow-the-scroll R25,
shelf pins R38, daily-book designation) through ONE upsert shape;
`Queries.themeSettings`/`shelfPins`/`dailyJournalBookID` with
sitting-letter defaults (pinned). Voices apply to the B-stage CHROME;
the editor surfaces get theirs in Stage C.

## B2 — the IA (sidebar final · Shelf · Library · Pool · ⌘N/⌘J/⌘K · Settings)

- **Sidebar FINAL (R44): Shelf · Library · Pool · Blocks.** Journal folded
  INTO the shelf (R38); Tags tab dropped (R39/R45 — hierarchy surfaced in
  context + Settings); Canvas off the sidebar (R40); Timeline a Library
  view mode. The Blocks scrap rows stay in the sidebar (QUESTIONS #26(c)).
- **THE SHELF** (`Features/Shelf/`): terminal list style + TAGS column
  (R4), the `~/shelf · N books · M finished` ls-line, pinning (R38;
  ordering pinned: pins → journal books → rest by name), finish +
  Length&Extent faces (`locked`/`max_posts`/`word_target` — visible at
  last; refusals surface), drag-a-post-onto-a-book (idempotent, pinned),
  the **bottom quick-entry bar** (R3: pinned at bottom, list scrolls
  above, blinking-cursor idiom, Enter → a whole SEGMENTED post through
  the import pipeline — pinned), the ⌘K/⌘J/⌘N hint bar. Cost tiers:
  books+pins observed; word counts + tags one-shot (P1; #26(g)).
- **LIBRARY** (`LibraryCatalogView`): R32's everything — catalog search
  (books/posts/blocks), scope picker, TIMELINE as a view mode, the R46
  addable tags column (per-row +tag; multi-select batch tagging), the
  post context menu relocated here; Recovery/Tutorial in the toolbar
  menu + ⌘K (#26(d)).
- **POOL** (`PoolPostsView`): the bookless-posts surface (R29/R44), a
  QUERY over membership (pinned: removing a membership returns the post);
  every row offers Add-to-Book + tags — the drainage purpose built in.
- **⌘K** (R15): `CommandPalette` — commands + catalog hits, Enter
  executes; vocabulary lives in RootView composition. **⌘N = New Post**
  (R41), **⌘J = Today's Entry**; `ShellRouter` carries menu commands.
- **SETTINGS** (R52): Appearance pane (all six B1 settings) + the TAG
  MANAGER's real home (create/child/rename/delete-with-subtree,
  hierarchy indented) + **Promote to Book…** (R30/R37: one or several
  tags, AND/OR → a smart book; the tags stay; spec construction pinned
  as exactly the A2 vocabulary).

## B3 — books (chapters · navigator · membership · journal books · reading flow)

- **Real chapters** in the book view for curated books: grouped by
  `(position, id)` with entries in reading order, unfiled trailing
  (#26(b)); chapter CRUD + Move Up/Down (movable chapters — the polished
  R19 drag bar is Stage C's); **Restore Last Deleted Chapter** faces the
  round-1 `restoreSection`; posts file via Chapter ▸.
- **The navigator** (R43's letter): chapters · top-level outline ·
  settings in a leading rail; **post-click opens in the CURRENT editor**
  (inline focus — no context jump); NO chapter view; the settings leg =
  BookSettingsSheet (rename/finish/extents).
- **The reading flow** (R2/R56 — direction C as a VIEW MODE): continuous
  page column on the C page tokens, typographic chapter breaks, posts
  flowing, lazy per-post text (P3); **a finished book OPENS into it**
  (pinned); click wakes the post in the book view (in-place waking =
  Stage C's v2-canon surface).
- **The membership indicator** (R35's requirement): the PostDetailView
  chip — "in N books" → the book list + THE DIVERGENCE DOOR
  (duplicate-as-version with the R31 explainer).
- **Journal books** (R50, resolved INSIDE the untouchable constraint):
  `JournalBooks.openToday` = create-or-open + ensure the designated daily
  book (created/pinned/designated on first use — #26(a)), shared by the
  shelf button, ⌘J, and the palette; other journal books' "+ new entry"
  mints freely into THAT book (both halves pinned).

**PROVISIONALs:** QUESTIONS #26 (a)–(g). **Retired surfaces:** the old
sidebar post pile/Journal/Readings/Tags/Views sections (ReadingViews'
sheets live on under the shelf); `SidebarSelection.timeline` (Library
absorbs it). Nothing requiring the author arose; the deferred pieces are
Stage C's by plan (v2-canon takes surfaces, seams/ring/wash, comments UI,
callout rendering, canvas-as-view).

## Stage B cold review, round 2 (2026-07-18) — findings + dispositions

**1 BLOCKER / 4 MAJOR / 6 MINOR / 2 NIT — ALL AGREED, ALL FIXED (no
disputes). Under the ladder these were NEW HIGH findings; their fixes get
the round-3 pass at the Stage C boundary. Post-fix gates: core 720 green
in 87 suites · Mac 400/73 · mobile 11/4; `/Applications` refreshed; the
dev-store design corpus RESEEDED on the fixed shape.**

1. **BLOCKER — non-daily journal-book entries minted as
   `profile='journal'` + `entry_date`, the exact shape the daily system
   keys on.** Mechanism verified against the named code: `canonical
   JournalEntry` (Timeline.swift) selects the day's entry by
   profile+date — a dream entry created first WAS ⌘J's answer (and
   `openToday` then added it to the daily book); the bridge sweep
   (BridgeEngine) enumerates `profile='journal'` posts — a lone dream
   entry pushed to Fragments as the day's journal, a shared day tripped
   the duplicate-day pause. FIXED per the arbitration read (and RATIFIED
   mid-fix by sitting 8/R57): non-daily entries mint **`.generic` +
   `entry_date` + explicit one-block segmentation** (journal-BOOK identity
   lives on `reading.profile`); the design-corpus seeder's dream entries
   corrected and THE DEV STORE RESEEDED. Pins:
   `aDreamEntryNeverCollidesWithTheDailyJournal` (dream on day D → the
   daily door mints its OWN entry; exactly ONE journal-shaped row on D —
   the bridge-sweep shape can't pause) + the scoped test now asserts the
   `.generic`+one-block shape. **RED VERIFIED BY BEHAVIORAL REVERT**
   (flipping back to `.journal`: the daily door returned the dream
   entry's ID — the exact predicted collision). QUESTIONS #26(a)
   corrected (the "scope stays exactly the daily door" claim was false as
   first shipped; the scope is the SHAPE). Note for the record: the first
   red-run attempt used a per-test `-only-testing:` name and reported
   VACUOUS success ("0 tests") — the kickoff's environment trap, caught;
   the real red ran at suite granularity.
2. **MAJOR — finishing/filling the daily book permanently wedged ⌘J**
   (openToday caught only `alreadyInReading`; `lockedReading`/
   `readingAtCapacity` threw; the ⌘J error surfaced via the active-editor
   status line, nil on the shelf = silent). FIXED: `JournalBooks.openToday`
   returns an `Outcome(postID, note)` — the entry ALWAYS opens; locked/
   capacity produce a speaking note naming the book and the recovery
   path; `EditorCommands` speaks via the editor status line OR an NSAlert
   (the importFiles precedent — never silent without an editor);
   LibraryViewModel surfaces the note in the sidebar overlay. The
   RE-DESIGNATION DOOR shipped: "Use as Daily Journal" on journal-profile
   books' shelf menu (+ "Create Journal Book" in the new-book alert — §14
   item 10's start-a-new-journal face). Pin:
   `aFinishedDailyBookNeverWedgesTodaysEntry` (lock the daily book →
   entry opens + note speaks + membership skipped; re-designation heals).
   **RED VERIFIED BY BEHAVIORAL REVERT** (stripping the catches: the pin
   caught the exact pre-fix `lockedReading` throw).
3. **MAJOR — smart-book (derived) membership was invisible to the Pool
   and the membership chip** (promote-tags-to-book didn't drain the Pool
   it was ruled to drain, and the reading was un-noted — the R55 contract
   missed). FIXED per the arbitration lean: `poolPosts` excludes and
   `readingsContaining` includes smart-book matches through ONE shared
   predicate builder (`smartMatchSQL`, extracted from `assembleReading` —
   behavior-identical refactor, existing suites guard); bounded to live
   smart readings; malformed specs fail closed; the empty spec matches
   everything (the ratified NULL-spec rule — such a book empties the
   Pool). Pin: `promotedSmartBooksDrainThePoolAndFeedTheChip` (drain +
   chip + the FLAP + fail-closed). The reading + flap consequence
   recorded as QUESTIONS #26(h).
4. **MAJOR — the shelf word count was wrong by construction** (SQL space
   arithmetic: newlines not separators, consecutive spaces multiplied —
   against I4's multi-paragraph blocks and the 2026-07-12 stored-newlines
   ruling; disagreed with the editor's own counts). FIXED:
   `bookWordCounts` now counts app-side in the same one-shot read with
   Unicode `.byWords` — the editor's `TextMetrics` rule; two surfaces,
   one answer (`Queries.wordCount` is the one implementation). The two
   MINOR skews fixed with it: ARCHIVED member posts excluded (the Phase 4
   ambient ratification) and SMART books counted (a word target on a
   smart book shows real progress). Pins:
   `wordCountsUseTheEditorsRuleNotSpaceArithmetic` ("one\ntwo" → 2 — the
   old SQL counted 1; "a  b" → 2 — old counted 3) +
   `wordCountsExcludeArchivedMembersAndCountSmartBooks` (both red on the
   old query by construction — the assertions name values the old code
   could not produce).
5. **MAJOR — two ratified capabilities dropped in the sidebar→Library
   move** (the per-post EXPORT doors and version_of DOOR 1). FIXED:
   both menu groups restored verbatim in `LibraryCatalogView`'s post
   context menu (Export Markdown/with-Takes/PDF through the same
   ExportModel doors; "Mark as Versions with" over the observed library
   posts — `LibraryViewModel.markAsVersions` is live again); filenames
   derive title-else-date like the retired implementation.
6. **MINOR — palette block hits were dead rows.** FIXED: `CatalogHit`
   carries `homeContainerID` + `homeIsPool`; palette Enter/click opens
   the home post or Blocks pool (caret-precise landing recorded as Stage
   C work); Library block rows navigate the same way. Pin:
   `paletteBlockHitsNavigateToTheirHome` (both kinds route; no dead rows).
7. **MINOR — unparseable extent input silently CLEARED a stored extent.**
   FIXED: `ExtentInput.parse` (ONE implementation, both sheets) — empty =
   clear, digits = value, garbage = REFUSE-and-keep with a spoken line.
   Pin: `extentInputDistinguishesClearFromTypo` ("10k"/"12,000" refuse).
8. **MINOR — the chapter recovery door vanished with the last chapter.**
   FIXED: `deletedSections` joined the observed snapshot; "restore
   deleted chapter" renders beside "+ new chapter" whenever non-empty —
   no section row needed.
9. **MINOR — query-driven refreshes raced.** FIXED with the standing
   Phase 8 pattern: generation-stamped adoption in `LibraryCatalogModel.
   search` and `PaletteModel.refresh`; the `didSet`-spawned task removed
   (view bindings spawn explicitly), so tests drive deterministically.
10. **MINOR — check-then-act on the daily designation outside the
    runner.** FIXED: `Operations.dailyJournalBookID()` (a core read
    helper) lets both doors read INSIDE the serialized runner closure —
    two rapid ⌘J invocations can no longer double-mint.
11. **MINOR — word-count skews (archived/smart).** Fixed inside finding 4.
12. **NIT — LIKE sanitization.** FIXED: `\`, `%`, `_` escaped + `ESCAPE`
    clauses on every catalog LIKE; block search excludes archived homes
    (the ambient-view rule).
13. **NIT — cleanliness batch.** FIXED: the stale RootView comment;
    `VoiceTokens.fallback(for:)` consolidates the per-view fallback;
    `TagChips.load` (one grouped `json_each` query) replaces both N+1
    tag-chip loops; the no-op `scrollTo("nav-noop")` removed.

**Session note (honesty for round 3):** during the BLOCKER's red-proof a
`git checkout` mistakenly restored `BookStructureModel.swift` to its
committed B3 state, clobbering the uncommitted round-2 edits; the file
was reconstructed in full from the session record and re-verified (the
16-test fix sweep + the full Mac suite re-ran green). The reconstructed
file is what this round's commit contains.

## Stage A cold review, round 1 (2026-07-18) — findings + dispositions

**0 BLOCKER / 0 MAJOR / 3 MINOR / 2 NIT; all five AGREED, all five fixed
in this round (no disputes). Post-fix counts: core 706 green in 85 suites
(was 703) · Mac 380/68 · mobile 11/4.**

1. **MINOR — the two new orphan-repair extensions had no race tests
   entering them** (the convergence test reached the dead state via the
   batch's own tombstones; a typo'd string would no-op silently with every
   suite green; SyncSpec §7's outbox-row assertion had no Phase 13
   instantiation). AGREED — mechanism traced exactly as found. Fixed: two
   new convergence tests
   (`aCommentRacingItsBlocksDeletionJoinsTheCascadeOnBothSides`,
   `aSectionRacingItsReadingsDeletionJoinsTheCascadeOnBothSides`) —
   device A pushes the child, device B deletes the parent WITHOUT pulling
   it; direction 1 asserted on A (suppressed-cascade victim stamped +
   EXPLICITLY enqueued) and direction 2 on B (arriving orphan joins the
   cascade with the parent's exact stamp + enqueued), then full settle to
   byte-identical dumps. **Red-on-old verified by BEHAVIORAL REVERT,
   both directions:** removing the two `deadParentStamp` cases fails both
   tests' B-side assertions; removing the two `enqueueMatching` lines
   fails both A-side outbox assertions; restored, green.
2. **MINOR — `deleteSection` was unrecoverable through any offered path
   and the disposition was missing from the PROVISIONAL record** (fresh
   UUIDs can never reattach the surviving pointers; the never-skimpy /
   `restoreContainer` doctrine points at a restore door). AGREED — the
   in-code justification did miss the assignment half. Fixed with the
   coordinator's arbitration lean: **`restoreSection`** (one tombstone
   flip; assignments reattach for FREE because the dangle rule never
   rewrote pointers — pinned by
   `restoreSectionReattachesTheSurvivingAssignmentsForFree`), plus
   `Queries.deletedReadingSections` (the recovery surface), the
   `sectionNotDeleted` refusal, locked-reading refusal, and the
   cascade-victim boundary (a section that died WITH its reading refuses —
   readings have no restore door, a standing pre-13 boundary). No undo
   entry (the tags/locks class — the door IS the recovery, the comments
   parallel). Recorded as QUESTIONS #25(e).
3. **MINOR — the recorded presentation-travel rule was false for
   `poolDragCopy`** ("copies it like block.name" — poolDragCopy has never
   copied `name`, so a named+framed+commented scrap dragged to a draft
   keeps frame and notes but silently loses its name; nobody ever decided
   that). AGREED. Fixed: the closeout wording corrected above (behavior
   deliberately UNCHANGED — aligning it is the author's call); the
   asymmetry recorded as QUESTIONS #24(e). (Commit `498eab5`'s message
   carries the wrong wording as immutable history; this section is the
   correction of record.)
4. **NIT — the spike's overlay-reposition guard-return could silently
   degrade the "+OVERLAYS" condition on a mid-run TK1 fallback.** AGREED;
   taken now per the coordinator (the spike is the re-run gate artifact):
   `reposition()` now PRECONDITION-crashes on a fallback. The hardened
   spike re-ran: numbers match the recorded baseline within noise
   (decorated p95 0.76 ms vs the recorded 0.79; the recorded table stands
   as the baseline).
5. **NIT — the closeout's "canary silent everywhere" over-implied an
   in-run observer in the spike.** AGREED; the canary-status paragraph
   above now states the guard surface precisely.

---

## Sitting 9, batch 15 (2026-07-20, post-reset) — THE STABILIZATION RESHAPING (R111–R114)

Context: the chat reset (brief Fable outage). An Opus interim reply ran a
coverage audit of the sitting — its one confirmed dropped item was her
FIRST message's gap-analysis ask. Fable then re-verified the architecture
evidence directly before this batch: THREE TK2 text surfaces
(`EditorTextView` / `TakePaneView` / `ReadPostView`; the fallback canary
is SHARED, not triplicated), the pane-text/liveness decision spread ~30
refs across 4 files (`liveBuffers`/`resolvedTake`/`deferredProjection`/
`projectionCaughtUp`) with no single tested authority, and
`TakesViewModel` at 890 lines / 180 comment lines of ruling-tagged
sediment. (Opus's figures — 54 sites, per-wrapper canaries — were
inflated; the structural diagnosis survives verification.)

- **R111 — mockups are REFERENCES, not spec.** "the mockups were more
  mockups… they look better designed than the app does — their spacing,
  fonts, colors, etc. are better thought out." She mostly LIKES the
  app's looks now; judge the app against screenshots of ITSELF; the
  mockup gap-list demoted to a cheap later deliverable ("arguably not
  that important right now"); looks-polish resumes after functionality
  ("the editor's looks can be worked on once the functionality is there,
  bug free, seamless").
- **R112 — USABILITY IS THE FIRST-CLASS PROBLEM.** "i can't even click
  around the app without finding a million first class obvious bugs…
  the app isn't very usable atm." The named class: buttons, overall
  slight crowdedness, and CONFUSION OF WHAT IS POSSIBLE AND WHAT IS
  BROKEN. Her ruling example: at the bottom block of a post in Takes
  there is no way to make a new block — Make Block silently does
  nothing, Divide speaks but redirects to Write — "the most basic thing
  (separate this part into a block so i can start making takes) doesn't
  work smoothly."
- **R113 — THE TUTORIAL IS THE AUDIT.** A tutorial flow "that could walk
  you through all the functionality, and has been walked through all the
  functionality… if it touched every functionality and actually worked
  perfectly, would be the thorough UI edit and pass needed." Adopted as
  the spine: build it, fix everything it touches, keep it green as the
  permanent acceptance script.
- **R114 — process + staffing.** Themed fix batches through the real
  loop RATIFIED; best note/hygiene practices mandatory — "you shouldn't
  be a god terminal session"; all context saved to repo docs; several
  phases expected, Fable orchestrating with fresh sessions per stage;
  **Fable implements AND reviews all of this** (her call — "the really
  crucial work of making the app actually WORK in practice"); the LIVE
  EDITOR CORE IS IN SCOPE ("i do think the live editor core needs some
  work done tbh"); selective fresh starts allowed where evidence
  supports ("if we have to start some things fresh even i'm open to
  that").

**Defects logged this batch:**

- **D1 — book card collapse no-ops on the focused post (TRACED).**
  `BookView.swift:545` — `expanded = expandedPosts.contains(…) ||
  focus.focusedPostID == entry.postID`: clicking into an expanded body
  focuses the post, and the force-expand disjunct makes the ▾ button
  (line 603) silently do nothing thereafter. Fix shape: collapsing the
  focused post must also release/move focus. Red-on-old pin owed.
- **D2 — margin grid shifts the whole post left; spacing needs work.**
  Her screenshot also shows suspiciously large vertical gaps between
  blocks in the takes article. Suspect: the R74 reserved rail/room
  repositioning the article column per-style. UNTRACED — trace before
  fixing, per the hallucination guard.
- **D3 — the Takes structural-gesture gap (the R112 class).** Structural
  gestures are Write-wired by BUILD-ORDER ACCIDENT (Phase 9 wired them
  into the editor when Write was the only editing surface; Takes/Lenses
  arrived 11a/13 and inherited nothing). Make Block is SILENT in Takes
  (a fire-and-speak violation); Divide's redirect notice is
  `TakesViewModel.swift:742`; there is NO add-block-at-end door in
  Takes. Fix shape PROPOSED (product call hers at plan ratification):
  fire-and-speak evolves to FIRE-AND-DO — a door either works in-mode,
  or performs the mode-switch-and-apply itself, or isn't shown;
  lecture-and-refuse is retired for reachable acts.
- **D4 — the capability-confusion theme** → the Stage 0 capability
  matrix (every mode × every action: door exists? fires? speaks?
  works?).

**PROPOSED (awaiting her go): Phase 13b — "make it work."** Stage 0
read-only audits (frontend architecture/tech-debt survey with
per-component keep/consolidate/rebuild verdicts INCLUDING the live
editor core; the capability matrix; a self-driven bug inventory via the
visual loop — Fable walks the app, not her) → she ratifies the ranked
backlog → Stage 1 text-surface + interaction-layer consolidation (ONE
text surface component, ONE tested liveness authority, board invariant
suite + randomized board soak — the ops-soak pattern lifted to the view
layer) → Stage 2 the tutorial spine (R113) → Stage 3+ themed batches
through the loop (build → soak+pins → screenshot-verify → point-by-point
report). Fable's verdict on her "vibecoded?" question, recorded:
substrate NO; component chrome mostly fine; the INTERACTION LAYER is
genuinely under-architected and sedimented — selective rebuild of that
layer, not a fresh frontend; per-component rebuild calls deferred to
Stage 0 evidence.

## Sitting 9, batch 16 (2026-07-20) — THE GO (R115–R117); Phase 13b opens

- **R115 — FIRE-AND-DO ratified.** "I agree that it should be
  fire-and-DO." The 9d fire-and-speak posture evolves: a rendered door
  either performs the act (including any mode-switch choreography,
  visibly) or delivers the ops layer's real refusal; doors that can
  never act in their context aren't rendered; lecture-and-redirect is
  retired.
- **R116 — the FRICTION DOCTRINE (hers, verbatim-faithful).** "if you
  keep pushing up against a rule — how merge is supposed to work, the w
  ceremony (that i have yet to seen an interaction for, if it does
  exist) — it's a sign that things have been underarchitected in that
  area and that the whole feature needs to be considered thoughtfully,
  not just patched into half existence. Every feature needs its edge
  cases thought about, even though right now we also need the happy
  path working." Consequences: merge and the W ceremony each get a
  WHOLE-FEATURE design memo (behavior whole, edge cases enumerated on
  paper, her rulings on product-flavored edges) instead of further
  patches; and her parenthetical is itself a finding — the W ceremony
  EXISTS (Phase 9's one-sheet, `divideW`) but she has NEVER seen it;
  its real-workflow reachability is a Stage 0(b) question (hypothesis:
  fanning happens in Takes, divide is Write-gated, so the ceremony's
  only trigger may be unreachable on her actual path).
- **R117 — the ARCHITECT MANDATE.** Scope agreed in full; the selective
  interaction-layer rebuild on audit evidence agreed; live editor core
  in scope (re-confirmed); all-Fable (re-confirmed); "go ahead and
  start Stage 0 now"; stages must be recorded; Fable chooses the
  architectural principles — "I'm giving you power as the project's
  architect and as the entity that knows the code base and the goals
  best at the moment… this is your chance to lay the plans that the
  app relies on." CLAUDE.md updates authorized; running things by her
  optional, ownership expected.

**Executed this batch:** Phase 13b created ACTIVE — plan
`notes/plans/phase-13b-make-it-work.md` (principles + stages + Stage 0
briefs + the running ledger); the master plan gains the 13b pointer +
table row; CLAUDE.md model policy gains the 13b cast line; Stage 0
agents A (architecture survey) and B (capability matrix) launched;
Stage 0(c) — the self-driven app-walk bug inventory — queued behind the
matrix so it drives the worst cells first.

## Sitting 9, batch 17 (2026-07-20) — STAGE 0 RATIFIED; Stage 1 kicks off (R118–R119)

- **The Stage 0 gate PASSED:** "I agree with all of these… I like all of
  your plans, so keep going… I ratify all of your verdicts." Verdicts and
  backlog T1–T8 stand as synthesized.
- **R118 — TAKES PARITY (binding registry-design input for T1):** "I
  don't really want Write to have capabilities that Takes doesn't - I see
  takes as the main editing view for those using the most powerful
  feature of this app, so it shouldn't be limited." For every editing
  capability, Takes offers it natively or via fire-and-DO
  move-and-execute; Write is never the privileged surface.
- **R119 — REBUILD EMPOWERMENT + THE EN-MASSE POSTURE:** verdicts
  ratified, and beyond them — "if once the code is going there's tons of
  test churn and you're fighting technical debt, feel empowered to
  change anything." Mid-stage issues: choose the best way forward,
  record it, queue it for her en-masse walk ("just choose the best way
  forward and save it for me to go through en masse later") — the R55
  PROVISIONAL-and-continue posture carried into 13b. Also re-affirmed:
  "we do need much more testing" (the Stage 1 test obligations stand;
  zero-test views gain coverage as they're touched).
- **The REAL STORE is usable for this phase:** she has not started real
  use — "nothing real is in there right now"; writing to the real store
  is allowed (e.g. the Stage 2 tutorial living there for her to walk).
  She is SIGNED OUT on the real store (sync inactive; the Fragments
  bridge active) — explicitly NOT an issue to fix unless it comes up.
  Note for Stage 2: tutorial content must stay non-journal (R57 —
  normal-notebook shapes), so the bridge (journal days only) never
  projects tutorial text to Fragments.
- **Executed this batch:** Stage 1 subdivided into 1a/1b (fresh
  implementer session each, per the context-degradation rule) with
  self-contained execution briefs in the 13b plan; the Stage 1a
  implementer launched (T2 + its T3 slice: the pane surface +
  `PaneTextAuthority` + autosave consolidation + the board soak). The 1b
  brief finalizes at 1a's closeout (just-in-time). Stage 0(c) app-drive
  folds into T5–T7 on landing.

## Sitting 9, batch 18 (2026-07-20) — memos self-executing, ONE end checkpoint (R120–R121)

- **R120 — MEMOS ARE SELF-EXECUTING, AND PLAIN.** "honestly, plan to
  just move forward with the memos you make, and just make an effort to
  not have them be overly jargon-y." The T4 memos (W, merge — and any
  future R116 memo in this phase) no longer gate on a pre-build ruling
  from her: the architect's memo decisions — product-flavored edges
  included — are DELEGATED for 13b, recorded, and reviewed at the end
  checkpoint. Memos are written in plain language: the app's own
  vocabulary or terms defined in place, no architecture jargon. The
  standing hard stops (invariants, schema-meaning changes, new
  dependencies, credentials, deleting her content, origin pushes)
  remain untouched.
- **R121 — CONTINUOUS EXECUTION THROUGH STAGE 3; ONE CHECKPOINT AT THE
  END.** Her instinct, adopted: "it's sometimes hard for me to give an
  opinion with existing bugs still present." The en-masse judgment-call
  walk merges with everything else into ONE end-of-phase checkpoint
  after Stage 3: the accumulated PROVISIONALs/judgment calls from all
  stages, the memos, the TUTORIAL WALK (Stage 2's artifact, seeded in
  the real store for her), a fresh screenshot tour, and the standing
  asks (A1 the `//` glyph, A2 QUESTIONS #23–#28 remainder, A3 the
  typographic PDF). Stages run continuously without her gating between
  them; the cold-review ladders and the hard-stop list are UNCHANGED.
- **Operational (her screensaver/brightness questions, answered on the
  record):** 0% brightness is harmless — `screencapture` reads the
  rendered framebuffer, never the backlight. The screensaver firing
  "despite caffeinate" is the missing flag: plain `caffeinate` holds
  only SYSTEM sleep; display sleep + the screensaver need
  `caffeinate -d`. Resolution: every drive session runs its own
  `caffeinate -d` for its duration (baked into the briefs — a locked
  screen would also swallow synthetic keystrokes); she may optionally
  set Lock Screen → screensaver "Never" as belt-and-braces, but NO
  setting change is required of her.
