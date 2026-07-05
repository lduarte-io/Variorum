# Technical Decisions

The architectural commitments for the writing app — the settled *how*. These are decided (not open); the "why not" notes exist so they aren't reopened. Requirements live in `REQUIREMENTS.md`; the full build spec is `SPEC.md`.

---

## Platform & stack

- **Native Apple**, not cross-platform — the text experience and the shortcut/capability needs justify it. Primary user is the author.
- **macOS-first**, then iOS (a smaller surface over the same store), then eventually **web** (WASM SQLite, same schema/SQL).
- **SQLite is the canonical local store, rows-as-truth.** Accessed via a GRDB-style, code-first layer (transparent in diffs, clean for AI to author and the author to review). Markdown export planned so the store is never a black box.
- **SwiftUI** for chrome and non-editing surfaces; the editing core wraps a **TextKit 2 `NSTextView`** (single continuous buffer, viewport layout).
- One model layer shared to iOS/web; those surfaces deliberately do *less*.

## Core philosophy

- The atomic unit is the **block**; everything points at blocks rather than owning them — non-destructive, pointer-based composition (same religion as ClipFarm), applied even to structural operations (split/merge are reversible pointer moves).
- The whole system is a **directed graph of text blocks with typed edges**; every view is a traversal/query, not a bespoke feature.
- **Rich substrate, lean surface:** the data model is always fully capable; any UI exposes only a chosen subset.
- **Coarse, not forensic:** the system preserves choices and lineage, never a word-by-word reconstruction. Edges are `(fromBlock, toBlock, type)` — no word-level tracking anywhere.

## Storage / history model (the "rows vs op-log" decision)

- **Rows-as-truth is canonical.** Standard schema, standard migrations, row-based sync.
- **Operations-as-API:** every mutation flows through a defined, transactional operation — never ad-hoc row edits.
- **History is native to the domain:** commits, the variant fan, and lineage edges are append-only and non-destructive by design — event-sourcing's benefits without its infrastructure.
- **Optional secondary audit/operation log** may record operations for global undo/debugging, but it is a *derived artifact*, never the source of truth.
- **Why not op-log-as-source-of-truth:** it would charge the full event-sourcing tax (projection-consistency bugs, permanent event-schema-evolution discipline, history-proportional rebuilds) to buy back history the domain already owns; it also fights the performance invariant and the row-sync engines. Rejected as canonical truth; kept only as an optional derived log.

## The stored objects (as concepts)

- **Block** — permanent identity; holds identity + its variants, nothing else.
- **Variant** — one alternative text for a block's slot; the "fan" is the set of a block's variants; variants are opt-in and rare, not ambient. Has a single mutable working buffer.
- **Commit** — an append-only savepoint *inside* a single variant (variant A can have commits 1, 2, 3); the block's version history.
- **Edge** — a typed block-to-block link: `derived_from` (lineage: split/merge/extract, outline→draft) and `version_of` (compare relationships, usable between posts).
- **Post** — the entry / blog post / chapter; does **not contain** blocks — it's an *ordered list of pointers* to them; has entry date, lock, free-floating notes.
- **Pool** — an inspiration holding area; modeled as the same "container" type as a post so single ownership is enforced uniformly.
- **Reading** — a book/chapter; curated (manual ordered list) or smart (a tag/query); sections come from grouping rules, not container objects; supports extent constraints (fixed-length journals) and locking.
- **Tag** — hierarchical (path-style), applied to posts and (cheaply) to blocks.

## Key model decisions

- **The chosen variant lives on the pointer, not the block** — the same block can show version A in one reading and version B in another.
- **Variants never span blocks** — a variant is always exactly one block's text; all cross-block relationships are edges.
- **Internal newlines are content, not structure** — a newline edits a block's text; it is *not* a block split. Blocks can span multiple paragraphs; different variants can have different internal paragraph structure.
- **No nesting** — a multi-paragraph block's variants are whole-span alternatives for the entire block; no paragraph inside a block carries its own sub-fan.
- **Block size:** floor is the sentence, default is the paragraph, ceiling-less upward; boundaries snap to sentence/paragraph marks; default segmentation of fresh text is a **document setting** (decoupled from UI/mode), with journal posts defaulting to one-block-per-entry.
- **Single ownership** — a block belongs to one container (post or pool); no transclusion; dragging from the pool is **copy + an auto `derived_from` edge** (new ID, new owner, lineage preserved, no shared mutation).
- **Posts are edges-only** across versions — no post-level variant resolution; "two articles side by side" and sticky-note boards are spatial UI over read-only post renders, joined by `version_of` edges.

## Mutation, commits, locking, deletion

- **One rule underneath it all:** mutation is local and ephemeral; permanence is explicit and append-only.
- Each variant has one live **working buffer**: mutable, continuously autosaved, ordinary undo — the only mutable text in the system.
- **Commit** is a deliberate shortcut that appends an immutable savepoint; append-only, ordered by time (no global monotonic seq — it would collide across devices offline).
- **Lock is fully orthogonal to commit** — a reversible guard, not a snapshot; lock a variant (freeze its buffer) or a post (freeze pointer order + chosen variants + forbid new commits); always un-lockable; locking a post auto-commits its live buffers.
- A post can be marked **complete** (the post-level lock); journals can be fixed-length or declared done and locked.
- Rejected variants can be **hard-deleted** or **archived** into the block's history view; deleting whole blocks is cheap, with an optional per-post "deleted blocks" tray.
- Branching a new variant **inherits** the current buffer's text; wanting a blank/new block is a *different* gesture.

