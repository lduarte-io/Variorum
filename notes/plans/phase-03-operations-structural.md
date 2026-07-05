# Phase 3 — Operations II: structural (the hard core)

## Kickoff message (for a fresh session)

> You are starting **Phase 3 of Variorum** — extract, divide (single- and multi-variant W), and merge exactly right, headless, each with its undo inverse. This is the hard core the whole app was designed around; get it right here and the editor phases are wiring, not invention. Read, in order: `CLAUDE.md`, `notes/OverallModel.md` §7 (the split taxonomy — the conceptual contract), `notes/AppSpec.md` §9 (extract/divide/merge/poolDragCopy semantics — authoritative, including the two documented behaviors: restoreCommit-predates-split and fanned-extract), the **Phase 2 closeout** at the bottom of `notes/plans/phase-02-operations-lifecycle.md` (your baseline: the full non-structural ops API + undo core exist; **`swift test` = 152 green on the Air — do not re-run at session start**), and this plan. Key inherited machinery — reuse, don't rebuild: the `Operations` scaffold (`liveBlock`/`liveVariant`/`liveContainer`, `ensureUnlocked`/`ensurePlacementUnlocked`, `containerPosition` for `InsertPosition` resolution, one clock read per op), `placeBlock` (the W-reversibility primitive; refuses doubly-placed blocks), `chooseVariant`, `registerTextChange` (call it from any op that edits `working_text` — extract and single-divide do), `FractionalIndex`, and the Step 8 undo pattern (capture pre-images inside the transaction, return them out, register an **internal revert operation** after success; inverses are exact-row flips + `placeBlock`, never re-derivations). Triggers stay a closed set (tombstone propagation + outbox capture) — if any structural op seems to want a semantic trigger, stop and run the trigger-smell protocol in the Phase 2 plan's Risks. Work step by step; each step lands with tests; Domain functions get their own commits. When done, run the closeout ritual (record results here, update the master plan table + pointer, write the Phase 4 plan — read layer & perf harness — with its own kickoff message).

**Goal:** the three structural operations plus `poolDragCopy`, with boundary-snapping Domain functions, lineage edges, exhaustive state-transition tests (including W mix-and-match and both documented behaviors), and undo round-trips. Zero UI, zero queries beyond what tests need, zero sync engine.

**References:** @notes/AppSpec.md §9 (operation semantics), §7 `edge` DDL note (directionality: source = descendant, target = ancestor; `version_of` stored canonically `(min,max)` — Phase 3 mints only `derived_from`); @notes/OverallModel.md §7; Phase 2 closeout (scaffold inventory, undo pattern).

---

## Ground rules (inherited)

