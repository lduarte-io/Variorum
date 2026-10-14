# Variorum — Overall Model (System Mental Model)

Internalize this before touching tables or code. This is the **how it hangs together** — the conceptual objects, the invariants, and the reasoning that keeps them honest. Concrete DDL, operations, and build detail live in `AppSpec.md`.

---

## 1. The one-sentence model

**The store is a directed graph of text blocks with typed edges.** Blocks are nodes holding alternative texts (variants). Posts and pools are *ordered pointer collections* over blocks; readings are *ordered pointer collections* over posts. Every view is a traversal of this graph — never a bespoke subsystem.

Three framing principles carry the whole design:

- **Rich substrate, lean surface.** The data model is always fully capable; any UI exposes only a chosen subset and lets the rest stay latent. Complexity lives in the store (cheap — rows and edges); restraint lives in the UI. This is how "crisp and usable" and "maximally flexible" coexist without choosing.
- **Pointer religion / non-destructive.** Nothing owns blocks; everything points at them. Mutation never reaches anything the author has decided to keep — including structural operations (split/merge are reversible pointer moves, not destructive rewrites).
- **Coarse, not forensic.** The system preserves *choices and lineage*, never a word-by-word reconstruction of edits. Edges are `(fromBlock, toBlock, type)` — two IDs and a label. If a design ever needs to track *which words moved*, it is out of scope by definition.

## 2. The stored objects (concepts)