## Split taxonomy (the hard core)

- Two distinct operations, not one overloaded "split":
  - **EXTRACT** — source survives: a boundary-adjacent prefix/suffix leaves the active variant to become a new adjacent block (with `derived_from`); the source keeps its identity and its **entire fan** untouched; zero ceremony; also how a sub-paragraph (e.g. conclusion-sentence) fan is created.
  - **DIVIDE** — source consumed into ordered successors:
    - single-variant block → in-place: the source keeps identity as the first half, only the second half is minted (lossless; the everyday case; no ceremony).
    - multi-variant block → the **only** place per-variant marking exists: place the cut into each variant to carry; B's fan = first-halves, C's fan = second-halves (lets you pair first-half-of-1 with second-half-of-3); unmarked variants aren't cut.
- A middle span cannot Extract (it would leave the slot discontiguous) — pulling a middle piece is by nature a Divide.
- **W resolution** (identity follows the whole) applies to multi-variant Divide: original block A is preserved whole and referenceable, unmarked variants stay on A as lineage, B and C are minted fresh; the divide is reversible and nothing is destroyed.
- **MERGE** mirrors Divide-W: combining adjacent blocks mints a fresh block whose active variant is "active-of-B + active-of-C," with `derived_from` edges back to both; B and C stay intact as lineage rather than cartesian-producting their fans.

## Performance (a hard constraint)

- **The invariant:** cost is proportional to what's on screen and what's being edited — **never** to total document or corpus size. (This is the Apple Notes failure mode to avoid.)
- **Storage layer:** per-block rows → tiny fixed-cost writes; indexed reads; render pages by post, never loads the whole book; WAL mode + connection pool; all DB I/O off the main thread.
- **Editing layer:** TextKit 2 viewport layout (only the on-screen region lays out); block IDs ride block ranges as text attributes so edits stay scoped.
- **Rendering layer:** virtualize long views (render only near-viewport posts); **read cheap, edit only the focused unit** — finished blocks render as lightweight read-only text, only the focused block/post is a live editor. (This is the same principle as the "calm default, one block blooms at a time" UX — one architecture serves both speed and calm UI.)
- **Escape hatch (later, only if needed):** virtualize *within* a very large post (>100k words) by recycling block views; the block decomposition makes this possible without re-architecting.

## Sync & commercial (designed-for now, built later)

- **Row-based sync engine** (PowerSync-class) over Postgres/Supabase; not built in early phases but the schema is shaped for it.
- **Tombstones, not deletes** (`deleted_at`) so deletions propagate.
- **Convergent IDs** — UUID; deterministic UUIDv5 from natural keys where available; the scheme freezes once sync ships.
- **`owner_id` + row-level security** for future multi-tenant isolation (nullable/dormant now).
- **Conflict-as-variant** — the one mutable field (`working_text`) resolves sync conflicts by inserting a new variant, never clobbering; semantically better than CRDT character-merging for prose.
- **FK cascades expressed as triggers**, not `ON DELETE CASCADE`, because the sync layer applies records out of order.
- **Pull cursors** via `updated_at`; background-context DB shape (also required for snappiness).
- **Why not CloudKit / Core Data / SwiftData:** CloudKit is device-sync under one iCloud account (wrong for multi-tenant commercial; the tool isn't iCloud-rooted), and the Core Data/SwiftData + CloudKit integration forbids unique constraints, ordered relationships, restrict-deletes, and recursive queries — exactly what this model needs.
- **Why not Rust (backend or core):** snappiness lives on the client, locally; a server's language is off the hot path. SQLite is already optimal for this data size/shape, and SQLite-as-shared-substrate delivers cross-platform logic reuse without an FFI seam. Rust would only earn its place for real-time collaboration, which is out of scope.

## Views (v1 is deliberately multi-view; UI is deferred)

- Multiple views is the *point* — each is a different traversal that stress-tests a different edge of the schema; a view that's tortured to build reveals a weak spot before everything is built on it.
- **Calm default, depth on demand:** at rest the document is seamless prose; block boundaries are invisible until a block is focused/hovered; a small corner badge appears only on blocks that have a fan.
- Fans **stay open** once expanded (no auto-close); a **close-all-fans** button exists; an "expand all fans" view renders every fan for read-down-and-prune.
- Planned views (as capabilities the model must support): continuous book view, book-scrub (page = a post), timeline, side-by-side, swap-and-reread, outline-left/draft-right with `derived_from` mapping, diff (optional whitespace normalization), folder, sticky-note/canvas board.
- **UI is an open concept.** Get it working technically first (store, operations, traversals, performance), then do UI design, layout, and tweaks later, iteratively, with the author's engagement. In the technical phase, build the simplest functional unstyled rendering of each view; do not invest in visual polish. The read-cheap/edit-focused split is the one UI-shaped thing that is load-bearing now, because it's a performance constraint.

## Sorting

- Two timestamps per post: `last_touched_at` (any keystroke) and `last_major_revision_at` (only when cumulative change crosses a threshold, default 0.8, or a new variant is committed).
- A reading's sort spec picks which stamp to use; journals sort by entry date. Fixing a typo never reshuffles the library; a real rewrite does. Threshold is tunable.

## Mobile

- Same store and model, smaller *surface* (not a simpler model).
- Mobile creates journal entries and **edits existing blocks' active text**, but exposes **no variant/fan gestures**.
- Journal restrictions are a **UI profile**, never a separate data model — so a journal entry can later "graduate" into a full reworkable post with zero migration.
