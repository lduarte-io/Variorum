# Project Handoff — Native Writing App, Schema Phase

This document hands off a writing-app project from a long design conversation into Claude Code, where the schema will live under version control. It captures the *mental model, invariants, and reasoning* behind the design. It is paired with two other documents you should treat as the authoritative requirements:

1. **Requirements & Wishes** — what the tool must do, in the author's own words, with examples.
2. **Technical Decisions** — the architectural commitments already made.

This handoff is the *why* behind those two lists. When they conflict with anything here, the lists win on *what*; this doc wins on *why*. Do not relitigate decisions already marked settled — many of them took a long time to reach and each protects a downstream invariant.

---

## 1. What this is

A native macOS writing tool (Swift, SwiftUI for chrome, TextKit 2 `NSTextView` for the editing core, GRDB/SQLite for storage). The author is the primary user. It must serve three modes over one model: **daily journaling**, **blog posts**, and **books**. It is explicitly *not* a Pages clone and *not* a knowledge base.

The thesis in one line: **the atomic unit is the block; nothing owns blocks, everything points at them; every view is a different traversal of the same graph.** This is the same non-destructive, pointer-based philosophy as the author's video tool (ClipFarm), applied to prose.

---

## 2. The mental model (internalize this before touching tables)

**It is a directed graph of text blocks with typed edges.** Not a tree, not a list of files. Blocks are nodes. Variants are alternative texts a block can show. Edges record lineage and comparison relationships between blocks. Posts and Readings are *ordered pointer collections* over blocks, not containers of them. Every feature the author wants — timeline, book view, side-by-side, outline→draft, diff, inspiration pool — is a query/traversal over this graph, not a bespoke subsystem.

**Rich substrate, lean surface.** The data model is always fully capable. Any given UI exposes only a chosen subset and lets the rest stay latent. This is the core tension-resolver for the whole project: complexity lives in the store (cheap — just rows and edges), restraint lives in the UI. Design the schema for the *full* capability even though v1's UI will only surface part of it.

**Coarse, not forensic.** The system preserves *choices and lineage*, never a word-by-word reconstruction of edits. Edges are `(fromBlock, toBlock, type)` — two IDs and a label. There is no word-level change tracking anywhere. If you ever find yourself designing something that tracks *which words moved*, stop — that's out of scope by design.

---

## 3. The immediate task

Produce the **data model** as GRDB migrations, plus a companion `SCHEMA.md` design note that explains each table and the reasoning. Validate every table against the invariants in §4. Do **not** build UI, the editor, or sync in this phase.