- Every operation = one transaction; ops never re-implement what triggers own.
- Structural ops run under the same guards as Phase 2: live targets, `ensurePlacementUnlocked` (a sealed post's structure is frozen), locked-variant rules where buffers are edited.
- Edge rows: `derived_from`, `origin_op` ∈ {'divide','merge','extract','pool_copy'}, source = the new/descendant block, target = the ancestor.
- Text-editing structural ops (extract, single-divide) call `registerTextChange` for the churn/touch stamps.
- Undo: pre-images at do-time; inverses are internal revert ops; register after the transaction succeeds; refusals leave the stack untouched.

## Steps

### Step 1 — Domain: boundary snapping
**Files:** `Sources/VariorumCore/Domain/BoundarySnapping.swift`, tests.
**Work:** pure functions over a variant's text (no GRDB): sentence- and paragraph-mark detection reusing/harmonizing with `SegmentationRules`' scanner; `snap(cut: Int, in text: String, granularity:) -> Int` (nearest sentence/paragraph boundary); span classification for extract — `extractableSpan(_ range: Range<Int>, in text: String) -> ExtractableSpan?` returning `.prefix`/`.suffix` (boundary-adjacent) or nil (middle span → the caller rejects with a typed error: that's a divide). Careful with Unicode: operate on `String.Index`/unicode scalars consistently; document the offset convention the editor will use (TextKit 2 works in UTF-16 — decide the boundary API's unit now and note it for Phase 7).
**Tests:** snapping at/near sentence marks incl. terminator runs and closing quotes; paragraph snapping on newline runs; cut at 0/end; empty text; middle-span → nil; prefix/suffix classification exact; multi-paragraph blocks.

### Step 2 — extract (source survives)
**Files:** `Sources/VariorumCore/Operations/Operations+Structural.swift`, tests.
**Work (AppSpec §9):** `extract(blockA, span)` — span must classify as boundary-adjacent prefix/suffix of A's *rendered/chosen-or-default… decide precisely: the spec says "A's active variant" = the variant the live slot renders (chosen falling back to default)*. INSERT block B + variant(text = span, trimmed consistently with `SegmentationRules`); UPDATE that one variant of A = remainder (other variants untouched); INSERT `container_block`(B) adjacent to A (before A for a prefix, after A for a suffix); edge (B derived_from A, 'extract'). Middle span → typed error. Refusals: sealed post, locked/archived rendered variant (its buffer is edited), unplaced A (extract needs adjacency — decide: refuse `blockNotPlaced`). Churn: A's container gets `registerTextChange` (delta = span length). **Fanned-extract documented behavior:** extracting from a fanned block edits only the rendered variant; other variants keep their span copy — land the test that documents duplication after a later `chooseVariant` switch (AppSpec review #10).
**Undo inverse:** pre-images: A's variant text, B's ids. Revert = restore A's variant text, tombstone B (+ its variant, placement, edge — B is fresh, so `revertExtract` can tombstone by exact ids captured at do-time). Round-trip test to row equality.

### Step 3 — divide, single-variant (the everyday cut)
**Files:** same extension, tests.
**Work:** `divide(blockA, cut)` where A's live slot renders its only active variant (the ~95% case — detect automatically; multi-variant W is a separate op below): snap/validate cut (0 < cut < length → else typed error); INSERT block C + variant(text = A[cut:]); UPDATE A's rendered variant = A[:cut] (A keeps identity as first half); INSERT `container_block`(C) immediately after A; edge (C derived_from A, 'divide'). Same refusals as extract. Churn via `registerTextChange`.
**Tests:** exact rows; A's commits untouched (**and the restoreCommit-predates-split documented test lands here**: commit A whole, divide, restoreCommit → A's buffer holds the full pre-split text while C sits next door — assert and document, editor warning owned by Phase 7 per KnownIssues); order (A then C); edge directionality; refusals.
**Undo inverse:** restore A's variant text + tombstone C (fresh ids captured at do-time).