- **Block** — permanent identity; holds identity + its variants, nothing else.
- **Variant** — one alternative text for a block's slot. The "fan" is the set of a block's active variants. Variants are **opt-in and rare, not ambient** — most blocks live their whole life with exactly one. Each variant has a single mutable **working buffer** (`working_text`) — the only mutable text in the entire system.
- **Commit** — an append-only savepoint *inside* one variant (variant A can have commits 1, 2, 3). The block's version history.
- **Edge** — a typed block-to-block link: `derived_from` (lineage: divide/merge/extract/pool-copy, outline→draft mapping) and `version_of` (compare relationships, usable between posts).
- **Post** — the entry / blog post / chapter. Does **not contain** blocks — it is an *ordered list of pointers* to them; has entry date, lock, free-floating notes.
- **Pool** — the inspiration holding area; the same container type as a post, so single ownership is enforced uniformly and "scrap" and "finished prose" are one object type.
- **Reading** — a BOOK (membership rows as truth: orderable, chapterable, finishable, sealable, ownable, archivable — 13i-e: kept-but-out-of-view forever, auto-ingestion paused, explicit adds open) or a GATHERING (a saved rule — tags/stars, boolean — assembled at read, holding nothing; evicts when the tag goes, by definition). *The 13i recast (the sitting record §1, stored at 13i-a): "curated/smart" is the superseded spelling; a gathering BINDS into a book in place — same row, intake keeps running.* Intake is EVENT-DRIVEN: it fires on the applying act, never on state; tombstone-means-decided, with a fresh act re-posing a dismissed pair at the door (built 13i-b; AppSpec §9). **Chapters are first-class, reorderable `reading_section` rows within a curated reading; a membership row points at its chapter** (`reading_post.section_id`; dangling ⇒ unsectioned at read time). *Ratified supersession (Phase 13 sittings 1/4, 2026-07-17/18 — the books reversal + R28): the original "sections come from grouping rules, not container objects" line is superseded for curated books — the author wants chapters she can reorder as real things. Sections are still ordered metadata rows a pointer names, never containers of posts; smart readings keep rule-derived sectioning (`grouping_tag_id`).* Supports extent constraints (fixed-length journals — `max_posts`, joined at Phase 13 by the words-based `word_target`) and locking. A post may appear in many readings at once — this asymmetry with blocks is deliberate and is what makes on-demand books work. *(Bend ratified 2026-08-26, built at Phase 13i: an opt-in per-book **Owned** relationship — the author's call, "notes will have to lose a little ground to let books be stronger" — plus required book-level text immutability; the many-readings default is untouched. The same phase adds **wings** — in-store libraries, a level above books; default wing "Home". Design record: the 13i brief.)*
- **Tag** — hierarchical (path-style, e.g. `life/goals/2024`), applied to posts and (cheaply) to blocks. Block tags primarily serve the pool.
- **Reference** — external source material (a file or URL) attached to a post as a *viewing aid* beside the draft. Deliberately not a knowledge object: no transclusion, no annotation sync, no citations — it renders next to your writing, and selected text dragged out of it lands as an ordinary lineage copy.

## 3. The mutability rule (one rule under everything)

**Mutation is local and ephemeral; permanence is explicit and append-only.**

- Each variant's working buffer is mutable, continuously autosaved, with ordinary undo. Nothing else in the system is mutable text.
- **Commit** appends an immutable savepoint. Restoring a commit loads its text into the buffer; committing again appends — never truncates. Commits are deliberate, with six quiet automatic exceptions (kind='auto', visually muted): sealing a post, locking a variant with uncommitted changes (the guard insures what it protects — author decision 2026-07-05), a long-idle dirty buffer (`idle_commit_hours`), a structural undo about to overwrite a buffer edited since the operation (author decision 2026-07-06 — same doctrine: insure what's about to become unreachable) *(a sixth — the Fragments-bridge landing's insurance — RETIRED with the bridge, 2026-09-04)*, and **leaving a note that carries unsaved changes** (Phase 13j, the author's savepoint-cadence ruling — `closeAutoCommit`: one quiet savepoint per edited take when the note stops being shown anywhere, deduped against that take's last commit. This is the everyday cadence her J11 question asked for; the idle timer's default dropped 24 h → 2 h as its backstop, and the ONE `savepoint_cadence` setting governs these two CADENCE occasions only — the other four are insurance and stay on in every mode), **and — THE SEVENTH OCCASION, kept at its ordinal (the retired sixth still counts) — a CROSS-BLOCK EDIT about to overwrite the takes it edits** (her own insurance idea, the 13u item 5 sketch; built as `Operations.insureTakes` at 13u1). Her reason is the doctrine's own: the gesture MIXES the text-undo and structural-undo worlds, which never interleave by design — the structural rewrite that lands the compound clears the text stack, so the buffer it is about to overwrite has no ⌘Z road afterwards, and one compound entry PLUS these savepoints is what makes the mixing safe. It insures the takes the compound EDITS and deliberately not the blocks it deletes whole (`deleteBlock` preserves them and Put back is real) or releases to lineage (the standing merge preserves both sources whole).
- **Structural undo — and, since Phase 13c, structural REDO** (both session-scoped and in-memory) cover structural operations only — inverses are cheap pointer restores because nothing destroys, and each registration carries its re-apply beside its inverse, so an entry moves between the two stacks and undo↔redo round-trips to the same rows (any new structural act clears the redo future). Command-Z inside a buffer is ordinary text undo; the two stacks never interleave. Redo emits ordinary operations exactly as undo does, so sync knows about neither. (AppSpec §9.)
- **Lock is fully orthogonal to commit** — a reversible guard, not a snapshot. Lock a variant (freeze its buffer; edit by branching or unlocking) or a post (freeze pointer order + chosen variants + forbid new commits). Locking a post auto-commits its live buffers — a consequence, not an equivalence.
- Rejected variants are **hard-deleted** (tombstoned) or **archived** into the block's history view. Deleting whole blocks is cheap; a per-post "deleted blocks" tray is the soft net.
- Branching a variant **inherits** the current buffer's text; a blank/new take is a *different gesture*.

## 4. Data invariants (never break; enforce in Domain/Operations, DB-backed where possible)

- **I1 — Variants never span blocks.** A variant is exactly one block's text. This is *the* invariant rendering rests on: render = concatenate each slot's chosen variant in order. All cross-block relationships are edges, never variants.
- **I2 — Single ownership.** A block is referenced by at most one container (one post or one pool). DB-enforced (unique live `container_block.block_id`).
- **I3 — The chosen variant lives on the pointer, not the block** (`container_block.chosen_variant_id`). The same block can show version A in one reading and version B in another.
- **I4 — Internal newlines are content, not structure.** Pressing return edits a block's text; it is not a split. Block boundaries change only via the explicit structural operations. Different variants of one block may have different internal paragraph structure.
- **I5 — Commits are append-only per variant.**
- **I6 — Lock is orthogonal to commit** — a reversible guard, zero commits.
- **I7 — No nesting.** A multi-paragraph block's variants are whole-span alternatives for the entire block; no sub-fans inside a block.
- **I8 — Posts are edges-only across versions.** No post-level variant resolution, ever. Two article versions = two posts + a `version_of` edge; comparison is a view.
- **I9 — Cross-block relationships are edges, never variants.**

## 5. Performance invariants (as load-bearing as the data ones)

> **P1 — No operation's cost may scale with total document or corpus size — only with viewport + edit size.** (The Apple Notes failure mode, banned.)

- **P2** — All DB I/O is off the main thread; reads never block writes (WAL + reader pool).
- **P3** — Long views are virtualized; only on-screen units render; **only the focused unit is a live editor** (everything else is lightweight read-only text).

P3 and the UX principle "calm default, one block blooms at a time" are the *same architecture* — build "only the focused thing is heavy" once and get both snappiness and calm.

## 6. Sync invariants (architecture settled in `SyncSpec.md`; sync arrives early so mobile journaling works)

- **S1** — All mutations are tiny, append-friendly writes through the operations API — never large-blob overwrites.
- **S2** — Deletes are tombstones (`deleted_at`), not row removal. *(Bent ONLY by the Phase 13j purge design — the author's J1 ruling, the binding text `notes/plans/phase-13j-purge-memo.md` §4f: a tombstone may be physically removed only after every live device on the account has seen the deletion — the horizon — with a content-free purged-ids ledger entry standing in its place for as long as any device could still push the row. Everywhere else, tombstones remain the only delete.)*
- **S3** — IDs are stable random UUIDs; convergence is the sync protocol's job, never the ID scheme's (SyncSpec §9).
- **S4** — Top-level entities carry nullable `owner_id` for future multi-tenant RLS.
- **S5** — The one mutable field (`variant.working_text`) resolves sync conflicts as a **new variant** (conflict-as-variant), never by clobbering.

## 7. The split taxonomy (the hard core, conceptually)

Two distinct operations, not one overloaded "split" — plus the inverse:

- **EXTRACT — source survives.** A boundary-adjacent prefix/suffix leaves the *active variant* to become a new adjacent block with a `derived_from` edge. The source keeps its identity and its entire fan untouched (the other variants never contained that span — nothing to mark). Zero ceremony. This is how a sub-paragraph fan is born (extract the conclusion sentence, fan *that*). A middle span cannot Extract — that's a Divide.
- **DIVIDE — source consumed into ordered successors.**
  - *Single-variant (~95% case):* trivial in-place cut — the source keeps identity as the first half; only the second half is minted. No ceremony.
  - *Multi-variant (rare; the only ceremony in the system):* the cut is placed into each variant to carry through; B's fan = first-halves, C's fan = second-halves (enabling first-half-of-attempt-1 with second-half-of-attempt-3). Unmarked variants aren't cut. **W resolution:** the original block A is preserved whole and referenceable; unmarked variants stay on A as lineage; B and C are minted fresh. Reversible by re-pointing at A. Nobody's five editors disappear.
- **MERGE — mirrors Divide-W.** Combining adjacent blocks mints a fresh block whose active variant is "active-of-B + a newline + active-of-C" *(author ruling **R-13u4-3**, 2026-09-20 — the RENDERING join: the page reads byte-identical before and after the merge, so a merged run keeps every newline inside it; it supersedes the 2026-07-06 single-space join for every merge DOOR, while the two DELETE roads — the seam carve and the cross-block compound's edge-join — keep the shipped join. AppSpec §9's bullet carries the full rule)*, with `derived_from` edges back to both. B and C remain as lineage; fans are **not** cartesian-producted. *(Extended by author ruling S4-23, Phase 13b Stage 4 — **the merge ceremony**: when either side carries a fan, merging opens the W's mirror, and a merge may mint **several** takes on the fresh block — one per hand-placed **＋ pairing** (left half + right half), plus any take **carried whole**; the rest stay with the released sources in lineage as before. This is what makes divide-then-merge round-trip whole: pair 1+1 and 2+2 and the divided block comes back. **The no-cartesian rule above is untouched and is exactly why the ceremony exists — pairing is choosing by hand, never multiplying.** A fanless merge still mints exactly one take, unchanged.)*

Block size: floor is the sentence (or a single word), default is the paragraph, ceiling-less upward; **a cut may fall between any two words and at newlines, snapping to word edges with a gentle settle onto sentence ends and newlines** *(author ruling S4-22, Phase 13b Stage 4 — superseding the earlier sentence/paragraph-only snapping; one rule serves plain divide, the ceremony's per-take cuts, and extract's span edges alike. In the ceremony, a take whose cut parks at its very end rides whole into the first block — the mirror at its start — so B's and C's fans may differ in size and no take is ever left without a legal placement)*. Default segmentation of fresh text is a **document/global setting** (never bound to a UI profile), with journal posts defaulting to one-block-per-entry. **When segmentation fires (author decision):** *type-time crystallization* — brand-new text at the end of a post crystallizes into blocks paragraph-by-paragraph as you type past them (the paragraph still being typed is an open tail, not yet a block); bulk entry (paste, pool-drop, capture) segments on entry. Once a block exists, Enter inside it is pure content forever — crystallization never touches existing blocks, so I4 holds unconditionally.

## 8. Why the stack is what it is (settled; do not reopen)

- **SQLite, rows-as-truth**, via GRDB: full SQL (recursive lineage CTEs, tag subtrees, the 80%-sort), real constraints (single ownership in the DB), local-first speed, a plain exportable file.
- **Operations-as-API:** every mutation is a defined transactional operation — never ad-hoc row edits.
- **History is native to the domain, not bolted on** — commits, fans, and edges are append-only by design; event-sourcing's benefits without its tax. An optional audit log may exist later but is a derived artifact, never truth.
- **Why not documents-as-text-blobs (+ diff-recovered structure):** the foundational rejection, from the original design chat. A blob store must *recover* block identity by diffing, and positional/content diffs guess — reflow a paragraph heavily, merge two, insert a sentence mid-block, and the differ decides a block was deleted-and-recreated rather than edited. One wrong guess severs that block's version history, and persistent per-block identity is the entire foundation (timeline, fans, lineage). The fix is the app's spine: **identity is maintained live during editing** (block IDs as text attributes; the editor reports exact changed ranges), never inferred afterward. Diffing demotes to a view-time feature between two already-identified variants.
- **Why not character-level CRDTs (Automerge/Yjs-class):** character merges of prose produce word-salad; the fan/chosen-variant machinery would still be bespoke on top; history-proportional storage/compute fights P1. Conflict-as-variant is semantically better for prose — a lost race becomes a card in the fan, not interleaved sentences (SyncSpec §1).
- **Why not op-log-as-truth:** full event-sourcing tax to buy back history the domain already owns; fights P1 and row-sync engines.
- **Why not CloudKit / Core Data / SwiftData+CloudKit:** wrong shape for multi-tenant commercial; the integration forbids unique constraints, ordered relationships, restrict-deletes, recursive queries — exactly what this model needs.
- **Why not Rust:** snappiness lives on the client; SQLite is already optimal; SQLite-as-shared-substrate delivers cross-platform reuse without an FFI seam. Only real-time collaboration would justify it — and that's out of scope.
- **TextKit 2 `NSTextView`** editor core (viewport lazy layout = P1's mechanism), SwiftUI chrome. TextKit 2 is also the project's largest external risk — see `notes/TEXTKIT2_NOTES.md`, which is a first-class build companion.

## 9. How to smell a wrong design

- A feature that needs a bespoke subsystem instead of a traversal → the model has a weak spot; fix the model.
- An operation that feels tortured to express → the schema is wrong, not the operation.
- Anything tracking word-level change → out of scope by definition.
- Any UI that must be heavy while unfocused → violates P3; restructure so only the focused unit is live.
- A view that's painful to query is *information*: it's stress-testing an edge of the schema — surface it, don't work around it.
- A trigger that wants domain knowledge (dirtiness, default-variant choice, lock rules, churn) → semantics are leaking into the database. Triggers own exactly three things — tombstone propagation, outbox capture (both since Phase 1), and DERIVED-INDEX capture (13o, author ruling R-13o-4: mechanical text mirroring into the local search-index family — zero domain knowledge in a body, ever; the re-assessment record is the 13o plan's §R-13o-4 RECORD) — and anything more means an operation or the schema is mis-shaped, never that the trigger should grow. Stop and run the re-assessment protocol in the Phase 2 plan (Risks) before writing a line of it.