Recommended sequence:
1. Draft `SCHEMA.md` (tables, fields, relationships, what's mutable vs append-only, what each view needs to query).
2. Implement GRDB migrations matching it.
3. Specify the **operations** in §5 as exact state transitions (which rows each reads/writes). This is where correctness actually lives — design the tables so these operations are clean.

Keep both files under version control from the first commit; iterating on the schema with real diffs is the reason for moving to Claude Code.

---

## 4. Load-bearing invariants (these must never break)

Each of these protects something downstream. Violating one quietly corrupts a whole class of views or operations.

- **Variants never span blocks.** A variant is always exactly one block's text. This is *the* invariant the rendering model rests on: every variant of a block must be interchangeable at that block's single slot, so that rendering a reading is simply "concatenate each slot's chosen variant in order." If a variant could resolve to text that overlaps the next slot, rendering double-prints and side-by-side breaks. All cross-block relationships are **edges**, never variants.

- **The chosen variant lives on the pointer, not the block.** The `post_blocks` join (post → block, with position) carries `chosenVariantID`. This is what lets the same block show version A in one reading and version B in another. "Which version is showing" is a property of *this appearance*, not a global fact about the block.

- **Internal newlines are content, not structure.** Pressing return edits a block's text. It is *not* a block split. Blocks may span multiple paragraphs, and different variants of one block may have different internal paragraph structure. Block boundaries change *only* through the explicit operations in §5.

- **Mutation is local and ephemeral; permanence is explicit and append-only.** Each variant has exactly one mutable **working buffer** (continuously autosaved, ordinary undo). That is the only mutable text in the system. A **commit** appends an immutable savepoint inside a variant. Autosave never creates committed history.

- **Lock is orthogonal to commit.** A lock is a reversible guard against casual edits (on a variant or a whole post); it takes zero commits and is always reversible. A commit is an append-only savepoint. They are different concepts at different layers — do not let one imply the other. (Locking a post does auto-commit its live buffers, because you can't seal something still pointing at mutable text — but that's a consequence, not an equivalence.)

- **Single ownership.** A block belongs to exactly one post. No transclusion / shared blocks. Dragging from the inspiration pool is **copy + an auto `derived-from` edge**: new block, new ID, new owner, lineage preserved, no shared-mutation.

- **No nesting.** A multi-paragraph block's variants are whole-span alternatives for the entire block. No paragraph inside a block carries its own sub-fan. This keeps the "one block blooms at a time" UI coherent.

- **Posts are edges-only.** No post-level variant *resolution*. Two versions of an article are two posts joined by a `version-of` edge; comparing them is a *view*, not a model feature. Do not add chosen-post-variant resolution to any pointer.

---

## 5. The operations the schema must support

These are the hard core of the project — the author identified split/merge/extract behavior as the single hardest part. The schema must make each of these a clean state transition. Specify each as exact rows read/written after the tables exist.

- **Branch a variant** — create a new variant on a block; default text is *inherited* from the current working buffer. (A blank/new block is a *different* gesture, not a branch.)

- **Commit** — append an immutable savepoint to the active variant. Append-only, linear per variant. Restoring a commit loads its text back into the buffer; committing again appends a new one (never truncates).

- **EXTRACT** (source survives) — a boundary-adjacent prefix/suffix leaves the *active variant* and becomes a new adjacent block, with a `derived-from` edge back to the source. The source keeps its identity and its **entire fan** untouched — zero ceremony, because the other variants never contained that span. This is also how a sub-paragraph fan is created (e.g. extract a conclusion sentence into its own block, fan *that*). A *middle* span cannot Extract (it would leave the slot discontiguous) — that's a Divide.

- **DIVIDE** (source consumed into ordered successors):
  - *Single-variant block (~95% case):* trivial cut into B + C, `derived-from` edges to both. No ceremony.
  - *Multi-variant block (rare):* the **only** place per-variant marking exists. The cut is placed into each variant the author chooses to carry; each marked variant cleaves into a first-half (→ B's fan) and second-half (→ C's fan), enabling mix-and-match (first-half-of-attempt-1 with second-half-of-attempt-3). Unmarked variants are not cut.

- **W resolution** (the chosen rule, applies *only* to multi-variant Divide): the original block A is **preserved whole** and stays referenceable; its unmarked variants live on as A (reachable as lineage); B and C are minted fresh. The divide is reversible (point back at A) and nothing is destroyed.

- **MERGE** (inverse, mirrors Divide-W): combining adjacent blocks mints a *fresh* block whose active variant is "active-of-B + active-of-C," with `derived-from` edges back to both. B and C stay intact as lineage rather than cartesian-producting their fans.

- **Lock / unlock** — set/clear a reversible guard on a variant or post. Locking a post freezes pointer order + chosen variants + forbids new commits, and auto-commits live buffers underneath.

- **Delete / archive variant** — hard-delete (gone) or archive (drops out of the fan, stays in the block's history view). Deleting a whole block is cheap; an optional per-post "deleted blocks" tray is a soft net.

---

## 6. Stored objects (concepts — exact fields are your job to finalize)

- **Block** — permanent identity; holds identity + its variants, nothing else.
- **Variant** — one alternative text for a block's slot; has a mutable working buffer, an optional parent (history is a tree), a status (active/archived), and a lock flag.
- **Commit** — append-only savepoint inside one variant (text + timestamp + kind: manual/auto).
- **Edge** — `(fromBlock, toBlock, type)`; `derived-from` for split/merge/extract lineage and outline→draft mapping; `version-of` for compare relationships (usable between posts too).
- **Post** — entry / blog post / chapter; an *ordered list of pointers* to blocks; has `entryDate`, `locked`, a free-floating notes area. Does **not** contain blocks.
- **post_blocks** join — `(postID, blockID, position, chosenVariantID)`. The `chosenVariantID` placement is load-bearing (see §4).
- **Reading** — a book/chapter; curated (manual ordered list) or smart (a tag/query); sections come from grouping rules, not container objects; supports extent constraints (e.g. fixed-length journals) and locking.
- **Tag** — hierarchical/path-style; applied to posts and (cheaply) to blocks. Block tags matter mainly for the inspiration pool; surface them sparingly in UI but support them in data.

Two sorting timestamps per post: `lastTouched` (any keystroke) and a **major-revision** stamp updated only when cumulative change crosses a threshold (or a new variant is committed). A reading's sort spec chooses which to sort by; journals sort by `entryDate`. The point is that fixing a typo must never reshuffle everything — design the post row to carry both stamps.

Default block segmentation of fresh text is a **document-level setting** (decoupled from UI/mode), with journal posts defaulting to one-block-per-entry. Do not bind granularity to a UI profile.

---

## 7. Scope boundaries for this phase

Do **not** build, yet:
- Any UI, editor surface, or `NSTextView` integration.
- Live identity-maintenance over `NSTextStorage` (that's the editor phase; the schema only needs to *support* it via stable block IDs).
- Sync (likely CloudKit given the author is on iCloud+); deferred to its own phase. Mobile leans append-only / edit-active-text-only, which keeps conflicts tractable — but not now.
- Markdown export (planned, so the store is never a black box — design with it in mind, implement later).

Mobile note for context only: same store and model, smaller *surface*; mobile creates journal entries and edits existing blocks' active text but exposes no variant/fan gestures. Journal restrictions are a UI profile, never a separate data model, so a journal entry can later "graduate" into a full post with zero migration. Keep the schema universal accordingly.

---

## 8. Known hard spots (budget for these, don't be surprised)

- **Re-bracketing across block boundaries.** Selecting a span that crosses existing block boundaries and making it a block requires splitting the touched blocks at the selection edges and reconciling pieces (each may carry a fan). Mitigation: boundaries snap to sentence/paragraph marks, so the cut points are bounded and countable, not arbitrary offsets. v1 can ship the clean-inside-one-block / whole-paragraph cases and defer messy cross-fan re-bracketing.
- **Multi-variant Divide** is the only operation with real ceremony; everything else is cheap. Get its state transition exactly right.
- **The major-revision threshold** (what counts as "80%+ edited") will need tuning; make it a parameter, not a magic constant.

---

## 9. How to work

- Treat the two companion lists as the source of truth for requirements; treat this doc as the rationale.
- Produce `SCHEMA.md` first and get it reviewed before committing to migrations — the author thinks in models and will want to read the design before the code.
- Design tables so the §5 operations are clean state transitions; if an operation feels tortured to express, the schema is wrong, not the operation.
- Each planned view is a deliberate stress test of a different edge of the schema (folder → tags/membership; book-scrub → ordering + post-as-page; timeline → commit/variant timestamps; outline → `derived-from`). A view that's painful to query reveals a weak spot — surface that early.
- Keep it honest and direct; flag tradeoffs rather than smoothing them over. The author prefers clear-eyed analysis to reassurance.
