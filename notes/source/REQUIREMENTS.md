# Requirements & Wishes

The author's requirements and desires for the writing app, in their own terms, with the examples they used. This is the authoritative *what* — the source of truth for what the tool must do. (Technical commitments live in `TECHNICAL_DECISIONS.md`; the full build spec is `SPEC.md`.)

---

## What it's for / the core feeling

- A native, Apple-audience **premium** writing tool. The user is the author (and "whoever else has a brain just like mine").
- The web version is too slow, too painful, and lacks the shortcuts and capabilities wanted.
- The real passion: figure out the **atomic unit**, then build around it — same idea as ClipFarm for video (take the underlying thing, play with it easily). It's about pointers and flexibility, not tedious apps.
- Must feel **free and dynamic** to work with — ideas aren't stifled. Not forensic reconstruction; just keeping choices open as long as wanted.
- If it's beautiful, bug-free, fast, interesting, and flexible, complexity is acceptable. **This is NOT Pages.**
- It must be **snappy**. A major complaint with Apple Notes: anything over ~10k words in a note starts to lag for several seconds. This app must not have that problem.

## Three use cases it must serve at once

- **Daily journaling** — relatively simple; one day, one block; nice to see if pieces were edited later, but the day it was written usually matters more for ordering.
- **Blog posts** — many different ideas; pull up sources and notes to the side as reference; try out different paragraphs.
- **Books** — chapter/scale ordering matters most; same paragraph/word/sentence-level editing as blog posts.

## Blocks & variants

- A block is a real stored node with its own identity and variants.
- Easy to make *many* variants of a block — 10 different versions of a paragraph if wanted.
- Focus on **fanning out parallel candidates** (held open side by side), not advancing one evolving line; for an evolving line, make separate blocks.
- Each block has a little version history.
- The floor is the block; split it as fine as a sentence when needed. Blocks can also span multiple paragraphs (bigger than a paragraph is important).
- Splitting a block with a fan: place the split into each variant you want carried through; versions with nothing redeemable can be deleted or kept as history; identity of the whole is preserved.
- Branching a candidate inherits the current text; wanting a genuinely new/blank block is a *different* gesture.
- If you're in a block and want to rework one sentence inside it, bring that sentence over; if you want a new block in the middle, let the current block split, record it, keep moving.
- Wanting a span to break off while the previous block stays the same (the parent) should be an option — painlessly chop off the last two sentences into a new block, knowing where it came from.
- Block tags cost almost nothing — worth allowing (especially for the inspiration pool). (Originally thought piece-level tags were enough.)
- **No** knowledge-base / transclusion setup — it brings annoying management problems.
- A block living in more than one post at once feels like a mess (who owns it?) — prefer copy or move.

## Commits, locking, deletion

- Always autosaving, **plus** a deliberate "save this version" shortcut (like coding: work freely, commit when you want a point you can return to — but with autosave).
- You can commit a variant several times (version A: commit 1, 2, 3; version B: commit 1, 2, 3) — that's the block's version history, *not* forced new variants.
- A **lock must be different from a commit** — commits are not the locking mechanism.
- Lock/unlock a block (or post): a locked thing can still appear in many views but can't be casually edited; to edit, you duplicate (or unlock).
- A way to mark a post as **complete** so you know it isn't drifting; locked posts can be unlocked again.
- Rejected candidates can be fully **deleted**, or **archived** into a "history" view of the block.
- Deleting whole blocks should feel relatively cheap; each post could optionally have a "deleted blocks" section.
- "What the block *is* is always changing."

## Views (any combination, together or apart — maximum flexibility)

- See notes stacked one on top of another, in book format — **not** paginated into fixed page-sized chunks.
- A book view where you scroll through different "notes," and each note you can scroll down to read in full.
- Drag the bottom scrubber to skim through a long book (ordered by time or something else), pause on any "page," read the whole thing — a page = a block or a series of blocks you've grouped. *Example: 50 journal entries = 50 pages, even if one is 10k words; you just scroll through that one.*
- Infinite-scroll through the entire "book" of journals (like Kindle/book apps).
- Flip through pages of a native book-type view for notes you add to.
- Timeline view.
- **Side-by-side:** rework one sentence and have both versions — or more than two — open at once. *Example: text | version one | version two | text.*
- See the whole piece read with one of the paragraph options swapped in; see it differently otherwise.
- A top-level view picks one option (A) when viewing the book that way, while the block-level options stay preserved once you click in.
- **Outline left, draft right:** outline tracks the draft as an *option* and not — either see the whole outline scrolling independently, or have it match the draft.
- Outline lines/blocks on the left can map to the block(s) they became on the right ("this became this, or these two") — see the spaced-out outline beside the wall of text it grew into.
- **Diff** views, with whitespace changes optional.
- See a paragraph beside the same paragraph with one word changed — to judge the impact and how it flows in the whole piece.
- Fan out variants and have them **stay open** (not auto-close) so you can read through and clear them as you go; a "close all fans" button when wanted.
- Bring posts up like sticky notes on a board, resize them, arrange freely (canvas).
- A folder view is fine too — "if people really want a folder view, who am I to stop them?"
- Easy drag-and-drop reordering.
- (Current outline is just a plain note, e.g. `hello` / `• my first point` / `• my second point` → `• sub point` / `• my third point`.)

## Structure via tags (not containment)

- Hierarchy comes from **hierarchical tags**, not headings owning child blocks.
- On-demand "books": pull together everything tagged motivation / accomplishment / goals / dreams, each in its own section.
- A "chapter" is effectively a tag section — e.g. flip through the *goals* section across time in a generic book.
- Books/chapters are "readings" — hand-curated *or* automatic.
- Pieces are tagged at the piece level; a heading need not own its children (could re-tag "part 2" and move all at once if needed).
- The chosen variant lives on the pointer, not the block.

## Posts & journals

- Each piece can have a little **free-floating notes area**, if wanted.
- Journals can be fixed length (e.g. 200 posts go into this journal) or declared "done" and locked.
- Journaling restrictions should be a *UI* constraint, not a separate data model.

## Inspiration pool

- Often scattered notes and random sentences for a post, some to throw away.
- Want a **pool of inspiration** to look through and drag pieces into a draft.
- Want the freedom of a notebook plus fast typing and version history.

## Sorting

- Sort by when **80%+** of something was edited.
- **Despise** when fixing one typo makes a file "most recently edited" and reshuffles everything — fine for some cases, dreadful for most.

## Mobile

- Add to journals from a mobile app.
- Mobile likely can't handle the full complexity — a journal-type post can be mobile-friendly.
- On mobile you can **edit existing blocks' active text** and create journal entries, but you don't need access to variants/fans.

## Commercial / future

- This will one day be a consumer / commercial app — that should be considered while building.
- No real-time collaborative editing is envisioned.
- The architecture and data setup must **stay fast** as the app scales in complexity.