### Step 4 — divide, multi-variant (W)
**Files:** same extension, tests.
**Work (the one ceremony):** `divideW(blockA, cuts: [variantID: cut])` — marked variants carry the cut through; unmarked stay on A as lineage. A is **preserved whole**: tombstone A's placement (release, don't delete — A stays live and unplaced), leave A's variants and commits untouched. INSERT blocks B and C; for each marked variant Vi in fan order: INSERT variant on B (text Vi[:cutᵢ]) and on C (text Vi[cutᵢ:]), fan positions preserving Vi's relative order; B/C defaults = the halves of A's rendered variant (or first marked); placements B then C where A stood (two fresh positions between A's old neighbors); edges (B derived_from A, 'divide'), (C derived_from A, 'divide'). Chosen variants on the new placements: the halves of the variant A's slot rendered, if marked; else NULL. Validate: every cut within its variant's bounds; at least one marked variant; refusals as above.
**Tests:** W mix-and-match — first-half-of-attempt-1 with second-half-of-attempt-3 via `chooseVariant` on B and C independently; unmarked variants remain on A, untouched; A live + unplaced (the unplaced-blocks query's population); reversibility: tombstone B/C placements + `placeBlock(A)` restores the reading (the promise made real); exact fan orders.
**Undo inverse:** revert = tombstone B and C (blocks + fresh children by captured ids) and un-tombstone A's exact placement row (pre-image: its id) — the Step 8 `revertDeleteBlock` placement-flip pattern.

### Step 5 — merge (mirrors W)
**Files:** same extension, tests.
**Work:** `merge(blockB, blockC)` — both live, placed **adjacently in the same container** (validate; typed error otherwise), same rendered-variant resolution. INSERT block A' + ONE variant(text = rendered(B) + separator + rendered(C) — decide the separator: "\n\n" if both multi-paragraph…? **Don't invent:** spec says "chosen(B) + chosen(C)"; concatenate exactly, no separator, and document — the author sees the raw join in the editor and adjusts). Fans are NOT cartesian-producted — A' gets exactly one variant. Release B and C's placements (tombstone; blocks stay live/unplaced as lineage); INSERT placement A' where B stood; edges (A' derived_from B, 'merge'), (A' derived_from C, 'merge').
**Tests:** exact rows; non-adjacent/cross-container refusal; non-cartesian (one variant on A'); B/C fans + commits untouched; reversibility via placeBlock; edge pair.
**Undo inverse:** tombstone A' (fresh ids), flip B and C's placement rows back.

### Step 6 — poolDragCopy
**Files:** same extension or `Operations+Pool.swift`, tests.
**Work (AppSpec §9):** `poolDragCopy(poolBlock P, to post, at, includeFan: Bool = false)` — INSERT block B; copy P's rendered variant's `working_text` into B's variant (default) — or the whole live fan when `includeFan` (fan positions/statuses copied; commits are NOT copied — lineage is coarse); INSERT placement at the drop point (chosen = copy of P's rendered variant); edge (B derived_from P, 'pool_copy'). P must live in a pool (typed error otherwise — decide whether post→post copy is in scope; spec names the pool, so refuse and note). Target post unsealed.
**Tests:** active-only vs includeFan row sets; P untouched; edge; refusals; undo (tombstone B + children by captured ids).

### Step 7 — sweep extension + closeout
**Files:** `InvariantSweepTests.swift` (extend).
**Work:** add extract/divide/divideW/merge/poolDragCopy (+ their undo) to the random op generator; predicates unchanged plus: every `derived_from` edge's origin_op ∈ the known vocabulary; released blocks (live, unplaced) never violate I10.
**Closeout:** ritual per CLAUDE.md — results here, master plan table + pointer, **Phase 4 plan + kickoff** (read layer: post render, reading assembly, lineage CTE, tag subtrees, timeline, pool, ValueObservation, 10k-block perf harness; read side tolerates referenced-but-missing rows per SyncSpec §5).

## Explicitly out of scope
Editor gestures and selection→boundary UI (Phase 9). Cross-block re-bracketing (KnownIssues, Phase 9). Queries/observation (Phase 4). The restoreCommit editor warning (Phase 7). Any UI.

## Risks / things to watch
- **The rendered-variant question recurs in every op here** (which variant does extract cut? which halves does W choose by default? what does merge concatenate?). Resolve it ONCE as a shared helper (`renderedVariant(db, blockID)` — chosen falling back to default, matching `renderedLength`'s COALESCE semantics) and test it directly.
- **Text-offset units.** Boundary snapping, cuts, and spans must agree on one unit (String.Index vs UTF-16 vs scalars) — TextKit 2 speaks UTF-16; tests must include multi-scalar graphemes (emoji, combining marks) so the convention is proven, not assumed.
- **W's fan bookkeeping** (marked/unmarked, order preservation, default/chosen on B and C) is the deepest state transition in the app — write the exact-row test FIRST for one worked example, then generalize.
- **Undo of ops that mint blocks** tombstones fresh rows by captured ids — never by stamp equality (the fresh rows never had a cascade stamp). Only placement *releases* (W, merge) flip by exact row id.
- **Trigger smell protocol** stands (Phase 2 plan, Risks) — unused in Phase 2; if a structural op wants a semantic trigger, stop and reassess before writing it.
